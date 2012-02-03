connect = require('connect')
util = require('./util')
Log = require('./log')

server = (config) ->
  server = connect()
  server.use connect.bodyParser()
  server.use connect.queryParse()
  server.use connect.router (app) ->

    app.post '/log', (req, res, next) ->
      log = new Log(req.body.user, req.body.asset, util.sanitizeHashArray(req.body.changes, ['field', 'old', 'new']))
      try
        log.validate()
        log.save (err) ->
          return util.errorResponse(res, err) if err ? 
          location = config.api.locationRoot + 'log/' + log.id
          res.writeHead(201, {'Content-Type': 'application/json', 'Location': location})
          res.end(JSON.stringify(log))
      catch error
        util.errorResponse(res, error)

    app.get '/log/:id', (req, res, next) ->
      Log.load req.params.id, (err, log) ->
        return util.errorResponse(res, err) if err?
        res.end(JSON.stringify(log))

    app.get '/logs', (req, res, next) ->
      #TODO Log.search 'XX', (err, log)

    
  server.listen(config.server.port, config.server.listen)
  console.log('Server running on http://%s:%d', config.server.listen, config.server.port);


module.exports = server