_G.XASVERSION = 0.86;
local add={
	gui={{
		name = "XAntiSpam",
		version = XASVERSION,
		window = "XAntiSpamGUI",
	}},
	popup={{
		GetText = function() return XAntiSpam_PopText(); end,
		GetTooltip = function()
			local info = "/xas, /xantispam\n\n";
			info = info..XASLang["XAddonTip1"].."\n";
			info = info..XASLang["XAddonTip2"];
			return info; end,
		OnClick = function(this, key) XAntiSpam_PopClick(this, key); end,
}}};
local def={
	["Spam"] = true,
	["Spamlist"] = {
		"Cheap&Fast ROM gold",
		"WWW.ROMGold.COM",
		"RomOlGold.com",
		"GOLD4MMORPG",
		"www.goldvk.com",
		"www MYOOG com",
		"www . l e v e l n . de",
		"www.rmt4game.com",
		"www. leveln .de",
	},
};
XAntiSpamSet = {};

local sysStr = {
	--%s
	TEXT("QUEST_MSG_GET"),
	TEXT("QUEST_MSG_FINISHED"),
	TEXT("QUEST_MSG_CONDITION_FINISHED"),
	TEXT("SYS_AC_CREATE_ITEM_SUCCESS"),
	TEXT("QUEST_MSG_DAILYGROUP_DONE"),
	--%s, %d
	TEXT("QUEST_MSG_DAILYGROUP_COMPLETE"),
	--%d
	TEXT("SYS_INCREASE_EXP"),
	TEXT("SYS_INCREASE_TP"),
	--none
	TEXT("GATHER_MSG_FAILED"),
	TEXT("SYS_AC_OPEN"),
	TEXT("SYS_AC_CLOSE"),
	TEXT("SYS_APARTITEM_SUCCESS"),
	TEXT("SYS_ERR_CHAT_NOPARTY"),
	TEXT("SYS_EXCHANGE_CLASS_SUCCESS"),
	TEXT("SYS_DISSOLUTION_SUCCESS"),
	TEXT("MSG_ANTQUEEN_NEST_OPEN"),
	TEXT("SYS_PARTY_LEAVE"),
};

SlashCmdList["XANTISPAM"] = function(editbox, msg)
	if XBARVERSION and XBARVERSION>=1.51 then
		XAddon_ShowPage("XAntiSpamGUI");
	else
		ToggleUIFrame(XAntiSpamGUI);
	end
end
SLASH_XANTISPAM1 = "/xas";
SLASH_XANTISPAM2 = "/xantispam";

function XAntiSpam_PopClick(this, key)
	if key=="LBUTTON" then
		XAddon_ShowPage("XAntiSpamGUI");
	elseif key=="RBUTTON" then
		if XAntiSpamSet["Spam"]==true then
			XAntiSpamSet["Spam"] = false;
		else
			XAntiSpamSet["Spam"] = true;
		end
		XAntiSpamGUI_Enable:SetChecked(XAntiSpamSet["Spam"]);
	end
end

function XAntiSpam_PopText()
	if XAntiSpamSet["Spam"]==true then
		return "XAntiSpam - "..ON;
	else
		return "XAntiSpam - "..C_OFF;
	end
end

function XAntiSpam_OnLoad(this)
	for k, v in pairs(def) do
		if XAntiSpamSet[k]==nil then
			XAntiSpamSet[k] = v;
		end
	end
	SaveVariables("XAntiSpamSet");
	this:RegisterEvent("VARIABLES_LOADED");
	local lang = GetLanguage():upper();
	local _, err = loadfile("Interface/Addons/XAntiSpam/Locales/"..lang..".lua");
	if err then
		dofile("Interface/Addons/XAntiSpam/Locales/ENUS.lua");
		XAntiSpam_Print("|cff993333XAntiSpam can't find translation, ENUS.lua loaded.|r");
	else
		dofile("Interface/Addons/XAntiSpam/Locales/"..lang..".lua");
	end
	XAntiSpam_OrigChat = ChatFrame_OnEvent;
	ChatFrame_OnEvent = XAntiSpam_ChatEvent;
	sysStr[6] = string.gsub(sysStr[6], "%%d", "0");
	for i = 1, 6 do
		sysStr[i] = string.format(sysStr[i], "(.*)", "(.*)");
	end
	sysStr[6] = string.gsub(sysStr[6], "0", "%%d");
	for i, v in ipairs(sysStr) do
		v = string.gsub(v, "'", "");
		v = string.gsub(v, "+", "");
	end
end

function XAntiSpam_OnEvent(event)
	if event=="VARIABLES_LOADED" then
		if XBARVERSION and XBARVERSION>=1.51 then
			XAddon_Register(add);
		end
		XAntiSpam_Print("|cff60AE5FXAntiSpam %s|r %s |cff60AE5F/xas|r %s", XASVERSION, XASLang["Load"], XASLang["ToConfig"]);
	end
end

function XAntiSpam_ChatEvent(this, event)
	if XAntiSpamSet["Spamlist"] then
		if XAntiSpamSet["Spam"]==true and type(arg1)=="string" then
			local msg = string.gsub(arg1, "'", "");
			local msg = string.gsub(msg, "-", "");
			local msg = string.gsub(msg, "%^", "");
			for i, v in ipairs(XAntiSpamSet.Spamlist) do
				if string.find(msg:lower(), v:lower()) then
					return;
				end
			end
		end
	end
	XAntiSpam_OrigChat(this, event);
end

