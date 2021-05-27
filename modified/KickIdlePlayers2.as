const int g_maxplayersAFK = 28;
const int g_maxTotalKick = 1500;

const string g_KeyIdleTime = "$i_idletime";
const string g_KeyIdleAFKSign = "$i_afk_sign";
const string g_KeyIdleOrg = "$v_idleorg";

array<PlayerData@> g_PlayerData;
int plyDataSize = 0;

bool precached = false;

final class PlayerData {
   private int total;
   private string steamID;
   private edict_t@ pPlayerEdict;
   private int lifeTime;
   
   PlayerData( string newsteamID, edict_t@ ply ){
      total = 0;
      steamID = newsteamID;
      @pPlayerEdict = @ply;
      lifeTime = 300;
   }
   
   string getSteamID(){
      return steamID;
   }
   
   int getTotal(){
      return total;
   }
   
   void setTotal(int newTotal){
      total = newTotal;
   }
   
   edict_t@ getPlayerEdict(){
      return pPlayerEdict;
   }
   
   bool shouldGiveUpEntry(){
      CBasePlayer@ pPlayer = null;
      
      //In case the plugin is being reloaded, fill in the list manually to account for it. Saves a lot of console output.
      for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer ){
         @pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );
         
         if( pPlayer is null || !pPlayer.IsConnected() || @pPlayer.edict() != @pPlayerEdict)
            continue;
         
         lifeTime = 300;
         return false;
      }
      
      lifeTime--;
      
      if(lifeTime < 1) return true;
      
      return false;
   }
}

void PluginInit(){
   g_Module.ScriptInfo.SetAuthor("DeepBlueSea + CubeMath + incognico");
   g_Module.ScriptInfo.SetContactInfo("https://discord.gg/qfZxWAd");
  
   g_PlayerData.resize( plyDataSize );
   
   g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @PlayerInit );
   g_Hooks.RegisterHook( Hooks::Player::ClientDisconnect, @ClientDisconnect );

   g_Scheduler.SetInterval("idletestfunc", 1.0f);
}

void MapInit(){
   g_Game.PrecacheModel("sprites/zbeam3.spr");
   g_SoundSystem.PrecacheSound("zode/thunder.ogg");
   g_Game.PrecacheGeneric("sound/zode/thunder.ogg");
   precached = true;
}

bool arrayContainsSteamID(string steamID){
   for(int i = 0; i < plyDataSize; i++){
      if(g_PlayerData[i].getSteamID() == steamID){
         return true;
      }
   }
   return false;
}

CBasePlayer@ GetPlayerBySteamId( const string& in szTargetSteamId ) {
   CBasePlayer@ pTarget;
   
   for( int iIndex = 1; iIndex <= g_Engine.maxClients; ++iIndex ) {
      @pTarget = g_PlayerFuncs.FindPlayerByIndex( iIndex );
      
      if( pTarget !is null ) {
         const string szSteamId = g_EngineFuncs.GetPlayerAuthId( pTarget.edict() );
         
         if( szSteamId == szTargetSteamId )
            return pTarget;
      }
   }
   
   return null;
}

void addOneToArray(string steamID, edict_t@ ply){
   plyDataSize++;
   g_PlayerData.resize( plyDataSize );
   
   PlayerData data( steamID, ply );
   @g_PlayerData[ plyDataSize-1 ] = @data;
}

HookReturnCode PlayerInit( CBasePlayer@ pPlayer ){
   CustomKeyvalues@ pCustom = pPlayer.GetCustomKeyvalues();
   pCustom.InitializeKeyvalueWithDefault(g_KeyIdleTime);
   pCustom.SetKeyvalue( g_KeyIdleOrg, pPlayer.pev.origin );
  
  
   string steamID = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
  
   //AppendEntry, but first check if Entry already exists.
   if(!arrayContainsSteamID(steamID)){
      addOneToArray(steamID, pPlayer.edict());
   }
   
   return HOOK_CONTINUE;
}

int getArrayIdxUsingPlyEdict(edict_t@ ply){
   for(int i = 0; i < plyDataSize; i++){
      if(@g_PlayerData[i].getPlayerEdict() == @ply){
         return i;
      }
   }
   return -1;
}

bool bPlayerMoved( CBasePlayer@ pPlayer ){
   CustomKeyvalues@ pCustom = pPlayer.GetCustomKeyvalues();

   bool bMoved = (pCustom.GetKeyvalue( g_KeyIdleOrg ).GetVector() != pPlayer.pev.origin);

   if (bMoved){
      pCustom.SetKeyvalue( g_KeyIdleOrg, pPlayer.pev.origin );
    
    const int idx = getArrayIdxUsingPlyEdict(pPlayer.edict());
    if(idx == -1){
      string steamID = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
      addOneToArray(steamID, pPlayer.edict());
    }else{
      if(g_PlayerData[idx].getTotal() > 0){
        g_PlayerData[idx].setTotal(g_PlayerData[idx].getTotal()-1);
      }
    }
   }
  
   return bMoved;
}

