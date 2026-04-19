-- Nexus UI Library v1.0
-- Open Source, Clean, Modern UI Library for Roblox Scripts
-- Easily host this on GitHub and loadstring it!

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

            return DropdownObj
        end

        return Tab
    end

    function Window:Notify(options)
        local notifTitle = options.Title or "Notification"
        local notifText = options.Content or ""

        local NotifFrame = Create("Frame", {
            Parent = ScreenGui,
            Size = UDim2.new(0, 250, 0, 80),
            Position = UDim2.new(1, 20, 1, -100),
            BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        })
        Create("UICorner", {Parent = NotifFrame, CornerRadius = UDim.new(0, 6)})
        Create("UIStroke", {Parent = NotifFrame, Color = Color3.fromRGB(55, 100, 255), Thickness = 1})

        Create("TextLabel", {
            Parent = NotifFrame,
            Size = UDim2.new(1, -20, 0, 25),
            Position = UDim2.new(0, 10, 0, 5),
            BackgroundTransparency = 1,
            Text = notifTitle,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        Create("TextLabel", {
            Parent = NotifFrame,
            Size = UDim2.new(1, -20, 1, -35),
            Position = UDim2.new(0, 10, 0, 30),
            BackgroundTransparency = 1,
            Text = notifText,
            TextColor3 = Color3.fromRGB(200, 200, 200),
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true
        })

        TweenService:Create(NotifFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(1, -270, 1, -100)}):Play()

        task.delay(options.Duration or 3, function()
            TweenService:Create(NotifFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, 20, 1, -100)}):Play()
            task.delay(0.4, function() NotifFrame:Destroy() end)
        end)
    end

    return Window
end

return Nexus
