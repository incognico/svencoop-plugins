void PluginInit(){
  g_Module.ScriptInfo.SetAuthor("incognico");
  g_Module.ScriptInfo.SetContactInfo("https://discord.gg/qfZxWAd");

  g_Hooks.RegisterHook( Hooks::Player::PlayerKilled, @PlayerKilled );
}

HookReturnCode PlayerKilled( CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib ) {
  if (g_SurvivalMode.IsActive() && pAttacker.IsPlayer() && pPlayer == pAttacker && !pPlayer.pev.FlagBitSet(FL_ONGROUND) && !((pPlayer.pev.health < -40 && iGib != GIB_NEVER) || iGib == GIB_ALWAYS)) {
    pPlayer.GibMonster();
    pPlayer.pev.deadflag = DEAD_DEAD;
    pPlayer.pev.effects |= EF_NODRAW;
  }

  return HOOK_CONTINUE;
}
