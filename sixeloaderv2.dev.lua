-- # [[ SERVICES / IMPORTS ]] # --

local Sixe = {
  env = "dev",
  name = "Sixe",
  version = "2.2.24",
  build_time = 1758097646,
}

local function loadRbxAssetByUrl(url: string, require: boolean?)
  local instance = game:GetObjects(url)[1]
  return require and require(instance) or instance
end

local Crypto = loadRbxAssetByUrl("rbxassetid://105499508340385", true) :: {}
local TableUtil = loadRbxAssetByUrl("rbxassetid://97310775178011", true) :: {}
local LoaderGui = loadRbxAssetByUrl("rbxassetid://114615535808385") :: ScreenGui

local aesIv = buffer.fromstring("a12cf4e8440b43a7")

local supportedPlaces = {
  ['126884695634066'] = 'Grow A Garden',
  ['123455678901234'] = 'Test Place',
}
local executors = {
  delta = 'delta',
  krnl = 'krnl',
  ronix = 'ronix',
  arceus = 'arceus',
  fluxus = 'fluxus',
}
local adPlatforms = {
  {
    id = 1,
    name = 'Linkvertise',
    hours = 12,
    disabled = false,
  },
  {
    id = 2,
    name = 'Work.Ink',
    hours = 24,
    disabled = false,
  },
  {
    id = 3,
    name = 'LootLabs',
    hours = 36,
    disabled = false,
  },
}
local placesVersions = {
  {
    name = 'Loader',
    version = '2.2.23',
  },
  {
    name = 'UILib',
    version = '1.0.0',
  },
  {
    name = 'GrowAGarden',
    version = '1.0.10',
  },
}

local aes = Crypto.Encryption.AES.New(buffer.fromstring("MzpJSUFwQTpJOXBB"), Crypto.Encryption.AES.Modes.CBC, Crypto.Encryption.AES.Pads.Pkcs7);
local aesEncrypt = function(data: string | table)
  if type(data) == "table" then data = TableUtil.EncodeJSON(data) end
  return buffer.tostring(Crypto.Utilities.Base64.Encode(aes:Encrypt(data, nil, aesIv)))
end
local aesDecrypt = function(data: string)
  return buffer.tostring(aes:Decrypt(Crypto.Utilities.Base64.Decode(buffer.fromstring(data)), nil, aesIv))
end

Sixe.build_date = DateTime.fromUnixTimestamp(Sixe.build_time):FormatLocalTime("LLL", "en-us")
Sixe.title = Sixe.name .. " v" .. Sixe.version
Sixe.place_title = "GrowAGarden v1.0.0"
Sixe.title_full = Sixe.title .. " - " .. Sixe.build_date

Sixe.user = {
  key = nil :: {}?,
  config = nil :: {}?
}

Sixe.paths = {
  base = Sixe.name,
  key = Sixe.paths.base .. "/key"
}

local supabaseReq = function(method: string, url: string, data: {}?, headers: {}?, compress: boolean?)
  local opts = {
    Url = "https://vtjqztqtdvtghwsfczdv.supabase.co/functions/v1" .. url,
    Method = method,
    Headers = {
      ["Authorization"] = "Bearer " .. "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ0anF6dHF0ZHZ0Z2h3c2ZjemR2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY4NzU0MzAsImV4cCI6MjA3MjQ1MTQzMH0.ASOGLHa30yLZ7hf0n4LXcG-o0lU_uClsPd8z2mIEWhg",
      ["Place-Id"] = game.PlaceId,
    }
  }
  if compress then
    opts.Compress = Enum.HttpCompression.Gzip
  end
  if data then
    opts.Body = TableUtil.EncodeJSON(data)
    opts.Headers["Content-Type"] = Enum.HttpContentType.ApplicationJson
  end
  for k, v in pairs(headers or {}) do
    opts.Headers[k] = v
  end
  return request(opts)
end

local supabase = {
  checkKey = function(key)
    return supabaseReq("POST", `/check-key?key={key}`)
  end,
  generateKey = function()
    return supabaseReq("POST", "/generate-key")
  end,
  whitelistKey = function(key)
    return supabaseReq("POST", `/whitelist-key?key={key}`)
  end
}

local key = {
  decrypt = function(encData: string)
    local data = TableUtil.DecodeJSON(aesDecrypt(encData))
    Sixe.user.key = data
    return data
  end,
  isExpired = function()
    local data = Sixe.user.key
    return DateTime.now().UnixTimestamp - data.whitelisted_at >= (data.validity_hours * 60 * 60)
  end,
  isWeekend = function()
    local t = os.date("*t")
    return t.wday == 1 or t.wday == 7
  end,
  isKeyless = function()
    local a = false
    local b = 1760025600
    local c = true
    if a then return true end
    if c and Sixe.key.isWeekend() then return true end
    if b and DateTime.now().UnixTimestamp >= b then return true end
    return false
  end,
  isValid = function()
    local a = Sixe.key.isKeyless()
    local b = Sixe.key.isExpired()
    return a or not b
  end
}

