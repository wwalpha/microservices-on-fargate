import express from 'express';

const app = express();

// health check
app.get('/', (_, res) => res.status(200).send());
// public service
app.get('/public', (_, res) => res.send('Hello world'));
// private service
app.get('/private', (_, res) => res.send('Hello world'));

app.listen(8080, () => console.log('started at port 8080'));
