
express = require 'express'
bodyParser = require 'body-parser'
config = require '../../config'

module.exports = class WebServer
  constructor: ->
    return console.log 'no config.webPort specified; web server will not start' unless config.webPort

    @app = express()
    @app.use bodyParser.json()
    @app.listen config.webPort
    console.log "webserver started on port #{config.webPort}"

