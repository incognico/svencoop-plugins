/////////////////////////////////////////////////////////////////////
// RandomNextMap v1.3.3b2
// 
//  This plugin decides next map randomly.
//
//  Notice: Remove mapname which is set "nextmap xxxx" in cfg from mapcyclelist.
//           ...or this plugin changes nextmap randomly everytime.
//
//   by takedeppo.50cal  (Im not eng speaker!! 英語わかんねえんだよ)
//   ("set_nextmap" command by JonnyBoy0719. merged with my coding style :D)
//
/////////////////////////////////////////////////////////////////////

const int pastMapListShortLength = 20; // IMPORTANT: Keep this in sync with the rtv.iExcludePrevMapsNomOnly CVar

// global 
CCVar@ g_pIgnoreEmpty = null;       // Ignore adding list when server is empty.
bool g_isPlayerConnected = false;   // Flag which is first player joined to server(each maps).
CCVar@ g_pExclude = null;           // Exclude past map count(Cvar)
array<string> g_pastList = {};      // Exclude past map list
CCVar@ g_pRandLogic = null;         // Random Logic type

// Const
const string PLUGIN_TAG = "[RandomNextMap] ";

// ClientCommand
CClientCommand cvar_set_nextmap( "set_nextmap", "Set the next map cycle", @SetNextMap );    // set nextmap
CClientCommand cvar_pastmaplist( "pastmaplist", "show played map list", @ShowPastMapList ); // show g_pastList to client console 
CClientCommand cvar_pastmaplist_full( "pastmaplistfull", "show played map list", @ShowPastMapList_full ); // show g_pastList to client console 

/** MersenneTwister class */
MersenneTwister g_Mt;

/** Plugin init */
void PluginInit() {
    // ....(^^;)b yay
    g_Module.ScriptInfo.SetAuthor("takedeppo.50cal");
    g_Module.ScriptInfo.SetContactInfo("http://steamcommunity.com/id/takedeppo");
    
    // Event hook
    g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @ClientPutInServer);
    g_Hooks.RegisterHook(Hooks::Game::MapChange, @MapChange);
    
    // Cvar
    @g_pExclude     = CCVar("exclude", 10, "Exclude past map number [num]", ConCommandFlag::AdminOnly);
    @g_pIgnoreEmpty = CCVar("ignoreempty", 0, "Ignore adding list when server is empty. [0=disabled, 1=enabled]", ConCommandFlag::AdminOnly);
    @g_pRandLogic   = CCVar("logictype", 1, "Random function logic type. [0=default, 1=MersenneTwister]", ConCommandFlag::AdminOnly);

    g_Mt = MersenneTwister();
	
	reloadPastMapListFromRtvPlugin();
}

/**  Map init */
void MapInit() {
    g_isPlayerConnected = false;
    
    string old = g_MapCycle.GetNextMap();
    if (execRandomNextMap()) {
        g_EngineFuncs.ServerPrint(PLUGIN_TAG + "Nextmap changed: " +  old + "->" + g_MapCycle.GetNextMap() + "\n");
    }
}

const string previousMapsFile = "scripts/plugins/store/previous_maps.txt"; // saved here by RTV plugin in case the server crashes
void MapActivate() {
	reloadPastMapListFromRtvPlugin();
}

/** Player Connected */
HookReturnCode ClientPutInServer(CBasePlayer@ pPlayer) {
    g_isPlayerConnected = true;
    return HOOK_CONTINUE;
}

/** Map change */
HookReturnCode MapChange() {
	/*
    // ignoreempty = 1 -> Except No player case.
    if (g_pIgnoreEmpty.GetInt() == 1) {
        if (g_isPlayerConnected) {
            updatePastList(g_Engine.mapname);
        }
    
    // ignoreempty = 0 -> Always add to list.
    } else {
        updatePastList(g_Engine.mapname);
    }
	*/
    return HOOK_CONTINUE;
}

