env GOOS=linux GOARCH=amd64 go build -o build/main
zip -j build/main.zip build/main
aws.cmd lambda update-function-code --function-name books --zip-file fileb://build/main.zip