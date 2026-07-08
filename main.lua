repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer and workspace:FindFirstChild("__Extra") and workspace:FindFirstChild("__Main")

local CoreGui = game:GetService("CoreGui")
for _, gui in ipairs(CoreGui:GetChildren()) do
    if gui.Name == "Rayfield" or gui.Name == "FPSPingDisplay" or gui.Name == "ImageButtonGUI" then
        gui:Destroy()
    end
end

-- Bypass anti-teleport trước khi load UI
local replicated = game:GetService("ReplicatedStorage")
local success, extraFunctionsModule = pcall(function()
    return require(replicated:WaitForChild("SharedModules"):WaitForChild("ExtraFunctions"))
end)

if success and extraFunctionsModule then
    local extraFunctions = extraFunctionsModule

    if not getgenv()._original_GetPlayerSpeed then
        getgenv()._original_GetPlayerSpeed = extraFunctions.GetPlayerSpeed

        extraFunctions.GetPlayerSpeed = function(player)
            return 9999999
        end
    end
end

-- Load Rayfield
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Pịa Hub - Vãi Pịa 💩",
    LoadingTitle = "Đang tải GUI...",
    LoadingSubtitle = "Vãi Pịa",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "PiaHubConfig",
        FileName = "Settings"
    },
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = false
    },
    KeySystem = false,
    KeySettings = {
        Title = "Pịa Hub",
        Subtitle = "Không cần nhập key",
        Note = "Free for all!",
        FileName = "PiaHubKey",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = "piahub123"
    }
})

local HttpService = game:GetService("HttpService")
local settingsFile = "piahubv2.json"
local settings = {}

-- Đọc file config
pcall(function()
    if isfile(settingsFile) then
        settings = HttpService:JSONDecode(readfile(settingsFile))
    end
end)

-- Thiết lập mặc định nếu thiếu
local defaultSettings = {
    AutoFarm = false,
    FarmScales = {"Normal", "Big"},
    FarmDelay = 0.2,
    AutoDestroy = false,
    AriseModels = {"Jinwoo", "Pucci", "Freeza"},
    OnlyCastleParts = false,
    AutoCastleCustom = false,
    AutoOutCastleFloor = 0,
    AutoBypassDungeon = false,
    AutoCheckDD = false,
    AutoClick = false,
    AutoAttack = false,
    AutoLoadScript = false,
    BypassCooldown = false,
    SpecialScript = false,
    AutoHideUI = false,
    AutoSendPetFast = false,
    SelectedCheckpoint = "25",
    AutoAddRune = false,
    SelectedRuneName = "Black Clover",
    AutoLeaveDungeonEnd = false,
    OnlyDungeon = false,
    AutoBypassDungeonBlockTime = false,
    AutoFarmRaid = false,
    AutoTPLowServer = false,
}

for key, value in pairs(defaultSettings) do
    if settings[key] == nil then
        settings[key] = value
    end
end

-- Hàm lưu settings
local function saveSettings()
    writefile(settingsFile, HttpService:JSONEncode(settings))
end

-- Tabs
local MainTab = Window:CreateTab("Main", 124598949660449)
local DungeonTab = Window:CreateTab("Dungeon", 106229124186030)
local RaidTab = Window:CreateTab("Raid", 124598949660450)
local MiscTab = Window:CreateTab("Misc", 95758233681936)
local ShopTab = Window:CreateTab("Shop", 126309628188296)
local TeleportTab = Window:CreateTab("Teleport", 136059427982959)


MiscTab:CreateToggle({
    Name = "Auto Hide UI",
    CurrentValue = settings["AutoHideUI"],
    Flag = "AutoHideUI",
    Callback = function(val)
        settings["AutoHideUI"] = val
        saveSettings()
    end
})

-- Tự động ẩn UI sau khi load GUI
task.delay(0.2, function()
    if settings["AutoHideUI"] then
        local vu = game:GetService("VirtualInputManager")
        vu:SendKeyEvent(true, Enum.KeyCode.K, false, game)
        vu:SendKeyEvent(false, Enum.KeyCode.K, false, game)
    end
end)

MainTab:CreateToggle({
    Name = "Auto Send Pet Fast (new)",
    CurrentValue = settings["AutoSendPetFast"],
    Flag = "AutoSendPetFast",
    Callback = function(val)
        settings["AutoSendPetFast"] = val
        saveSettings()
    end
})

task.spawn(function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local PetsController = require(ReplicatedStorage:WaitForChild("SharedModules"):WaitForChild("Pets"):WaitForChild("PetsController"))

    repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character.PrimaryPart

    -- Hàm tìm quái gần nhất còn sống
    local function getNearestEnemy()
        local myPos = LocalPlayer.Character.PrimaryPart.Position
        local nearest, minDist = nil, math.huge

        for _, clientEnemy in ipairs(workspace.__Main.__Enemies.Client:GetChildren()) do
            local serverEnemy = workspace.__Main.__Enemies.Server:FindFirstChild(clientEnemy.Name, true)
            if serverEnemy and not serverEnemy:GetAttribute("Dead") and (serverEnemy:GetAttribute("HP") or 1) > 0 then
                local dist = (clientEnemy.PrimaryPart.Position - myPos).Magnitude
                if dist < minDist then
                    nearest = clientEnemy
                    minDist = dist
                end
            end
        end

        return nearest
    end

    while true do
        if settings["AutoSendPetFast"] then
            local target = getNearestEnemy()
            if target then
                pcall(function()
                    PetsController.AutoEnemy(target)
                end)
            end
        end
        task.wait(0.1)
    end
end)

MainTab:CreateLabel("Auto Farm all mode")

--  Toggle Auto Farm
MainTab:CreateToggle({
    Name = " Auto Farm",
    CurrentValue = settings["AutoFarm"],
    Flag = "AutoFarm",
    Callback = function(val)
        settings["AutoFarm"] = val
        saveSettings()
    end
})

MainTab:CreateToggle({
    Name = "Only Dungeon/Castle",
    CurrentValue = settings["OnlyDungeon"],
    Flag = "OnlyDungeon",
    Callback = function(val)
        settings["OnlyDungeon"] = val
        saveSettings()
    end
})

MainTab:CreateDropdown({
    Name = "select mob",
    Options = {"All", "Normal", "Big", "big priority"},
    MultiSelection = true,
    CurrentOption = settings["FarmScales"],
    Flag = "FarmScales",
    Callback = function(val)
        settings["FarmScales"] = val
        saveSettings()
    end
})

