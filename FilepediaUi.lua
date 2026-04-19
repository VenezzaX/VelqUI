-- Filepedia v1.0
-- Open Source, Clean, Modern UI Library for Roblox Scripts

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local Nexus = {}

-- Utility to create instances with properties
local function Create(className, properties)
    local inst = Instance.new(className)
    for k, v in pairs(properties) do
        inst[k] = v
    end
    return inst
end

-- Draggable function for the top bar
local function MakeDraggable(topbar, frame)
    local dragging = false
    local dragInput, mousePos, framePos

    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            frame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)
end

function Nexus:CreateWindow(options)
    local title = options.Name or "Nexus UI"
    local guiParent = pcall(function() return CoreGui.Name end) and CoreGui or game.Players.LocalPlayer:WaitForChild("PlayerGui")

    local ScreenGui = Create("ScreenGui", {
        Name = "NexusUI_" .. tostring(math.random(1000,9999)),
        Parent = guiParent,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        Size = UDim2.new(0, 600, 0, 400),
        Position = UDim2.new(0.5, -300, 0.5, -200),
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        BorderSizePixel = 0,
        ClipsDescendants = true
    })
    Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 8)})
    Create("UIStroke", {Parent = MainFrame, Color = Color3.fromRGB(40, 40, 40), Thickness = 1})

    local TopBar = Create("Frame", {
        Name = "TopBar",
        Parent = MainFrame,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        BorderSizePixel = 0
    })
    Create("UICorner", {Parent = TopBar, CornerRadius = UDim.new(0, 8)})

    -- Bottom corner fix for TopBar
    Create("Frame", {
        Parent = TopBar,
        Size = UDim2.new(1, 0, 0, 8),
        Position = UDim2.new(0, 0, 1, -8),
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        BorderSizePixel = 0
    })

    local TitleLabel = Create("TextLabel", {
        Parent = TopBar,
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Close button
    local CloseBtn = Create("TextButton", {
        Parent = TopBar,
        Size = UDim2.new(0, 28, 0, 24),
        Position = UDim2.new(1, -32, 0.5, -12),
        BackgroundColor3 = Color3.fromRGB(200, 60, 60),
        Text = "×",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        AutoButtonColor = false,
        ZIndex = 10
    })
    Create("UICorner", {Parent = CloseBtn, CornerRadius = UDim.new(0, 4)})
    CloseBtn.MouseEnter:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(230, 80, 80)}):Play()
    end)
    CloseBtn.MouseLeave:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(200, 60, 60)}):Play()
    end)
    CloseBtn.MouseButton1Click:Connect(function()
        TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
        task.delay(0.3, function() ScreenGui:Destroy() end)
    end)

    -- Minimize button
    local MinBtn = Create("TextButton", {
        Parent = TopBar,
        Size = UDim2.new(0, 28, 0, 24),
        Position = UDim2.new(1, -64, 0.5, -12),
        BackgroundColor3 = Color3.fromRGB(50, 50, 50),
        Text = "−",
        TextColor3 = Color3.fromRGB(200, 200, 200),
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        AutoButtonColor = false,
        ZIndex = 10
    })
    Create("UICorner", {Parent = MinBtn, CornerRadius = UDim.new(0, 4)})

    local minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 600, 0, 40)}):Play()
            MinBtn.Text = "+"
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 600, 0, 400)}):Play()
            MinBtn.Text = "−"
        end
    end)

    -- RightShift to toggle the whole UI
    local guiVisible = true
    game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
        if input.KeyCode == Enum.KeyCode.RightShift then
            guiVisible = not guiVisible
            MainFrame.Visible = guiVisible
        end
    end)


    MakeDraggable(TopBar, MainFrame)

    local Sidebar = Create("ScrollingFrame", {
        Name = "Sidebar",
        Parent = MainFrame,
        Size = UDim2.new(0, 160, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundColor3 = Color3.fromRGB(22, 22, 22),
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
    })
    Create("UIStroke", {Parent = Sidebar, Color = Color3.fromRGB(35, 35, 35), Thickness = 1})

    local SidebarLayout = Create("UIListLayout", {
        Parent = Sidebar,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6)
    })
    Create("UIPadding", {Parent = Sidebar, PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)})

    local ContentContainer = Create("Frame", {
        Name = "ContentContainer",
        Parent = MainFrame,
        Size = UDim2.new(1, -160, 1, -40),
        Position = UDim2.new(0, 160, 0, 40),
        BackgroundTransparency = 1
    })

    local Window = {
        CurrentTab = nil,
        Tabs = {}
    }

    function Window:CreateTab(tabName)
        local TabBtn = Create("TextButton", {
            Parent = Sidebar,
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = Color3.fromRGB(30, 30, 30),
            Text = tabName,
            TextColor3 = Color3.fromRGB(180, 180, 180),
            Font = Enum.Font.GothamSemibold,
            TextSize = 13,
            AutoButtonColor = false
        })
        Create("UICorner", {Parent = TabBtn, CornerRadius = UDim.new(0, 6)})

        local TabContent = Create("ScrollingFrame", {
            Parent = ContentContainer,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60),
            Visible = false
        })

        local ContentLayout = Create("UIListLayout", {
            Parent = TabContent,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        })
        Create("UIPadding", {Parent = TabContent, PaddingTop = UDim.new(0, 15), PaddingLeft = UDim.new(0, 15), PaddingRight = UDim.new(0, 15), PaddingBottom = UDim.new(0, 15)})

        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 30)
        end)

        TabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(Window.Tabs) do
                t.Content.Visible = false
                TweenService:Create(t.Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 30), TextColor3 = Color3.fromRGB(180, 180, 180)}):Play()
            end
            TabContent.Visible = true
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(55, 100, 255), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            Window.CurrentTab = tabName
        end)

        if not Window.CurrentTab then
            TabContent.Visible = true
            TabBtn.BackgroundColor3 = Color3.fromRGB(55, 100, 255)
            TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            Window.CurrentTab = tabName
        end

        local Tab = {}
        Window.Tabs[tabName] = {Btn = TabBtn, Content = TabContent}

        function Tab:CreateSection(name)
            local SectionLabel = Create("TextLabel", {
                Parent = TabContent,
                Size = UDim2.new(1, 0, 0, 25),
                BackgroundTransparency = 1,
                Text = name,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            Create("Frame", {
                Parent = SectionLabel,
                Size = UDim2.new(1, 0, 0, 1),
                Position = UDim2.new(0, 0, 1, 0),
                BackgroundColor3 = Color3.fromRGB(45, 45, 45),
                BorderSizePixel = 0
            })
        end

        function Tab:CreateButton(options)
            local btnName = options.Name or "Button"
            local callback = options.Callback or function() end

            local ButtonFrame = Create("Frame", {
                Parent = TabContent,
                Size = UDim2.new(1, 0, 0, 38),
                BackgroundColor3 = Color3.fromRGB(32, 32, 32)
            })
            Create("UICorner", {Parent = ButtonFrame, CornerRadius = UDim.new(0, 6)})
            Create("UIStroke", {Parent = ButtonFrame, Color = Color3.fromRGB(45, 45, 45), Thickness = 1})

            local Btn = Create("TextButton", {
                Parent = ButtonFrame,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = btnName,
                TextColor3 = Color3.fromRGB(220, 220, 220),
                Font = Enum.Font.GothamSemibold,
                TextSize = 13
            })

            Btn.MouseEnter:Connect(function() TweenService:Create(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play() end)
            Btn.MouseLeave:Connect(function() TweenService:Create(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(32, 32, 32)}):Play() end)
            Btn.MouseButton1Click:Connect(function()
                TweenService:Create(ButtonFrame, TweenInfo.new(0.07), {BackgroundColor3 = Color3.fromRGB(55, 100, 255)}):Play()
                task.delay(0.12, function()
                    TweenService:Create(ButtonFrame, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(32, 32, 32)}):Play()
                end)
                task.spawn(pcall, callback)
            end)
        end

        function Tab:CreateToggle(options)
            local togName = options.Name or "Toggle"
            local active = options.CurrentValue or false
            local callback = options.Callback or function() end

            local ToggleFrame = Create("Frame", {
                Parent = TabContent,
                Size = UDim2.new(1, 0, 0, 38),
                BackgroundColor3 = Color3.fromRGB(32, 32, 32)
            })
            Create("UICorner", {Parent = ToggleFrame, CornerRadius = UDim.new(0, 6)})
            Create("UIStroke", {Parent = ToggleFrame, Color = Color3.fromRGB(45, 45, 45), Thickness = 1})

            Create("TextLabel", {
                Parent = ToggleFrame,
                Size = UDim2.new(1, -60, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                Text = togName,
                TextColor3 = Color3.fromRGB(220, 220, 220),
                Font = Enum.Font.GothamSemibold,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local ToggleArea = Create("Frame", {
                Parent = ToggleFrame,
                Size = UDim2.new(0, 36, 0, 18),
                Position = UDim2.new(1, -46, 0.5, -9),
                BackgroundColor3 = active and Color3.fromRGB(55, 100, 255) or Color3.fromRGB(20, 20, 20)
            })
            Create("UICorner", {Parent = ToggleArea, CornerRadius = UDim.new(1, 0)})

            local Circle = Create("Frame", {
                Parent = ToggleArea,
                Size = UDim2.new(0, 14, 0, 14),
                Position = active and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            })
            Create("UICorner", {Parent = Circle, CornerRadius = UDim.new(1, 0)})

            local Btn = Create("TextButton", {
                Parent = ToggleFrame,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = ""
            })

            local function FireToggle(state)
                active = state
                local targetX = active and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
                local targetColor = active and Color3.fromRGB(55, 100, 255) or Color3.fromRGB(20, 20, 20)

                TweenService:Create(Circle, TweenInfo.new(0.2), {Position = targetX}):Play()
                TweenService:Create(ToggleArea, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
                pcall(callback, active)
            end

            Btn.MouseButton1Click:Connect(function() FireToggle(not active) end)
            pcall(callback, active)
        end

        function Tab:CreateSlider(options)
            local slName = options.Name or "Slider"
            local min = options.Range and options.Range[1] or 0
            local max = options.Range and options.Range[2] or 100
            local default = options.CurrentValue or min
            local suffix = options.Suffix or ""
            local callback = options.Callback or function() end

            local SliderFrame = Create("Frame", {
                Parent = TabContent,
                Size = UDim2.new(1, 0, 0, 55),
                BackgroundColor3 = Color3.fromRGB(32, 32, 32)
            })
            Create("UICorner", {Parent = SliderFrame, CornerRadius = UDim.new(0, 6)})
            Create("UIStroke", {Parent = SliderFrame, Color = Color3.fromRGB(45, 45, 45), Thickness = 1})

            Create("TextLabel", {
                Parent = SliderFrame,
                Size = UDim2.new(1, -20, 0, 20),
                Position = UDim2.new(0, 15, 0, 8),
                BackgroundTransparency = 1,
                Text = slName,
                TextColor3 = Color3.fromRGB(220, 220, 220),
                Font = Enum.Font.GothamSemibold,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local ValueLabel = Create("TextLabel", {
                Parent = SliderFrame,
                Size = UDim2.new(0, 50, 0, 20),
                Position = UDim2.new(1, -65, 0, 8),
                BackgroundTransparency = 1,
                Text = tostring(default) .. suffix,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Right
            })

            local Track = Create("Frame", {
                Parent = SliderFrame,
                Size = UDim2.new(1, -30, 0, 6),
                Position = UDim2.new(0, 15, 0, 36),
                BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            })
            Create("UICorner", {Parent = Track, CornerRadius = UDim.new(1, 0)})

            local Fill = Create("Frame", {
                Parent = Track,
                Size = UDim2.new(math.clamp((default - min) / (max - min), 0, 1), 0, 1, 0),
                BackgroundColor3 = Color3.fromRGB(55, 100, 255)
            })
            Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(1, 0)})

            local Btn = Create("TextButton", {
                Parent = Track,
                Size = UDim2.new(1, 0, 1, 10),
                Position = UDim2.new(0, 0, 0, -5),
                BackgroundTransparency = 1,
                Text = ""
            })

            local dragging = false
            local function updateSlider(input)
                local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                TweenService:Create(Fill, TweenInfo.new(0.1), {Size = UDim2.new(pos, 0, 1, 0)}):Play()

                local value = math.floor(min + ((max - min) * pos))
                ValueLabel.Text = tostring(value) .. suffix
                pcall(callback, value)
            end

            Btn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    updateSlider(input)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(input)
                end
            end)
        end

        function Tab:CreateDropdown(options)
            local dropName = options.Name or "Dropdown"
            local dropList = options.Options or {}
            local default = options.CurrentOption and options.CurrentOption[1] or (dropList[1] or "")
            local callback = options.Callback or function() end

            local expanded = false

            local DropdownFrame = Create("Frame", {
                Parent = TabContent,
                Size = UDim2.new(1, 0, 0, 38),
                BackgroundColor3 = Color3.fromRGB(32, 32, 32),
                ClipsDescendants = true
            })
            Create("UICorner", {Parent = DropdownFrame, CornerRadius = UDim.new(0, 6)})
            Create("UIStroke", {Parent = DropdownFrame, Color = Color3.fromRGB(45, 45, 45), Thickness = 1})

            local Title = Create("TextLabel", {
                Parent = DropdownFrame,
                Size = UDim2.new(1, -40, 0, 38),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                Text = dropName .. " : " .. tostring(default),
                TextColor3 = Color3.fromRGB(220, 220, 220),
                Font = Enum.Font.GothamSemibold,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local Arrow = Create("TextLabel", {
                Parent = DropdownFrame,
                Size = UDim2.new(0, 20, 0, 38),
                Position = UDim2.new(1, -30, 0, 0),
                BackgroundTransparency = 1,
                Text = "+",
                TextColor3 = Color3.fromRGB(220, 220, 220),
                Font = Enum.Font.GothamBold,
                TextSize = 18
            })

            local Btn = Create("TextButton", {
                Parent = DropdownFrame,
                Size = UDim2.new(1, 0, 0, 38),
                BackgroundTransparency = 1,
                Text = ""
            })

            local ListFrame = Create("ScrollingFrame", {
                Parent = DropdownFrame,
                Size = UDim2.new(1, -20, 1, -45),
                Position = UDim2.new(0, 10, 0, 40),
                BackgroundTransparency = 1,
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
            })
            local ListLayout = Create("UIListLayout", {
                Parent = ListFrame,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 4)
            })

            local function populateList(list)
                for _, child in ipairs(ListFrame:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end

                for _, opt in ipairs(list) do
                    local OptBtn = Create("TextButton", {
                        Parent = ListFrame,
                        Size = UDim2.new(1, 0, 0, 28),
                        BackgroundColor3 = Color3.fromRGB(26, 26, 26),
                        Text = opt,
                        TextColor3 = Color3.fromRGB(200, 200, 200),
                        Font = Enum.Font.Gotham,
                        TextSize = 12
                    })
                    Create("UICorner", {Parent = OptBtn, CornerRadius = UDim.new(0, 4)})

                    OptBtn.MouseButton1Click:Connect(function()
                        Title.Text = dropName .. " : " .. opt
                        expanded = false
                        TweenService:Create(DropdownFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 38)}):Play()
                        Arrow.Text = "+"
                        pcall(callback, opt)
                    end)
                end
                ListFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)
            end

            populateList(dropList)

            Btn.MouseButton1Click:Connect(function()
                expanded = not expanded
                if expanded then
                    TweenService:Create(DropdownFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 140)}):Play()
                    Arrow.Text = "-"
                else
                    TweenService:Create(DropdownFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 38)}):Play()
                    Arrow.Text = "+"
                end
            end)

            local DropdownObj = {}
            function DropdownObj:Refresh(newList, newDefaultList)
                local newDef = (newDefaultList and newDefaultList[1]) or (newList and newList[1]) or ""
                populateList(newList)
                Title.Text = dropName .. " : " .. tostring(newDef)
                pcall(callback, newDef)
            end

            -- Adding missing functions to DropdownObj so they map to velqTab dropdown behavior
            function DropdownObj:AddButton(name, callback)
                Tab:CreateButton({Name = name, Callback = callback})
            end
            function DropdownObj:AddCheckbox(name, callback)
                Tab:CreateToggle({Name = name, Callback = callback})
            end

            return DropdownObj
        end

        return Tab
    end

