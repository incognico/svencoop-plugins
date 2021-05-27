CClientCommand g_ListModels("listmodels", "List model names and colors of the current players", @ListModels);

void PluginInit() {
  g_Module.ScriptInfo.SetAuthor("incognico");
  g_Module.ScriptInfo.SetContactInfo("https://discord.gg/qfZxWAd");
}

void ListModels(const CCommand@ pArgs) {
  CBasePlayer@ pCaller = g_ConCommandSystem.GetCurrentPlayer();

  g_PlayerFuncs.ClientPrint(pCaller, HUD_PRINTCONSOLE, "PLAYERNAME ==> MODELNAME (TOPCOLOR, BOTTOMCOLOR)\n");
  g_PlayerFuncs.ClientPrint(pCaller, HUD_PRINTCONSOLE, "------------------------------------------------\n");

  array<string> tmp;

  for (int i = 1; i <= g_Engine.maxClients; ++i) {
    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);

    if (pPlayer !is null && pPlayer.IsConnected()) {
      KeyValueBuffer@ pInfos = g_EngineFuncs.GetInfoKeyBuffer(pPlayer.edict());
      tmp.insertLast("" + pPlayer.pev.netname + " ==> " + pInfos.GetValue("model") + " (" + pInfos.GetValue("topcolor") + ", " + pInfos.GetValue("bottomcolor") + ")");
    }
  }

  tmp.sort(function(a,b) { return a.ICompareN(b, 64) < b.ICompareN(a, 64); });

  for (uint i = 0; i < tmp.length(); i++) {
    g_PlayerFuncs.ClientPrint(pCaller, HUD_PRINTCONSOLE, tmp[i] + "\n");
  }

  tmp.resize(0);
}
