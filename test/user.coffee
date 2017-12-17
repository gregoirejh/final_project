should = require 'should'
sinon = require 'sinon'
userDb = require('../src/db') "#{__dirname}/../db/user"

sandbox = null

callback = () ->
  true

beforeEach () ->
  sandbox = sinon.sandbox.create()

afterEach () ->
  sandbox.restore()

describe "users", () ->

  it "gets an user", (done) ->
    sandbox.stub(userDb, 'get').returns(true)
    user = require('../src/user')(userDb)
    user.get 'foo', callback
    sinon.assert.calledWith userDb.get, 'user:foo', callback
    done()
  
  it "saves an user", (done) ->
    sandbox.stub(userDb, 'put').returns(true)
    user = require('../src/user')(userDb)
    user.save { username: 'foo', password: 'bar' }, callback
    sinon.assert.calledWith userDb.put, 'user:foo', 'bar', callback
    done()
  
  it "removes an user", (done) ->
    sandbox.stub(userDb, 'del').returns(true)
    user = require('../src/user')(userDb)
    user.remove 'foo', callback
    sinon.assert.calledWith userDb.del, 'user:foo', callback
    done()