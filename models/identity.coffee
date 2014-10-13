class Identity extends Backbone.Model
  module.exports = this

  keys: ->
    @get("keys")

  publicKey: ->
    if @has("keys") then return @get("keys").publicKey
    if @has("miniLockID") then return miniLockLib.ID.decode(@get("miniLockID"))

  secretKey: ->
    @get("keys")?.secretKey

  miniLockID: ->
    miniLockLib.ID.encode @publicKey() if @has("keys")

  makeKeyPair: ->
    @trigger "keypair:start"
    Function.delay 1, =>
      miniLockLib.makeKeyPair @get('secret_phrase'), @get('email_address'), (error, keys) =>
        if keys
          @set "keys", keys
          Function.delay 1, => @trigger "keypair:ready"
        else
          console.error(error)
          Function.delay 1, => @trigger "keypair:error", error
