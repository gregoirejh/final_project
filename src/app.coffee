express = require 'express'
bodyparser = require 'body-parser'
session = require 'express-session'
LevelStore = require('level-session-store')(session)

userDb  = require('./db') "#{__dirname}/../db"
metricDb = require('./db') "#{__dirname}/../db/user"

metrics = require('./metrics')(metricDb)
user  = require('./user')(userDb)


app = express()

app.set 'port', '8888'
app.set 'views', "#{__dirname}/../views"
app.set 'view engine', 'pug'

app.use bodyparser.json()
app.use bodyparser.urlencoded()

app.use '/', express.static "#{__dirname}/../public"

#app.get '/', (req, res) ->
#  res.render 'index', 
#    text: "Hey ! Here your can bring your metrics !"

app.get '/hello/:name', (req, res) ->
  res.send "Hello #{req.params.name}, here your can bring your metrics !"
  
app.get '/metrics.json', (req, res, next) ->
  metrics.get null,(err, data) ->
    throw next err if err
    res.status(200).json data
    
app.post '/metrics.json', (req, res, next) -> 
  metrics.save req.body.id, req.body.metrics, (err) ->
    throw next err if err 
    res.status(201).json { created: 1, deleted: 0 }

app.delete '/metrics.json/:key', (req, res, next) ->
  metrics.del req.params.key, (err, element) ->
    throw next err if err
    res.status(200).json { created: 0, deleted: 1 }


## USer
#user_router = express.Router()


#middleware = (req, res, next) ->
#  console.log "#{req.method} on #{req.url}"
#  next()

#user_router.use middleware
#user_router.get '/login', (req, res) ->
#  # route logic
#app.use router

app.use session
  secret: 'MyAppSecret'
  store: new LevelStore './db/sessions'
  resave: true
  saveUninitialized: true

authCheck = (req, res, next) ->
  unless req.session.loggedIn == true
    res.redirect '/login'
  else
    next()

app.get '/', authCheck, (req, res) ->
  res.render 'index', name: req.session.username

app.get '/login', (req, res) ->
  res.render 'login'

app.post '/login', (req, res) ->
  user.get req.body.username, (err, data) ->
    return next err if err
    if !data.length
      console.log "unvalid username"
      res.redirect '/login'
    else
      req.session.loggedIn = true
      req.session.username = data.username
      res.redirect '/'

app.get '/logout', (req, res) ->
  delete req.session.loggedIn
  delete req.session.username
  res.redirect '/login'






app.listen app.get('port'), () ->
  console.log "Server listening on #{app.get 'port'} !"
