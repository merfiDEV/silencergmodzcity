local frame

local function toggleMenu()
	if IsValid(frame) then
		frame:Remove()
		frame = nil
		return
	end

	frame = vgui.Create("DFrame")
	frame:SetTitle("Авто-обвес")
	frame:SetSize(320, 220)
	frame:SetPos((ScrW() - 320) / 2, (ScrH() - 220) / 2)
	frame:SetDraggable(true)
	frame:SetSizable(false)
	frame:ShowCloseButton(true)
	frame:MakePopup()

	frame.OnClose = function()
		frame = nil
	end

	local check = vgui.Create("DCheckBoxLabel", frame)
	check:SetText("Вешать глушитель при выдаче оружия")
	check:SetPos(20, 25)
	check:SetValue(GetConVar("zc_auto_silencer_enabled"):GetBool())

	check.OnChange = function(_, val)
		net.Start("zc_toggle_silencer")
		net.WriteBool(val)
		net.SendToServer()
	end

	local checkSight = vgui.Create("DCheckBoxLabel", frame)
	checkSight:SetText("Рандомный прицел при выдаче")
	checkSight:SetPos(20, 55)
	checkSight:SetValue(GetConVar("zc_auto_silencer_random_sight"):GetBool())

	checkSight.OnChange = function(_, val)
		net.Start("zc_toggle_sight")
		net.WriteBool(val)
		net.SendToServer()
	end

	local checkLaser = vgui.Create("DCheckBoxLabel", frame)
	checkLaser:SetText("Рандомный лазер при выдаче")
	checkLaser:SetPos(20, 85)
	checkLaser:SetValue(GetConVar("zc_auto_silencer_random_laser"):GetBool())

	checkLaser.OnChange = function(_, val)
		net.Start("zc_toggle_laser")
		net.WriteBool(val)
		net.SendToServer()
	end

	local checkNotify = vgui.Create("DCheckBoxLabel", frame)
	checkNotify:SetText("Уведомлять об установке")
	checkNotify:SetPos(20, 115)
	checkNotify:SetValue(GetConVar("zc_auto_silencer_notify"):GetBool())

	checkNotify.OnChange = function(_, val)
		net.Start("zc_toggle_notify")
		net.WriteBool(val)
		net.SendToServer()
	end
end

concommand.Add("silencer_open", toggleMenu)