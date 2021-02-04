echo '123456789012345789'

pwd

cd $FOLDER_PATH

aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

docker build -t backend_auth .

docker tag backend_auth:latest $REPO_URL:latest

docker push $REPO_URL:latest
