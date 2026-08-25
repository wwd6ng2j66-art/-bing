--// ============================================
--     冰缝合脚本 V2.6 - 修复版
--  修复：伤害单次/眼睛射线/手机飞行
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
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
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
        if activeNotices[1] then activeNotices[1]:Destroy() end
        table.remove(activeNotices, 1)
    end
    local card = Instance.new("Frame", RightContainer)
    card.Size = UDim2.new(0,280,0,56)
    card.BackgroundTransparency = 1
    card.ClipsDescendants = true
    card.LayoutOrder = tick()

    local bg = Instance.new("Frame", card)
    bg.Size = UDim2.new(1,0,1,0)
    bg.BackgroundColor3 = join and COLORS.JoinBG or COLORS.LeaveBG
    bg.BackgroundTransparency = 0.75
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0,16)

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

--// ===== 3. 角色 =====
local char, root, head, hum
local function onChar(c)
    char = c
    root = c:WaitForChild("HumanoidRootPart")
    hum = c:WaitForChild("Humanoid")
    head = c:WaitForChild("Head")
end
if player.Character then onChar(player.Character) end
player.CharacterAdded:Connect(onChar)

--// ===== 4. 激光射线（从眼睛射出 + 稳定伤害）=====
local laserOn = false
local laserColor = Color3.fromRGB(255,0,0)
local laserDamage = 20
local laserRange = 800
local dmgCooldown = 0.5

-- 用细长 Part 做射线，两根（双眼）
local function makeRayPart()
    local p = Instance.new("Part")
    p.Size = Vector3.new(0.25, 0.25, 1)
    p.Anchored = true
    p.CanCollide = false
    p.Material = Enum.Material.Neon
    p.Color = laserColor
    p.Transparency = 0.15
    p.Parent = workspace
    return p
end

local rayL, rayR
local lastDmg = {} -- [humanoid] = tick

local function drawRay(p, origin, hitPos)
    if not p then return end
    local dir = (hitPos - origin)
    local dist = dir.Magnitude
    if dist < 0.1 then p.Transparency = 1; return end
    p.Transparency = 0.15
    p.Size = Vector3.new(0.25, 0.25, dist)
    p.CFrame = CFrame.lookAt(origin + dir*0.5, hitPos)
end

local function tryDamage(targetModel, hitPos)
    if not targetModel then return end
    local h = targetModel:FindFirstChild("Humanoid")
    if not h or not h:IsA("Humanoid") then return end
    if h.Health <= 0 then return end -- 已死亡不再伤害
    if targetModel == char then return end -- 不伤自己
    local now = tick()
    if lastDmg[h] and now - lastDmg[h] < dmgCooldown then return end
    lastDmg[h] = now
    -- 飘字
    local bg = Instance.new("BillboardGui")
    bg.Size = UDim2.new(0,90,0,45)
    bg.AlwaysOnTop = true
    bg.Parent = workspace
    local lbl = Instance.new("TextLabel", bg)
    lbl.Size = UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "-" .. tostring(laserDamage)
    lbl.TextColor3 = Color3.fromRGB(255,40,40)
    lbl.TextScaled = true
    lbl.Font = Enum.Font.GothamBlack
    local att = Instance.new("Attachment", workspace)
    att.WorldPosition = hitPos + Vector3.new(0, 1.2, 0)
    bg.Parent = att
    game:GetService("Debris"):AddItem(bg, 0.9)
    game:GetService("Debris"):AddItem(att, 0.9)
    -- 伤害（客户端；服务端保护时仅对 NPC/无保护目标生效）
    pcall(function() h:TakeDamage(laserDamage) end)
    -- 击退
    local hrp = targetModel:FindFirstChild("HumanoidRootPart")
    if hrp then
        local push = (hrp.Position - (root and root.Position or hitPos)).Unit * 180 + Vector3.new(0,90,0)
        pcall(function() hrp.AssemblyLinearVelocity = push end)
    end
end

local function updateLasers()
    if not (char and root and head and hum) then return end
    local cam = workspace.CurrentCamera
    local look = cam.CFrame.LookVector
    -- 眼睛位置：头部前向稍前
    local headPos = head.Position
    local eyeOff = head.CFrame:VectorToWorldSpace(Vector3.new(0, 0.25, -0.3))
    local origin = headPos + eyeOff
    -- 双眼左右微偏
    local right = cam.CFrame.RightVector
    local oL = origin - right * 0.35
    local oR = origin + right * 0.35

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {char}

    local function cast(o)
        local r = workspace:Raycast(o, look * laserRange, params)
        return r
    end
    local rL = cast(oL)
    local rR = cast(oR)

    drawRay(rayL, oL, rL and rL.Position or (oL + look * laserRange))
    drawRay(rayR, oR, rR and rR.Position or (oR + look * laserRange))

    if rL then tryDamage(rL.Instance:FindFirstAncestorOfClass("Model"), rL.Position) end
    if rR then tryDamage(rR.Instance:FindFirstAncestorOfClass("Model"), rR.Position) end
