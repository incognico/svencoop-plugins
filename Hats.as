// TODO:
// - wearing multiple hats speeds up animations on custom player models, needs investigation see https://cdn.discordapp.com/attachments/698803767512006677/842109605600559145/svencoop.exe_2021.05.12_-_19.40.39.04.mp4
// - filter duplicates? ".hat foo foo bar bar bar" but actually it does not really matter, only aestethics
// - hat inspect can be improved a lot

const string PREFIX = "[Hats] ";
const string g_hatsfile = "scripts/plugins/cfg/hatmodels.txt";
const uint8 g_hatlimit = 5;

size_t filesize;
bool safe;

class HatData {
  bool dynamic;
  string path;
  string name;
  int sequence;
  int body;
}
array<HatData> g_hats;
array<string> g_hats_keys;
array<string> g_sorted_hats;

class PlayerPersist {
  array<string> hats;
}
dictionary g_player_persist;

class PlayerState {
  dictionary hat_ents;
  bool inspecting;

  const uint hatcount() {
    return hat_ents.getKeys().length();
  }
}
array<PlayerState> g_player_states;

CClientCommand _hat("hat", "hat commands", @consoleCmd);

// Menus need to be defined globally when the plugin is loaded or else paging doesn't work.
// Each player needs their own menu or else paging breaks when someone else opens the menu.
// These also need to be modified directly (not via a local var reference).
array<CTextMenu@> g_menus(g_Engine.maxClients+1, null);

void PluginInit() {
  g_Module.ScriptInfo.SetAuthor("incognico + w00tguy + Zode");
  g_Module.ScriptInfo.SetContactInfo("https://discord.gg/qfZxWAd");

  g_Hooks.RegisterHook(Hooks::Player::ClientDisconnect, @ClientDisconnect);
  g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @ClientPutInServer);
  g_Hooks.RegisterHook(Hooks::Player::ClientSay, @ClientSay);
  
  g_player_states.resize(g_Engine.maxClients+1);
  
  ReadHats();
}

void PluginExit() {
  for (int i = 1; i <= g_Engine.maxClients; i++) {
    CBasePlayer@ plr = g_PlayerFuncs.FindPlayerByIndex(i);
    if (plr !is null)
      strip_all(plr, true);
  }
}

void MapInit() {
  if (HatsChanged())
    ReadHats();

  for (uint i = 0; i < g_hats.length(); i++) {
    HatData@ hat = cast<HatData@>(g_hats[i]);
    g_Game.PrecacheModel( "models/" + hat.path + ".mdl" );
  }

  g_player_states.resize(0);
  g_player_states.resize(g_Engine.maxClients+1);

  safe = true;
}

const bool HatsChanged() {
  File@ file = g_FileSystem.OpenFile(g_hatsfile, OpenFile::READ);
  const bool changed = (file.GetSize() != filesize) ? true : false;
  file.Close();

  return changed;
}

void ReadHats() {
  g_hats_keys.resize(0);
  g_hats.resize(0);
  g_sorted_hats.resize(0);

  File@ file = g_FileSystem.OpenFile(g_hatsfile, OpenFile::READ);
  if (file !is null && file.IsOpen()) {
    while(!file.EOFReached()) {
      string sLine;
      file.ReadLine(sLine);
      
      sLine.Trim();
      if (sLine.IsEmpty())
        continue;

      HatData hat;
    
      if (sLine.Tokenize(" ")[0] == 'D') {
        hat.dynamic  = true;
        hat.path     = sLine.Tokenize(" ");
        hat.body     = atoi(sLine.Tokenize(" "));
        hat.sequence = atoi(sLine.Tokenize(" "));
        hat.name     = sLine.Tokenize(" ").ToLowercase();
      }
      else {
        hat.path = sLine.Tokenize(" ");
        const array<string> tmp = hat.path.Split("/");
        //hat.name = string(tmp[tmp.length()-1]).ToLowercase(); // BUG: game crash
        hat.name = tmp[tmp.length()-1];
        hat.name = hat.name.ToLowercase();
      }

      g_hats.insertLast(hat);
      g_hats_keys.insertLast(hat.name);
      g_sorted_hats.insertLast(hat.name);
    }

    file.Close();
  }

  g_sorted_hats.sortAsc();
}

