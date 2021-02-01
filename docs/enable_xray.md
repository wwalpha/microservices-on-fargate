# Enable XRay for Express

## Express

```typescript
import AWSXRay from 'aws-xray-sdk';
import express from 'express';

const app = express();
const XRayExpress = AWSXRay.express;

AWSXRay.captureHTTPsGlobal(http, true);

// add first
app.use(XRayExpress.openSegment('site-name'));

// health check
app.get('/', (_, res) => res.status(200).send());

// add last
app.use(XRayExpress.closeSegment());

app.listen(8080, () => console.log('started at port 8080'));
```

## Task Definition

Add xray daemon to task definition.

```JSON
[
  ...
  {
    "name": "xray-daemon",
    "image": "amazon/aws-xray-daemon",
    "cpu": 32,
    "memoryReservation": 256,
    "portMappings": [
      {
        "containerPort": 2000,
        "protocol": "udp"
      }
    ]
  }
]
```

## Task Execution Role

Add `AWSXRayDaemonWriteAccess` policy to task execution role.
