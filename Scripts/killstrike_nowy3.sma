#include <amxmodx>
#include <dhudmessage>
#include <hamsandwich>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <cstrike>
#include <xs>
#include <torreinc>
//#include <achievements>
#include <acg>

#define PLUGIN "KillStreak [with ACG]"
#define VERSION "1.5a"
#define AUTHOR "cypis (=ToRRent= edit)"

#define DMG_BULLET (1<<1)
#define MAX_DIST 8192.0
#define MAX 20

//#define fm_entity_set_origin2(%1,%2) engfunc(EngFunc_SetOrigin, %1, %2)
//#define FindAliveEnemy(%1,%2) ((1 <= %1 <= 32) && is_user_alive(%1) && get_user_team(%1) != get_user_team(%2))

/*static const Float:g_fDamageMultiplier[8] = {
	0.8, 	//HIT_GENERIC
	1.45,	//HIT_HEAD
	0.80,	//HIT_CHEST
	0.95,	//HIT_STOMACH
	0.5,	//HIT_STOMACH
	0.5,	//HIT_RIGHTARM
	0.35,	//HIT_LEFTLEG
	0.35	//HIT_RIGHTLEG
};

new Float:g_fLastTime[33];
new bool:g_bUsing[33];
new user_sentry[33];

new g_sSprBlood, g_sSprBloodspray, g_sSprESP;
new cvarRemoteDamage;

*/

new const maxAmmo[31]={0,52,0,90,1,32,1,100,90,1,120,100,100,90,90,90,100,120,30,120,200,32,90,120,90,2,35,90,90,0,100};

new sprite_blast, cache_trail;

new licznik_zabic[MAX+1], bool:radar[2], bool:nalot[MAX+1], bool:predator[MAX+1], bool:nuke[MAX+1], bool:emp[MAX+1], bool:cuav[MAX+1], bool:uav[MAX+1], bool:advuav[MAX+1], /*bool:remotesentry[MAX+1], */bool:airtrap[MAX+1], bool:pack[MAX+1], bool:sentrys[MAX+1],  bool:airdrop[MAX+1];
new user_controll[MAX+1], emp_czasowe, bool:nuke_koniec, bool:sentry_build[MAX+1], bool:advuav_active[2];	

new PobraneOrigin[3], ZmienKilla[2];

new /*msgHostagePos, msgHostageK, */msgHideWeapon, msgScreenShake;

new Odliczanie[MAX + 1], Uzyte_Nuke = 0;
//new uch_budowniczy, uch_pierwszy, uch_radar, uch_zbieracz;

new g_entity_channel = 0, g_pack_count = 0, /*g_icon_delay[MAX+1], */pack_channel[20];

public plugin_init() {
	
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_think("sentry","SentryThink");
	
	register_touch("predator", "*", "touchedpredator");
	register_touch("bomb", "*", "touchedrocket");

	register_forward(FM_ClientKill, "cmdKill");
	
	RegisterHam(Ham_TakeDamage, "func_breakable", "TakeDamage");
	RegisterHam(Ham_Killed, "player", "SmiercGracza", 1);
	RegisterHam(Ham_Spawn, "player", "Spawn", 1);
	
	register_forward(FM_CmdStart, "fwCmdStart");
	register_forward(FM_UpdateClientData, "UpdateClientData_Post", 1);
	register_forward(FM_AddToFullPack, "AddToFullPack", 1);
	
	register_event("CurWeapon","CurWeapon","be", "1=1");
	register_event("HLTV", "NowaRunda", "a", "1=0", "2=0");
	register_message(get_user_msgid("DeathMsg"), "message_DeathMsg");
	
	register_cvar("ks_hpsentry", "600.0");
	/*register_cvar("remote_damage", "20");
	cvarRemoteDamage = get_cvar_num("remote_damage");*/
	//register_cvar("ks_icon_size", "4")
	//register_cvar("ks_icon_light", "35")
	
	//uch_budowniczy = ach_add("Budowniczy", "Wybuduj 50 Dzialek Strazniczych", 50);
	//uch_pierwszy = ach_add("Pierwszy Raz", "Zdobadz Ostatni KillStreak (Atomowka)", 1);
	//uch_radar = ach_add("Radar-owiec", "Wezwij 150 razy UAV", 150);
	//uch_zbieracz = ach_add("Zbieracz", "Zbierz 50 paczek z wyposazeniem", 50);
	
	register_clcmd("say /ks", "uzyj_nagrody");
	//msgHostagePos = get_user_msgid("HostagePos");
	//msgHostageK = get_user_msgid("HostageK");
	msgHideWeapon = get_user_msgid("HideWeapon");
	msgScreenShake = get_user_msgid("ScreenShake");
	//msgScreenFade = get_user_msgid("ScreenFade");

	//set_task(1.5,"radar_scan", .flags="b");
}

public plugin_precache()
{
	sprite_blast = precache_model("sprites/dexplo.spr");
	cache_trail = precache_model("sprites/smoke.spr");
	
	precache_model("models/p_hegrenade.mdl");
	precache_model("models/cod_carepackage.mdl");
	precache_model("models/cod_carepackage2.mdl");
	precache_model("models/cod_plane.mdl");
	precache_model("models/cod_predator.mdl");
	precache_model("models/sentrygun_mw2.mdl");
	
	precache_sound("mw/ks_get_moab.wav");
	precache_sound("mw/ks_enemy_moab.wav");
	precache_sound("mw/ks_use_moab.wav");
	/*precache_sound("mw/nuke_friend.wav");
	precache_sound("mw/nuke_enemy.wav");
	precache_sound("mw/nuke_give.wav");*/
	
	precache_sound("mw/jet_fly1.wav");
	//precache_sound("mw/jet_fly2.wav");
	
	precache_sound("mw/ks_get_emp_01.wav")
	precache_sound("mw/ks_get_emp_02.wav")
	precache_sound("mw/ks_use_emp.wav")
	precache_sound("mw/emp_enemy.wav");
	/*precache_sound("mw/emp_friend.wav");
	precache_sound("mw/emp_give.wav");*/
	precache_sound("mw/emp_effect.wav");
	
	precache_sound("TM_CodMod/Tick.mp3");
	precache_sound("TM_CodMod/Tick1.mp3");
	precache_sound("TM_CodMod/Tick2.mp3");
	precache_sound("TM_CodMod/Tick3.mp3");
	precache_sound("TM_CodMod/Tick4.mp3");
	
	precache_sound("mw/ks_get_jamuav_01.wav");
	precache_sound("mw/ks_get_jamuav_02.wav");
	precache_sound("mw/ks_enemy_jamuav_01.wav");
	precache_sound("mw/ks_enemy_jamuav_02.wav");
	precache_sound("mw/ks_use_jamuav_01.wav");
	precache_sound("mw/ks_use_jamuav_02.wav");
	/*precache_sound("mw/counter_friend.wav");
	precache_sound("mw/counter_enemy.wav");
	precache_sound("mw/counter_give.wav");*/
	
	precache_sound("mw/ks_get_airstrike.wav");
	precache_sound("mw/ks_use_airstrike.wav");
	precache_sound("mw/ks_enemy_airstrike.wav");
	/*precache_sound("mw/air_friend.wav");
	precache_sound("mw/air_enemy.wav");
	precache_sound("mw/air_give.wav");*/
	
	precache_sound("mw/ks_get_predator_01.wav");
	precache_sound("mw/ks_get_predator_02.wav");
	precache_sound("mw/ks_use_predator.wav");
	precache_sound("mw/ks_enemy_predator.wav");
	/*precache_sound("mw/predator_friend.wav");
	precache_sound("mw/predator_enemy.wav");
	precache_sound("mw/predator_give.wav");*/
	
	precache_sound("mw/ks_get_uav_01.wav");
	precache_sound("mw/ks_get_uav_02.wav");
	precache_sound("mw/ks_get_uav_03.wav");
	precache_sound("mw/ks_use_uav.wav");
	precache_sound("mw/ks_enemy_uav_01.wav");
	precache_sound("mw/ks_enemy_uav_02.wav");
	precache_sound("mw/ks_enemy_uav_03.wav");
	/*precache_sound("mw/uav_friend.wav");
	precache_sound("mw/uav_enemy.wav");
	precache_sound("mw/uav_give.wav");*/
	
	precache_sound("mw/ks_get_carepackage_01.wav");
	precache_sound("mw/ks_get_carepackage_02.wav");
	precache_sound("mw/ks_use_carepackage.wav");
	precache_sound("mw/ks_enemy_carepackage.wav");
	/*precache_sound("mw/carepackage_friend.wav");
	precache_sound("mw/carepackage_enemy.wav");
	precache_sound("mw/carepackage_give.wav");*/
	
	precache_sound("mw/firemw.wav");
	precache_sound("mw/plant.wav");
	precache_sound("mw/sentrygun_starts.wav");
	precache_sound("mw/sentrygun_stops.wav");
	precache_sound("mw/sentrygun_gone.wav");
	precache_sound("mw/ks_get_sentrygun.wav");
	precache_sound("mw/ks_use_sentrygun.wav");
	precache_sound("mw/ks_enemy_sentrygun.wav");
	/*precache_sound("mw/sentrygun_friend.wav");
	precache_sound("mw/sentrygun_enemy.wav");
	precache_sound("mw/sentrygun_give.wav");*/
	
	precache_sound("mw/ks_get_airdrop_01.wav");
	precache_sound("mw/ks_get_airdrop_02.wav");
	precache_sound("mw/ks_use_airdrop.wav");
	precache_sound("mw/ks_enemy_airdrop.wav");
	/*precache_sound("mw/emergairdrop_friend.wav");
	precache_sound("mw/emergairdrop_enemy.wav");
	precache_sound("mw/emergairdrop_give.wav");*/
	
	precache_sound("mw/ks_get_airtrap.wav");
	precache_sound("mw/ks_use_airtrap.wav");
	
	precache_sound("mw/ks_get_advuav.wav");
	precache_sound("mw/ks_use_advuav.wav");
	precache_sound("mw/ks_enemy_advuav.wav");
	
	precache_model("models/computergibs.mdl");
	//g_supplybox_icon_id = engfunc(EngFunc_PrecacheModel, supplybox_icon_spr)
	precache_model("sprites/icon_supplybox_mini.spr")
}

