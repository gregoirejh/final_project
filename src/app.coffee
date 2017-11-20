express = require 'express'
bodyparser = require 'body-parser'
session = require 'express-session'
LevelStore = require('level-session-store')(session)

userDb  = require('./db') "#{__dirname}/../db"
metricDb = require('./db') "#{__dirname}/../db/user"

metrics = require('./metrics')(metricDb)
user  = require('./user')(userDb)

token = require('./token')



authCheck = (req, res, next) ->
  unless req.session.jwt
    res.redirect '/login'
  else
    next()

logging_middleware = (req,res,next) ->
  for socket, i in sockets 
    socket.emit 'logs',
      username: 
        if !req.session.jwt then 'anonymous' 
        else token.decrypt(req.session.jwt).username
      url: req.url
  next()


app = express()

server = require('http').Server(app)
io = require('socket.io') server

sockets = []

io.on 'connection', (socket) ->
  sockets.push socket




# MIDDLEWARES

app.use bodyparser.urlencoded({ extended: true })
app.use bodyparser.json()
app.use session
  secret: 'MyAppSecret'
  store: new LevelStore './db/sessions'
  resave: true
  saveUninitialized: true
app.set 'port', '8888'
app.set 'views', "#{__dirname}/../views"
app.set 'view engine', 'pug'
app.use '/', express.static "#{__dirname}/../public"
app.use logging_middleware

# MAIN

app.get '/', authCheck, (req, res) ->
  res.render 'index', name: token.decrypt(req.session.jwt).username

# LOGIN

app.get '/login', (req, res) ->
  res.render 'login'

app.post '/login', (req, res,next) ->
  user.get req.body.username, (err, data) ->
    #return next err if err
    if err
      console.log err
      res.redirect '/login'
    else
      req.session.jwt = token.encrypt req.body.username
      res.redirect '/'

app.get '/signin', (req, res) ->
  res.render 'signin'

app.get '/addMetrics', (req, res) ->
  res.render 'addMetrics'

app.post '/signin', (req, res) ->
  { username, password } = req.body
  user.save { username, password }, (err, result) ->
    throw err if err
    res.redirect '/login'

app.get '/logout', (req, res) ->
  delete req.session.jwt
  res.redirect '/login'

#Logging
app.get '/Logging', (req,res) ->
  res.render 'logging'

# METRICS

app.get '/metrics.json', authCheck, (req, res, next) ->
  username = token.decrypt(req.session.jwt).username
  metrics.get null, (err, data) ->
    throw next err if err
    res.status(200).json data.filter (metric) -> metric.key.includes username
    
app.post '/metrics.json', authCheck, (req, res, next) -> 
  username = token.decrypt(req.session.jwt).username
  console.log req.body.value
  metrics = []
  metrics.save username, req.body.metrics, (err) ->
    throw next err if err 
    res.redirect '/'
    #res.status(201).json { created: 1, deleted: 0 }

app.delete '/metrics.json/:key', authCheck, (req, res, next) ->
  username = token.decrypt(req.session.jwt).username
  throw new Error 'Unauthorized' if !req.params.key.includes username
  metrics.del req.params.key, (err, element) ->
    throw next err if err
    res.status(200).json { created: 0, deleted: 1 }



server.listen app.get('port'), () ->
  console.log "Server listening on #{app.get 'port'} !"