local VelqUI = Nexus
local Window = VelqUI:CreateWindow({
   Name = "99 Nights in the Forest"
})
local Rayfield = Window -- compatibility alias

local function wrapTab(velqTab)
    local wrapper = {}

    function wrapper:CreateComment(text)
        velqTab:CreateSection(text)
    end

    function wrapper:CreateButton(name, callback)
        velqTab:CreateButton({
            Name = name,
            Callback = callback or function() end
        })
    end

    function wrapper:CreateCheckbox(name, callback)
        velqTab:CreateToggle({
            Name = name,
            CurrentValue = false,
            Flag = name,
            Callback = callback or function() end
        })
    end

    function wrapper:CreateSlider(name, max, defaultVal, callback)
        velqTab:CreateSlider({
            Name = name,
            Range = {0, max or 100},
            Increment = 1,
            Suffix = "",
            CurrentValue = defaultVal or 0,
            Flag = name,
            Callback = callback or function() end
        })
    end

    -- In the old UI, Dropdowns act as Collapsible Sections / Menus that hold buttons and toggles
    function wrapper:CreateDropDown(name, optionalCallback)
        velqTab:CreateSection(name)

        local dropdownWrapper = {}
        function dropdownWrapper:AddButton(btnName, btnCallback)
            velqTab:CreateButton({
                Name = btnName,
                Callback = btnCallback or function() end
            })
        end
        function dropdownWrapper:AddCheckbox(chkName, chkCallback)
            velqTab:CreateToggle({
                Name = chkName,
                CurrentValue = false,
                Flag = name .. "_" .. chkName,
                Callback = chkCallback or function() end
            })
        end
        return dropdownWrapper
    end

    return wrapper
end

local GeneralTabRaw = Window:CreateTab("🏠 General")
local CombatTabRaw = Window:CreateTab("⚔️ Combat")
local AutoTabRaw = Window:CreateTab("🌲 Auto Farm")
local VisualsTabRaw = Window:CreateTab("👁️ Visuals")
local TeleportsTabRaw = Window:CreateTab("🧲 Go To...")
local BringItemsTabRaw = Window:CreateTab("🧲 Bring To Me...")
local ChestsTabRaw = Window:CreateTab("📦 Chests")
local MiscTabRaw = Window:CreateTab("⚙️ Misc")

local main = wrapTab(CombatTabRaw)
local autofarmss = wrapTab(AutoTabRaw)
local gametp = wrapTab(TeleportsTabRaw)
local charactertp = wrapTab(BringItemsTabRaw)
local plr = wrapTab(GeneralTabRaw)
local vis = wrapTab(VisualsTabRaw)
local misc = wrapTab(MiscTabRaw)

-- Proxy wrapper for itemtp to sort "Go To" vs "Bring To Me"
local itemtp = {}
function itemtp:CreateDropDown(name, callback)
    if name:lower():match("teleport item %(bulk%)") or name:lower():match("bring") then
        return wrapTab(BringItemsTabRaw):CreateDropDown(name, callback)
    else
        return wrapTab(TeleportsTabRaw):CreateDropDown(name, callback)
    end
end
function itemtp:CreateCheckbox(name, callback)
    return wrapTab(VisualsTabRaw):CreateCheckbox(name, callback)
end
function itemtp:CreateComment(text)
    return wrapTab(TeleportsTabRaw):CreateComment(text)
end

-- ==========================================
-- ====== SCRIPT 2 (NEW FEATURES) ======
-- ==========================================

-- Additional Services for Script 2
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local workspace = game:GetService("Workspace")
local camera = workspace.CurrentCamera

-- Helper Function to safely get the player's HumanoidRootPart
local function getHRP()
    local char = game.Players.LocalPlayer.Character
    if char then
        return char:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

-- Variables
local teleportTargetsV2 = {
"Good Sack", "Chili", "Old Rod", "Shark", "Clownfish", "Thorn Body", "Bear Corpse", "Ribs", "Old Sack", "Cave Vine Flower", "Alpha Wolf Corpse", "Bolt", "Corn", "Old Flashlight", "Red Key", "Flower", "Moonflower Bulb", "Cultist Gem", "Cooked Morsel", "Laser Cannon", "Turkey Legs", "Mossy Coin", "Candy Corn", "Metal Chair", "Log", "Kunai", "Mandrake Seeds", "Vampire Cloak", "Cooked Ribs", "Casserole", "Leather Body", "Wildfire", "Rifle Ammo", "Frozen Shuriken", "Cooked Steak", "Cake", "Ice Sword", "Beanie", "Mammoth Helmet", "Mammoth Tusk", "Frog Key", "Pumpkin", "Meteor Anvil Base", "Sapling", "Wood", "Crafting Blueprint", "Watering Can", "Cooked Shark", "Chainsaw", "Revolver", "Oil Barrel", "Ray Gun", "Admin Gun", "Bandage", "Snowball", "Infernal Helmet", "Scythe", "Tactical Shotgun", "Salmon", "Spicy Swordfish", "Recipe Book", "Paint Brush", "Obsidiron Chest Blueprint", "Bouncing Blade", "Char", "Stuffing Bowl", "Carrot Cake", "Medkit", "Yellow Key", "Strong Rod", "Poison Spear", "Alien Corpse", "Steak Dinner", "Hearty Stew", "Obsidiron Body", "Berry Seeds", "Rifle", "Cultist Experiment", "Trident", "Pumpkin Pie", "Halloween Blueprint", "Eel", "Armor Trim Kit", "Cultist King Antler", "Cultist Corpse", "Cultist Prototype", "UFO Junk", "Cooked Mackerel", "Arctic Fox Pelt", "Obsidiron Boots", "Washing Machine", "Chili Seeds", "Defense Blueprint", "Stareweed Petal", "Chef's Station", "Cooked Char", "Jellyfish", "Juggernaut Cultist Corpse", "Steak", "Katana", "Wolf Pelt", "Carrot", "Old Radio", "Flamethrower", "Roast Turkey", "Tyre", "Alien Armor", "Broken Fan", "Grey Key", "Old Taming Flute", "Frog Boots", "Furniture Blueprint", "Cooked Turkey Leg", "Crossbow Cultist Corpse", "Iron Body", "Corn on the Cob", "Cooked Lava Eel", "Good Axe", "Cultist King Mace", "Spear", "Admin Sack", "Raw Obsidiron Ore", "Dripleaf Seeds", "Stuffing", "Hammer", "Obsidiron Hammer", "Earmuffs", "Flower Seeds", "Turkey Leg", "Elite Alien Corpse", "Firefly Seeds", "Bunny Foot", "Polar Bear Pelt", "Cultist Staff", "Berry Juice", "Arctic Fox Hat", "Coal", "Lionfish", "Obsidiron Ingot", "Friendly Gun", "Meat? Sandwich", "Dripleaf", "Sweet Potato", "Cooked Eel", "Cooked Clownfish", "Chair", "Purple Fur Tuft", "Alpha Wolf Pelt", "Stareweed Seeds", "Front of Support Notes", "Scalding Obsidiron Ingot", "Cultist King Corpse", "Bear Pelt", "Air Rifle", "Meteor Anvil Back", "Lava Eel", "Meteor Shard", "Cavevine Seeds", "Pumpkin Soup", "Back of Support Notes", "Crossbow", "Jar o' Jelly", "Halloween Candle", "Infernal Crossbow", "Good Rod", "Blowpipe", "Fuel Canister", "Hearty Thanksgiving Meal", "Giant Sack", "Gold Shard", "Anvil Back", "Scrap", "Sheet Metal", "UFO Scrap", "BBQ Ribs", "Strong Taming Flute", "Infernal Sack", "Vampire Scythe", "Strong Axe", "Good Taming Flute", "Riot Shield", "Cooked Swordfish", "Berry", "Revolver Ammo", "Swordfish", "UFO Component", "Meteor Anvil Front", "Forest Gem Fragment", "Polar Bear Hat", "Broken Microwave", "Poison Armor", "Stew", "Seafood Chowder", "Old Axe", "Blue Key", "Cotton Candy", "Witch Potion", "Anvil Base", "Candy Apple", "Morningstar", "Ice Axe", "Forest Gem", "Admin Axe", "Moonflower Seeds", "Laser Sword", "Cooked Lionfish", "Gears", "Strong Flashlight", "Axe Trim Kit", "Morsel", "Mackerel", "Apple", "Stuffed Peppers", "Sweet Potato Pie", "Old Car Engine", "Cooked Salmon", "Sacrifice Totem", "Biofuel", "Anvil Front", "Shotgun Ammo", "Infernal Sword", "Wolf Corpse", "Raw Obsidiron Ore (Shard)", "Scorpion Shell", "Mandrake"}
local AimbotTargetsV2 = {"Alien", "Alpha Wolf", "Wolf", "Crossbow Cultist", "Cultist", "Bunny", "Bear", "Polar Bear"}