void wear(CBasePlayer@ plr, const int hatidx, bool addtopersist = true) {
  HatData@ hatdata = cast<HatData@>(g_hats[hatidx]);

  CBaseEntity@ hat = g_EntityFuncs.Create("info_target", plr.pev.origin, plr.pev.angles, true);

  @hat.pev.aiment    = @hat.pev.owner = @plr.edict();
  hat.pev.movetype   = MOVETYPE_FOLLOW;
  hat.pev.rendermode = kRenderNormal;
  hat.pev.colormap   = plr.pev.colormap;
  hat.pev.targetname = "bspguy_plugin_player_hat"; // bspguy_ prefix needed so hats aren't deleted when a merged map section reloads
  hat.pev.netname    = "hat \"" + hatdata.name + "\" of " + plr.pev.netname;

  g_EntityFuncs.SetModel(hat, "models/" + hatdata.path + ".mdl");
  g_EntityFuncs.SetSize(hat.pev, g_vecZero, g_vecZero);

  if (hatdata.dynamic) {
    hat.pev.body      = hatdata.body;
    hat.pev.sequence  = hatdata.sequence;
    hat.pev.framerate = 1;
  }

  g_EntityFuncs.DispatchSpawn(hat.edict());
  g_player_states[plr.entindex()].hat_ents[hatdata.name] = hat.entindex();

  if (addtopersist) {
    const string steamid = g_EngineFuncs.GetPlayerAuthId(plr.edict());
    if (!g_player_persist.exists(steamid))
      g_player_persist[steamid] = PlayerPersist();
    PlayerPersist@ persist = cast<PlayerPersist@>(g_player_persist[steamid]);
    persist.hats.insertLast(hatdata.name);
  }
}

void strip(CBasePlayer@ plr, const int hatidx) {
  const int plridx = plr.entindex();

  if (g_player_states[plridx].hat_ents.exists(g_hats_keys[hatidx])) {
    const int entidex = int(g_player_states[plridx].hat_ents[g_hats_keys[hatidx]]);
    if (entidex > 0) {
      CBaseEntity@ hat = g_EntityFuncs.Instance(entidex);
      if (hat !is null)
        g_EntityFuncs.Remove(hat);
    }

    g_player_states[plridx].hat_ents.delete(g_hats_keys[hatidx]);
  }

  const string steamid = g_EngineFuncs.GetPlayerAuthId(plr.edict());
  if (g_player_persist.exists(steamid)) {
    PlayerPersist@ persist = cast<PlayerPersist@>(g_player_persist[steamid]);
    const int sidx = persist.hats.find(g_hats_keys[hatidx]);
    if (sidx >= 0)
      persist.hats.removeAt(sidx);
  }
}

void strip_all(CBasePlayer@ plr, bool delpersist = false) {
  const int plridx = plr.entindex();

  for (uint i = 0; i < g_player_states[plridx].hatcount(); i++) {
    const int entidex = int(g_player_states[plridx].hat_ents[g_hats_keys[i]]);
    if (entidex > 0) {
      CBaseEntity@ hat = g_EntityFuncs.Instance(entidex);
      if (hat !is null)
        g_EntityFuncs.Remove(hat);
    }
  }

  g_player_states[plridx].hat_ents.deleteAll();
  
  if (delpersist)
    g_player_persist[g_EngineFuncs.GetPlayerAuthId(plr.edict())] = PlayerPersist();
}

HookReturnCode ClientPutInServer(CBasePlayer@ plr) {
  if (!safe)
    return HOOK_CONTINUE;

  const string steamid = g_EngineFuncs.GetPlayerAuthId(plr.edict());

  if (g_player_persist.exists(steamid)) {
    PlayerPersist@ persist = cast<PlayerPersist@>(g_player_persist[steamid]);

    for (uint i = 0; i < persist.hats.length(); i++) {
      const int sidx = g_hats_keys.find(persist.hats[i]);
      if (sidx >= 0)
        wear(plr, sidx, false);
    }
  }

  return HOOK_CONTINUE;
}

