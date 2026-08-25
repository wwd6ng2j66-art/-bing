-- ============================================================
--  WK 控制菜单  (修复版: 窗口可拖拽 / 最小化 / 关闭)
-- ============================================================

-- ---------- 服务 ----------
local p      = game:GetService("Players").LocalPlayer
local u      = game:GetService("UserInputService")
local rs     = game:GetService("RunService")
local debris = game:GetService("Debris")

-- ---------- 安全获取 GUI 父节点 ----------
local function getGuiParent()
    local ok, hui = pcall(function() return gethui() end)
    if ok and hui then return hui end
    -- 等待 PlayerGui
    local pg = p:WaitForChild("PlayerGui", 10)
    return pg
end

local guiParent = getGuiParent()

-- ---------- 主 ScreenGui ----------
local g = Instance.new("ScreenGui")
g.Name             = "WK_Menu"
g.ResetOnSpawn    = false
g.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
g.Parent          = guiParent

-- ============================================================
--  浮动按钮 (左下角圆形按钮, 用于重新打开菜单)
-- ============================================================
local floatBtn = Instance.new("TextButton")
floatBtn.Name               = "FloatBtn"
floatBtn.Size               = UDim2.new(0, 56, 0, 56)
floatBtn.Position           = UDim2.new(0, 14, 1, -70)   -- 左下角
floatBtn.BackgroundColor3   = Color3.fromRGB(40, 40, 40)
floatBtn.BackgroundTransparency = 0.15
floatBtn.Text               = "WK"
floatBtn.TextColor3         = Color3.fromRGB(255, 255, 255)
floatBtn.TextScaled         = true
floatBtn.Font               = Enum.Font.SourceSansBold
floatBtn.Visible            = false
floatBtn.Parent             = g

-- 圆角
local floatCorner = Instance.new("UICorner")
floatCorner.CornerRadius = UDim.new(1, 0)
floatCorner.Parent       = floatBtn

-- 彩虹渐变
local floatGrad = Instance.new("UIGradient")
floatGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(0.25,Color3.fromRGB(255,255, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 0)),
    ColorSequenceKeypoint.new(0.75,Color3.fromRGB(0, 0, 255)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(255, 0, 255)),
}
floatGrad.Parent = floatBtn

floatBtn.MouseButton1Click:Connect(function()
    floatBtn.Visible = false
    mainFrame.Visible = true
end)

-- ============================================================
--  主菜单框架
-- ============================================================
local mainFrame = Instance.new("Frame")
mainFrame.Name              = "MainFrame"
mainFrame.Size              = UDim2.new(0, 400, 0, 360)
mainFrame.Position          = UDim2.new(0.5, -200, 0.5, -180)
mainFrame.BackgroundColor3  = Color3.fromRGB(30, 30, 30)
mainFrame.BackgroundTransparency = 0.12
mainFrame.BorderSizePixel   = 0
mainFrame.Parent            = g

-- 圆角
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent       = mainFrame

