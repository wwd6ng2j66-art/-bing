-- ============================================================
-- wk 脚本 v2.9（完整修复 · 手机适配 · 跑马灯边框 · 虚拟摇杆飞行）
-- 修复/改动：
--   1) 加载界面改用 PlayerGui 父级，避免 CoreGui 权限报错
--   2) 主窗口边框加跑马灯（流动彩虹边框动画）
--   3) 移除【分析】页，导航恢复为 通用/飞行/战斗/传送
--   4) 飞行开关开启后弹出独立【移动控制盘】（虚拟摇杆）
--      - 摇杆控制飞行方向（前后左右）
--      - 右侧加速滑块/按钮控制速度
--      - 上升/下降按钮
--      - 适配手机触屏，PC 也可用鼠标拖摇杆
-- ============================================================

-- ==================== 服务与工具 ====================
local p = game:GetService("Players").LocalPlayer
local u = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local ws = game:GetService("Workspace")

local function getRP()
	local char = p.Character
	if char then return char:FindFirstChild("HumanoidRootPart") end
	return nil
end
local rp = getRP()
p.CharacterAdded:Connect(function(c)
	c:WaitForChild("HumanoidRootPart")
	rp = c:FindFirstChild("HumanoidRootPart")
end)

local isTouch = u.TouchEnabled

-- ==================== 加载界面（3秒） ====================
local loadGui = Instance.new("ScreenGui")
loadGui.Name = "LoadGUI"
loadGui.ResetOnSpawn = false
loadGui.Parent = p:WaitForChild("PlayerGui") -- 直接用 PlayerGui，避免 CoreGui 权限问题

local bg = Instance.new("Frame")
bg.Size = UDim2.new(1,0,1,0)
bg.BackgroundColor3 = Color3.fromRGB(0,0,0)
bg.BackgroundTransparency = 0.55
bg.Parent = loadGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = isTouch and UDim2.new(0.9,0,0,260) or UDim2.new(0,400,0,280)
mainFrame.Position = UDim2.new(0.5,-(isTouch and 0 or 200),0.5,-140)
mainFrame.AnchorPoint = isTouch and Vector2.new(0.5,0.5) or Vector2.new(0,0)
mainFrame.BackgroundColor3 = Color3.fromRGB(18,18,18)
mainFrame.BackgroundTransparency = 0.25
mainFrame.BorderSizePixel = 0
mainFrame.Parent = bg
-- 加载框也加个简易彩虹边框（外层略大一圈的彩色底框）
local loadBorder = Instance.new("Frame")
loadBorder.Size = UDim2.new(1,6,1,6); loadBorder.Position = UDim2.new(0,-3,0,-3)
loadBorder.ZIndex = -1; loadBorder.BackgroundColor3 = Color3.fromRGB(0,120,255)
loadBorder.BorderSizePixel = 0; loadBorder.Parent = mainFrame
local loadGrad = Instance.new("UIGradient"); loadGrad.Parent = loadBorder
loadGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
	ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255,255,0)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,0)),
	ColorSequenceKeypoint.new(0.75, Color3.fromRGB(0,0,255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,255)),
})
-- 让加载框底框随跑马灯旋转色相
task.spawn(function()
	local h = 0
	while loadBorder and loadBorder.Parent do
		h = (h + 0.02) % 1
		loadBorder.BackgroundColor3 = Color3.fromHSV(h,1,1)
		task.wait(0.03)
	end
end)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,56); title.Position = UDim2.new(0,0,0.1,0)
title.BackgroundTransparency = 1; title.Text = "wk 脚本"
title.TextColor3 = Color3.fromRGB(255,255,255); title.TextScaled = true
title.Font = Enum.Font.GothamBold; title.Parent = mainFrame

local sub = Instance.new("TextLabel")
sub.Size = UDim2.new(1,0,0,36); sub.Position = UDim2.new(0,0,0.3,0)
sub.BackgroundTransparency = 1; sub.Text = "V2.9 · 正在处理数据"
sub.TextColor3 = Color3.fromRGB(200,200,200); sub.TextScaled = true
sub.Font = Enum.Font.SourceSans; sub.Parent = mainFrame

local progText = Instance.new("TextLabel")
progText.Size = UDim2.new(1,0,0,36); progText.Position = UDim2.new(0,0,0.48,0)
progText.BackgroundTransparency = 1; progText.Text = "正在初始化引擎..0%"
progText.TextColor3 = Color3.fromRGB(255,255,255); progText.TextScaled = true
progText.Font = Enum.Font.SourceSans; progText.Parent = mainFrame