--  Textbox delay sau khi tiêu diệt
local delayInput = MainTab:CreateInput({
    Name = " Delay tp",
    PlaceholderText = "0.2",
    RemoveTextAfterFocusLost = false,
    Default = tostring(settings["FarmDelay"]),
    Callback = function(val)
        local num = tonumber(val)
        if num and num > 0 then
            settings["FarmDelay"] = num
            saveSettings()
        else
            warn("Delay không hợp lệ:", val)
        end
    end
})

-- Gán lại giá trị rõ ràng sau khi UI tạo xong
task.delay(0.1, function()
    delayInput:Set(tostring(settings["FarmDelay"]))
end)

-- Auto Farm logic
task.spawn(function()
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")

    local enemiesRoot = workspace:WaitForChild("__Main"):WaitForChild("__Enemies")
    local enemiesServer = enemiesRoot:WaitForChild("Server")
    local enemiesClient = enemiesRoot:WaitForChild("Client")

    local scaleMap = {
        ["Normal"] = 1,
        ["Big"] = 2
    }

    local noclipConnection

    local function enableNoClip()
        if noclipConnection then return end
        noclipConnection = game:GetService("RunService").Stepped:Connect(function()
            if settings["AutoFarm"] and character and humanoid then
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end

    local function disableNoClip()
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end

        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end

    local function isScaleAllowed(scale)
        local selected = settings["FarmScales"] or {}
        if table.find(selected, "All") then return true end
        if table.find(selected, "big priority") then return scale >= 1 end
        local rounded = math.floor((scale or 0) + 0.01)
        for _, name in ipairs(selected) do
            if scaleMap[name] == rounded then return true end
        end
        return false
    end

    local function findNearestMob()
        local nearestNormal, nearestBoss
        local minNormalDist, minBossDist = math.huge, math.huge
        local selected = settings["FarmScales"] or {}

        local function check(part)
            local hp = part:GetAttribute("HP")
            local scale = part:GetAttribute("Scale")
            if not hp or hp <= 0 or not scale then return end
            if not isScaleAllowed(scale) then return end

            local uuid = part.Name
            local model = enemiesClient:FindFirstChild(uuid, true)
            local pos = (model and model:FindFirstChild("HumanoidRootPart")) and model.HumanoidRootPart.Position or part.Position
            local dist = (pos - rootPart.Position).Magnitude

            if scale >= 2 and table.find(selected, "big priority") then
                if dist < minBossDist then
                    minBossDist = dist
                    nearestBoss = {model = model, part = part}
                end
            elseif dist < minNormalDist then
                minNormalDist = dist
                nearestNormal = {model = model, part = part}
            end
        end

        for _, child in ipairs(enemiesServer:GetDescendants()) do
            if child:IsA("Part") then
                check(child)
            end
        end

        return (nearestBoss or nearestNormal or {}).model, (nearestBoss or nearestNormal or {}).part
    end

    local function teleportNearMob(pos)
    if typeof(pos) ~= "Vector3" then return end
    local dir = rootPart.Position - pos
    if dir.Magnitude == 0 then return end

    local success, direction = pcall(function() return dir.Unit end)
    if not success then return end

    local offset = direction * 2 + Vector3.new(0, 1, 0)
    local finalCFrame = CFrame.new(pos + offset, pos)

    local originalGravity = workspace.Gravity
    workspace.Gravity = 0

    rootPart.Velocity = Vector3.zero
    humanoid.AutoRotate = false
    humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    rootPart.CFrame = finalCFrame

    task.delay(0.1, function()
        workspace.Gravity = originalGravity
        humanoid.AutoRotate = true
        humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
    end)
end

    local function handleMob(model, part)
        if not part then return end

        local function getTargetPosition()
            if model and model:FindFirstChild("HumanoidRootPart") then
                return model.HumanoidRootPart.Position
            elseif part:IsA("Part") then
                return part.Position
            end
            return nil
        end

        if settings["AutoFarm"] and part:IsDescendantOf(workspace) and part:GetAttribute("Dead") ~= true then
    local targetPos = getTargetPosition()
    if targetPos and (targetPos - rootPart.Position).Magnitude > 7 then
        teleportNearMob(targetPos)
    end

    -- Đợi quái chết
    repeat
        task.wait(0.2)
    until part:GetAttribute("Dead") == true
end

        task.wait(settings["FarmDelay"] or 0.1)
    end

    -- Main loop
    local LOBBY_PLACE_ID = 87039211657390

    while true do
        local isInLobby = game.PlaceId == LOBBY_PLACE_ID
        local onlyDungeon = settings["OnlyDungeon"]

        if settings["AutoFarm"] and (not onlyDungeon or not isInLobby) then
            enableNoClip()
            local model, part = findNearestMob()
            if part then
                handleMob(model, part)
            else
                task.wait(0.1)
            end
        else
            disableNoClip()
            task.wait(0.1)
        end
    end
end)

-- ⚙ Cài đặt mặc định
local autoDestroy = settings["AutoDestroy"]
local selectedModels = settings["AriseModels"]

--  Danh sách tất cả model có thể chọn
local allModels = {"JinWoo", "Okarun", "Metus", "Statue", "Esil", "Baran", "Vulcan", "Kamish"}  -- bạn có thể thêm tùy ý

-- 🗡 Toggle: Auto Destroy
MainTab:CreateToggle({
    Name = "Auto Destroy",
    CurrentValue = autoDestroy,
    Flag = "AutoDestroy",
    Callback = function(val)
        autoDestroy = val
        settings["AutoDestroy"] = val
        saveSettings()
    end
})

MainTab:CreateDropdown({
	Name = "select mob arise",
	Options = {"JinWoo", "Okarun", "Metus", "Statue", "Esil", "Baran", "Vulcan", "Kamish"},
	CurrentOption = settings["AriseModels"] or {},
	MultipleOptions = true, -- Bật multi-select
	Flag = "AriseModels",
	Callback = function(optionList)
		settings["AriseModels"] = optionList
		saveSettings()
	end
})

--  Xử lý Auto Destroy/Arise
task.spawn(function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Workspace = game:GetService("Workspace")
    local Players = game:GetService("Players")

    local player = Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")

    local enemiesRoot = Workspace:WaitForChild("__Main"):WaitForChild("__Enemies")
    local enemiesServer = enemiesRoot:WaitForChild("Server")
    local enemiesClient = enemiesRoot:WaitForChild("Client")

    local remote = ReplicatedStorage:WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent")

    -- Hàm tìm mob gần nhất, kết hợp Server và Client để lấy UUID chính xác
    local function getNearestMob()
        local nearestPart, nearestModel, minDist = nil, nil, math.huge

        local function check(uuidPart)
            local uuid = uuidPart.Name
            local hp = uuidPart:GetAttribute("HP")
            local scale = uuidPart:GetAttribute("Scale")

            if not hp or hp > 0 then return end -- chỉ xử lý mob đã chết

            local model = enemiesClient:FindFirstChild(uuid, true)
            if model and model:IsA("Model") and model:FindFirstChild("HumanoidRootPart") then
                local dist = (model.HumanoidRootPart.Position - hrp.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    nearestPart = uuidPart
                    nearestModel = model
                end
            end
        end

        -- Duyệt hết từ Server
        for _, child in pairs(enemiesServer:GetChildren()) do
            if child:IsA("Folder") then
                for _, uuidPart in pairs(child:GetChildren()) do
                    if uuidPart:IsA("Part") then
                        check(uuidPart)
                    end
                end
            elseif child:IsA("Part") then
                check(child)
            end
        end

        return nearestPart, nearestModel
    end

    -- Xử lý Arise hoặc Destroy
    local function handleMob()
    local mobPart, mobModel = getNearestMob()
    if not mobPart or not mobModel then return end

    local uuid = mobPart.Name
    local modelName = mobPart:GetAttribute("Model")

    local eventType = "EnemyDestroy"
    if table.find(settings["AriseModels"] or {}, modelName) then
        eventType = "EnemyCapture"
    end

    for _ = 1, 4 do
        local args = {
	    {
		{
			Event = eventType,
			Enemy = uuid
		},
		"\005"
	    }
        }
        remote:FireServer(unpack(args))
        task.wait(0.1)
    end
end

    while true do
        if autoDestroy then
            pcall(handleMob)
        end
        task.wait(0.1)
    end
end)

DungeonTab:CreateLabel("Auto farm Dungeon")

DungeonTab:CreateToggle({
    Name = "Out dungeon xx:45m",
    CurrentValue = settings["AutoBypassDungeonBlockTime"],
    Flag = "AutoBypassDungeonBlockTime",
    Callback = function(val)
        settings["AutoBypassDungeonBlockTime"] = val
        saveSettings()
    end
})

task.spawn(function()
    local TeleportService = game:GetService("TeleportService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    while true do
        if settings["AutoBypassDungeonBlockTime"] and game.PlaceId ~= 87039211657390 then
            local curTime = os.date("*t")

            if curTime.min >= 45 and curTime.min <= 58 then
                local isInCastle = false

                pcall(function()
                    local label = LocalPlayer.PlayerGui.Hud.UpContanier:FindFirstChild("Room")
                    if label and typeof(label.Text) == "string" then
                        -- Nếu match Floor: xx/xx thì đang ở Castle
                        isInCastle = label.Text:match("Floor:%s*%d+/%d+") ~= nil
                    end
                end)

                if not isInCastle then
                    TeleportService:Teleport(87039211657390)
                    task.wait(60) -- tránh spam
                end
            end
        end
        task.wait(10)
    end
end)

-- 🛡Auto Bypass Dungeon Toggle 
DungeonTab:CreateToggle({
    Name = "Auto Bypass Dungeon",
    CurrentValue = settings["AutoBypassDungeon"],
    Flag = "AutoBypassDungeon",
    Callback = function(val)
        settings["AutoBypassDungeon"] = val
        saveSettings()
    end
})

-- uto Check DD Toggle (ở dưới)
DungeonTab:CreateToggle({
    Name = "Auto Check DD (fix)",
    CurrentValue = settings["AutoCheckDD"],
    Flag = "AutoCheckDD",
    Callback = function(val)
        settings["AutoCheckDD"] = val
        saveSettings()
    end
})

--  Hàm tạo Dungeon
local function createAndStartDungeon()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Players = game:GetService("Players")
    local bridge = ReplicatedStorage:WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent")

    -- 🔢 Lấy ID người chơi hiện tại
    local idPlayer = Players.LocalPlayer.UserId

    -- Mua vé
    local args1 = {
        [1] = {
            [1] = {
                ["Type"] = "Gems",
                ["Event"] = "DungeonAction",
                ["Action"] = "BuyTicket"
            },
            [2] = "\v"
        }
    }
    bridge:FireServer(unpack(args1))
    task.wait(0.5)

    -- Tạo dungeon
    local args2 = {
        [1] = {
            [1] = {
                ["Event"] = "DungeonAction",
                ["Action"] = "Create"
            },
            [2] = "\v"
        }
    }
    bridge:FireServer(unpack(args2))

    task.wait(0.5)
    -- ⚡️ Auto Add Rune nếu bật
if settings["AutoAddRune"] then
    local runeDisplayNames = {
        ["DgOPMRune"] = "OPM Rune",
        ["DgDanRune"] = "Dandadan Rune",
        ["DgSoloRune"] = "Solo Rune",
        ["DgSoloRune2"] = "Hunter Rune",
        ["DgDoubleDungeonRune"] = "dd rune",
        ["DgURankUpRune"] = "Ultimate Rank UP",
        ["DgRankDownRune"] = "Rank Down Rune",
        ["DgHealthRune"] = "Heal Rune",
        ["DgRankUpRune"] = "Rank Up Rune",
        ["DgRoomRune"] = "- Room Rune",
        ["DgTimeRune"] = "Time Rune",
        ["DgMoreRoomRune"] = "More Room Rune"
    }

    for slot = 1, 5 do
        local selectedName = settings["SelectedRuneSlot" .. slot]
        if selectedName and selectedName ~= "None" then
            for id, name in pairs(runeDisplayNames) do
                if name == selectedName then
                    local addArgs = {
                        [1] = {
                            [1] = {
                                ["Dungeon"] = idPlayer,
                                ["Action"] = "AddItems",
                                ["Slot"] = slot,
                                ["Event"] = "DungeonAction",
                                ["Item"] = id
                            },
                            [2] = "\v"
                        }
                    }
                    bridge:FireServer(unpack(addArgs))
                    task.wait(0.1) -- ✅ Thêm delay giữa các AddItems để đảm bảo server nhận đầy đủ
                    break
                end
            end
        end
    end
end

    -- ⏳ Bắt đầu dungeon sau 0.5s
    task.wait(3)

    local args3 = {
        [1] = {
            [1] = {
                ["Dungeon"] = idPlayer,
                ["Event"] = "DungeonAction",
                ["Action"] = "Start"
            },
            [2] = "\v"
        }
    }
    bridge:FireServer(unpack(args3))

    -- 🛑 Rời dungeon cũ sau khi bắt đầu dungeon mới (spam 3 lần)
    task.spawn(function()
        task.wait(0.2)
        local leaveArgs = {
            [1] = {
                [1] = {
                    ["Dungeon"] = idPlayer,
                    ["Event"] = "DungeonAction",
                    ["Action"] = "Leave"
                },
                [2] = "\v"
            }
        }
        for i = 1, 3 do
            bridge:FireServer(unpack(leaveArgs))
            task.wait(0.3)
        end
    end)
end

--  Luồng xử lý Auto Dungeon (cho cả hai toggle)
task.spawn(function()
    local lastText = ""
    local waitFor12s = false
    local isDoubleDungeonCheck = false
    local hasCheckedDoubleDD = false

    while true do
        if not settings["AutoBypassDungeon"] and not settings["AutoCheckDD"] then
            task.wait(1)
        else
            if game.PlaceId == 87039211657390 then
                if settings["AutoBypassDungeon"] then
                    task.wait(1)
                    createAndStartDungeon()
                end
            else
                local player = game.Players.LocalPlayer
                local infoGui = player:WaitForChild("PlayerGui"):WaitForChild("Hud"):FindFirstChild("UpContanier")
                local dungeonInfo = infoGui and infoGui:FindFirstChild("DungeonInfo")

                if dungeonInfo then
                    local textLabel = dungeonInfo:FindFirstChild("TextLabel")
                    local currentText = textLabel and textLabel.Text or ""

                    -- 📌 Khi thấy Dungeon Ends in 20s → bắt đầu kiểm tra double dungeon
                    if currentText == "Dungeon Ends in 20s" then
                        isDoubleDungeonCheck = true
                        waitFor12s = false
                        hasCheckedDoubleDD = false
                    end

                    -- 🧠 Auto Check Double Dungeon
                    if settings["AutoCheckDD"] and isDoubleDungeonCheck and not hasCheckedDoubleDD then
                        if currentText == "Dungeon Ends in 13s" then
                            waitFor12s = true
                        elseif waitFor12s and currentText == "Dungeon Ends in 12s" then
                            createAndStartDungeon()
                            waitFor12s = false
                            isDoubleDungeonCheck = false
                            hasCheckedDoubleDD = true
                        elseif currentText ~= "Dungeon Ends in 13s" and currentText ~= "Dungeon Ends in 12s" then
                            waitFor12s = false
                        end
                    end

                    -- 🛡️ Auto Bypass Dungeon
                    if settings["AutoBypassDungeon"] then
                        -- ⏳ Kiểm tra giờ thực
                        local curTime = os.date("*t")
                        local isInBlockTime = (curTime.min >= 45 and curTime.min <= 58)
                        local allowBypass = true

                        if settings["AutoLeaveDungeonByTime"] and isInBlockTime then
                            allowBypass = false
                        end

                        if allowBypass then
                            local isEndTimer = currentText:match("^Dungeon Ends in %d+s$")
                            local isNewText = currentText ~= lastText

                            if isEndTimer and isNewText then
                                if hasCheckedDoubleDD then
                                    createAndStartDungeon()
                                    hasCheckedDoubleDD = false
                                elseif not settings["AutoCheckDD"] then
                                    createAndStartDungeon()
                                end
                            end
                        end
                    end

                    lastText = currentText
                end
            end

            task.wait(0.3)
        end
    end
end)

local runeDisplayNames = {
    ["DgOPMRune"] = "OPM Rune",
    ["DgDanRune"] = "Dandadan Rune",
    ["DgSoloRune"] = "Solo Rune",
    ["DgSoloRune2"] = "Hunter Rune",
    ["DgDoubleDungeonRune"] = "dd rune",
    ["DgURankUpRune"] = "Ultimate Rank UP",
    ["DgRankDownRune"] = "Rank Down Rune",
    ["DgHealthRune"] = "Heal Rune",
    ["DgRankUpRune"] = "Rank Up Rune",
    ["DgRoomRune"] = "- Room Rune",
    ["DgTimeRune"] = "Time Rune",
    ["DgMoreRoomRune"] = "More Room Rune"
}

local runeDropdownOptions = {"None"}
for id, display in pairs(runeDisplayNames) do
    table.insert(runeDropdownOptions, display)
end

-- 🔘 Toggle: Auto Add Rune
DungeonTab:CreateToggle({
    Name = "Auto Add Rune",
    CurrentValue = settings["AutoAddRune"],
    Flag = "AutoAddRune",
    Callback = function(val)
        settings["AutoAddRune"] = val
        saveSettings()
    end
})

-- 🔽 5 Dropdown chọn rune cho 5 slot
for slot = 1, 5 do
    DungeonTab:CreateDropdown({
        Name = "Slot " .. slot .. " Rune",
        Options = runeDropdownOptions,
        CurrentOption = {settings["SelectedRuneSlot" .. slot] or runeDropdownOptions[1]},
        Flag = "SelectedRuneSlot" .. slot,
        MultipleOptions = false,
        Callback = function(opt)
            local displayName = typeof(opt) == "table" and opt[1] or opt
            settings["SelectedRuneSlot" .. slot] = displayName
            saveSettings()
        end
    })
end

--  Textbox: Nhập số tầng hoặc thông tin tùy ý
DungeonTab:CreateLabel("Auto castle")

-- 🔧 Biến toàn cục (không lặp lại)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local lobbyPlaceId = 87039211657390

-- 🔘 Toggle: Auto Castle Join
local castleJoinToggle = DungeonTab:CreateToggle({
    Name = "Auto Castle Join",
    CurrentValue = settings["AutoCastleCustom"],
    Flag = "AutoCastleCustom",
    Callback = function(val)
        settings["AutoCastleCustom"] = val
        if val then
            Rayfield.Flags["AutoCastleCheckpoint"]:Set(false)
        end
        saveSettings()

        if val then
            task.spawn(function()
                while settings["AutoCastleCustom"] do
                    local minute = os.date("*t").min
                    if minute >= 45 and minute <= 58 then
                        -- only args updated as requested:
                        local args = {
                            {
                                {
                                    Check = false,
                                    Event = "CastleAction",
                                    Action = "Join"
                                },
                                "\011"
                            }
                        }
                        pcall(function()
                            ReplicatedStorage.BridgeNet2.dataRemoteEvent:FireServer(unpack(args))
                        end)
                    end
                    task.wait(3)
                end
            end)
        end
    end
})

-- ✅ Tự động bật lại Auto Castle Join nếu đang lưu là true
task.delay(0.5, function()
    if settings["AutoCastleCustom"] then
        local toggle = Rayfield.Flags["AutoCastleCustom"]
        if toggle then
            toggle:Set(false)
            task.wait(0.05)
            toggle:Set(true)
        end
    end
end)

-- 🔘 Toggle: Auto Castle Checkpoint
local castleCheckpointToggle = DungeonTab:CreateToggle({
    Name = "Auto Castle Checkpoint",
    CurrentValue = settings["AutoCastleCheckpoint"],
    Flag = "AutoCastleCheckpoint",
    Callback = function(val)
        settings["AutoCastleCheckpoint"] = val
        if val then
            Rayfield.Flags["AutoCastleCustom"]:Set(false)
        end
        saveSettings()

        if val then
            task.spawn(function()
                while settings["AutoCastleCheckpoint"] do
                    local minute = os.date("*t").min
                    if minute >= 45 and minute <= 58 then
                        local args = {
                            {
                                {
                                    Check = true,
                                    Event = "CastleAction",
                                    Action = "Join"
                                },
                                "\011"
                            }
                        }
                        pcall(function()
                            ReplicatedStorage.BridgeNet2.dataRemoteEvent:FireServer(unpack(args))
                        end)
                    end
                    task.wait(3)
                end
            end)
        end
    end
})

-- ✅ Tự động bật lại toggle nếu đang lưu là true (sau khi GUI load xong)
task.delay(0.5, function()
    if settings["AutoCastleCheckpoint"] then
        local toggle = Rayfield.Flags["AutoCastleCheckpoint"]
        if toggle then
            toggle:Set(false)
            task.wait(0.05)
            toggle:Set(true)
        end
    end
end)


-- 🔽 Dropdown chọn tầng checkpoint
local teleportFloors = {"25", "50", "75", "100"}

DungeonTab:CreateDropdown({
    Name = "Teleport Floor",
    Options = teleportFloors,
    CurrentOption = {
        table.find(teleportFloors, settings["SelectedCheckpoint"]) and settings["SelectedCheckpoint"]
        or "25"
    },
    MultipleOptions = false,
    Flag = "SelectedCheckpoint",
    Callback = function(option)
        settings["SelectedCheckpoint"] = typeof(option) == "table" and option[1] or option
        saveSettings()
    end
})

-- 🌀 Teleport đến checkpoint trong Castle
task.spawn(function()
    local teleported = false
    local lastFloor = ""

    local checkpointPositions = {
        ["25"] = CFrame.new(-23996.8671875, 3161.200927734375, 55.12371826171875),
        ["100"] = CFrame.new(-24050, 3200, 100) -- Cập nhật đúng toạ độ nếu cần
    }

    while true do
        -- ✅ Chỉ hoạt động trong Castle
        if game.PlaceId == 128336380114944 and settings["AutoCastleCheckpoint"] then
            local selectedFloor = tostring(settings["SelectedCheckpoint"] or "25")
            local checkpointCFrame = checkpointPositions[selectedFloor]

            local roomLabel = LocalPlayer:FindFirstChild("PlayerGui")
                and LocalPlayer.PlayerGui:FindFirstChild("Hud")
                and LocalPlayer.PlayerGui.Hud:FindFirstChild("UpContanier")
                and LocalPlayer.PlayerGui.Hud.UpContanier:FindFirstChild("Room")

            if roomLabel then
                local currentFloor = tonumber(roomLabel.Text:match("Floor:%s*(%d+)/"))
                if currentFloor then
                    if selectedFloor ~= lastFloor then
                        teleported = false
                        lastFloor = selectedFloor
                    end

                    if tostring(currentFloor) == selectedFloor and checkpointCFrame and not teleported then
                        pcall(function()
                            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                            local hrp = char:WaitForChild("HumanoidRootPart", 5)
                            if hrp then
                                hrp.CFrame = checkpointCFrame + Vector3.new(0, 5, 0)
                                teleported = true
                            end
                        end)
                    end
                end
            end
        else
            teleported = false
        end
        task.wait(1)
    end
end)

-- 🔢 Input nhập tầng boss để tự động out nếu boss chết
local bossOutInput = DungeonTab:CreateInput({
    Name = "Boss die out (floor)", -- 🆕 tên mới
    PlaceholderText = "VD: 50",
    RemoveTextAfterFocusLost = false,
    Default = tostring(settings["AutoOutCastleFloor"]),
    Callback = function(val)
        local num = tonumber(val)
        if num and num >= 1 then
            settings["AutoOutCastleFloor"] = num
            saveSettings()
        else
            warn("❌ Sai giá trị tầng:", val)
        end
    end
})

-- Gán lại sau khi tạo UI
task.delay(0.2, function()
    bossOutInput:Set(tostring(settings["AutoOutCastleFloor"]))
end)

task.spawn(function()
    local Players = game:GetService("Players")
    local TeleportService = game:GetService("TeleportService")
    local LocalPlayer = Players.LocalPlayer

    local lobbyPlaceId = 87039211657390

    while true do
        if game.PlaceId == 128336380114944 and settings["AutoOutCastleFloor"] and tonumber(settings["AutoOutCastleFloor"]) then
            local castleFolder = workspace:FindFirstChild("__Main") and workspace.__Main:FindFirstChild("__Enemies")
            local curFloor = 0

            -- Lấy số tầng hiện tại từ TextLabel tên Room
            pcall(function()
                local label = LocalPlayer.PlayerGui.Hud.UpContanier:FindFirstChild("Room")
                if label and label:IsA("TextLabel") then
                    local match = label.Text:match("Floor:%s*(%d+)/")
                    if match then
                        curFloor = tonumber(match)
                    end
                end
            end)

            local targetFloor = tonumber(settings["AutoOutCastleFloor"])

            if castleFolder and curFloor == targetFloor then
                local closestBoss = nil
                local closestDist = math.huge

                -- Tìm boss gần nhất có Scale >= 3.5
                for _, uuid in ipairs(castleFolder:GetDescendants()) do
                    if uuid:IsA("Part") then
                        local scale = uuid:GetAttribute("Scale")
                        local isDead = uuid:GetAttribute("Dead")
                        if scale and scale >= 3.5 and not isDead then
                            local dist = (uuid.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                            if dist < closestDist then
                                closestBoss = uuid
                                closestDist = dist
                            end
                        end
                    end
                end

                if closestBoss then
                    -- Đợi boss chết
                    repeat
                        task.wait(0.3)
                    until closestBoss:GetAttribute("Dead") == true

                    -- Teleport sau khi boss chết
                    task.wait(2)
                    TeleportService:Teleport(lobbyPlaceId)
                end
            end
        end

        task.wait(1)
    end
end)

-- Toggle Auto Farm Raid
RaidTab:CreateToggle({
    Name = "Auto Farm Raid",
    CurrentValue = settings["AutoFarmRaid"] or false,
    Flag = "AutoFarmRaid",
    Callback = function(val)
        settings["AutoFarmRaid"] = val
        saveSettings()
    end
})

task.spawn(function()
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart")
    local enemiesServer = workspace.__Main.__Enemies.Server

    local raidCFrame = CFrame.new(4851, 30, -2093)

    -- Hàm tìm mob còn sống và đúng Model
    local function findFirstMob()
        for _, mobPart in pairs(enemiesServer:GetChildren()) do
            if mobPart:IsA("Part") and mobPart:GetAttribute("HP") and mobPart:GetAttribute("HP") > 0 then
                local modelName = mobPart:GetAttribute("Model")
                if modelName == "WElf2" or modelName == "WBoss" or modelName == "WBoss2" then
                    return mobPart
                end
            end
        end
        return nil
    end

    while true do
        if settings["AutoFarmRaid"] then
            -- Teleport về điểm Raid ban đầu nếu chưa đứng gần đó
            if (rootPart.Position - raidCFrame.Position).Magnitude > 10 then
                rootPart.CFrame = raidCFrame
            end

            local targetMob = findFirstMob()

            if targetMob then
                -- Teleport ngay lập tức đến mob khi xuất hiện
                repeat
                    if (rootPart.Position - targetMob.Position).Magnitude > 5 then
                        rootPart.CFrame = CFrame.new(targetMob.Position + Vector3.new(0, 5, 0))
                    end
                    task.wait(1.5)
                until targetMob:GetAttribute("HP") <= 0 or not settings["AutoFarmRaid"]
            else
                -- Đứng tại chỗ đợi UUID part load
                task.wait(0.2)
            end
        else
            task.wait(0.5)
        end
    end
end)

-- Toggle Auto TP LowServer
RaidTab:CreateToggle({
    Name = "Auto TP LowServer",
    CurrentValue = settings["AutoTPLowServer"] or false,
    Flag = "AutoTPLowServer",
    Callback = function(val)
        settings["AutoTPLowServer"] = val
        saveSettings()
    end
})

task.spawn(function()
    local Players = game:GetService("Players")
    local Player = Players.LocalPlayer
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    local enemiesServer = workspace.__Main.__Enemies.Server
    local placeId = game.PlaceId

    local modelList = {"WBoss", "WBoss2", "WElf2"}

    local function listServers()
        local Api = "https://games.roblox.com/v1/games/"
        local url = Api .. placeId .. "/servers/Public?sortOrder=Asc&limit=10"
        local raw = game:HttpGet(url)
        return HttpService:JSONDecode(raw)
    end

    local function teleportLowServer()
        local servers = listServers()
        if servers and servers.data and #servers.data > 0 then
            local targetServer = servers.data[1]
            TeleportService:TeleportToPlaceInstance(placeId, targetServer.id, Player)
        end
    end

    local function findMobByModels()
        for _, mob in ipairs(enemiesServer:GetChildren()) do
            if mob:IsA("Part") and mob:GetAttribute("HP") and mob:GetAttribute("HP") > 0 then
                local modelName = mob:GetAttribute("Model")
                if modelName and table.find(modelList, modelName) then
                    return mob, modelName
                end
            end
        end
        return nil, nil
    end

    local function getCurrentMinute()
        local t = os.date("*t")
        return t.min
    end

    local function isRaidWaitingTime()
        local min = getCurrentMinute()
        return (min >= 40 and min <= 41) or (min >= 10 and min <= 11)
    end

    local function isAfterRaidStart()
        local min = getCurrentMinute()
        return (min >= 42 and min <= 59) or (min >= 12 and min <= 39)
    end

    while true do
        if settings["AutoTPLowServer"] then
            local mob, modelName = findMobByModels()

            if isRaidWaitingTime() then
                -- Khung giờ 40-41 / 10-11 -> chờ WBoss2 xuất hiện
                if modelName == "WBoss2" then
                    -- Phát hiện WBoss2 → đợi chết
                    while mob and mob:GetAttribute("HP") > 0 and settings["AutoTPLowServer"] do
                        task.wait(1)
                        mob, modelName = findMobByModels()
                    end
                    task.wait(2)
                    teleportLowServer()
                else
                    -- Không có WBoss2 → không TP, chỉ đợi
                    task.wait(1)
                end

            elseif isAfterRaidStart() then
                -- Sau 42p hoặc 12p

                if modelName == "WBoss2" then
                    -- Nếu thấy WBoss2, đợi HP về 0
                    while mob and mob:GetAttribute("HP") > 0 and settings["AutoTPLowServer"] do
                        task.wait(1)
                        mob, modelName = findMobByModels()
                    end
                    task.wait(2)
                    teleportLowServer()

                elseif modelName == "WElf2" then
                    -- Nếu thấy WElf2 → đợi HP về 0 rồi TP
                    while mob and mob:GetAttribute("HP") > 0 and settings["AutoTPLowServer"] do
                        task.wait(1)
                        mob, modelName = findMobByModels()
                    end
                    task.wait(2)
                    teleportLowServer()

                elseif modelName == "WBoss" then
                    -- Nếu gặp WBoss → đợi 10s xem WBoss2 spawn hay không
                    local start = tick()
                    local foundWBoss2 = false

                    repeat
                        task.wait(0.5)
                        local mobCheck, modelCheck = findMobByModels()
                        if modelCheck == "WBoss2" then
                            foundWBoss2 = true
                            mob = mobCheck
                            break
                        end
                    until tick() - start > 10 or not settings["AutoTPLowServer"]

                    if foundWBoss2 then
                        -- WBoss2 spawn → đợi HP WBoss2 về 0
                        while mob and mob:GetAttribute("HP") > 0 and settings["AutoTPLowServer"] do
                            task.wait(1)
                            mob, modelName = findMobByModels()
                        end
                        task.wait(2)
                        teleportLowServer()
                    else
                        -- Không có WBoss2 sau 10s → TP
                        teleportLowServer()
                    end

                else
                    -- Không có mob đúng → TP ngay
                    teleportLowServer()
                end

            else
                -- Các thời điểm khác → TP liên tục nếu không thấy mob
                if not mob then
                    teleportLowServer()
                end
                task.wait(1)
            end
        else
            task.wait(1)
        end
    end
end)

local autoClicking = false

MiscTab:CreateToggle({
    Name = "AutoClick",	
    CurrentValue = settings["AutoClick"],
    Flag = "AutoClick",
    Callback = function(val)
        settings["AutoClick"] = val
        autoClicking = val
        saveSettings()
    end
})

-- Luồng xử lý AutoClick
task.spawn(function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Player = game:GetService("Players").LocalPlayer
    local SharedModules = ReplicatedStorage:WaitForChild("SharedModules")
    local WeaponsModule = require(SharedModules:WaitForChild("WeaponsModule"))

    repeat task.wait(1) until Player:GetAttribute("Loaded") == true

    while true do
        task.wait(0.3)
        if autoClicking then
            if Player.leaderstats:FindFirstChild("Passes") and Player.leaderstats.Passes:GetAttribute("AutoClicker") ~= true then
                task.wait(0.2)
            end

            if Player:GetAttribute("AutoClick") ~= true then
                Player:SetAttribute("AutoClick", true)
            end

            WeaponsModule.Click({
                ["KeyCode"] = Enum.KeyCode.ButtonX
            }, false, nil, true)
        end
    end
end)

local autoAttackEnabled = settings["AutoAttack"]

MiscTab:CreateToggle({
    Name = "Auto Attack",
    CurrentValue = autoAttackEnabled,
    Flag = "AutoAttack",
    Callback = function(val)
        autoAttackEnabled = val
        settings["AutoAttack"] = val
        saveSettings()
    end
})

task.spawn(function()
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	local rootPart = character:WaitForChild("HumanoidRootPart")
	local enemies = workspace:WaitForChild("__Main"):WaitForChild("__Enemies"):WaitForChild("Server")
	local dataRemoteEvent = game:GetService("ReplicatedStorage"):WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent")

	local attackRange = 10
	local lastAttackTime = 0
	local lastUUID = nil

	local function getClosestEnemy()
		local closest = nil
		local minDist = math.huge

		for _, part in pairs(enemies:GetDescendants()) do
			if part:IsA("Part") then
				local hp = part:GetAttribute("HP")
				if hp and hp > 0 then
					local dist = (part.Position - rootPart.Position).Magnitude
					if dist <= attackRange and dist < minDist then
						minDist = dist
						closest = part
					end
				end
			end
		end

		return closest
	end

	while true do
		if autoAttackEnabled then
			local target = getClosestEnemy()
			if target then
				local uuid = target.Name
				local now = tick()

				-- Nếu target mới → reset delay cho phép đánh ngay nếu đã đủ khoảng cách
				if uuid ~= lastUUID then
					lastUUID = uuid
					lastAttackTime = now - 0.1 -- cho phép đánh ngay
				end

				if (target.Position - rootPart.Position).Magnitude <= attackRange and (now - lastAttackTime) >= 0.1 then
					local args = {
						[1] = {
							[1] = {
								["Event"] = "PunchAttack",
								["Enemy"] = uuid
							},
							[2] = "\004"
						}
					}
					pcall(function()
						dataRemoteEvent:FireServer(unpack(args))
					end)
					lastAttackTime = now
				end
			else
				lastUUID = nil
			end
		end
		task.wait() -- quét liên tục
	end
end)

MiscTab:CreateToggle({
    Name = "Auto Load Script",
    CurrentValue = settings["AutoLoadScript"],
    Flag = "AutoLoadScript",
    Callback = function(val)
        settings["AutoLoadScript"] = val
        saveSettings()

        if val then
            queue_on_teleport([[
                loadstring(game:HttpGet('https://raw.githubusercontent.com/thaemmayanh/thaem/refs/heads/main/main'))()
            ]])
        end
    end
})

MiscTab:CreateToggle({
    Name = "No Cooldown",
    CurrentValue = settings["BypassCooldown"],
    Flag = "BypassCooldown",
    Callback = function(val)
        settings["BypassCooldown"] = val
        saveSettings()

        if val then
            task.spawn(function()
                local replicated = game:GetService("ReplicatedStorage")
                local success, module = pcall(function()
                    return require(replicated:WaitForChild("SharedModules"):WaitForChild("CooldownModule"))
                end)

                if success and module then
                    module.Verify = function(...) return true end
                    module.VerifyPower = function(...) return true end
                    module.VerifyNpc = function(...) return true end
                    module.VerifyPlayer = function(...) return true end
                    module.VerifyPowerPlayer = function(...) return true end
                end
            end)
        end
    end
})

MiscTab:CreateToggle({
    Name = "Giảm lag",
    CurrentValue = settings["SpecialScript"],
    Flag = "SpecialScript",
    Callback = function(val)
        settings["SpecialScript"] = val
        saveSettings()

        if val then
            task.spawn(function()
                pcall(function()
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/skyemngu13/hee/refs/heads/main/giamlag"))()
                end)
            end)
        end
    end
})

ShopTab:CreateLabel("Đổi DUST")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remote = ReplicatedStorage:WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent")

local exchangeOptions = {
    ["10 rare = 1 legend"] = "EnchLegendary",
    ["1 legend = 1 rare"] = "EnchRare2",
    ["10 common = 1 rare"] = "EnchRare"
}

local selectedExchange = "EnchLegendary"
local isExchanging = false

-- Dropdown ở ShopTab
ShopTab:CreateDropdown({
    Name = "Loại đổi Enchant (fix)",
    Options = {"10 rare = 1 legend", "1 legend = 1 rare", "10 common = 1 rare"},
    CurrentOption = "10 rare = 1 legend",
    Flag = "EnchantType",
    Callback = function(option)
        if typeof(option) == "table" then
            option = option[1]
        end
        selectedExchange = exchangeOptions[option]
    end
})

-- Toggle ở ShopTab
ShopTab:CreateToggle({
    Name = "Auto Exchange Enchant",
    CurrentValue = false,
    Flag = "AutoExchangeEnchant",
    Callback = function(val)
        isExchanging = val
        if val then
            -- Mở GUI
            local openGUIArgs = {
                [1] = {
                    [1] = {
                        ["Shop"] = "ExchangeShop",
                        ["Event"] = "OpenShop"
                    },
                    [2] = "\n"
                }
            }
            remote:FireServer(unpack(openGUIArgs))
        else
            -- Đóng GUI
            local closeGUIArgs = {
                [1] = {
                    [1] = {
                        ["Event"] = "CloseShop"
                    },
                    [2] = "\n"
                }
            }
            remote:FireServer(unpack(closeGUIArgs))
        end
    end
})

-- Vòng lặp thực hiện đổi
task.spawn(function()
    while true do
        if isExchanging and selectedExchange then
            local args = {
                [1] = {
                    [1] = {
                        ["Action"] = "Buy",
                        ["Shop"] = "ExchangeShop",
                        ["Item"] = selectedExchange,
                        ["Event"] = "ItemShopAction"
                    },
                    [2] = "\n"
                }
            }
            pcall(function()
                remote:FireServer(unpack(args))
            end)
        end
        task.wait(0.5)
    end
end)

local teleportData = {
    {Name = "Solo lvl", Position = CFrame.new(577.968262, 27.9623756, 261.452271)},
    {Name = "Naruto", Position = CFrame.new(-3380.2373, 29.8265285, 2257.26196)},
    {Name = "One piece", Position = CFrame.new(-2851.1062, 49.8987885, -2011.39526)},
    {Name = "Bleach", Position = CFrame.new(2641.79517, 45.9265289, -2645.07568)},
    {Name = "Black clover", Position = CFrame.new(198.338684, 39.2076797, 4296.10938)},
    {Name = "Chain sawn man", Position = CFrame.new(236.932678, 33.3960934, -4301.60547)},
    {Name = "JoJo", Position = CFrame.new(4816.31641, 30.4423409, -120.22998)},
    {Name = "DB", Position = CFrame.new(-6295.89209, 24.6981049, -73.7149353, 0, 0, 1, 0, 1, -0, -1, 0, 0)},
    {Name = "OPM", Position = CFrame.new(5994.5376, 171.666214, 4863.9458, 0.776914835, -0, -0.62960577, 0, 1, -0, 0.62960577, 0, 0.776914835)},
    {Name = "DanDaDan", Position = CFrame.new(-4374.35352, 19.4620514, 5588.17773, -0.923002124, 8.06914073e-08, 0.384794801, 1.21062612e-07, 1, 8.06914073e-08, -0.384794801, 1.21062612e-07, -0.923002124)},
    {Name = "GuildHall", Position = CFrame.new(289.015015, 31.8532162, 157.246201, 1, 0, 0, 0, 1, 0, 0, 0, 1)},
}

for _, data in ipairs(teleportData) do
    TeleportTab:CreateButton({
        Name = data.Name,
        Callback = function()
            local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Anchored = true
                hrp.CFrame = data.Position

                Rayfield:Notify({
                    Title = "Teleported!",
                    Content = "Đã dịch chuyển đến " .. data.Name,
                    Duration = 3,
                    Image = "rbxassetid://126309628188296"
                })

                task.delay(1, function()
                    if hrp then hrp.Anchored = false end
                end)
            end
        end
    })
end

local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

-- Xóa GUI cũ nếu đã tồn tại
local old = game:GetService("CoreGui"):FindFirstChild("FPSPingDisplay")
if old then
	old:Destroy()
end

-- Tạo GUI mới
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FPSPingDisplay"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999999
screenGui.Enabled = true

pcall(function()
	screenGui.Parent = game:GetService("CoreGui")
end)

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 240, 0, 100)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundTransparency = 1
mainFrame.Parent = screenGui

-- Tạo dòng text
local function createRow(y)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 30)
	row.Position = UDim2.new(0, 0, 0, y)
	row.BackgroundTransparency = 1
	row.Parent = mainFrame

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 4)
	layout.Parent = row

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0, 50, 1, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.SourceSansBold
	label.TextSize = 24
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextStrokeTransparency = 0.5
	label.Parent = row

	local value = label:Clone()
	value.Size = UDim2.new(1, -50, 1, 0)
	value.Parent = row

	return label, value
end

local fpsLabel, fpsValue = createRow(0)
local pingLabel, pingValue = createRow(30)
local timeLabel, timeValue = createRow(60)

fpsLabel.Text = "FPS:"
pingLabel.Text = "Ping:"
timeLabel.Text = "Time:"

-- Hiệu ứng rainbow
local function rainbow(offset)
	local t = tick()
	local r = 0.5 + 0.5 * math.sin(t * 3 + offset)
	local g = 0.5 + 0.5 * math.sin(t * 3 + offset + 2)
	local b = 0.5 + 0.5 * math.sin(t * 3 + offset + 4)
	return Color3.new(r, g, b)
end

-- Luồng riêng để update UI
task.spawn(function()
	local fps, count, last = 0, 0, tick()

	RunService.RenderStepped:Connect(function()
		if not screenGui.Enabled then return end

		count = count + 1
		local now = tick()

		if now - last >= 1 then
			fps = count
			count = 0
			last = now

			local pingStat = Stats:FindFirstChild("Network") and Stats.Network:FindFirstChild("ServerStatsItem")
			local ping = pingStat and pingStat["Data Ping"]:GetValue() or 0
			pingValue.Text = math.floor(ping + 0.5) .. " ms"
			fpsValue.Text = tostring(fps)
		end

		local t = os.date("*t")
		timeValue.Text = string.format("%02d:%02d:%02d", t.hour, t.min, t.sec)

		-- Rainbow màu
		fpsLabel.TextColor3 = rainbow(0)
		fpsValue.TextColor3 = rainbow(1)
		pingLabel.TextColor3 = rainbow(2)
		pingValue.TextColor3 = rainbow(3)
		timeLabel.TextColor3 = rainbow(4)
		timeValue.TextColor3 = rainbow(5)
	end)
end)

task.spawn(function()
    task.wait(1) -- Đảm bảo UI đã vẽ xong

    -- Bật lại các toggle đã lưu trạng thái trong settings
task.spawn(function()
    task.wait(1) -- Đợi UI vẽ xong

    local function reTrigger(flag)
        local toggle = Rayfield.Flags[flag]
        if toggle and settings[flag] then
            toggle:Set(false)
            task.wait(0.05)
            toggle:Set(true)
        end
    end

    -- Các flag toggle cần khởi động lại
    local allFlags = {
        "AutoClick",
        "AutoAttack",
        "AutoLoadScript",
        "SpecialScript",
        "BypassCooldown",
        "AutoCastleCustom",
        "AutoCheckDD",
        "AutoCastleBossOut",
        "AutoCastleBossFloor",
    }

    for _, flag in ipairs(allFlags) do
        reTrigger(flag)
    end
end)

    -- Nếu bật BypassCooldown thì patch lại module (vì không thể rely hoàn toàn vào toggle)
    if settings["BypassCooldown"] then
        task.spawn(function()
            local replicated = game:GetService("ReplicatedStorage")
            local success, module = pcall(function()
                return require(replicated:WaitForChild("SharedModules"):WaitForChild("CooldownModule"))
            end)
            if success and module then
                module.Verify = function(...) return true end
                module.VerifyPower = function(...) return true end
                module.VerifyNpc = function(...) return true end
                module.VerifyPlayer = function(...) return true end
                module.VerifyPowerPlayer = function(...) return true end
            end
        end)
    end
end)

local UIS = game:GetService("UserInputService")

-- Tạo ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "ImageButtonGUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
pcall(function()
	gui.Parent = game:GetService("CoreGui")
end)

-- Tạo ImageButton
local btn = Instance.new("ImageButton")
btn.Name = "KButton"
btn.Size = UDim2.new(0, 40, 0, 40)
btn.Position = UDim2.new(1, -40, 0.30, -25) -- 🔼 Dịch lên cao hơn
btn.BackgroundTransparency = 1
btn.Image = "rbxassetid://126309628188296"
btn.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = btn

-- Khi click, giả lập phím K
btn.MouseButton1Click:Connect(function()
	local vu = game:GetService("VirtualInputManager")
	vu:SendKeyEvent(true, Enum.KeyCode.K, false, game)
	vu:SendKeyEvent(false, Enum.KeyCode.K, false, game)
end)

-- Anti-AFK Script (Auto Execute Version)
local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    vu:CaptureController()
    vu:ClickButton2(Vector2.new(0, 0))
end)
