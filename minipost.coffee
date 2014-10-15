if location.hostname is "minipostlink.github.io" and location.protocol isnt "https:"
  return window.location = location.toString().replace("http:", "https:")

Function.delay = (amount, f) -> setTimeout(f, amount)

window.minipost =
  hostname: if location.hostname is "minipost.dev" then "minipost.link" else location.hostname
  pageSuffix: if location.hostname in ["minipost.link", "auto.minipost.link", "minipostlink.github.io"] then "" else ".html"

$(document).ready ->
  typefaces = {avenir: "AvenirNext-DemiBold", corbel: "Corbel"}
  available = []
  tests = ["""<a id="monospace" style="font: 100px/1 monospace; display:inline-block;">ii</a>"""]
  for id, name of typefaces
    tests.push """<a id="#{id}" style="font: 100px/1 '#{name}', monospace; display:inline-block;">ii</a>"""
  container = document.createElement("div")
  container.innerHTML = tests.join("")
  document.body.appendChild(container)
  monospaceWidth = $("#monospace").width()
  for id in Object.keys(typefaces)
    typefaceIsAvailable = $("##{id}").width() isnt monospaceWidth
    available.push(id) if typefaceIsAvailable
  container.remove()
  document.body.classList.add(available[0])

$(document).ready ->
  minipost.router = new MinipostRouter
  Backbone.history.start({pushState: true}) unless location.protocol is "chrome-extension:"

class MinipostRouter extends Backbone.Router
  IndexPageView      = require "./views/index_page_view.coffee"
  WritePostcardView  = require "./views/write_postcard.coffee"
  UnlockPostcardView = require "./views/unlock_postcard.coffee"

  initialize: ->
    $(window).on {@offline, @online}
    @renderNetworkStatus()

  routes:
    "": "showIndex"
    "index": "showIndex"
    "write": "writePostcard"
    "unlock": "unlockPostcard"
    "index.html": "showIndex"
    "write.html": "writePostcard"
    "unlock.html": "unlockPostcard"
    ":bundle/index.html": "showIndex"
    ":bundle/write.html": "writePostcard"
    ":bundle/unlock.html": "unlockPostcard"

  showIndex: (params) ->
    console.info "Open Index", params
    @currentView?.remove()
    @currentView = new IndexPageView params

  writePostcard: (params) ->
    console.info "Write Postcard", params
    @currentView?.remove()
    @currentView = new WritePostcardView params

  unlockPostcard: (params) ->
    console.info "Unlock Postcard", params
    @currentView?.remove()
    @currentView = new UnlockPostcardView params

  execute: (callback, args) ->
    console.info "execute", args
    if (callback) then callback.call(this, @params())

  params: (url=window.location) ->
    params = {}
    if url.search
      for pair in url.search.replace("?", "").split("&")
        [name, value] = pair.split("=")
        params[name] = decodeURIComponent value
    return params

  offline: =>
    @renderNetworkStatus()

  online: =>
    @renderNetworkStatus()

  renderNetworkStatus: ->
    document.body.classList[if navigator.onLine then "add" else "remove"]("online")
    document.body.classList[if navigator.onLine then "remove" else "add"]("offline")



$(document).ready ->
  document.body.classList.add("ready")
  if navigator.userAgent.match(/Paparazzi!/)
    document.body.style.padding = "0px" if window.innerWidth is 1200
    document.body.style.padding = "180px 0 0" if window.innerWidth is 3000


$(document).on "click", "a[href]", (event) ->
  hrefAttribute = event.currentTarget.getAttribute("href")
  return if hrefAttribute[0] isnt "/"
  return if event.metaKey is true # Let them open tabs!
  event.preventDefault()
  destination = new URL event.currentTarget.href
  if location.protocol is "chrome-extension:"
    router = minipost.router
    method = switch
      when destination.pathname.match("write") then "writePostcard"
      when destination.pathname.match("unlock") then "unlockPostcard"
      else "showIndex"
    router[method] router.params(destination)
  else
    Backbone.history.navigate hrefAttribute, trigger:yes


$(document).on "mousedown", "a.copy_n_paste, em.copy_n_paste", (event) ->
  event.preventDefault()
  range = document.createRange()
  range.selectNodeContents(event.currentTarget)
  selection = window.getSelection()
  selection.removeAllRanges()
  selection.addRange(range)


$(document).on "input", "textarea, input", (event) ->
  if event.currentTarget.value.trim() is ""
    event.currentTarget.classList.add("undefined")
    event.currentTarget.classList.remove("valuable")
  else
    event.currentTarget.classList.remove("undefined")
    event.currentTarget.classList.add("valuable")


$(document).on "input", "div.input", (event) ->
  if event.target.value.trim() is ""
    event.currentTarget.classList.add("undefined")
    event.currentTarget.classList.remove("valuable")
  else
    event.currentTarget.classList.remove("undefined")
    event.currentTarget.classList.add("valuable")


Alice = minipost.Alice = {}
Alice.secretPhrase = "lions and tigers and all the fear in my heart"
Alice.emailAddress = "alice@example.org"
Alice.miniLockID   = "zDRLdbPFEb95Q7xzTuiHr24qUSpearDoB5c9DS1To93cZ"

Bobby = minipost.Bobby = {}
Bobby.secretPhrase = "No I also got a quesadilla, it’s from the value menu"
Bobby.emailAddress = "bobby@example.org"
Bobby.miniLockID   = "PYN1P1uhHXTNT5MUccZYv1mhvPBFQX2cS7g9n3wcof8JU"
