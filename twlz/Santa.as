#include "MapBlacklist"

// settings
const bool g_togglesolid        = true;
const bool g_replaceitemmodels  = true;
const bool g_snowmanspawns      = false;
const int g_maxhelpersperplayer = 3;
const string g_helpermodel      = "models/santashelper.mdl"; // monster_human_assassin
const string g_gibmodel         = "models/xmas/alberto309/candy_cane.mdl";
const string g_presentmodel     = "models/xmas/spiritvii/present_small.mdl";
const string g_healthmodel      = "models/xmas/alberto309/present1.mdl";
const string g_batterymodel     = "models/xmas/alberto309/present2.mdl";
const string g_snowmanmodel     = "models/xmas/alberto309/snowman.mdl";
const string g_painsound        = "fgrunt/gr_pain6.wav";
const string g_effectsound      = "debris/beamstart4.wav";
const array<string> g_monsters  = { "monster_headcrab", "monster_babycrab", "monster_snark", "monster_shockroach" }; // "monster_cockroach", "monster_rat" // "monster_chumtoad" too strong
const array<string> g_spawnents = { 'info_player_start', 'info_player_deathmatch', 'info_player_coop', 'info_player_dm2' };
///////////

dictionary g_Counter;
array<EHandle> g_Helpers;
CScheduledFunction@ g_SolidThink = null;
bool g_SolidState = false;

class BadPresent : ScriptBaseItemEntity {
    void Spawn() {
        self.Precache();

        g_EntityFuncs.SetModel( self, g_presentmodel );
        g_EntityFuncs.SetSize( self.pev, Vector( -32, -32, 0 ), Vector( 32, 32, 36 ) );

        BaseClass.Spawn();

        SetUse( UseFunction( this.MyUse ) );
    }

    void Precache() {
        g_Game.PrecacheModel( g_presentmodel );
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

        if ( !g_SurvivalMode.IsActive() && Math.RandomLong(0, 3) == 0 ) {
            if ( Math.RandomLong(0, 1) == 0 ) {
                dictionary keyvalues = {
                    { "health", "2" },
                    { "origin", originStr }
                };

                g_EntityFuncs.CreateEntity( "monster_handgrenade", keyvalues );
                g_Scheduler.SetTimeout( "KillHelper", 2, EHandle( pPlayer ) );
            }
        }
        else {
            string monster = g_monsters[ Math.RandomLong( 0, g_monsters.length() - 1 ) ];

            dictionary keyvalues = {
                { "displayname", "Krampus" },
                { "spawnflags", "4" },
                { "origin", originStr }
            };

            if ( monster == "monster_chumtoad" ) {
                keyvalues["health"] = "10";
                keyvalues["is_player_ally"] = "1";
            }

            g_EntityFuncs.CreateEntity( monster, keyvalues );
        }
    }
}

void PluginInit() {
    g_Module.ScriptInfo.SetAuthor( "incognico" );
    g_Module.ScriptInfo.SetContactInfo( "https://discord.gg/qfZxWAd" );

    g_Hooks.RegisterHook( Hooks::Player::PlayerKilled, @PlayerKilled );

    if ( g_togglesolid )
        @g_SolidThink = g_Scheduler.SetInterval( "SolidThink", 5.0f );
}

void MapInit() {
    g_Game.PrecacheModel( g_helpermodel );
    g_Game.PrecacheModel( g_gibmodel );
    g_Game.PrecacheModel( g_presentmodel );

    if( g_replaceitemmodels ) {
        g_Game.PrecacheModel( g_healthmodel );
        g_Game.PrecacheModel( g_batterymodel );
    }

    if( g_snowmanspawns )
        g_Game.PrecacheModel( g_snowmanmodel );

    for( uint i = 0; i < g_monsters.length(); ++i ) {
        g_Game.PrecacheMonster( g_monsters[i], false );
    }
    g_Game.PrecacheMonster( "monster_human_assassin", true );

    g_Game.PrecacheGeneric ( 'sound/' + g_painsound );
    g_Game.PrecacheGeneric ( 'sound/' + g_effectsound );
    g_SoundSystem.PrecacheSound( g_painsound );
    g_SoundSystem.PrecacheSound( g_effectsound );
    
    g_CustomEntityFuncs.RegisterCustomEntity( "BadPresent", "item_badpresent" );

    g_Helpers.resize(0);
    g_Counter.deleteAll();

    if( g_SolidThink !is null )
        g_Scheduler.RemoveTimer( g_SolidThink );

    if ( g_togglesolid )
        @g_SolidThink = g_Scheduler.SetInterval( "SolidThink", 5.0f );
}