local espEnabledV2 = false
local npcESPEnabledV2 = false
local AutoTreeFarmEnabledV2 = false
local ignoreDistanceFromV2 = Vector3.new(0, 0, 0)
local minDistanceV2 = 50

-- Click simulation
local function mouse1click()
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait()
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end)
end

-- Aimbot FOV Circle Setup
local AimbotEnabledV2 = false
local FOVRadiusV2 = 100
local FOVCircleV2
if Drawing then
    FOVCircleV2 = Drawing.new("Circle")
    FOVCircleV2.Color = Color3.fromRGB(128, 255, 0)
    FOVCircleV2.Thickness = 1
    FOVCircleV2.Radius = FOVRadiusV2
    FOVCircleV2.Transparency = 0.5
    FOVCircleV2.Filled = false
    FOVCircleV2.Visible = false
end

-- ESP Function
local function createESPV2(item)
    if not item or not item.Parent then return end

    local adorneePart
    if item:IsA("Model") then
        if item:FindFirstChildWhichIsA("Humanoid") then return end
        adorneePart = item:FindFirstChildWhichIsA("BasePart")
    elseif item:IsA("BasePart") then
        adorneePart = item
    else
        return
    end

    if not adorneePart then return end

    local distance = (adorneePart.Position - ignoreDistanceFromV2).Magnitude
    if distance < minDistanceV2 then return end

    if not item:FindFirstChild("ESP_Billboard") then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP_Billboard"
        billboard.Adornee = adorneePart
        billboard.Size = UDim2.new(0, 50, 0, 20)
        billboard.AlwaysOnTop = true
        billboard.StudsOffset = Vector3.new(0, 2, 0)

        local label = Instance.new("TextLabel", billboard)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.Text = item.Name
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextStrokeTransparency = 0
        label.TextScaled = true
        billboard.Parent = item
    end

    if not item:FindFirstChild("ESP_Highlight") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Highlight"
        highlight.FillColor = Color3.fromRGB(255, 85, 0)
        highlight.OutlineColor = Color3.fromRGB(0, 100, 0)
        highlight.FillTransparency = 0.25
        highlight.OutlineTransparency = 0
        highlight.Adornee = item:IsA("Model") and item or adorneePart
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = item
    end
end

local function toggleESPV2(state)
    espEnabledV2 = state
    for _, item in pairs(workspace:GetDescendants()) do
        if table.find(teleportTargetsV2, item.Name) then
            if espEnabledV2 then
                createESPV2(item)
            else
                local bb = item:FindFirstChild("ESP_Billboard")
                local hl = item:FindFirstChild("ESP_Highlight")
                if bb then bb:Destroy() end
                if hl then hl:Destroy() end
            end
        end
    end
end

workspace.DescendantAdded:Connect(function(desc)
    if espEnabledV2 and table.find(teleportTargetsV2, desc.Name) then
        task.wait(0.1)
        if desc and desc.Parent then
            createESPV2(desc)
        end
    end
end)

-- ESP for NPCs
local npcBoxesV2 = {}

local function createNPCESPV2(npc)
    if not npc or not npc:IsA("Model") or not npc:FindFirstChild("HumanoidRootPart") then return end
    if npcBoxesV2[npc] or not Drawing then return end

    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Transparency = 1
    box.Color = Color3.fromRGB(255, 85, 0)
    box.Filled = false
    box.Visible = true

    local nameText = Drawing.new("Text")
    nameText.Text = npc.Name
    nameText.Color = Color3.fromRGB(255, 255, 255)
    nameText.Size = 16
    nameText.Center = true
    nameText.Outline = true
    nameText.Visible = true

    npcBoxesV2[npc] = {box = box, name = nameText}

    local connection
    connection = npc.AncestryChanged:Connect(function(_, parent)
        if not parent then
            if npcBoxesV2[npc] then
                pcall(function()
                    npcBoxesV2[npc].box:Remove()
                    npcBoxesV2[npc].name:Remove()
                end)
                npcBoxesV2[npc] = nil
            end
            if connection then connection:Disconnect() end
        end
    end)
end

local function toggleNPCESPV2(state)
    npcESPEnabledV2 = state
    if not state then
        for npc, visuals in pairs(npcBoxesV2) do
            pcall(function()
                if visuals.box then visuals.box:Remove() end
                if visuals.name then visuals.name:Remove() end
            end)
        end
        npcBoxesV2 = {}
    else
        for _, obj in ipairs(workspace:GetDescendants()) do
            if table.find(AimbotTargetsV2, obj.Name) and obj:IsA("Model") then
                createNPCESPV2(obj)
            end
        end
    end
end

workspace.DescendantAdded:Connect(function(desc)
    if npcESPEnabledV2 and desc:IsA("Model") and table.find(AimbotTargetsV2, desc.Name) then
        task.wait(0.1)
        if desc and desc.Parent then
            createNPCESPV2(desc)
        end
    end
end)

-- Auto Tree Farm Logic (Safe Iteration)
local badTreesV2 = {}

task.spawn(function()
    while true do
        if AutoTreeFarmEnabledV2 then
            local hrp = getHRP()
            if hrp then
                local trees = {}
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj.Name == "Trunk" and obj.Parent and obj.Parent.Name == "Small Tree" then
                        local distance = (obj.Position - ignoreDistanceFromV2).Magnitude
                        if distance > minDistanceV2 and not badTreesV2[obj:GetFullName()] then
                            table.insert(trees, obj)
                        end
                    end
                end

                table.sort(trees, function(a, b)
                    return (a.Position - hrp.Position).Magnitude < (b.Position - hrp.Position).Magnitude
                end)

                for _, trunk in ipairs(trees) do
                    if not AutoTreeFarmEnabledV2 or not getHRP() then break end

                    pcall(function()
                        game.Players.LocalPlayer.Character:PivotTo(trunk.CFrame + Vector3.new(0, 3, 0))
                    end)

                    task.wait(0.2)
                    local startTime = tick()

                    while AutoTreeFarmEnabledV2 and trunk and trunk.Parent and trunk.Parent.Name == "Small Tree" do
                        if not getHRP() then break end
                        mouse1click()
                        task.wait(0.2)
                        if tick() - startTime > 12 then
                            badTreesV2[trunk:GetFullName()] = true
                            break
                        end
                    end
                    task.wait(0.3)
                end
            end
        end
        task.wait(1.5)
    end
end)

-- Optimized Aimbot & GUI Updates Logic
local lastAimbotCheckV2 = 0
local aimbotCheckIntervalV2 = 0.02
local smoothnessV2 = 0.2

game:GetService("RunService").RenderStepped:Connect(function()
    local mousePos = UserInputService:GetMouseLocation()

    if FOVCircleV2 then
        if AimbotEnabledV2 then
            FOVCircleV2.Position = Vector2.new(mousePos.X, mousePos.Y)
            FOVCircleV2.Visible = true
        else
            FOVCircleV2.Visible = false
        end
    end

    for npc, visuals in pairs(npcBoxesV2) do
        local box = visuals.box
        local name = visuals.name

        if npc and npc.Parent and npc:FindFirstChild("HumanoidRootPart") then
            local hrp = npc.HumanoidRootPart
            local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)

            if onScreen then
                local size = Vector2.new(60, 80)
                box.Position = Vector2.new(screenPos.X - size.X / 2, screenPos.Y - size.Y / 2)
                box.Size = size
                box.Visible = true

                name.Position = Vector2.new(screenPos.X, screenPos.Y - size.Y / 2 - 15)
                name.Visible = true
            else
                box.Visible = false
                name.Visible = false
            end
        else
            pcall(function()
                box:Remove()
                name:Remove()
            end)
            npcBoxesV2[npc] = nil
        end
    end

    if AimbotEnabledV2 and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local currentTime = tick()
        if currentTime - lastAimbotCheckV2 < aimbotCheckIntervalV2 then return end
        lastAimbotCheckV2 = currentTime

        local closestTarget, shortestDistance = nil, math.huge

        for _, obj in ipairs(workspace:GetDescendants()) do
            if table.find(AimbotTargetsV2, obj.Name) and obj:IsA("Model") then
                local head = obj:FindFirstChild("Head")
                if head then
                    local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if dist < shortestDistance and dist <= FOVRadiusV2 then
                            shortestDistance = dist
                            closestTarget = head
                        end
                    end
                end
            end
        end

        if closestTarget then
            pcall(function()
                local currentCF = camera.CFrame
                local targetCF = CFrame.new(currentCF.Position, closestTarget.Position)
                camera.CFrame = currentCF:Lerp(targetCF, smoothnessV2)
            end)
        end
    end
end)

-- Fly Logic
local flyingV2, flyConnectionV2 = false, nil
local speedV2 = 60

local function startFlyingV2()
    local hrp = getHRP()
    if not hrp then return end

    local bodyGyro = Instance.new("BodyGyro", hrp)
    local bodyVelocity = Instance.new("BodyVelocity", hrp)
    bodyGyro.P = 9e4
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.CFrame = hrp.CFrame
    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)

    flyConnectionV2 = game:GetService("RunService").RenderStepped:Connect(function()
        local currentHrp = getHRP()
        if not currentHrp then stopFlyingV2(); return end

        local moveVec = Vector3.zero
        local camCF = camera.CFrame
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVec += camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVec -= camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVec -= camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVec += camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVec += camCF.UpVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveVec -= camCF.UpVector end

        bodyVelocity.Velocity = moveVec.Magnitude > 0 and moveVec.Unit * speedV2 or Vector3.zero
        bodyGyro.CFrame = camCF
    end)
end

function stopFlyingV2()
    if flyConnectionV2 then 
        flyConnectionV2:Disconnect() 
        flyConnectionV2 = nil 
    end
    local hrp = getHRP()
    if hrp then
        for _, v in pairs(hrp:GetChildren()) do
            if v:IsA("BodyGyro") or v:IsA("BodyVelocity") then v:Destroy() end
        end
    end
end

local function toggleFlyV2(state)
    flyingV2 = state
    if flyingV2 then startFlyingV2() else stopFlyingV2() end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Q then
        toggleFlyV2(not flyingV2)
    end
end)

-- ==========================================
-- ====== GUI TABS FOR SCRIPT 2 ======
-- ==========================================

local HomeTabV2 = GeneralTabRaw

HomeTabV2:CreateButton({
    Name = "Teleport to Campfire",
    Callback = function()
        pcall(function() game.Players.LocalPlayer.Character:PivotTo(CFrame.new(0, 10, 0)) end)
    end
})

HomeTabV2:CreateButton({
    Name = "Teleport to Grinder",
    Callback = function()
        pcall(function() game.Players.LocalPlayer.Character:PivotTo(CFrame.new(16.1,4,-4.6)) end)
    end
})

HomeTabV2:CreateToggle({
    Name = "Item ESP (New)",
    CurrentValue = false,
    Callback = toggleESPV2
})

HomeTabV2:CreateToggle({
    Name = "NPC ESP (New)",
    CurrentValue = false,
    Callback = function(value)
        toggleNPCESPV2(value)
    end
})

