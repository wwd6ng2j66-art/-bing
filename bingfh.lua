--// ============================================
--         冰缝合脚本 V2.2 - 完整整合版
--   主页 + 进出提示 + 关于 + Aero + 其他脚本
-- ============================================

--// ===== 1. 加载 Rayfield UI 库 =====
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success or not Rayfield then
    Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua', true))()
end

if not Rayfield then
    warn("Rayfield UI 库加载失败，请检查网络或更换执行器。")
    return
end

--// ===== 2. 创建 Rayfield 窗口 =====
local Window = Rayfield:CreateWindow({
    Name = "冰缝合脚本",
    LoadingTitle = "冰缝合脚本",
    LoadingSubtitle = "正在加载...",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

--// ===== 3. 创建所有标签页（顺序很重要！）=====
local TabHome    = Window:CreateTab("主页")
local TabNotify  = Window:CreateTab("进出提示")
local TabAbout   = Window:CreateTab("关于脚本")
local TabAero    = Window:CreateTab("Aero")
local TabOther   = Window:CreateTab("其他脚本") -- ✅ 必须在这里创建，不能漏

--// ===== 4. 主页 =====
TabHome:CreateSection("作者信息")
TabHome:CreateLabel("作者：榆")
TabHome:CreateParagraph({ Title = "关于作者", Content = "本脚本由 榆 开发，仅供学习交流使用。" })

--// ============================================
--   5. iOS 玻璃风格 - 玩家进出提示
-- ============================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local NotifyEnabled   = true
local MaxNotices      = 5
local NoticeDuration  = 3.0
local activeNotices   = {}

local COLORS = {
    JoinBG    = Color3.fromRGB(48, 209, 88),
    LeaveBG   = Color3.fromRGB(255, 59, 48),
    GlassTint = Color3.fromRGB(255, 255, 255),
    Text      = Color3.fromRGB(255, 255, 255),
    SubText   = Color3.fromRGB(230, 230, 230),
}

local NotifyGui = Instance.new("ScreenGui")
NotifyGui.Name = "iOSNotifyGui"
NotifyGui.ResetOnSpawn = false
NotifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
NotifyGui.Parent = PlayerGui

local RightContainer = Instance.new("Frame")
RightContainer.Name = "RightContainer"
RightContainer.Size = UDim2.new(0, 300, 1, -60)
RightContainer.Position = UDim2.new(1, -310, 0, 30)
RightContainer.BackgroundTransparency = 1
RightContainer.ClipsDescendants = true
RightContainer.Parent = NotifyGui

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 12)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Right
UIList.VerticalAlignment = Enum.VerticalAlignment.Top
UIList.Parent = RightContainer

local function createBlurBackground(parent, tintColor)
    local blurFrame = Instance.new("Frame")
    blurFrame.Size = UDim2.new(1, 0, 1, 0)
    blurFrame.BackgroundColor3 = tintColor
    blurFrame.BackgroundTransparency = 0.75
    blurFrame.BorderSizePixel = 0
    blurFrame.Parent = parent
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 16)
    c.Parent = blurFrame

    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1, 0, 0.5, 0)
    overlay.Position = UDim2.new(0, 0, 0, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    overlay.BackgroundTransparency = 0.88
    overlay.BorderSizePixel = 0
    overlay.Parent = parent
    local oc = Instance.new("UICorner")
    oc.CornerRadius = UDim.new(0, 16)
    oc.Parent = overlay

    local shadow = Instance.new("Frame")
    shadow.Size = UDim2.new(1, 6, 1, 6)
    shadow.Position = UDim2.new(0, -3, 0, -3)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.92
    shadow.BorderSizePixel = 0
    shadow.ZIndex = -1
    shadow.Parent = parent
    local sc = Instance.new("UICorner")
    sc.CornerRadius = UDim.new(0, 18)
    sc.Parent = shadow

    return blurFrame
end

local function createNotice(plrName, isJoin)
    if not NotifyEnabled then return end
    if #activeNotices >= MaxNotices then
        local oldest = table.remove(activeNotices, 1)
        if oldest and oldest.Parent then oldest:Destroy() end
    end

    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, 280, 0, 56)
    card.BackgroundTransparency = 1
    card.BorderSizePixel = 0
    card.ClipsDescendants = true
    card.LayoutOrder = tick()
    card.Parent = RightContainer
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 16)
    cardCorner.Parent = card

    local tintColor = isJoin and Color3.fromRGB(48, 209, 88) or Color3.fromRGB(255, 59, 48)
    createBlurBackground(card, tintColor)

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 3, 0.6, 0)
    indicator.Position = UDim2.new(0, 14, 0.2, 0)
    indicator.BackgroundColor3 = COLORS.GlassTint
    indicator.BackgroundTransparency = 0.2
    indicator.BorderSizePixel = 0
    indicator.Parent = card
    local indCorner = Instance.new("UICorner")
    indCorner.CornerRadius = UDim.new(1, 0)
    indCorner.Parent = indicator

    local textX = 28
    local textW = 280 - textX - 16

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, textW, 0, 22)
    title.Position = UDim2.new(0, textX, 0, 8)
    title.BackgroundTransparency = 1
    title.Text = isJoin and "玩家加入" or "玩家离开"
    title.TextColor3 = COLORS.Text
    title.TextSize = 15
    title.Font = Enum.Font.GothamSemibold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextTransparency = 1
    title.Parent = card

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0, textW, 0, 18)
    nameLabel.Position = UDim2.new(0, textX, 0, 30)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = plrName
    nameLabel.TextColor3 = COLORS.SubText
    nameLabel.TextSize = 13
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextTransparency = 1
    nameLabel.Parent = card

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 8, 0, 8)
    dot.Position = UDim2.new(1, -18, 0, 14)
    dot.BackgroundColor3 = COLORS.GlassTint
    dot.BackgroundTransparency = 0.3
    dot.BorderSizePixel = 0
    dot.Parent = card
    local dotC = Instance.new("UICorner")
    dotC.CornerRadius = UDim.new(1, 0)
    dotC.Parent = dot

    card.Position = UDim2.new(0, 300, 0, 0)
    table.insert(activeNotices, card)

    local EASE_OUT  = Enum.EasingStyle.Quart
    local EASE_IN   = Enum.EasingStyle.Quart
    local EASE_SMOOTH = Enum.EasingStyle.Sine

    TweenService:Create(card, TweenInfo.new(0.45, EASE_OUT, Enum.EasingDirection.Out), { Position = UDim2.new(0, 0, 0, 0) }):Play()
    TweenService:Create(title, TweenInfo.new(0.35, EASE_SMOOTH), { TextTransparency = 0 }):Play()
    TweenService:Create(nameLabel, TweenInfo.new(0.35, EASE_SMOOTH), { TextTransparency = 0 }):Play()
    TweenService:Create(dot, TweenInfo.new(0.35, EASE_SMOOTH), { BackgroundTransparency = 0.3 }):Play()

    task.delay(NoticeDuration, function()
        TweenService:Create(card, TweenInfo.new(0.7, EASE_IN, Enum.EasingDirection.InOut), { Position = UDim2.new(0, -300, 0, 0) }):Play()
        TweenService:Create(title, TweenInfo.new(0.6, EASE_SMOOTH), { TextTransparency = 1 }):Play()
        TweenService:Create(nameLabel, TweenInfo.new(0.6, EASE_SMOOTH), { TextTransparency = 1 }):Play()
        TweenService:Create(dot, TweenInfo.new(0.5, EASE_SMOOTH), { BackgroundTransparency = 1 }):Play()

        for _, child in ipairs(card:GetChildren()) do
            if child:IsA("Frame") then
                TweenService:Create(child, TweenInfo.new(0.6, EASE_SMOOTH), { BackgroundTransparency = child.BackgroundTransparency + 0.25 }):Play()
            end
        end

        task.delay(0.8, function()
            if card and card.Parent then card:Destroy() end
            for i, v in ipairs(activeNotices) do
                if v == card then
                    table.remove(activeNotices, i)
                    break
                end
            end
        end)
    end)
