--// ============================================
--         冰缝合脚本 - WindUI 终极版 - 榆
-- ============================================

--// ===== 0. 通用颜色转换函数（兼容旧版执行器）=====
local function hexToColor3(hex)
    hex = hex:gsub("#", "")
    local r = tonumber(hex:sub(1, 2), 16) or 0
    local g = tonumber(hex:sub(3, 4), 16) or 0
    local b = tonumber(hex:sub(5, 6), 16) or 0
    return Color3.fromRGB(r, g, b)
end

--// ===== 1. 加载 WindUI 库 =====
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
if not WindUI then
    warn("WindUI 库加载失败，请检查网络或更换执行器。")
    return
end

--// ============================================
--   2. 注册所有主题（已替换为 hexToColor3）
--// ============================================
WindUI:AddTheme({ Name = "Amber", Accent = hexToColor3("#92400e"), Background = hexToColor3("#1c140f"), Outline = hexToColor3("#fcd34d"), Text = hexToColor3("#fffbeb"), Placeholder = hexToColor3("#a8a29e"), Button = hexToColor3("#78350f"), Icon = hexToColor3("#fbbf24") })
WindUI:AddTheme({ Name = "Plant", Accent = hexToColor3("#166534"), Background = hexToColor3("#0f1f17"), Outline = hexToColor3("#4ade80"), Text = hexToColor3("#f0fdf4"), Placeholder = hexToColor3("#86efac"), Button = hexToColor3("#14532d"), Icon = hexToColor3("#22c55e") })
WindUI:AddTheme({ Name = "Cotton Candy", Accent = hexToColor3("#7e22ce"), Background = hexToColor3("#1a1026"), Outline = hexToColor3("#e879f9"), Text = hexToColor3("#faf5ff"), Placeholder = hexToColor3("#c4b5fd"), Button = hexToColor3("#6b21a8"), Icon = hexToColor3("#d946ef") })
WindUI:AddTheme({ Name = "Monokai Pro", Accent = hexToColor3("#272822"), Background = hexToColor3("#1e1f1c"), Outline = hexToColor3("#f8f8f2"), Text = hexToColor3("#f7f7f7"), Placeholder = hexToColor3("#90908a"), Button = hexToColor3("#3e3d32"), Icon = hexToColor3("#a6e22e") })
WindUI:AddTheme({ Name = "Crimson", Accent = hexToColor3("#991b1b"), Background = hexToColor3("#200c0c"), Outline = hexToColor3("#f87171"), Text = hexToColor3("#fef2f2"), Placeholder = hexToColor3("#fca5a5"), Button = hexToColor3("#7f1d1d"), Icon = hexToColor3("#ef4444") })
WindUI:AddTheme({ Name = "Violet", Accent = hexToColor3("#4c1d95"), Background = hexToColor3("#17102b"), Outline = hexToColor3("#a78bfa"), Text = hexToColor3("#f5f3ff"), Placeholder = hexToColor3("#c4b5fd"), Button = hexToColor3("#5b21b6"), Icon = hexToColor3("#8b5cf6") })
WindUI:AddTheme({ Name = "Midnight", Accent = hexToColor3("#1e3a8a"), Background = hexToColor3("#0f172a"), Outline = hexToColor3("#93c5fd"), Text = hexToColor3("#eff6ff"), Placeholder = hexToColor3("#94a3b8"), Button = hexToColor3("#1e40af"), Icon = hexToColor3("#3b82f6") })
WindUI:AddTheme({ Name = "Rose", Accent = hexToColor3("#881337"), Background = hexToColor3("#230e16"), Outline = hexToColor3("#fda4af"), Text = hexToColor3("#fff1f2"), Placeholder = hexToColor3("#fda4af"), Button = hexToColor3("#9f1239"), Icon = hexToColor3("#f43f5e") })
WindUI:AddTheme({ Name = "Mellowsi", Accent = hexToColor3("#78350f"), Background = hexToColor3("#1c120a"), Outline = hexToColor3("#fcd34d"), Text = hexToColor3("#fffbeb"), Placeholder = hexToColor3("#a8a29e"), Button = hexToColor3("#713f12"), Icon = hexToColor3("#fbbf24") })
WindUI:AddTheme({ Name = "Sky", Accent = hexToColor3("#0e7490"), Background = hexToColor3("#0c1d24"), Outline = hexToColor3("#5eead4"), Text = hexToColor3("#ecfeff"), Placeholder = hexToColor3("#5eead4"), Button = hexToColor3("#155e75"), Icon = hexToColor3("#14b8a6") })
WindUI:AddTheme({ Name = "Indigo", Accent = hexToColor3("#312e81"), Background = hexToColor3("#12142d"), Outline = hexToColor3("#a5b4fc"), Text = hexToColor3("#eef2ff"), Placeholder = hexToColor3("#a5b4fc"), Button = hexToColor3("#3730a3"), Icon = hexToColor3("#6366f1") })
WindUI:AddTheme({ Name = "Red", Accent = hexToColor3("#b91c1c"), Background = hexToColor3("#1f0d0d"), Outline = hexToColor3("#fca5a5"), Text = hexToColor3("#fef2f2"), Placeholder = hexToColor3("#fca5a5"), Button = hexToColor3("#991b1b"), Icon = hexToColor3("#ef4444") })
WindUI:AddTheme({ Name = "Emerald", Accent = hexToColor3("#047857"), Background = hexToColor3("#0c1c16"), Outline = hexToColor3("#6ee7b7"), Text = hexToColor3("#f0fdfa"), Placeholder = hexToColor3("#6ee7b7"), Button = hexToColor3("#065f46"), Icon = hexToColor3("#10b981") })
WindUI:AddTheme({ Name = "Dark", Accent = hexToColor3("#18181b"), Background = hexToColor3("#101010"), Outline = hexToColor3("#FFFFFF"), Text = hexToColor3("#FFFFFF"), Placeholder = hexToColor3("#7a7a7a"), Button = hexToColor3("#52525b"), Icon = hexToColor3("#a1a1aa") })