/** Change nextmap randomly */
bool execRandomNextMap() {
    // Check mapcycle num. (first map with cfg overwrote, then return 0 too.)
    if (g_MapCycle.Count() <= 0) {
        return false;
    }    
    // Retrieve maplist
    array<string> mapList = g_MapCycle.GetMapCycle();
    
    // Nextmap is not in mapcycle, no change return.
    if (mapList.find(g_MapCycle.GetNextMap()) < 0) {
        return false;
    }
    
    // Remove past maps
    mapListExclude(mapList);
    if (mapList.length() == 0) {
        return false;
    }
    
    // Random choose
    uint target = (g_pRandLogic.GetInt() == 1) ? 
        g_Mt.mtRand(mapList.length() - 1) : Math.RandomLong(0, mapList.length() - 1);
    
    // Execute ServerCommand
    g_EngineFuncs.ServerCommand("mp_nextmap_cycle " + mapList[target] + "\n");
    g_EngineFuncs.ServerExecute();
    return true;
}

void execRandomChooseMap() {
     // Check mapcycle num. (first map with cfg overwrote, then return 0 too.)
    if (g_MapCycle.Count() <= 0) {
        return;
    }    
    // Retrieve maplist
    array<string> mapList = g_MapCycle.GetMapCycle();
    
    // Nextmap is exist in mapcycle, exit
    if (mapList.find(g_MapCycle.GetNextMap()) >= 0) {
        return;
    }
    
    // Remove past maps
    mapListExclude(mapList);
    if (mapList.length() == 0) {
        return;
    }
    
    // Random choose
    uint target = (g_pRandLogic.GetInt() == 1) ? 
        g_Mt.mtRand(mapList.length() - 1) : Math.RandomLong(0, mapList.length() - 1);
    
    // Execute ServerCommand
    //g_EngineFuncs.ChangeLevel(mapList[target]);
    g_EngineFuncs.ServerCommand("changelevel " + mapList[target] + "\n");
    g_EngineFuncs.ServerExecute();
}

/** Remove past maps from list */
void mapListExclude(array<string> &inout mapList) {
    // mapList - g_pastList
    int searchIndex;
    for (uint i = 0; (i < g_pastList.length()) && (mapList.length() > 0); i++) {
        searchIndex = mapList.find(g_pastList[i]);
        if (searchIndex >= 0) { 
            mapList.removeAt(searchIndex);
        }
    }
    
    // played all maps, reset g_pastList
    if (mapList.length() == 0) {
        g_pastList.resize(0);
        mapList = g_MapCycle.GetMapCycle();
    }
    
    // remove current map
    searchIndex = mapList.find(g_Engine.mapname);
    if (searchIndex >= 0) { 
        mapList.removeAt(searchIndex);
    }
}

/** Update past maps */
/*
void updatePastList(string &in mapName) {
	
    array<string> mapList = g_MapCycle.GetMapCycle();
    
    // if mapName is not included mapList, return
    if (mapList.find(mapName) < 0) {
        return;
    }
    // if mapName duplicated, return
    if (g_pastList.find(mapName) >= 0) {
        return;
    }
    
    // Remove old map if over exclude list.
    uint exclude = g_pExclude.GetInt();
    if (g_pastList.length() >= exclude) {
        g_pastList.removeAt(0);
    }
    // Add past map
    g_pastList.insertLast(mapName);
	
}
*/

void reloadPastMapListFromRtvPlugin() {
	g_pastList.resize(0);
	
	// load previous maps from file
	File@ file = g_FileSystem.OpenFile(previousMapsFile, OpenFile::READ);

	if(file !is null && file.IsOpen())
	{
		while(!file.EOFReached())
		{
			string sLine;
			file.ReadLine(sLine);
				
			sLine.Trim();
			if (sLine.Length() == 0) {
				continue;
			}
			g_pastList.insertLast(sLine);
		}

		file.Close();
	} else {
		g_Log.PrintF("[RanomNextMap] previous map list file not found: " + previousMapsFile + "\n");
	}
}

/**
 * Changes the next map
 *  (Referenced: JonnyBoy0719's code) 
 *   thx, but Im following my coding style ....(^^;)b yay
 */
