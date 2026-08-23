--// ============================================
--         冰缝合脚本 V2.1 - iOS 玻璃风格
--   玩家进出提示：右侧滑出 → 左侧平滑消失
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
local TabNotify  = Window:CreateTab("进出提示")
local TabAbout   = Window:CreateTab("关于脚本")

--// ===== 3. 主页 =====
TabHome:CreateSection("作者信息")
TabHome:CreateLabel("作者：榆")
TabHome:CreateParagraph({ Title = "关于作者", Content = "本脚本由 榆 开发，仅供学习交流使用。" })

--// ===== 4. 游戏脚本 =====
TabGame:CreateSection("动物医院")
TabGame:CreateButton({
    Name = "动物医院",
    Callback = function()
        Rayfield:Notify({ Title="加载中", Content="正在加载动物医院脚本...", Duration=3 })
        local s, err = pcall(function()
            script_key = "umjjkMsWDMFEhzyhERlOwQihGFQYgGGp"
            loadstring(game:HttpGet("https://raw.githubusercontent.com/caomod2077/Script/refs/heads/main/FN_AnimalHospital.lua"))()
        end)
        Rayfield:Notify({ Title = s and "成功" or "失败", Content = s and "动物医院 加载成功！" or ("动物医院 加载失败："..tostring(err)), Duration = s and 3 or 5 })
    end
})

TabGame:CreateSection("RB脚本")
TabGame:CreateButton({
    Name = "RB脚本",
    Callback = function()
        Rayfield:Notify({ Title="加载中", Content="正在加载 RB脚本...", Duration=3 })
        local s, err = pcall(function()
            loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/a0502f7619e7a63fb0dabac96e425c21.lua"))()
        end)
        Rayfield:Notify({ Title = s and "成功" or "失败", Content = s and "RB脚本 加载成功！" or ("RB脚本 加载失败："..tostring(err)), Duration = s and 3 or 5 })
    end
})

TabGame:CreateSection("夜脚本")
TabGame:CreateButton({
    Name = "夜脚本",
    Callback = function()
        Rayfield:Notify({ Title="加载中", Content="正在加载夜脚本...", Duration=3 })
        local s, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ylt410/roblox-Script/refs/heads/main/yejiaoben"))()
        end)
        Rayfield:Notify({ Title = s and "成功" or "失败", Content = s and "夜脚本 加载成功！" or ("夜脚本 加载失败："..tostring(err)), Duration = s and 3 or 5 })
    end
})

TabGame:CreateSection("叶脚本")
TabGame:CreateButton({
    Name = "叶脚本",
    Callback = function()
        Rayfield:Notify({ Title="加载中", Content="正在加载叶脚本...", Duration=3 })
        local s, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/roblox-ye/QQ515966991/refs/heads/main/ROBLOX-CNVIP-XIAOYE.lua"))()
        end)
        Rayfield:Notify({ Title = s and "成功" or "失败", Content = s and "叶脚本 加载成功！" or ("叶脚本 加载失败："..tostring(err)), Duration = s and 3 or 5 })
    end
})

--// ============================================
--   5. iOS 玻璃风格 - 玩家进出提示
-- ============================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- 新增：Lighting / 设备检测 / 全局 Blur 管理
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local isMobile = UserInputService.TouchEnabled

-- 全局 Blur 管理（避免频繁开关）
local blur = Lighting:FindFirstChildOfClass("BlurEffect")
if not blur then
    blur = Instance.new("BlurEffect")
    blur.Parent = Lighting
    blur.Size = 0
end
local activeBlurCount = 0
local function enableGlobalBlur()
    if activeBlurCount == 0 then
        local target = isMobile and 4 or 8
        TweenService:Create(blur, TweenInfo.new(0.35, Enum.EasingStyle.Sine), { Size = target }):Play()
    end
    activeBlurCount = activeBlurCount + 1
end
local function disableGlobalBlur()
    activeBlurCount = math.max(0, activeBlurCount - 1)
    if activeBlurCount == 0 then
        TweenService:Create(blur, TweenInfo.new(0.35, Enum.EasingStyle.Sine), { Size = 0 }):Play()
    end
end

-- 配置
local NotifyEnabled   = true
local MaxNotices      = 5
local NoticeDuration  = 3.0
local activeNotices   = {}

