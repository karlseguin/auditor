config = require('../config')
ddb = require('dynamodb').ddb(config.dynamodb)

throughput = {read: 3, write: 5}

ddb.createTable 'logs', { hash: ['id', ddb.schemaTypes().string] }, throughput , (err, details) ->
  console.log(err) if err?
  
ddb.createTable 'logs_by_user', { hash: ['user', ddb.schemaTypes().string], range: ['time', ddb.schemaTypes().number] },  throughput, (err, details) ->
  console.log(err) if err?

ddb.createTable 'logs_by_asset', { hash: ['asset', ddb.schemaTypes().string], range: ['time', ddb.schemaTypes().number] },  throughput, (err, details) ->
  console.log(err) if err?

ddb.createTable 'logs_by_user_asset', { hash: ['userasset', ddb.schemaTypes().string], range: ['time', ddb.schemaTypes().number] },  throughput, (err, details) ->
  console.log(err) if err?