local barBg = Instance.new("Frame")
barBg.Size = UDim2.new(0.8,0,0,18); barBg.Position = UDim2.new(0.1,0,0.66,0)
barBg.BackgroundColor3 = Color3.fromRGB(50,50,50); barBg.BorderSizePixel = 0; barBg.Parent = mainFrame

local bar = Instance.new("Frame")
bar.Size = UDim2.new(0,0,1,0); bar.BackgroundColor3 = Color3.fromRGB(0,120,255)
bar.BorderSizePixel = 0; bar.Parent = barBg

local timerLabel = Instance.new("TextLabel")
timerLabel.Size = UDim2.new(1,0,0,28); timerLabel.Position = UDim2.new(0,0,0.82,0)
timerLabel.BackgroundTransparency = 1; timerLabel.Text = "3.00s"
timerLabel.TextColor3 = Color3.fromRGB(150,150,150); timerLabel.TextScaled = true
timerLabel.Font = Enum.Font.SourceSans; timerLabel.Parent = mainFrame

local startTime = tick(); local duration = 3; local elapsed = 0
while elapsed < duration do
	elapsed = tick() - startTime
	local progress = math.min(elapsed / duration, 1)
	bar.Size = UDim2.new(progress, 0, 1, 0)
	progText.Text = "正在初始化引擎.." .. math.floor(progress*100) .. "%"
	timerLabel.Text = string.format("%.2fs", duration - elapsed)
	task.wait(0.03)
end
bar.Size = UDim2.new(1,0,1,0); progText.Text = "正在初始化引擎..100%"; timerLabel.Text = "0.00s"
task.wait(0.2); loadGui:Destroy()

-- ==================== 主 GUI ====================
local g = Instance.new("ScreenGui")
g.Name = "WkGUI"; g.ResetOnSpawn = false
g.Parent = p:WaitForChild("PlayerGui")

-- ==================== 彩色悬浮球 ====================
local ball = Instance.new("TextButton")
ball.Size = UDim2.new(0,96,0,72)
ball.Position = UDim2.new(0.5,-48,0.5,-36)
ball.BackgroundColor3 = Color3.fromRGB(255,255,255); ball.BackgroundTransparency = 0
ball.Text = "WK脚本"; ball.TextColor3 = Color3.fromRGB(0,0,0)
ball.TextScaled = true; ball.Font = Enum.Font.SourceSansBold; ball.Parent = g
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
	ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255,255,0)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,0)),
	ColorSequenceKeypoint.new(0.75, Color3.fromRGB(0,0,255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,255)),
})
gradient.Parent = ball

local drag = false; local dragStart, posStart
ball.InputBegan:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
		drag = true; dragStart = inp.Position; posStart = ball.Position
	end
end)
ball.InputChanged:Connect(function(inp)
	if drag and (inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseMovement) then
		local delta = inp.Position - dragStart
		ball.Position = UDim2.new(posStart.X.Scale, posStart.X.Offset+delta.X, posStart.Y.Scale, posStart.Y.Offset+delta.Y)
	end
end)
ball.InputEnded:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
end)

-- ==================== 主窗口 ====================
local win = Instance.new("Frame")
win.Size = isTouch and UDim2.new(1,0,1,0) or UDim2.new(0,420,0,520)
win.Position = isTouch and UDim2.new(0,0,0,0) or UDim2.new(0.5,-210,0.5,-260)
win.BackgroundColor3 = Color3.fromRGB(30,30,30); win.BackgroundTransparency = 0.15
win.BorderSizePixel = 0; win.Visible = false; win.Parent = g

-- ===== 跑马灯边框（主窗口） =====
-- 用四个彩色边条（上/下/左/右）+ 一个 Heartbeat 驱动的颜色循环实现流动效果
local borderFrames = {}
local function makeBorder(name, size, pos, z)
	local f = Instance.new("Frame")
	f.Name = name; f.Size = size; f.Position = pos; f.ZIndex = z or 2
	f.BackgroundColor3 = Color3.fromRGB(255,0,0); f.BorderSizePixel = 0; f.Parent = win
	return f