void delOneToArray(int idx){
   plyDataSize--;
   for(int i = idx; i < plyDataSize; i++){
      @g_PlayerData[ i ] = @g_PlayerData[ i+1 ];
   }
   g_PlayerData.resize( plyDataSize );
}

void idletestfunc(){ 
   string m_sMap = g_Engine.mapname;
   if(m_sMap == "of0a0") return;
   if(m_sMap == "th_ep1_00") return;
   if(m_sMap == "dy_outro") return;
   if(m_sMap == "botparty") return;
   if(m_sMap == "island") return;
   if(m_sMap == "f_island") return;
   if(m_sMap == "f_island_v2") return;
   if(m_sMap == "rust_legacy") return;
   if(m_sMap == "rust_islands") return;
   if(m_sMap == "rust_mini") return;
   
  int plyCnt = 0;
  
   for( int i = 1; i <= g_Engine.maxClients; ++i ) {
      CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( i );
      if (pPlayer !is null && pPlayer.IsConnected()) ++plyCnt;
   }
  
   for( int i = 1; i <= g_Engine.maxClients; ++i ) {
      CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( i );
    
      if (pPlayer !is null && pPlayer.IsConnected()) {
         CustomKeyvalues@ pCustom = pPlayer.GetCustomKeyvalues();
         CustomKeyvalue valuePlayerIdle( pCustom.GetKeyvalue( g_KeyIdleTime ) );
      
      int plyIdle = valuePlayerIdle.GetInteger();
      bool alive = pPlayer.IsAlive();
      
      if (!bPlayerMoved(pPlayer)) {
         if(alive) {
            ++plyIdle;
         }
      }else{
         plyIdle = 0;
         pCustom.SetKeyvalue( g_KeyIdleAFKSign, 0);
      }
      
      pCustom.SetKeyvalue( g_KeyIdleTime, plyIdle);
      
      int idx = getArrayIdxUsingPlyEdict(pPlayer.edict());
      if(idx == -1){
        string steamID = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
        addOneToArray(steamID, pPlayer.edict());
        idx = plyDataSize - 1;
      }
      
      int totalVal = g_PlayerData[idx].getTotal();
      int maxIdle = 180;
      if(totalVal > 0) maxIdle = 120; // player was afk once?

      if (g_SurvivalMode.IsActive())
         maxIdle = maxIdle/2;

      if( m_sMap == "hl_c08_a2" &&
          pPlayer.pev.origin.x > -3174 && pPlayer.pev.origin.x < -2788 &&
          pPlayer.pev.origin.y > 384 && pPlayer.pev.origin.y < 960 &&
          pPlayer.pev.origin.z > -1400 && pPlayer.pev.origin.z < -1000
      ) maxIdle = 3;

      if (pPlayer.pev.FlagBitSet(FL_FROZEN))
          maxIdle = maxIdle*5;

      if (valuePlayerIdle.GetInteger() >= maxIdle ) {
        pCustom.SetKeyvalue( g_KeyIdleTime, 0);

        if(totalVal > g_maxTotalKick){
          g_EngineFuncs.ServerCommand("kick #" + g_EngineFuncs.GetPlayerUserId(pPlayer.edict()) + " You were kicked for being AFK too long.\n");
          g_EngineFuncs.ServerExecute();
          g_PlayerFuncs.ClientPrintAll( HUD_PRINTNOTIFY, "" + pPlayer.pev.netname + " was kicked for being AFK too long.\n" );
        }else if(plyCnt > g_maxplayersAFK){
          g_EngineFuncs.ServerCommand("kick #" + g_EngineFuncs.GetPlayerUserId(pPlayer.edict()) + " You were kicked for being AFK on a full server.\n");
          g_EngineFuncs.ServerExecute();
          g_PlayerFuncs.ClientPrintAll( HUD_PRINTNOTIFY, "" + pPlayer.pev.netname + " was kicked for being AFK on a full server.\n" );
        }else{
          entvars_t@ world = g_EntityFuncs.Instance(0).pev;
          pPlayer.TakeDamage(world, world, 9999.9f, (g_SurvivalMode.IsActive() ? DMG_ALWAYSGIB : DMG_NEVERGIB) | DMG_SHOCK_GLOW);
          if (precached){
              TraceResult tr;
              g_EngineFuncs.MakeVectors(pPlayer.pev.angles);
              g_Utility.TraceLine(pPlayer.pev.origin, pPlayer.pev.origin+g_Engine.v_up*4096, ignore_monsters, pPlayer.edict(), tr);
              NetworkMessage message(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null);
                 message.WriteByte(TE_BEAMPOINTS);
                 message.WriteCoord(pPlayer.pev.origin.x);
                 message.WriteCoord(pPlayer.pev.origin.y);
                 message.WriteCoord(pPlayer.pev.origin.z);
                 message.WriteCoord(tr.vecEndPos.x);
                 message.WriteCoord(tr.vecEndPos.y);
                 message.WriteCoord(tr.vecEndPos.z);
                 message.WriteShort(g_EngineFuncs.ModelIndex("sprites/zbeam3.spr"));
                 message.WriteByte(0);
                 message.WriteByte(1);
                 message.WriteByte(2);
                 message.WriteByte(16);
                 message.WriteByte(64);
                 message.WriteByte(175);
                 message.WriteByte(215);
                 message.WriteByte(255);
                 message.WriteByte(255);
                 message.WriteByte(0);
              message.End();
              NetworkMessage message2(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null);
                 message2.WriteByte(TE_DLIGHT);
                 message2.WriteCoord(pPlayer.pev.origin.x);
                 message2.WriteCoord(pPlayer.pev.origin.y);
                 message2.WriteCoord(pPlayer.pev.origin.z);
                 message2.WriteByte(24);
                 message2.WriteByte(175);
                 message2.WriteByte(215);
                 message2.WriteByte(255);
                 message2.WriteByte(4);
                 message2.WriteByte(88);
              message2.End();
              g_SoundSystem.PlaySound(pPlayer.edict(), CHAN_STATIC, "zode/thunder.ogg", 0.67f, 1.0f);
          }
          g_PlayerFuncs.ClientPrintAll( HUD_PRINTNOTIFY, "" + pPlayer.pev.netname + " was slayed for being AFK.\n" );
          g_PlayerData[idx].setTotal(g_PlayerData[idx].getTotal() + maxIdle);
          pCustom.SetKeyvalue( g_KeyIdleAFKSign, 1);
        }
         } else {
            if (plyIdle > 0 && (valuePlayerIdle.GetInteger() >= maxIdle - 15 )) {
               int timeRemaining = maxIdle - valuePlayerIdle.GetInteger();
          if(totalVal > g_maxTotalKick || plyCnt > g_maxplayersAFK)
            g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCENTER, "AFK: You will be KICKED in: "+timeRemaining+"s\n" );
          else
            g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCENTER, "AFK: You will be slayed in: "+timeRemaining+"s\n" );
            }
         }
      }
   }
  
  if(plyCnt > g_maxplayersAFK){
    CBasePlayer@ pPlayerAFK = null;
    int afkTotal = 99;
    
    for( int i = 1; i <= g_Engine.maxClients; ++i )   {
      CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( i );
      
      if (pPlayer !is null && pPlayer.IsConnected() && !pPlayer.IsAlive()){
        CustomKeyvalues@ pCustom = pPlayer.GetCustomKeyvalues();
        CustomKeyvalue valuePlayerAFKSign( pCustom.GetKeyvalue( g_KeyIdleTime ) );
        int afkSign = valuePlayerAFKSign.GetInteger();
        if(afkSign == 1) {
          const int idx = getArrayIdxUsingPlyEdict(pPlayer.edict());
          if(idx == -1){
            string steamID = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
            addOneToArray(steamID, pPlayer.edict());
          }else{
            int plyIdle = g_PlayerData[idx].getTotal();
            
            if(plyIdle > afkTotal){
              @pPlayerAFK = @pPlayer;
              afkTotal = plyIdle;
            }
          }
        }
      }
    }
    
    if(pPlayerAFK !is null){
      g_EngineFuncs.ServerCommand("kick #" + g_EngineFuncs.GetPlayerUserId(pPlayerAFK.edict()) + "You were kicked for being AFK on a full server.\n");
      g_EngineFuncs.ServerExecute();
      g_PlayerFuncs.ClientPrintAll( HUD_PRINTNOTIFY, "" + pPlayerAFK.pev.netname + " was kicked for being AFK on a full server.\n" ); 
    }
  }
  
   for(int i = 0; i < plyDataSize; i++){
      if(g_PlayerData[i].shouldGiveUpEntry()){
         delOneToArray(i);
         i--;
      }
   }
}

HookReturnCode ClientDisconnect( CBasePlayer@ pPlayer ){
   
   //Find and Delete Entry
   const int targetIndex = getArrayIdxUsingPlyEdict(pPlayer.edict());
   if(targetIndex != -1){
      delOneToArray(targetIndex);
   }
   
   //SOLVED: People might disconnect while on a MapChange and avoid calling this Hook.
   
   return HOOK_CONTINUE;
}
