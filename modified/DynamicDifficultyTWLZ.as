final class Diffy {

	private array<double> diffPerPeep = {
			0.700, //0
			0.750, //1
			0.800, //2
			0.815, //3
			0.830, //4
			0.840, //5
			0.850, //6
			0.860, //7
			0.870, //8
			0.880, //9
			0.890, //10
			0.900, //11
			0.910, //12
			0.920, //13
			0.930, //14
			0.940, //15
			0.950, //16
			0.960, //17
			0.970, //18
			0.980, //19
			0.990, //20
			0.991, //21
			0.992, //22
			0.993, //23
			0.994, //24
			0.995, //25
			0.996, //26
			0.997, //27
			0.998, //28
			0.999, //29
			0.999, //30
			0.999, //31
			0.999  //32
			// see m_gaussDiff for gaussjumping
	};
	
	/**
	*	Skill-Names
	*/
	private array<string> sk_names = {
			"sk_agrunt_health",
			"sk_agrunt_dmg_punch",
			"sk_agrunt_melee_engage_distance",
			"sk_agrunt_berserker_dmg_punch",
			"sk_apache_health",
			"sk_barnacle_health",
			"sk_barnacle_bite",
			"sk_barney_health",
			"sk_bullsquid_health",
			"sk_bullsquid_dmg_bite",
			"sk_bullsquid_dmg_whip",
			"sk_bullsquid_dmg_spit",
			"sk_bigmomma_health_factor",
			"sk_bigmomma_dmg_slash",
			"sk_bigmomma_dmg_blast",
			"sk_bigmomma_radius_blast",
			"sk_gargantua_health",
			"sk_gargantua_dmg_slash",
			"sk_gargantua_dmg_fire",
			"sk_gargantua_dmg_stomp",
			"sk_hassassin_health",
			"sk_headcrab_health",
			"sk_headcrab_dmg_bite",
			"sk_hgrunt_health",
			"sk_hgrunt_kick",
			"sk_hgrunt_pellets",
			"sk_hgrunt_gspeed",
			"sk_houndeye_health",
			"sk_houndeye_dmg_blast",
			"sk_islave_health",
			"sk_islave_dmg_claw",
			"sk_islave_dmg_clawrake",
			"sk_islave_dmg_zap",
			"sk_ichthyosaur_health",
			"sk_ichthyosaur_shake",
			"sk_leech_health",
			"sk_leech_dmg_bite",
			"sk_controller_health",
			"sk_controller_dmgzap",
			"sk_controller_speedball",
			"sk_controller_dmgball",
			"sk_nihilanth_health",
			"sk_nihilanth_zap",
			"sk_scientist_health",
			"sk_snark_health",
			"sk_snark_dmg_bite",
			"sk_snark_dmg_pop",
			"sk_zombie_health",
			"sk_zombie_dmg_one_slash",
			"sk_zombie_dmg_both_slash",
			"sk_turret_health",
			"sk_miniturret_health",
			"sk_sentry_health",
			"sk_plr_crowbar",
			"sk_plr_9mm_bullet",
			"sk_plr_357_bullet",
			"sk_plr_9mmAR_bullet",
			"sk_plr_9mmAR_grenade",
			"sk_plr_buckshot",
			"sk_plr_xbow_bolt_monster",
			"sk_plr_rpg",
			"sk_plr_gauss",
			"sk_plr_egon_narrow",
			"sk_plr_egon_wide",
			"sk_plr_hand_grenade",
			"sk_plr_satchel",
			"sk_plr_tripmine",
			"sk_12mm_bullet",
			"sk_9mmAR_bullet",
			"sk_9mm_bullet",
			"sk_hornet_dmg",
			"sk_suitcharger",
			"sk_battery",
			"sk_healthcharger",
			"sk_healthkit",
			"sk_scientist_heal",
			"sk_monster_head",
			"sk_monster_chest",
			"sk_monster_stomach",
			"sk_monster_arm",
			"sk_monster_leg",
			"sk_player_head",
			"sk_player_chest",
			"sk_player_stomach",
			"sk_player_arm",
			"sk_player_leg",
			"sk_grunt_buckshot",
			"sk_babygargantua_health",
			"sk_babygargantua_dmg_slash",
			"sk_babygargantua_dmg_fire",
			"sk_babygargantua_dmg_stomp",
			"sk_hwgrunt_health",
			"sk_hwgrunt_minipellets",
			"sk_rgrunt_explode",
			"sk_massassin_sniper",
			"sk_otis_health",
			"sk_otis_bullet",
			"sk_zombie_barney_health",
			"sk_zombie_barney_dmg_one_slash",
			"sk_zombie_barney_dmg_both_slash",
			"sk_zombie_soldier_health",
			"sk_zombie_soldier_dmg_one_slash",
			"sk_zombie_soldier_dmg_both_slash",
			"sk_gonome_health",
			"sk_gonome_dmg_one_slash",
			"sk_gonome_dmg_guts",
			"sk_gonome_dmg_one_bite",
			"sk_pitdrone_health",
			"sk_pitdrone_dmg_bite",
			"sk_pitdrone_dmg_whip",
			"sk_pitdrone_dmg_spit",
			"sk_shocktrooper_health",
			"sk_shocktrooper_kick",
			"sk_shocktrooper_maxcharge",
			"sk_tor_health",
			"sk_tor_punch",
			"sk_tor_energybeam",
			"sk_tor_sonicblast",
			"sk_voltigore_health",
			"sk_voltigore_dmg_punch",
			"sk_voltigore_dmg_beam",
			"sk_voltigore_dmg_explode",
			"sk_tentacle",
			"sk_blkopsosprey",
			"sk_osprey",
			"sk_stukabat",
			"sk_sqknest_health",
			"sk_kingpin_health",
			"sk_kingpin_lightning",
			"sk_kingpin_tele_blast",
			"sk_kingpin_plasma_blast",
			"sk_kingpin_melee",
			"sk_kingpin_telefrag",
			"sk_plr_HpMedic",
			"sk_plr_wrench",
			"sk_plr_grapple",
			"sk_plr_uzi",
			"sk_556_bullet",
			"sk_plr_secondarygauss",
			"sk_hornet_pdmg",
			"sk_plr_762_bullet",
			"sk_plr_spore",
			"sk_plr_shockrifle",
			"sk_plr_shockrifle_beam",
			"sk_shockroach_dmg_xpl_touch",
			"sk_shockroach_dmg_xpl_splash",
			"sk_plr_displacer_other",
			"sk_plr_displacer_radius"
	};
	
	/**
	*	Skill-Borders
	*/
	private array<double> diffBorders = {
			0.0, 0.1, 0.3, 0.5, 0.7, 0.9, 1.0
	};
	
	private array<double> playerMaxHealth = {
			10000.0, 200.0, 100.0, 100.0, 100.0, 100.0, 1.0, 1.0
	};
	
	private array<double> playerMaxArmor = {
			10000.0, 200.0, 100.0, 100.0, 100.0, 100.0, 1.0, 0.0
	};
	
	private array<double> playerRegenerateHealth = { // per Second
			1000.0, 10.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
	};
	
	private array<double> playerRegenerateArmor = { // per Second
			1000.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
	};
	
	/**
	*	Skill-Data
	*/
	private array<array<double>> skillMatrix = {
			{ 6.0, 30.0, 60.0, 100.0, 150.0, 225.0, 300.0, 300.0 }, // sk_agrunt_health 0
			{ 1.0, 5.0, 10.0, 20.0, 20.0, 100.0, 2000.0, 2000.0 }, // sk_agrunt_dmg_punch 1
			{ 128.0, 192.0, 224.0, 256.0, 256.0, 256.0, 256.0, 256.0 }, // sk_agrunt_melee_engage_distance 2
			{ 2.0, 10.0, 20.0, 30.0, 40.0, 200.0, 4000.0, 4000.0 }, // sk_agrunt_berserker_dmg_punch 3
			{ 15.0, 75.0, 150.0, 300.0, 500.0, 750.0, 1000.0, 1000.0 }, // sk_apache_health 4
			{ 2.0, 15.0, 30.0, 40.0, 50.0, 75.0, 100.0, 100.0 }, // sk_barnacle_health 5
			{ 8.0, 8.0, 8.0, 8.0, 10.0, 50.0, 1000.0, 1000.0 }, // sk_barnacle_bite 6
			{ 65.0, 65.0, 65.0, 65.0, 65.0, 65.0, 65.0, 1.0 }, // sk_barney_health 7
			{ 4.0, 20.0, 40.0, 80.0, 120.0, 180.0, 240.0, 240.0 }, // sk_bullsquid_health 8
			{ 1.5, 7.5, 15.0, 25.0, 25.0, 125.0, 2500.0, 2500.0 }, // sk_bullsquid_dmg_bite 9
			{ 2.5, 12.5, 25.0, 35.0, 45.0, 225.0, 4500.0, 4500.0 }, // sk_bullsquid_dmg_whip 10
			{ 1.0, 5.0, 10.0, 10.0, 15.0, 75.0, 1500.0, 1500.0 }, // sk_bullsquid_dmg_spit 11
			{ 0.1, 0.3, 0.5, 0.75, 1.0, 1.0, 1.0, 1.0 }, // sk_bigmomma_health_factor 12
			{ 5.0, 25.0, 50.0, 60.0, 70.0, 350.0, 7000.0, 7000.0 }, // sk_bigmomma_dmg_slash 13
			{ 10.0, 50.0, 100.0, 120.0, 160.0, 240.0, 16000.0, 16000.0 }, // sk_bigmomma_dmg_blast 14
			{ 100.0, 200.0, 250.0, 250.0, 275.0, 300.0, 500.0, 5000.0 }, // sk_bigmomma_radius_blast 15
			{ 80.0, 400.0, 800.0, 800.0, 1000.0, 1500.0, 2000.0, 2500.0 }, // sk_gargantua_health 16
			{ 1.0, 5.0, 10.0, 30.0, 50.0, 250.0, 5000.0, 5000.0 }, // sk_gargantua_dmg_slash 17
			{ 0.3, 1.5, 3.0, 4.0, 5.0, 25.0, 500.0, 5000.0 }, // sk_gargantua_dmg_fire 18
			{ 5.0, 25.0, 50.0, 100.0, 100.0, 500.0, 10000.0, 10000.0 }, // sk_gargantua_dmg_stomp 19
			{ 3.0, 15.0, 30.0, 50.0, 50.0, 75.0, 100.0, 100.0 }, // sk_hassassin_health 20
			{ 1.0, 5.0, 10.0, 10.0, 20.0, 30.0, 40.0, 50.0 }, // sk_headcrab_health 21
			{ 0.5, 2.5, 5.0, 10.0, 10.0, 50.0, 75.0, 2500.0 }, // sk_headcrab_dmg_bite 22
			{ 5.0, 25.0, 50.0, 50.0, 100.0, 150.0, 200.0, 200.0 }, // sk_hgrunt_health 23
			{ 0.5, 2.5, 5.0, 10.0, 12.0, 60.0, 1200.0, 1200.0 }, // sk_hgrunt_kick 24
			{ 1.0, 2.0, 3.0, 5.0, 7.0, 15.0, 20.0, 25.0 }, // sk_hgrunt_pellets 25
			{ 100.0, 200.0, 400.0, 600.0, 800.0, 1200.0, 1600.0, 2000.0 }, // sk_hgrunt_gspeed 26
			{ 2.0, 10.0, 20.0, 30.0, 60.0, 90.0, 120.0 , 120.0 }, // sk_houndeye_health 27
			{ 1.0, 5.0, 10.0, 13.0, 15.0, 75.0, 1500.0, 10000.0 }, // sk_houndeye_dmg_blast 28
			{ 3.0, 15.0, 30.0, 60.0, 80.0, 120.0, 160.0, 160.0 }, // sk_islave_health 29
			{ 0.8, 4.0, 8.0, 9.0, 10.0, 50.0, 1000.0, 1000.0 }, // sk_islave_dmg_claw 30
			{ 2.4, 12.0, 24.0, 25.0, 25.0, 125.0, 2500.0, 2500.0 }, // sk_islave_dmg_clawrake 31
			{ 1.0, 5.0, 10.0, 12.0, 15.0, 75.0, 1500.0, 1500.0 }, // sk_islave_dmg_zap 32
			{ 1.0, 5.0, 10.0, 50.0, 100.0, 250.0, 400.0, 500.0 }, // sk_ichthyosaur_health 33
			{ 2.0, 10.0, 20.0, 35.0, 50.0, 250.0, 5000.0, 5000.0 }, // sk_ichthyosaur_shake 34
			{ 1.0, 1.0, 2.0, 2.0, 3.0, 4.0, 5.0, 10.0 }, // sk_leech_health 35
			{ 0.2, 1.0, 2.0, 3.0, 5.0, 25.0, 500.0, 5000.0 }, // sk_leech_dmg_bite 36
			{ 6.0, 30.0, 60.0, 80.0, 100.0, 150.0, 200.0, 200.0 }, // sk_controller_health 37
			{ 1.5, 7.5, 15.0, 25.0, 35.0, 175.0, 3500.0, 3500.0 }, // sk_controller_dmgzap 38
			{ 150.0, 450.0, 650.0, 800.0, 1000.0, 1000.0, 1000.0, 2000.0 }, // sk_controller_speedball 39
			{ 0.3, 1.5, 3.0, 4.0, 5.0, 25.0, 500.0, 5000.0 }, // sk_controller_dmgball 40
			{ 800.0, 800.0, 800.0, 900.0, 1000.0, 1000.0, 1000.0, 1000.0 }, // sk_nihilanth_health 41
			{ 3.0, 15.0, 30.0, 40.0, 50.0, 250.0, 5000.0, 5000.0 }, // sk_nihilanth_zap 42
			{ 50.0, 50.0, 50.0, 50.0, 50.0, 50.0, 50.0, 1.0 }, // sk_scientist_health 43
			{ 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0 }, // sk_snark_health 44
			{ 0.5, 2.5, 5.0, 10.0, 10.0, 50.0, 75.0, 10.0 }, // sk_snark_dmg_bite 45
			{ 0.5, 2.5, 5.0, 5.0, 5.0, 10.0, 50.0, 10.0 }, // sk_snark_dmg_pop 46
			{ 5.0, 25.0, 50.0, 60.0, 100.0, 150.0, 200.0, 250.0 }, // sk_zombie_health 47
			{ 1.0, 5.0, 10.0, 20.0, 25.0, 125.0, 2500.0, 2500.0 }, // sk_zombie_dmg_one_slash 48
			{ 2.5, 12.5, 25.0, 40.0, 40.0, 200.0, 4000.0, 4000.0 }, // sk_zombie_dmg_both_slash 49
			{ 5.0, 25.0, 50.0, 100.0, 200.0, 300.0, 400.0, 400.0 }, // sk_turret_health 50
			{ 4.0, 20.0, 40.0, 50.0, 80.0, 120.0, 160.0, 160.0 }, // sk_miniturret_health 51
			{ 4.0, 20.0, 40.0, 50.0, 80.0, 120.0, 160.0, 160.0 }, // sk_sentry_health 52
			{ 150.0, 30.0, 15.0, 15.0, 15.0, 15.0, 15.0, 15.0 }, // sk_plr_crowbar 53
			{ 120.0, 24.0, 12.0, 12.0, 12.0, 12.0, 12.0, 12.0 }, // sk_plr_9mm_bullet 54
			{ 500.0, 100.0, 50.0, 50.0, 50.0, 50.0, 50.0, 50.0 }, // sk_plr_357_bullet 55
			{ 80.0, 16.0, 8.0, 8.0, 8.0, 8.0, 8.0, 8.0 }, // sk_plr_9mmAR_bullet 56
			{ 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0 }, // sk_plr_9mmAR_grenade 57
			{ 90.0, 18.0, 9.0, 9.0, 9.0, 9.0, 9.0, 9.0 }, // sk_plr_buckshot 58
			{ 750.0, 150.0, 75.0, 75.0, 75.0, 75.0, 75.0, 75.0 }, // sk_plr_xbow_bolt_monster 59
			{ 150.0, 150.0, 150.0, 150.0, 150.0, 150.0, 150.0, 150.0 }, // sk_plr_rpg 60
			{ 190.0, 38.0, 19.0, 19.0, 19.0, 19.0, 19.0, 19.0 }, // sk_plr_gauss 61
			{ 10.0, 7.5, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0 }, // sk_plr_egon_narrow 62
			{ 24.0, 18.0, 12.0, 12.0, 12.0, 12.0, 12.0, 12.0 }, // sk_plr_egon_wide 63
			{ 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0 }, // sk_plr_hand_grenade 64
			{ 160.0, 160.0, 160.0, 160.0, 160.0, 160.0, 160.0, 160.0 }, // sk_plr_satchel 65
			{ 150.0, 150.0, 150.0, 150.0, 150.0, 150.0, 150.0, 150.0 }, // sk_plr_tripmine 66
			{ 1.0, 5.0, 10.0, 12.0, 15.0, 75.0, 1500.0, 12.0 }, // sk_12mm_bullet 67
			{ 0.3, 1.5, 3.0, 4.0, 6.0, 30.0, 600.0, 4.0 }, // sk_9mmAR_bullet 68
			{ 0.5, 2.5, 5.0, 6.0, 9.0, 45.0, 900.0, 6.0 }, // sk_9mm_bullet 69
			{ 0.5, 2.5, 4.0, 7.0, 10.0, 50.0, 75.0, 7.0 }, // sk_hornet_dmg 70
			{ 10000.0, 10000.0, 10000.0, 1000.0, 100.0, 10.0, 1.0, 0.0 }, // sk_suitcharger 71
			{ 100.0, 100.0, 50.0, 25.0, 15.0, 10.0, 1.0, 0.0 }, // sk_battery 72
			{ 10000.0, 10000.0, 10000.0, 10000.0, 1000.0, 100.0, 1.0, 0.0 }, // sk_healthcharger 73
			{ 100.0, 100.0, 100.0, 25.0, 15.0, 10.0, 1.0, 0.0 }, // sk_healthkit 74
			{ 100.0, 100.0, 100.0, 100.0, 50.0, 10.0, 1.0, -1000.0 }, // sk_scientist_heal 75
			{ 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0 }, // sk_monster_head 76
			{ 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0 }, // sk_monster_chest 77
			{ 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0 }, // sk_monster_stomach 78
			{ 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0 }, // sk_monster_arm 79
			{ 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0 }, // sk_monster_leg 80
			{ 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0 }, // sk_player_head 81
			{ 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0 }, // sk_player_chest 82
			{ 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0 }, // sk_player_stomach 83
			{ 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0 }, // sk_player_arm 84
			{ 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0 }, // sk_player_leg 85
			{ 0.5, 2.5, 5.0, 6.0, 8.0, 40.0, 800.0, 50000.0 }, // sk_grunt_buckshot 86
			{ 40.0, 200.0, 400.0, 600.0, 800.0, 1200.0, 1600.0, 2000.0 }, // sk_babygargantua_health 87
			{ 1.5, 7.5, 15.0, 25.0, 35.0, 175.0, 3500.0, 10000.0 }, // sk_babygargantua_dmg_slash 88
			{ 0.15, 0.75, 1.5, 2.0, 3.0, 15.0, 300.0, 3000.0 }, // sk_babygargantua_dmg_fire 89
			{ 2.5, 12.5, 25.0, 50.0, 60.0, 300.0, 6000.0, 10000.0 }, // sk_babygargantua_dmg_stomp 90
			{ 15.0, 75.0, 150.0, 200.0, 250.0, 375.0, 500.0, 500.0 }, // sk_hwgrunt_health 91
			{ 0.08, 0.4, 0.8, 1.0, 1.2, 3.0, 4.0, 5.0 }, // sk_hwgrunt_minipellets
			{ 8.0, 40.0, 80.0, 100.0, 125.0, 150.0, 200.0 , 12500.0 }, // sk_rgrunt_explode 93
			{ 2.5, 12.5, 25.0, 40.0, 50.0, 250.0, 5000.0, 50000.0 }, // sk_massassin_sniper 94
			{ 65.0, 65.0, 65.0, 65.0, 65.0, 75.0, 80.0, 100.0 }, // sk_otis_health 95
			{ 2.0, 10.0, 20.0, 34.0, 50.0, 250.0, 5000.0, 50.0 }, // sk_otis_bullet 96
			{ 5.0, 25.0, 50.0, 60.0, 110.0, 165.0, 220.0, 250.0 }, // sk_zombie_barney_health 97
			{ 1.0, 5.0, 10.0, 20.0, 25.0, 125.0, 2500.0, 2500.0 }, // sk_zombie_barney_dmg_one_slash 98
			{ 2.5, 12.5, 25.0, 35.0, 40.0, 200.0, 4000.0, 4000.0 }, // sk_zombie_barney_dmg_both_slash 99
			{ 6.0, 30.0, 60.0, 90.0, 150.0, 225.0, 300.0, 300.0 }, // sk_zombie_soldier_health 100
			{ 1.0, 5.0, 10.0, 20.0, 40.0, 200.0, 4000.0, 4000.0 }, // sk_zombie_soldier_dmg_one_slash 101
			{ 2.5, 12.5, 25.0, 40.0, 55.0, 275.0, 5500.0, 5500.0 }, // sk_zombie_soldier_dmg_both_slash 102
			{ 8.5, 42.5, 85.0, 125.0, 200.0, 300.0, 400.0, 400.0 }, // sk_gonome_health 103
			{ 1.0, 5.0, 10.0, 20.0, 30.0, 150.0, 3000.0, 3000.0 }, // sk_gonome_dmg_one_slash 104
			{ 1.0, 5.0, 10.0, 10.0, 15.0, 75.0, 1500.0, 1500.0 }, // sk_gonome_dmg_guts 105
			{ 0.7, 3.5, 7.0, 14.0, 15.0, 75.0, 1500.0, 1500.0 }, // sk_gonome_dmg_one_bite 106
			{ 4.0, 20.0, 40.0, 60.0, 110.0, 165.0, 220.0, 220.0 }, // sk_pitdrone_health 107
			{ 1.5, 7.5, 15.0, 20.0, 25.0, 125.0, 2500.0, 2500.0 }, // sk_pitdrone_dmg_bite 108
			{ 2.5, 12.5, 25.0, 30.0, 35.0, 175.0, 3500.0, 3500.0 }, // sk_pitdrone_dmg_whip 109
			{ 1.0, 5.0, 10.0, 12.5, 15.0, 75.0, 1000.0, 1000.0 }, // sk_pitdrone_dmg_spit 110
			{ 5.0, 25.0, 50.0, 80.0, 200.0, 300.0, 400.0, 400.0 }, // sk_shocktrooper_health 111
			{ 0.5, 2.5, 5.0, 10.0, 12.0, 60.0, 1200.0, 1200.0 }, // sk_shocktrooper_kick 112
			{ 0.8, 4.0, 8.0, 8.0, 10.0, 50.0, 1000.0, 1000.0 }, // sk_shocktrooper_maxcharge 113
			{ 60.0, 300.0, 600.0, 800.0, 1000.0, 1500.0, 2000.0, 2000.0 }, // sk_tor_health 114
			{ 4.0, 20.0, 40.0, 55.0, 75.0, 315.0, 7500.0, 7500.0 }, // sk_tor_punch 115
			{ 0.2, 1.0, 2.0, 3.0, 5.0, 25.0, 500.0, 5000.0 }, // sk_tor_energybeam 116
			{ 1.0, 5.0, 10.0, 15.0, 25.0, 125.0, 2500.0, 2500.0 }, // sk_tor_sonicblast 117
			{ 16.0, 160.0, 320.0, 350.0, 450.0, 675.0, 900.0, 900.0 }, // sk_voltigore_health 118
			{ 3.0, 15.0, 30.0, 40.0, 50.0, 250.0, 5000.0, 5000.0 }, // sk_voltigore_dmg_punch 119
			{ 4.0, 20.0, 40.0, 50.0, 60.0, 300.0, 6000.0, 6000.0 }, // sk_voltigore_dmg_beam 120
			{ 15.0, 75.0, 150.0, 200.0, 250.0, 500.0, 1000.0, 25000.0 }, // sk_voltigore_dmg_explode 121
			{ 50.0, 250.0, 500.0, 750.0, 900.0, 1350.0, 1800.0, 100000.0 }, // sk_tentacle 122
			{ 45.0, 225.0, 450.0, 600.0, 750.0, 1125.0, 1500.0, 2000.0 }, // sk_blkopsosprey 123
			{ 45.0, 225.0, 450.0, 600.0, 750.0, 1125.0, 1500.0, 2000.0 }, // sk_osprey 124
			{ 10.0, 50.0, 100.0, 123.0, 150.0, 225.0, 300.0, 400.0 }, // sk_stukabat 125
			{ 3.0, 15.0, 30.0, 50.0, 100.0, 150.0, 200.0, 300.0 }, // sk_sqknest_health 126
			{ 30.0, 150.0, 300.0, 450.0, 600.0, 900.0, 1200.0, 1200.0 }, // sk_kingpin_health 127
			{ 2.0, 10.0, 20.0, 25.0, 40.0, 200.0, 4000.0, 4000.0 }, // sk_kingpin_lightning 128
			{ 1.0, 5.0, 10.0, 15.0, 25.0, 125.0, 2500.0, 2500.0 }, // sk_kingpin_tele_blast 129
			{ 6.0, 30.0, 60.0, 80.0, 100.0, 500.0, 10000.0, 10000.0 }, // sk_kingpin_plasma_blast 130
			{ 3.0, 15.0, 30.0, 40.0, 50.0, 250.0, 5000.0, 5000.0 }, // sk_kingpin_melee 131
			{ 30.0, 150.0, 300.0, 500.0, 1000.0, 5000.0, 100000.0, 100000.0 }, // sk_kingpin_telefrag 132
			{ 10.0, 10.0, 10.0, 10.0, 10.0, 10.0, 10.0, 10.0 }, // sk_plr_HpMedic 133
			{ 220.0, 44.0, 22.0, 22.0, 22.0, 22.0, 22.0, 22.0 }, // sk_plr_wrench 134
			{ 400.0, 80.0, 40.0, 40.0, 40.0, 40.0, 40.0, 40.0 }, // sk_plr_grapple 135
			{ 100.0, 20.0, 10.0, 10.0, 10.0, 10.0, 10.0, 10.0 }, // sk_plr_uzi 136
			{ 15.0, 15.0, 15.0, 15.0, 15.0, 15.0, 15.0, 15.0 }, // sk_556_bullet 137
			{ 1900.0, 380.0, 190.0, 190.0, 190.0, 190.0, 190.0, 190.0 }, // sk_plr_secondarygauss 138
			{ 120.0, 24.0, 12.0, 12.0, 12.0, 12.0, 12.0, 12.0 }, // sk_hornet_pdmg 139
			{ 1100.0, 220.0, 110.0, 110.0, 110.0, 110.0, 110.0, 110.0 }, // sk_plr_762_bullet 140
			{ 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0 }, // sk_plr_spore 141
			{ 15.0, 15.0, 15.0, 15.0, 15.0, 15.0, 15.0, 15.0 }, // sk_plr_shockrifle 142
			{ 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0 }, // sk_plr_shockrifle_beam2 143
			{ 25.0, 125.0, 250.0, 350.0, 500.0, 750.0, 1000.0, 50000.0 }, // sk_shockroach_dmg_xpl_touch 144
			{ 10.0, 20.0, 30.0, 50.0, 75.0, 100.0, 150.0, 1000.0 }, // sk_shockroach_dmg_xpl_splash 145
			{ 250.0, 250.0, 250.0, 250.0, 250.0, 250.0, 250.0, 250.0 }, // sk_plr_displacer_other 146
			{ 300.0, 300.0, 300.0, 300.0, 300.0, 300.0, 300.0, 300.0 } // sk_plr_displacer_radius 147
	};
	
	/**
	* Current Difficulty of the map
	*/
	private double m_fl_difficulty = 0.5;

	/**
	* Current Difficulty of the map
	*/
	bool m_ignore_diff = true;
	
	/**
	* Current MaxHealth of the map
	*/
	double m_fl_maxH = 100.0;
	
	/**
	* Current MaxArmor of the map
	*/
	double m_fl_maxA = 100.0;
	
	/**
	* Current MaxHealth of the map
	*/
	double m_fl_chargeH = 0.0;
	
	/**
	* Current MaxArmor of the map
	*/
	double m_fl_chargeA = 0.0;
	
	/**
	* Number of Players that are connected to the Server
	*/
	private int m_playerNum = 0;
	
	/**
	* Number of Players that are connected at the end of the last map.
	*/
	private int m_LastPlayerNum = 0;
	
	/**
	* How often does the same map needs to restart.
	*/
	private int m_Fails = 0;
	
	/**
	* Diff limit for gaussjumping to enable (int)
	*/
	private int m_gaussDiff = 995;
	
	/**
	* What was the name of the last map?
	*/
	private string m_oldMap = "";
	
	/**
	* Did the last map ran for over 30 seconds?
	*/
	private bool m_30sec_over = false;
	
	private string s_message = "DIFFICULTY: 50.0 Percent (Medium) (none were connected at Map-Begin)";
	double m_flMessageTime = 0.0;
	double m_oldEngineTime = 0.0;
	
	array<string> chargerValuesStr;
	
	CScheduledFunction@ countPeopleScheduler;
	CScheduledFunction@ enable30SScheduler;
	
	Diffy(){
		m_fl_difficulty = 0.5;
		m_playerNum = 0;
		m_LastPlayerNum = 0;
		m_flMessageTime = 0.0;
		m_oldEngineTime = g_Engine.time;
		m_oldMap = "";
		
		changeMaxHealth();
		diffyThink();
	}
	
	void diffyThink(){
		double betweenTime = g_Engine.time - m_oldEngineTime;
		
		if(betweenTime < 0.0){
			m_oldEngineTime = g_Engine.time;
		}else{
			if(!m_ignore_diff){
				CBasePlayer@ pPlayer;

				for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer ){
					@pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

					if( pPlayer is null || !pPlayer.IsConnected() )
						continue;

					if(pPlayer.IsAlive()){

						if(pPlayer.pev.health > 0.0){
							pPlayer.pev.max_health = m_fl_maxH;
							pPlayer.pev.armortype = m_fl_maxA;

							pPlayer.pev.health += m_fl_chargeH * betweenTime;
							pPlayer.pev.armorvalue += m_fl_chargeA * betweenTime;
						}

						if(pPlayer.pev.health > pPlayer.pev.max_health)
							pPlayer.pev.health = pPlayer.pev.max_health;

						if(pPlayer.pev.armorvalue > pPlayer.pev.armortype)
							pPlayer.pev.armorvalue = pPlayer.pev.armortype;

						g_PlayerDiffData_LastIsAlive[ iPlayer-1 ] = true;
					}else{
						if(g_PlayerDiffData_LastIsAlive[ iPlayer-1 ]){
							g_PlayerDiffData_LastIsAlive[ iPlayer-1 ] = false;
						}
					}
				}
			}
			
			m_oldEngineTime += betweenTime;
		}
		
		g_Scheduler.SetTimeout( @this, "diffyThink", 0.15);
	}
	
	double getSkValue(int indexo){
		uint iMax = diffBorders.length();
		
		if(m_fl_difficulty == 1.0){
			return skillMatrix[indexo][7];
		}else{
			
			for(uint i = 0; i < iMax;i++){
			
				if(diffBorders[i] == m_fl_difficulty){
					return skillMatrix[indexo][i];
				}else if(diffBorders.length()>i && diffBorders[i+1]>m_fl_difficulty){
					double mino = diffBorders[i];
					double maxo = diffBorders[i+1];
					double difference = (m_fl_difficulty-mino)/(maxo-mino);
					
					return skillMatrix[indexo][i]*(1-difference) + skillMatrix[indexo][i+1]*difference;
				}
				
			}
			
		}
		return -1.0;
	}
	
	double getSkValueMaxHealth(){
		uint iMax = diffBorders.length();
		
		if(m_fl_difficulty == 1.0){
			return playerMaxHealth[7];
		}else{
			
			for(uint i = 0; i < iMax;i++){
			
				if(diffBorders[i] == m_fl_difficulty){
					return playerMaxHealth[i];
				}else if(diffBorders.length()>i && diffBorders[i+1]>m_fl_difficulty){
					double mino = diffBorders[i];
					double maxo = diffBorders[i+1];
					double difference = (m_fl_difficulty-mino)/(maxo-mino);
					
					return playerMaxHealth[i]*(1-difference) + playerMaxHealth[i+1]*difference;
				}
				
			}
			
		}
		return -1.0;
	}
	
	double getSkValueMaxArmor(){
		uint iMax = diffBorders.length();
		
		if(m_fl_difficulty == 1.0){
			return playerMaxArmor[7];
		}else{
			
			for(uint i = 0; i < iMax;i++){
			
				if(diffBorders[i] == m_fl_difficulty){
					return playerMaxArmor[i];
				}else if(diffBorders.length()>i && diffBorders[i+1]>m_fl_difficulty){
					double mino = diffBorders[i];
					double maxo = diffBorders[i+1];
					double difference = (m_fl_difficulty-mino)/(maxo-mino);
					
					return playerMaxArmor[i]*(1-difference) + playerMaxArmor[i+1]*difference;
				}
				
			}
			
		}
		return -1.0;
	}
	
	double getSkValueChargeHealth(){
		uint iMax = diffBorders.length();
		
		if(m_fl_difficulty == 1.0){
			return playerRegenerateHealth[7];
		}else{
			
			for(uint i = 0; i < iMax;i++){
			
				if(diffBorders[i] == m_fl_difficulty){
					return playerRegenerateHealth[i];
				}else if(diffBorders.length()>i && diffBorders[i+1]>m_fl_difficulty){
					double mino = diffBorders[i];
					double maxo = diffBorders[i+1];
					double difference = (m_fl_difficulty-mino)/(maxo-mino);
					
					return playerRegenerateHealth[i]*(1-difference) + playerRegenerateHealth[i+1]*difference;
				}
				
			}
			
		}
		return -1.0;
	}
	
	double getSkValueChargeArmor(){
		uint iMax = diffBorders.length();
		
		if(m_fl_difficulty == 1.0){
			return playerRegenerateArmor[7];
		}else{
			
			for(uint i = 0; i < iMax;i++){
			
				if(diffBorders[i] == m_fl_difficulty){
					return playerRegenerateArmor[i];
				}else if(diffBorders.length()>i && diffBorders[i+1]>m_fl_difficulty){
					double mino = diffBorders[i];
					double maxo = diffBorders[i+1];
					double difference = (m_fl_difficulty-mino)/(maxo-mino);
					
					return playerRegenerateArmor[i]*(1-difference) + playerRegenerateArmor[i+1]*difference;
				}
				
			}
			
		}
		return -1.0;
	}
	
	double getValueCustomArray(array<double> arr){
		uint iMax = diffBorders.length();
		
		if(m_fl_difficulty == 1.0){
			return arr[7];
		}else{
		
			for(uint i = 0; i < iMax;i++){
			
				if(diffBorders[i] == m_fl_difficulty){
					return arr[i];
				}else if(diffBorders.length()>i && diffBorders[i+1]>m_fl_difficulty){
					double mino = diffBorders[i];
					double maxo = diffBorders[i+1];
					double difference = (m_fl_difficulty-mino)/(maxo-mino);
					
					return arr[i]*(1-difference) + arr[i+1]*difference;
				}
				
			}
		}
		
		return -1.0;
	}
	
	void changeMonsterHealth(){
		for( int i = 0; i < g_Engine.maxEntities; ++i ) {
			CBaseEntity@ ent = g_EntityFuncs.Instance( i );
			
			if( ent !is null ) {
				if( ent.pev.health <= 0.0 || ent.pev.health >= 100000.0 || ent.Classify() == CLASS_PLAYER_ALLY ) continue;

				if ( ent.pev.classname == "monster_alien_babyvoltigore" ){
					ent.pev.health = getSkValue(118)/3.0f;
				}else if ( ent.pev.classname == "monster_alien_controller" ){
					ent.pev.health = getSkValue(37);
				}else if ( ent.pev.classname == "monster_alien_grunt" ){
					ent.pev.health = getSkValue(0);
				}else if ( ent.pev.classname == "monster_alien_slave" ){
					ent.pev.health = getSkValue(29);
				}else if ( ent.pev.classname == "monster_alien_tor" ){
					ent.pev.health = getSkValue(114);
				}else if ( ent.pev.classname == "monster_alien_voltigore" ){
					ent.pev.health = getSkValue(118);
				}else if ( ent.pev.classname == "monster_apache" ){
					if(g_Engine.mapname == "hl_c11_a2") {
						array<double> arrD = { 15.0, 100.0, 500.0, 1000.0, 1250.0, 1500.0, 2000.0, 2000.0 };
						ent.pev.health = getValueCustomArray(arrD);
					}else{
						ent.pev.health = getSkValue(4);
					}
				// }else if ( ent.pev.classname == "monster_assassin_repel" ){
					// ent.pev.health = getSkValue();
				}else if ( ent.pev.classname == "monster_babycrab" ){
					ent.pev.health = getSkValue(21)/3.0f;
				// }else if ( ent.pev.classname == "monster_babygarg" ){
					// ent.pev.health = getSkValue();
				}else if ( ent.pev.classname == "monster_barnacle" ){
					ent.pev.health = getSkValue(5);
				}else if ( ent.pev.classname == "monster_barney" ){
					ent.pev.health = getSkValue(7);
				}else if ( ent.pev.classname == "monster_barney_dead" ){
					ent.pev.health = getSkValue(7);
				}else if ( ent.pev.classname == "monster_bigmomma" ){
					ent.pev.health = getSkValue(12);
				}else if ( ent.pev.classname == "monster_blkop_osprey" ){
					ent.pev.health = getSkValue(123);
				}else if ( ent.pev.classname == "monster_blkop_apache" ){
					ent.pev.health = getSkValue(4);
				// }else if ( ent.pev.classname == "monster_bloater" ){
					// ent.pev.health = getSkValue();
				// }else if ( ent.pev.classname == "monster_bodyguard" ){
					// ent.pev.health = getSkValue();
				}else if ( ent.pev.classname == "monster_bullchicken" ){
					ent.pev.health = getSkValue(8);
				// }else if ( ent.pev.classname == "monster_chumtoad" ){
					// ent.pev.health = getSkValue();
				}else if ( ent.pev.classname == "monster_cleansuit_scientist" ){
					ent.pev.health = getSkValue(43);
				// }else if ( ent.pev.classname == "monster_cockroach" ){
					// ent.pev.health = getSkValue();
				// }else if ( ent.pev.classname == "monster_flyer_flock" ){
					// ent.pev.health = getSkValue();
				// }else if ( ent.pev.classname == "monster_furniture" ){
					// ent.pev.health = getSkValue();
				}else if ( ent.pev.classname == "monster_gargantua" ){
					ent.pev.health = getSkValue(16);
				// }else if ( ent.pev.classname == "monster_generic" ){
					// ent.pev.health = getSkValue();
				// }else if ( ent.pev.classname == "monster_gman" ){
					// ent.pev.health = getSkValue();
				}else if ( ent.pev.classname == "monster_gonome" ){
					ent.pev.health = getSkValue(103);
				// }else if ( ent.pev.classname == "monster_grunt_ally_repel" ){
					// ent.pev.health = getSkValue();
				// }else if ( ent.pev.classname == "monster_grunt_repel" ){
					// ent.pev.health = getSkValue();
				// }else if ( ent.pev.classname == "monster_handgrenade" ){
					// ent.pev.health = getSkValue();
				}else if ( ent.pev.classname == "monster_headcrab" ){
					ent.pev.health = getSkValue(21);
				// }else if ( ent.pev.classname == "monster_hevsuit_dead" ){
					// ent.pev.health = getSkValue();
				// }else if ( ent.pev.classname == "monster_hgrunt_dead" ){
					// ent.pev.health = getSkValue();
				}else if ( ent.pev.classname == "monster_houndeye" ){
					ent.pev.health = getSkValue(27);
				}else if ( ent.pev.classname == "monster_human_assassin" ){
					ent.pev.health = getSkValue(20);
				}else if ( ent.pev.classname == "monster_human_grunt" ){
					ent.pev.health = getSkValue(23);
				// }else if ( ent.pev.classname == "monster_human_grunt_ally" ){
					// ent.pev.health = getSkValue();
				// }else if ( ent.pev.classname == "monster_human_grunt_ally_dead" ){
					// ent.pev.health = getSkValue();
				// }else if ( ent.pev.classname == "monster_human_medic_ally" ){
					// ent.pev.health = getSkValue();
				// }else if ( ent.pev.classname == "monster_human_torch_ally" ){
					// ent.pev.health = getSkValue();
				}else if ( ent.pev.classname == "monster_hwgrunt" ){
					ent.pev.health = getSkValue(91);
				// }else if ( ent.pev.classname == "monster_hwgrunt_repel" ){
					// ent.pev.health = getSkValue();
				}else if ( ent.pev.classname == "monster_ichthyosaur" ){
					if(g_Engine.mapname == "hl_c08_a1") {
						array<double> arrD = { 5.0, 20.0, 100.0, 300.0, 500.0, 750.0, 900.0, 1000.0 };
						ent.pev.health = getValueCustomArray(arrD);
					}else{
						ent.pev.health = getSkValue(33);
					}
				}else if ( ent.pev.classname == "monster_kingpin" ){
					ent.pev.health = getSkValue(127);
				}else if ( ent.pev.classname == "monster_leech" ){
					ent.pev.health = getSkValue(35);
				}else if ( ent.pev.classname == "monster_male_assassin" ){
					ent.pev.health = getSkValue(23);
				// }else if ( ent.pev.classname == "monster_medic_ally_repel" ){
					// ent.pev.health = getSkValue();
				}else if ( ent.pev.classname == "monster_miniturret" ){
					ent.pev.health = getSkValue(51);
				}else if ( ent.pev.classname == "monster_nihilanth" ){
					ent.pev.health = getSkValue(41);
				}else if ( ent.pev.classname == "monster_osprey" ){
					ent.pev.health = getSkValue(124);
				}else if ( ent.pev.classname == "monster_otis" ){
					ent.pev.health = getSkValue(95);
				// }else if ( ent.pev.classname == "monster_otis_dead" ){
					// ent.pev.health = getSkValue();
				}else if ( ent.pev.classname == "monster_pitdrone" ){
					ent.pev.health = getSkValue(107);
				// }else if ( ent.pev.classname == "monster_rat" ){
					// ent.pev.health = getSkValue();
				// }else if ( ent.pev.classname == "monster_robogrunt" ){
					// ent.pev.health = getSkValue();
				// }else if ( ent.pev.classname == "monster_robogrunt_repel" ){
					// ent.pev.health = getSkValue();
				// }else if ( ent.pev.classname == "monster_satchel" ){
					// ent.pev.health = getSkValue();
				}else if ( ent.pev.classname == "monster_scientist" ){
					ent.pev.health = getSkValue(43);
				// }else if ( ent.pev.classname == "monster_scientist_dead" ){
					// ent.pev.health = getSkValue();
				}else if ( ent.pev.classname == "monster_sentry" ){
					ent.pev.health = getSkValue(52);
				// }else if ( ent.pev.classname == "monster_shockroach" ){
					// ent.pev.health = getSkValue();
				}else if ( ent.pev.classname == "monster_shocktrooper" ){
					ent.pev.health = getSkValue(111);
				// }else if ( ent.pev.classname == "monster_sitting_scientist" ){
					// ent.pev.health = getSkValue();
				}else if ( ent.pev.classname == "monster_snark" ){
					ent.pev.health = getSkValue(44);
				}else if ( ent.pev.classname == "monster_sqknest" ){
					ent.pev.health = getSkValue(126);
				}else if ( ent.pev.classname == "monster_stukabat" ){
					ent.pev.health = getSkValue(125);
				}else if ( ent.pev.classname == "monster_tentacle" ){
					ent.pev.health = getSkValue(122);
				// }else if ( ent.pev.classname == "monster_torch_ally_repel" ){
					// ent.pev.health = getSkValue();
				// }else if ( ent.pev.classname == "monster_tripmine" ){
					// ent.pev.health = getSkValue();
				}else if ( ent.pev.classname == "monster_turret" ){
					ent.pev.health = getSkValue(50);
				}else if ( ent.pev.classname == "monster_zombie" ){
					ent.pev.health = getSkValue(47);
				}else if ( ent.pev.classname == "monster_zombie_barney" ){
					ent.pev.health = getSkValue(97);
				}else if ( ent.pev.classname == "monster_zombie_soldier" ){
					ent.pev.health = getSkValue(100);
				}
			}
		}
	}
	
	//Mode 0 = Count people
	//Mode 1 = Changed by Admin
	//Mode 2 = Count people and Fails
	//Mode 3 = Disabled
	void changeMessage(int mode){
		string aStr = "DIFFICULTY: Current: "+format_float(getDiffInt()/10)+" percent ";
		
		string bStr = "";
		string cStr = "";
		string dStr = " Gaussjump: ";
		
		if(m_fl_difficulty<0.0005)
			bStr = "(Lowest Difficulty)";
		else if(m_fl_difficulty<0.1)
			bStr = "(Beginners)";
		else if(m_fl_difficulty<0.2)
			bStr = "(Very Easy)";
		else if(m_fl_difficulty<0.4)
			bStr = "(Easy)";
		else if(m_fl_difficulty<0.6)
			bStr = "(Medium)";
		else if(m_fl_difficulty<0.75)
			bStr = "(Hard)";
		else if(m_fl_difficulty<0.85)
			bStr = "(Very Hard!)";
		else if(m_fl_difficulty<0.9)
			bStr = "(Extreme!)";
		else if(m_fl_difficulty<0.95)
			bStr = "(Near Impossible!)";
		else if(m_fl_difficulty<0.9995)
			bStr = "(Impossible!)";
		else
			bStr = "(MAXIMUM DIFFICULTY!)";
			
		switch(mode){
		case 0:
			if(m_LastPlayerNum == 0){
				cStr = " (Nobody was connected during Starting point)";
			}else if(m_LastPlayerNum == 1){
				cStr = " (A person connected during Starting point)";
			}else{
				cStr = " ("+m_LastPlayerNum+" people were connected during Starting point)";
			}
			
			break;
		case 1:
			cStr = " (changed by an Admin)";
			break;
		case 2:
			if(m_Fails == 0){
				cStr = " (First time on this map)";
			}else if(m_Fails == 1){
				cStr = " (Map restarted once)";
			}else if(m_Fails == 2){
				cStr = " (Map restarted twice)";
			}else if(m_Fails == 3){
				cStr = " (Map restarted thrice)";
			}else{
				cStr = " (Map restarted "+m_Fails+" times)";
			}
			break;
		case 3:
			cStr = " (Disabled on this map)";
			break;
		}

		if(getDiffInt() >= m_gaussDiff){
			dStr = dStr + "on";
		}else{
			dStr = dStr + "off";
		}

		s_message = aStr+bStr+cStr+dStr;
	}
	
	void calculateSkills(){
		int iMax = skillMatrix.size();
		
		for( int i = 0; i < iMax; ++i ){
			if(i == 4 && g_Engine.mapname == "hl_c11_a2") {
				array<double> arrD = { 15.0, 100.0, 500.0, 1000.0, 1250.0, 1500.0, 2000.0, 2000.0 };
				g_EngineFuncs.CVarSetFloat(sk_names[i], getValueCustomArray(arrD));
			}else if(i == 33 && g_Engine.mapname == "hl_c08_a1") {
				array<double> arrD = { 5.0, 20.0, 100.0, 300.0, 500.0, 750.0, 900.0, 1000.0 };
				g_EngineFuncs.CVarSetFloat(sk_names[i], getValueCustomArray(arrD));
			}else{
				g_EngineFuncs.CVarSetFloat(sk_names[i], getSkValue(i));
			}
		}
	}
	
	void changeMaxHealth(){
		m_fl_maxH = getSkValueMaxHealth();
		m_fl_maxA = getSkValueMaxArmor();
		m_fl_chargeH = getSkValueChargeHealth();
		m_fl_chargeA = getSkValueChargeArmor();
		
		CBasePlayer@ pPlayer;
		
		for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer ){
			@pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );
		
			if( pPlayer is null || !pPlayer.IsConnected() )
				continue;
			
			double h = pPlayer.pev.health;
			double a = pPlayer.pev.armorvalue;
			double h2 = pPlayer.pev.max_health;
			double a2 = pPlayer.pev.armortype;
			
			if(h2 < 1.0) h2 = 1.0;
			if(a2 < 1.0) a2 = 1.0;
			
			if(pPlayer.pev.health > 0.0)
				pPlayer.pev.health *= m_fl_maxH/h2 + 1.0;
			
			if(pPlayer.pev.armorvalue > 0.0)
				pPlayer.pev.armorvalue *= m_fl_maxA/a2 + 1.0;
			
			pPlayer.pev.max_health = m_fl_maxH;
			pPlayer.pev.armortype = m_fl_maxA;
			
			if(pPlayer.pev.health > pPlayer.pev.max_health)
				pPlayer.pev.health = pPlayer.pev.max_health;
			
			if(pPlayer.pev.armorvalue > pPlayer.pev.armortype)
				pPlayer.pev.armorvalue = pPlayer.pev.armortype;
			
		}
	}
	
	void setDifficulty(double newDiff, bool ignoreChanges, int mode){

		m_ignore_diff = ignoreChanges;

		if(newDiff < 0.0) newDiff = 0.0;
		if(newDiff > 1.0) newDiff = 1.0;
		if(newDiff < 0.001 && newDiff > 0.0) newDiff = 0.001;
		if(newDiff > 0.999 && newDiff < 1.0) newDiff = 0.999;
		
		if(ignoreChanges) {
			newDiff = 0.5;
			mode = 3;
		}
		
		m_fl_difficulty = newDiff;
		if(!ignoreChanges) {
			calculateSkills();
			manipulateEntities();
			changeMaxHealth();
			changeMonsterHealth();
		}
		
		changeMessage(mode);
		AppendHostname();
	}
	
	void countPeople(){
		if(g_Engine.time < 30.0f){
			if(countPeopleScheduler is null){
				@countPeopleScheduler = g_Scheduler.SetTimeout( @this, "countPeople", 30.0f-g_Engine.time);
			}
			return;
		}
		
		m_playerNum = 0;
		
		CBasePlayer@ pPlayer;
		
		for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer ){
			@pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );
		
			if( pPlayer is null || !pPlayer.IsConnected() )
				continue;
			
			m_playerNum++;
		}
		
		if(m_playerNum == 0){
			m_Fails = 0;
			m_oldMap = "";
		}
	}
	
	void multiplySpeed(CBaseEntity@ pEntity, double factor){
		CustomKeyvalues@ cKeyValues = pEntity.GetCustomKeyvalues();
		
		if(!cKeyValues.HasKeyvalue("$f_originalSpeed")){
			cKeyValues.SetKeyvalue("$f_originalSpeed", pEntity.pev.speed);
			pEntity.pev.speed *= factor;
		}else{
			pEntity.pev.speed = cKeyValues.GetKeyvalue("$f_originalSpeed").GetFloat() * factor;
		}
	}
	
	void multiplyMaxSpeed(CBaseEntity@ pEntity, double factor){
		CustomKeyvalues@ cKeyValues = pEntity.GetCustomKeyvalues();
		
		if(!cKeyValues.HasKeyvalue("$f_originalMaxSpeed")){
			cKeyValues.SetKeyvalue("$f_originalMaxSpeed", pEntity.pev.maxspeed);
			pEntity.pev.maxspeed *= factor;
		}else{
			pEntity.pev.maxspeed = cKeyValues.GetKeyvalue("$f_originalSpeed").GetFloat() * factor;
		}
	}
	
	void manipulateEntities2(){
		for(uint i = 0; i < chargerValuesStr.size(); i+=4){
			dictionary keyvalues = {
					{ "model", chargerValuesStr[i] },
					{ "origin", chargerValuesStr[i+2] },
					{ "angles", chargerValuesStr[i+3] },
					{ "CustomRechargeTime", "86400" }
			};
			g_EntityFuncs.CreateEntity(chargerValuesStr[i+1], keyvalues, true);
		}
		
		chargerValuesStr.resize(0);
	}
	
	void manipulateEntities(){
		string strMap = g_Engine.mapname;
		CBaseEntity@ pWorld = g_EntityFuncs.Instance( 0 );
		
		for( int i = 0; i < g_Engine.maxEntities; ++i ) {
			CBaseEntity@ pEntity = g_EntityFuncs.Instance( i );
			if( pEntity is null ) continue;
			
			string s_Targetname = pEntity.GetTargetname();
			bool needsRetrigger = false;
			
			if((pEntity.pev.classname == "item_battery" || pEntity.pev.classname == "item_healthkit") && m_fl_difficulty == 1.0){
				g_EntityFuncs.Remove( pEntity );
				continue;
			}
			
			if(pEntity.pev.classname == "func_recharge" || pEntity.pev.classname == "func_healthcharger"){
				chargerValuesStr.insertLast(pEntity.pev.model);
				chargerValuesStr.insertLast(pEntity.pev.classname);
				string aStr = "" + pEntity.pev.origin.x + " " + pEntity.pev.origin.y + " " + pEntity.pev.origin.z;
				chargerValuesStr.insertLast(aStr);
				aStr = "" + pEntity.pev.angles.x + " " + pEntity.pev.angles.y + " " + pEntity.pev.angles.z;
				chargerValuesStr.insertLast(aStr);
				
				g_EntityFuncs.Remove( pEntity );
				continue;
			}
			
			if(strMap == "hl_c07_a2"){
				bool movingEntities = s_Targetname == "crates";
				movingEntities = movingEntities || s_Targetname.Find("z5crateway") < 4294967295;
				
				if(movingEntities){
					array<double> arrD = { 1.0, 1.0, 1.0, 1.0, 1.25, 2.0, 5.0, 10.0 };
					multiplyMaxSpeed(pEntity, getValueCustomArray(arrD));
					multiplySpeed(pEntity, getValueCustomArray(arrD));
				}
				
				if(s_Targetname == "sniper1"){
					array<double> arrD1 = { 0.5, 0.75, 0.9, 1.0, 1.25, 2.0, 5.0, 10.0 };
					array<double> arrD2 = { 1.0, 1.0, 1.0, 1.0, 0.9, 0.5, 0.01, 0.01 };
					g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "firerate", (2.0*getValueCustomArray(arrD1)) );
					g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "targetwait", (2.0*getValueCustomArray(arrD2)) );
				}
				
				if(s_Targetname == "trackguardrocket" || s_Targetname == "trackguardrocketv2"){
					array<double> arrD = { 0.25, 0.5, 0.75, 1.0, 1.5, 3.0, 10.0, 10.0 };
					g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "firerate", (1.0*getValueCustomArray(arrD)) );
				}
				
				if(s_Targetname == "siloguardgun" || s_Targetname == "siloguardgunv2" || s_Targetname == "siloguardgunv3"){
					array<double> arrD = { 0.5, 0.75, 0.9, 1.0, 1.25, 2.0, 5.0, 10.0 };
					g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "firerate", (4.0*getValueCustomArray(arrD)) );
				}
			}
			
			if(strMap == "hl_c09"){
				needsRetrigger = s_Targetname == "sec2_moveables";
				
				bool movingEntities2 = s_Targetname == "sec4_moveables";
				movingEntities2 = movingEntities2 || s_Targetname == "sec4_endcrusher";
				movingEntities2 = movingEntities2 || (s_Targetname.Find("piston") < 4294967295 && s_Targetname.Find("_a") == 4294967295);
				movingEntities2 = movingEntities2 || s_Targetname.Find("chomper") < 4294967295;
				
				bool movingEntities = s_Targetname == "towerwater";
				movingEntities = movingEntities || needsRetrigger;
				movingEntities = movingEntities || s_Targetname == "sec3_moveables";
				movingEntities = movingEntities || s_Targetname.Find("piston") < 4294967295;
				movingEntities = movingEntities || s_Targetname.Find("vat") < 4294967295;
				movingEntities = movingEntities || movingEntities2;
				
				if(movingEntities){
					if(movingEntities2){
						array<double> arrD = { 0.5, 0.75, 0.9, 1.0, 1.1, 1.5, 2.5, 2.5 };
						multiplyMaxSpeed(pEntity, getValueCustomArray(arrD));
						multiplySpeed(pEntity, getValueCustomArray(arrD));
					}else{
						array<double> arrD = { 1.0, 1.0, 1.0, 1.0, 1.25, 2.0, 5.0, 10.0 };
						multiplyMaxSpeed(pEntity, getValueCustomArray(arrD));
						multiplySpeed(pEntity, getValueCustomArray(arrD));
					}
				}
			}
			
			if(strMap == "hl_c10"){
				if(s_Targetname == "psychobot" || s_Targetname == "psychobot2"){
					array<double> arrD = { 0.5, 0.5, 0.75, 1.0, 2.0, 4.0, 5.0, 6.0 };
					multiplyMaxSpeed(pEntity, getValueCustomArray(arrD));
					multiplySpeed(pEntity, getValueCustomArray(arrD));
					needsRetrigger = true;
				}
			}
			
			if(strMap == "hl_c11_a2"){
				if(s_Targetname == "sniper1" || s_Targetname == "sniper2"){
					array<double> arrD1 = { 0.5, 0.75, 0.9, 1.0, 1.25, 2.0, 5.0, 10.0 };
					array<double> arrD2 = { 1.0, 1.0, 1.0, 1.0, 0.9, 0.5, 0.0, 0.0 };
					g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "firerate", (2.0*getValueCustomArray(arrD1)) );
					g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "targetwait", (2.0*getValueCustomArray(arrD2)) );
				}
				if(pEntity.pev.classname == "func_tankmortar" && s_Targetname == "tank_turret"){
					array<double> arrD1 = { 0.1, 0.5, 0.9, 1.0, 1.1, 1.5, 2.0, 3.0 };
					array<double> arrD2 = { 0.25, 0.5, 0.75, 1.0, 1.5, 3.0, 10.0, 10.0 };
					g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "iMagnitude", (100.0*getValueCustomArray(arrD1)) );
					g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "firerate", (0.4*getValueCustomArray(arrD2)) );
				}
				if(s_Targetname == "brad_turret"){
					array<double> arrD = { 0.25, 0.5, 0.75, 1.0, 1.5, 3.0, 10.0, 10.0 };
					g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "firerate", (1.0*getValueCustomArray(arrD)) );
				}
				
			}
			if(strMap == "hl_c11_a4"){
				if(s_Targetname == "sniper1"){
					array<double> arrD1 = { 0.5, 0.75, 0.9, 1.0, 1.25, 2.0, 5.0, 10.0 };
					array<double> arrD2 = { 1.0, 1.0, 1.0, 1.0, 0.9, 0.5, 0.0, 0.0 };
					g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "firerate", (2.0*getValueCustomArray(arrD1)) );
					g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "targetwait", (2.0*getValueCustomArray(arrD2)) );
				}
				if(pEntity.pev.classname == "func_tankmortar" && s_Targetname == "brad_cannon"){
					array<double> arrD = { 0.25, 0.5, 0.75, 1.0, 1.5, 3.0, 10.0, 10.0 };
					g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "firerate", (1.0*getValueCustomArray(arrD)) );
				}
			}
			
			if(strMap == "hl_c12"){
				if(pEntity.pev.classname == "func_tankmortar" && s_Targetname == "tank_turret"){
					array<double> arrD1 = { 0.1, 0.5, 0.9, 1.0, 1.1, 1.5, 2.0, 3.0 };
					array<double> arrD2 = { 0.25, 0.5, 0.75, 1.0, 1.5, 3.0, 10.0, 10.0 };
					g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "iMagnitude", (100.0*getValueCustomArray(arrD1)) );
					g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "firerate", (0.4*getValueCustomArray(arrD2)) );
				}
				if(s_Targetname == "biggun"){
					array<double> arrD = { 0.5, 0.75, 0.9, 1.0, 1.25, 2.0, 5.0, 10.0 };
					g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "firerate", (6.0*getValueCustomArray(arrD)) );
				}
				if(s_Targetname == "alien_turret_2"){
					array<double> arrD = { 0.5, 0.75, 0.9, 1.0, 1.25, 2.0, 5.0, 10.0 };
					g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "firerate", (2.0*getValueCustomArray(arrD)) );
				}
			}
			
			if(strMap == "hl_c13_a3"){
				bool movingEntities = pEntity.pev.modelindex == 60;
				bool movingEntities2 = pEntity.pev.modelindex == 2;
				movingEntities = movingEntities || pEntity.pev.modelindex == 59;
				movingEntities = movingEntities || pEntity.pev.modelindex == 58;
				movingEntities2 = movingEntities2 || pEntity.pev.modelindex == 3;
				movingEntities2 = movingEntities2 || pEntity.pev.modelindex == 5;
				movingEntities = movingEntities || movingEntities2;
				
				if(movingEntities){
					if(movingEntities2){
						array<double> arrD = { 0.5, 0.5, 0.75, 1.0, 2.0, 4.0, 5.0, 6.0 };
						multiplyMaxSpeed(pEntity, getValueCustomArray(arrD));
						multiplySpeed(pEntity, getValueCustomArray(arrD));
					}else{
						array<double> arrD = { 0.5, 0.5, 0.75, 1.0, 2.0, 4.0, 5.0, 6.0 };
						multiplyMaxSpeed(pEntity, getValueCustomArray(arrD));
						multiplySpeed(pEntity, getValueCustomArray(arrD));
					}
					needsRetrigger = true;
				}
			}
			
			if(strMap == "hl_c14"){
				bool movingEntities = pEntity.pev.modelindex > 1 && pEntity.pev.modelindex < 8;
				movingEntities = movingEntities || pEntity.pev.modelindex == 41;
				movingEntities = movingEntities || pEntity.pev.modelindex == 40;
				movingEntities = movingEntities || s_Targetname == "a";
				movingEntities = movingEntities || s_Targetname == "b";
				movingEntities = movingEntities || s_Targetname == "c";
				movingEntities = movingEntities || s_Targetname == "d";
				movingEntities = movingEntities || s_Targetname == "e";
				movingEntities = movingEntities || s_Targetname == "f";
				movingEntities = movingEntities || s_Targetname == "g";
				movingEntities = movingEntities || s_Targetname == "h";
				movingEntities = movingEntities || s_Targetname == "i";
				movingEntities = movingEntities || s_Targetname == "j";
				movingEntities = movingEntities || s_Targetname == "k";
				movingEntities = movingEntities || s_Targetname == "l";
				movingEntities = movingEntities || s_Targetname == "m";
				movingEntities = movingEntities || s_Targetname == "n";
				movingEntities = movingEntities || s_Targetname == "o";
				movingEntities = movingEntities || s_Targetname == "p";
				
				if(movingEntities){
					array<double> arrD = { 1.0, 1.0, 1.0, 1.0, 1.5, 3.0, 5.0, 6.0 };
					multiplyMaxSpeed(pEntity, getValueCustomArray(arrD));
					multiplySpeed(pEntity, getValueCustomArray(arrD));
					needsRetrigger = true;
				}
				
				if(pEntity.pev.classname == "func_tanklaser"){
					array<double> arrD = { 0.5, 0.75, 0.9, 1.0, 1.25, 2.0, 5.0, 10.0 };
					g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "firerate", (1.0*getValueCustomArray(arrD)) );
				}
			}
			
			if(strMap == "hl_c16_a1"){
				bool movingEntities2 = pEntity.pev.modelindex > 17 && pEntity.pev.modelindex < 22;
				movingEntities2 = movingEntities2 || pEntity.pev.modelindex == 2;
				bool movingEntities = pEntity.pev.modelindex > 2 && pEntity.pev.modelindex < 5;
				movingEntities = movingEntities || pEntity.pev.modelindex > 17 && pEntity.pev.modelindex < 22;
				movingEntities = movingEntities || pEntity.pev.modelindex == 64;
				movingEntities = movingEntities || pEntity.pev.modelindex == 142;
				movingEntities = movingEntities || pEntity.pev.modelindex == 141;
				movingEntities = movingEntities || pEntity.pev.modelindex == 8;
				movingEntities = movingEntities || movingEntities2;
				
				if(movingEntities){
					array<double> arrD = { 1.0, 1.0, 1.0, 1.0, 1.5, 3.0, 5.0, 6.0 };
					multiplyMaxSpeed(pEntity, getValueCustomArray(arrD));
					multiplySpeed(pEntity, getValueCustomArray(arrD));
					
					if(movingEntities2){
						needsRetrigger = true;
					}
				}
			}

			if(strMap == "th_ep2_04"){
				if(pEntity.pev.modelindex == 226 || pEntity.pev.modelindex == 259 || pEntity.pev.modelindex == 640){
					g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "dmg", 0.0 );
				}
			}

			if(strMap == "yabma"){
				if(pEntity.pev.modelindex == 262){
					g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "dmg", 0.0 );
				}
			}

			if(needsRetrigger){
				pEntity.Use( pWorld, pWorld, USE_OFF, 0 );
				pEntity.Use( pWorld, pWorld, USE_ON, 0 );
			}
		}
		g_Scheduler.SetTimeout( @this, "manipulateEntities2", 0.01f );
	}
	
	bool shouldIgnoreDynDiff(){
		File@ pFile = g_FileSystem.OpenFile( "scripts/plugins/store/DDX-Maplist.txt", OpenFile::READ );
		
		if( pFile is null || !pFile.IsOpen() ) {
			g_PlayerFuncs.ClientPrintAll( HUD_PRINTCONSOLE, "ERROR: scripts/plugins/store/DDX-Maplist.txt failed to open\n" );
			return false;
		}
		
		string strMap = g_Engine.mapname;
		strMap.ToLowercase();
		
		string line;
		
		while( !pFile.EOFReached() ){
			pFile.ReadLine( line );
			
			if(line.Length() < 1) continue;
			
			line.ToLowercase();
			
			if(strMap == line) return false;
			
		}
		
		pFile.Close();
		
		return true;
	}
	
	void enable_m_30sec_over(){
		g_diffy.m_flMessageTime = g_Engine.time + 15.0f;
		string aStr = g_diffy.getMessage()+"\n";
		g_Game.AlertMessage( at_logged, aStr );
		//g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, aStr );
		m_30sec_over = true;
	}
	
	void mapStartDiffy(){
		m_flMessageTime = 0.0;
		m_LastPlayerNum = m_playerNum;
		
		if(m_LastPlayerNum < 0) m_LastPlayerNum = 0;
		if(m_LastPlayerNum > 32) m_LastPlayerNum = 32;
		
		if(m_oldMap == g_Engine.mapname){
			if(m_30sec_over) m_Fails++;
		}else{
			m_Fails = 0;
			m_oldMap = g_Engine.mapname;
		}
		
		double d = diffPerPeep[m_LastPlayerNum];
		int mode = 0;
		
		if(m_Fails > 0){
			if(d == 1.0){
				d = d - double(m_Fails-1)*0.05 - 0.001;
			}else{
				d = d - double(m_Fails-0)*0.05;
			}
			mode = 2;
		}
		
		setDifficulty(d, shouldIgnoreDynDiff(), mode);

		countPeople();
		
		m_30sec_over = false;
		if(enable30SScheduler !is null){
			g_Scheduler.RemoveTimer(enable30SScheduler);
		}
		@enable30SScheduler = g_Scheduler.SetTimeout( @this, "enable_m_30sec_over", 33.0f );
	}
	
	string getMessage(){
		return s_message;
	}

	double getDiff() {
		return m_fl_difficulty;
	}

	int getDiffInt() {
		return int(m_fl_difficulty*1000.0+0.5);
	}

	int getGaussDiff() {
		return m_gaussDiff;
	}
}

