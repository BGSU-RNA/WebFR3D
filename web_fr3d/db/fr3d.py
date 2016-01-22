from flask.ext.sqlalchemy import SQLAlchemy

# TODO: Reflect all models?
# Other databases are managed outside webapps so they don't shouldn't have
# models defined inside them, this one may. Not clear.
# TODO: Add a utility class to handle all the inserting/updating/etc logic.


class Fr3d(object):
    def __init__(self, db):
        pass

    def known(self, query_id):
        pass

    def insert(self, data):
        pass

    def update(self, data):
        pass
