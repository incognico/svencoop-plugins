// TODO:
// - trail vs. semiclip stuck?
// - trail menu (lol)

#include "inc/RelaySay"
#include "inc/MetaChads"

const bool onbydefault = true;

const string g_classname = "star_trail";
const string g_sprtrail  = "sprites/smallplain.spr";
const string PREFIX      = "[Trails] ";
const float PHI          = 1.618033988749895f;

const dictionary wheel = {
{'red', 0.001}, {'orange', 30},  {'yellow', 60},   {'cgreen', 90},
{'green', 120}, {'sgreen', 150}, {'cyan', 180},    {'azure', 210},
{'blue', 240},  {'violet', 270}, {'magenta', 300}, {'rose', 330}
};

const Vector2D V(const float x, const float y) { return Vector2D(x, y); }
const dictionary palettes = {
{'anime',       array<Vector2D> = {V(5,35),    V(7,30),    V(30,10),   V(46,59),   V(44,77),   V(4,69)}},
{'beach',       array<Vector2D> = {V(152,27),  V(48,32),   V(2,59),    V(41,64),   V(150,37)}},
{'cyberpunk',   array<Vector2D> = {V(284,81),  V(304,100), V(183,95),  V(215,85)}},
{'forest',      array<Vector2D> = {V(84,91),   V(87,89),   V(68,87),   V(70,87),   V(73,88)}},
{'goldfish',    array<Vector2D> = {V(190,55),  V(177,24),  V(70,11),   V(26,80),   V(25,100)}},
{'interceptor', array<Vector2D> = {V(214,69),  V(216,2),   V(4,94),    V(49,86),   V(54,74)}},
{'intersex',    array<Vector2D> = {V(51,100),  V(283,100)}},
{'lgbt',        array<Vector2D> = {V(0,100),   V(33,100),  V(56,100),  V(134,100), V(224,100), V(292,100)}},
{'light',       array<Vector2D> = {V(351,33),  V(13,30),   V(36,31),   V(79,16),   V(159,11)}},
{'metro',       array<Vector2D> = {V(345,92),  V(150,100), V(192,100), V(21,78),   V(44,85)}},
{'moss',        array<Vector2D> = {V(106,100), V(133,100), V(112,99),  V(121,98)}},
{'neonpunk',    array<Vector2D> = {V(283,100), V(300,100), V(70,72),   V(198,100), V(234,100)}},
{'pansexual',   array<Vector2D> = {V(331,87),  V(51,100),  V(205,100)}},
{'pastel',      array<Vector2D> = {V(125,39),  V(57,41),   V(199,23),  V(248,41),  V(0,45)}},
{'seaweed',     array<Vector2D> = {V(122,58),  V(158,55),  V(146,71),  V(164,100), V(171,86)}},
{'sugar',       array<Vector2D> = {V(311,86),  V(339,89),  V(32,99),   V(49,100),  V(67,90)}},
{'trap',        array<Vector2D> = {V(197,66),  V(0,0),     V(348,32)}},
{'wheel',       array<Vector2D> = {V(0,100),   V(30,100),  V(60,100),  V(90,100),  V(120,100), V(150,100), V(180,100), V(210,100), V(240,100), V(270,100), V(300,100), V(330,100)}},
{'white',       array<Vector2D> = {V(0,0)}},
{'winter',      array<Vector2D> = {V(232,87),  V(0,0),     V(207,62),  V(207,55),  V(207,42),  V(200,16)}}
};

string scoremessage, rscoremessage;
CScheduledFunction@ g_statsched = null;
bool safe = false;

class PlayerPersist {
  bool enabled;
  float hue = -1.0f;
  bool usingpalette;
  string palette;
  bool glow = true;
  bool dlight = false;
}
dictionary g_persist;

class PlayerState : PlayerPersist {
  PlayerState() {}
  PlayerState(const PlayerPersist& in copy) {
    enabled      = copy.enabled;
    hue          = copy.hue;
    usingpalette = copy.usingpalette;
    palette      = copy.palette;
    glow         = copy.glow;
    dlight       = copy.dlight;
  }

  bool ishere;
  string name;
  float nexttrailthink;
  float nextglowthink;
  uint trailcount;
  uint trailscore;
  uint trailhighscore;
  uint8 lastlife;
  int trailent = -1;
  float seed = Math.RandomFloat(0.001f, 0.999f);
  uint8 palettepos;
  Vector2D lasths;
}
array<PlayerState> g_player_states;

class EndStats {
  string name;
  uint score;
}
array<EndStats> g_end;

CClientCommand _trail("trail", "trail commands", @consoleCmd);

void PluginInit() {
  g_Module.ScriptInfo.SetAuthor("incognico");
  g_Module.ScriptInfo.SetContactInfo("https://discord.gg/qfZxWAd");

  g_Hooks.RegisterHook(Hooks::Game::MapChange, @MapChange);
  g_Hooks.RegisterHook(Hooks::Player::ClientDisconnect, @ClientDisconnect);
  g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @ClientPutInServer);
  g_Hooks.RegisterHook(Hooks::Player::ClientSay, @ClientSay);
  g_Hooks.RegisterHook(Hooks::Player::PlayerKilled, @PlayerKilled);

  g_player_states.resize(g_Engine.maxClients+1);
}

void MapInit() {
  g_player_states.resize(0);
  g_player_states.resize(g_Engine.maxClients+1);
  
  g_CustomEntityFuncs.RegisterCustomEntity("CustomPlayerTrail", g_classname);
  g_Game.PrecacheOther(g_classname);

  g_Game.PrecacheModel(g_sprtrail);

  if (!safe)
    g_Hooks.RegisterHook(Hooks::Player::PlayerPostThink, @PlayerPostThink);
  safe = true;
}

void MapStart() {
  if (!rscoremessage.IsEmpty()) {
    RelaySay("score\\" + rscoremessage);
    rscoremessage = '';
  }

  @g_statsched = g_Scheduler.SetTimeout( "PrintStats", 40.0f, scoremessage);
}