public uzyj_nagrody(id)
{
	new menu = menu_create("Nagrody KillStreak:", "Nagrody_Handler");
	new cb = menu_makecallback("Nagrody_Callback");
	menu_additem(menu, "UAV \y[3x]", _, _, cb);
	menu_additem(menu, "Paczka z wyposazeniem \y[5x]", _, _, cb);
	menu_additem(menu, "Kontr-UAV \y[5x]", _, _, cb);
	menu_additem(menu, "Dzialko Straznicze \y[7x]", _, _, cb);
	menu_additem(menu, "Nalot Precyzyjny \y[8x]", _, _, cb);
	menu_additem(menu, "Rakieta Predator \y[10x]", _, _, cb);
	//menu_additem(menu, "Dzialko Kontrolowane \y[10x]", _, _, cb);
	menu_additem(menu, "Paczka Pulapka \y[13x]", _, _, cb);
	menu_additem(menu, "Zrzut Pomocniczy \y[13x]", _, _, cb);
	menu_additem(menu, "EMP \y[16x]", _, _, cb);
	menu_additem(menu, "Zaawansowane UAV \y[16x]", _, _, cb);
	menu_additem(menu, "Atomowka \y[20x]", _, _, cb);
	menu_setprop(menu, MPROP_PERPAGE, 7);
	menu_setprop(menu, MPROP_BACKNAME, "Poprzednia strona");
	menu_setprop(menu, MPROP_NEXTNAME, "Nastepna strona");
	menu_setprop(menu, MPROP_EXITNAME, "Wyjdz^n\yKillStreak v1.5 by \rCypis (=ToRRent Edit)");
	menu_display(id, menu)
	//ColorChat(id, "!g[KillStrike] !nTwoj killstrike aktualnie wynosi x%i", licznik_zabic[id]);
	
	return PLUGIN_HANDLED;
}

public Nagrody_Callback(id, menu, item)
{
	if(!uav[id] && item == 0 || !pack[id] && item == 1 || !cuav[id] && item == 2 || !sentrys[id] && item == 3 || !nalot[id] && item == 4 || !predator[id] && item == 5 /*|| !remotesentry[id] && item == 6  */ || !airtrap[id] && item == 6 || !airdrop[id] && item == 7 || !emp[id] && item == 8 || !advuav[id] && item == 9|| !nuke[id] && item == 10)
		return ITEM_DISABLED;
	
	return ITEM_ENABLED;
}
	
public Nagrody_Handler(id, menu, item)
{
	if(!is_user_alive(id))
		return PLUGIN_HANDLED;
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	if(!emp_czasowe || (emp_czasowe && get_user_team(id) == get_user_team(emp_czasowe)))
	{
		//COD_MSG_EXP_P;
		switch(item)
		{
			case 0:
			{
				cod_set_user_xp(id, cod_get_user_xp(id)+15);
				cod_show_exp_reward(id, 15, "Aktywacja UAV")
				//show_dhudmessage(id, "+15");
				CreateUVA(id);
			}
			case 1:
			{
				if(g_pack_count <= 10)
					CreatePack(id);
				else
					client_print(id, print_center, "Przekroczono limit paczek lezacych na ziemi !")
			}
			case 2:
			{
				cod_set_user_xp(id, cod_get_user_xp(id)+25);
				cod_show_exp_reward(id, 25, "Aktywacja Kontr-UAV")
				//show_dhudmessage(id, "+25");
				CreateCUVA(id);
			} 
			case 3:
			{
				if(!sentry_build[id])
					CreateSentry(id);
				else
					client_print(id, print_center, "Mozesz postawic tylko jedno dzialko na raz !");
			} 
			case 4:
			{
				cod_set_user_xp(id, cod_get_user_xp(id)+40);
				cod_show_exp_reward(id, 40, "Uzycie Nalotu Precyzyjnego")
				//show_dhudmessage(id, "+40");
				CreateNalot(id);
			} 
			case 5:
			{
				cod_set_user_xp(id, cod_get_user_xp(id)+50);
				cod_show_exp_reward(id, 50, "Uzycie Rakiety Predator")
				//show_dhudmessage(id, "+50");
				CreatePredator(id);
			} 
			/*case 6:
			{
				cod_set_user_xp(id, cod_get_user_xp(id)+50);
				show_dhudmessage(id, "+50");
				CreateRemoteSentry(id);
			}*/
			case 6:
			{
				if(g_pack_count <= 10)
					CreateAirTrap(id);
				else
					client_print(id, print_center, "Przekroczono limit paczek lezacych na ziemi !")	
			}
			case 7:
			{
				if(g_pack_count <= 7)
					CreateAirDrop(id);
				else
					client_print(id, print_center, "Przekroczono limit paczek lezacych na ziemi !")	
			}
			case 8:
			{
				cod_set_user_xp(id, cod_get_user_xp(id)+80);
				cod_show_exp_reward(id, 80, "Aktywacja EMP")
				//show_dhudmessage(id, "+80");
				CreateEmp(id);
			} 
			case 9:
			{
				cod_set_user_xp(id, cod_get_user_xp(id)+80);
				//show_dhudmessage(id, "+80");
				cod_show_exp_reward(id, 80, "Aktywacja Zaawansowanego UAV")
				CreateAdvancedUAV(id);
			}
			case 10:
			{
				if(++Uzyte_Nuke <= 1 || nuke_koniec)
				{
					cod_set_user_xp(id, cod_get_user_xp(id)+100);
					cod_show_exp_reward(id, 100, "Aktywacja Atomowki MOAB")
					//show_dhudmessage(id, "+100");
					CreateNuke(id);
				}
				else
					client_print(id, print_center, "Atomowke moze wezwac tylko jeden gracz na mapie !");
				
			}
		}
	}
	else client_print(id, print_center, "Nie mozna uzywac nagrod kiedy uruchomiony jest EMP");
	return PLUGIN_HANDLED;
}
public client_disconnect(id)
{
	new ent = -1
	while((ent = find_ent_by_class(ent, "sentry")))
	{
		if(pev(ent, pev_iuser2) == id)
			fm_remove_entity(ent);
	}
	/*while((ent = fm_find_ent_by_class(ent, "remote_sentry")))
	{
		if(pev(ent, pev_iuser2) == id)
			fm_remove_entity(ent);
	}
	user_sentry[id] = 0;*/
	return PLUGIN_CONTINUE;
}

public NowaRunda()
{
	new num, players[32];
	get_players(players, num, "gh");
	for(new i = 0; i < num; i++)
	{
		if(task_exists(players[i]+997))
			remove_task(players[i]+997);
	}
	
	remove_entity_name("predator");
	remove_entity_name("bomb");
	//remove_entity_name("sentry");
}

public client_putinserver(id){
	licznik_zabic[id] = 0;
	user_controll[id] = 0;
	
	nalot[id] = false;
	predator[id] = false;
	nuke[id] = false;
	cuav[id] = false;
	uav[id] = false;
	emp[id] = false;
	pack[id] = false;
	sentrys[id] = false;
	sentry_build[id] = false;
	airdrop[id] = false;
	airtrap[id] = false;
	advuav[id] = false;
	//remotesentry[id] = false;
	
	if(is_user_connected(id) && acg_userstatus(id) && !is_user_bot(id))
	{
		set_task(2.0, "Licznik", id)
	}
}

