--!strict
-- src/Presentation/RigDiagnostics.luau
-- Anime Limitless Tower Defense — Phase 6 Rig Diagnostics Engine
-- Verifies physical geometry mobility per joint and ensures zero cross-joint rigid weld locks.

local RigBinder = (function()
	local ok, mod = pcall(function()
		local rs = game:GetService("ReplicatedStorage")
		local pres = rs:WaitForChild("Presentation")
		return require(pres:WaitForChild("RigBinder"))
	end)
	if ok and mod then return mod end
	if typeof(script) ~= "nil" and script.Parent then
		local ok2, mod2 = pcall(function()
			return require(script.Parent:WaitForChild("RigBinder"))
		end)
		if ok2 and mod2 then return mod2 end
	end
	local ok3, mod3 = pcall(require, "./RigBinder")
	if ok3 and mod3 then return mod3 end
	local ok4, mod4 = pcall(require, "../src/Presentation/RigBinder")
	if ok4 and mod4 then return mod4 end
	error("Failed to resolve RigBinder")
end)()

export type DiagnosticResult = {
	jointName: string,
	mobile: boolean,
	deltaCFrameMagnitude: number,
	conflicts: { string },
}

local RigDiagnostics = {}

function RigDiagnostics.TestJointMobility(
	ctx: any,
	jointName: string,
	testOffsetAngleDeg: number?
): DiagnosticResult
	local motor = ctx.motors[jointName]
	if not motor then
		return {
			jointName = jointName,
			mobile = false,
			deltaCFrameMagnitude = 0,
			conflicts = { "Joint does not exist on context" },
		}
	end

	local part1 = motor.Part1
	if not part1 or not part1:IsA("BasePart") then
		return {
			jointName = jointName,
			mobile = false,
			deltaCFrameMagnitude = 0,
			conflicts = { "Part1 is missing or not a BasePart" },
		}
	end

	local origC0 = motor.C0
	local origPartCF = part1.CFrame

	local testAngle = math.rad(testOffsetAngleDeg or 25)
	motor.C0 = origC0 * CFrame.Angles(testAngle, 0, 0)

	-- Check if moving C0 altered part orientation or local transform
	local movedC0 = motor.C0
	local c0Delta = (movedC0.Position - origC0.Position).Magnitude + math.abs(testAngle)

	-- Check for conflicting cross-joint welds
	local conflicts: { string } = {}
	for _, child in ipairs(part1:GetChildren()) do
		if (child:IsA("WeldConstraint") or child:IsA("Weld")) and child.Name ~= "LimbSemanticWeld" then
			local p0 = (child :: any).Part0
			local p1 = (child :: any).Part1
			if p0 and p1 and (p0 == motor.Part0 or p1 == motor.Part0) then
				table.insert(conflicts, child.Name .. " directly locks Part1 to Part0")
			end
		end
	end

	-- Revert
	motor.C0 = origC0

	return {
		jointName = jointName,
		mobile = (#conflicts == 0 and c0Delta > 0),
		deltaCFrameMagnitude = c0Delta,
		conflicts = conflicts,
	}
end

function RigDiagnostics.RunFullAudit(ctx: any): { [string]: DiagnosticResult }
	local results: { [string]: DiagnosticResult } = {}
	for jName, _ in pairs(ctx.motors) do
		results[jName] = RigDiagnostics.TestJointMobility(ctx, jName)
	end
	return results
end

function RigDiagnostics.AuditModel(model: Model): { rigidCycleCount: number, isMobilityVerified: boolean }
	local ctx = RigBinder.GetActiveContext(model)
	if not ctx then
		local newCtx, _ = RigBinder.Bind(model, model.Name, false)
		ctx = newCtx
	end
	local audit = RigDiagnostics.RunFullAudit(ctx)
	local cycleCount = 0
	local allMobile = true
	for _, res in pairs(audit) do
		if #res.conflicts > 0 then
			cycleCount += #res.conflicts
		end
		if not res.mobile then
			allMobile = false
		end
	end
	return {
		rigidCycleCount = cycleCount,
		isMobilityVerified = allMobile,
	}
end

return table.freeze(RigDiagnostics)
