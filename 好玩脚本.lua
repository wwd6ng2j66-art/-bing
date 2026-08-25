-- WK GUI v2.5 修复完整版
local p = game:GetService("Players").LocalPlayer
local u = game:GetService("UserInputService")
local rs = game:GetService("RunService")

repeat wait() until p.Character and p.Character:FindFirstChild("HumanoidRootPart")
local rp = p.Character.HumanoidRootPart
local h = p.Character.Humanoid

local g = Instance.new("ScreenGui")
g.Name = "WKGUI"
g.ResetOnSpawn = false
g.Parent = p:WaitForChild("PlayerGui")

-- =======================
-- 彩色悬浮球
-- =======================
local ball = Instance.new("TextButton")
ball.Size = UDim2.new(0, 80, 0, 60)
ball.Position = UDim2.new(0.5, -40, 0.5, -30)
ball.BackgroundColor3 = Color3.fromRGB(255,255,255)
ball.Text = "WK脚本"
ball.TextColor3 = Color3.fromRGB(0,0,0)
ball.TextScaled = true
ball.Font = Enum.Font.SourceSansBold
ball.Parent = g

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
    ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255,255,0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,0)),
    ColorSequenceKeypoint.new(0.75, Color3.fromRGB(0,0,255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,255))
})
gradient.Parent = ball

-- 悬浮球拖动
local drag, dragStart, posStart
ball.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        drag = true
        dragStart = inp.Position
        posStart = ball.Position
    end
end)

u.InputChanged:Connect(function(inp)
    if drag and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
        local delta = inp.Position - dragStart
        ball.Position = UDim2.new(posStart.X.Scale, posStart.X.Offset + delta.X, posStart.Y.Scale, posStart.Y.Offset + delta.Y)
    end
end)

u.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        drag = false
    end
end)

-- =======================
-- 主窗口
-- =======================
local win = Instance.new("Frame")
win.Size = UDim2.new(0,400,0,480)
win.Position = UDim2.new(0.5,-200,0.5,-240)
win.BackgroundColor3 = Color3.fromRGB(30,30,30)
win.Visible = false
win.Parent = g

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1,0,0,40)
titleBar.BackgroundColor3 = Color3.fromRGB(50,50,50)
titleBar.Parent = win

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.8,0,1,0)
title.BackgroundTransparency = 1
title.Text = "wk 辅助 v2.5"
title.TextColor3 = Color3.new(1,1,1)
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextScaled = true
title.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0,40,0,40)
closeBtn.Position = UDim2.new(1,-44,0,0)
closeBtn.Text = "×"
closeBtn.TextScaled = true
closeBtn.BackgroundTransparency = 1
closeBtn.TextColor3 = Color3.fromRGB(255,80,80)
closeBtn.Parent = titleBar

closeBtn.MouseButton1Click:Connect(function()
    win.Visible = false
    ball.Visible = true
end)

ball.MouseButton1Click:Connect(function()
    win.Visible = true
    ball.Visible = false
end)

-- 窗口拖动
local wDrag, wDragStart, wPosStart
titleBar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        wDrag = true
        wDragStart = inp.Position
        wPosStart = win.Position
    end
end)

u.InputChanged:Connect(function(inp)
    if wDrag and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
        local delta = inp.Position - wDragStart
        win.Position = UDim2.new(wPosStart.X.Scale, wPosStart.X.Offset + delta.X, wPosStart.Y.Scale, wPosStart.Y.Offset + delta.Y)
    end
end)

u.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        wDrag = false
    end
end)

-- =======================
-- 导航
-- =======================
local nav = Instance.new("Frame")
nav.Size = UDim2.new(0,100,1,-40)
nav.Position = UDim2.new(0,0,0,40)
nav.BackgroundColor3 = Color3.fromRGB(25,25,25)
nav.Parent = win

local function navBtn(t,y)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,0,0,40)
    b.Position = UDim2.new(0,0,0,y)
    b.Text = t
    b.TextScaled = true
    b.BackgroundColor3 = Color3.fromRGB(40,40,40)
    b.TextColor3 = Color3.new(1,1,1)
    b.Parent = nav
    return b
end

local bGeneral = navBtn("通用",5)
local bFly = navBtn("飞行",50)
local bCombat = navBtn("战斗",95)
local bTele = navBtn("传送",140)