end
borderFrames.top = makeBorder("BTop", UDim2.new(1,0,0,3), UDim2.new(0,0,0,0))
borderFrames.bot = makeBorder("BBot", UDim2.new(1,0,0,3), UDim2.new(0,0,1,-3))
borderFrames.lef = makeBorder("BLef", UDim2.new(0,3,1,0), UDim2.new(0,0,0,0))
borderFrames.rig = makeBorder("BRig", UDim2.new(0,3,1,0), UDim2.new(1,-3,0,0))
local marqueeHue = 0
rs.Heartbeat:Connect(function(dt)
	marqueeHue = (marqueeHue + dt*0.6) % 1
	-- 四边按相位差形成"流动"效果
	borderFrames.top.BackgroundColor3 = Color3.fromHSV(marqueeHue, 1, 1)
	borderFrames.bot.BackgroundColor3 = Color3.fromHSV((marqueeHue+0.5)%1, 1, 1)
	borderFrames.lef.BackgroundColor3 = Color3.fromHSV((marqueeHue+0.25)%1, 1, 1)
	borderFrames.rig.BackgroundColor3 = Color3.fromHSV((marqueeHue+0.75)%1, 1, 1)
end)

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1,0,0,44); titleBar.BackgroundColor3 = Color3.fromRGB(50,50,50); titleBar.Parent = win
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0.8,0,1,0); titleLabel.BackgroundTransparency = 1
titleLabel.Text = "wk 辅助 v2.9"; titleLabel.TextColor3 = Color3.fromRGB(255,255,255)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left; titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.SourceSans; titleLabel.Parent = titleBar
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0,44,0,44); closeBtn.Position = UDim2.new(1,-44,0,0)
closeBtn.BackgroundTransparency = 1; closeBtn.Text = "×"; closeBtn.TextColor3 = Color3.fromRGB(255,80,80)
closeBtn.TextScaled = true; closeBtn.Font = Enum.Font.SourceSans; closeBtn.Parent = titleBar
closeBtn.MouseButton1Click:Connect(function() win.Visible = false; ball.Visible = true end)
ball.MouseButton1Click:Connect(function() win.Visible = true; ball.Visible = false end)

local winDrag = false; local winDragStart, winPosStart
titleBar.InputBegan:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
		winDrag = true; winDragStart = inp.Position; winPosStart = win.Position
	end
end)
titleBar.InputChanged:Connect(function(inp)
	if winDrag and (inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseMovement) then
		local delta = inp.Position - winDragStart
		win.Position = UDim2.new(winPosStart.X.Scale, winPosStart.X.Offset+delta.X, winPosStart.Y.Scale, winPosStart.Y.Offset+delta.Y)
	end
end)
titleBar.InputEnded:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then winDrag = false end
end)

-- ==================== 导航栏（手机底部横排，PC 左侧竖排） ====================
local nav
if isTouch then
	nav = Instance.new("Frame")
	nav.Size = UDim2.new(1,0,0,52); nav.Position = UDim2.new(0,0,1,-52)
	nav.BackgroundColor3 = Color3.fromRGB(25,25,25); nav.BorderSizePixel = 0; nav.Parent = win
else
	nav = Instance.new("Frame")
	nav.Size = UDim2.new(0,100,1,-44); nav.Position = UDim2.new(0,0,0,44)
	nav.BackgroundColor3 = Color3.fromRGB(25,25,25); nav.BorderSizePixel = 0; nav.Parent = win
end

local navItems = {"通用","飞行","战斗","传送"}
local navBtns = {}
local function createNavBtn(text, idx)
	local btn = Instance.new("TextButton")
	if isTouch then
		btn.Size = UDim2.new(1/#navItems,0,1,0)
		btn.Position = UDim2.new(idx/#navItems,0,0,0)
	else
		btn.Size = UDim2.new(1,0,0,44)
		btn.Position = UDim2.new(0,0,0, idx*49+5)
	end
	btn.BackgroundColor3 = Color3.fromRGB(40,40,40); btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255,255,255); btn.TextScaled = true; btn.Font = Enum.Font.SourceSans; btn.Parent = nav
	return btn
end
for i, name in ipairs(navItems) do navBtns[name] = createNavBtn(name, i-1) end

-- 内容区
local content = Instance.new("Frame")
if isTouch then
	content.Size = UDim2.new(1,0,1,-96); content.Position = UDim2.new(0,0,0,44)
else
	content.Size = UDim2.new(1,-110,1,-44); content.Position = UDim2.new(0,105,0,44)
end
content.BackgroundColor3 = Color3.fromRGB(35,35,35); content.BorderSizePixel = 0; content.Parent = win

local function createOptionRow(parent, yPos, labelText, controlWidget)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1,-16,0,46); row.Position = UDim2.new(0.02,0,0,yPos)
	row.BackgroundColor3 = Color3.fromRGB(45,45,45); row.BorderSizePixel = 0; row.Parent = parent
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.55,0,1,0); label.Position = UDim2.new(0.02,0,0,0)
	label.BackgroundTransparency = 1; label.Text = labelText
	label.TextColor3 = Color3.fromRGB(220,220,220); label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextScaled = true; label.Font = Enum.Font.SourceSans; label.Parent = row
	if controlWidget then
		controlWidget.Parent = row
		controlWidget.Size = UDim2.new(0,130,1,0); controlWidget.Position = UDim2.new(1,-135,0,0)
	end
	return row
