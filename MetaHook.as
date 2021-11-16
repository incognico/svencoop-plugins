const bool verbose = false;

const string bitskey = "$s_bits";
uint metachads = 0; // bitfield
int chadent = -1;
array<string> valid;

void PluginInit() {
  g_Module.ScriptInfo.SetAuthor("incognico");
  g_Module.ScriptInfo.SetContactInfo("https://discord.gg/qfZxWAd");

  g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @ClientPutInServer);
  g_Hooks.RegisterHook(Hooks::Player::ClientDisconnect, @ClientDisconnect);

  CBaseEntity@ oldchadent = g_EntityFuncs.FindEntityByTargetname(null, "_MetaChads");

  if (oldchadent !is null && g_EntityFuncs.IsValidEntity(oldchadent.edict())) {
    chadent = g_EntityFuncs.EntIndex(oldchadent.edict());
    CustomKeyvalues@ chadkv = oldchadent.GetCustomKeyvalues();

    if (chadkv.HasKeyvalue(bitskey)) {
      metachads = atoui((chadkv.GetKeyvalue(bitskey)).GetString());
    }
    else {
      CBaseEntity@ del = g_EntityFuncs.Instance(oldchadent.edict());
      g_EntityFuncs.Remove(del);
      MapInit();
    }
  }
  else {
    MapInit();
  }
}

CClientCommand g_ReportMetahookPlugin("mh_reportplugin", "ReportPluginInfo", @ReportPluginInfo);
CClientCommand g_ListChads("chads", "ListChads", @ListChads);

void MapInit() {
  metachads = 0;
  valid.resize(0);

  dictionary keys = {
    { "targetname", "_MetaChads" },
    { bitskey, "" + metachads }
  };
  CBaseEntity@ ent = g_EntityFuncs.CreateEntity("info_target", keys, true);
  chadent = g_EntityFuncs.EntIndex(ent.edict());
}

HookReturnCode ClientPutInServer(CBasePlayer@ plr) {
  NetworkMessage message(MSG_ONE, NetworkMessages::NetworkMessageType(39), plr.edict()); // svc_newusermsg
    message.WriteByte(146); // 64 ~ 145 = SelAmmo ~ VModelPos, all of them are reserved or used by Sven Co-op
    message.WriteByte(255); // 255 = variable length
    message.WriteLong(0x6174654D); // 'ateM'
    message.WriteLong(0x6B6F6F48); // 'kooH'
    message.WriteLong(0);
    message.WriteLong(0);
  message.End();

  RequestPlugins(EHandle(plr));

  return HOOK_CONTINUE;
}

HookReturnCode ClientDisconnect(CBasePlayer@ plr) {
  if (IsChad(plr)) {
    ChadDisable(plr);
    UpdateEnt();
  }

  return HOOK_CONTINUE;
}

void Invalid(const string szSteamId) {
  const int idx = valid.find(szSteamId);

  if (idx >= 0)
    valid.removeAt(idx);
}

const bool IsValid(const string szSteamId) {
  if (valid.find(szSteamId) >= 0)
    return true;

  return false;
}

void RequestPlugins(EHandle eplr) {
  if (!eplr)
    return;

  CBasePlayer@ plr = cast<CBasePlayer@>(eplr.GetEntity());

  const string szSteamId = g_EngineFuncs.GetPlayerAuthId(plr.edict());
  valid.insertLast(szSteamId);
  g_Scheduler.SetTimeout("Invalid", 1.0f, szSteamId);

  NetworkMessage message(MSG_ONE, NetworkMessages::NetworkMessageType(146), plr.edict());
    message.WriteLong(1); // Query plugin list
  message.End();
}

void ReportPluginInfo(const CCommand@ args) {
  CBasePlayer@ plr = g_ConCommandSystem.GetCurrentPlayer();
  const string szSteamId = g_EngineFuncs.GetPlayerAuthId(plr.edict());

  if (IsValid(szSteamId) && args.ArgC() >= 4) {
    if (verbose)
      g_EngineFuncs.ServerPrint("[MetaHookPlugins " + plr.pev.netname + "] #" + args[1] + " :: apiver: " + args[2] + " :: name: " + args[3] + " :: ver: " + args[4] + "\n");

    if (!IsChad(plr)) {
      ChadEnable(plr);
      UpdateEnt();
    }
  }
}

void UpdateEnt() {
  if (chadent != -1) {
    CBaseEntity@ ent = g_EntityFuncs.Instance(chadent);
    CustomKeyvalues@ chadkv = ent.GetCustomKeyvalues();
    chadkv.SetKeyvalue(bitskey, string_t(string(metachads)));
  }
}

void ListChads(const CCommand@ args) {
  CBasePlayer@ plr = g_ConCommandSystem.GetCurrentPlayer();

  g_PlayerFuncs.ClientPrint(plr, HUD_PRINTCONSOLE, "CHADS (MetaHookSv users)\n------------------------\n");

  array<string> tmp;

  for (int i = 1; i <= g_Engine.maxClients; i++) {
    CBasePlayer@ chad = g_PlayerFuncs.FindPlayerByIndex(i);

    if (chad is null || !chad.IsConnected())
      continue;

    if (IsChad(chad))
      tmp.insertLast(string(chad.pev.netname));
  }

  if (tmp.length() > 0) {
    tmp.sort(function(a,b) { return a.ICompareN(b, 64) < b.ICompareN(a, 64); });

    for (uint i = 0; i < tmp.length(); i++) {
      g_PlayerFuncs.ClientPrint(plr, HUD_PRINTCONSOLE, "- " + tmp[i] + "\n");
    }

    tmp.resize(0);
  }
  else {
    g_PlayerFuncs.ClientPrint(plr, HUD_PRINTCONSOLE, "none\n");
  }
}

void ChadEnable(CBasePlayer@ plr) {
  const uint uiPlrBit = (1 << (plr.entindex() & 31));
  metachads |= uiPlrBit;
}

void ChadDisable(CBasePlayer@ plr) {
  const uint uiPlrBit = (1 << (plr.entindex() & 31));
  metachads &= ~uiPlrBit;
}

const bool IsChad(CBasePlayer@ plr) {
  const uint uiPlrBit = (1 << (plr.entindex() & 31));
  return metachads & uiPlrBit == uiPlrBit;
}
