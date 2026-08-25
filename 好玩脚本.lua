-- 完整脚本 v2.8（修复天空盒）
-- 加载界面（3秒）
local loadGui = Instance.new("ScreenGui")
loadGui.Name = "LoadGUI"
loadGui.Parent = game:GetService("CoreGui")
local bg = Instance.new("Frame")
bg.Size = UDim2.new(1,0,1,0)
bg.BackgroundColor3 = Color3.fromRGB(0,0,0)
bg.BackgroundTransparency = 0.6
bg.Parent = loadGui
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0,400,0,300)
mainFrame.Position = UDim2.new(0.5,-200,0.5,-150)
mainFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
mainFrame.BackgroundTransparency = 0.3
mainFrame.BorderSizePixel = 0
mainFrame.Parent = bg
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,60)
title.Position = UDim2.new(0,0,0.1,0)
title.BackgroundTransparency = 1
title.Text = "wk 脚本"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame
local sub = Instance.new("TextLabel")
sub.Size = UDim2.new(1,0,0,40)
sub.Position = UDim2.new(0,0,0.3,0)
sub.BackgroundTransparency = 1
sub.Text = "V2.0 · 正在处理数据"
sub.TextColor3 = Color3.fromRGB(200,200,200)
sub.TextScaled = true
sub.Font = Enum.Font.SourceSans
sub.Parent = mainFrame
local progText = Instance.new("TextLabel")
progText.Size = UDim2.new(1,0,0,40)
progText.Position = UDim2.new(0,0,0.5,0)
progText.BackgroundTransparency = 1
progText.Text = "正在初始化引擎..0%"
progText.TextColor3 = Color3.fromRGB(255,255,255)
progText.TextScaled = true
progText.Font = Enum.Font.SourceSans
progText.Parent = mainFrame
local barBg = Instance.new("Frame")
barBg.Size = UDim2.new(0.8,0,0,20)
barBg.Position = UDim2.new(0.1,0,0.7,0)
barBg.BackgroundColor3 = Color3.fromRGB(50,50,50)
barBg.BorderSizePixel = 0
barBg.Parent = mainFrame
local bar = Instance.new("Frame")
bar.Size = UDim2.new(0,0,1,0)
bar.BackgroundColor3 = Color3.fromRGB(0,120,255)
bar.BorderSizePixel = 0
bar.Parent = barBg
local timerLabel = Instance.new("TextLabel")
timerLabel.Size = UDim2.new(1,0,0,30)
timerLabel.Position = UDim2.new(0,0,0.85,0)
timerLabel.BackgroundTransparency = 1
timerLabel.Text = "3.00s"
timerLabel.TextColor3 = Color3.fromRGB(150,150,150)
timerLabel.TextScaled = true
timerLabel.Font = Enum.Font.SourceSans
timerLabel.Parent = mainFrame
local startTime = tick()
local duration = 3
local elapsed = 0
while elapsed < duration do
    elapsed = tick() - startTime
    local progress = math.min(elapsed / duration, 1)
    local percent = math.floor(progress * 100)
    bar.Size = UDim2.new(progress, 0, 1, 0)
    progText.Text = "正在初始化引擎.." .. percent .. "%"
    timerLabel.Text = string.format("%.2fs", duration - elapsed)
    task.wait(0.03)
end
bar.Size = UDim2.new(1,0,1,0)
progText.Text = "正在初始化引擎..100%"
timerLabel.Text = "0.00s"
task.wait(0.2)
loadGui:Destroy()

-- 主脚本
local p = game:GetService("Players").LocalPlayer
local u = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local g = Instance.new("ScreenGui")
g.Name = "WkGUI"
g.Parent = game:GetService("CoreGui") or p:WaitForChild("PlayerGui")

-- 彩色悬浮球
local ball = Instance.new("TextButton")
ball.Size = UDim2.new(0,80,0,60)
ball.Position = UDim2.new(0.5,-40,0.5,-30)
ball.BackgroundColor3 = Color3.fromRGB(255,255,255)
ball.BackgroundTransparency = 0
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
local drag = false
local dragStart, posStart
ball.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
        drag = true
        dragStart = inp.Position
        posStart = ball.Position
    end
end)
ball.InputChanged:Connect(function(inp)
    if drag and inp.UserInputType == Enum.UserInputType.Touch then
        local delta = inp.Position - dragStart
        ball.Position = UDim2.new(posStart.X.Scale, posStart.X.Offset + delta.X, posStart.Y.Scale, posStart.Y.Offset + delta.Y)
    end
end)
ball.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
        drag = false
    end
end)

