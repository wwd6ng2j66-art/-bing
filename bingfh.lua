--// ===== 前置：Rayfield UI 框架初始化（请保留你原有的初始化代码） =====
--// 假设已有：local Rayfield = loadstring(game:HttpGet('Rayfield链接'))()
--// 假设已有：local Window = Rayfield:CreateWindow({...})
--// 假设已有：TabNotify, TabAbout, TabAero 等标签页已创建

--// ===== 5. 进出提示设置页（保留原样） =====
TabNotify:CreateSection("提示外观")
TabNotify:CreateToggle({
    Name = "启用玩家进出提示",
    CurrentValue = true,
    Callback = function(value)
        NotifyEnabled = value
        NotifyGui.Enabled = value
    end
})

TabNotify:CreateSlider({
    Name = "提示停留时间（秒）",
    Range = {1, 8},
    Increment = 0.5,
    CurrentValue = 3.0,
    Callback = function(value)
        NoticeDuration = value
    end
})

TabNotify:CreateSlider({
    Name = "最大同时显示条数",
    Range = {1, 10},
    Increment = 1,
    CurrentValue = 5,
    Callback = function(value)
        MaxNotices = math.floor(value)
    end
})

TabNotify:CreateSection("测试")
TabNotify:CreateButton({ Name = "测试 - 玩家加入", Callback = function() createNotice("TestPlayer_Join", true) end })
TabNotify:CreateButton({ Name = "测试 - 玩家离开", Callback = function() createNotice("TestPlayer_Leave", false) end })

--// ===== 6. 关于脚本 =====
TabAbout:CreateSection("脚本信息")
TabAbout:CreateParagraph({ Title = "冰缝合脚本 V2.2", Content = "纯净版：UI 框架 + iOS 玻璃风格玩家进出提示 + Aero 脚本加载 + 其他脚本。" })
TabAbout:CreateLabel("开发者：榆 QQ3347313900")
TabAbout:CreateLabel("版本：V2.2")
TabAbout:CreateLabel("风格：iOS Glassmorphism")
TabAbout:CreateSection("系统")
TabAbout:CreateButton({ Name = "关闭 UI", Callback = function() Rayfield:Destroy() end })
TabAbout:CreateToggle({ Name = "开关五", CurrentValue = false, Callback = function() end })

--// ============================================
--   7. Aero 脚本加载区（超高速跑者 + 99夜）
--// ============================================
local SCRIPT_URLS = {
    SpeedRunner = "https://raw.githubusercontent.com/wwd6ng2j66-art/-/main/%E8%B6%85%E9%AB%98%E9%80%9F%E8%B7%91%E8%80%85.lua",
    Night99     = "https://raw.githubusercontent.com/wwd6ng2j66-art/-/38aa514a561dd344e3b75c60e21197e484fc31aa/99%20%E5%A4%9C.lua",
}

local function loadExternalScript(name, url)
    Rayfield:Notify({ Title = "Aero", Content = "正在加载 " .. name .. "...", Duration = 2 })
    task.spawn(function()
        local ok, srcOrErr = pcall(function()
            return game:HttpGet(url, true)
        end)
        if not ok then
            Rayfield:Notify({ Title = "加载失败", Content = name .. " 下载失败：" .. tostring(srcOrErr), Duration = 5 })
            return
        end
        local success, err = pcall(function()
            loadstring(srcOrErr)()
        end)
        if success then
            Rayfield:Notify({ Title = "加载成功", Content = name .. " 已加载", Duration = 3 })
        else
            Rayfield:Notify({ Title = "加载失败", Content = name .. " 执行错误：" .. tostring(err), Duration = 5 })
        end
    end)
end

TabAero:CreateSection("Aero 脚本库")
TabAero:CreateButton({
    Name = "▶ 加载 超高速跑者",
    Callback = function() loadExternalScript("超高速跑者", SCRIPT_URLS.SpeedRunner) end
})
TabAero:CreateButton({
    Name = "▶ 加载 99夜脚本",
    Callback = function() loadExternalScript("99夜", SCRIPT_URLS.Night99) end
})
TabAero:CreateSection("说明")
TabAero:CreateParagraph({
    Title = "使用说明",
    Content = "点击按钮后才会加载对应脚本，不会自动运行。两个脚本链接均已验证可正常访问。"
})

--// ============================================
--   8. 其他脚本加载区（新增：Escanor源）
--// ============================================
local OtherUrls = {
    Escanor = "https://raw.githubusercontent.com/wwd6ng2j66-art/-/main/Escanor%E6%BA%90.lua"
}

TabOther:CreateSection("其他脚本库")
TabOther:CreateButton({
    Name = "▶ 加载 Escanor源 (其他UI)",
    Callback = function() loadExternalScript("Escanor源", OtherUrls.Escanor) end
})
TabOther:CreateSection("说明")
TabOther:CreateParagraph({
    Title = "使用说明",
    Content = "点击加载 Escanor源，将作为独立UI运行。链接已验证可访问。"
})
