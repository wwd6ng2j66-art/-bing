--[[
	GlassWK — GlassNotice 玻璃拟态 UI + WK 全功能控制菜单
	功能：通用(防传送/披风/最小化) | 飞行 | 战斗(双激光) | 传送(玩家列表)
	用法：在 Executor 中直接执行本文件（不要包 loadstring）
--]]

-- ==================== GlassNotice 模块 ====================
local GlassNotice = {}
GlassNotice.Defaults = {
	Duration = 4,
	TintColor = Color3.fromRGB(30, 30, 40),
}

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local isMobile = UserInputService.TouchEnabled

-- 全局 Blur 管理
local blur = Lighting:FindFirstChildOfClass("BlurEffect")
if not blur then
	blur = Instance.new("BlurEffect")
	blur.Name = "GlassNoticeBlur"
	blur.Parent = Lighting
	blur.Size = 0
end
local activeBlurCount = 0

local function enableGlobalBlur()
	if activeBlurCount == 0 then
		local target = isMobile and 4 or 8
		TweenService:Create(blur, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Size = target }):Play()
	end
	activeBlurCount = activeBlurCount + 1
end

local function disableGlobalBlur()
	activeBlurCount = math.max(0, activeBlurCount - 1)
	if activeBlurCount == 0 then
		TweenService:Create(blur, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Size = 0 }):Play()
	end
end

-- 玻璃拟态背景构造
local function createBlurBackground(parent, tintColor)
	local shadow = Instance.new("Frame")
	shadow.Name = "GlassShadow"
	shadow.Size = UDim2.new(1, 6, 1, 6)
	shadow.Position = UDim2.new(0, -3, 0, -3)
	shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	shadow.BackgroundTransparency = 0.92
	shadow.BorderSizePixel = 0
	shadow.ZIndex = 0
	shadow.Parent = parent
	local sc = Instance.new("UICorner"); sc.CornerRadius = UDim.new(0, 18); sc.Parent = shadow

	local blurFrame = Instance.new("Frame")
	blurFrame.Name = "GlassFrame"
	blurFrame.Size = UDim2.new(1, 0, 1, 0)
	blurFrame.BackgroundColor3 = tintColor
	blurFrame.BackgroundTransparency = 0.78
	blurFrame.BorderSizePixel = 0
	blurFrame.ZIndex = 1
	blurFrame.Parent = parent
	local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 16); c.Parent = blurFrame

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 1; stroke.Color = Color3.new(1, 1, 1); stroke.Transparency = 0.85
	stroke.Parent = blurFrame

	local gloss = Instance.new("Frame")
	gloss.Name = "Gloss"
	gloss.Size = UDim2.new(1, -8, 0, 10)
	gloss.Position = UDim2.new(0, 4, 0, 6)
	gloss.BackgroundColor3 = Color3.new(1, 1, 1)
	gloss.BackgroundTransparency = 0.92
	gloss.BorderSizePixel = 0; gloss.ZIndex = 2; gloss.Parent = parent
	local gCorner = Instance.new("UICorner"); gCorner.CornerRadius = UDim.new(0, 10); gCorner.Parent = gloss
	local gGrad = Instance.new("UIGradient")
	gGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.new(1,1,1))})
	gGrad.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.88),NumberSequenceKeypoint.new(1,1.0)})
	gGrad.Rotation = 90; gGrad.Parent = gloss

	local overlay = Instance.new("Frame")
	overlay.Name = "Overlay"
	overlay.Size = UDim2.new(1, 0, 0.5, 0)
	overlay.Position = UDim2.new(0, 0, 0, 0)
	overlay.BackgroundColor3 = Color3.new(1, 1, 1)
	overlay.BackgroundTransparency = 0.88
	overlay.BorderSizePixel = 0; overlay.ZIndex = 2; overlay.Parent = parent
	local oc = Instance.new("UICorner"); oc.CornerRadius = UDim.new(0, 16); oc.Parent = overlay

	return blurFrame
end