-- 主窗口
local win = Instance.new("Frame")
win.Size = UDim2.new(0,400,0,480)
win.Position = UDim2.new(0.5,-200,0.5,-240)
win.BackgroundColor3 = Color3.fromRGB(30,30,30)
win.BackgroundTransparency = 0.15
win.BorderSizePixel = 0
win.Visible = false
win.Parent = g
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1,0,0,40)
titleBar.BackgroundColor3 = Color3.fromRGB(50,50,50)
titleBar.Parent = win
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0.8,0,1,0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "wk 辅助 v2.0"
titleLabel.TextColor3 = Color3.fromRGB(255,255,255)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.SourceSans
titleLabel.Parent = titleBar
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0,40,0,40)
closeBtn.Position = UDim2.new(1,-44,0,0)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(255,80,80)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.SourceSans
closeBtn.Parent = titleBar
closeBtn.MouseButton1Click:Connect(function()
    win.Visible = false
    ball.Visible = true
end)
ball.MouseButton1Click:Connect(function()
    win.Visible = true
    ball.Visible = false
end)
local winDrag = false
local winDragStart, winPosStart
titleBar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
        winDrag = true
        winDragStart = inp.Position
        winPosStart = win.Position
    end
end)
titleBar.InputChanged:Connect(function(inp)
    if winDrag and inp.UserInputType == Enum.UserInputType.Touch then
        local delta = inp.Position - winDragStart
        win.Position = UDim2.new(winPosStart.X.Scale, winPosStart.X.Offset + delta.X, winPosStart.Y.Scale, winPosStart.Y.Offset + delta.Y)
    end
end)
titleBar.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
        winDrag = false
    end
end)

local nav = Instance.new("Frame")
nav.Size = UDim2.new(0,100,1,-40)
nav.Position = UDim2.new(0,0,0,40)
nav.BackgroundColor3 = Color3.fromRGB(25,25,25)
nav.BorderSizePixel = 0
nav.Parent = win
local function createNavBtn(text, yPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,0,40)
    btn.Position = UDim2.new(0,0,0,yPos)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.TextScaled = true
    btn.Font = Enum.Font.SourceSans
    btn.Parent = nav
    return btn
end
local btnGeneral = createNavBtn("通用",5)
local btnFly = createNavBtn("飞行",50)
local btnCombat = createNavBtn("战斗",95)
local btnTele = createNavBtn("传送",140)

local content = Instance.new("Frame")
content.Size = UDim2.new(1,-110,1,-50)
content.Position = UDim2.new(0,105,0,45)
content.BackgroundColor3 = Color3.fromRGB(35,35,35)
content.BorderSizePixel = 0
content.Parent = win
local function createOptionRow(parent, yPos, labelText, controlWidget)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,-20,0,40)
    row.Position = UDim2.new(0.02,0,0,yPos)
    row.BackgroundColor3 = Color3.fromRGB(45,45,45)
    row.BorderSizePixel = 0
    row.Parent = parent
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5,0,1,0)
    label.Position = UDim2.new(0.02,0,0,0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(220,220,220)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextScaled = true
    label.Font = Enum.Font.SourceSans
    label.Parent = row
    if controlWidget then
        controlWidget.Parent = row
        controlWidget.Size = UDim2.new(0,120,1,0)
        controlWidget.Position = UDim2.new(1,-130,0,0)
    end
    return row
end
local function clearContent()
    for _, child in ipairs(content:GetChildren()) do
        child:Destroy()
    end
end

-- 通用（含防传送 + 彩虹天空盒，已修复ID）
local antiTeleport = false
local lastPos = nil
local skyboxEnabled = false
local origSky = {}
local function showGeneral()
    clearContent()
    local minBtn = Instance.new("TextButton")
    minBtn.BackgroundColor3 = Color3.fromRGB(200,200,200)
    minBtn.Text = "最小化"
    minBtn.TextColor3 = Color3.fromRGB(0,0,0)
    minBtn.TextScaled = true
    minBtn.Font = Enum.Font.SourceSans
    local row1 = createOptionRow(content,10,"窗口控制",minBtn)
    minBtn.MouseButton1Click:Connect(function()
        win.Visible = false
        ball.Visible = true
    end)
    local antiBtn = Instance.new("TextButton")
    antiBtn.BackgroundColor3 = antiTeleport and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,50,50)
    antiBtn.Text = antiTeleport and "防传送 (开)" or "防传送 (关)"
    antiBtn.TextColor3 = Color3.fromRGB(255,255,255)
    antiBtn.TextScaled = true
    antiBtn.Font = Enum.Font.SourceSans
    local row2 = createOptionRow(content,60,"防传送",antiBtn)
    antiBtn.MouseButton1Click:Connect(function()
        antiTeleport = not antiTeleport
        antiBtn.Text = antiTeleport and "防传送 (开)" or "防传送 (关)"
        antiBtn.BackgroundColor3 = antiTeleport and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,50,50)
        if antiTeleport and rp then lastPos = rp.Position else lastPos = nil end
        print("防传送状态:", antiTeleport and "开启" or "关闭")
    end)
    local skyBtn = 
