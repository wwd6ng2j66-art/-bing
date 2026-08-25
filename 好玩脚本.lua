--[[
	悬浮球 + 高级菜单 v2.5（彩色悬浮球，黑字"WK脚本"）【已修复完整版】
	修复内容：
		1) 原脚本 g(Parent) 在 rp/initChar 等使用前未定义 -> 统一在顶部定义服务与变量
		2) rp/h 通过 initChar 异步获取，所有使用 rp 的地方均做 nil 判断，避免 attempt to index nil
		3) 补全 showFly 末尾缺失的 updateSpeedLabel / +/- 按钮 / flyToggle 逻辑与函数闭合
		4) 鼠标拖动改用 UserInputService.InputChanged 全局监听，同时支持 Touch 与 Mouse
		5) 防传送增加基于 RenderStepped 的位移检测，rp 有效时才生效
		6) 补全 btnGeneral/btnFly 导航点击事件切换页面
		7) 标题栏拖动支持（原代码仅写了 Touch 分支，现统一走全局 InputChanged）
		8) 所有局部变量在使用前声明，避免 nil 报错
	功能：彩色渐变悬浮球（点击打开菜单） / 通用（最小化+防传送） / 飞行（开关+速度±） / 导航框架（战斗/传送占位）
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local p = Players.LocalPlayer
local pg = p:WaitForChild("PlayerGui")

-- 创建 GUI
local g = Instance.new("ScreenGui")
g.Name = "WkGUI"
g.ResetOnSpawn = false
g.Parent = pg

-- ===== 角色部件（异步等待）=====
local rp, h = nil, nil
local function initChar()
	local c = p.Character or p.CharacterAdded:Wait()
	rp = c:WaitForChild("HumanoidRootPart", 5)
	h = c:FindFirstChild("Humanoid")
end
spawn(initChar)
p.CharacterAdded:Connect(function(c)
	rp = c:WaitForChild("HumanoidRootPart", 5)
	h = c:FindFirstChild("Humanoid")
end)

-- ===== 彩色悬浮球 =====
local ball = Instance.new("TextButton")
ball.Size = UDim2.new(0, 80, 0, 60)
ball.Position = UDim2.new(0.5, -40, 0.5, -30)
ball.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ball.BackgroundTransparency = 0
ball.Text = "WK脚本"
ball.TextColor3 = Color3.fromRGB(0, 0, 0)
ball.TextScaled = true
ball.Font = Enum.Font.SourceSansBold
ball.Parent = g

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
	ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 255, 0)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 0)),
	ColorSequenceKeypoint.new(0.75, Color3.fromRGB(0, 0, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255)),
})
gradient.Parent = ball

-- 拖动悬浮球（全局监听，同时支持 Touch / Mouse）
local drag, dragStart, posStart = false, nil, nil
ball.InputBegan:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
		drag = true
		dragStart = inp.Position
		posStart = ball.Position
	end
end)
ball.InputEnded:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
		drag = false
	end
end)

-- ===== 主窗口（高级菜单）=====
local win = Instance.new("Frame")
win.Size = UDim2.new(0, 400, 0, 480)
win.Position = UDim2.new(0.5, -200, 0.5, -240)
win.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
win.BackgroundTransparency = 0.15
win.BorderSizePixel = 0
win.Visible = false
win.Parent = g

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
titleBar.Parent = win

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0.8, 0, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "wk 辅助 v2.0"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.SourceSans
titleLabel.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -44, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
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

-- 标题栏拖动
local winDrag, winDragStart, winPosStart = false, nil, nil
titleBar.InputBegan:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
		winDrag = true
		winDragStart = inp.Position
		winPosStart = win.Position
	end
end)
titleBar.InputEnded:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
		winDrag = false
	end
end)

-- 全局移动监听（同时驱动球与窗口拖动）
UserInputService.InputChanged:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
		if drag and dragStart then
			local delta = inp.Position - dragStart
			ball.Position = UDim2.new(posStart.X.Scale, posStart.X.Offset + delta.X, posStart.Y.Scale, posStart.Y.Offset + delta.Y)
		end
		if winDrag and winDragStart then
			local delta = inp.Position - winDragStart
			win.Position = UDim2.new(winPosStart.X.Scale, winPosStart.X.Offset + delta.X, winPosStart.Y.Scale, winPosStart.Y.Offset + delta.Y)
		end
	end
