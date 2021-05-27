/////////////////////////////////////////
// SoundSayプラグイン
//  参考：nico氏のchatsound
/////////////////////////////////////////

// カスタムキー
const string g_keySaidTime    = "$i_saidtime";    // 発言時間(Int)
const string g_keySaidCount   = "$i_saidcount";   // 発言回数(Int)
const string g_keyWarnedCount = "$i_warnedcount"; // 警告回数(Int)

// Const
const string TAGNAME = "[SoundSay] ";  // コンソール出力用タグ名
const uint SPAM_INTERVAL = 60000;      // スパム判定リセット時間
const uint SPAM_COUNT    = 20;         // スパム判定回数

const uint KICK_COUNT    = 30;         // チャットスパム対策
const uint ALLOW_WARNED   = 2;         // 警告回数

const uint BAN_TIME = 3;               // BAN時間。

// ClientCommand
CClientCommand g_soundlist("soundlist", "Show chat sound list", @ShowSoundList);

// サウンドIndexのディクショナリ定義。
//  ※サウンドデータのインデックス番号と照合
const dictionary g_soundDict = {
    {"hi",      0}, {"hello",      0}, {"konichiwa",   0}, {"konitiwa",   0},
    {"bye",     1}, {"otu",        1},
    {"thx",     2}, {"ty",         2}, {"thank",       2}, {"thanks",     2},
    {"sry",     3}, {"sorry",      3},
    {"clear",   4},
    {"gj",      5}, {"nice",       5},
    {"yes",     6},
    {"no",      7}, {"nope",       7},
    {"k",       8}, {"ok",         8}, {"okay",         8},
    {"waa",     9}, {"waaa",       9},
    {"hey",     10},
    {"heey",    11}, {"heeey",     11},
    {"go",      12}, {"gogo",      12}, {"gogogo",     12},
    {"noo",     13}, {"nooo",      13},
    {"ooo",     14}, {"oooo",      14},
    {"daa",     15}, {"daaa",      15},
    {"daah",    16}, {"daaah",     16},
    {"uwaa",    17}, {"uwaaa",     17},
    {"aaa" ,    18}, {"aaaa" ,     18},
    {"stop" ,   19},
    {"ugh" ,    20},
    {"help",    21},
    {"fire",    22},
    {"aghh",    23},
    {"candy",   24},
    {"yees",    25},
    {"shutup",  26},
    {"wan",     27}, {"wanwan",    27}, {"bowwow",     27},
    {"hahaha",  28},
    {"gg",      29},
    {"choose",  30},
    {"regret",  31},
    {"wise",    32},
    {"lol",     33}, {"rofl",      33}, {"w",         33},
    {"brain",   34},
    {"ahh",     35}, {"ahhh",      35},
    {"uuu",     36},
    {"idk",     37},
    {"tetris",  38},
    {"chubby",  39},
    {"move",    40},    
    {"ha",      41},
    {"medic",   42},
    {"tfc",     43},
    {"gusya",   44}, {"splat",     44},
    {"beki",    45}, {"fall",      45},
    {"guwa-",   46}, {"guwaa",     46},
    {"garg",    47}, {"gargantua", 47},
    {"tentacle",48},
    {"fuaa",    49}, {"yawn",    49}, {"nemui",    49}, {"akubi",    49},
    {"buta",    50}, {"booboo",  50}, {"pig",      50}, {"oink",     50},
    {"houndeye", 51}, {"quun",   51},
    {"now",      52},
    {"reveille", 53},
    {"maybe"   , 54},
    {"music"   , 55}, 
    {"fish"    , 56}, 
    {"mario?"  , 57}, {"smb?"    , 57}, 
    {"levelup" , 58}, {"lvup"  , 58},
    {"fanfare" , 59},
    {"barnacle", 60},
    {"valve",    61},
    {"thunder",  62},
    {"coin",     63},
    {"horror",   64}
};
const array<string> @g_soundIndexList = g_soundDict.getKeys();

