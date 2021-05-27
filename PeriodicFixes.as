const array<string> g_CrashModelList = {
'apacheshit',
'axis2_s5',
'big_mom',
'bmrftruck',
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
'tomb_raider',
'vehicleshit_submarine'
};

void PluginInit() {
  g_Module.ScriptInfo.SetAuthor( "incognico" );
  g_Module.ScriptInfo.SetContactInfo( "https://discord.gg/qfZxWAd" );

  g_Scheduler.SetInterval( "Periodic", 1.11f );
}

void Periodic() {
  CheckPlayerSinking();
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

void CrashModelCheck() {
  for( int i = 1; i <= g_Engine.maxClients; ++i ) {
    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( i );

    if( pPlayer !is null ) {
      KeyValueBuffer@ pInfos = g_EngineFuncs.GetInfoKeyBuffer( pPlayer.edict() );

      if( g_CrashModelList.find( pInfos.GetValue( "model" ).ToLowercase() ) >= 0 )  {
        g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Warning] Don\'t use player model \'" + pInfos.GetValue( "model" ) + "\', it is prone to crash or obscures views!\n" );
        pInfos.SetValue( "model", "helmet" );
      }
    }
  }
}
