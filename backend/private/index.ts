import express from 'express';

const app = express();

// health check
app.get('/', (_, res) => res.status(200).send());
// private endpoint
app.get('/endpoint', (_, res) => res.send('private task'));

app.listen(8090, () => console.log('started at port 8090'));
