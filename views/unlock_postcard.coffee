class UnlockPostcardView extends Backbone.View
  module.exports = this
  HTML = require "./HTML.coffee"
  Identity = require "../models/identity.coffee"
  Postcard = require "../models/postcard.coffee"
  MakeKeysView = require "./make_keys_view.coffee"
  IdentityView = require "./identity_view.coffee"
  OutputsView = require "./outputs_view.coffee"

  title: -> "Unlock #{if @identity.has("email_address") then "your" else (if @postcard.has("Base58") then "this" else "a")} miniLock Postcard"
  attributes: {id: "unlock_postcard_view"}

  initialize: (params) ->
    @postcard = window.postcard = new Postcard
    @postcard.set "Base58", params.Base58, validate:yes
    @identity = window.identity = new Identity
    @identity.set "email_address", params.address, validate:yes
    @initialRender()
    @initializeViews()
    @initializeEventListeners()

  initialRender: ->
    @renderHTML()
    @render()
    document.body.appendChild(@el)
    @el.focus()
    Function.delay 666, => @el.querySelector("[name=Base58].undefined,[name=email_address].undefined,[name=secret_phrase].undefined")?.focus()

  initializeViews: ->
    new MakeKeysView
      el: @el.querySelector("div.make_keys_view")
      model: @identity
    new IdentityView
      el: @el.querySelector("div.identity")
      model: @identity
    new OutputsView
      el: @el.querySelector("div.outputs_view")
      model: @postcard

  initializeEventListeners: ->
    @listenTo @identity, "keypair:ready", @unlockPostcard
    # @listenTo @postcard, "change:hue", @render
    @listenTo @postcard, "change:Base58", @render
    # @listenTo @postcard, "change:text", @render
    # @listenTo @postcard, "change:senderID", @render
    @listenTo @postcard, "decrypt:complete", @render
    @listenTo @postcard, "decrypt:error", @decryptError

  events:
    "input [name=secret_phrase]": "setSecretPhrase"
    "input [name=email_address]": "setEmailAddress"
    "input .Base58.encoded": "setBase58encodedInput"
    "change input[type=file]": "setFileInput"
    "click button.lock": "lockPostcard"
    "click button.unlock": "unlockPostcard"

  lockPostcard: (event) ->
    @postcard.lock()
    @render()

  unlockPostcard: (event) ->
    if @identity.keys()
      @postcard.unlock(@identity.keys())
    else
      @identity.makeKeyPair()

  decryptError: (error) ->
    if error is "Can’t decrypt this file with this set of keys."
      $("body").css
        "background-color": "hsl(355, 100%, 66%)"
        "transition": "none"
      Function.delay 333, =>
        @el.querySelector(".make_keys_view [name=email_address]").focus()
        @identity.unset("keys")
        @el.querySelector("article").classList.remove("keys_are_ready")
        @el.querySelector(".make_keys_view .public.key div").innerHTML = HTML.renderByteStream new Uint8Array 32
        @el.querySelector(".make_keys_view .secret.key div").innerHTML = HTML.renderByteStream new Uint8Array 32
        @el.querySelector(".make_keys_view [name=miniLockID]").classList.remove("valuable")
        @el.querySelector(".make_keys_view [name=miniLockID]").classList.add("expired")
        $("body").css
          "background-color": ""
          "transition": "background-color 666ms linear 666ms"
        $("body").one "transitionend", ->
          $("body").css
            "background-color": ""
            "transition": ""

  setFileInput: (event) ->
    console.info event.target.files[0]
    @postcard.set("file", event.target.files[0])
    @postcard.unlockFile(@identity.keys())

  setBase58encodedInput: (event) ->
    Base58input = event.target.value.replace(/\n/g, "").trim()
    if Base58input is ""
      @postcard.unset "Base58"
      event.currentTarget.classList.remove("acceptable")
      event.currentTarget.classList.add("unacceptable")
    else
      if @postcard.set("Base58", Base58input, validate:yes)
        console.info "Accepted Base58 input"
        event.currentTarget.classList.add("acceptable")
        event.currentTarget.classList.remove("unacceptable")
      else
        console.info "Rejected Base58 input"
        event.currentTarget.classList.remove("acceptable")
        event.currentTarget.classList.add("unacceptable")
    @render()

  setSecretPhrase: (event) ->
    @identity.set "secret_phrase", event.currentTarget.value

  setEmailAddress: (event) ->
    @identity.set "email_address", event.currentTarget.value

  render: =>
    @renderTitle()
    @renderBodyBackgroundColor()
    @renderText()
    @el.querySelector("article.postcard").classList[if @postcard.isUndefined() then 'add' else 'remove']("undefined")
    @el.querySelector("article.postcard").classList[if @postcard.isLocked() then 'add' else 'remove']("locked")
    @el.querySelector("article.postcard").classList[if @postcard.isUnlocked() then 'add' else 'remove']("unlocked")
    @el.querySelector(".author input[type=email]").value = @postcard.get("mailfrom") or "Unknown"
    @el.querySelector(".author input[name=miniLockID]").value = @postcard.get("senderID") or ""
    @el.querySelector(".author input[name=miniLockID]").classList.remove("blank")
    if @postcard.get("senderID")
      @el.querySelector(".author .public.key div").innerHTML = HTML.renderByteStream miniLockLib.ID.decode(@postcard.get("senderID"))
    else
      @el.querySelector(".author .public.key div").innerHTML = HTML.renderByteStream new Uint8Array 32


  renderTitle: ->
    document.querySelector("title").innerText = @title()
    document.querySelector("body > h1").innerText = @title()

  renderBodyBackgroundColor: ->
    color = if @postcard.get("hue")
      "hsl(#{ @postcard.get("hue") }, 66%, 66%);"
    else
      "hsl(260, 8%, 50%);"
    $(document.body).css "background-color": color

  renderText: ->
    @el.querySelector(".decrypted.text div").innerText = @postcard.get("text")

  renderHTML: ->
    @el.innerHTML = """
      <article class="postcard #{ if @postcard.isLocked() then 'locked' else 'unlocked' }">
        <b class="line"></b>
        <a class="stamp"></a>
        #{HTML.stamp "undefined", alt:"Undefined Postcard"}
        #{HTML.stamp "locked", alt:"Locked Postcard"}
        #{HTML.stamp "unlocked", alt:"Unlocked Postcard"}
        #{HTML.stamp "confused", alt:"Confused About Postcard Input"}
        <div class="Base58 encoded encrypted input #{if @postcard.get("Base58") then "acceptable valuable" else "undefined"}">
          <label class="undefined">Paste your postcard code:</label>
          <label class="unacceptable"><span class="erase">⌫</span> This is not a postcard code:</label>
          <label class="acceptable">Base58 encoded encrypted postcard code:</label>
          #{HTML.textarea name: "Base58", value: @postcard.get("Base58")}
        </div>
        <div class="encrypted file input">
          <label class="undefined"></label>
          <input type="file" name="blob" class="undefined">
        </div>
        <div class="UTF8 encoded decrypted text">
          <label>Decrypted postcard text</label>
          <div>#{@postcard.get('text') or ""}</div>
        </div>
        <div class="east">
          <div class="make_keys_view">
            <div class="error message"></div>
            <div class="email_address">
              <h2>Address</h2>
              #{HTML.input name:"email_address", placeholder:"Paste your address", type: "email", value: @identity.get("email_address")}
            </div>
            <div class="secret_phrase">
              #{HTML.textarea name: "secret_phrase", placeholder: "Type your secret phrase…"}
            </div>
            <div class="identity"></div>
          </div>
          <div class="key_pair operation progress_graphic">
            <div class="progress"></div>
          </div>
          <div class="decrypt operation progress_graphic">
            <div class="progress"></div>
          </div>
          <br>
          <div class="author">
            <div class="email_address">
              <h2>From</h2>
              #{HTML.input name:"email_address", type: "email", tabindex: "-1", readonly: "yes", value:""}
            </div>
            <div class="miniLockID">
              <h2>#{HTML.miniLockIconHTML} ID</h2>
              #{HTML.input type: "text", name: "miniLockID", tabindex: "-1", readonly: "yes"}
            </div>
            <div class="public key">
              <h2>Public Key</h2>
              <div>#{HTML.renderByteStream @identity.publicKey() ? new Uint8Array 32}</div>
            </div>
          </div>
          <br>
          <button class="unlock">Unlock Postcard</button><button class="lock">Lock Postcard</button>
        <div>
      </article>
      <div class="outputs_view"></div>
      <nav style="display:#{if location.protocol is "safari-extension:" then "none" else "block"};">
        <h3>Site Map</h3>
        <a tabindex="-1" #{'href="/"' unless location.pathname is "/" }>#{minipost.hostname}</a><br>
        <a tabindex="-1" #{'href="'+"/write#{ minipost.pageSuffix }"+'"' unless location.pathname is "/write#{ minipost.pageSuffix }" }>#{minipost.hostname}/write</a><br>
        <a tabindex="-1" #{'href="'+"/unlock#{ minipost.pageSuffix }"+'"' unless location.pathname is "/unlock#{ minipost.pageSuffix }" }>#{minipost.hostname}/unlock</a><br>
      </nav>
    """
