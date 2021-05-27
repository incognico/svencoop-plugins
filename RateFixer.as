const int twlz_rate  = 100000;
const int twlz_dlmax = 1024;

void PluginInit() {
  g_Module.ScriptInfo.SetAuthor("incognico");
  g_Module.ScriptInfo.SetContactInfo("https://discord.gg/qfZxWAd");

  g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @ClientPutInServer);
}

HookReturnCode ClientPutInServer(CBasePlayer@ pPlayer) {
  KeyValueBuffer@ pInfos = g_EngineFuncs.GetInfoKeyBuffer(pPlayer.edict());

  int rate  = atoi(pInfos.GetValue("rate"));
  if (rate < twlz_rate)
    pInfos.SetValue("rate", twlz_rate);

  int dlmax = atoi(pInfos.GetValue("cl_dlmax"));
  if (dlmax < twlz_dlmax)
    pInfos.SetValue("cl_dlmax", twlz_dlmax);

  return HOOK_CONTINUE;
}
