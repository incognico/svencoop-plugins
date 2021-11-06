#include "brap"

// config
const string g_SoundFile      = "scripts/plugins/cfg/ChatSounds.txt";
const string soundStatsFile   = "scripts/plugins/store/cs_stats.txt"; // .csstats
const uint g_BaseDelay        = 6666;
const array<string> g_sprites = {'sprites/flower.spr', 'sprites/nyanpasu2.spr'};
/////////

uint g_Delay = g_BaseDelay;
bool precached = false;
dictionary g_SoundList;
dictionary g_Pitch;
dictionary g_Mutes;
array<uint> g_ChatTimes(33);
array<string> @g_SoundListKeys;
size_t filesize;

CClientCommand g_ListSounds("listsounds", "List all chat sounds", @listsounds);
CClientCommand g_CSPitch("cspitch", "Sets the pitch at which your ChatSounds play (25-255)", @cspitch);
CClientCommand g_CSStats("csstats", "Sound usage stats", @cs_stats);
CClientCommand g_CSMute("csmute", "Mute sounds from player", @csmute);
CClientCommand g_writecsstats("writecsstats", "Write sound usage stats", @writecsstats_cmd, ConCommandFlag::AdminOnly);

void PluginInit() {
    g_Module.ScriptInfo.SetAuthor("incognico + w00tguy");
    g_Module.ScriptInfo.SetContactInfo("https://discord.gg/qfZxWAd");

    g_Hooks.RegisterHook(Hooks::Player::ClientSay, @ClientSay);
    g_Hooks.RegisterHook(Hooks::Player::ClientDisconnect, @ClientDisconnect);
    g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @ClientPutInServer);
    g_Hooks.RegisterHook( Hooks::Game::MapChange, @MapChange );

    ReadSounds();
    loadUsageStats();
	
	g_Scheduler.SetInterval("brap_think", 0.05f, -1);
}

void PluginExit() {
    writeUsageStats();
	brap_unload();
}

void MapInit() {
    if (SoundsChanged())
        ReadSounds();

    g_ChatTimes.resize(33);
    g_any_stats_changed = false;
    g_Delay = g_BaseDelay;

    for (uint i = 0; i < g_SoundListKeys.length(); ++i) {
        g_Game.PrecacheGeneric("sound/" + string(g_SoundList[g_SoundListKeys[i]]));
        g_SoundSystem.PrecacheSound(string(g_SoundList[g_SoundListKeys[i]]));
    }

    for (uint i = 0; i < g_sprites.length(); ++i) {
        g_Game.PrecacheGeneric(g_sprites[i]);
        g_Game.PrecacheModel(g_sprites[i]);
    }

    precached = true;
	
	brap_precache();
}

HookReturnCode MapChange() {
    writeUsageStats();
    return HOOK_CONTINUE;
}

void ReadSounds() {
    g_SoundList.deleteAll();

    File@ file = g_FileSystem.OpenFile(g_SoundFile, OpenFile::READ);
    filesize = file.GetSize();
    if (file !is null && file.IsOpen()) {
        while(!file.EOFReached()) {
            string sLine;
            file.ReadLine(sLine);

            sLine.Trim();
            if (sLine.IsEmpty())
                continue;

            const array<string> parsed = sLine.Split(" ");
            if (parsed.length() < 2)
                continue;

            g_SoundList[parsed[0]] = parsed[1];
        }
        file.Close();
        @g_SoundListKeys = g_SoundList.getKeys();
        g_SoundListKeys.sortAsc();
    }
}

const bool SoundsChanged() {
    File@ file = g_FileSystem.OpenFile(g_SoundFile, OpenFile::READ);
    const bool changed = (file.GetSize() != filesize) ? true : false;
    file.Close();
    return changed;
}

