//========================================
// NINTAI GLOW 
// (参考: Zodemon氏のSimpleGlow)
//========================================
int    g_totalDeathCount = 0;       // 全プレーヤー死亡数
int[]  g_playerDeathCount(32+1);    // プレイヤーごと死亡数 (1-32)
bool[] g_playerGlowEnable(32+1);    // glow有効フラグ(1-32)

// 7色制御用
CScheduledFunction@ g_colorRotation = null;
bool g_colorRotActive = false;
int g_spriteTail; // sprite
int g_spriteWave;

void PluginInit() {
    g_Module.ScriptInfo.SetAuthor("takedeppo.50cal");
    g_Module.ScriptInfo.SetContactInfo("http://steamcommunity.com/id/takedeppo");

    // イベントフック
    g_Hooks.RegisterHook(Hooks::Player::ClientSay,         @ClientSay);
    g_Hooks.RegisterHook(Hooks::Player::PlayerSpawn,       @PlayerSpawn);
    g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @ClientPutInServer);
    g_Hooks.RegisterHook(Hooks::Player::ClientDisconnect,  @ClientDisconnect);
    g_Hooks.RegisterHook(Hooks::Player::PlayerKilled,      @PlayerKilled);
}

// マップ初期化時
void MapInit() {
    // スプライトファイルプリキャッシュ
    g_spriteTail = g_Game.PrecacheModel("sprites/zbeam3.spr");
    g_spriteWave = g_Game.PrecacheModel("sprites/laserbeam.spr");
    
    // 死亡カウンタをリセット
    g_totalDeathCount = 0;
    for (uint i = 1; i < g_playerDeathCount.length(); i++) {
        initPlayer(i);
    }
    
    // 7色情報リセット
    g_Scheduler.RemoveTimer(g_colorRotation);
    g_colorRotActive = false;
}

// プレイヤー発言時
HookReturnCode ClientSay(SayParameters@ pParams) {
    // 引数
    const CCommand@ pArguments = pParams.GetArguments();
    if (pArguments.ArgC() == 2) {
        if ((pArguments.Arg(0) == "glow") || (pArguments.Arg(0) == "!glow")) {
            pParams.ShouldHide = true;
            // プレイヤー情報取得
            CBasePlayer@ pPlayer = pParams.GetPlayer();
            if (pPlayer !is null) {
                int playerIndex = g_EngineFuncs.IndexOfEdict(pPlayer.edict());
                    
                // OFF
                if (pArguments.Arg(1) == "off") {
                    g_playerGlowEnable[playerIndex] = false;
                    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "※発光設定OFFにしたよ (now, glow setting is OFF) ....(^^;)");
                    
                    // プレイヤーエンティティを戻す
                    pPlayer.pev.rendermode  = kRenderNormal;
                    pPlayer.pev.renderfx    = kRenderFxNone;
                    pPlayer.pev.renderamt   = 255;
                    pPlayer.pev.rendercolor = Vector(255,255,255);
                    
                // ON
                } else if (pArguments.Arg(1) == "on") {
                    g_playerGlowEnable[playerIndex] = true;
                    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "※発光設定ONにしたよ (now, glow setting is ON) ....(^^;)");
                    
                    // プレイヤーを光らせる
                    pPlayer.pev.rendermode  = kRenderNormal;
                    pPlayer.pev.renderfx    = kRenderFxGlowShell;
                    pPlayer.pev.renderamt   = 4;
                    pPlayer.pev.rendercolor = getGlowColor(g_playerDeathCount[playerIndex]);
                }
            }
            return HOOK_HANDLED;
        }
    }
    return HOOK_CONTINUE;
}

// プレイヤー参加時
HookReturnCode PlayerSpawn(CBasePlayer@ pPlayer) {
    // 参加時に初期化
    int playerIndex = g_EngineFuncs.IndexOfEdict(pPlayer.edict());
    g_Scheduler.SetTimeout("playerSpawnDelay", 1.0f, playerIndex);
    
    return HOOK_CONTINUE;
}