--// ============================================
--   3. 背景 / UI黑色透明度 管理模块
--// ============================================
local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

local BG_LIST = {
    "rbxassetid://116211389465318",
    "rbxassetid://92883588549999",
    "rbxassetid://108917308701664",
    "rbxassetid://101390233693690",
}
local BG_NAMES = { "背景 1", "背景 2", "背景 3", "背景 4" }

local CurrentBG = BG_LIST[1]
local CurrentBGTransparency = 0.15

-- ★ UI黑色透明度
local UIDarkTransparency = 0.75
local EnhancedTransparency = false
local ENHANCED_VALUE = 0.92

local MainWindowFrame = nil
local DarkFrames = {}

task.spawn(function()
    pcall(function() ContentProvider:PreloadAsync(BG_LIST) end)
end)

local function normalizeImageId(id)
    if not id or type(id) ~= "string" or id == "" then return nil end
    id = tostring(id):gsub("%s", "")
    if id == "" then return nil end
    if string.find(id, "rbxassetid://") or string.find(id, "rbxthumb://") or string.find(id, "http") then return id end
    if string.match(id, "^%d+$") then return "rbxassetid://" .. id end
    return nil
end

function applyBackgroundImage(id)
    if not id or type(id) ~= "string" or id == "" then return end
    local normalized = normalizeImageId(id)
    if not normalized then
        WindUI:Notify({ Title = "错误", Content = "无效的图片 ID", Icon = "x", Duration = 3 })
        return
    end
    CurrentBG = normalized
    task.spawn(function() pcall(function() ContentProvider:PreloadAsync({ CurrentBG }) end) end)

    if MainWindowFrame and MainWindowFrame.Parent then
        local holder = MainWindowFrame:FindFirstChild("BgImageHolder")
        if holder then
            local img = holder:FindFirstChild("WindowBackground")
            if img then
                img.Image = ""
                task.wait(0.05)
                img.Image = CurrentBG
                img.ImageTransparency = CurrentBGTransparency
            end
        end
    end
    WindUI:Notify({ Title = "背景已更新", Content = CurrentBG, Icon = "check", Duration = 2 })
