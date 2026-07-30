--// 加载 Rayfield
local bing Script = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

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

--// ===== 左侧栏（只放分类，不放功能）=====
local TabHome = Window:CreateTab("主页")
local TabCommon = Window:CreateTab("常用功能")
local TabGame = Window:CreateTab("游戏脚本")  -- 新增：游戏脚本页
local TabAbout = Window:CreateTab("关于脚本")

--// ===== 主页（右侧显示作者信息）=====
TabHome:CreateSection("作者信息")

TabHome:CreateLabel("作者：榆")

TabHome:CreateParagraph({
    Title = "关于作者",
    Content = "本脚本由 榆 开发，仅供学习交流使用。"
})

--// ===== 常用功能 =====
TabCommon:CreateSection("基础操作")

TabCommon:CreateButton({
    Name = "执行按钮一",
    Callback = function()
        Rayfield:Notify({
            Title = "提示",
            Content = "按钮一（空功能）",
            Duration = 2
        })
    end
})

TabCommon:CreateToggle({
    Name = "开关一",
    CurrentValue = false,
    Callback = function() end
})

TabCommon:CreateButton({
    Name = "执行按钮二",
    Callback = function()
        Rayfield:Notify({
            Title = "提示",
            Content = "按钮二（空功能）",
            Duration = 2
        })
    end
})

TabCommon:CreateToggle({
    Name = "开关二",
    CurrentValue = false,
    Callback = function() end
})

-- ============ 通用飞踢（远程加载脚本）============
TabCommon:CreateSection("远程脚本")

TabCommon:CreateButton({
    Name = "通用飞踢",
    Callback = function()
        Rayfield:Notify({
            Title = "加载中",
            Content = "正在加载通用飞踢脚本...",
            Duration = 3
        })

        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/wwd6ng2j66-art/-bing/main/通用飞踢.lua"))()
        end)

        if success then
            Rayfield:Notify({
                Title = "成功",
                Content = "通用飞踢 加载成功！",
                Duration = 3
            })
        else
            Rayfield:Notify({
                Title = "失败",
                Content = "通用飞踢 加载失败：" .. tostring(err),
                Duration = 5
            })
        end
    end
})

TabCommon:CreateSection("扩展操作")

TabCommon:CreateButton({
    Name = "执行按钮三",
    Callback = function()
        Rayfield:Notify({
            Title = "提示",
            Content = "按钮三（空功能）",
            Duration = 2
        })
    end
})

TabCommon:CreateToggle({
    Name = "开关三",
    CurrentValue = false,
    Callback = function() end
})

--// ===== 游戏脚本页（动物医院 + RB脚本）=====
TabGame:CreateSection("动物医院")

TabGame:CreateButton({
    Name = "动物医院",
    Callback = function()
        Rayfield:Notify({
            Title = "加载中",
            Content = "正在加载动物医院脚本...",
            Duration = 3
        })

        local success, err = pcall(function()
            script_key = "umjjkMsWDMFEhzyhERlOwQihGFQYgGGp"
            loadstring(game:HttpGet("https://raw.githubusercontent.com/caomod2077/Script/refs/heads/main/FN_AnimalHospital.lua"))()
        end)

        if success then
            Rayfield:Notify({
                Title = "成功",
                Content = "动物医院 加载成功！",
                Duration = 3
            })
        else
            Rayfield:Notify({
                Title = "失败",
                Content = "动物医院 加载失败（成功）：" .. tostring(err),
                Duration = 5
            })
        end
    end
})

TabGame:CreateSection("RB脚本")

TabGame:CreateButton({
    Name = "RB脚本",
    Callback = function()
        Rayfield:Notify({
            Title = "加载中",
            Content = "正在加载 RB脚本...",
            Duration = 3
        })

        local success, err = pcall(function()
            loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/a0502f7619e7a63fb0dabac96e425c21.lua"))()
        end)

        if success then
            Rayfield:Notify({
                Title = "成功",
                Content = "RB脚本 加载成功！",
                Duration = 3
            })
        else
            Rayfield:Notify({
                Title = "失败",
                Content = "RB脚本 加载失败：" .. tostring(err),
                Duration = 5
            })
        end
    end
})

--// ===== 关于脚本（右侧显示说明）=====
TabAbout:CreateSection("脚本信息")

TabAbout:CreateParagraph({
    Title = "冰缝合脚本 V1.0",
    Content = "无任何外传，自己玩"
})

TabAbout:CreateLabel("开发者：榆 QQ3347313900")
TabAbout:CreateLabel("版本：V1.0")
TabAbout:CreateLabel("状态：学习用途")

TabAbout:CreateSection("系统")

TabAbout:CreateButton({
    Name = "关闭 UI",
    Callback = function()
        Rayfield:Destroy()
    end
})

TabAbout:CreateToggle({
    Name = "开关五",
    CurrentValue = false,
    Callback = function() end
})
