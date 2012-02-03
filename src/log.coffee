config = require('../config')
ddb = require('dynamodb').ddb(config.dynamodb)
uuid = require('node-uuid')
check = require('validator').check

class Log
  constructor: (@user, @asset, @changes) ->
    @id = uuid.v4()
    @created = new Date()

  validate: =>
    check(@user, 'name should be 1-50 characters').len(1, 50)
    check(@asset, 'asset should be 1-50 characters').len(1, 50)
    check(@changes, 'expecting 1 or more changes').isArray().len(1)
    check(change.field, 'change field shoudl be 1-50 characters').len(1, 50) for change in @changes
    true

  save: (callback) =>
    ddb.putItem 'logs', this.serialize(), {}, (err, res, cap) =>

      return callback(err, null) if err?

      ddb.putItem 'logs_by_user', {user: @user, time: @created.getTime(), id: @id}, {}, ->
      ddb.putItem 'logs_by_asset', {asset: @asset, time: @created.getTime(), id: @id}, {}, ->
      ddb.putItem 'logs_by_user_asset', {userasset: @user + ':' + @asset, time: @created.getTime(), id: @id}, {}, ->
      callback(null, res)

  serialize: =>
    {id: @id, user: @user, asset: @asset, created: @created.getTime(), changes: JSON.stringify(@changes)}

  @load: (id, callback) =>
    ddb.getItem 'logs', id, null, {}, (err, res) =>
      return callback(err, null) if err?
      callback(null, this.deserialize(res))

  
  @deserialize: (data) =>
    data.created = new Date(data.created)
    data.changes = JSON.parse(data.changes)
    return data

module.exports = Log