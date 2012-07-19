--------------------------------------------------------
-- Blood Legion Raidcooldowns - Core --
--------------------------------------------------------
local BLRCD = BLRCD
local RI = LibStub("LibRaidInspect-1.0")
local CB = LibStub("LibCandyBar-3.0")
local AceConfig = LibStub("AceConfig-3.0") -- For the options panel
local AceConfigDialog = LibStub("AceConfigDialog-3.0") -- Also for options panel
local AceDB = LibStub("AceDB-3.0") -- Makes saving things relaly easy
local AceDBOptions = LibStub("AceDBOptions-3.0") -- More database options

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
	BLRCD:RegisterChatCommand("BLRCD", "SlashProcessor_BLRCD")
	
	-- DB
	BLRCD.db = AceDB:New("BLRCDDB", BLRCD.defaults, true)
	
	--self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	--self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
	--self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
	
	BLRCD.profileDB = BLRCD.db.profile
	BLRCD:SetupOptions()
	
	BLRCD.CreateBase()
	local index = 0
	for i, cooldown in pairs(BLRCD.cooldowns) do
		if (BLRCD.db.profile.cooldown[cooldown['name']]) then
			index = index + 1;
			BLRCD.curr[cooldown['spellID']] = {}
			BLRCD.cooldownRoster[cooldown['spellID']] = {}
			BLRCD.CreateCooldown(index, cooldown);
		end
   end
	BLRCD.active = index
	BLRCD:CheckVisibility()
	
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
	
	if(BLRCD.profileDB.castannounce) then
		local name = select(1, GetSpellInfo(cooldown['spellID']))
		if(RI:GroupType()==2) then
			SendChatMessage(caster.." Casts "..name.." "..cooldown['CD'].."CD" ,"RAID");
		else
			SendChatMessage(caster.." Casts "..name.." "..cooldown['CD'].."CD" ,"PARTY");
		end
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
	
	if(BLRCD.profileDB.cdannounce) then
		local name = select(1, GetSpellInfo(args[1]['spellID']))
		if(RI:GroupType()==2) then
			SendChatMessage(args[6].."'s "..name.." CD UP" ,"RAID");
		else
			SendChatMessage(args[6].."'s "..name.." CD UP" ,"PARTY");
		end
	end
		
	args[4]:SetText(BLRCD:GetTotalCooldown(args[1]))
end

function BLRCD:CheckSpecial(guid,spell)
--[[
	if LibRaidInspectMembers[guid]['class'] == 'Shaman' and spell == "Call of the Elements" then
		for spell,value in pairs(BLRCD['handles'][guid]) do
			if spell == "Mana Tide Totem" or spell == "Spirit Link Totem" or spell == "Healing Tide Totem" then
				BLRCD:StopCD(value[1])
				value[3]:Stop()
			end
		end
	end
	-- if (LibRaidInspectMembers[sourceGUID]['spec'] == "Restoration") and (spellName == "Tranquility") then
		-- return 300
	-- end
	-- return 0]]
end

