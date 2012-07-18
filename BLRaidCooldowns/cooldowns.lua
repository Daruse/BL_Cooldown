--------------------------------------------------------
-- Blood Legion Raidcooldowns - Cooldowns --
--------------------------------------------------------
local BLRCD = BLRCD

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
		name = "HOS",
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
		talents = 5,
	},
	{ -- Stormlash Totem
		spellID = 120668,
		succ = "SPELL_CAST_SUCCESS",
		name = "ST",
		CD = 300,
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