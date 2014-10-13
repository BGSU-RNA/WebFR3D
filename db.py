import beanstalkc
import sqlalchemy as sa


def beanstalk(config):
    beanstalk = beanstalkc.Connection(host=config['beanstalk']['host'],
                                      port=config['beanstalk']['port'])
    beanstalk.use(config['beanstalk']['tube'])
    beanstalk.ignore('default')
    return beanstalk


def connect(config):
    engine = sa.create_engine(config['db']['uri'])


def defalt_info(connection):
    return {'known': []}


def store(connection, data):
    pass


def result(connection, id):
    pass
