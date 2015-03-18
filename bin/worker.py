#!/usr/bin/env python

import json
import argparse
import logging
import subprocess as sp

from web_fr3d.background import worker


class Worker(worker.Worker):
    def filename(self, query):
        pass

    def generate_file(self, raw, query):
        raw.write("Query.Name = '%s';\n" % query['id'])
        raw.write("Query.Geometric = %i;" % int(query['geometric']))
        raw.write("Query.ExcludeOverlap = 1;\n")
        raw.write("Query.NumNT = '%i';\n" % query['size'])
        raw.write("Query.SearchFiles = {};")

        for index, sequence in enumerate(query['nts']):
            raw.write("Query.Diagonal{%i} = '%s';\n" %
                      index + 1, sequence)

            for row, columns in enumerate(query['diff']):
                for col, entry in enumerate(columns):
                    raw.write("Query.Diff{%i,%i} = '%s';\n" %
                              row + 1, col + 1, entry)

            for row, columns in enumerate(query['edges']):
                for col, constraint in enumerate(columns):
                    raw.write("Query.Edges{%i,%i} = '%s';\n" %
                              row + 1, col + 1, constraint)

        raw.write("aListCandidates;\n")

    def results(self):
        pass

    def process(self, query):
        filename = self.filename(query)
        with open(filename, 'rb') as raw:
            self.generate_file(raw, query)
        # TODO: Clean up in the case of a timeout.
        sp.check_call([self.matlab, filename])
        return self.results()


def main(config_file):
    with open(config_file, 'rb') as raw:
        config = json.load(raw)

    worker = Worker(config, matlab=config['matlab'])
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