-- 获取/创建 ScreenGui 容器
local function getScreenGui()
	local player = Players.LocalPlayer
	local pgui = player:WaitForChild("PlayerGui")
	local gui = pgui:FindFirstChild("GlassNoticeGui")
	if not gui then
		gui = Instance.new("ScreenGui")
		gui.Name = "GlassNoticeGui"
		gui.ResetOnSpawn = false
		gui.IgnoreGuiInset = true
		gui.DisplayOrder = 10
		gui.Parent = pgui
	end
	return gui
end

-- 创建玻璃通知面板（用作 WK 菜单容器）
function GlassNotice.createNotice(config)
	config = config or {}
	local titleText = config.Title or "通知"
	local descText = config.Description or ""
	local duration = config.Duration or GlassNotice.Defaults.Duration
	local tint = config.TintColor or GlassNotice.Defaults.TintColor
	local onComplete = config.OnComplete

	local screenGui = getScreenGui()

	local card = Instance.new("Frame")
	card.Name = "NoticeCard"
	card.Size = config.Size or UDim2.new(0, 400, 0, 420)
	card.Position = UDim2.new(0.5, -200, 0.5, -210)
	card.BackgroundTransparency = 1
	card.BorderSizePixel = 0
	card.ClipsDescendants = true
	card.Parent = screenGui

	createBlurBackground(card, tint)

	-- 标题栏（拖拽区）
	local tb = Instance.new("Frame")
	tb.Name = "TitleBar"
	tb.Size = UDim2.new(1, 0, 0, 36)
	tb.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
	tb.BackgroundTransparency = 0.6
	tb.Parent = card
	local tbC = Instance.new("UICorner"); tbC.CornerRadius = UDim.new(0, 16); tbC.Parent = tb
	local tbF = Instance.new("Frame"); tbF.Size = UDim2.new(1,0,0.5,0); tbF.Position = UDim2.new(0,0,0.5,0); tbF.BackgroundTransparency=1; tbF.Parent=tb

	local tl = Instance.new("TextLabel")
	tl.Size = UDim2.new(0.8, 0, 1, 0)
	tl.Position = UDim2.new(0.02, 0, 0, 0)
	tl.BackgroundTransparency = 1
	tl.Text = titleText
	tl.TextColor3 = Color3.fromRGB(255, 255, 255)
	tl.TextXAlignment = Enum.TextXAlignment.Left
	tl.TextScaled = true; tl.Font = Enum.Font.GothamBold; tl.Parent = tb

	local cl = Instance.new("TextButton")
	cl.Size = UDim2.new(0, 32, 0, 32)
	cl.Position = UDim2.new(1, -36, 0, 2)
	cl.BackgroundTransparency = 1
	cl.Text = "×"; cl.TextColor3 = Color3.fromRGB(255, 90, 90)
	cl.TextScaled = true; cl.Font = Enum.Font.Gotham; cl.Parent = tb

	-- 描述
	if descText ~= "" then
		local d = Instance.new("TextLabel")
		d.Size = UDim2.new(1, -16, 0, 18)
		d.Position = UDim2.new(0, 8, 0, 38)
		d.BackgroundTransparency = 1
		d.Text = descText
		d.TextColor3 = Color3.fromRGB(220, 220, 225)
		d.TextXAlignment = Enum.TextXAlignment.Left
		d.TextScaled = true; d.Font = Enum.Font.Gotham; d.Parent = card
	end

	enableGlobalBlur()

	-- 入场动画
	card.Position = UDim2.new(0.5, -200, 0.5, -260)
	TweenService:Create(card, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Position = UDim2.new(0.5, -200, 0.5, -210) }):Play()

	local dismissed = false
	local function dismiss()
		if dismissed then return end
		dismissed = true
		TweenService:Create(card, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.In), { Position = UDim2.new(0.5, -200, 0.5, -260) }):Play()
		task.delay(0.4, function()
			disableGlobalBlur()
			card:Destroy()
			if onComplete then task.spawn(onComplete) end
		end)
	end

	if duration < math.huge then task.delay(duration, dismiss) end
	cl.MouseButton1Click:Connect(dismiss)

	-- 拖拽（绑定标题栏）
	local drag = false; local ds, sp
	tb.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
			drag = true; ds = i.Position; sp = card.Position
		end
	end)
	tb.InputChanged:Connect(function(i)
		if drag and i.UserInputType == Enum.UserInputType.Touch then
			local dt = i.Position - ds
			card.Position = UDim2.new(sp.X.Scale, sp.X.Offset + dt.X, sp.Y.Scale, sp.Y.Offset + dt.Y)
		end
	end)
	tb.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
	end)

	return { Card = card, Dismiss = dismiss, TitleBar = tb, CloseButton = cl }
