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

      ddb.putItem 'logs_by_user', {user: @user, time: @created.getTime(), id: @id}, {}, (err, x, y)->
      ddb.putItem 'logs_by_asset', {asset: @asset, time: @created.getTime(), id: @id}, {}, ->
      ddb.putItem 'logs_by_user_asset', {userasset: @user + ':' + @asset, time: @created.getTime(), id: @id}, {}, ->

  serialize: =>
    {id: @id, user: @user, asset: @asset, created: @created.getTime(), changes: JSON.stringify(@changes)}

  @load: (id, callback) =>
    ddb.getItem 'logs', id, null, {}, (err, res) =>
      return callback(err, null) if err?
      callback(null, this.deserialize(res))

  @find: (user, asset, callback) =>
    if user? && asset?
      table = 'logs_by_user_asset'
      key = user + ':' + asset
    else if user?
      table = 'logs_by_user'
      key = user
    else if asset?
      table = 'logs_by_asset'
      key = asset
    else
      return callback('missing user and/or asset', null)

    ddb.query table,  key, null, {attributesToGet: ['id']}, (err, res) =>
      return callback(err, null) if err?
      ids = (key.id for key in res.Items)
      ddb.batchGetItem {table: 'logs', keys: ids}, (err, res) =>
        return callback(err, null) if err?
        items = []
        for item in res.Items
          items.push(this.deserialize(item))
        callback(null, items)

  @deserialize: (data) =>
    data.created = new Date(data.created)
    data.changes = JSON.parse(data.changes)
    return data

module.exports = Log