-- 颜色方案（iOS 风格）
local COLORS = {
    JoinBG    = Color3.fromRGB(48, 209, 88),    -- iOS Green
    LeaveBG   = Color3.fromRGB(255, 59, 48),    -- iOS Red
    GlassTint = Color3.fromRGB(255, 255, 255),  -- 白色玻璃
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

-- 可选：噪点贴图的 asset id（上传后填入），在手机上建议保守使用
local NOISE_ASSET_ID = nil

-- 创建模糊背景（模拟 iOS 毛玻璃） - 改良版
local function createBlurBackground(parent, tintColor)
    -- 主模糊/色调层（半透明）
    local blurFrame = Instance.new("Frame")
    blurFrame.Size = UDim2.new(1, 0, 1, 0)
    blurFrame.BackgroundColor3 = tintColor
    blurFrame.BackgroundTransparency = 0.78
    blurFrame.BorderSizePixel = 0
    blurFrame.Parent = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 16)
    c.Parent = blurFrame

    -- 细边（切边高光）
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = Color3.new(1, 1, 1)
    stroke.Transparency = 0.85
    stroke.Parent = blurFrame

    -- 顶部高光（渐变条）——加强玻璃光泽感
    local gloss = Instance.new("Frame")
    gloss.Size = UDim2.new(1, -8, 0, 10)
    gloss.Position = UDim2.new(0, 4, 0, 6)
    gloss.BackgroundColor3 = Color3.new(1, 1, 1)
    gloss.BackgroundTransparency = 0.92
    gloss.BorderSizePixel = 0
    gloss.ZIndex = blurFrame.ZIndex + 1
    gloss.Parent = parent

    local gCorner = Instance.new("UICorner")
    gCorner.CornerRadius = UDim.new(0, 10)
    gCorner.Parent = gloss

    local gGrad = Instance.new("UIGradient")
    gGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))
    }
    gGrad.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.88),
        NumberSequenceKeypoint.new(1, 1.0)
    }
    gGrad.Rotation = 90
    gGrad.Parent = gloss

    -- 半透明覆盖层（增强玻璃厚度感）
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

    -- 轻微投影（放在 card 下层并略偏移以模拟浮起）
    local shadow = Instance.new("Frame")
    shadow.Size = UDim2.new(1, 6, 1, 6)
    shadow.Position = UDim2.new(0, -3, 0, -3)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.92
    shadow.BorderSizePixel = 0
    shadow.ZIndex = blurFrame.ZIndex - 1
    shadow.Parent = parent

    local sc = Instance.new("UICorner")
    sc.CornerRadius = UDim.new(0, 18)
    sc.Parent = shadow

    -- 可选：微弱噪点层（需要上传到 Roblox 并替换 NOISE_ASSET_ID）
    if NOISE_ASSET_ID and NOISE_ASSET_ID ~= "" then
        local noise = Instance.new("ImageLabel")
        noise.Size = UDim2.new(2, 0, 2, 0)
        noise.Position = UDim2.new(-0.5, 0, -0.5, 0)
        noise.BackgroundTransparency = 1
        noise.Image = "rbxassetid://" .. NOISE_ASSET_ID
        noise.ImageTransparency = 0.9
        noise.ScaleType = Enum.ScaleType.Tile
        noise.ZIndex = blurFrame.ZIndex + 1
        noise.Parent = blurFrame

        spawn(function()
            while noise.Parent do
                for i = 0, 1, 0.01 do
                    noise.ImageRectOffset = Vector2.new(i*200, i*200)
                    wait(isMobile and 0.06 or 0.03)
                end
                for i = 1, 0, -0.01 do
                    noise.ImageRectOffset = Vector2.new(i*200, i*200)
                    wait(isMobile and 0.06 or 0.03)
                end
            end
        end)
    end

    return blurFrame
end