end

-- ==================== WK 控制菜单（全部功能） ====================
local p = Players.LocalPlayer
local rs = game:GetService("RunService")
local u = UserInputService

-- 状态
local flying = false
local hSpd = 50; local vSpd = 30
local rp, h = nil, nil
local anti = false
local laser = false
local cape = nil
local lpL, lpR = nil, nil

-- 初始化角色
local function init()
	repeat task.wait() until p.Character and p.Character:FindFirstChild("HumanoidRootPart")
	rp = p.Character.HumanoidRootPart
	h = p.Character:FindFirstChild("Humanoid")
end
spawn(init)

-- 披风
local function togCape(e)
	if not rp then return end
	if e and not cape then
		local tr = p.Character:FindFirstChild("Torso")
		if not tr then return end
		cape = Instance.new("Part"); cape.Name = "WKCape"
		cape.Size = Vector3.new(5, 4, 0.2); cape.Anchored = false; cape.CanCollide = false
		cape.Material = Enum.Material.SmoothPlastic; cape.Color = Color3.fromRGB(200, 20, 20); cape.Transparency = 0.2
		cape.Parent = p.Character
		local st = Instance.new("Part"); st.Size = Vector3.new(0.3, 3.8, 0.25); st.Anchored = false; st.CanCollide = false
		st.Material = Enum.Material.SmoothPlastic; st.Color = Color3.fromRGB(255, 215, 0); st.Transparency = 0.2; st.Parent = cape
		local capW = Instance.new("Weld"); capW.Part0 = tr; capW.Part1 = cape; capW.C0 = CFrame.new(0, 0.5, -1.5); capW.Parent = tr
		local sw = Instance.new("Weld"); sw.Part0 = cape; sw.Part1 = st; sw.C0 = CFrame.new(0, 0, -0.1); sw.Parent = cape
	elseif not e and cape then cape:Destroy(); cape = nil end
end

-- 激光部件
local function crLaser()
	if lpL then lpL:Destroy() end; if lpR then lpR:Destroy() end
	local function mk()
		local pa = Instance.new("Part"); pa.Size = Vector3.new(1.5, 1.5, 0.2); pa.Anchored = true; pa.CanCollide = false
		pa.Material = Enum.Material.Neon; pa.Color = Color3.fromRGB(255, 0, 0); pa.Transparency = 0.2; pa.Parent = workspace; return pa
	end
	lpL = mk(); lpR = mk()
end
crLaser()

local function ub(part, o, d, dist)
	if not part then return end
	if dist < 0.1 then part.Size = Vector3.new(0.1,0.1,0.1); part.CFrame = CFrame.new(o); return end
	local e = o + d * dist; part.Size = Vector3.new(1.5, 1.5, dist); part.CFrame = CFrame.lookAt((o + e) / 2, e)
end

local function sdn(pos, amt)
	local bg = Instance.new("BillboardGui"); bg.Size = UDim2.new(0, 80, 0, 40); bg.AlwaysOnTop = true; bg.Parent = workspace
	local fr = Instance.new("Frame"); fr.Size = UDim2.new(1,0,1,0); fr.BackgroundTransparency = 1; fr.Parent = bg
	local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1,0,1,0); lbl.BackgroundTransparency = 1; lbl.Text = "-" .. tostring(amt)
	lbl.TextColor3 = Color3.fromRGB(255, 0, 0); lbl.TextScaled = true; lbl.Font = Enum.Font.GothamBlack; lbl.Parent = fr
	local att = Instance.new("Attachment"); att.Parent = workspace; att.Position = pos; bg.Parent = att
	game:GetService("Debris"):AddItem(bg, 0.8); game:GetService("Debris"):AddItem(att, 0.8)
