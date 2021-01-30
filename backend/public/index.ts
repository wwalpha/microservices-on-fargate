import express from 'express';
import axios from 'axios';

const app = express();

// health check
app.get('/', (_, res) => res.status(200).send());
// public service
app.get('/api/public', (_, res) => res.send('Hello world'));
// private service
app.get('/api/private', async (_, res) => {
  const response = await axios.get('http://xxxx/endpoint');

  res.send(response.data);
});

app.listen(8080, () => console.log('started at port 8080'));