HomeTabV2:CreateToggle({
    Name = "Auto Tree Farm (Small Tree)",
    CurrentValue = false,
    Callback = function(value)
        AutoTreeFarmEnabledV2 = value
    end
})

HomeTabV2:CreateToggle({
    Name = "Aimbot (Right Click)",
    CurrentValue = false,
    Callback = function(value)
        AimbotEnabledV2 = value
    end
})

HomeTabV2:CreateToggle({
    Name = "Fly (WASD + Space + Shift)",
    CurrentValue = false,
    Callback = function(value)
        toggleFlyV2(value)
    end
})

local TeleTabV2 = TeleportsTabRaw
local ChestsTabV2 = ChestsTabRaw

-- Chest Teleport Logic
local function getActiveChestsV2()
    local activeChests = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        local n = obj.Name:lower()

        -- Check if the name matches chest keywords
        if (n:match("chest") or n:match("crate") or n:match("box") or n:match("safe") or n:match("loot") or n:match("stash")) and (obj:IsA("Model") or obj:IsA("BasePart") or obj:IsA("Folder")) then

            -- FILTER OUT CHILDREN: Ignores "lid" and ignores parts whose parent is the main chest model
            local isChild = false
            if n:match("lid") then
                isChild = true
            elseif obj:IsA("BasePart") and obj.Parent and obj.Parent.Name:lower():match("chest") then
                isChild = true
            end

            if not isChild then
                local dist = 0
                if obj:IsA("Model") and obj.PrimaryPart then
                    dist = (obj.PrimaryPart.Position - ignoreDistanceFromV2).Magnitude
                elseif obj:IsA("BasePart") then
                    dist = (obj.Position - ignoreDistanceFromV2).Magnitude
                else
                    local part = obj:FindFirstChildWhichIsA("BasePart")
                    if part then dist = (part.Position - ignoreDistanceFromV2).Magnitude end
                end

                if dist > minDistanceV2 then
                    if not table.find(activeChests, obj.Name) then
                        table.insert(activeChests, obj.Name)
                    end
                end
            end
        end
    end
    if #activeChests == 0 then table.insert(activeChests, "No Chests Found") end
    return activeChests
end

local selectedChestV2 = nil
local ChestDropdownV2 = ChestsTabV2:CreateDropdown({
    Name = "Select Active Chest",
    Options = getActiveChestsV2(),
    CurrentOption = {"No Chests Found"},
    MultipleOptions = false,
    Flag = "ChestDropdownV2",
    Callback = function(Option)
        selectedChestV2 = type(Option) == "table" and Option[1] or Option
    end,
})

ChestsTabV2:CreateButton({
    Name = "Refresh Chest List",
    Callback = function()
        local newChests = getActiveChestsV2()
        ChestDropdownV2:Refresh(newChests, {newChests[1]})
    end
})

ChestsTabV2:CreateButton({
    Name = "Teleport to Selected Chest",
    Callback = function()
        if not selectedChestV2 or selectedChestV2 == "No Chests Found" then return end

        local closest, shortest = nil, math.huge
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name == selectedChestV2 and (obj:IsA("Model") or obj:IsA("BasePart")) then
                local cf = nil
                if obj:IsA("Model") then
                    pcall(function() cf = obj:GetPivot() end)
                    if not cf then
                        local part = obj:FindFirstChildWhichIsA("BasePart")
                        if part then cf = part.CFrame end
                    end
                else
                    cf = obj.CFrame
                end

                if cf then
                    local dist = (cf.Position - ignoreDistanceFromV2).Magnitude
                    if dist >= minDistanceV2 and dist < shortest then
                        closest = obj
                        shortest = dist
                    end
                end
            end
        end

        if closest then
            local cf = nil
            if closest:IsA("Model") then
                pcall(function() cf = closest:GetPivot() end)
                if not cf then
                    local part = closest:FindFirstChildWhichIsA("BasePart")
                    if part then cf = part.CFrame end
                end
            else
                cf = closest.CFrame
            end

            if cf then
                pcall(function() game.Players.LocalPlayer.Character:PivotTo(cf + Vector3.new(0, 5, 0)) end)
            end
        end
    end
})

-- ==========================================
-- ====== CATEGORIZED ITEM & MOB TP LOGIC ======
-- ==========================================

local categorizedItems = {
    ["Tools"] = {
        "Old Sack", "Good Sack", "Infernal Sack", "Giant Sack", "Admin Sack",
        "Old Axe", "Good Axe", "Ice Axe", "Strong Axe", "Chainsaw", "Admin Axe",
        "Old Rod", "Good Rod", "Strong Rod",
        "Old Taming Flute", "Good Taming Flute", "Strong Taming Flute"
    },
    ["Flashlights"] = {
        "Old Flashlight", "Strong Flashlight"
    },
    ["Trim Kits"] = {
        "Axe Trim Kit", "Armor Trim Kit"
    },
    ["Food"] = {
        "Carrot", "Corn", "Pumpkin", "Berry", "Apple",
        "Morsel", "Cooked Morsel",
        "Steak", "Cooked Steak",
        "Ribs", "Cooked Ribs",
        "Cake", "Chili", "Stew", "Hearty Stew", "Meat? Sandwich",
        "Seafood Chowder", "Steak Dinner", "Pumpkin Soup", "BBQ Ribs",
        "Carrot Cake", "Jar o' Jelly",
        "Candy Apple", "Candy Corn", "Pumpkin Pie", "Cotton Candy"
    },
    ["Fish"] = {
        "Mackerel", "Cooked Mackerel",
        "Salmon", "Cooked Salmon",
        "Clownfish", "Cooked Clownfish",
        "Jellyfish",
        "Char", "Cooked Char",
        "Eel", "Cooked Eel",
        "Swordfish", "Cooked Swordfish",
        "Shark", "Cooked Shark",
        "Lava Eel", "Cooked Lava Eel",
        "Lionfish", "Cooked Lionfish"
    },
    ["Thanksgiving Dinner"] = {
        "Turkey Leg", "Cooked Turkey Leg", "Stuffing", "Sweet Potato",
        "Turkey Legs", "Berry Juice", "Casserole", "Corn on the Cob",
        "Stuffing Bowl", "Roast Turkey", "Stuffed Peppers",
        "Sweet Potato Pie", "Spicy Swordfish", "Hearty Thanksgiving Meal"
    },
    ["Seeds"] = {
        "Chili Seeds", "Flower Seeds", "Berry Seeds", "Firefly Seeds",
        "Dripleaf Seeds", "Moonflower Seeds", "Stareweed Seeds",
        "Cavevine Seeds", "Mandrake Seeds"
    },
    ["Weapons - Melee"] = {
        "Spear", "Morningstar", "Katana", "Laser Sword", "Ice Sword",
        "Trident", "Poison Spear", "Infernal Sword", "Cultist King Mace",
        "Obsidiron Hammer", "Scythe", "Vampire Scythe"
    },
    ["Weapons - Ranged"] = {
        "Revolver", "Rifle", "Tactical Shotgun", "Snowball", "Frozen Shuriken",
        "Kunai", "Ray Gun", "Laser Cannon", "Flamethrower", "Blowpipe",
        "Admin Gun", "Friendly Gun", "Crossbow", "Wildfire",
        "Infernal Crossbow", "Witch Potion", "Bouncing Blade", "Air Rifle"
    },
    ["Ammunition"] = {
        "Revolver Ammo", "Rifle Ammo", "Shotgun Ammo", "Fuel Canister", "Oil Barrel"
    },
    ["Armor"] = {
        "Leather Body", "Poison Armor", "Iron Body", "Thorn Body",
        "Riot Shield", "Alien Armor", "Obsidiron Body", "Vampire Cloak"
    },
    ["Warm Clothing"] = {
        "Earmuffs", "Beanie", "Arctic Fox Hat", "Polar Bear Hat", "Mammoth Helmet"
    },
    ["Boots"] = {
        "Frog Boots", "Obsidiron Boots"
    },
    ["Misc Wearables"] = {
        "Infernal Helmet"
    },
    ["Class Items"] = {
        "Watering Can", "Chef's Station", "Recipe Book",
        "Front of Support Notes", "Back of Support Notes", "Cultist Staff"
    },
    ["Fuel - Resources"] = {
        "Log", "Chair", "Biofuel", "Coal", "Purple Fur Tuft", "Fuel Canister", "Oil Barrel"
    },
    ["Fuel - Corpses"] = {
        "Cultist Corpse", "Crossbow Cultist Corpse", "Juggernaut Cultist Corpse",
        "Cultist King Corpse", "Alien Corpse", "Elite Alien Corpse",
        "Wolf Corpse", "Alpha Wolf Corpse", "Bear Corpse"
    },
    ["Scrap"] = {
        "Bolt", "Sheet Metal", "UFO Junk", "UFO Component", "Broken Fan",
        "Old Radio", "Gears", "Broken Microwave", "Tyre", "Metal Chair",
        "Old Car Engine", "Washing Machine", "Cultist Experiment",
        "Cultist Prototype", "UFO Scrap"
    },
    ["Pelts"] = {
        "Bunny Foot", "Wolf Pelt", "Alpha Wolf Pelt", "Bear Pelt",
        "Arctic Fox Pelt", "Polar Bear Pelt", "Mammoth Tusk",
        "Scorpion Shell", "Cultist King Antler"
    },
    ["Blueprints"] = {
        "Crafting Blueprint", "Defense Blueprint", "Furniture Blueprint",
        "Obsidiron Chest Blueprint", "Halloween Blueprint"
    },
    ["Decoration Tools"] = {
        "Hammer", "Paint Brush"
    },
    ["Materials"] = {
        "Wood", "Scrap", "Cultist Gem", "Forest Gem", "Forest Gem Fragment",
        "Mossy Coin", "Flower", "Sapling", "Sacrifice Totem",
        "Meteor Shard", "Gold Shard",
        "Raw Obsidiron Ore", "Raw Obsidiron Ore (Shard)",
        "Scalding Obsidiron Ingot", "Obsidiron Ingot"
    },
    ["Healing"] = {
        "Bandage", "Medkit", "Cake", "Hearty Stew", "BBQ Ribs", "Carrot Cake", "Jar o' Jelly"
    },
    ["Keys"] = {
        "Red Key", "Blue Key", "Yellow Key", "Grey Key", "Frog Key"
    },
    ["Anvil Parts"] = {
        "Anvil Front", "Anvil Back", "Anvil Base",
        "Meteor Anvil Front", "Meteor Anvil Back", "Meteor Anvil Base"
    },
    ["Potion Ingredients"] = {
        "Dripleaf", "Moonflower Bulb", "Stareweed Petal", "Cave Vine Flower", "Mandrake"
    },
    ["Junk"] = {
        "Halloween Candle"
    }
}

local categorizedMobs = {
    ["Animals"] = {"Wolf", "Alpha Wolf", "Bear", "Polar Bear", "Bunny", "Deer"},
    ["Cultists"] = {"Cultist", "Crossbow Cultist", "Juggernaut Cultist", "Cultist King"},
    ["Aliens & Mutants"] = {"Alien", "Elite Alien", "Cultist Experiment", "Cultist Prototype"},
    ["NPCs & Others"] = {"Lost Child", "Lost Child2", "Lost Child3", "Lost Child4"},
    ["Corpses"] = {"Cultist Corpse", "Crossbow Cultist Corpse", "Juggernaut Cultist Corpse", "Cultist King Corpse",
    "Alien Corpse", "Elite Alien Corpse", "Wolf Corpse", "Alpha Wolf Corpse", "Bear Corpse"}
}

local GoToValues = {}
local BringValues = {}

local remoteEvents = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvents")

-- ================== 1. GO TO... (Teleport Player to Object) ==================

