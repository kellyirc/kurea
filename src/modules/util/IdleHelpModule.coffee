module.exports = (Module) ->
  _ = {}
  _.str = require "underscore.string"

  class IdleHelpModule extends Module
    shortName: "IdleHelp"
    helpText:
      default: "I can get a wiki page for IdleLands!"
      'idle-repo': 'I can get the repo link for IdleLands!'
      'idle-issue': 'Get the page for an issue!'
    usage:
      default: "idle-wiki [page]"
      'idle-repo': "idle-repo"
      'idle-issue': "idle-issue [issue-number]"

    constructor: (moduleManager) ->
      super moduleManager

      @addRoute "idle-repo", (origin) =>
        @reply origin, "https://github.com/seiyria/IdleLands"

      @addRoute "idle-wiki :page?", (origin, route) =>
        page = route.params.page or ''
        @reply origin, "https://github.com/seiyria/IdleLands/wiki/#{_.str.slugify page}"

      @addRoute "idle-issue :issue", (origin, route) =>
        @reply origin, "https://github.com/seiyria/IdleLands/issues/#{route.params.issue}"

  IdleHelpModule