Diffy@ g_diffy;
array<bool> g_PlayerDiffData_LastIsAlive;
string hostname;

CClientCommand g_DiffCommand("diff", "Sets the Difficulty (0.0 - 100.0)", @manipulate_difficulty, ConCommandFlag::AdminOnly);

void manipulate_difficulty(const CCommand@ pArguments){
	if(pArguments.ArgC() < 1) return;
	
	string aStr = pArguments.Arg(1);
	if(aStr == "") return;
	
	double newDiff = atod(aStr);
	
	g_diffy.setDifficulty(newDiff/100.0, false, 1);
}

void PluginInit(){
	g_Module.ScriptInfo.SetAuthor( "CubeMath" );
	g_Module.ScriptInfo.SetContactInfo( "steamcommunity.com/id/CubeMath" );
	
	g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @ClientPutInServer );
	g_Hooks.RegisterHook( Hooks::Player::ClientDisconnect, @ClientDisconnect );
	g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay2 );
	g_Hooks.RegisterHook( Hooks::Player::PlayerKilled, @PlayerKilled );
	
	g_PlayerDiffData_LastIsAlive.resize( g_Engine.maxClients );

	hostname = g_EngineFuncs.CVarGetString("hostname");
	
	for( int iPlayer = 0; iPlayer < g_Engine.maxClients; ++iPlayer ){
		g_PlayerDiffData_LastIsAlive[ iPlayer ] = false;
	}
	
	Diffy dif();
	@g_diffy = @dif;
	
	g_diffy.countPeople();
	g_diffy.mapStartDiffy();
}

