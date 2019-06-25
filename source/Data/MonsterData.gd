extends Node

# Map type => variation type => monsters => data
const MONSTER_DATA = {
	"Forest": {
		"Slime": {
			"Gold Slime": {
				"type": "Gold Slime",
				"weight": 70,
				"health": 70,
				"strength": 25,
				"defense": 17,
				"turns": 1,
				"experience points": 14,
				
				"skill_probability": 40, # 40 = 40%
				"skills": {
					"chomp": 100
				}
			},
			"Vampire Bat": {
				"type": "Vampire Bat",
				"weight": 30,
				"health": 85,
				"strength": 23,
				"defense": 14,
				"turns": 1,
				"experience points": 11,
				"vampire multiplier": 1.1, # normal is 1.5
				
				"skill_probability": 50,
				"skills": {
					"vampire": 100 
				}
			} 
		},
		"Frost": {
			"Howler": {
				"type": "Howler",
				"weight": 30,
				"health": 90,
				"strength": 28,
				"defense": 16,
				"turns": 2,
				"experience points": 17,
				
				"skill_probability": 40, # 40 = 40%
				"skills": {
					"roar": 100
				},
				# Override skill messages with custom values
				"skill_messages": {
					"roar": "howls! Attack up by {amount}!"
				}
			},
			"Ice Terrapin": {
				"type": "Ice Terrapin",
				"weight": 60,
				"health": 65,
				"strength": 20,
				"defense": 20,
				"turns": 2,
				"experience points": 13,
				
				"skill_probability": 50, # 40 = 40%
				"skills": {
					"freeze": 100
				}
			}
		},
		"Death": {
			"Toxitail": {
				"type": "Toxitail",
				"weight": 60,
				"health": 80,
				"strength": 23,
				"defense": 20,
				"turns": 1,
				"experience points": 17,
				
				"skill_probability": 50, # 40 = 40%
				"skills": {
					"poison": 50,
					"chomp": 50
				},
				"skill_messages": {
					"chomp": "pierces you with its fangs! {damage} damage!"
				}
			},
			"Skelly": {
				"type": "Skelly",
				"weight": 40,
				"health": 110,
				"strength": 28,
				"defense": 16,
				"turns": 1,
				"experience points": 20,
				
				"skill_probability": 40,
				"skills": {
					"heal": 100
				},
				"skill_messages": {
					"heal": "regenerates its bones! Healed {amount} health!"
				}
			}
		}
	},
	"Cave": {
		"River": {
			"Clawomatic": {
				"type": "Clawomatic",
				"weight": 50,
				"health": 150,
				"strength": 30,
				"defense": 10,
				"turns": 1,
				"experience points": 18,
				
				"skill_probability": 50, # 40 = 40%
				"skills": {
					"harden": 100 
				}
			},
			"WingBeak": {
				"type": "WingBeak",
				"weight": 50,
				"health": 110,
				"strength": 20,
				"defense": 16,
				"turns": 2,
				"experience points": 16,
				
				"skill_probability": 50, # 40 = 40%
				"skills": {
					"roar": 100 
				}
			}
		},
		"Lava": {
			"Flame Tail": {
				"type": "Flame Tail",
				"weight": 60,
				"health": 110,
				"strength": 35,
				"defense": 10,
				"turns": 1,
				"experience points": 13,
				
				"skill_probability": 30, # 40 = 40%
				"skills": {
					"poison": 100 
				}
			},
			"Red Scorpion": {
				"type": "Red Scorpion",
				"weight": 40,
				"health": 80,
				"strength": 25,
				"defense": 17,
				"turns": 1,
				"experience points": 13,
				
				"skill_probability": 25,
				"skills": {
					"armour break": 100
				}
			}
		}
	},
	"Dungeon": {
		"Castle": {
			"Foot Soldier": {
				"type": "Foot Soldier",
				"weight": 70,
				"health": 120,
				"strength": 30,
				"defense": 14,
				"turns": 1,
				"experience points": 17,
				
				"skill_probability": 65, # 40 = 40%
				"skills": {
					"chomp": 100,
				},
				"skill_messages": {
					"chomp": "bashes you with his shield! {damage} damage!"
				}
			},
			"Antipode Mage": {
				"type": "Antipode Mage",
				"weight": 30,
				"health": 110,
				"strength": 20,
				"defense": 15,
				"turns": 1,
				"experience points": 18,
				
				"skill_probability": 100,
				"skills": {
					"chomp": 50,
					"freeze": 50
				},
				"skill_messages": {
					"chomp": "hurls a fireball at you! {damage} damage!"
				}
			}
		},
		"Desert": {
			"Scarab": {
				"type": "Scarab",
				"weight": 50,
				"health": 110,
				"strength": 21,
				"defense": 15,
				"turns": 1,
				"experience points": 16,
				
				"skill_probability": 80,
				"skills": {
					"harden": 40,
					"chomp": 60
				}
			},
			"Cactrot": {
				"type": "Cactrot",
				"weight": 50,
				"health": 110,
				"strength": 24,
				"defense": 13,
				"turns": 1,
				"experience points": 20,
				
				"skill_probability": 50,
				"skills": {
					"chomp": 100,
				},
				"skill_messages": {
					"chomp": "stabs you with a hundred needles! {damage} damage!"
				}
			}
		}
	}
}