void listsounds(const CCommand@ pArgs) {
    CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();

    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "AVAILABLE SOUND TRIGGERS\n");
    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "------------------------\n");

    string sMessage = "";

    for (uint i = 1; i < g_SoundListKeys.length()+1; ++i) {
        sMessage += g_SoundListKeys[i-1] + " | ";

        if (i % 5 == 0) {
            sMessage.Resize(sMessage.Length() -2);
            g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, sMessage);
            g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "\n");
            sMessage = "";
        }
    }

    if (sMessage.Length() > 2) {
        sMessage.Resize(sMessage.Length() -2);
        g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, sMessage + "\n");
    }

    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "\n");
}

void cspitch(const CCommand@ pArgs) {
    CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
    const string steamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());

    if (pArgs.ArgC() < 2)
        return;

    setpitch(steamId, pArgs[1], pPlayer);
}

void csmute(const CCommand@ pArgs) {
    CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
    const string steamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());

    setmute(steamId, pArgs[1], pPlayer);
}

bool isNumeric(string arg) {
    if (arg.Length() == 0) {
        return false;
    }

    if (!isdigit(arg[0]) and arg[0] != "-") {
        return false;
    }

    for (uint i = 1; i < arg.Length(); i++) {
        if (!isdigit(arg[i])) {
            return false;
        }
    }
    
    return true;
}

void print(string text) { g_Game.AlertMessage( at_console, text); }
void println(string text) { print(text + "\n"); }

void player_say(CBaseEntity@ plr, string msg) {
    NetworkMessage m(MSG_ALL, NetworkMessages::NetworkMessageType(74), null);
        m.WriteByte(plr.entindex());
        m.WriteByte(2); // tell the client to color the player name according to team
        m.WriteString("" + plr.pev.netname + ": " + msg + "\n");
    m.End();

    // fake the server log line and print
    g_Game.AlertMessage(at_logged, "\"%1<%2><%3><player>\" say \"%4\"\n", plr.pev.netname, string(g_EngineFuncs.GetPlayerUserId(plr.edict())), g_EngineFuncs.GetPlayerAuthId(plr.edict()), msg);
    g_EngineFuncs.ServerPrint("" + plr.pev.netname + ": " + msg + "\n");
}

/* void player_say_delayed(EHandle h_plr, string msg) {
    CBasePlayer@ plr = cast<CBasePlayer@>(h_plr.GetEntity());
    if (plr !is null and plr.IsConnected()) {
        player_say(plr, msg);
    }
} */

void play_chat_sound(CBasePlayer@ speaker, SOUND_CHANNEL channel, string snd, float volume, float attenuation, int pitch) {
	string speakerId = g_EngineFuncs.GetPlayerAuthId(speaker.edict());
	speakerId = speakerId.ToLowercase();
	
	for (int i = 1; i <= g_Engine.maxClients; i++) {
		CBasePlayer@ plr = g_PlayerFuncs.FindPlayerByIndex(i);
		
		if (plr is null or !plr.IsConnected()) {
			continue;
		}
		
		string steamid = g_EngineFuncs.GetPlayerAuthId(plr.edict());
		if (g_Mutes.exists(steamid)) {
			array<string> muteList = cast<array<string>>(g_Mutes[steamid]);
			
			if (muteList.find(speakerId) != -1) {
				continue; // player muted the speaker
			}
		}
		
		g_SoundSystem.PlaySound(speaker.edict(), channel, snd, volume, attenuation, 0, pitch, plr.entindex());
	}
}

