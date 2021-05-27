//constants
const uint RTV_LIMIT = 3;
const float percentage = 0.65;

//variables
int counter;
int required;
bool voteStarted;
array<string> g_RockTheVote;
array<string> g_nomination;
array<string> g_voting;
array<string> rtvList;
array<string> mapList;
array<string> twoMaps;
array<uint> voting;
string chosenMap;

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor("Straitlaced");
	g_Module.ScriptInfo.SetContactInfo("Straitlaced @ Sven Co-op Forums");
	g_Hooks.RegisterHook(Hooks::Player::ClientSay, @ClientSay);
	g_Hooks.RegisterHook(Hooks::Player::ClientConnected, @ClientConnected);
	g_Hooks.RegisterHook(Hooks::Player::ClientDisconnect, @ClientDisconnect);
	g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @ClientPutInServer);
}

void MapInit()
{
	//reset variables
	chosenMap = "";
	voteStarted = false;
	counter = 0;
	required = -1; //not set until a player connects
	g_RockTheVote.resize(0);
	g_nomination.resize(0);
	g_voting.resize(0);
	rtvList.resize(0);
	twoMaps.resize(0);
	mapList.resize(0);
        ReadMaps();
	voting.resize(RTV_LIMIT);
	for(uint i = 0; i < RTV_LIMIT; i++)
	{
		voting[i] = 0;
	}
}

const string g_MapvoteFile = "scripts/plugins/mapvote.cfg";
void ReadMaps()
{
        File@ file = g_FileSystem.OpenFile(g_MapvoteFile, OpenFile::READ);
        if(file !is null && file.IsOpen())
        {
                while(!file.EOFReached())
                {
                        string sLine;
                        file.ReadLine(sLine);
                        if(sLine.SubString(0,1) == "#" || sLine.IsEmpty())
                                continue;

                        array<string> parsed = sLine.Split(" ");
                        if(parsed.length() < 2)
                                continue;

                        mapList.insertLast(parsed[1]);
                }
                file.Close();
        }
}


CClientCommand rtv("rtv", "Rock the Vote Menu", @rtvCmd);

void rtvCmd(const CCommand@ args)
{
	CBasePlayer@ plr = g_ConCommandSystem.GetCurrentPlayer();
	
}

bool doCommand(CBasePlayer@ plr, const CCommand@ args)
{
	const string steamId = g_EngineFuncs.GetPlayerAuthId(plr.edict());
	//maps output to console
	if(args[0] == "maplist" && args.ArgC() == 1)
	{
		g_PlayerFuncs.SayText(plr, "[RTV] Map list dumped to console.\n");
		g_PlayerFuncs.ClientPrint(plr, HUD_PRINTCONSOLE, "[RTV] Available Maps:\n");
		string returnMaps = "";
		for(uint i = 0; i < mapList.length(); i++)
		{
			returnMaps += mapList[i] + " ";
			if(i % 9 == 0)
			{
				g_PlayerFuncs.ClientPrint(plr, HUD_PRINTCONSOLE, returnMaps);
				returnMaps = "";
			}
		}
		g_PlayerFuncs.ClientPrint(plr, HUD_PRINTCONSOLE, "\n");
		return true;
	}
	if(args.ArgC() > 0 && !voteStarted)
	{
		if(args.ArgC() == 1 && (args[0] == "rtv" || args[0] == "rockthevote"))
		{
			//check if unique player
			if(g_RockTheVote.find(steamId) < 0)
			{
				g_RockTheVote.insertLast(steamId);
				counter++;
				g_PlayerFuncs.SayTextAll(plr, "[RTV] " + plr.pev.netname + " has rocked the vote.\n");
				g_PlayerFuncs.SayTextAll(plr, "[RTV] " + counter + " out of " + required + " required RTV have rocked the vote!\n");
			}
			else
			{
				g_PlayerFuncs.SayText(plr, "[RTV] Already rocked the vote!\n");
				g_PlayerFuncs.SayText(plr, "[RTV] " + counter + " out of " + required + " required RTV have rocked the vote!\n");
			}
			//start rtv if possible
			if(counter >= required && !voteStarted)
			{
				startVote(plr);
			}
			return true;
		}
		if((args[0] == "nominate" || args[0] == "nom") && args.ArgC() == 2)
		{
			string plr_map = args[1];
			//g_PlayerFuncs.SayText(plr, "[RTV] Voting for " + plr_map + "\n");
			//check if player already nominated
			if(g_nomination.find(steamId) >= 0)
			{
				g_PlayerFuncs.SayText(plr, "[RTV] Already nominated!\n");
			}
			//check if argument is valid map
			else if(mapList.find(plr_map) < 0)
			{
				g_PlayerFuncs.SayText(plr, "[RTV] Map not found!\n");
			}
			//check if list is not full
			else if(rtvList.length() == RTV_LIMIT)
			{
				g_PlayerFuncs.SayText(plr, "[RTV] Rock The Vote list is full!\n");
			}
			//add map if not already in list
			else if(rtvList.find(plr_map) < 0)
			{
				rtvList.insertLast(plr_map);
				g_nomination.insertLast(steamId);
				g_PlayerFuncs.SayTextAll(plr, "[RTV] " + plr.pev.netname + " nominated " + plr_map +".\n");
			}
			else
			{
				g_PlayerFuncs.SayText(plr, "[RTV] Map already included!\n");
			}
			return true;
		}
	}
	if(voteStarted && args.ArgC() == 2 && args[0] == "rtv")
	{
		string option = args[1];
		int option_int = intParser(option);
		if(option_int > 0 && option_int <= RTV_LIMIT)
		{
			//add the vote
			if(g_voting.find(steamId) < 0)
			{
				g_voting.insertLast(steamId);
				voting[option_int - 1]++;
				g_PlayerFuncs.SayTextAll(plr, "[RTV] " + plr.pev.netname + " voted for " + rtvList[option_int - 1] + ".\n");
			}
			else
			{
				g_PlayerFuncs.SayText(plr, "[RTV] Already voted!\n");
			}
		}
		else
		{
			g_PlayerFuncs.SayText(plr, "[RTV] Invalid rtv choice!\n");
		}
		return true;
	}
	if(args[0] == "listmaps" && args.ArgC() == 1)
	{
		listmaps(plr);
	}
	return false;
}

