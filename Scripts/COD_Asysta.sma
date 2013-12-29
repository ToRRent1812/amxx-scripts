/* --------------------------------------------------------------------------
CVary

- amx_killassist_enable 0-3 (default: 1)
0 = Wylacz plugin / 1 = Uruchom przez DeathMsg / 2 = Uruchom przez HUD message / 3 = Uruchom przez Dynamic Hud By R3X (3 opcja wkrotce zostanie dodana ;])

- amx_killassist_mindamage 1-9999 (default: 30)
ilosc dmg jaka musi wykonac gracz zeby zaliczylo asyste

- amx_killassist_givefrags 0/1 (default: 1)
Dac fraga graczowi ktory asystowal ?

- amx_killassist_givemoney 0-16000 (default: 150)
Ile $$ dac pomocnikowi ?

- amx_killassist_onlyalive 0/1 (default: 1)
Czy tylko zywi pomocnicy maja otrzymywac wynagrodzenie za asyste ?
-------------------------------------------------------------- */

/* HUD message */

#define HUD_colorR		255	// default: 255
#define HUD_colorG		155	// default: 155
#define HUD_colorB		0	// default: 0
#define HUD_posX		0.6	// default: 0.6
#define HUD_posY		0.2	// default: 0.2
#define HUD_fx			0	// default: 0
#define HUD_fxTime		0.0	// default: 0.0
#define HUD_holdTime		1.0	// default: 1.0
#define HUD_fadeInTime		0.3	// default: 0.3
#define HUD_fadeOutTime		2.0	// default: 2.0
#define HUD_channel		-1	// default: -1

/* -------------------------------------------------------------------------
Nic tu nie zmieniaj ! */

#include <amxmodx>
#include <hamsandwich>
#include <cstrike>
#include <engine>
#include <fun>
#include <torreinc>
#include <acg>

#define PLUGIN_TITLE		"Asysta przy zabiciu"
#define PLUGIN_VERSION		"1.2b"
#define PLUGIN_AUTHOR		"Digi (ToRRent Edit)"
#define PLUGIN_PUBLICVAR	"killassist_version"

#define MAXPLAYERS		20 + 1

#define TEAM_NONE			0
#define TEAM_TE			1
#define TEAM_CT			2
#define TEAM_SPEC			3

#define is_player(%1) (1 <= %1 <= g_iMaxPlayers)

new msgID_sayText
new msgID_deathMsg
new msgID_scoreInfo
new msgID_money

new pCVar_amxMode

new pCVar_enabled
new pCVar_minDamage
new pCVar_giveFrags
new pCVar_giveMoney
new pCVar_onlyAlive

new ch_pCVar_enabled
new ch_pCVar_minDamage
new ch_pCVar_giveFrags
new ch_pCVar_giveMoney
new ch_pCVar_onlyAlive

new g_szName[MAXPLAYERS][32]
new g_iTeam[MAXPLAYERS]
new g_iDamage[MAXPLAYERS][MAXPLAYERS]
new bool:g_bAlive[MAXPLAYERS] = {false, ...}
new bool:g_bOnline[MAXPLAYERS] = {false, ...}

new g_iLastAmxMode
new g_iMaxPlayers = 0
new bool:g_bAmxModeExists = false

//new dhud;

public plugin_init()
{
	register_plugin(PLUGIN_TITLE, PLUGIN_VERSION, PLUGIN_AUTHOR)
	register_cvar(PLUGIN_PUBLICVAR, PLUGIN_VERSION, FCVAR_SERVER|FCVAR_SPONLY)
	
	pCVar_enabled = register_cvar("amx_killassist_enabled", "2")
	pCVar_minDamage = register_cvar("amx_killassist_mindamage", "35")
	pCVar_giveFrags = register_cvar("amx_killassist_givefrags", "1")
	pCVar_giveMoney = register_cvar("amx_killassist_givemoney", "150")
	pCVar_onlyAlive = register_cvar("amx_killassist_onlyalive", "1")
	
	if(cvar_exists("amx_mode"))
	{
		pCVar_amxMode = get_cvar_pointer("amx_mode")
		
		g_bAmxModeExists = true
	}
	
	msgID_money = get_user_msgid("Money")
	msgID_sayText = get_user_msgid("SayText")
	msgID_deathMsg = get_user_msgid("DeathMsg")
	msgID_scoreInfo = get_user_msgid("ScoreInfo")
	
	register_message(msgID_deathMsg, "msg_deathMsg")
	
	register_logevent("event_roundStart", 2, "1=Round_Start")
	
	register_event("Damage", "player_damage", "be", "2!0", "3=0", "4!0")
	register_event("DeathMsg", "player_die", "ae")
	register_event("TeamInfo", "player_joinTeam", "a")
	
	RegisterHam(Ham_Spawn, "player", "player_spawn", 1)
	
	g_iMaxPlayers = get_maxplayers()
	
	//dhud = DHUD_create()
	//StopKlatki()
	
}

