jwt = require('jsonwebtoken')

key = 'awesome-secret-key'

module.exports =
  encrypt: (username) ->
    jwt.sign({ username: username, ttl: 3600 }, key)
  
  decrypt: (token) ->
    jwt.verify(token, key)
