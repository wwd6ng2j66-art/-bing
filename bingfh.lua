--// ============================================
--         冰缝合脚本 V4.0 - Aero 模块化版
--   包含：Rayfield UI + iOS 玻璃玩家进出提示
--        + Aero 动态加载系统（17 款游戏）
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

local TabHome    = Window:CreateTab("主页")
local TabGame    = Window:CreateTab("游戏脚本")
local TabAero    = Window:CreateTab("Aero")       -- Aero 标签页
local TabNotify  = Window:CreateTab("进出提示")
local TabAbout   = Window:CreateTab("关于脚本")

--// ===== 3. 主页 =====
TabHome:CreateSection("作者信息")
TabHome:CreateLabel("作者：榆")
TabHome:CreateParagraph({ Title = "关于作者", Content = "本脚本由 榆 开发，仅供学习交流使用。" })

--// ===== 4. 游戏脚本（原有功能已清空，可自由添加）=====
TabGame:CreateSection("游戏脚本")
TabGame:CreateLabel("在此添加你的游戏脚本按钮")

--// ===== 5. Aero 模块化加载系统 =====
TabAero:CreateSection("🎮 Aero 游戏列表")

local AeroScripts = {
    {"训练怪兽进行破坏", "https://raw.githubusercontent.com/Yisan886/Aero/refs/heads/main/训练怪兽进行破坏.lua"},
    {"血债", "https://raw.githubusercontent.com/Yisan886/Aero/refs/heads/main/血债.lua"},
    {"po大po", "https://raw.githubusercontent.com/Yisan886/Aero/refs/heads/main/po大po.lua"},
    {"Dungeon Hunters", "https://raw.githubusercontent.com/Yisan886/Aero/refs/heads/main/Dungeon Hunters.lua"},
    {"Blox Fruit", "https://raw.githubusercontent.com/Yisan886/Aero/refs/heads/main/Blox Fruit.lua"},
    {"种植花园", "https://raw.githubusercontent.com/Yisan886/Aero/refs/heads/main/种植花园.lua"},
    {"像素之刃", "https://raw.githubusercontent.com/Yisan886/Aero/refs/heads/main/像素之刃.lua"},
    {"最强的拳击模拟器", "https://raw.githubusercontent.com/Yisan886/Aero/refs/heads/main/最强的拳击模拟器.lua"},
    {"血色地带", "https://raw.githubusercontent.com/Yisan886/Aero/refs/heads/main/血色地带.lua"},
    {"月球增量", "https://raw.githubusercontent.com/Yisan886/Aero/refs/heads/main/月球增量.lua"},
    {"造船寻宝", "https://raw.githubusercontent.com/Yisan886/Aero/refs/heads/main/造船寻宝.lua"},
    {"诅咒之刃", "https://raw.githubusercontent.com/Yisan886/Aero/refs/heads/main/诅咒之刃.lua"},
    {"最强战场", "https://raw.githubusercontent.com/Yisan886/Aero/refs/heads/main/最强战场.lua"},
    {"战争机器", "https://raw.githubusercontent.com/Yisan886/Aero/refs/heads/main/战争机器.lua"},
    {"GB", "https://raw.githubusercontent.com/Yisan886/Aero/refs/heads/main/GB.lua"},
    {"寻找巨型鱼", "https://raw.githubusercontent.com/Yisan886/Aero/refs/heads/main/寻找巨型鱼.lua"},
    {"chain", "https://raw.githubusercontent.com/Yisan886/Aero/refs/heads/main/chain.lua"},
}

local currentAeroScript = nil
local isLoading = false

local function loadAeroScript(scriptName, url)
    if isLoading then return end
    isLoading = true
    
    -- 通知开始加载
    Rayfield:Notify({
        Title = "加载中",
        Content = "正在加载 " .. scriptName .. "...",
        Duration = 2
    })
    
    -- 如果已有 Aero 脚本在运行，先尝试清理
    if currentAeroScript then
        -- 关闭可能存在的 WindUI 窗口
        if getgenv().WindUI and getgenv().WindUI.Destroy then
            pcall(function() getgenv().WindUI.Destroy() end)
        end
        currentAeroScript = nil
    end
    
    -- 加载新脚本
    local success, err = pcall(function()
        loadstring(game:HttpGet(url, true))()
    end)
    
    isLoading = false
    
    if success then
        Rayfield:Notify({
            Title = "成功",
            Content = scriptName .. " 加载成功！",
            Duration = 3
        })
        currentAeroScript = scriptName
    else
        Rayfield:Notify({
            Title = "失败",
            Content = scriptName .. " 加载失败：" .. tostring(err),
            Duration = 5
        })
    end
end

