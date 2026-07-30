--// 1. 更换为更稳定可靠的 Rayfield 源
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

-- 如果上面的源失效，尝试使用 GitHub 备份源
if not success or not Rayfield then
    Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua', true))()
end

-- 如果 Rayfield 依然没有加载成功，则终止脚本并提示
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

--// ===== 游戏脚本（动物医院）=====
TabGame:CreateSection("动物医院")
TabGame:CreateButton({
    Name = "动物医院",
    Callback = function()
        Rayfield:Notify({ Title="加载中", Content="正在加载动物医院脚本...", Duration=3 })
        local s, err = pcall(function()
            -- 将 script_key 定义在加载前
            script_key = "umjjkMsWDMFEhzyhERlOwQihGFQYgGGp"
            loadstring(game:HttpGet("https://raw.githubusercontent.com/caomod2077/Script/refs/heads/main/FN_AnimalHospital.lua"))()
        end)
        Rayfield:Notify({ Title = s and "成功" or "失败", Content = s and "动物医院 加载成功！" or ("动物医院 加载失败："..tostring(err)), Duration = s and 3 or 5 })
    end
})

--// ===== 关于脚本 =====
TabAbout:CreateSection("脚本信息")
TabAbout:CreateParagraph({ Title = "冰缝合脚本 V1.0", Content = "纯 UI 演示版本，所有按钮与开关均为空功能，仅用于界面布局学习。" })
TabAbout:CreateLabel("开发者：榆QQ3347313900")
TabAbout:CreateLabel("版本：V1.0")
TabAbout:CreateLabel("状态：学习用途")
TabAbout:CreateSection("系统")
TabAbout:CreateButton({ Name = "关闭 UI", Callback = function() Rayfield:Destroy() end })
TabAbout:CreateToggle({ Name = "开关五", CurrentValue = false, Callback = function() end })
