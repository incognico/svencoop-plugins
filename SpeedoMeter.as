array<string> g_PlayerSpeed;
uint g_spdflags = 0; // bitfield
uint g_oddeven  = 0; // bitfield

void PluginInit() {
  g_Module.ScriptInfo.SetAuthor("incognico");
  g_Module.ScriptInfo.SetContactInfo("https://discord.gg/qfZxWAd");

  g_Hooks.RegisterHook(Hooks::Player::ClientDisconnect, @ClientDisconnect);
  g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @ClientPutInServer);
  g_Hooks.RegisterHook(Hooks::Player::ClientSay, @ClientSay);
  g_Hooks.RegisterHook(Hooks::Player::PlayerPostThink, @PlayerPostThink);
}

void MapInit() {
  g_spdflags = 0;
}

HookReturnCode ClientSay(SayParameters@ pParams) {
  CBasePlayer@ plr = pParams.GetPlayer();
  const CCommand@ pArguments = pParams.GetArguments();
 
  if (pArguments.ArgC() == 1) {
    if (pArguments.Arg(0) == "speedometer" || pArguments.Arg(0) == ".speedometer" || pArguments.Arg(0) == "/speed") {
      pParams.ShouldHide = true;
      const string szSteamId = g_EngineFuncs.GetPlayerAuthId(plr.edict());

      const int idx = g_PlayerSpeed.find(szSteamId);
      if (idx >= 0) {
        g_PlayerFuncs.ClientPrint(plr, HUD_PRINTTALK, "[SpeedoMeter] Disabled.\n");
        g_PlayerSpeed.removeAt(idx);
        SpeedDisable(plr);
      }
      else {
        g_PlayerFuncs.ClientPrint(plr, HUD_PRINTTALK, "[SpeedoMeter] Enabled.\n");
        g_PlayerSpeed.insertLast(szSteamId);
        SpeedEnable(plr);
      }
    }
  }

  return HOOK_CONTINUE;
}

HookReturnCode ClientPutInServer(CBasePlayer@ plr) {
  const string szSteamId = g_EngineFuncs.GetPlayerAuthId(plr.edict());

  const int idx = g_PlayerSpeed.find(szSteamId);
  if (idx >= 0)
    SpeedEnable(plr);

  return HOOK_CONTINUE;
}

HookReturnCode ClientDisconnect(CBasePlayer@ plr) {
  SpeedDisable(plr);

  return HOOK_CONTINUE;
}

HookReturnCode PlayerPostThink(CBasePlayer@ plr) {
  if (plr !is null && IsSpeedEnabled(plr)) {
    if (IsOdd(plr))
      SpeedMsg(plr);

    ToggleOE(plr);
  }

  return HOOK_CONTINUE;
}

void SpeedMsg(CBasePlayer@ plr) {
  Vector velocity;
  bool observer = false;

  if (plr.GetObserver().IsObserver()) {
    CBaseEntity@ observerTarget = plr.GetObserver().GetObserverTarget();

    if (observerTarget !is null) {
      velocity = observerTarget.pev.velocity;
    }
    else {
      velocity = plr.pev.velocity;
    }

    observer = true;
  }
  else {
    velocity = plr.pev.velocity;
  }

  //const uint speed  = uint( floor( velocity.Length() + 0.5f ) );
  const uint speedh = uint( floor( velocity.Length2D() + 0.5f ) );

  HUDTextParams txtPrms;

  if (speedh <= 0)
    SetColor(txtPrms, RGBA_SVENCOOP);
  else if (speedh <= 106)
    SetColor(txtPrms, RGBA_WHITE);
  else if (speedh <= 270)
    SetColor(txtPrms, RGBA_GREEN);
  else if (speedh <= 320)
    SetColor(txtPrms, RGBA_ORANGE);
  else
    SetColor(txtPrms, RGBA_RED);

  txtPrms.x = -1.0f;
  txtPrms.y = 1.0f;
  txtPrms.effect = 0;
  txtPrms.fadeinTime = 0.0f;
  txtPrms.fadeoutTime = 0.0f;
  txtPrms.holdTime = 1.0f;
  txtPrms.channel = 4;

  if (observer) {
    //HudMessageUnreliable(plr, txtPrms, string(speedh) + " v (" + string(speed) + " s)");
    HudMessageUnreliable(plr, txtPrms, string(speedh) + "\n\n");
  }
  else {
    //HudMessageUnreliable(plr, txtPrms, string(speedh) + " v\n(" + string(speed) + " s)");
    HudMessageUnreliable(plr, txtPrms, string(speedh) + "\n");
  }
}