HookReturnCode ClientSay(SayParameters@ pParams) {
    const CCommand@ pArguments = pParams.GetArguments();

    if (pArguments.ArgC() > 0) {
        const string soundArgUpper = pArguments.Arg(0);
        const string soundArg = pArguments.Arg(0).ToLowercase();
        const string pitchArg = pArguments.ArgC() > 1 ? pArguments.Arg(1) : "";

        if (g_SoundList.exists(soundArg)) {
            CBasePlayer@ pPlayer = pParams.GetPlayer();
            const string steamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
            const int idx = pPlayer.entindex();

            int pitch = g_Pitch.exists(steamId) ? int(g_Pitch[steamId]) : 100;
            const bool pitchOverride = isNumeric(pitchArg) && pArguments.ArgC() == 2;
            if (pitchOverride) {
                pitch = clampPitch(atoi(pitchArg));
            }

            const uint t = uint(g_EngineFuncs.Time()*1000);
            const uint d = t - g_ChatTimes[idx];

            if (d < g_Delay) {
                const float w = float(g_Delay - d) / 1000.0f;
                g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCENTER, "Wait " + format_float(w) + " seconds\n");

                if (pitchOverride || pArguments.ArgC() == 1) {
                    pParams.ShouldHide = true;
                }
            }
            else {
                logSoundStat(pPlayer, soundArg);

                if (soundArg == 'medic' || soundArg == 'meedic') {
                    pPlayer.ShowOverheadSprite('sprites/saveme.spr', 51.0f, 3.5f);
					play_chat_sound(pPlayer, CHAN_STATIC, string(g_SoundList[soundArg]), 1.0f, 0.2f, Math.RandomLong(35, 220));
				}
                else {
                    if (precached) {
                        pPlayer.ShowOverheadSprite( g_sprites[Math.RandomLong(0, g_sprites.length()-1)], 56.0f, 2.5f);
                    }
                    const float volume      = 1.0f; // increased volume from .75 since converting stereo sounds to mono made them quiet
                    const float attenuation = 0.4f; // less = bigger sound range
                    play_chat_sound(pPlayer, CHAN_VOICE, string(g_SoundList[soundArg]), volume, attenuation, pitch);
                }
				
				if (soundArg == 'toot' || soundArg == 'tooot' || soundArg == 'brap' || soundArg == 'tootrape' || soundArg == 'braprape') {
					do_brap(pPlayer, soundArg, pitch);
				}
				if (soundArg == 'sniff' || soundArg == 'snifff' || soundArg == 'sniffrape') {
					do_sniff(pPlayer, soundArg, pitch);
				}

                g_ChatTimes[idx] = t;

                const bool allowrelay = ( (!pitchOverride && pArguments.ArgC() >= 2) || (soundArg == 'yes!' || soundArg == 'no!') && pArguments.ArgC() == 1 ); // can't take care of pitch override for yes!/no! here
                if (allowrelay) {
                    return HOOK_CONTINUE;
                }
                else if (pitchOverride) {
                    player_say(pPlayer, soundArgUpper); // hide the pitch modifier
                }
                else {
                    player_say(pPlayer, pParams.GetCommand());
                }

                pParams.ShouldHide = true;
            }
        }
        else if (pArguments.ArgC() > 1 && soundArg == '.cspitch') {
            CBasePlayer@ pPlayer = pParams.GetPlayer();
            const string steamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
            pParams.ShouldHide = true;
            setpitch(steamId, pArguments[1], pPlayer);
        }
		else if (pArguments.ArgC() > 0 && soundArg == '.csmute') {
            CBasePlayer@ pPlayer = pParams.GetPlayer();
            const string steamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
            pParams.ShouldHide = true;
            setmute(steamId, pArguments[1], pPlayer);
        }
        else if (pArguments.ArgC() > 0 && soundArg == '.csstats') {
            CBasePlayer@ pPlayer = pParams.GetPlayer();
            g_PlayerFuncs.SayText(pPlayer, "[ChatSounds] Usage stats sent to your console.\n");
            pParams.ShouldHide = true;
            showSoundStats(pPlayer, pArguments.Arg(1));
        }
    }

    return HOOK_CONTINUE;
}

HookReturnCode ClientPutInServer(CBasePlayer@ pPlayer) {
    g_Delay = g_Delay + 333;
    return HOOK_CONTINUE;
}

HookReturnCode ClientDisconnect(CBasePlayer@ pPlayer) {
    g_Delay = g_Delay - 333;
    return HOOK_CONTINUE;
}

void setpitch(const string steamId, const string val, CBasePlayer@ pPlayer) {
    g_Pitch[steamId] = clampPitch(atoi(val));
    g_PlayerFuncs.SayText(pPlayer, "[ChatSounds] Pitch set to: " + int(g_Pitch[steamId]) + ".\n");
}

