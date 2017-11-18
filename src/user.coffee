

module.exports = (db) ->
  get: (username, callback) ->
    user = {}
    rs = db.createReadStream
      gte: "user:#{username}"   
    rs.on 'data', (data) ->
      user.value = data.value
      user.key = data.key
    rs.on 'error', callback
    rs.on 'close', ->
      callback null, user

    
  save: (id, metrics, callback) -> 
    #TODO

  remove: (username, callback) ->
   #TODO
