#include < amxmodx >
#include < torreinc >
//#include < dhudmessage >
//#include < achievements >
#include < acg >

#define MAX 20
#define LEVELS 13

new g_iFirstbloodVariable;

new g_iKills[ MAX+1 ];

new bool:last = false;

//new uch_zemsta, uch_pierwszy;

new g_szDoublekillVariable[ MAX+1 ][ 24 ];
new g_szRevengeKillVariable[ MAX+1 ][ 32 ];

new kills[MAX+1] = {0,...};
new levels[13] = {3, 5, 7, 9, 10, 11, 12, 13, 14, 15, 17, 20, 25};

new stksounds[13][] = {
	"misc/1k/1",
	"misc/1k/2",
	"misc/1k/3",
	"misc/1k/4",
	"misc/1k/5",
	"misc/1k/6",
	"misc/1k/7",
	"misc/1k/8",
	"misc/1k/9",
	"misc/1k/10",
	"misc/1k/11",
	"misc/1k/12",
"misc/1k/13"};

new stkmessages[13][] = {
	"%s: Ostro !",
	"%s: Wypierdalac !",
	"%s: Pierdol sie !",
	"%s: Wsciekusie !!",
	"%s: Nie Uraj Kolo !!",
	"%s: Rzadzisz !!",
	"%s: WOW !!",
	"%s: To Bydle !!",
	"%s: ORGAZM !!!",
	"%s: WOMBO COMBO !!!",
	"%s: Robi Wrazenie !!!",
	"%s: Przeznaczenie !!!",
"%s: POTEGA !!! \o/"};

// Executed after the `plugin_precache` forward
public plugin_init( )
{
	register_plugin( "COD ExpSystem", "0.9", "ToRRent" );

	register_event( "DeathMsg", "PlayerKilled", "a" );
	register_logevent( "RoundStart", 2, "1=Round_Start" );
	
	//uch_zemsta = ach_add("Slodka Zemsta", "Dokonaj 100 razy zemsty", 100);
	//uch_pierwszy = ach_add("Zawsze Pierwszy", "Dokonaj 50 razy Firstblood", 50);
}

public client_connect(id)
{
	kills[id] = 0;
}

// Executed when client disconnect
public client_disconnect( iPlayer )
{
	g_iKills[ iPlayer ] = 0;
	
	g_szRevengeKillVariable[ iPlayer ] = "";
	g_szDoublekillVariable[ iPlayer ] = "";
}

// Executed when map start
public plugin_precache( )
{
	precache_sound("misc/1k/suicide.wav");
	precache_sound("misc/1k/suicide2.wav");
	precache_sound("misc/1k/suicide4.wav");
	precache_sound("TM_CodMod/Payback.wav");
	precache_sound("TM_CodMod/Payback2.wav");
	precache_sound("misc/1k/headshot.wav");
	precache_sound("misc/1k/headshot2.wav");
	precache_sound("misc/1k/lebshot.wav");
	precache_sound("misc/1k/firstblood.wav");
	precache_sound("misc/1k/TK.wav");
	precache_sound("misc/1k/granat.wav");
	precache_sound("misc/1k/he2.wav");
	precache_sound("misc/1k/humiliation.wav");
	precache_sound("misc/1k/doublekill.wav");
	
	precache_sound("misc/1k/1.wav");
	precache_sound("misc/1k/2.wav");
	precache_sound("misc/1k/3.wav");
	precache_sound("misc/1k/4.wav");
	precache_sound("misc/1k/5.wav");
	precache_sound("misc/1k/6.wav");
	precache_sound("misc/1k/7.wav");
	precache_sound("misc/1k/8.wav");
	precache_sound("misc/1k/9.wav");
	precache_sound("misc/1k/10.wav");
	precache_sound("misc/1k/11.wav");
	precache_sound("misc/1k/12.wav");
	precache_sound("misc/1k/13.wav");
	
	//precache_model("sprites/kill_marki/headshot.spr");
	//precache_model("sprites/kill_marki/knife.spr");
	//precache_model("sprites/kill_marki/he.spr");
}

