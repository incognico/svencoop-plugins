CTextMenu@ menu;

CClientCommand g_ManualMapChange("map", "Changes map to <map> (admin only)", @ManualMapChange);
CClientCommand g_MapChangeMenu("mapchangemenu", "Displays the map change menu (admin only)", @DisplayMapChangeMenu);

void PluginInit() {
  g_Module.ScriptInfo.SetAuthor("incognico");
  g_Module.ScriptInfo.SetContactInfo("https://discord.gg/qfZxWAd");
  g_Module.ScriptInfo.SetMinimumAdminLevel(ADMIN_YES);
}

void MenuCallback(CTextMenu@ menu, CBasePlayer@ pPlayer, int page, const CTextMenuItem@ item) {
  if (item !is null && pPlayer !is null)
    MapChange(item.m_szName, pPlayer.pev.netname);

  if (@menu !is null && menu.IsRegistered())
    menu.Unregister();
    @menu = null;
}

void DisplayMapChangeMenu(const CCommand@ pArgs) {
  CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();

  if (g_PlayerFuncs.AdminLevel(pPlayer) < ADMIN_YES) {
    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "You have no access to this command.\n");
  }
  else {
    @menu = CTextMenu(@MenuCallback);
    menu.SetTitle("Change map to: ");

    const array<string> @MapCycle = g_MapCycle.GetMapCycle();

    for (uint i = 0; i < MapCycle.length(); ++i) {
      menu.AddItem(MapCycle[i], any(MapCycle[i]));
    }

    menu.Register();
    menu.Open(0, 0, pPlayer);
  }
}

void ManualMapChange(const CCommand@ args) {
  CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();

  if (g_PlayerFuncs.AdminLevel(pPlayer) >= ADMIN_YES) {
    if (args.ArgC() >= 1 && g_EngineFuncs.IsMapValid(args.Arg(1))) {
      MapChange(args.Arg(1), pPlayer.pev.netname);
      g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "Changing map to: " + args.Arg(1) + "\n");
    }
    else {
      g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "No or invalid map name given.\n");
    }
  }
  else {
    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "You have no access to this command.\n");
  }
}

void MapChange(const string map, const string pName) {
  g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "[MapChange] Admin " + pName + " changed map to: " + map + "\n");
  // Will be available at some point, waiting for SC update:
  NetworkMessage message(MSG_ALL, NetworkMessages::SVC_INTERMISSION, null);
  message.End();
  g_Scheduler.SetTimeout("ChangeLevelCmd", 5.0f, map);
}

void ChangeLevelCmd(const string map) {
  //g_EngineFuncs.ChangeLevel(map);
  g_EngineFuncs.ServerCommand("changelevel " + map + "\n");
}
