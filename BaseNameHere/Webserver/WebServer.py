## This will be the home to the webserver that will provide the API for the base computers to make calls to.

### Module Import ###
import flask
from flask import request, jsonify
import Database 


app = flask.Flask(__name__)




app.run()