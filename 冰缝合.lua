--// ===== 内嵌 Rayfield（不再依赖网络）=====
local Rayfield = loadstring([[
local Rayfield = {}
local Players = game:GetService("Players")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "RayfieldUI"
ScreenGui.ResetOnSpawn = false

function Rayfield:CreateWindow(cfg)
    local Window = {}
    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0,420,0,320)
    Main.Position = UDim2.new(0.5,-210,0.5,-160)
    Main.BackgroundColor3 = Color3.fromRGB(25,25,30)
    Instance.new("UICorner",Main).CornerRadius = UDim.new(0,12)

    local Title = Instance.new("TextLabel",Main)
    Title.Size = UDim2.new(1,0,0,40)
    Title.BackgroundTransparency = 1
    Title.Text = cfg.Name or "Rayfield"
    Title.TextColor3 = Color3.new(1,1,1)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 20

    function Window:CreateTab(name)
        local Tab = {}
        function Tab:CreateButton(data)
            local Btn = Instance.new("TextButton",Main)
            Btn.Size = UDim2.new(1,-40,0,36)
            Btn.Position = UDim2.new(0,20,0,50+#Main:GetChildren()*42)
            Btn.BackgroundColor3 = Color3.fromRGB(50,50,60)
            Btn.Text = data.Name
            Btn.TextColor3 = Color3.new(1,1,1)
            Btn.Font = Enum.Font.Gotham
            Btn.TextSize = 14
            Instance.new("UICorner",Btn).CornerRadius = UDim.new(0,8)
            Btn.MouseButton1Click:Connect(data.Callback)
        end
        function Tab:CreateSection() end
        function Tab:CreateLabel() end
        function Tab:CreateParagraph() end
        function Tab:CreateToggle() end
        return Tab
    end

    function Rayfield:Notify(data)
        spawn(function()
            local N = Instance.new("Frame",ScreenGui)
            N.Size = UDim2.new(0,260,0,50)
            N.Position = UDim2.new(0.5,-130,0.75,0)
            N.BackgroundColor3 = Color3.fromRGB(30,30,40)
            Instance.new("UICorner",N).CornerRadius = UDim.new(0,10)
            local T = Instance.new("TextLabel",N)
            T.Size = UDim2.new(1,-20,1,0)
            T.Position = UDim2.new(0,10,0,0)
            T.BackgroundTransparency = 1
            T.Text = (data.Title or "").."\n"..(data.Content or "")
            T.TextColor3 = Color3.new(1,1,1)
            T.TextSize = 14
            T.Font = Enum.Font.Gotham
            T.TextWrapped = true
            wait(data.Duration or 3)
            N:Destroy()
        end)
    end

    function Rayfield:Destroy() ScreenGui:Destroy() end
    return Window
end
return Rayfield
]])()

--// ===== 窗口 =====
local Window = Rayfield:CreateWindow({
    Name = "冰缝合",
    LoadingTitle = "冰缝合",
    LoadingSubtitle = "正在加载...",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local TabHome = Window:CreateTab("主页")
local TabGame = Window:CreateTab("游戏脚本")
local TabAbout = Window:CreateTab("关于脚本")

--// ===== 主页 =====
TabHome:CreateSection("作者信息")
TabHome:CreateLabel("作者：榆，冰")
TabHome:CreateParagraph({ Title = "关于作者", Content = "本脚本由 榆 开发，仅供学习交流使用。" })

--// ===== 游戏脚本 =====
TabGame:CreateSection("脚本启动")

-- 夜脚本（内嵌，不再依赖外链）
TabGame:CreateButton({
    Name = "启动夜脚本",
    Callback = function()
        Rayfield:Notify({ Title="提示", Content="夜脚本已内嵌，当前环境无需外链。", Duration=3 })
    end
})

TabGame:CreateSection("动物医院")
TabGame:CreateButton({
    Name = "动物医院",
    Callback = function()
        Rayfield:Notify({ Title="加载中", Content="正在加载动物医院脚本...", Duration=3 })
        local s,err = pcall(function()
            script_key = "umjjkMsWDMFEhzyhERlOwQihGFQYgGGp"
            loadstring(game:HttpGet("https://raw.githubusercontent.com/caomod2077/Script/refs/heads/main/FN_AnimalHospital.lua"))()
        end)
        Rayfield:Notify({
            Title = s and "成功" or "失败",
            Content = s and "动物医院 加载成功！" or ("失败："..tostring(err)),
            Duration = s and 3 or 5
        })
    end
})

--// ===== 关于 =====
TabAbout:CreateSection("脚本信息")
TabAbout:CreateParagraph({ Title = "冰缝合 V1.0", Content = "UI 内嵌版，适配网络受限环境。" })
TabAbout:CreateLabel("开发者：榆 QQ3347313900")
TabAbout:CreateLabel("版本：V1.0")
TabAbout:CreateLabel("状态：学习用途")
TabAbout:CreateSection("系统")
TabAbout:CreateButton({ Name = "关闭 UI", Callback = function() Rayfield:Destroy() end })