end
local function clearContent()
	for _, child in ipairs(content:GetChildren()) do child:Destroy() end
end

-- ==================== 功能状态 ====================
local antiTeleport = false; local lastPos = nil
local skyboxEnabled = false; local origSky = nil; local rainbowConn = nil; local currentSky = nil
local flyEnabled = false; local flySpeed = 50; local flyBodyVel = nil; local flyBodyGyro = nil
local noclipEnabled = false; local espEnabled = false

-- ==================== 天空盒 ====================
local function saveOriginalSky()
	if not origSky then
		origSky = Lighting:FindFirstChildOfClass("Sky")
		if origSky then origSky.Parent = nil end
	end
end
local function restoreSky()
	if origSky then origSky.Parent = Lighting; origSky = nil end
end
local function makeRainbowSky()
	local sky = Instance.new("Sky"); sky.Name = "WkRainbowSky"
	local id = "rbxassetid://8567812061"
	sky.SkyboxBk = id; sky.SkyboxDn = id; sky.SkyboxFt = id; sky.SkyboxLf = id; sky.SkyboxRt = id; sky.SkyboxUp = id
	return sky
end
local hue = 0
local function startRainbowSky()
	saveOriginalSky()
	if currentSky then currentSky:Destroy() end
	currentSky = makeRainbowSky(); currentSky.Parent = Lighting
	if rainbowConn then rainbowConn:Disconnect() end
	rainbowConn = rs.Heartbeat:Connect(function(dt)
		hue = (hue + dt*0.5) % 1
		pcall(function() Lighting.Ambient = Color3.fromHSV(hue,1,1) end)
	end)
end
local function stopRainbowSky()
	if rainbowConn then rainbowConn:Disconnect() rainbowConn = nil end
	if currentSky then currentSky:Destroy() currentSky = nil end
	pcall(function() Lighting.Ambient = Color3.fromRGB(127,127,127) end)
	restoreSky()
end

-- ==================== 飞行 ====================
local function startFly()
	rp = getRP(); if not rp then return false end
	if flyBodyVel then flyBodyVel:Destroy() end
	if flyBodyGyro then flyBodyGyro:Destroy() end
	flyBodyVel = Instance.new("BodyVelocity"); flyBodyVel.MaxForce = Vector3.new(1e5,1e5,1e5)
	flyBodyVel.Velocity = Vector3.new(0,0,0); flyBodyVel.Parent = rp
	flyBodyGyro = Instance.new("BodyGyro"); flyBodyGyro.MaxTorque = Vector3.new(1e5,1e5,1e5)
	flyBodyGyro.CFrame = rp.CFrame; flyBodyGyro.Parent = rp
	flyEnabled = true; return true
end
local function stopFly()
	flyEnabled = false
	if flyBodyVel then flyBodyVel:Destroy() flyBodyVel = nil end
	if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
end

-- 飞行输入：键盘（PC）+ 摇杆（手机）
local flyKeys = {W=false,A=false,S=false,D=false,Up=false,Down=false}
u.InputBegan:Connect(function(inp)
	if not flyEnabled then return end
	if inp.UserInputType == Enum.UserInputType.Keyboard then
		local k = inp.KeyCode
		if k == Enum.KeyCode.W then flyKeys.W = true end
		if k == Enum.KeyCode.S then flyKeys.S = true end
		if k == Enum.KeyCode.A then flyKeys.A = true end
		if k == Enum.KeyCode.D then flyKeys.D = true end
		if k == Enum.KeyCode.Space then flyKeys.Up = true end
		if k == Enum.KeyCode.LeftShift then flyKeys.Down = true end
	end
end)
u.InputEnded:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.Keyboard then
		local k = inp.KeyCode
		if k == Enum.KeyCode.W then flyKeys.W = false end
		if k == Enum.KeyCode.S then flyKeys.S = false end
		if k == Enum.KeyCode.A then flyKeys.A = false end
		if k == Enum.KeyCode.D then flyKeys.D = false end
		if k == Enum.KeyCode.Space then flyKeys.Up = false end
		if k == Enum.KeyCode.LeftShift then flyKeys.Down = false end
	end
