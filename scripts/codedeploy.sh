#!/usr/bin/env bash

./staging-pipleline-build.sh

# Get the environment.
readonly ENV="dev"
readonly APPLICATION_NAME="app"
echo "The environment is ${ENV}"

readonly CODE_DEPLOY_APP_NAME="Ec2-CodeDeploy-$ENV-$APPLICATION_NAME-Application"
echo "Application is ${CODE_DEPLOY_APP_NAME}"

readonly CODE_DEPLOY_DEPLOYMENT_GROUP_NAME="$ENV-$APPLICATION_NAME"

readonly GIT_HASH=$(git rev-parse --verify HEAD)
readonly S3_BUCKET="$ENV-$APPLICATION_NAME-code-deploy"
readonly S3_FIlE_NAME="SM-$APPLICATION_NAME-$GIT_HASH-$(date +%s).zip"

echo "Moving Composer and Node files to /tmp will be copied after the code is sent"
mv webroot/vendor /tmp/${CODE_DEPLOY_APP_NAME}_vendor;
mv current_frontend/node_modules /tmp/${CODE_DEPLOY_APP_NAME}_node_modules;

echo "Deploying hash: ${GIT_HASH} to s3://${S3_BUCKET}/${S3_FIlE_NAME} "

readonly CODE_DEPLOY_RESULTS=$(aws deploy push --application-name $CODE_DEPLOY_APP_NAME \
--s3-location s3://$S3_BUCKET/$S3_FIlE_NAME \
--source webroot)

echo $CODE_DEPLOY_RESULTS;

readonly CODE_DEPLOY_DEPLOYMENT_RESULTS=$(aws deploy create-deployment --application-name $CODE_DEPLOY_APP_NAME \
 --s3-location bucket=dev-app-code-deploy,key=$S3_FIlE_NAME,bundleType=zip \
 --deployment-group-name $CODE_DEPLOY_DEPLOYMENT_GROUP_NAME)

echo $CODE_DEPLOY_DEPLOYMENT_RESULTS

mv /tmp/${CODE_DEPLOY_APP_NAME}_vendor webroot/vendor
mv /tmp/${CODE_DEPLOY_APP_NAME}_node_modules current_frontend/node_modules