HookReturnCode MapChange() {
  if (g_statsched !is null && !g_statsched.HasBeenRemoved()) {
    g_Scheduler.RemoveTimer(g_statsched);
    return HOOK_CONTINUE;
  }

  @g_statsched = null;
  scoremessage = rscoremessage = '';
  g_end.resize(0);

  for (int i = 1; i <= g_Engine.maxClients; i++) {
    CBasePlayer@ plr = g_PlayerFuncs.FindPlayerByIndex(i);

    if (plr !is null && plr.IsConnected() && IsTrailEnabled(plr))
      KillTrail(i);
  }

  CBaseEntity@ ent = null;
  while ( ( @ent = g_EntityFuncs.FindEntityByClassname( ent, g_classname ) ) !is null )
    g_EntityFuncs.Remove( ent );

  for (uint i = 0; i < g_player_states.length(); i++) {
    PlayerState@ state = g_player_states[i];

    if (state.trailhighscore < 5)
      continue;

    EndStats data;
    data.name  = state.name;
    data.score = state.trailhighscore;

    g_end.insertLast(data);
  }

  if (g_end.length() == 0)
    return HOOK_CONTINUE;

  g_end.sort(function(a,b) { return a.score > b.score; });

  if (g_end.length() > 5)
    g_end.resize(5);

  string message = "Trail highscores for the previous map:\n-------------------------------------------\n";

  for (uint i = 0; i < g_end.length(); i++) {
    message += g_end[i].name + " ==> " + g_end[i].score + "\n";

    if (i == 0)
      rscoremessage = "" + g_end[i].score + "\\" + g_end[i].name;
    else if (g_end[i].score == g_end[0].score)
      rscoremessage += "\\" + g_end[i].name;
  }

  scoremessage = message;
  g_end.resize(0);

  return HOOK_CONTINUE;
}

HookReturnCode ClientSay(SayParameters@ pParams) {
  CBasePlayer@ plr     = pParams.GetPlayer();
  const CCommand@ args = pParams.GetArguments();

  if (doCommand(plr, args, false))
    pParams.ShouldHide = true;

  return HOOK_CONTINUE;
}

void consoleCmd(const CCommand@ args) {
  CBasePlayer@ plr = g_ConCommandSystem.GetCurrentPlayer();
  doCommand(plr, args, true);
}

const bool doCommand(CBasePlayer@ plr, const CCommand@ args, bool inConsole) {
  if (args.ArgC() > 0 && (args[0] == ".trail" || args[0] == "trail")) {
    if (!safe) {
      g_PlayerFuncs.ClientPrint(plr, HUD_PRINTTALK, PREFIX + "Plugin was reloaded and needs to precache first, please wait for a map change.\n");
      return true;
    }

    if (args.ArgC() == 1 && !IsTrailEnabled(plr)) {
      TrailEnable(plr);
      g_PlayerFuncs.ClientPrint(plr, HUD_PRINTTALK, PREFIX + "Enabled.\n");
    }
    else if (args.ArgC() == 2) {
      const int idx = plr.entindex();
      bool usingpalette = false;
      
      string arg = args[1].ToLowercase();

      if (arg == "on") {
        TrailEnable(plr);
        g_PlayerFuncs.ClientPrint(plr, HUD_PRINTTALK, PREFIX + "Enabled.\n");
      }
      else if (arg == "off") {
        TrailDisable(plr);
        g_PlayerFuncs.ClientPrint(plr, HUD_PRINTTALK, PREFIX + "Disabled.\n");
      }
      else if (arg == "info") {
        if (g_player_states[idx].usingpalette)
          g_PlayerFuncs.ClientPrint(plr, HUD_PRINTTALK, PREFIX + "Color hue is currently automatically managed by palette: " + string(g_player_states[idx].palette).ToUppercase() + ". Glow is " + (g_player_states[idx].glow ? "ON" : "OFF") + ". DLight is " + (g_player_states[idx].dlight ? "ON" : "OFF") + ".\n");
        else
          g_PlayerFuncs.ClientPrint(plr, HUD_PRINTTALK, PREFIX + "Color hue is currently set to: " + (g_player_states[idx].hue > -1.0f ? formatFloat(floor(g_player_states[idx].hue*360+0.5f)) : "RANDOM") + ". Glow is " + (g_player_states[idx].glow ? "ON" : "OFF")  + ". DLight is " + (g_player_states[idx].dlight ? "ON" : "OFF") + ".\n");
      }
      else if (arg == "glow" || arg == "noglow") {
        if (arg.Length() == 4)
          g_player_states[idx].glow = true;
        else
          g_player_states[idx].glow = false;

        g_PlayerFuncs.ClientPrint(plr, HUD_PRINTTALK, PREFIX + "Glow is now " + (g_player_states[idx].glow ? "ON" : "OFF") + ".\n");
      }
      else if (arg == "dlight" || arg == "nodlight") {
        if (arg.Length() == 6)
          g_player_states[idx].dlight = true;
        else
          g_player_states[idx].dlight = false;

        g_PlayerFuncs.ClientPrint(plr, HUD_PRINTTALK, PREFIX + "DLight is now " + (g_player_states[idx].dlight ? "ON" : "OFF") + ".\n");
      }
      else if (arg == "r" || arg == "random" || arg == "-1") {
        g_player_states[idx].hue = -1.0f;
        g_PlayerFuncs.ClientPrint(plr, HUD_PRINTTALK, PREFIX + "Color hue is now set to: RANDOM.\n");
        TrailEnable(plr);
      }
      else if (palettes.exists(arg)) {
        usingpalette = true;
        g_player_states[idx].palette = arg;
        g_player_states[idx].palettepos = 0;
        g_PlayerFuncs.ClientPrint(plr, HUD_PRINTTALK, PREFIX + "Color hue is now automatically managed by palette: " + string(g_player_states[idx].palette).ToUppercase() + ".\n");
        TrailEnable(plr);
      }
      else if (wheel.exists(args[1].ToLowercase())) {
        g_player_states[idx].hue = float(wheel[arg])/359.99f;
        g_PlayerFuncs.ClientPrint(plr, HUD_PRINTTALK, PREFIX + "Color hue is now set to: " + formatFloat(floor(g_player_states[idx].hue*360+0.5f)) + " (" + arg + ").\n");
        TrailEnable(plr);
      }
      else if (isNumeric(arg) && atoui(arg) >= 0 && atoui(arg) <= 360) {
        const float hue = Math.clamp(0.001f, 0.999f, atof(arg)/359.99f);
        g_player_states[idx].hue = hue;
        g_PlayerFuncs.ClientPrint(plr, HUD_PRINTTALK, PREFIX + "Color hue is now set to: " + formatFloat(floor(hue*360+0.5f)) + ".\n");
        TrailEnable(plr);
      }
      else {
        g_PlayerFuncs.ClientPrint(plr, inConsole ? HUD_PRINTCONSOLE : HUD_PRINTTALK, PREFIX + "Usage: .trail on/off/info/[no]glow/[no]dlight/0-360/r[andom]/<colorname>/<palettename>\n");
      }

      g_player_states[idx].usingpalette = usingpalette;
    }
    else {
      if (!IsTrailEnabled(plr))
        TrailEnable(plr);

      g_PlayerFuncs.ClientPrint(plr, inConsole ? HUD_PRINTCONSOLE : HUD_PRINTTALK, PREFIX + "Usage: .trail on/off/info/[no]glow/[no]dlight/0-360/r[andom]/<colorname>/<palettename> (see palette names in console).\n");
      g_PlayerFuncs.ClientPrint(plr, HUD_PRINTCONSOLE, "AVAILABLE TRAIL PALETTES\n------------------------\n");

      string msg;
      array<string> keys = palettes.getKeys();
      keys.sortAsc();

      for (uint i = 1; i < keys.length()+1; ++i) {
        msg += keys[i-1] + " | ";

        if (i % 5 == 0) {
          msg.Resize(msg.Length() -2);
          g_PlayerFuncs.ClientPrint(plr, HUD_PRINTCONSOLE, msg);
          g_PlayerFuncs.ClientPrint(plr, HUD_PRINTCONSOLE, "\n");
          msg = "";
        }
      }

      if (msg.Length() > 2) {
        msg.Resize(msg.Length() -2);
        g_PlayerFuncs.ClientPrint(plr, HUD_PRINTCONSOLE, msg + "\n");
      }

      g_PlayerFuncs.ClientPrint(plr, HUD_PRINTCONSOLE, "\n");
    }

    UpdatePersist(plr);

    return true;
  }

  return false;
}

