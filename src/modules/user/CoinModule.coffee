module.exports = (Module) ->

  class CoinModule extends Module
    shortName: "Coin"
    helpText:
      default: "Get coins for talking!"
    usage:
      default: "coins"

    constructor: (moduleManager) ->
      super(moduleManager)

      getCoinTotal = (origin, callback) =>
        @getUserData origin, "coins", (data) =>
          callback?(data)

      setCoinTotal = (origin, coins, callback) =>
        @setUserData origin, "coins", coins, () =>
          callback?()

      addCoins = (origin, coins, callback) =>
        getCoinTotal origin, (coinTotal) =>
          coinTotal = 0 if (isNaN coinTotal) or not coinTotal
          setCoinTotal origin, coinTotal+coins, callback

      removeCoins = (origin, coins, callback) =>
        addCoins origin, -coins, callback

      @getApi().getCoinTotal = getCoinTotal

      @getApi().addCoins = addCoins

      @getApi().removeCoins = removeCoins

      @getApi().setCoinTotal = setCoinTotal

      @registerApi()

      @addRoute "coins", (origin) =>
        @getUserData origin, "coins", (data) =>
          @reply origin, "You have #{data ? 0} coins."

      @addRoute "*", (origin) =>
        addCoins origin, 1

  CoinModule