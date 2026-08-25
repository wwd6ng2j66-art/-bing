local success, rs = pcall(function() return game:GetService("RunService") end)

if not success then rs = game:GetService("RunService") end

local success, u = pcall(function() return game:GetService("UserInputService") end)

if not success then u = game:GetService("UserInputService") end

local p = game.Players.LocalPlayer

local w = Instance.new('ScreenGui')

w.Name = "ControlMenu"

w.ResetOnSpawn = false

w.Parent = p:WaitForChild("PlayerGui")

local b = Instance.new('TextButton')

b.Size = UDim2.new(0,40,0,40)

b.Position = UDim2.new(0,10,0,10)

b.Text = '+'

b.TextScaled = true

b.Font = Enum.Font.SourceSans

b.BackgroundColor3 = Color3.fromRGB(50,50,50)

b.TextColor3 = Color3.fromRGB(255,255,255)

b.Parent = w

local tb = Instance.new('Frame')

tb.Size = UDim2.new(1,0,0,35)

tb.BackgroundColor3 = Color3.fromRGB(50,50,50)

tb.Parent = w

local tl = Instance.new('TextLabel')

tl.Size = UDim2.new(0.8,0,1,0)

tl.Position = UDim2.new(0.02,0,0,0)

tl.BackgroundTransparency = 1

tl.Text = '控制菜单'

tl.TextColor3 = Color3.fromRGB(255,255,255)

tl.TextXAlignment = Enum.TextXAlignment.Left

tl.TextScaled = true

tl.Font = Enum.Font.SourceSans

tl.Parent = tb

local cl = Instance.new('TextButton')

cl.Size = UDim2.new(0,35,0,35)

cl.Position = UDim2.new(1,-38,0,0)

cl.BackgroundTransparency = 1

cl.Text = '×'

cl.TextColor3 = Color3.fromRGB(255,80,80)

cl.TextScaled = true

cl.Font = Enum.Font.SourceSans

cl.Parent = tb

cl.MouseButton1Click:Connect(function()

w.Visible = false

b.Visible = true

end)

b.MouseButton1Click:Connect(function()

w.Visible = true

b.Visible = false

end)

local nv = Instance.new('Frame')

nv.Size = UDim2.new(0,90,1,-35)

nv.Position = UDim2.new(0,0,0,35)

nv.BackgroundColor3 = Color3.fromRGB(25,25,25)

nv.Parent = w

local function nb(t, y)

local x = Instance.new('TextButton')

x.Size = UDim2.new(1,0,0,35)

x.Position = UDim2.new(0,0,0,y)

x.BackgroundColor3 = Color3.fromRGB(40,40,40)

x.Text = t

x.TextColor3 = Color3.fromRGB(255,255,255)

x.TextScaled = true

x.Font = Enum.Font.SourceSans

x.Parent = nv

return x

end

local bG = nb('通用', 5)

local bF = nb('飞行', 45)

local bC = nb('战斗', 85)

local bT = nb('传送', 125)

local ct = Instance.new('Frame')

ct.Size = UDim2.new(1,-95,1,-45)

ct.Position = UDim2.new(0,93,0,40)

ct.BackgroundColor3 = Color3.fromRGB(35,35,35)

ct.Parent = w

local function clr()

for _, v in pairs(ct:GetChildren()) do

v:Destroy()

end

end

local function rw(y, l, btn)

local fr = Instance.new('Frame')

fr.Size = UDim2.new(1,-10,0,35)

fr.Position = UDim2.new(0.02,0,0,y)

fr.BackgroundColor3 = Color3.fromRGB(45,45,45)

fr.Parent = ct
  local lb = Instance.new('TextLabel')
lb.Size = UDim2.new(0.5,0,1,0)
lb.Position = UDim2.new(0.02,0,0,0)
lb.BackgroundTransparency = 1
lb.Text = l
lb.TextColor3 = Color3.fromRGB(220,220,220)
lb.TextXAlignment = Enum.TextXAlignment.Left
lb.TextScaled = true
lb.Font = Enum.Font.SourceSans
lb.Parent = fr

btn.Parent = fr
btn.Size = UDim2.new(0,80,1,0)
btn.Position = UDim2.new(1,-90,0,0)
btn.TextColor3 = Color3.fromRGB(255,255,255)
btn.TextScaled = true
btn.Font = Enum.Font.SourceSans
return btn
  end

-- 飞行相关变量

local flying = false

local hSpd = 50

local vSpd = 30

local stp = 5

local mn = 10

local mx = 200

local rp, h, ht

local anti = false

local lp = nil

local laser = false

local lpL, lpR

local cape = nil

local capW = nil

-- 初始化角色

local function init()

repeat task.wait() until p.Character and p.Character:FindFirstChild('HumanoidRootPart')

rp = p.Character.HumanoidRootPart

h = p.Character:FindFirstChild('Humanoid')

end

spawn(init)

-- 披风功能

local function togCape(e)

if not rp then return end

if e and not cape then

local tr = p.Character:FindFirstChild('Torso')

if not tr then return end

cape = Instance.new('Part')

cape.Size = Vector3.new(5,4,0.2)