end

Players.PlayerAdded:Connect(function(plr)
    if plr == player then return end
    createNotice(plr.Name, true)
end)

Players.PlayerRemoving:Connect(function(plr)
    if plr == player then return end
    createNotice(plr.Name, false)
end)

task.defer(function()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            createNotice(plr.Name, true)
        end
    end
end)

--// ===== 6. 进出提示设置页 =====
TabNotify:CreateSection("提示外观")
TabNotify:CreateToggle({
    Name = "启用玩家进出提示",
    CurrentValue = true,
    Callback = function(value)
        NotifyEnabled = value
        NotifyGui.Enabled = value
    end
})

TabNotify:CreateSlider({
    Name = "提示停留时间（秒）",
    Range = {1, 8},
    Increment = 0.5,
    CurrentValue = 3.0,
    Callback = function(value)
        NoticeDuration = value
    end
})

TabNotify:CreateSlider({
    Name = "最大同时显示条数",
    Range = {1, 10},
    Increment = 1,
    CurrentValue = 5,
    Callback = function(value)
        MaxNotices = math.floor(value)
    end
})

TabNotify:CreateSection("测试")
TabNotify:CreateButton({ Name = "测试 - 玩家加入", Callback = function() createNotice("TestPlayer_Join", true) end })
TabNotify:CreateButton({ Name = "测试 - 玩家离开", Callback = function() createNotice("TestPlayer_Leave", false) end })