-- ---------- 标题栏 (可拖拽) ----------
local titleBar = Instance.new("Frame")
titleBar.Name             = "TitleBar"
titleBar.Size             = UDim2.new(1, 0, 0, 36)
titleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
titleBar.BorderSizePixel  = 0
titleBar.Parent           = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent       = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size             = UDim2.new(0.6, 0, 1, 0)
titleLabel.Position         = UDim2.new(0.02, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text             = "WK 控制菜单"
titleLabel.TextColor3       = Color3.fromRGB(255, 255, 255)
titleLabel.TextXAlignment   = Enum.TextXAlignment.Left
titleLabel.TextScaled       = true
titleLabel.Font             = Enum.Font.SourceSansBold
titleLabel.Parent           = titleBar

-- 最小化按钮
local minBtn = Instance.new("TextButton")
minBtn.Name             = "MinBtn"
minBtn.Size             = UDim2.new(0, 34, 0, 34)
minBtn.Position         = UDim2.new(1, -72, 0, 1)
minBtn.BackgroundTransparency = 1
minBtn.Text             = "_"
minBtn.TextColor3       = Color3.fromRGB(200, 200, 200)
minBtn.TextScaled       = true
minBtn.Font             = Enum.Font.SourceSansBold
minBtn.Parent           = titleBar

-- 关闭按钮
local closeBtn = Instance.new("TextButton")
closeBtn.Name             = "CloseBtn"
closeBtn.Size             = UDim2.new(0, 34, 0, 34)
closeBtn.Position         = UDim2.new(1, -38, 0, 1)
closeBtn.BackgroundTransparency = 1
closeBtn.Text             = "×"
closeBtn.TextColor3       = Color3.fromRGB(255, 80, 80)
closeBtn.TextScaled       = true
closeBtn.Font             = Enum.Font.SourceSansBold
closeBtn.Parent           = titleBar

-- ---------- 左侧导航栏 ----------
local navBar = Instance.new("Frame")
navBar.Name             = "NavBar"
navBar.Size             = UDim2.new(0, 92, 1, -36)
navBar.Position         = UDim2.new(0, 0, 0, 36)
navBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
navBar.BorderSizePixel  = 0
navBar.Parent           = mainFrame

local navLayout = Instance.new("UIListLayout")
navLayout.SortOrder      = Enum.SortOrder.LayoutOrder
navLayout.Padding        = UDim.new(0, 4)
navLayout.Parent         = navBar

local navPad = Instance.new("UIPadding")
navPad.PaddingTop    = UDim.new(0, 6)
navPad.PaddingLeft   = UDim.new(0, 4)
navPad.PaddingRight  = UDim.new(0, 4)
navPad.Parent        = navBar

local function createNavButton(text, order)
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.Text             = text
    btn.TextColor3       = Color3.fromRGB(255, 255, 255)
    btn.TextScaled       = true
    btn.Font             = Enum.Font.SourceSans
    btn.LayoutOrder      = order
    btn.Parent           = navBar

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent       = btn
    return btn
end

local navGeneral = createNavButton("通用", 1)
local navFly     = createNavButton("飞行", 2)
local navCombat  = createNavButton("战斗", 3)
local navTele    = createNavButton("传送", 4)

-- ---------- 内容区域 ----------
local contentFrame = Instance.new("Frame")
contentFrame.Name             = "Content"
contentFrame.Size             = UDim2.new(1, -96, 1, -42)
contentFrame.Position         = UDim2.new(0, 94, 0, 38)
contentFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
contentFrame.BorderSizePixel  = 0
contentFrame.Parent           = mainFrame

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 6)
contentCorner.Parent       = contentFrame

local contentPad = Instance.new("UIPadding")
contentPad.PaddingTop    = UDim.new(0, 8)
contentPad.PaddingLeft   = UDim.new(0, 8)
contentPad.PaddingRight  = UDim.new(0, 8)
contentPad.Parent        = contentFrame

-- ============================================================
--  工具函数
-- ============================================================
local function clearContent()
    for _, v in pairs(contentFrame:GetChildren()) do
        if not v:IsA("UIPadding") and not v:IsA("UICorner") then
            v:Destroy()
        end
    end
end

-- 创建一行: 标签 + 按钮
local function createRow(yOffset, labelText, btnRef)
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1, 0, 0, 36)
    row.Position         = UDim2.new(0, 0, 0, yOffset)
    row.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    row.BorderSizePixel  = 0
    row.Parent           = contentFrame

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 5)
    rowCorner.Parent       = row

    local lbl = Instance.new("TextLabel")
    lbl.Size             = UDim2.new(0.5, -6, 1, 0)
    lbl.Position         = UDim2.new(0, 6, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text             = labelText
    lbl.TextColor3       = Color3.fromRGB(220, 220, 220)
    lbl.TextXAlignment   = Enum.TextXAlignment.Left
    lbl.TextScaled       = true
    lbl.Font             = Enum.Font.SourceSans
    lbl.Parent           = row

    local btn = btnRef
    btn.Size             = UDim2.new(0, 86, 1, -4)
    btn.Position         = UDim2.new(1, -90, 0, 2)
    btn.TextColor3       = Color3.fromRGB(255, 255, 255)
    btn.TextScaled       = true
    btn.Font             = Enum.Font.SourceSans
    btn.Parent           = row

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 5)
    btnCorner.Parent       = btn

    return btn
