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
local TabCommon = Window:CreateTab("常用功能")
local TabGame = Window:CreateTab("游戏脚本")
local TabAbout = Window:CreateTab("关于脚本")

--// ===== 主页 =====
TabHome:CreateSection("作者信息")
TabHome:CreateLabel("作者：榆")
TabHome:CreateParagraph({ Title = "关于作者", Content = "本脚本由 榆 开发，仅供学习交流使用。" })

--// ===== 常用功能 =====
TabCommon:CreateSection("基础操作")
TabCommon:CreateButton({ Name = "执行按钮一", Callback = function() Rayfield:Notify({ Title="提示", Content="按钮一（空功能）", Duration=2 }) end })
TabCommon:CreateToggle({ Name = "开关一", CurrentValue = false, Callback = function() end })
TabCommon:CreateButton({ Name = "执行按钮二", Callback = function() Rayfield:Notify({ Title="提示", Content="按钮二（空功能）", Duration=2 }) end })
TabCommon:CreateToggle({ Name = "开关二", CurrentValue = false, Callback = function() end })

TabCommon:CreateSection("远程脚本")
TabCommon:CreateButton({
    Name = "通用飞踢",
    Callback = function()
        Rayfield:Notify({ Title="加载中", Content="正在加载通用飞踢脚本...", Duration=3 })
        local s, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/wwd6ng2j66-art/-bing/main/通用飞踢.lua"))()
        end)
        Rayfield:Notify({ Title = s and "成功" or "失败", Content = s and "通用飞踢 加载成功！" or ("通用飞踢 加载失败："..tostring(err)), Duration = s and 3 or 5 })
    end
})

TabCommon:CreateSection("扩展操作")
TabCommon:CreateButton({ Name = "执行按钮三", Callback = function() Rayfield:Notify({ Title="提示", Content="按钮三（空功能）", Duration=2 }) end })
TabCommon:CreateToggle({ Name = "开关三", CurrentValue = false, Callback = function() end })

--// ===== 游戏脚本（动物医院 + RB脚本 + 夜脚本）=====
TabGame:CreateSection("动物医院")
TabGame:CreateButton({
    Name = "动物医院",
    Callback = function()
        Rayfield:Notify({ Title="加载中", Content="正在加载动物医院脚本...", Duration=3 })
        local s, err = pcall(function()
            script_key = "umjjkMsWDMFEhzyhERlOwQihGFQYgGGp"
            loadstring(game:HttpGet("https://raw.githubusercontent.com/caomod2077/Script/refs/heads/main/FN_AnimalHospital.lua"))()
        end)
        Rayfield:Notify({ Title = s and "成功" or "失败", Content = s and "动物医院 加载成功！" or ("动物医院 加载失败："..tostring(err)), Duration = s and 3 or 5 })
    end
})

TabGame:CreateSection("RB脚本")
TabGame:CreateButton({
    Name = "RB脚本",
    Callback = function()
        Rayfield:Notify({ Title="加载中", Content="正在加载 RB脚本...", Duration=3 })
        local s, err = pcall(function()
            loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/a0502f7619e7a63fb0dabac96e425c21.lua"))()
        end)
        Rayfield:Notify({ Title = s and "成功" or "失败", Content = s and "RB脚本 加载成功！" or ("RB脚本 加载失败："..tostring(err)), Duration = s and 3 or 5 })
    end
})

--// ===== 夜脚本（新增）=====
TabGame:CreateSection("夜脚本")
TabGame:CreateButton({
    Name = "夜脚本",
    Callback = function()
        Rayfield:Notify({ Title="加载中", Content="正在加载夜脚本...", Duration=3 })
        local s, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ylt410/roblox-Script/refs/heads/main/yejiaoben"))()
        end)
        Rayfield:Notify({ Title = s and "成功" or "失败", Content = s and "夜脚本 加载成功！" or ("夜脚本 加载失败："..tostring(err)), Duration = s and 3 or 5 })
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
