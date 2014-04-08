_ = require('lodash')
events = require('events')
debug = require('debug')('sse-bench:ConnectionManager')
EventSource = require('eventsource')

class ConnectionManager extends events.EventEmitter

  constructor: (@URLs=[], initialClients=0) ->
    @_receivedMsgs = 0
    @_nextClientID = 0
    @_clients = []
    @_resetStatusValues()

    # override the http agent maxsockets for great justice
    require('http').globalAgent.maxSockets  = Infinity
    require('https').globalAgent.maxSockets = Infinity

    # add any initial clients requests
    @addClients(initialClients) if initialClients >= 1

  addClients: (n) ->
    debug "adding #{n} clients to pool"
    throw new Error('cant add clients without URLs in pool!') if @URLs.length < 1
    _(n).times => @_clientCreate( @_pickURL() )

  numClients: ->
    @_clients.length

  rampUpClients: (increment, period, maxclients) ->
    debug "beginning rampup with increment: #{increment},
                                 period: #{period},
                                 maxclients: #{maxclients}"

    #if request comes in when already ramping up, clear old rampup
    clearInterval(@rampupTimer)

    #set class properties to keep state of rampup (kinda dumb but whatever)
    @_rampupIncrement = increment
    @_rampupPeriod = period
    @_rampupMaxClients = maxclients

    #event-handler for adding batches of clients in the ramp-up
    @on 'rampup-tick', =>
      debug 'processing rampup tick'
      debug "I think there are #{@_rampUpClientsRemaining()} rampup clients remaining"
      if @_rampUpClientsRemaining() > 0
        @addClients @_rampUpClientsToAdd()
      else
        clearInterval(@rampupTimer)
        #TODO: remove myself as listener....
        @emit 'rampup-done'

    #add first batch of clients immediately
    @emit 'rampup-tick'

    #set up an interval timer to add subsequent batches
    @rampupTimer = setInterval (=> @emit 'rampup-tick'), period

  # how many clients to add in current ramp-up batch
  _rampUpClientsToAdd: ->
    debug "figuring out how many clients to add in this batch..."
    debug "   remaining: #{@_rampUpClientsRemaining()}"
    debug "   increment: #{@_rampupIncrement}"
    debug "   min: #{_.min([@_rampUpClientsRemaining(), @_rampupIncrement])}"
    _.min([@_rampUpClientsRemaining(), @_rampupIncrement])

  # how many clients remain to be added to meet ramp-up
  _rampUpClientsRemaining: ->
    diff = @_rampupMaxClients - @numClients()
    return 0 if diff < 0
    diff

  # return a random endpoint from the list
  _pickURL: ->
    if @URLs.length > 0
      return _.sample(@URLs)
    else
      return null

  # create a new client and add to the pool
  _clientCreate: (url) ->
    clientID = ++@_nextClientID
    debug "init new client \##{clientID} who wants to connect to #{url}"
    es = new EventSource(url)
    @_clients.push es
    es.onopen = =>
      debug "client \##{clientID} opened new conn to #{url}"
    es.onmessage = =>
      # debug "client \##{clientID} got new msg from #{url}"
      @_receivedMsgs++
    es.onerror = =>
      debug "client \##{clientID} had conn closed from #{url}"

  _clientsWithReadyState: (status) ->
    @_clients.filter( (c)->c.readyState == status )


  # formally get the current status report
  # resets the counts for the "since last report"
  statusReport: ->
    status = @_status()
    @emit 'reported-status', status
    debug 'emitted status report'
    @_resetStatusValues()
    return status


  # peek at the current status without resetting report counts
  statusPeek: ->
    @_status()

  # internal convenience object representation of status
  _status: ->
    {
      time:
        since_previous: @_reportTimeSincePrevious()
      messages:
        total_received: @_receivedMsgs
        since_previous: @_reportMsgsSincePrevious()
        rate_per_second: @_reportMsgsPerSecond()
        avg_client_rate: @_reportMsgsPerClientRate()
      clients:
        total: @numClients()
        status:
          connecting: @_clientsWithReadyState( EventSource.CONNECTING ).length
          open: @_clientsWithReadyState( EventSource.OPEN ).length
          closed: @_clientsWithReadyState( EventSource.CLOSED ).length
    }

  _reportMsgsSincePrevious: -> @_receivedMsgs - @_lastResportReceivedMsgs
  _reportTimeSincePrevious: -> Date.now() - @_lastReportTime
  _reportMsgsPerSecond: -> @_reportMsgsSincePrevious() / (@_reportTimeSincePrevious() / 1000)
  _reportMsgsPerClientRate: -> @_reportMsgsPerSecond() / @numClients()


  # add the listener that resets status counts on reports
  _resetStatusValues: ->
    debug 'resetting status report counters'
    @_lastReportTime = Date.now()
    @_lastResportReceivedMsgs = @_receivedMsgs


module.exports = ConnectionManager
