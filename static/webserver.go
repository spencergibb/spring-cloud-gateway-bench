package main

import (
	 "log"
    "net/http"
    "runtime"
)

func main() {
	 log.Print("Starting webserver...")
    runtime.GOMAXPROCS(runtime.NumCPU())
    server := http.FileServer(http.Dir("."))
    log.Print(http.ListenAndServe(":8000", server))
}
