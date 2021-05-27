/////////////////////////////////////////////
// Model Color Changer
//
//  This change player model color dynamically.
//
//    RED   YELLOW   BLUE    GREEN  PURPLE
//  | ﾟДﾟ| | ﾟДﾟ| | ﾟДﾟ| | ﾟДﾟ| | ﾟДﾟ|
/////////////////////////////////////////////

// Const
const float LIFE_TIME = 600; // life time for dictinary
const int STATUS_NONE    = 0;
const int STATUS_RANDOM  = 1;
const int STATUS_RAINBOW = 2;

// Global
CScheduledFunction@ g_pTimer = null;
CCVar@ g_pInterval;

// Player model Info
class CModelInfo {
    int status;     // mode
    int colorIndex; // index for Rainbow mode
    float lastTime; // time for delete
    
    int defTop;     // default Top color
    int defBottom;  // default Bottom color
    
    CModelInfo() {
        lastTime   = g_EngineFuncs.Time();
        status     = 0;
        colorIndex = 0;
        defTop     = 0;
        defBottom  = 0;
    }
}
dictionary g_statusDict;


/** Plugin Init */
void PluginInit() {
    // ....(^^;)b yay
    g_Module.ScriptInfo.SetAuthor("takedeppo.50cal");
    g_Module.ScriptInfo.SetContactInfo("http://steamcommunity.com/id/takedeppo");

    // Cvar
    @g_pInterval = CCVar("interval", 0.5f, "Color update time [seconds]", ConCommandFlag::AdminOnly);
    
    // Event hook
    g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @PlayerJoin);
    g_Hooks.RegisterHook(Hooks::Player::ClientSay, @ClientSay);
    g_Hooks.RegisterHook(Hooks::Game::MapChange, @MapChange);
    
    g_statusDict.deleteAll();
}

/** Map Init */
void MapInit() {
    
    // check players color info
    array<string> @statusList = g_statusDict.getKeys();
    
    float currentTime = g_EngineFuncs.Time();
    for (uint i = 0 ; i < statusList.length(); i++) {
        string steamId = statusList[i];
        CModelInfo modelInfo = cast<CModelInfo>(g_statusDict[steamId]);
        
        if (currentTime >= modelInfo.lastTime + LIFE_TIME) {
            g_statusDict.delete(steamId);
        }
    }
    
    // Timer
    if (g_pTimer !is null) {
        g_Scheduler.RemoveTimer(g_pTimer);
    }
    @g_pTimer = g_Scheduler.SetInterval("ColorChangeTimer", g_pInterval.GetFloat());
}

/** Player join */
HookReturnCode PlayerJoin(CBasePlayer@ pPlayer) {
    // Get Key Info from SteamID
    string steamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
    CModelInfo modelInfo;
    if (g_statusDict.exists(steamId)) {
        modelInfo = cast<CModelInfo>(g_statusDict[steamId]);
    }
    KeyValueBuffer@ pColor = g_EngineFuncs.GetInfoKeyBuffer(pPlayer.edict());
    modelInfo.defTop    = atoi(pColor.GetValue("topcolor"));
    modelInfo.defBottom = atoi(pColor.GetValue("bottomcolor"));
    modelInfo.lastTime  = g_EngineFuncs.Time();
    g_statusDict.set(steamId, modelInfo);
    
    return HOOK_CONTINUE;
}


/** Map End */
HookReturnCode MapChange() {
    // Stop timer
    if (g_pTimer !is null) {
        g_Scheduler.RemoveTimer(g_pTimer);
    }
    
    // Update Players color info time
    for (int i = 1; i <= g_Engine.maxClients; i++) {
        CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
        if ((pPlayer !is null) && (pPlayer.IsConnected()) ) {
            string steamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
            if (g_statusDict.exists(steamId)) {
                CModelInfo modelInfo = cast<CModelInfo>(g_statusDict[steamId]);
                modelInfo.lastTime = g_EngineFuncs.Time();
                g_statusDict.set(steamId, modelInfo);
            }
        }
    }
    return HOOK_CONTINUE;
}

/** Say hook */
HookReturnCode ClientSay(SayParameters@ pParams) {
    const CCommand@ pArguments = pParams.GetArguments();
    if (pArguments.ArgC() >= 1) {
        const string arg1 = pArguments.Arg(0).ToLowercase();
        const string arg2 = pArguments.Arg(1).ToLowercase();
        
        CBasePlayer@ pPlayer = pParams.GetPlayer();
        if ((pPlayer !is null) && (pPlayer.IsConnected())) {
            if ((arg1 == ".color") || (arg1 == "!color")) {
                pParams.ShouldHide = true;
                
                // Get Key Info from SteamID
                string steamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
                CModelInfo modelInfo = cast<CModelInfo>(g_statusDict[steamId]);
                
                if (arg2 == "random") {
                    modelInfo.status = STATUS_RANDOM;
                    g_statusDict.set(steamId, modelInfo);
                    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "ModelColor: Random mode\n");
                    
                } else if (arg2 == "rainbow") {
                    modelInfo.status = STATUS_RAINBOW;
                    g_statusDict.set(steamId, modelInfo);
                    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "ModelColor: Rainbow mode\n");
                    
                } else {
                    modelInfo.status = STATUS_NONE;
                    g_statusDict.set(steamId, modelInfo);
                    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "ModelColor: Default\n");
                    
                    KeyValueBuffer@ pColor = g_EngineFuncs.GetInfoKeyBuffer(pPlayer.edict());
                    pColor.SetValue("topcolor", modelInfo.defTop);
                    pColor.SetValue("bottomcolor",  modelInfo.defBottom);
                }
                
            } 
        }
    }
    return HOOK_CONTINUE;
}

/** Color Change Timer */
void ColorChangeTimer() {
    for (int i = 1; i <= g_Engine.maxClients; i++ ) {
        // Check Players
        CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
        if ((pPlayer !is null) && (pPlayer.IsConnected())) {
            
            // Get Key Info from SteamID
            string steamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
            CModelInfo modelInfo = cast<CModelInfo>(g_statusDict[steamId]);
            KeyValueBuffer@ pColor = g_EngineFuncs.GetInfoKeyBuffer(pPlayer.edict());
            
            if (modelInfo.status == STATUS_RANDOM) {
                pColor.SetValue("topcolor", Math.RandomLong(0, 255));
                pColor.SetValue("bottomcolor", Math.RandomLong(0, 255));
                
            } else if (modelInfo.status == STATUS_RAINBOW) {
                int mainColor = (modelInfo.colorIndex + 6) % 255;
                int subColor  = (mainColor + 20) % 255;
                
                pColor.SetValue("topcolor", mainColor);
                pColor.SetValue("bottomcolor", subColor);
                
                modelInfo.colorIndex = mainColor;
                g_statusDict.set(steamId, modelInfo);
            }
            
        }
    }
}
