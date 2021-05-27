const array<string> g_MapBlacklist = {
'aom_*',
'aomdc_*',
'bm_sts',
'bossbattle',
'botparty',
'botrace',
'ctf_warforts',
'quad_f',
'ra_quad',
'rust_*',
'shitty_pubg',
'spaceinvaders',
'th_escape',
'uboa',
'zombie_nights_v7'
};

const bool MapBlacklisted()
{
  bool disabled = false;

  for ( uint i = 0; i < g_MapBlacklist.length(); i++ )
  {
    bool wildcard = false;
    string tmp = g_MapBlacklist[i];

    if ( tmp.SubString( tmp.Length()-1, 1 ) == "*" )
    {
      wildcard = true;
      tmp = tmp.SubString( 0, tmp.Length()-1 );
    }

    if ( wildcard )
    {
      if ( tmp == string(g_Engine.mapname).SubString( 0, tmp.Length() ) )
      {
        disabled = true;
        break;
      }
    }
    else if ( string(g_Engine.mapname) == g_MapBlacklist[i] )
    {
      disabled = true;
      break;
    }
  }

  return disabled;
}
