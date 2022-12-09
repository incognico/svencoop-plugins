// bind key ".typing;messagemode"   // say
// bind key ".typing;messagemode2"  // say_team
// bind key "toggleconsole;.typing2" // console // does not work in config

// Creating a sprite:
// - The first frame of an env_sprite animation is skipped when looping,
//   so the first frame in the sprite should be a duplicate of the last.
// - Set a vertical offset (-51) or else it will show at player origin

const string g_chatspr = 'sprites/chatbubble/chat.spr';
const string g_consolespr = 'sprites/chatbubble/console.spr';

int g_spridx = 0;

CClientCommand _typing("typing", "Typing indicator for chat", @TypingCmd );
CClientCommand _typing2("typing2", "Typing indicator for console", @TypingCmd2 );

array<EHandle> g_typing_sprites;

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "incognico" );
    g_Module.ScriptInfo.SetContactInfo( "https://discord.gg/qfZxWAd" );

    g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
    g_Hooks.RegisterHook( Hooks::Player::ClientDisconnect, @ClientDisconnect );
    g_Hooks.RegisterHook( Hooks::Player::PlayerPostThink, @PlayerPostThink );
    
    g_typing_sprites.resize(g_Engine.maxClients+1);
}

void PluginExit()
{
	for (uint i = 0; i < g_typing_sprites.size(); i++) {
		g_EntityFuncs.Remove(g_typing_sprites[i]);
	}
}

void MapInit()
{
    g_typing_sprites.resize(0);
    g_typing_sprites.resize(g_Engine.maxClients+1);
    
    g_spridx = g_Game.PrecacheModel( g_chatspr );
    g_Game.PrecacheModel( g_consolespr );
}

HookReturnCode PlayerPostThink( CBasePlayer@ plr )
{
    const bool bpressed = (plr.m_afButtonPressed & ~32768) + (plr.m_afButtonLast & ~32768) != 0;

    if ( plr !is null && IsTyping( plr ) && bpressed )
        EndChatMode( plr );

    return HOOK_CONTINUE;
}

HookReturnCode ClientSay( SayParameters@ pParams )
{
    EndChatMode( pParams.GetPlayer() );

    return HOOK_CONTINUE;
}

HookReturnCode ClientDisconnect( CBasePlayer@ plr )
{
    EndChatMode( plr );

    return HOOK_CONTINUE;
}

void TypingCmd( const CCommand@ args )
{
    StartChatMode( g_ConCommandSystem.GetCurrentPlayer(), g_chatspr );
}

void TypingCmd2( const CCommand@ args )
{
    StartChatMode( g_ConCommandSystem.GetCurrentPlayer(), g_consolespr );
}

void StartChatMode( CBasePlayer@ plr, string spritePath )
{
    if ( plr !is null and g_spridx != 0)
    {
		if (plr.GetObserver() !is null && plr.GetObserver().IsObserver()) {
			return;
		}
		
        g_EntityFuncs.Remove(g_typing_sprites[plr.entindex()]);
        
        dictionary keys;
        keys["origin"] = plr.pev.origin.ToString();
        keys["model"] = spritePath;
        keys["scale"] =  "1";
        keys["framerate"] =  "10.0";
        keys["spawnflags"] = "1";
        CBaseEntity@ sprite = g_EntityFuncs.CreateEntity("env_sprite", keys, true);
        sprite.pev.movetype = MOVETYPE_FOLLOW;
        @sprite.pev.aiment = @plr.edict();
        
        g_typing_sprites[plr.entindex()] = sprite;

		bool isBarnacled = plr.m_afPhysicsFlags & PFLAG_ONBARNACLE != 0;
        if ( g_PlayerFuncs.AdminLevel( plr ) >= ADMIN_YES && !g_SurvivalMode.IsActive() && plr.IsAlive() && !isBarnacled )
            plr.pev.flags |= FL_NOTARGET;
    }
}

void EndChatMode( CBasePlayer@ plr )
{
    if ( g_PlayerFuncs.AdminLevel( plr ) >= ADMIN_YES && plr.IsAlive() )
        plr.pev.flags &= ~FL_NOTARGET;

    g_EntityFuncs.Remove(g_typing_sprites[plr.entindex()]);
}

bool IsTyping( CBasePlayer@ plr )
{
    return g_typing_sprites[plr.entindex()].IsValid();
}
