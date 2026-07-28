-- =============================================
-- 0. 服务
-- =============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- 等 PlayerGui 就绪（关键！）
local guiParent = LocalPlayer:WaitForChild("PlayerGui")

-- =============================================
-- 1. ScreenGui（必须这样写）
-- =============================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "IceHackGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true          -- 不受状态栏遮挡
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling -- 防止被覆盖
screenGui.Parent = guiParent

-- =============================================
-- 2. 冰按钮（用 TextButton 代替 ImageButton，绝对可见）
-- =============================================
local iceBtn = Instance.new("TextButton")
iceBtn.Name = "IceButton"
iceBtn.Size = UDim2.fromOffset(70, 70)
iceBtn.Position = UDim2.fromOffset(30, 120)
iceBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 255) -- 冰蓝色
iceBtn.Text = "冰"
iceBtn.TextColor3 = Color3.fromRGB(0, 30, 60)
iceBtn.TextScaled = true
iceBtn.Font = Enum.Font.GothamBlack
iceBtn.Parent = screenGui

-- 圆形
local iceCorner = Instance.new("UICorner")
iceCorner.CornerRadius = UDim.new(1, 0)
iceCorner.Parent = iceBtn

-- 发光边框
local iceStroke = Instance.new("UIStroke")
iceStroke.Color = Color3.fromRGB(200, 240, 255)
iceStroke.Thickness = 3
iceStroke.Parent = iceBtn

-- 呼吸动画（让按钮明显可见）
spawn(function()
	local t = 0
	while iceBtn and iceBtn.Parent do
		t += 0.05
		local pulse = 0.5 + 0.5 * math.sin(t)
		iceBtn.BackgroundColor3 = Color3.new(
			0.4 + pulse * 0.3,
			0.8,
			1
		)
		task.wait(0.03)
	end
end)

-- =============================================
-- 3. 拖拽（修正版）
-- =============================================
local dragging = false
local dragStartPos, btnStartPos

iceBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch
	or input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStartPos = input.Position
		btnStartPos = iceBtn.Position
	end
end)

iceBtn.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch
	or input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (
		input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseMovement
	) then
		local delta = input.Position - dragStartPos
		local newX = btnStartPos.X.Offset + delta.X
		local newY = btnStartPos.Y.Offset + delta.Y
		local sw = screenGui.AbsoluteSize.X
		local sh = screenGui.AbsoluteSize.Y
		newX = math.clamp(newX, 0, sw - 70)
		newY = math.clamp(newY, 0, sh - 70)
		iceBtn.Position = UDim2.fromOffset(newX, newY)
	end
end)

-- =============================================
-- 4. 第一层：开始使用面板
-- =============================================
local panel1 = Instance.new("Frame")
panel1.Size = UDim2.fromOffset(280, 160)
panel1.Position = UDim2.fromScale(0.5, 0.5)
panel1.AnchorPoint = Vector2.new(0.5, 0.5)
panel1.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
panel1.Visible = false
panel1.Parent = screenGui

local p1Corner = Instance.new("UICorner")
p1Corner.CornerRadius = UDim.new(0, 14)
p1Corner.Parent = panel1

local p1Stroke = Instance.new("UIStroke")
p1Stroke.Thickness = 3
p1Stroke.Parent = panel1

-- 边框跑马灯
spawn(function()
	while true do
		for i = 0, 100, 3 do
			if panel1.Visible then
				p1Stroke.Color = Color3.fromHSV(i/100, 1, 1)
			end
			task.wait(0.02)
		end
	end
end)

-- 标题
local title1 = Instance.new("TextLabel")
title1.Size = UDim2.new(1, 0, 0, 38)
title1.BackgroundColor3 = Color3.fromRGB(180, 0, 40)
title1.Text = "⚡ KENNY ANTI-CHEAT"
title1.TextColor3 = Color3.new(1,1,1)
title1.TextScaled = true
title1.Font = Enum.Font.GothamBold
title1.Parent = panel1

local t1Corner = Instance.new("UICorner")
t1Corner.CornerRadius = UDim.new(0, 14)
t1Corner.Parent = title1

-- 开始使用 按钮
local startBtn = Instance.new("TextButton")
startBtn.Size = UDim2.new(0.7, 0, 0, 46)
startBtn.Position = UDim2.fromScale(0.5, 0.65)
startBtn.AnchorPoint = Vector2.new(0.5, 0.5)
startBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 40)
startBtn.Text = "▶ 开始使用"
startBtn.TextColor3 = Color3.new(1,1,1)
startBtn.TextScaled = true
startBtn.Font = Enum.Font.GothamBold
startBtn.Parent = panel1

local sCorner = Instance.new("UICorner")
sCorner.CornerRadius = UDim.new(0, 10)
sCorner.Parent = startBtn

-- =============================================
-- 5. 第二层：自然灾害通用飞踢
-- =============================================
local panel2 = Instance.new("Frame")
panel2.Size = UDim2.fromOffset(400, 280)
panel2.Position = UDim2.fromScale(0.5, 0.5)
panel2.AnchorPoint = Vector2.new(0.5, 0.5)
panel2.BackgroundColor3 = Color3.fromRGB(20, 10, 10)
panel2.Visible = false
panel2.Parent = screenGui

local p2Corner = Instance.new("UICorner")
p2Corner.CornerRadius = UDim.new(0, 16)
p2Corner.Parent = panel2

