// this is pretty hacky due to the following bugs:
// - zoomable weapons set the fov directly, holding a zoomable weapon in spook mode just breaks the fov
//   and resets it to default. even when swiching to a non-zoomable weapon it stays broken (default).
// - pev values on the player by the game are applied AFTER PlayerSpawn hook, workaround: short Timeout
// - no way to detect if player was revived, maxspeed also set after revive by the game overriding custom
//   value. because of this the maxspeed value has to be set in SpookThink which leads to other problems:
// - some custom weapons and especially the minigun also change the players maxspeed value,
//   as soon as SpookThinks alters it the speed is fast again, even with the minigun,
//   thus I ignore custom entities and weapon_minigun but still the minigun uses a factor for setting
//   maxspeed on the player, derived from sv_maxspeed, so you are faster with the minigun while this is on
// - minor issue: helpers are basically godmoded while they are nonsolid, thus I spawn em with very low hp

#include "MapBlacklist"

// settings
const bool g_togglesolid        = true;
const bool g_replaceitemmodels  = true;
const int g_maxhelpersperplayer = 3;
const float g_spookspeedfactor  = 1.3666;
const string g_ghostspr         = "sprites/lemonghost_alpha.spr";
const string g_helpermodel      = "models/twlz/karenkujo_halloween_fassn.mdl"; // monster_human_assassin
const string g_gibmodel         = "models/biglolly_coop/agibs.mdl";
const string g_treatmodel       = "models/zode/hween17/pumpkin_loot_v2.mdl";
const string g_healthmodel      = "models/twlz/pumpkin_red_fb.mdl";
const string g_batterymodel     = "models/twlz/pumpkin_blue_fb.mdl";
const string g_snarkmodel       = "models/keenhalloween/pumpkinsnark.mdl";
const string g_crabmodel        = "models/hallohospital/m/handcrab.mdl";
const string g_voltimodel       = "models/sa13/baby_voltigore.mdl";
const string g_painsound        = "twlz/cry.ogg";
const string g_spooksound       = "tur/scream2.wav";
const string g_effectsound      = "twlz/trickortreat.ogg";
const array<string> g_monsters  = { "monster_headcrab", "monster_babycrab", "monster_snark", "monster_shockroach", "monster_alien_babyvoltigore" };
const float hallostart          = 1572436800.0;
const float halloend            = 1572652740.0;
///////////

dictionary g_Counter;
dictionary player_states;
array<EHandle> g_Helpers;
CScheduledFunction@ g_SolidThink = null;
CScheduledFunction@ g_SpookThink = null;
bool g_SolidState = false;
int g_ghost = 0;
float maxspeed = 270.0;

class PlayerState {
    EHandle pPlayer;
    int reportState;
}

class BadTreat : ScriptBaseItemEntity {
    void Spawn() {
        self.Precache();

        g_EntityFuncs.SetModel( self, g_treatmodel );
        g_EntityFuncs.SetSize( self.pev, Vector( -32, -32, 0 ), Vector( 32, 32, 36 ) );

        BaseClass.Spawn();

        SetUse( UseFunction( this.MyUse ) );
    }

    void Precache() {
        g_Game.PrecacheModel( g_treatmodel );
    }

    bool MyTouch( CBasePlayer@ pOther ) {
        if ( pOther.IsPlayer() && pOther.IsAlive() && pOther.pev.health > 0 ) {
            CBasePlayer@ pPlayer = cast<CBasePlayer@>( pOther );

            UseTouch( pPlayer );

            return true;
        }

        return false;
    }

    void MyUse( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value ) {
        if ( pActivator.IsPlayer() && pActivator.IsAlive() && pActivator.pev.health > 0 ) {
            CBasePlayer@ pPlayer = cast<CBasePlayer@>( pActivator );

            UseTouch( pPlayer );
        }
    }