cape.Anchored = false

cape.CanCollide = false

cape.Material = Enum.Material.SmoothPlastic

cape.Color = Color3.fromRGB(200,20,20)

cape.Transparency = 0.2

cape.Parent = p.Character
local st = Instance.new('Part')
st.Size = Vector3.new(0.3,3.8,0.25)
st.Anchored = false
st.CanCollide = false
st.Material = Enum.Material.SmoothPlastic
st.Color = Color3.fromRGB(255,215,0)
st.Transparency = 0.2
st.Parent = cape

capW = Instance.new('Weld')
capW.Part0 = tr
capW.Part1 = cape
capW.C0 = CFrame.new(0,0.5,-1.5)
capW.Parent = tr

local sw = Instance.new('Weld')
sw.Part0 = cape
sw.Part1 = st
sw.C0 = CFrame.new(0,0,-0.1)
sw.Parent = cape
elseif not e and cape then
cape:Destroy()
cape = nil
capW = nil
end
end

-- 创建激光部件

local function crLaser()

if lpL then lpL:Destroy() end

if lpR then lpR:Destroy() end

local function nb2()

local p = Instance.new('Part')

p.Size = Vector3.new(1.5,1.5,0.2)

p.Anchored = true

p.CanCollide = false

p.Material = Enum.Material.Neon

p.Color = Color3.fromRGB(255,0,0)

p.Transparency = 0.2

p.Parent = workspace

return p

end

lpL = nb2()

lpR = nb2()

end

crLaser()

-- 更新激光长度

local function ub(p, o, d, dist)

if not p then return end

if dist < 0.1 then

p.Size = Vector3.new(0.1,0.1,0.1)

p.CFrame = CFrame.new(o)

return

end

local e = o + d * dist

p.Size = Vector3.new(1.5,1.5,dist)

p.CFrame = CFrame.lookAt((o+e)/2, e)

end

-- 伤害飘字

local function sdn(pos, amt)

local bg = Instance.new('BillboardGui')

bg.Size = UDim2.new(0,80,0,40)

bg.AlwaysOnTop = true

bg.Parent = workspace    
local fr = Instance.new('Frame')
fr.Size = UDim2.new(1,0,1,0)
fr.BackgroundTransparency = 1
fr.Parent = bg

local lbl = Instance.new('TextLabel')
lbl.Size = UDim2.new(1,0,1,0)
lbl.BackgroundTransparency = 1
lbl.Text = '-' .. tostring(amt)
lbl.TextColor3 = Color3.fromRGB(255,0,0)
lbl.TextScaled = true
lbl.Font = Enum.Font.GothamBlack
lbl.Parent = fr

local att = Instance.new('Attachment')
att.Parent = workspace
att.Position = pos
bg.Parent = att

game:GetService('Debris'):AddItem(bg, 0.8)
game:GetService('Debris'):AddItem(att, 0.8)
end

-- 发射激光逻辑

local function fireLasers()

if not rp or not p.Character then return end

local cam = workspace.CurrentCamera

local dir = cam.CFrame.LookVector

local oL = rp.Position + Vector3.new(-0.6,1.5,0)

local oR = rp.Position + Vector3.new(0.6,1.5,0)

local maxD = 800    
local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Blacklist
params.FilterDescendantsInstances = {p.Character}

local rL = workspace:Raycast(oL, dir * maxD, params)
local dL = maxD
if rL then
    dL = (oL - rL.Position).Magnitude
    local hit = rL.Instance
    local model = hit:FindFirstAncestorOfClass('Model')
    if model and model:FindFirstChild('Humanoid') then
        local root = model:FindFirstChild('HumanoidRootPart')
        local hum = model:FindFirstChild('Humanoid')
        if root and hum then
            local force = (root.Position - rp.Position).Unit * 200 + Vector3.new(0,120,0)
            root.Velocity = force
            root.AssemblyLinearVelocity = force
            hum:TakeDamage(30)
            sdn(rL.Position, 30)
            
            local fx = Instance.new('Part')
            fx.Size = Vector3.new(5,5,5)
            fx.Anchored = true
            fx.CanCollide = false
            fx.Material = Enum.Material.Neon
            fx.Color = Color3.fromRGB(255,255,200)
            fx.Transparency = 0.5
            fx.Position = rL.Position
            fx.Parent = workspace
            game:GetService('Debris'):AddItem(fx, 0.4)
            
            for i = 1, 10 do
                local p2 = Instance.new('Part')
                p2.Size = Vector3.new(1,1,1)
                p2.Anchored = true
                p2.CanCollide = false
                p2.Material = Enum.Material.Neon
                p2.Color = Color3.fromRGB(255,200,100)
                p2.Transparency = 0.8
                p2.Position = rL.Position + Vector3.new(math.random(-5,5), math.random(-5,5), math.random(-5,5))
                p2.Parent = workspace
                game:GetService('Debris'):AddItem(p2, 0.5)
            end
            
            local exp = Instance.new('Explosion')
            exp.Position = rL.Position
            exp.BlastRadius = 4
            exp.ExplosionType = Enum.ExplosionType.NoCraters
            exp.Parent = workspace
            game:GetService('Debris'):AddItem(exp, 0.3)
        end
    end
