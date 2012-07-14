--------------------------------------------------------
-- Blood Legion Raidcooldowns - Core --
--------------------------------------------------------
local BLRCD = BLRCD
local RI = LibStub("LibRaidInspect-1.0")
local CB = LibStub("LibCandyBar-3.0")
local Elv = IsAddOnLoaded("ElvUI")

if(Elv) then
	E, L, V, P, G =  unpack(ElvUI);
end

BLRCD.curr = {}
BLRCD.cooldownRoster = {}
BLRCD.tmp = {}
BLRCD.handles = {}

--------------------------------------------------------
-- Initialization --
--------------------------------------------------------
local count = 0
function BLRCD:OnInitialize()
	if count == 1 then return end
	BLRCD.CreateBase()
	BLRCD:RegisterChatCommand("BLRCD", "SlashProcessor_BLRCD")
	
	-- DB
	self.db = LibStub("AceDB-3.0"):New("BLRCDDB", self.defaults, "Default")
	BLRCDDB = BLRCDDB or {}
	LibStub("AceConfig-3.0"):RegisterOptionsTable("BLRCD", self.options)
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("BLRCD", "BL Raid Cooldowns")

	-- Profiles
	LibStub("AceConfig-3.0"):RegisterOptionsTable("BLRCD-Profiles", LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db))
	self.profilesFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("BLRCD-Profiles", "Profiles", "BLRCD")
	
	local index = 0
	for i, cooldown in pairs(BLRCD.cooldowns) do
	   index = index + 1;
   	BLRCD.curr[cooldown['spellID']] = {}
		BLRCD.cooldownRoster[cooldown['spellID']] = {}
   	BLRCD.CreateCooldown(index, cooldown);
   end    
   count = 1
end

function BLRCD:OnEnable()

end

function BLRCD:OnDisable()

end
-------------------------------------------------------

-------------------------------------------------------
-- Addon Functions --
-------------------------------------------------------
function BLRCD:SlashProcessor_BLRCD(input)
	local v1, v2 = input:match("^(%S*)%s*(.-)$")
	v1 = v1:lower()

	if v1 == "" then
		print("|cffc41f3bBL Raid Cooldowns|r: /blrcd lock - Lock and Unlock Frame")
		print("|cffc41f3bBL Raid Cooldowns|r: /blrcd debug - Raid talents")
		print("|cffc41f3bBL Raid Cooldowns|r: /blrcd show - Hide/Show Main Frame")
		print("|cffc41f3bBL Raid Cooldowns|r: /blrcd raid - Print Raid Roster and talents")		
	elseif v1 == "lock" or v1 == "unlock" or v1 == "drag" or v1 == "move" or v1 == "l" then
		BLRCD:ToggleMoversLock()	
	elseif v1 == "raid" then
		BLRCD:returnRaidRoster()
	elseif v1 == "debug" then
		BLRCD:print_r(LibRaidInspectMembers)
	elseif v1 == "debug2" then
		BLRCD:print_r(BLRCD.cooldownRoster)
	elseif v1 == "show" then
		BLRCD:ToggleVisibility()	
	elseif v1 == "reset" then
		RI:Reset()	
	end
end

function BLRCD:StartCD(frame,cooldown,text,guid,caster,frameicon, spell)
	if not (BLRCD.curr[cooldown['spellID']][guid]) then
	    BLRCD.curr[cooldown['spellID']][guid]=guid
   end
	 
	local bar = BLRCD:CreateBar(frame,cooldown,caster,frameicon,guid)
	
	local args = {cooldown,guid,frame,text,bar,caster,spell}
	local handle = BLRCD:ScheduleTimer("StopCD", cooldown['CD'],args)
	BLRCD['handles'][guid] = BLRCD['handles'][guid] or {}
	BLRCD['handles'][guid][spell] = {args,handle,bar}
end


function BLRCD:StopCD(args)
	BLRCD.curr[args[1]['spellID']][args[2]] = nil;
	
	local a = args[5]:Get("raidcooldowns:anchor")
	if a and a.bars and a.bars[args[5]] then
      a.bars[args[5]] = nil
		BLRCD:RearrangeBars(a) 
	end
	
	args[4]:SetText(BLRCD:GetTotalCooldown(args[1]))
end

function BLRCD:CheckSpecial(guid,spell)
	-- if (LibRaidInspectMembers[sourceGUID]['spec'] == "Restoration") and (spellName == "Tranquility") then
		-- return 300
	-- end
	-- return 0
end

function BLRCD:UpdateCooldown(frame,event,unit,cooldown,text,frameicon, ...)
	if(event == "COMBAT_LOG_EVENT_UNFILTERED") then
		local timestamp, type,_, sourceGUID, sourceName,_,_, destGUID, destName = select(1, ...)
		if(type == cooldown['succ']) then
			local spellId, spellName, spellSchool = select(12, ...)
			if(spellId == cooldown['spellID']) then
				if (LibRaidInspectMembers[sourceGUID]) then
					--BLRCD:CheckSpecial(sourceGUID,spellName)
					BLRCD:StartCD(frame,cooldown,text,sourceGUID,sourceName,frameicon, spellName)
					text:SetText(BLRCD:GetTotalCooldown(cooldown))
	         end
			end
		 end
	elseif(event =="GROUP_ROSTER_UPDATE") then
		if not(RI:GroupType() == 2 or RI:GroupType() == 1) then
			BLRCD:UpdateRoster(cooldown)
	      BLRCD:CancelBars(frameicon)
		end
		text:SetText(BLRCD:GetTotalCooldown(cooldown))
	elseif(event =="LibRaidInspect_Remove") then
		local guid, name = select(1, ...)
		BLRCD:RemovePlayer(guid)
	else
		text:SetText(BLRCD:GetTotalCooldown(cooldown))
	end