// find a player by name or partial name
CBasePlayer@ getPlayerByName(CBasePlayer@ caller, string name)
{
	name = name.ToLowercase();
	int partialMatches = 0;
	CBasePlayer@ partialMatch;
	CBaseEntity@ ent = null;
	do {
		@ent = g_EntityFuncs.FindEntityByClassname(ent, "player");
		if (ent !is null) {
			CBasePlayer@ plr = cast<CBasePlayer@>(ent);
			string plrName = string(plr.pev.netname).ToLowercase();
			if (plrName == name)
				return plr;
			else if (plrName.Find(name) != uint(-1))
			{
				@partialMatch = plr;
				partialMatches++;
			}
		}
	} while (ent !is null);
	
	if (partialMatches == 1) {
		return partialMatch;
	} else if (partialMatches > 1) {
		g_PlayerFuncs.SayText(caller, '[ChatSounds] Mute failed. There are ' + partialMatches + ' players that have "' + name + '" in their name. Be more specific.\n');
	} else {
		g_PlayerFuncs.SayText(caller, '[ChatSounds] Mute failed. There is no player named "' + name + '".\n');
	}
	
	return null;
}

void setmute(const string steamId, const string val, CBasePlayer@ pPlayer) {
	string targetid = val;
	targetid = targetid.ToLowercase();
	string nicename = "???";
	
	array<string> muteList;
	if (g_Mutes.exists(steamId)) {
		muteList = cast<array<string>>(g_Mutes[steamId]);
	}
	
	if (val.Length() == 0) {
		if (muteList.size() > 0) {
			muteList.resize(0);
			g_PlayerFuncs.SayText(pPlayer, "[ChatSounds] Unmuted everyone.\n");
			g_Mutes[steamId] = muteList;
			return;
		} else {
			g_PlayerFuncs.SayText(pPlayer, "[ChatSounds] No one is muted.\n");
			return;
		}
	}
	
	if (targetid.Find("steam_0:") == 0) {
		g_Mutes[steamId] = val;
		nicename = targetid;
		nicename.ToUppercase();
	} else {
		CBasePlayer@ target = getPlayerByName(pPlayer, val);
		
		if (target is null) {
			return;
		}
		
		targetid = g_EngineFuncs.GetPlayerAuthId(target.edict());
		targetid = targetid.ToLowercase();
		nicename = target.pev.netname;
	}
	
	if (muteList.find(targetid) != -1) {
		muteList.removeAt(muteList.find(targetid));
		g_PlayerFuncs.SayText(pPlayer, "[ChatSounds] Unmuted player: " + nicename + "\n");
	} else {
		if (muteList.size() >= 50) {
			g_PlayerFuncs.SayText(pPlayer, "[ChatSounds] Can't mute more than 50 players!\n");
			return;
		}
		
		g_PlayerFuncs.SayText(pPlayer, "[ChatSounds] Muted player: " + nicename + "\n");
		muteList.insertLast(targetid);
	}
	
	g_Mutes[steamId] = muteList;
}

const int clampPitch(const int val) {
    return Math.clamp(25, 255, val);
}

const string format_float(const float f) {
    const uint decimal = uint(((f - int(f)) * 10)) % 10;
    return "" + int(f) + "." + decimal;
}

//
// .csstats
//

class UserStat {
    string steamid;
    string name;
    int soundCount = 0;
}

class SoundStat {
    string chatTrigger;
    array<UserStat> users;
    int totalUses; // temp for sorting
    bool isValid = false; // does this sound exist?
}

array<SoundStat> g_stats;
dictionary unique_users;

void update_stat_user_name(string steamid, string newname) {
	for (uint i = 0; i < g_stats.size(); i++) {
		for (uint k = 0; k < g_stats[i].users.size(); k++) {
			if (steamid == g_stats[i].users[k].steamid) {
				g_stats[i].users[k].name = newname;
			}
		}
	}
}

