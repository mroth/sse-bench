ConnectionManager = require('./lib/connection_manager')

debug = require('debug')('sse-bench')
program = require('commander')
program
  .version('0.0.1')
  .option('-n, --maxclients [n]', 'maximum number of simultaneous clients \t[1024]', 1024, parseInt)
  .option('-c, --increment [n]', 'ramp up this many clients at a time \t\t[MAX]', parseInt)
  .option('-p, --period [ms]', 'period between ramp-ups, in milliseconds \t[1000]', 1000, parseInt)
  .option('-r, --report [ms]', 'interval to report to STDOUT \t\t\t[1000]', 1000, parseInt)
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

URLs = program.args
if URLs.length < 1
  #TODO: exit with error
  null

if program.increment >= program.maxclients
  console.log "Opening #{program.maxclients} connections to #{URLs.length} endpoint."
  cm = new ConnectionManager(URLs, program.maxclients)
else
  console.log "Ramping up #{program.increment} clients every #{program.period}ms (until #{program.maxclients} total) against #{URLs.length} endpoint."
  cm = new ConnectionManager(URLs)
  cm.rampUpClients(program.increment,program.period,program.maxclients)

setInterval ->
  console.log cm.statusReport()
, program.report
