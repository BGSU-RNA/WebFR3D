from flask import Flask
from flask import request
from flask import g
from flask import redirect
from flask import url_for

import mimerender

import web_fr3d as fr3d

app = Flask(__name__)
mimerender = mimerender.FlaskMimeRender()

# TODO: Should we use flask-sqlachemly? Seems to do most of what we need


@app.before_request
def before_request():
    g.queue = fr3d.background.Queue(app.config)


@app.teardown_request
def teardown_request(exception):
    queue = getattr(g, 'queue', None)
    if queue is not None:
        queue.close()


@app.route("/", methods=['GET', 'POST'])
@mimerender(
    html=fr3d.render.to_html,
    json=fr3d.render.to_json,
    override_input_key='format',
)
def index():
    data = fr3d.db.default_info(g.db)
    data['query'] = fr3d.utils.santize_query(request.args)
    if request.method == 'POST':
        data['query'] = fr3d.utils.santize_query(request.form)
    data['template'] = 'index.html'
    return data


@app.route("/search", methods=['POST'])
@mimerender(
    html=fr3d.render.to_html,
    json=fr3d.render.to_json,
    override_input_key='format',
)
def search():
    data = request.form
    try:
        data = fr3d.utils.santize_search(data)
        fr3d.background.queue.process(data)
        return redirect(url_for('results', id=data['id']))
    except fr3d.utils.ValidationError:
        data['status'] = 'invalid'
    except:
        data['status'] = 'failed'
    return data


@app.route("/results/:id", method=['GET'])
@mimerender(
    html=fr3d.render.to_html,
    json=fr3d.render.to_json,
    override_input_key='format',
)
def result(id):
    return fr3d.queue.result(id)


if __name__ == '__main__':
    app.run()
