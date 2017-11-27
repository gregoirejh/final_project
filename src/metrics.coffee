
uuid = require 'uuid/v4'

module.exports =  (db) ->
  # get(id, callback)
  # Get metrics 
  # - id: metric's id 
  # - callback: the callback function, callback(err, data)
  get: (id, callback) ->
    rs = db.createReadStream()
    result = []
    rs.on 'data', (data) -> result.push(data)
    rs.on 'error', (err) -> callback err,null
    rs.on 'close', () -> callback null, result
    
  # save(id, metrics, callback)
  # Save given metrics 
  # - metrics: an array of { timestamp, value }
  # - callback: the callback function
  save: (user, metrics, callback) -> 
    ws = db.createWriteStream()
    ws.on 'error', callback
    ws.on 'close', callback 
    for metric in metrics 
      { timestamp, value } =  metric
      ws.write 
        key: "metric:#{user}:#{uuid()}"
        value: value
    ws.end()

  del: (key, callback) ->
    db.del key, callback