const bool isNumeric(const string arg) {
  if (arg.Length() == 0)
    return false;

  if (!isdigit(arg[0]) && arg[0] != "-")
    return false;

  for (uint i = 1; i < arg.Length(); i++) {
    if (!isdigit(arg[i]))
      return false;
  }

  return true;
}

void MetaHookSpecial(EHandle eplr) {
  if (!eplr)
    return;

  CBasePlayer@ plr = cast<CBasePlayer@>(eplr.GetEntity());

  if (IsMetaChad(plr)) {
    g_player_states[plr.entindex()].dlight = true;
    g_PlayerFuncs.ClientPrint(plr, HUD_PRINTTALK, PREFIX + "DLight was auto-enabled because you are a MetaChad.\n");
  }
}

HookReturnCode ClientPutInServer(CBasePlayer@ plr) {
  const string steamid = g_EngineFuncs.GetPlayerAuthId(plr.edict());
  const int idx = plr.entindex();

  if (g_persist.exists(steamid)) {
    g_player_states[idx] = PlayerState(cast<PlayerPersist@>(g_persist[steamid]));

    if (g_player_states[idx].enabled)
      TrailEnable(plr);
  }
  else {
    g_player_states[idx] = PlayerState();

    if (onbydefault)
      TrailEnable(plr);

    g_Scheduler.SetTimeout("MetaHookSpecial", 2.0f, EHandle(plr));
  }

  g_player_states[idx].ishere = true;

  return HOOK_CONTINUE;
}

HookReturnCode ClientDisconnect(CBasePlayer@ plr) {
  const int idx = plr.entindex();

  KillTrail(idx);

  g_player_states[idx].ishere = false;

  return HOOK_CONTINUE;
}

HookReturnCode PlayerKilled(CBasePlayer@ plr, CBaseEntity@, int) {
  KillTrail(plr.entindex());

  return HOOK_CONTINUE;
}

HookReturnCode PlayerPostThink(CBasePlayer@ plr) {
  if (IsTrailEnabled(plr) && plr.IsAlive())
    Trail(plr);

  return HOOK_CONTINUE;
}

void UpdatePersist(CBasePlayer@ plr) {
  g_persist[g_EngineFuncs.GetPlayerAuthId(plr.edict())] = cast<PlayerPersist@>(g_player_states[plr.entindex()]);
}

void RestoreRenderMode(CBasePlayer@ plr) {
  plr.pev.rendermode  = plr.m_iOriginalRenderMode;
  plr.pev.renderfx    = plr.m_iOriginalRenderFX;
  plr.pev.renderamt   = plr.m_flOriginalRenderAmount;
  plr.pev.rendercolor = plr.m_vecOriginalRenderColor;
}

const bool IsFast(CBasePlayer@ plr, const uint speed) {
  //return (speed > int((plr.GetMaxSpeed()*pow(PHI, PHI))*0.1f)); // easier
  return (speed > uint((plr.GetMaxSpeed()*PHI*PHI)*0.1f));
}

const float ColorValue(const uint trailcount, const uint speed) {
  return Math.min(1.0f, (trailcount/(PHI*32))+(speed*0.01f));
}

