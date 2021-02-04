[
  {
    "name": "${container_name}",
    "image": "${container_image}",
    "essential": true,
    "cpu": 0,
    "environment": [],
    "mountPoints": [],
    "volumesFrom": [],
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80,
        "protocol": "tcp"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/${container_name}",
        "awslogs-region": "${aws_region}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]