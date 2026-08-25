--// ============================================
--     冰缝合脚本 V2.5 - 修复版
--  修复：激光可见 / 伤害生效 / 飞行可移动
-- ============================================

--// ===== 1. 加载 Rayfield =====
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)
if not success or not Rayfield then
    Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua', true))()
end
if not Rayfield then warn("Rayfield 加载失败"); return end

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

--// ===== 2. iOS 玻璃玩家进出提示 =====
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
    table.insert(activeNotices, card)

    -- 玻璃背景
    local bg = Instance.new("Frame", card)
    bg.Size = UDim2.new(1,0,1,0)
    bg.BackgroundColor3 = join and COLORS.JoinBG or COLORS.LeaveBG
    bg.BackgroundTransparency = 0.72
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0,16)

    local overlay = Instance.new("Frame", card)
    overlay.Size = UDim2.new(1,0,0.5,0)
    overlay.BackgroundColor3 = Color3.new(1,1,1)
    overlay.BackgroundTransparency = 0.88
    Instance.new("UICorner", overlay).CornerRadius = UDim.new(0,16)

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

--// ===== 3. 角色引用 =====
local char, root, hum
local function getChar()
    char = player.Character or player.CharacterAdded:Wait()
    root = char:WaitForChild("HumanoidRootPart")
    hum  = char:WaitForChild("Humanoid")
end
getChar()
player.CharacterAdded:Connect(getChar)

--// ===== 4. 激光射线系统（V2.5 修复：用 BodyGyro+BodyVelocity 的 Part 激光） =====
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local laserOn = false
local laserColor = Color3.fromRGB(255, 0, 0)
local laserDamage = 25
local laserRange = 400
local hitCooldown = {}

-- 创建一根激光（细长 Part）
local function makeLaserPart()
    local p = Instance.new("Part")
    p.Size = Vector3.new(0.3, 0.3, 1)   -- 细长的棒，后面用 CFrame 拉伸
    p.Anchored = true
    p.CanCollide = false
    p.Material = Enum.Material.Neon
    p.Color = laserColor
    p.Transparency = 0.15
    p.Parent = workspace
    return p
end

local leftLaser, rightLaser

local function destroyLasers()
    if leftLaser then leftLaser:Destroy(); leftLaser = nil end
    if rightLaser then rightLaser:Destroy(); rightLaser = nil end
end

-- 把一根激光从 origin 沿 dir 方向拉伸到距离 d，命中则停
local function drawLaser(part, origin, dir, maxDist)
    if not part then return end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {char}
    local result = workspace:Raycast(origin, dir * maxDist, params)
    local dist = maxDist
    local hitPos = origin + dir * maxDist
    if result then
        dist = (origin - result.Position).Magnitude
        hitPos = result.Position
        -- 伤害判定
        local hitModel = result.Instance and result.Instance:FindFirstAncestorOfClass("Model")
        if hitModel and hitModel ~= char then
            local h = hitModel:FindFirstChildWhichIsA("Humanoid")
            if h and h ~= hum then
                local cdKey = hitModel
                if not hitCooldown[cdKey] or tick() - hitCooldown[cdKey] > 0.5 then
                    hitCooldown[cdKey] = tick()
                    -- 客户端伤害（对 NPC 有效；玩家是否被服务端接受取决于游戏）
                    local ok = pcall(function() h:TakeDamage(laserDamage) end)
                    -- 击退
                    local hrp = hitModel:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local force = (hrp.Position - origin).Unit * 60 + Vector3.new(0, 40, 0)
                        pcall(function() hrp.Velocity = force end)
                    end
                    -- 飘字
                    spawn(function() showDamageNumber(hitPos, laserDamage) end)
                end
            end
        end
    end
    -- 放置并拉伸 part：part 中心在 origin->hitPos 中点，朝向 hitPos
    local mid = (origin + hitPos) / 2
    part.CFrame = CFrame.lookAt(mid, hitPos) * CFrame.Angles(math.rad(90), 0, 0)
    part.Size = Vector3.new(0.35, 0.35, dist)
    part.Color = laserColor
end

-- 飘血数字
function showDamageNumber(pos, dmg)
    local bg = Instance.new("BillboardGui")
    bg.Size = UDim2.new(0, 90, 0, 45)
    bg.StudsOffset = Vector3.new(0, 2, 0)
    bg.AlwaysOnTop = true
    bg.Parent = workspace
    local lbl = Instance.new("TextLabel", bg)
    lbl.Size = UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "-" .. tostring(dmg)
    lbl.TextColor3 = Color3.fromRGB(255, 40, 40)
    lbl.TextScaled = true
    lbl.Font = Enum.Font.GothamBlack
    lbl.Parent = bg
    local att = Instance.new("Attachment", workspace)
    att.Position = pos
    bg.Parent = att
    -- 上浮动效
    spawn(function()
        for i = 1, 20 do
            att.Position = att.Position + Vector3.new(0, 0.08, 0)
            lbl.TextTransparency = i / 20
            wait(0.04)
        end
        bg:Destroy()
        att:Destroy()
    end)
