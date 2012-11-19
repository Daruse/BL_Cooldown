--------------------------------------------------------
-- Blood Legion Raidcooldowns - Functions --
--------------------------------------------------------
if not BLCD then return end
local BLCD = BLCD
local LGIST=LibStub:GetLibrary("LibGroupInSpecT-1.0")
local CB = LibStub("LibCandyBar-3.0")
local Elv = IsAddOnLoaded("ElvUI")

if(Elv) then
	E, L, V, P, G =  unpack(ElvUI);
end

--------------------------------------------------------

--------------------------------------------------------
-- Helper Functions --
--------------------------------------------------------
function BLCD:GetPartyType()
    return ((select(2, IsInInstance()) == "pvp" and "battleground") or (select(2, IsInInstance()) == "arena" and "battleground") or (IsInRaid() and "raid") or (GetNumSubgroupMembers() > 0 and "party") or "none") 
end

function BLCD:print_r ( t )
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

function BLCD:ClassColorString (class)
    return string.format ("|cFF%02x%02x%02x",
        RAID_CLASS_COLORS[class].r * 255,
        RAID_CLASS_COLORS[class].g * 255,
        RAID_CLASS_COLORS[class].b * 255)
end

function BLCD:print_raid()
	return BLCD:print_r(BLCD['raidRoster'])
end

function BLCD:sec2Min(secs)
	return secs
end
--------------------------------------------------------

--------------------------------------------------------
-- Display Bar Functions --
--------------------------------------------------------
local function barSorter(a, b)
	return a.remaining < b.remaining and true or false
end

