// port of https://forums.alliedmods.net/showthread.php?t=115739

void PluginInit()
{
   g_Module.ScriptInfo.SetAuthor("incognico");
   g_Module.ScriptInfo.SetContactInfo("https://discord.gg/qfZxWAd");
}

void MapActivate()
{
   CBaseEntity@ pEntity = null;
   for (int i = g_Engine.maxClients; i <= g_Engine.maxEntities; i++)
   {
      if (pEntity !is null && g_EntityFuncs.IsValidEntity(pEntity.edict()) && pEntity.pev.rendermode == kRenderGlow)
      {
         if (string(pEntity.pev.model)[0] == '*')
           pEntity.pev.rendermode = kRenderNormal;
      }
   }
}