function BLRCD:UpdateCooldown(frame,event,unit,cooldown,text,frameicon, ...)
	if(event == "COMBAT_LOG_EVENT_UNFILTERED") then
		local timestamp, type,_, sourceGUID, sourceName,_,_, destGUID, destName = select(1, ...)
		if(type == cooldown['succ']) then
			local spellId, spellName, spellSchool = select(12, ...)
			if(spellId == cooldown['spellID']) then
				if (LibRaidInspectMembers[sourceGUID]) then
					--0BLRCD:CheckSpecial(sourceGUID,spellName)
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
	BLRCD:BLPoint(raidcdbasemover,'TOPLEFT', UIParent, 'TOPLEFT', 0, 0)
	BLRCD:BLSize(raidcdbasemover,32*BLRCD.profileDB.scale,(32*#BLRCD.cooldowns)*BLRCD.profileDB.scale)
	if(Elv) then
		raidcdbasemover:SetTemplate()
	end
	raidcdbasemover:SetMovable(true)
	raidcdbasemover:SetFrameStrata("HIGH")
	raidcdbasemover:SetScript("OnDragStart", function(self) self:StartMoving() end)
	raidcdbasemover:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
	raidcdbasemover:Hide()
	
	local raidcdbase = CreateFrame("Frame", 'BLRaidCooldownBase_Frame', UIParent)
	BLRCD:BLSize(raidcdbase,32*BLRCD.profileDB.scale,(32*#BLRCD.cooldowns)*BLRCD.profileDB.scale)
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
	BLRCD:BLHeight(frame,28*BLRCD.profileDB.scale);
	BLRCD:BLWidth(frame,145*BLRCD.profileDB.scale);	
	frame:SetClampedToScreen(true);

	local frameicon = CreateFrame("Button", 'BLRaidCooldownIcon'..index, BLRaidCooldownBase_Frame);
	if(ElvUI) then
		frameicon:SetTemplate()
	end
	
	local classcolor = RAID_CLASS_COLORS[string.upper(cooldown.class):gsub(" ", "")]
	frameicon:SetBackdropBorderColor(classcolor.r,classcolor.g,classcolor.b)
	frameicon:SetParent(frame)
	frameicon.bars = {}
	BLRCD:BLSize(frameicon,30*BLRCD.profileDB.scale,30*BLRCD.profileDB.scale)
	frameicon:SetClampedToScreen(true);
	
	if(BLRCD.profileDB.growth == "left") then
	    if index == 1 then
			BLRCD:BLPoint(frame,'TOPRIGHT', 'BLRaidCooldownBase_Frame', 'TOPRIGHT', 2, -2);
		else
			BLRCD:BLPoint(frame,'TOPRIGHT', 'BLRaidCooldown'..(index-1), 'BOTTOMRIGHT', 0, -4);
		end
		BLRCD:BLPoint(frameicon,'TOPRIGHT', frame, 'TOPRIGHT');
	elseif(BLRCD.profileDB.growth  == "right") then
		if index == 1 then
			BLRCD:BLPoint(frame,'TOPLEFT', 'BLRaidCooldownBase_Frame', 'TOPLEFT', 2, -2);
		else
			BLRCD:BLPoint(frame,'TOPLEFT', 'BLRaidCooldown'..(index-1), 'BOTTOMLEFT', 0, -4);
		end
		BLRCD:BLPoint(frameicon,'TOPLEFT', frame, 'TOPLEFT');
	end
	
	frameicon.icon = frameicon:CreateTexture(nil, "OVERLAY");
	frameicon.icon:SetTexCoord(unpack(BLRCD.TexCoords));
	frameicon.icon:SetTexture(select(3, GetSpellInfo(cooldown['spellID'])));
	BLRCD:BLPoint(frameicon.icon,'TOPLEFT', 2, -2)
	BLRCD:BLPoint(frameicon.icon,'BOTTOMRIGHT', -2, 2)
	frameicon.text = frameicon:CreateFontString(nil, 'OVERLAY')
	BLRCD:BLFontTemplate(frameicon.text, 20*BLRCD.profileDB.scale, 'OUTLINE')
	BLRCD:BLPoint(frameicon.text, "CENTER",frameicon, "CENTER", 1, 0)
	BLRCD:UpdateRoster(cooldown)
	BLRCD:UpdateCooldown(self,event,unit,cooldown,frameicon.text,frameicon)
 	
	frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	frame:RegisterEvent("GROUP_ROSTER_UPDATE")
	
	RI.RegisterCallback (frame, "LibRaidInspect_Add", function(event, ...)
		BLRCD:UpdateRoster(cooldown)
		BLRCD:UpdateCooldown(frame,event,unit,cooldown,frameicon.text,frameicon, ...)
	end)
	
	RI.RegisterCallback (frame, "LibRaidInspect_Update", function(event, ...)
		BLRCD:UpdateRoster(cooldown)
		BLRCD:UpdateCooldown(frame,event,unit,cooldown,frameicon.text,frameicon, ...)
	end)
	
	RI.RegisterCallback (frame, "LibRaidInspect_Remove", function(event, ...)
		BLRCD:UpdateRoster(cooldown)
		BLRCD:UpdateCooldown(frame,event,unit,cooldown,frameicon.text,frameicon, ...)
	end)
	
	frameicon:SetScript("OnEnter", function(self,event, ...)
		BLRCD:OnEnter(self, cooldown, BLRCD.cooldownRoster[cooldown['spellID']], BLRCD.curr[cooldown['spellID']])
   end);
   
	frameicon:SetScript("PostClick", function(self,event, ...)
		BLRCD:PostClick(self, cooldown, BLRCD.cooldownRoster[cooldown['spellID']], BLRCD.curr[cooldown['spellID']])
	end);  
    
   frameicon:SetScript("OnLeave", function(self,event, ...)
		BLRCD:OnLeave(self)
   end);
	
	frame:SetScript("OnEvent", function(self,event, ...)
		BLRCD:UpdateCooldown(frame,event,unit,cooldown,frameicon.text,frameicon, ...)
   end);
		
	frame:Show()
end
--------------------------------------------------------