HookReturnCode ClientDisconnect(CBasePlayer@ plr) {
  strip_all(plr);

  return HOOK_CONTINUE;
}

void StopInspect(EHandle ent, const int idx) {
  g_player_states[idx].inspecting = false;

  if (ent)
    g_EntityFuncs.Remove(ent.GetEntity());
}

const string join(const array<string> &in arr, const string &in delimiter) {
  string res;

  for (uint i = 0; i < arr.length(); i++)
    res += arr[i] + delimiter;

  if (!res.IsEmpty())
    res.Truncate(res.Length()-delimiter.Length());

  return res;
}

void hatMenuCallback(CTextMenu@ menu, CBasePlayer@ plr, int itemNumber, const CTextMenuItem@ item) {
  if (item is null or plr is null or !plr.IsConnected())
    return;

  string option = "";
  item.m_pUserData.retrieve(option);
  const array<string> values = option.Split(":");

  toggleHat(plr, values[0], true);
  g_Scheduler.SetTimeout("openHatMenu", 0.0f, EHandle(plr), atoi(values[1])); // wait a frame or else game crashes
}

void openHatMenu(EHandle h_plr, int pageNum) {
  CBasePlayer@ plr = cast<CBasePlayer@>(h_plr.GetEntity());
  if (plr is null)
    return;

  const int eidx = plr.entindex();

  @g_menus[eidx] = CTextMenu(@hatMenuCallback);
  g_menus[eidx].SetTitle("\\yHat Menu   ");

  const bool moreThanOnePage = g_hats_keys.length() > 9;

  for (uint i = 0; i < g_sorted_hats.length(); i++) {
    const int itemPage = moreThanOnePage ? (i / 7) : 0;
    const bool isEquipped = g_player_states[eidx].hat_ents.exists(g_sorted_hats[i]);
    const string color = isEquipped ? "\\r" : "\\w";
    g_menus[eidx].AddItem(color + g_sorted_hats[i] + "\\y", any(g_sorted_hats[i] + ":" + itemPage));
  }

  g_menus[eidx].Register();
  g_menus[eidx].Open(0, pageNum, plr);
}

void toggleHat(CBasePlayer@ plr, string hats, bool inmenu = false) {
  const int plridx = plr.entindex();
  hats.Trim();

  bool limithit = false;
  array<string> added;
  array<string> removed;
  array<string> invalid;

  string tok = hats.Tokenize(" ");
  while (tok != String::NO_MORE_TOKENS) {
    const int hatidx = g_hats_keys.find(tok);
    if (hatidx >= 0) {
      if (g_player_states[plridx].hat_ents.exists(tok)) {
        strip(plr, hatidx);
        removed.insertLast(tok);
      }
      else {
        if (g_player_states[plridx].hatcount() < g_hatlimit) {
          wear(plr, hatidx);
          added.insertLast(tok);
        }
        else {
          limithit = true;
        }
      }
    }
    else {
      invalid.insertLast(tok);
    }

    tok = hats.Tokenize(" ");
  }

  string msg;

  if (added.length() > 0) {
    msg += " ADDED: ";
    msg += join(added, ", ");
  }
  if (removed.length() > 0) {
    msg += " REMOVED: ";
    msg += join(removed, ", ");
  }
  if (invalid.length() > 0) {
    msg += " INVALID: ";
    msg += join(invalid, ", ");
  }
  if (limithit) {
    const string hitmsg = "HAT LIMIT OF " + g_hatlimit + " EXCEEDED!";
    if (inmenu)
      msg += hitmsg;
    else
      g_PlayerFuncs.ClientPrint(plr, HUD_PRINTTALK, PREFIX + hitmsg + "\n");
  }

  msg.Trim();

  if (!msg.IsEmpty())
    g_PlayerFuncs.ClientPrint(plr, inmenu ? HUD_PRINTCENTER : HUD_PRINTTALK, PREFIX + msg + "\n");
}

