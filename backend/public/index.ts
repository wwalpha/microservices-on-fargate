import express from 'express';
import axios from 'axios';

const app = express();

// health check
app.get('/', (_, res) => res.status(200).send());
// public service
app.get('/api/public', (_, res) => res.send('Hello world'));
// private service
app.get('/api/private', async (_, res) => {
  try {
    const response = await axios.get('http://private.backend.microservice.local/endpoint');

    res.send(response.data);
  } catch (err) {
    console.log(err);
  }
});

app.listen(8080, () => console.log('started at port 8080'));