    void UseTouch( CBasePlayer@ pPlayer ) {
        string originStr = "" + self.pev.origin.x + " " + self.pev.origin.y + " " + self.pev.origin.z;

        g_EntityFuncs.Remove( self );

        if ( !g_SurvivalMode.IsActive() && Math.RandomLong( 0, 4 ) == 0 ) {
            dictionary keyvalues = {
                { "health", "2" },
                { "displayname", "SPOOKY HANDGRENADE, BOO!" },
                { "origin", originStr }
            };

            g_EntityFuncs.CreateEntity( "monster_handgrenade", keyvalues );
            g_Scheduler.SetTimeout( "KillHelper", 2, EHandle( pPlayer ) );
        }
        else if ( !g_SurvivalMode.IsActive() && Math.RandomLong( 0, ( g_EngineFuncs.Time() >= hallostart && g_EngineFuncs.Time() <= halloend ) ? 1 : 4 ) == 0 ) {
            string steamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );

            if ( steamId == 'STEAM_ID_LAN' || steamId == 'BOT' )
                steamId = pPlayer.pev.netname;

            PlayerState@ pState = getPlayerState( pPlayer );

            if ( pState.reportState == 1 )
                return;

            pState.reportState = 1;

            SpookEffect( pPlayer );

            pPlayer.TakeHealth( 666, DMG_MEDKITHEAL, pPlayer.m_iMaxHealth );
            pPlayer.TakeArmor( 66.6, DMG_MEDKITHEAL, 66 );

            int classify = int( Math.RandomLong( 0, 1 ) );
            pPlayer.SetClassification( classify == 0 ? CLASS_ALIEN_MONSTER : CLASS_HUMAN_MILITARY );
            g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "[AAAAA] 0M0, " + pPlayer.pev.netname + " got S-P-O-O-K-E-D by the " + ( classify == 0 ? "aliens" : "military" ) + "!\n" );

            g_SoundSystem.EmitSound( pPlayer.edict(), CHAN_ITEM, g_spooksound, 1.0f, ATTN_NORM );
        }
        else {
            string monster = g_monsters[ Math.RandomLong( 0, g_monsters.length() - 1 ) ];

            dictionary keyvalues = {
                { "displayname", "SPOOKY MONSTER, BOO!" },
                { "spawnflags", "4" },
                { "origin", originStr }
            };

            if ( monster == "monster_snark" )
                keyvalues["model"] = g_snarkmodel;

            if ( monster == "monster_headcrab" ) 
                keyvalues["model"] = g_crabmodel;

            if ( monster == "monster_alien_babyvoltigore" )
                keyvalues["model"] = g_voltimodel;

            g_EntityFuncs.CreateEntity( monster, keyvalues );
        }
    }
}

void PluginInit() {
    g_Module.ScriptInfo.SetAuthor( "incognico" );
    g_Module.ScriptInfo.SetContactInfo( "https://discord.gg/qfZxWAd" );

    g_Hooks.RegisterHook( Hooks::Player::PlayerSpawn, @PlayerSpawn );
    g_Hooks.RegisterHook( Hooks::Player::PlayerKilled, @PlayerKilled );
    g_Hooks.RegisterHook( Hooks::Game::EntityCreated, @EntityCreated );
}

void MapInit() {
    g_ghost = g_Game.PrecacheModel( g_ghostspr );

    g_Game.PrecacheModel( g_helpermodel );
    g_Game.PrecacheModel( g_gibmodel );
    g_Game.PrecacheModel( g_treatmodel );
    g_Game.PrecacheModel( g_snarkmodel );
    g_Game.PrecacheModel( g_crabmodel );
    g_Game.PrecacheModel( g_voltimodel );

    if ( g_replaceitemmodels ) {
        g_Game.PrecacheModel( g_healthmodel );
        g_Game.PrecacheModel( g_batterymodel );
    }

    for ( uint i = 0; i < g_monsters.length(); ++i ) {
        g_Game.PrecacheMonster( g_monsters[i], false );
    }
    g_Game.PrecacheMonster( "monster_human_assassin", true );

    g_Game.PrecacheGeneric( 'sound/' + g_painsound );
    g_Game.PrecacheGeneric( 'sound/' + g_effectsound );
    g_Game.PrecacheGeneric( 'sound/' + g_spooksound );
    g_SoundSystem.PrecacheSound( g_painsound );
    g_SoundSystem.PrecacheSound( g_effectsound );
    g_SoundSystem.PrecacheSound( g_spooksound );

    g_CustomEntityFuncs.RegisterCustomEntity( "BadTreat", "item_badtreat" );

    g_Helpers.resize(0);
    g_Counter.deleteAll();
    player_states.deleteAll();

    if ( g_SolidThink !is null )
        g_Scheduler.RemoveTimer( g_SolidThink );

    if ( g_togglesolid )
        @g_SolidThink = g_Scheduler.SetInterval( "SolidThink", 3.666f );

    if ( g_SpookThink !is null )
        g_Scheduler.RemoveTimer( g_SpookThink );

    @g_SpookThink = g_Scheduler.SetInterval( "SpookThink", 1.666f );
}

void MapActivate() {
    if ( g_replaceitemmodels )
        ReplaceItemModels();

    if ( !MapBlacklisted() ) {
        maxspeed = g_EngineFuncs.CVarGetFloat( "sv_maxspeed" );
        g_EngineFuncs.CVarSetFloat( "sv_maxspeed", maxspeed*g_spookspeedfactor );
    }
}