local saveLocalKey = function(encData: string)
  writefile(Sixe.paths.key, encData)
end

local getLocalKey = function()
  if not isfile(Sixe.paths.key) then return nil end
  local encData = readfile(Sixe.paths.key)
  return key.decrypt(encData)
end

local fetchKey = function()
  local keyData = Sixe.user.key or getLocalKey()
  local encData = supabase.checkKey(keyData.key)
  saveLocalKey(encData)
  return key.decrypt(encData)
end

-- # [[ FUNCTIONS ]] # --

local rootFrame = LoaderGui.Notification :: Frame

local unsupportedPlaceFrame = rootFrame.UnsupportedPlace
local supportedPlaceListFrame = rootFrame.SupportedPlaceList
local errorMessageFrame = rootFrame.ErrorMessage
local mainFrame = rootFrame.Main

local discordBtn = rootFrame.DiscordBtn
local loginBtn = rootFrame.LoginBtn
local exitBtn = rootFrame.ExitBtn
local copyInfoBtn = rootFrame.CopyInfoBtn
local togglePlaceListBtn = rootFrame.TogglePlaceListBtn

local textBoxContainer = mainFrame.Textbox
local textBox = textBoxContainer.TextboxFrame.TextBox
local textBoxPasteBtn = textBoxContainer.TextboxFrame.PasteBtn

local placeId = game.PlaceId
local placeName = game.Name
local placeVersion = game.PlaceVersion
local placeNameNoSpaces = string.gsub(placeName, " ", "")
local isUnsupportedPlace = not Sixe.config.supported_places[tostring(placeId)]
local executorName = string.lower((getexecutorname or identifyexecutor)())

local prevActiveFrame = nil
local currActiveFrame = nil

local icons = {
  list = "rbxassetid://6031079156",
  clear = "rbxassetid://6035047409",
  paste = "rbxassetid://6035053285",
  location = "rbxassetid://6035190846"
}

local toggledButtons = {
  loginBtn,
  exitBtn,
  copyInfoBtn,
}

local toggledContents = {
  {
    frame = mainFrame,
    buttons = {loginBtn, exitBtn},
    onLoad = function()
      textBoxPasteBtn.Visible = not not getclipboard
      for _, item in ipairs(Sixe.config.ad_platforms) do
        local frame = mainFrame:FindFirstChild(item.id) :: Frame
        if not frame then continue end
        if item.disabled then
          frame.Visible = false
          continue
        end
        frame.Visible = true
        local btn = frame.TextButton :: TextButton
        local lbl = frame.TextLabel :: TextLabel
        btn.Text = item.name
        lbl.Text = `Validity: {item.hours} hrs`
        btn.MouseButton1Click:Connect(function() 
          log(item.name.." btn clicked")
        end)
      end
    end,
  },
  {
    frame = errorMessageFrame,
    buttons = {copyInfoBtn, exitBtn},
    onLoad = function()
      local placeId = game.PlaceId
      local placeName = game.Name
      local placeVersion = game.PlaceVersion
      local errCode = "100"
      local errMsg = "Crypto lib not found"
      local sixeFullTitle = "Sixe v1.2.2 | GrowAGarden v1.0.35"

      errorMessageFrame.Title.Text = "Something went wrong!"
      errorMessageFrame.PlaceDetails.Value.Text = `{placeId}|{placeName}|{placeVersion}`
      errorMessageFrame.Code.Value.Text = errCode
      errorMessageFrame.Message.Value.Text = errMsg
      errorMessageFrame.Visible = true
      copyInfoBtn.Visible = true

      copyInfoBtn.MouseButton1Click:Connect(function() 
        local copyInfoText = `!reporterror Place={errorMessageFrame.PlaceDetails.Value.Text}&Sixe={sixeFullTitle}&Code={errCode}&Msg={errMsg}`
        log("copy info btn clicked, sample copy:", copyInfoText)
      end)
    end,
  },
  {
    frame = unsupportedPlaceFrame,
    buttons = {copyInfoBtn, exitBtn},
    onLoad = function()
      local copyInfoText = `!suggestplace {placeId}`

      unsupportedPlaceFrame.PlaceName.Value.Text = placeName
      unsupportedPlaceFrame.PlaceId.Value.Text = placeId
      unsupportedPlaceFrame.Visible = true
      copyInfoBtn.Visible = true

      copyInfoBtn.MouseButton1Click:Connect(function() 
        log("copy info btn clicked, sample copy:", copyInfoText)
      end)
    end,
  },
  {
    frame = supportedPlaceListFrame,
    buttons = {exitBtn},
    onLoad = function()
      local template = supportedPlaceListFrame.ScrollingFrame.Template
      for id, name in pairs(Sixe.config.supported_places) do
        local item = template:Clone()
        item.Name = "Item"
        item.PlaceId.Text = id
        item.PlaceName.Text = name
        item.Visible = true
        item.Parent = supportedPlaceListFrame.ScrollingFrame
        item.TeleportBtn.Icon.Image = icons.location
        item.TeleportBtn.MouseButton1Click:Connect(function()
          log("teleport btn clicked", id, name)
        end)
      end
    end,
  },
}

