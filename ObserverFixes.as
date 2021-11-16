// https://github.com/RedSprend/svencoop_plugins/blob/master/svencoop/scripts/plugins/ObserverBugFixes.as
// but with Player*Observer Hooks instead of PlayerPostThink

void PluginInit() {
  g_Module.ScriptInfo.SetAuthor("incognico");
  g_Module.ScriptInfo.SetContactInfo("https://discord.gg/qfZxWAd");

  g_Hooks.RegisterHook(Hooks::Player::PlayerEnteredObserver, @PlayerEnteredObserver);
  g_Hooks.RegisterHook(Hooks::Player::PlayerLeftObserver, @PlayerLeftObserver);
}

HookReturnCode PlayerEnteredObserver(CBasePlayer@ pPlayer) {
  pPlayer.pev.movetype = MOVETYPE_NOCLIP;
  pPlayer.pev.flags   |= FL_NOTARGET;

  return HOOK_CONTINUE;
}

HookReturnCode PlayerLeftObserver(CBasePlayer@ pPlayer) {
  pPlayer.pev.flags &= ~FL_NOTARGET;

  return HOOK_CONTINUE;
}
