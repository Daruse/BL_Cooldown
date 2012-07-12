--------------------------------------------------------
-- Blood Legion Raidcooldowns --
--------------------------------------------------------
local name = "BLRaidCooldown"
BLRCD = LibStub("AceAddon-3.0"):NewAddon(name, "AceEvent-3.0", "AceConsole-3.0", "AceTimer-3.0")
local RI =  LibStub("LibRaidInspect-1.0")
local CB = LibStub("LibCandyBar-3.0")
local curr = {}
local cooldownRoster = {}
local tmp = {}
local BLRCDt = {}
BLRCDt['handles'] ={}


if not BLRCD then return end

--[[curr ={['spellID'] = {
									['GUID'] = name
								 },
			}
]]

BLRCD.TexCoords = {.08, .92, .08, .92}

if not BLRCD.events then
	BLRCD.events = LibStub("CallbackHandler-1.0"):New(BLRCD)
end

local frame = BLRCD.frame
if (not frame) then
	frame = CreateFrame("Frame", name .. "_Frame")
	BLRCD.frame = frame
end

--------------------------------------------------------
-- Cooldowns --
--------------------------------------------------------

BLRCD.cooldowns = {
	     -- Paladin
	{ -- Devotion Aura
		spellID = 31821,
		name = "DA",
		succ = "SPELL_CAST_SUCCESS",
		CD = 180,
		class = "PALADIN",
	},
	{ -- Hand of Sacrifice
		spellID = 6940,
		name = "HoS",
		succ = "SPELL_CAST_SUCCESS",
		CD = 120,
		class = "PALADIN",
	},
	
	     -- Priest
	{ -- Power Word: Barrier 
		spellID = 62618,
		succ = "SPELL_CAST_SUCCESS",
		name = "PWB",
		CD = 180,
		class = "PRIEST", 
		cast_time = 10,
		spec = "Discipline",
	},
	{ -- Pain Suppression  
		spellID = 33206,
		succ = "SPELL_CAST_SUCCESS",
		name = "PS",
		CD = 180,
		class = "PRIEST", 
		cast_time = 8,
		spec = "Discipline",
	},
	{ -- Divine Hymn
	
		spellID = 64843,
		succ = "SPELL_CAST_SUCCESS",
		name = "DH",
		CD = 180,
		class = "PRIEST", 
		cast_time = 8,
		spec = "Holy",
	},	
	{ -- Guardian Spirit 
		spellID = 47788,
		succ = "SPELL_CAST_SUCCESS",
		name = "GS",
		CD = 180,
		class = "PRIEST", 
		cast_time = 10,
		spec = "Holy",
	},	
	{ -- Void Shift
		spellID = 108968,
		succ = "SPELL_CAST_SUCCESS",
		name = "VS",
		CD = 360,
		class = "PRIEST",
	},
	{ -- Hymn Of Hope
		spellID = 64901,
		succ = "SPELL_CAST_SUCCESS",
		name = "HH",
		CD = 360,
		class = "PRIEST", 
		cast_time = 8,	
	},
		
		 -- Druid
	{ -- Tranquility
		spellID = 740,
		succ = "SPELL_CAST_SUCCESS",
		name = "T",
		CD = 480,
		class = "DRUID",
	},
	{ -- Ironbark
		spellID = 102342,
		succ = "SPELL_CAST_SUCCESS",
		name = "FE",
		CD = 120,
		class = "DRUID",
		spec = "Guardian",
	},
	{ -- Rebirth
		spellID = 20484,
		succ = "SPELL_CAST_START",
		name = "R",
		cd = 600,
		class = "DRUID",
	},
	{ -- Innervate
		spellID = 29166,
		succ = "SPELL_CAST_SUCCESS",
		name = "I",
		CD = 180,
		class = "DRUID",
	},
	
		-- Shaman
	{ -- Spirit Link Totem
		spellID = 98008,
		succ = "SPELL_CAST_SUCCESS",
		name = "SLT",
		CD = 180,
		class = "SHAMAN", 
		cast_time = 6,
		spec = "Restoration",
	},
	{ -- Mana Tide Totem
		spellID = 16190,
		succ = "SPELL_CAST_SUCCESS",
		name = "MTT",
		CD = 180,
		class = "SHAMAN",
		cast_time = 12,
		spec = "Restoration",
	},
	{ -- Healing Tide Totem
		spellID = 108280,
		succ = "SPELL_CAST_SUCCESS",
		name = "HTT",
		CD = 180,
		class = "SHAMAN",
	},
	{ -- Stormlash Totem
		spellID = 120668,
		succ = "SPELL_CAST_SUCCESS",
		name = "ST",
		CD = 300,
		class = "SHAMAN",
	},
	{ -- Call of the Elements
		spellID = 108285,
		succ = "SPELL_CAST_SUCCESS",
		name = "COTE",
		CD = 480,
		class = "SHAMAN",
	},
	 
		 -- Monk
	{	-- Zen Meditation
		spellID = 115176,
		succ = "SPELL_CAST_SUCCESS",
		name = "ZEN",
		CD = 180,
		class = "MONK",
	},
	{	-- Life Cocoon
		spellID = 116849,
		succ = "SPELL_CAST_SUCCESS",
		name = "LIFE",
		CD = 120,
		class = "MONK",
		spec = "Mistweaver",
	},
	{	-- Revival
		spellID = 115310,
		succ = "SPELL_CAST_SUCCESS",
		name = "REV",
		CD = 180,
		class = "MONK",
		spec = "Mistweaver",
	},
	
		 -- Warlock
	{ -- Soulstone Resurrection
		spellID = 20707,
		succ = "SPELL_CAST_START",
		name = "SR",
		CD = 900,
		class = "WARLOCK",
	},
	
	     -- Death Knight
	{ -- Raise Ally
		spellID = 61999,
		succ = "SPELL_CAST_SUCCESS", 
		name = "RA",
		CD = 600,
		class = "DEATHKNIGHT",
	},
	{ -- Anti-Magic Zone
		spellID = 51052,
		succ = "SPELL_CAST_SUCCESS",
		name = "AMZ",
		CD = 120,
		class = "DEATHKNIGHT",
		spec = "Unholy",
	},
	
	     -- Warrior
	{ -- Rallying Cry
		spellID = 97462,
		succ = "SPELL_CAST_SUCCESS",
		name = "RC",
		CD = 180,
		class = "WARRIOR",
	},
	{ -- Demoralizing Banner
		spellID = 114203,
		succ = "SPELL_CAST_SUCCESS",
		name = "DB",
		CD = 180,
		class = "WARRIOR",
	},
}
--------------------------------------------------------
-- Helper Functions --
--------------------------------------------------------

