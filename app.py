import json

from flask import Flask
from flask import request
from flask import g
from flask import redirect
from flask import url_for

import db
import utils

app = Flask(__name__)


@app.before_request
def before_request():
    g.db = db.connect()
    if not hasattr(g, 'beanstalk'):
        g.beanstalk = db.beanstalk()


@app.teardown_request
def teardown_request(exception):
    db = getattr(g, 'db', None)
    if db is not None:
        db.close()


@app.route("/", methods=['GET', 'POST'])
def index():
    data = db.default_info(g.db)
    data['given'] = utils.santize_given(request.args)
    if request.method == 'POST':
        data['given'] = utils.santize_given(request.form)
    return render_template('index.html', data=data)


@app.route("/search", methods=['POST'])
def search():
    data = request.form
    try:
        data = utils.santize_search(data)
        db.store(g.db, data)
        g.beanstalk.put(json.dumps(data))
        return redirect(url_for('results', id=data['id']))
    except utils.ValidationError:
        return render_template("invalid.html", data=data)
    except:
        return render_template('failed.html', data=data)


@app.route("/results/:id", method=['GET'])
def result(id):
    data = db.result(g.db, id)
    if data['status'] == 'complete':
        return render_template('results/complete.html', data=data)
    if data['status'] == 'pending':
        return render_template('results/pending.html', data=data)
    if data['status'] == 'failed':
        render_template('results/failed.html', data=data)
    return render_template('unknown.html', data=data)


if __name__ == '__main__':
    app.run()