public SmiercGracza(id, attacker)
{	
	if(is_user_alive(attacker) && is_user_connected(attacker))
	{
		if(get_user_team(attacker) != get_user_team(id) && !nuke_koniec)
		{
			licznik_zabic[attacker]++;
			//set_hudmessage(255, 255, 255, -1.0, 0.02, 2, 0.4, 3.5, 0.05, 0.3, -1)
			//show_hudmessage(attacker, "Twoj Killstrike wynosi x%i", licznik_zabic[attacker]);
			if(acg_userstatus(attacker) && !is_user_bot(attacker))
				Licznik(attacker)
			if(acg_userstatus(id) && !is_user_bot(id) && is_user_connected(id))	
				Licznik(id)
			set_hudmessage(120, 245, 120, -1.0, 0.20, 0, 2.0, 4.0, 0.2, 0.3, -1)
			switch(licznik_zabic[attacker])
			{
				case 3:
				{
					if(uav[attacker] == false)
					{
						uav[attacker] = true;
						show_hudmessage(attacker, "Dostales UAV za killstreak x%i !", licznik_zabic[attacker]);
						ColorChat(attacker, "!g[KillStrike] !nZeby widziec wrogow na radarze, say /ks");
						switch(random_num(0, 2))
						{
							case 0: client_cmd(attacker, "spk sound/mw/ks_get_uav_01.wav")
							case 1: client_cmd(attacker, "spk sound/mw/ks_get_uav_02.wav")
							case 2: client_cmd(attacker, "spk sound/mw/ks_get_uav_03.wav")
						}
						
					}	
				}
				case 5:
				{
					if(cuav[attacker] == false && pack[attacker] == false)
					{
						switch(random_num(0,1))
						{
							case 0:
							{
								cuav[attacker] = true;
								show_hudmessage(attacker, "Dostales Kontr-UAV za killstreak x%i !", licznik_zabic[attacker]);
								ColorChat(attacker, "!g[KillStrike] !nZeby wylaczyc wrogom UAV, say /ks");
								switch(random_num(0, 1))
								{
									case 0: client_cmd(attacker, "spk sound/mw/ks_get_jamuav_01.wav")
									case 1: client_cmd(attacker, "spk sound/mw/ks_get_jamuav_02.wav")
								}
							}
							case 1:
							{
								pack[attacker] = true;
								show_hudmessage(attacker, "Dostales Paczke z wyposazeniem za killstreak x%i !", licznik_zabic[attacker]);
								ColorChat(attacker, "!g[KillStrike] !nBy wykonac zrzut paczki, say /ks i naceluj gdzie ma spasc");
								switch(random_num(0, 1))
								{
									case 0: client_cmd(attacker, "spk sound/mw/ks_get_carepackage_01.wav")
									case 1: client_cmd(attacker, "spk sound/mw/ks_get_carepackage_02.wav")
								}
							}
						}
					}
					else if(cuav[attacker] == false && pack[attacker] == true)
					{
						cuav[attacker] = true;
						show_hudmessage(attacker, "Dostales Kontr-UAV za killstreak x%i !", licznik_zabic[attacker]);
						ColorChat(attacker, "!g[KillStrike] !nZeby wylaczyc wrogom UAV, say /ks");
						switch(random_num(0, 1))
						{
							case 0: client_cmd(attacker, "spk sound/mw/ks_get_jamuav_01.wav")
							case 1: client_cmd(attacker, "spk sound/mw/ks_get_jamuav_02.wav")
						}
					}
					else if(cuav[attacker] == true && pack[attacker] == false)
					{
						pack[attacker] = true;
						show_hudmessage(attacker, "Dostales Paczke z wyposazeniem za killstreak x%i !", licznik_zabic[attacker]);
						ColorChat(attacker, "!g[KillStrike] !nBy wykonac zrzut paczki, say /ks i naceluj gdzie ma spasc");
						switch(random_num(0, 1))
						{
							case 0: client_cmd(attacker, "spk sound/mw/ks_get_carepackage_01.wav")
							case 1: client_cmd(attacker, "spk sound/mw/ks_get_carepackage_02.wav")
						}
					}
				}
				case 7:
				{
					if(sentrys[attacker] == false)
					{
						sentrys[attacker] = true;
						show_hudmessage(attacker, "Dostales Dzialko straznicze za killstreak x%i !", licznik_zabic[attacker]);
						ColorChat(attacker, "!g[KillStrike] !nAby skorzystac z dzialka, say /ks");
						client_cmd(attacker, "spk sound/mw/ks_get_sentrygun.wav");
					}
				}
				case 8:
				{
					if(nalot[attacker] == false)
					{
						nalot[attacker] = true;
						show_hudmessage(attacker, "Dostales Nalot Precyzyjny za killstreak x%i !", licznik_zabic[attacker]);
						ColorChat(attacker, "!g[KillStrike] !nSay /ks i Naceluj, gdzie ma byc wykonany zrzut bomb");
						client_cmd(attacker, "spk sound/mw/ks_get_airstrike.wav");
					}
				}
				/*case 10:
				{
					if(predator[attacker] == false && remotesentry[attacker] == false)
					{
						switch(random_num(0,1))
						{
							case 0:
							{
								predator[attacker] = true;
								show_hudmessage(attacker, "Dostales Rakiete Predator za killstreak x%i !", licznik_zabic[attacker]);
								ColorChat(attacker, "!g[KillStrike] !nZeby odpalic predatora, say /ks");
								switch(random_num(0, 1))
								{
									case 0: client_cmd(attacker, "spk sound/mw/ks_get_predator_01.wav")
									case 1: client_cmd(attacker, "spk sound/mw/ks_get_predator_02.wav")
								}
							}
							case 1:
							{
								remotesentry[attacker] = true;
								show_hudmessage(attacker, "Dostales Dzialko Kontrolowane za killstreak x%i !", licznik_zabic[attacker]);
								ColorChat(attacker, "!g[KillStrike] !nAby skorzystac z dzialka, say /ks, nastepnie wcisnij use aby przejsc na zdalne sterowanie");
								client_cmd(attacker, "spk sound/mw/ks_get_remotesentry.wav");
							}
						}
					}
					else if(predator[attacker] == false && remotesentry[attacker] == true)
					{
						predator[attacker] = true;
						show_hudmessage(attacker, "Dostales Rakiete Predator za killstreak x%i !", licznik_zabic[attacker]);
						ColorChat(attacker, "!g[KillStrike] !nZeby odpalic predatora, say /ks");
						switch(random_num(0, 1))
						{
							case 0: client_cmd(attacker, "spk sound/mw/ks_get_predator_01.wav")
							case 1: client_cmd(attacker, "spk sound/mw/ks_get_predator_02.wav")
						}
					}
					else if(predator[attacker] == true && remotesentry[attacker] == false)
					{
						remotesentry[attacker] = true;
						show_hudmessage(attacker, "Dostales Dzialko Kontrolowane za killstreak x%i !", licznik_zabic[attacker]);
						ColorChat(attacker, "!g[KillStrike] !nAby skorzystac z dzialka, say /ks, nastepnie wcisnij use aby przejsc na zdalne sterowanie");
						client_cmd(attacker, "spk sound/mw/ks_get_remotesentry.wav");
					}
				}*/
				case 10:
				{
					if(predator[attacker] == false)
					{
						predator[attacker] = true;
						show_hudmessage(attacker, "Dostales Rakiete Predator za killstreak x%i !", licznik_zabic[attacker]);
						ColorChat(attacker, "!g[KillStrike] !nZeby odpalic predatora, say /ks");
						switch(random_num(0, 1))
						{
							case 0: client_cmd(attacker, "spk sound/mw/ks_get_predator_01.wav")
							case 1: client_cmd(attacker, "spk sound/mw/ks_get_predator_02.wav")
						}
					}
				}
				case 13:
				{
					if(airdrop[attacker] == false && airtrap[attacker] == false)
					{
						switch(random_num(0,1))
						{
							case 0:
							{
								airdrop[attacker] = true;
								show_hudmessage(attacker, "Dostales Zrzut Pomocniczy za killstreak x%i !", licznik_zabic[attacker]);
								ColorChat(attacker, "!g[KillStrike] !nBy wykonac zrzut paczek, say /ks i naceluj gdzie maja spasc");
								switch(random_num(0, 1))
								{
									case 0: client_cmd(attacker, "spk sound/mw/ks_get_airdrop_01.wav")
									case 1: client_cmd(attacker, "spk sound/mw/ks_get_airdrop_02.wav")
								}
							}
							case 1:
							{
								airtrap[attacker] = true;
								show_hudmessage(attacker, "Dostales Paczke Pulapke za killstreak x%i !", licznik_zabic[attacker]);
								ColorChat(attacker, "!g[KillStrike] !nBy wykonac zrzut paczki, say /ks i naceluj gdzie maja spasc");
								client_cmd(attacker, "spk sound/mw/ks_get_airtrap.wav");
							}
						}
					}
					else if(airdrop[attacker] == false && airtrap[attacker] == true)
					{
						airdrop[attacker] = true;
						show_hudmessage(attacker, "Dostales Zrzut Pomocniczy za killstreak x%i !", licznik_zabic[attacker]);
						ColorChat(attacker, "!g[KillStrike] !nBy wykonac zrzut paczek, say /ks i naceluj gdzie maja spasc");
						switch(random_num(0, 1))
						{
							case 0: client_cmd(attacker, "spk sound/mw/ks_get_airdrop_01.wav")
							case 1: client_cmd(attacker, "spk sound/mw/ks_get_airdrop_02.wav")
						}
					}
					else if(airdrop[attacker] == true && airtrap[attacker] == false)
					{
						airtrap[attacker] = true;
						show_hudmessage(attacker, "Dostales Paczke Pulapke za killstreak x%i !", licznik_zabic[attacker]);
						ColorChat(attacker, "!g[KillStrike] !nBy wykonac zrzut paczki, say /ks i naceluj gdzie maja spasc");
						client_cmd(attacker, "spk sound/mw/ks_get_airtrap.wav");
					}
				}
						
				case 16:
				{
					if(emp[attacker] == false && advuav[attacker] == false)
					{
						switch(random_num(0,1))
						{
							case 0:
							{
								emp[attacker] = true;
								show_hudmessage(attacker, "Dostales EMP za killstreak x%i !", licznik_zabic[attacker]);
								ColorChat(attacker, "!g[KillStrike] !nAby uruchomic EMP, say /ks");
								switch(random_num(0, 1))
								{
									case 0: client_cmd(attacker, "spk sound/mw/ks_get_emp_01.wav")
									case 1: client_cmd(attacker, "spk sound/mw/ks_get_emp_02.wav")
								}
							}
							case 1:
							{
								advuav[attacker] = true;
								show_hudmessage(attacker, "Dostales Zaawansowane UAV za killstreak x%i !", licznik_zabic[attacker]);
								ColorChat(attacker, "!g[KillStrike] !nZeby widziec wrogow na radarze, say /ks");
								client_cmd(attacker, "spk sound/mw/ks_get_advuav.wav");
							}
						}
					}
					else if(emp[attacker] == false && advuav[attacker] == true)
					{
						emp[attacker] = true;
						show_hudmessage(attacker, "Dostales EMP za killstreak x%i !", licznik_zabic[attacker]);
						ColorChat(attacker, "!g[KillStrike] !nAby uruchomic EMP, say /ks");
						switch(random_num(0, 1))
						{
							case 0: client_cmd(attacker, "spk sound/mw/ks_get_emp_01.wav")
							case 1: client_cmd(attacker, "spk sound/mw/ks_get_emp_02.wav")
						}
					}
					else if(emp[attacker] == true && advuav[attacker] == false)
					{
						advuav[attacker] = true;
						show_hudmessage(attacker, "Dostales Zaawansowane UAV za killstreak x%i !", licznik_zabic[attacker]);
						ColorChat(attacker, "!g[KillStrike] !nZeby widziec wrogow na radarze, say /ks");
						client_cmd(attacker, "spk sound/mw/ks_get_advuav.wav");
					}
				}
				case 20:
				{
					if(nuke[attacker] == false && Uzyte_Nuke < 1)
					{
						nuke[attacker] = true;
						show_hudmessage(attacker, "Dostales Atomowke za killstreak x%i !", licznik_zabic[attacker]);
						ColorChat(attacker, "!g[KillStrike] !nAby Uzyc bomby, say /ks");
						client_cmd(attacker, "spk sound/mw/ks_get_moab.wav")
						licznik_zabic[attacker] = 0;
					}
				}
			}
		}
	}
	if(!is_user_alive(id))
	{
		licznik_zabic[id] = 0
		user_controll[id] = 0;
	}
	new ent = find_drop_pack(id, "pack")
	if(is_valid_ent(ent))
	{
		if(task_exists(2571+ent))
		{
			remove_task(2571+ent);
			set_bartime(id, 0, 0);
			
		}
	}
	new ent2 = find_drop_pack(id, "airtrap")
	if(is_valid_ent(ent2))
	{
		if(task_exists(2572+ent2))
		{
			remove_task(2572+ent2);
			set_bartime(id, 0, 0);
			
		}
	}
	return HAM_IGNORED;
}

public Licznik(id)
{
	acg_setextraammo(id, licznik_zabic[id])
	acg_setextraammotext(id, "", "d_headshot")
	acg_showextraammo(id, 1)
}

public Spawn(id)
{
	if(acg_userstatus(id) && !is_user_bot(id) && is_user_connected(id))
		Licznik(id)
}
public CreateUVA(id)
{
	//static CzasUav[2];
	
	uav[id] = false;
	new team = cs_get_user_team(id) == CS_TEAM_T? 0: 1;
	radar[team] = true;
	
	new num, players[32];
	get_players(players, num, "cgh")
	for(new a = 0; a < num; a++)
	{
		new i = players[a]	
		if(get_user_team(id) != get_user_team(i))
		{
			switch(random_num(0,2))
			{
				case 0: client_cmd(i, "spk sound/mw/ks_enemy_uav_01.wav")
				case 1: client_cmd(i, "spk sound/mw/ks_enemy_uav_02.wav")
				case 2: client_cmd(i, "spk sound/mw/ks_enemy_uav_03.wav")
			}
		}	
		else
		{
			client_cmd(i, "spk sound/mw/ks_use_uav.wav")
			
			if(is_user_connected(i) && acg_userstatus(i))
				acg_drawoverviewradar (i, 1, 1, 0, 150, 150, 255, 255, 255)
		}
	}
	print_info(id, "UAV");
	//ach_add_status(id, uch_radar, 1);
	//radar_scan();
	
	/*if(task_exists(7354+team))
	{
		new times = (CzasUav[team]-get_systime())+45;
		change_task(7354+team, float(times));
		CzasUav[team] = CzasUav[team]+times;
	}
	else
	{
		new data[1];
		data[0] = team;
		set_task(45.0, "deluav", 7354+team, data, 1);
		CzasUav[team] = get_systime()+45;
	}*/
	set_task(45.0, "deluav", id);
	return PLUGIN_CONTINUE;
}

