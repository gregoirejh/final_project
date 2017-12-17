EventEmitter = require 'events'
should = require 'should'
sinon = require 'sinon'
metricDb = require('../src/db') "#{__dirname}/../db"

sandbox = null

beforeEach () ->
  sandbox = sinon.sandbox.create()

afterEach () ->
  sandbox.restore()

readStream = new EventEmitter()
writeStream = new EventEmitter()

describe "metrics", () ->

  it "gets a metric", (next) ->
    sandbox.stub(metricDb, 'createReadStream').returns(readStream)
    metrics = require('../src/metrics')(metricDb)
    metrics.get (err, metrics) ->
        should.ok metricDb.createReadStream.calledOnce
        should.equal err, null
        should.equal metrics.length, 0
        should.equal err, null
        next()
    readStream.emit 'close'

  it "sets a metric", (next) ->
    writeStream.write = sinon.stub().returns(true) 
    writeStream.end = sinon.stub() 
    sandbox.stub(metricDb, 'createWriteStream').returns(writeStream)
    metrics = require('../src/metrics')(metricDb)
    metrics.save '1', [
      timestamp:new Date('2015-11-04 14:00 UTC').getTime(), value:23
     ,
      timestamp:new Date('2015-11-04 14:10 UTC').getTime(), value:56
    ], (err) ->
      should.ok metricDb.createWriteStream.calledOnce
      return next err if err
      next()
    writeStream.emit('close')
