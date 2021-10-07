void RelaySay( string message )
{
  message = message.Replace( "\n", "" ); // strip any newlines, ChatBridge.as takes care
 
  const string targetname  = "twlz_tmp_" + Math.RandomLong( 0, Math.INT32_MAX );
  const string caller      = g_Module.GetModuleName();

  g_EngineFuncs.ServerPrint( "<RelaySay " + caller + ">: " + message + "\n" );

  message = message.Replace( "\\", "\\\\" ); // escape backslashes, or the entity fucks them up

  dictionary keys = {
    { "targetname",           targetname },
    { "$s_twlz_relay_caller", caller     },
    { "$s_twlz_relay_msg",    message    }
  };
  CBaseEntity@ pEntity = g_EntityFuncs.CreateEntity( "info_target", keys );
  g_Scheduler.SetTimeout( "Failsafe", 2.0f, EHandle( pEntity ) ); // ChatBridge.as must pick up pEntity in less than this time
}

void Failsafe( EHandle hEntity )
{
  if ( hEntity )
    g_EntityFuncs.Remove( hEntity.GetEntity() );
}
