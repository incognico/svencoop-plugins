const int g_MaxVotes = 3; // times per map party mode can be enabled
const int g_VoteWaitTime = 300; // time in seconds between a new vote (on or off) is possible
//const string g_PartySound = "svencoop2/stadium3.wav"; // path to some sound in sound/ to play when PM was enabled or remove lines 30,31,85
const string g_PartySound = "twlz/party.wav"; // path to some sound in sound/ to play when PM was enabled or remove lines 30,31,85

const string g_Keyrendermode = "$i_origrendermode";
const string g_Keyrenderfx = "$i_origrenderfx";
const string g_Keyrenderamt = "$f_origrenderamt";
const string g_KeyColor = "$v_origcolor";

int g_VoteCount = 0;
int g_LastVoteTime = 0; 

CClientCommand g_PartyModeOn("partymodeon", "Turn on Party Mode :D (admin only)", @StartPartyModeCmd);
CClientCommand g_PartyModeOff("partymodeoff", "Turn off Party Mode :( (admin only)", @StopPartyModeCmd);

CScheduledFunction@ g_pThinkFunc = null;

void PluginInit() {
  g_Module.ScriptInfo.SetAuthor("incognico");
  g_Module.ScriptInfo.SetContactInfo("https://discord.gg/qfZxWAd");

  g_Hooks.RegisterHook(Hooks::Game::MapChange, @MapChange);
  g_Hooks.RegisterHook(Hooks::Player::ClientSay, @ClientSay);
}

void MapInit() {
  g_VoteCount = 0;
  g_LastVoteTime = 0;

  g_Game.PrecacheGeneric('sound/' + g_PartySound);
  g_SoundSystem.PrecacheSound(g_PartySound);
}

HookReturnCode MapChange() {
  StopPartyMode(true);

  return HOOK_CONTINUE;
}

HookReturnCode ClientSay(SayParameters@ pParams) {
  const CCommand@ pArguments = pParams.GetArguments();
  CBasePlayer@ pPlayer = pParams.GetPlayer();

  if (pArguments.ArgC() > 0 && (pArguments.Arg(0).ToLowercase() == "party?" || pArguments.Arg(0).ToLowercase() == "partymode" || pArguments.Arg(0).ToLowercase() == "partymode?")) {
    if (g_LastVoteTime != 0 && (uint(g_EngineFuncs.Time()) - g_LastVoteTime) < g_VoteWaitTime) {
      g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[Info] Calm down, there was a vote little time ago already.\n");
	  pParams.ShouldHide = true;
	  return HOOK_HANDLED;
    }
	if (g_SurvivalMode.IsEnabled() || g_SurvivalMode.IsActive()) {
      g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[Info] Party mode disabled during survival.\n");
	  pParams.ShouldHide = true;
	  return HOOK_HANDLED;
    }
    //if () {
    //  g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "[Info] Voting is currently not allowed.\n");
    //  return HOOK_HANDLED;
    //}

    if (g_pThinkFunc !is null) {
      Vote@ PMVote = Vote("PartyOff", "Stop the party? :(", 15.0f, 66.0f);
      PMVote.SetYesText("Yes, let's go home");
      PMVote.SetNoText("No, I don't want to leave");
      PMVote.SetVoteBlockedCallback(@PMVoteBlocked);
      PMVote.SetVoteEndCallback(@PMVoteEnd);
      PMVote.Start();
    }
    else if (g_VoteCount >= g_MaxVotes) {
      g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "[Info] Maximum tries to toggle Party Mode reached, try again after map change.\n");
    }
    else {
      Vote@ PMVote = Vote("PartyOn", "ZOMG let's have a fucking party!!!??", 15.0f, 75.0f);
      PMVote.SetYesText("Yes, let's party");
      PMVote.SetNoText("No, I'd rather stay at home");
      PMVote.SetVoteBlockedCallback(@PMVoteBlocked);
      PMVote.SetVoteEndCallback(@PMVoteEnd);
      PMVote.Start();
      g_VoteCount++;
    }
    return HOOK_HANDLED;
  }
  return HOOK_CONTINUE;
}

void PMVoteBlocked(Vote@, float flTime) {
  g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "[Info] Another vote is currently active, try again in " + ceil(flTime) + " seconds.\n");
}

void PMVoteEnd(Vote@ pVote, bool fResult, int) {
  g_LastVoteTime = uint(g_EngineFuncs.Time());

  if (pVote.GetName() == "PartyOn") {
    if (fResult) {
      StartPartyMode();
      g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "[Info] LOL PARTY LOL PARTY LOL PARTY!\n");
      g_SoundSystem.PlaySound(g_EntityFuncs.IndexEnt(0), CHAN_STATIC, g_PartySound, 1.0f, ATTN_NONE, 0, 100);
    }
    else {
      g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "[Info] The boring players choose to stay at home.\n");
    }
  }
  else if (pVote.GetName() == "PartyOff") {
    if (fResult) {
      StopPartyMode();
      g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "[Info] The party is over. Go home.\n");
    }
    else {
      g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "[Info] YAY MORE PARTY LOL! :D:D:D\n");
      g_SoundSystem.PlaySound(g_EntityFuncs.IndexEnt(0), CHAN_STATIC, g_PartySound, 1.0f, ATTN_NONE, 0, 100);
    }
  }
}

void PushRenderMode(CBaseEntity@ pEnt) {
  CustomKeyvalues@ pCustom = pEnt.GetCustomKeyvalues();
  
  pCustom.SetKeyvalue(g_Keyrendermode, pEnt.pev.rendermode);
  pCustom.SetKeyvalue(g_Keyrenderfx, pEnt.pev.renderfx);
  pCustom.SetKeyvalue(g_Keyrenderamt, pEnt.pev.renderamt);
  pCustom.SetKeyvalue(g_KeyColor, pEnt.pev.rendercolor);
}

