import AWSXRay from 'aws-xray-sdk';
import express from 'express';
import axios from 'axios';
import http from 'http';

const app = express();
const XRayExpress = AWSXRay.express;

AWSXRay.captureHTTPsGlobal(http, true);

app.use(XRayExpress.openSegment('backend-public'));

// health check
app.get('/', (_, res) => res.status(200).send());
// public service
app.get('/api/public', (_, res) => res.send('Hello world'));
// private service
app.get('/api/private', async (_, res) => {
  try {
    const response = await axios.get('http://private.backend.microservice.local:8090/endpoint');

    res.send(response.data);
  } catch (err) {
    console.log(err);
  }
});

// private service with alb
app.get('/api/private-with-alb', async (_, res) => {
  try {
    const response = await axios.get(
      'http://internal-onecloud-fargate-private-828171989.ap-northeast-1.elb.amazonaws.com:8090/endpoint'
    );

    res.send(response.data);
  } catch (err) {
    console.log(err);
  }
});

app.use(XRayExpress.closeSegment());

app.listen(8080, () => console.log('started at port 8080'));