void logSoundStat(CBasePlayer@ plr, const string chatTrigger) {
    if (chatTrigger.Length() == 0) {
        return;
    }
    
    const bool debugit = chatTrigger == "ots";
    
    g_any_stats_changed = true;

    string steamid = g_EngineFuncs.GetPlayerAuthId( plr.edict() );
    steamid = steamid.SubString(8); // strip STEAM_0:
    unique_users[steamid] = true;
    
    for (uint i = 0; i < g_stats.size(); i++) {
        if (chatTrigger == g_stats[i].chatTrigger.ToLowercase()) {
            for (uint k = 0; k < g_stats[i].users.size(); k++) {
                if (debugit) println("COMPARE " + steamid + " " + g_stats[i].users[k].steamid);
                
                if (steamid == g_stats[i].users[k].steamid) {
                    g_stats[i].users[k].soundCount++;
					if (g_stats[i].users[k].name != plr.pev.netname) {
						update_stat_user_name(steamid, plr.pev.netname);
					}
                    g_stats[i].totalUses++;
                    if (debugit) println("increase sound count for " + steamid);
                    return;
                }
            }
            
            if (debugit) println("add new user stat " + steamid);
            UserStat newStat;
            newStat.steamid = steamid;
            newStat.name = plr.pev.netname;
            newStat.soundCount = 1;
            g_stats[i].totalUses++;
            g_stats[i].users.insertLast(newStat);
            return;
        }
    }
    
    if (debugit) println("add new sound stat " + chatTrigger);
    UserStat newStat;
    newStat.steamid = steamid;
    newStat.name = plr.pev.netname;
    newStat.soundCount = 1;
    
    SoundStat newVstat;
    newVstat.chatTrigger = chatTrigger;
    newVstat.totalUses = 1;
    newVstat.users.insertLast(newStat);
    
    g_stats.insertLast(newVstat);
}

// only write stats if anything changes (sometimes maps are restarted before anyone can use a sound)
bool g_any_stats_changed = false;

void writeUsageStats() {
    if (!g_any_stats_changed) {
        return;
    }
    DateTime start = DateTime();
    
    File@ f = g_FileSystem.OpenFile( soundStatsFile, OpenFile::WRITE);
    
    if( f.IsOpen() )
    {       
        int numWritten = 0;
        for (uint i = 0; i < g_stats.size(); i++) {         
            f.Write("[" + g_stats[i].chatTrigger + "]\n");
            for (uint k = 0; k < g_stats[i].users.size(); k++) {
                f.Write(g_stats[i].users[k].steamid + "\\" + g_stats[i].users[k].name + "\\" + g_stats[i].users[k].soundCount + "\n");
                numWritten++;
            }
        }
        f.Close();
        
        println("Wrote " + numWritten + " usage stats");
    }
    else
        println("Failed to open chat sound stats file: " + soundStatsFile + "\n");
        
    const float diff = TimeDifference(DateTime(), start).GetTimeDifference();
    println("Wrote chatsound stats in " + diff + " seconds");
}

