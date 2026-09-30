--// ============================================
--         冰缝合脚本 V2.2 - 榆
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

--// ============================================
--   背景图片管理模块（必须放在标签页创建之前）
-- ============================================
local BG_IMAGE    = "rbxassetid://122447960096082"  -- 默认背景图
local IMG_ALPHA   = 0.12                            -- 图片透明度 0~1
local GLASS_ALPHA = 0.38                            -- 内容玻璃化程度

local MainWindow = nil                              -- 全局共享
local ContentProvider = game:GetService("ContentProvider")

-- 启动即预加载默认背景，加快首次显示
task.spawn(function()
    pcall(function()
        ContentProvider:PreloadAsync({ BG_IMAGE })
    end)
end)

-- 规范化图片 ID：支持纯数字 / rbxassetid:// / http 链接
local function normalizeImageId(id)
    if not id or id == "" then return nil end
    id = tostring(id):gsub("%s", "")
    if string.find(id, "rbxassetid://") or string.find(id, "rbxthumb://") or string.find(id, "http") then
        return id
    end
    if string.match(id, "^%d+$") then
        return "rbxassetid://" .. id
    end
    return nil
end

-- 全局函数：应用/更换背景图片
function applyBackgroundImage(id)
    local normalized = normalizeImageId(id)
    if not normalized then
        if Rayfield and Rayfield.Notify then
            Rayfield:Notify({ Title = "错误", Content = "无效的图片 ID", Duration = 3 })
        end
        return
    end
    BG_IMAGE = normalized

    -- 异步预加载新图
    task.spawn(function()
        pcall(function()
            ContentProvider:PreloadAsync({ BG_IMAGE })
        end)
    end)

    -- 窗口存在则热更新
    if MainWindow and MainWindow.Parent then
        local holder = MainWindow:FindFirstChild("BgImageHolder")
        if holder then
            local img = holder:FindFirstChild("WindowBackground")
            if img then
                img.Image = BG_IMAGE
                img.ImageTransparency = IMG_ALPHA
            end
        end
    end

    if Rayfield and Rayfield.Notify then
        Rayfield:Notify({ Title = "背景已更新", Content = BG_IMAGE, Duration = 2 })
    end
end

--// ===== 3. 创建所有标签页 =====
local TabHome    = Window:CreateTab("主页")
local TabNotify  = Window:CreateTab("进出提示")
local TabAbout   = Window:CreateTab("关于脚本")
local TabAero    = Window:CreateTab("Aero")
local TabOther   = Window:CreateTab("其他脚本")

--// ===== 4. 主页 =====
TabHome:CreateSection("作者信息")
TabHome:CreateLabel("作者：榆")
TabHome:CreateLabel("参与者：心意冰存(嵩)")
TabHome:CreateParagraph({ Title = "关于作者", Content = "本脚本由 榆 开发，仅供学习交流使用。" })

TabHome:CreateSection("背景图片")
TabHome:CreateInput({
    Name = "图片 ID（回车应用）",
    PlaceholderText = "如 122447960096082 或 rbxassetid://xxx",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        applyBackgroundImage(text)
    end
})

TabHome:CreateButton({
    Name = "应用 / 刷新背景",
    Callback = function()
        applyBackgroundImage(BG_IMAGE)
    end
})

TabHome:CreateButton({
    Name = "恢复默认背景",
    Callback = function()
        applyBackgroundImage("122447960096082")
    end
})

-- ============================================
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
TabAbout:CreateLabel("参与者：心意冰存(嵩) QQ 3629335696")
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
    StealEgg  = "https://raw.githubusercontent.com/JsYb666/Item/refs/heads/main/Steal-Eggs",
}

TabOther:CreateSection("其他脚本库")

TabOther:CreateButton({
    Name = "▶ 加载 偷一个蛋 (TX Script)",
    Callback = function()
        loadExternalScript("偷一个蛋", OTHER_URLS.StealEgg)
    end
})