void Trail(CBasePlayer@ plr) {
  const int idx = plr.entindex();
  const bool glowstuff = (g_player_states[idx].glow && g_player_states[idx].trailcount > 1) ? true : false;

  if( !plr.IsMoving() || plr.pev.FlagBitSet(FL_FROZEN) ) {
    if (glowstuff)
      RestoreRenderMode(plr);
    KillTrail(idx);
  }
  else {
    const uint speed = Math.max(uint(0), uint(floor(plr.pev.velocity.Length2D()-plr.pev.basevelocity.Length2D()+0.5f)*0.1f));
    const uint tresh = uint(floor(plr.GetMaxSpeed()*(((PHI-1)*2))*0.1f)); // harder
    //const uint tresh = uint(floor(plr.GetMaxSpeed()*(((PHI-1)*3)*(PHI-1)))*0.1f); // easier

    if ( speed < tresh ) {
      if (glowstuff)
        RestoreRenderMode(plr);
      KillTrail(idx);
      return;
    }

    if (glowstuff && g_Engine.time > g_player_states[idx].nextglowthink) {
      if (IsFast(plr, speed)) {
        plr.pev.rendermode = kRenderTransAdd; // kRenderTransAlpha
        plr.pev.renderfx   = kRenderFxPulseFastWide;
        plr.pev.renderamt  = 196.0f;
      }
      else {
        plr.pev.rendermode = kRenderNormal;
        plr.pev.renderfx   = kRenderFxGlowShell;
        plr.pev.renderamt  = Math.min(32.0f, g_player_states[idx].trailcount*PHI);

        const RGBA gcolor = FetchColor(g_player_states[idx].lasths.x, g_player_states[idx].lasths.y, ColorValue(g_player_states[idx].trailcount, speed));
        plr.pev.rendercolor.x = gcolor.r;
        plr.pev.rendercolor.y = gcolor.g;
        plr.pev.rendercolor.z = gcolor.b;
      }

      g_player_states[idx].nextglowthink = g_Engine.time + 0.2f;
    }

    if ( g_Engine.time < g_player_states[idx].nexttrailthink )
      return;

    float hue, saturation;

    if (g_player_states[idx].usingpalette) {
      const array<Vector2D> colors = cast<array<Vector2D>>(palettes[g_player_states[idx].palette]);
      hue = g_player_states[idx].hue = Math.clamp(0.001f, 0.999f, colors[g_player_states[idx].palettepos].x/359.99f);
      saturation = colors[g_player_states[idx].palettepos].y/100;

      if (++g_player_states[idx].palettepos >= colors.length())
        g_player_states[idx].palettepos = 0;
    }
    else {
      hue = g_player_states[idx].hue > 0.000f ? Math.clamp(0.001f, 0.999f, g_player_states[idx].hue + Math.RandomFloat(-0.0014f, 0.0014f)) : (g_player_states[idx].seed = (g_player_states[idx].seed + PHI-1) % 1);
      saturation = IsFast(plr, speed) ? 1.0f : Math.RandomFloat(PHI-1, 1.0f);
    }

    g_player_states[idx].lasths = V(hue, saturation);

    const RGBA color = FetchColor(hue, saturation, ColorValue(g_player_states[idx].trailcount, speed));
    const uint8 life = g_player_states[idx].lastlife = Math.clamp(10, 255, uint(floor((speed*(PHI/2)+g_player_states[idx].trailcount)*(3/PHI)/(g_player_states[idx].lastlife == 0 ? 3/PHI : 1))));
    //g_player_states[idx].lastlife = uint8(floor((life*(PHI-1))+0.5f)); // hack: shorther trails

    if (g_player_states[idx].trailent > 0) {
      CustomPlayerTrail@ trail = GetTrailEnt(idx);
      if (trail !is null)
        trail.Detach(false);
    }

    CreateTrailEnt(plr);

    NetworkMessage m( MSG_ALL, NetworkMessages::SVC_TEMPENTITY );
      m.WriteByte( TE_BEAMFOLLOW );
      m.WriteShort( g_player_states[idx].trailent );
      m.WriteShort( g_EngineFuncs.ModelIndex( g_sprtrail ) );
      m.WriteByte( life );
      m.WriteByte( IsFast(plr, speed) ? 6 : 4 );
      m.WriteByte( color.r );
      m.WriteByte( color.g );
      m.WriteByte( color.b );
      m.WriteByte( color.a );
    m.End();

    const uint count = ++g_player_states[idx].trailcount;
    const uint score = life/10;

    g_player_states[idx].trailscore += score;

    if ( count > 1 ) {
      HUDTextParams txtPrms;
      txtPrms.r1 = 255;
      txtPrms.g1 = 0;
      txtPrms.b1 = 255;
      txtPrms.a1 = 160;
      txtPrms.x = -1.0f;
      txtPrms.y = 0.9f;
      txtPrms.effect = 0;
      txtPrms.fadeinTime = 0.1f;
      txtPrms.fadeoutTime = 0.5f;
      txtPrms.holdTime = 1.4f;
      txtPrms.channel = 1;

      string hudtext;

      switch ( count ) {
        case 2:
          hudtext = "~";
          break;
        default:
          hudtext = "" + count + " (+" + score + ")";
      }

      g_PlayerFuncs.HudMessage( plr, txtPrms, hudtext );
    }

    g_player_states[idx].nexttrailthink = g_Engine.time + (life/10);
  }
}

void TrailEnable(CBasePlayer@ plr) {
  g_player_states[plr.entindex()].enabled = true;
}

void TrailDisable(CBasePlayer@ plr) {
  const int idx = plr.entindex();

  KillTrail(idx);
  g_player_states[idx].enabled = false;
}

const bool IsTrailEnabled(CBasePlayer@ plr) {
  return g_player_states[plr.entindex()].enabled;
}

void CreateTrailEnt(CBasePlayer@ plr) {
  const int idx = plr.entindex();

  CBaseEntity@ attachment = g_EntityFuncs.Create(g_classname, plr.pev.origin, plr.pev.angles, true, plr.edict());
    attachment.pev.iuser1   = int(g_player_states[idx].trailcount);
    attachment.pev.effects |= EF_NOINTERP;
  g_EntityFuncs.DispatchSpawn(attachment.edict());

  g_player_states[idx].trailent = attachment.entindex();
}

