--------------------------------------------------------
-- Blood Legion Raidcooldowns - Functions --
--------------------------------------------------------
local BLRCD = BLRCD
local RI = LibStub("LibRaidInspect-1.0")
local CB = LibStub("LibCandyBar-3.0")
local Elv = IsAddOnLoaded("ElvUI")

if(Elv) then
	E, L, V, P, G =  unpack(ElvUI);
end

--------------------------------------------------------

--------------------------------------------------------
-- Helper Functions --
--------------------------------------------------------
function BLRCD:Scale()
	local raidcdbase = BLRaidCooldownBase_Frame
	local raidcdbasemover = BLRaidCooldownBaseMover_Frame
	BLRCD:BLSize(raidcdbase,32*BLRCD.profileDB.scale,(32*BLRCD.active)*BLRCD.profileDB.scale)
	BLRCD:BLSize(raidcdbasemover,32*BLRCD.profileDB.scale,(32*BLRCD.active)*BLRCD.profileDB.scale)
	for i=1,BLRCD.active do
		BLRCD:BLHeight(_G['BLRaidCooldown'..i],28*BLRCD.profileDB.scale);
		BLRCD:BLWidth(_G['BLRaidCooldown'..i],145*BLRCD.profileDB.scale);	
		BLRCD:BLSize(_G['BLRaidCooldownIcon'..i],28*BLRCD.profileDB.scale);
		BLRCD:BLFontTemplate(_G['BLRaidCooldownIcon'..i].text, 20*BLRCD.profileDB.scale, 'OUTLINE')
	end
end

function BLRCD:CheckVisibility()
	local frame = BLRaidCooldownBase_Frame
	if(RI:GroupType() == 2) then
		frame:Show()
	else
		frame:Hide()
	end
end

function BLRCD:BLHeight(frame, height)
	if(Elv) then
		frame:Height(height)
	else
		frame:SetHeight(height)
	end
end

function BLRCD:BLWidth(frame, width)
	if(Elv) then
		frame:Width(width)
	else
		frame:SetWidth(width)
	end
end

function BLRCD:BLSize(frame, height, width)
	if(Elv) then
		frame:Size(height, width)
	else
		frame:SetSize(height, width)
	end
end

function BLRCD:BLPoint(obj, arg1, arg2, arg3, arg4, arg5)
	if(Elv) then
		obj:Point(arg1, arg2, arg3, arg4, arg5)
	else
		obj:SetPoint(arg1, arg2, arg3, arg4, arg5)
	end
end

function BLRCD:BLTexture()
	if(Elv) then
			return E["media"].normTex
	else
		return "Interface\\AddOns\\MyAddOn\\statusbar"	
	end
end

function BLRCD:BLCreateBG(frame)
	if(Elv) then
		local bg = CreateFrame("Frame");
		bg:SetTemplate("Default")
		bg:SetParent(frame)
		bg:ClearAllPoints()
		bg:Point("TOPLEFT", frame, "TOPLEFT", -2, 2)
		bg:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 2, -2)
		bg:SetFrameStrata("MEDIUM")
		bg:Show()
	end
end

function BLRCD:BLFontTemplate(frame, x, y)
	if(Elv) then
		frame:FontTemplate(nil, x, y)
	else
		frame:SetFont("Fonts\\FRIZQT__.TTF", x, y)
	end
end

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

--------------------------------------------------------
-- Raid Roster Functions --
--------------------------------------------------------
function BLRCD:UpdateRoster(cooldown)
	if(RI:GroupType() == 2 or RI:GroupType() == 1) then
		for i, name in pairs(BLRCD.cooldownRoster[cooldown['spellID']]) do
			if not(UnitInRaid(i) or UnitInParty(i)) then
				BLRCD.cooldownRoster[cooldown['spellID']][i] = nil
			end
		end
		for i, char in pairs(LibRaidInspectMembers) do
			if(UnitInRaid(char['name']) or UnitInParty(char['name'])) then 
				if(string.lower(char["class"]:gsub(" ", ""))==string.lower(cooldown["class"]):gsub(" ", "")) then 
					if(cooldown["spec"]) then
						if(char["spec"]) then 
							if(string.lower(char["spec"])==string.lower(cooldown["spec"])) then 
								BLRCD.cooldownRoster[cooldown['spellID']][i] = char['name'] 
							end
						end
					elseif(cooldown["talents"]) then
						if(char["talents"]) then
							if(char["talents"][cooldown["talents"]]==cooldown["spellID"]) then 
								BLRCD.cooldownRoster[cooldown['spellID']][i] = char['name']
							end
						end
					else
						BLRCD.cooldownRoster[cooldown['spellID']][i] = char['name']
					end
				end
			else		
				if(BLRCD.cooldownRoster[cooldown['spellID']][i]) then
					BLRCD.cooldownRoster[cooldown['spellID']][i] = nil
				end
				LibRaidInspectMembers[i] = nil
			end
		end
	else
		BLRCD.cooldownRoster[cooldown['spellID']] = {}
		BLRCD.curr[cooldown['spellID']] = {}
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

