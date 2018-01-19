Spring Cloud Gateway Benchmark
=======

TL;DR

Proxy | Avg Latency | Avg Req/Sec/Thread
-- | -- | -- 
gateway | 6.61ms | 3.24k
linkered | 7.62ms | 2.82k
zuul | 12.56ms | 2.09k
none | 2.09ms | 11.77k

## Terminal 1 (simple webserver)

```bash
cd static
./webserver # or ./webserver.darwin-amd64 on a mac
```

## Terminal 2 (zuul)
```bash
cd zuul
./mvnw clean package
java -jar target/zuul-0.0.1-SNAPSHOT.jar 
```

## Terminal 3 (gateway)
```bash
cd gateway
./mvnw clean package
java -jar target/gateway-0.0.1-SNAPSHOT.jar 
```

## Terminal 4 (linkerd)
```bash
cd linkerd
java -jar linkerd-1.3.4.jar linkerd.yaml
```

## Terminal N (wrk)

### install `wrk`
Ubuntu: `sudo apt install wrk`

Mac: `brew install wrk`

NOTE: run each one multiple times to warm up jvm

### Gateway bench (8082)
```bash
$ wrk -t 10 -c 200 -d 30s http://localhost:8082/hello.txt
Running 30s test @ http://localhost:8082/hello.txt
  10 threads and 200 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     6.61ms    4.71ms  49.59ms   69.36%
    Req/Sec     3.24k   278.42     9.02k    75.89%
  969489 requests in 30.10s, 175.67MB read
Requests/sec:  32213.38
Transfer/sec:      5.84MB

```

### zuul bench (8081)
```bash
~% wrk -t 10 -c 200 -d 30s http://localhost:8081/hello.txt
Running 30s test @ http://localhost:8081/hello.txt
  10 threads and 200 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    12.56ms   13.35ms 195.11ms   86.33%
    Req/Sec     2.09k   215.10     4.28k    71.81%
  625781 requests in 30.09s, 123.05MB read
Requests/sec:  20800.13
Transfer/sec:      4.09MB
```

### linkerd bench (4140)
```bash
~% wrk -H "Host: web" -t 10 -c 200 -d 30s http://localhost:4140/hello.txt
Running 30s test @ http://localhost:4140/hello.txt
  10 threads and 200 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     7.62ms    5.45ms  53.51ms   69.82%
    Req/Sec     2.82k   184.58     4.11k    72.17%
  843418 requests in 30.07s, 186.61MB read
Requests/sec:  28050.76
Transfer/sec:      6.21MB
```

### no proxy bench (8000)
```bash
~% wrk -t 10 -c 200 -d 30s http://localhost:8000/hello.txt
Running 30s test @ http://localhost:8000/hello.txt
  10 threads and 200 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     2.09ms    2.07ms  28.37ms   85.89%
    Req/Sec    11.77k     2.07k   45.46k    70.97%
  3516807 requests in 30.10s, 637.24MB read
Requests/sec: 116841.15
Transfer/sec:     21.17MB
```