void MapActivate() {
    if ( g_snowmanspawns )
        FestiveSpawns();

    if ( g_replaceitemmodels )
        ReplaceItemModels();
}

HookReturnCode PlayerKilled( CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib ) {
    if ( ( pPlayer.pev.health < -40 && iGib != GIB_NEVER ) || iGib == GIB_ALWAYS )
        CreateGibs( pPlayer.pev.origin );

        if ( MapBlacklisted() )
                return HOOK_CONTINUE;
    
    string originStr = "" + pPlayer.pev.origin.x + " " + pPlayer.pev.origin.y + " " + pPlayer.pev.origin.z;

    switch ( Math.RandomLong( 1, 9 ) ) {
        case 1:
        {
            dictionary keyvalues = {
                { "model", g_presentmodel },
                { "movetype", "0" },
                { "origin", originStr },
                { "m_flCustomRespawnTime", "-1" },
                //{ "ARgrenades", "" + Math.RandomLong(0, 1) }, // gives weapon on some maps
                { "bolts", "" + Math.RandomLong(0, 8) },
                { "buckshot", "" + Math.RandomLong(0, 12) },
                { "bullet357", "" + Math.RandomLong(0, 3) },
                { "bullet556", "" + Math.RandomLong(0, 14) },
                { "bullet9mm", "" + Math.RandomLong(0, 14) },
                { "m40a1", "" + Math.RandomLong(0, 3) },
                { "rockets", "" + Math.RandomLong(0, 1) },
                { "snarks", "" + Math.RandomLong(0, 1) },
                { "sporeclip", "" + Math.RandomLong(0, 3) },
                { "uranium", "" + Math.RandomLong(0, 12) },
                { "spawnflags", "1152" }
            };

            CreateEffect( pPlayer );
            g_EntityFuncs.CreateEntity( "weaponbox", keyvalues );
        }
        break;

        case 2:
        {
            dictionary keyvalues = {
                { "model", g_presentmodel },
                { "health", "" + Math.RandomLong(3, 20) },
                { "healthcap", "" + Math.RandomLong(10, 20) + 100 },
                { "movetype", "0" },
                { "origin", originStr },
                { "m_flCustomRespawnTime", "-1" },
                { "spawnflags", "1152" }
            };

            CreateEffect( pPlayer );
            g_EntityFuncs.CreateEntity( "item_healthkit", keyvalues );
        }
        break;

        case 3:
        {
            dictionary keyvalues = {
                { "model", g_presentmodel },
                { "health", "" + Math.RandomLong(3, 20) },
                { "healthcap", "" + Math.RandomLong(10, 20) + 100 },
                { "movetype", "0" },
                { "origin", originStr },
                { "m_flCustomRespawnTime", "-1" },
                { "spawnflags", "1152" }
            };

            CreateEffect( pPlayer );
            g_EntityFuncs.CreateEntity( "item_battery", keyvalues );
        }
        break;

        case 4:
        {
            dictionary keyvalues = {
                { "origin", originStr }
            };

            CreateEffect( pPlayer );
            g_EntityFuncs.CreateEntity( "item_badpresent", keyvalues );
        }
        break;

        case 9:
        {
//            if ( Math.RandomLong(0, 1) == 0 )
//                break;

            string steamId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );

            if ( g_Counter.exists(steamId) ) {
                g_Counter[steamId] = int(g_Counter[steamId]) + 1;
            }
            else {
                g_Counter[steamId] = int(1);
            }

            if ( int(g_Counter[steamId]) > g_maxhelpersperplayer )
                return HOOK_CONTINUE;

            dictionary keyvalues = {
                { "model", g_helpermodel },
                { "health", "35" },
                { "gag", "-1" },
                { "origin", originStr },
                { "is_player_ally", "1" },
                { "displayname", "Festive Helper of " + pPlayer.pev.netname },
                { "is_not_revivable", "1" },
                { "freeroam", "1" },
                { "spawnflags", "4" }
            };

            CreateEffect( pPlayer );
            CBaseEntity@ helper = g_EntityFuncs.CreateEntity( "monster_human_assassin", keyvalues );
            helper.pev.solid = SOLID_NOT;

            if ( g_togglesolid )
                g_Scheduler.SetTimeout( "AddToHelpers", 6, EHandle(helper) );

            g_Scheduler.SetTimeout( "KillHelper", 300, EHandle(helper) );
        }
        break;
    }

        return HOOK_HANDLED;
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
                g_SoundSystem.EmitSound( cast<CBasePlayer@>( killme ).edict(), CHAN_AUTO, g_painsound, 0.8f, ATTN_STATIC );
        }

        CreateGibs( killme.pev.origin );
    }
}

