import AWSXRay from 'aws-xray-sdk';
import express from 'express';
import axios from 'axios';

const app = express();
const XRayExpress = AWSXRay.express;

app.use(XRayExpress.openSegment('backend-api'));

// health check
app.get('/', (_, res) => res.status(200).send());
// public service
app.get('/api/local', (_, res) => res.send('Hello world'));
// backend auth service
app.get('/api/auth', async (_, res) => {
  try {
    const response = await axios.get('http://auth.backend.microservice.local:8090/endpoint');

    res.send(response.data);
  } catch (err) {
    console.log(err);
  }
});

// backend worker service
app.get('/api/worker', async (_, res) => {
  try {
    const response = await axios.get('http://worker.backend.microservice.local:8090/endpoint');

    res.send(response.data);
  } catch (err) {
    console.log(err);
  }
});

app.use(XRayExpress.closeSegment());

app.listen(8080, () => console.log('started at port 8080'));