public plugin_cfg() event_roundStart()

public event_roundStart()
{
	ch_pCVar_enabled = clamp(get_pcvar_num(pCVar_enabled), 0, 2)
	ch_pCVar_minDamage = clamp(get_pcvar_num(pCVar_minDamage), 0, 9999)
	ch_pCVar_giveFrags = clamp(get_pcvar_num(pCVar_giveFrags), 0, 1)
	ch_pCVar_giveMoney = clamp(get_pcvar_num(pCVar_giveMoney), 0, 99999)
	ch_pCVar_onlyAlive = clamp(get_pcvar_num(pCVar_onlyAlive), 0, 1)
}

public client_putinserver(iPlayer)
{
	g_bOnline[iPlayer] = true
	
	get_user_name(iPlayer, g_szName[iPlayer], 31)
}

public client_disconnect(iPlayer)
{
	g_iTeam[iPlayer] = TEAM_NONE
	g_bAlive[iPlayer] = false
	g_bOnline[iPlayer] = false
}

public player_joinTeam()
{
	new iPlayer, szTeam[2]
	
	iPlayer = read_data(1)
	read_data(2, szTeam, 1)
	
	switch(szTeam[0])
	{
		case 'T': g_iTeam[iPlayer] = TEAM_TE
		case 'C': g_iTeam[iPlayer] = TEAM_CT
		default: g_iTeam[iPlayer] = TEAM_SPEC // since you can't transfer yourself to unassigned team...
	}
	
	return PLUGIN_CONTINUE
}

public player_spawn(iPlayer)
{
	if(!is_user_alive(iPlayer))
		return HAM_IGNORED
	
	g_bAlive[iPlayer] = true // he's alive !
	
	new szName[32]
	
	get_user_name(iPlayer, szName, 31)
	
	if(!equali(szName, g_szName[iPlayer])) // make sure he has his name !
	{
		set_msg_block(msgID_sayText, BLOCK_ONCE)
		set_user_info(iPlayer, "name", g_szName[iPlayer])
	}
	
	// reset damage meters
	
	for(new p = 1; p <= g_iMaxPlayers; p++)
		g_iDamage[iPlayer][p] = 0
	
	return HAM_IGNORED
}

public player_damage(iVictim)
{
	if(!ch_pCVar_enabled || !is_player(iVictim))
		return PLUGIN_CONTINUE
	
	new iAttacker = get_user_attacker(iVictim)
	
	if(!is_player(iAttacker))
		return PLUGIN_CONTINUE
	
	g_iDamage[iAttacker][iVictim] += read_data(2)
	
	return PLUGIN_CONTINUE
}

