local frame

local function toggleMenu()
	if IsValid(frame) then
		frame:Remove()
		frame = nil
		return
	end

	frame = vgui.Create("DFrame")
	frame:SetTitle("Авто-глушитель")
	frame:SetSize(320, 140)
	frame:SetPos((ScrW() - 320) / 2, (ScrH() - 140) / 2)
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
end

concommand.Add("silencer_open", toggleMenu)