errorMessageFrame.PlaceDetails.Value.Text = `{placeId}|{placeNameNoSpaces}|{placeVersion}`
unsupportedPlaceFrame.PlaceId.Value.Text = placeId
unsupportedPlaceFrame.PlaceName.Value.Text = placeName

local function log(...: any) print("[sixe]", ...) end

local function exit(gui: ScreenGui?) (gui or LoaderGui):Destroy(); script:Destroy() end

local function changeContentFrame(frame: Frame)
  for _, btn in ipairs(toggledButtons) do
    btn.Visible = false
  end
  for _, item in ipairs(toggledContents) do
    if item.frame == frame then
      if not item.loaded then item.onLoad() end
      item.loaded = true
      item.frame.Visible = true
      for _, btn in ipairs(item.buttons) do
        btn.Visible = true
      end
    else
      item.frame.Visible = false
    end
  end
  prevActiveFrame = currActiveFrame
  currActiveFrame = frame
end

local function sixeCall(name: string, func: () -> any): (boolean, any)
  return xpcall(func, function(err)
    if LoaderGui then
      log(`Something went wrong! ({name})`, err)
    else
      errorMessageFrame.Code.Text = name
      errorMessageFrame.Message.Text = err
      changeContentFrame(errorMessageFrame)
    end
  end)
end

local function login(key: string)
  log("login key", key)
end

-- # [[ MAIN ]] # --

log(Sixe.title_full)

sixeCall("init config folder", function()
  if not isfolder(Sixe.paths.base) then
    makefolder(Sixe.paths.base)
  end
  for id, name in pairs(Sixe.config.supported_places) do
    local path = Sixe.paths.base .. "/" .. name
    local configPath = path .. "/config.json"
    if not isfolder(name) then
      makefolder(name)
    end
    if not isfile(configPath) then
      writefile(configPath, "{}")
    end
  end
end)

sixeCall("check key", function()
  if not Sixe.key.getLocal() then
    Sixe.key.fetch() 
  end
  if Sixe.key.isValid() then
    -- TODO: load game source, then destroy this loader
    log("valid key, loading game...")
    exit()
  end
end)

rootFrame.Title.Text = Sixe.title .. " | " .. Sixe.place_title
exitBtn.Text = "Exit"
loginBtn.Text = "Login"
discordBtn.Text = "DISCORD"
copyInfoBtn.Text = "Copy Info"
textBox.PlaceholderText = "Your key here"
mainFrame.Notice.Text = "Keyless every weekends!"
supportedPlaceListFrame.Title.Text = "Supported Places:"
unsupportedPlaceFrame.Title.Text = "Unsupported Place!"
unsupportedPlaceFrame.Desc.Text = "Better suggest this on our discord."
unsupportedPlaceFrame.PlaceName.Text = "Name:"
unsupportedPlaceFrame.PlaceId.Text = "ID:"
errorMessageFrame.Title.Text = "Something went wrong!"
errorMessageFrame.Desc.Text = "Better report this on our discord."
errorMessageFrame.PlaceDetails.Text = "Place:"
errorMessageFrame.Message.Text = "Msg:"
errorMessageFrame.Code.Text = "Code:"
togglePlaceListBtn.Icon.Image = icons.list
textBoxPasteBtn.Icon.Image = icons.paste

LoaderGui.Parent = gethui and gethui() or game.CoreGui
LoaderGui.Enabled = true

exitBtn.MouseButton1Click:Connect(exit)

loginBtn.MouseButton1Click:Connect(function() login(textBox.Text) end)

discordBtn.MouseButton1Click:Connect(function() setclipboard(Sixe.config.discord_invite_url) end)

textBoxPasteBtn.MouseButton1Click:Connect(function() textBox.Text = getclipboard and getclipboard() or "" end)

togglePlaceListBtn.MouseButton1Click:Connect(function() 
  if supportedPlaceListFrame.Visible then
    togglePlaceListBtn.Icon.Image = icons.list
    supportedPlaceListFrame:TweenSize(
      UDim2.new(1, 0, 0, 0),
      Enum.EasingDirection.Out,
      Enum.EasingStyle.Quart,
      .2,
      true
    )
    task.wait(.1)
    supportedPlaceListFrame.Visible = false
    changeContentFrame(prevActiveFrame)
  else
    togglePlaceListBtn.Icon.Image = icons.clear
    supportedPlaceListFrame.Visible = true
    supportedPlaceListFrame:TweenSize(
      UDim2.new(1, 0, 0.612, 0),
      Enum.EasingDirection.Out,
      Enum.EasingStyle.Quart,
      .2,
      true
    )
    changeContentFrame(supportedPlaceListFrame)
  end
end)

if isUnsupportedPlace then
  changeContentFrame(unsupportedPlaceFrame)
else
  changeContentFrame(mainFrame)
end