void MapInit(){
}

void MapActivate(){
	g_diffy.mapStartDiffy();

	if(!g_diffy.m_ignore_diff && g_Engine.mapname != "hl_c13_a3"){
		OverrideMapCfg();
	}
}

HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer ){
	if(!g_diffy.m_ignore_diff){
		pPlayer.pev.max_health = g_diffy.m_fl_maxH;
		pPlayer.pev.armortype = g_diffy.m_fl_maxA;
	}

	g_diffy.countPeople();
	return HOOK_CONTINUE;
}

HookReturnCode ClientDisconnect( CBasePlayer@ pPlayer ){
	g_diffy.countPeople();
	return HOOK_CONTINUE;
}

HookReturnCode ClientSay2( SayParameters@ pParams ){
	string str = pParams.GetCommand();
	str.ToUppercase();
	bool strTest = false;

	strTest = (str.Find("DIFF") != String::INVALID_INDEX);
	strTest = strTest && (g_diffy.m_flMessageTime < g_Engine.time);
	
	if (strTest) {
		g_diffy.m_flMessageTime = g_Engine.time + 25.0f;
		string aStr = g_diffy.getMessage()+"\n";
		g_Game.AlertMessage( at_logged, aStr );
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, aStr );
	}

	return HOOK_CONTINUE;
}

