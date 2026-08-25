--// ============================================
--     冰缝合脚本 V2.3 - Rayfield 整合版
--   iOS 玻璃提示 + 激光射线 + 全功能
-- ============================================

--// ===== 1. 加载 Rayfield =====
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success or not Rayfield then
    Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua', true))()
end

if not Rayfield then
    warn("Rayfield 加载失败")
    return
end

local Window = Rayfield:CreateWindow({
    Name = "冰缝合脚本",
    LoadingTitle = "冰缝合脚本",
    LoadingSubtitle = "加载中...",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local TabHome   = Window:CreateTab("主页")
local TabNotify = Window:CreateTab("进出提示")
local TabCombat = Window:CreateTab("战斗")
local TabMove   = Window:CreateTab("移动")
local TabAbout  = Window:CreateTab("关于")

--// ===== 2. iOS 玻璃玩家进出提示（你原来的，完整保留）=====
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local NotifyEnabled = true
local MaxNotices = 5
local NoticeDuration = 3
local activeNotices = {}

local COLORS = {
    JoinBG = Color3.fromRGB(48,209,88),
    LeaveBG = Color3.fromRGB(255,59,48),
    GlassTint = Color3.fromRGB(255,255,255),
    Text = Color3.fromRGB(255,255,255),
    SubText = Color3.fromRGB(230,230,230),
}

local NotifyGui = Instance.new("ScreenGui", PlayerGui)
NotifyGui.Name = "iOSNotifyGui"
NotifyGui.ResetOnSpawn = false

local RightContainer = Instance.new("Frame", NotifyGui)
RightContainer.Size = UDim2.new(0,300,1,-60)
RightContainer.Position = UDim2.new(1,-310,0,30)
RightContainer.BackgroundTransparency = 1
RightContainer.ClipsDescendants = true

local UIList = Instance.new("UIListLayout", RightContainer)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0,12)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Right

local function createBlurBackground(parent, tint)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1,0,1,0)
    f.BackgroundColor3 = tint
    f.BackgroundTransparency = 0.75
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,16)

    local o = Instance.new("Frame", parent)
    o.Size = UDim2.new(1,0,0.5,0)
    o.BackgroundColor3 = Color3.new(1,1,1)
    o.BackgroundTransparency = 0.88
    Instance.new("UICorner", o).CornerRadius = UDim.new(0,16)
end

local function createNotice(name, join)
    if not NotifyEnabled then return end
    if #activeNotices >= MaxNotices then
        activeNotices[1]:Destroy()
        table.remove(activeNotices,1)
    end

    local card = Instance.new("Frame", RightContainer)
    card.Size = UDim2.new(0,280,0,56)
    card.BackgroundTransparency = 1
    card.ClipsDescendants = true
    createBlurBackground(card, join and COLORS.JoinBG or COLORS.LeaveBG)

    local title = Instance.new("TextLabel", card)
    title.Text = join and "玩家加入" or "玩家离开"
    title.TextColor3 = COLORS.Text
    title.Font = Enum.Font.GothamSemibold
    title.TextSize = 15
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0,28,0,8)
    title.Size = UDim2.new(0,200,0,22)

    local nameL = Instance.new("TextLabel", card)
    nameL.Text = name
    nameL.TextColor3 = COLORS.SubText
    nameL.Font = Enum.Font.Gotham
    nameL.TextSize = 13
    nameL.BackgroundTransparency = 1
    nameL.Position = UDim2.new(0,28,0,30)
    nameL.Size = UDim2.new(0,200,0,18)

    card.Position = UDim2.new(0,300,0,0)
    table.insert(activeNotices, card)

    TweenService:Create(card, TweenInfo.new(0.45, Enum.EasingStyle.Quart), {Position = UDim2.new(0,0,0,0)}):Play()

    task.delay(NoticeDuration, function()
        TweenService:Create(card, TweenInfo.new(0.7, Enum.EasingStyle.Quart), {Position = UDim2.new(0,-300,0,0)}):Play()
        task.delay(0.8, function()
            card:Destroy()
            for i,v in ipairs(activeNotices) do if v==card then table.remove(activeNotices,i) break end end
        end)
    end)
end

Players.PlayerAdded:Connect(function(p) if p~=player then createNotice(p.Name,true) end end)
Players.PlayerRemoving:Connect(function(p) if p~=player then createNotice(p.Name,false) end end)

--// ===== 3. 激光射线系统（完整保留）=====
local RS = game:GetService("RunService")
local lp = player
local char, root, hum
local laserOn = false
local lpL, lpR

local function getChar()
    char = lp.Character or lp.CharacterAdded:Wait()
    root = char:WaitForChild("HumanoidRootPart")
    hum = char:WaitForChild("Humanoid")
end
getChar()
lp.CharacterAdded:Connect(getChar)

local function createLaserPart()
    local p = Instance.new("Part")
    p.Size = Vector3.new(1.5,1.5,0.2)
    p.Anchored = true
    p.CanCollide = false
    p.Material = Enum.Material.Neon
    p.Color = Color3.fromRGB(255,0,0)
    p.Transparency = 0.2
    p.Parent = workspace
    return p
end

local function updateLaser()
    if not root then return end
    local cam = workspace.CurrentCamera
    local dir = cam.CFrame.LookVector
    local oL = root.Position + Vector3.new(-0.6,1.5,0)
    local oR = root.Position + Vector3.new(0.6,1.5,0)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {char}

    local function ray(origin)
        local r = workspace:Raycast(origin, dir*800, params)
        return r and (origin - r.Position).Magnitude or 800
    end

    local dL, dR = ray(oL), ray(oR)

    local function draw(p, o, d)
        if not p then return end
        p.Size = Vector3.new(1.5,1.5,d)
        p.CFrame = CFrame.lookAt(o + dir*(d/2), o + dir*d)
    end

    draw(lpL, oL, dL)
    draw(lpR, oR, dR)
end

--// ===== 4. Rayfield UI 功能绑定 =====

-- 进出提示设置
TabNotify:CreateToggle({
    Name = "启用进出提示",
    CurrentValue = true,
    Callback = function(v) NotifyEnabled = v end
})

TabNotify:CreateSlider({
    Name = "提示停留时间",
    Range = {1,8},
    Increment = 0.5,
    CurrentValue = 3,
    Callback = function(v) NoticeDuration = v end
})

-- 战斗页
TabCombat:CreateToggle({
    Name = "激光射线",
    CurrentValue = false,
    Callback = function(v)
        laserOn = v
        if v then
            lpL = createLaserPart()
            lpR = createLaserPart()
            RS.RenderStepped:Connect(function()
                if laserOn then updateLaser() end
            end)
        else
            if lpL then lpL:Destroy() end
            if lpR then lpR:Destroy() end
        end
    end
})

TabCombat:CreateToggle({
    Name = "防传送",
    CurrentValue = false,
    Callback = function(v)
        if v then
            RS.Heartbeat:Connect(function()
                if root then
                    root.AssemblyLinearVelocity = Vector3.zero
                end
            end)
        end
    end
})

-- 移动页
TabMove:CreateToggle({
    Name = "飞行（简易）",
    CurrentValue = false,
    Callback = function(v)
        if hum then hum.PlatformStand = v end
    end
})

-- 关于
TabAbout:CreateParagraph({
    Title = "冰缝合脚本 V2.3",
    Content = "Rayfield 整合版\n作者：榆\n功能：iOS 玻璃提示 + 激光射线 + 战斗 + 移动"
})

TabAbout:CreateButton({
    Name = "关闭脚本",
    Callback = function()
        Rayfield:Destroy()
    end
})
