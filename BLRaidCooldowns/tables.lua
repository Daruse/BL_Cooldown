--[[LibRaidInspectMembers ={['GUID'] = {
													['name']    = Character Name,
													['class']   = Character Class,
													['race']    = Character Race,
													['realm']   = Character Realm,
													['guid'] 	= Character GUID,
													['spec']    = Character Specialization,
													['talents'] = {
																	 ['1'] = Talent 1,
																	 ['2'] = Talent 2,
																	 ['3'] = Talent 3,
																	 ['4'] = Talent 4,
																	 ['5'] = Talent 5,
																	 ['6'] = Talent 6,
																	}
													['glyphs'] = {
																	 ['1'] = Glyph 1,
																	 ['2'] = Glyph 2,
																	 ['3'] = Glyph 3,
																	 ['4'] = Glyph 4,
																	 ['5'] = Glyph 5,
																	 ['6'] = Glyph 6,
																	}
													},
									}

--[[BLRCD = {{['handles'] = {
									['guid'] = {
														['spellId'] = {
																			['args']	= {cooldown,guid,frame,text,bar,caster,spellId},
																			['handle'] 	= {table returned from ScheduleTimer},
																			['bar'] 	= {returned from CreatBar},
																		},
												},
							}
			},
			{['cooldownRoster'] = {
									['spellId'] = {
														[name] = Toon's name,
													},
								},
			{['curr'] = {
									['spellId'] = {
														[guid] = GUID of toon who is on cooldown,
													},
						},