class WritePostcardView extends Backbone.View
  module.exports = this
  HTML = require "./HTML.coffee"
  Identity = require "../models/identity.coffee"
  Postcard = require "../models/postcard.coffee"
  MakeKeysView = require "./make_keys_view.coffee"
  IdentityView = require "./identity_view.coffee"
  PostieView = require "./postie_view.coffee"
  OutputsView = require "./outputs_view.coffee"

  attributes: {id:"write_postcard_view"}

  initialize: (params) ->
    @postcard = window.postcard = new Postcard
    @identity = window.identity = minipost.identity ? new Identity
    @postcard.set
      "text": params.text
      "hue": params.hue or Math.round(Math.random()*(360-120))+60
      "mailto": params.mailto
      "mailfrom": params.mailfrom
    @postcard.postie.set
      "email_address": params.mailto
      "miniLockID": params.miniLockID
    @identity.set
      "email_address": params.mailfrom

    @render()
    document.body.appendChild(@el)

    new PostieView
      el: @el.querySelector("div.postie")
      model: @postcard.postie
    new MakeKeysView
      el: @el.querySelector("div.make_keys_view")
      model: @identity
    new IdentityView
      el: @el.querySelector("div.identity")
      model: @identity
    new OutputsView
      el: @el.querySelector("div.outputs_view")
      model: @postcard

    @identity.on "keypair:start", =>
      document.querySelector(".postcard").classList.add("making_keys")

    @identity.on "keypair:ready", =>
      document.querySelector(".postcard").classList.add("encrypting")
      Function.delay 333, => @postcard.encrypt(@identity.keys())

    @postcard.on "encrypt:complete", =>
      document.querySelector(".postcard").classList.remove("encrypting")
      document.querySelector(".postcard").classList.add("encrypted")

    @el.focus()
    if @postcard.isAcceptable() and @identity.keys()
      @postcard.encrypt(@identity.keys())
    else
      Function.delay 666, => @el.querySelector("textarea.undefined,input.undefined")?.focus()

  events:
    "input [name=text]": "setText"
    "input [name=mailto]": "setMailto"
    "input [name=miniLockID]": "setMiniLockID"
    "input .make_keys_view [name=email_address]": "setMailFrom"
    "click button.commit": "makePostcard"
    "input [name=hue]": "setHueOfBody"
    "change [name=hue]": "setHue"

  makePostcard: (event) ->
    return @el.querySelector("[name=text]").focus() unless @postcard.get("text")
    return @el.querySelector("[name=mailto]").focus() unless @postcard.get("mailto")
    return @el.querySelector("[name=miniLockID]").focus() unless @postcard.get("miniLockID")
    return @el.querySelector(".make_keys_view [name=email_address]").focus() unless @identity.get("email_address")
    return @el.querySelector(".make_keys_view [name=secret_phrase]").focus() unless @identity.get("secret_phrase")
    if @identity.keys()
      @postcard.encrypt(@identity.keys())
    else
      @identity.makeKeyPair()

  setText: (event) ->
    @postcard.set "text", @el.querySelector("textarea").value

  setMailto: (event) ->
    @postcard.set "mailto", event.target.value

  setMiniLockID: (event) ->
    @postcard.set "miniLockID", event.target.value

  setMailFrom: (event) ->
    @postcard.set "mailfrom", event.target.value

  setHueOfBody: (event) ->
    $(document.body).css
      "background-color": "hsl(#{ event.currentTarget.value }, 66%, 66%);"
      "transition": "none"

  setHue: (event) ->
    @postcard.set "hue", event.currentTarget.value
    $(document.body).css
      "background-color": "hsl(#{ @postcard.get "hue" }, 66%, 66%);"
      "transition": null

  renderBodyBackgroundColor: ->
    $(document.body).css "background-color": "hsl(#{ @postcard.get "hue" }, 66%, 66%);"

  render: ->
    document.querySelector("title").innerText = "Write a miniLock Postcard"
    document.querySelector("body > h1").innerText = "Write a miniLock Postcard"
    @renderBodyBackgroundColor()
    @el.innerHTML = """
      <article class="postcard #{ if @postcard.isLocked() then 'locked' else 'unlocked' }">
        <header>
          This postcard will be encrypted with <em>#{HTML.a "miniLock", href: "https://minilock.io"}</em> <br>to ensure no one else can sneak a peek.
        </header>
        <a class="stamp"></a>
        <b class="line"></b>
        <div class="decrypted text">
          <label for="postcard_text_input" tabindex="-1">Write a lovely note…</label>
          #{HTML.textarea id: "postcard_text_input", name: "text", spellcheck: "off", value: @postcard.get("text") }
        </div>
        <div class="hue">
          <label for="postcard_hue_input" tabindex="-1">Hue</label>
          <input id="postcard_hue_input" tabindex="-1" name="hue" type="range" min="#{@postcard.minHue}" max="#{@postcard.maxHue}" value="#{ @postcard.get("hue") or "" }">
        </div>
        <div class="east">
          <div class="postie"></div>
          <br>
          <div class="make_keys_view">
            <header>
              <div class="error message">#{undefined}</div>
            </header>
            <div class="email_address">
              <h2><label for="author_address">From</label></h2>
              #{HTML.input id:"author_address", type: "email", name: "email_address", value: @identity.get("email_address"), placeholder: "Paste your address"}
            </div>
            <div class="secret_phrase">
              <h2><label for="author_secret_phrase">Secret</label></h2>
              #{HTML.textarea id:"author_secret_phrase", name: "secret_phrase", placeholder: "Type your secret phrase…"}
            </div>
            <div class="identity"></div>
          </div>
          <div class="key_pair operation progress_graphic">
            <div class="progress"></div>
          </div>
          <div class="encrypt operation progress_graphic">
            <div class="progress"></div>
          </div>
          <br>
          <button class="commit">Make Postcard</button>
        </div>
      </article>
      <div class="outputs_view"></div>
      <nav style="display:#{if location.protocol.match("safariextension") then "none" else "block"};">
        <h3>Site Map</h3>
        <a tabindex="-1" #{'href="/"' unless location.pathname is "/" }>#{minipost.hostname}</a><br>
        <a tabindex="-1" #{'href="'+"/write#{ minipost.pageSuffix }"+'"' unless location.pathname is "/write#{ minipost.pageSuffix }" }>#{minipost.hostname}/write</a><br>
        <a tabindex="-1" #{'href="'+"/unlock#{ minipost.pageSuffix }"+'"' unless location.pathname is "/unlock#{ minipost.pageSuffix }" }>#{minipost.hostname}/unlock</a><br>
      </nav>
    """