end

-- 递归收集所有黑色 Frame（扩大识别范围，确保UI透明度生效）
local function collectDarkFrames()
    DarkFrames = {}
    if not MainWindowFrame then return end

    local function scan(obj)
        for _, child in ipairs(obj:GetChildren()) do
            if child:IsA("Frame") then
                -- 排除我们自己的特殊组件
                if child.Name ~= "BgImageHolder"
                    and child.Name ~= "MarqueeOverlay"
                    and child.Name ~= "WindowBackground"
                    and child.Visible then
                    local c = child.BackgroundColor3
                    local area = child.AbsoluteSize.X * child.AbsoluteSize.Y
                    -- 扩大深色识别范围：RGB低于0.5的都算，面积够大
                    local isDark = c.R < 0.5 and c.G < 0.5 and c.B < 0.5
                    if isDark and area > 200 and child.BackgroundTransparency < 0.95 then
                        table.insert(DarkFrames, child)
                    end
                end
                scan(child)
            elseif child:IsA("CanvasGroup") then
                scan(child)
            end
        end
    end
    scan(MainWindowFrame)
end

-- ★ 应用 UI 黑色透明度
function applyUIDarkTransparency()
    local target = EnhancedTransparency and ENHANCED_VALUE or UIDarkTransparency
    for _, f in ipairs(DarkFrames) do
        if f and f.Parent then
            f.BackgroundTransparency = target
        end
    end
end

-- ★ 寻找 WindUI 主窗口（精准定位）
local function findWindUIWindow()
    local containers = { game:GetService("CoreGui") }
    local ok, hui = pcall(function() return gethui() end)
    if ok and hui then table.insert(containers, 1, hui) end
    local pg = player:FindFirstChild("PlayerGui")
    if pg then table.insert(containers, pg) end

    local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
    local screenArea = viewport.X * viewport.Y

    for _, c in ipairs(containers) do
        for _, sg in ipairs(c:GetChildren()) do
            if sg:IsA("ScreenGui") and (string.find(string.lower(sg.Name), "windui") or string.find(string.lower(sg.Name), "wind")) then
                local bestFrame = nil
                local bestArea = 0
                for _, d in ipairs(sg:GetDescendants()) do
                    if d:IsA("Frame") and d.Visible and d:FindFirstChildOfClass("UICorner") then
                        local area = d.AbsoluteSize.X * d.AbsoluteSize.Y
                        -- 寻找面积合适（不是全屏遮罩）且带圆角的Frame
                        if area > 10000 and area < screenArea * 0.9 then
                            if area > bestArea then
                                bestArea = area
                                bestFrame = d
                            end
                        end
                    end
                end
                if bestFrame then return bestFrame end
            end
        end
    end
    return nil
end

