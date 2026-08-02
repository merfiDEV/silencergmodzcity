local frame
local openIcon = Material("entities/zc_auto_silencer", "smooth mips")

local function closeMenu()
	local menu = frame
	frame = nil
	if IsValid(menu) then
		menu:Remove()
	end
end

local function setDescription(panel, title, text)
	panel.title:SetText(title)
	panel.text:SetText(text)
	panel.text:InvalidateLayout(true)
end

local function addRow(scroll, description, text, convarName, netName, helpText)
	local row = vgui.Create("DPanel", scroll)
	row:Dock(TOP)
	row:SetTall(30)
	row:DockMargin(8, 2, 8, 2)
	row.Paint = function(_, w, h)
		draw.RoundedBox(3, 0, 0, w, h, Color(48, 57, 76, 120))
	end

	local check = vgui.Create("DCheckBoxLabel", row)
	check:SetText(text)
	check:SizeToContents()
	check:Dock(LEFT)
	check:DockMargin(0, 2, 0, 0)
	check:SetValue(GetConVar(convarName):GetBool())

	check.OnChange = function(_, val)
		net.Start(netName)
		net.WriteBool(val)
		net.SendToServer()
	end

	local info = vgui.Create("DButton", row)
	info:Dock(RIGHT)
	info:SetWide(28)
	info:DockMargin(4, 3, 3, 3)
	info:SetText("?")
	info:SetTooltip(false)
	info.DoClick = function()
		setDescription(description, text, helpText)
	end

	check.DoRightClick = function()
		setDescription(description, text, helpText)
	end
end

local function toggleMenu()
	if IsValid(frame) then
		closeMenu()
		return
	end

	frame = vgui.Create("DFrame")
	frame:SetTitle("Авто-обвес")
	frame:SetSize(620, 440)
	frame:SetPos((ScrW() - 620) / 2, (ScrH() - 440) / 2)
	frame:SetDraggable(true)
	frame:SetSizable(false)
	frame:ShowCloseButton(true)
	frame:MakePopup()
	frame.OnClose = function()
		frame = nil
	end

	local closeBtn = vgui.Create("DButton", frame)
	closeBtn:SetText("Закрыть")
	closeBtn:Dock(BOTTOM)
	closeBtn:SetTall(26)
	closeBtn:DockMargin(8, 2, 8, 8)
	closeBtn.DoClick = closeMenu

	local description = vgui.Create("DPanel", frame)
	description:Dock(BOTTOM)
	description:SetTall(165)
	description:DockMargin(8, 4, 8, 0)
	description.Paint = function(_, w, h)
		draw.RoundedBox(5, 0, 0, w, h, Color(22, 27, 38, 245))
		surface.SetDrawColor(98, 125, 190, 255)
		surface.DrawOutlinedRect(0, 0, w, h)
	end

	description.title = vgui.Create("DLabel", description)
	description.title:Dock(TOP)
	description.title:DockMargin(12, 10, 12, 4)
	description.title:SetFont("DermaDefaultBold")
	description.title:SetTextColor(Color(165, 190, 255))
	description.title:SetText("Описание настройки")
	description.title:SetTall(18)

	description.text = vgui.Create("DLabel", description)
	description.text:Dock(FILL)
	description.text:DockMargin(12, 0, 12, 10)
	description.text:SetWrap(true)
	description.text:SetTextColor(Color(235, 235, 240))
	description.text:SetText("Нажмите кнопку ? справа от настройки, чтобы открыть её подробное описание. Текст остаётся на экране, пока вы не выберете другую настройку.")

	local scroll = vgui.Create("DScrollPanel", frame)
	scroll:Dock(FILL)
	scroll:DockMargin(4, 4, 4, 4)
	scroll:SetPaintBackground(false)

	local sbar = scroll:GetVBar()
	sbar:SetHideButtons(true)

	addRow(scroll, description, "Рандомный кит: обвесы на все слоты", "zc_auto_silencer_random_all", "zc_toggle_all",
		"Рандомный кит: на все совместимые слоты оружия при выдаче ставятся случайные обвесы — глушитель, прицел, лазер, рукоятка и магазин.\n\nВ этом режиме отдельные настройки ниже не используются.")

	addRow(scroll, description, "Вешать глушитель при выдаче оружия", "zc_auto_silencer_enabled", "zc_toggle_silencer",
		"Автоматически вешать совместимый с оружием глушитель при выдаче (магазин, лут, классы).\n\nУже установленные глушители (например, с лута) не заменяются.")

	addRow(scroll, description, "Рандомный прицел при выдаче", "zc_auto_silencer_random_sight", "zc_toggle_sight",
		"При выдаче ставить случайный прицел, совместимый с оружием: коллиматоры, голограммы, оптические прицелы (EOTech, Kobra, ПСО-1, ACOG и другие).\n\nУже стоящие прицелы не заменяются.")

	addRow(scroll, description, "Рандомный лазер при выдаче", "zc_auto_silencer_random_laser", "zc_toggle_laser",
		"При выдаче ставить случайный лазер или фонарь, совместимый с планкой оружия (TBL Blue, Klesch, Baldr Pro, ANPEQ2, A-Laser).")

	addRow(scroll, description, "Уведомлять об установке", "zc_auto_silencer_notify", "zc_toggle_notify",
		"Показывать игроку сообщение в чате и звук при установке обвесов на выданное оружие.")
end

local function addCMenuButton(panel)
	local button = vgui.Create("DButton", panel)
	button:Dock(TOP)
	button:DockMargin(0, 0, 0, 6)
	button:SetTall(52)
	button:SetText("")

	button.Paint = function(self, w, h)
		local bg = self:IsHovered() and Color(58, 70, 96, 255) or Color(40, 48, 66, 255)
		draw.RoundedBox(6, 0, 0, w, h, bg)
		draw.RoundedBox(6, 1, 1, w - 2, h - 2, Color(20, 24, 34, 160))

		if openIcon and not openIcon:IsError() then
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(openIcon)
			surface.DrawTexturedRect(8, 8, 36, 36)
		end

		draw.SimpleText("Auto Silencer", "DermaDefaultBold", 52, 11, Color(245, 245, 250), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("Open silencer_open", "DermaDefault", 52, 26, Color(190, 200, 220), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end

	button.DoClick = function()
		RunConsoleCommand("silencer_open")
	end
end

--[[
hook.Add("PopulateToolMenu", "zc_auto_silencer_cmenu", function()
	spawnmenu.AddToolMenuOption("zc_auto_silencer", "settings", "zc_auto_silencer_open", "Auto Silencer", "", "", function(panel)
		panel:ClearControls()
		addCMenuButton(panel)
	end)
end)

hook.Add("AddToolMenuTabs", "zc_auto_silencer_tabs", function()
	spawnmenu.AddToolTab("zc_auto_silencer", "Auto Silencer", "entities/zc_auto_silencer")
	spawnmenu.AddToolCategory("zc_auto_silencer", "settings", "Settings")
end)
]]

concommand.Add("silencer_open", toggleMenu)
