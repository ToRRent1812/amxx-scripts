#include <amxmodx>
#include <cstrike>
#include <hamsandwich>
//#include <acg>

new const PLUGIN_NAME[] = "Team List"
new const PLUGIN_VERSION[] = "0.4.0"
new const PLUGIN_AUTHOR[] = "jas0n"

// hud color CT (R, G, B)
#define COLOR_CT			0, 100, 255		// blue
#define COLOR_T				255, 30, 0		// red
#define COLOR				255, 255, 255	// white

// hud position
#define X_POS				0.07
#define Y_POS				0.20

// hud message update interval
#define UPDATE_INTERVAL		0.7				// in seconds

#define HUD_CT				COLOR_CT, X_POS,Y_POS,0,0.0,UPDATE_INTERVAL+0.1,0.0,0.0,3
#define HUD_T				COLOR_T,X_POS+0.58,Y_POS,0,0.0,UPDATE_INTERVAL+0.1,0.0,0.0,4

#define MAX_PLAYERS 		20
#define NUMBER_OF_ITEMS		30
#define TASK_ID				26145

#define MAX_NAME_LENGTH		31
#define MAX_STR_LENGTH		127
#define MAX_HUD_SIZE		600

// Uncomment below if you want /speclist showing up on chat
//#define ECHOCMD

// cvar name
new const CVAR_NAME_TEAMLIST[] = "amx_teamlist"

//commands name
new const CMD_SAY[] = "say /teamlist"
new const CMD_SAY_TEAM[] = "say_team /teamlist"

// message teamplates
new const MSG_OFF[] = "[AMXX] You will no longer see teams list"
new const MSG_ON[] = "[AMXX] You will now see teams list"
new const HEADER_CT[] = "[CT] Zywi Gracze:^n"
new const HEADER_T[] = "[T] Zywi Gracze:^n"
new const STR_FORMAT[] = "[ %s ] %d HP %d AP %s^n"
//new const MSG_INFO[] = "Time Left: %d:%02d^nTeam Score: %d - %d"

new hudCT[MAX_HUD_SIZE + 1]
new hudT[MAX_HUD_SIZE + 1]
new hud[MAX_HUD_SIZE + 1]
new name[MAX_NAME_LENGTH + 1]
new str[MAX_STR_LENGTH + 1]

new gCvarOn, pCvarOn
new bool:gOnOff[MAX_PLAYERS + 1] = true
new gMaxPlayers
//new gTeamScore[2]

new gSyncMessageCT
new gSyncMessageT
//new gSyncMessage

//new gRoundStartedTime
//new gBombPlantedTime
//new gRoundTime, pRoundTime
//new gC4Timer, pC4Timer
//new bool:bIsBombPlanted = false

new const gWeaponNamesTable[NUMBER_OF_ITEMS + 1][] = {
	"",					// 0 First should be empty
	"p228",
	"",
	"scout",
	"hegrenade",
	"xm1014",
	"c4",				// 6 C4 CSW_C4
	"mac10",
	"aug",
	"smokegrenade",
	"elite",
	"fiveseven",		// = "models/w_fiveseven.mdl"
	"ump45",
	"sg550",
	"galil",			// 14
	"famas",			// 15
	"usp",
	"glock18",
	"awp",
	"mp5navy",
	"m249",
	"m3",
	"m4a1",
	"tmp",
	"g3sg1",
	"flashbang",
	"deagle",
	"sg552",
	"ak47",
	"knife",			// 29 knife CSW_KNIFE
	"p90"				// 30 p90 CSW_P90
}

new bool: zaczynamy[MAX_PLAYERS+1] = false
public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)
	
	register_clcmd(CMD_SAY, "team_list_cmd", -1)
	register_clcmd(CMD_SAY_TEAM, "team_list_cmd", -1)
	
	gCvarOn = register_cvar(CVAR_NAME_TEAMLIST, "1")
		
	//register_event("TeamScore", "team_score", "ab")
	
	register_logevent("round_start_event", 2, "1=Round_Start")
	RegisterHam(Ham_Spawn, "player", "Spawn", 1);
	register_event( "DeathMsg", "PlayerKilled", "a" );
	//register_logevent("bomb_planted_false", 2, "1=Round_End")
	//register_logevent("bomb_planted_false", 2, "1&Restart_Round_")

	//register_logevent("bomb_planted_true", 3, "2=Planted_The_Bomb")
	//register_logevent("bomb_planted_false", 3, "2=Defused_The_Bomb")
	//register_logevent("bomb_planted_false", 6, "3=Target_Bombed")	
	
	//gRoundTime = get_cvar_pointer("mp_roundtime")
	//gC4Timer = get_cvar_pointer("mp_c4timer")
	
	gSyncMessageCT = CreateHudSyncObj()
	gSyncMessageT = CreateHudSyncObj()
	//gSyncMessage = CreateHudSyncObj()
}

