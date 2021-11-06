// Query MetaChads: const bool IsMetaChad(CBasePlayer@);
//
// If used early (eg. ClientPutInServer), use SetTimeout("func", 3.0f) (at least >2.0f!)
// so the client has enough time to report back, otherwise it is probably a race condition
//
// Requires MetaHook.as

const bool IsMetaChad(CBasePlayer@ plr) {
  CBaseEntity@ chadent = g_EntityFuncs.FindEntityByTargetname(null, "_MetaChads");

  if (chadent !is null && g_EntityFuncs.IsValidEntity(chadent.edict())) {
    const string bitskey = "$s_bits";
    CustomKeyvalues@ chadkv = chadent.GetCustomKeyvalues();

    if (chadkv.HasKeyvalue(bitskey)) {
      const uint bits = atoui(chadkv.GetKeyvalue(bitskey).GetString());
      const uint uiPlrBit = (1 << (plr.entindex() & 31));
      return bits & uiPlrBit == uiPlrBit;
    }
    else {
      return false;
    }
  }
}