end)

-- ==================== 虚拟摇杆移动控制盘（飞行开启后弹出） ====================
local joyGui = Instance.new("ScreenGui"); joyGui.Name = "WkJoystick"; joyGui.ResetOnSpawn = false; joyGui.Parent = g
joyGui.Enabled = false

-- 摇杆基座（左下）
local stickBase = Instance.new("Frame"); stickBase.Name = "StickBase"
stickBase.Size = UDim2.new(0,150,0,150); stickBase.Position = UDim2.new(0.02,0,1,-170)
stickBase.BackgroundColor3 = Color3.fromRGB(40,40,40); stickBase.BackgroundTransparency = 0.4
stickBase.BorderSizePixel = 0; stickBase.Parent = joyGui
local stickCorner = Instance.new("UICorner"); stickCorner.CornerRadius = UDim.new(0.5,0); stickCorner.Parent = stickBase
local stickBtn = Instance.new("Frame"); stickBtn.Name = "Stick"
stickBtn.Size = UDim2.new(0,60,0,60); stickBtn.Position = UDim2.new(0.5,-30,0.5,-30)
stickBtn.BackgroundColor3 = Color3.fromRGB(0,120,255); stickBtn.BorderSizePixel = 0; stickBtn.Parent = stickBase
local stickBtnCorner = Instance.new("UICorner"); stickBtnCorner.CornerRadius = UDim.new(0.5,0); stickBtnCorner.Parent = stickBtn

-- 摇杆输入状态（-1~1）
local joyX, joyY = 0, 0
local stickDragging = false; local stickDragStart
stickBase.InputBegan:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
		stickDragging = true; stickDragStart = inp.Position
	end
end)
u.InputChanged:Connect(function(inp)
	if stickDragging and (inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseMovement) then
		local delta = inp.Position - stickDragStart
		local r = 45 -- 摇杆活动半径
		local dx = math.max(-r, math.min(r, delta.X))
		local dy = math.max(-r, math.min(r, delta.Y))
		stickBtn.Position = UDim2.new(0.5, -30+dx, 0.5, -30+dy)
		joyX = dx / r; joyY = dy / r
	end
end)
u.InputEnded:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
		stickDragging = false; joyX, joyY = 0, 0
		stickBtn.Position = UDim2.new(0.5,-30,0.5,-30)
	end
end)

-- 右侧控制列：加速 / 减速 / 上升 / 下降 / 关闭盘
local function mkJoyBtn(name, y, text, color)
	local b = Instance.new("TextButton"); b.Name = name
	b.Size = UDim2.new(0,80,0,44); b.Position = UDim2.new(1,-90,0,y)
	b.BackgroundColor3 = color; b.Text = text; b.TextColor3 = Color3.fromRGB(255,255,255)
	b.TextScaled = true; b.Font = Enum.Font.SourceSansBold; b.Parent = joyGui
	return b
end
local btnUp = mkJoyBtn("BtnUp", 0.5,-190, "上升", Color3.fromRGB(0,120,255))
local btnDown = mkJoyBtn("BtnDown", 0.5,-140, "下降", Color3.fromRGB(120,120,120))
local btnFaster = mkJoyBtn("BtnFaster", 0.5,-80, "加速+", Color3.fromRGB(0,180,0))
local btnSlower = mkJoyBtn("BtnSlower", 0.5,-30, "减速-", Color3.fromRGB(180,120,0))
local btnClose = mkJoyBtn("BtnClose", 0.5,20, "关闭盘", Color3.fromRGB(200,50,50))
btnUp.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.Touch or inp.UserInputType==Enum.UserInputType.MouseButton1 then flyKeys.Up=true end end)
btnUp.InputEnded:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.Touch or inp.UserInputType==Enum.UserInputType.MouseButton1 then flyKeys.Up=false end end)
btnDown.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.Touch or inp.UserInputType==Enum.UserInputType.MouseButton1 then flyKeys.Down=true end end)
btnDown.InputEnded:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.Touch or inp.UserInputType==Enum.UserInputType.MouseButton1 then flyKeys.Down=false end end)
btnFaster.MouseButton1Click:Connect(function() flySpeed = math.min(flySpeed+10, 200) end)
btnSlower.MouseButton1Click:Connect(function() flySpeed = math.max(flySpeed-10, 10) end)
btnClose.MouseButton1Click:Connect(function() joyGui.Enabled = false end)