public deluav(id)
{
	new num, players[32];
	get_players(players, num, "cgh")
	for(new a = 0; a < num; a++)
	{
		new i = players[a]
		if(get_user_team(id) == get_user_team(i))
		{
			if(is_user_connected(i) && acg_userstatus(i))
				acg_drawoverviewradar (i, 1, 0, 0, 150, 150, 255, 255, 255)
			radar[cs_get_user_team(id) == CS_TEAM_T? 1: 0] = false;
		}
	}
}

public deluadv(id)
{
	new num, players[32];
	get_players(players, num, "cgh")
	for(new a = 0; a < num; a++)
	{
		new i = players[a]
		if(get_user_team(id) == get_user_team(i))
		{
			if(is_user_connected(i) && acg_userstatus(i))
				acg_drawoverviewradar (i, 1, 0, 0, 150, 150, 255, 255, 255)
			advuav_active[cs_get_user_team(id) == CS_TEAM_T? 1: 0] = false;
		}
	}
}

/*public deluav(data[1])
{
	radar[data[0]] = false;
}
	
public radar_scan()
{
	new num, players[32];
	get_players(players, num, "gh")
	for(new i=0; i<num; i++)
	{
		new id = players[i];
		if(!is_user_alive(id) || !radar[cs_get_user_team(id) == CS_TEAM_T? 0: 1])
			continue;

		if(!emp_czasowe || (emp_czasowe && cs_get_user_team(id) == cs_get_user_team(emp_czasowe)))
			radar_continue(id);
	}
}

radar_continue(id)
{
	acg_drawoverviewradar (id, 1, 1, 0, 150, 150, 255, 255, 255)
	new num, players[32], PlayerCoords[3];
	get_players(players, num, "gh");
	for(new a=0; a<num; a++)
	{
		new i = players[a];     
		if(!is_user_alive(i) || cs_get_user_team(i) == cs_get_user_team(id)) 
			continue;
		
		get_user_origin(i, PlayerCoords);
		
		message_begin(MSG_ONE_UNRELIABLE, msgHostagePos, .player = id);
		write_byte(id);
		write_byte(i);
		write_coord(PlayerCoords[0]);
		write_coord(PlayerCoords[1]);
		write_coord(PlayerCoords[2]);
		message_end();
		
		message_begin(MSG_ONE_UNRELIABLE, msgHostageK, .player = id);
		write_byte(i);
		message_end();
	}	
}*/

//airpack
public CreatePack(id)
{
	new num, players[32];
	get_players(players, num, "cgh");
	for(new a = 0; a < num; a++)
	{
		new i = players[a];
		if(get_user_team(id) != get_user_team(i))
			client_cmd(i, "spk sound/mw/ks_enemy_carepackage.wav");
		else
			client_cmd(i, "spk sound/mw/ks_use_carepackage.wav");
	}
	print_info(id, "Paczki z wyposazeniem");
	set_bartime(id, 1, 0);
	CreatePlane(id);
	pack[id] = false
	set_task(1.0, "CarePack", id+742)
}

public CarePack(taskid)
{
	new id = (taskid - 742)
	
	PobraneOrigin[2] += 200; 
	new Float:LocVecs[3];
	IVecFVec(PobraneOrigin, LocVecs);
	new ent = create_pack(id, "pack", "models/cod_carepackage.mdl", 1, 6, LocVecs);
	entity_set_int(ent, EV_INT_iuser1, LosujNagrode());
	if(acg_userstatus(id) && is_user_connected(id) && is_user_alive(id))
	{
		acg_drawentityicon (id, "icon_supplybox_mini", 200, 200, 200, 1, 108, 180, 216, _, ent, -1.0, DRAW_ADDITIVE,entity_get_int(pack_channel[g_entity_channel], EV_INT_iuser2))
	}
}

//emergy airdrop
public CreateAirDrop(id)
{
	new num, players[32];
	get_players(players, num, "cgh");
	for(new a = 0; a < num; a++)
	{
		new i = players[a];
		if(get_user_team(id) != get_user_team(i))
			client_cmd(i, "spk sound/mw/ks_enemy_airdrop.wav");
		else
			client_cmd(i, "spk sound/mw/ks_use_airdrop.wav");
	}
	print_info(id, "Zrzutu Pomocniczego");
	set_bartime(id, 2, 0);
	CreatePlane(id);
	set_task(2.0, "CareEmpPack", id+746);
	airdrop[id] = false;
}

/*public CareEmpPack(id)
{
	id -=  746;
	new Float:LocVecs[4][3], k;
	for(new i=0; i<4; i++)
	{
		k = 0;
jeszczeraz:
		if(k > 30)
			continue;
			
		LocVecs[i][0] = PobraneOrigin[0] + random_float(-300.0,300.0);
		LocVecs[i][1] = PobraneOrigin[1] + random_float(-300.0,300.0);
		LocVecs[i][2] = PobraneOrigin[2] + 150.0;
		if(!is_hull_vacant(LocVecs[i], HULL_HUMAN))
		{
			k++;
			goto jeszczeraz;
		}
	}
	create_pack(id, "pack", "models/cod_carepackage2.mdl", 1, 6, LocVecs[0]);
	create_pack(id, "pack", "models/cod_carepackage2.mdl", 1, 6, LocVecs[1]);
	create_pack(id, "pack", "models/cod_carepackage2.mdl", 1, 6, LocVecs[2]);
	create_pack(id, "pack", "models/cod_carepackage2.mdl", 1, 6, LocVecs[3]);
	
	new num, players[32];
	get_players(players, num, "acgh");
	for(new a = 0; a < num; a++)
	{
		new i = players[a]
		if(acg_userstatus(i) && is_user_connected(i) && is_user_alive(i))
		{
			acg_drawentityicon (i, "icon_supplybox_mini", 200, 200, 200, 1, 108, 180, 216, LocVecs[0], -1.0, DRAW_ADDITIVE,entity_get_int(pack_channel[g_entity_channel], EV_INT_iuser2))
			acg_drawentityicon (i, "icon_supplybox_mini", 200, 200, 200, 1, 108, 180, 216, LocVecs[1], -1.0, DRAW_ADDITIVE, entity_get_int(pack_channel[g_entity_channel], EV_INT_iuser2))
			acg_drawentityicon (i, "icon_supplybox_mini", 200, 200, 200, 1, 108, 180, 216, LocVecs[2], -1.0, DRAW_ADDITIVE,entity_get_int(pack_channel[g_entity_channel], EV_INT_iuser2))
			acg_drawentityicon (i, "icon_supplybox_mini", 200, 200, 200, 1, 108, 180, 216, LocVecs[3], -1.0, DRAW_ADDITIVE, entity_get_int(pack_channel[g_entity_channel], EV_INT_iuser2))
		}
	}	
}*/

public CareEmpPack(id)
{
	id -=  746;
	new Float:LocVecs[4][3], k;
	for(new i=0; i<4; i++)
	{
		k = 0;
jeszczeraz:
		if(k > 40)
			continue;
			
		LocVecs[i][0] = PobraneOrigin[0] + random_float(-300.0,300.0);
		LocVecs[i][1] = PobraneOrigin[1] + random_float(-300.0,300.0);
		LocVecs[i][2] = PobraneOrigin[2] + 150.0;
		if(!is_hull_vacant(LocVecs[i], HULL_HUMAN))
		{
			k++;
			goto jeszczeraz;
		}
	}
	new ent, co_ma_dostac[4];
	for(new i=0; i<4; i++)
	{
		ent = create_pack(id, "pack", "models/cod_carepackage2.mdl", 1, 6, LocVecs[i]);
		if(acg_userstatus(id) && is_user_connected(id) && is_user_alive(id))
		{
			acg_drawentityicon (id, "icon_supplybox_mini", 200, 200, 200, 1, 108, 180, 216, _, ent, -1.0, DRAW_ADDITIVE,entity_get_int(pack_channel[g_entity_channel], EV_INT_iuser2))
		}
		
sprawdz:
		co_ma_dostac[i] = LosujNagrode();
		if(i > 1)
		{
			for(new k=0; k<i; k++)
			{
				if(co_ma_dostac[i] == co_ma_dostac[k] && i != k)
					goto sprawdz;
			}
		}
		entity_set_int(ent, EV_INT_iuser1, co_ma_dostac[i]);
	}
}

stock LosujNagrode()
{
	new nagroda;
	switch(random_num(0,75))	
	{
		case 0..14: 	nagroda = 1; //uav
		case 15..25: 	nagroda = 2; //cuav
		case 26..35:	nagroda= 3 ; //sentry
		case 36..45:	nagroda= 4; //predator
		case 46..60:	nagroda= 5; //nalot
		case 61..70:	nagroda= 6;//advuav
		case 71..75:	nagroda=7;//emp
	}
	return nagroda;
}

public CreateAirTrap(id)
{
	new num, players[32];
	get_players(players, num, "cgh");
	for(new a = 0; a < num; a++)
	{
		new i = players[a];
		if(get_user_team(id) != get_user_team(i))
		{
			print_id_info(id, "Paczki z wyposazeniem", i);
			client_cmd(i, "spk sound/mw/ks_enemy_carepackage.wav");
		}
		else
		{
			print_id_info(id, "Paczki Pulapki", i);
			client_cmd(i, "spk sound/mw/ks_use_airtrap.wav");
		}
	}
	set_bartime(id, 1, 0);
	CreatePlane(id);
	airtrap[id] = false
	set_task(1.0, "CareAirTrap", id+747)
}

public CareAirTrap(taskid)
{
	new id = (taskid - 747)
	
	PobraneOrigin[2] += 200; 
	new Float:LocVecs[3];
	IVecFVec(PobraneOrigin, LocVecs);
	new ent = create_pack(id, "airtrap", "models/cod_carepackage.mdl", 1, 6, LocVecs);
	if(acg_userstatus(id) && is_user_connected(id) && is_user_alive(id))
	{
		acg_drawentityicon (id, "icon_supplybox_mini", 200, 200, 200, 1, 108, 180, 216, _, ent,  -1.0, DRAW_ADDITIVE,entity_get_int(pack_channel[g_entity_channel], EV_INT_iuser2))
	}
}

