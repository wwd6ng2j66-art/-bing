--// ===== Rayfield =====
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success or not Rayfield then
    Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua', true))()
end

if not Rayfield then
    warn("Rayfield 加载失败")
    return
end

--// ===== 窗口 =====
local Window = Rayfield:CreateWindow({
    Name = "冰缝合脚本",
    LoadingTitle = "冰缝合脚本",
    LoadingSubtitle = "正在加载...",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local TabHome = Window:CreateTab("主页")
local TabGame = Window:CreateTab("游戏脚本")
local TabAbout = Window:CreateTab("关于脚本")

--// ===== 主页 =====
TabHome:CreateSection("作者信息")
TabHome:CreateLabel("作者：榆")
TabHome:CreateParagraph({ Title = "关于作者", Content = "本脚本由 榆 开发，仅供学习交流使用。" })

--// ===== 游戏脚本 =====

-- ✅ 玩家进出提示 Toggle（放在游戏脚本页）
local PlayerNotifyEnabled = true

TabGame:CreateToggle({
    Name = "玩家进出提示",
    CurrentValue = true,
    Callback = function(v)
        PlayerNotifyEnabled = v
    end
})

-- ✅ 安全的 Notify 封装
local function SafeNotify(title, content)
    if not PlayerNotifyEnabled then return end
    pcall(function()
        Rayfield:Notify({
            Title = title,
            Content = content,
            Duration = 3
        })
    end)
end

-- ✅ 玩家监听（关键）
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

Players.PlayerAdded:Connect(function(plr)
    if plr ~= LocalPlayer then
        SafeNotify("玩家加入", plr.Name .. " 进入了游戏")
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    if plr ~= LocalPlayer then
        SafeNotify("玩家离开", plr.Name .. " 离开了游戏")
    end
end)

-- ✅ 初始化：提示当前已在的玩家
for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then
        SafeNotify("当前在线", plr.Name)
    end
end

-- ===== 动物医院 =====
TabGame:CreateSection("动物医院")
TabGame:CreateButton({
    Name = "动物医院",
    Callback = function()
        Rayfield:Notify({ Title="加载中", Content="正在加载动物医院...", Duration=3 })
        local s, err = pcall(function()
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

-- ===== 夜脚本 =====
TabGame:CreateSection("夜脚本")
TabGame:CreateButton({
    Name = "夜脚本",
    Callback = function()
        Rayfield:Notify({ Title="加载中", Content="正在加载夜脚本...", Duration=3 })
        local s, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ylt410/roblox-Script/refs/heads/main/yejiaoben"))()
        end)
        Rayfield:Notify({
            Title = s and "成功" or "失败",
            Content = s and "夜脚本 加载成功！" or ("失败："..tostring(err)),
            Duration = s and 3 or 5
        })
    end
})

-- ===== 叶脚本 =====
TabGame:CreateSection("叶脚本")
TabGame:CreateButton({
    Name = "叶脚本",
    Callback = function()
        Rayfield:Notify({ Title="加载中", Content="正在加载叶脚本...", Duration=3 })
        local s, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/roblox-ye/QQ515966991/refs/heads/main/ROBLOX-CNVIP-XIAOYE.lua"))()
        end)
        Rayfield:Notify({
            Title = s and "成功" or "失败",
            Content = s and "叶脚本 加载成功！" or ("失败："..tostring(err)),
            Duration = s and 3 or 5
        })
    end
})

--// ===== 关于 =====
TabAbout:CreateSection("脚本信息")
TabAbout:CreateParagraph({ Title = "冰缝合脚本 V1.1", Content = "新增玩家进出提示功能。" })
TabAbout:CreateLabel("开发者：榆 QQ3347313900")
TabAbout:CreateLabel("版本：V1.1")
TabAbout:CreateLabel("状态：学习用途")
TabAbout:CreateSection("系统")
TabAbout:CreateButton({ Name = "关闭 UI", Callback = function() Rayfield:Destroy() end })