-- ★ 创建彩虹跑马灯（强制覆盖在窗口边缘，清除原有黑边框）
local function ensureMarquee(main, radius)
    -- 清除之前可能残留的覆盖层
    local old = main:FindFirstChild("MarqueeOverlay")
    if old then old:Destroy() end

    -- 移除 WindUI 自带的黑色边框，防止覆盖我们的跑马灯
    for _, child in ipairs(main:GetChildren()) do
        if child:IsA("UIStroke") and child.Name ~= "MarqueeStroke" then
            child.Transparency = 1 -- 隐藏自带黑边
        end
    end

    local overlay = Instance.new("Frame")
    overlay.Name = "MarqueeOverlay"
    overlay.BackgroundTransparency = 1
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.Position = UDim2.new(0, 0, 0, 0)
    overlay.ZIndex = 99999 -- 绝对最高层，防止被遮挡
    overlay.ClipsDescendants = false
    overlay.Parent = main

    local oc = Instance.new("UICorner")
    oc.CornerRadius = UDim.new(0, radius)
    oc.Parent = overlay

    local stroke = Instance.new("UIStroke")
    stroke.Name = "MarqueeStroke"
    stroke.Thickness = 3
    stroke.Transparency = 0.05
    -- ★ 关键修复：必须设置底色为白色，UIGradient 才能正常显示彩虹色，否则默认是黑色
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = overlay

    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 210, 255)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(130, 80, 255)),
        ColorSequenceKeypoint.new(0.66, Color3.fromRGB(255, 60, 160)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 210, 255)),
    })
    grad.Parent = stroke

    -- 彩虹旋转动画
    task.spawn(function()
        local t = 0
        while overlay.Parent do
            t += task.wait(0.03)
            grad.Rotation = (t * 180) % 360
        end
    end)

    -- 呼吸闪烁动画
    task.spawn(function()
        while overlay.Parent do
            TweenService:Create(stroke, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Transparency = 0.4 }):Play()
            task.wait(1.2)
            if not overlay.Parent then break end
            TweenService:Create(stroke, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Transparency = 0.05 }):Play()
            task.wait(1.2)
        end
    end)
end

-- ★ 注入背景 + 跑马灯
local function applyWindUITheme()
    local main = findWindUIWindow()
    if not main then return end
    MainWindowFrame = main

    main.ClipsDescendants = false
    collectDarkFrames()
    applyUIDarkTransparency()

    local radius = 12
    local mc = main:FindFirstChildOfClass("UICorner")
    if mc and typeof(mc.CornerRadius) == "UDim" then radius = mc.CornerRadius.Offset end

    -- 注入背景图
    if not main:FindFirstChild("BgImageHolder") then
        local holder = Instance.new("Frame")
        holder.Name = "BgImageHolder"
        holder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        holder.BackgroundTransparency = 0.85
        holder.Size = UDim2.new(1, 0, 1, 0)
        holder.ClipsDescendants = true
        holder.ZIndex = -10
        holder.Parent = main

        local hc = Instance.new("UICorner")
        hc.CornerRadius = UDim.new(0, radius)
        hc.Parent = holder

        local img = Instance.new("ImageLabel")
        img.Name = "WindowBackground"
        img.BackgroundTransparency = 1
        img.Size = UDim2.new(1, 0, 1, 0)
        img.Image = CurrentBG
        img.ScaleType = Enum.ScaleType.Crop
        img.ImageTransparency = CurrentBGTransparency
        img.ZIndex = 0
        img.Parent = holder
    end

    -- 注入跑马灯
    ensureMarquee(main, radius)
end

-- ★ 监控窗口状态，保持一切正常
task.spawn(function()
    for _ = 1, 50 do
        task.wait(0.1)
        if findWindUIWindow() then break end
    end
    task.wait(0.5)
    applyWindUITheme()

    local tick = 0
    while true do
        task.wait(0.5)
        tick = tick + 1

        if MainWindowFrame and MainWindowFrame.Parent then
            -- 保活背景图
            local holder = MainWindowFrame:FindFirstChild("BgImageHolder")
            if holder then
                holder.ZIndex = -10
                local img = holder:FindFirstChild("WindowBackground")
                if img then
                    img.ZIndex = 0
                    img.ImageTransparency = CurrentBGTransparency
                end
            end

            -- 保活跑马灯
            if not MainWindowFrame:FindFirstChild("MarqueeOverlay") then
                local radius = 12
                local mc = MainWindowFrame:FindFirstChildOfClass("UICorner")
                if mc and typeof(mc.CornerRadius) == "UDim" then radius = mc.CornerRadius.Offset end
                ensureMarquee(MainWindowFrame, radius)
            end

            -- 每2秒重新收集一次深色Frame（防止打开新面板时透明度失效）
            if tick % 4 == 0 then collectDarkFrames() end
            applyUIDarkTransparency()
        else
            MainWindowFrame = nil
            DarkFrames = {}
            applyWindUITheme()
        end
    end
end)