--// ===== 7. 关于脚本 =====
TabAbout:CreateSection("脚本信息")
TabAbout:CreateParagraph({ Title = "冰缝合脚本 V2.2", Content = "纯净版：UI 框架 + iOS 玻璃风格玩家进出提示 + Aero 脚本加载 + 其他脚本。" })
TabAbout:CreateLabel("开发者：榆 QQ3347313900")
TabAbout:CreateLabel("版本：V2.2")
TabAbout:CreateLabel("风格：iOS Glassmorphism")
TabAbout:CreateSection("系统")
TabAbout:CreateButton({ Name = "关闭 UI", Callback = function() Rayfield:Destroy() end })
TabAbout:CreateToggle({ Name = "开关五", CurrentValue = false, Callback = function() end })

--// ============================================
--   8. 通用脚本加载函数
--// ============================================
local function loadExternalScript(name, url)
    Rayfield:Notify({ Title = "加载中", Content = "正在加载 " .. name .. "...", Duration = 2 })
    task.spawn(function()
        local ok, srcOrErr = pcall(function()
            return game:HttpGet(url, true)
        end)
        if not ok then
            Rayfield:Notify({ Title = "加载失败", Content = name .. " 下载失败：" .. tostring(srcOrErr), Duration = 5 })
            return
        end
        local success, err = pcall(function()
            loadstring(srcOrErr)()
        end)
        if success then
            Rayfield:Notify({ Title = "加载成功", Content = name .. " 已加载", Duration = 3 })
        else
            Rayfield:Notify({ Title = "加载失败", Content = name .. " 执行错误：" .. tostring(err), Duration = 5 })
        end
    end)
end

--// ============================================
--   9. Aero 脚本加载区
--// ============================================
local SCRIPT_URLS = {
    SpeedRunner = "https://raw.githubusercontent.com/wwd6ng2j66-art/-/main/%E8%B6%85%E9%AB%98%E9%80%9F%E8%B7%91%E8%80%85.lua",
    Night99     = "https://raw.githubusercontent.com/wwd6ng2j66-art/-/38aa514a561dd344e3b75c60e21197e484fc31aa/99%20%E5%A4%9C.lua",
}

TabAero:CreateSection("Aero 脚本库")

TabAero:CreateButton({
    Name = "▶ 加载 超高速跑者",
    Callback = function()
        loadExternalScript("超高速跑者", SCRIPT_URLS.SpeedRunner)
    end
})

TabAero:CreateButton({
    Name = "▶ 加载 99夜脚本",
    Callback = function()
        loadExternalScript("99夜", SCRIPT_URLS.Night99)
    end
})

TabAero:CreateSection("说明")
TabAero:CreateParagraph({
    Title = "使用说明",
    Content = "点击按钮后才会加载对应脚本，不会自动运行。两个脚本链接均已验证可正常访问。"
})

--// ============================================
--   10. 其他脚本加载区
--// ============================================
local OTHER_URLS = {
    Escanor = "https://raw.githubusercontent.com/wwd6ng2j66-art/-/main/Escanor%E6%BA%90.lua",
    Snow    = "https://raw.githubusercontent.com/wwd6ng2j66-art/-/main/Snow%E5%85%A8%E6%BA%90lyy%E7%89%9B%E9%80%BC.lua",
    Ju      = "https://raw.githubusercontent.com/wwd6ng2j66-art/-/main/%E6%81%90%E8%84%9A%E6%9C%AC%E5%85%A8%E6%BA%90%E6%9C%80%E6%96%B09%E6%9C%8827.lua",
}

TabOther:CreateSection("其他脚本库")

TabOther:CreateButton({
    Name = "▶ 加载 Escanor源",
    Callback = function()
        loadExternalScript("Escanor源", OTHER_URLS.Escanor)
    end
})

TabOther:CreateButton({
    Name = "▶ 加载 Snow全源",
    Callback = function()
        loadExternalScript("Snow全源", OTHER_URLS.Snow)
    end
})

TabOther:CreateButton({
    Name = "▶ 加载 惧脚本全源",
    Callback = function()
        loadExternalScript("惧脚本全源", OTHER_URLS.Ju)
    end
})

TabOther:CreateSection("说明")
TabOther:CreateParagraph({
    Title = "使用说明",
    Content = "点击按钮后才会加载对应脚本，不会自动运行。三个脚本链接均已验证可正常访问。"
})
