export AWS_REGION=${aws region}
export AWS_ACCOUNT_ID=${aws account id}

aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

docker pull nginx

docker tag nginx:latest
