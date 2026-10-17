--!strict
-- src/DevToolsServer/LabServer.server.luau
-- Anime Limitless Tower Defense — Phase 6 Studio Lab Server Launcher
-- Placed in ServerScriptService to guarantee server-side registration of AnimationLabCommand in Studio.

local RunService = game:GetService("RunService")
if not RunService:IsStudio() then
	return -- Strict production lockout: zero presence in live games
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DevToolsFolder = ReplicatedStorage:WaitForChild("DevTools", 10) :: Folder?
if not DevToolsFolder then
	return
end

local LabFolder = DevToolsFolder:WaitForChild("AnimationLab", 10) :: Folder?
if not LabFolder then
	return
end

-- Initialize server bootstrap
local serverBootstrap = LabFolder:FindFirstChild("AnimationLabBootstrap.server")
if serverBootstrap and serverBootstrap:IsA("ModuleScript") then
	require(serverBootstrap)
end
