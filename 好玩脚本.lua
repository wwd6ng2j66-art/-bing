--// ============================================
--     冰缝合脚本 V2.4 - Rayfield 整合版
--   iOS 玻璃提示 + 双手激光射线(可见/伤害/飘字)
--   + 飞行(开启后弹出速度调节)
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

--// ===== 2. 服务与局部玩家 =====
local Players    = game:GetService("Players")
local TweenSrv   = game:GetService("TweenService")
local RunSrv     = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local Debris     = game:GetService("Debris")

local lp        = Players.LocalPlayer
local PlayerGui = lp:WaitForChild("PlayerGui")

--// ===== 3. iOS 玻璃风格 - 玩家进出提示 =====
local NotifyEnabled  = true
local MaxNotices     = 5
local NoticeDuration = 3
local activeNotices  = {}

local COLORS = {
    JoinBG    = Color3.fromRGB(48,209,88),
    LeaveBG   = Color3.fromRGB(255,59,48),
    GlassTint = Color3.fromRGB(255,255,255),
    Text      = Color3.fromRGB(255,255,255),
    SubText   = Color3.fromRGB(230,230,230),
}

local NotifyGui = Instance.new("ScreenGui", PlayerGui)
NotifyGui.Name = "iOSNotifyGui"
NotifyGui.ResetOnSpawn = false
NotifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local RightContainer = Instance.new("Frame", NotifyGui)
RightContainer.Size = UDim2.new(0,300,1,-60)
RightContainer.Position = UDim2.new(1,-310,0,30)
RightContainer.BackgroundTransparency = 1
RightContainer.ClipsDescendants = true

local UIList = Instance.new("UIListLayout", RightContainer)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0,12)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Right
UIList.VerticalAlignment = Enum.VerticalAlignment.Top

local function createBlurBackground(parent, tint)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1,0,1,0)
    f.BackgroundColor3 = tint
    f.BackgroundTransparency = 0.72
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
        local old = table.remove(activeNotices,1)
        if old and old.Parent then old:Destroy() end
    end
    local card = Instance.new("Frame", RightContainer)
    card.Size = UDim2.new(0,280,0,56)
    card.BackgroundTransparency = 1
    card.ClipsDescendants = true
    card.LayoutOrder = tick()
    createBlurBackground(card, join and COLORS.JoinBG or COLORS.LeaveBG)

    local title = Instance.new("TextLabel", card)
    title.Text = join and "玩家加入" or "玩家离开"
    title.TextColor3 = COLORS.Text
    title.Font = Enum.Font.GothamSemibold
    title.TextSize = 15
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0,28,0,8)
    title.Size = UDim2.new(0,220,0,22)
    title.TextTransparency = 1

    local nameL = Instance.new("TextLabel", card)
    nameL.Text = name
    nameL.TextColor3 = COLORS.SubText
    nameL.Font = Enum.Font.Gotham
    nameL.TextSize = 13
    nameL.BackgroundTransparency = 1
    nameL.Position = UDim2.new(0,28,0,30)
    nameL.Size = UDim2.new(0,220,0,18)
    nameL.TextTransparency = 1

    card.Position = UDim2.new(0,300,0,0)
    table.insert(activeNotices, card)

    TweenSrv:Create(card, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position=UDim2.new(0,0,0,0)}):Play()
    TweenSrv:Create(title, TweenInfo.new(0.35, Enum.EasingStyle.Sine), {TextTransparency=0}):Play()
    TweenSrv:Create(nameL, TweenInfo.new(0.35, Enum.EasingStyle.Sine), {TextTransparency=0}):Play()

    task.delay(NoticeDuration, function()
        TweenSrv:Create(card, TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {Position=UDim2.new(0,-300,0,0)}):Play()
        TweenSrv:Create(title, TweenInfo.new(0.6, Enum.EasingStyle.Sine), {TextTransparency=1}):Play()
        TweenSrv:Create(nameL, TweenInfo.new(0.6, Enum.EasingStyle.Sine), {TextTransparency=1}):Play()
        task.delay(0.8, function()
            if card and card.Parent then card:Destroy() end
            for i,v in ipairs(activeNotices) do if v==card then table.remove(activeNotices,i); break end end
        end)
    end)
end

Players.PlayerAdded:Connect(function(p) if p~=lp then createNotice(p.Name,true) end end)
Players.PlayerRemoving:Connect(function(p) if p~=lp then createNotice(p.Name,false) end end)
task.defer(function()
    for _,p in ipairs(Players:GetPlayers()) do if p~=lp then createNotice(p.Name,true) end end
end)

--// ===== 4. 角色引用 =====
local char, root, hum
local function bindChar(c)
    char = c
    root = c:WaitForChild("HumanoidRootPart")
    hum  = c:WaitForChild("Humanoid")
end
if lp.Character then bindChar(lp.Character) end
lp.CharacterAdded:Connect(bindChar)