-- 创建单条提示
local function createNotice(plrName, isJoin)
    if not NotifyEnabled then return end

    -- 超过上限移除最旧
    if #activeNotices >= MaxNotices then
        local oldest = table.remove(activeNotices, 1)
        if oldest and oldest.Parent then oldest:Destroy() end
    end

    -- === 主卡片 ===
    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, 280, 0, 56)
    card.BackgroundTransparency = 1  -- 由子元素负责视觉
    card.BorderSizePixel = 0
    card.ClipsDescendants = true
    card.LayoutOrder = tick()
    card.Parent = RightContainer

    -- 圆角
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 16)
    cardCorner.Parent = card

    -- 玻璃背景（带色调）
    local tintColor = isJoin and Color3.fromRGB(48, 209, 88) or Color3.fromRGB(255, 59, 48)
    createBlurBackground(card, tintColor)

    -- === 左侧色条（iOS 风格细条）===
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

    -- === 文字容器 ===
    local textX = 28
    local textW = 280 - textX - 16

    -- 标题
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

    -- 玩家名
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

    -- === 右侧时间小圆点（装饰）===
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

    -- 初始状态：在屏幕右侧外面
    card.Position = UDim2.new(0, 300, 0, 0)

    table.insert(activeNotices, card)

    -- ========== 动画 ==========

    -- 缓动函数
    local EASE_OUT  = Enum.EasingStyle.Quart
    local EASE_IN   = Enum.EasingStyle.Quart
    local EASE_SMOOTH = Enum.EasingStyle.Sine

    -- ① 滑入：从右侧进入到位
    TweenService:Create(card, TweenInfo.new(0.45, EASE_OUT, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0)
    }):Play()

    -- 启用全局模糊（引用计数）
    enableGlobalBlur()

    -- 文字淡入（稍微延迟一点，更自然）
    TweenService:Create(title, TweenInfo.new(0.35, EASE_SMOOTH), {
        TextTransparency = 0
    }):Play()
    TweenService:Create(nameLabel, TweenInfo.new(0.35, EASE_SMOOTH), {
        TextTransparency = 0
    }):Play()
    TweenService:Create(dot, TweenInfo.new(0.35, EASE_SMOOTH), {
        BackgroundTransparency = 0.3
    }):Play()

    -- ② 停留后：向左平滑滑出 + 渐隐
    task.delay(NoticeDuration, function()
        -- 卡片整体左移 + 透明
        TweenService:Create(card, TweenInfo.new(0.7, EASE_IN, Enum.EasingDirection.InOut), {
            Position = UDim2.new(0, -300, 0, 0),  -- 向左滑出屏幕
        }):Play()

        -- 文字渐隐
        TweenService:Create(title, TweenInfo.new(0.6, EASE_SMOOTH), {
            TextTransparency = 1
        }):Play()
        TweenService:Create(nameLabel, TweenInfo.new(0.6, EASE_SMOOTH), {
            TextTransparency = 1
        }):Play()
        TweenService:Create(dot, TweenInfo.new(0.5, EASE_SMOOTH), {
            BackgroundTransparency = 1
        }):Play()

        -- 卡片整体透明度也渐隐（玻璃效果慢慢消失）
        for _, child in ipairs(card:GetChildren()) do
            if child:IsA("Frame") then
                TweenService:Create(child, TweenInfo.new(0.6, EASE_SMOOTH), {
                    BackgroundTransparency = child.BackgroundTransparency + 0.25
                }):Play()
            end
        end

        -- 在销毁前少���延迟然后关闭模糊（保持平滑过渡）
        task.delay(0.9, function()
            disableGlobalBlur()
        end)

        -- 销毁
        task.delay(0.8, function()
            if card and card.Parent then
                card:Destroy()
            end
            for i, v in ipairs(activeNotices) do
                if v == card then
                    table.remove(activeNotices, i)
                    break
                end
            end
        end)
    end)
end

-- 监听玩家进出
Players.PlayerAdded:Connect(function(plr)
    if plr == player then return end
    createNotice(plr.Name, true)
end)

Players.PlayerRemoving:Connect(function(plr)
    if plr == player then return end
    createNotice(plr.Name, false)
end)

-- 已在服务器玩家
task.defer(function()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            createNotice(plr.Name, true)
        end
    end
end)

--// ===== 6. 进出提示设置页 =====
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

TabNotify:CreateSection("🧪 测试")

TabNotify:CreateButton({
    Name = "测试 - 玩家加入",
    Callback = function()
        createNotice("TestPlayer_Join", true)
    end
})

TabNotify:CreateButton({
    Name = "测试 - 玩家离开",
    Callback = function()
        createNotice("TestPlayer_Leave", false)
    end
})

--// ===== 7. 关于脚本 =====
TabAbout:CreateSection("脚本信息")
TabAbout:CreateParagraph({ Title = "冰缝合脚本 V2.1", Content = "iOS 玻璃风格玩家进出提示，右侧滑出、左侧平滑消失。" })
TabAbout:CreateLabel("开发者：榆 QQ3347313900")
TabAbout:CreateLabel("版本：V2.1")
TabAbout:CreateLabel("风格：iOS Glassmorphism")
TabAbout:CreateSection("系统")
TabAbout:CreateButton({ Name = "关闭 UI", Callback = function() Rayfield:Destroy() end })
TabAbout:CreateToggle({ Name = "开关五", CurrentValue = false, Callback = function() end })
