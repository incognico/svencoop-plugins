void print(string text) { g_Game.AlertMessage( at_console, text); }
void println(string text) { print(text + "\n"); }

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "w00tguy" );
	g_Module.ScriptInfo.SetContactInfo( "asdf" );
	
	g_Scheduler.SetInterval("undo_forced_models", 0.5, -1);
}

void undo_forced_models() {
	for ( int i = 1; i <= g_Engine.maxClients; i++ )
	{
		CBasePlayer@ plr = g_PlayerFuncs.FindPlayerByIndex(i);
		
		if (plr is null or !plr.IsConnected()) {
			continue;
		}
		
		KeyValueBuffer@ pKeyvalues = g_EngineFuncs.GetInfoKeyBuffer( plr.edict() );
		string currentModel = pKeyvalues.GetValue( "model" );
		plr.ResetOverriddenPlayerModel(true, true);
		string wantModel = pKeyvalues.GetValue( "model" );
		
		if (currentModel != wantModel) {
			plr.SetOverriddenPlayerModel(currentModel);
			g_Scheduler.SetTimeout("delay_update_model", 0.2f, EHandle(plr), wantModel);
		}
	}
}

void delay_update_model(EHandle h_plr, string model) {
	CBasePlayer@ plr = cast<CBasePlayer@>(h_plr.GetEntity());
	if (plr is null or !plr.IsConnected()) {
		return;
	}
	
	plr.SetOverriddenPlayerModel(model);
}