public pickup_pack(info[2])
{
	new id = info[0];
	new ent = info[1];
	
	if(!is_user_connected(id) || !is_user_alive(id))
		return;

	new weapons[32], weaponsnum;
	get_user_weapons(id, weapons, weaponsnum);
	for(new i=0; i<weaponsnum; i++)
		if(maxAmmo[weapons[i]] > 0)
			cs_set_user_bpammo(id, weapons[i], maxAmmo[weapons[i]]);
	
	fm_set_user_health(id, get_user_health(id)+20);
	cod_set_user_xp(id, cod_get_user_xp(id)+20);
	cod_show_exp_reward(id, 20, "Zabranie Paczki z wyposazeniem")
	//COD_MSG_EXP_P;
	//show_dhudmessage(id, "+20");
	//ach_add_status(id, uch_zbieracz, 1);
	new kanal = entity_get_int(ent, EV_INT_iuser2)
	
	if(acg_userstatus(id) && !is_user_bot(id))
		acg_removedrawnimage(id, 4, kanal)
		
	set_hudmessage(120, 245, 120, -1.0, 0.20, 0, 2.0, 4.0, 0.2, 0.3, -1)
	switch(entity_get_int(ent, EV_INT_iuser1))	
	{
		case 1:
		{
			if(uav[id] == false)
			{
				uav[id] = true;
				show_hudmessage(id, "Dostales UAV !");
				ColorChat(id, "!g[KillStrike] !nZeby widziec wrogow na radarze, say /ks");
				switch(random_num(0, 2))
				{
					case 0: client_cmd(id, "spk sound/mw/ks_get_uav_01.wav")
					case 1: client_cmd(id, "spk sound/mw/ks_get_uav_02.wav")
					case 2: client_cmd(id, "spk sound/mw/ks_get_uav_03.wav")
				}
			}
		}
		case 2:
		{
			if(cuav[id] == false)
			{
				cuav[id] = true;
				show_hudmessage(id, "Dostales Kontr-UAV !");
				ColorChat(id, "!g[KillStrike] !nZeby wylaczyc wrogom UAV, say /ks");
				switch(random_num(0, 1))
				{
					case 0: client_cmd(id, "spk sound/mw/ks_get_jamuav_01.wav")
					case 1: client_cmd(id, "spk sound/mw/ks_get_jamuav_02.wav")
				}
			}
		}
		case 3:
		{
			if(sentrys[id] == false)
			{
				sentrys[id] = true;
				show_hudmessage(id, "Dostales Dzialko straznicze !");
				ColorChat(id, "!g[KillStrike] !nAby postawic dzialko, say /ks");
				client_cmd(id, "spk sound/mw/ks_get_sentrygun.wav");
			}
		}
		case 4:
		{
			if(predator[id] == false)
			{
				predator[id] = true;
				show_hudmessage(id, "Dostales Rakiete Predator !");
				ColorChat(id, "!g[KillStrike] !nZeby odpalic predatora, say /ks");
				switch(random_num(0, 1))
				{
					case 0: client_cmd(id, "spk sound/mw/ks_get_predator_01.wav")
					case 1: client_cmd(id, "spk sound/mw/ks_get_predator_02.wav")
				}
			}
		}
		case 5:
		{
			if(nalot[id] == false)
			{
				nalot[id] = true;
				show_hudmessage(id, "Dostales Nalot Precyzyjny !");
				ColorChat(id, "!g[KillStrike] !nSay /ks i Naceluj, gdzie ma byc wykonany zrzut bomb");
				client_cmd(id, "spk sound/mw/ks_get_airstrike.wav");
			}
		}
		case 6:
		{
			if(advuav[id] == false)
			{
				advuav[id] = true;
				show_hudmessage(id, "Dostales Zaawansowane UAV !");
				ColorChat(id, "!g[KillStrike] !nZeby widziec wrogow na radarze, say /ks");
				client_cmd(id, "spk sound/mw/ks_get_advuav.wav");
			}
		}
		case 7:
		{
			if(emp[id] == false)
			{
				emp[id] = true;
				show_hudmessage(id, "Dostales EMP !");
				ColorChat(id, "!g[KillStrike] !nAby uruchomic EMP, say /ks");
				switch(random_num(0, 1))
				{
					case 0: client_cmd(id, "spk sound/mw/ks_get_emp_01.wav")
					case 1: client_cmd(id, "spk sound/mw/ks_get_emp_02.wav")
				}
			}
		}
	}
	pack_channel[kanal] = 0
	remove_entity(ent)
	g_pack_count--;
}
		
public pickup_airtrap(info[2])
{
	new id = info[0];
	new ent = info[1];
	
	if(!is_user_connected(id) || !is_user_alive(id))
		return;
	
	if(acg_userstatus(id) && !is_user_bot(id) )
		acg_drawtext(id, 0.0, 0.0, "Wziales Paczke Pulapke !", 255, 100, 100, 255, 0.1, 2.0, 4.0, 1, TS_SHADOW, 0, 1, 9) 
	
	user_silentkill(id)
	/*
	//zmieniam ilosc zginiec w tablicy ofiary
	message_begin(MSG_ALL,gmsgScoreInfo)
	write_byte(id)
	write_short(get_user_frags(id))
	write_short(get_user_deaths(id)+1)
	write_short(0)
	write_short(get_user_team(id))
	message_end()
			
	//Pokazuje wiadomosc o zabiciu
	message_begin(MSG_ALL,gmsgDeathMsg,{0,0,0},0)
	write_byte(kid)
	write_byte(Touched)
	write_byte(0)
	write_string("worldspawn")
	message_end()
	//emit_sound(id, CHAN_ITEM, "player/die1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	*/
	
	new kanal = entity_get_int(ent, EV_INT_iuser2)
	
	if(acg_userstatus(id) && !is_user_bot(id) && is_user_connected(id))
		acg_removedrawnimage(id, 4, kanal)
		
	pack_channel[kanal] = 0
	remove_entity(ent)
	g_pack_count--;
	
}

public client_PreThink(id)
{	
	if(!is_user_alive(id))
		return PLUGIN_CONTINUE;	
		
	if(user_controll[id])
	{
		new ent2 = user_controll[id];
		if(is_valid_ent(ent2))
		{
			new Float:Velocity[3], Float:Angle[3];
			velocity_by_aim(id, 500, Velocity);
			entity_get_vector(id, EV_VEC_v_angle, Angle);
			
			entity_set_vector(ent2, EV_VEC_velocity, Velocity);
			entity_set_vector(ent2, EV_VEC_angles, Angle);
		}
		else
			attach_view(id, id);
	}
	static ent_id[MAX+1];
	new ent3 = find_drop_pack(id, "pack");
	
	if(is_valid_ent(ent3))
	{
		if(!task_exists(2571+ent3) && !is_user_bot(id))
		{
			ent_id[id] = ent3;
			set_bartime(id, 2, 0);
		
			new info[2];
			info[0] = id;
			info[1] = ent3;
			set_task(2.0, "pickup_pack", 2571+ent3, info, 2);
		}
		else if(!task_exists(2571+ent3) && is_user_bot(id))
		{
			ent_id[id] = ent3;
		
			new info[2];
			info[0] = id;
			info[1] = ent3;
			set_task(0.2, "pickup_pack", 2571+ent3, info, 2);
		}
	}
	else
	{
		if(task_exists(2571+ent_id[id]))
		{
			remove_task(2571+ent_id[id]);
			set_bartime(id, 0, 100);
			ent_id[id] = 0;
		}
	}
	
	static ent_id2[MAX+1];
	new ent4 = find_drop_pack(id, "airtrap");
	if(is_valid_ent(ent4))
	{
		if(!task_exists(2572+ent4) && !is_user_bot(id))
		{
			ent_id2[id] = ent4;
			set_bartime(id, 2, 0);
		
			new info[2];
			info[0] = id;
			info[1] = ent4;
			set_task(2.0, "pickup_airtrap", 2572+ent4, info, 2);
		}
		else if(!task_exists(2572+ent4) && is_user_bot(id))
		{
			ent_id2[id] = ent4;
		
			new info[2];
			info[0] = id;
			info[1] = ent4;
			set_task(0.2, "pickup_airtrap", 2572+ent4, info, 2);
		}
	}
	else
	{
		if(task_exists(2572+ent_id2[id]))
		{
			remove_task(2572+ent_id2[id]);
			set_bartime(id, 0, 100);
			ent_id2[id] = 0;
		}
	}
	/*if((g_icon_delay[id]) > get_gametime())
		return PLUGIN_CONTINUE;
		
	g_icon_delay[id] = floatround((get_gametime() + 2.0)) // delay 2.0 second

	// display icons in players screen
	if(g_pack_count)
	{
		if(acg_userstatus(id) && !is_user_bot(id) && is_user_connected(id))
		{
			new ents = -1, classnamess[32], Float:origin_paczek[3]; // by Cypis
			while((ents = find_ent_by_class(ents, "pack")))
			{
				entity_get_string(ents, EV_SZ_classname, classnamess, 31);
				if(equali(classnamess, "pack") )
				{
					//create_icon_origin(id, ents, g_supplybox_icon_id)
					//pev(ents, pev_origin, origin_paczek)
					entity_get_vector(ents, EV_VEC_origin, origin_paczek)
					acg_drawentityicon(id, "icon_supplybox_mini", 255, 255, 255, 1, 108, 180, 216, origin_paczek, ents, 2.0, DRAW_ADDITIVE, entity_get_int(ents, EV_INT_iuser2))
				}
			}
			new ents2 = -1, classnamess2[32], Float:origin_pulapek[3];
			while((ents2 = find_ent_by_class(ents2, "airtrap")))
			{
				entity_get_string(ents2, EV_SZ_classname, classnamess2, 31);
				if(equali(classnamess2, "airtrap"))
				{
					//create_icon_origin(id, ents, g_supplybox_icon_id)
					//pev(ents, pev_origin, origin_paczek)
					entity_get_vector(ents2, EV_VEC_origin, origin_pulapek)
					acg_drawentityicon(id, "icon_supplybox_mini", 255, 255, 255, 1, 108, 180, 216, origin_pulapek, ents2, 2.0, DRAW_ADDITIVE, entity_get_int(ents2, EV_INT_iuser2))
				}
			}
		}
	}*/
	return PLUGIN_CONTINUE;
}

//counter-uva
public CreateCUVA(id)
{
	cuav[id] = false;
	new num, players[32];
	get_players(players, num, "cgh");
	
	for(new a = 0; a < num; a++)
	{
		new i = players[a];
		if(get_user_team(id) != get_user_team(i))
		{
			if(advuav_active[cs_get_user_team(id) == CS_TEAM_T? 0: 1]  == false)
			{
				if(acg_userstatus(i) && is_user_connected(i))
					acg_drawoverviewradar (i, 1, 0, 0, 150, 150, 255, 255, 255)
					
				switch(random_num(0,1))
				{
					case 0: client_cmd(i, "spk sound/mw/ks_enemy_jamuav_01.wav")
					case 1: client_cmd(i, "spk sound/mw/ks_enemy_jamuav_02.wav")
				}
			}
		}
		else
		{
			switch(random_num(0,1))
			{
				case 0: client_cmd(i, "spk sound/mw/ks_use_jamuav_01.wav")
				case 1: client_cmd(i, "spk sound/mw/ks_use_jamuav_02.wav")
			}
		}	
	}
	
	radar[cs_get_user_team(id) == CS_TEAM_T? 1: 0] = false;
	
	print_info(id, "Kontr-UAV");
	
}