TabOther:CreateSection("说明")
TabOther:CreateParagraph({
    Title = "使用说明",
    Content = "点击按钮后才会加载对应脚本，不会自动运行。所有脚本链接均已验证可正常访问。"
})

--// ============================================
--   11. 窗口美化：背景图片 + 边缘跑马灯
--   （BG_IMAGE / IMG_ALPHA / GLASS_ALPHA / MainWindow 已在顶部统一定义）
-- ============================================

-- 定位 Rayfield 主窗口（过滤键盘UI，避免误抓）
local function findMainWindow()
    local containers = {}
    local ok, hui = pcall(function() return gethui() end)
    if ok and hui then table.insert(containers, hui) end
    table.insert(containers, game:GetService("CoreGui"))
    local pg = player:FindFirstChild("PlayerGui")
    if pg then table.insert(containers, pg) end

    local best, bestArea = nil, 0
    for _, c in ipairs(containers) do
        local ok2, kids = pcall(function() return c:GetChildren() end)
        if ok2 then
            for _, sg in ipairs(kids) do
                if sg:IsA("ScreenGui") then
                    for _, d in ipairs(sg:GetDescendants()) do
                        if d:IsA("Frame") and d:FindFirstChildOfClass("UICorner") then
                            local n = string.lower(d.Name)
                            if not string.find(n, "keyboard") and not string.find(n, "key") then
                                local area = d.Size.X.Offset * d.Size.Y.Offset
                                if area > bestArea then
                                    bestArea = area
                                    best = d
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return best
end

-- 深色容器变半透明（跳过 TextButton，防止 UIStroke 报错）
local baseTrans = setmetatable({}, { __mode = "k" })

local function fadeContent(Main, skipA, skipB)
    for _, d in ipairs(Main:GetDescendants()) do
        if (d:IsA("Frame") or d:IsA("ScrollingFrame"))
            and d ~= skipA and d ~= skipB then
            local base = baseTrans[d]
            if base == nil then
                base = d.BackgroundTransparency
                baseTrans[d] = base
            end
            if base < 1 then
                local c = d.BackgroundColor3
                local lum = c.R * 0.299 + c.G * 0.587 + c.B * 0.114
                if lum < 0.32 then
                    d.BackgroundTransparency = math.min(0.96, base + GLASS_ALPHA)
                end
            end
        end
    end
end

