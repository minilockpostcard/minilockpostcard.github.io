class Shortcut extends Backbone.Model
  module.exports = this

  initialize: ->
    @set "identifier", (number.toString() for number in miniLockLib.NaCl.randomBytes(4)).join("")

  url: (options={}) ->
    "/unlock#{minipost.HTMLsuffix}?Base58=#{@get("Base58")}"
