
mkdir build
env GOOS=linux GOARCH=amd64 go build -o build/main books
zip -j build/main.zip build/main

#setup
aws iam create-role --role-name lambda-books-executor --assume-role-policy-document file://aws/trust-policy.json

aws iam attach-role-policy --role-name lambda-books-executor --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

aws lambda create-function --function-name books --runtime go1.x \
--role arn:aws:iam::account-id:role/lambda-books-executor \
--handler main --zip-file fileb://build/main.zip

aws dynamodb create-table --table-name Books \
--attribute-definitions AttributeName=ISBN,AttributeType=S \
--key-schema AttributeName=ISBN,KeyType=HASH \
--provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5

aws iam put-role-policy --role-name lambda-books-executor \
--policy-name dynamodb-item-crud-role \
--policy-document file://aws/privilege-policy.json

aws apigateway create-rest-api --name bookstore

#aws apigateway create-resource --rest-api-id rest-api-id --parent-id root-path-id --path-part books

#aws apigateway put-method --rest-api-id rest-api-id --resource-id resource-id --http-method ANY --authorization-type NONE

#aws apigateway create-deployment --rest-api-id rest-api-id  --stage-name staging

#aws lambda add-permission --function-name books --statement-id 20181202051120 --action lambda:InvokeFunction --principal apigateway.amazonaws.com --source-arn arn:aws:execute-api:ap-southeast-2:373828124123:fmama3l144/*/*/*
#aws apigateway test-invoke-method --rest-api-id fmama3l144 --resource-id 2t8iqg --http-method "GET" --path-with-query-string "/books?isbn=978-1420931693"