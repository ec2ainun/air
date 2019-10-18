from flask import Flask, request
import sys, flask, requests, os, json, datetime, traceback, random

app = Flask(__name__)
HOST = os.getenv("HOST", '0.0.0.0')
DOCKER_PORT = os.getenv('PORT', '7020')
UPSTREAM_URI = os.getenv('UPSTREAM_URI', 'http://worldtimeapi.org/api/timezone/Asia/Jakarta')
SERVICE_NAME = os.getenv('SERVICE_NAME', 'tester-python-v1')

def headerCustom(request):
    incoming_headers = [
        'x-request-id',
		'x-b3-traceid',
		'x-b3-spanid',
		'x-b3-parentspanid',
		'x-b3-sampled',
		'x-b3-flags',
		'x-ot-span-context',
		'x-dev-user',
		'fail',
    ]
    headers = {}
    for h in incoming_headers:
        if request.headers.get(h):
            headers[h] = request.headers.get(h)
            
    return headers
    
def openIssues(request):
    if request.headers.get('fail'):
        failPercent = float(request.headers.get('fail'))
        if (random.random() < failPercent):
            return 'fail'
    
    
@app.route("/")
def hello():
    waktuInit= datetime.datetime.now()
    if openIssues(request)== 'fail':
        return flask.Response(status=500)
    headers={}
    kirim=''
    try:
        headers = headerCustom(request)
        kirim=requests.get(UPSTREAM_URI, headers=headers)
        kirim=kirim.content.decode("utf-8")
    except Exception:
        traceback.print_exc()
        
    lama = (datetime.datetime.now()-waktuInit).total_seconds() * 1000.0
    printData = SERVICE_NAME+' -> '+str(lama)+' ms\n'+UPSTREAM_URI+' -> '+kirim
    return flask.Response(printData, headers=headers, status=200, mimetype='application/json')

@app.route("/hello", methods=['POST','PUT','GET','DELETE'])
def hai():
    response_data = {}
    if request.method == 'GET':
        response_data["hello"] ="world!"
    
    return flask.Response(json.dumps(response_data), status=200, mimetype='application/json')
 
if __name__ == "__main__":
    app.run(host=HOST, port=DOCKER_PORT)