void loadUsageStats() {
    g_stats.resize(0);

    DateTime start = DateTime();

    string tempSoundName = "";
    array<UserStat> tempUserStats;

    File@ file = g_FileSystem.OpenFile(soundStatsFile, OpenFile::READ);

    if(file !is null && file.IsOpen())
    {
        int numRead = 0;
        int soundCountTotal = 0;
        
        while(!file.EOFReached())
        {
            string sLine;
            file.ReadLine(sLine);
                
            sLine.Trim();
            if (sLine.Length() == 0)
                continue;
            
            if (sLine[0] == '[') {
                if (tempSoundName.Length() > 0) {
                    SoundStat vstat;
                    vstat.chatTrigger = tempSoundName;
                    vstat.users = tempUserStats;
                    vstat.totalUses = soundCountTotal;
                    tempUserStats = array<UserStat>();
                    g_stats.insertLast(vstat);
                    soundCountTotal = 0;
                }
            
                tempSoundName = sLine.Replace("[", "").Replace("]", "");
                continue;
            }
            
            UserStat stat;
            stat.steamid = sLine.Tokenize("\\");
            stat.name = sLine.Tokenize("\\");
            stat.soundCount = atoi(sLine.Tokenize("\\"));
            soundCountTotal += stat.soundCount;
            numRead++;
            unique_users[stat.steamid] = true;
            
            tempUserStats.insertLast(stat);
        }

        if (tempSoundName.Length() > 0) {
            SoundStat vstat;
            vstat.chatTrigger = tempSoundName.ToLowercase();
            vstat.users = tempUserStats;
            vstat.totalUses = soundCountTotal;
            tempUserStats = array<UserStat>();
            g_stats.insertLast(vstat);
            soundCountTotal = 0;
        }
        
        println("Loaded " + numRead + " chat sound stats");

        file.Close();
    } else {
        println("chat sound stats file not found: " + soundStatsFile + "\n");
    }
    
    for (uint i = 0; i < g_SoundListKeys.size(); i++) {
        bool hasStat = false;
        
        const string lowerSound = g_SoundListKeys[i].ToLowercase();
        
        for (uint k = 0; k < g_stats.size(); k++) {
            if (g_stats[k].chatTrigger.ToLowercase() == lowerSound) {
                hasStat = true;
                g_stats[k].isValid = true;
                break;
            }
        }
        
        if (!hasStat) {
            SoundStat vstat;
            vstat.chatTrigger = lowerSound;
            vstat.isValid = true;
            g_stats.insertLast(vstat);
        }
    }
    
    const float diff = TimeDifference(DateTime(), start).GetTimeDifference();
    println("Finished load in " + diff + " seconds");
}

void showSoundStats(CBasePlayer@ plr, string chatTrigger) {
    if (chatTrigger.Length() > 0) {
        showSoundStats_singleSound(plr, chatTrigger);
        return;
    }
    chatTrigger = chatTrigger.ToLowercase();
    
    g_stats.sort(function(a,b) { return a.totalUses > b.totalUses; });
    
    g_PlayerFuncs.ClientPrint(plr, HUD_PRINTCONSOLE, "\nUsage stats for " + g_SoundListKeys.size() + " chat sounds\n");
    g_PlayerFuncs.ClientPrint(plr, HUD_PRINTCONSOLE, "\n      Sound               Uses     Users");
    g_PlayerFuncs.ClientPrint(plr, HUD_PRINTCONSOLE, "\n-------------------------------------------\n");

    int position = 1;
    int allSoundUses = 0;
    for (uint i = 0; i < g_stats.size(); i++) {
        if (!g_stats[i].isValid) {
            continue; // chat sound not loaded
        }
    
        string line = " " + position + ") " + g_stats[i].chatTrigger;
        
        if (position < 100) {
            line = " " + line;
        }
        if (position < 10) {
            line = " " + line;
        }
        position++;
        
        int padding = 20 - g_stats[i].chatTrigger.Length();
        for (int k = 0; k < padding; k++)
            line += " ";
        
        string count = g_stats[i].totalUses;
        padding = 9 - count.Length();
        for (int k = 0; k < padding; k++)
            count += " ";
        line += count;
        
        string users = g_stats[i].users.size();
        padding = 8 - users.Length();
        for (int k = 0; k < padding; k++)
            users += " ";
        line += users;
        
        line += "\n";
        g_PlayerFuncs.ClientPrint(plr, HUD_PRINTCONSOLE, line);
        
        allSoundUses += g_stats[i].totalUses;
    }

    string totals = allSoundUses;
    int padding = 9 - totals.Length();
    for (int k = 0; k < padding; k++)
        totals += " ";
    totals += unique_users.size();

    g_PlayerFuncs.ClientPrint(plr, HUD_PRINTCONSOLE, "-------------------------------------------\n");
    g_PlayerFuncs.ClientPrint(plr, HUD_PRINTCONSOLE, "                  Total:  " + totals + "\n");
    g_PlayerFuncs.ClientPrint(plr, HUD_PRINTCONSOLE, "\nUses   = Number of times a chat sound has been used.");
    g_PlayerFuncs.ClientPrint(plr, HUD_PRINTCONSOLE, "\nUsers  = Number of unique players that have used the sound.\n\n");
}

