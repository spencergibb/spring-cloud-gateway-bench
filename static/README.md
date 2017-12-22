## Compile webserver

### linux
`go build -o webserver webserver.go`

### Mac
`GOOS=darwin GOARCH=amd64 go build -o webserver.darwin-amd64 webserver.go`