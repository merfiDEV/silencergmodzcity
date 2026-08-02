if not SERVER then return end

local enabled = CreateConVar("zc_auto_silencer_enabled", 1, FCVAR_REPLICATED + FCVAR_ARCHIVE, "Automatically attach a silencer to every given weapon", 0, 1)

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

local function attachSilencer(wep)
	if not hg or not hg.SetAttachment or not ishgweapon(wep) then return end
	if not wep.attachments or not wep.availableAttachments or not wep.availableAttachments.barrel then return end
	if wep:HasAttachment("barrel", "supressor") then return end

	local silencer = getSilencerFor(wep)
	if not silencer then return end

	hg.SetAttachment(wep.attachments, silencer, wep:GetClass())
	wep:SyncAtts()
end

hook.Add("WeaponEquip", "zc_auto_silencer", function(wep, ply)
	if not enabled:GetBool() then return end
	if not IsValid(ply) or not ply:IsPlayer() or not IsValid(wep) then return end

	timer.Simple(0, function()
		if IsValid(wep) then attachSilencer(wep) end
	end)
end)

util.AddNetworkString("zc_toggle_silencer")
net.Receive("zc_toggle_silencer", function(len, ply)
	if not IsValid(ply) or not ply:IsPlayer() then return end
	enabled:SetBool(net.ReadBool())
end)
