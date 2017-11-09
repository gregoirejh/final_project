    metric = require '../src/metrics'

    met = [
      timestamp:(new Date '2013-11-04 14:00 UTC').getTime(), value:12
    ,
      timestamp:(new Date '2013-11-04 14:10 UTC').getTime(), value:13
    ]

    metric.save 0, met, (err) ->
      throw err if err
      console.log 'Metrics saved'