end

-- ============================================================
--  状态变量
-- ============================================================
local flying    = false
local hSpd      = 50
local vSpd      = 30
local anti      = false
local cape      = nil
local capW      = nil
local laser     = false
local lpL, lpR  = nil, nil
local rp        = nil
local h         = nil

-- ============================================================
--  角色初始化
-- ============================================================
local function initChar()
    local char = p.Character or p.CharacterAdded:Wait()
    repeat task.wait() until char:FindFirstChild("HumanoidRootPart")
    rp = char:FindFirstChild("HumanoidRootPart")
    h  = char:FindFirstChild("Humanoid")
end
spawn(initChar)
p.CharacterAdded:Connect(function()
    task.wait(0.5)
    initChar()
end)

-- ============================================================
--  披风功能
-- ============================================================
local function togCape(enable)
    if not rp then return end
    local char = p.Character
    if not char then return end

    if enable and not cape then
        local tr = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
        if not tr then return end

        cape = Instance.new("Part")
        cape.Name            = "WK_Cape"
        cape.Size            = Vector3.new(5, 4, 0.2)
        cape.Anchored        = false
        cape.CanCollide      = false
        cape.Material        = Enum.Material.SmoothPlastic
        cape.Color           = Color3.fromRGB(200, 20, 20)
        cape.Transparency    = 0.2
        cape.Parent          = char

        local st = Instance.new("Part")
        st.Name            = "WK_CapeSpine"
        st.Size            = Vector3.new(0.3, 3.8, 0.25)
        st.Anchored        = false
        st.CanCollide      = false
        st.Material        = Enum.Material.SmoothPlastic
        st.Color           = Color3.fromRGB(255, 215, 0)
        st.Transparency    = 0.2
        st.Parent          = cape

        capW = Instance.new("Weld")
        capW.Name   = "WK_CapeWeld"
        capW.Part0  = tr
        capW.Part1  = cape
        capW.C0     = CFrame.new(0, 0.5, -1.5)
        capW.Parent = tr

        local sw = Instance.new("Weld")
        sw.Part0  = cape
        sw.Part1  = st
        sw.C0     = CFrame.new(0, 0, -0.1)
        sw.Parent = cape

    elseif not enable and cape then
        cape:Destroy()
        cape = nil
        capW = nil
    end
end

-- ============================================================
--  激光功能
-- ============================================================
local function createLaserPart()
    local part = Instance.new("Part")
    part.Name            = "WK_Laser"
    part.Size            = Vector3.new(1.5, 1.5, 0.2)
    part.Anchored        = true
    part.CanCollide      = false
    part.Material        = Enum.Material.Neon
    part.Color           = Color3.fromRGB(255, 0, 0)
    part.Transparency    = 0.2
    part.Parent          = workspace
    return part
end

local function rebuildLasers()
    if lpL then lpL:Destroy() lpL = nil end
    if lpR then lpR:Destroy() lpR = nil end
    lpL = createLaserPart()
    lpR = createLaserPart()
end
rebuildLasers()

-- 更新激光外观
local function updateLaserBeam(laserPart, origin, direction, distance)
    if not laserPart then return end
    if distance < 0.1 then
        laserPart.Size     = Vector3.new(0.1, 0.1, 0.1)
        laserPart.CFrame   = CFrame.new(origin)
        return
    end
    local endPoint = origin + direction * distance
    laserPart.Size   = Vector3.new(1.5, 1.5, distance)
    laserPart.CFrame = CFrame.lookAt((origin + endPoint) / 2, endPoint)
end

-- 伤害飘字
local function spawnDamageNumber(pos, amount)
    local bg = Instance.new("BillboardGui")
    bg.Size         = UDim2.new(0, 80, 0, 40)
    bg.AlwaysOnTop  = true
    bg.Parent       = workspace

    local fr = Instance.new("Frame")
    fr.Size                 = UDim2.new(1, 0, 1, 0)
    fr.BackgroundTransparency = 1
    fr.Parent               = bg

    local lbl = Instance.new("TextLabel")
    lbl.Size             = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text             = "-" .. tostring(amount)
    lbl.TextColor3       = Color3.fromRGB(255, 0, 0)
    lbl.TextScaled       = true
    lbl.Font             = Enum.Font.GothamBlack
    lbl.Parent           = fr

    local att = Instance.new("Attachment")
    att.Parent   = workspace
    att.Position = pos
    bg.Parent   = att

    debris:AddItem(bg, 0.8)
    debris:AddItem(att, 0.8)