HookReturnCode PlayerSpawn( CBasePlayer@ pPlayer ) {
    if ( !MapBlacklisted() )
        g_Scheduler.SetTimeout( "ResetPlayer", 0.1666, EHandle( pPlayer ) );

    return HOOK_CONTINUE;
}

HookReturnCode PlayerKilled( CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib ) {
    if ( ( pPlayer.pev.health < -40 && iGib != GIB_NEVER ) || iGib == GIB_ALWAYS )
        CreateGibs( pPlayer.pev.origin );

    if ( MapBlacklisted() )
        return HOOK_CONTINUE;

    ResetPlayer( EHandle( pPlayer ) );

    string originStr = "" + pPlayer.pev.origin.x + " " + pPlayer.pev.origin.y + " " + pPlayer.pev.origin.z;

    CBaseEntity@ pEnt;

    switch ( Math.RandomLong( 1, ( g_EngineFuncs.Time() >= hallostart && g_EngineFuncs.Time() <= halloend ) ? 9 : 14 ) ) {
        case 1:
        {
            dictionary keyvalues = {
                { "model", g_treatmodel },
                { "movetype", "0" },
                { "origin", originStr },
                { "m_flCustomRespawnTime", "-1" },
                //{ "ARgrenades", "" + Math.RandomLong(0, 1) }, // gives weapon on some maps
                { "bolts", "" + Math.RandomLong(0, 8) },
                { "buckshot", "" + Math.RandomLong(0, 12) },
                { "bullet357", "" + Math.RandomLong(0, 4) },
                { "bullet556", "" + Math.RandomLong(0, 14) },
                { "bullet9mm", "" + Math.RandomLong(0, 14) },
                { "m40a1", "" + Math.RandomLong(0, 3) },
                { "rockets", "" + Math.RandomLong(0, 1) },
                { "snarks", "" + Math.RandomLong(0, 1) },
                { "sporeclip", "" + Math.RandomLong(0, 3) },
                { "uranium", "" + Math.RandomLong(0, 18) },
                { "spawnflags", "1152" }
            };

            @pEnt = g_EntityFuncs.CreateEntity( "weaponbox", keyvalues );
        }
        break;

        case 2:
        {
            dictionary keyvalues = {
                { "model", g_treatmodel },
                { "health", "" + Math.RandomLong(3, 20) },
                { "healthcap", "" + Math.RandomLong(10, 20) + 100 },
                { "movetype", "0" },
                { "origin", originStr },
                { "m_flCustomRespawnTime", "-1" },
                { "spawnflags", "1152" }
            };

            @pEnt = g_EntityFuncs.CreateEntity( "item_healthkit", keyvalues );
        }
        break;

        case 3:
        {
            dictionary keyvalues = {
                { "model", g_treatmodel },
                { "health", "" + Math.RandomLong(3, 20) },
                { "healthcap", "" + Math.RandomLong(10, 20) + 100 },
                { "movetype", "0" },
                { "origin", originStr },
                { "m_flCustomRespawnTime", "-1" },
                { "spawnflags", "1152" }
            };

            @pEnt = g_EntityFuncs.CreateEntity( "item_battery", keyvalues );
        }
        break;

        case 4:
        {
            dictionary keyvalues = {
                { "origin", originStr }
            };

            @pEnt = g_EntityFuncs.CreateEntity( "item_badtreat", keyvalues );
        }
        break;

        case 9:
        {
            if ( !( g_EngineFuncs.Time() >= hallostart && g_EngineFuncs.Time() <= halloend ) && Math.RandomLong( 0, 99 ) > 66 )
                break;

            string steamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );

            if ( g_Counter.exists( steamId ) )
                g_Counter[steamId] = int( g_Counter[steamId] ) + 1;
            else
                g_Counter[steamId] = int( 1 );

            if ( int( g_Counter[steamId] ) > g_maxhelpersperplayer )
                return HOOK_CONTINUE;

            dictionary keyvalues = {
                { "model", g_helpermodel },
                { "health", "35" },
                { "gag", "-1" },
                { "origin", originStr },
                { "is_player_ally", "1" },
                { "displayname", "Spooky Helper of " + pPlayer.pev.netname },
                { "is_not_revivable", "1" },
                { "freeroam", "1" },
                { "spawnflags", "4" }
            };

            CreateEffect( pPlayer );
            CBaseEntity@ helper = g_EntityFuncs.CreateEntity( "monster_human_assassin", keyvalues );
            helper.pev.solid = SOLID_NOT;

            if ( g_togglesolid )
                g_Scheduler.SetTimeout( "AddToHelpers", 6.666f, EHandle( helper ) );

            g_Scheduler.SetTimeout( "KillHelper", 300, EHandle( helper ) );
        }
        break;
    }

    if ( pEnt !is null ) {
        CreateEffect( pPlayer );
        setRenderMode( pEnt, kRenderNormal, kRenderFxGlowShell, 1.666f, Vector( 235, 97, 35 ) );
    }

    return HOOK_HANDLED;
}

