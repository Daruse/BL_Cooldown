--------------------------------------------------------
-- Blood Legion Raidcooldowns - Options --
--------------------------------------------------------
local BLRCD = BLRCD
local CB = LibStub("LibCandyBar-3.0")
local AceConfig = LibStub("AceConfig-3.0") -- For the options panel
local AceConfigDialog = LibStub("AceConfigDialog-3.0") -- Also for options panel
local AceDB = LibStub("AceDB-3.0") -- Makes saving things relaly easy
local AceDBOptions = LibStub("AceDBOptions-3.0") -- More database options

function BLRCD:SetupOptions()
	BLRCD.options.args.profile = AceDBOptions:GetOptionsTable(BLRCD.db)
	
	AceConfig:RegisterOptionsTable("BLRCD", BLRCD.options, nil)
	
	BLRCD.optionsFrames = {}
	BLRCD.optionsFrames.general = AceConfigDialog:AddToBlizOptions("BLRCD", "Blood Legion Cooldowns", nil, "general")
	BLRCD.optionsFrames.cooldowns = AceConfigDialog:AddToBlizOptions("BLRCD", "Cooldown Settings", "Blood Legion Cooldowns", "cooldowns")
	BLRCD.optionsFrames.profile = AceConfigDialog:AddToBlizOptions("BLRCD", "Profiles", "Blood Legion Cooldowns", "profile")
end

BLRCD.TexCoords = {.08, .92, .08, .92}

BLRCD.defaults = {
	profile = {
		castannounce = false,
		cdannounce = false,
		clickannounce = false,
		scale = 1,
		growth = "right",
		show = "raid",
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
		},
	},
}

