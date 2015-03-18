import abc
import uuid
import logging

import beanstalkc
import simplejson as json
from interruptingcow import timeout


class WorkTimeOutException(Exception):
    """This is an exception that is raise if the processing stage takes too
    long.
    """
    pass


class Worker(object):
    """A base class for background workers. This provides the basic logic for
    getting jobs from beanstalk and storing them in the database. This
    has a process() method which should implement the needed processing steps.
    """

    __metaclass__ = abc.ABCMeta

    def __init__(self, config, **kwargs):
        self.store = None
        self.beanstalk = beanstalkc.Connection(**config['queue']['connection'])
        self.beanstalk.watch(config['queue']['name'])
        self.beanstalk.ignore('default')

        self.name = kwargs.get('name', str(uuid.uuid4()))
        self.logger = logging.getLogger('queue.Worker:%s' % self.name)

        for key, value in kwargs.items():
            setattr(self, key, value)

    @abc.abstractmethod
    def process(self, query):
        pass

    def save(self, result, status='failed'):
        self.logger.debug("Updating results for %s", result['id'])
        info = dict(result)
        info['status'] = status
        self.store.update(info)

    def work(self, job, query):
        self.logger.debug("Working on query %s", query['id'])
        self.save(query, status='pending')

        try:
            with timeout(self.timeout, exception=WorkTimeOutException):
                result = self.process(query)
            self.logger.debug("Done working on %s", query['id'])
            self.save(result, status='succeeded')

        except WorkTimeOutException:
            self.logger.warning("Timeout with %s", query['id'])
            self.save(query, status='timeout')
            job.delete()

    def __call__(self):
        self.logger.info("Starting worker %s", self.name)

        while True:
            job = self.beanstalk.reserve()
            job.bury()

            try:
                query = json.loads(job.body)
                self.work(job, query)

            except Exception as err:
                self.logger.error("Error working with %s", query['id'])
                self.logger.exception(err)
                query['reason'] = 'Server Error'
                self.save(query, status='failed')
                job.delete()