// サウンドデータリスト
const array<string> g_soundDataList = {
    // 0-
    "fgrunt/hellosir.wav",
    "vox/goodbye.wav",
    "fgrunt/thanks.wav",
    "vox/sorry.wav",
    "fgrunt/clear.wav",
    
    "holo/tr_holo_nicejob.wav",
    "fgrunt/yes.wav",
    "fgrunt/no.wav",
    "scientist/alright.wav",
    "scientist/scream08.wav",
    // 11-
    "otis/hey.wav",
    "barney/hey.wav",
    "drill/livefire02.wav",
    "scientist/scream10.wav",
    "scientist/sci_fear2.wav",
    
    "scientist/sci_pain1.wav",
    "scientist/c1a0_sci_catscream.wav",
    "scientist/scream06.wav",
    "scientist/scream05.wav",
    "scientist/sci_pain3.wav",
    // 21-
    "scientist/sneeze.wav",
    "barney/ba_needhelp0.wav",
    "barney/openfire.wav",    
    "barney/aghh.wav",
    "otis/candy.wav",
    
    "scientist/yees.wav", 
    "scientist/shutup.wav",    
    "hungerhound/he_alert1.wav",
    "svencoop2/weirdlaugh1.wav",
    "tfc/ambience/goal_1.wav",
    // 31-
    "gman/gman_choose1.wav",    
    "gman/gman_noreg.wav",
    "gman/gman_wise.wav",
    "incoming/df.wav",
    "hunger/hungerzombiecop/zo_attack1.wav",
    
    "hunger/franklin/frank_die.wav",
    "scientist/sci_fear1.wav",
    "scientist/dontknow.wav",
    "sc_tetris/success.wav",
    "svencoop1/chubbyhelp2.wav",
    // 41-
    "drill/oc101.wav",
    "tfc/player/plyrjmp8.wav",
    "tfc/speech/saveme2.wav",
    "tfc/misc/endgame.wav",    
    "common/bodysplat.wav",
    
    "player/pl_fallpain3.wav",
    "player/knifed.wav",    
    "garg/gar_alert2.wav",
    "tentacle/te_sing1.wav",
    "scientist/yawn.wav",
    // 51-
    "sc_psyko/pig.wav",
    "houndeye/he_alert3.wav",
    "fvox/time_is_now.wav",
    "bootcamp/reveille.wav",
    "otis/maybe.wav",
    
    "incoming/f.ogg",
    "incoming/f2.ogg",
    "incoming/w.ogg",
    "incoming/w2.ogg",
    "descrcl/fanfare.wav",
    // 61-
    "barnacle/bcl_alert2.wav",
    "crystal/pwnage.wav",
    "crystal2/thunder.wav",
    "turretfortress/coin.wav",
    "ambience/the_horror1.wav"
};

/** プラグイン初期化 */
void PluginInit() {
    g_Module.ScriptInfo.SetAuthor("takedeppo.50cal");
    g_Module.ScriptInfo.SetContactInfo("http://steamcommunity.com/id/takedeppo");
    
    // イベントフック
    g_Hooks.RegisterHook(Hooks::Player::ClientSay, @ClientSay);
    g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @PlayerJoin );
}

/** マップ初期化 */
void MapInit() {
    precacheFiles();
}

/** プリキャッシュ */
void precacheFiles() {
    for (uint i = 0; i < g_soundDataList.length(); i++) {
        g_Game.PrecacheGeneric("sound/" + g_soundDataList[i]);
        g_SoundSystem.PrecacheSound(g_soundDataList[i]);
    }
}

/** プレイヤー参加時 */
HookReturnCode PlayerJoin(CBasePlayer@ pPlayer) {
    initPlayerValue(pPlayer);
    return HOOK_CONTINUE;
}

/** プレイヤー情報の初期化 */
void initPlayerValue(CBasePlayer@ &in pPlayer) {
    CustomKeyvalues@ pCustom = pPlayer.GetCustomKeyvalues();
    pCustom.SetKeyvalue(g_keySaidTime, 0);
    pCustom.SetKeyvalue(g_keySaidCount, 0);
    pCustom.SetKeyvalue(g_keyWarnedCount, 0);
}