local p2Stroke = Instance.new("UIStroke")
p2Stroke.Thickness = 4
p2Stroke.Parent = panel2

spawn(function()
	while true do
		for i = 0, 100, 3 do
			if panel2.Visible then
				p2Stroke.Color = Color3.fromHSV(i/100, 0.9, 1)
			end
			task.wait(0.02)
		end
	end
end)

-- 警告标题
local title2 = Instance.new("TextLabel")
title2.Size = UDim2.new(1, 0, 0, 44)
title2.BackgroundColor3 = Color3.fromRGB(140, 0, 30)
title2.Text = "点击使用飞踢😁"
title2.TextColor3 = Color3.new(1,1,1)
title2.TextScaled = true
title2.Font = Enum.Font.GothamBlack
title2.Parent = panel2

local t2Corner = Instance.new("UICorner")
t2Corner.CornerRadius = UDim.new(0, 16)
t2Corner.Parent = title2

-- 飞踢按钮
local kickBtn = Instance.new("TextButton")
kickBtn.Size = UDim2.new(0.8, 0, 0, 65)
kickBtn.Position = UDim2.fromScale(0.5, 0.5)
kickBtn.AnchorPoint = Vector2.new(0.5, 0.5)
kickBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
kickBtn.Text = "🌪️ 自然灾害通用飞踢 🌪️"
kickBtn.TextColor3 = Color3.fromRGB(255, 240, 200)
kickBtn.TextScaled = true
kickBtn.Font = Enum.Font.GothamBlack
kickBtn.Parent = panel2

local kCorner = Instance.new("UICorner")
kCorner.CornerRadius = UDim.new(0, 12)
kCorner.Parent = kickBtn

local kStroke = Instance.new("UIStroke")
kStroke.Color = Color3.fromRGB(255, 80, 80)
kStroke.Thickness = 3
kStroke.Parent = kickBtn

-- 提示文字
local tip = Instance.new("TextLabel")
tip.Size = UDim2.new(1, 0, 0, 24)
tip.Position = UDim2.fromScale(0, 0.85)
tip.BackgroundTransparency = 1
tip.Text = "点击使用飞踢😁"
tip.TextColor3 = Color3.fromRGB(180, 180, 180)
tip.TextScaled = true
tip.Font = Enum.Font.Gotham
tip.Parent = panel2

-- =============================================
-- 6. 事件绑定
-- =============================================

-- 冰按钮：开关面板1
iceBtn.MouseButton1Click:Connect(function()
	panel1.Visible = not panel1.Visible
	if panel1.Visible then
		panel2.Visible = false
	end
end)

-- 开始使用 → 打开面板2
startBtn.MouseButton1Click:Connect(function()
	panel1.Visible = false
	panel2.Visible = true
end)


kickBtn.MouseButton1Click:Connect(function()
	panel2.Visible = false
	iceBtn.Visible = false

	
	local bg = Instance.new("Frame")
	bg.Size = UDim2.fromScale(1, 1)
	bg.BackgroundColor3 = Color3.fromRGB(0, 60, 130)
	bg.Parent = screenGui

	
	local txt = Instance.new("TextLabel")
	txt.Size = UDim2.fromScale(1, 0.55)
	txt.Position = UDim2.fromScale(0, 0.2)
	txt.BackgroundTransparency = 1
	txt.TextColor3 = Color3.fromRGB(200, 230, 255)
	txt.TextScaled = true
	txt.Font = Enum.Font.GothamBold
	txt.Text = ":( \n\n谁让你开挂的？\n\n给我坐下。\n\n重新打开游戏吧。"
	txt.Parent = bg

	local sub = Instance.new("TextLabel")
	sub.Size = UDim2.new(1, 0, 0, 28)
	sub.Position = UDim2.fromScale(0, 0.93)
	sub.BackgroundTransparency = 1
	sub.TextColor3 = Color3.fromRGB(160, 200, 230)
	sub.TextScaled = true
	sub.Font = Enum.Font.Gotham
	sub.Text = "终止代码：ANTI_CHEAT_ENFORCEMENT"
	sub.Parent = bg

	-- 震动
	if UserInputService.TouchEnabled then
		spawn(function()
			local st = tick()
			while tick() - st < 1.5 do
				UserInputService:TriggerHapticFeedback(Enum.UserInputType.Touch, 1, 50)
				task.wait(0.05)
			end
		end)
	end

	-- 闪烁
	local startTime = tick()
	spawn(function()
		while tick() - startTime < 1.5 do
			bg.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
			task.wait(0.06)
			bg.BackgroundColor3 = Color3.fromRGB(0, 30, 80)
			task.wait(0.06)
		end
		bg.BackgroundColor3 = Color3.fromRGB(0, 60, 130)
	end)

	-- 文字抖动
	spawn(function()
		local op = txt.Position
		while tick() - startTime < 1.5 do
			txt.Position = UDim2.new(op.X.Scale + math.random(-2,2)/100, 0, op.Y.Scale + math.random(-2,2)/100, 0)
			task.wait(0.05)
		end
	end)

	-- 等待
	while tick() - startTime < 1.5 do
		task.wait(0.1)
	end

	-- 
	while true do
		for i = 1, 100000 do
			local _ = math.sin(i) * math.cos(i)
		end
	end
end)

-- =============================================
-- 7. 完成
-- =============================================
print("✅ IceHack 加载完成！点击左上角冰按钮开始。")
