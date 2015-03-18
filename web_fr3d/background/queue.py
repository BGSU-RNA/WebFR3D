import beanstalkc
import simplejson as json

from web_fr3d.db import fr3d


class Queue(object):

    def __init__(self, db, config):
        self.beanstalk = beanstalkc.Connection(**config['queue']['connection'])
        self.beanstalk.use(config['queue']['name'])
        self.beanstalk.ignore('default')
        self.fr3d = fr3d.Database(config)

    def process(self, data):
        if self.fr3d.known(data):
            return self.result(data['id'])

        data['status'] = 'pending'
        self.fr3d.store(data)
        self.beanstalk.put(json.dumps(data))

        return data

    def result(self, query_id):
        return self.fr3d.result(query_id)
