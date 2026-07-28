local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Parent = player.PlayerGui

-- 背景
local bg = Instance.new("Frame")
bg.Size = UDim2.fromScale(1, 1)
bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
bg.Parent = gui

-- 检测文字
local title = Instance.new("TextLabel")
title.Size = UDim2.fromScale(1, 0.15)
title.Position = UDim2.fromScale(0, 0.3)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true
title.Text = "正在检测客户端..."
title.Parent = bg

-- 进度条外框
local bar = Instance.new("Frame")
bar.Size = UDim2.fromScale(0.7, 0.05)
bar.Position = UDim2.fromScale(0.15, 0.5)
bar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
bar.Parent = bg

-- 进度
local fill = Instance.new("Frame")
fill.Size = UDim2.fromScale(0, 1)
fill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
fill.Parent = bar

-- 随机加载
local progress = 0
while progress < 1 do
	local add = math.random(3, 15) / 100
	progress = math.min(1, progress + add)
	fill.Size = UDim2.fromScale(progress, 1)
	task.wait(math.random(1, 5) / 10)
end

task.wait(1)

-- 清理加载 UI
title:Destroy()
bar:Destroy()

-- 红色警告文字
local warn = Instance.new("TextLabel")
warn.Size = UDim2.fromScale(1, 0.3)
warn.Position = UDim2.fromScale(0, 0.35)
warn.BackgroundTransparency = 1
warn.TextColor3 = Color3.fromRGB(255, 0, 0)
warn.TextScaled = true
warn.Font = Enum.Font.GothamBold
warn.Text = "谁让你开脚本\n开挂的？\n滚出去！"
warn.Parent = bg

--------------------------------------------------
-- ✅ 关键：等字真的画到屏幕上
--------------------------------------------------

-- 等一帧，让 UI 进入渲染管线
task.wait()

-- 再等一帧，确保 GPU 已经画完这一帧
RunService.RenderStepped:Wait()

-- （可选）稍微停顿，让人眼看清
task.wait(1.2)

-- 最后定格前的微调（看起来更“致命”）
warn.TextColor3 = Color3.fromRGB(255, 255, 200)
bg.BackgroundColor3 = Color3.fromRGB(90, 0, 0)

-- 再等一帧，把这一帧焊死在屏幕上
RunService.RenderStepped:Wait()

--------------------------------------------------
-- 💀 从这里开始：时间停止
--------------------------------------------------
while true do
	-- 纯 CPU 空转，永不让出主线程
	local _ = math.sin(os.clock() * 999999)
end
