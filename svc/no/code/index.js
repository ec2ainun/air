const express = require('express');
const app = express();
const bodyParser = require('body-parser');
const request = require('request-promise-native')

const DOCKER_PORT = process.env.PORT || 7020
const UPSTREAM_URI = process.env.UPSTREAM_URI || 'http://worldtimeapi.org/api/timezone/Asia/Jakarta'
const SERVICE_NAME = process.env.SERVICE_NAME || 'tester-node-v1'

function headerCustom(req) {
	incoming_headers = [
		'x-request-id',
		'x-b3-traceid',
		'x-b3-spanid',
		'x-b3-parentspanid',
		'x-b3-sampled',
		'x-b3-flags',
		'x-ot-span-context',
		'x-dev-user',
		'fail'
	]
	let headers = {}
	for (let h of incoming_headers) {
		if (req.header(h))
			headers[h] = req.header(h)
	}
	return headers
}

function openIssues(req) {
	const failPercent = Number(req.header('fail')) || 0
	if (Math.random() < failPercent) {
		return 'fail'
	}
}

app.get('/', async function (req,res) {
    try {
        let waktuInit = Date.now()
        if (openIssues(req)=='fail'){
            res.status(500).end()
        }else{
            const headers = headerCustom(req)
            let kirim = await request({
                url: UPSTREAM_URI,
                headers: headers
            })
            let lama = (Date.now() - waktuInit)
            res.status(200).header(headers).end(`${SERVICE_NAME} -> ${lama} ms\n${UPSTREAM_URI} -> ${kirim}`);
        }
    } catch (err) {
        res.json({success: false, msg: err.message});
    }
});

app.get('/hello', async function (req,res) {
    try {
        res.status(200).json({
            hello: 'world'
        });
    } catch (err) {
        res.json({success: false, msg: err.message});
    }
});

var server = app.listen(DOCKER_PORT, function () {
   var host = server.address().address
   var port = server.address().port
   console.log("app listening at http://%s:%s", host, port)
})