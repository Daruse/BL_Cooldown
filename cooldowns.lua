--------------------------------------------------------
-- Blood Legion Cooldown - Cooldowns --
--------------------------------------------------------
if not BLCD then return end
local BLCD = BLCD

BLCD.cooldowns = {
-- Paladin
	{ -- Devotion Aura
		spellID = 31821,
		name = "DA",
		succ = "SPELL_CAST_SUCCESS",
		CD = 180,
		cast = 6,
		class = "PALADIN",
	},
	{ -- Hand of Sacrifice
		spellID = 6940,
		name = "HOS",
		succ = "SPELL_CAST_SUCCESS",
		CD = 120,
		cast = 12,
		class = "PALADIN",
	},
-- Priest
	{ -- Power Word: Barrier 
		spellID = 62618,
		name = "PWB",
		succ = "SPELL_CAST_SUCCESS",
		CD = 180,
		cast = 10,
		class = "PRIEST",
		spec = 256,
	},
	{ -- Pain Suppression  
		spellID = 33206,
		name = "PS",
		succ = "SPELL_CAST_SUCCESS",
		CD = 180,
		cast = 8,
		class = "PRIEST", 
		spec = 256,
	},
	{ -- Divine Hymn
		spellID = 64843,
		name = "DH",
		succ = "SPELL_CAST_SUCCESS",
		CD = 180, 
		cast = 8,
		class = "PRIEST",
		spec = 257,
	},	
	{ -- Guardian Spirit 
		spellID = 47788,
		succ = "SPELL_CAST_SUCCESS",
		name = "GS",
		CD = 180,
		cast = 10,
		class = "PRIEST", 
		spec = 257,
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
		cast = 8,
		class = "PRIEST",
	},
-- Druid
	{ -- Tranquility
		spellID = 740,
		succ = "SPELL_CAST_SUCCESS",
		name = "T",
		CD = 480,
		cast = 8,
		class = "DRUID",
	},
	{ -- Ironbark
		spellID = 102342,
		succ = "SPELL_CAST_SUCCESS",
		name = "FE",
		CD = 120,
		cast = 8,
		class = "DRUID",
		spec = 105,
	},
	{ -- Rebirth
		spellID = 20484,
		succ = "SPELL_RESURRECT",
		name = "R",
		CD = 600,
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
		cast = 6,
		class = "SHAMAN", 
		spec = 264,
	},
	{ -- Mana Tide Totem
		spellID = 16190,
		succ = "SPELL_CAST_SUCCESS",
		name = "MTT",
		CD = 180,
		cast = 12,
		class = "SHAMAN",
		spec = 264,
	},
	{ -- Healing Tide Totem
		spellID = 108280,
		succ = "SPELL_CAST_SUCCESS",
		name = "HTT",
		CD = 180,
		class = "SHAMAN",
		talent = 5,
	},
	{ -- Stormlash Totem
		spellID = 120668,
		succ = "SPELL_CAST_SUCCESS",
		name = "ST",
		CD = 300,
		cast = 10,
		class = "SHAMAN",
	},
 -- Monk
	{	-- Zen Meditation
		spellID = 115176,
		succ = "SPELL_CAST_SUCCESS",
		name = "ZEN",
		CD = 180,
		cast = 8,
		class = "MONK",
	},
	{	-- Life Cocoon
		spellID = 116849,
		succ = "SPELL_CAST_SUCCESS",
		name = "LIFE",
		CD = 120,
		cast = 12,
		class = "MONK",
		spec = 270,
	},
	{	-- Revival
		spellID = 115310,
		succ = "SPELL_CAST_SUCCESS",
		name = "REV",
		CD = 180,
		class = "MONK",
		spec = 270,
	},
-- Warlock
	{ -- Soulstone Resurrection
		spellID = 95750,
		succ = "SPELL_RESURRECT",
		name = "SR",
		CD = 600,
		class = "WARLOCK",
	},
-- Death Knight
	{ -- Raise Ally
		spellID = 61999,
		succ = "SPELL_RESURRECT", 
		name = "RA",
		CD = 600,
		class = "DEATHKNIGHT",
	},
	{ -- Anti-Magic Zone
		spellID = 51052,
		succ = "SPELL_CAST_SUCCESS",
		name = "AMZ",
		CD = 120,
		cast = 10,
		class = "DEATHKNIGHT",
		talent = 2,
	},
-- Warrior
	{ -- Rallying Cry
		spellID = 97462,
		succ = "SPELL_CAST_SUCCESS",
		name = "RC",
		CD = 180,
		cast = 10,
		class = "WARRIOR",
	},
	{ -- Demoralizing Banner
		spellID = 114203,
		succ = "SPELL_CAST_SUCCESS",
		name = "DB",
		CD = 180,
		cast = 15,
		class = "WARRIOR",
	},
	{ -- Skull Banner
		spellID = 114207,
		succ = "SPELL_CAST_SUCCESS",
		name = "SB",
		CD = 180,
		cast = 10,
		class = "WARRIOR",
	},
}
--------------------------------------------------------

BLCD.cooldownReduction = {
	["T"] = { -- Tranquility
				spellID = 740,
				CD = 180,
				spec = 105,
			},
}