local function AddGoToSection(tabRaw, categoryName, itemsList)
    table.sort(itemsList)
    tabRaw:CreateSection(categoryName)

    local dropdown = tabRaw:CreateDropdown({
        Name = "Select " .. categoryName .. " to Go To",
        Options = itemsList,
        CurrentOption = {itemsList[1]},
        MultipleOptions = false,
        Flag = "GoTo_" .. categoryName,
        Callback = function(Option)
            GoToValues[categoryName] = type(Option) == "table" and Option[1] or Option
        end,
    })
    GoToValues[categoryName] = itemsList[1]

    tabRaw:CreateButton({
        Name = "Teleport to " .. categoryName,
        Callback = function()
            local itemName = GoToValues[categoryName]
            if not itemName then return end

            local closest, shortest = nil, math.huge
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj.Name == itemName and (obj:IsA("Model") or obj:IsA("BasePart")) then
                    local cf = nil
                    if obj:IsA("Model") then
                        pcall(function() cf = obj:GetPivot() end)
                        if not cf then
                            local part = obj:FindFirstChildWhichIsA("BasePart")
                            if part then cf = part.CFrame end
                        end
                    else
                        cf = obj.CFrame
                    end
                    if cf then
                        local dist = (cf.Position - ignoreDistanceFromV2).Magnitude
                        if dist >= minDistanceV2 and dist < shortest then
                            closest = obj
                            shortest = dist
                        end
                    end
                end
            end

            if closest then
                local cf = nil
                if closest:IsA("Model") then pcall(function() cf = closest:GetPivot() end) end
                if not cf and closest:IsA("Model") then
                    local part = closest:FindFirstChildWhichIsA("BasePart")
                    if part then cf = part.CFrame end
                elseif closest:IsA("BasePart") then
                    cf = closest.CFrame
                end

                if cf then
                    pcall(function() game.Players.LocalPlayer.Character:PivotTo(cf + Vector3.new(0, 5, 0)) end)
                    Window:Notify({Title = "Teleported", Content = "Went to " .. itemName, Duration = 3})
                end
            else
                Window:Notify({Title = "Not Found", Content = "Could not find " .. itemName, Duration = 3})
            end
        end
    })
end

for category, items in pairs(categorizedItems) do AddGoToSection(TeleportsTabRaw, category, items) end
for category, mobs in pairs(categorizedMobs) do AddGoToSection(TeleportsTabRaw, category, mobs) end

-- ================== 2. BRING TO ME... (Teleport Object to Player) ==================

local function AddBringSection(tabRaw, categoryName, itemsList, isItem)
    table.sort(itemsList)
    tabRaw:CreateSection(categoryName)

    local dropdown = tabRaw:CreateDropdown({
        Name = "Select " .. categoryName .. " to Bring",
        Options = itemsList,
        CurrentOption = {itemsList[1]},
        MultipleOptions = false,
        Flag = "Bring_" .. categoryName,
        Callback = function(Option)
            BringValues[categoryName] = type(Option) == "table" and Option[1] or Option
        end,
    })
    BringValues[categoryName] = itemsList[1]

    local function getCategoryGridCF(rootPart, index)
        local spacing = 3
        local rowSize = 6
        local col = index % rowSize
        local row = math.floor(index / rowSize)
        local xOffset = (col - math.floor(rowSize / 2)) * spacing
        local zOffset = -5 - (row * spacing)
        return rootPart.CFrame * CFrame.new(xOffset, 0.5, zOffset)
    end

    local function moveSingleNamedTarget(targetName, rootPart, startIndex)
        local count = startIndex or 0
        local sources = isItem and {workspace:FindFirstChild("Items"), game:GetService("ReplicatedStorage"):FindFirstChild("TempStorage")} or {workspace:FindFirstChild("Characters")}

        if isItem and remoteEvents and remoteEvents:FindFirstChild("RequestStartDraggingItem") and remoteEvents:FindFirstChild("StopDraggingItem") then
            for _, source in ipairs(sources) do
                if source then
                    for _, item in ipairs(source:GetChildren()) do
                        if item.Name == targetName then
                            local targetPart = item:FindFirstChildWhichIsA("BasePart") or item:FindFirstChildWhichIsA("MeshPart")
                            if not targetPart then
                                for _, child in ipairs(item:GetDescendants()) do
                                    if child:IsA("BasePart") or child:IsA("MeshPart") then targetPart = child break end
                                end
                            end

                            if targetPart then
                                pcall(function()
                                    remoteEvents.RequestStartDraggingItem:FireServer(item)
                                    targetPart.CFrame = getCategoryGridCF(rootPart, count)
                                    remoteEvents.StopDraggingItem:FireServer(item)
                                end)
                                count = count + 1
                            end
                        end
                    end
                end
            end
        else
            for _, model in ipairs(workspace:GetDescendants()) do
                if model.Name == targetName and model:IsA("Model") then
                    local mainPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
                    if mainPart then
                        local targetCFrame = getCategoryGridCF(rootPart, count)
                        pcall(function()
                            if model.PrimaryPart then
                                model:SetPrimaryPartCFrame(targetCFrame)
                            else
                                mainPart.CFrame = targetCFrame
                            end
                        end)
                        count = count + 1
                    end
                end
            end
        end

        return count
    end

    tabRaw:CreateButton({
        Name = "Bring " .. categoryName .. " to Player",
        Callback = function()
            local itemName = BringValues[categoryName]
            if not itemName then return end

            local rootPart = getHRP()
            if not rootPart then return end

            local count = moveSingleNamedTarget(itemName, rootPart, 0)

            if count > 0 then
                Window:Notify({Title = "Brought", Content = "Brought " .. count .. "x " .. itemName, Duration = 3})
            else
                Window:Notify({Title = "Not Found", Content = "Could not find " .. itemName .. " to bring.", Duration = 3})
            end
        end
    })

    tabRaw:CreateButton({
        Name = "Bring Entire " .. categoryName,
        Callback = function()
            local rootPart = getHRP()
            if not rootPart then return end

            local count = 0
            for _, targetName in ipairs(itemsList) do
                count = moveSingleNamedTarget(targetName, rootPart, count)
                if count % 10 == 0 then task.wait() end
            end

            if count > 0 then
                Window:Notify({Title = "Brought Category", Content = "Brought " .. count .. " items from " .. categoryName, Duration = 4})
            else
                Window:Notify({Title = "Not Found", Content = "Could not find any items from " .. categoryName, Duration = 4})
            end
        end
    })
end

for category, items in pairs(categorizedItems) do AddBringSection(BringItemsTabRaw, category, items, true) end

for category, mobs in pairs(categorizedMobs) do AddBringSection(BringItemsTabRaw, category, mobs, false) end

-- ==========================================
-- ====== END CATEGORIZED ITEM LOGIC ======

-- ==========================================
-- ====== END OF SCRIPT 2 LOGIC ======

-- ==========================================
-- ==========================================

-- Compatibility Layer

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- === Main Configurations === 

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Safe zone setup: 9 baseplates in a grid
local safezoneBaseplates = {}
local baseplateSize = Vector3.new(2048, 1, 2048)
local baseY = 100
local centerPos = Vector3.new(0, baseY, 0) -- original center

for dx = -1, 1 do
    for dz = -1, 1 do
        local pos = centerPos + Vector3.new(dx * baseplateSize.X, 0, dz * baseplateSize.Z)
        local baseplate = Instance.new("Part")
        baseplate.Name = "SafeZoneBaseplate"
        baseplate.Size = baseplateSize
        baseplate.Position = pos
        baseplate.Anchored = true
        baseplate.CanCollide = true
        baseplate.Transparency = 1
        baseplate.Color = Color3.fromRGB(255, 255, 255)
        baseplate.Parent = workspace
        table.insert(safezoneBaseplates, baseplate)
    end
end

-- Checkbox to toggle visibility/collision for all baseplates
main:CreateCheckbox("Show Safe Zone", function(enabled)
    for _, baseplate in ipairs(safezoneBaseplates) do
        baseplate.Transparency = enabled and 0.8 or 1
        baseplate.CanCollide = enabled
    end
end)

-- Utility to convert "x, y, z" string to CFrame
local function stringToCFrame(str)
    local x, y, z = str:match("([^,]+),%s*([^,]+),%s*([^,]+)")
    return CFrame.new(tonumber(x), tonumber(y), tonumber(z))
end

-- Teleport function with optional tween duration
local function teleportToTarget(cf, duration)
    local char = game.Players.LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if duration and duration > 0 then
        local ts = game:GetService("TweenService")
        local info = TweenInfo.new(duration, Enum.EasingStyle.Linear)
        local goal = { CFrame = cf }
        local tween = ts:Create(hrp, info, goal)
        tween:Play()
    else
        hrp.CFrame = cf
    end
end

local storyCoords = {
    { "[campsite] camp site", "0, 8, -0"},
    { "[safezone] safe zone", "0, 110, -0" }
}

local storyDropdown = gametp:CreateDropDown("Teleports")

-- Create dropdown for story teleports
for _, entry in ipairs(storyCoords) do
    local name, coord = entry[1], entry[2]
    storyDropdown:AddButton(name, function()
        teleportToTarget(stringToCFrame(coord), 0.1)
    end)
end

