level = require 'level'
levelws = require 'level-ws'

db = levelws level "#{__dirname}/../db"

module.exports = 
  # get(id, callback)
  # Get metrics 
  # - id: metric's id 
  # - callback: the callback function, callback(err, data)
  get: (id, callback) ->
    rs = db.createReadStream({keys: true, values: false})
    rs.on 'data', callback
    rs.end()
    
  # save(id, metrics, callback)
  # Save given metrics 
  # - id: metric id
  # - metrics: an array of { timestamp, value }
  # - callback: the callback function
  save: (id, metrics, callback) -> 
    ws = db.createWriteStream()
    ws.on 'error', callback 
    ws.on 'close', callback 
    for metric in metrics 
      { timestamp, value } =  metric
      ws.write 
        key: "metrics:#{id}:#{timestamp}"
        value: value
    ws.end()