public player_die()
{
	if(!ch_pCVar_enabled)
		return PLUGIN_CONTINUE
	
	new iVictim = read_data(2)
	new iKiller = read_data(1)
	new iHS = read_data(3)
	new szWeapon[24]
	read_data(4, szWeapon, 23)
	new vnick[32];
	get_user_name(iVictim, vnick, charsmax(vnick))
	if(!is_player(iVictim))
	{
		do_deathmsg(iKiller, iVictim, iHS, szWeapon)
		
		return PLUGIN_CONTINUE
	}
	
	g_bAlive[iVictim] = false
	
	if(!is_player(iKiller))
	{
		do_deathmsg(iKiller, iVictim, iHS, szWeapon)
		
		return PLUGIN_CONTINUE
	}
	
	new iKillerTeam = g_iTeam[iKiller]
	
	if(iKiller != iVictim && g_iTeam[iVictim] != iKillerTeam)
	{
		new iKiller2 = 0
		new iDamage2 = 0
		
		for(new p = 1; p <= g_iMaxPlayers; p++)
		{
			if(p != iKiller && g_bOnline[p] && (ch_pCVar_onlyAlive && g_bAlive[p] || !ch_pCVar_onlyAlive) && iKillerTeam == g_iTeam[p] && g_iDamage[p][iVictim] >= ch_pCVar_minDamage && g_iDamage[p][iVictim] > iDamage2)
			{
				iKiller2 = p
				iDamage2 = g_iDamage[p][iVictim]
			}
			
			g_iDamage[p][iVictim] = 0
		}
		
		if(iKiller2 > 0 && iDamage2 > ch_pCVar_minDamage)
		{
			new Float:exp
			if(cod_get_user_level(iVictim) > cod_get_user_level(iKiller2)) 
			{
				exp = float((cod_get_user_level(iVictim)-cod_get_user_level(iKiller2))+(get_cvar_num("cod_killxp")/2))
			}
			else
			{
				exp = float(get_cvar_num("cod_killxp")/2)
			}
			new xp = floatround(exp, floatround_tozero);
			if(get_user_team(iVictim) != get_user_team(iKiller2))
			{
				cod_set_user_xp(iKiller2, cod_get_user_xp(iKiller2)+xp);
			//COD_MSG_EXP_P;
			//show_dhudmessage(iKiller2, "Asysta^n+%i ", xp);
				new do_show[128]
				format(do_show, 127, "Asysta w zabiciu %s", vnick)
				cod_show_exp_reward(iKiller2, xp, do_show)
			}
			if(ch_pCVar_giveFrags)
			{
				new iFrags = get_user_frags(iKiller2)+1
				
				set_user_frags(iKiller2, iFrags);
				
				message_begin(MSG_ALL, msgID_scoreInfo)
				write_byte(iKiller2)
				write_short(iFrags)
				write_short(get_user_deaths(iKiller2))
				write_short(0)
				write_short(iKillerTeam)
				message_end()
			}
			if(ch_pCVar_giveMoney)
			{
				new iMoney = cs_get_user_money(iKiller2) + ch_pCVar_giveMoney

				cs_set_user_money(iKiller2, iMoney)
				
				if(g_bAlive[iKiller2]) // no reason to send a money message when the player has no hud :}
				{
					message_begin(MSG_ONE_UNRELIABLE, msgID_money, _, iKiller2)
					write_long(iMoney)
					write_byte(1)
					message_end()
				}
			}
			
			if(ch_pCVar_enabled == 2)
			{
				new szName1[32], szName2[32], szName3[32], szMsg[128];
				
				get_user_name(iKiller, szName1, 31)
				get_user_name(iKiller2, szName2, 31)
				get_user_name(iVictim, szName3, 31)
				
				/*DHUD_display(0, dhud, 0.03, 3, "%s Zabil %s dzieki pomocy %s", szName1, szName3, szName2)*/
				
				formatex(szMsg, 63, "%s Zabil %s dzieki pomocy %s", szName1, szName3, szName2)
				set_hudmessage(HUD_colorR, HUD_colorG, HUD_colorB, HUD_posX, HUD_posY, HUD_fx, HUD_fxTime, HUD_holdTime, HUD_fadeInTime, HUD_fadeOutTime, HUD_channel)
				show_hudmessage(0, szMsg)
			}
			else
			{
				new szName1[32], iName1Len, szName2[32], iName2Len, szNames[32], szWeaponLong[32]
				
				iName1Len = get_user_name(iKiller, szName1, 31)
				iName2Len = get_user_name(iKiller2, szName2, 31)
				
				g_szName[iKiller] = szName1
				
				if(iName1Len < 14)
				{
					formatex(szName1, iName1Len, "%s", szName1)
					formatex(szName2, 28-iName1Len, "%s", szName2)
				}
				else if(iName2Len < 14)
				{
					formatex(szName1, 28-iName2Len, "%s", szName1)
					formatex(szName2, iName2Len, "%s", szName2)
				}
				else
				{
					formatex(szName1, 13, "%s", szName1)
					formatex(szName2, 13, "%s", szName2)
				}
				
				formatex(szNames, 31, "%s + %s", szName1, szName2)
				
				set_msg_block(msgID_sayText, BLOCK_ONCE)
				set_user_info(iKiller, "name", szNames)
				
				if(g_bAmxModeExists)
				{
					g_iLastAmxMode = get_pcvar_num(pCVar_amxMode)
					
					set_pcvar_num(pCVar_amxMode, 0)
				}
				
				if(equali(szWeapon, "grenade"))
					szWeaponLong = "weapon_hegrenade"
				else
					formatex(szWeaponLong, 31, "weapon_%s", szWeapon)
				
				new args[4]
				
				args[0] = iVictim
				args[1] = iKiller
				args[2] = iHS
				args[3] = get_weaponid(szWeaponLong)
				
				set_task(0.1, "player_diePost", 0, args, 4)
			}
		}
		else if(ch_pCVar_enabled == 1)
			do_deathmsg(iKiller, iVictim, iHS, szWeapon)
	}
	else if(ch_pCVar_enabled == 1)
		do_deathmsg(iVictim, iVictim, iHS, szWeapon)
	
	return PLUGIN_CONTINUE
}

public player_diePost(arg[])
{
	new szWeapon[24]
	new iKiller = arg[1]
	
	get_weaponname(arg[3], szWeapon, 23)
	replace(szWeapon, 23, "weapon_", "")
	
	do_deathmsg(iKiller, arg[0], arg[2], szWeapon)
	
	set_msg_block(msgID_sayText, BLOCK_ONCE)
	set_user_info(iKiller, "name", g_szName[iKiller])
	
	if(g_bAmxModeExists)
		set_pcvar_num(pCVar_amxMode, g_iLastAmxMode)
	
	return PLUGIN_CONTINUE
}

