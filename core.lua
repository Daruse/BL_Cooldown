--------------------------------------------------------
-- Blood Legion Raidcooldowns - Core --
--------------------------------------------------------
if not BLCD then return end
local BLCD = BLCD
local CB = LibStub("LibCandyBar-3.0")
local LGIST=LibStub:GetLibrary("LibGroupInSpecT-1.0")
local AceConfig = LibStub("AceConfig-3.0") -- For the options panel
local AceConfigDialog = LibStub("AceConfigDialog-3.0") -- Also for options panel
local AceDB = LibStub("AceDB-3.0") -- Makes saving things relaly easy
local AceDBOptions = LibStub("AceDBOptions-3.0") -- More database options

local Elv = IsAddOnLoaded("ElvUI")

if(Elv) then
	E, L, V, P, G =  unpack(ElvUI);
end
--------------------------------------------------------
-- Raid Roster Functions --
--------------------------------------------------------
function BLCD:OnUpdate(event, info)
    local baseclass = info.class							  	
    local name = info.name
    local spec_id = info.global_spec_id
    local talents = info.talents
    local guid = info.guid
	if not baseclass or not guid or not spec_id or not talents or not guid then return end	
	local  _,classFilename = GetPlayerInfoByGUID(guid)
	local raid_id
	
	if(string.len(info.lku)==5) then
		raid_id = tonumber(string.sub(info.lku,-1))
	elseif(string.len(info.lku)==6) then
		raid_id = tonumber(string.sub(info.lku,-2))
	end

	if(raid_id) then
		if(raid_id < 26) then
			BLCD['raidRoster'][guid] = BLCD['raidRoster'][guid] or {}
			BLCD['raidRoster'][guid]['name'] = name
			BLCD['raidRoster'][guid]['class']= classFilename
			BLCD['raidRoster'][guid]['spec'] = spec_id
			BLCD['raidRoster'][guid]['talents'] = talents
			BLCD['raidRoster'][guid]['lku'] = info.lku
		end
	end
end

function BLCD:OnRemove(guid)
	if(guid) then
	    local  _,classFilename = GetPlayerInfoByGUID(guid)
	    BLCD['raidRoster'][guid] = nil
	else
		BLCD['raidRoster'] = {}
	end
end

function BLCD:UpdateRoster(cooldown)
	if(BLCD:GetPartyType() == "party" or BLCD:GetPartyType() == "raid") then

		for i, name in pairs(BLCD.cooldownRoster[cooldown['spellID']]) do
			if not(UnitInRaid(i) or UnitInParty(i)) then
				BLCD.cooldownRoster[cooldown['spellID']][i] = nil
			end
		end

		for i, char in pairs(BLCD['raidRoster']) do
			if(UnitInRaid(char['name']) or UnitInParty(char['name'])) then 
				if(string.lower(char["class"]:gsub(" ", ""))==string.lower(cooldown["class"]):gsub(" ", "")) then 
					if(cooldown["spec"] and char["spec"]) then
						if(char["spec"]==cooldown["spec"]) then 
							BLCD.cooldownRoster[cooldown['spellID']][i] = char['name']
						end
					elseif(cooldown["talent"] and char["talents"]) then
						if(char["talents"][cooldown["spellID"]]) then 
							BLCD.cooldownRoster[cooldown['spellID']][i] = char['name']
						end
					else
						BLCD.cooldownRoster[cooldown['spellID']][i] = char['name']
					end
				end
			else
				if(BLCD.cooldownRoster[cooldown['spellID']][i]) then
					BLCD.cooldownRoster[cooldown['spellID']][i] = nil
				end
			end
		end
	else
		BLCD.cooldownRoster[cooldown['spellID']] = {}
		BLCD.curr[cooldown['spellID']] = {}
	end
end
--------------------------------------------------------