void SetNextMap(const CCommand@ args) {
    CBasePlayer@ client = g_ConCommandSystem.GetCurrentPlayer();    
    if (g_PlayerFuncs.AdminLevel(client) < ADMIN_YES) {
        g_PlayerFuncs.ClientPrint(client, HUD_PRINTCONSOLE, PLUGIN_TAG + "You must be an admin to use this command!\n");
        return;
    }
    
    // Check map
    const string mapName = args[1].ToLowercase();
    if (mapName == "") {
        g_PlayerFuncs.ClientPrint(client, HUD_PRINTCONSOLE, PLUGIN_TAG + ".set_nextmap <mapname>\n");
        return;
    }
    if (!g_EngineFuncs.IsMapValid(mapName)) {
        g_PlayerFuncs.ClientPrint(client, HUD_PRINTCONSOLE, PLUGIN_TAG + mapName + " does not exist.\n");
        return;
    }
    
    // Grab the current nextmap
    string old = g_MapCycle.GetNextMap();
    if (old == mapName) {
        g_PlayerFuncs.ClientPrint(client, HUD_PRINTCONSOLE, PLUGIN_TAG + "You can't change to the same map. Please select another map.\n");
        return;
    }
    
    // Console message
    const string msg = PLUGIN_TAG + "Nextmap changed (by admin): " +  old + "->" + mapName + "\n";
    g_PlayerFuncs.ClientPrint(client, HUD_PRINTCONSOLE, msg);
    g_EngineFuncs.ServerPrint(msg);
    
    // Execute the changes
    g_EngineFuncs.ServerCommand("mp_nextmap_cycle " + mapName + "\n");
    g_EngineFuncs.ServerExecute();
}

/** Show g_pastList to player's console */
void ShowPastMapList(const CCommand@ args) {
    CBasePlayer@ client = g_ConCommandSystem.GetCurrentPlayer();
	
	int start = 0;
	if (g_pastList.length() > pastMapListShortLength) {
		start = g_pastList.length() - pastMapListShortLength;
	}
    
    g_PlayerFuncs.ClientPrint(client, HUD_PRINTCONSOLE, "--Past maplist---------------\n");
    for (uint i = start; i < g_pastList.length(); i++) {
       g_PlayerFuncs.ClientPrint(client, HUD_PRINTCONSOLE, " " + ((i-start) + 1) +  ": "  + g_pastList[i] + "\n");
    }
    g_PlayerFuncs.ClientPrint(client, HUD_PRINTCONSOLE, "-----------------------------\n");
}

/** Show g_pastList to player's console */
void ShowPastMapList_full(const CCommand@ args) {
    CBasePlayer@ client = g_ConCommandSystem.GetCurrentPlayer();
    
    g_PlayerFuncs.ClientPrint(client, HUD_PRINTCONSOLE, "--Past maplist---------------\n");
    for (uint i = 0; i < g_pastList.length(); i++) {
       g_PlayerFuncs.ClientPrint(client, HUD_PRINTCONSOLE, " " + (i + 1) +  ": "  + g_pastList[i] + "\n");
    }
    g_PlayerFuncs.ClientPrint(client, HUD_PRINTCONSOLE, "-----------------------------\n");
}


//=======================================================================================================
// RAMDOM LOGIC //////

////////////////////////////////////////////
// MersenneTwister
//
//  wrapped and converted to AngelScript 
//    by takedeppo.50cal ....(^^;)b
//
//  (if you want to know detail, read original source pls)
////////////////////////////////////////////

/* 
   A C-program for MT19937, with initialization improved 2002/1/26.
   Coded by Takuji Nishimura and Makoto Matsumoto.

   Before using, initialize the state by using init_genrand(seed)  
   or init_by_array(init_key, key_length).

   Copyright (C) 1997 - 2002, Makoto Matsumoto and Takuji Nishimura,
   All rights reserved.                          

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions
   are met:

     1. Redistributions of source code must retain the above copyright
        notice, this list of conditions and the following disclaimer.

     2. Redistributions in binary form must reproduce the above copyright
        notice, this list of conditions and the following disclaimer in the
        documentation and/or other materials provided with the distribution.

     3. The names of its contributors may not be used to endorse or promote 
        products derived from this software without specific prior written 
        permission.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
   A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
   CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
   EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
   PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
   PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
   NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


   Any feedback is very welcome.
   http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/emt.html
   email: m-mat @ math.sci.hiroshima-u.ac.jp (remove space)
*/

void print(string text) { g_Game.AlertMessage( at_console, text); }
void println(string text) { print(text + "\n"); }

class MersenneTwister {
    int N = 624;
    int M = 397;
    
    uint64 MATRIX_A   = 0x9908b0df;   /* constant vector a */
    uint64 UPPER_MASK = 0x80000000; /* most significant w-r bits */
    uint64 LOWER_MASK = 0x7fffffff; /* least significant r bits */
    