end

--// ===== 5. 飞行（响应手机移动摇杆 + PC WASD）=====
local flying = false
local flySpeed = 50
local bodyVel, bodyGyro
local flyUp = 0

local function setFlying(v)
    flying = v
    if v then
        if not (char and root and hum) then flying = false; return end
        hum.PlatformStand = true
        bodyVel = Instance.new("BodyVelocity", root)
        bodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bodyVel.Velocity = Vector3.zero
        bodyGyro = Instance.new("BodyGyro", root)
        bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        bodyGyro.CFrame = root.CFrame
    else
        if bodyVel then bodyVel:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
        bodyVel, bodyGyro = nil, nil
        if hum then hum.PlatformStand = false end
    end
end

UIS.InputBegan:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.Space then flyUp = 1 end
    if i.KeyCode == Enum.KeyCode.LeftControl then flyUp = -1 end
end)
UIS.InputEnded:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.Space and flyUp == 1 then flyUp = 0 end
    if i.KeyCode == Enum.KeyCode.LeftControl and flyUp == -1 then flyUp = 0 end
end)

RS.Heartbeat:Connect(function(dt)
    if flying and char and root and hum then
        -- MoveDirection 会由手机虚拟摇杆 / PC WASD 自动填充（相对相机水平方向）
        local md = hum.MoveDirection
        local cam = workspace.CurrentCamera
        local look = cam.CFrame.LookVector
        local right = cam.CFrame.RightVector
        -- 将 MoveDirection 投影到相机水平面
        local move = Vector3.new(md.X, 0, md.Z)
        if move.Magnitude < 0.01 then move = Vector3.zero end
        local vert = flyUp
        -- 手机触屏点击上半屏可作为上升的额外方式已用空格/ctrl；移动键控制水平
        local vel = move * flySpeed + Vector3.new(0, vert * flySpeed, 0)
        if bodyVel then bodyVel.Velocity = vel end
        if bodyGyro then bodyGyro.CFrame = CFrame.lookAt(root.Position, root.Position + (move.Magnitude>0 and move or look)) end
    end
end)

--// ===== 6. Rayfield UI =====
TabNotify:CreateToggle({ Name = "启用进出提示", CurrentValue = true,
    Callback = function(v) NotifyEnabled = v end })
TabNotify:CreateSlider({ Name = "提示停留时间", Range = {1,8}, Increment = 0.5, CurrentValue = 3,
    Callback = function(v) NoticeDuration = v end })

TabCombat:CreateToggle({ Name = "激光射线(双眼)", CurrentValue = false,
    Callback = function(v)
        laserOn = v
        if v then
            rayL = makeRayPart(); rayR = makeRayPart()
            RS.RenderStepped:Connect(function()
                if laserOn then updateLasers() else if rayL then rayL.Transparency=1 end if rayR then rayR.Transparency=1 end end
            end)
        else
            if rayL then rayL:Destroy() rayL=nil end
            if rayR then rayR:Destroy() rayR=nil end
        end
    end })
TabCombat:CreateColorPicker({ Name = "激光颜色", Color = laserColor,
    Callback = function(c) laserColor = c; if rayL then rayL.Color=c end; if rayR then rayR.Color=c end end })
TabCombat:CreateSlider({ Name = "激光伤害", Range = {1,100}, Increment = 1, CurrentValue = laserDamage,
    Callback = function(v) laserDamage = v end })
TabCombat:CreateSlider({ Name = "激光射程", Range = {100,2000}, Increment = 50, CurrentValue = laserRange,
    Callback = function(v) laserRange = v end })

TabMove:CreateToggle({ Name = "飞行(手机摇杆/PC WASD)", CurrentValue = false,
    Callback = function(v) setFlying(v) end })
TabMove:CreateSlider({ Name = "飞行速度", Range = {10,200}, Increment = 5, CurrentValue = flySpeed,
    Callback = function(v) flySpeed = v end })
TabMove:CreateLabel("手机：使用屏幕左侧虚拟摇杆移动；PC：WASD。空格上升，左Ctrl下降。")

TabAbout:CreateParagraph({ Title = "冰缝合脚本 V2.6", Content = "修复：射线从眼睛射出 / 伤害仅一次修复 / 飞行响应手机移动键\n作者：榆" })
TabAbout:CreateButton({ Name = "关闭脚本", Callback = function() Rayfield:Destroy() end })

print("[冰缝合脚本] V2.6 加载完成")