-------------------------------------------------------
-- Frame Management --
-------------------------------------------------------
function BLCD:CreateBase()
	local raidcdbasemover = CreateFrame("Frame", 'BLCooldownBaseMover_Frame', UIParent)
	raidcdbasemover:SetClampedToScreen(true)
	BLCD:BLPoint(raidcdbasemover,'TOPLEFT', UIParent, 'TOPLEFT', 0, 0)
	BLCD:BLSize(raidcdbasemover,32*BLCD.profileDB.scale,(32*#BLCD.cooldowns)*BLCD.profileDB.scale)
	if(Elv) then
		raidcdbasemover:SetTemplate()
	end
	raidcdbasemover:SetMovable(true)
	raidcdbasemover:SetFrameStrata("HIGH")
	raidcdbasemover:SetScript("OnDragStart", function(self) self:StartMoving() end)
	raidcdbasemover:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
	raidcdbasemover:Hide()
	
	local raidcdbase = CreateFrame("Frame", 'BLCooldownBase_Frame', UIParent)
	BLCD:BLSize(raidcdbase,32*BLCD.profileDB.scale,(32*#BLCD.cooldowns)*BLCD.profileDB.scale)
	BLCD:BLPoint(raidcdbase,'TOPLEFT', raidcdbasemover, 'TOPLEFT')
	raidcdbase:SetClampedToScreen(true)
	
	BLCD.locked = true
	BLCD:CheckVisibility()
end

function BLCD:CreateCooldown(index, cooldown)
	local frame = CreateFrame("Frame", 'BLCooldown'..index, BLCooldownBase_Frame);
	BLCD:BLHeight(frame,28*BLCD.profileDB.scale);
	BLCD:BLWidth(frame,145*BLCD.profileDB.scale);	
	frame:SetClampedToScreen(true);
	frame.index = index

	local frameicon = CreateFrame("Button", 'BLCooldownIcon'..index, BLCooldownBase_Frame);
	
	if(ElvUI) then
		frameicon:SetTemplate()
	end
	
	local classcolor = RAID_CLASS_COLORS[string.upper(cooldown.class):gsub(" ", "")]
	frameicon:SetBackdropBorderColor(classcolor.r,classcolor.g,classcolor.b)
	frameicon:SetParent(frame)
	frameicon.bars = {}
	BLCD:BLSize(frameicon,30*BLCD.profileDB.scale,30*BLCD.profileDB.scale)
	frameicon:SetClampedToScreen(true);

	BLCD:SetBarGrowthDirection(frame, frameicon, index)
	
	frameicon.icon = frameicon:CreateTexture(nil, "OVERLAY");
	frameicon.icon:SetTexCoord(unpack(BLCD.TexCoords));
	frameicon.icon:SetTexture(select(3, GetSpellInfo(cooldown['spellID'])));
	BLCD:BLPoint(frameicon.icon,'TOPLEFT', 2, -2)
	BLCD:BLPoint(frameicon.icon,'BOTTOMRIGHT', -2, 2)

	frameicon.text = frameicon:CreateFontString(nil, 'OVERLAY')
	BLCD:BLFontTemplate(frameicon.text, 20*BLCD.profileDB.scale, 'OUTLINE')
	BLCD:BLPoint(frameicon.text, "CENTER",frameicon, "CENTER", 1, 0)
	
	BLCD:UpdateCooldown(frame,event,unit,cooldown,frameicon.text,frameicon)
 	
	frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	frame:RegisterEvent("PLAYER_ENTERING_WORLD");
	frame:RegisterEvent("GROUP_ROSTER_UPDATE")

	LGIST.RegisterCallback (frame, "GroupInSpecT_Update", function(event, ...)
		BLCD:UpdateRoster(cooldown)
		BLCD:UpdateCooldown(frame,event,unit,cooldown,frameicon.text,frameicon, ...)
	end)

	LGIST.RegisterCallback (frame, "GroupInSpecT_Remove", function(event, ...)
		BLCD:UpdateRoster(cooldown)
		BLCD:UpdateCooldown(frame,event,unit,cooldown,frameicon.text,frameicon, ...)
	end)
	
	frameicon:SetScript("OnEnter", function(self,event, ...)
		BLCD:OnEnter(self, cooldown, BLCD.cooldownRoster[cooldown['spellID']], BLCD.curr[cooldown['spellID']])
   	end);
   
	frameicon:SetScript("PostClick", function(self,event, ...)
		BLCD:PostClick(self, cooldown, BLCD.cooldownRoster[cooldown['spellID']], BLCD.curr[cooldown['spellID']])
	end);  
    
 	frameicon:SetScript("OnLeave", function(self,event, ...)
		BLCD:OnLeave(self)
   	end);
	
	frame:SetScript("OnEvent", function(self,event, ...)
		BLCD:UpdateCooldown(frame,event,unit,cooldown,frameicon.text,frameicon, ...)
 	end);
		
	frame:Show()
end
--------------------------------------------------------

--------------------------------------------------------
-- Cooldown Management --
--------------------------------------------------------
function BLCD:UpdateCooldown(frame,event,unit,cooldown,text,frameicon, ...)
	if(event == "COMBAT_LOG_EVENT_UNFILTERED") then
		local timestamp, type , _, soureGUID, soureName, _, _, destGUID, destName, _, _, spellId, spellName = select(1, ...)
		if(type ==cooldown['succ'] and spellId == cooldown['spellID']) then
			if(BLCD['raidRoster'][soureGUID]) then
				local duration = BLCD:getCooldownCD(cooldown,soureGUID)
				BLCD:StartCD(frame,cooldown,text,soureGUID,soureName,frameicon, spellName,duration)
	            text:SetText(BLCD:GetTotalCooldown(cooldown))
			end
		end
	elseif(event =="GROUP_ROSTER_UPDATE") then
	    local partyType = BLCD:GetPartyType()
	    if(partyType=="none") then
	        BLCD.curr[cooldown['spellID']]={}
	        BLCD.cooldownRoster[cooldown['spellID']] = {}
	        BLCD:CancelBars(frameicon)
	        BLCD:CheckVisibility()
	    end
	    text:SetText(BLCD:GetTotalCooldown(cooldown))
    elseif(event =="GroupInSpecT_Update") then
	    text:SetText(BLCD:GetTotalCooldown(cooldown))
    end
end

function BLCD:StartCD(frame,cooldown,text,guid,caster,frameicon,spell,duration)
	if not(BLCD.curr[cooldown['spellID']][guid]) then
	    BLCD.curr[cooldown['spellID']][guid]=guid
    end

	if(BLCD.profileDB.castannounce) then
		local name = select(1, GetSpellInfo(cooldown['spellID']))
		print(caster,name,duration)
		if(BLCD:GetPartyType()=="raid") then
			SendChatMessage(caster.." Casts "..name.." "..BLCD:sec2Min(duration).."CD" ,"RAID");
		elseif(BLCD:GetPartyType()=="party") then
			SendChatMessage(caster.." Casts "..name.." "..BLCD:sec2Min(duration).."CD" ,"PARTY");
		else
			SendChatMessage(caster.." Casts "..name.." "..BLCD:sec2Min(duration).."CD" ,"SAY");
		end
	end

	local bar = BLCD:CreateBar(frame,cooldown,caster,frameicon,guid,duration)
	
	local args = {cooldown,guid,frame,text,bar,caster,spell,duration}
	local handle = BLCD:ScheduleTimer("StopCD",duration,args)
	BLCD['handles'][guid] = BLCD['handles'][guid] or {}
	BLCD['handles'][guid][spell] = {args,handle,bar}
end

function BLCD:StopCD(args)
	BLCD.curr[args[1]['spellID']][args[2]] = nil;
	
	local a = args[5]:Get("raidcooldowns:anchor")
	if a and a.bars and a.bars[args[5]] then
        a.bars[args[5]] = nil
        BLCD:RearrangeBars(a) 
	end
	
	if(BLCD.profileDB.cdannounce) then
		local name = select(1, GetSpellInfo(args[1]['spellID']))
		if(BLCD:GetPartyType()=="raid") then
			SendChatMessage(args[6].."'s "..name.." CD UP" ,"RAID");
		elseif(BLCD:GetPartyType()=="party") then
			SendChatMessage(args[6].."'s "..name.." CD UP" ,"PARTY");
		else
			SendChatMessage(args[6].."'s "..name.." CD UP" ,"PARTY");
		end
	end
	
	args[4]:SetText(BLCD:GetTotalCooldown(args[1]))
end

function BLCD:getCooldownCD(cooldown,soureGUID)
	local cd = cooldown['CD']
	if(BLCD.cooldownReduction[cooldown['name']]) then
		if(BLCD['raidRoster'][soureGUID]['spec'] == BLCD.cooldownReduction[cooldown['name']]['spec']) then
			cd = BLCD.cooldownReduction[cooldown['name']]['CD']
		end
	end
	
	return cd
end

function BLCD:GetTotalCooldown(cooldown)
	local cd = 0
	local cdTotal = 0
	
	for i,v in pairs(BLCD.cooldownRoster[cooldown['spellID']]) do
		cdTotal=cdTotal+1
	end
	
	for i,v in pairs(BLCD.curr[cooldown['spellID']]) do
		cd=cd+1
	end

	local total = (cdTotal-cd)
	if(total < 0) then
		total = 0
	end
		
	return total
end
--------------------------------------------------------

--------------------------------------------------------
-- Initialization --
--------------------------------------------------------
function BLCD:CreateRaidTables()
	BLCD.cooldownRoster = {}
	BLCD.raidRoster = {}
    BLCD.curr = {}
    BLCD.tmp = {}
	BLCD.handles = {}
	BLCD.frame_cache = {}
end

function BLCD:SlashProcessor_BLCD(input)
	local v1, v2 = input:match("^(%S*)%s*(.-)$")
	v1 = v1:lower()

	if v1 == "" then
		print("|cffc41f3bBlood Legion Cooldown|r:")
		print("/blcd lock - Lock/Unlock Cooldown Frame")
		print("/blcd show - Hide/Show Cooldown Frame")
		print("/blcd config - Open Config Options")
		print("---------------------------------------------")
	elseif v1 == "lock" or v1 == "unlock" or v1 == "drag" or v1 == "move" or v1 == "l" then
		BLCD:ToggleMoversLock()
	elseif v1 == "show" then
		BLCD:ToggleVisibility()
	elseif v1 == "raid" then
		BLCD:print_raid()

		local raidsize = 0

		for i, char in pairs(BLCD['raidRoster']) do
			raidsize = raidsize + 1
		end
		print(raidsize)
	elseif v1 == "config" then
		AceConfigDialog:Open("BLCD")
	end
end

local count = 0
function BLCD:OnInitialize()
	if count == 1 then return end
	BLCD:RegisterChatCommand("BLCD", "SlashProcessor_BLCD")
	
	-- DB
	BLCD.db = AceDB:New("BLCDDB", BLCD.defaults, true)
	
	--self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	--self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
	--self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
	
	BLCD.profileDB = BLCD.db.profile
	BLCD:SetupOptions()
	
	LGIST.RegisterCallback (BLCD, "GroupInSpecT_Update", function(event, ...)
		BLCD.OnUpdate(...)
	end)

	LGIST.RegisterCallback (BLCD, "GroupInSpecT_Remove", function(...)
		BLCD.OnRemove(...)
	end)

	BLCD:CreateRaidTables()
	BLCD:CreateBase()

	local index = 0
	for i, cooldown in pairs(BLCD.cooldowns) do
		if (BLCD.db.profile.cooldown[cooldown.name] == true) then
			index = index + 1;
			BLCD.curr[cooldown['spellID']] = {}
			BLCD.cooldownRoster[cooldown['spellID']] = {}
			BLCD:CreateCooldown(index, cooldown);
		end
    end
	BLCD.active = index
	BLCD:CheckVisibility()

	count = 1
end

function BLCD:OnEnable()

end

function BLCD:OnDisable()

end
--------------------------------------------------------