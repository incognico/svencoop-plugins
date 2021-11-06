const string bitskey = "$s_bits";
uint metachads = 0; // bitfield
int chadent = -1;

void PluginInit() {
  g_Module.ScriptInfo.SetAuthor("incognico");
  g_Module.ScriptInfo.SetContactInfo("https://discord.gg/qfZxWAd");

  g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @ClientPutInServer);
  g_Hooks.RegisterHook(Hooks::Player::ClientDisconnect, @ClientDisconnect);

  CBaseEntity@ oldchadent = g_EntityFuncs.FindEntityByTargetname(null, "_MetaChads");

  if (g_EntityFuncs.IsValidEntity(oldchadent.edict())) {
    chadent = g_EntityFuncs.EntIndex(oldchadent.edict());
    CustomKeyvalues@ chadkv = oldchadent.GetCustomKeyvalues();

    if (chadkv.HasKeyvalue(bitskey))
      metachads = atoui(chadkv.GetKeyvalue(bitskey).GetString());
  }
}

CClientCommand g_ReportMetahookPlugin("mh_reportplugin", "ReportPluginInfo", @ReportPluginInfo);

void MapInit() {
  metachads = 0;

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

void RequestPlugins(EHandle eplr) {
  if (!eplr)
    return;

  CBasePlayer@ plr = cast<CBasePlayer@>(eplr.GetEntity());

  NetworkMessage message(MSG_ONE, NetworkMessages::NetworkMessageType(146), plr.edict());
    message.WriteLong(1); // Query plugin list
  message.End();
}

void ReportPluginInfo(const CCommand@ args) {
  CBasePlayer@ plr = g_ConCommandSystem.GetCurrentPlayer();

  if (args.ArgC() >= 4) {
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
    chadkv.SetKeyvalue(bitskey, "" + metachads);
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