void PopRenderMode(CBaseEntity@ pEnt) {
  CustomKeyvalues@ pCustom = pEnt.GetCustomKeyvalues();
  
  pEnt.pev.rendermode = pCustom.GetKeyvalue(g_Keyrendermode).GetInteger();
  pEnt.pev.renderfx = pCustom.GetKeyvalue(g_Keyrenderfx).GetInteger();
  pEnt.pev.renderamt = pCustom.GetKeyvalue(g_Keyrenderamt).GetFloat();
  pEnt.pev.rendercolor = pCustom.GetKeyvalue(g_KeyColor).GetVector();
}

void setRenderMode(CBaseEntity@ pEnt, int rendermode, int renderfx, float renderamt, Vector color) {
  pEnt.pev.rendermode = rendermode;
  pEnt.pev.renderfx = renderfx;
  pEnt.pev.renderamt = renderamt;
  pEnt.pev.rendercolor = color;
}

void StartPartyModeCmd(const CCommand@ pArgs) {
  CBasePlayer@ pCaller = g_ConCommandSystem.GetCurrentPlayer();

  if (g_PlayerFuncs.AdminLevel(pCaller) < ADMIN_YES)
    g_PlayerFuncs.ClientPrint(pCaller, HUD_PRINTCONSOLE, "You have no access to this command.\n");
  else {
    g_Log.PrintF("[Admin] " + pCaller.pev.netname + " did .partymodeon\n");
    StartPartyMode();
  }
}

void StartPartyMode() {
  if (g_pThinkFunc !is null) {
    return;
  }
  else {
    edict_t@ edict = null;
    CBaseEntity@ pEntity = null;

    for (int i = 0; i < g_Engine.maxEntities; ++i) {
      @edict = @g_EntityFuncs.IndexEnt(i);
      @pEntity = g_EntityFuncs.Instance(edict);

      if (pEntity !is null && (pEntity.IsBSPModel() || pEntity.IsMonster() || pEntity.IsPointEnt())) {
	    string tname = pEntity.pev.targetname;
	    if (tname.Find("as_view_wep_") == 0 || tname.Find("plugin_ghost_") == 0) {
		    // don't touch ghosts or view hands (messes up env_render_individual)
			continue;
		}
        PushRenderMode(pEntity);
	  }
    }

    @g_pThinkFunc = g_Scheduler.SetInterval("SetRandomRenderModes", 1.8f);
  }
}

void StopPartyModeCmd(const CCommand@ pArgs) {
  CBasePlayer@ pCaller = g_ConCommandSystem.GetCurrentPlayer();

  if (g_PlayerFuncs.AdminLevel(pCaller) < ADMIN_YES)
    g_PlayerFuncs.ClientPrint(pCaller, HUD_PRINTCONSOLE, "You have no access to this command.\n");
  else {
    g_Log.PrintF("[Admin] " + pCaller.pev.netname + " did .partymodeoff\n");
    StopPartyMode();
  }
}

void StopPartyMode(bool skip = false) {
  if (g_pThinkFunc is null) {
    return;
  }
  else {
    g_Scheduler.RemoveTimer(g_pThinkFunc);
    @g_pThinkFunc = null;
  }

  if (!skip) {
    edict_t@ edict = null;
    CBaseEntity@ pEntity = null;

    for (int i = 0; i < g_Engine.maxEntities; ++i) {
      @edict = @g_EntityFuncs.IndexEnt(i);
      @pEntity = g_EntityFuncs.Instance(edict);

      if (pEntity !is null && (pEntity.IsBSPModel() || pEntity.IsMonster() || pEntity.IsPointEnt())) {
		string tname = pEntity.pev.targetname;
	    if (tname.Find("as_view_wep_") == 0 || tname.Find("plugin_ghost_") == 0) {
		    // don't touch ghosts or view hands (messes up env_render_individual)
			continue;
		}
        PopRenderMode(pEntity);
	  }
    }
  }
}

void SetRandomRenderModes() {
  edict_t@ edict = null;
  CBaseEntity@ pEntity = null;

  for (int i = 0; i < g_Engine.maxEntities; ++i) {
    @edict = @g_EntityFuncs.IndexEnt(i);
    @pEntity = g_EntityFuncs.Instance(edict);

    if (pEntity !is null) {
      if (Math.RandomLong(1,2) == 1 && pEntity.IsBSPModel()) {
        setRenderMode(pEntity, kRenderTransColor, kRenderFxDistort, Math.RandomLong(10,250), Vector(Math.RandomLong(10,250),Math.RandomLong(10,250),Math.RandomLong(10, 250)));
      }
      else if (Math.RandomLong(1,2) == 1 && (pEntity.IsMonster() && !pEntity.IsPlayer()) || pEntity.IsPointEnt()) {
        setRenderMode(pEntity, kRenderNormal, kRenderFxGlowShell, Math.RandomLong(6,64), Vector(Math.RandomLong(10,250),Math.RandomLong(10,250),Math.RandomLong(10,250)));
      }
      else if (Math.RandomLong(1,2) == 1 && pEntity.IsPlayer()) {
        if (Math.RandomLong(1,10) == 1)
          setRenderMode(pEntity, kRenderTransAdd, kRenderFxDistort, Math.RandomLong(10,250), Vector(Math.RandomLong(10,250),Math.RandomLong(10,250),Math.RandomLong(10, 250)));
        else
          setRenderMode(pEntity, kRenderNormal, kRenderFxGlowShell, 4, Vector(Math.RandomLong(10,250),Math.RandomLong(10,250),Math.RandomLong(10,250)));
      }
    }
  }
}
