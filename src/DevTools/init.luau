--!strict
-- src/DevTools/init.luau
-- Anime Limitless Tower Defense — DevTools Root Package
-- Production-guarded: returns empty table outside Roblox Studio.

local RunService = game:GetService("RunService")
if not RunService:IsStudio() then
	return {}
end

return {
	Version = "5.0.0",
}
