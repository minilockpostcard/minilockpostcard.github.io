class OutputView extends Backbone.View
  module.exports = this
  HTML = require "./HTML.coffee"
  Shortcut = require "../models/shortcut.coffee"

  initialize: (options) ->
    @postcard = options.model
    @shortcut = new Shortcut
    @listenTo @postcard, "change:Base58", @render
    @listenTo @postcard, "encrypt:complete", @render
    @listenTo @postcard, "encrypt:error", @render
    $(window).on "online", @render
    $(window).on "offline", @render
    @renderHTML()
    @render()

  events:
    "click .rw": "mousedownOnReadWriteInput"
    "input .rw": "readWriteInput"
    "focusout .rw": "readWriteInputLostFocus"
    "click .mail button": "sendPostcardByMail"
    "click .file button": "savePostcardFile"
    "click .shortcut button": "postPostcardShortcut"

  sendPostcardByMail: (event) ->
    if @mailOutputIsAvailable()
      if undefinedInput = @el.querySelector(".mail.output [name=email_address].undefined")
        event.preventDefault()
        undefinedInput.focus()
      else
        event.target.classList.add("activated")
        event.target.blur()
        linkToOpenMailMessage = @el.querySelector(".mail.output a")
        linkToOpenMailMessage.href = @postcardMailtoURL()
        linkToOpenMailMessage.click()
        Function.delay 333, -> event.target.classList.remove("activated")
    else
      event.preventDefault()

  # if safari then post encoded blob to server and send it back with Content-Disposition header.
  savePostcardFile: (event) ->
    if @fileOutputIsAvailable()
      event.target.classList.add("activated")
      event.target.blur()
      basename = @el.querySelector(".file.output [name=basename]").value
      reader = new FileReader
      reader.readAsDataURL @postcard.encryptedBlob()
      reader.onloadend = =>
        linkToSaveFile = @el.querySelector("div.file a")
        linkToSaveFile.href = reader.result
        linkToSaveFile.download = "#{basename}.minilock"
        linkToSaveFile.click()
        event.target.classList.remove("activated")
    else
      event.preventDefault()

  postPostcardShortcut: (event) ->
    @shortcut.set "Base58": @postcard.get("Base58")
    @shortcut.save()
    @shortcut.once "sync", =>
      console.info "Shortcut is ready", shortcut

  mailOutputIsAvailable: ->
    @postcard.has("Base58")

  fileOutputIsAvailable: ->
    @postcard.has("Base58")

  URLoutputIsAvailable: ->
    @postcard.has("Base58")

  shortcutOutputIsAvailable: ->
    navigator.onLine and @postcard.has("Base58")

  render: =>
    @el.querySelector(".mail.output button").disabled = @mailOutputIsAvailable() is no
    @el.querySelector(".mail.output input").disabled = @mailOutputIsAvailable() is no
    @el.querySelector(".mail.output").classList[if @mailOutputIsAvailable() then "add" else "remove"]("available")
    @el.querySelector(".mail.output").classList[if @mailOutputIsAvailable() then "remove" else "add"]("unavailable")
    @el.querySelector(".file.output button").disabled = @fileOutputIsAvailable() is no
    @el.querySelector(".file.output input").disabled = @fileOutputIsAvailable() is no
    @el.querySelector(".file.output").classList[if @fileOutputIsAvailable() then "add" else "remove"]("available")
    @el.querySelector(".file.output").classList[if @fileOutputIsAvailable() then "remove" else "add"]("unavailable")
    @el.querySelector(".shortcut.output button").disabled = @mailOutputIsAvailable() is no
    @el.querySelector(".shortcut.output").classList[if @shortcutOutputIsAvailable() then "add" else "remove"]("available")
    @el.querySelector(".shortcut.output").classList[if @shortcutOutputIsAvailable() then "remove" else "add"]("unavailable")
    @el.querySelector(".copy.URL.output").classList[if @URLoutputIsAvailable() then "add" else "remove"]("available")
    @el.querySelector(".copy.URL.output").classList[if @URLoutputIsAvailable() then "remove" else "add"]("unavailable")
    @el.querySelector(".copy.URL a").innerHTML = "https://#{location.hostname}#{@postcard.url()}"
    @el.querySelector(".visit.URL.output").classList[if @URLoutputIsAvailable() then "add" else "remove"]("available")
    @el.querySelector(".visit.URL.output").classList[if @URLoutputIsAvailable() then "remove" else "add"]("unavailable")
    @el.querySelector(".visit.URL a").href = @postcard.url()

  renderHTML: ->
    @el.innerHTML = """
      <div class="mail output"><a class="mail" href="#{undefined}" tabindex="-1"></a>
        <header>
          <button>Mail Postcard</button> to
          <a class="rw #{if @postcard.postie.get("email_address") then "valuable" else "undefined"}"><input placeholder="Paste an address" name="email_address" type="email" value="#{@postcard.postie.get("email_address") or ""}"><var>#{@postcard.postie.get("email_address") or "Paste an address"}</var></a>
        </header>
        <p>
          Open a message in your mail program with a postcard code and link to unlock it.
          You control the final delivery from your mail program.
        </p>
      </div>
      <div class="file output"><a class="file" href="#{undefined}" download="#{undefined}.minilock" tabindex="-1"></a>
        <header>
          <button>Save File</button> as
          <a class="rw"><input type="text" name="basename" value="Postcard" default="Postcard"><var>Postcard</var>.minilock</a>
          </span>
        </header>
        <p>
          Download a postcard file that you can move around any way you please.
          Upload the file to this site when you need to unlock it.
        </p>
        <p style="display:#{if navigator.userAgent.match(/Version\/([\d.]+)([^S](Safari)|[^M]*(Mobile)[^S]*(Safari))/) then "block" else "none"};">
          Unfortunately, the filename will be <em>Unknown</em> because we are having touble with Safari right now.
        </p>
      </div>
      <div class="shortcut output" style="display:none;">
        <header>
          <button>Push Postcard</button> to <a href="">minipost.link#<span class="io" contenteditable="plaintext-only" data-name="basename">#{@shortcut.get("identifier")}</span></a>
        </header>
        <p>
          Put this postcard at a publically accesible network address
          that is short enough to share
          in a bird song or another sort of chitter chatter.
        </p>
      </div>
      <div class="copy URL output">
        <h2>Copy Postcard URL</h2>
        <div><a class="copy_n_paste">#{undefined}</a></div>
      </div>
      <div class="visit URL output" style="display:#{if location.pathname.match("write") then "block" else "none"};">
        <h2>#{HTML.a "Visit Postcard Page", href: undefined, class: "visit"}</h2>
        <p>To see what your postie will see.</p>
      </div>
    """

  mousedownOnReadWriteInput: (event) ->
    event.currentTarget.querySelector("input").focus()

  readWriteInput: (event) ->
    input = event.currentTarget.querySelector("input")
    output = event.currentTarget.querySelector("var")
    if input.value
      output.innerText = input.value
      event.currentTarget.classList.remove("undefined")
    else if input.getAttribute("default")
      output.innerText = ""
    else
      output.innerText = input.getAttribute("placeholder")
      event.currentTarget.classList.add("undefined")

  postcardMailtoURL: ->
    address = encodeURIComponent @el.querySelector(".mail.output [name=email_address]").value
    subject = encodeURIComponent "miniLock postcard for you!"
    body    = encodeURIComponent """
      This is a miniLock postcard code:

      #{@postcard.blockOfBase58Text()}

      To unlock your postcard, copy the code and paste it at:

      https://#{location.hostname}/unlock
    """
    "mailto:#{address}?Subject=#{subject}&Body=#{body}"

  readWriteInputLostFocus: (event) ->
    input = event.currentTarget.querySelector("input")
    output = event.currentTarget.querySelector("var")
    if (input.value is "") and input.getAttribute("default")
      input.value = input.getAttribute("default")
      output.innerText = input.getAttribute("default")