end

-- 主循环
local laserConn
local function startLaser()
    if leftLaser or rightLaser then return end
    leftLaser = makeLaserPart()
    rightLaser = makeLaserPart()
    hitCooldown = {}
    laserConn = RS.RenderStepped:Connect(function()
        if not laserOn or not root then return end
        local cam = workspace.CurrentCamera
        local dir = cam.CFrame.LookVector
        local oL = root.Position + Vector3.new(-0.7, 1.4, 0)
        local oR = root.Position + Vector3.new( 0.7, 1.4, 0)
        drawLaser(leftLaser,  oL, dir, laserRange)
        drawLaser(rightLaser, oR, dir, laserRange)
    end)
end

local function stopLaser()
    laserOn = false
    if laserConn then laserConn:Disconnect(); laserConn = nil end
    destroyLasers()
end

--// ===== 5. 飞行系统（V2.5 修复：BodyVelocity 真正移动） =====
local flying = false
local flySpeed = 50
local bv, bg

local function startFly()
    if not root or not hum then return end
    hum.PlatformStand = true
    bv = Instance.new("BodyVelocity", root)
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.Velocity = Vector3.zero
    bg = Instance.new("BodyGyro", root)
    bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bg.CFrame = root.CFrame
    flying = true
end

local function stopFly()
    flying = false
    if bv then bv:Destroy(); bv = nil end
    if bg then bg:Destroy(); bg = nil end
    if hum then hum.PlatformStand = false end
end

-- 飞行移动输入（每帧）
RS.RenderStepped:Connect(function(dt)
    if not flying or not root or not bv then return end
    local cam = workspace.CurrentCamera
    local move = Vector3.zero
    if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0,1,0) end
    if move.Magnitude > 0 then move = move.Unit * flySpeed end
    bv.Velocity = move
    bg.CFrame = cam.CFrame * CFrame.Angles(math.rad(-cam.CFrame.LookVector.Y*0), 0, 0)
end)

--// ===== 6. Rayfield UI =====

-- 主页
TabHome:CreateSection("作者信息")
TabHome:CreateLabel("作者：榆")
TabHome:CreateParagraph({ Title = "关于", Content = "冰缝合脚本 V2.5 - 修复版\n激光射线 / 飞行 / 玩家进出提示" })

-- 进出提示
TabNotify:CreateSection("提示设置")
TabNotify:CreateToggle({
    Name = "启用进出提示", CurrentValue = true,
    Callback = function(v) NotifyEnabled = v end
})
TabNotify:CreateSlider({
    Name = "提示停留时间(秒)", Range = {1,8}, Increment = 0.5, CurrentValue = 3,
    Callback = function(v) NoticeDuration = v end
})
TabNotify:CreateButton({ Name = "测试 - 玩家加入", Callback = function() createNotice("TestPlayer", true) end })
TabNotify:CreateButton({ Name = "测试 - 玩家离开", Callback = function() createNotice("TestPlayer", false) end })

-- 战斗
TabCombat:CreateSection("激光射线")
TabCombat:CreateToggle({
    Name = "开启激光", CurrentValue = false,
    Callback = function(v)
        laserOn = v
        if v then startLaser() else stopLaser() end
    end
})
TabCombat:CreateColorPicker({
    Name = "激光颜色", Color = laserColor,
    Callback = function(c) laserColor = c end
})
TabCombat:CreateSlider({
    Name = "激光伤害", Range = {1,100}, Increment = 1, CurrentValue = laserDamage,
    Callback = function(v) laserDamage = v end
})
TabCombat:CreateSlider({
    Name = "激光射程", Range = {50,1000}, Increment = 10, CurrentValue = laserRange,
    Callback = function(v) laserRange = v end
})

TabCombat:CreateSection("防御")
TabCombat:CreateToggle({
    Name = "防传送(简易)", CurrentValue = false,
    Callback = function(v)
        if v then
            spawn(function()
                while v and wait(0.1) do
                    if root then root.AssemblyLinearVelocity = Vector3.zero end
                end
            end)
        end
    end
})

-- 移动
TabMove:CreateSection("飞行控制")
TabMove:CreateToggle({
    Name = "开启飞行", CurrentValue = false,
    Callback = function(v)
        if v then startFly() else stopFly() end
    end
})
TabMove:CreateSlider({
    Name = "飞行速度", Range = {10,200}, Increment = 5, CurrentValue = flySpeed,
    Callback = function(v) flySpeed = v end
})
TabMove:CreateLabel("WASD 移动 | 空格上升 | Ctrl 下降")

-- 关于
TabAbout:CreateParagraph({ Title = "冰缝合脚本 V2.5", Content = "修复：激光可见射线 / 命中伤害+飘字 / 飞行可自由移动" })
TabAbout:CreateLabel("开发者：榆")
TabAbout:CreateButton({ Name = "关闭脚本", Callback = function()
    stopLaser(); stopFly(); Rayfield:Destroy()
end })

-- 初始化提示
createNotice("冰缝合脚本已加载", true)
