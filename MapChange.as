CClientCommand g_ManualMapChange("map", "Changes map to <map> (admin only)", @ManualMapChange);

void PluginInit() {
  g_Module.ScriptInfo.SetAuthor("incognico");
  g_Module.ScriptInfo.SetContactInfo("https://discord.gg/qfZxWAd");
  g_Module.ScriptInfo.SetMinimumAdminLevel(ADMIN_YES);
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

void MapChange(string map, const string pName) {
  g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "[MapChange] Admin " + pName + " changed map to: " + map.ToLowercase() + "\n");
  NetworkMessage message(MSG_ALL, NetworkMessages::SVC_INTERMISSION, null);
  message.End();
  g_Scheduler.SetTimeout("ChangeLevelCmd", 5.0f, map.ToLowercase());
}

void ChangeLevelCmd(string map) {
  g_EngineFuncs.ChangeLevel(map.ToLowercase());
  //g_EngineFuncs.ServerCommand("changelevel " + map.ToLowercase() + "\n");
}
