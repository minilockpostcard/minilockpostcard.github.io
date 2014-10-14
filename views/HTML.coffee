exports.stamps = require "./HTML.stamps.coffee"

exports.stamp = (name, attributes={}) ->
  attributes.class = "stamp"
  @stamps[name].replace("<svg", "<svg #{@attributes(attributes)}")

exports.attributes = (attributes) ->
  (name+"="+'"'+value+'"' for name, value of attributes).join(" ")

exports.a = (text, attributes={}) ->
  if attributes.href
    if attributes.href[0] is "/"
      attributes.href = if attributes.href.indexOf("?") isnt -1
        attributes.href.replace("?", "#{minipost.pageSuffix}?")
      else
        attributes.href + minipost.pageSuffix
    attributes.href = encodeURI attributes.href
  attributes.tabindex ?= -1
  """<a #{@attributes(attributes)}>#{text}</a>"""

exports.input = (attributes) ->
  attributes.class = if attributes.value? then "valuable" else "undefined"
  attributes.value ?= ""
  "<input #{@attributes(attributes)}>"

exports.textarea = (attributes) ->
  attributes.class = if attributes.value? then "valuable" else "undefined"
  value = attributes.value or ""
  delete attributes.value
  "<textarea #{@attributes(attributes)}>#{value}</textarea>"


exports.miniLockIconHTML = """
  <svg viewBox="0 0 525 702" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
    <g fill-rule="evenodd">
      <path fill="black" d="M347.8125,478.934579 C369.558712,478.934579 387.1875,461.310499 387.1875,439.570093 C387.1875,417.829688 369.558712,400.205607 347.8125,400.205607 C326.066288,400.205607 308.4375,417.829688 308.4375,439.570093 C308.4375,461.310499 326.066288,478.934579 347.8125,478.934579 Z M177.1875,478.934579 C198.933712,478.934579 216.5625,461.310499 216.5625,439.570093 C216.5625,417.829688 198.933712,400.205607 177.1875,400.205607 C155.441288,400.205607 137.8125,417.829688 137.8125,439.570093 C137.8125,461.310499 155.441288,478.934579 177.1875,478.934579 Z M177.1875,255.869159 L177.1875,223.065421 L177.228748,223.065421 C177.201304,221.975295 177.1875,220.881783 177.1875,219.785047 C177.1875,149.12873 234.481061,91.8504673 305.15625,91.8504673 C375.831439,91.8504673 433.125,149.12873 433.125,219.785047 C433.125,220.881783 433.111196,221.975295 433.083752,223.065421 L433.125,223.065421 L433.125,255.869159 L523.525694,255.869159 L525,255.869159 L525,219.785047 C525,98.4011172 426.5726,0 305.15625,0 C183.7399,0 85.3125,98.4011172 85.3125,219.785047 L85.3125,255.869159 L86.7868059,255.869159 L177.1875,255.869159 L177.1875,255.869159 Z M131.25,616.71028 C105.879419,616.71028 85.3125,596.148853 85.3125,570.785047 L85.3125,347.719626 L439.6875,347.719626 L439.6875,570.785047 C439.6875,596.148853 419.120581,616.71028 393.75,616.71028 L131.25,616.71028 L131.25,616.71028 Z M131.25,702 C58.7626266,702 0,643.253064 0,570.785047 L0,255.869159 L525,255.869159 L525,570.785047 C525,643.253064 466.237373,702 393.75,702 L131.25,702 L131.25,702 Z"></path>
    </g>
  </svg>
  """

exports.renderByteStream = (typedArray) ->
  if typedArray
    bytes = ('<b class="byte" style="background-color: hsla(0, 0%, 0%, '+byte/255+');"></b>' for byte in typedArray)
    '<div class="byte_stream">'+bytes.join("")+'</div>'
  else
    "&nbsp;"