local function applyCustomTheme()
    if MainWindow and MainWindow.Parent then return end

    local Main = findMainWindow()
    if not Main then return end
    MainWindow = Main

    Main.ClipsDescendants = false
    Main.BackgroundTransparency = 1

    local radius = 12
    local mc = Main:FindFirstChildOfClass("UICorner")
    if mc and typeof(mc.CornerRadius) == "UDim" then
        radius = mc.CornerRadius.Offset
    end

    -------------------------------------------------
    -- A. 边缘跑马灯（Frame + UIGradient）
    -------------------------------------------------
    local glow = Instance.new("Frame")
    glow.Name = "MarqueeGlow"
    glow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    glow.BackgroundTransparency = 0.15
    glow.BorderSizePixel = 0
    glow.Position = UDim2.new(0, -4, 0, -4)
    glow.Size = UDim2.new(1, 8, 1, 8)
    glow.ZIndex = 0
    glow.Parent = Main

    local gc = Instance.new("UICorner")
    gc.CornerRadius = UDim.new(0, radius + 6)
    gc.Parent = glow

    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 210, 255)),
        ColorSequenceKeypoint.new(0.20, Color3.fromRGB(130, 80, 255)),
        ColorSequenceKeypoint.new(0.40, Color3.fromRGB(255, 60, 160)),
        ColorSequenceKeypoint.new(0.60, Color3.fromRGB(130, 80, 255)),
        ColorSequenceKeypoint.new(0.80, Color3.fromRGB(0, 210, 255)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 210, 255)),
    })
    grad.Parent = glow

    task.spawn(function()
        local t = 0
        while glow.Parent do
            t += task.wait(0.03)
            grad.Rotation = (t * 130) % 360
        end
    end)

    task.spawn(function()
        while glow.Parent do
            TweenService:Create(glow, TweenInfo.new(1.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                { BackgroundTransparency = 0.42 }):Play()
            task.wait(1.3)
            if not glow.Parent then break end
            TweenService:Create(glow, TweenInfo.new(1.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                { BackgroundTransparency = 0.12 }):Play()
            task.wait(1.3)
        end
    end)

    -------------------------------------------------
    -- B. 背景图片（贴合圆角）
    -------------------------------------------------
    local holder = Instance.new("Frame")
    holder.Name = "BgImageHolder"
    holder.BackgroundTransparency = 1
    holder.Position = UDim2.new(0, 0, 0, 0)
    holder.Size = UDim2.new(1, 0, 1, 0)
    holder.ClipsDescendants = true
    holder.ZIndex = 0
    holder.Parent = Main

    local hc = Instance.new("UICorner")
    hc.CornerRadius = UDim.new(0, radius)
    hc.Parent = holder

    local img = Instance.new("ImageLabel")
    img.Name = "WindowBackground"
    img.BackgroundTransparency = 1
    img.Size = UDim2.new(1, 0, 1, 0)
    img.Position = UDim2.new(0, 0, 0, 0)
    img.Image = BG_IMAGE
    img.ScaleType = Enum.ScaleType.Crop
    img.ImageTransparency = IMG_ALPHA
    img.ZIndex = 0
    img.Parent = holder

    -------------------------------------------------
    -- C. 内容半透明化
    -------------------------------------------------
    fadeContent(Main, holder, glow)

    local pending = false
    Main.DescendantAdded:Connect(function()
        if pending then return end
        pending = true
        task.delay(0.25, function()
            pending = false
            if MainWindow and MainWindow.Parent then
                fadeContent(MainWindow, holder, glow)
            end
        end)
    end)

    task.spawn(function()
        for _ = 1, 12 do
            task.wait(0.5)
            if MainWindow and MainWindow.Parent then
                fadeContent(MainWindow, holder, glow)
            end
        end
    end)
end

-- 关闭再打开窗口后背景消失的修复：可重复安全调用
local originalApply = applyCustomTheme
applyCustomTheme = function()
    if MainWindow and MainWindow.Parent then
        local holder = MainWindow:FindFirstChild("BgImageHolder")
        local glow   = MainWindow:FindFirstChild("MarqueeGlow")
        if holder and glow then
            MainWindow.BackgroundTransparency = 1
            fadeContent(MainWindow, holder, glow)
            return
        end
        MainWindow = nil
    end
    originalApply()
end

-- 等 Rayfield 窗口渲染出来再执行（快速轮询，最多 3 秒）
task.spawn(function()
    for _ = 1, 30 do
        if findMainWindow() then break end
        task.wait(0.1)
    end
    applyCustomTheme()

    -------------------------------------------------
    -- 持续监控窗口状态（避免重开窗口后背景丢失）
    -------------------------------------------------
    task.spawn(function()
        while true do
            task.wait(0.4)

            if MainWindow and not MainWindow.Parent then
                MainWindow = nil
            end

            if not MainWindow then
                local m = findMainWindow()
                if m then applyCustomTheme() end
            else
                local holder = MainWindow:FindFirstChild("BgImageHolder")
                local glow   = MainWindow:FindFirstChild("MarqueeGlow")

                if not holder or not glow then
                    MainWindow = nil
                    local m = findMainWindow()
                    if m then applyCustomTheme() end
                else
                    if MainWindow.BackgroundTransparency ~= 1 then
                        MainWindow.BackgroundTransparency = 1
                        fadeContent(MainWindow, holder, glow)
                    end
                end
            end
        end
    end)
end)