--// ============================================
--   4. 玩家进出提示（卡片自带跑马灯）
--// ============================================
local NotifyEnabled   = true
local MaxNotices      = 5
local NoticeDuration  = 3.0
local activeNotices   = {}

local NotifyGui = Instance.new("ScreenGui")
NotifyGui.Name = "iOSNotifyGui"
NotifyGui.ResetOnSpawn = false
NotifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
NotifyGui.Parent = player:WaitForChild("PlayerGui")

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

local function addCardMarquee(card)
    local stroke = Instance.new("UIStroke")
    stroke.Name = "CardMarquee"
    stroke.Thickness = 2
    stroke.Transparency = 0.1
    stroke.Color = Color3.fromRGB(255, 255, 255) -- 必须设为白色
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = card

    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 210, 255)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(130, 80, 255)),
        ColorSequenceKeypoint.new(0.66, Color3.fromRGB(255, 60, 160)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 210, 255)),
    })
    grad.Parent = stroke

    task.spawn(function()
        local t = 0
        while card.Parent do
            t += task.wait(0.03)
            grad.Rotation = (t * 180) % 360
        end
    end)
    task.spawn(function()
        while card.Parent do
            TweenService:Create(stroke, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Transparency = 0.45 }):Play()
            task.wait(1.2)
            if not card.Parent then break end
            TweenService:Create(stroke, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Transparency = 0.05 }):Play()
            task.wait(1.2)
        end
    end)
end

local function createNotice(plrName, isJoin)
    if not NotifyEnabled then return end
    if #activeNotices >= MaxNotices then
        local oldest = table.remove(activeNotices, 1)
        if oldest and oldest.Parent then oldest:Destroy() end
    end

    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, 280, 0, 56)
    card.BackgroundColor3 = isJoin and Color3.fromRGB(48, 209, 88) or Color3.fromRGB(255, 59, 48)
    card.BackgroundTransparency = 0.75
    card.BorderSizePixel = 0
    card.ClipsDescendants = true
    card.LayoutOrder = tick()
    card.Parent = RightContainer
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 16)
    cardCorner.Parent = card

    addCardMarquee(card)

    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1, 0, 0.5, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    overlay.BackgroundTransparency = 0.88
    overlay.BorderSizePixel = 0
    overlay.Parent = card
    local oc = Instance.new("UICorner")
    oc.CornerRadius = UDim.new(0, 16)
    oc.Parent = overlay

    local textX = 28
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 280 - textX - 16, 0, 22)
    title.Position = UDim2.new(0, textX, 0, 8)
    title.BackgroundTransparency = 1
    title.Text = isJoin and "玩家加入" or "玩家离开"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 15
    title.Font = Enum.Font.GothamSemibold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextTransparency = 1
    title.Parent = card

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0, 280 - textX - 16, 0, 18)
    nameLabel.Position = UDim2.new(0, textX, 0, 30)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = plrName
    nameLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    nameLabel.TextSize = 13
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextTransparency = 1
    nameLabel.Parent = card

    card.Position = UDim2.new(0, 300, 0, 0)
    table.insert(activeNotices, card)

    TweenService:Create(card, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Position = UDim2.new(0, 0, 0, 0) }):Play()
    TweenService:Create(title, TweenInfo.new(0.35), { TextTransparency = 0 }):Play()
    TweenService:Create(nameLabel, TweenInfo.new(0.35), { TextTransparency = 0 }):Play()

    task.delay(NoticeDuration, function()
        TweenService:Create(card, TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), { Position = UDim2.new(0, -300, 0, 0) }):Play()
        TweenService:Create(title, TweenInfo.new(0.6), { TextTransparency = 1 }):Play()
        TweenService:Create(nameLabel, TweenInfo.new(0.6), { TextTransparency = 1 }):Play()
        task.delay(0.8, function()
            if card and card.Parent then card:Destroy() end
            for i, v in ipairs(activeNotices) do
                if v == card then table.remove(activeNotices, i); break end
            end
        end)
    end)
