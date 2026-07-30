--// ===== 玩家进出提示系统 =====
_G.PlayerNotify = {}
local PlayerNotifyEnabled = true

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

function _G.PlayerNotify.SetEnabled(state)
    PlayerNotifyEnabled = state
end

local function Notify(content)
    if not PlayerNotifyEnabled then return end
    if not Rayfield then return end
    Rayfield:Notify({
        Title = "玩家提示",
        Content = content,
        Duration = 3
    })
end

-- 监听玩家加入
Players.PlayerAdded:Connect(function(plr)
    if plr ~= LocalPlayer then
        Notify("玩家加入：" .. plr.Name)
    end
end)

-- 监听玩家离开
Players.PlayerRemoving:Connect(function(plr)
    if plr ~= LocalPlayer then
        Notify("玩家离开：" .. plr.Name)
    end
end)

-- 初始化提示已在服务器的玩家
for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then
        Notify("当前在线：" .. plr.Name)
    end
end

--// ===== Rayfield UI =====
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success or not Rayfield then
    Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua', true))()
end

if not Rayfield then
    warn("Rayfield UI 库加载失败，请检查网络或更换执行器。")
    return
end

--// ===== 加载界面 =====
local Window = Rayfield:CreateWindow({
    Name = "冰缝合脚本",
    LoadingTitle = "冰缝合脚本",
    LoadingSubtitle = "正在加载...",
    ConfigurationSaving = {
        Enabled = false
    },
    KeySystem = false
})

--// ===== 标签页 =====
local TabHome = Window:CreateTab("主页")
local TabGame = Window:CreateTab("游戏脚本")
local TabAbout = Window:CreateTab("关于脚本")

--// ===== 主页 =====
TabHome:CreateSection("作者信息")
TabHome:CreateLabel("作者：榆")
TabHome:CreateParagraph({ Title = "关于作者", Content = "本脚本由 榆 开发，仅供学习交流使用。" })

-- ✅ 玩家进出提示 Toggle（已接入）
TabHome:CreateToggle({
    Name = "玩家进出提示",
    CurrentValue = true,
    Callback = function(v)
        _G.PlayerNotify.SetEnabled(v)
    end
})

--// ===== 游戏脚本 =====
TabGame:CreateSection("动物医院")
TabGame:CreateButton({
    Name = "动物医院",
    Callback = function()
        Rayfield:Notify({ Title="加载中", Content="正在加载动物医院脚本...", Duration=3 })
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

--// ===== 关于脚本 =====
TabAbout:CreateSection("脚本信息")
TabAbout:CreateParagraph({ Title = "冰缝合脚本 V1.0", Content = "集成 UI + 玩家提示 + 多脚本加载。" })
TabAbout:CreateLabel("开发者：榆 QQ3347313900")
TabAbout:CreateLabel("版本：V1.0")
TabAbout:CreateLabel("状态：学习用途")
TabAbout:CreateSection("系统")
TabAbout:CreateButton({ Name = "关闭 UI", Callback = function() Rayfield:Destroy() end })
TabAbout:CreateToggle({ Name = "开关五", CurrentValue = false, Callback = function() end })
