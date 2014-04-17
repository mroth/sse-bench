#!/usr/bin/env node
var ConnectionManager = require('../lib/connection_manager');
var debug = require('debug')('sse-bench');
var program = require('commander');

program
  .version('0.0.1')
  .usage('[options] <url ...>')
  .option('-n, --maxclients [n]', 'maximum number of simultaneous clients \t[1024]', 1024, parseInt)
  .option('-c, --increment [n]', 'ramp up this many clients at a time \t\t[MAX]', parseInt)
  .option('-p, --period [ms]', 'period between ramp-ups, in milliseconds \t[1000]', 1000, parseInt)
  .option('-r, --report [ms]', 'interval to report to STDOUT \t\t\t[1000]', 1000, parseInt)
  .parse(process.argv);

program.increment = program.increment || program.maxclients;

debug("increment: " + program.increment);
debug("period: " + program.period);
debug("maxclients: " + program.maxclients);
debug("report: " + program.report);
debug("args: " + program.args);
debug("increment value: " + program.increment);

var URLs = program.args;
if (URLs.length < 1) {
  program.help();
}

var endpointStr = URLs.length > 1 ? "across " + URLs.length + " endpoints." : "against 1 endpoint.";
var cm;
if (program.increment >= program.maxclients) {
  console.log("Opening " + program.maxclients + " connections " + endpointStr);
  cm = new ConnectionManager(URLs, program.maxclients);
} else {
  console.log("Ramping up " + program.increment + " clients every " + program.period + "ms (until " + program.maxclients + " total) " + endpointStr);
  cm = new ConnectionManager(URLs);
  cm.rampUpClients(program.increment, program.period, program.maxclients);
}

// TODO: replace this with a eventlistener to a status report event that CM should emit
setInterval(function() {
  return console.log(cm.statusReport());
}, program.report);