-- =======================
-- 内容区
-- =======================
local content = Instance.new("Frame")
content.Size = UDim2.new(1,-110,1,-50)
content.Position = UDim2.new(0,105,0,45)
content.BackgroundColor3 = Color3.fromRGB(35,35,35)
content.Parent = win

local function clear()
    for _,v in pairs(content:GetChildren()) do v:Destroy() end
end

local function row(y,text)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,-20,0,40)
    f.Position = UDim2.new(0.02,0,0,y)
    f.BackgroundColor3 = Color3.fromRGB(45,45,45)
    f.Parent = content

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.5,0,1,0)
    l.Text = text
    l.TextScaled = true
    l.BackgroundTransparency = 1
    l.TextColor3 = Color3.new(1,1,1)
    l.Parent = f
    return f
end

-- =======================
-- 通用
-- =======================
local antiTP = false
local lastPos = rp.Position

bGeneral.MouseButton1Click:Connect(function()
    clear()
    local r = row(10,"防传送")

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,120,1,0)
    btn.Position = UDim2.new(1,-130,0,0)
    btn.Text = "防传送 (关)"
    btn.BackgroundColor3 = Color3.fromRGB(200,50,50)
    btn.TextScaled = true
    btn.Parent = r

    btn.MouseButton1Click:Connect(function()
        antiTP = not antiTP
        btn.Text = antiTP and "防传送 (开)" or "防传送 (关)"
        btn.BackgroundColor3 = antiTP and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,50,50)
    end)

    rs.Heartbeat:Connect(function()
        if antiTP and rp then
            if (rp.Position - lastPos).Magnitude > 15 then
                rp.CFrame = CFrame.new(lastPos)
            else
                lastPos = rp.Position
            end
        else
            lastPos = rp.Position
        end
    end)
end)

-- =======================
-- 飞行
-- =======================
local flying = false
local flySpeed = 50
local bv = Instance.new("BodyVelocity")
bv.MaxForce = Vector3.new(1e5,1e5,1e5)

bFly.MouseButton1Click:Connect(function()
    clear()
    local r = row(10,"飞行状态")

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,120,1,0)
    btn.Position = UDim2.new(1,-130,0,0)
    btn.Text = "飞行 (关)"
    btn.BackgroundColor3 = Color3.fromRGB(30,144,255)
    btn.TextScaled = true
    btn.Parent = r

    btn.MouseButton1Click:Connect(function()
        flying = not flying
        btn.Text = flying and "飞行 (开)" or "飞行 (关)"
        btn.BackgroundColor3 = flying and Color3.fromRGB(0,200,0) or Color3.fromRGB(30,144,255)
        if flying then
            bv.Parent = rp
        else
            bv.Parent = nil
        end
    end)

    local r2 = row(60,"飞行速度")
    local sp = Instance.new("TextLabel")
    sp.Size = UDim2.new(0,40,1,0)
    sp.Position = UDim2.new(0.5,-20,0,0)
    sp.Text = tostring(flySpeed)
    sp.TextScaled = true
    sp.BackgroundTransparency = 1
    sp.TextColor3 = Color3.new(1,1,1)
    sp.Parent = r2

    local plus = Instance.new("TextButton")
    plus.Size = UDim2.new(0,30,1,0)
    plus.Position = UDim2.new(1,-30,0,0)
    plus.Text = "+"
    plus.TextScaled = true
    plus.Parent = r2

    local minus = Instance.new("TextButton")
    minus.Size = UDim2.new(0,30,1,0)
    minus.Position = UDim2.new(0,0,0,0)
    minus.Text = "-"
    minus.TextScaled = true
    plus.Parent = r2

    plus.MouseButton1Click:Connect(function()
        flySpeed = math.min(200, flySpeed + 10)
        sp.Text = tostring(flySpeed)
    end)

    minus.MouseButton1Click:Connect(function()
        flySpeed = math.max(10, flySpeed - 10)
        sp.Text = tostring(flySpeed)
    end)

    u.InputBegan:Connect(function(i)
        if not flying then return end
        if i.KeyCode == Enum.KeyCode.Space then
            bv.Velocity = Vector3.new(0,flySpeed,0)
        elseif i.KeyCode == Enum.KeyCode.LeftShift then
            bv.Velocity = Vector3.new(0,-flySpeed,0)
        elseif i.KeyCode == Enum.KeyCode.W then
            bv.Velocity = workspace.CurrentCamera.CFrame.LookVector * flySpeed
        end
    end)
end)

-- 默认页
bGeneral.MouseButton1Click:Fire()
