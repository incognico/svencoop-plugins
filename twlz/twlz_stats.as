void PluginInit() {
  g_Module.ScriptInfo.SetAuthor("incognico");
  g_Module.ScriptInfo.SetContactInfo("https://discord.gg/qfZxWAd");

  g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @ClientPutInServer);

  ReadStats();
}

dictionary g_PlayerStats;

class PlayerStats {
  int rank;
  int score;
  int deaths;
}

const string g_StatsFile = "scripts/plugins/cfg/twlzstats.txt";

void ReadStats() {
  File@ file = g_FileSystem.OpenFile(g_StatsFile, OpenFile::READ);
  if (file !is null && file.IsOpen()) {
    while(!file.EOFReached()) {
      string sLine;
      file.ReadLine(sLine);
      if (sLine.SubString(0,1) == "#" || sLine.IsEmpty())
        continue;

      array<string> parsed = sLine.Split(" ");
      if (parsed.length() < 4)
            continue;

      PlayerStats data;

      data.rank   = atoi(parsed[0]);
      data.score  = atoi(parsed[2]);
      data.deaths = atoi(parsed[3]);

      g_PlayerStats['STEAM_' + parsed[1]] = data;
    }
    file.Close();
  }
}

void MapInit() {
  g_PlayerStats.deleteAll();
  ReadStats();
}

HookReturnCode ClientPutInServer(CBasePlayer@ pPlayer) {
  string szSteamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());

  if (g_PlayerStats.exists(szSteamId)) {
    PlayerStats@ data = cast<PlayerStats@>(g_PlayerStats[szSteamId]);
    g_Scheduler.SetTimeout("PlayerPostConnect", 6.0f, g_EngineFuncs.IndexOfEdict(pPlayer.edict()), data.rank, data.score, data.deaths);
  }

  return HOOK_CONTINUE;
}

void PlayerPostConnect(int pIndex, int rank, int score, int deaths) {
  CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(pIndex);

  if (pPlayer !is null && pPlayer.IsConnected())
    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[twlz] Welcome back, " + pPlayer.pev.netname + "! #" + rank + " Score: " + score + " Deaths: " + deaths + "\n");
}
