const array<string> answers = {
'It is certain.',
'It is decidedly so.',
'Without a doubt.',
'Yes - definitely.',
'You may rely on it.',
'As I see it, yes.',
'Most likely.',
'Outlook good.',
'Yes.',
'Signs point to yes.',
'Reply hazy, try again.',
'Ask again later.',
'Better not tell you now.',
'Cannot predict now.',
'Concentrate and ask again.',
'Don\'t count on it.',
'My reply is no.',
'My sources say no.',
'Outlook not so good.',
'Very doubtful.'
};

const uint delay = 10;

array<uint> antiflood(33);

void PluginInit() {
  g_Module.ScriptInfo.SetAuthor("incognico");
  g_Module.ScriptInfo.SetContactInfo("https://discord.gg/qfZxWAd");

  g_Hooks.RegisterHook(Hooks::Weapon::WeaponTertiaryAttack, @WeaponTertiaryAttack);
}

void MapStart() {
  antiflood.resize(0);
  antiflood.resize(33);
}

HookReturnCode WeaponTertiaryAttack(CBasePlayer@ pPlayer, CBasePlayerWeapon@ wep) {
  if (wep is null)
    return HOOK_CONTINUE;

  if (wep.GetClassname() == "weapon_medkit") {
    const int idx = pPlayer.entindex();
    const uint t  = uint(g_EngineFuncs.Time());
    const uint d  = t - antiflood[idx];

    if (d > delay) {
      g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCENTER, answers[Math.RandomLong(0, answers.length()-1)] + "\n");
      antiflood[idx] = t;
    }

    return HOOK_HANDLED;
  }

  return HOOK_CONTINUE;
}