CustomPlayerTrail@ GetTrailEnt (const int idx) {
  CBaseEntity@ trailent = g_EntityFuncs.Instance(g_player_states[idx].trailent);
  return cast<CustomPlayerTrail@>(g_EntityFuncs.CastToScriptClass(@trailent));
}

void KillTrail(const int idx) {
  if (g_player_states[idx].trailcount > 0) {
    CustomPlayerTrail@ trail = GetTrailEnt(idx);
    if (trail !is null)
      trail.Detach(true);

    g_player_states[idx].trailent = -1;

    if (g_player_states[idx].trailscore > g_player_states[idx].trailhighscore) {
      CBasePlayer@ plr = g_PlayerFuncs.FindPlayerByIndex(idx);
      if (plr !is null)
        g_player_states[idx].name = plr.pev.netname;

      g_player_states[idx].trailhighscore = g_player_states[idx].trailscore;

      if ( g_player_states[idx].trailcount > 2 ) {
        HUDTextParams txtPrms;
        txtPrms.r1 = 255;
        txtPrms.g1 = 0;
        txtPrms.b1 = 255;
        txtPrms.a1 = 160;
        txtPrms.x  = -1.0f;
        txtPrms.y  = 0.9f;
        txtPrms.effect = 0;
        txtPrms.fadeinTime  = 0.1f;
        txtPrms.fadeoutTime = 0.5f;
        txtPrms.holdTime    = 1.4f;
        txtPrms.channel     = 1;

        g_PlayerFuncs.HudMessage( plr, txtPrms, ">>>  " + g_player_states[idx].trailcount + " (" + g_player_states[idx].trailscore + ")  <<<" );
      }
    }

    g_player_states[idx].trailscore = g_player_states[idx].trailcount = g_player_states[idx].lastlife = 0;
  }

  g_player_states[idx].nexttrailthink = g_Engine.time + 0.1f;
}

void PrintStats (const string message) {
  if (!message.IsEmpty()) {
    g_PlayerFuncs.ClientPrintAll(HUD_PRINTCONSOLE, "\n");

    const array<string>@ msg = message.Split("\n");
    for (uint i = 0; i < msg.length(); i++)
      g_PlayerFuncs.ClientPrintAll(HUD_PRINTCONSOLE, msg[i] + "\n");

    for (int i = 1; i <= g_Engine.maxClients; i++) {
      CBasePlayer@ plr = g_PlayerFuncs.FindPlayerByIndex(i);

      if (plr !is null && plr.IsConnected() && IsTrailEnabled(plr))
        g_PlayerFuncs.ShowMessage(plr, message);
    }
  }
}

const RGBA FetchColor(const float h, const float s, const float v) {
  const uint8 h_i = uint8(h*6);
  const float f = h*6 - h_i;
  const float p = v * (1 - s);
  const float q = v * (1 - f*s);
  const float t = v * (1 - (1 - f)*s);

  float r, g, b;
  r = g = b = 256.0f;

  switch (h_i) {
    case 0: r = v; g = t; b = p; break;
    case 1: r = q; g = v; b = p; break;
    case 2: r = p; g = v; b = t; break;
    case 3: r = p; g = q; b = v; break;
    case 4: r = t; g = p; b = v; break;
    case 5: r = v; g = p; b = q; break;
  }

  return RGBA(uint8(floor(r*255)), uint8(floor(g*255)), uint8(floor(b*255)));
}

class CustomPlayerTrail : ScriptBaseEntity {
  //private string model    = g_ClassicMode.IsEnabled() ? "models/twlz/star64.mdl" : "models/twlz/star.mdl"; // TODO: Detect Classicu
  private string model    = "models/twlz/star.mdl";
  private string sprglow  = "sprites/glow07x.spr";
  private string sprsmoke = "sprites/steam1.spr";
  private string sparksnd = "buttons/spark1.wav";
  private string fuzzsnd  = "kh6/fuzz.wav";
  private bool isfirst  = false;
  private bool islast   = false;
  private bool detached = false;
  private bool finished = false;
  private bool revived  = false;
  private bool rambo    = false;
  private bool dlight   = false;
  private float killtime    = 0.0f;
  private float nextdmgtime = 0.0f;
  private float lasthue     = 0.0f;
  private float maxvelocity = 4096.0f;
  private uint8 life = 0;
  private int owneridx = -1;
  private Vector lastorigin    = g_vecZero;
  private Vector lastplrorigin = g_vecZero;
  private Vector2D lasths;

  void Precache() {
    g_Game.PrecacheModel( model );
    g_Game.PrecacheModel( sprglow );
    g_Game.PrecacheModel( sprsmoke );

    g_Game.PrecacheGeneric("sound/" + sparksnd);
    g_Game.PrecacheGeneric("sound/" + fuzzsnd);
    g_SoundSystem.PrecacheSound(fuzzsnd);
    g_SoundSystem.PrecacheSound(sparksnd);
    
    g_Game.PrecacheMonster( "monster_cockroach", false );
  }

  void Spawn() {
    if (self.pev.owner is null) {
      g_EntityFuncs.Remove( self );
      return;
    }

    self.Precache();

    g_EntityFuncs.SetModel( self, model );

    if (self.pev.iuser1 == 0) {
      g_EntityFuncs.SetSize( self.pev, g_vecZero, g_vecZero );
      g_EntityFuncs.SetOrigin( self, self.pev.owner.vars.origin );

      @self.pev.aiment    = @self.pev.owner;
      self.pev.movetype   = MOVETYPE_FOLLOW;
      self.pev.solid      = SOLID_NOT;
      self.pev.rendermode = kRenderTransTexture;
      self.pev.renderamt  = 0.0f;

      isfirst = true;
    }
    else {
      const float scale = Math.min(PHI*2, 0.85f + (self.pev.iuser1*0.075f));

      g_EntityFuncs.SetSize( self.pev, Vector( -2, -2, 0 )*scale, Vector( 2, 2, 4 )*scale );
      const Vector neworigin = CalcTarget(self.pev.owner.vars.origin, self.pev.owner.vars.velocity, self.pev.owner.vars.size);
      g_EntityFuncs.SetOrigin( self, neworigin == g_vecZero ? self.pev.owner.vars.origin : neworigin );

      self.pev.solid      = SOLID_TRIGGER;
      self.pev.movetype   = MOVETYPE_FLY;
      self.pev.flags      = FL_FLY;
      self.pev.rendermode = kRenderTransAdd;
      self.pev.renderfx   = kRenderFxPulseFastWide;
      self.pev.renderamt  = 224.0f;
      self.pev.scale      = scale;
      self.pev.friction   = 0.0f;
      self.pev.velocity   = OffsetVelocity(true);
    }

    self.pev.netname   = string_t("trail of " + self.pev.owner.vars.netname);
    self.pev.nextthink = g_Engine.time + 0.1f;

    maxvelocity = g_EngineFuncs.CVarGetFloat("sv_maxvelocity");
    owneridx    = g_EntityFuncs.EntIndex(@self.pev.owner);
    lasths      = g_player_states[owneridx].lasths;   

    BaseClass.Spawn();
  }