const bool doCommand(CBasePlayer@ plr, const CCommand@ args, bool inConsole) {
  if (args.ArgC() > 0 && (args[0] == ".hat" || args[0] == "hat")) {
    if (args.ArgC() >= 2) {
      if (!safe) {
        g_PlayerFuncs.ClientPrint(plr, HUD_PRINTTALK, PREFIX + "Plugin was reloaded and needs to precache first, please wait for a map change.\n");
        return true;
      }

      const string steamid = g_EngineFuncs.GetPlayerAuthId(plr.edict());
      const int idx = plr.entindex();

      if (args[1] == "info") {
        if (!g_player_persist.exists(steamid))
          g_player_persist[steamid] = PlayerPersist();
        PlayerPersist@ persist = cast<PlayerPersist@>(g_player_persist[steamid]);

        persist.hats.sortAsc();
        const uint count = persist.hats.length();
        const string hatnames = join(persist.hats, ", ");
        const string s = count == 1 ? ": " : (count == 0 ? "s." : "s: ");

        g_PlayerFuncs.ClientPrint(plr, HUD_PRINTTALK, PREFIX + "You are wearing " + count + " hat" + s + hatnames + "\n");
      }
      else if (args[1] == "inspect") {
        if (!plr.IsAlive() || plr.GetObserver().IsObserver()) {
          g_PlayerFuncs.ClientPrint(plr, HUD_PRINTTALK, PREFIX + "Can't inspect when dead or observer.\n");
          return true;
        }

        if (g_player_states[idx].inspecting) {
          g_PlayerFuncs.ClientPrint(plr, HUD_PRINTTALK, PREFIX + "Wait shortly before inspecting again.\n");
          return true;
        }

        g_player_states[idx].inspecting = true;

        Vector vfwd;
        g_EngineFuncs.AngleVectors(plr.pev.angles, vfwd, void, void);
        const Vector origin = plr.pev.origin + Vector(vfwd.x*96, vfwd.y*96, 0);
        const Vector angles = Math.VecToAngles(plr.pev.origin - origin);
        const uint holdtime = 6;

        dictionary keyvalues = {
          { "origin", origin.ToString() },
          { "angles", angles.ToString() },
          { "wait", "" + holdtime },
          { "spawnflags", "4" }
        };

        CBaseEntity@ cam = g_EntityFuncs.CreateEntity( "trigger_camera", keyvalues );
        cam.Use( plr, plr, USE_ON, 0 );
        g_Scheduler.SetTimeout("StopInspect", holdtime*1.5f, EHandle(cam), idx);
      }
      else if (args[1] == "off") {
        if (g_player_states[plr.entindex()].hatcount() < 1) {
          g_PlayerFuncs.ClientPrint(plr, HUD_PRINTTALK, PREFIX + "You are not wearing any hats!\n");
        }
        else {
          strip_all(plr, true);
          g_PlayerFuncs.ClientPrint(plr, HUD_PRINTTALK, PREFIX + "REMOVED: ALL\n");
        }
      }
      else if (args[1] == "list") {
        g_PlayerFuncs.ClientPrint(plr, HUD_PRINTCONSOLE, "AVAILABLE HATS\n--------------\n");

        string msg;

        for (uint i = 1; i < g_sorted_hats.length()+1; ++i) {
          msg += g_sorted_hats[i-1] + " | ";

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

        g_PlayerFuncs.ClientPrint(plr, HUD_PRINTTALK, "\n" + PREFIX + "Hat list printed to console.\n");
      }
      else if (args[1] == "menu") {
        openHatMenu(plr, 0);
      }
      else {
        toggleHat(plr, args.GetArgumentsString().ToLowercase());
      }
    }
    else {
      g_PlayerFuncs.ClientPrint(plr, HUD_PRINTTALK, PREFIX + "Usage: .hat off/info/inspect/list/menu/<name> [<name>]...\n");
    }

    return true;
  }

  return false;
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
