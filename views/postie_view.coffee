class PostieView extends Backbone.View
  module.exports = this
  HTML = require "./HTML.coffee"
  Identity = require "../models/identity.coffee"

  initialize: (options) ->
    @postie = options.model or new Identity
    @listenTo @postie, "change:email_address", @render
    @listenTo @postie, "change:miniLockID", @render
    @el.innerHTML = """
      <div class="email_address">
        <h2><label for="postie_address">Mail to</label></h2>
        #{HTML.input id: "postie_address", type: "email", name: "email_address", value: @postie.get("email_address"), placeholder: "Paste your postie’s address"}
      </div>
      <div class="miniLockID">
        <h2><label for="postie_miniLockID">#{HTML.miniLockIconHTML} ID</label></h2>
        #{HTML.input id: "postie_miniLockID", type: "text", name: "miniLockID", value: @postie.get("miniLockID"), placeholder: "Paste your postie’s miniLock ID"}
      </div>
      <div class="public key">
        <h2>Public Key</h2>
        <div>#{HTML.renderByteStream @postie.publicKey() or new Uint8Array 32}</div>
      </div>
    """
    @render()

  events:
    "input [name=miniLockID]": "setMiniLockID"
    "input [name=email_address]": "setEmailAddress"

  setMiniLockID: (event) ->
    @postie.set "miniLockID", event.currentTarget.value

  setEmailAddress: (event) ->
    @postie.set "email_address", event.currentTarget.value

  render: =>
    @el.classList[if @postie.has("miniLockID") then "remove" else "add"]("undefined")
    @el.querySelector(".public.key > div").innerHTML = HTML.renderByteStream @postie.publicKey() or new Uint8Array 32
