// config:
// files must exist before loading this script (touch first) !!!
const string g_FromSven = "scripts/plugins/store/_fromsven.txt";
const string g_ToSven   = "scripts/plugins/store/_tosven.txt";
const float delay       = 1.50f; // poll g_ToSven this often (sec.)
const float unlockAfter = 25.0f; // queue period from discord to sven so messages are not lost while players still connect
//////////

File@ f_FromSven;
File@ f_ToSven;
CScheduledFunction@ sf_Unlock = null;
CScheduledFunction@ sf_Status = null;
bool live = false;
bool lock = false;
int oldCount = 0;
dictionary ips;

const string g_key_caller = "$s_twlz_relay_caller";
const string g_key_msg    = "$s_twlz_relay_msg";

void PluginInit() {
  g_Module.ScriptInfo.SetAuthor("incognico");
  g_Module.ScriptInfo.SetContactInfo("https://discord.gg/qfZxWAd");

  g_Hooks.RegisterHook(Hooks::Game::MapChange, @MapChange);
  g_Hooks.RegisterHook(Hooks::Game::EntityCreated, @EntityCreated);
  g_Hooks.RegisterHook(Hooks::Player::ClientSay, @ClientSay);
  g_Hooks.RegisterHook(Hooks::Player::ClientConnected, @ClientConnected);
  g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @ClientPutInServer);
  g_Hooks.RegisterHook(Hooks::Player::ClientDisconnect, @ClientDisconnect);

  TruncateFromSven();

  g_Scheduler.SetInterval( "ChatPoll", delay, g_Scheduler.REPEAT_INFINITE_TIMES );
}

void PluginExit() {
  if ( f_FromSven !is null && f_FromSven.IsOpen() )
    f_FromSven.Close();

  if ( f_ToSven !is null && f_ToSven.IsOpen() )
    f_ToSven.Close();
}

void MapStart() {
  if ( live ) {
    g_Scheduler.SetTimeout( "TruncateFromSven", delay );
    @sf_Status = g_Scheduler.SetTimeout( "ServerStatus", delay * 5 );
    @sf_Unlock = g_Scheduler.SetTimeout( "Unlock", unlockAfter );
  }

  live = true;
}

void Lock() {
  g_Scheduler.RemoveTimer( sf_Unlock );
  lock = true;
}

void Unlock() {
  lock = false;
  //g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "[Info] Discord is now linked to in-game chat.\n" );
}

void ServerStatus() {
  const string count  = g_PlayerFuncs.GetNumPlayers() >= oldCount ? g_PlayerFuncs.GetNumPlayers() : oldCount;
  const string append = "status " + g_Engine.mapname + " " + count + " " + g_EngineFuncs.CVarGetString( "hostname" ) + "\n";

  AppendFromSven( append );

  oldCount = g_PlayerFuncs.GetNumPlayers();
}

void ChatPoll() {
  if ( !lock )
    FlushToSven();
}

void FlushFromSven() {
  if ( f_FromSven !is null && f_FromSven.IsOpen() )
    f_FromSven.Close();

  @f_FromSven = g_FileSystem.OpenFile( g_FromSven, OpenFile::APPEND );
}

void TruncateFromSven() {
  if ( f_FromSven !is null && f_FromSven.IsOpen() )
    f_FromSven.Close();

  @f_FromSven = g_FileSystem.OpenFile( g_FromSven, OpenFile::WRITE );
  f_FromSven.Write( null );
  f_FromSven.Close();

  // file is now truncated, immediately open for appending again!
  FlushFromSven();
}

void FlushToSven() {
  if ( f_ToSven !is null && f_ToSven.IsOpen() )
    f_ToSven.Close();

  bool truncate = false;

  @f_ToSven = g_FileSystem.OpenFile( g_ToSven, OpenFile::READ );

  while ( !f_ToSven.EOFReached() ) {
    string sLine;
    f_ToSven.ReadLine( sLine );

    if ( sLine.IsEmpty() )
      continue;

    // TODO: Split lines, 127 chars max, so maybe split at 124 + \n and maybe max. allow 3 lines
    g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, sLine + "\n" );

    truncate = true;
  }

  f_ToSven.Close();

  if ( truncate )
    TruncateToSven();
}
  
void TruncateToSven() {
  @f_ToSven = g_FileSystem.OpenFile( g_ToSven, OpenFile::WRITE );
  f_ToSven.Write( null );
  f_ToSven.Close();
}

void AppendFromSven( string append ) {
  f_FromSven.Write( "" + UnixTimestamp() + " " + append );
  FlushFromSven();
}