//helper method, does not check for overflows
int intParser(string str)
{
	int str_toInt = 0;
	uint str_size = str.Length();
	uint uint_add = 0;
	bool invalid_str = false;
	for(uint i = 0; i < str_size && !invalid_str; i++)
	{
		char str_char = str.opIndex(i);
		if(str_char == '0')
		{
			uint_add = 0;
		}
		else if(str_char == '1')
		{
			uint_add = 1;
		}
		else if(str_char == '2')
		{
			uint_add = 2;
		}
		else if(str_char == '3')
		{
			uint_add = 3;
		}
		else if(str_char == '4')
		{
			uint_add = 4;
		}
		else if(str_char == '5')
		{
			uint_add = 5;
		}
		else if(str_char == '6')
		{
			uint_add = 6;
		}
		else if(str_char == '7')
		{
			uint_add = 7;
		}
		else if(str_char == '8')
		{
			uint_add = 8;
		}
		else if(str_char == '9')
		{
			uint_add = 9;
		}
		else
		{
			invalid_str = true;
		}
		if(invalid_str)
		{
			str_toInt = -1;
		}
		else
		{
			str_toInt += int(uint_add) * power(10, str_size - 1 - i);
		}
	}
	return str_toInt;
}

//exponent helper method
int power(int base, int exponent)
{
	if(exponent == 0)
	{
		return 1;
	}
	int modulo = exponent % 2;
	int temp = 0;
	switch(modulo)
	{
	case 0:
		temp = power(base, exponent >>> 1);
		return temp * temp;
	default:
		return base * power(base, exponent - 1);
	}
	return -1;
}

void listmaps(CBasePlayer@ plr)
{
	uint rtvList_size = rtvList.length();
	if(rtvList_size > 0)
	{
		string text_maplist = "Maps in Rock The Vote list:";
		for(uint i = 0; i < rtvList_size - 1; i++)
		{
			text_maplist += " " + rtvList[i] + ",";
		}
		text_maplist += " " + rtvList[rtvList_size - 1];
		g_PlayerFuncs.SayTextAll(plr, "[RTV] " + text_maplist + "\n");
	}
	else
	{
		g_PlayerFuncs.SayText(plr, "[RTV] No maps have been nominated!\n");
	}
}

