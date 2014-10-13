class IdentityView extends Backbone.View
  module.exports = this
  HTML = require "./HTML.coffee"
  Identity = require "../models/identity.coffee"

  initialize: (options) ->
    @identity = options.model or new Identity
    @listenTo @identity, "keypair:ready", @render
    @listenTo @identity, "keypair:error", @render
    @render()

  render: =>
    @el.classList[if @identity.has("keys") then "remove" else "add"]("undefined")
    @el.innerHTML = """
      <div class="miniLockID">
        <h2>#{HTML.miniLockIconHTML} ID</h2>
        #{HTML.input type: "text", name: "miniLockID", value: @identity.miniLockID(), tabindex: "-1", readonly: "yes"}
      </div>
      <div class="public key">
        <h2>Public Key</h2>
        <div>#{HTML.renderByteStream @identity.publicKey() ? new Uint8Array 32}</div>
      </div>
      <div class="secret key">
        <h2>Secret Key</h2>
        <div>#{HTML.renderByteStream @identity.secretKey() ? new Uint8Array 32}</div>
      </div>
    """