BLRCD.options =  {
	type = "group",
	name = "Blood Legion Cooldowns",
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
						return BLRCD.profileDB.castannounce
					end,
					set = function(key, value)
						BLRCD.profileDB.castannounce = value
					end,
				},		
				cdannounce = {
					type = "toggle",
					name = "Announce CD Expire",
					order = 3,
					get = function()
						return BLRCD.profileDB.cdannounce
					end,
					set = function(key, value)
						BLRCD.profileDB.cdannounce = value
					end,
				},		
				scale = {
					order = 4,
					type = "range",
					name = 'Set Scale',
					desc = "Sets Scale of Raid Cooldowns",
					min = 0.3, max = 2, step = 0.01,
					get = function()
						return BLRCD.profileDB.scale 
					end,
					set = function(info, value)
						BLRCD.profileDB.scale = value;
						BLRCD:Scale();
					end,
				},	
				grow = {
					order = 5,
					name = "Bar Grow Direction",
					type = 'select',
					get = function()
						return BLRCD.profileDB.growth 
					end,
					set = function(info, value)
						BLRCD.profileDB.growth = value
					end,
					values = {
						['left'] = "Left",
						['right'] = "Right",
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
						return BLRCD.profileDB.clickannounce
					end,
					set = function(key, value)
						BLRCD.profileDB.clickannounce = value
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
								return BLRCD.profileDB.cooldown.DA
							end,
							set = function(key, value)
								BLRCD.profileDB.cooldown.DA = value
							end,
						},
						HOS = {
							type = "toggle",
							name = "Hand of Sacrifice",
							order = 2,
							get = function()
								return BLRCD.profileDB.cooldown.HOS
							end,
							set = function(key, value)
								BLRCD.profileDB.cooldown.HOS = value
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
								return BLRCD.profileDB.cooldown.PWB
							end,
							set = function(key, value)
								BLRCD.profileDB.cooldown.PWB = value
							end,
						},
						PS = {
							type = "toggle",
							name = "Pain Suppression",
							order = 2,
							get = function()
								return BLRCD.profileDB.cooldown.PS
							end,
							set = function(key, value)
								BLRCD.profileDB.cooldown.PS = value
							end,
						},		
						DH = {
							type = "toggle",
							name = "Divine Hymn",
							order = 2,
							get = function()
								return BLRCD.profileDB.cooldown.DH
							end,
							set = function(key, value)
								BLRCD.profileDB.cooldown.DH = value
							end,
						},		
						GS = {
							type = "toggle",
							name = "Guardian Spirit",
							order = 2,
							get = function()
								return BLRCD.profileDB.cooldown.GS
							end,
							set = function(key, value)
								BLRCD.profileDB.cooldown.GS = value
							end,
						},		
						VS = {
							type = "toggle",
							name = "Void Shift",
							order = 2,
							get = function()
								return BLRCD.profileDB.cooldown.VS
							end,
							set = function(key, value)
								BLRCD.profileDB.cooldown.VS = value
							end,
						},
						HH = {
							type = "toggle",
							name = "Hymn Of Hope",
							order = 2,
							get = function()
								return BLRCD.profileDB.cooldown.HH
							end,
							set = function(key, value)
								BLRCD.profileDB.cooldown.HH = value
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
								return BLRCD.profileDB.cooldown.T
							end,
							set = function(key, value)
								BLRCD.profileDB.cooldown.T = value
							end,
						},		
						FE = {
							type = "toggle",
							name = "Ironbark",
							order = 1,
							get = function()
								return BLRCD.profileDB.cooldown.FE
							end,
							set = function(key, value)
								BLRCD.profileDB.cooldown.FE = value
							end,
						},	
						R = {
							type = "toggle",
							name = "Rebirth",
							order = 1,
							get = function()
								return BLRCD.profileDB.cooldown.R
							end,
							set = function(key, value)
								BLRCD.profileDB.cooldown.R = value
							end,
						},	
						I = {
							type = "toggle",
							name = "Innervate",
							order = 1,
							get = function()
								return BLRCD.profileDB.cooldown.I
							end,
							set = function(key, value)
								BLRCD.profileDB.cooldown.I = value
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
								return BLRCD.profileDB.cooldown.SLT
							end,
							set = function(key, value)
								BLRCD.profileDB.cooldown.SLT = value
							end,
						},		
						MTT = {
							type = "toggle",
							name = "Mana Tide Totem",
							order = 1,
							get = function()
								return BLRCD.profileDB.cooldown.MTT
							end,
							set = function(key, value)
								BLRCD.profileDB.cooldown.MTT = value
							end,
						},		
						HTT = {
							type = "toggle",
							name = "Healing Tide Totem",
							order = 1,
							get = function()
								return BLRCD.profileDB.cooldown.HTT
							end,
							set = function(key, value)
								BLRCD.profileDB.cooldown.HTT = value
							end,
						},		
						ST = {
							type = "toggle",
							name = "Stormlash Totem",
							order = 1,
							get = function()
								return BLRCD.profileDB.cooldown.ST
							end,
							set = function(key, value)
								BLRCD.profileDB.cooldown.ST = value
							end,
						},		
						COTE = {
							type = "toggle",
							name = "Call of the Elements",
							order = 1,
							get = function()
								return BLRCD.profileDB.cooldown.COTE
							end,
							set = function(key, value)
								BLRCD.profileDB.cooldown.COTE = value
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
								return BLRCD.profileDB.cooldown.ZEN
							end,
							set = function(key, value)
								BLRCD.profileDB.cooldown.ZEN = value
							end,
						},	
						LIFE = {
							type = "toggle",
							name = "Life Cocoon",
							order = 1,
							get = function()
								return BLRCD.profileDB.cooldown.LIFE
							end,
							set = function(key, value)
								BLRCD.profileDB.cooldown.LIFE = value
							end,
						},	
						REV = {
							type = "toggle",
							name = "Revival",
							order = 1,
							get = function()
								return BLRCD.profileDB.cooldown.REV
							end,
							set = function(key, value)
								BLRCD.profileDB.cooldown.REV = value
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
								return BLRCD.profileDB.cooldown.SR
							end,
							set = function(key, value)
								BLRCD.profileDB.cooldown.SR = value
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
								return BLRCD.profileDB.cooldown.RA
							end,
							set = function(key, value)
								BLRCD.profileDB.cooldown.RA = value
							end,
						},
						AMZ = {
							type = "toggle",
							name = "Anti-Magic Zone",
							order = 1,
							get = function()
								return BLRCD.profileDB.cooldown.AMZ
							end,
							set = function(key, value)
								BLRCD.profileDB.cooldown.AMZ = value
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
								return BLRCD.profileDB.cooldown.RC
							end,
							set = function(key, value)
								BLRCD.profileDB.cooldown.RC = value
							end,
						},
						DB = {
							type = "toggle",
							name = "Demoralizing Banner",
							order = 1,
							get = function()
								return BLRCD.profileDB.cooldown.DB
							end,
							set = function(key, value)
								BLRCD.profileDB.cooldown.DB = value
							end,
						},
					},
				},
			},
		},
	},
}---------------------------------------------------