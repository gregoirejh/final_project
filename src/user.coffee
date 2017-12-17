

module.exports = (db) ->
  get: (username, callback) ->
    db.get "user:#{username}", callback

  save: (user, callback) -> 
    db.put "user:#{user.username}", user.password, callback

  remove: (username, callback) ->
    db.del "user:#{username}", callback