end

function BLRCD:GetTotalCooldown(cooldown)
	local cd = 0
	local cdTotal = 0
	for i,v in pairs(BLRCD.cooldownRoster[cooldown['spellID']]) do
		cdTotal=cdTotal+1
	end
	
	for i,v in pairs(BLRCD.curr[cooldown['spellID']]) do
		cd=cd+1
	end
	
	return (cdTotal-cd)
end
-------------------------------------------------------

-------------------------------------------------------
-- Frame Management --
-------------------------------------------------------
BLRCD.CreateBase = function()
	local raidcdbasemover = CreateFrame("Frame", 'BLRaidCooldownBaseMover_Frame', UIParent)
	raidcdbasemover:SetClampedToScreen(true)
	BLRCD:BLPoint(raidcdbasemover,'TOPLEFT', UIParent, 'TOPLEFT', 100, 100)
	BLRCD:BLSize(raidcdbasemover,32,(32*#BLRCD.cooldowns))
	if(Elv) then
		raidcdbasemover:SetTemplate()
	end
	raidcdbasemover:SetMovable(true)
	raidcdbasemover:SetFrameStrata("HIGH")
	raidcdbasemover:SetScript("OnDragStart", function(self) self:StartMoving() end)
	raidcdbasemover:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
	raidcdbasemover:Hide()
	
	local raidcdbase = CreateFrame("Frame", 'BLRaidCooldownBase_Frame', UIParent)
	BLRCD:BLSize(raidcdbase,32,(32*#BLRCD.cooldowns))
	BLRCD:BLPoint(raidcdbase,'TOPLEFT', raidcdbasemover, 'TOPLEFT')
	raidcdbase:SetClampedToScreen(true)
	
	BLRCD.locked = true
	if (RI:GroupType()==2 or RI:GroupType()==1) then
		raidcdbase:Show()
		BLRCD.show = true
	end
end

BLRCD.CreateCooldown = function (index, cooldown)
	local frame = CreateFrame("Frame", 'BLRaidCooldown'..index, BLRaidCooldownBase_Frame);
	BLRCD:BLHeight(frame,28);
	BLRCD:BLWidth(frame,145);	
	frame:SetClampedToScreen(true);

	local frameicon = CreateFrame("Frame", 'BLRaidCooldownIcon'..index, BLRaidCooldownBase_Frame);
	if(ElvUI) then
		frameicon:SetTemplate()
	end
	
	local classcolor = RAID_CLASS_COLORS[string.upper(cooldown.class):gsub(" ", "")]
	frameicon:SetBackdropBorderColor(classcolor.r,classcolor.g,classcolor.b)
	frameicon:SetParent(frame)
	frameicon.bars = {}
	BLRCD:BLSize(frameicon,30,30)
	frameicon:SetClampedToScreen(true);
	
	if index == 1 then
		BLRCD:BLPoint(frame,'TOPLEFT', 'BLRaidCooldownBase_Frame', 'TOPLEFT', 2, -2);
	else
		BLRCD:BLPoint(frame,'TOPLEFT', 'BLRaidCooldown'..(index-1), 'BOTTOMLEFT', 0, -4);
	end
	BLRCD:BLPoint(frameicon,'TOPLEFT', frame, 'TOPLEFT');
	
	frameicon.icon = frameicon:CreateTexture(nil, "OVERLAY");
	frameicon.icon:SetTexCoord(unpack(BLRCD.TexCoords));
	frameicon.icon:SetTexture(select(3, GetSpellInfo(cooldown['spellID'])));
	BLRCD:BLPoint(frameicon.icon,'TOPLEFT', 2, -2)
	BLRCD:BLPoint(frameicon.icon,'BOTTOMRIGHT', -2, 2)
	local text = frameicon:CreateFontString(nil, 'OVERLAY')
	BLRCD:BLFontTemplate(text, 20, 'OUTLINE')
	BLRCD:BLPoint(text, "CENTER",frameicon, "CENTER", 1, 0)
	BLRCD:UpdateRoster(cooldown)
	BLRCD:UpdateCooldown(self,event,unit,cooldown,text,frameicon)
 	
	frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	frame:RegisterEvent("GROUP_ROSTER_UPDATE")
	
	RI.RegisterCallback (frame, "LibRaidInspect_Add", function(event, ...)
		BLRCD:UpdateRoster(cooldown)
		BLRCD:UpdateCooldown(frame,event,unit,cooldown,text,frameicon, ...)
	end)
	
	RI.RegisterCallback (frame, "LibRaidInspect_Update", function(event, ...)
		BLRCD:UpdateRoster(cooldown)
		BLRCD:UpdateCooldown(frame,event,unit,cooldown,text,frameicon, ...)
	end)
	
	RI.RegisterCallback (frame, "LibRaidInspect_Remove", function(event, ...)
		BLRCD:UpdateRoster(cooldown)
		BLRCD:UpdateCooldown(frame,event,unit,cooldown,text,frameicon, ...)
	end)
	
	frameicon:SetScript("OnEnter", function(self,event, ...)
		BLRCD:OnEnter(self, cooldown, BLRCD.cooldownRoster[cooldown['spellID']], BLRCD.curr[cooldown['spellID']])
   end);
    
   frameicon:SetScript("OnLeave", function(self,event, ...)
		BLRCD:OnLeave(self)
   end);
	
	frame:SetScript("OnEvent", function(self,event, ...)
		BLRCD:UpdateCooldown(frame,event,unit,cooldown,text,frameicon, ...)
   end);
		
	frame:Show()
end
--------------------------------------------------------