end

local rR = workspace:Raycast(oR, dir * maxD, params)
local dR = maxD
if rR then
    dR = (oR - rR.Position).Magnitude
    local hit = rR.Instance
    local model = hit:FindFirstAncestorOfClass('Model')
    if model and model:FindFirstChild('Humanoid') then
        local root = model:FindFirstChild('HumanoidRootPart')
        local hum = model:FindFirstChild('Humanoid')
        if root and hum then
            local force = (root.Position - rp.Position).Unit * 200 + Vector3.new(0,120,0)
            root.Velocity = force
            root.AssemblyLinearVelocity = force
            hum:TakeDamage(30)
            sdn(rR.Position, 30)
            
            local fx = Instance.new('Part')
            fx.Size = Vector3.new(5,5,5)
            fx.Anchored = true
            fx.CanCollide = false
            fx.Material = Enum.Material.Neon
            fx.Color = Color3.fromRGB(255,255,200)
            fx.Transparency = 0.5
            fx.Position = rR.Position
            fx.Parent = workspace
            game:GetService('Debris'):AddItem(fx, 0.4)
            
            for i = 1, 10 do
                local p2 = Instance.new('Part')
                p2.Size = Vector3.new(1,1,1)
                p2.Anchored = true
                p2.CanCollide = false
                p2.Material = Enum.Material.Neon
                p2.Color = Color3.fromRGB(255,200,100)
                p2.Transparency = 0.8
                p2.Position = rR.Position + Vector3.new(math.random(-5,5), math.random(-5,5), math.random(-5,5))
                p2.Parent = workspace
                game:GetService('Debris'):AddItem(p2, 0.5)
            end
            
            local exp = Instance.new('Explosion')
            exp.Position = rR.Position
            exp.BlastRadius = 4
            exp.ExplosionType = Enum.ExplosionType.NoCraters
            exp.Parent = workspace
            game:GetService('Debris'):AddItem(exp, 0.3)
        end
    end
end
ub(lpL, oL, dir, dL)
ub(lpR, oR, dir, dR)
end

-- 通用页面

local function gen()

clr()

local m = Instance.new('TextButton')

m.BackgroundColor3 = Color3.fromRGB(200,200,200)

m.Text = '最小化'

m.TextColor3 = Color3.fromRGB(0,0,0)

m.TextScaled = true

m.Font = Enum.Font.SourceSans

rw(5, '窗口控制', m)

m.MouseButton1Click:Connect(function()

w.Visible = false

b.Visible = true

end)
 end

bG.MouseButton1Click:Connect(gen)

-- 飞行页面

bF.MouseButton1Click:Connect(function()

clr()

local f = Instance.new('TextButton')

f.BackgroundColor3 = flying and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,50,50)

f.Text = flying and '飞行 (开)' or '飞行 (关)'

f.TextColor3 = Color3.fromRGB(255,255,255)

f.TextScaled = true

f.Font = Enum.Font.SourceSans

rw(5, '飞行开关', f)

f.MouseButton1Click:Connect(function()

flying = not flying

f.Text = flying and '飞行 (开)' or '飞行 (关)'

f.BackgroundColor3 = flying and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,50,50)

end)

end)

-- 战斗页面

bC.MouseButton1Click:Connect(function()

clr()

local l = Instance.new('TextButton')

l.BackgroundColor3 = laser and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,50,50)

l.Text = laser and '激光 (开)' or '激光 (关)'

l.TextColor3 = Color3.fromRGB(255,255,255)

l.TextScaled = true

l.Font = Enum.Font.SourceSans

rw(5, '双激光', l)

l.MouseButton1Click:Connect(function()

laser = not laser

l.Text = laser and '激光 (开)' or '激光 (关)'

l.BackgroundColor3 = laser and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,50,50)

end)

end)

-- 传送页面 (预留)

bT.MouseButton1Click:Connect(function()

clr()

local t = Instance.new('TextLabel')

t.Size = UDim2.new(1,-10,0,35)

t.Position = UDim2.new(0.02,0,0,5)

t.BackgroundColor3 = Color3.fromRGB(45,45,45)

t.Text = '传送功能待添加'

t.TextColor3 = Color3.fromRGB(255,255,255)

t.TextScaled = true

t.Font = Enum.Font.SourceSans

t.Parent = ct

end)

-- 核心心跳循环 (飞行、防传送、激光)

rs.Heartbeat:Connect(function()

-- 飞行逻辑

if flying and rp then

local cam = workspace.CurrentCamera

local move = Vector3.new()

if u:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end

if u:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end

if u:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end

if u:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end

if u:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,vSpd,0) end

if u:IsKeyDown(Enum.KeyCode.LeftShift) or u:IsKeyDown(Enum.KeyCode.RightShift) then move -= Vector3.new(0,vSpd,0) end

rp.Velocity = move * hSpd

end
-- 防传送逻辑
if anti and rp then
    rp.Anchored = true
    task.wait()
    rp.Anchored = false
end

-- 激光逻辑
if laser then
    fireLasers()
end
end)

-- 启动通用页面

gen()    