public CreateAdvancedUAV(id)
{
	//static CzasUav[2];
	
	advuav[id] = false;
	new team = cs_get_user_team(id) == CS_TEAM_T? 0: 1;
	advuav_active[team] = true;
	
	//radar[team] = true;
	
	new num, players[32];
	get_players(players, num, "cgh")
	for(new a = 0; a < num; a++)
	{
		new i = players[a]
			
		if(get_user_team(id) != get_user_team(i))
			client_cmd(i, "spk sound/mw/ks_enemy_advuav.wav")
		else
		{
			client_cmd(i, "spk sound/mw/ks_use_advuav.wav")
			
			if(acg_userstatus(i) && is_user_connected(i))
				acg_drawoverviewradar (i, 1, 1, 0, 150, 150, 255, 255, 255)
		}
	}
	print_info(id, "Zaawansowanego UAV");
	//ach_add_status(id, uch_radar, 1);
	//radar_scan();
	
	/*if(task_exists(7354+team))
	{
		new times = (CzasUav[team]-get_systime())+45;
		change_task(7354+team, float(times));
		CzasUav[team] = CzasUav[team]+times;
	}
	else
	{
		new data[1];
		data[0] = team;
		set_task(45.0, "deluav", 7354+team, data, 1);
		CzasUav[team] = get_systime()+45;
	}*/
	CreatePlane(id);
	set_task(120.0, "deluadv", id);
	return PLUGIN_CONTINUE;
}


//emp
public CreateEmp(id)
{
	client_cmd(0, "spk sound/mw/emp_effect.wav");
	emp[id] = false;
	new num, players[32];
	get_players(players, num, "cgh")
	for(new a = 0; a < num; a++)
	{
		new i = players[a];
		if(get_user_team(id) != get_user_team(i))
		{
			if(is_user_alive(i))
			{
				//Display_Fade(i,1<<12,1<<12,1<<16,255, 255,0,166)
				if(is_user_connected(i) && acg_userstatus(i) && !is_user_bot(i))
					acg_screenfade(i, 0, 212, 255, 166, 1.5, 0.0, 2.0)
					
				message_begin(MSG_ONE_UNRELIABLE, msgHideWeapon, .player = i);
				write_byte(0x29); //(1<<0)|(1<<3)|(1<<5)
				message_end();
			}
			client_cmd(i, "spk sound/mw/emp_enemy.wav");
		}
		else
			client_cmd(i, "spk sound/mw/ks_use_emp.wav");
	}
	print_info(id, "Impulsu Elektromagnetycznego (EMP)");
	emp_czasowe = id;
	set_task(90.0,"del_emp");
	info(id);
}
public info(id)
{
	Odliczanie[id] = 90
        
	if(task_exists(id + 3431))
	{
		remove_task(id + 3431)
	}
	set_task(1.0, "KoniecEMP", id + 3431, _, _, "b")
        
	return PLUGIN_CONTINUE
}

public KoniecEMP(task_id)
{
	new id = task_id - 3431
        
	if(is_user_alive(id) && (Odliczanie[id] > 80 && Odliczanie[id] < 90 || Odliczanie[id] > 30 && Odliczanie[id] < 46 || Odliczanie[id] > 0 && Odliczanie[id] < 20 ))
	{
		//set_hudmessage(255, 255, 255, -1.0, 0.85, 0, 0.02, 1.0, 0.01, 0.3, -1);
		new Text[128];
		format(Text, 127, "EMP wylaczy sie za %d sek.", Odliczanie[id])
		
		if(is_user_connected(id) && acg_userstatus(id) && !is_user_bot(id))
			acg_drawtext(id, -1.0, 0.84, Text, 255, 255, 255, 255, 0.0, 0.0, 1.01, 0, TS_NONE, 0, 0, 10)
		//show_hudmessage(0, "EMP wylaczy sie za %d sek.", Odliczanie[id]);
	}
        
	Odliczanie[id] --; 
	if(Odliczanie[id]  <= 15 && Odliczanie[id] > 10)
		client_cmd(id, "mp3 play TM_CodMod/Tick");
	
	if(Odliczanie[id]  <= 10 && Odliczanie[id] > 6)
		client_cmd(id, "mp3 play TM_CodMod/Tick1");
		
	if(Odliczanie[id]  <= 6 && Odliczanie[id] > 4)
		client_cmd(id, "mp3 play TM_CodMod/Tick2");
	
	if(Odliczanie[id] == 3 || Odliczanie[id]  == 2 )
		client_cmd(id, "mp3 play TM_CodMod/Tick3");
	
	if(Odliczanie[id]  == 1)
		client_cmd(id, "mp3 play TM_CodMod/Tick4");
        
	if(Odliczanie[id] <= 0)
	{
		if(task_exists(task_id))
		{
			remove_task(task_id)
		}
	}
}

public del_emp()
{
	new num, players[32];
	get_players(players, num, "cgh");
	for(new a = 0; a < num; a++)
	{
		new i = players[a];
		if(get_user_team(emp_czasowe) != get_user_team(i))
		{
			if(is_user_alive(i))
			{
				message_begin(MSG_ONE_UNRELIABLE, msgHideWeapon, .player = i); 
				write_byte(0);
				message_end();
			}
		}
	}
	emp_czasowe = 0;
}

public CurWeapon(id)
{
	if(emp_czasowe && get_user_team(id) != get_user_team(emp_czasowe))
	{
		message_begin(MSG_ONE_UNRELIABLE, msgHideWeapon, .player = id); 
		write_byte(0x29); //(1<<0)|(1<<3)|(1<<5)
		message_end(); 
	}
}
//nuke
public CreateNuke(id)
{
	new num, players[32];
	get_players(players, num, "cgh");
	for(new a = 0; a < num; a++)
	{
		new i = players[a];
		if(get_user_team(id) != get_user_team(i))
			client_cmd(i, "spk sound/mw/ks_enemy_moab.wav");
		else
			client_cmd(i, "spk sound/mw/ks_use_moab.wav");
	}
	client_cmd(0, "spk sound/mw/nuke_enemy1.wav");
	//Display_Fade(0,(10<<12),(10<<12),(1<<16),255, 42, 42,171);
	acg_screenfade(0, 255, 42, 42, 171, 3.8, 0.0, 0.0)
		
	print_info(id, "Atomowki");
	set_task(3.8,"ShakeHud");
	set_task(6.3,"del_nuke", id);
	
	//ach_add_status(id, uch_pierwszy, 1)
	nuke_koniec = true;
	nuke[id] = false;
}
public ShakeHud()
{
	//Display_Fade(0,(3<<12),(3<<12),(1<<16),255, 85, 42,215);
	acg_screenfade(0, 255, 85, 42, 215, 2.5, 0.0, 0.0)
	
	message_begin(MSG_BROADCAST, msgScreenShake);
	write_short(255<<12);
	write_short(4<<12);
	write_short(255<<12);
	message_end();
}

public del_nuke(id)
{
	new num, players[32];
	get_players(players, num, "gh");
	for(new a = 0; a < num; a++)
	{
		new i = players[a];
		if(is_user_alive(i) && id != i)
		{
			if(get_user_team(id) != get_user_team(i))
			{
				cs_set_user_armor(i, 0, CS_ARMOR_NONE);
				UTIL_Kill(id, i, float(get_user_health(i)), DMG_BULLET)
			}
			else
				user_silentkill(i);
		}
	}
	if(is_user_alive(id))
		user_silentkill(id);
	
	nuke_koniec = false;
	licznik_zabic[id] = 0;
}

//nalot
public CreateNalot(id)
{
	new num, players[32];
	get_players(players, num, "cgh");
	for(new a = 0; a < num; a++)
	{
		new i = players[a];
		if(get_user_team(id) != get_user_team(i))
			client_cmd(i, "spk sound/mw/ks_enemy_airstrike.wav");
		else
			client_cmd(i, "spk sound/mw/ks_use_airsrtike.wav");
	}
	set_hudmessage(255, 100, 100, -1.0, 0.7, 0, 0.5, 1.5);
	show_hudmessage(id, "WSPARCIE NADLATUJE!");
	set_bartime(id, 1, 0);
	print_info(id, "Nalotu Precyzyjnego");
	set_task(1.2, "CreateBombs", id+997, _, _, "a", 3);
	CreatePlane(id);
	nalot[id] = false;
}

public CreateBombs(taskid)
{	
	new id = (taskid-997);
	
	new radlocation[3];
	PobraneOrigin[0] += random_num(-300,300);
	PobraneOrigin[1] += random_num(-300,300);
	PobraneOrigin[2] += 70;
	
	for(new i=0; i<15; i++) 
	{
		radlocation[0] = PobraneOrigin[0]+1*random_num(-150,150); 
		radlocation[1] = PobraneOrigin[1]+1*random_num(-150,150); 
		radlocation[2] = PobraneOrigin[2]; 
		
		new Float:LocVec[3]; 
		IVecFVec(radlocation, LocVec); 
		create_ent(id, "bomb", "models/p_hegrenade.mdl", 2, 10, LocVec);
	}
}  