// プレイヤースポーン後、タイマー
void playerSpawnDelay(int &in playerIndex) {
    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(playerIndex);
    // glowが有効なら
    if ((pPlayer !is null) && (pPlayer.IsConnected()) && (g_playerGlowEnable[playerIndex])) {
        
        // プレイヤーへ通知
        if (g_playerDeathCount[playerIndex] == 50) {
            g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "" + pPlayer.pev.netname + "は最高に光っている!! (glowing maximum!!) LV MAX....(^^;)b ｶｺｲｲ");
            
            // 7色発光スタート
            if (!g_colorRotActive) {
                @g_colorRotation = g_Scheduler.SetInterval("colorRotation", 1.0f);
                g_colorRotActive = true;
            }
            
        } else if (g_playerDeathCount[playerIndex] == 40) {
            g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "" + pPlayer.pev.netname + "はさらに光っている!! (glowing more!!) LV6....(^^;)b ｶｺｲｲ");
            
        } else if (g_playerDeathCount[playerIndex] == 35) {
            g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "" + pPlayer.pev.netname + "はさらに光っている!! (glowing more!!) LV5....(^^;)b ｶｺｲｲ");
            
        } else if (g_playerDeathCount[playerIndex] == 30) {
            g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "" + pPlayer.pev.netname + "はさらに光っている!! (glowing more!!) LV4....(^^;)b ｶｺｲｲ");
            
        } else if (g_playerDeathCount[playerIndex] == 25) {
            g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "" + pPlayer.pev.netname + "はさらに光っている!! (glowing more!!) LV3....(^^;)b ｶｺｲｲ");
            
        } else if (g_playerDeathCount[playerIndex] == 20) {
            g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "" + pPlayer.pev.netname + "はさらに光っている!! (glowing more!!) LV2....(^^;)b ｶｺｲｲ");
            
        } else if (g_playerDeathCount[playerIndex] == 15) {
            g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "" + pPlayer.pev.netname + "は光っている!! (now glowing!!) ....(^^;)b ｶｺｲｲ");
        }
       
        // プレイヤーを光らせる
        pPlayer.pev.rendermode  = kRenderNormal;
        pPlayer.pev.renderfx    = kRenderFxGlowShell;
        pPlayer.pev.renderamt   = 4;
        pPlayer.pev.rendercolor = getGlowColor(g_playerDeathCount[playerIndex]);
    }
}

// 発光色
Vector getGlowColor(int &in deathCount) {
    Vector color = Vector(0, 0, 0);
    
    // ターコイズ
    if (deathCount >= 50) {
        color = Vector(0, 255, 200);
    // グリーン
    } else if (deathCount >= 40) {
        color = Vector(0, 255, 0);
    // ライム
    } else if (deathCount >= 35) {
        color = Vector(128, 255, 0);
    // 黄色
    } else if (deathCount >= 30) {
        color = Vector(255, 255, 0);
    // オレンジ
    } else if (deathCount >= 25) {
        color = Vector(255, 128, 0);
    // 赤
    } else if (deathCount >= 20) {
        color = Vector(255, 0, 0);
    // 白
    } else if (deathCount >= 15) {
        color = Vector(255, 255, 255);
    }
    return color;
}