end

Players.PlayerAdded:Connect(function(plr) if plr ~= player then createNotice(plr.Name, true) end end)
Players.PlayerRemoving:Connect(function(plr) if plr ~= player then createNotice(plr.Name, false) end end)
task.defer(function()
    for _, plr in ipairs(Players:GetPlayers()) do if plr ~= player then createNotice(plr.Name, true) end end
end)

--// ============================================
--   5. 通用脚本加载
--// ============================================
local function loadExternalScript(name, url)
    WindUI:Notify({ Title = "加载中", Content = "正在加载 " .. name .. "...", Icon = "loader", Duration = 2 })
    task.spawn(function()
        local ok, srcOrErr = pcall(function() return game:HttpGet(url, true) end)
        if not ok then
            WindUI:Notify({ Title = "下载失败", Content = name .. " 错误: " .. tostring(srcOrErr), Icon = "x", Duration = 5 })
            return
        end
        local success, err = pcall(function() loadstring(srcOrErr)() end)
        if success then
            WindUI:Notify({ Title = "加载成功", Content = name .. " 已加载", Icon = "check", Duration = 3 })
        else
            WindUI:Notify({ Title = "执行失败", Content = name .. " 错误: " .. tostring(err), Icon = "x", Duration = 5 })
        end
    end)
end