public CreatePlane(id)
{
	new Float:Origin[3], Float:Angle[3], Float:Velocity[3];
	
	get_user_origin(id, PobraneOrigin, 3);
	
	velocity_by_aim(id, 1000, Velocity);
	entity_get_vector(id, EV_VEC_origin, Origin);
	entity_get_vector(id, EV_VEC_v_angle, Angle);
	
	Angle[0] = Velocity[2] = 0.0;
	Origin[2] += 500.0;
	
	new ent = create_ent(id, "samolot", "models/cod_plane.mdl", 2, 8, Origin);
	
	entity_set_vector(ent, EV_VEC_velocity, Velocity);
	entity_set_vector(ent, EV_VEC_angles, Angle);
	
	emit_sound(ent, CHAN_ITEM, "mw/jet_fly1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
	set_task(4.5, "del_plane", ent+5731);
}

public del_plane(taskid)
	remove_entity(taskid-5731);

public touchedrocket(ent, id)
{
	if(!is_valid_ent(ent))
		return PLUGIN_CONTINUE;
	
	bombs_explode(ent, 100.0, 200.0);
	return PLUGIN_CONTINUE;
}

//predator
public CreatePredator(id)
{
	acg_showteammate(id, 0)
	new num, players[32];
	get_players(players, num, "cgh");
	for(new a = 0; a < num; a++)
	{
		new i = players[a];
		if(cs_get_user_team(id) != cs_get_user_team(i))
			client_cmd(i, "spk sound/mw/ks_enemy_predator.wav");
		else
			client_cmd(i, "spk sound/mw/ks_use_predator.wav");
	}
	print_info(id, "Rakiety Predator");
	set_task(0.3, "StartPredator", id)
} 

public StartPredator(id)
{
	new Float:Origin[3], Float:Angle[3], Float:Velocity[3], ent;
	
	velocity_by_aim(id, 700, Velocity);
	entity_get_vector(id, EV_VEC_origin, Origin);
	entity_get_vector(id, EV_VEC_v_angle, Angle);
	
	Angle[0] *= -1.0;
	
	ent = create_ent(id, "predator", "models/cod_predator.mdl", 2, 5, Origin);
	
	entity_set_vector(ent, EV_VEC_velocity, Velocity);
	entity_set_vector(ent, EV_VEC_angles, Angle);
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMFOLLOW);
	write_short(ent);
	write_short(cache_trail);
	write_byte(10);
	write_byte(5);
	write_byte(205);
	write_byte(237);
	write_byte(163);
	write_byte(200);
	message_end();
	
	predator[id] = false;
	set_hudmessage(235, 235, 255, -1.0, 0.7, 0, 5.0, 3.5);
	show_hudmessage(id, "Steruj predatorem za pomoca myszki.");
	
	attach_view(id, ent);
	user_controll[id] = ent;
}
	
public touchedpredator(ent, id)
{
	if(!is_valid_ent(ent))
		return PLUGIN_CONTINUE;
	
	new owner = entity_get_edict(ent, EV_ENT_owner);
	bombs_explode(ent, 200.0, 300.0);
	attach_view(owner, owner);
	user_controll[owner] = 0;
	set_task(0.3, "Back", owner)
	return PLUGIN_CONTINUE;
}

public Back(id)
{
	acg_showteammate(id, 1)
}
//sentry gun
public CreateSentry(id) 
{
	if(!(entity_get_int(id, EV_INT_flags) & FL_ONGROUND)) 
		return;

	new entlist[3];
	if(find_sphere_class(id, "func_bomb_target", 600.0, entlist, 2))
	{
		client_print(id, print_center, "Jestes zbyt blisko BS'A.");
		return;
	}
	if(find_sphere_class(id, "func_buyzone", 600.0, entlist, 2))
	{
		client_print(id, print_center, "Jestes zbyt blisko Respa.");
		return;
	}
	new num, players[32], Float:Origin[3];
	get_players(players, num, "cgh");
	for(new a = 0; a < num; a++)
	{
		new i = players[a];
		if(cs_get_user_team(id) != cs_get_user_team(i))
			client_cmd(i, "spk sound/mw/sentrygun_enemy.wav");
		else
			client_cmd(i, "spk sound/mw/sentrygun_friend.wav");
	}
	print_info(id, "Dzialka Strazniczego");
	
	entity_get_vector(id, EV_VEC_origin, Origin);
	Origin[2] += 45.0;
	
	new health[12], ent = create_entity("func_breakable");
	get_cvar_string("ks_hpsentry",health, charsmax(health));
	
	DispatchKeyValue(ent, "health", health);
	DispatchKeyValue(ent, "material", "6");
	
	entity_set_string(ent, EV_SZ_classname, "sentry");
	entity_set_model(ent, "models/sentrygun_mw2.mdl");
	
	entity_set_float(ent, EV_FL_takedamage, DAMAGE_YES);
	
	entity_set_size(ent, Float:{-16.0, -16.0, 0.0}, Float:{16.0, 16.0, 48.0});
	
	entity_set_origin(ent, Origin);
	entity_set_int(ent, EV_INT_solid, SOLID_SLIDEBOX);
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_TOSS);
	entity_set_int(ent, EV_INT_iuser2, id);
	entity_set_vector(ent, EV_VEC_angles, Float:{0.0, 0.0, 0.0});
	entity_set_byte(ent, EV_BYTE_controller2, 127);

	entity_set_float(ent, EV_FL_nextthink, get_gametime()+1.0);
	
	sentrys[id] = false;
	emit_sound(ent, CHAN_ITEM, "mw/plant.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
	cod_set_user_xp(id, cod_get_user_xp(id)+35);
	//COD_MSG_EXP_P;
	//show_dhudmessage(id, "+35");
	cod_show_exp_reward(id, 35, "Postawienie Dzialka strazniczego")
	//ach_add_status(id, uch_budowniczy, 1);
	sentry_build[id] = true;
}

