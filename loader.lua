(function()
  _G.SIXE_NAME = "SIXE"
  _G.SIXE_VERSION = "1.2.107"
  _G.SIXE_BUILD_TIME = tonumber("1756545066")
  _G.SIXE_GAME_NAME = "GrowAGarden"

  local UI_LIB_URL = "https://raw.githubusercontent.com/rzbz/sixe/refs/heads/main/uilib.lua"
  
  if _G.SIXE_LOADING then
    return print(_G.SIXE_NAME.." is loading!")
  end

  _G.SIXE_LOADING = true

  local title = `{_G.SIXE_NAME} <{_G.SIXE_GAME_NAME}> v{_G.SIXE_VERSION}`

  local buildDate = DateTime.fromUnixTimestamp(_G.SIXE_BUILD_TIME)
  local titleWithBuildDate = `{title} - {buildDate:FormatLocalTime("LLL", "en-us")}`

  if _G.SIXE_WINDOW then
    if _G.SIXE_LAST_VERSION == _G.SIXE_VERSION then
      return print(`{title} is already running!`)
    else
      print(`New {title} is available! Updating...`)
      _G.SIXE_WINDOW:Destroy()
      print(titleWithBuildDate.." (Updated)")
    end
  else
    print(titleWithBuildDate)
  end

  -- load from config file
  local config = {
    ["servers"] = {
      {
        ["name"] = "Global Config",
        ["image"] = "rbxassetid://123478452300557",
        ["is_running"] = true,
        ["data"] = {
          ["shop"] = {
            ["gears"] = {"Grandmaster Sprinkler"},
            ["seeds"] = {"Beanstalk"},
            ["eggs"] = {"Bug Egg"}
          }
        }
      },
      {
        ["name"] = "1",
        ["image"] = nil,
        ["data"] = {}
      },
      {
        ["name"] = "2",
        ["image"] = nil,
        ["data"] = {}
      },
      {
        ["name"] = "3",
        ["image"] = nil,
        ["data"] = {}
      },
      {
        ["name"] = "4",
        ["image"] = nil,
        ["data"] = {}
      },
      {
        ["name"] = "5",
        ["image"] = nil,
        ["data"] = {}
      },
      {
        ["name"] = "Loong assss name aahh1234567890",
        ["image"] = nil,
        ["data"] = {}
      },
    }
  }

  print("Fetching UI Lib...")
  local UILib = loadstring(game:HttpGet(UI_LIB_URL))()
  print("UI Lib loaded!")

  local window = UILib:Window(titleWithBuildDate);

  -- show menu by double clicking roblox icon or double esc key
  (function()
    local robloxMenuBtn = game.CoreGui.TopBarApp.TopBarApp.MenuIconHolder.TriggerPoint.Background :: ImageButton
    local DOUBLE_CLICK_TIME = 0.3
    local lastClickTime = 0
    local pendingClick = false
    robloxMenuBtn.MouseButton1Click:Connect(function()
      local currentTime = tick()
      local timeSinceLastClick = currentTime - lastClickTime
      if timeSinceLastClick <= DOUBLE_CLICK_TIME and pendingClick then
        -- Double click detected!
        pendingClick = false -- Cancel pending single click
        window:toggleWindow()
      else
        -- Potential single click
        pendingClick = true
        lastClickTime = currentTime
        -- Use spawn to handle single click delay without blocking
        task.spawn(function()
          task.wait(DOUBLE_CLICK_TIME)
          if pendingClick and tick() - lastClickTime >= DOUBLE_CLICK_TIME then
            -- Single click
            pendingClick = false
          end
        end)
      end
    end)
    -- TODO: add `esc` keybind to toggle menu
  end)()

  local function setupServer(server, serverName, data)
    print(`Server loaded: {serverName}`, data)
    local shopChannel = server:Channel("Main")
    shopChannel:Button("Kill all", function()
      UILib:Notification("Notification", "Killed everyone!", "Okay!")
    end)
    shopChannel:Seperator()
    shopChannel:Button("Get max level", function()
      UILib:Notification("Notification", "Max level!", "Okay!")
    end)

    local category1 = server:Category("Category 1")
    local category1channel1 = category1:Channel("Channel 1")
    local category1channel2 = category1:Channel("Channel 2")
    category1:CategoryEnd()

    local autoFarmChannel = server:Channel("Auto farm")
    autoFarmChannel:Toggle("Auto-Farm",false, function(bool)
      print(bool)
    end)

    local walkSpeedChannel = server:Channel("Walk speed")

    local slider = walkSpeedChannel:Slider("Slide me!", 0, 1000, 400, function(t)
      print(t)
    end)
    walkSpeedChannel:Button("Change to 50", function()
      slider:Change(50)
    end)

    if data.shop then
      local fruitNamesChannel = server:Channel("Shop")
      fruitNamesChannel:Dropdown("Seeds",data.shop.seeds, function(bool)
        print(bool)
      end)
      fruitNamesChannel:Dropdown("Gears",data.shop.gears, function(bool)
        print(bool)
      end)
      fruitNamesChannel:Dropdown("Eggs",data.shop.eggs, function(bool)
        print(bool)
      end)
    end

    local targetFruitChannel = server:Channel("Target fruit")
    targetFruitChannel:Textbox("Gun power", "Type here!", true, function(t)
      print(t)
    end)

    local targetFruitChannel2 = server:Channel("Target fruit 2")
    targetFruitChannel2:Textbox("Gun power", "Type here!", true, function(t)
      print(t)
    end)

    local targetFruitChannel3 = server:Channel("Target fruit 3")
    targetFruitChannel3:Textbox("Gun power", "Type here!", true, function(t)
      print(t)
    end)

    local targetFruitChannel4 = server:Channel("Target fruit 4")
    targetFruitChannel4:Textbox("Gun power", "Type here!", true, function(t)
      print(t)
    end)

    local targetFruitChannel5 = server:Channel("Target fruit 5")
    targetFruitChannel5:Textbox("Gun power", "Type here!", true, function(t)
      print(t)
    end)

    local targetFruitChannel6 = server:Channel("Target fruit 6")
    targetFruitChannel6:Textbox("Gun power", "Type here!", true, function(t)
      print(t)
    end)
  end

  for _, _server in ipairs(config.servers) do
    -- lazy loading server if user interacted with it
    local server = nil
    local loaded = false
    local function loadServer()
      if loaded then return end
      setupServer(server, _server.name, _server.data)
      loaded = true
    end
    server = window:Server(_server.name, _server.image, _server.is_running, loadServer)
    if _server.is_running then
      loadServer()
    end
  end

  _G.SIXE_WINDOW = window
  _G.SIXE_LAST_VERSION = _G.SIXE_VERSION
  _G.SIXE_LOADING = false
end)()