function BLRCD:print_r ( t )
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    sub_print_r(t," ")
end


--------------------------------------------------------
-- Addon Functions --
--------------------------------------------------------

function BLRCD:OnEnter(self, cooldown)
   local parent = self:GetParent()
	GameTooltip:Hide()
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT",3, 14)
	GameTooltip:ClearLines()
	GameTooltip:AddSpellByID(cooldown['spellID'])
	GameTooltip:Show()
end

function BLRCD:OnLeave(self)
   GameTooltip:Hide()
end

function BLRCD:SlashProcessor_BLRCD(input)
	local v1, v2 = input:match("^(%S*)%s*(.-)$")
	v1 = v1:lower()

	if v1 == "" then
		print("/blrcd lock - Lock and Unlock Frame")
		print("/blrcd debug - Raid talents")
		print("/blrcd show - Hide/Show Main Frame")
		print("/blrcd raid - Print Raid Roster and talents")		
	elseif v1 == "lock" or v1 == "unlock" or v1 == "drag" or v1 == "move" or v1 == "l" then
		BLRCD:ToggleMoversLock()	
	elseif v1 == "raid" then
		BLRCD:returnRaidRoster()
	elseif v1 == "debug" then
		BLRCD:print_r(LibRaidInspectMembers)
	elseif v1 == "debug2" then
		BLRCD:print_r(cooldownRoster)
	elseif v1 == "show" then
		BLRCD:ToggleVisibility()	
	end
end

function	BLRCD:ToggleVisibility()
	local raidcdbase = BLRaidCooldownBase_Frame
	if(BLRCD.show) then
		raidcdbase:Hide()
		BLRCD.show = nil
	else
		raidcdbase:Show()
		BLRCD.show = true
	end
end

