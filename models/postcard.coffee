class Postcard extends Backbone.Model
  module.exports = this
  Identity = require "../models/identity.coffee"

  initialize: (options) ->
    @postie = new Identity
    @author = new Identity

  minHue: 40
  maxHue: 320

  url: (options={}) ->
    "/unlock#{minipost.pageSuffix}?Base58=#{@get("Base58")}"

  validate: (attributes) ->
    if attributes.Base58?
      if attributes.Base58.trim() is ""
        return "Unacceptable Base58 input"
      if attributes.Base58.length < 256
        return "Unacceptable Base58 input"
      try
        miniLockLib.Base58.decode(attributes.Base58)
      catch error
        return "Unacceptable Base58 input"
    return undefined

  isUndefined: ->
    @get("text") is undefined and @get("Base58") is undefined

  isUnlocked: ->
    @has("text") and @has("hue") and @has("senderID") and @has("recipientID")

  isLocked: ->
    @get("text") is @get("hue") is @get("senderID") is @get("recipientID") is undefined

  lock: ->
    @unset("text")
    @unset("hue")
    @unset("mailto")
    @unset("mailfrom")
    @unset("senderID")
    @unset("recipientID")

  serialize: ->
    JSON.stringify
      text: @get("text")
      hue: @get("hue")
      mailto: @get("mailto")
      mailfrom: @get("mailfrom")

  parse: (serialized) ->
    JSON.parse serialized

  blockOfBase58Text: ->
    lineLength = 0
    block = ""
    if @has("Base58")
      for char in @get("Base58")
        if lineLength < 80
          block += char
        else
          lineLength = 0
          block += "\n"
          block += char
        lineLength = lineLength + 1
    return block

  isAcceptable: ->
    switch
      when @get("text") is undefined
        return no
      when @get("text").trim() is ""
        return no
      when miniLockLib.ID.isAcceptable(@get("miniLockID")) is no
        return no
      else
        return yes

  encryptedBlob: ->
    @get("file") or new Blob [miniLockLib.Base58.decode @get("Base58")], type: "application/octet-stream"

  unencryptedBlob: ->
    new Blob [@serialize()], type: "text/plain"

  unlock: (keys)->
    operation = new miniLockLib.DecryptOperation
      data: @encryptedBlob()
      keys: keys
    operation.start (error, decrypted) =>
      if decrypted
        console.info "decrypted", decrypted, decrypted.duration
        reader = new FileReader
        reader.readAsArrayBuffer(decrypted.data)
        reader.onerror = (event) =>
          @trigger "decrypt:error", "reader.onerror", event
        reader.onabort = (event) =>
          @trigger "decrypt:error", "reader.onabort", event
        reader.onload = =>
          @set @parse miniLockLib.NaCl.util.encodeUTF8(new Uint8Array(reader.result))
          @set "senderID", decrypted.senderID
          @set "recipientID", decrypted.recipientID
          @trigger "decrypt:complete"
      else
        console.error error, operation
        Function.delay 1, => @trigger "decrypt:error", error

  unlockFile: (keys)->
    operation = new miniLockLib.DecryptOperation
      data: @get("file")
      keys: keys
    operation.start (error, decrypted) =>
      if decrypted
        console.info "decrypted", decrypted, decrypted.duration
        reader = new FileReader
        reader.readAsArrayBuffer(decrypted.data)
        reader.onerror = (event) =>
          @trigger "encrypt:reader:error", event
        reader.onabort = (event) =>
          @trigger "encrypt:reader:abort", event
        reader.onload  = (event) =>
          decryptedBytes = new Uint8Array reader.result
          @set @parse miniLockLib.NaCl.util.encodeUTF8(decryptedBytes)
          @trigger "decrypt:complete"
      else
        console.error error, operation
        Function.delay 1, => @trigger "decrypt:error", error

  encrypt: (keys)->
    operation = new miniLockLib.EncryptOperation
      data: @unencryptedBlob()
      name: "Postcard for #{@postie.get("email_address")} in hue ##{@get('hue')}"
      keys: keys
      miniLockIDs: [@postie.get("miniLockID")]
    operation.start (error, encrypted) =>
      if encrypted
        console.info "encrypted", encrypted, encrypted.duration
        reader = new FileReader
        reader.readAsArrayBuffer(encrypted.data)
        reader.onerror = (event) =>
          @trigger "encrypt:reader:error", event
        reader.onabort = (event) =>
          @trigger "encrypt:reader:abort", event
        reader.onload  = (event) =>
          encryptedBytes = new Uint8Array reader.result
          @set "Base58", miniLockLib.Base58.encode(encryptedBytes)
          Function.delay 1, => @trigger "encrypt:complete"
      else
        console.error error, operation
        Function.delay 1, => @trigger "encrypt:error", error
