module.exports.errorResponse = (res, error) ->
  res.writeHead(400, {'Content-Type': 'application/json'})
  res.end(JSON.stringify({error: if error.message? then error.message else error}))

module.exports.sanitizeHashArray = (array, keys) ->
  sanitized = []
  for item in array
    copy = {}
    copy[key] = value for key, value of item when key in keys
    sanitized.push(copy)

  return sanitized