HookReturnCode MapChange() {
  Lock();

  bool removed = true;

  if ( @sf_Status !is null )
    removed = sf_Status.HasBeenRemoved();

  if ( removed ) {
    oldCount = g_PlayerFuncs.GetNumPlayers();

    AppendFromSven( "mapend " + g_Engine.mapname + " " + oldCount + "\n" );

    // do cleanup, mainly to catch previous ghost leavers
    array<string> active;
    for ( int i = 1; i <= g_Engine.maxClients; i++ )
    {
      CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( i );

      if ( pPlayer !is null /* && pPlayer.IsConnected() */ )
        active.insertLast( g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) );
    }

    array<string>@ ipKeys = ips.getKeys();
    for ( uint i = 0; i < ipKeys.length(); i++ )
    {
      if ( active.find( ipKeys[i] ) < 0 )
      {
        if ( ( ipKeys[i].SubString(0, 8) ) == "STEAM_0:" )
          AppendFromSven( "<-><\\orphan><><" + ipKeys[i] + "> has left the game\n" );

        ips.delete( ipKeys[i] );
      }
    }

    active.resize( 0 );
  }
  else { // if the status scheduler is still running it was a "toggle" map restart, do nothing, pretend no map change happened
    g_Scheduler.RemoveTimer( sf_Status );
  }

  live = true;

  return HOOK_CONTINUE;
}

HookReturnCode ClientSay( SayParameters@ pParams ) {
  const CCommand@ pArgs = pParams.GetArguments();

  if ( pParams.ShouldHide || pArgs.ArgC() < 1 )
    return HOOK_CONTINUE;

  const string message = pParams.GetCommand();
  CBasePlayer@ pPlayer = pParams.GetPlayer();
  const string steamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
  const bool observer  = pPlayer.GetObserver().IsObserver();
  const bool alive     = pPlayer.IsAlive();
  const bool survival  = g_SurvivalMode.IsActive();
  const string status  = ( observer ? "observer" : ( survival ? ( alive ? "alive" : "dead" ) : "player" ) );

  if ( !message.IsEmpty() ) {
    AppendFromSven( "<" + status + "><" + pPlayer.pev.netname + "><" + string(ips[steamId]) + "><" + steamId + "> " + message + "\n" );
  }

  return HOOK_CONTINUE;
}

HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer ) {
  const string steamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );

  ips[steamId] = string( ips[pPlayer.pev.netname] );

  if ( ips.exists( pPlayer.pev.netname ) )
    ips.delete( pPlayer.pev.netname );

  AppendFromSven( "<+><" + pPlayer.pev.netname + "><" + string(ips[steamId]) + "><" + steamId + "> has joined the game\n" );

  return HOOK_CONTINUE;
}

HookReturnCode ClientDisconnect( CBasePlayer@ pPlayer ) {
  const string steamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );

  AppendFromSven( "<-><" + pPlayer.pev.netname + "><" + string(ips[steamId]) + "><" + steamId + "> has left the game\n" );

  if ( ips.exists( steamId ) )
    ips.delete( steamId );

  return HOOK_CONTINUE;
}

HookReturnCode EntityCreated( CBaseEntity@ pEntity ) {
  if ( pEntity is null || pEntity.GetClassname().Compare( "info_target" ) != 0 )
    return HOOK_CONTINUE;

  // EntityCreated -> At this point the entity is not spawned yet and may not be fully initialized, so no custom KeyValues yet...
  g_Scheduler.SetTimeout( "RelaySay", delay / 2, EHandle( pEntity ) );

  return HOOK_CONTINUE;
}

void RelaySay( EHandle hEntity ) {
  if ( !hEntity )
    return;

  CBaseEntity@ pEntity     = hEntity.GetEntity();
  CustomKeyvalues@ pCustom = pEntity.GetCustomKeyvalues();

  if ( pCustom.HasKeyvalue( g_key_caller ) && pCustom.HasKeyvalue( g_key_msg ) ) {
    const string caller  = pCustom.GetKeyvalue( g_key_caller ).GetString();
          string message = pCustom.GetKeyvalue( g_key_msg ).GetString();

    g_EntityFuncs.Remove( pEntity );

    message = message.Replace( "\n", "" );

    if ( !caller.IsEmpty() && !message.IsEmpty() )
      AppendFromSven( "plugin " + caller + " " + message + "\n" );
  }
}

HookReturnCode ClientConnected( edict_t@, const string& in szPlayerName, const string& in szIPAddress, bool& out, string& out ) {
  ips[szPlayerName] = szIPAddress;

  return HOOK_CONTINUE;
}