function XAntiSpam_OnShow(this)
	XAntiSpamGUI_Enable:SetChecked(XAntiSpamSet["Spam"]);
	XAntiSpamGUI_Version:SetText("XAntiSpam "..XASVERSION);
	XAntiSpamGUI_Edit_Text:SetText(XASLang["SpamCheck"]);
	if XBARVERSION and XBARVERSION>=1.51 then
		XAddon_Page(this);
	end
end

function XAntiSpam_Close(this)
	if XBARVERSION and XBARVERSION>=1.51 then
		XAddonMngr:Hide();
	end
	this:GetParent():Hide();
end

function XAntiSpamLegend_OnShow(this, frame)
	if frame then
		XAntiSpamLegend.frame = frame;
	end
	for i = 1, 6 do
		getglobal("XAntiSpamLegend_Button"..i):Hide();
	end
	if XAntiSpamLegend.frame=="SPAM" then
		for i = 1, 6 do
			if XAntiSpamSet["Spamlist"][XAntiSpamLegend.start+i-1] then
				getglobal("XAntiSpamLegend_Button"..i.."Text"):SetText("["..XAntiSpamSet["Spamlist"][XAntiSpamLegend.start+i-1].."]");
				getglobal("XAntiSpamLegend_Button"..i):SetID(i);
				getglobal("XAntiSpamLegend_Button"..i):Show();
			end
		end
	end
	XAntiSpamLegend:Show();
	XAntiSpamLegend_Head:SetText(XASLang["SpamHead"]);
end

function XAntiSpamLegend_OnWheel(this, delta)
	local start = XAntiSpamLegend.start;
	if delta>0 then
		if start>1 then
			start = start - 1;
		end
	end
	if delta<0 then
		if start<#XAntiSpamSet["Spamlist"]-5 then
			start = start + 1;
		end
	end
	XAntiSpamLegend.start = start;
	XAntiSpamLegend_OnShow(this);
end

function XAntiSpamLegend_OnClick(this, key)
	local ID = this:GetID();
	for i = 1, 6 do
		getglobal("XAntiSpamLegend_Button"..i.."Mark"):Hide();
	end
	getglobal(this:GetName().."Mark"):Show();
	XAntiSpamGUI_Edit:SetText(XAntiSpamSet["Spamlist"][XAntiSpamLegend.start+ID-1]);
	XAntiSpamGUI_Del:Show();
	XAntiSpamLegend_OnShow();
	if key=="RBUTTON" then
		XAntiSpam_SpamDel();
	end
end

function XAntiSpamSys_OnShow(this, frame)
	if frame then
		XAntiSpamSys.frame = frame;
	end
	for i = 1, 6 do
		getglobal("XAntiSpamSys_Button"..i):Hide();
	end
	if XAntiSpamSys.frame=="SYS" then
		for i = 1, 6 do
			if sysStr[XAntiSpamSys.start+i-1] then
				getglobal("XAntiSpamSys_Button"..i.."Text"):SetText("["..sysStr[XAntiSpamSys.start+i-1].."]");
				getglobal("XAntiSpamSys_Button"..i):SetID(i);
				getglobal("XAntiSpamSys_Button"..i):Show();
			end
		end
	end
	XAntiSpamSys:Show();
	XAntiSpamSys_Head:SetText(XASLang["SysHead"]);
end

function XAntiSpamSys_OnWheel(this, delta)
	local start = XAntiSpamSys.start;
	if delta>0 then
		if start>1 then
			start = start - 1;
		end
	end
	if delta<0 then
		if start<#sysStr-5 then
			start = start + 1;
		end
	end
	XAntiSpamSys.start = start;
	XAntiSpamSys_OnShow(this);
end

function XAntiSpamSys_OnClick(this, key)
	local ID = this:GetID();
	for i = 1, 6 do
		getglobal("XAntiSpamSys_Button"..i.."Mark"):Hide();
	end
	getglobal(this:GetName().."Mark"):Show();
	XAntiSpamGUI_Edit:SetText(sysStr[XAntiSpamSys.start+ID-1]);
	XAntiSpamLegend_OnShow();
	XAntiSpamSys_OnShow();
	if key=="RBUTTON" then
		XAntiSpam_SpamAdd();
	end
end

function XAntiSpam_SpamAdd()
	local str = XAntiSpamGUI_Edit:GetText()
	local exist = 0;
	for i = 1, #XAntiSpamSet["Spamlist"] do
		if str==XAntiSpamSet["Spamlist"][i] then
			exist = 1;
		end
	end
	if exist==0 and str~="" then
		table.insert(XAntiSpamSet["Spamlist"], 1, str);
	end
	XAntiSpamGUI_Edit:SetText("");
	XAntiSpamGUI_Del:Hide();
	for i = 1, 6 do
		getglobal("XAntiSpamLegend_Button"..i.."Mark"):Hide();
	end
	XAntiSpamLegend_OnShow();
end

function XAntiSpam_SpamDel()
	for i, v in ipairs(XAntiSpamSet["Spamlist"]) do
		if v==XAntiSpamGUI_Edit:GetText() then
			table.remove(XAntiSpamSet["Spamlist"], i);
		end
	end
	XAntiSpamGUI_Edit:SetText("");
	XAntiSpamGUI_Del:Hide();
	for i = 1, 6 do
		getglobal("XAntiSpamLegend_Button"..i.."Mark"):Hide();
	end
	XAntiSpamLegend_OnShow();
end

function XAntiSpam_Print(str, ...)
	DEFAULT_CHAT_FRAME:AddMessage(str:format(...), 1, 1, 1);
end