// 7色発光処理
void colorRotation() {
    CBasePlayer@ pPlayer = null;
    int tailId = 0;
    
    int r;
    int g;
    int b;
    
    for (uint i = 1; i < g_playerDeathCount.length(); i++) {
        @pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
        if ((pPlayer !is null) && (pPlayer.IsConnected())
            && (g_playerDeathCount[i] >= 50)) {
                
            r = Math.RandomLong(0, 255);
            g = Math.RandomLong(0, 255);
            b = Math.RandomLong(0, 255);
                
            pPlayer.pev.rendercolor = Vector(r, g, b);
                            
            if (g_playerGlowEnable[i]) {
                tailId = g_EntityFuncs.EntIndex(pPlayer.edict());
                // Tail処理;
                NetworkMessage messageOff(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null);
                    messageOff.WriteByte(TE_KILLBEAM);
                    messageOff.WriteShort(tailId);
                messageOff.End();
                NetworkMessage message(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null);
                    message.WriteByte(TE_BEAMFOLLOW);
                    message.WriteShort(tailId);
                    message.WriteShort(g_spriteTail);
                    message.WriteByte(4.0f);    // duration
                    message.WriteByte(16);      // size
                    message.WriteByte(r);       // color red
                    message.WriteByte(g);       // color green
                    message.WriteByte(b);       // color blue
                    message.WriteByte(100);     // color alpha
                message.End();
                // 発光
                NetworkMessage messageLight(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null);
                messageLight.WriteByte(TE_DLIGHT);
                messageLight.WriteCoord(pPlayer.pev.origin.x);
                messageLight.WriteCoord(pPlayer.pev.origin.y);
                messageLight.WriteCoord(pPlayer.pev.origin.z);
                messageLight.WriteByte(16);
                messageLight.WriteByte(r);
                messageLight.WriteByte(g);
                messageLight.WriteByte(b);
                messageLight.WriteByte(100);
                messageLight.WriteByte(50);
                messageLight.End();
                
                // 集中線
                NetworkMessage messageImplosion(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null);
                messageImplosion.WriteByte(TE_IMPLOSION);
                messageImplosion.WriteCoord(pPlayer.pev.origin.x);
                messageImplosion.WriteCoord(pPlayer.pev.origin.y);
                messageImplosion.WriteCoord(pPlayer.pev.origin.z);
                messageImplosion.WriteByte(50);
                messageImplosion.WriteByte(10);
                messageImplosion.WriteByte(2);
                messageImplosion.End();
                
                // 波動
                NetworkMessage messageWave(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null);
                messageWave.WriteByte(TE_BEAMCYLINDER);
                messageWave.WriteCoord(pPlayer.pev.origin.x);
                messageWave.WriteCoord(pPlayer.pev.origin.y);
                messageWave.WriteCoord(pPlayer.pev.origin.z);
                messageWave.WriteCoord(pPlayer.pev.origin.x);
                messageWave.WriteCoord(pPlayer.pev.origin.y);
                messageWave.WriteCoord(pPlayer.pev.origin.z + 100);
                messageWave.WriteShort(g_spriteWave);
                messageWave.WriteByte(0);
                messageWave.WriteByte(16);
                messageWave.WriteByte(8);
                messageWave.WriteByte(8);
                messageWave.WriteByte(0);
                messageWave.WriteByte(r);
                messageWave.WriteByte(g);
                messageWave.WriteByte(b);
                messageWave.WriteByte(100);
                messageWave.WriteByte(0);
                messageWave.End();
            }
            
        }
    }
}

// 初期化
void initPlayer(int &in playerIndex) {
    g_playerDeathCount[playerIndex] = 0;
    g_playerGlowEnable[playerIndex] = true;
}

// 接続時
HookReturnCode ClientPutInServer(CBasePlayer@ pPlayer) {
    int playerIndex = g_EngineFuncs.IndexOfEdict(pPlayer.edict());
    initPlayer(playerIndex);
    return HOOK_CONTINUE;
}

// 切断時
HookReturnCode ClientDisconnect(CBasePlayer@ pPlayer) {
    int playerIndex = g_EngineFuncs.IndexOfEdict(pPlayer.edict());
    initPlayer(playerIndex);
    return HOOK_CONTINUE;
}

// 死亡時
HookReturnCode PlayerKilled (CBasePlayer@ pPlayer, CBaseEntity@ pEntity, int param) {
    // プレイヤー死亡数を加算
    int playerIndex = g_EngineFuncs.IndexOfEdict(pPlayer.edict());
    g_playerDeathCount[playerIndex]++;
    
    // 全体死亡数を加算
    g_totalDeathCount++;
    string msg;
    if ((g_totalDeathCount % 100) == 0) {
        msg = "[祝]: Total " + g_totalDeathCount + " death達成!! (Congrats!!)  ....(^^;)v ﾅｲｽ";
        g_Scheduler.SetTimeout("messageDelayAll", 3.0f, msg );
    }
    return HOOK_CONTINUE;
}


// ディレイメッセージ
void messageDelayAll(string &in msg) {
    g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, msg);
}
