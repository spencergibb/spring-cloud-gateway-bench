#!/bin/bash
# A Bash script to execute a Benchmark about implementation of Gateway pattern for Spring Cloud

echo "Gateway Benchmark Script"

OSX="OSX"
WIN="WIN"
LINUX="LINUX"
UNKNOWN="UNKNOWN"
PLATFORM=$UNKNOWN

function detectOS() {

    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        PLATFORM=$LINUX
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        PLATFORM=$OSX
    elif [[ "$OSTYPE" == "cygwin" ]]; then
        PLATFORM=$WIN
    elif [[ "$OSTYPE" == "msys" ]]; then
        PLATFORM=$WIN
    elif [[ "$OSTYPE" == "win32" ]]; then
        PLATFORM=$WIN
    else
        PLATFORM=$UNKNOWN
    fi

    echo "Platform detected: $PLATFORM"
    echo

    if [ "$PLATFORM" == "$UNKNOWN" ]; then
        echo "Sorry, this platform is not recognized by this Script."
        echo
        echo "Open a issue if the problem continues:"
        echo "https://github.com/spencergibb/spring-cloud-gateway-bench/issues"
        echo
        exit 1
    fi

}

function detectGo() {

    if type -p go; then
        echo "Found Go executable in PATH"
    else
        echo "Not found Go installed"
        exit 1
    fi

}

function detectJava() {

    if type -p java; then
        echo "Found Java executable in PATH"
    else
        echo "Not found Java installed"
        exit 1
    fi

}

function detectMaven() {

    if type -p mvn; then
        echo "Found Maven executable in PATH"
    else
        echo "Not found Java installed"
        exit 1
    fi

}

function detectWrk() {

    if type -p wrk; then
        echo "Found wrk executable in PATH"
    else
        echo "Not found wrk installed"
        exit 1
    fi

}

function setup(){

    detectOS

    detectGo
    detectJava
    detectMaven

    detectWrk

    mkdir -p reports
    rm ./reports/*.txt
}

setup

#Launching the different services

function runStatic() {

    cd static
    if [ "$PLATFORM" == "$OSX" ]; then
        GOOS=darwin GOARCH=amd64 go build -o webserver.darwin-amd64 webserver.go
        ./webserver.darwin-amd64
    elif [ "$PLATFORM" == "$LINUX" ]; then
        echo "Googling"
        exit 1
    elif [ "$PLATFORM" == "$WIN" ]; then
        echo "Googling"
        exit 1
    else
        echo "Googling"
        exit 1
    fi

}

function runZuul() {

    echo "Running Gateway Zuul"

    cd zuul
    ./mvnw clean package
    java -jar target/zuul-0.0.1-SNAPSHOT.jar
}

function runGateway() {

    echo "Running Spring Gateway"

    cd gateway
    ./mvnw clean package
    java -jar target/gateway-0.0.1-SNAPSHOT.jar
}

function runLinkerd() {

    echo "Running Gateway Linkerd"

    cd linkerd
    java -jar linkerd-1.3.4.jar linkerd.yaml
}

# trap ctrl-c and call ctrl_c()
trap ctrl_c INT

function ctrl_c() {
        echo "** Trapped CTRL-C"
        kill $(ps aux | grep './webserver.darwin-amd64' | awk '{print $2}')
        pkill java
        exit 1
}

#Run Static web server
runStatic &

echo "Wait 10"
sleep 10

function runGateways() {

    echo "Run Gateways"
    runZuul &
    runGateway &
    runLinkerd &

}

runGateways

#Execute performance tests

function warnup() {

    echo "JVM Warnup"

    for run in {1..10}
    do
      wrk -t 10 -c 200 -d 30s http://localhost:8082/hello.txt >> ./reports/gateway.txt
    done

    for run in {1..10}
    do
      wrk -H "Host: web" -t 10 -c 200 -d 30s http://localhost:4140/hello.txt >> ./reports/linkerd.txt
    done

    for run in {1..10}
    do
      wrk -t 10 -c 200 -d 30s http://localhost:8081/hello.txt >> ./reports/zuul.txt
    done
}

function runPerformanceTests() {

    echo "Static results"
    wrk -t 10 -c 200 -d 30s  http://localhost:8000/hello.txt > ./reports/static.txt

    echo "Wait 60 seconds"
    sleep 60

    warnup
}

runPerformanceTests

ctrl_c
echo "Script Finished"