-- 当前速度显示
local speedDisp = Instance.new("TextLabel")
speedDisp.Size = UDim2.new(0,80,0,28); speedDisp.Position = UDim2.new(1,-90,0,0.5,-218)
speedDisp.BackgroundColor3 = Color3.fromRGB(60,60,60); speedDisp.TextColor3 = Color3.fromRGB(255,255,255)
speedDisp.TextScaled = true; speedDisp.Font = Enum.Font.SourceSans; speedDisp.Text = "速度:"..flySpeed
speedDisp.Parent = joyGui

-- 飞行 Heartbeat：键盘 + 摇杆合成
rs.Heartbeat:Connect(function()
	if flyEnabled and rp and flyBodyVel then
		local cam = ws.CurrentCamera
		local move = Vector3.new(0,0,0)
		-- 键盘
		if flyKeys.W then move = move + cam.CFrame.LookVector end
		if flyKeys.S then move = move - cam.CFrame.LookVector end
		if flyKeys.A then move = move - cam.CFrame.RightVector end
		if flyKeys.D then move = move + cam.CFrame.RightVector end
		-- 摇杆：joyX 右为正，joyY 前为正（UI 坐标需取反 Y）
		if joyX ~= 0 or joyY ~= 0 then
			move = move + cam.CFrame.RightVector * joyX + cam.CFrame.LookVector * (-joyY)
		end
		if flyKeys.Up then move = move + Vector3.new(0,1,0) end
		if flyKeys.Down then move = move - Vector3.new(0,1,0) end
		if move.Magnitude > 0 then move = move.Unit end
		flyBodyVel.Velocity = move * flySpeed
		flyBodyGyro.CFrame = cam.CFrame
		-- 刷新速度显示
		if speedDisp and speedDisp.Parent then speedDisp.Text = "速度:"..flySpeed end
	end
end)

-- ==================== 防传送 ====================
rs.Heartbeat:Connect(function()
	if antiTeleport then
		rp = getRP()
		if rp then
			if lastPos and (rp.Position - lastPos).Magnitude > 50 then
				rp.CFrame = CFrame.new(lastPos)
			end
			lastPos = rp.Position
		end
	end
end)

