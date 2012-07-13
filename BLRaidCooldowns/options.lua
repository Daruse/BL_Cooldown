--------------------------------------------------------
-- Blood Legion Raidcooldowns - Options --
--------------------------------------------------------
local BLRCD = BLRCD

BLRCD.TexCoords = {.08, .92, .08, .92}

BLRCD.defaults = {
	profile = {
		enable=true,
	}
}

BLRCD.options =  {
    name = "Blood Legion Raid Cooldowns",
    handler = BLRCD,
    type = 'group',
    args = {
        enable = {
					type="toggle",
					name="Enable",
					desc="Enable",
					order=1,
			},
    },
}
--------------------------------------------------------