  private void KillMsg() {
    NetworkMessage m( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY );
      m.WriteByte( TE_KILLBEAM );
      m.WriteShort( self.entindex() );
    m.End();
  }

  private const Vector ApproachVector(const Vector vecTarget, const Vector vecOrigin, const float limit) {
    const Vector vecDelta = vecTarget - vecOrigin;
    const float vecLen = vecDelta.Length();
    
    return vecDelta.Normalize() * vecLen * (vecLen > limit * PHI ? PHI*PHI : 1);
  }

  private const Vector CalcTarget(const Vector origin, const Vector velocity, const Vector size) {
    const Vector vnorm  = velocity.Normalize();
    const Vector offset = origin + Vector(vnorm.x*-(size.x*PHI), vnorm.y*-(size.y*PHI), vnorm.z*-(size.z*PHI));

    if (g_EngineFuncs.PointContents(offset) == CONTENTS_SOLID)
      return g_vecZero;
    else
      return offset;
  }

  private const Vector BoundVelocity(Vector velocity) {
    for (uint i = 0; i < 3; i++) {
      if (self.pev.basevelocity.Length() > 0.0f) {
        if (self.pev.basevelocity[i] < 0.0f) {
          if (velocity[i] < 0.0f)
            velocity[i] -= self.pev.basevelocity[i];
          else 
            velocity[i] += self.pev.basevelocity[i];
         }
         else {
           if (velocity[i] < 0.0f)
             velocity[i] += self.pev.basevelocity[i];
           else
             velocity[i] -= self.pev.basevelocity[i];
         }
      }

      if (velocity[i] > maxvelocity)
        velocity[i] = maxvelocity;
      else if (velocity[i] < -maxvelocity)
        velocity[i] = -maxvelocity;
    }

    return velocity;
  }

  private const Vector OffsetVelocity(const bool eyepos) {
    const Vector neworigin   = CalcTarget(self.pev.owner.vars.origin + (eyepos ? self.pev.owner.vars.view_ofs : g_vecZero), self.pev.owner.vars.velocity, self.pev.owner.vars.size);
    const Vector newvelocity = neworigin != g_vecZero ? self.pev.owner.vars.velocity + ApproachVector(neworigin, self.pev.origin, self.pev.owner.vars.size.z) : self.pev.owner.vars.velocity + ApproachVector(self.pev.owner.vars.origin, self.pev.origin, self.pev.owner.vars.size.z);

    return BoundVelocity(newvelocity);
  }

  void Think() {
    if (self.pev.owner is null) {
      g_EntityFuncs.Remove( self );
      return;
    }

    if (!detached) {
      if (!isfirst) {
        if (lastplrorigin == self.pev.owner.vars.origin) {
          g_Scheduler.SetTimeout("KillTrail", 0.0f, owneridx);
        }
        else {
          if (UnixTimestamp() % 4 != 0)
            self.pev.velocity = OffsetVelocity((UnixTimestamp() % 7 == 0) ? true : false);
          else
            self.pev.velocity = BoundVelocity(self.pev.owner.vars.velocity);

          g_EngineFuncs.VecToAngles(self.pev.velocity + self.pev.basevelocity, self.pev.angles);
          lastplrorigin = self.pev.owner.vars.origin;
        }
      }
    }
    else if (g_Engine.time > killtime) {
      if (revived) {
        NetworkMessage m(MSG_PVS, NetworkMessages::SVC_TEMPENTITY, self.pev.origin );
          m.WriteByte(TE_IMPLOSION);
          m.WriteCoord(self.pev.origin.x);
          m.WriteCoord(self.pev.origin.y);
          m.WriteCoord(self.pev.origin.z-24.0f);
          m.WriteByte(128);
          m.WriteByte(16);
          m.WriteByte(5);
        m.End();

        g_Scheduler.SetTimeout(this, "CreateMerci", 0.5f, self.pev.origin);
      }
      else if (!isfirst) {
        if (rambo)
          g_SoundSystem.StopSound( self.edict(), CHAN_WEAPON, fuzzsnd, false );
        else if (islast)
          g_Utility.Sparks(self.pev.origin);
        else
          g_EngineFuncs.ParticleEffect(self.pev.origin, self.pev.origin + Vector(0, 0, 64), 111.0f, 3.0f);
      }

      g_EntityFuncs.Remove( self );
      return;
    }
    else if (!finished) {
      if (self.pev.velocity.Length2D() < 1.0f || (self.pev.waterlevel > 0 && self.pev.velocity.Length2D() < 16.0f)) {
        self.pev.avelocity = g_vecZero;
        self.pev.angles.x  = 270.0f;

        if (islast) {
          self.pev.renderfx  = kRenderFxPulseFast;
          self.pev.renderamt = 128.0f;
        }

        killtime = g_Engine.time + (life*0.1f);
        finished = true;
      }
      else {
        g_EngineFuncs.VecToAngles(self.pev.velocity + self.pev.basevelocity, self.pev.avelocity);

        if (rambo) {
          const Vector vrnd = Vector(Math.RandomFloat(-500.0f, 500.0f), Math.RandomFloat(-500.0f, 500.0f), Math.RandomFloat(-500.0f, 500.0f));

          g_EntityFuncs.CreateExplosion(self.pev.origin, self.pev.angles, self.edict(), 72, true);

          switch ( Math.RandomLong(13, 37) ) {
            case 0:
              g_EntityFuncs.CreateRPGRocket(self.pev.origin, vrnd, vrnd, self.edict());
              break;
            case 1:
              g_EntityFuncs.ShootBananaCluster(self.pev, self.pev.origin, vrnd);
              break;
          }
        }
      }
    }

    if (!isfirst) {
      if (!finished) {
        const RGBA dlcolor = FetchColor(lasths.x, lasths.y, Math.min(PHI-1, ColorValue(1, uint(floor(self.pev.velocity.Length2D()+0.5f)*0.1f))));

        for (int i = 1; i <= g_Engine.maxClients; i++) {
          if (g_player_states[i].ishere && g_player_states[i].dlight) {
            NetworkMessage m2(MSG_ONE_UNRELIABLE, NetworkMessages::SVC_TEMPENTITY, g_EntityFuncs.IndexEnt(i));
              m2.WriteByte(TE_DLIGHT);
              m2.WriteCoord(self.pev.origin.x);
              m2.WriteCoord(self.pev.origin.y);
              m2.WriteCoord(self.pev.origin.z);
              m2.WriteByte(Math.clamp(6, 10, self.pev.iuser1+5));
              m2.WriteByte(dlcolor.r);
              m2.WriteByte(dlcolor.g);
              m2.WriteByte(dlcolor.b);
              m2.WriteByte(detached ? (islast ? life : 2) : g_player_states[owneridx].lastlife);
              m2.WriteByte(1);
            m2.End();
          }
        }

        //dot(self.pev.origin);
      }

      if (self.pev.waterlevel > 0) {
        if (detached)
          self.pev.velocity = BoundVelocity(Vector(self.pev.velocity.x*(PHI-1)*1.37f, self.pev.velocity.y*(PHI-1)*1.37f, PHI*64));
        if (islast)
          g_Utility.Bubbles(self.pev.origin + self.pev.mins*PHI*8, self.pev.origin + self.pev.maxs*PHI*8, 1);
      }

      if (detached && !finished && lastorigin == self.pev.origin) {
        finished = true;
        killtime = g_Engine.time + PHI;
      }

      lastorigin = self.pev.origin;
    }

    self.pev.nextthink = g_Engine.time + 0.05f;
  }

