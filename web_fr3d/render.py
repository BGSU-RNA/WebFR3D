import simplejson as json

from flask import render_template


def to_html(**data):
    template = data.pop('template', data.get('status', 'unknown') + '.html')
    return render_template(template, **data)


def to_json(data):
    if 'template' in data:
        del data['template']

    return json.dumps(data)
