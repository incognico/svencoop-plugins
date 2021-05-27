/////////////////////////////////////////////
// Marker
/////////////////////////////////////////////

// グローバル
const string TAGNAME = "[Marker]";           // コンソール出力用タグ名

CScheduledFunction@ g_marker = null;
int g_spriteGohere;
int g_spriteTake;
int g_spriteUse;
int g_spriteObjective;
int g_spriteDead;
int g_spriteQuestion;
int g_spriteFlagRed;
int g_spriteFlagBlue;
int g_spriteWave;

const uint MAX_MARKER_NUM = 30;
uint[] g_markerState(MAX_MARKER_NUM);
Vector[] g_markerPos(MAX_MARKER_NUM);

const uint MARKER_DISABLED  = 0;
const uint MARKER_GOHERE    = 1;
const uint MARKER_TAKE      = 2;
const uint MARKER_USE       = 3;
const uint MARKER_OBJECTIVE = 4;
const uint MARKER_DEAD      = 5;
const uint MARKER_QUESTION  = 6;
const uint MARKER_FLAGRED   = 7;
const uint MARKER_FLAGBLUE  = 8;

// クライアントコマンド
CClientCommand g_mklist("mklist", "Show marker command arguments list", @ShowMarkerList);

/** 初期化 */
void PluginInit() {
    // ....(^^;)b yay
    g_Module.ScriptInfo.SetAuthor("takedeppo.50cal");
    g_Module.ScriptInfo.SetContactInfo("http://steamcommunity.com/id/takedeppo");

    // Event hook
    g_Hooks.RegisterHook(Hooks::Player::ClientSay, @ClientSay);
    
}
// マップ初期化時
void MapInit() {    
    // Precache
    g_spriteGohere    = g_Game.PrecacheModel("sprites/adamr/arrow_gohere.spr");
    g_spriteTake      = g_Game.PrecacheModel("sprites/adamr/arrow_take.spr");
    g_spriteUse       = g_Game.PrecacheModel("sprites/adamr/arrow_use.spr");
    g_spriteObjective = g_Game.PrecacheModel("sprites/inc_objective.spr");
    g_spriteDead      = g_Game.PrecacheModel("sprites/iplayerdead.spr");
    g_spriteQuestion  = g_Game.PrecacheModel("sprites/iunknown.spr");
    g_spriteFlagRed   = g_Game.PrecacheModel("sprites/iflagred.spr");
    g_spriteFlagBlue  = g_Game.PrecacheModel("sprites/iflagblue.spr");
    g_spriteWave      = g_Game.PrecacheModel("sprites/laserbeam.spr");
    
    // タイマー初期化
    g_Scheduler.RemoveTimer(g_marker);
    @g_marker = g_Scheduler.SetInterval("DrawMarker", 2.0f);
    
    initValues();
}

// フラグ初期化
void initValues() {
    for (uint i = 0; i < MAX_MARKER_NUM; i++) {
        g_markerState[i] = MARKER_DISABLED;
        g_markerPos[i] = Vector(0, 0, 0);
    }
}

// プレイヤー発言時
HookReturnCode ClientSay(SayParameters@ pParams) {
    
    // 引数
    const CCommand@ pArguments = pParams.GetArguments();
    if (pArguments.ArgC() >= 1) {
        const string arg1 = pArguments.Arg(0).ToLowercase();
        
        CBasePlayer@ pPlayer = pParams.GetPlayer();
        if ((pPlayer !is null) && (pPlayer.IsAlive())) {
            
            uint markerType = MARKER_GOHERE;
            if (pArguments.ArgC() >= 2) {
                string arg2 = pArguments.Arg(1).ToLowercase();
                if ((arg2 == "t") || (arg2 == "take")) {
                    markerType = MARKER_TAKE;
                } else if ((arg2 == "u") || (arg2 == "use")) {
                    markerType = MARKER_USE;
                } else if ((arg2 == "o") || (arg2 == "obj")) {
                    markerType = MARKER_OBJECTIVE;
                } else if ((arg2 == "d") || (arg2 == "danger")) {
                    markerType = MARKER_DEAD;
                } else if ((arg2 == "?") || (arg2 == "q") || (arg2 == "question")) {
                    markerType = MARKER_QUESTION;
                } else if ((arg2 == "fr") || (arg2 == "flagred")) {
                    markerType = MARKER_FLAGRED;
                } else if ((arg2 == "fb") || (arg2 == "flagred")) {
                    markerType = MARKER_FLAGBLUE;
                }
            }
                        
            // マーカー番号取得
            uint num = getMarkerIndex();
            
            // マーカー追加
            if ((arg1 == "!mk") || (arg1 == ".mk")) {
                g_markerState[num] = markerType;
                g_markerPos[num]   = pPlayer.pev.origin;
            
            // マーカー削除
            } else if ((arg1 == "!mkc") || (arg1 == ".mkc")) {
                bool isAll = false;
                float dist = 80.0f;
                if (pArguments.ArgC() >= 2) {
                    string arg2 = pArguments.Arg(1);
                    isAll = true;
                    dist = (arg2 == "all") ? -1.0f : atof(arg2);
                }
                
                deleteMarker(pPlayer.pev.origin, dist, isAll);
            }
        }
        
    }
    return HOOK_CONTINUE;
}

