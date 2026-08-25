-- 悬浮球 + 高级菜单 v2.5（修复完整版）
local p = game:GetService("Players").LocalPlayer
local u = game:GetService("UserInputService")
local rs = game:GetService("RunService")

-- ✅ GUI 容器（修复报错）
local g = Instance.new("ScreenGui")
g.Name = "WkGUI"
g.ResetOnSpawn = false
g.Parent = p:WaitForChild("PlayerGui")

-- ======================
-- 🌈 彩色悬浮球
-- ======================
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

-- ======================
-- 🖱 悬浮球拖动
-- ======================
local drag, dragStart, posStart = false, nil, nil

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
        ball.Position = UDim2.new(
            posStart.X.Scale, posStart.X.Offset + delta.X,
            posStart.Y.Scale, posStart.Y.Offset + delta.Y
        )
    end
end)

u.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        drag = false
    end
end)

-- ======================
-- 🪟 主菜单窗口
-- ======================
local win = Instance.new("Frame")
win.Size = UDim2.new(0,400,0,480)
win.Position = UDim2.new(0.5,-200,0.5,-240)
win.BackgroundColor3 = Color3.fromRGB(30,30,30)
win.BackgroundTransparency = 0.15
win.Visible = false
win.Parent = g

-- 标题栏
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1,0,0,40)
titleBar.BackgroundColor3 = Color3.fromRGB(50,50,50)
titleBar.Parent = win

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.8,0,1,0)
title.Text = "wk 辅助 v2.5"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.TextScaled = true
title.BackgroundTransparency = 1
title.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0,40,0,40)
closeBtn.Position = UDim2.new(1,-44,0,0)
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(255,80,80)
closeBtn.TextScaled = true
closeBtn.BackgroundTransparency = 1
closeBtn.Parent = titleBar

closeBtn.MouseButton1Click:Connect(function()
    win.Visible = false
    ball.Visible = true
end)

ball.MouseButton1Click:Connect(function()
    win.Visible = true
    ball.Visible = false
end)

-- ======================
-- 🧭 左侧导航
-- ======================
local nav = Instance.new("Frame")
nav.Size = UDim2.new(0,100,1,-40)
nav.Position = UDim2.new(0,0,0,40)
nav.BackgroundColor3 = Color3.fromRGB(25,25,25)
nav.Parent = win

local function navBtn(text,y)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,0,0,40)
    b.Position = UDim2.new(0,0,0,y)
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.BackgroundColor3 = Color3.fromRGB(40,40,40)
    b.TextScaled = true
    b.Parent = nav
    return b
end

local btnGeneral = navBtn("通用",5)
local btnFly = navBtn("飞行",50)

-- ======================
-- 📄 内容区
-- ======================
local content = Instance.new("Frame")
content.Size = UDim2.new(1,-110,1,-50)
content.Position = UDim2.new(0,105,0,45)
content.BackgroundColor3 = Color3.fromRGB(35,35,35)
content.Parent = win

local function clear()
    for _,v in ipairs(content:GetChildren()) do v:Destroy() end
end

-- ======================
-- 🛡 通用（防传送）
-- ======================
local antiTP = false
local lastPos = nil

btnGeneral.MouseButton1Click:Connect(function()
    clear()
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,160,0,40)
    btn.Position = UDim2.new(0.1,0,0,20)
    btn.Text = antiTP and "防传送 ✅" or "防传送 ❌"
    btn.TextScaled = true
    btn.Parent = content

    btn.MouseButton1Click:Connect(function()
        antiTP = not antiTP
        btn.Text = antiTP and "防传送 ✅" or "防传送 ❌"
    end)
end)

-- ======================
-- 🚀 飞行系统
-- ======================
local flying = false
local flySpeed = 50
local bv = nil

btnFly.MouseButton1Click:Connect(function()
    clear()

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0,160,0,40)
    toggle.Position = UDim2.new(0.1,0,0,20)
    toggle.Text = flying and "飞行 ✅" or "飞行 ❌"
    toggle.TextScaled = true
    toggle.Parent = content

    local speed = Instance.new("TextLabel")
    speed.Size = UDim2.new(0,100,0,40)
    speed.Position = UDim2.new(0.1,0,0,80)
    speed.Text = "速度: "..flySpeed
    speed.TextScaled = true
    speed.Parent = content

    toggle.MouseButton1Click:Connect(function()
        flying = not flying
        toggle.Text = flying and "飞行 ✅" or "飞行 ❌"

        local rp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
        if flying and rp then
            bv = Instance.new("BodyVelocity",rp)
            bv.Velocity = Vector3.zero
            bv.MaxForce = Vector3.new(1e5,1e5,1e5)
        elseif bv then
            bv:Destroy()
        end
    end)

    -- 速度调节
    for i=1,2 do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0,40,0,40)
        b.Position = UDim2.new(0.6 + i*0.1,0,0,80)
        b.Text = i==1 and "-" or "+"
        b.TextScaled = true
        b.Parent = content

        b.MouseButton1Click:Connect(function()
            flySpeed = math.clamp(flySpeed + (i==1 and -10 or 10),10,200)
            speed.Text = "速度: "..flySpeed
        end)
    end
end)

-- ======================
-- 🚀 飞行运行
-- ======================
rs.RenderStepped:Connect(function()
    if flying and bv then
        local cam = workspace.CurrentCamera
        bv.Velocity = (cam.CFrame.LookVector * flySpeed)
    end
end)

-- 默认打开通用
btnGeneral.MouseButton1Click:Fire()
