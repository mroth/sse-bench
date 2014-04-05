chai = require('chai')
should = chai.should()

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
      cm = new ConnectionManager(['http://localhost:8001'])
      cm.addClients(5)
      cm.numClients().should.equal 5
    it 'should throw an error if you try to add clients without a URL pool', ->
      cm = new ConnectionManager()
      try
        cm.addClient(5)
      catch error
        error.should.be.a Error

  describe '#numClients()', ->
    it 'should return the current count of clients'
  describe '#rampUpClients()', ->
    it "should ramp up new clients"
    it "should remove its ticker and event handler when done"
  describe '#status()', ->
    it 'should return a hash representing client pool status, suitable for reporting'
  describe '#logStatus()', ->
    it 'should log the results of status to STDOUT'