-- ==================== Noclip ====================
rs.Stepped:Connect(function()
	if noclipEnabled and p.Character then
		for _, part in ipairs(p.Character:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = false end
		end
	end
end)

-- ==================== ESP ====================
local espFolder = Instance.new("Folder", g); espFolder.Name = "ESP"
local espTable = {}
local function refreshESP()
	for _, v in pairs(espTable) do if v and v.Destroy then v:Destroy() end end
	espTable = {}
	if not espEnabled then return end
	for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
		if plr ~= p and plr.Character and plr.Character:FindFirstChild("Head") then
			local bill = Instance.new("BillboardGui")
			bill.Size = UDim2.new(0,120,0,44); bill.Adornee = plr.Character.Head; bill.AlwaysOnTop = true
			local tl = Instance.new("TextLabel", bill)
			tl.Size = UDim2.new(1,0,1,0); tl.BackgroundTransparency = 1; tl.Text = plr.Name
			tl.TextColor3 = Color3.fromRGB(255,50,50); tl.TextScaled = true; tl.Font = Enum.Font.SourceSansBold
			bill.Parent = espFolder; table.insert(espTable, bill)
		end
	end
end

-- ==================== 传送扫描 ====================
local teleTargets = {}
local function scanTeleports()
	teleTargets = {}
	for _, obj in ipairs(ws:GetDescendants()) do
		if obj:IsA("BasePart") and obj.Name:lower():find("teleport") then
			table.insert(teleTargets, obj)
		end
	end
end

-- ==================== 页面：通用 ====================
local function showGeneral()
	clearContent()
	local minBtn = Instance.new("TextButton")
	minBtn.BackgroundColor3 = Color3.fromRGB(200,200,200); minBtn.Text = "最小化"
	minBtn.TextColor3 = Color3.fromRGB(0,0,0); minBtn.TextScaled = true; minBtn.Font = Enum.Font.SourceSans
	createOptionRow(content,10,"窗口控制",minBtn)
	minBtn.MouseButton1Click:Connect(function() win.Visible = false; ball.Visible = true end)

	local antiBtn = Instance.new("TextButton")
	antiBtn.BackgroundColor3 = antiTeleport and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,50,50)
	antiBtn.Text = antiTeleport and "防传送 (开)" or "防传送 (关)"
	antiBtn.TextColor3 = Color3.fromRGB(255,255,255); antiBtn.TextScaled = true; antiBtn.Font = Enum.Font.SourceSans
	createOptionRow(content,66,"防传送",antiBtn)
	antiBtn.MouseButton1Click:Connect(function()
		antiTeleport = not antiTeleport
		antiBtn.Text = antiTeleport and "防传送 (开)" or "防传送 (关)"
		antiBtn.BackgroundColor3 = antiTeleport and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,50,50)
		rp = getRP(); lastPos = (antiTeleport and rp) and rp.Position or nil
	end)

	local skyBtn = Instance.new("TextButton")
	skyBtn.BackgroundColor3 = skyboxEnabled and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,50,50)
	skyBtn.Text = skyboxEnabled and "彩虹天空 (开)" or "彩虹天空 (关)"
	skyBtn.TextColor3 = Color3.fromRGB(255,255,255); skyBtn.TextScaled = true; skyBtn.Font = Enum.Font.SourceSans
	createOptionRow(content,122,"彩虹天空",skyBtn)
	skyBtn.MouseButton1Click:Connect(function()
		skyboxEnabled = not skyboxEnabled
		skyBtn.Text = skyboxEnabled and "彩虹天空 (开)" or "彩虹天空 (关)"
		skyBtn.BackgroundColor3 = skyboxEnabled and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,50,50)
		if skyboxEnabled then startRainbowSky() else stopRainbowSky() end
	end)

	local ncBtn = Instance.new("TextButton")
	ncBtn.BackgroundColor3 = noclipEnabled and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,50,50)
	ncBtn.Text = noclipEnabled and "穿墙 (开)" or "穿墙 (关)"
	ncBtn.TextColor3 = Color3.fromRGB(255,255,255); ncBtn.TextScaled = true; ncBtn.Font = Enum.Font.SourceSans
	createOptionRow(content,178,"穿墙",ncBtn)
	ncBtn.MouseButton1Click:Connect(function()
		noclipEnabled = not noclipEnabled
		ncBtn.Text = noclipEnabled and "穿墙 (开)" or "穿墙 (关)"
		ncBtn.BackgroundColor3 = noclipEnabled and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,50,50)
	end)
end

-- ==================== 页面：飞行 ====================
local function showFly()
	clearContent()
	local flyBtn = Instance.new("TextButton")
	flyBtn.BackgroundColor3 = flyEnabled and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,50,50)
	flyBtn.Text = flyEnabled and "飞行 (开)" or "飞行 (关)"
	flyBtn.TextColor3 = Color3.fromRGB(255,255,255); flyBtn.TextScaled = true; flyBtn.Font = Enum.Font.SourceSans
	createOptionRow(content,10,"飞行开关",flyBtn)
	flyBtn.MouseButton1Click:Connect(function()
		if flyEnabled then
			stopFly(); joyGui.Enabled = false
		else
			if startFly() then joyGui.Enabled = true end
		end
		flyBtn.Text = flyEnabled and "飞行 (开)" or "飞行 (关)"
		flyBtn.BackgroundColor3 = flyEnabled and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,50,50)
	end)

	-- 速度显示 + 加减（手机也可用按钮）
	local spdLabel = Instance.new("TextLabel")
	spdLabel.Size = UDim2.new(0,130,1,0); spdLabel.Position = UDim2.new(1,-135,0,0)
	spdLabel.BackgroundColor3 = Color3.fromRGB(60,60,60); spdLabel.TextColor3 = Color3.fromRGB(255,255,255)
	spdLabel.TextScaled = true; spdLabel.Font = Enum.Font.SourceSans; spdLabel.Text = tostring(flySpeed)
	local rowSpd = createOptionRow(content,66,"速度")
	spdLabel.Parent = rowSpd
	local plusBtn = Instance.new("TextButton")
	plusBtn.Size = UDim2.new(0,44,1,0); plusBtn.Position = UDim2.new(1,-44,0,0)
	plusBtn.BackgroundColor3 = Color3.fromRGB(0,120,255); plusBtn.Text = "+"
	plusBtn.TextColor3 = Color3.fromRGB(255,255,255); plusBtn.TextScaled = true; plusBtn.Font = Enum.Font.SourceSans; plusBtn.Parent = rowSpd
	plusBtn.MouseButton1Click:Connect(function() flySpeed = math.min(flySpeed+10,200); spdLabel.Text = tostring(flySpeed) end)
	local minusBtn = Instance.new("TextButton")
	minusBtn.Size = UDim2.new(0,44,1,0); minusBtn.Position = UDim2.new(1,-89,0,0)
	minusBtn.BackgroundColor3 = Color3.fromRGB(120,120,120); minusBtn.Text = "-"
	minusBtn.TextColor3 = Color3.fromRGB(255,255,255); minusBtn.TextScaled = true; minusBtn.Font = Enum.Font.SourceSans; minusBtn.Parent = rowSpd
	minusBtn.MouseButton1Click:Connect(function() flySpeed = math.max(flySpeed-10,10); spdLabel.Text = tostring(flySpeed) end)

	local tip = Instance.new("TextLabel")
	tip.Size = UDim2.new(1,-16,0,60); tip.Position = UDim2.new(0.02,0,0,122)
	tip.BackgroundTransparency = 1; tip.TextColor3 = Color3.fromRGB(180,180,180); tip.TextScaled = true; tip.Font = Enum.Font.SourceSans
	tip.Text = isTouch
		and "飞行开启后会弹出【移动控制盘】\n用左下摇杆控制方向，右侧按钮加速/升降"
		or "飞行开启后弹出移动控制盘（摇杆+加速）\nPC 也可用 WASD+空格/Shift 操控"
	tip.Parent = content