end

-- 发射激光
local function fireLasers()
	if not rp or not p.Character then return end
	local cam = workspace.CurrentCamera; local dir = cam.CFrame.LookVector
	local oL = rp.Position + Vector3.new(-0.6, 1.5, 0); local oR = rp.Position + Vector3.new(0.6, 1.5, 0)
	local maxD = 800
	local params = RaycastParams.new(); params.FilterType = Enum.RaycastFilterType.Blacklist; params.FilterDescendantsInstances = {p.Character}

	local function hitFx(pos)
		local fx = Instance.new("Part"); fx.Size = Vector3.new(5,5,5); fx.Anchored = true; fx.CanCollide = false; fx.Material = Enum.Material.Neon
		fx.Color = Color3.fromRGB(255,255,200); fx.Transparency = 0.5; fx.Position = pos; fx.Parent = workspace
		game:GetService("Debris"):AddItem(fx, 0.4)
		for i = 1, 10 do local p2 = Instance.new("Part"); p2.Size = Vector3.new(1,1,1); p2.Anchored = true; p2.CanCollide = false
			p2.Material = Enum.Material.Neon; p2.Color = Color3.fromRGB(255,200,100); p2.Transparency = 0.8
			p2.Position = pos + Vector3.new(math.random(-5,5), math.random(-5,5), math.random(-5,5)); p2.Parent = workspace
			game:GetService("Debris"):AddItem(p2, 0.5)
		end
		local exp = Instance.new("Explosion"); exp.Position = pos; exp.BlastRadius = 4; exp.ExplosionType = Enum.ExplosionType.NoCraters; exp.Parent = workspace
		game:GetService("Debris"):AddItem(exp, 0.3)
	end

	local function procHit(o, r)
		if not r then return 800 end
		local d = (o - r.Position).Magnitude
		local model = r.Instance and r.Instance:FindFirstAncestorOfClass("Model")
		if model and model:FindFirstChild("Humanoid") then
			local root = model:FindFirstChild("HumanoidRootPart"); local hum = model:FindFirstChild("Humanoid")
			if root and hum then
				local force = (root.Position - rp.Position).Unit * 200 + Vector3.new(0, 120, 0)
				root.Velocity = force; root.AssemblyLinearVelocity = force; hum:TakeDamage(30); sdn(r.Position, 30); hitFx(r.Position)
			end
		end
		return d
	end

	local dL = procHit(oL, workspace:Raycast(oL, dir * maxD, params))
	local dR = procHit(oR, workspace:Raycast(oR, dir * maxD, params))
	ub(lpL, oL, dir, dL); ub(lpR, oR, dir, dR)
end

-- ==================== 构建玻璃菜单 UI ====================
local notice = GlassNotice.createNotice({
	Title = "WK 控制面板",
	Description = "拖拽标题栏移动 · 点击 × 关闭",
	Duration = math.huge,
	TintColor = Color3.fromRGB(28, 28, 38),
	Size = UDim2.new(0, 400, 0, 420),
})

local card = notice.Card

-- 内容区
local content = Instance.new("Frame")
content.Name = "Content"
content.Size = UDim2.new(1, -16, 1, -60)
content.Position = UDim2.new(0, 8, 0, 56)
content.BackgroundTransparency = 1
content.Parent = card

-- 左侧导航
local nv = Instance.new("Frame")
nv.Size = UDim2.new(0, 90, 1, 0)
nv.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
nv.BackgroundTransparency = 0.5
nv.Parent = content
local nvC = Instance.new("UICorner"); nvC.CornerRadius = UDim.new(0, 12); nvC.Parent = nv