HookReturnCode EntityCreated( CBaseEntity@ pEnt ) {
    if ( pEnt !is null ) {
        if ( pEnt.GetClassname() == "item_healthkit" )
            g_EntityFuncs.SetModel( pEnt, g_healthmodel );
        else if ( pEnt.GetClassname() == "item_battery" )
            g_EntityFuncs.SetModel( pEnt, g_batterymodel );
    }

    return HOOK_CONTINUE;
}

void AddToHelpers( EHandle& in helper ) {
    if ( helper.IsValid() )
        g_Helpers.insertLast( helper );
}

void KillHelper( EHandle& in helper ) {
    if ( helper.IsValid() ) {
        CBaseEntity@ killme = helper.GetEntity();

        if ( killme.IsAlive() && killme.pev.health > 0 ) {
            killme.TakeDamage( g_EntityFuncs.Instance(0).pev, g_EntityFuncs.Instance(0).pev, 77, DMG_BLAST );

            if ( killme.IsPlayer() )
                g_SoundSystem.EmitSound( cast<CBasePlayer@>( killme ).edict(), CHAN_AUTO, g_painsound, 0.666f, ATTN_STATIC );
        }

        CreateGibs( killme.pev.origin );
    }
}

void SolidThink() {
    array<EHandle> tokeep;

    for ( uint i = 0; i < g_Helpers.length(); ++i ) {
        if ( !g_Helpers[i].IsValid() )
            continue;
        else
            tokeep.insertLast( g_Helpers[i] );

        CBaseEntity@ toggleme = g_Helpers[i].GetEntity();

        if ( g_SolidState )
            toggleme.pev.solid = SOLID_NOT;
        else
            toggleme.pev.solid = SOLID_SLIDEBOX;
    }

    g_Helpers = tokeep;
    g_SolidState = !g_SolidState;
}

void CreateEffect( CBasePlayer@ pPlayer ) {
    float restime = g_EngineFuncs.CVarGetFloat( "mp_respawndelay" );
    pPlayer.m_flRespawnDelayTime = restime >= 3.666f ? restime*1.666f-restime : 6.66f;

    uint8 radius = 96;
    uint8 count = 32;
    uint8 life = 3;

    NetworkMessage m( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null );
    m.WriteByte( TE_IMPLOSION );
    m.WriteCoord( pPlayer.pev.origin.x );
    m.WriteCoord( pPlayer.pev.origin.y );
    m.WriteCoord( pPlayer.pev.origin.z );
    m.WriteByte( radius );
    m.WriteByte( count );
    m.WriteByte( life );
    m.End();

    NetworkMessage m2( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null );
    m2.WriteByte( TE_TELEPORT );
    m2.WriteCoord( pPlayer.pev.origin.x );
    m2.WriteCoord( pPlayer.pev.origin.y );
    m2.WriteCoord( pPlayer.pev.origin.z );
    m2.End();

    g_SoundSystem.EmitSound( pPlayer.edict(), CHAN_ITEM, g_effectsound, 0.666f, ATTN_STATIC );
}

void CreateGibs( Vector origin ) {
    float velocity = 512.0f;
    uint16 count = 36;
    uint8 life = 196;

    NetworkMessage m( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null );
    m.WriteByte( TE_EXPLODEMODEL );
    m.WriteCoord( origin.x );
    m.WriteCoord( origin.y );
    m.WriteCoord( origin.z );
    m.WriteCoord( velocity );
    m.WriteShort( g_EngineFuncs.ModelIndex( g_gibmodel ) );
    m.WriteShort( count );
    m.WriteByte( life );
    m.End();
}

void ReplaceItemModels() {
    CBaseEntity@ pEnt = null;

    // meh can't check for globalmodellist entries, it changes globally replaced models too then :/
    // but somehow not in classic mode?

    while ( ( @pEnt = g_EntityFuncs.FindEntityByClassname( pEnt, "item_healthkit" ) ) !is null ) {
        //if ( pEnt.pev.model == "models/w_medkit.mdl" )
            g_EntityFuncs.SetModel( pEnt, g_healthmodel );
            //setRenderMode( pEnt, kRenderTransAdd, kRenderFxNone, 106, Vector( 235, 97, 35 ) );
    }

    while ( ( @pEnt = g_EntityFuncs.FindEntityByClassname( pEnt, "item_battery" ) ) !is null ) {
        //if ( pEnt.pev.model == "models/w_battery.mdl" )
            g_EntityFuncs.SetModel( pEnt, g_batterymodel );
            //setRenderMode( pEnt, kRenderTransAdd, kRenderFxNone, 106, Vector( 235, 97, 35 ) );
    }
}


