import express from 'express';
import axios from 'axios';

const app = express();

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

app.listen(8090, () => console.log('started at port 8090'));