local function navBtn(t, y)
	local x = Instance.new("TextButton"); x.Size = UDim2.new(1, 0, 0, 34); x.Position = UDim2.new(0, 0, 0, y)
	x.BackgroundColor3 = Color3.fromRGB(40, 40, 48); x.Text = t; x.TextColor3 = Color3.fromRGB(255, 255, 255)
	x.TextScaled = true; x.Font = Enum.Font.Gotham; x.Parent = nv; return x
end
local bG = navBtn("通用", 6)
local bF = navBtn("飞行", 44)
local bC = navBtn("战斗", 82)
local bT = navBtn("传送", 120)

-- 右侧面板
local ct = Instance.new("Frame")
ct.Size = UDim2.new(1, -96, 1, 0)
ct.Position = UDim2.new(0, 94, 0, 0)
ct.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
ct.BackgroundTransparency = 0.5
ct.Parent = content
local ctC = Instance.new("UICorner"); ctC.CornerRadius = UDim.new(0, 12); ctC.Parent = ct

local function clr() for _, v in pairs(ct:GetChildren()) do if v ~= ctC then v:Destroy() end end end

local function rw(y, l, btn)
	local fr = Instance.new("Frame"); fr.Size = UDim2.new(1, -10, 0, 34); fr.Position = UDim2.new(0.02, 0, 0, y)
	fr.BackgroundColor3 = Color3.fromRGB(45, 45, 54); fr.Parent = ct; local frc = Instance.new("UICorner"); frc.CornerRadius = UDim.new(0,8); frc.Parent = fr
	local lb = Instance.new("TextLabel"); lb.Size = UDim2.new(0.5, 0, 1, 0); lb.Position = UDim2.new(0.02, 0, 0, 0)
	lb.BackgroundTransparency = 1; lb.Text = l; lb.TextColor3 = Color3.fromRGB(220, 220, 225)
	lb.TextXAlignment = Enum.TextXAlignment.Left; lb.TextScaled = true; lb.Font = Enum.Font.Gotham; lb.Parent = fr
	btn.Parent = fr; btn.Size = UDim2.new(0, 78, 1, 0); btn.Position = UDim2.new(1, -86, 0, 0)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255); btn.TextScaled = true; btn.Font = Enum.Font.Gotham; return btn
end

-- 通用页
local function gen()
	clr()
	local a = Instance.new("TextButton"); a.BackgroundColor3 = anti and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,50,50)
	a.Text = anti and "防传送 (开)" or "防传送 (关)"; a.TextColor3 = Color3.fromRGB(255,255,255); a.TextScaled = true; a.Font = Enum.Font.Gotham
	rw(6, "防传送", a)
	a.MouseButton1Click:Connect(function() anti = not anti; a.Text = anti and "防传送 (开)" or "防传送 (关)"; a.BackgroundColor3 = anti and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,50,50) end)

	local c = Instance.new("TextButton"); c.BackgroundColor3 = cape and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,50,50)
	c.Text = cape and "披风 (开)" or "披风 (关)"; c.TextColor3 = Color3.fromRGB(255,255,255); c.TextScaled = true; c.Font = Enum.Font.Gotham
	rw(44, "披风", c)
	c.MouseButton1Click:Connect(function() togCape(not cape); c.Text = cape and "披风 (开)" or "披风 (关)"; c.BackgroundColor3 = cape and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,50,50) end)

	local min = Instance.new("TextButton"); min.BackgroundColor3 = Color3.fromRGB(200,200,200); min.Text = "最小化"; min.TextColor3 = Color3.fromRGB(0,0,0); min.TextScaled = true; min.Font = Enum.Font.Gotham
	rw(82, "窗口", min)
	min.MouseButton1Click:Connect(function() notice.Dismiss() end)
end

-- 飞行页
bF.MouseButton1Click:Connect(function()
	clr()
	local f = Instance.new("TextButton"); f.BackgroundColor3 = flying and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,50,50)
	f.Text = flying and "飞行 (开)" or "飞行 (关)"; f.TextColor3 = Color3.fromRGB(255,255,255); f.TextScaled = true; f.Font = Enum.Font.Gotham
	rw(6, "飞行开关", f)
	f.MouseButton1Click:Connect(function() flying = not flying; f.Text = flying and "飞行 (开)" or "飞行 (关)"; f.BackgroundColor3 = flying and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,50,50) end)
