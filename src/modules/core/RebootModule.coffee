module.exports = (Module) ->

  class RebootModule extends Module
    shortName: "Kill"
    helpText:
      default: "Kill me! If I'm running as a daemon, I'll be right back."
    usage:
      default: "kill"

    constructor: (moduleManager) ->
      super(moduleManager)

      @addRoute "kill", "core.manage.kill", (origin, route) =>
        process.exit()

  RebootModule