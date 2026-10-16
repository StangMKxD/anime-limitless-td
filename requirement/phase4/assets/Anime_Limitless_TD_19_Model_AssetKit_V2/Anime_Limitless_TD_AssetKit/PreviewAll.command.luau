-- Paste into Studio Command Bar in EDIT mode after Rojo sync.
-- Preview-only: creates Workspace/ASSET_KIT_PREVIEW; delete this folder to clean up.
local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local old = WS:FindFirstChild("ASSET_KIT_PREVIEW")
if old then old:Destroy() end
local display = Instance.new("Folder")
display.Name = "ASSET_KIT_PREVIEW"
display.Parent = WS
local groups = {"HeroModels", "EnemyModels", "MapModels"}
local index = 0
for _, groupName in ipairs(groups) do
    local folder = RS:WaitForChild(groupName)
    local children = folder:GetChildren()
    table.sort(children, function(a, b) return a.Name < b.Name end)
    for _, asset in ipairs(children) do
        if asset:IsA("Model") then
            local x = (index % 5) * 13
            local z = math.floor(index / 5) * 14
            local copy = asset:Clone()
            copy.Name = groupName .. "_" .. asset.Name
            copy:PivotTo(CFrame.new(x, groupName == "MapModels" and 3 or 6, z))
            copy.Parent = display
            local labelPart = Instance.new("Part")
            labelPart.Name = "NamePlate"
            labelPart.Size = Vector3.new(9, .4, 1)
            labelPart.Anchored = true
            labelPart.CanCollide = false
            labelPart.CFrame = CFrame.new(x, 1, z - 4.5)
            labelPart.Color = Color3.fromRGB(39, 44, 59)
            labelPart.Parent = display
            local gui = Instance.new("SurfaceGui")
            gui.Face = Enum.NormalId.Top
            gui.Parent = labelPart
            local text = Instance.new("TextLabel")
            text.Size = UDim2.fromScale(1, 1)
            text.BackgroundTransparency = 1
            text.TextColor3 = Color3.fromRGB(255, 255, 255)
            text.Font = Enum.Font.GothamBold
            text.TextScaled = true
            text.Text = asset.Name
            text.Parent = gui
            index += 1
        end
    end
end
print("[AssetKit] Previewed", index, "models")