end)

-- ===== 左侧导航 =====
local nav = Instance.new("Frame")
nav.Size = UDim2.new(0, 100, 1, -40)
nav.Position = UDim2.new(0, 0, 0, 40)
nav.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
nav.BorderSizePixel = 0
nav.Parent = win

local function createNavBtn(text, yPos)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 40)
	btn.Position = UDim2.new(0, 0, 0, yPos)
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextScaled = true
	btn.Font = Enum.Font.SourceSans
	btn.Parent = nav
	return btn
end
local btnGeneral = createNavBtn("通用", 5)
local btnFly = createNavBtn("飞行", 50)
local btnCombat = createNavBtn("战斗", 95)
local btnTele = createNavBtn("传送", 140)

-- ===== 右侧内容 =====
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -110, 1, -50)
content.Position = UDim2.new(0, 105, 0, 45)
content.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
content.BorderSizePixel = 0
content.Parent = win

local function createOptionRow(parent, yPos, labelText, controlWidget)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -20, 0, 40)
	row.Position = UDim2.new(0.02, 0, 0, yPos)
	row.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	row.BorderSizePixel = 0
	row.Parent = parent

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.5, 0, 1, 0)
	label.Position = UDim2.new(0.02, 0, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = labelText
	label.TextColor3 = Color3.fromRGB(220, 220, 220)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextScaled = true
	label.Font = Enum.Font.SourceSans
	label.Parent = row

	if controlWidget then
		controlWidget.Parent = row
		controlWidget.Size = UDim2.new(0, 120, 1, 0)
		controlWidget.Position = UDim2.new(1, -130, 0, 0)
	end
	return row
end

local function clearContent()
	for _, child in ipairs(content:GetChildren()) do
		child:Destroy()
	end
end

-- ===== 通用（含防传送）=====
local antiTeleport = false
local lastPos = nil

local function showGeneral()
	clearContent()
	local minBtn = Instance.new("TextButton")
	minBtn.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
	minBtn.Text = "最小化"
	minBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
	minBtn.TextScaled = true
	minBtn.Font = Enum.Font.SourceSans
	createOptionRow(content, 10, "窗口控制", minBtn)
	minBtn.MouseButton1Click:Connect(function()
		win.Visible = false
		ball.Visible = true
	end)

	local antiBtn = Instance.new("TextButton")
	antiBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	antiBtn.Text = "防传送 (关)"
	antiBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	antiBtn.TextScaled = true
	antiBtn.Font = Enum.Font.SourceSans
	createOptionRow(content, 60, "防传送", antiBtn)
	antiBtn.MouseButton1Click:Connect(function()
		antiTeleport = not antiTeleport
		antiBtn.Text = antiTeleport and "防传送 (开)" or "防传送 (关)"
		antiBtn.BackgroundColor3 = antiTeleport and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 50, 50)
		if antiTeleport and rp then
			lastPos = rp.Position
		else
			lastPos = nil
		end
		print("防传送状态:", antiTeleport and "开启" or "关闭")
	end)

	local info = Instance.new("TextLabel")
	info.Size = UDim2.new(1, 0, 0, 30)
	info.Position = UDim2.new(0, 0, 0, 110)
	info.BackgroundTransparency = 1
	info.Text = "阻止其他脚本传送你（客户端）"
	info.TextColor3 = Color3.fromRGB(150, 150, 150)
	info.TextScaled = true
	info.Font = Enum.Font.SourceSans
	info.Parent = content
end

-- ===== 飞行 =====
local flying = false
local hSpeed = 50
local vSpeed = 30
local step = 5
local minSp = 10
local maxSp = 200
local bodyVel = nil

local function setFlying(state)
	flying = state
	if flying then
		if rp and not bodyVel then
			bodyVel = Instance.new("BodyVelocity")
			bodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
			bodyVel.Velocity = Vector3.new(0, 0, 0)
			bodyVel.Parent = rp
		end
	else
		if bodyVel then bodyVel:Destroy() bodyVel = nil end
	end
end