  void Detach(const bool _islast) {
    islast = _islast;
    life   = g_player_states[owneridx].lastlife;

    if (detached)
      return;
    detached = true;

    if (isfirst) {
      KillMsg();
      killtime = 0.0f;
    }
    else {
      self.pev.movetype = MOVETYPE_BOUNCE;
      self.pev.flags   |= FL_FLY;

      if (rambo) {
        self.pev.movetype = MOVETYPE_BOUNCEMISSILE;
        self.pev.velocity = BoundVelocity(self.pev.velocity + (self.pev.velocity.Normalize() * 1337));
        killtime = g_Engine.time + 13.37f;
        return;
      }

      g_EngineFuncs.ParticleEffect(self.pev.origin, self.pev.velocity*-1, 111.0f, 5.0f);

      if (islast) {
        self.pev.velocity = BoundVelocity(self.pev.velocity + (self.pev.velocity.Normalize() * pow(self.pev.iuser1, 3/PHI)));
        self.pev.iuser1   = -1;

        NetworkMessage m(MSG_PVS, NetworkMessages::SVC_TEMPENTITY, self.pev.origin);
          m.WriteByte(TE_GLOWSPRITE);
          m.WriteCoord(self.pev.origin.x);
          m.WriteCoord(self.pev.origin.y);
          m.WriteCoord(self.pev.origin.z);
          m.WriteShort(g_EngineFuncs.ModelIndex(sprglow));
          m.WriteByte(life/2);
          m.WriteByte(1);
          m.WriteByte(96);
        m.End();

        g_SoundSystem.PlaySound( self.edict(), CHAN_AUTO, sparksnd, 1.0f, ATTN_NORM, 0, 100, owneridx );
      }
      else {
        self.pev.rendermode = kRenderTransTexture;
        self.pev.renderfx   = kRenderFxDistort;
        self.pev.renderamt  = 255.0f;
      }

      killtime = g_Engine.time + (life/2);
    }
  }

