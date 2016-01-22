#!/usr/bin/env python

import logging
import argparse

from simplejson import json

from web_fr3d.background import worker


class Worker(worker.Worker):
    def process(self, query):
        self.logger.info('Working on %s', query['id'])
        return []


def main(config_file):
    with open(config_file, 'rb') as raw:
        config = json.load(raw)

    worker = Worker(config, **config['worker'])
    worker()


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Background worker for FR3D")
    parser.add_option("id", dest="id",
                      help="ID of this worker")
    parser.add_option("--config", dest='config',
                      help="Config file to load")
    parser.add_option("--log-level", dest='log_level', default='info',
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
