--// 加载 Rayfield
local bing Suture = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

--// ===== 加载界面 =====
local Window = Rayfield:CreateWindow({
    Name = "冰缝合脚本",
    LoadingTitle = "冰缝合脚本",
    LoadingSubtitle = "正在加载...",
    ConfigurationSaving = { Enabled = false },
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

TabCommon:CreateSection("远程脚本")
TabCommon:CreateButton({
    Name = "通用飞踢",
    Callback = function()
        Rayfield:Notify({ Title="加载中", Content="正在加载通用飞踢脚本...", Duration=3 })
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/wwd6ng2j66-art/-bing/main/通用飞踢.lua"))()
        end)
        Rayfield:Notify({ Title = success and "成功" or "失败", Content = success and "通用飞踢 加载成功！" or ("通用飞踢 加载失败："..tostring(err)), Duration = success and 3 or 5 })
    end
})

TabCommon:CreateSection("扩展操作")
TabCommon:CreateButton({ Name = "执行按钮三", Callback = function() Rayfield:Notify({ Title="提示", Content="按钮三（空功能）", Duration=2 }) end })
TabCommon:CreateToggle({ Name = "开关三", CurrentValue = false, Callback = function() end })

--// ===== 游戏脚本（动物医院 + RB脚本）=====
TabGame:CreateSection("动物医院")
TabGame:CreateButton({
    Name = "动物医院",
    Callback = function()
        Rayfield:Notify({ Title="加载中", Content="正在加载动物医院脚本...", Duration=3 })
        local success, err = pcall(function()
            script_key = "umjjkMsWDMFEhzyhERlOwQihGFQYgGGp"
            loadstring(game:HttpGet("https://raw.githubusercontent.com/caomod2077/Script/refs/heads/main/FN_AnimalHospital.lua"))()
        end)
        Rayfield:Notify({ Title = success and "成功" or "失败", Content = success and "动物医院 加载成功！" or ("动物医院 加载失败（成功）："..tostring(err)), Duration = success and 3 or 5 })
    end
})

TabGame:CreateSection("RB脚本")
TabGame:CreateButton({
    Name = "RB脚本",
    Callback = function()
        Rayfield:Notify({ Title="加载中", Content="正在加载 RB脚本...", Duration=3 })
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/a0502f7619e7a63fb0dabac96e425c21.lua"))()
        end)
        Rayfield:Notify({ Title = success and "成功" or "失败", Content = success and "RB脚本 加载成功！" or ("RB脚本 加载失败："..tostring(err)), Duration = success and 3 or 5 })
    end
})

--// ===== 关于脚本 =====
TabAbout:CreateSection("脚本信息")
TabAbout:CreateParagraph({ Title = "冰缝合脚本 V1.0", Content = "纯自己使用￼。" })
TabAbout:CreateLabel("开发者：榆 QQ 3347313900")
TabAbout:CreateLabel("版本：V1.0")
TabAbout:CreateLabel("状态：学习用途")
TabAbout:CreateSection("系统")
TabAbout:CreateButton({ Name = "关闭 UI", Callback = function() Rayfield:Destroy() end })
TabAbout:CreateToggle({ Name = "开关五", CurrentValue = false, Callback = function() end })