// taken from BleedOut.as, credits to Zorbos & w00tguy123
PlayerState@ getPlayerState( CBasePlayer@ pPlayer ) {
    string steamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );

    if ( steamId == 'STEAM_ID_LAN' || steamId == 'BOT' )
        steamId = pPlayer.pev.netname;

    if ( !player_states.exists( steamId ) ) {
        PlayerState pState;
        pState.pPlayer = pPlayer;
        pState.reportState = 0;
        player_states[steamId] = pState;
    }

    return cast<PlayerState@>( player_states[steamId] );
}

void SpookThink() {
    CBaseEntity@ pEntity = null;

    do {
        @pEntity = g_EntityFuncs.FindEntityByClassname( pEntity, "player" );

        if ( pEntity !is null ) {
            CBasePlayer@ pPlayer = cast<CBasePlayer@>( pEntity );
            PlayerState@ pState = getPlayerState( pPlayer );

            if ( !pPlayer.IsAlive() || !pPlayer.IsConnected() ) {
                pState.reportState = 0;
                continue;
            }

            if ( pState.reportState == 1 ) {
                SpookEffect( pPlayer );
            }
            else if ( pPlayer.m_hActiveItem.GetEntity() !is null ) {
                CBaseEntity@ pEnt = cast<CBaseEntity@>( pPlayer.m_hActiveItem.GetEntity() );

                if ( pEnt !is null && ( pEnt.GetClassname() != "weapon_minigun" || g_CustomEntityFuncs.IsCustomEntity( pEnt.GetClassname() ) ) )
                    pPlayer.pev.maxspeed = maxspeed;
            }
            else {
                 pPlayer.pev.maxspeed = maxspeed;
            }
        }
   } while ( pEntity !is null );
}

void SpookEffect( CBasePlayer@ pPlayer ) {
    setRenderMode( pPlayer, kRenderNormal, kRenderFxGlowShell, 66.0f, Vector( 235, 97, 35 ) );
    g_PlayerFuncs.ScreenFade( pPlayer, Vector( 235, 97, 35 ), 3.666, 1.666, 236, FFADE_MODULATE | FFADE_IN );
    pPlayer.pev.fov = pPlayer.m_iFOV = 115;
    pPlayer.pev.maxspeed = maxspeed*g_spookspeedfactor;
    pPlayer.pev.punchangle.x = Math.RandomFloat( -0.00, -6.66 );

    NetworkMessage spook( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY );
    spook.WriteByte( TE_FIREFIELD );
    spook.WriteCoord( pPlayer.pev.origin.x );
    spook.WriteCoord( pPlayer.pev.origin.y );
    spook.WriteCoord( pPlayer.pev.origin.z );
    spook.WriteShort( 16 );
    spook.WriteShort( g_ghost );
    spook.WriteByte( 4 );
    spook.WriteByte( TEFIRE_FLAG_ALLFLOAT | TEFIRE_FLAG_ALPHA );
    spook.WriteByte( 4 );
    spook.End();

    if ( pPlayer.pev.health <= 6.66 )
        return;

    pPlayer.TakeHealth( -1.9666f, DMG_GENERIC, pPlayer.m_iMaxHealth );
}

void ResetPlayer( EHandle& in player ) {
    if ( player.IsValid() ) {
        CBasePlayer@ pPlayer = cast<CBasePlayer@>( player.GetEntity() );
        PlayerState@ pState = getPlayerState( pPlayer );

        if ( pState.reportState == 1 ) {
            pPlayer.pev.fov = pPlayer.m_iFOV = 0;
            pPlayer.ClearClassification();
            setRenderMode( pPlayer, kRenderNormal, kRenderFxNone, 255, Vector( 255, 255, 255 ) );
        }

        pState.reportState = 0;

        pPlayer.pev.maxspeed = maxspeed;
    }
}

void setRenderMode( CBaseEntity@ pEnt, int rendermode, int renderfx, float renderamt, Vector color ) {
    pEnt.pev.rendermode = rendermode;
    pEnt.pev.renderfx = renderfx;
    pEnt.pev.renderamt = renderamt;
    pEnt.pev.rendercolor = color;
}
