module KevinsVoice
using Toolips
using ToolipsSession
using ToolipsDefaults
using ToolipsMarkdown
# welcome to your new toolips project!
audiosections = Vector{Servable}()
scheme = ColorScheme(background = "#292529",
foreground = "#8a6e8a",
faces = "#514f69",
faces_hover = "#6d6b8c",
text = "#17d1af",
text_faces = "#ffffff",
color1 = "#736ad9",
color2 = "#07ff03",
color3 = "#670669",
color4 = "#b5aeb5",
color5 = "#dbcd30",
)

function new_audiosection(name::String, c::Connection, md::String, audiosrc::String)
    splitaudiodir::Vector{AbstractString} = split(audiosrc, "/")
    audioname::String = splitaudiodir[length(splitaudiodir)]
    c["/audio/$audioname"] = (c::Connection) -> write!(c, File(audiosrc))
    newsection::Component{:section} = section(name)
    markd::Component{:div} = tmd("$name-md", md)
    aud = audio("$name-audio", src = "audio/$audioname")
    style!(markd, "display" => "inline-block")
    style!(aud, "display" => "inline-block")
    push!(newsection, markd, aud)
    newsection::Component{:section}
end
"""
home(c::Connection) -> _
--------------------
The home function is served as a route inside of your server by default. To
    change this, view the start method below.
"""
function home(c::Connection)
    #==
    Styles
    ==#
    styles::Component{:sheet} = stylesheet("kevinsvoice", scheme)
    styles[:children]["section"]["background-color"] = scheme.background
    write!(c, styles)
    #==
    Body
    ==#
    bod = body("main")
    style!(bod, "background-color" => "#080508")
    #==
    Header
    ==#
    header_div = div("header", align = "center")
    get_voiceb = button("getvoiceb", text = "get my voice!")
    push!(header_div, h("mainheading", 1, text = "Kevin's voice"), get_voiceb)
    #==
    Request voice
    ==#
    reqv_div = div("requestv", open = false)
    style!(reqv_div, "z-index" => "2", "text-align" => "center",
    "position" => "fixed", "top" => -20percent, "height" => 20percent,
     "transition" => ".5s", "margin-left" => 40percent, "width" => 20percent)
    on(c, get_voiceb, "click") do cm::ComponentModifier
        style!(cm, reqv_div, "top" => 50percent)
    end
    push!(reqv_div, tmd"""## $20/10 minutes
    fill the form below in order to request a vocal reading, and I will get back
    to you within 5 business days!""")
    #==
    Audios
    ==#
    audios = div("audio sections")
    audios[:children] = [p(text = "no audio currently available.")]
    if length(audiosections) != 0
        audios[:children] = audiosections
    end
    #==
    compose and write!
    ==#
    push!(bod, header_div, reqv_div, audios)
    write!(c, bod)
end

fourofour = route("404") do c
    write!(c, p("404message", text = "404, not found!"))
end

routes = [route("/", home), fourofour]
extensions = [Logger(), Files(), Session()]
"""
start(IP::String, PORT::Integer, ) -> ::ToolipsServer
--------------------
The start function starts the WebServer.
"""
function start(IP::String = "127.0.0.1", PORT::Integer = 8000)
     ws = WebServer(IP, PORT, routes = routes, extensions = extensions)
     ws.start()
     ws
end
end # - module
