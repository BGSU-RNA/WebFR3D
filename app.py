from flask import Flask
from flask import request
from flask import g
from flask import redirect
from flask import url_for

import mimerender

import web_fr3d

app = Flask(__name__, static_url_path='/web-fr3d/static')
mimerender = mimerender.FlaskMimeRender()

# TODO: Should we use flask-sqlachemly? Seems to do most of what we need


@app.before_request
def before_request():
    """Run before any request to get a connection to the queue and eventually
    the database.
    """
    # g.queue = web_fr3d.background.Queue(app.config)
    pass


@app.teardown_request
def teardown_request(exception):
    """Run after each request to close the connection to the queue or database.
    """
    queue = getattr(g, 'queue', None)
    if queue is not None:
        queue.close()


@app.route("/web-fr3d", methods=['GET', 'POST'])
@mimerender(
    html=web_fr3d.render.to_html,
    json=web_fr3d.render.to_json,
    override_input_key='format',
)
def index():
    """Route for building the search page.
    """
    data = {}
    # data = web_fr3d.db.default_info(g.db)
    # data['query'] = web_fr3d.utils.santize_query(request.args)
    # if request.method == 'POST':
    #     data['query'] = web_fr3d.utils.santize_query(request.form)
    data['template'] = 'index.html'
    return data


@app.route("/web-fr3d/search", methods=['POST'])
@mimerender(
    html=web_fr3d.render.to_html,
    json=web_fr3d.render.to_json,
    override_input_key='format',
)
def search():
    """This url response is where data is sent for searches.
    """
    data = request.form
    try:
        data = web_fr3d.utils.santize_search(data)
        web_fr3d.background.queue.process(data)
        return redirect(url_for('results', id=data['id']))
    except web_fr3d.utils.ValidationError:
        data['status'] = 'invalid'
    except:
        data['status'] = 'failed'
    return data


@app.route("/web-fr3d/results/:id", methods=['GET'])
@mimerender(
    html=web_fr3d.render.to_html,
    json=web_fr3d.render.to_json,
    override_input_key='format',
)
def result(query_id):
    return {'status': 'succeeded', 'msg': 'Implement me'}


if __name__ == '__main__':
    app.run(debug=True)