void SetColor(HUDTextParams& out txtPrms, const RGBA& in color) {
  txtPrms.r1 = color.r;
  txtPrms.g1 = color.g;
  txtPrms.b1 = color.b;
  txtPrms.a1 = color.a;
}

void SpeedEnable(CBasePlayer@ plr) {
  const uint uiPlrBit = (1 << (plr.entindex() & 31));
  g_spdflags |= uiPlrBit;
}

void SpeedDisable(CBasePlayer@ plr) {
  const uint uiPlrBit = (1 << (plr.entindex() & 31));
  g_spdflags &= ~uiPlrBit;
}

const bool IsSpeedEnabled(CBasePlayer@ plr) {
  const uint uiPlrBit = (1 << (plr.entindex() & 31));
  return g_spdflags & uiPlrBit == uiPlrBit;
}

void ToggleOE(CBasePlayer@ plr) {
  const uint uiPlrBit = (1 << (plr.entindex() & 31));
  g_oddeven ^= uiPlrBit;
}

const bool IsOdd(CBasePlayer@ plr) {
  const uint uiPlrBit = (1 << (plr.entindex() & 31));
  return g_oddeven & uiPlrBit == uiPlrBit;
}

// because g_PlayerFuncs.HudMessage() does not allow passing NetworkMessageDest and uses MSG_ONE (reliable)
// we have to recreate the method to be able to use MSG_ONE_UNRELIABLE
void HudMessageUnreliable(CBasePlayer@ plr, const HUDTextParams& in txtPrms, const string& in text) {
  if (plr is null)
    return;

  NetworkMessage m(MSG_ONE_UNRELIABLE, NetworkMessages::SVC_TEMPENTITY, plr.edict());
    m.WriteByte(TE_TEXTMESSAGE);
    m.WriteByte(txtPrms.channel & 0xFF);

    m.WriteShort(FixedSigned16(txtPrms.x, 1<<13));
    m.WriteShort(FixedSigned16(txtPrms.y, 1<<13));
    m.WriteByte(txtPrms.effect);

    m.WriteByte(txtPrms.r1);
    m.WriteByte(txtPrms.g1);
    m.WriteByte(txtPrms.b1);
    m.WriteByte(txtPrms.a1);

    m.WriteByte(txtPrms.r2);
    m.WriteByte(txtPrms.g2);
    m.WriteByte(txtPrms.b2);
    m.WriteByte(txtPrms.a2);

    m.WriteShort(FixedUnsigned16(txtPrms.fadeinTime, 1<<8));
    m.WriteShort(FixedUnsigned16(txtPrms.fadeoutTime, 1<<8));
    m.WriteShort(FixedUnsigned16(txtPrms.holdTime, 1<<8));

    if (txtPrms.effect == 2) 
      m.WriteShort(FixedUnsigned16(txtPrms.fxTime, 1<<8));

    m.WriteString(text);
  m.End();
}

uint16 FixedUnsigned16( float value, float scale ) {
   float scaled = value * scale;
   int output = int( scaled );
   
   if ( output < 0 )
      output = 0;
   if ( output > 0xFFFF )
      output = 0xFFFF;

   return uint16( output );
}

int16 FixedSigned16( float value, float scale ) {
   float scaled = value * scale;
   int output = int( scaled );

   if ( output > 32767 )
      output = 32767;
   if ( output < -32768 )
      output = -32768;

   return int16( output );
}
