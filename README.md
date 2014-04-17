** UNFINISHED WORK IN PROGRESS, NOT ACTUALLY ON NPM JUST YET! **

# sse-bench
Benchmarks Server-Sent Events Endpoints.  Normal HTTP benchmarking tools test for the wrong things for this use case.

This fires up a bunch of clients that will hit a list of one or more endpoints.  
These clients behave like normal `EventSource` browser clients, e.g. they will attempt to stay connected as long as possible and reconnect when disconnected.

Stats-wise, this mostly looks at msgs received per client per second and latency to open new connections under load, since that's where I have seen breakdowns on my servers.  Please add functionality and send pull requests!

P.S. Remember to set ulimit -n !

### Installation

    npm install -g sse-bench

(Once it's released anyhow!  In the meantime, grab source and `npm link`.)

### Usage

Open ten connections against a single endpoint:

    $ sse-bench -n 10 http://127.0.0.1:8001
    Opening 10 connections to 1 endpoint.

Open 100 connections at once, randomly spread across three different endpoints:

    $ sse-bench -n 100 http://127.0.0.1/d/1 http://127.0.0.1/d/2 http://127.0.0.1/d/3
    Opening 100 connections across 3 endpoints.

Open 1000 connections to a single endpoint by adding 10 connections per second, and report status every 5 seconds.  Also be verbose in output:

    $ sse-bench -n 1000 -c 10 -p 1000 -r 5000 http://127.0.0.1
    Ramping up 10 clients every 1000ms (until 1000 total) against 1 endpoint.
    Adding +10 clients (10 total)
    Adding +10 clients (20 total)
    Adding +10 clients (30 total)
    Adding +10 clients (40 total)
    Adding +10 clients (50 total)
    Status report: ****
    Adding +10 clients (60 total)

### Debugging
Uses the standard DEBUG environment variable pattern.  Set `sse-bench*` if you want to see everything.

### CLI TODO

 - [x] it should return a helpful status message showing it understood what you wanted
 - [x] it should die with error code and print usage if there are no servers passed
 - [ ] it should capture control-c and show stats on exit
 - [ ] it should verifiably exit gracefully and shut down connections