itemtp:CreateCheckbox("Item ESP", function(state)
    local itemFolder = workspace:FindFirstChild("Items")
    if not itemFolder then
        warn("workspace.Items folder not found")
        return
    end

    local itemNames = {
        ["Revolver"] = true, ["Oil Barrel"] = true, ["Chainsaw"] = true, ["Giant Sack"] = true, ["Bunny Foot"] = true,["MedKit"] = true, ["Alien Chest"] = true, ["Berry"] = true,
        ["Bolt"] = true, ["Broken Fan"] = true, ["Carrot"] = true, ["Coal"] = true,
        ["Coin Stack"] = true, ["Hologram Emitter"] = true, ["Item Chest"] = true,
        ["Laser Fence Blueprint"] = true, ["Log"] = true, ["Old Flashlight"] = true,
        ["Old Radio"] = true, ["Sheet Metal"] = true, ["Bandage"] = true, ["Rifle"] = true,
        ["Item Chest2"] = true, ["Item Chest3"] = true, ["Item Chest4"] = true, ["Item Chest5"] = true
    }

    local function isValidESPItem(model)
        if not model then return false end
        local nameLower = model.Name:lower()
        if itemNames[model.Name] then return true end
        if nameLower:match("chest") and not nameLower:match("lid") then return true end
        return false
    end

    local connections = {}

    local function createESP(model)
        if not model:IsA("Model") or not isValidESPItem(model) then return end

        local targetPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
        if not targetPart or model:FindFirstChild("ESP") then return end

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP"
        billboard.Size = UDim2.new(0, 100, 0, 30)
        billboard.Adornee = targetPart
        billboard.AlwaysOnTop = true
        billboard.StudsOffset = Vector3.new(0, 3, 0)

        local customFont = Font.new("rbxassetid://16658246179", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
        local label = Instance.new("TextLabel")

        label.Size = UDim2.new(1, 0, 1, 0)
        label.TextSize = 17
        label.BackgroundTransparency = 1

        label.TextColor3 = model.Name:lower():match("chest") and Color3.fromRGB(255, 215, 0) or Color3.new(1, 1, 1)
        label.TextStrokeTransparency = 0.5
        label.TextScaled = false
        label.FontFace = customFont
        label.Text = model.Name

        label.Parent = billboard
        billboard.Parent = model
    end

    local function removeAllESP()
        for _, model in itemFolder:GetChildren() do
            local esp = model:FindFirstChild("ESP")
            if esp then esp:Destroy() end
        end
    end

    if state then
        for _, model in itemFolder:GetChildren() do
            createESP(model)
        end

        local connection = itemFolder.ChildAdded:Connect(function(model)
            if model:IsA("Model") and isValidESPItem(model) then
                task.wait(0.1) 
                createESP(model)
            end
        end)

        table.insert(connections, connection)
    else
        removeAllESP()
        for _, conn in connections do
            if conn.Disconnect then conn:Disconnect() end
        end
        table.clear(connections)
    end
end)

-- tp to item

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local itemFolder = workspace:WaitForChild("Items")

local itemNames = {
    "Revolver", "Medkit", "Alien Chest", "Berry", "Bolt", "Broken Fan",
    "Carrot", "Coal", "Coin Stack", "Hologram Emitter", "Item Chest",
    "Laser Fence Blueprint", "Log", "Old Flashlight", "Old Radio",
    "Sheet Metal", "Bandage", "Rifle"
}

local function getModelPart(model)
    if model.PrimaryPart then
        return model.PrimaryPart
    end
    for _, part in pairs(model:GetChildren()) do
        if part:IsA("BasePart") then
            return part
        end
    end
    return nil
end

local dropdown = itemtp:CreateDropDown("Teleport to Item")

for _, itemName in ipairs(itemNames) do
    dropdown:AddButton("TP to " .. itemName, function()
        -- Find all models with this name inside Items folder
        local candidates = {}
        for _, model in pairs(itemFolder:GetChildren()) do
            if model:IsA("Model") and model.Name == itemName then
                local part = getModelPart(model)
                if part then
                    table.insert(candidates, part)
                end
            end
        end

        if #candidates == 0 then
            warn("No '" .. itemName .. "' found to teleport to.")
            return
        end

        -- Pick a random part and teleport
        local targetPart = candidates[math.random(1, #candidates)]
        local character = localPlayer.Character
        if character then
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = targetPart.CFrame + Vector3.new(0, 5, 0)
            end
        end
    end)
end

-- tp to item

-- tp item to you  

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

local itemsFolder = workspace:WaitForChild("Items")
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

local possibleItems = {}
local possibleItemsLookup = {}

local function addPossibleItem(name)
    if name and not possibleItemsLookup[name] then
        possibleItemsLookup[name] = true
        table.insert(possibleItems, name)
    end
end

for _, categoryItems in pairs(categorizedItems) do
    for _, itemName in ipairs(categoryItems) do
        addPossibleItem(itemName)
    end
end

-- Keep non-wiki / in-game aliases that already exist in your script
for _, extraName in ipairs({
    "Alien Chest",
    "Item Chest",
    "Coin Stack",
    "Hologram Emitter",
    "Laser Fence Blueprint",
    "Gem of the Forest Fragment",
    "Forest Gem Fragment",
    "MedKit",
    "Medkit",
    "Raygun",
    "Ray Gun",
    "Cultist",
    "Broken Microwave"
}) do
    addPossibleItem(extraName)
end

table.sort(possibleItems)

local bringitemtoyou = itemtp:CreateDropDown("Teleport Item (Bulk):")
local sources = {
    itemsFolder,
    game:GetService("ReplicatedStorage"):WaitForChild("TempStorage")
}

local function teleportItem(itemName)
    local stackOffsetY = 2 -- Height between stacked items
    local count = 0

    for _, source in ipairs(sources) do
        for _, item in ipairs(source:GetChildren()) do
            if item.Name == itemName then
                local targetPart = nil

                if itemName == "Berry" then
                    targetPart = item:FindFirstChild("Handle")
                    if not targetPart then
                        for _, child in ipairs(item:GetDescendants()) do
                            if child:IsA("MeshPart") or child:IsA("Part") or child:IsA("UnionOperation") then
                                targetPart = child
                                break
                            end
                        end
                    end
                else
                    for _, child in ipairs(item:GetDescendants()) do
                        if child:IsA("MeshPart") or child:IsA("Part") then
                            targetPart = child
                            break
                        end
                    end
                end

                if targetPart then
                    remoteEvents.RequestStartDraggingItem:FireServer(item)

                    -- Stack vertically at player's position
                    local offset = Vector3.new(0, count * stackOffsetY, 0)
                    targetPart.CFrame = rootPart.CFrame + offset

                    remoteEvents.StopDraggingItem:FireServer(item)
                    print("Moved", itemName, ":", item:GetFullName())

                    count = count + 1
                else
                    warn(itemName .. " found, but no MeshPart or Part inside:", item:GetFullName())
                end
            end
        end
    end
end

for _, itemName in ipairs(possibleItems) do
    bringitemtoyou:AddButton(itemName, function()
        teleportItem(itemName)
    end)
end

-- tp item to you 

-- tp char to you

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

local characterFolder = workspace:WaitForChild("Characters")

local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents") -- if needed

-- List of character names to teleport (your tags)

-- tp char to you 

-- === Player Sliders ===

-- JumpPower Slider
plr:CreateSlider("jumppower", 700, 50, function(value)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.JumpPower = value
    end
end)

-- WalkSpeed Slider with Persistent Behavior
plr:CreateSlider("walkspeed", 700, 16, function(value)
    _G.HackedWalkSpeed = value

    local function applyWalkSpeed(humanoid)
        if humanoid then
            humanoid.WalkSpeed = _G.HackedWalkSpeed
            humanoid.Changed:Connect(function(property)
                if property == "WalkSpeed" and humanoid.WalkSpeed ~= _G.HackedWalkSpeed then
                    humanoid.WalkSpeed = _G.HackedWalkSpeed
                end
            end)
        end
    end

    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        applyWalkSpeed(LocalPlayer.Character.Humanoid)
    end

    LocalPlayer.CharacterAdded:Connect(function(char)
        char:WaitForChild("Humanoid")
        applyWalkSpeed(char:FindFirstChild("Humanoid"))
    end)
end)

plr:CreateCheckbox("walkspeed toggle (50)",function(toggle)
    if toggle == true then 
    _G.HackedWalkSpeed = 50
        else
    _G.HackedWalkSpeed = 16
    end

    local function applyWalkSpeed(humanoid)
        if humanoid then
            humanoid.WalkSpeed = _G.HackedWalkSpeed
            humanoid.Changed:Connect(function(property)
                if property == "WalkSpeed" and humanoid.WalkSpeed ~= _G.HackedWalkSpeed then
                    humanoid.WalkSpeed = _G.HackedWalkSpeed
                end
            end)
        end
    end

    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        applyWalkSpeed(LocalPlayer.Character.Humanoid)
    end

    LocalPlayer.CharacterAdded:Connect(function(char)
        char:WaitForChild("Humanoid")
        applyWalkSpeed(char:FindFirstChild("Humanoid"))
    end)
end)

--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

--// CONFIG
local espTransparency = 0.4
local teamCheck = true

--// CUSTOM FONT
local customFont = Font.new("rbxassetid://16658246179", Enum.FontWeight.Regular, Enum.FontStyle.Normal)

--// STATE
local BillboardESPs = {}
local ChamsESPs = {}
local ESPConnections = {}

local ESPEnabled = false
local ChamsEnabled = false

--// HELPERS
local function round(num, decimals)
	return tonumber(string.format("%." .. (decimals or 0) .. "f", num))
end

local function getRoot(char)
	return char and char:FindFirstChild("HumanoidRootPart")
end

--// BILLBOARD ESP
local function createBillboardESP(plr)
	if BillboardESPs[plr] or plr == LocalPlayer then return end
	if not plr.Character or not plr.Character:FindFirstChild("Head") then return end

	local gui = Instance.new("BillboardGui")
	gui.Name = "Billboard_ESP"
	gui.Adornee = plr.Character.Head
	gui.Parent = plr.Character.Head
	gui.Size = UDim2.new(0, 100, 0, 40)
	gui.AlwaysOnTop = true
	gui.StudsOffset = Vector3.new(0, 2, 0)

	local label = Instance.new("TextLabel", gui)
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.5
	label.TextScaled = true
	label.FontFace = customFont

	local conn
	conn = RunService.RenderStepped:Connect(function()
		if not plr.Character or not plr.Character:FindFirstChild("Humanoid") then
			gui:Destroy()
			if conn then conn:Disconnect() end
			BillboardESPs[plr] = nil
			ESPConnections[plr] = nil
			return
		end

		local hp = math.floor(plr.Character.Humanoid.Health / plr.Character.Humanoid.MaxHealth * 100)
		label.Text = plr.Name .. " | " .. hp .. "%"
	end)

	BillboardESPs[plr] = gui
	ESPConnections[plr] = conn
end

--// CHAMS ESP (BoxHandleAdornment)
local function createChamsESP(plr)
	if ChamsESPs[plr] or plr == LocalPlayer then return end
	if not plr.Character or not getRoot(plr.Character) then return end

	local folder = Instance.new("Folder")
	folder.Name = "Chams_ESP"
	folder.Parent = CoreGui
	ChamsESPs[plr] = folder

	for _, part in pairs(plr.Character:GetChildren()) do
		if part:IsA("BasePart") then
			local box = Instance.new("BoxHandleAdornment")
			box.Name = "Cham_" .. plr.Name
			box.Adornee = part
			box.AlwaysOnTop = true
			box.ZIndex = 10
			box.Size = part.Size
			box.Transparency = espTransparency
			box.Color = BrickColor.new(
				teamCheck and (plr.TeamColor == LocalPlayer.TeamColor and "Bright green" or "Bright red") or tostring(plr.TeamColor)
			)
			box.Parent = folder
		end
	end
end

--// CLEANUP FUNCTIONS
local function cleanupBillboardESP()
	for _, gui in pairs(BillboardESPs) do
		if gui then gui:Destroy() end
	end
	for _, conn in pairs(ESPConnections) do
		if conn then conn:Disconnect() end
	end
	BillboardESPs = {}
	ESPConnections = {}
end

local function cleanupChamsESP()
	for _, folder in pairs(ChamsESPs) do
		if folder then folder:Destroy() end
	end
	ChamsESPs = {}
end

--// INITIALIZATION HANDLER
local function handlePlayerESP(plr)
	if ESPEnabled then createBillboardESP(plr) end
	if ChamsEnabled then createChamsESP(plr) end

	plr.CharacterAdded:Connect(function()
		task.wait(1)
		if ESPEnabled then createBillboardESP(plr) end
		if ChamsEnabled then createChamsESP(plr) end
	end)
end

--// GUI TOGGLES (INTEGRATE INTO YOUR UI)
vis:CreateCheckbox("ESP", function(state)
	ESPEnabled = state
	if not state then
		cleanupBillboardESP()
	else
		for _, plr in pairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer then
				createBillboardESP(plr)
			end
		end
	end
end)

vis:CreateCheckbox("Chams", function(state)
	ChamsEnabled = state
	if not state then
		cleanupChamsESP()
	else
		for _, plr in pairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer then
				createChamsESP(plr)
			end
		end
	end
end)

--// INIT ON CURRENT PLAYERS
for _, plr in pairs(Players:GetPlayers()) do
	if plr ~= LocalPlayer then
		handlePlayerESP(plr)
	end
end

Players.PlayerAdded:Connect(function(plr)
	handlePlayerESP(plr)
end)

--// FOV CIRCLE
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Transparency = 1
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.ZIndex = 2

local FOVRadius = 100

RunService.RenderStepped:Connect(function()
	if FOVCircle.Visible then
		FOVCircle.Radius = FOVRadius
		FOVCircle.Position = UserInputService:GetMouseLocation()
	end
end)

vis:CreateCheckbox("FOV Circle", function(state)
	FOVCircle.Visible = state
end)

-- extra scripts

local civDropdown2 = misc:CreateDropDown("Extra Scripts", function() end)

civDropdown2:AddButton("infinite yield",function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end)

civDropdown2:AddButton("emote gui",function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/dimension-sources/random-scripts-i-found/refs/heads/main/r6%20animations"))()
end)

civDropdown2:AddButton("anti afk",function()
    
    wait(0.5)local ba=Instance.new("ScreenGui")
local ca=Instance.new("TextLabel")local da=Instance.new("Frame")
local _b=Instance.new("TextLabel")local ab=Instance.new("TextLabel")ba.Parent=game.CoreGui
ba.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;ca.Parent=ba;ca.Active=true
ca.BackgroundColor3=Color3.new(0.176471,0.176471,0.176471)ca.Draggable=true
ca.Position=UDim2.new(0.698610067,0,0.098096624,0)ca.Size=UDim2.new(0,370,0,52)
ca.Font=Enum.Font.SourceSansSemibold;ca.Text="anti afk"ca.TextColor3=Color3.new(0,1,1)
ca.TextSize=22;da.Parent=ca
da.BackgroundColor3=Color3.new(0.196078,0.196078,0.196078)da.Position=UDim2.new(0,0,1.0192306,0)
da.Size=UDim2.new(0,370,0,107)_b.Parent=da
_b.BackgroundColor3=Color3.new(0.176471,0.176471,0.176471)_b.Position=UDim2.new(0,0,0.800455689,0)
_b.Size=UDim2.new(0,370,0,21)_b.Font=Enum.Font.Arial;_b.Text="anti afk"
_b.TextColor3=Color3.new(0,1,1)_b.TextSize=20;ab.Parent=da
ab.BackgroundColor3=Color3.new(0.176471,0.176471,0.176471)ab.Position=UDim2.new(0,0,0.158377,0)
ab.Size=UDim2.new(0,370,0,44)ab.Font=Enum.Font.ArialBold;ab.Text="status: active"
ab.TextColor3=Color3.new(0,1,1)ab.TextSize=20;local bb=game:service'VirtualUser'
game:service'Players'.LocalPlayer.Idled:connect(function()
bb:CaptureController()bb:ClickButton2(Vector2.new())
ab.Text="roblox tried to kick you but failed to do so!"wait(2)ab.Text="status : active"end)

    
end)

civDropdown2:AddButton("turtle spy",function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Turtle-Brand/Turtle-Spy/main/source.lua", true))()
end)

-- extra scripts

-- loop distance

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local player = Players.LocalPlayer

-- Original Kill Aura Variables
local killAuraToggle = false
local radius = 200

-- Infinite Range Kill Aura Variables
local infRangeKillAuraToggle = false
-- Script generated by TurtleSpy, made by Intrer#0421
-- Supported tools and their damage IDs

local toolsDamageIDs = {
    ["Old Axe"] = "1_8982038982",
    ["Good Axe"] = "112_8982038982",
    ["Strong Axe"] = "116_8982038982",
    ["Chainsaw"] = "647_8992824875",
    ["Spear"] = "196_8999010016"
    
}

-- Try to find any supported tool in inventory with damageID
local function getAnyToolWithDamageID()
    for toolName, damageID in pairs(toolsDamageIDs) do
        local tool = player.Inventory:FindFirstChild(toolName)
        if tool then
            return tool, damageID
        end
    end
    return nil, nil
end

-- Equip a given tool
local function equipTool(tool)
    if tool then
        RemoteEvents.EquipItemHandle:FireServer("FireAllClients", tool)
    end
end

-- Unequip a given tool
local function unequipTool(tool)
    if tool then
        RemoteEvents.UnequipItemHandle:FireServer("FireAllClients", tool)
    end
end

-- Original Kill Aura main loop (with radius)
local function killAuraLoop()
    while killAuraToggle do
        local character = player.Character or player.CharacterAdded:Wait()
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local tool, damageID = getAnyToolWithDamageID()
            if tool and damageID then
                equipTool(tool)

                for _, mob in ipairs(Workspace.Characters:GetChildren()) do
                    if mob:IsA("Model") then
                        local part = mob:FindFirstChildWhichIsA("BasePart")
                        if part and (part.Position - hrp.Position).Magnitude <= radius then
                            pcall(function()
                                RemoteEvents.ToolDamageObject:InvokeServer(
                                    mob,
                                    tool,
                                    damageID,
                                    CFrame.new(part.Position)
                                )
                            end)
                        end
                    end
                end

                task.wait(0.1)
            else
                warn("No supported tool found in inventory")
                task.wait(1)
            end
        else
            task.wait(0.5)
        end
    end
end

-- Helper: Get all models recursively in a folder
local function getAllModelsInFolder(folder)
    local models = {}
    for _, obj in ipairs(folder:GetDescendants()) do
        if obj:IsA("Model") then
            table.insert(models, obj)
        end
    end
    return models
end

-- Helper: Find any BasePart descendant of a model
local function findAnyBasePart(model)
    for _, descendant in ipairs(model:GetDescendants()) do
        if descendant:IsA("BasePart") then
            return descendant
        end
    end
    return nil
end

-- UI checkbox toggles
main:CreateCheckbox("Kill Aura", function(state)
    killAuraToggle = state
    if state then
        task.spawn(killAuraLoop)
    else
        local tool, _ = getAnyToolWithDamageID()
        unequipTool(tool)
    end
end)

main:CreateSlider("Kill Aura Radius", 500, 20, function(value)
    radius = math.clamp(value, 20, 500)
end)

-- loop distance

-- extra item automation

itemtp:CreateComment("remaining specific item teleports:")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

local itemsFolder = workspace:WaitForChild("Items")
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

local bracket = {
    weapons = {
        -- Removed Good Axe and Strong Axe
        "Laser Sword", "Raygun", "Kunai", "Katana", "Spear" -- moved to misc tools, but you wanted it here too?
    },
    minifoods = {
        "Apple", "Berry", "Carrot"
    },
    meat = {
        "Steak", "Cooked Steak", "Cooked Morsel" , "Morsel"
    },
    armor = {
        "Leather Body", "Iron Body", "Thorn Body"
    },
    ["guns/ammo"] = {
        "Rifle", "Revolver", "Raygun", "Tactical Shotgun", "Revolver Ammo", "Rifle Ammo"
    },
    materials = {
        "Log", "Coal", "Fuel Canister", "UFO Junk", "UFO Component", "Bandage", "MedKit",
        "Old Car Engine", "Broken Fan", "Old Microwave", "Old Radio", "Sheet Metal"
    },
    pelts = {
        "Alpha Wolf Pelt", "Bear Pelt", "Wolf Pelt", "Bunny Foot"
    },
    misc_tools = {  -- changed to misc_tools for consistency with no spaces
        "Good Sack", "Old Flashlight", "Old Radio", "Giant Sack", "Strong Flashlight", "Chainsaw"
    }
}

-- Finds the first suitable BasePart to teleport
local function findTeleportablePart(item)
    for _, descendant in ipairs(item:GetDescendants()) do
        if descendant:IsA("BasePart") then
            return descendant
        end
        if descendant:IsA("Model") then
            for _, sub in ipairs(descendant:GetDescendants()) do
                if sub:IsA("BasePart") then
                    return sub
                end
            end
        end
    end
    return nil
end

local function teleportItem(itemName)
    local stackOffsetY = 2 -- offset per stacked item
    local count = 0

    for _, item in ipairs(itemsFolder:GetChildren()) do
        if item.Name == itemName then
            local targetPart = findTeleportablePart(item)
            if targetPart then
                remoteEvents.RequestStartDraggingItem:FireServer(item)
                local offset = Vector3.new(0, count * stackOffsetY, 0)
                targetPart.CFrame = rootPart.CFrame + offset
                remoteEvents.StopDraggingItem:FireServer(item)

                print("Moved", itemName, ":", item:GetFullName())
                count = count + 1
            else
                warn("Couldn't find part for:", item:GetFullName())
            end
        end
    end
end

-- Create one dropdown per bracket
for groupName, itemList in pairs(bracket) do
    -- Make dropdown label nicer: replace underscores and slashes, capitalize words
    local label = groupName:gsub("_", " "):gsub("/", "/")
    label = label:gsub("(%a)([%w_']*)", function(first, rest)
        return first:upper() .. rest:lower()
    end)
    local dropdown = itemtp:CreateDropDown(label)
    for _, itemName in ipairs(itemList) do
        dropdown:AddButton(itemName, function()
            teleportItem(itemName)
        end)
    end
end

-- separation for the automation

-- auto 

-- === SERVICES ===
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- === PLAYER REFERENCES ===
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local itemsFolder = Workspace:WaitForChild("Items")
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local remoteConsume = remoteEvents:WaitForChild("RequestConsumeItem")

-- === POSITIONS ===
local campfireDropPos = Vector3.new(0, 19, 0)
local machineDropPos = Vector3.new(21, 16, -5)

-- === ITEM LISTS ===
local campfireFuelItems = {"Log", "Coal", "Fuel Canister", "Oil Barrel", "Biofuel"}
local autocookItems = {"Morsel", "Steak"}
local autoGrindItems = {"UFO Junk", "UFO Component", "Old Car Engine", "Broken Fan", "Old Microwave", "Bolt", "Log", "Cultist Gem", "Sheet Metal", "Old Radio","Tyre","Washing Machine", "Cultist Experiment", "Cultist Component", "Gem of the Forest Fragment", "Broken Microwave"}
local autoEatFoods = {"Cooked Steak", "Cooked Morsel", "Berry", "Carrot", "Apple"}
local biofuelItems = {"Carrot", "Cooked Morsel", "Morsel", "Steak", "Cooked Steak", "Log"}

-- === TOGGLES ===
local autoFuelEnabledItems = {}
local autoCookEnabledItems = {}
local autoGrindEnabledItems = {}
local autoEatEnabled = false
local autoBreakEnabled = false
local autoBiofuelEnabledItems = {}
local alwaysFeedEnabledItems = {}

-- === MOVE ITEM FUNCTION (STABLE) ===
local function moveItemToPos(item, position)
    if not item or not item:IsDescendantOf(workspace) then return end
    local part = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart") or item:FindFirstChild("Handle")
    if not part then return end

    if not item.PrimaryPart then
        pcall(function() item.PrimaryPart = part end)
    end

    pcall(function()
        remoteEvents.RequestStartDraggingItem:FireServer(item)
        task.wait(0.05)
        item:SetPrimaryPartCFrame(CFrame.new(position))
        task.wait(0.05)
        remoteEvents.StopDraggingItem:FireServer(item)
    end)
end

-- === UI INITIALIZATION ===
local autofarmss = autofarmss or main -- fallback if not already defined
local function createDropdownWithCheckboxes(title, itemList, enabledTable)
    local dropdown = autofarmss:CreateDropDown(title)
    for _, itemName in ipairs(itemList) do
        dropdown:AddCheckbox(itemName, function(checked)
            enabledTable[itemName] = checked
        end)
    end
    dropdown:AddCheckbox("Bulk (All)", function(checked)
        for _, itemName in ipairs(itemList) do
            enabledTable[itemName] = checked
        end
    end)
    return dropdown
end

createDropdownWithCheckboxes("Auto Feed Campfire (ignores HP)", campfireFuelItems, alwaysFeedEnabledItems)
createDropdownWithCheckboxes("Auto Feed Campfire (HP Based)", campfireFuelItems, autoFuelEnabledItems)
createDropdownWithCheckboxes("Auto Cook Food", autocookItems, autoCookEnabledItems)
createDropdownWithCheckboxes("Auto Machine Grind", autoGrindItems, autoGrindEnabledItems)
createDropdownWithCheckboxes("Auto Biofuel Processor", biofuelItems, autoBiofuelEnabledItems)

-- Auto Eat
local eatDropdown = autofarmss:CreateDropDown("Auto Eat (3 sec interval)")
eatDropdown:AddCheckbox("Enable Auto Eat", function(checked)
    autoEatEnabled = checked
end)

-- Auto Eat HP Based
local eatHPDropdown = autofarmss:CreateDropDown("Auto Eat (HP Bar Based)")
eatHPDropdown:AddCheckbox("Enable Auto Eat (HP Bar Based)", function(checked)
    autoEatHPEnabled = checked
end)

-- === BACKGROUND COROUTINES ===
coroutine.wrap(function() -- Always Feed Campfire
    while true do
        for itemName, enabled in pairs(alwaysFeedEnabledItems) do
            if enabled then
                for _, item in ipairs(itemsFolder:GetChildren()) do
                    if item.Name == itemName then
                        moveItemToPos(item, campfireDropPos)
                    end
                end
            end
        end
        task.wait(2)
    end
end)()

coroutine.wrap(function() -- HP-Based Feed
    local campfire = Workspace:WaitForChild("Map"):WaitForChild("Campground"):WaitForChild("MainFire")
    local fillFrame = campfire.Center.BillboardGui.Frame.Background.Fill
    while true do
        local healthPercent = fillFrame.Size.X.Scale
        if healthPercent < 0.7 then
            repeat
                for itemName, enabled in pairs(autoFuelEnabledItems) do
                    if enabled then
                        for _, item in ipairs(itemsFolder:GetChildren()) do
                            if item.Name == itemName then
                                moveItemToPos(item, campfireDropPos)
                            end
                        end
                    end
                end
                task.wait(0.5)
                healthPercent = fillFrame.Size.X.Scale
            until healthPercent >= 1
        end
        task.wait(2)
    end
end)()

coroutine.wrap(function() -- Auto Cook
    while true do
        for itemName, enabled in pairs(autoCookEnabledItems) do
            if enabled then
                for _, item in ipairs(itemsFolder:GetChildren()) do
                    if item.Name == itemName then
                        moveItemToPos(item, campfireDropPos)
                    end
                end
            end
        end
        task.wait(2.5)
    end
end)()

coroutine.wrap(function() -- Auto Grind
    while true do
        for itemName, enabled in pairs(autoGrindEnabledItems) do
            if enabled then
                for _, item in ipairs(itemsFolder:GetChildren()) do
                    if item.Name == itemName then
                        moveItemToPos(item, machineDropPos)
                    end
                end
            end
        end
        task.wait(2.5)
    end
end)()

coroutine.wrap(function() -- Auto Eat
    while true do
        if autoEatEnabled then
            local available = {}
            for _, item in ipairs(itemsFolder:GetChildren()) do
                if table.find(autoEatFoods, item.Name) then
                    table.insert(available, item)
                end
            end
            if #available > 0 then
                local food = available[math.random(1, #available)]
                pcall(function() remoteConsume:InvokeServer(food) end)
            end
        end
        task.wait(3)
    end
end)()

local player = game:GetService("Players").LocalPlayer
local hungerBar = player:WaitForChild("PlayerGui"):WaitForChild("Interface"):WaitForChild("StatBars"):WaitForChild("HungerBar"):WaitForChild("Bar")

coroutine.wrap(function() -- Auto Eat (HP Bar Based)
    while true do
        if autoEatHPEnabled then
            if hungerBar.Size.X.Scale <= 0.5 then
                repeat
                    local currentHunger = hungerBar.Size.X.Scale

                    local available = {}
                    for _, item in ipairs(itemsFolder:GetChildren()) do
                        if item.Name and table.find(autoEatFoods, item.Name) then
                            table.insert(available, item)
                            print("Found available food item: ", item.Name)
                        end
                    end

                    if #available > 0 then
                        local food = available[math.random(1, #available)]
                        if food then
                            pcall(function()
                                remoteConsume:InvokeServer(food)
                            end)
                        end
                    else
                        warn("No available food found in inventory.")
                        break -- Stop trying if no food
                    end

                    task.wait(1) -- Wait for GUI to reflect update

                until hungerBar.Size.X.Scale >= 0.99 or not autoEatHPEnabled
            end
        end
        task.wait(3)
    end
end)()

coroutine.wrap(function() -- Auto Biofuel
    local biofuelProcessorPos
    while true do
        if not biofuelProcessorPos then
            local processor = Workspace:FindFirstChild("Structures") and Workspace.Structures:FindFirstChild("Biofuel Processor")
            local part = processor and processor:FindFirstChild("Part")
            if part then
                biofuelProcessorPos = part.Position + Vector3.new(0, 5, 0)
            end
        end

        if biofuelProcessorPos then
            for itemName, enabled in pairs(autoBiofuelEnabledItems) do
                if enabled then
                    for _, item in ipairs(itemsFolder:GetChildren()) do
                        if item.Name == itemName then
                            moveItemToPos(item, biofuelProcessorPos)
                        end
                    end
                end
            end
        end
        task.wait(2)
    end
end)()

-- === TREE TELEPORT SYSTEM ===
local originalTreeCFrames = {}
local treesBrought = false

local function getAllSmallTrees()
    local trees = {}
    local function scan(folder)
        for _, obj in ipairs(folder:GetChildren()) do
            if obj:IsA("Model") and obj.Name == "Small Tree" then
                table.insert(trees, obj)
            end
        end
    end

    local map = Workspace:FindFirstChild("Map")
    if map then
        if map:FindFirstChild("Foliage") then scan(map.Foliage) end
        if map:FindFirstChild("Landmarks") then scan(map.Landmarks) end
    end
    return trees
end

local function findTrunk(tree)
    for _, part in ipairs(tree:GetDescendants()) do
        if part:IsA("BasePart") and part.Name == "Trunk" then return part end
    end
end

local function bringAllTrees()
    local target = CFrame.new(rootPart.Position + rootPart.CFrame.LookVector * 10)
    for _, tree in ipairs(getAllSmallTrees()) do
        local trunk = findTrunk(tree)
        if trunk then
            if not originalTreeCFrames[tree] then originalTreeCFrames[tree] = trunk.CFrame end
            tree.PrimaryPart = trunk
            trunk.Anchored = false
            trunk.CanCollide = false
            task.wait()
            tree:SetPrimaryPartCFrame(target + Vector3.new(math.random(-5,5), 0, math.random(-5,5)))
            trunk.Anchored = true
        end
    end
    treesBrought = true
end

local function restoreTrees()
    for tree, cframe in pairs(originalTreeCFrames) do
        local trunk = findTrunk(tree)
        if trunk then
            tree.PrimaryPart = trunk
            tree:SetPrimaryPartCFrame(cframe)
            trunk.Anchored = true
            trunk.CanCollide = true
        end
    end
    originalTreeCFrames = {}
    treesBrought = false
end

-- Tree toggle
local miscdropdown = autofarmss:CreateDropDown("Auto Misc Features")
miscdropdown:AddCheckbox("Auto Bring All Small Trees", function(checked)
    autoBreakEnabled = checked
    if checked and not treesBrought then
        bringAllTrees()
    elseif not checked and treesBrought then
        restoreTrees()
    end
end)

-- === AUTO STRONGHOLD ===

local strongholdRunning = true -- Always running

local function getStrongholdTimerLabel()
    return workspace:FindFirstChild("Map")
        and workspace.Map:FindFirstChild("Landmarks")
        and workspace.Map.Landmarks:FindFirstChild("Stronghold")
        and workspace.Map.Landmarks.Stronghold:FindFirstChild("Functional")
        and workspace.Map.Landmarks.Stronghold.Functional:FindFirstChild("Sign")
        and workspace.Map.Landmarks.Stronghold.Functional.Sign:FindFirstChild("SurfaceGui")
        and workspace.Map.Landmarks.Stronghold.Functional.Sign.SurfaceGui:FindFirstChild("Frame")
        and workspace.Map.Landmarks.Stronghold.Functional.Sign.SurfaceGui.Frame:FindFirstChild("Body")
end

local initialLabel = getStrongholdTimerLabel()
local initialText = "Stronghold Timer: " .. tostring(initialLabel and initialLabel.ContentText or "N/A")
local strongholdDropdown = main:CreateDropDown("Stronghold Clients")

local strongholdTimeChecker = main:CreateComment(initialText)

-- Coroutine to update timer text every second
coroutine.wrap(function()
    local lastTimerText = nil
    while strongholdRunning do
        local label = getStrongholdTimerLabel()
        local timerText = "Stronghold Timer: " .. tostring(label and label.ContentText or "N/A")

        if timerText ~= lastTimerText then
            if strongholdTimeChecker and type(strongholdTimeChecker) == "table" and strongholdTimeChecker.SetText then
                strongholdTimeChecker:SetText(timerText)
            elseif strongholdTimeChecker and typeof(strongholdTimeChecker) == "Instance" then
                local commentContent = strongholdTimeChecker:FindFirstChild("commentcontent")
                if commentContent then
                    commentContent.Text = timerText
                end
            end
            lastTimerText = timerText
        end

        task.wait(0.5) -- check every second
    end
end)()

strongholdDropdown:AddButton("Teleport to Stronghold", function()
    local targetPart = workspace:FindFirstChild("Map")
        and workspace.Map:FindFirstChild("Landmarks")
        and workspace.Map.Landmarks:FindFirstChild("Stronghold")
        and workspace.Map.Landmarks.Stronghold:FindFirstChild("Functional")
        and workspace.Map.Landmarks.Stronghold.Functional:FindFirstChild("EntryDoors")
        and workspace.Map.Landmarks.Stronghold.Functional.EntryDoors:FindFirstChild("DoorRight")
        and workspace.Map.Landmarks.Stronghold.Functional.EntryDoors.DoorRight:FindFirstChild("Model")

    if targetPart then
        local children = targetPart:GetChildren()
        local destination = children[5]

        if destination and destination:IsA("BasePart") then
            local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                -- Offset slightly above the target to avoid clipping
                hrp.CFrame = destination.CFrame + Vector3.new(0, 5, 0)
                print("Teleported to Stronghold DoorRight Model child #5.")
            else
                warn("HumanoidRootPart not found!")
            end
        else
            warn("Child #5 is missing or not a BasePart!")
        end
    else
        warn("DoorRight.Model path not found!")
    end
end)

-- Teleport to Stronghold Diamond Chest button
strongholdDropdown:AddButton("Teleport to Diamond Chest", function()
    local items = workspace:FindFirstChild("Items")
    if not items then
        warn("Items folder not found!")
        return
    end

    local chest = items:FindFirstChild("Stronghold Diamond Chest")
    if not chest then
        warn("Stronghold Diamond Chest not found!")
        return
    end

    local chestLid = chest:FindFirstChild("ChestLid")
    if not chestLid then
        warn("ChestLid not found!")
        return
    end

    local diamondchest = chestLid:FindFirstChild("Meshes/diamondchest_Cube.002")
    if not diamondchest then
        warn("Diamond chest mesh not found!")
        return
    end

    local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = diamondchest.CFrame + Vector3.new(0, 5, 0)
    else
        warn("HumanoidRootPart not found!")
    end
end)

-- auto 

-- ============================================================
-- REVEAL ALL MAP (Client-Side Fog of War Removal)
-- ============================================================
local function revealFullMap()
    local player = game:GetService("Players").LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui", 5)
    if not playerGui then warn("PlayerGui not found") return end
    local count = 0
    for _, gui in ipairs(playerGui:GetDescendants()) do
        local n = gui.Name:lower()
        if gui:IsA("GuiObject") and (n:match("fog") or n:match("unexplored") or n:match("tile") or n:match("cell") or n:match("chunk") or n:match("dark") or n:match("covered")) then
            pcall(function()
                gui.Visible = false
                gui.BackgroundTransparency = 1
                if gui:IsA("ImageLabel") then gui.ImageTransparency = 1 end
                count = count + 1
            end)
        end
    end
    for _, obj in ipairs(workspace:GetDescendants()) do
        local n = obj.Name:lower()
        if obj:IsA("BasePart") and (n:match("fog") or n:match("mapfog") or n:match("maptile") or n:match("unexplored")) then
            pcall(function() obj.Transparency = 1; obj.CanCollide = false; count = count + 1 end)
        end
    end
    local ok, rs = pcall(function() return game:GetService("ReplicatedStorage") end)
    if ok and rs then
        local remotes = rs:FindFirstChild("RemoteEvents")
        if remotes then
            for _, rem in ipairs(remotes:GetChildren()) do
                local n = rem.Name:lower()
                if n:match("map") or n:match("reveal") or n:match("explore") or n:match("fog") then
                    pcall(function()
                        if rem:IsA("RemoteEvent") then rem:FireServer()
                        elseif rem:IsA("RemoteFunction") then rem:InvokeServer() end
                    end)
                end
            end
        end
    end
    Window:Notify({ Title = "Map Revealed", Content = "Cleared " .. count .. " fog elements.", Duration = 5 })
end

MiscTabRaw:CreateSection("Map")
MiscTabRaw:CreateButton({ Name = "🗺️ Reveal Full Map", Callback = revealFullMap })
MiscTabRaw:CreateButton({
    Name = "🔍 Scan Map Remotes (Debug)",
    Callback = function()
        local rs = game:GetService("ReplicatedStorage")
        local remotes = rs:FindFirstChild("RemoteEvents")
        if not remotes then Window:Notify({ Title = "Debug", Content = "No RemoteEvents folder.", Duration = 4 }) return end
        local names = {}
        for _, r in ipairs(remotes:GetChildren()) do
            local n = r.Name:lower()
            if n:match("map") or n:match("reveal") or n:match("fog") or n:match("explore") then
                table.insert(names, r.Name .. " [" .. r.ClassName .. "]")
            end
        end
        local result = #names > 0 and table.concat(names, ", ") or "None found"
        Window:Notify({ Title = "Map Remotes", Content = result, Duration = 8 })
        print("[Map Remotes]", result)
    end
})
-- ============================================================

-- extra item automation
