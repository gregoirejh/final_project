
uuid = require 'uuid/v4'

module.exports =  (db) ->
  # get(id, callback)
  # Get all metrics 
  # - callback: the callback function, callback(err, data)
  get: (callback) ->
    rs = db.createReadStream()
    result = []
    rs.on 'data', (data) -> result.push(data)
    rs.on 'error', (err) -> callback err, null
    rs.on 'close', () -> callback null, result
    
  # save(id, metrics, callback)
  # Save given metrics 
  # - metrics: an array of { timestamp, value }
  # - callback: the callback function
  save: (user, metrics, callback) -> 
    collectionId = uuid()
    ws = db.createWriteStream()
    ws.on 'error', callback
    ws.on 'close', callback
    for metric in metrics
      { timestamp, value } =  metric
      ws.write
        key: "#{user}:#{collectionId}:#{timestamp}"
        value: Number.parseInt(value)
    ws.end()

  del: (key, callback) ->
    db.del key, callback