    uint64[] mt(N); /* the array for the state vector  */
    int mti = N + 1; /* mti==N+1 means mt[N] is not initialized */

    MersenneTwister() {
//        const DateTime dt = DateTime();
//        const time_t unixtime = dt.ToUnixTimestamp();
//        const uint64 randSeed = uint64(unixtime);
//        init_genrand(randSeed);
        
        const int INT_MAX = 2147483647;
        const uint64 randSeed = uint64(Math.RandomLong(0, INT_MAX));
        init_genrand(randSeed);
    }
    
    MersenneTwister(uint64 s) {
        init_genrand(s);
    }
    
    /* initializes mt[N] with a seed */
    void init_genrand(uint64 s) {
        mt[0]= s & 0xffffffff;
        for (mti = 1; mti < N; mti++) {
            mt[mti] = (1812433253 * (mt[mti-1] ^ (mt[mti-1] >> 30)) + mti); 
            /* See Knuth TAOCP Vol2. 3rd Ed. P.106 for multiplier. */
            /* In the previous versions, MSBs of the seed affect   */
            /* only MSBs of the array mt[].                        */
            /* 2002/01/09 modified by Makoto Matsumoto             */
            mt[mti] &= 0xffffffff;
            /* for >32 bit machines */
        }
    }
    
    /* generates a random number on [0,0xffffffff]-interval */
    uint64 genrand_int32() {
        uint64 y;
        uint64[] mag01 = {0x0, MATRIX_A};
        /* mag01[x] = x * MATRIX_A  for x=0,1 */

        if (mti >= N) { /* generate N words at one time */
            int kk;

            if (mti == N+1) {  /* if init_genrand() has not been called, */
				uint64 seed = DateTime().GetMilliseconds();
                init_genrand(seed);
            }

            for (kk = 0; kk < N - M; kk++) {
                y = (mt[kk] & UPPER_MASK) | (mt[kk + 1] & LOWER_MASK);
                mt[kk] = mt[kk + M] ^ (y >> 1) ^ mag01[y & 0x1];
            }
            for (; kk < N - 1; kk++) {
                y = (mt[kk]&UPPER_MASK)|(mt[kk+1]&LOWER_MASK);
                mt[kk] = mt[kk+(M-N)] ^ (y >> 1) ^ mag01[y & 0x1];
            }
            y = (mt[N-1] & UPPER_MASK) | (mt[0] & LOWER_MASK);
            mt[N - 1] = mt[M - 1] ^ (y >> 1) ^ mag01[y & 0x1];

            mti = 0;
        }
      
        y = mt[mti++];

        /* Tempering */
        y ^= (y >> 11);
        y ^= (y << 7) & 0x9d2c5680;
        y ^= (y << 15) & 0xefc60000;
        y ^= (y >> 18);

        return y;
    }

    /* generates a random number on [0,0x7fffffff]-interval */
    int64 genrand_int31() {
        return int64(genrand_int32()>>1);
    }

    /* generates a random number on [0,1]-real-interval */
    double genrand_real1() {
        return genrand_int32()*(1.0/4294967295.0); 
        /* divided by 2^32-1 */ 
    }

    /* generates a random number on [0,1)-real-interval */
    double genrand_real2() {
        return genrand_int32()*(1.0/4294967296.0); 
        /* divided by 2^32 */
    }

    /* generates a random number on (0,1)-real-interval */
    double genrand_real3() {
        return (double(genrand_int32()) + 0.5) * (1.0 / 4294967296.0); 
        /* divided by 2^32 */
    }

    /* generates a random number on [0,1) with 53-bit resolution*/
    double genrand_res53() { 
        uint64 a = genrand_int32()>>5;
        uint64 b = genrand_int32()>>6;
        return (a * 67108864.0 + b) * (1.0 / 9007199254740992.0); 
    } 
    /* These real versions are due to Isaku Wada, 2002/01/09 added */
    
    /** modulo function */
    int mtRand(int &in max) {
        
        // Cast to int FORCIBLY :D
        //  uint can not obtain correct value.
        //  ...maybe modulo(%) result depend on the types of the operand.
        int ret = genrand_int32() % max;
        ret = (ret > 0) ? ret : -ret;
        
        return ret;
    }
}

//=======================================================================================================
