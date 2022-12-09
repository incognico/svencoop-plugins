int MAX_ANNOYANCE_TIME = 60; // number of seconds a player can use an annoying model
int ANNOYANCE_REGAIN_TIME = 2; // seconds regained per hour that the player can use towards annoying model usage

void print(string text) { g_Game.AlertMessage( at_console, text); }
void println(string text) { print(text + "\n"); }

const array<string> g_CrashModelList = {
'axis2_s5',
'tomb_rider',
'white_suit',
'axis2_s5_v2',
'tomb_rider_v2',
'white_suit_v2',
'kz_rindo_swc',
'vtuber_filian_sw'
};

const array<string> g_AnnoyingModelList = {
'apacheshit',
'big_mom',
'bmrftruck',
'bmrftruck2',
'carshit1',
'carshit4',
'carshit5',
'citroen',
'corvet',
'dc_tank',
'dc_tanks',
'f_zero_car1',
'f_modzero_car2',
'f_zero_car3',
'f_zero_car4',
'fdrx7',
'fockewulftriebflugel',
'forkliftshit',
'gaz',
'gto',
'hitlerlimo',
'humvee_be',
'humvee_desert',
'humvee_jungle',
'humvee_sc',
'mbt',
'mbts',
'mbts',
'friendlygarg',
'garg',
'gargantua',
'gonach',
'meatwall',
'onos',
'owatarobo',
'owatarobo_s',
'plantshit2',
'plantshit3',
'policecar',
'policecar2',
'sil80',
'sprt_tiefighter',
'sprt_xwing',
'tank_mbt',
'taskforcecar',
'treeshit',
'truck',
'vehicleshit_tigerii',
'vehicleshit_m1a1_abrams',
'vehicleshit_submarine',
'obamium',
'gigacirno_v2',
'snarkgarg'
};

DateTime last_annoying_psa;
const int annoying_psa_delay = 60*30;

void PluginInit() {
  g_Module.ScriptInfo.SetAuthor( "incognico" );
  g_Module.ScriptInfo.SetContactInfo( "https://discord.gg/qfZxWAd" );

  g_Scheduler.SetInterval( "Periodic", 1.11f );
  g_Scheduler.SetInterval( "fastcheck", 0.0f );
}

void Periodic() {
  CheckPlayerSinking();
  AnnoyingModelSurvivalSwap();
  SemiDeadFix();
}

void fastcheck() {
	CrashModelCheck();
}

void CheckPlayerSinking() {
  for( int i = 0; i < g_Engine.maxEntities; ++i ) {
    CBaseEntity@ pEntity = g_EntityFuncs.Instance( i );

    if( pEntity !is null) {
      if( pEntity.GetClassname() == "deadplayer" && pEntity.pev.speed < 10.0 ) {
        if( pEntity.pev.movetype != 5 && pEntity.pev.movetype != 8 ) {
          pEntity.pev.origin.z += 20.0;
          pEntity.pev.velocity.z -= 128.0;
          pEntity.pev.movetype = 5;
        }
        else if( pEntity.pev.movetype != 8 ) {
          pEntity.pev.velocity = Vector(0,0,0);
          pEntity.pev.movetype = 8;
        }

        pEntity.pev.solid = SOLID_NOT;
      }
    }
  }
}

void AnnoyingModelSurvivalSwap() {
	for( int i = 1; i <= g_Engine.maxClients; ++i ) {
		CBasePlayer@ plr = g_PlayerFuncs.FindPlayerByIndex( i );

		if (plr is null or !plr.IsConnected()) {
			continue;
		}
		
		KeyValueBuffer@ pInfos = g_EngineFuncs.GetInfoKeyBuffer( plr.edict() );
		
		bool isAnnoying = g_AnnoyingModelList.find( pInfos.GetValue( "model" ).ToLowercase() ) >= 0;
		
		if (isAnnoying and g_SurvivalMode.IsActive()) {
			g_PlayerFuncs.ClientPrint( plr, HUD_PRINTTALK, "[Warning] Don\'t use player model \'" + pInfos.GetValue( "model" ) + "\' during survival. It obscures views!\n" );
			pInfos.SetValue( "model", "helmet" );
		}
	}
}

void CrashModelCheck() {
	
  for( int i = 1; i <= g_Engine.maxClients; ++i ) {
    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( i );

    if( pPlayer !is null ) {
      KeyValueBuffer@ pInfos = g_EngineFuncs.GetInfoKeyBuffer( pPlayer.edict() );
	  string modelName = pInfos.GetValue( "model" ).ToLowercase();

      if( g_CrashModelList.find( modelName ) >= 0 )  {
        g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Warning] Don\'t use player model \'" + pInfos.GetValue( "model" ) + "\', it is prone to crash clients!\n" );
        pInfos.SetValue( "model", "helmet" );
      }
    }
  }
}

void SemiDeadFix() {
  for( int i = 1; i <= g_Engine.maxClients; ++i ) {
    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( i );

    if( pPlayer !is null ) {
      if (pPlayer.pev.health < 1 && pPlayer.pev.deadflag == 0) {
		pPlayer.Killed(pPlayer.pev, 1);
	  }
    }
  }
}
