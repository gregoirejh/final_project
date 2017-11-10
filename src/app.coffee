express = require 'express'
bodyparser = require 'body-parser'

metrics = require './metrics'

app = express()

app.set 'port', '8888'
app.set 'views', "#{__dirname}/../views"
app.set 'view engine', 'pug'

app.use bodyparser.json()
app.use bodyparser.urlencoded()

app.use '/', express.static "#{__dirname}/../public"

app.get '/', (req, res) ->
  res.render 'index', 
    text: "Hello world !"

app.get '/hello/:name', (req, res) ->
  res.send "Hello #{req.params.name}"
  
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

app.listen app.get('port'), () ->
  console.log "Server listening on #{app.get 'port'} !"