public SentryThink(ent)
{
	if(!is_valid_ent(ent)) 
		return PLUGIN_CONTINUE;
	
	new Float:SentryOrigin[3], Float:closestOrigin[3];
	entity_get_vector(ent, EV_VEC_origin, SentryOrigin);

	new id = entity_get_int(ent, EV_INT_iuser2);
	new target = entity_get_edict(ent, EV_ENT_euser1);
	new firemods = entity_get_int(ent, EV_INT_iuser1);
	
	if(firemods)
	{ 
		if(fm_is_ent_visible(target, ent) && is_user_alive(target)) 
		{
			#if defined TARCZA
			if(UTIL_In_FOV(target,ent))
				goto fireoff;
			#endif
			
			new Float:TargetOrigin[3];
			entity_get_vector(target, EV_VEC_origin, TargetOrigin);
				
			emit_sound(ent, CHAN_AUTO, "mw/firemw.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
			sentry_turntotarget(ent, SentryOrigin, TargetOrigin);
				
			new Float:hitRatio = random_float(0.0, 1.0) - 0.2;
			if(hitRatio <= 0.0)
			{
				UTIL_Kill(id, target, random_float(5.0, 35.0), DMG_BULLET, 1);
				
				message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
				write_byte(TE_TRACER);
				write_coord(floatround(SentryOrigin[0]));
				write_coord(floatround(SentryOrigin[1]));
				write_coord(floatround(SentryOrigin[2]));
				write_coord(floatround(TargetOrigin[0]));
				write_coord(floatround(TargetOrigin[1]));
				write_coord(floatround(TargetOrigin[2]));
				message_end();
			}
			entity_set_float(ent, EV_FL_nextthink, get_gametime()+0.1);
			return PLUGIN_CONTINUE;
		}
		else
		{
#if defined TARCZA
fireoff:
#endif
			firemods = 0;
			entity_set_int(ent, EV_INT_iuser1, 0);
			entity_set_edict(ent, EV_ENT_euser1, 0);
			emit_sound(ent, CHAN_AUTO, "mw/sentrygun_stops.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
			
			entity_set_float(ent, EV_FL_nextthink, get_gametime()+0.1);
			return PLUGIN_CONTINUE;
		}
	}

	new closestTarget = getClosestPlayer(ent, id);
	if(closestTarget)
	{
		emit_sound(ent, CHAN_AUTO, "mw/sentrygun_starts.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
		entity_get_vector(closestTarget, EV_VEC_origin, closestOrigin);
		sentry_turntotarget(ent, SentryOrigin, closestOrigin);
		
		entity_set_int(ent, EV_INT_iuser1, 1);
		entity_set_edict(ent, EV_ENT_euser1, closestTarget);
		
		entity_set_float(ent, EV_FL_nextthink, get_gametime()+0.3);
		return PLUGIN_CONTINUE;
	}

	if(!firemods)
	{
		new controler1 = entity_get_byte(ent, EV_BYTE_controller1)+1;
		if(controler1 > 255)
			controler1 = 0;
		entity_set_byte(ent, EV_BYTE_controller1, controler1);
		
		new controler2 = entity_get_byte(ent, EV_BYTE_controller2);
		if(controler2 > 127 || controler2 < 127)
			entity_set_byte(ent, EV_BYTE_controller2, 127);
			
		entity_set_float(ent, EV_FL_nextthink, get_gametime()+0.05);
	}
	return PLUGIN_CONTINUE
}

public sentry_turntotarget(ent, Float:sentryOrigin[3], Float:closestOrigin[3]) 
{
	sentryOrigin[2] += 35.0;
	new Float:x = closestOrigin[0]-sentryOrigin[0], Float:y = closestOrigin[1]-sentryOrigin[1], Float:z = closestOrigin[2]-sentryOrigin[2],
	Float:newAngle = floatatan(y/x, radian) * 57.2957795,
	Float:newTrip = (floatatan(z/floatsqroot((x*x)+(y*y)), radian) * 57.2957795)-90.0;

	if(closestOrigin[0] < sentryOrigin[0])
		newAngle += 180.0;
	if(newAngle < 0.0)
		newAngle += 360.0;

	entity_set_byte(ent, EV_BYTE_controller1, floatround(newAngle * 0.70833));
	entity_set_byte(ent, EV_BYTE_controller2, floatround(newTrip * -1.416));
	entity_set_byte(ent, EV_BYTE_controller3, entity_get_byte(ent, EV_BYTE_controller3)+20>255? 0: entity_get_byte(ent, EV_BYTE_controller3)+20);
}

public TakeDamage(ent, idinflictor, attacker, Float:damage, damagebits)
{
	if(!is_user_alive(attacker))
		return HAM_IGNORED;
	
	new classname[32];
	entity_get_string(ent, EV_SZ_classname, classname, 31);
	
	if(equal(classname, "sentry")) 
	{
		new id = entity_get_int(ent, EV_INT_iuser2);
		if(cs_get_user_team(attacker) == cs_get_user_team(id))
			return HAM_SUPERCEDE;

		if(damage >= entity_get_float(ent, EV_FL_health))
		{
			new Float:Origin[3];
			entity_get_vector(ent, EV_VEC_origin, Origin);	
			new entlist[33];
			new numfound = find_sphere_class(ent, "player", 190.0, entlist, 32);
			
			for(new i=0; i < numfound; i++)
			{		
				new pid = entlist[i];
				
				if(!is_user_alive(pid) || cs_get_user_team(id) == cs_get_user_team(pid))
					continue;
				UTIL_Kill(id, pid, 70.0, (1<<24));
			}
			client_cmd(id, "spk sound/mw/sentrygun_gone.wav");
			//Sprite_Blast(Origin);
			//remove_entity(ent); //jak to dam to cresh serwer bo odrazu usuwa sentry guna :O
			set_task(0.4, "del_sentry", ent); //jak tego nie dam to sentry jest jako byt i strzela
			sentry_build[id] = false;
		}
	}
	return HAM_IGNORED;
}

public del_sentry(ent)
	remove_entity(ent);
	
//wybuch
bombs_explode(ent, Float:zadaje, Float:promien)
{
	if(!is_valid_ent(ent)) 
		return;
	
	new attacker = entity_get_edict(ent, EV_ENT_owner);
	
	new Float:entOrigin[3], Float:fDamage, Float:Origin[3];
	entity_get_vector(ent, EV_VEC_origin, entOrigin);
	entOrigin[2] += 1.0;
	
	new entlist[33];
	new numfound = find_sphere_class(ent, "player", promien, entlist, 32);	
	for(new i=0; i < numfound; i++)
	{		
		new victim = entlist[i];		
		if(!is_user_alive(victim) || cs_get_user_team(attacker) == cs_get_user_team(victim))
			continue;
			
		entity_get_vector(victim, EV_VEC_origin, Origin);
		fDamage = zadaje - floatmul(zadaje, floatdiv(get_distance_f(Origin, entOrigin), promien));
		fDamage *= estimate_take_hurt(entOrigin, victim, 0);
		if(fDamage>0.0)
			UTIL_Kill(attacker, victim, fDamage, DMG_BULLET);
	}
	Sprite_Blast(entOrigin);
	remove_entity(ent);
}

public cmdKill()
	return FMRES_SUPERCEDE;

public message_DeathMsg()
{
	new killer = get_msg_arg_int(1);
	if(ZmienKilla[0] & (1<<killer))
	{
		set_msg_arg_string(4, "grenade");
		return PLUGIN_CONTINUE;
	}
	if(ZmienKilla[1] & (1<<killer))
	{
		set_msg_arg_string(4, "m249");
		return PLUGIN_CONTINUE;
	}
	return PLUGIN_CONTINUE;
}

stock create_ent(id, szName[], szModel[], iSolid, iMovetype, Float:fOrigin[3])
{
	new ent = create_entity("info_target");
	entity_set_string(ent, EV_SZ_classname, szName);
	entity_set_model(ent, szModel);
	entity_set_int(ent, EV_INT_solid, iSolid);
	entity_set_int(ent, EV_INT_movetype, iMovetype);
	entity_set_edict(ent, EV_ENT_owner, id);
	entity_set_origin(ent, fOrigin);
	return ent;
}

stock create_pack(id, szName[], szModel[], iSolid, iMovetype, Float:fOrigin[3])
{
	new ent= create_entity("info_target");
	entity_set_string(ent, EV_SZ_classname, szName);
	entity_set_model(ent, szModel);
	entity_set_int(ent, EV_INT_solid, iSolid);
	entity_set_int(ent, EV_INT_movetype, iMovetype);
	entity_set_edict(ent, EV_ENT_owner, id);
	entity_set_origin(ent, fOrigin);
	if(g_entity_channel < 20)
		entity_set_int(ent, EV_INT_iuser2, g_entity_channel);
	else
	{
		g_entity_channel = 0
		entity_set_int(ent, EV_INT_iuser2, g_entity_channel);
	}
	pack_channel[g_entity_channel] = ent;
	g_entity_channel++;
	g_pack_count++;
	return ent;
}

stock Sprite_Blast(Float:iOrigin[3])
{
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(TE_EXPLOSION);
	write_coord(floatround(iOrigin[0]));
	write_coord(floatround(iOrigin[1])); 
	write_coord(floatround(iOrigin[2]));
	write_short(sprite_blast);
	write_byte(32);
	write_byte(20); 
	write_byte(0);
	message_end();
}

stock Float:estimate_take_hurt(Float:fPoint[3], ent, ignored) 
{
	new Float:fFraction, Float:fOrigin[3], tr;
	entity_get_vector(ent, EV_VEC_origin, fOrigin);
	engfunc(EngFunc_TraceLine, fPoint, fOrigin, DONT_IGNORE_MONSTERS, ignored, tr);
	get_tr2(tr, TR_flFraction, fFraction);
	if(fFraction == 1.0 || get_tr2(tr, TR_pHit) == ent)
		return 1.0;
	return 0.6;
}

stock find_drop_pack(id, const class[])
{
	new Float:origin[3], classname[32], ent;
	entity_get_vector(id, EV_VEC_origin, origin);
	
	while((ent = find_ent_in_sphere(ent, origin, 75.0)) != 0) 
	{
		entity_get_string(ent, EV_SZ_classname, classname, 31);
		if(equali(classname, class))
			return ent;
	}
	return 0;
}

stock set_bartime(id, czas, startprogress)
{
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("BarTime2"), _, id)
	write_short(czas);
	write_short(startprogress);
	message_end()
} 

stock UTIL_Kill(atakujacy, obrywajacy, Float:damage, damagebits, ile=0)
{
	ZmienKilla[ile] |= (1<<atakujacy);
	ExecuteHam(Ham_TakeDamage, obrywajacy, atakujacy, atakujacy, damage, damagebits);
	ZmienKilla[ile] &= ~(1<<atakujacy);
}
	
stock getClosestPlayer(ent, id)
{
	new iClosestPlayer = 0, Float:flClosestDist = MAX_DIST, Float:flDistanse, Float:fOrigin[2][3];
	new num, players[32];
	get_players(players, num, "gh")
	for(new a = 0; a < num; a++)
	{
		new i = players[a];
		if(!is_user_connected(i) || !is_user_alive(i) || !fm_is_ent_visible(i, ent) || cs_get_user_team(i) == cs_get_user_team(id))
			continue;
		
		#if defined TARCZA
		if(UTIL_In_FOV(i, ent))
			continue;
		#endif
		
		entity_get_vector(i, EV_VEC_origin, fOrigin[0]);
		entity_get_vector(ent, EV_VEC_origin, fOrigin[1]);
		
		flDistanse = get_distance_f(fOrigin[0], fOrigin[1]);
		
		if(flDistanse <= flClosestDist)
		{
			iClosestPlayer = i;
			flClosestDist = flDistanse;
		}
	}
	return iClosestPlayer;
}
#if defined TARCZA
stock bool:UTIL_In_FOV(id,ent)
{
	if((get_pdata_int(id, 510) & (1<<16)) && (Find_Angle(id, ent) > 0.0))
		return true;
	return false;
}

stock Float:Find_Angle(id, target)
{
	new Float:Origin[3], Float:TargetOrigin[3];
	pev(id,pev_origin, Origin);
	pev(target,pev_origin,TargetOrigin);
	
	new Float:Angles[3], Float:vec2LOS[3];
	pev(id,pev_angles, Angles);
	
	xs_vec_sub(TargetOrigin, Origin, vec2LOS);
	vec2LOS[2] = 0.0;
	
	new Float:veclength = vector_length(vec2LOS);
	if (veclength <= 0.0)
		vec2LOS[0] = vec2LOS[1] = 0.0;
	else
	{
		new Float:flLen = 1.0 / veclength;
		vec2LOS[0] = vec2LOS[0]*flLen;
		vec2LOS[1] = vec2LOS[1]*flLen;
	}
	engfunc(EngFunc_MakeVectors, Angles);
	
	new Float:v_forward[3];
	get_global_vector(GL_v_forward, v_forward);
	
	new Float:flDot = vec2LOS[0]*v_forward[0]+vec2LOS[1]*v_forward[1];
	if(flDot > 0.5)
		return flDot;
	
	return 0.0;
}
#endif

stock print_info(id_korzystajacego, const nagroda[])
{
	new nick[33]
	get_user_name(id_korzystajacego, nick, 32);
	ColorChat(0, "!g[KillStrike] !n%s skorzystal z %s", nick, nagroda);
}

stock print_id_info(id_korzystajacego, const nagroda[], id_wyswietlajacych)
{
	new nick[33]
	get_user_name(id_korzystajacego, nick, 32);
	ColorChat(id_wyswietlajacych, "!g[KillStrike] !n%s skorzystal z %s", nick, nagroda);
}

stock is_hull_vacant(Float:origin[3], hull)
{
	static tr;
	engfunc(EngFunc_TraceHull, origin, origin, 0, hull, 0, tr);	
	if (!get_tr2(tr, TR_StartSolid) && !get_tr2(tr, TR_AllSolid) && get_tr2(tr, TR_InOpen))
		return true;
	return false;
}

stock ColorChat(id, const msg[], any:...)
{
	new message[256]
	vformat(message, 255, msg, 3)
	
	replace_all(message, 255, "!n", "^x01")
	replace_all(message, 255, "!t", "^x03")
	replace_all(message, 255, "!g", "^x04")
	
	if(id == 0)
	{
		new maxplayers = get_maxplayers()
		for(new i = 1; i <= maxplayers; i++)
		{
			if(is_user_connected(i))
			{
				message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), {0,0,0}, i)
				write_byte(i)
				write_string(message)
				message_end()
			}
		}
	}
	else
	{
		if(is_user_connected(id))
		{
			message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), {0,0,0}, id)
			write_byte(id)
			write_string(message)
			message_end()
		}
	}
}

/*public ach_give_reward(pid, aid)
{
	if(ach_get_stance(pid, uch_budowniczy) == 1)
	{
		//ach_set_stance(pid, uch_budowniczy, 1)
		cod_set_user_xp(pid, cod_get_user_xp(pid)+150);
		COD_MSG_EXP_N;
		show_dhudmessage(pid, "+150");
	}
	if(ach_get_stance(pid, uch_pierwszy) == 1)
	{
		//ach_set_stance(pid, uch_pierwszy, 1)
		cod_set_user_xp(pid, cod_get_user_xp(pid)+50);
		COD_MSG_EXP_N;
		show_dhudmessage(pid, "+50");
	}
	if(ach_get_stance(pid, uch_radar) == 1)
	{
		//ach_set_stance(pid, uch_radar, 1)
		cod_set_user_xp(pid, cod_get_user_xp(pid)+50);
		COD_MSG_EXP_N;
		show_dhudmessage(pid, "+50");
	}
	if(ach_get_stance(pid, uch_zbieracz) == 1)
	{
		//ach_set_stance(pid, uch_zbieracz, 1)
		cod_set_user_xp(pid, cod_get_user_xp(pid)+75);
		COD_MSG_EXP_N;
		show_dhudmessage(pid, "+75");
	}
}*/

public client_PostThink(id)
{
	new target, body;
	if(!is_user_bot(id) || !is_user_alive(id))
		return PLUGIN_CONTINUE;
		
	if(!emp_czasowe && uav[id])
		CreateUVA(id);
			
	if(!emp_czasowe && cuav[id])
		CreateCUVA(id);
	
	if(!emp_czasowe && advuav[id])
		CreateAdvancedUAV(id);
	
	if(!emp_czasowe && sentrys[id])
	{
		if( get_user_aiming(id, target, body, 3500) && get_user_team(id) != get_user_team(target))
		{
			CreateSentry(id);
		}
	}
	
	if(!emp_czasowe && nalot[id] && get_user_aiming(id, target, body, 4200))
	{
		CreateNalot(id);
	}
		
	if(!emp_czasowe && emp[id])
		CreateEmp(id);
		
	if(!emp_czasowe && nuke[id] && Uzyte_Nuke < 1)
		CreateNuke(id);
	
	return PLUGIN_CONTINUE;	
}