function BLRCD:ToggleMoversLock()
	local raidcdbase = BLRaidCooldownBase_Frame
	if(BLRCD.locked) then
		raidcdbase:EnableMouse(true)
		raidcdbase:RegisterForDrag("LeftButton")
		BLRCD.locked = nil
		print("unlocked")
	else
		raidcdbase:EnableMouse(false)
		raidcdbase:RegisterForDrag(nil)
		BLRCD.locked = true
		print("locked")
	end
end

local function barSorter(a, b)
	return a.remaining < b.remaining and true or false
end

function BLRCD:RearrangeBars(anchor)
	if not anchor then return end
    if not next(anchor.bars) then return end
    local frame = anchor:GetParent()
    wipe(tmp)
	
    for bar in pairs(anchor.bars) do
		tmp[#tmp + 1] = bar
	end
	
	if(#tmp>2)then
		frame:SetHeight(14*#tmp);
	else
		frame:SetHeight(28);
	end
	
	table.sort(tmp, barSorter)
	local lastDownBar, lastUpBar = nil, nil
	
	for i, bar in next, tmp do
		local spacing = -6
		bar:ClearAllPoints()
		if not (lastDownBar) then
			bar:SetPoint("TOPLEFT",anchor,"TOPRIGHT", 5, -2)
    	else    
    		bar:SetPoint("TOPLEFT", lastDownBar, "BOTTOMLEFT", 0, -6)
		end
		lastDownBar = bar
	end
end

function BLRCD:CreateBar(frame,cooldown,caster,frameicon,guid)
	local bar = CB:New("Interface\\AddOns\\MyAddOn\\statusbar", 100, 9)
	frameicon.bars[bar] = true
	bar:Set("raidcooldowns:module", "raidcooldowns")
	bar:Set("raidcooldowns:anchor", frameicon)
	bar:Set("raidcooldowns:key", guid)
	bar:SetParent(frameicon)
	bar:SetFrameStrata("MEDIUM")
	bar:SetColor(.5,.5,.5,1);	
	bar:SetDuration(cooldown['CD'])
	bar:SetClampedToScreen(true)
	local caster = strsplit("-",caster)
	bar:SetLabel(caster)
	bar.candyBarLabel:SetJustifyH("LEFT")
	local classcolor = RAID_CLASS_COLORS[string.upper(cooldown.class):gsub(" ", "")]
	bar.candyBarLabel:SetTextColor(classcolor.r,classcolor.g,classcolor.b)
	bar:Start()
	BLRCD:RearrangeBars(bar:Get("raidcooldowns:anchor"))
	
	return bar
end

function BLRCD:StartCD(frame,cooldown,text,guid,caster,frameicon, spell)
	if not (curr[cooldown['spellID']][guid]) then
	    curr[cooldown['spellID']][guid]=guid
   end
	 
	local bar = BLRCD:CreateBar(frame,cooldown,caster,frameicon,guid)
	
	local args = {cooldown,guid,frame,text,bar,caster,spell}
	local handle = BLRCD:ScheduleTimer("StopCD", cooldown['CD'],args)
	if not BLRCDt['handles'][guid] then
		BLRCDt['handles'][guid] = {}
	end
	BLRCDt['handles'][guid][spell] = {args,handle,bar}
end


function BLRCD:CancelBars(frameicon)
    for k in pairs(frameicon.bars) do
        k:Stop()
    end
	 
	 BLRCD:RearrangeBars(frameicon) 
end

function BLRCD:StopCD(args)
	curr[args[1]['spellID']][args[2]] = nil;
	
	local a = args[5]:Get("raidcooldowns:anchor")
	if a and a.bars and a.bars[args[5]] then
      a.bars[args[5]] = nil
		BLRCD:RearrangeBars(a) 
	end
	
	args[4]:SetText(BLRCD:GetTotalCooldown(args[1]))
end

function BLRCD:CheckSpecial(guid,spell)
	if LibRaidInspectMembers[guid]['class'] == 'Shaman' and spell == "Call of the Elements" then
		for spell,value in pairs(BLRCDt['handles'][guid]) do
			if spell == "Mana Tide Totem" or spell == "Spirit Link Totem" or spell == "Healing Tide Totem" then
				BLRCD:StopCD(value[1])
				BLRCD:CancelTimer(value[2])
				value[3]:Stop()
			end
		end
	end
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
					BLRCD:CheckSpecial(sourceGUID,spellName)
					BLRCD:StartCD(frame,cooldown,text,sourceGUID,sourceName,frameicon, spellName)
					text:SetText(BLRCD:GetTotalCooldown(cooldown))
	         end
			end
		 end
	elseif(event =="GROUP_ROSTER_UPDATE") then
		if not(RI:GroupType() == 2) then
			curr[cooldown['spellID']]={}
	      BLRCD:CancelBars(frameicon)
		end
		text:SetText(BLRCD:GetTotalCooldown(cooldown))
	else
		text:SetText(BLRCD:GetTotalCooldown(cooldown))
	end
end

function BLRCD:GetTotalCooldown(cooldown)
	local cd = 0
	local cdTotal = 0
	for i,v in pairs(cooldownRoster[cooldown['spellID']]) do
		cdTotal=cdTotal+1
	end
	
	for i,v in pairs(curr[cooldown['spellID']]) do
		cd=cd+1
	end
	
	return (cdTotal-cd)
end


--------------------------------------------------------
-- Raid Roster Functions --
--------------------------------------------------------
function BLRCD:UpdateRoster(cooldown)
	for i, name in pairs(cooldownRoster[cooldown['spellID']]) do
		if not(UnitInRaid(i)) then
			cooldownRoster[cooldown['spellID']][i] = nil
		end
	end
	for i, char in pairs(LibRaidInspectMembers) do
		if(UnitInRaid(char['name'])) then 
               if(string.lower(char["class"]:gsub(" ", ""))==string.lower(cooldown["class"]):gsub(" ", "")) then 
                    if(cooldown["spec"]) then 
                         if(char["spec"]) then 
                              if(string.lower(char["spec"])==string.lower(cooldown["spec"])) then 
                                   cooldownRoster[cooldown['spellID']][i] = char['name'] 
                              end 
                         end 
                    else 
                         cooldownRoster[cooldown['spellID']][i] = char['name'] 
                    end 
				end
		end
	end
end

function BLRCD:returnRaidRoster()
	SendChatMessage("Current Raid Roster", "RAID")
	for i, char in pairs(LibRaidInspectMembers) do
		SendChatMessage(char["name"].." - "..char["class"].." - "..char["race"], "RAID")
		if(char["spec"]) then
			SendChatMessage(char["spec"], "RAID")
			SendChatMessage("Talents", "RAID")
			for j, talent in pairs(char["talents"]) do
				SendChatMessage(select(1, GetSpellInfo(talent)), "RAID")
			end
			SendChatMessage("Glyphs", "RAID")
			for j, glyph in pairs(char["glyphs"]) do
				SendChatMessage(select(1, GetSpellInfo(glyph)), "RAID")
			end
		end
		SendChatMessage("----------------------------", "RAID")
	end
end

--------------------------------------------------------
-- Initialization --
--------------------------------------------------------
BLRCD.frame:UnregisterAllEvents()
BLRCD.frame:RegisterEvent("ADDON_LOADED")
BLRCD.frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
BLRCD.frame:RegisterEvent("GROUP_ROSTER_UPDATE")
BLRCD.frame:RegisterEvent("INSPECT_READY")

BLRCD.frame:SetScript("OnEvent", function(this, event, ...)
	return BLRCD[event](BLRCD, ...)
end)

local count = 0
function BLRCD:OnInitialize()
	if count == 1 then return end
	BLRCD.CreateBase()
	BLRCD:RegisterChatCommand("BLRCD", "SlashProcessor_BLRCD")
	local index = 0
	for i, cooldown in pairs(BLRCD.cooldowns) do
	   index = index + 1;
   	curr[cooldown['spellID']] = {}
		cooldownRoster[cooldown['spellID']] = {}
   	BLRCD.CreateCooldown(index, cooldown);
   end    
   count = 1
end

function BLRCD:OnEnable()
	BLRCD.roster = LibRaidInspectMembers
end

function BLRCD:OnDisable()

end

--------------------------------------------------------
-- Frame Management --
--------------------------------------------------------
BLRCD.CreateBase = function()
	local raidcdbase = CreateFrame("Frame", 'BLRaidCooldownBase_Frame', UIParent);
	raidcdbase:SetSize(32,(30*#BLRCD.cooldowns)+(1*#BLRCD.cooldowns+3));
	raidcdbase:SetClampedToScreen(true);
	raidcdbase:SetPoint('TOPLEFT', UIParent, 'TOPLEFT', 7, -50);
	raidcdbase:SetMovable(true)
	raidcdbase:SetScript("OnDragStart", function(self) self:StartMoving() end)
	raidcdbase:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
	BLRCD.locked = true
	if (RI:GroupType() == 2) then
		raidcdbase:Show()
		BLRCD.show = true
	end
end

BLRCD.CreateCooldown = function (index, cooldown)
	local frame = CreateFrame("Frame", 'BLRaidCooldown'..index, BLRaidCooldownBase_Frame);
	frame:SetHeight(30);
	frame:SetClampedToScreen(true);
	frame:SetWidth(145);
	  
	local frameicon = CreateFrame("Frame", 'BLRaidCooldownIcon'..index, BLRaidCooldownBase_Frame);
	local classcolor = RAID_CLASS_COLORS[string.upper(cooldown.class):gsub(" ", "")]
	frameicon:SetBackdropBorderColor(classcolor.r,classcolor.g,classcolor.b)
	frameicon:SetParent(frame)
	frameicon.bars = {}
	frameicon:SetSize(30,30);
	frameicon:SetClampedToScreen(true);
	
	if index == 1 then
		frame:SetPoint('TOPLEFT', 'BLRaidCooldownBase_Frame', 'TOPLEFT', 2, -2);
	else
		frame:SetPoint('TOPLEFT', 'BLRaidCooldown'..(index-1), 'BOTTOMLEFT', 0, -4);
	end
	frameicon:SetPoint('TOPLEFT', frame, 'TOPLEFT');
	
	frameicon.icon = frameicon:CreateTexture(nil, "OVERLAY");
	frameicon.icon:SetTexCoord(unpack(BLRCD.TexCoords));
	frameicon.icon:SetTexture(select(3, GetSpellInfo(cooldown['spellID'])));
	frameicon.icon:SetPoint('TOPLEFT', 2, -2);
	frameicon.icon:SetPoint('BOTTOMRIGHT', -2, 2);
	
	local text = frameicon:CreateFontString(nil, 'OVERLAY')
	text:SetPoint("CENTER",frameicon, "CENTER", 1, 0)
	text:SetFont("Fonts\\FRIZQT__.TTF", 20, "OUTLINE")
	BLRCD:UpdateRoster(cooldown)
	BLRCD:UpdateCooldown(self,event,unit,cooldown,text,frameicon)
 	
	frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	frame:RegisterEvent("GROUP_ROSTER_UPDATE")	
	
	RI.RegisterCallback (frame, "LibRaidInspect_Update", function(self,event, ...)
		BLRCD:UpdateRoster(cooldown)
		BLRCD:UpdateCooldown(frame,event,unit,cooldown,text,frameicon, ...)
	end)
	
	RI.RegisterCallback (frame, "LibRaidInspect_Remove", function(self,event, ...)
		BLRCD:UpdateRoster(cooldown)
		BLRCD:UpdateCooldown(frame,event,unit,cooldown,text,frameicon, ...)
	end)
	
	frameicon:SetScript("OnEnter", function(self,event, ...)
		BLRCD:OnEnter(self, cooldown, cooldownRoster[cooldown['spellID']], curr[cooldown['spellID']])
   end);
    
   frameicon:SetScript("OnLeave", function(self,event, ...)
		BLRCD:OnLeave(self)
   end);
	
	
	frame:SetScript("OnEvent", function(self,event, ...)
		BLRCD:UpdateCooldown(self,event,unit,cooldown,text,frameicon, ...)
   end);
		
	frame:Show()
end

--------------------------------------------------------
-- Event Functions --
--------------------------------------------------------
function BLRCD:ADDON_LOADED(name)
	if(name=="BLRaidCooldowns") then
	
	end
end

function BLRCD:COMBAT_LOG_EVENT_UNFILTERED(timestamp, type,_, sourceGUID, sourceName,_,_, destGUID, destName)

end

function BLRCD:GROUP_ROSTER_UPDATE(unit, spell)
	BLRCD.roster = LibRaidInspectMembers
end

function BLRCD:INSPECT_READY(guid)
	BLRCD.roster = LibRaidInspectMembers
end