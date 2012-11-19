--------------------------------------------------------
-- Blood Legion Raidcooldowns - Options --
--------------------------------------------------------
if not BLCD then return end
local BLCD = BLCD
local AceConfig = LibStub("AceConfig-3.0") -- For the options panel
local AceConfigDialog = LibStub("AceConfigDialog-3.0") -- Also for options panel
local AceDB = LibStub("AceDB-3.0") -- Makes saving things relaly easy
local AceDBOptions = LibStub("AceDBOptions-3.0") -- More database options

function BLCD:SetupOptions()
	BLCD.options.args.profile = AceDBOptions:GetOptionsTable(BLCD.db)
	
	AceConfig:RegisterOptionsTable("BLCD", BLCD.options, nil)
	
	BLCD.optionsFrames = {}
	BLCD.optionsFrames.general = AceConfigDialog:AddToBlizOptions("BLCD", "Blood Legion Cooldown", nil, "general")
	BLCD.optionsFrames.cooldowns = AceConfigDialog:AddToBlizOptions("BLCD", "Cooldown Settings", "Blood Legion Cooldown", "cooldowns")
	BLCD.optionsFrames.profile = AceConfigDialog:AddToBlizOptions("BLCD", "Profiles", "Blood Legion Cooldown", "profile")
end

BLCD.TexCoords = {.08, .92, .08, .92}

BLCD.defaults = {
	profile = {
		castannounce = false,
		cdannounce = false,
		clickannounce = true,
		scale = 1,
		growth = "right",
		show = "always",
		cooldown = {
			DA   = true,
			HOS  = true,
			PWB  = true,
			PS   = true,
			DH   = true,
			GS   = true,
			VS   = true,
			HH   = true,
			T    = true,
			FE   = true,
			R    = true,
			I    = true,
			SLT  = true,
			MTT  = true,
			HTT  = true,
			ST   = true,
			COTE = true,
			ZEN  = true,
			LIFE = true,
			REV  = true,
			SR   = true,
			RA   = true,
			AMZ  = true,
			RC   = true,
			DB   = true,
			SB	 = true,
		},
	},
}