--// ===== 5. 飘字伤害数字 =====
local function spawnDamageNumber(pos, amount)
    local bg = Instance.new("BillboardGui")
    bg.Size = UDim2.new(0,90,0,40)
    bg.StudsOffset = Vector3.new(0,2,0)
    bg.AlwaysOnTop = true
    bg.Parent = workspace

    local lbl = Instance.new("TextLabel", bg)
    lbl.Size = UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "-"..tostring(amount)
    lbl.TextColor3 = Color3.fromRGB(255,40,40)
    lbl.TextScaled = true
    lbl.Font = Enum.Font.GothamBlack
    lbl.Parent = bg

    local att = Instance.new("Attachment", workspace)
    att.Position = pos
    bg.Parent = att

    TweenSrv:Create(lbl, TweenInfo.new(0.7, Enum.EasingStyle.Sine), {TextTransparency=1}):Play()
    Debris:AddItem(bg, 0.9)
    Debris:AddItem(att, 0.9)
end

--// ===== 6. 激光射线系统 =====
local laserOn     = false
local laserColor  = Color3.fromRGB(255,0,0)
local laserDamage = 25
local laserRange  = 600
local leftBeam, rightBeam
local leftAtt0, leftAtt1, rightAtt0, rightAtt1
local beamConn

local function makeBeam(originAttach, color)
    local beam = Instance.new("Beam")
    beam.Color = ColorSequence.new(color)
    beam.Transparency = NumberSequence.new(0.15)
    beam.Width0 = 1.2
    beam.Width1 = 1.2
    beam.FaceCamera = true
    beam.LightInfluence = 0
    beam.Parent = workspace
    return beam
end

local function destroyBeams()
    if leftBeam  then leftBeam:Destroy()  leftBeam=nil  end
    if rightBeam then rightBeam:Destroy() rightBeam=nil end
    if leftAtt0  then leftAtt0:Destroy()  leftAtt0=nil  end
    if leftAtt1  then leftAtt1:Destroy()  leftAtt1=nil  end
    if rightAtt0 then rightAtt0:Destroy() rightAtt0=nil end
    if rightAtt1 then rightAtt1:Destroy() rightAtt1=nil end
end

-- 对命中的 Humanoid 造成伤害(服务端需 RemoteEvent 时才生效，这里直接对本地可访问 Humanoid 扣血)
local dmgCooldown = {}
local function applyDamage(humanoid, model, hitPos)
    if not humanoid or humanoid.Health <= 0 then return end
    if dmgCooldown[humanoid] and tick()-dmgCooldown[humanoid] < 0.4 then return end
    dmgCooldown[humanoid] = tick()
    humanoid:TakeDamage(laserDamage)
    spawnDamageNumber(hitPos, laserDamage)
    -- 击退
    local hrp = model:FindFirstChild("HumanoidRootPart")
    if hrp and root then
        local dir = (hrp.Position - root.Position).Unit
        hrp.Velocity = dir*180 + Vector3.new(0,90,0)
    end
end

local function rayHit(origin, dir, range)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = char and {char} or {}
    local result = workspace:Raycast(origin, dir*range, params)
    return result
end

local function updateLaser()
    if not root or not char then return end
    local cam = workspace.CurrentCamera
    local dir = cam.CFrame.LookVector
    local oL = root.Position + Vector3.new(-0.6, 1.4, 0)
    local oR = root.Position + Vector3.new( 0.6, 1.4, 0)

    local rL = rayHit(oL, dir, laserRange)
    local rR = rayHit(oR, dir, laserRange)

    local endL = rL and rL.Position or (oL + dir*laserRange)
    local endR = rR and rR.Position or (oR + dir*laserRange)

    if leftAtt0 and leftAtt1 then
        leftAtt0.WorldPosition  = oL
        leftAtt1.WorldPosition  = endL
    end
    if rightAtt0 and rightAtt1 then
        rightAtt0.WorldPosition = oR
        rightAtt1.WorldPosition = endR
    end

    -- 命中处理
    if rL then
        local m = rL.Instance and rL.Instance:FindFirstAncestorOfClass("Model")
        if m and m~=char and m:FindFirstChild("Humanoid") then
            applyDamage(m.Humanoid, m, rL.Position)
        end
    end
    if rR then
        local m = rR.Instance and rR.Instance:FindFirstAncestorOfClass("Model")
        if m and m~=char and m:FindFirstChild("Humanoid") then
            applyDamage(m.Humanoid, m, rR.Position)
        end
    end
end

local function setLaser(on)
    laserOn = on
    if on then
        leftAtt0  = Instance.new("Attachment", workspace)
        leftAtt1  = Instance.new("Attachment", workspace)
        rightAtt0 = Instance.new("Attachment", workspace)
        rightAtt1 = Instance.new("Attachment", workspace)
        leftBeam  = makeBeam(leftAtt0, laserColor);  leftBeam.Attachment0 = leftAtt0;  leftBeam.Attachment1 = leftAtt1
        rightBeam = makeBeam(rightAtt0, laserColor); rightBeam.Attachment0 = rightAtt0; rightBeam.Attachment1 = rightAtt1
        if beamConn then beamConn:Disconnect() end
        beamConn = RunSrv.RenderStepped:Connect(updateLaser)
    else
        if beamConn then beamConn:Disconnect(); beamConn=nil end
        destroyBeams()
    end
