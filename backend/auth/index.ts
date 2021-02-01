import AWSXRay from 'aws-xray-sdk';
import express from 'express';
import axios from 'axios';

const app = express();
const XRayExpress = AWSXRay.express;

app.use(XRayExpress.openSegment('backend-auth'));

// health check
app.get('/', (_, res) => res.status(200).send());
// private endpoint
app.get('/endpoint', async (_, res) => {
  try {
    const response = await axios.get(`${process.env.ECS_CONTAINER_METADATA_URI_V4}/task`);

    console.log(response.data);

    const taskInfo = response.data;
    const taskId = (taskInfo.TaskARN as string).split('/')[2];

    res.send(`TaskId: ${taskId}`);
  } catch (err) {
    console.log(err);
    res.send('private task2');
  }
});

app.use(XRayExpress.closeSegment());

app.listen(8090, () => console.log('started at port 8090'));
