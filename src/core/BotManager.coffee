_ = require 'underscore'
path = require 'path'
file = require 'file'
fs = require 'fs'

Bot = require('./Bot').Bot
ModuleManager = require('./ModuleManager').ModuleManager
PermissionManager = require('./PermissionManager').PermissionManager

class BotManager

  constructor: (@config) ->
    @configPath = path.resolve "config.json"
    if typeof @config is "string"
      @configPath = @config
      @config = require path.resolve @config

    @bots = []
    @botHash = {}

    @permissionManager = new PermissionManager()
    @userManagerClasses = @loadUserManagers __dirname + '/../auths'

    globalConfig = _.omit(@config, 'bots')
    for botName, botConfig of @config.bots
      # Settings unique to the bot, not to be deleted when writing
      # the config back to file
      botConfig.overrides = (key for key, value of botConfig)
      for key, value of globalConfig
        botConfig[key] = value if not botConfig[key]?
      botConfig.name = botName

      bot = new Bot @, botConfig
      @bots.push bot
      @botHash[botConfig.server] = bot

    @moduleManager = new ModuleManager @

  loadUserManagers: (path) ->
    managerClasses = {}

    file.walkSync path, (start, dirs, files) ->
      for f in (files.map (f) ->
        start + '/' + f)
        auth = require f
        managerClasses[auth.name] = auth.AuthClass
        console.log "Added ", auth.name

    managerClasses

  setConfig: (key, value) ->
    @config[key] = value
    @writeConfig()

  writeConfig: ->
    # clone the object and write
    config = JSON.parse JSON.stringify @config
    for botName, botConfig of config.bots
      overrides = botConfig.overrides
      for key, value of botConfig
        delete botConfig[key] if not (key in overrides)
    fs.writeFile @configPath, JSON.stringify(config, null, '\t'), (err) ->
      console.error "Unable to write to config:", err if err?

exports.BotManager = BotManager