BLCD.options =  {
	type = "group",
	name = "Blood Legion Cooldown",
	args = {
		general = {
			order = 1,
			type = "group",
			name = "General Settings",
			cmdInline = true,
			args = {
				castannounce = {
					type = "toggle",
					name = "Announce Casts",
					order = 2,
					get = function()
						return BLCD.profileDB.castannounce
					end,
					set = function(key, value)
						BLCD.profileDB.castannounce = value
					end,
				},		
				cdannounce = {
					type = "toggle",
					name = "Announce CD Expire",
					order = 3,
					get = function()
						return BLCD.profileDB.cdannounce
					end,
					set = function(key, value)
						BLCD.profileDB.cdannounce = value
					end,
				},		
				scale = {
					order = 4,
					type = "range",
					name = 'Set Scale',
					desc = "Sets Scale of Raid Cooldowns",
					min = 0.3, max = 2, step = 0.01,
					get = function()
						return BLCD.profileDB.scale 
					end,
					set = function(info, value)
						BLCD.profileDB.scale = value;
						BLCD:Scale();
					end,
				},	
				grow = {
					order = 5,
					name = "Bar Grow Direction",
					type = 'select',
					get = function()
						return BLCD.profileDB.growth 
					end,
					set = function(info, value)
						BLCD.profileDB.growth = value
					end,
					values = {
						['left'] = "Left",
						['right'] = "Right",
					},			
				},
				show = {
					order = 6,
					name = "Show Main Frame",
					type = 'select',
					get = function()
						return BLCD.profileDB.show 
					end,
					set = function(info, value)
						BLCD.profileDB.show = value
					end,
					values = {
						['always'] = "Always",
						['raid'] = "Raid",
						['party'] = "Party",
						['none'] = "None",
					},			
				},
				configure = {
					order = 9,
					type = "execute",
					name = "Apply Changes",
					desc = "Apply the changes to the active cooldowns and reload the UI.",
					func = function()
						ReloadUI()
					end,
					order = 1,
					width = "full",
				},
				clickannounce = {
					type = "toggle",
					name = "Click to Announce Available",
					order = 10,
					get = function()
						return BLCD.profileDB.clickannounce
					end,
					set = function(key, value)
						BLCD.profileDB.clickannounce = value
					end,
				},
			},
		},
		cooldowns = {
			order = 2,
			type = "group",
			name = "Cooldown Settings",
			cmdInline = true,
			args = {
				configure = {
					type = "execute",
					name = "Apply Changes",
					desc = "Apply the changes to the active cooldowns and reload the UI.",
					func = function()
						ReloadUI()
					end,
					order = 1,
					width = "full",
				},
				paladin = {
					type = "group",
					name = "Paladin Cooldowns",
					order = 2,
					args ={
						DA = {
							type = "toggle",
							name = "Devotion Aura",
							order = 1,
							get = function()
								return BLCD.profileDB.cooldown.DA
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.DA = value
							end,
						},
						HOS = {
							type = "toggle",
							name = "Hand of Sacrifice",
							order = 2,
							get = function()
								return BLCD.profileDB.cooldown.HOS
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.HOS = value
							end,
						},					
					},
				},
				priest = {
					type = "group",
					name = "Priest Cooldowns",
					order = 2,
					args ={
						PWB = {
							type = "toggle",
							name = "Power Word: Barrier",
							order = 1,
							get = function()
								return BLCD.profileDB.cooldown.PWB
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.PWB = value
							end,
						},
						PS = {
							type = "toggle",
							name = "Pain Suppression",
							order = 2,
							get = function()
								return BLCD.profileDB.cooldown.PS
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.PS = value
							end,
						},		
						DH = {
							type = "toggle",
							name = "Divine Hymn",
							order = 2,
							get = function()
								return BLCD.profileDB.cooldown.DH
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.DH = value
							end,
						},		
						GS = {
							type = "toggle",
							name = "Guardian Spirit",
							order = 2,
							get = function()
								return BLCD.profileDB.cooldown.GS
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.GS = value
							end,
						},		
						VS = {
							type = "toggle",
							name = "Void Shift",
							order = 2,
							get = function()
								return BLCD.profileDB.cooldown.VS
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.VS = value
							end,
						},
						HH = {
							type = "toggle",
							name = "Hymn Of Hope",
							order = 2,
							get = function()
								return BLCD.profileDB.cooldown.HH
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.HH = value
							end,
						},							
					},
				},
				druid = {
					type = "group",
					name = "Druid Cooldowns",
					order = 2,
					args ={
						T = {
							type = "toggle",
							name = "Tranquility",
							order = 1,
							get = function()
								return BLCD.profileDB.cooldown.T
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.T = value
							end,
						},		
						FE = {
							type = "toggle",
							name = "Ironbark",
							order = 1,
							get = function()
								return BLCD.profileDB.cooldown.FE
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.FE = value
							end,
						},	
						R = {
							type = "toggle",
							name = "Rebirth",
							order = 1,
							get = function()
								return BLCD.profileDB.cooldown.R
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.R = value
							end,
						},	
						I = {
							type = "toggle",
							name = "Innervate",
							order = 1,
							get = function()
								return BLCD.profileDB.cooldown.I
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.I = value
							end,
						},		
					},
				},
				shaman = {
					type = "group",
					name = "Shaman Cooldowns",
					order = 2,
					args ={
						SLT = {
							type = "toggle",
							name = "Spirit Link Totem",
							order = 1,
							get = function()
								return BLCD.profileDB.cooldown.SLT
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.SLT = value
							end,
						},		
						MTT = {
							type = "toggle",
							name = "Mana Tide Totem",
							order = 1,
							get = function()
								return BLCD.profileDB.cooldown.MTT
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.MTT = value
							end,
						},		
						HTT = {
							type = "toggle",
							name = "Healing Tide Totem",
							order = 1,
							get = function()
								return BLCD.profileDB.cooldown.HTT
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.HTT = value
							end,
						},		
						ST = {
							type = "toggle",
							name = "Stormlash Totem",
							order = 1,
							get = function()
								return BLCD.profileDB.cooldown.ST
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.ST = value
							end,
						},		
						COTE = {
							type = "toggle",
							name = "Call of the Elements",
							order = 1,
							get = function()
								return BLCD.profileDB.cooldown.COTE
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.COTE = value
							end,
						},			
					},
				},
				monk = {
					type = "group",
					name = "Monk Cooldowns",
					order = 2,
					args ={
						ZEN = {
							type = "toggle",
							name = "Zen Meditation",
							order = 1,
							get = function()
								return BLCD.profileDB.cooldown.ZEN
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.ZEN = value
							end,
						},	
						LIFE = {
							type = "toggle",
							name = "Life Cocoon",
							order = 1,
							get = function()
								return BLCD.profileDB.cooldown.LIFE
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.LIFE = value
							end,
						},	
						REV = {
							type = "toggle",
							name = "Revival",
							order = 1,
							get = function()
								return BLCD.profileDB.cooldown.REV
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.REV = value
							end,
						},	
					},
				},
				warlock = {
					type = "group",
					name = "Warlock Cooldowns",
					order = 2,
					args ={
						SR = {
							type = "toggle",
							name = "Soulstone Resurrection",
							order = 1,
							get = function()
								return BLCD.profileDB.cooldown.SR
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.SR = value
							end,
						},
					},
				},
				DK = {
					type = "group",
					name = "Death Knight Cooldowns",
					order = 2,
					args ={
						RA = {
							type = "toggle",
							name = "Raise Ally",
							order = 1,
							get = function()
								return BLCD.profileDB.cooldown.RA
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.RA = value
							end,
						},
						AMZ = {
							type = "toggle",
							name = "Anti-Magic Zone",
							order = 1,
							get = function()
								return BLCD.profileDB.cooldown.AMZ
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.AMZ = value
							end,
						},
					},
				},
				warrior = {
					type = "group",
					name = "Warrior Cooldowns",
					order = 2,
					args ={
						RC = {
							type = "toggle",
							name = "Rallying Cry",
							order = 1,
							get = function()
								return BLCD.profileDB.cooldown.RC
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.RC = value
							end,
						},
						DB = {
							type = "toggle",
							name = "Demoralizing Banner",
							order = 1,
							get = function()
								return BLCD.profileDB.cooldown.DB
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.DB = value
							end,
						},
						SB = {
							type = "toggle",
							name = "Skull Banner",
							order = 1,
							get = function()
								return BLCD.profileDB.cooldown.SB
							end,
							set = function(key, value)
								BLCD.profileDB.cooldown.SB = value
							end,
						},
					},
				},
			},
		},
	},
}
--------------------------------------------------------