function BLRCD:RemovePlayer(guid)
	if(BLRCD['handles'][guid]) then
		for spell,value in pairs(BLRCD['handles'][guid]) do
			BLRCD:StopCD(value[1])
			value[3]:Stop()
		end
	end
	LibRaidInspectMembers[guid] = nil
end
--------------------------------------------------------

--------------------------------------------------------
-- Display Bar Functions --
--------------------------------------------------------
local function barSorter(a, b)
	return a.remaining < b.remaining and true or false
end

function BLRCD:RearrangeBars(anchor)
	if not anchor then return end
    if not next(anchor.bars) then return end
    local frame = anchor:GetParent()
    wipe(BLRCD.tmp)
	
    for bar in pairs(anchor.bars) do
		BLRCD.tmp[#BLRCD.tmp + 1] = bar
	end
	
	if(#BLRCD.tmp>2)then
		frame:SetHeight((14*#BLRCD.tmp)*BLRCD.profileDB.scale);
	else
		frame:SetHeight(28*BLRCD.profileDB.scale);
	end

	table.sort(BLRCD.tmp, barSorter)
	local lastDownBar, lastUpBar = nil, nil
	
	for i, bar in next, BLRCD.tmp do
		local spacing = -6
		bar:ClearAllPoints()
		if not (lastDownBar) then
	      if(BLRCD.profileDB.growth  == "right") then
	    	   bar:SetPoint("TOPLEFT",anchor,"TOPRIGHT", 5, -2)
			elseif(BLRCD.profileDB.growth  == "left") then
	    	   bar:SetPoint("TOPRIGHT",anchor,"TOPLEFT", -5, -2)
		   end	    
		else    
    		bar:SetPoint("TOPLEFT", lastDownBar, "BOTTOMLEFT", 0, -6)
		end
		lastDownBar = bar
	end
end

function BLRCD:CreateBar(frame,cooldown,caster,frameicon,guid)
	local bar = CB:New(BLRCD:BLTexture(), 100, 9)
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

	BLRCD:BLCreateBG(bar)
	
	bar:Start()
	BLRCD:RearrangeBars(bar:Get("raidcooldowns:anchor"))
	
	return bar
end

function BLRCD:CancelBars(frameicon)
    for k in pairs(frameicon.bars) do
        k:Stop()
    end
	 
	 BLRCD:RearrangeBars(frameicon) 
end
--------------------------------------------------------

--------------------------------------------------------
-- Frame Functions --
--------------------------------------------------------
function BLRCD:OnEnter(self, cooldown)
   local parent = self:GetParent()
	GameTooltip:Hide()
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT",3, 14)
	GameTooltip:ClearLines()
	GameTooltip:AddSpellByID(cooldown['spellID'])
	GameTooltip:Show()
end

function BLRCD:PostClick(self, cooldown, rosterCD, curr)
	if(BLRCD.profileDB.clickannounce) then
		local allCD,onCD = rosterCD, curr
		local name = GetSpellInfo(cooldown['spellID'])
		for i,v in pairs(onCD) do
			allCD[i] = nil
		end
	
		if next(allCD) ~= nil then
			SendChatMessage('----- '..name..' -----','raid')
			for i,v in pairs(allCD) do
				SendChatMessage(v..' ready!','raid')
			end
		end
	end
end

function BLRCD:OnLeave(self)
   GameTooltip:Hide()
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
	local raidcdbasemover = BLRaidCooldownBaseMover_Frame
	if(BLRCD.locked) then
		raidcdbasemover:EnableMouse(true)
		raidcdbasemover:RegisterForDrag("LeftButton")
		raidcdbasemover:Show()
		BLRCD.locked = nil
		print("|cffc41f3bBL Raid Cooldowns|r: unlocked")
	else
		raidcdbasemover:EnableMouse(false)
		raidcdbasemover:RegisterForDrag(nil)
		raidcdbasemover:Hide()
		BLRCD.locked = true
		print("|cffc41f3bBL Raid Cooldowns|r: locked")
	end
end
--------------------------------------------------------