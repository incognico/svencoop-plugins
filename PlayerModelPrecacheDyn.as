// IMPORTANT:
// You need to create a symlink: svencoop_addon/models/player -> svencoop_addon/scripts/plugins/store/playermodelfolder
// LOL SECURITY VIOLATION USE AT OWN RISK LOL

const string g_pmodel_folder_default = "scripts/plugins/store/playermodelfolder_default/"; // Tailing /
const string g_pmodel_folder_addon = "scripts/plugins/store/playermodelfolder_addon/"; // Tailing /

void PluginInit() {
  g_Module.ScriptInfo.SetAuthor( "incognico" );
  g_Module.ScriptInfo.SetContactInfo( "https://discord.gg/qfZxWAd" );

  g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @ClientPutInServer );
  g_Hooks.RegisterHook( Hooks::Game::MapChange, @MapChange );
}

CClientCommand g_ListPrecacheModels( "listprecachedplayermodels", "List currently precached player models", @ListPrecachePlayerModels );
CClientCommand g_ListNewPrecacheModels( "listscheduledplayermodels", "List player models scheduled for precaching next map", @ListNewPrecachePlayerModels );
CClientCommand g_ListMissingModels( "listmissingplayermodels", "List missing player models", @ListMissingPlayerModels );

array<string> g_ModelList;
array<string> g_missing_list;
array<string> precachedModels;

HookReturnCode MapChange() {
  for ( int i = 1; i <= g_Engine.maxClients; i++ ) {
    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( i );
    AddToList( EHandle( pPlayer ) );
  }
 
  return HOOK_CONTINUE;
}

HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer ) {
  AddToList( EHandle( pPlayer ) );

  return HOOK_CONTINUE;
}

void AddToList( EHandle ePlayer ) {
  if ( !ePlayer.IsValid() )
    return;

  CBaseEntity@ pPlayer = ePlayer.GetEntity();

  if ( pPlayer is null )
    return;

  KeyValueBuffer@ p_PlayerInfo = g_EngineFuncs.GetInfoKeyBuffer( pPlayer.edict() );
  const string model = p_PlayerInfo.GetValue( "model" ).ToLowercase();

  // No paths allowed
  const int res = model.FindFirstOf( "/" );
  if ( res >= 0 )
    return;

  if ( g_ModelList.find( model ) < 0 )
    g_ModelList.insertLast( model );
}

void MapInit() {
  g_missing_list.resize( 0 );
  precachedModels.resize( 0 );

  for ( uint i = 0; i < g_ModelList.length(); i++ ) {
    string model = g_ModelList[i] + "/" + g_ModelList[i] + ".mdl";
    string tmodel = g_ModelList[i] + "/" + g_ModelList[i] + "t.mdl";
    string pic = g_ModelList[i] + "/" + g_ModelList[i] + ".bmp";
    
    if ( playerModelFileExists(tmodel) ) {
      g_Game.PrecacheGeneric( "models/player/" + tmodel );
    }

    if ( playerModelFileExists(model) ) {
      g_Game.PrecacheModel( "models/player/" + model );
      precachedModels.insertLast(g_ModelList[i]);
    } else {
        g_missing_list.insertLast(g_ModelList[i]);
    }

    if ( playerModelFileExists(pic) ) {
      g_Game.PrecacheGeneric( "models/player/" + pic );
    }
  }

  // share the list of precached models with other plugins
  dictionary keys;
  keys["targetname"] = "PlayerModelPrecacheDyn";
  for ( uint i = 0; i < precachedModels.size(); i++ ) {
    keys["$s_model" + i] = precachedModels[i];
  }
  g_EntityFuncs.CreateEntity( "info_target", keys, true );

  g_ModelList.resize( 0 );
}

bool playerModelFileExists(string path) {
    File@ pFile = g_FileSystem.OpenFile( g_pmodel_folder_addon + path, OpenFile::READ );
    
    if (pFile !is null && pFile.IsOpen()) {
        pFile.Close();
        return true;
    }
    
    @pFile = g_FileSystem.OpenFile( g_pmodel_folder_default + path, OpenFile::READ );
    
    if (pFile !is null && pFile.IsOpen()) {
        pFile.Close();
        return true;
    }
    
    return false;
}

void ListPrecachePlayerModels( const CCommand@ pArgs ) {
  CBasePlayer@ pCaller = g_ConCommandSystem.GetCurrentPlayer();

  g_PlayerFuncs.ClientPrint( pCaller, HUD_PRINTCONSOLE, "Currently dynamically precached playermodels:\n---------------------------------------------\n" );

  for ( uint i = 0; i < precachedModels.length(); i++ ) {
    g_PlayerFuncs.ClientPrint( pCaller, HUD_PRINTCONSOLE, precachedModels[i] + "\n" );
  }

  g_PlayerFuncs.ClientPrint( pCaller, HUD_PRINTCONSOLE, "---------------------------------------------\n" );
}

void ListNewPrecachePlayerModels( const CCommand@ pArgs ) {
  CBasePlayer@ pCaller = g_ConCommandSystem.GetCurrentPlayer();

  g_PlayerFuncs.ClientPrint( pCaller, HUD_PRINTCONSOLE, "Playermodels scheduled for precaching nextmap:\n----------------------------------------------\n" );

  for ( uint i = 0; i < g_ModelList.length(); i++ ) {
    g_PlayerFuncs.ClientPrint( pCaller, HUD_PRINTCONSOLE, g_ModelList[i] + "\n" );
  }

  g_PlayerFuncs.ClientPrint( pCaller, HUD_PRINTCONSOLE, "----------------------------------------------\n" );
}

void ListMissingPlayerModels( const CCommand@ pArgs ) {
  CBasePlayer@ pCaller = g_ConCommandSystem.GetCurrentPlayer();

  g_PlayerFuncs.ClientPrint( pCaller, HUD_PRINTCONSOLE, "Currently missing playermodels:\n-------------------------------\n" );

  for ( uint i = 0; i < g_missing_list.length(); i++ ) {
    g_PlayerFuncs.ClientPrint( pCaller, HUD_PRINTCONSOLE, g_missing_list[i] + "\n" );
  }

  g_PlayerFuncs.ClientPrint( pCaller, HUD_PRINTCONSOLE, "-------------------------------\n" );
}