// マーカー描画
void DrawMarker() {
    const int UPPOS = 10;
    const int DOWNPOS = -30;
    
    uint8 r = 192;
    uint8 g = 192;
    uint8 b = 192;
    uint8 alpha = 192;
    
    for (uint i = 0; i < MAX_MARKER_NUM; i++) {
    
        if (g_markerState[i] != MARKER_DISABLED) { 
            
            int sprite;
            int size;
            switch (g_markerState[i]) {
                case MARKER_TAKE:
                    sprite = g_spriteTake;
                    size   = 4;
                    break;
                case MARKER_USE:
                    sprite = g_spriteUse;
                    size   = 4;
                    break;
                case MARKER_OBJECTIVE:
                    sprite = g_spriteObjective;
                    size   = 3;
                    break;
                case MARKER_DEAD:
                    sprite = g_spriteDead;
                    size   = 7;
                    break;
                case MARKER_QUESTION:
                    sprite = g_spriteQuestion;
                    size   = 7;
                    break;
                case MARKER_FLAGRED:
                    sprite = g_spriteFlagRed;
                    size   = 10;
                    break;
                case MARKER_FLAGBLUE:
                    sprite = g_spriteFlagBlue;
                    size   = 10;
                    break;
                default:
                    sprite = g_spriteGohere;
                    size   = 4;
                    break;
            }
             
            // マーカースプライト
            NetworkMessage m(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null);
            m.WriteByte(TE_GLOWSPRITE);
            m.WriteCoord(g_markerPos[i].x);
            m.WriteCoord(g_markerPos[i].y);
            m.WriteCoord(g_markerPos[i].z + UPPOS);
            m.WriteShort(sprite);
            m.WriteByte(10);
            m.WriteByte(size);
            m.WriteByte(alpha);
            m.End();
             
            // 波動
            NetworkMessage messageWave(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null);
            messageWave.WriteByte(TE_BEAMCYLINDER);
            messageWave.WriteCoord(g_markerPos[i].x);
            messageWave.WriteCoord(g_markerPos[i].y);
            messageWave.WriteCoord(g_markerPos[i].z + DOWNPOS);
            messageWave.WriteCoord(g_markerPos[i].x);
            messageWave.WriteCoord(g_markerPos[i].y);
            messageWave.WriteCoord(g_markerPos[i].z + DOWNPOS + 60);
            messageWave.WriteShort(g_spriteWave);
            messageWave.WriteByte(0);
            messageWave.WriteByte(16);
            messageWave.WriteByte(8);
            messageWave.WriteByte(4);
            messageWave.WriteByte(0);
            messageWave.WriteByte(r);
            messageWave.WriteByte(g);
            messageWave.WriteByte(b);
            messageWave.WriteByte(100);
            messageWave.WriteByte(0);
            messageWave.End();
        
 /*             
            NetworkMessage messageDisk(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null);
            messageDisk.WriteByte(TE_BEAMDISK);
            messageDisk.WriteCoord(g_markerPos[i].x);
            messageDisk.WriteCoord(g_markerPos[i].y);
            messageDisk.WriteCoord(g_markerPos[i].z + DOWNPOS);
            messageDisk.WriteCoord(g_markerPos[i].x);
            messageDisk.WriteCoord(g_markerPos[i].y);
            messageDisk.WriteCoord(g_markerPos[i].z + DOWNPOS + 60);
            messageDisk.WriteShort(g_spriteWave);
            messageDisk.WriteByte(0);
            messageDisk.WriteByte(16);
            messageDisk.WriteByte(8);
            messageDisk.WriteByte(1);
            messageDisk.WriteByte(0);
            messageDisk.WriteByte(r);
            messageDisk.WriteByte(g);
            messageDisk.WriteByte(b);
            messageDisk.WriteByte(100);
            messageDisk.WriteByte(0);
            messageDisk.End();
 */            
        }
    }
}

// 使用可能マーカーIndex取得
uint getMarkerIndex() {
    for (uint i = 0; i < MAX_MARKER_NUM; i++) {
        if (g_markerState[i] == MARKER_DISABLED) { 
            return i;
        }
    }
    uint num = Math.RandomLong(0, MAX_MARKER_NUM - 1);
    return num;
}

// マーカー削除
void deleteMarker(Vector &in pos, float dist, bool &in isAll) {
    
    if (dist == 0) {
        dist = 80.0f;
    }
    
    for (uint i = 0; i < MAX_MARKER_NUM; i++) {
        if (g_markerState[i] != MARKER_DISABLED) { 
            // 有効状態で距離の近いマーカーがあればそれを無効化
            Vector diff = g_markerPos[i] - pos;
            if ((diff.Length() <= dist) || (dist == -1)) {
                g_markerState[i] = MARKER_DISABLED;
                
                // １つのみ処理するならreturn
                if (!isAll) {
                    return;
                }
            }
        }
    }
}


// コマンドリスト表示
void ShowMarkerList(const CCommand@ pArgs) {
    CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
        
    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "--- Marker parameter command ---\n"); 
    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "GoHere marker    => (Unspecified)" + "\n");
    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "Take marker      => t, take" + "\n");
    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "Use marker       => u, use" + "\n");
    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "Objective marker => o, obj" + "\n");
    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "Skull icon       => d, danger" + "\n");
    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "Question icon    => ?, q, question" + "\n");
    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "Flag (Red)       => fr, flagred" + "\n");
    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "Flag (Blue)      => fb, flagblue" + "\n");
    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "--------------------------------\n");
}