end

-- ==================== 页面：战斗 ====================
local function showCombat()
	clearContent()
	local espBtn = Instance.new("TextButton")
	espBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,50,50)
	espBtn.Text = espEnabled and "玩家ESP (开)" or "玩家ESP (关)"
	espBtn.TextColor3 = Color3.fromRGB(255,255,255); espBtn.TextScaled = true; espBtn.Font = Enum.Font.SourceSans
	createOptionRow(content,10,"玩家ESP",espBtn)
	espBtn.MouseButton1Click:Connect(function()
		espEnabled = not espEnabled
		espBtn.Text = espEnabled and "玩家ESP (开)" or "玩家ESP (关)"
		espBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,50,50)
		refreshESP()
	end)
	local refreshBtn = Instance.new("TextButton")
	refreshBtn.BackgroundColor3 = Color3.fromRGB(0,120,255); refreshBtn.Text = "刷新ESP"
	refreshBtn.TextColor3 = Color3.fromRGB(255,255,255); refreshBtn.TextScaled = true; refreshBtn.Font = Enum.Font.SourceSans
	createOptionRow(content,66,"刷新列表",refreshBtn)
	refreshBtn.MouseButton1Click:Connect(function() if espEnabled then refreshESP() end end)
end

-- ==================== 页面：传送 ====================
local function showTele()
	clearContent()
	scanTeleports()
	if #teleTargets == 0 then
		local note = Instance.new("TextLabel")
		note.Size = UDim2.new(1,-16,0,46); note.Position = UDim2.new(0.02,0,0,10)
		note.BackgroundColor3 = Color3.fromRGB(45,45,45); note.TextColor3 = Color3.fromRGB(220,220,220)
		note.TextScaled = true; note.Font = Enum.Font.SourceSans; note.Text = "未找到名称含 'teleport' 的传送点"
		note.Parent = content
		return
	end
	local y = 10
	for i, target in ipairs(teleTargets) do
		if y > 420 then break end
		local tBtn = Instance.new("TextButton")
		tBtn.BackgroundColor3 = Color3.fromRGB(0,120,255); tBtn.Text = target.Name
		tBtn.TextColor3 = Color3.fromRGB(255,255,255); tBtn.TextScaled = true; tBtn.Font = Enum.Font.SourceSans
		createOptionRow(content, y, "传送到 "..target.Name, tBtn)
		tBtn.MouseButton1Click:Connect(function()
			rp = getRP()
			if rp then rp.CFrame = target.CFrame + Vector3.new(0,3,0) end
		end)
		y = y + 56
	end
end

-- ==================== 导航绑定 ====================
navBtns["通用"].MouseButton1Click:Connect(showGeneral)
navBtns["飞行"].MouseButton1Click:Connect(showFly)
navBtns["战斗"].MouseButton1Click:Connect(showCombat)
navBtns["传送"].MouseButton1Click:Connect(showTele)

-- 默认显示通用页
showGeneral()

print("[wk 脚本 v2.9] 已加载（加载UI修复 + 跑马灯边框 + 虚拟摇杆飞行控制盘）。")
