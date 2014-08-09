_ = require "underscore"

module.exports = (Module) ->

  class ChanLinkModule extends Module
    shortName: "ChanLink"
    helpText:
      default: "I can link a bunch of channels together so you can chat across servers or even channels."
    usage:
      default: "chanlink [add|remove] [linkId]"

    add: (origin, link) ->
      @_add origin.bot.config.server, origin.channel, link

    _add: (server, channel, link) ->
      @links[link] = [] if not (link of @links)

      hash = @_channelHash server, channel

      @channelHashes[hash] = [] if not (hash of @channelHashes)

      @links[link].push hash
      @links[link] = _.uniq @links[link]

      @channelHashes[hash].push link
      @channelHashes[hash] = _.uniq @channelHashes[hash]

      @db.update
        server: server
        channel: channel
        link: link
      ,
        server: server
        channel: channel
        link: link
        active: true
      ,
        upsert: true
      , ->

    remove: (origin, link) ->
      hash = @channelHash origin
      @links[link] = _.without @links[link], hash
      @channelHashes[hash] = _.without @channelHashes[hash], link

      @db.update
        server: origin.bot.config.server
        channel: origin.channel
        link: link
      ,
        active: false
      , ->

    channelHash: (origin) ->
      @_channelHash origin.bot.config.server, origin.channel

    _channelHash: (server, channel) ->
      "#{server}|#{channel}"

    loadFromDatabase: ->
      @db.findForEach {active:true}, (e, doc) =>
        @_add doc.server, doc.channel, doc.link

    constructor: (moduleManager) ->
      super(moduleManager)

      @db = @newDatabase 'links'

      @links = {}
      @channelHashes = {}

      @loadFromDatabase()

      @addRoute "chanlink :action(add|remove) :linkId", "chanlink", (origin, route) =>
        [action, linkId] = [route.params.action, route.params.linkId]

        @[action] origin, linkId

        @reply origin, "Channel link #{action} #{origin.channel} successful."

      @on 'message', (bot, sender, channel, message) =>
        hash = @channelHash bot: bot, channel: channel

        id = @channelHashes[hash]

        return if not id or not (id of @links)

        _.each @links[id], (hash) =>
          [server, chan] = hash.split "|"
          return if chan is channel

          bot.botManager.botHash[server]?.say chan, "<#{sender}> #{message}"

  ChanLinkModule