  void Touch(CBaseEntity@ pOther) {
    if (isfirst || revived || rambo || pOther.edict() is self.pev.owner || pOther.pev.owner is self.pev.owner)
      return;

    const bool inwater = self.pev.waterlevel > 0 ? true : false;

    if (detached && !pOther.pev.ClassNameIs(g_classname) && pOther.IsBSPModel() /* !(pOther.IsPlayer() || pOther.IsMonster() )*/) {
      if (!inwater) {
        self.pev.friction = 0.0f;
        self.pev.velocity = BoundVelocity(self.pev.velocity*(PHI*0.5f));
      }

      if (nextdmgtime > g_Engine.time)
        return;

      if (islast && !inwater)
        g_Utility.Sparks(self.pev.origin);

      if (pOther.IsBreakable()) {
        const int decal = pOther.DamageDecal(DMG_CLUB);
        g_Utility.DecalTrace(g_Utility.GetGlobalTrace(), decal);

        CBasePlayer@ plr = cast<CBasePlayer@>(g_EntityFuncs.Instance(@self.pev.owner));
        if (plr !is null && (plr.HasNamedPlayerItem("weapon_crowbar") !is null || plr.HasNamedPlayerItem("weapon_pipewrench") !is null))
          pOther.TakeDamage(self.pev, self.pev.owner.vars, (self.pev.velocity.Length2D()*PHI-1)*self.pev.scale, DMG_SONIC);
      }

      nextdmgtime = g_Engine.time + 0.0667f;
    }
    else if (pOther.IsPlayer() && !(detached && !islast)) {
      if (nextdmgtime > g_Engine.time)
        return;

      if (!self.pev.FlagBitSet(FL_ONGROUND) && !inwater) {
        if (pOther.pev.armorvalue > 0.0f) {
          g_Utility.Ricochet(self.pev.origin, 1.0f);
        }
        else {
          g_Utility.Sparks(self.pev.origin);
          g_SoundSystem.PlaySound( self.edict(), CHAN_AUTO, sparksnd, Math.RandomFloat(0.7f, 0.9f), ATTN_NORM, 0, Math.RandomLong(90, 105) );
        }

        if (!g_SurvivalMode.IsActive()) {
          const int oldclass = pOther.Classify();
          pOther.SetClassification(CLASS_ALIEN_MONSTER);
          pOther.TakeDamage(self.pev, self.pev.owner.vars, 1.0f, DMG_NEVERGIB|DMG_SHOCK_GLOW);
          pOther.SetClassification(oldclass);
        }

        nextdmgtime = g_Engine.time + 0.05f;
      }
    }
    else if (!detached && pOther.pev.ClassNameIs(g_classname) && pOther.pev.iuser1 < 0 && !(g_SurvivalMode.IsEnabled() || g_SurvivalMode.IsActive())) {
      HUDTextParams txtPrms;
      txtPrms.r1 = 255;
      txtPrms.g1 = 0;
      txtPrms.b1 = 0;
      txtPrms.a1 = 160;
      txtPrms.x = -1.0f;
      txtPrms.y = 0.75f;
      txtPrms.effect = 0;
      txtPrms.fadeinTime = 0.1f;
      txtPrms.fadeoutTime = 0.5f;
      txtPrms.holdTime = 1.4f;
      txtPrms.channel = 1;
      
      const string msg = "The " + pOther.pev.netname + " angered the " + self.pev.netname + ". UNLEASHING THE WRATH!";

      g_PlayerFuncs.HudMessageAll(txtPrms, msg);
      RelaySay("rambo\\" + msg);

      GoRambo();
    }
  }

  bool IsRevivable() { return (finished && islast && !revived && !rambo); }

  void BeginRevive(float timetorev) {
    if (g_Engine.time + timetorev >= killtime) {
      killtime = 0.0f;

      NetworkMessage m(MSG_PVS, NetworkMessages::SVC_TEMPENTITY, self.pev.origin);
        m.WriteByte(TE_SMOKE);
        m.WriteCoord(self.pev.origin.x);
        m.WriteCoord(self.pev.origin.y);
        m.WriteCoord(self.pev.origin.z);
        m.WriteShort(g_EngineFuncs.ModelIndex(sprsmoke));
        m.WriteByte(2);
        m.WriteByte(15);
      m.End();
    }
  }

  void EndRevive(float) {
    KillMsg();

    g_EntityFuncs.SetOrigin( self, Vector(self.pev.origin.x, self.pev.origin.y, self.pev.origin.z+48) );

    const float _life = Math.RandomFloat(3.33f, 6.66f);

    NetworkMessage m2(MSG_PVS, NetworkMessages::SVC_TEMPENTITY, self.pev.origin);
      m2.WriteByte(TE_DLIGHT);
      m2.WriteCoord(self.pev.origin.x);
      m2.WriteCoord(self.pev.origin.y);
      m2.WriteCoord(self.pev.origin.z);
      m2.WriteByte(12);
      m2.WriteByte(250);
      m2.WriteByte(250);
      m2.WriteByte(250);
      m2.WriteByte(uint8(_life*10));
      m2.WriteByte(1);
    m2.End();

    self.pev.scale      = PHI*5;
    self.pev.movetype   = MOVETYPE_NOCLIP;
    self.pev.rendermode = kRenderNormal;
    self.pev.renderfx   = kRenderFxNone;
    self.pev.avelocity  = Vector(Math.RandomFloat(12.0f, 255.0f), Math.RandomFloat(12.0f, 255.0f), Math.RandomFloat(12.0f, 255.0f));
    self.pev.effects   |= EF_BRIGHTFIELD|EF_NOINTERP;

    revived  = true;
    killtime = g_Engine.time + _life;
  }

  private void GoRambo() {
    rambo = true;

    self.pev.scale       = PHI*8;
    self.pev.rendermode  = kRenderNormal;
    self.pev.renderfx    = kRenderFxGlowShell;
    self.pev.renderamt   = 128.0f;
    self.pev.rendercolor = Vector(255.0f, 0.0f, 0.0f);

    g_SoundSystem.PlaySound( self.edict(), CHAN_WEAPON, fuzzsnd, 1.0f, 0.0f, SND_FORCE_LOOP, 50 );
  }

  private void CreateMerci(const Vector origin) {
    if (g_SurvivalMode.IsActive() || Math.RandomLong(0, 2) == 0) {
      dictionary keyvalues = {
        { "origin", origin.ToString() },
        { "health", "1" },
        { "displayame", "lol" }
      };

      g_EntityFuncs.CreateEntity( "monster_cockroach", keyvalues );
    }
    else {
      dictionary keyvalues = {
        { "model", model },
        { "health", "" + Math.RandomLong(3, 33) },
        { "healthcap", "" + Math.RandomLong(100, 133) },
        { "scale", "4" },
        { "movetype", "0" },
        { "origin", origin.ToString() },
        { "angles", "270 0 0" },
        { "m_flCustomRespawnTime", "-1" },
        { "spawnflags", "1152" }
      };

      g_EntityFuncs.CreateEntity( Math.RandomLong(0, 1) == 0 ? "item_healthkit" : "item_battery", keyvalues );
    }
  }
}

// debug methods

void say(const string text) { g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, text + "\n"); };

void dot(const Vector origin) {
  NetworkMessage m(MSG_PVS, NetworkMessages::SVC_TEMPENTITY, origin);
    m.WriteByte(TE_SHOWLINE);
    m.WriteCoord(origin.x);
    m.WriteCoord(origin.y);
    m.WriteCoord(origin.z);
    m.WriteCoord(origin.x);
    m.WriteCoord(origin.y);
    m.WriteCoord(origin.z+1);
  m.End();
}
