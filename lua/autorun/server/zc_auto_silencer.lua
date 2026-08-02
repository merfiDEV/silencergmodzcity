if not SERVER then return end

local enabled = CreateConVar("zc_auto_silencer_enabled", 1, FCVAR_REPLICATED + FCVAR_ARCHIVE, "Automatically attach a silencer to every given weapon", 0, 1)
local randomSight = CreateConVar("zc_auto_silencer_random_sight", 1, FCVAR_REPLICATED + FCVAR_ARCHIVE, "Attach a random compatible sight to every given weapon", 0, 1)
local randomLaser = CreateConVar("zc_auto_silencer_random_laser", 1, FCVAR_REPLICATED + FCVAR_ARCHIVE, "Attach a random compatible underbarrel laser to every given weapon", 0, 1)
local randomAll = CreateConVar("zc_auto_silencer_random_all", 0, FCVAR_REPLICATED + FCVAR_ARCHIVE, "Random kit: random attachment on every compatible slot", 0, 1)
local notify = CreateConVar("zc_auto_silencer_notify", 1, FCVAR_REPLICATED + FCVAR_ARCHIVE, "Notify the player about installed attachments", 0, 1)

local function getSilencerFor(wep)
	local barrel = wep.availableAttachments and wep.availableAttachments.barrel
	if not barrel then return end

	for _, att in pairs(barrel) do
		if istable(att) and string.find(att[1], "supressor") then
			return att[1]
		end
	end

	return "supressor2"
end

local function getRandomSilencer(wep)
	local barrel = wep.availableAttachments and wep.availableAttachments.barrel
	if not barrel then return end

	local candidates = {}
	for _, att in pairs(barrel) do
		if istable(att) and string.find(att[1], "supressor") then
			candidates[#candidates + 1] = att[1]
		end
	end

	if #candidates == 0 then
		return "supressor2"
	end

	return candidates[math.random(#candidates)]
end

local function getRandomAttachment(attTable, weaponTable)
	local mountTypes = weaponTable.mountType
	if not mountTypes then return end
	if not istable(mountTypes) then mountTypes = {mountTypes} end

	local candidates = {}
	for name, data in pairs(attTable) do
		if not istable(data) or not data[2] or data[2] == "" then continue end
		local mt = data.mountType
		if mt and table.HasValue(mountTypes, mt) then
			candidates[#candidates + 1] = name
		end
	end

	if #candidates == 0 then return end
	return candidates[math.random(#candidates)]
end

local function getRandomSight(wep)
	local sightSlot = wep.availableAttachments and wep.availableAttachments.sight
	if not istable(sightSlot) or wep.scopedef then return end
	return getRandomAttachment(hg.attachments.sight, sightSlot)
end

local function getRandomLaser(wep)
	local underbarrel = wep.availableAttachments and wep.availableAttachments.underbarrel
	if not istable(underbarrel) then return end
	return getRandomAttachment(hg.attachments.underbarrel, underbarrel)
end

local function getRandomGrip(wep)
	local gripSlot = wep.availableAttachments and wep.availableAttachments.grip
	if not istable(gripSlot) then return end
	return getRandomAttachment(hg.attachments.grip, gripSlot)
end

local function getRandomMag(wep)
	local magwell = wep.availableAttachments and wep.availableAttachments.magwell
	if not istable(magwell) then return end

	local candidates = {}
	for _, att in pairs(magwell) do
		if istable(att) and istring(att[1]) and string.find(att[1], "mag") then
			candidates[#candidates + 1] = att[1]
		end
	end

	if #candidates == 0 then return end
	return candidates[math.random(#candidates)]
end

local function getAttachmentName(key)
	if not key then return nil end
	if hg.attachmentslaunguage and hg.attachmentslaunguage[key] then
		return hg.attachmentslaunguage[key]
	end
	return key
end

local function notifyPlayer(ply, label, key)
	if not IsValid(ply) or not notify:GetBool() then return end
	ply:ChatPrint("Установлен " .. label .. ": " .. (getAttachmentName(key) or key))
end

local function attachAndNotify(wep, ply, label, att)
	if not att then return end
	hg.SetAttachment(wep.attachments, att, wep:GetClass())
	notifyPlayer(ply, label, att)
end

local function installRandomKit(wep, ply)
	attachAndNotify(wep, ply, "глушитель", getRandomSilencer(wep))
	attachAndNotify(wep, ply, "прицел", getRandomSight(wep))
	attachAndNotify(wep, ply, "лазер", getRandomLaser(wep))
	attachAndNotify(wep, ply, "рукоятка", getRandomGrip(wep))
	attachAndNotify(wep, ply, "магазин", getRandomMag(wep))
end

local function installDefaults(wep, ply)
	if enabled:GetBool() and wep.availableAttachments.barrel and not wep:HasAttachment("barrel", "supressor") then
		attachAndNotify(wep, ply, "глушитель", getSilencerFor(wep))
	end

	if randomSight:GetBool() and not wep:HasAttachment("sight", "optic") and not wep:HasAttachment("sight", "holo") then
		attachAndNotify(wep, ply, "прицел", getRandomSight(wep))
	end

	if randomLaser:GetBool() and not wep:HasAttachment("underbarrel") then
		attachAndNotify(wep, ply, "лазер", getRandomLaser(wep))
	end
end

local function installAttachments(wep, ply)
	if not hg or not hg.SetAttachment or not ishgweapon(wep) then return end
	if not wep.attachments or not wep.availableAttachments then return end

	if randomAll:GetBool() then
		installRandomKit(wep, ply)
	else
		installDefaults(wep, ply)
	end

	wep:SyncAtts()
	if IsValid(ply) and notify:GetBool() then
		ply:EmitSound("weapons/ump45/ump45_fireselect.wav", 65)
	end
end

hook.Add("WeaponEquip", "zc_auto_silencer", function(wep, ply)
	if not IsValid(ply) or not ply:IsPlayer() or not IsValid(wep) then return end
	if not enabled:GetBool() and not randomSight:GetBool() and not randomLaser:GetBool() and not randomAll:GetBool() then return end

	timer.Simple(0, function()
		if IsValid(wep) then installAttachments(wep, ply) end
	end)
end)

util.AddNetworkString("zc_toggle_silencer")
net.Receive("zc_toggle_silencer", function(len, ply)
	if not IsValid(ply) or not ply:IsPlayer() then return end
	enabled:SetBool(net.ReadBool())
end)

util.AddNetworkString("zc_toggle_sight")
net.Receive("zc_toggle_sight", function(len, ply)
	if not IsValid(ply) or not ply:IsPlayer() then return end
	randomSight:SetBool(net.ReadBool())
end)

util.AddNetworkString("zc_toggle_laser")
net.Receive("zc_toggle_laser", function(len, ply)
	if not IsValid(ply) or not ply:IsPlayer() then return end
	randomLaser:SetBool(net.ReadBool())
end)

util.AddNetworkString("zc_toggle_all")
net.Receive("zc_toggle_all", function(len, ply)
	if not IsValid(ply) or not ply:IsPlayer() then return end
	randomAll:SetBool(net.ReadBool())
end)

util.AddNetworkString("zc_toggle_notify")
net.Receive("zc_toggle_notify", function(len, ply)
	if not IsValid(ply) or not ply:IsPlayer() then return end
	notify:SetBool(net.ReadBool())
end)
