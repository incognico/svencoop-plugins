const array<string> defaultmodels = { 'aswat', 'barney', 'barney2', 'barniel', 'betagordon', 'boris', 'bs_unarmored_barney_1', 'bs_unarmored_barney_2', 'cannibal', 'cl_suit', 'colette', 'dgf_robogrunt', 'etac', 'fassn', 'gina', 'gman', 'gordon', 'helmet', 'hevbarney', 'hevbarney2', 'hevscientist', 'hevscientist2', 'hevscientist3', 'hevscientist4', 'hevscientist5', 'hl_construction', 'hl_gus', 'kate', 'madscientist', 'massn', 'massn_blue', 'massn_green', 'massn_normal', 'massn_red', 'massn_yell', 'obi09', 'op4_cigar', 'op4_grunt', 'op4_grunt2', 'op4_heavy', 'op4_lance', 'op4_medic', 'op4_medic2', 'op4_mp', 'op4_mp2', 'op4_recon', 'op4_recon2', 'op4_robot', 'op4_rocket', 'op4_rocket2', 'op4_scientist_einstein', 'op4_scientist_luther', 'op4_scientist_slick', 'op4_scientist_walter', 'op4_shephard', 'op4_shotgun', 'op4_shotgun2', 'op4_sniper', 'op4_sniper2', 'op4_torch', 'op4_torch2', 'op4_tower', 'op4_tower2', 'otis', 'rgrunt', 'robo', 'scientist', 'scientist2', 'scientist3', 'scientist4', 'scientist5', 'scientist6', 'ta_assault', 'ta_flanker', 'ta_marine', 'ta_operative', 'ta_research', 'ta_support', 'ta_tank', 'th_civpaul', 'th_cl_suit', 'th_dave', 'th_einar', 'th_einstein', 'th_gangster', 'th_host', 'th_jack', 'th_neil', 'th_nurse', 'th_nypdcop', 'th_orderly', 'th_patient', 'th_paul', 'th_slick', 'th_worker', 'zombie', 'sieni' };
const array<string> cmds = { '.vc', 'glow', 'trail', 'speedometer', 'hat', '.observer', '.observe', '.spectate', '.cspitch', '.help', '.lost', '.ping', 'party?', 'pandemic?', 'afk?', 'rtv', '.e', '.c' };

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "April" );
	g_Module.ScriptInfo.SetContactInfo( "April" );

   g_Hooks.RegisterHook(Hooks::Player::ClientSay, @ClientSay);

	g_Scheduler.SetInterval("force_models", 0.5, -1);
}

void force_models()
{
	for ( int i = 1; i <= g_Engine.maxClients; i++ )
	{
		CBasePlayer@ plr = g_PlayerFuncs.FindPlayerByIndex(i);

		if (plr is null or !plr.IsConnected()) {
			continue;
		}

		KeyValueBuffer@ pKeyvalues = g_EngineFuncs.GetInfoKeyBuffer( plr.edict() );
		string currentModel = pKeyvalues.GetValue( "model" ).ToLowercase();

		if (defaultmodels.find(currentModel) >= 0) {
			continue;
		}

		plr.ResetOverriddenPlayerModel(true, true);
		string wantModel = pKeyvalues.GetValue( "model" ).ToLowercase();

		if (defaultmodels.find(currentModel) < 0) {
			wantModel = defaultmodels[Math.RandomLong(0, defaultmodels.length()-1)];
		}

		if (currentModel != wantModel) {
			plr.SetOverriddenPlayerModel(wantModel);
		}
	}
}

HookReturnCode ClientSay(SayParameters@ pParams) {
  const CCommand@ pArguments = pParams.GetArguments();

  if (pArguments.ArgC() > 0) {
    const string command = pArguments.Arg(0).ToLowercase();

    if (cmds.find(command) >= 0) {
      pParams.ShouldHide = true;
      return HOOK_HANDLED;
    }
  }

   return HOOK_CONTINUE;
}
