--!strict
-- src/DevTools/AnimationLab/ModelValidator.luau
-- Truthful runtime inspection of all 19 assets (Heroes, Enemies, and Static Map Assets).

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SharedFolder = ReplicatedStorage:WaitForChild("Shared")
local AnimationContract = require(SharedFolder:WaitForChild("AnimationContract")) :: any
local LabConfig = require(script.Parent:WaitForChild("LabConfig")) :: any

local ModelValidator = {}

export type ValidationStatusCode =
	"VALID"
	| "STATIC_MAP_ASSET"
	| "MISSING_MODEL"
	| "MISSING_ROOT"
	| "CHILDREN_ANCHORED"
	| "CONFLICT_WELD_OVER_MOTOR"
	| "PART_COUNT_MISMATCH"
	| "FALLBACK_PROFILE"

export type ModelValidationReport = {
	assetId: string,
	category: string,
	isValid: boolean,
	statusCode: ValidationStatusCode,
	statusBadge: string,
	basePartCount: number,
	expectedBasePartCount: number,
	motor6DCount: number,
	weldCount: number,
	particleEmitterCount: number,
	isRigged: boolean,
	isStaticMapAsset: boolean,
	hasSignatureAnim: boolean,
	hasSignatureVFX: boolean,
	anchoredChildCount: number,
	conflictingWelds: { string },
	missingJoints: { string },
	errors: { string },
	warnings: { string },
}

function ModelValidator.ResolveModelTemplate(assetId: string): (Model?, string?)
	local entry = LabConfig.ASSET_CATALOG[assetId]
	if not entry then
		return nil, string.format("Asset ID '%s' not recognized in LabConfig catalog", assetId)
	end

	local categoryFolder = ReplicatedStorage:FindFirstChild(entry.category)
	if not categoryFolder then
		return nil, string.format("ReplicatedStorage folder '%s' does not exist", entry.category)
	end

	local template = categoryFolder:FindFirstChild(entry.id)
	if not template or not template:IsA("Model") then
		return nil, string.format("Model template '%s' not found under '%s'", entry.id, entry.category)
	end

	return template :: Model, nil
end

