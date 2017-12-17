EventEmitter = require 'events'
{exec} = require 'child_process'
should = require 'should'
sinon = require 'sinon'
metricDb = require('../src/db') "#{__dirname}/../db"

readStream = new EventEmitter()
writeStream = new EventEmitter()

writeStream.write = sinon.stub().returns(true)
writeStream.end = sinon.stub()

metricDb.createReadStream = sinon.stub().returns(readStream)
metricDb.createWriteStream = sinon.stub().returns(writeStream)

describe "metrics", () ->

  it "gets a metric", (next) ->
    metrics = require('../src/metrics')(metricDb)
    metrics.get (err, metrics) ->
        should.ok(metricDb.createReadStream.calledOnce)
        return next err if err
        # do some tests here on the returned metrics
        next()
    readStream.emit('close')

  it "sets a metric", (next) ->
    metrics = require('../src/metrics')(metricDb)
    metrics.save '1', [
      timestamp:(new Date '2015-11-04 14:00 UTC').getTime(), value:23
     ,
      timestamp:(new Date '2015-11-04 14:10 UTC').getTime(), value:56
    ], (err) ->
      should.ok(metricDb.createReadStream.calledOnce)
      return next err if err
      next()
    writeStream.emit('close')
