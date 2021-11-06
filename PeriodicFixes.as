const array<string> g_CrashModelList = {
'axis2_s5',
'tomb_rider',
'white_suit',
'axis2_s5_v2',
'tomb_rider_v2',
'white_suit_v2'
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
'truck',
'vehicleshit_tigerii',
'vehicleshit_m1a1_abrams',
'vehicleshit_submarine',
'obamium'
};

void PluginInit() {
  g_Module.ScriptInfo.SetAuthor( "incognico" );
  g_Module.ScriptInfo.SetContactInfo( "https://discord.gg/qfZxWAd" );

  g_Scheduler.SetInterval( "Periodic", 1.11f );
}

void Periodic() {
  CheckPlayerSinking();
  CrashModelCheck();
  SemiDeadFix();
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

void CrashModelCheck() {
  for( int i = 1; i <= g_Engine.maxClients; ++i ) {
    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( i );

    if( pPlayer !is null ) {
      KeyValueBuffer@ pInfos = g_EngineFuncs.GetInfoKeyBuffer( pPlayer.edict() );

      if( g_CrashModelList.find( pInfos.GetValue( "model" ).ToLowercase() ) >= 0 )  {
        g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Warning] Don\'t use player model \'" + pInfos.GetValue( "model" ) + "\', it is prone to crash clients!\n" );
        pInfos.SetValue( "model", "helmet" );
      }
	  
	  if( g_SurvivalMode.IsEnabled() and g_AnnoyingModelList.find( pInfos.GetValue( "model" ).ToLowercase() ) >= 0 )  {
        g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Warning] Don\'t use player model \'" + pInfos.GetValue( "model" ) + "\' during survival. It obscures views!\n" );
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