function ModelValidator.ValidateModel(target: string | Model): ModelValidationReport
	local assetId = ""
	local model: Model? = nil

	if typeof(target) == "string" then
		assetId = target
		local foundModel, err = ModelValidator.ResolveModelTemplate(assetId)
		if not foundModel then
			return {
				assetId = assetId,
				category = "Unknown",
				isValid = false,
				statusCode = "MISSING_MODEL",
				statusBadge = "ERROR: NOT FOUND",
				basePartCount = 0,
				expectedBasePartCount = 0,
				motor6DCount = 0,
				weldCount = 0,
				particleEmitterCount = 0,
				isRigged = false,
				isStaticMapAsset = false,
				hasSignatureAnim = false,
				hasSignatureVFX = false,
				anchoredChildCount = 0,
				conflictingWelds = {},
				missingJoints = {},
				errors = { err or "Model not found" },
				warnings = {},
			}
		end
		model = foundModel
	elseif typeof(target) == "Instance" and target:IsA("Model") then
		model = target
		assetId = target.Name
	else
		error("ModelValidator.ValidateModel expects an asset ID string or Model instance")
	end

	assert(model ~= nil, "Model must not be nil")
	local entry = LabConfig.ASSET_CATALOG[assetId]
	local category = entry and entry.category or "Unknown"
	local expectedParts = entry and entry.expectedBaseParts or 0
	local isStaticMap = entry and entry.isStaticMapAsset or false
	local hasSignatureAnim = entry and entry.hasSignatureAnim or false
	local hasSignatureVFX = entry and entry.hasSignatureVFX or false

	local errors: { string } = {}
	local warnings: { string } = {}
	local basePartCount = 0
	local motor6DCount = 0
	local weldCount = 0
	local particleEmitterCount = 0
	local anchoredChildCount = 0
	local conflictingWelds: { string } = {}
	local missingJoints: { string } = {}

	-- Check static map assets immediately and return truthful N/A status
	if isStaticMap then
		for _, desc in ipairs(model:GetDescendants()) do
			if desc:IsA("BasePart") then
				basePartCount += 1
			end
		end

		return {
			assetId = assetId,
			category = category,
			isValid = true,
			statusCode = "STATIC_MAP_ASSET",
			statusBadge = "N/A (Static Map Asset)",
			basePartCount = basePartCount,
			expectedBasePartCount = expectedParts,
			motor6DCount = 0,
			weldCount = 0,
			particleEmitterCount = 0,
			isRigged = false,
			isStaticMapAsset = true,
			hasSignatureAnim = false,
			hasSignatureVFX = false,
			anchoredChildCount = 0,
			conflictingWelds = {},
			missingJoints = {},
			errors = {},
			warnings = { "Static map geometry: no joint or animation rig expected." },
		}
	end

	-- Character & Enemy Rig Inspection
	local rootPart = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not rootPart then
		rootPart = model:FindFirstChildWhichIsA("BasePart")
		if not rootPart then
			table.insert(errors, "Model has no BasePart or HumanoidRootPart")
		else
			table.insert(warnings, "Model missing HumanoidRootPart; fallback to first BasePart")
		end
	end

	local motorsByPair: { [string]: Motor6D } = {}
	local jointsPresent: { [string]: boolean } = {}

	for _, desc in ipairs(model:GetDescendants()) do
		if desc:IsA("BasePart") then
			basePartCount += 1
			if rootPart and desc ~= rootPart and desc.Anchored then
				anchoredChildCount += 1
			end
		elseif desc:IsA("Motor6D") then
			motor6DCount += 1
			jointsPresent[desc.Name] = true
			if desc.Part0 and desc.Part1 then
				local pairKey = string.format("%s->%s", desc.Part0.Name, desc.Part1.Name)
				motorsByPair[pairKey] = desc
			end
		elseif desc:IsA("WeldConstraint") or desc:IsA("Weld") then
			weldCount += 1
			local p0 = (desc :: any).Part0
			local p1 = (desc :: any).Part1
			if p0 and p1 then
				local pairKey1 = string.format("%s->%s", p0.Name, p1.Name)
				local pairKey2 = string.format("%s->%s", p1.Name, p0.Name)
				if motorsByPair[pairKey1] or motorsByPair[pairKey2] then
					table.insert(conflictingWelds, string.format("Weld '%s' locks Motor6D between '%s' and '%s'", desc.Name, p0.Name, p1.Name))
				end
			end
		elseif desc:IsA("ParticleEmitter") then
			particleEmitterCount += 1
		end
	end

	if expectedParts > 0 and basePartCount ~= expectedParts then
		table.insert(warnings, string.format("BasePart count (%d) differs from catalog baseline (%d)", basePartCount, expectedParts))
	end

	if anchoredChildCount > 0 then
		table.insert(errors, string.format("%d child parts are Anchored (rigid body lock prevents animation)", anchoredChildCount))
	end

	if #conflictingWelds > 0 then
		for _, cw in ipairs(conflictingWelds) do
			table.insert(errors, cw)
		end
	end

	-- Check standard 6 body joints
	for _, expectedJoint in ipairs(AnimationContract.BODY_JOINTS) do
		if not jointsPresent[expectedJoint] then
			table.insert(missingJoints, expectedJoint)
		end
	end

	local isRigged = motor6DCount >= 5
	local statusCode: ValidationStatusCode = "VALID"
	local statusBadge = "VALID (Signature)"

	if not rootPart then
		statusCode = "MISSING_ROOT"
		statusBadge = "ERROR: NO ROOT"
	elseif anchoredChildCount > 0 then
		statusCode = "CHILDREN_ANCHORED"
		statusBadge = "ERROR: ANCHORED"
	elseif #conflictingWelds > 0 then
		statusCode = "CONFLICT_WELD_OVER_MOTOR"
		statusBadge = "ERROR: WELD CONFLICT"
	elseif #missingJoints > 0 then
		statusCode = "FALLBACK_PROFILE"
		statusBadge = "FALLBACK (Incomplete Rig)"
	elseif not hasSignatureAnim then
		statusCode = "FALLBACK_PROFILE"
		statusBadge = "VALID (Fallback Profile)"
	end

	return {
		assetId = assetId,
		category = category,
		isValid = #errors == 0,
		statusCode = statusCode,
		statusBadge = statusBadge,
		basePartCount = basePartCount,
		expectedBasePartCount = expectedParts,
		motor6DCount = motor6DCount,
		weldCount = weldCount,
		particleEmitterCount = particleEmitterCount,
		isRigged = isRigged,
		isStaticMapAsset = false,
		hasSignatureAnim = hasSignatureAnim,
		hasSignatureVFX = hasSignatureVFX,
		anchoredChildCount = anchoredChildCount,
		conflictingWelds = conflictingWelds,
		missingJoints = missingJoints,
		errors = errors,
		warnings = warnings,
	}
end

function ModelValidator.ValidateAll19Assets(): { [string]: ModelValidationReport }
	local reports: { [string]: ModelValidationReport } = {}
	for assetId, _ in pairs(LabConfig.ASSET_CATALOG) do
		reports[assetId] = ModelValidator.ValidateModel(assetId)
	end
	return reports
end

return table.freeze(ModelValidator)