--// ============================================
--   6. 弹窗与主窗口
--// ============================================
WindUI:Popup({
    Title = "冰缝合脚本",
    Icon = "info",
    Content = "点击执行进入脚本主界面\n作者：榆 | 参与者：心意冰存(嵩)",
    Buttons = {
        {
            Title = "退出",
            Callback = function() end,
            Variant = "Tertiary",
        },
        {
            Title = "执行",
            Icon = "arrow-right",
            Callback = function()
                local Window = WindUI:CreateWindow({
                    Title = "冰缝合脚本",
                    Icon = "door-open",
                    Author = "榆",
                    HideSearchBar = false,
                })

                Window:ToggleTransparency(true)
                EnhancedTransparency = true

                --// ===== 公告页 =====
                local NoticeTab = Window:Tab({ Title = "公告", Icon = "megaphone", Locked = false })
                NoticeTab:Paragraph({ Title = "欢迎使用", Desc = "本脚本由 榆 开发，仅供学习交流使用。" })
                NoticeTab:Paragraph({
                    Title = "玩家信息",
                    Desc = "用户名: " .. player.Name .. "\n显示名称: " .. player.DisplayName .. "\n账号年龄: " .. player.AccountAge .. " 天\n用户ID: " .. player.UserId,
                    Image = "user",
                    ImageSize = 20
                })

                --// ===== 主要功能页 =====
                local MainTab = Window:Tab({ Title = "主要", Icon = "house", Locked = false })
                MainTab:Paragraph({ Title = "作者信息", Desc = "作者：榆\n参与者：心意冰存(嵩)" })

                MainTab:Dropdown({
                    Title = "切换背景图片",
                    Values = BG_NAMES,
                    Value = BG_NAMES[1],
                    Callback = function(selected)
                        for i, name in ipairs(BG_NAMES) do
                            if name == selected then
                                applyBackgroundImage(BG_LIST[i])
                                break
                            end
                        end
                    end
                })

                MainTab:Slider({
                    Title = "UI 黑色透明度",
                    Desc = "0 = 纯黑   1 = 完全透明（开启透明窗口时会被拉满）",
                    Value = { Min = 0, Max = 1, Default = UIDarkTransparency },
                    Callback = function(value)
                        UIDarkTransparency = value
                        if #DarkFrames == 0 then collectDarkFrames() end
                        applyUIDarkTransparency()
                    end
                })

                MainTab:Input({
                    Title = "自定义背景图片 ID",
                    Desc = "输入图片 ID 后按回车应用",
                    Icon = "image",
                    Callback = function(text)
                        if text and text ~= "" then
                            applyBackgroundImage(text)
                        end
                    end
                })

                MainTab:Button({
                    Title = "应用 / 刷新背景",
                    Desc = "重新加载当前背景图片",
                    Icon = "refresh-cw",
                    Callback = function() applyBackgroundImage(CurrentBG) end
                })

                --// ===== 进出提示页 =====
                local NotifyTab = Window:Tab({ Title = "进出提示", Icon = "bell", Locked = false })
                NotifyTab:Toggle({
                    Title = "启用玩家进出提示",
                    Value = true,
                    Callback = function(value) NotifyEnabled = value; NotifyGui.Enabled = value end
                })
                NotifyTab:Slider({
                    Title = "提示停留时间（秒）",
                    Value = { Min = 1, Max = 8, Default = 3 },
                    Callback = function(value) NoticeDuration = value end
                })
                NotifyTab:Slider({
                    Title = "最大同时显示条数",
                    Value = { Min = 1, Max = 10, Default = 5 },
                    Callback = function(value) MaxNotices = math.floor(value) end
                })
                NotifyTab:Section({ Title = "测试" })
                NotifyTab:Button({ Title = "测试 - 玩家加入", Callback = function() createNotice("TestPlayer_Join", true) end })
                NotifyTab:Button({ Title = "测试 - 玩家离开", Callback = function() createNotice("TestPlayer_Leave", false) end })

                --// ===== 脚本库页 =====
                local ScriptTab = Window:Tab({ Title = "脚本库", Icon = "code", Locked = false })
                ScriptTab:Section({ Title = "Aero 脚本库" })
                ScriptTab:Button({ Title = "▶ 加载 超高速跑者", Callback = function() loadExternalScript("超高速跑者", "https://raw.githubusercontent.com/wwd6ng2j66-art/-/main/%E8%B6%85%E9%AB%98%E9%80%9F%E8%B7%91%E8%80%85.lua") end })
                ScriptTab:Button({ Title = "▶ 加载 99夜脚本", Callback = function() loadExternalScript("99夜", "https://raw.githubusercontent.com/wwd6ng2j66-art/-/38aa514a561dd344e3b75c60e21197e484fc31aa/99%20%E5%A4%9C.lua") end })

                ScriptTab:Section({ Title = "其他脚本库" })
                ScriptTab:Button({ Title = "▶ 加载 偷一个蛋 (TX Script)", Callback = function() loadExternalScript("偷一个蛋", "https://raw.githubusercontent.com/JsYb666/Item/refs/heads/main/Steal-Eggs") end })

                --// ===== 设置页 =====
                local SettingsTab = Window:Tab({ Title = "设置", Icon = "settings", Locked = false })

                SettingsTab:Toggle({
                    Title = "切换透明窗口",
                    Desc = "开启后 UI 会变得非常透明，可清晰看到背景图",
                    Callback = function(e)
                        Window:ToggleTransparency(e)
                        EnhancedTransparency = e
                        applyUIDarkTransparency()
                    end,
                    Value = WindUI:GetTransparency()
                })

                SettingsTab:Dropdown({
                    Title = "切换主题",
                    Values = { "Dark", "Amber", "Plant", "Cotton Candy", "Monokai Pro", "Crimson", "Violet", "Midnight", "Rose", "Mellowsi", "Sky", "Indigo", "Red", "Emerald" },
                    Value = "Dark",
                    Callback = function(selected) WindUI:SetTheme(selected); WindUI:UpdateTheme() end
                })

                SettingsTab:Space()
                SettingsTab:Button({
                    Title = "重新加入当前服务器",
                    Desc = "自动读取当前服务器 ID 并重新加入",
                    Icon = "refresh-cw",
                    Callback = function()
                        local jobId = game.JobId
                        if jobId and jobId ~= "" then
                            local success, err = pcall(function() game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, jobId, player) end)
                            if success then WindUI:Notify({ Title = "正在重连", Content = "正在返回当前服务器...", Icon = "check", Duration = 3 })
                            else WindUI:Notify({ Title = "重连失败", Content = "无法返回当前服务器。", Icon = "x", Duration = 5 }) end
                        else
                            WindUI:Notify({ Title = "重连失败", Content = "无法获取当前服务器 ID", Icon = "x", Duration = 3 })
                        end
                    end
                })

                SettingsTab:Space()
                SettingsTab:Button({
                    Title = "服务器跳跃",
                    Desc = "寻找一个新的随机服务器",
                    Icon = "globe",
                    Callback = function()
                        local TS = game:GetService("TeleportService")
                        local HS = game:GetService("HttpService")
                        local success, res = pcall(function() return HS:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")) end)
                        if success and res and res.data and #res.data > 0 then
                            local chosen = res.data[math.random(1, #res.data)]
                            TS:TeleportToPlaceInstance(game.PlaceId, chosen.id, player)
                        else
                            WindUI:Notify({ Title = "跳跃失败", Content = "没有找到可用的服务器", Icon = "x" })
                        end
                    end
                })

                SettingsTab:Space()
                SettingsTab:Button({
                    Title = "加入人少的服务器",
                    Desc = "自动寻找并加入当前在线人数最少的服务器",
                    Icon = "users",
                    Callback = function()
                        local TS = game:GetService("TeleportService")
                        local HS = game:GetService("HttpService")
                        local success, res = pcall(function() return HS:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")) end)
                        if success and res and res.data and #res.data > 0 then
                            table.sort(res.data, function(a, b) return a.playing < b.playing end)
                            local chosenServer = res.data[1]
                            TS:TeleportToPlaceInstance(game.PlaceId, chosenServer.id, player)
                            WindUI:Notify({ Title = "正在跳跃", Content = "当前人数：" .. chosenServer.playing, Icon = "check", Duration = 3 })
                        else
                            WindUI:Notify({ Title = "跳跃失败", Content = "没有找到可用的服务器", Icon = "x" })
                        end
                    end
                })

                SettingsTab:Space()
                SettingsTab:Button({
                    Title = "复制当前服务器 ID",
                    Desc = "将当前服务器的 ID 复制到剪贴板",
                    Icon = "copy",
                    Callback = function()
                        if game.JobId and game.JobId ~= "" then
                            setclipboard(game.JobId)
                            WindUI:Notify({ Title = "复制成功", Content = "服务器 ID 已复制", Icon = "check", Duration = 3 })
                        else
                            WindUI:Notify({ Title = "复制失败", Content = "无法获取当前服务器 ID", Icon = "x", Duration = 3 })
                        end
                    end
                })

                SettingsTab:Space()
                local TargetJobId = ""
                SettingsTab:Input({
                    Title = "输入服务器 ID",
                    Desc = "粘贴你想加入的服务器 JobId",
                    Icon = "hash",
                    Callback = function(value) TargetJobId = value end
                })

                SettingsTab:Space()
                SettingsTab:Button({
                    Title = "加入特定服务器",
                    Desc = "使用上方输入框中的 ID 加入对应服务器",
                    Icon = "log-in",
                    Callback = function()
                        if not TargetJobId or TargetJobId == "" then
                            WindUI:Notify({ Title = "加入失败", Content = "请先粘贴服务器 ID", Icon = "alert-triangle", Duration = 3 })
                            return
                        end
                        local TS = game:GetService("TeleportService")
                        local success, err = pcall(function() TS:TeleportToPlaceInstance(game.PlaceId, TargetJobId, player) end)
                        if success then WindUI:Notify({ Title = "正在传送", Content = "正在加入: " .. TargetJobId, Icon = "check", Duration = 3 })
                        else WindUI:Notify({ Title = "加入失败", Content = tostring(err), Icon = "x", Duration = 5 }) end
                    end
                })

                task.delay(0.5, function()
                    applyWindUITheme()
                end)
            end,
            Variant = "Primary",
        }
    }
})
