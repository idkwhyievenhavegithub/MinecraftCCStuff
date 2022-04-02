from flask import Flask, jsonify, request
import json
import beets.ui
import beets.library
from flask import Flask, send_file
from pydub import AudioSegment
import os
import base64
MusicLib = beets.library.Library(path="music.db")
app = Flask(__name__)

def cleanup(word):
        clean_title = word
        if "'" in word:
            clean_title = clean_title.title.replace("'", "")
        if '"' in word:
            clean_title = clean_title.replace('"', "")
        if "(" in word:
            clean_title = clean_title.replace("(", "")
        if ")" in word:
            clean_title = clean_title.replace(")", "")
        if "’" in word:
            clean_title = clean_title.replace("’", "")
        return clean_title


@app.route('/')
def index():
    return "Hello, World!"
@app.route('/api/<var>')
def varroute(var):
    return str(var)
@app.route('/song', methods=['POST','GET'])
def getsong():
    if request.method == 'GET':
        return "<h1>This is an API endpoint. Please use POST to access it</h1>"
    query = json.loads(request.data)["query"]
    song_res = MusicLib.items(query)
    if not song_res:
        print("one")
        return """{"error": "404"}"""
    else:
        song = song_res[0]
        for songsearch in song_res:
            if query.lower() in songsearch.title.lower():
                song = songsearch
        for songsearch in song_res:
            if songsearch.title.lower() == query.lower():
                song = songsearch
        sound = AudioSegment.from_file(song.path)
        sound.export("audio.wav", format="wav")
        os.system("java -jar LionRay.jar audio.wav")
        print(cleanup(song.title))
        print(cleanup(song.artist))
        print(cleanup(song.album))
        song_info = [{
            "error": "200",
            "title": cleanup(song.title),
            "artist": cleanup(song.artist),
            "album": cleanup(song.album),
            "time": song.length
        }]
        return jsonify(song_info)
@app.route('/audio')
def audio():
    return send_file("audio.wav.dfpwm")


    
app.run(host='192.168.23.30')