void startVote(CBasePlayer@ plr)
{
	if(rtvList.length() < RTV_LIMIT)
	{
		addRandomMaps();
	}
	g_PlayerFuncs.SayTextAll(plr, "[RTV] Enough players have rocked the vote.\n");
	voteStarted = true;
	g_PlayerFuncs.SayTextAll(plr, "[RTV] There is 30 seconds to vote.\n");
	listmaps(plr);
	g_PlayerFuncs.SayTextAll(plr, "[RTV] Type \"rtv [number in respect to map listed]\" to vote for a particular map\n");
	listmaps(plr);
	g_Scheduler.SetTimeout("vote", 30, @plr);
}

void vote(CBasePlayer@ plr)
{
	//get two of the highest voted maps
	uint highest = 0;
	int highestIndex = -1;
	uint secondHighest = 0;
	int secondHighestIndex = -1;
	for(uint i = 0; i < voting.length(); i++)
	{
		if(voting[i] != 0 && voting[i] >= highest)
		{
			secondHighest = highest;
			secondHighestIndex = highestIndex;
			highest = voting[i];
			highestIndex = i;
		}
	}
	//no one voted
	if(highestIndex == -1 && secondHighestIndex == -1)
	{
		g_PlayerFuncs.SayTextAll(plr, "[RTV] No one voted, choosing map randomly.\n");
		uint randomMap = Math.RandomLong(0, rtvList.length() - 1);
		chosenMap = rtvList[randomMap];
	}
	//only one voted
	else if(secondHighestIndex == -1 && highestIndex != -1)
	{
		chosenMap = rtvList[highestIndex];
	}
	//more than one voted
	else
	{
		//tiebreaker
		if(highest == secondHighest)
		{
			g_PlayerFuncs.SayTextAll(plr, "[RTV] Tie detected, choosing randomly between: " + rtvList[highestIndex] + " and "
			+ rtvList[secondHighestIndex] + "\n");
			twoMaps.insertLast(rtvList[highestIndex]);
			twoMaps.insertLast(rtvList[secondHighestIndex]);
			uint randomTieBreaker = Math.RandomLong(0, 1);
			chosenMap = twoMaps[randomTieBreaker];
		}
		else
		{
			chosenMap = rtvList[highestIndex];
		}
	}
	//debugging
	/*
	g_PlayerFuncs.SayTextAll(plr, "[RTV] voting length: " + voting.length() + "\n");
	for(uint k = 0; k < voting.length(); k++)
	{
		g_PlayerFuncs.SayTextAll(plr, "[RTV] " + rtvList[k] + " " + voting[k] + "\n");
	}
	*/
	g_PlayerFuncs.SayTextAll(plr, "[RTV] Changing to " + chosenMap + " in 5 seconds....\n");
	g_Scheduler.SetTimeout("changeChosenMap", 5);
}

void changeChosenMap()
{
	g_EngineFuncs.ChangeLevel(chosenMap);
}

void addRandomMaps()
{
	//duplicate maps are not checked for performance reasons
	uint rtvList_size = rtvList.length();
	uint mapList_size = mapList.length();
	for(uint i = 0; i < RTV_LIMIT - rtvList_size; i++)
	{
		rtvList.insertLast(mapList[Math.RandomLong(0, mapList_size - 1)]);
	}
}

HookReturnCode ClientSay(SayParameters@ pParams)
{
	CBasePlayer@ plr = pParams.GetPlayer();
	const CCommand@ args = pParams.GetArguments();
	
	if(doCommand(plr, args))
	{
		pParams.ShouldHide = true;
		return HOOK_HANDLED;
	}
	
	return HOOK_CONTINUE;
}

//player joined?
HookReturnCode ClientPutInServer(CBasePlayer@ plr)
{
	float math = g_PlayerFuncs.GetNumPlayers() * percentage;
	required = uint(math + 0.5);
	return HOOK_CONTINUE;
}

//player joined
HookReturnCode ClientConnected(edict_t@, const string& in, const string& in, bool& out, string& out)
{
	//update rtv player requirement
	float math = g_PlayerFuncs.GetNumPlayers() * percentage;
	required = uint(math + 0.5);
	return HOOK_CONTINUE;
}

//player left
HookReturnCode ClientDisconnect(CBasePlayer@ plr)
{
	//update player requirement
	float math = g_PlayerFuncs.GetNumPlayers() * percentage;
	required = uint(math + 0.5);
	return HOOK_CONTINUE;
}