end

--// ===== 7. 飞行系统 =====
local flying   = false
local flySpeed = 50
local flyConn
local moveVec  = Vector3.zero

local function setFlying(on)
    flying = on
    if not root or not hum then return end
    hum.PlatformStand = on
    if on then
        if flyConn then flyConn:Disconnect() end
        flyConn = RunSrv.Heartbeat:Connect(function(dt)
            if not flying or not root then return end
            local cam = workspace.CurrentCamera
            local lv = UIS:IsKeyDown(Enum.KeyCode.A) and -1 or (UIS:IsKeyDown(Enum.KeyCode.D) and 1 or 0)
            local fb = UIS:IsKeyDown(Enum.KeyCode.W) and -1 or (UIS:IsKeyDown(Enum.KeyCode.S) and 1 or 0)
            local ud = UIS:IsKeyDown(Enum.KeyCode.Space) and 1 or (UIS:IsKeyDown(Enum.KeyCode.LeftControl) and -1 or 0)
            local right = cam.CFrame.RightVector * lv
            local forward = cam.CFrame.LookVector * fb
            local up = Vector3.new(0,1,0) * ud
            local dir = (right + forward + up)
            if dir.Magnitude > 0 then dir = dir.Unit end
            root.Velocity = dir * flySpeed
        end)
    else
        if flyConn then flyConn:Disconnect(); flyConn=nil end
        if hum then hum.PlatformStand = false end
        if root then root.Velocity = Vector3.zero end
    end
end

--// ===== 8. Rayfield UI 绑定 =====

-- 主页
TabHome:CreateSection("作者信息")
TabHome:CreateLabel("作者：榆")
TabHome:CreateParagraph({Title="关于作者", Content="本脚本由 榆 开发，仅供学习交流使用。"})

-- 进出提示
TabNotify:CreateSection("提示外观")
TabNotify:CreateToggle({Name="启用玩家进出提示", CurrentValue=true,
    Callback=function(v) NotifyEnabled = v; NotifyGui.Enabled = v end})
TabNotify:CreateSlider({Name="提示停留时间(秒)", Range={1,8}, Increment=0.5, CurrentValue=3,
    Callback=function(v) NoticeDuration = v end})
TabNotify:CreateSlider({Name="最大同时显示条数", Range={1,10}, Increment=1, CurrentValue=5,
    Callback=function(v) MaxNotices = math.floor(v) end})
TabNotify:CreateSection("测试")
TabNotify:CreateButton({Name="测试 - 玩家加入", Callback=function() createNotice("TestPlayer_Join",true) end})
TabNotify:CreateButton({Name="测试 - 玩家离开", Callback=function() createNotice("TestPlayer_Leave",false) end})

-- 战斗 - 激光
TabCombat:CreateSection("激光射线")
TabCombat:CreateToggle({Name="启用激光射线", CurrentValue=false,
    Callback=function(v) setLaser(v) end})
TabCombat:CreateColorPicker({Name="激光颜色", Color=laserColor,
    Callback=function(c)
        laserColor = c
        if leftBeam  then leftBeam.Color  = ColorSequence.new(c) end
        if rightBeam then rightBeam.Color = ColorSequence.new(c) end
    end})
TabCombat:CreateSlider({Name="激光伤害", Range={1,100}, Increment=1, CurrentValue=25,
    Callback=function(v) laserDamage = v end})
TabCombat:CreateSlider({Name="激光射程", Range={100,2000}, Increment=50, CurrentValue=600,
    Callback=function(v) laserRange = v end})
TabCombat:CreateLabel("提示：面向目标发射，命中玩家会扣血+飘字+击退")

-- 移动 - 飞行
TabMove:CreateSection("飞行")
TabMove:CreateToggle({Name="启用飞行", CurrentValue=false,
    Callback=function(v) setFlying(v) end})
TabMove:CreateSlider({Name="飞行速度", Range={10,200}, Increment=5, CurrentValue=50,
    Callback=function(v) flySpeed = v end})
TabMove:CreateLabel("操作：W/A/S/D 移动，空格上升，左Ctrl下降")
TabMove:CreateLabel("提示：开启飞行后可用上方速度滑块实时调节")

-- 关于
TabAbout:CreateSection("脚本信息")
TabAbout:CreateParagraph({Title="冰缝合脚本 V2.4", Content="Rayfield 整合版\niOS玻璃提示 + 双手激光射线(可见/伤害/飘字) + 飞行调速"})
TabAbout:CreateLabel("开发者：榆")
TabAbout:CreateLabel("版本：V2.4")
TabAbout:CreateButton({Name="关闭 UI", Callback=function() Rayfield:Destroy() end})

