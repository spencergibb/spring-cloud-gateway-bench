//Simple Web Application designed to test the performance of some Gateway implementations.
//Author: @spencerbgibb
//Author: @juanantoniobm

package main

import (
    "log"
    "fmt"
    "net/http"
    "runtime"
    "io/ioutil"
)

//Define the port used for this web application
var SERVER_PORT = ":8000"

//Read the content of a file
func serveContent(file string) string {
    b, err := ioutil.ReadFile(file)
    if err != nil {
        log.Print(err)
        return "{error:\"Resource not found\"}"
    }
    str := string(b)
    return str
}

//REST handler
func handler(w http.ResponseWriter, r *http.Request) {
    log.Print("Processing request: ", r.URL.Path[1:])
    str := serveContent(r.URL.Path[1:])
    fmt.Fprintf(w, str)
}

//Main program
func main() {
    runtime.GOMAXPROCS(runtime.NumCPU())
    log.Print("Starting webserver on Port", SERVER_PORT)
    http.HandleFunc("/", handler)
    http.ListenAndServe(SERVER_PORT, nil)
}