end

-- 发射激光
local function fireLasers()
    if not rp or not p.Character then return end
    local cam   = workspace.CurrentCamera
    local dir   = cam.CFrame.LookVector
    local oL    = rp.Position + Vector3.new(-0.6, 1.5, 0)
    local oR    = rp.Position + Vector3.new( 0.6, 1.5, 0)
    local maxD  = 800

    local params = RaycastParams.new()
    params.FilterType             = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {p.Character}

    local function processHit(origin, result, dist)
        if not result then return end
        local hit   = result.Instance
        local model = hit:FindFirstAncestorOfClass("Model")
        if not model then return end
        local targetHum  = model:FindFirstChild("Humanoid")
        local targetRoot = model:FindFirstChild("HumanoidRootPart")
        if not targetHum or not targetRoot then return end

        local force = (targetRoot.Position - rp.Position).Unit * 200 + Vector3.new(0, 120, 0)
        targetRoot.Velocity           = force
        targetRoot.AssemblyLinearVelocity = force
        targetHum:TakeDamage(30)
        spawnDamageNumber(result.Position, 30)

        -- 命中特效
        local fx = Instance.new("Part")
        fx.Size            = Vector3.new(5, 5, 5)
        fx.Anchored        = true
        fx.CanCollide      = false
        fx.Material        = Enum.Material.Neon
        fx.Color           = Color3.fromRGB(255, 255, 200)
        fx.Transparency    = 0.5
        fx.Position        = result.Position
        fx.Parent          = workspace
        debris:AddItem(fx, 0.4)

        for i = 1, 10 do
            local p2 = Instance.new("Part")
            p2.Size            = Vector3.new(1, 1, 1)
            p2.Anchored        = true
            p2.CanCollide      = false
            p2.Material        = Enum.Material.Neon
            p2.Color           = Color3.fromRGB(255, 200, 100)
            p2.Transparency    = 0.8
            p2.Position        = result.Position + Vector3.new(math.random(-5,5), math.random(-5,5), math.random(-5,5))
            p2.Parent          = workspace
            debris:AddItem(p2, 0.5)
        end

        local exp = Instance.new("Explosion")
        exp.Position        = result.Position
        exp.BlastRadius     = 4
        exp.ExplosionType   = Enum.ExplosionType.NoCraters
        exp.Parent          = workspace
        debris:AddItem(exp, 0.3)
    end

    local rL = workspace:Raycast(oL, dir * maxD, params)
    local dL = rL and (oL - rL.Position).Magnitude or maxD
    processHit(oL, rL, dL)

    local rR = workspace:Raycast(oR, dir * maxD, params)
    local dR = rR and (oR - rR.Position).Magnitude or maxD
    processHit(oR, rR, dR)

    updateLaserBeam(lpL, oL, dir, dL)
    updateLaserBeam(lpR, oR, dir, dR)
end

-- ============================================================
--  页面: 通用
-- ============================================================
local function showGeneral()
    clearContent()

    -- 最小化按钮行
    local minRowBtn = Instance.new("TextButton")
    minRowBtn.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    minRowBtn.Text             = "最小化到悬浮按钮"
    minRowBtn.Parent           = contentFrame
    createRow(0,  "窗口", minRowBtn)
    minRowBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        floatBtn.Visible  = true
    end)

    -- 防传送
    local antiBtn = Instance.new("TextButton")
    antiBtn.BackgroundColor3 = anti and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 50, 50)
    antiBtn.Text             = anti and "防传送 (开)" or "防传送 (关)"
    antiBtn.Parent           = contentFrame
    createRow(42, "防传送", antiBtn)
    antiBtn.MouseButton1Click:Connect(function()
        anti = not anti
        antiBtn.Text             = anti and "防传送 (开)" or "防传送 (关)"
        antiBtn.BackgroundColor3 = anti and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 50, 50)
    end)

    -- 披风
    local capeBtn = Instance.new("TextButton")
    capeBtn.BackgroundColor3 = cape and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 50, 50)
    capeBtn.Text             = cape and "披风 (开)" or "披风 (关)"
    capeBtn.Parent           = contentFrame
    createRow(84, "披风", capeBtn)
    capeBtn.MouseButton1Click:Connect(function()
        togCape(not cape)
        capeBtn.Text             = cape and "披风 (开)" or "披风 (关)"
        capeBtn.BackgroundColor3 = cape and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 50, 50)
    end)