function BLCD:RearrangeBars(anchor)
	if not anchor then return end
    if not next(anchor.bars) then return end
    local frame = anchor:GetParent()
    wipe(BLCD.tmp)
	
    for bar in pairs(anchor.bars) do
		BLCD.tmp[#BLCD.tmp + 1] = bar
	end
	
	if(#BLCD.tmp>2)then
		frame:SetHeight((14*#BLCD.tmp)*BLCD.profileDB.scale);
	else
		frame:SetHeight(28*BLCD.profileDB.scale);
	end

	table.sort(BLCD.tmp, barSorter)
	local lastDownBar, lastUpBar = nil, nil
	
	for i, bar in next, BLCD.tmp do
		local spacing = -6
		bar:ClearAllPoints()
		if not (lastDownBar) then
	      if(BLCD.profileDB.growth  == "right") then
	    	   bar:SetPoint("TOPLEFT",anchor,"TOPRIGHT", 5, -2)
			elseif(BLCD.profileDB.growth  == "left") then
	    	   bar:SetPoint("TOPRIGHT",anchor,"TOPLEFT", -5, -2)
		   end	    
		else    
    		bar:SetPoint("TOPLEFT", lastDownBar, "BOTTOMLEFT", 0, -6)
		end
		lastDownBar = bar
	end
end


function BLCD:CreateBar(frame,cooldown,caster,frameicon,guid,duration)
	local bar = CB:New(BLCD:BLTexture(), 100, 9)
	frameicon.bars[bar] = true
	bar:Set("raidcooldowns:module", "raidcooldowns")
	bar:Set("raidcooldowns:anchor", frameicon)
	bar:Set("raidcooldowns:key", guid)
	bar:SetParent(frameicon)
	bar:SetFrameStrata("MEDIUM")
	bar:SetColor(.5,.5,.5,1);	
	bar:SetDuration(duration)
	bar:SetScale(BLCD.profileDB.scale)
	bar:SetClampedToScreen(true)

	local caster = strsplit("-",caster)
	bar:SetLabel(caster)
	
	bar.candyBarLabel:SetJustifyH("LEFT")
	BLCD:BLCreateBG(bar)
	
	bar:Start()

	BLCD:RearrangeBars(bar:Get("raidcooldowns:anchor"))
	
	return bar
end

function BLCD:CancelBars(frameicon)
    for k in pairs(frameicon.bars) do
        k:Stop()
    end
	 
	BLCD:RearrangeBars(frameicon) 
end
--------------------------------------------------------

--------------------------------------------------------
-- Visibility Functions --
--------------------------------------------------------
function BLCD:CheckVisibility()
	local frame = BLCooldownBase_Frame
    local grouptype = BLCD:GetPartyType()

    if(BLCD.profileDB.show == "always") then
		frame:Show()
		BLCD.show = true
	elseif(grouptype == "none") then
		frame:Hide()
		BLCD.show = nil
	elseif(BLCD.profileDB.show == "raid" and grouptype =="raid") then
		frame:Show()
		BLCD.show = true
	elseif(BLCD.profileDB.show == "raid" and grouptype ~="raid") then
		frame:Hide()
		BLCD.show = nil
	elseif(BLCD.profileDB.show == "party" and grouptype =="party") then
		frame:Show()
		BLCD.show = true
	elseif(BLCD.profileDB.show == "party" and grouptype ~="party") then
		frame:Hide()
		BLCD.show = nil
	end
end

function BLCD:ToggleVisibility()
	local frame = BLCooldownBase_Frame
	if(BLCD.show) then
		frame:Hide()
		BLCD.show = nil
	else
		frame:Show()
		BLCD.show = true
	end
end

function BLCD:ToggleMoversLock()
	local raidcdbasemover = BLCooldownBaseMover_Frame
	if(BLCD.locked) then
		raidcdbasemover:EnableMouse(true)
		raidcdbasemover:RegisterForDrag("LeftButton")
		raidcdbasemover:Show()
		BLCD.locked = nil
		print("|cffc41f3bBlood Legion Cooldown|r: unlocked")
	else
		raidcdbasemover:EnableMouse(false)
		raidcdbasemover:RegisterForDrag(nil)
		raidcdbasemover:Hide()
		BLCD.locked = true
		print("|cffc41f3bBlood Legion Cooldown|r: locked")
	end
end
--------------------------------------------------------

--------------------------------------------------------
-- Frame Functions --
--------------------------------------------------------
function BLCD:OnEnter(self, cooldown)
   local parent = self:GetParent()
	GameTooltip:Hide()
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT",3, 14)
	GameTooltip:ClearLines()
	GameTooltip:AddSpellByID(cooldown['spellID'])
	GameTooltip:Show()
end

function BLCD:OnLeave(self)
   GameTooltip:Hide()
end

function BLCD:PostClick(self, cooldown, rosterCD, curr)
	if(BLCD.profileDB.clickannounce) then
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
--------------------------------------------------------

--------------------------------------------------------
-- Frame Appearance Functions --
--------------------------------------------------------
function BLCD:Scale()
	local raidcdbase = BLCooldownBase_Frame
	local raidcdbasemover = BLCooldownBaseMover_Frame
	BLCD:BLSize(raidcdbase,32*BLCD.profileDB.scale,(32*BLCD.active)*BLCD.profileDB.scale)
	BLCD:BLSize(raidcdbasemover,32*BLCD.profileDB.scale,(32*BLCD.active)*BLCD.profileDB.scale)
	for i=1,BLCD.active do
		BLCD:BLHeight(_G['BLCooldown'..i],28*BLCD.profileDB.scale);
		BLCD:BLWidth(_G['BLCooldown'..i],145*BLCD.profileDB.scale);	
		BLCD:BLSize(_G['BLCooldownIcon'..i],28*BLCD.profileDB.scale);
		BLCD:BLFontTemplate(_G['BLCooldownIcon'..i].text, 20*BLCD.profileDB.scale, 'OUTLINE')
	end
end

function BLCD:SetBarGrowthDirection(frame, frameicon, index)
	if(BLCD.profileDB.growth == "left") then
	    if index == 1 then
			BLCD:BLPoint(frame,'TOPRIGHT', 'BLCooldownBase_Frame', 'TOPRIGHT', 2, -2);
		else
			BLCD:BLPoint(frame,'TOPRIGHT', 'BLCooldown'..(index-1), 'BOTTOMRIGHT', 0, -4);
		end
		BLCD:BLPoint(frameicon,'TOPRIGHT', frame, 'TOPRIGHT');
	elseif(BLCD.profileDB.growth  == "right") then
		if index == 1 then
			BLCD:BLPoint(frame,'TOPLEFT', 'BLCooldownBase_Frame', 'TOPLEFT', 2, -2);
		else
			BLCD:BLPoint(frame,'TOPLEFT', 'BLCooldown'..(index-1), 'BOTTOMLEFT', 0, -4);
		end
		BLCD:BLPoint(frameicon,'TOPLEFT', frame, 'TOPLEFT');
	end
end

function BLCD:BLHeight(frame, height)
	if(Elv) then
		frame:Height(height)
	else
		frame:SetHeight(height)
	end
end

function BLCD:BLWidth(frame, width)
	if(Elv) then
		frame:Width(width)
	else
		frame:SetWidth(width)
	end
end

function BLCD:BLSize(frame, height, width)
	if(Elv) then
		frame:Size(height, width)
	else
		frame:SetSize(height, width)
	end
end

function BLCD:BLPoint(obj, arg1, arg2, arg3, arg4, arg5)
	if(Elv) then
		obj:Point(arg1, arg2, arg3, arg4, arg5)
	else
		obj:SetPoint(arg1, arg2, arg3, arg4, arg5)
	end
end

function BLCD:BLTexture()
	if(Elv) then
		return E["media"].normTex
	else
		return "Interface\\AddOns\\BL_Cooldown\\statusbar"	
	end
end

function BLCD:BLCreateBG(frame)
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

function BLCD:BLFontTemplate(frame, x, y)
	if(Elv) then
		frame:FontTemplate(nil, x, y)
	else
		frame:SetFont("Fonts\\FRIZQT__.TTF", x, y)
	end
end
--------------------------------------------------------