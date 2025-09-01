local HttpService = game:GetService("HttpService")

SIXE = {
  NAME = "SIXE",
  VERSION = "1.2.152",
  BUILD_DATE = DateTime.fromUnixTimestamp(tonumber("1756720191")),
  PLACES = HttpService:JSONDecode('{"126884695634066":"Grow A Garden"}')
}

SIXE.UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/rzbz/sixe/refs/heads/main/uilib.lua"))()
SIXE.TITLE = `{SIXE.NAME} v{SIXE.VERSION}`
SIXE.TITLE_FULL = `{SIXE.TITLE} - {SIXE.BUILD_DATE:FormatLocalTime("LLL", "en-us")}`

print(SIXE.TITLE_FULL)

local placeId = game.PlaceId
local placeName = nil -- SIXE.PLACES[tostring(placeId)]

if not placeName then
  SIXE.UI:GlobalNotification("SIXE", "This place is not supported.", "Okay")
  print("This place is not supported")
end


--[[
SIXE v1.0.0
UI Lib v1.0.0
GrowAGarden v1.0.0

inc version every publish and if there is new changes (use hashes for comparing)
]]