end

-- ============================================================
--  页面: 飞行
-- ============================================================
local function showFly()
    clearContent()

    local flyBtn = Instance.new("TextButton")
    flyBtn.BackgroundColor3 = flying and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 50, 50)
    flyBtn.Text             = flying and "飞行 (开)" or "飞行 (关)"
    flyBtn.Parent           = contentFrame
    createRow(0, "飞行开关", flyBtn)
    flyBtn.MouseButton1Click:Connect(function()
        flying = not flying
        flyBtn.Text             = flying and "飞行 (开)" or "飞行 (关)"
        flyBtn.BackgroundColor3 = flying and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 50, 50)
    end)

    -- 速度提示
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size             = UDim2.new(1, 0, 0, 28)
    speedLabel.Position         = UDim2.new(0, 0, 0, 88)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text             = "WASD 移动 | 空格上升 | Shift 下降"
    speedLabel.TextColor3       = Color3.fromRGB(180, 180, 180)
    speedLabel.TextScaled       = true
    speedLabel.Font             = Enum.Font.SourceSans
    speedLabel.Parent           = contentFrame
end

-- ============================================================
--  页面: 战斗
-- ============================================================
local function showCombat()
    clearContent()

    local laserBtn = Instance.new("TextButton")
    laserBtn.BackgroundColor3 = laser and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 50, 50)
    laserBtn.Text             = laser and "双激光 (开)" or "双激光 (关)"
    laserBtn.Parent           = contentFrame
    createRow(0, "双激光", laserBtn)
    laserBtn.MouseButton1Click:Connect(function()
        laser = not laser
        laserBtn.Text             = laser and "双激光 (开)" or "双激光 (关)"
        laserBtn.BackgroundColor3 = laser and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 50, 50)
        if not laser then
            rebuildLasers()
        end
    end)

    local hint = Instance.new("TextLabel")
    hint.Size             = UDim2.new(1, 0, 0, 28)
    hint.Position         = UDim2.new(0, 0, 0, 88)
    hint.BackgroundTransparency = 1
    hint.Text             = "激光从双肩发射, 对准视角方向"
    hint.TextColor3       = Color3.fromRGB(180, 180, 180)
    hint.TextScaled       = true
    hint.Font             = Enum.Font.SourceSans
    hint.Parent           = contentFrame
end

-- ============================================================
--  页面: 传送
-- ============================================================
local function showTeleport()
    clearContent()

    local hint = Instance.new("TextLabel")
    hint.Size             = UDim2.new(1, 0, 0, 30)
    hint.Position         = UDim2.new(0, 0, 0, 0)
    hint.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    hint.Text             = "传送功能 - 点击玩家名传送到其身边"
    hint.TextColor3       = Color3.fromRGB(255, 255, 255)
    hint.TextScaled       = true
    hint.Font             = Enum.Font.SourceSans
    hint.Parent           = contentFrame

    local hintCorner = Instance.new("UICorner")
    hintCorner.CornerRadius = UDim.new(0, 5)
    hintCorner.Parent       = hint

    -- 玩家列表
    local playerList = Instance.new("ScrollingFrame")
    playerList.Size             = UDim2.new(1, 0, 1, -38)
    playerList.Position         = UDim2.new(0, 0, 0, 34)
    playerList.BackgroundTransparency = 1
    playerList.BorderSizePixel  = 0
    playerList.ScrollBarThickness = 6
    playerList.Parent           = contentFrame

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.Name
    listLayout.Padding   = UDim.new(0, 3)
    listLayout.Parent    = playerList

    local function refreshPlayerList()
        for _, child in pairs(playerList:GetChildren()) do
            if not child:IsA("UIListLayout") then child:Destroy() end
        end
        local y = 0
        for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
            if plr ~= p then
                local pb = Instance.new("TextButton")
                pb.Size             = UDim2.new(1, -4, 0, 30)
                pb.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                pb.Text             = plr.Name
                pb.TextColor3       = Color3.fromRGB(255, 255, 255)
                pb.TextScaled       = true
                pb.Font             = Enum.Font.SourceSans
                pb.Parent           = playerList

                local pbc = Instance.new("UICorner")
                pbc.CornerRadius = UDim.new(0, 4)
                pbc.Parent       = pb

                pb.MouseButton1Click:Connect(function()
                    if rp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        rp.CFrame = plr.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
                    end
                end)
            end
        end
    end

    refreshPlayerList()
    -- 每 3 秒刷新一次玩家列表
    task.spawn(function()
        while contentFrame.Visible and mainFrame.Visible do
            task.wait(3)
            if navTele == nil then break end
            refreshPlayerList()
        end
    end)