void printUserStat(CBasePlayer@ plr, int k, UserStat@ stat, bool isYou) {
    int position = k+1;
    string line = "" + position + ") ";
    
    if (position < 100) {
        line = " " + line;
    }
    if (position < 10) {
        line = " " + line;
    }
    
    line = (isYou ? "*" : " ") + line;
            
    string name = stat.name;
    int padding = 32 - name.Length();
    for (int p = 0; p < padding; p++) {
        name += " ";
    }
    line += name;
    
    string count = stat.soundCount;
    padding = 7 - count.Length();
    for (int p = 0; p < padding; p++) {
        count += " ";
    }
    line += count;
    
    line += "STEAM_0:" + stat.steamid;
    
    g_PlayerFuncs.ClientPrint(plr, HUD_PRINTCONSOLE, line + "\n");
}

void showSoundStats_singleSound(CBasePlayer@ plr, string chatTrigger) {
    chatTrigger = chatTrigger.ToLowercase();
    const int limit = 20;
    string steamid = g_EngineFuncs.GetPlayerAuthId( plr.edict() );
    steamid = steamid.SubString(8);
    
    SoundStat@ stat = null;
    for (uint i = 0; i < g_stats.size(); i++) {
        if (!g_stats[i].isValid) {
            continue; // chat sound not loaded
        }
        if (g_stats[i].chatTrigger.ToLowercase() == chatTrigger) {
            @stat = @g_stats[i];
            break;
        }
    }
    
    if (stat is null or stat.users.size() == 0) {
        g_PlayerFuncs.ClientPrint(plr, HUD_PRINTCONSOLE, "No stats found for " + chatTrigger);
        return;
    }
    
    g_PlayerFuncs.ClientPrint(plr, HUD_PRINTCONSOLE, "\nTop " + limit + " users of \"" + stat.chatTrigger + "\"\n");
    g_PlayerFuncs.ClientPrint(plr, HUD_PRINTCONSOLE, "\n      Name                            Uses   Steam ID");
    g_PlayerFuncs.ClientPrint(plr, HUD_PRINTCONSOLE, "\n-----------------------------------------------------------------\n");
    
    if (stat.users.size() > 0) {
        stat.users.sort(function(a,b) { return a.soundCount > b.soundCount; });
    }

    int yourPosition = -1;
    UserStat@ yourStat = null;
    for (uint k = 0; k < stat.users.size(); k++) {
    
        bool isYou = stat.users[k].steamid == steamid;
        if (isYou) {
            yourPosition = k;
            @yourStat = @stat.users[k];
        }
        
        if (k < limit) {
            printUserStat(plr, k, stat.users[k], isYou);
        }
    }
    
    if (yourPosition > limit) {
        g_PlayerFuncs.ClientPrint(plr, HUD_PRINTCONSOLE, "  ...\n");
        printUserStat(plr, yourPosition, yourStat, true);
    }
    
    g_PlayerFuncs.ClientPrint(plr, HUD_PRINTCONSOLE, "-----------------------------------------------------------------\n\n");
    g_PlayerFuncs.ClientPrint(plr, HUD_PRINTCONSOLE, "Total users: " + stat.users.size() + "\n");
    g_PlayerFuncs.ClientPrint(plr, HUD_PRINTCONSOLE, "Total uses:  " + stat.totalUses + "\n\n");
}

void cs_stats(const CCommand@ pArgs) {
    CBasePlayer@ plr = g_ConCommandSystem.GetCurrentPlayer();
    showSoundStats(plr, pArgs.Arg(1));
}

void writecsstats_cmd(const CCommand@ pArgs) {
    CBasePlayer@ plr = g_ConCommandSystem.GetCurrentPlayer();
    writeUsageStats();
    g_PlayerFuncs.SayText(plr, "[ChatSounds] Wrote usage stats to " + soundStatsFile + "\n");
}
