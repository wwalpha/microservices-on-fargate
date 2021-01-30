import express from 'express';
import axios from 'axios';

const app = express();

// health check
app.get('/', (_, res) => res.status(200).send());
// private endpoint
app.get('/endpoint', async (_, res) => {
  try {
    const response = await axios.get('http://localhost:51678/v1/metadata');

    console.log(response.data);

    res.send(response.data);
  } catch (err) {
    console.log(err);
    res.send('private task');
  }
});

app.listen(8090, () => console.log('started at port 8090'));
