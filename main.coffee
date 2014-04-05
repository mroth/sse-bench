ConnectionManager = require('./lib/connection_manager')

debug = require('debug')('sse-bench')
program = require('commander')
program
  .version('0.0.1')
  .option('-n, --maxclients [n]', 'maximum number of simultaneous clients \t[1024]', 1024, parseInt)
  .option('-c, --increment [n]', 'ramp up this many clients at a time \t\t[MAX]', parseInt)
  .option('-p, --period [ms]', 'period between ramp-ups, in milliseconds \t[1000]', 1000, parseInt)
  .option('-r, --report [ms]', 'interval to report to STDOUT \t\t[1000]', 1000, parseInt)
  .parse(process.argv)

debug "increment: " + program.increment
debug "period: " + program.period
debug "maxclients: " + program.maxclients
debug "report: " + program.report
debug "args: " + program.args

incrementVal = program.increment || program.maxclients
debug "increment value: " + incrementVal

# cm = new ConnectionManager(program.args)
# cm.addClients(program.maxclients)

URLs = ["http://localhost:8001/subscribe/eps"]
cm = new ConnectionManager(URLs)
cm.addClients(10)
cm.rampUpClients(10,9*1000,1024)
#
# setInterval ->
#   cm.addClients(10)
# , 5000
#
setInterval ->
  console.log cm.statusReport()
, 5000
