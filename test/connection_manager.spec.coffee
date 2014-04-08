require 'coffee-errors'

chai = require('chai')
should = chai.should()

# using compiled JavaScript file here to be sure module works
ConnectionManager = require '../lib/connection_manager'

describe 'ConnectionManager', ->
  describe '.new()', ->
    it 'should init with list of URLs and num of initial clients'
    it 'should override the maxsockets so we can hammer shit', ->
      http = require('http')
      http.globalAgent.maxSockets.should.eq 5 #default
      cm = new ConnectionManager()
      http.globalAgent.maxSockets.should.eq Infinity
  describe '#addClients(n)', ->
    it 'should add N hungry clients to the pool', ->
      cm = new ConnectionManager(['http://foo:8001'])
      cm.addClients(5)
      cm.numClients().should.equal 5
    it 'should throw an error if you try to add clients without a URL pool'#, ->
      # cm = new ConnectionManager()
      # try
      #   cm.addClient(5)
      # catch error
      #   error.should.be.a Error

  describe '#numClients()', ->
    it 'should return zero when there are no clients', ->
      cm = new ConnectionManager(['http://foo:8001'])
      cm.numClients().should.equal 0

  describe '#rampUpClients()', ->
    it "should initialize class properties the internal rampup methods count on", ->
      cm = new ConnectionManager(['http://foo:8001'])
      cm.rampUpClients(10,20,30)
      cm._rampupIncrement.should.equal 10
      cm._rampupPeriod.should.equal 20
      cm._rampupMaxClients.should.equal 30

    it "should ramp up new clients according to proper timing", (done) ->
      cm = new ConnectionManager(['http://foo:8001'])
      cm.numClients().should.equal 0

      #the first batch should be created immediately
      cm.rampUpClients(10,10,35)
      cm.numClients().should.equal 10

      # the rest trickle in
      setTimeout -> #check after clients have time to rampup
        cm.numClients().should.equal 35
        done()
      , 100

    it "should remove its ticker and event handler when done"
      # check for on 'rampup-complete'

  describe '#_rampUpClientsRemaining', ->
    it "should properly determine the amount of rampup clients remaining to add", ->
      cm = new ConnectionManager(['http://foo:8001'])
      # stub these values to things dont actually ramp up
      cm._rampupMaxClients = 10

      cm._rampUpClientsRemaining().should.equal 10
      cm.addClients(1)
      cm._rampUpClientsRemaining().should.equal 9
      cm.addClients(9)
      cm._rampUpClientsRemaining().should.equal 0
      cm.addClients(5)
      cm._rampUpClientsRemaining().should.equal 0

  describe '#_rampUpClientsToAdd', ->
    it "should properly determine the amount of rampup clients to add in a batch", ->
      cm = new ConnectionManager(['http://foo:8001'])

      # stub these values to things dont actually ramp up
      cm._rampupIncrement = 5
      cm._rampupMaxClients = 10

      cm._rampUpClientsToAdd().should.equal 5
      cm.addClients(9)
      cm._rampUpClientsToAdd().should.equal 1
      cm.addClients(5)
      cm._rampUpClientsToAdd().should.equal 0

  describe '#statusReport()', ->
    beforeEach ->
      @cm = new ConnectionManager()
    it 'should return an object representing client pool status, suitable for reporting', ->
      @cm.statusReport().should.be.a 'object'
    it 'should reset the period values for the next status report', ->
      a = @_lastReportTime
      @cm.statusReport()
      @cm._lastReportTime.should.not.equal a
    it 'should emit an event with the report so it can be consumed elsewhere', (done) ->
      @cm.on 'reported-status', -> done()
      @cm.statusReport()
