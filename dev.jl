using Pkg; Pkg.activate(".")
using Toolips
using ToolipsSession
using Revise
using KevinsVoice

IP = "127.0.0.1"
PORT = 8000
KevinsVoiceServer = KevinsVoice.start(IP, PORT)
