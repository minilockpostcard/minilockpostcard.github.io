class MakeKeysView extends Backbone.View
  module.exports = this
  HTML = require "./HTML.coffee"
  Identity = require "../models/identity.coffee"

  initialize: (options) ->
    @identity = options.model or new Identity
    @listenTo @identity, "keypair:ready", @keyPairIsReady
    @listenTo @identity, "keypair:error", @errorMakingKeyPair
    @render()

  events:
    "focus [name=secret_phrase]": "removeSecretPhraseMask"
    "blur  [name=secret_phrase]": "applySecretPhraseMask"
    "input [name=secret_phrase]": "setSecretPhrase"
    "input [name=email_address]": "setEmailAddress"
    "keypress [name=secret_phrase]": "makeKeyPairIfEnterKeyWasPressed"
    "keypress [name=email_address]": "makeKeyPairIfEnterKeyWasPressed"

  removeSecretPhraseMask: (event) ->
    event.currentTarget.value = @identity.get("secret_phrase") or ""
    event.currentTarget.classList.remove("masked")

  applySecretPhraseMask: (event) ->
    if event.currentTarget.value isnt ""
      event.currentTarget.value = @secretPhraseMask
      event.currentTarget.classList.add("masked")

  secretPhraseMask: ("•" for char in [0...92]).join("")

  setSecretPhrase: (event) ->
    @identity.set "secret_phrase", event.currentTarget.value

  setEmailAddress: (event) ->
    @identity.set "email_address", event.currentTarget.value

  makeKeyPair: ->
    console.info "makeKeyPair"
    Function.delay 1, => @identity.makeKeyPair()
    document.activeElement.blur()
    document.querySelector("article.postcard").classList.add("making_keys")
    @render()

  makeKeyPairIfEnterKeyWasPressed: (event) ->
    if event.keyCode is 13
      event.preventDefault()
      @makeKeyPair()

  keyPairIsReady: (event) =>
    console.info "keyPairIsReady", event
    delete @error
    document.querySelector("article.postcard").classList.remove("making_keys")
    document.querySelector("article.postcard").classList.add("keys_are_ready")
    @render()

  errorMakingKeyPair: (error) =>
    console.info "errorMakingKeys", error
    @error = error
    @el.classList.remove("processing")
    document.querySelector("article.postcard").classList.remove("making_keys")
    @render()
    if /secret phrase/.test(error)
      @el.querySelector('[name=secret_phrase]').focus()
    if /email address/.test(error)
      @el.querySelector('[name=email_address]').focus()

  render: =>
    @el.classList[if @identity.has("keys") then "add" else "remove"]("complete")
    @el.classList[if @identity.has("keys") then "remove" else "add"]("incomplete")
    @el.classList[if @error then "add" else "remove"]("failed")
    @el.querySelector("div.error.message").innerHTML = @error