public PlayerKilled( )
{
	static iKiller, iVictim, iHeadshot, szWeapon[ 24 ], szName[ 32 ], szVictimName[ 32 ]
	iKiller = read_data( 1 );
	iVictim = read_data( 2 );
	
	g_iKills[ iVictim ] = 0;
	
	if( !iKiller )
		return PLUGIN_CONTINUE;
	
	iHeadshot = read_data( 3 );
	read_data( 4, szWeapon, charsmax( szWeapon ) );
	get_user_name( iKiller, szName, charsmax( szName ) );
	get_user_name( iVictim, szVictimName, charsmax( szVictimName ) );
	
	g_iKills[ iKiller ]++;
	
	g_szRevengeKillVariable[ iVictim ] = szName;
	
	if( iVictim == iKiller )
	{
		set_hudmessage( 255, 0, 0, -1.0, 0.24, 0, 6.0, 5.0, 0.5, 1.5, -1 );
		show_hudmessage( 0, "%s To byla piekna smierc !", szName );
		new rand_suicide = random_num(1,4)
		switch(rand_suicide)
		{
			case 1:
			{
				if(!last)
				{
					last = true;
					set_task(4.0, "Change");
					client_cmd( 0, "spk misc/1k/suicide")
				}
			}
			case 2:
			{
				if(!last)
				{
					last = true;
					set_task(4.0, "Change");
					client_cmd( 0, "spk misc/1k/suicide2")
				}
			}
			case 3:
			{
				if(!last)
				{
					last = true;
					set_task(4.0, "Change");
					client_cmd( 0, "spk misc/1k/suicide4")
				}
			}
			case 4:
			{
				if(!last)
				{
					last = true;
					set_task(4.0, "Change");
					client_cmd( 0, "spk misc/1k/TK")
				}
			}
		}
	}
	else
	{
		if( equal( szVictimName, g_szRevengeKillVariable[ iKiller ] ))
		{
				
			g_szRevengeKillVariable[ iKiller ] = "";
			//ach_add_status(iKiller, uch_zemsta, 1);
			if(get_user_frags(iKiller) > 10)
			{
				cod_set_user_xp(iKiller, cod_get_user_xp(iKiller)+20);
				//COD_MSG_EXP_P;
				//show_dhudmessage( iKiller, "Zemsta na %s^n+20", szVictimName );
				new wiado[128]
				format(wiado, 127, "Zemsta na %s", szVictimName)
				cod_show_exp_reward(iKiller, 20, wiado)
			}
			else
			{
				//COD_MSG_EXP_P;
				//show_dhudmessage( iKiller, "Zemsta na %s^n+15", szVictimName );
				cod_set_user_xp(iKiller, cod_get_user_xp(iKiller)+15)
				new wiado[128]
				format(wiado, 127, "Zemsta na %s", szVictimName)
				cod_show_exp_reward(iKiller, 15, wiado)
				
			}
			new rand_revenge = random_num(1,2)
			switch(rand_revenge)
			{
				case 1: client_cmd( iKiller, "spk TM_CodMod/payback")
				case 2: client_cmd( iKiller, "spk TM_CodMod/payback2")
					
			}
		}
			
		if( iHeadshot)
		{
			if(is_plugin_loaded("gungame.amxx", true) == 1)
			{
				if(get_user_frags(iKiller) > 10)
				{
					cod_set_user_xp(iKiller, cod_get_user_xp(iKiller)+5);
					//COD_MSG_EXP_P;
					//show_dhudmessage( iKiller, "Headshot^n+5");
					cod_show_exp_reward(iKiller, 5, "HeadShot")
				}
				else
				{
					cod_set_user_xp(iKiller, cod_get_user_xp(iKiller)+3);
					//COD_MSG_EXP_P;
					//show_dhudmessage( iKiller, "Headshot^n+3");
					cod_show_exp_reward(iKiller, 3, "HeadShot")
				}
			}
			else
			{
				if(get_user_frags(iKiller) > 10)
				{
					cod_set_user_xp(iKiller, cod_get_user_xp(iKiller)+10);
					//COD_MSG_EXP_P;
					//show_dhudmessage( iKiller, "Headshot^n+10");
					cod_show_exp_reward(iKiller, 10, "HeadShot")
				}
				else
				{
					cod_set_user_xp(iKiller, cod_get_user_xp(iKiller)+5);
					//COD_MSG_EXP_P;
					//show_dhudmessage( iKiller, "Headshot^n+5");
					cod_show_exp_reward(iKiller, 5, "HeadShot")
				}
			}
			new rand_hs = random_num(1,3)
			switch(rand_hs)
			{
				case 1: client_cmd( iKiller, "spk misc/1k/headshot")
				case 2: client_cmd( iKiller, "spk misc/1k/headshot2")
				case 3: client_cmd( iKiller, "spk misc/1k/lebshot")
			}	
				//acg_drawtga(iKiller, "kill_headshot", 255, 255, 255, 150, -1.0, 0.14, 0, FX_FADE, 0.5, 2.0, 1.0,  3.0, DRAW_HOLES, 0, 0, -1);
			//acg_drawspr(iKiller, "kill_marki/headshot",255, 255, 255, -1.0, 0.14, 0, FX_FADE, 0.5, 2.0, 1.0, 3.0, DRAW_ADDITIVE, -1)

		}
			
		g_iFirstbloodVariable++;
			
		if( g_iFirstbloodVariable == 1)
		{
			//ach_add_status(iKiller, uch_pierwszy, 1);
			if(get_user_frags(iKiller) > 10)
			{
				cod_set_user_xp(iKiller, cod_get_user_xp(iKiller)+20)
				//COD_MSG_EXP_P;
				//show_dhudmessage( iKiller, "Pierwsza krew^n+20");
				cod_show_exp_reward(iKiller, 20, "Pierwsza krew")
			}
			else
			{
				cod_set_user_xp(iKiller, cod_get_user_xp(iKiller)+15)
				//COD_MSG_EXP_P;
				//show_dhudmessage( iKiller, "Pierwsza krew^n+15");
				cod_show_exp_reward(iKiller, 15, "Pierwsza krew")
			}
			client_cmd( iKiller, "spk misc/1k/firstblood")
		}
			
		if( get_user_team( iVictim ) == get_user_team( iKiller ))
		{
			set_hudmessage( 255, 0, 0, -1.0, 0.24, 0, 6.0, 5.0, 0.5, 1.5, -1 );
			show_hudmessage( 0, "%s Cos robi nie tak ...", szName );
			client_cmd(0, "spk misc/1k/TK")
		}
			
		if( szWeapon[ 1 ] == 'r')
		{
			if(get_user_frags(iKiller) > 10)
			{
				cod_set_user_xp(iKiller, cod_get_user_xp(iKiller)+10);
				//COD_MSG_EXP_P;
				//show_dhudmessage( iKiller, "Egzekucja^n+10");
				cod_show_exp_reward(iKiller, 10, "Egzekucja")
			}
			else
			{
				cod_set_user_xp(iKiller, cod_get_user_xp(iKiller)+5);
				//COD_MSG_EXP_P;
				//show_dhudmessage( iKiller, "Egzekucja^n+5")
				cod_show_exp_reward(iKiller, 5, "Egzekucja");
			}
			new egz_hs = random_num(1,2)
			switch(egz_hs)
			{
				case 1: client_cmd( 0, "spk misc/1k/granat");
				case 2: client_cmd(0, "spk misc/1k/he2");
			}
				
				//acg_drawtga(iKiller, "kill_grenade", 255, 255, 255, 250, -1.0, 0.16, 0, FX_FADE_INTERVAL, 0.5, 2.0, 1.0,  3.0, DRAW_ADDITIVE, 0, 0, -1);
			//acg_drawspr(iKiller, "kill_marki/he",255, 255, 255, -1.0, 0.14, 0, FX_FADE, 0.5, 2.0, 1.0, 3.0, DRAW_ADDITIVE, -1)
		}
			
		if( szWeapon[ 0 ] == 'k')
		{
			if(get_user_frags(iKiller) > 10)
			{
				cod_set_user_xp(iKiller, cod_get_user_xp(iKiller)+10);
				//COD_MSG_EXP_P;
				//show_dhudmessage(iKiller, "Zabicie z noza^n+10");
				cod_show_exp_reward(iKiller, 10, "Zabicie z noza")
			}
			else
			{
				cod_set_user_xp(iKiller, cod_get_user_xp(iKiller)+5);
				//COD_MSG_EXP_P;
				//show_dhudmessage(iKiller, "Zabicie z noza^n+5");
				cod_show_exp_reward(iKiller, 5, "Zabicie z noza")
			}
			client_cmd( 0, "spk misc/1k/humiliation");
			//acg_drawtga(iKiller, "kill_knife", 255, 255, 255, 250, -1.0, 0.16, 0, FX_FADE_INTERVAL, 0.5, 2.0, 1.0,  3.0, DRAW_ADDITIVE,  0, 0, -1);
			//acg_drawspr(iKiller, "kill_marki/knife",255, 255, 255, -1.0, 0.14, 0, FX_FADE, 0.5, 2.0, 1.0, 3.0, DRAW_ADDITIVE, -1)
		}
			
		if( equal( g_szDoublekillVariable[ iKiller ], szWeapon ))
		{
			if(get_user_frags(iKiller) > 10)
			{
				cod_set_user_xp(iKiller, cod_get_user_xp(iKiller)+25);
				//COD_MSG_EXP_P;
				//show_dhudmessage( iKiller, "Double kill^n+30");
				cod_show_exp_reward(iKiller, 25, "Double kill")
			}
			else
			{
				cod_set_user_xp(iKiller, cod_get_user_xp(iKiller)+15);
				//COD_MSG_EXP_P;
				//show_dhudmessage( iKiller, "Double kill^n+20");
				cod_show_exp_reward(iKiller, 15, "Double kill")
			}
			client_cmd( iKiller, "spk misc/1k/doublekill");
				
			g_szDoublekillVariable[ iKiller ] = "";
		}
			
		else
		{
			g_szDoublekillVariable[ iKiller ] = szWeapon;
			set_task( 0.1, "Task_ClearKill", iKiller + 69113 );
		}
	}
	for (new i = 0; i < LEVELS; i++)
	{
		if (g_iKills[iKiller] == levels[i])
		{
			announce(iKiller, i);
			return PLUGIN_CONTINUE;
		}
	}
		
	return PLUGIN_CONTINUE;
}
announce(killer, level)
{
	new name[32];
	
	get_user_name(killer, name, 32);
	set_hudmessage(0, 100, 200, 0.05, 0.65, 2, 0.02, 6.0, 0.01, 0.1, -1);
	show_hudmessage(0, stkmessages[level], name);
	client_cmd(0, "spk %s", stksounds[level]);
}

public Change()
	last = false
	
public RoundStart( )
{
	g_iFirstbloodVariable = 0;
}

public Task_ClearKill( iTask )
	g_szDoublekillVariable[ iTask - 69113 ] = "";
	
// wynagrodzenie cod nowy
/*public ach_give_reward(pid, aid)
{
	if(ach_get_stance(pid, uch_zemsta) == 1)
	{
		ach_set_stance(pid, uch_zemsta, 1)
		cod_set_user_xp(pid, cod_get_user_xp(pid)+100);
		COD_MSG_EXP_N;
		show_dhudmessage(pid, "+100");
	}
	if(ach_get_stance(pid, uch_pierwszy) == 1)
	{
		ach_set_stance(pid, uch_pierwszy, 1)
		cod_set_user_xp(pid, cod_get_user_xp(pid)+200);
		COD_MSG_EXP_N;
		show_dhudmessage(pid, "+200");
	}
}*/