public msg_deathMsg()
	return ch_pCVar_enabled == 1 ? PLUGIN_HANDLED : PLUGIN_CONTINUE

/* originally from messages_stocks.inc, but simplified */

stock do_deathmsg(iKiller, iVictim, iHS, const szWeapon[])
{
	message_begin(MSG_ALL, msgID_deathMsg)
	write_byte(iKiller)
	write_byte(iVictim)
	write_byte(iHS)
	write_string(szWeapon)
	message_end()
}

/*public StopKlatki()
{
DHUD_setFrame(dhud, 0, {255, 155, 0}, 1.0, 0.2);
DHUD_setFrame(dhud, 1, {255, 155, 0}, 0.97, 0.2);
DHUD_setFrame(dhud, 2, {255, 155, 0}, 0.94, 0.2);
DHUD_setFrame(dhud, 3, {255, 155, 0}, 0.91, 0.2);
DHUD_setFrame(dhud, 4, {255, 155, 0}, 0.88, 0.2);
DHUD_setFrame(dhud, 5, {255, 155, 0}, 0.85, 0.2);
DHUD_setFrame(dhud, 6, {255, 155, 0}, 0.82, 0.2);
DHUD_setFrame(dhud, 7, {255, 155, 0}, 0.79, 0.2);
DHUD_setFrame(dhud, 8, {255, 155, 0}, 0.76, 0.2);
DHUD_setFrame(dhud, 9, {255, 155, 0}, 0.73, 0.2);
DHUD_setFrame(dhud, 10, {255, 155, 0}, 0.7, 0.2);
DHUD_setFrame(dhud, 11, {255, 155, 0}, 0.67, 0.2);
DHUD_setFrame(dhud, 12, {255, 155, 0}, 0.64, 0.2);
DHUD_setFrame(dhud, 13, {255, 155, 0}, 0.61, 0.2, 50);
//DHUD_applyFilter(dhud, "SetPosition", 13, 63, D_ZERO, D_ZERO, 0.61, 0.2);
DHUD_setFrame(dhud, 64, {255, 175, 30}, 0.59, 0.2);
DHUD_setFrame(dhud, 65, {255, 195, 50}, 0.54, 0.2);
DHUD_setFrame(dhud, 66, {255, 215, 70}, 0.49, 0.2);
DHUD_setFrame(dhud, 67, {255, 235, 90}, 0.44, 0.2);
DHUD_setFrame(dhud, 68, {255, 255, 110}, 0.39, 0.2);
DHUD_setFrame(dhud, 69, {255, 255, 135}, 0.34, 0.2);
DHUD_setFrame(dhud, 70, {255, 255, 155}, 0.29, 0.2);
DHUD_setFrame(dhud, 71, {255, 255, 175}, 0.24, 0.2);
DHUD_setFrame(dhud, 72, {255, 255, 195}, 0.19, 0.2);
DHUD_setFrame(dhud, 73, {255, 255, 215}, 0.14, 0.2);
DHUD_setFrame(dhud, 74, {255, 255, 235}, 0.09, 0.2);
DHUD_setFrame(dhud, 75, {255, 255, 255}, 0.04, 0.2);
DHUD_setFrame(dhud, 76, {255, 255, 255}, -0.02, 0.2);
DHUD_setFrame(dhud, 77, {255, 255, 255}, -0.07, 0.2);
DHUD_setFrame(dhud, 78, {255, 255, 255}, -0.12, 0.2);
DHUD_setFrame(dhud, 79, {255, 255, 255}, -0.17, 0.2);
DHUD_setFrame(dhud, 80, {255, 255, 255}, -0.22, 0.2);
DHUD_setFrame(dhud, 81, {255, 255, 255}, -0.27, 0.2);
DHUD_setFrame(dhud, 82, {255, 255, 255}, -0.32, 0.2);
DHUD_setFrame(dhud, 83, {255, 255, 255}, -0.37, 0.2);
DHUD_setFrame(dhud, 84, {255, 255, 255}, -0.42, 0.2);
DHUD_setFrame(dhud, 85, {255, 255, 255}, -0.47, 0.2);
DHUD_setFrame(dhud, 86, {255, 255, 255}, -0.52, 0.2);
DHUD_setFrame(dhud, 87, {255, 255, 255}, -0.57, 0.2);
DHUD_setFrame(dhud, 88, {255, 255, 255}, -0.62, 0.2);
DHUD_setFrame(dhud, 89, {255, 255, 255}, -0.7, 0.2);
}*/