local function showFly()
	clearContent()
	local flyToggle = Instance.new("TextButton")
	flyToggle.BackgroundColor3 = Color3.fromRGB(30, 144, 255)
	flyToggle.Text = "飞行 (关)"
	flyToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
	flyToggle.TextScaled = true
	flyToggle.Font = Enum.Font.SourceSans
	createOptionRow(content, 10, "飞行状态", flyToggle)

	local spLabel = Instance.new("TextLabel")
	spLabel.Size = UDim2.new(0, 40, 1, 0)
	spLabel.Position = UDim2.new(0.5, -20, 0, 0)
	spLabel.BackgroundTransparency = 1
	spLabel.Text = tostring(hSpeed)
	spLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	spLabel.TextScaled = true
	spLabel.Font = Enum.Font.SourceSans

	local spMinus = Instance.new("TextButton")
	spMinus.Size = UDim2.new(0, 30, 1, 0)
	spMinus.Position = UDim2.new(0.1, 0, 0, 0)
	spMinus.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	spMinus.Text = "-"
	spMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
	spMinus.TextScaled = true
	spMinus.Font = Enum.Font.SourceSans

	local spPlus = Instance.new("TextButton")
	spPlus.Size = UDim2.new(0, 30, 1, 0)
	spPlus.Position = UDim2.new(0.7, 0, 0, 0)
	spPlus.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
	spPlus.Text = "+"
	spPlus.TextColor3 = Color3.fromRGB(255, 255, 255)
	spPlus.TextScaled = true
	spPlus.Font = Enum.Font.SourceSans

	local speedContainer = Instance.new("Frame")
	speedContainer.BackgroundTransparency = 1
	speedContainer.Size = UDim2.new(0, 120, 1, 0)
	speedContainer.Position = UDim2.new(1, -130, 0, 0)
	spMinus.Parent = speedContainer
	spLabel.Parent = speedContainer
	spPlus.Parent = speedContainer

	createOptionRow(content, 60, "飞行速度", speedContainer)

	local function updateSpeedLabel()
		spLabel.Text = tostring(hSpeed)
	end

	spMinus.MouseButton1Click:Connect(function()
		hSpeed = math.max(minSp, hSpeed - step)
		updateSpeedLabel()
	end)
	spPlus.MouseButton1Click:Connect(function()
		hSpeed = math.min(maxSp, hSpeed + step)
		updateSpeedLabel()
	end)
	updateSpeedLabel()

	flyToggle.MouseButton1Click:Connect(function()
		setFlying(not flying)
		flyToggle.Text = flying and "飞行 (开)" or "飞行 (关)"
		flyToggle.BackgroundColor3 = flying and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(30, 144, 255)
	end)
end

-- 占位页面
local function showPlaceholder(name)
	clearContent()
	local t = Instance.new("TextLabel")
	t.Size = UDim2.new(1, -20, 0, 40)
	t.Position = UDim2.new(0.02, 0, 0, 10)
	t.BackgroundTransparency = 1
	t.Text = name .. "（功能开发中）"
	t.TextColor3 = Color3.fromRGB(200, 200, 200)
	t.TextScaled = true
	t.Font = Enum.Font.SourceSans
	t.Parent = content
end

btnGeneral.MouseButton1Click:Connect(showGeneral)
btnFly.MouseButton1Click:Connect(showFly)
btnCombat.MouseButton1Click:Connect(function() showPlaceholder("战斗") end)
btnTele.MouseButton1Click:Connect(function() showPlaceholder("传送") end)

-- 默认显示通用页
showGeneral()

-- ===== 飞行驱动 + 防传送检测 =====
RunService.RenderStepped:Connect(function()
	if rp then
		-- 飞行：按相机朝向水平移动
		if flying and bodyVel then
			local cam = workspace.CurrentCamera
			local lv = cam and cam.CFrame.LookVector or Vector3.new(0,0,-1)
			lv = Vector3.new(lv.X, 0, lv.Z).Unit
			bodyVel.Velocity = lv * hSpeed
		end
		-- 防传送检测
		if antiTeleport and lastPos then
			if (rp.Position - lastPos).Magnitude > 15 then
				rp.CFrame = CFrame.new(lastPos)
			else
				lastPos = rp.Position
			end
		end
	end
end)