end

-- ============================================================
--  导航按钮绑定
-- ============================================================
navGeneral.MouseButton1Click:Connect(showGeneral)
navFly.MouseButton1Click:Connect(showFly)
navCombat.MouseButton1Click:Connect(showCombat)
navTele.MouseButton1Click:Connect(showTeleport)

-- ============================================================
--  关闭 / 最小化 按钮
-- ============================================================
closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    floatBtn.Visible  = true
end)

minBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    floatBtn.Visible  = true
end)

-- ============================================================
--  窗口拖拽 (鼠标 + 触摸)
-- ============================================================
local dragging = false
local dragStartPos
local frameStartPos

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging       = true
        dragStartPos   = input.Position
        frameStartPos  = mainFrame.Position
    end
end)

titleBar.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStartPos
        mainFrame.Position = UDim2.new(
            frameStartPos.X.Scale, frameStartPos.X.Offset + delta.X,
            frameStartPos.Y.Scale, frameStartPos.Y.Offset + delta.Y
        )
    end
end)

titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ============================================================
--  主循环 (飞行 / 防传送 / 激光)
-- ============================================================
rs.Heartbeat:Connect(function()
    -- 飞行
    if flying and rp then
        local cam  = workspace.CurrentCamera
        local move = Vector3.new()

        local ok_w, w_down = pcall(function() return u:IsKeyDown(Enum.KeyCode.W) end)
        local ok_s, s_down = pcall(function() return u:IsKeyDown(Enum.KeyCode.S) end)
        local ok_a, a_down = pcall(function() return u:IsKeyDown(Enum.KeyCode.A) end)
        local ok_d, d_down = pcall(function() return u:IsKeyDown(Enum.KeyCode.D) end)
        local ok_sp, sp_down = pcall(function() return u:IsKeyDown(Enum.KeyCode.Space) end)
        local ok_sh, sh_down = pcall(function() return u:IsKeyDown(Enum.KeyCode.LeftShift) or u:IsKeyDown(Enum.KeyCode.RightShift) end)

        if ok_w and w_down then move = move + cam.CFrame.LookVector end
        if ok_s and s_down then move = move - cam.CFrame.LookVector end
        if ok_a and a_down then move = move - cam.CFrame.RightVector end
        if ok_d and d_down then move = move + cam.CFrame.RightVector end
        if ok_sp and sp_down then move = move + Vector3.new(0, vSpd, 0) end
        if ok_sh and sh_down then move = move - Vector3.new(0, vSpd, 0) end

        rp.Velocity = move * hSpd
    end

    -- 防传送 (强锚定)
    if anti and rp then
        rp.Anchored = true
        task.wait()
        rp.Anchored = false
    end

    -- 激光
    if laser then
        fireLasers()
    end
end)

-- ============================================================
--  初始显示通用页面
-- ============================================================
showGeneral()

-- 提示
print("[WK] 菜单已加载 | 拖拽标题栏移动 | 点击 × 或 _ 最小化到悬浮按钮")
