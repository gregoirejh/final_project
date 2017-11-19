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

app = express()

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

# MAIN

app.get '/', authCheck, (req, res) ->
  res.render 'index', name: token.decrypt(req.session.jwt).email

# LOGIN

app.get '/login', (req, res) ->
  res.render 'login'

app.post '/login', (req, res) ->
  user.get req.body.username, (err, data) ->
    return next err if err
    if !data.length
      console.log "unvalid username"
      res.redirect '/login'
    else
      req.session.jwt = token.encrypt req.body.username
      res.redirect '/'

app.post '/signin', (req, res) ->
  { username, password } = req.body
  user.save { username, password }, (err, result) ->
    throw err if err
    res.redirect '/login'

app.get '/logout', (req, res) ->
  delete req.session.jwt
  res.redirect '/login'

# METRICS

app.get '/metrics.json', authCheck, (req, res, next) ->
  email = token.decrypt(req.session.jwt).email
  metrics.get null, (err, data) ->
    throw next err if err
    res.status(200).json data.filter (metric) -> metric.key.includes email
    
app.post '/metrics.json', authCheck, (req, res, next) -> 
  email = token.decrypt(req.session.jwt).email
  metrics.save email, req.body.metrics, (err) ->
    throw next err if err 
    res.status(201).json { created: 1, deleted: 0 }

app.delete '/metrics.json/:key', authCheck, (req, res, next) ->
  email = token.decrypt(req.session.jwt).email
  throw new Error 'Unauthorized' if !req.params.key.includes email
  metrics.del req.params.key, (err, element) ->
    throw next err if err
    res.status(200).json { created: 0, deleted: 1 }


app.listen app.get('port'), () ->
  console.log "Server listening on #{app.get 'port'} !"