-- 创建游戏按钮
for _, scriptData in ipairs(AeroScripts) do
    local displayName = scriptData[1]
    local url = scriptData[2]
    
    TabAero:CreateButton({
        Name = displayName,
        Callback = function()
            loadAeroScript(displayName, url)
        end
    })
end

TabAero:CreateSection("ℹ️ 说明")
TabAero:CreateLabel("点击游戏名称即可加载对应的 Aero 脚本")
TabAero:CreateLabel("每次只加载一个，避免冲突")
TabAero:CreateLabel("加载失败请检查网络或 URL 是否有效")

--// ============================================
--   6. iOS 玻璃风格 - 玩家进出提示
-- ============================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- 配置
local NotifyEnabled   = true
local MaxNotices      = 5
local NoticeDuration  = 3.0
local activeNotices   = {}

-- 颜色方案（iOS 风格）
local COLORS = {
    JoinBG    = Color3.fromRGB(48, 209, 88),
    LeaveBG   = Color3.fromRGB(255, 59, 48),
    GlassTint = Color3.fromRGB(255, 255, 255),
    Text      = Color3.fromRGB(255, 255, 255),
    SubText   = Color3.fromRGB(230, 230, 230),
}

-- 创建 ScreenGui
local NotifyGui = Instance.new("ScreenGui")
NotifyGui.Name = "iOSNotifyGui"
NotifyGui.ResetOnSpawn = false
NotifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
NotifyGui.Parent = PlayerGui

-- 右侧容器
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

-- 创建模糊背景（模拟 iOS 毛玻璃）
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

-- 创建单条提示
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

    local tintColor = isJoin and COLORS.JoinBG or COLORS.LeaveBG
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

    TweenService:Create(card, TweenInfo.new(0.45, EASE_OUT, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0)
    }):Play()

    TweenService:Create(title, TweenInfo.new(0.35, EASE_SMOOTH), { TextTransparency = 0 }):Play()
    TweenService:Create(nameLabel, TweenInfo.new(0.35, EASE_SMOOTH), { TextTransparency = 0 }):Play()
    TweenService:Create(dot, TweenInfo.new(0.35, EASE_SMOOTH), { BackgroundTransparency = 0.3 }):Play()

    task.delay(NoticeDuration, function()
        TweenService:Create(card, TweenInfo.new(0.7, EASE_IN, Enum.EasingDirection.InOut), {
            Position = UDim2.new(0, -300, 0, 0),
        }):Play()

        TweenService:Create(title, TweenInfo.new(0.6, EASE_SMOOTH), { TextTransparency = 1 }):Play()
        TweenService:Create(nameLabel, TweenInfo.new(0.6, EASE_SMOOTH), { TextTransparency = 1 }):Play()
        TweenService:Create(dot, TweenInfo.new(0.5, EASE_SMOOTH), { BackgroundTransparency = 1 }):Play()

        for _, child in ipairs(card:GetChildren()) do
            if child:IsA("Frame") then
                TweenService:Create(child, TweenInfo.new(0.6, EASE_SMOOTH), {
                    BackgroundTransparency = child.BackgroundTransparency + 0.25
                }):Play()
            end
        end

        task.delay(0.8, function()
            if card and card.Parent then card:Destroy() end
            for i, v in ipairs(activeNotices) do
                if v == card then table.remove(activeNotices, i); break end
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
        if plr ~= player then createNotice(plr.Name, true) end
    end
end)

--// ===== 7. 进出提示设置页 =====
TabNotify:CreateSection("🎨 提示外观")

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
    Range = {1, 8}, Increment = 0.5, CurrentValue = 3.0,
    Callback = function(value) NoticeDuration = value end
})

TabNotify:CreateSlider({
    Name = "最大同时显示条数",
    Range = {1, 10}, Increment = 1, CurrentValue = 5,
    Callback = function(value) MaxNotices = math.floor(value) end
})

TabNotify:CreateSection("🧪 测试")
TabNotify:CreateButton({ Name = "测试 - 玩家加入", Callback = function() createNotice("TestPlayer", true) end })
TabNotify:CreateButton({ Name = "测试 - 玩家离开", Callback = function() createNotice("TestPlayer", false) end })

--// ===== 8. 关于脚本 =====
TabAbout:CreateSection("脚本信息")
TabAbout:CreateParagraph({ Title = "冰缝合脚本 V4.0", Content = "模块化整合版：Rayfield UI + iOS 玻璃玩家进出提示 + Aero 动态加载系统。" })
TabAbout:CreateLabel("开发者：榆 QQ3347313900")
TabAbout:CreateLabel("版本：V4.0")
TabAbout:CreateLabel("包含：17 款 Aero 游戏脚本")
TabAbout:CreateSection("系统")
TabAbout:CreateButton({ Name = "关闭 UI", Callback = function() Rayfield:Destroy() end })