void SolidThink() {
    array<EHandle> tokeep;

    for ( uint i = 0; i < g_Helpers.length(); ++i ) {
        if ( !g_Helpers[i].IsValid() ) {
            continue;
        }
        else {
            tokeep.insertLast( g_Helpers[i] );
        }

        CBaseEntity@ toggleme = g_Helpers[i].GetEntity();

        if ( g_SolidState ) {
            toggleme.pev.solid = SOLID_NOT;
        }
        else {
            toggleme.pev.solid = SOLID_SLIDEBOX;
        }
    }

    g_Helpers = tokeep;
    g_SolidState = !g_SolidState;
}

void CreateEffect( CBasePlayer@ pPlayer ) {
    uint8 radius = 196;
    uint8 count = 96;
    uint8 life = 4;

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

    g_SoundSystem.EmitSound( pPlayer.edict(), CHAN_ITEM, g_effectsound, 0.8f, ATTN_STATIC );
}

void CreateGibs( Vector origin ) {
    float velocity = 512.0f;
    uint16 count = 16;
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

void FestiveSpawns() {
    CBaseEntity@ pEnt = null;

    for( uint i = 0; i < g_spawnents.length(); ++i ) {
        while( ( @pEnt = g_EntityFuncs.FindEntityByClassname( pEnt, g_spawnents[i] ) ) !is null ) {
            string originStr = "" + pEnt.pev.origin.x + " " + pEnt.pev.origin.y + " " + pEnt.pev.origin.z;

            dictionary keyvalues = {
                { "model", g_snowmanmodel },
                { "movetype", "0" },
                { "origin", originStr  },
                { "angles", "0 " + Math.RandomLong(-180, 180) + " 0" },
                { "spawnflags", "1024" }
            };

            CBaseEntity@ pNewEnt = g_EntityFuncs.CreateEntity( "item_generic", keyvalues );
            pNewEnt.pev.solid = SOLID_NOT;
        }
    }
}

void ReplaceItemModels() {
    CBaseEntity@ pEnt = null;

    // meh can't check for globalmodellist entries, it changes globally replaced models too then :/
    // but somehow not in classic mode?

    while( ( @pEnt = g_EntityFuncs.FindEntityByClassname( pEnt, "item_healthkit" ) ) !is null ) {
        //if( pEnt.pev.model == "models/w_medkit.mdl" )
            g_EntityFuncs.SetModel( pEnt, g_healthmodel );
    }
    
    while( ( @pEnt = g_EntityFuncs.FindEntityByClassname( pEnt, "item_battery" ) ) !is null ) {
        //if ( pEnt.pev.model == "models/w_battery.mdl" )
            g_EntityFuncs.SetModel( pEnt, g_batterymodel );
    }
}