public plugin_cfg()
{ 
	pCvarOn = get_pcvar_num(gCvarOn)
	gMaxPlayers = get_maxplayers()
	//pRoundTime = floatround(floatmul(get_pcvar_float(gRoundTime), 60.0)) - 1
	//pC4Timer = get_pcvar_num(gC4Timer)
}

public client_putinserver(id)
{
	gOnOff[id] = true
}

public round_start_event()
{
	//gRoundStartedTime = get_systime()
	set_task(UPDATE_INTERVAL, "team_list_format", TASK_ID, _, _, "b", _)
}

public PlayerKilled()
{
	new vic = read_data(2);
	if(is_user_connected(vic))
		set_task(4.0, "zamieniamy", vic)
}

public zamieniamy(id)
{
	zaczynamy[id] = true;
}

public Spawn(id)
{
	zaczynamy[id] = false;
}
/*public bomb_planted_true()
{
	bIsBombPlanted = true
	gBombPlantedTime = get_systime()
}
 
public bomb_planted_false()
{
	remove_task(TASK_ID)
	if(bIsBombPlanted)
	{
		bIsBombPlanted = false
	}
}

get_remaining_seconds()
{
	static iSecondsLeft
	
	switch (bIsBombPlanted)
	{
		case false:	iSecondsLeft = pRoundTime - (get_systime() - gRoundStartedTime)
		case true:	iSecondsLeft = pC4Timer - (get_systime() - gBombPlantedTime)
	}
	
	return iSecondsLeft
}*/

// This is a function originally written by Johnny got his gun
// Im taking no credit whatsoever FOR THIS FUNCTION ONLY:
/*public team_score(id)
{
	static team[2]
	
	read_data(1, team, 1)
	gTeamScore[(team[0]=='C')? 0 : 1] = read_data(2)
	
	return PLUGIN_CONTINUE 
}
// End the Credit :D

public client_spawn (id)
{
	team_score(id)
}*/

public team_list_cmd(id)
{
	switch (gOnOff[id])
	{
		case true:
		{
			client_print(id, print_chat, MSG_OFF)
			gOnOff[id] = false
		}
		case false:
		{
			client_print(id, print_chat, MSG_ON)
			gOnOff[id] = true
		}
	}

	#if defined ECHOCMD
	return PLUGIN_CONTINUE
	#else
	return PLUGIN_HANDLED
	#endif
}

public team_list_format()
{
	if (pCvarOn != 1)
		return PLUGIN_HANDLED
	
	static iPlayers[32], iNum
	
	get_players(iPlayers, iNum, "ah")
	
	if (!iNum)
		return PLUGIN_HANDLED
	
	static szHudCT = MAX_HUD_SIZE
	static szHudT = MAX_HUD_SIZE
	static iPlayer
	static iWeapon
	static Health
	static Armor
	static gTeam
	//new ScoreCT = gTeamScore[0]
	//new ScoreT = gTeamScore[1]
	new n, m
	
	hudCT[0] = '^0'
	hudT[0] = '^0'
	hud[0] = '^0'
	name[0] = '^0'
	str[0] = '^0'
	
	//formatex(hud, MAX_HUD_SIZE, MSG_INFO, get_remaining_seconds()/60, get_remaining_seconds()%60, ScoreCT, ScoreT)
	
	n += copy(hudCT[n], szHudCT-n, HEADER_CT)
	m += copy(hudT[m], szHudT-m, HEADER_T)
	
	for (--iNum; iNum >= 0; iNum--)
	{
		iPlayer = iPlayers[iNum]
		get_user_name(iPlayer, name, MAX_NAME_LENGTH)
		Health = get_user_health(iPlayer)
		Armor = get_user_armor(iPlayer)
		iWeapon = get_user_weapon(iPlayer)
		gTeam = get_user_team(iPlayer)
		
		formatex(str, MAX_STR_LENGTH, STR_FORMAT, name, Health, Armor, gWeaponNamesTable[iWeapon])
		
		switch(gTeam)
		{
			case CS_TEAM_CT: n += copy(hudCT[n], szHudCT-n, str)
			case CS_TEAM_T: m += copy(hudT[m], szHudT-m, str)
		}
	}
	team_list_show()
	
	return PLUGIN_CONTINUE
}

team_list_show()
{
	for (new i=0; i < gMaxPlayers; i++)
	{
		if (is_user_connected(i) && gOnOff[i]) 
		{
			if(!is_user_alive(i) && zaczynamy[i])
			{
				set_hudmessage(HUD_CT)
				ShowSyncHudMsg(i,gSyncMessageCT,hudCT)
				//acg_drawtext(i, hudCT
				set_hudmessage(HUD_T)
				ShowSyncHudMsg(i,gSyncMessageT,hudT)
			}
			if (is_user_hltv(i) || cs_get_user_team(i) == CS_TEAM_SPECTATOR )
			{
				set_hudmessage(HUD_CT)
				ShowSyncHudMsg(i,gSyncMessageCT,hudCT)
				//acg_drawtext(i, hudCT
				set_hudmessage(HUD_T)
				ShowSyncHudMsg(i,gSyncMessageT,hudT)
			}
		}
	}
}
