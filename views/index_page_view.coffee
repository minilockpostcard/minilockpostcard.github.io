class IndexPageView extends Backbone.View
  module.exports = this
  HTML = require "./HTML.coffee"

  attributes: {id: "index_page_view"}

  initialize: ->
    $(window).on {@online, @offline}
    @render()
    document.querySelector("body").appendChild(@el)
    @el.focus()

  events:
    "mousedown .example img": "mousedownOnExampleImage"

  mousedownOnExampleImage: (event) ->
    url = event.target.parentNode.querySelector("a[href]").getAttribute("href")
    Backbone.history.navigate url, trigger:yes

  remove: ->
    $(window).off {@online, @offline}
    Backbone.View::remove.call(this)

  offline: =>
    @render()

  online: =>
    @render()

  render: ->
    document.querySelector("title").innerText = "miniLock Postcard Home"
    document.querySelector("body > h1").innerText = "Home"
    document.querySelector("body").style.backgroundColor = ""
    @el.innerHTML = """
      <header>
        #{HTML.stamp "rainbow-pink"}<b>miniLock</b> <b>Postcard</b>
      </header>
      <p>
        This is #{minipost.hostname}<br>
        <br>
        Everything we need to make and unlock postcards has loaded.<br>
        <br>
        #{if navigator.onLine then "You can disconnect your network and continue your session offline if your soul has paranormal desires." else 'And now we are offline where the air is fresh and the noise is pink.'}
        <br>
        <br>
        #{HTML.a "Make a postcard for your postie", href:"/write"}<br>
        <br>
        #{HTML.a "Unlock a postcard code or file", href:"/unlock"}<br>
      </p>
      <br>
      <br>
      <div class="examples">
        <h2>Examples</h2>
        <div class="example">
          #{HTML.a "Make a postcard for Alice", href: "/write?mailto=alice@example.org&amp;hue=60&amp;miniLockID=zDRLdbPFEb95Q7xzTuiHr24qUSpearDoB5c9DS1To93cZ" }
          <p>It’s only an example.<br>&amp; she probably won’t respond.</p>
          <img alt="Writing a postcard for Alice." src="examples/Write a postcard to Alice.png">
        </div>
        <div class="example">
          #{HTML.a "Unlock a postcard addressed to Bobby", href: "/unlock?address=bobby@example.org&amp;Base58=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" }
          <p>His secret phrase is:<br><em class="copy_n_paste">#{ minipost.Bobby.secretPhrase }</em></p>
          <img alt="Unlocking Bobby’s postcard." src="examples/Unlock a postcard for Bobby.png">
        </div>
        <div class="example">
          #{HTML.a "Post a question to the author", href: "/write?mailto=undefined@minipost.link&amp;hue=300&amp;miniLockID=29FnzFiUxGd6z8bveWWXZFhcaU5zNCkUgdnrz72SoAcsPc&amp;text=Hello!\n\nI have a question about miniLock Postcard.\n\n" }
          <p>The author of this site is <a tabindex="-1" href="https://45678.github.io/">undefined</a>.<br>Send them a message if you please.</p>
          <img alt="Posting a question to the author." src="examples/Post a question.png">
        </div>
      </div>
      <br>
      <br>
      <div class="downloads" style="#{if location.protocol is "chrome-extension:" then "display:none;" else ""}">
        <h2>Downloads</h2>
        <div class="safari">
          <a tabindex="-1" href="https://github.com/minipostlink/minipost-safari/raw/master/miniLock%20Postcard.safariextz">Get miniLock Postcard for Apple Safari</a><br>
          <p>
            This extension adds a miniLock Postcard button to your toolbar for quick access to the write and unlock screens.
            Works without a network connection.
          </p>
          <img alt="miniLock Postcard button in Safari toolbar" src="downloads/Safari + miniLock Postcard.png">
        </div>
        <br>
        <br>
        <div class="chrome">
          Get miniLock Postcard for Google Chrome<br>
          <p>
            This app appears in your Chrome Apps folder and launcher after you install it.
            Make and unlock postcards with ease; works without a network connection.
          </p>
          <p>
            Install Instructions:
          </p>
          <ol>
            <li><a href="https://github.com/minipostlink/minipost-chrome/raw/master/miniLock%20Postcard.crx">Download the <em>miniLock Postcard.crx</em> file</a> and save it to your computer.</li>
            <li>Click the Chrome menu icon <img src="downloads/Chrome menu button.png" width="29" height="29" alt="Chrome menu" title="Chrome menu"> on the browser toolbar.</li>
            <li>Select <em>Tools &gt; Extensions</em>.</li>
            <li>Locate the <em>miniLock Postcard.crx</em> file on your computer and drag it onto the Extensions page.</li>
            <li>Review the dialog that appears, and if you would like to proceed, click <em>Install</em>.
          </ol>
          <img alt="Google Chrome + miniLock Postcard" src="downloads/Chrome + miniLock Postcard.png">
        </div>
      </div>
      <br>
      <br>
      <div class="hosts">
        <h2>Hosts</h2>
        <div class="easy">
          <a tabindex="-1" href="https://minipost.link">minipost.link</a><br>
          <p>
            <a href="https://www.ssllabs.com/ssltest/analyze.html?d=minipost.link">Easy TLS connection with strong forward secure ciphers</a>.<br>
            <a tabindex="-1" href="#{location.protocol}//#{location.hostname}/certificates/minipost.link.crt">Get X.509 Certificate</a>.
            <a tabindex="-1" href="https://github.com/minipostlink/minipost/tree/deploy">Review the source code</a>.<br>
            Hosted by <a tabindex="-1" href="https://45678.github.io/">undefined</a> in Singapore.<br>
          </p>
        </div>
        <br>
        <div class="autonomous">
          <a tabindex="-1" href="https://auto.minipost.link">auto.minipost.link</a><br>
          <p>
            <a href="https://www.ssllabs.com/ssltest/analyze.html?d=auto.minipost.link">Autonomous TLS connection with strong forward secure ciphers</a>.<br>
            <a tabindex="-1" href="#{location.protocol}//#{location.hostname}/certificates/auto.minipost.link.crt">Get X.509 Certificate</a>.
            <a tabindex="-1" href="https://github.com/minipostlink/minipost/tree/deploy">Review the source code</a>.<br>
            Hosted by <a tabindex="-1" href="https://45678.github.io/">undefined</a> in New York City.<br>
          </p>
        </div>
        <br>
        <div class="github">
          <a tabindex="-1" href="https://minipostlink.github.io">minipostlink.github.io</a><br>
          <p>
            <a href="https://www.ssllabs.com/ssltest/analyze.html?d=minipostlink.github.io">Easy TLS connection with good forward secure ciphers</a><br>
            &amp; <a tabindex="-1" href="https://github.com/minipostlink/minipostlink.github.io/tree/master">an authentic view of the source code</a>.<br>
            Hosted by <a tabindex="-1" href="https://github.com/">Github</a> somewhere in the USA.
          </p>
        </div>
      </div>
    """