/** チャット発言時 */
HookReturnCode ClientSay(SayParameters@ pParams) {
    // 引数
    const CCommand@ pArguments = pParams.GetArguments();
    if( pArguments.ArgC() > 0) {
        const string sayMsg = pArguments.Arg(0).ToLowercase();
        
        // ディクショナリに定義あり
        if (g_soundDict.exists(sayMsg)) {
            // index内なら、その音声を再生
            uint index = uint(g_soundDict[sayMsg]);
            if (index < g_soundDataList.length()) {
                
                CBasePlayer@ pPlayer = pParams.GetPlayer();
                CustomKeyvalues@ pCustom = pPlayer.GetCustomKeyvalues();
                
                // 前回発言時刻
                uint elapsedTime = pCustom.GetKeyvalue(g_keySaidTime).GetInteger();
                // 現在時刻（unixtime）
                uint currentTime = uint(g_EngineFuncs.Time() * 1000); 
                // 一定時間内の発言回数
                uint saidCount = pCustom.GetKeyvalue(g_keySaidCount).GetInteger();
                // 警告数
                uint warnedCount = pCustom.GetKeyvalue(g_keyWarnedCount).GetInteger();
                
                // Adminは除外
                if (g_PlayerFuncs.AdminLevel(pPlayer) >= ADMIN_YES) {
                    saidCount = 0;
                }
                
                // 前回発言から経過時間内
                if (currentTime < elapsedTime + SPAM_INTERVAL) {
                    // 発言数加算
                    pCustom.SetKeyvalue(g_keySaidCount, saidCount + 1);
                    
                    // 一定時間内で発言しすぎ
                    if (saidCount >= KICK_COUNT) {
                        autoKick(pPlayer);
                        return HOOK_HANDLED;
                        
                    // 警告されすぎ
                    } else if (warnedCount >= ALLOW_WARNED) {
                        autoKick(pPlayer);
                        return HOOK_HANDLED;
                        
                    // チャット多すぎ
                    } else if (saidCount >= SPAM_COUNT) {
                        g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, " ※スパムはやめよう。さもないと蹴るよ。(STOP SPAMMING!! or, you'll be kicked.)");
                        // ログ出力処理
                        if (saidCount == SPAM_COUNT) {
                            pCustom.SetKeyvalue(g_keyWarnedCount, warnedCount + 1);
                            
                            string logMsg = TAGNAME + " " + getHHMMSS() + " " +  pPlayer.pev.netname + " warned for spamming." + "\n";
                            g_EngineFuncs.ServerPrint(logMsg);
                            g_Log.PrintF(logMsg);
                        }
                    }
                    
                } else {
                    pCustom.SetKeyvalue(g_keySaidCount, 1);
                }
                
                // 発言時刻を保存
                pCustom.SetKeyvalue(g_keySaidTime, currentTime);
                
                // サウンド再生
                string saySound = g_soundDataList[index];
                
                
                if ((pArguments.ArgC() >= 2) && (pArguments.Arg(1) == "*")) {
                    
                    for (int i = 1; i <= g_Engine.maxClients; ++i) {
                        CBasePlayer@ pTarget = g_PlayerFuncs.FindPlayerByIndex(i);
                        if (pTarget !is null && pTarget.IsConnected()) {
                            g_SoundSystem.PlaySound(pTarget.edict(), CHAN_AUTO, saySound, 1.0f, ATTN_NORM, 0, 100);
                        }
                    }
                    
                } else {
                    g_SoundSystem.PlaySound(pPlayer.edict(), CHAN_AUTO, saySound, 1.0f, ATTN_NONE, 0, 100);
                }
                
                
                return HOOK_HANDLED;
            }
        }
    }
    return HOOK_CONTINUE;
}

// キック処理
void autoKick(CBasePlayer@ pPlayer) {
    initPlayerValue(pPlayer);                
    g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "" + pPlayer.pev.netname + "はキックされましたとさ。(Spammer was kicked.)\n" ); 
    
    string logMsg = TAGNAME + " " + getHHMMSS() + " " +  pPlayer.pev.netname + " kicked." + "\n";
    g_EngineFuncs.ServerPrint(logMsg);
    g_Log.PrintF(logMsg);
    
    // 3分BAN
    g_EngineFuncs.ServerCommand("banid " + BAN_TIME + " \"#" + g_EngineFuncs.GetPlayerUserId(pPlayer.edict()) + "\" \"Reason: Spamming.\" kick\n");
    g_EngineFuncs.ServerExecute();
}

// リスト表示
void ShowSoundList(const CCommand@ pArgs) {
    CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
    
    string word = pArgs[1];
    
    g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCONSOLE, "--- Sound List -----------------\n");    
    for (uint i = 0; i < g_soundIndexList.length(); i++) {
        if (word == "") {
            g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, g_soundIndexList[i] + "\n");
        } else {
            if (g_soundIndexList[i].StartsWith(word)) {
                g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, g_soundIndexList[i] + "\n");
            }
        }
    }
    g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCONSOLE, "--------------------------------\n");
}

// 時間取得
string getHHMMSS() {
    DateTime dt = DateTime();
    string time = zeroFill(dt.GetHour()) + ":" + zeroFill(dt.GetMinutes()) + ":" + zeroFill(dt.GetSeconds());
    return time;
}

// 時間0埋め
string zeroFill(int &in value) {
    if (value < 10) {
        return "0" + value;
    } else {
        return value;
    }
}