end)

-- 战斗页
bC.MouseButton1Click:Connect(function()
	clr()
	local l = Instance.new("TextButton"); l.BackgroundColor3 = laser and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,50,50)
	l.Text = laser and "激光 (开)" or "激光 (关)"; l.TextColor3 = Color3.fromRGB(255,255,255); l.TextScaled = true; l.Font = Enum.Font.Gotham
	rw(6, "双激光", l)
	l.MouseButton1Click:Connect(function() laser = not laser; l.Text = laser and "激光 (开)" or "激光 (关)"; l.BackgroundColor3 = laser and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,50,50) end)
end)

-- 传送页（玩家列表，实时刷新）
bT.MouseButton1Click:Connect(function()
	clr()
	local pl = Instance.new("ScrollingFrame"); pl.Size = UDim2.new(1, -10, 1, -6); pl.Position = UDim2.new(0.02, 0, 0, 4)
	pl.BackgroundTransparency = 1; pl.Parent = ct
	local ll = Instance.new("UIListLayout"); ll.FillDirection = Enum.FillDirection.Vertical; ll.Padding = UDim.new(0, 4); ll.Parent = pl
	local function refresh()
		for _, v in pairs(pl:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
		for _, plr in pairs(Players:GetPlayers()) do
			if plr ~= p and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
				local tb = Instance.new("TextButton"); tb.Size = UDim2.new(1, 0, 0, 30); tb.BackgroundColor3 = Color3.fromRGB(50,50,60)
				tb.Text = plr.Name; tb.TextColor3 = Color3.fromRGB(255,255,255); tb.TextScaled = true; tb.Font = Enum.Font.Gotham; tb.Parent = pl
				local tbc = Instance.new("UICorner"); tbc.CornerRadius = UDim.new(0,8); tbc.Parent = tb
				tb.MouseButton1Click:Connect(function()
					if rp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
						rp.CFrame = plr.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
					end
				end)
			end
		end
	end
	refresh()
	task.spawn(function() while pl.Parent do task.wait(3); refresh() end end)
end)

bG.MouseButton1Click:Connect(gen)
gen()

-- ==================== 心跳循环（飞行/防传送/激光） ====================
rs.Heartbeat:Connect(function()
	if flying and rp then
		local cam = workspace.CurrentCamera; local move = Vector3.new()
		if u:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
		if u:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
		if u:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
		if u:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
		if u:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, vSpd, 0) end
		if u:IsKeyDown(Enum.KeyCode.LeftShift) or u:IsKeyDown(Enum.KeyCode.RightShift) then move = move - Vector3.new(0, vSpd, 0) end
		rp.Velocity = move * hSpd
	end
	if anti and rp then rp.Anchored = true; task.wait(); rp.Anchored = false end
	if laser then fireLasers() end
end)

-- ==================== 悬浮 FAB 按钮（关闭后重新打开） ====================
local fab = Instance.new("TextButton")
fab.Size = UDim2.new(0, 52, 0, 52)
fab.Position = UDim2.new(0, 16, 1, -68)
fab.Text = "WK"; fab.TextColor3 = Color3.fromRGB(255,255,255); fab.TextScaled = true; fab.Font = Enum.Font.GothamBold
fab.Parent = getScreenGui()
createBlurBackground(fab, Color3.fromRGB(30,30,40))
fab.MouseButton1Click:Connect(function()
	if card and card.Parent then notice.Dismiss() end
	task.wait(0.4)
	notice = GlassNotice.createNotice({
		Title = "WK 控制面板", Description = "拖拽标题栏移动 · 点击 × 关闭",
		Duration = math.huge, TintColor = Color3.fromRGB(28, 28, 38), Size = UDim2.new(0, 400, 0, 420),
	})
	card = notice.Card
	-- 重新挂载内容（简化：重新执行构建）
	content.Parent = card; nv.Parent = content; ct.Parent = content
end)

return GlassNotice
