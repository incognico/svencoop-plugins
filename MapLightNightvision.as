// This (lag-free and fps-friendly) NV won't work on maps which use brighter lightstyles e.g. zombie_nights_v7, but on those you either don't need NV or the mapper did not intend for it to be used anyways.
const string SND_ON  = "items/flashlight2.wav";
const string SND_OFF = "player/hud_nightvision.wav";
const string LIGHT_DEFAULT = "m";
const string LIGHT_NVIS    = "z";
const float INTERVAL = 0.66f;
const RGBA NV_COLOR( 90, 190, 90, 100 );
const array<string> DISALLOWED_MAPS = { 'aom_*', 'aomdc_*', 'zombie_nights_*', 'sc5x_bonus', 'shitty_pubg', 'want*' };

uint g_nightriders = 0; // bitfield
bool disallowed = false;
CScheduledFunction@ g_nvsched;

void PluginInit()
{
  g_Module.ScriptInfo.SetAuthor("incognico");
  g_Module.ScriptInfo.SetContactInfo("https://discord.gg/qfZxWAd");
  
  g_Hooks.RegisterHook( Hooks::Player::ClientDisconnect, @ClientDisconnect );
  g_Hooks.RegisterHook( Hooks::Player::PlayerKilled, @PlayerKilled );

  disallowed = MapBlacklisted();

  @g_nvsched = g_Scheduler.SetInterval( "NvSched", INTERVAL, g_Scheduler.REPEAT_INFINITE_TIMES ); // only needed to restore the NV fade if other screen fades are received when NV is on
}

CClientCommand nightvision( "nightvision", "Toggles night vision on/off", @ToggleNV );

void MapInit()
{
  g_nightriders = 0;

  g_SoundSystem.PrecacheSound( SND_ON );
  g_SoundSystem.PrecacheSound( SND_OFF );

  if ( !disallowed )
    g_EngineFuncs.LightStyle(0, LIGHT_DEFAULT);

  disallowed = MapBlacklisted();
}

void ToggleNV( const CCommand@ args )
{
  if ( disallowed )
    return;

  CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();

  if ( pPlayer.IsAlive() )
  {
    if ( NvIsOn( pPlayer ) )
      RemoveNV( pPlayer );
    else
      WearNV( pPlayer );
  }
}

void NvSched()
{
  if ( disallowed )
    return;

  for ( int i = 1; i <= g_Engine.maxClients; ++i )
  {
    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);

    if ( pPlayer !is null && NvIsOn( pPlayer ) )
      NVMsg( pPlayer );
  }
}

void NVMsg( CBasePlayer@ pPlayer, const int fadetype = FFADE_STAYOUT, const int fadeduration = 0, const int fadehold = 0, const RGBA color = NV_COLOR )
{
  bool ison = NvIsOn(pPlayer);

  NetworkMessage nv( MSG_ONE_UNRELIABLE, NetworkMessages::ScreenFade, pPlayer.edict() );
    nv.WriteShort( fadeduration );
    nv.WriteShort( fadehold );
    nv.WriteShort( fadetype );
    nv.WriteByte( color.r );
    nv.WriteByte( color.g );
    nv.WriteByte( color.b );
    nv.WriteByte( (ison || fadetype == FFADE_IN) ? color.a : 0 );
  nv.End();

  NetworkMessage nvlght( MSG_ONE_UNRELIABLE, NetworkMessages::NetworkMessageType(12), pPlayer.edict() );
   nvlght.WriteByte( 0 );
   nvlght.WriteString( ison ? LIGHT_NVIS : LIGHT_DEFAULT );
  nvlght.End();
}

void WearNV( CBasePlayer@ pPlayer )
{
  g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_WEAPON, SND_ON, Math.RandomFloat(0.92f, 1.0f), ATTN_NORM, 0, 98 );

  SetNvOn( pPlayer );
  g_nvsched.SetNextCallTime( g_Engine.time + INTERVAL ); // stupid hack so NvSched() does not interfere with the on-fade
  NVMsg( pPlayer, FFADE_OUT|FFADE_STAYOUT, (1<<9), (1<<10) );
}

void RemoveNV( CBasePlayer@ pPlayer )
{
  g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_WEAPON, SND_OFF, Math.RandomFloat(0.92f, 1.0f), ATTN_NORM, 0, 98 );

  SetNvOff( pPlayer );
  NVMsg( pPlayer, FFADE_IN, (1<<9), (1<<4) );
}

HookReturnCode ClientDisconnect( CBasePlayer@ pPlayer )
{
  if ( NvIsOn( pPlayer ) )
    SetNvOff( pPlayer );
 
  return HOOK_CONTINUE;
}

HookReturnCode PlayerKilled( CBasePlayer@ pPlayer, CBaseEntity@, int )
{
  if ( NvIsOn( pPlayer ) )
    RemoveNV( pPlayer );
 
  return HOOK_CONTINUE;
}

void SetNvOn( CBasePlayer@ plr )
{
  const uint uiPlrBit = ( 1 << (plr.entindex() & 31) );
  g_nightriders |= uiPlrBit;
}

void SetNvOff( CBasePlayer@ plr )
{
  const uint uiPlrBit = ( 1 << (plr.entindex() & 31) );
  g_nightriders &= ~uiPlrBit;
}

bool NvIsOn( CBasePlayer@ plr )
{
  const uint uiPlrBit = ( 1 << (plr.entindex() & 31) );
  return g_nightriders & uiPlrBit == uiPlrBit;
}

const bool MapBlacklisted()
{
  bool disabled = false;

  for ( uint i = 0; i < DISALLOWED_MAPS.length(); i++ )
  {
    bool wildcard = false;
    string tmp = DISALLOWED_MAPS[i];

    if ( tmp.SubString( tmp.Length()-1, 1 ) == "*" )
    {
      wildcard = true;
      tmp = tmp.SubString( 0, tmp.Length()-1 );
    }

    if ( wildcard )
    {
      if ( tmp == string(g_Engine.mapname).SubString( 0, tmp.Length() ) )
      {
        disabled = true;
        break;
      }
    }
    else if ( string(g_Engine.mapname) == DISALLOWED_MAPS[i] )
    {
      disabled = true;
      break;
    }
  }

  return disabled;
}
