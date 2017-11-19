jwt = require('jsonwebtoken')

key = 'awesome-secret-key'

module.exports =
  encrypt: (user) ->
    jwt.sign({ email: user.email, ttl: 3600 }, key)
  
  decrypt: (token) ->
    jwt.verify(token, key)