// better way to handle gibbing than dying twice at 100% diff
HookReturnCode PlayerKilled( CBasePlayer@ pPlayer, CBaseEntity@, int iGib ){
	if (g_diffy.getDiff() == 1.0 && !((pPlayer.pev.health < -40 && iGib != GIB_NEVER) || iGib == GIB_ALWAYS)) {
		pPlayer.GibMonster();
		pPlayer.pev.deadflag = DEAD_DEAD;
		pPlayer.pev.effects |= EF_NODRAW;
	}

	return HOOK_CONTINUE;
}

// put the diff value in the hostname
void AppendHostname(){
	if(g_diffy.getDiffInt() != 500) {
		string dStr = "" + format_float(g_diffy.getDiffInt()/10) + "%";
		string hostnamenew = "hostname \"" + hostname + " | difficulty: " + dStr + "\"\n";
		g_EngineFuncs.ServerCommand(hostnamenew);
	}
}
void PluginExit() {
		g_EngineFuncs.ServerCommand("hostname \"" + hostname + "\"\n");
}

// gaussjumping
void OverrideMapCfg(){
	if (g_diffy.getDiffInt() >= g_diffy.getGaussDiff()) {
		g_EngineFuncs.ServerCommand("mp_disablegaussjump 0\n");
	}
	else {
		g_EngineFuncs.ServerCommand("mp_disablegaussjump 1\n");
	}
	g_EngineFuncs.ServerExecute();
}

string format_float(float f) {
   uint decimal = uint(((f - int(f)) * 10)) % 10;

   string uo = "" + int(f) + "." + decimal;

   while (uo.Length() > 0) {
      char c = uo[uo.Length()-1];

      if (c == '0' or c == '.') {
         uo = uo.SubString(0, uo.Length()-1);
        
         if (c == '.') {
            break;
         }
      } else {
         break;
      }
   }

   return uo;
}
