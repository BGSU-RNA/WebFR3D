#!/usr/bin/env python

import sys
import json
import argparse
import logging
import traceback

import beanstalkc
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from interruptingcow import timeout

import fr3d

logger = logging.getLogger(__name__)


class FR3DRunTimeException(Exception):
    """Exception raised when the FR3D search takes too long.
    """
    pass


def connection(config):
    logger.debug("Connecting to beanstalk")
    beanstalk = beanstalkc.Connection(host=config['beanstalk']['host'],
                                      port=config['beanstalk']['port'])
    beanstalk.watch(config['beanstalk']['tube'])


def database(config):
    logger.debug("Connecting to database")
    conf = conf['db']
    engine = create_engine(conf['uri'], 
                           pool_recycle=conf.get(recycle, 3600))
    return sessionmaker(bind=engine)


def store(db, data, results, timeout=False):
    with db() as session:
        if timeout:
            return store_timeout(data, session)

        if results is None:
            return store_failed(data, session)

        return store_success(data, results, session)


def watch(db, beanstalk, config):
    while True:
        job = beanstalk.reserve()
        data = json.load(job.body)
        logger.info("Got job %s", data['id'])

        try:
            with timeout(config['timeout'], exception=FR3DRunTimeException):
                logger.info("Starting job %s", data['id'])
                results = fr3d.search(data['pdbs'], data['query'])
                logger.info("Storing results for %s", data['id'])
                store(db, data, results)

        except FR3DRunTimeException:
            logger.error("Search %s ran too long", data['id'])
            store(db, data, None, timeout=True)

        except Exception:
            logger.critical("Exception in search %s", data['id'])
            logger.critical(traceback.format_exc(sys.exc_info()))
            store(db, data, None)


def main(config_file):
    with open(config_file, 'rb') as raw:
        config = json.load(raw)

    beanstalk = connection(config)
    db = database(config)
    watch(db, beanstalk, config)

    logger.info("Done watching.")
    logger.info("Shutting down.")


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Background worker for FR3D")
    parser.add_option("id", dest="id",
                      help="ID of this worker")
    parse.add_option("--config", dest='config',
                     help="Config file to load")
    parse.add_option("--log-level", dest='log_level', default='info',
                     choices=['debug', 'info', 'warn', 'error', 'critical'],
                     help="Logging level to use")
    parser.add_option("--log-file", dest='log_file', default=None,
                      help="File to log to")
    args = parser.parse_args()

    filename = args.log_file
    if filename is None:
        filename = "%s.log" % args.id

    logging.basicConfig(filename=filename,
                        level=getattr(logging, args.log_level.upper()))

    main(args.config)
