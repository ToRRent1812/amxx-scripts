#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <fun>
#include <nvault>
#include <colorchat>
#include <acg>

#define PLUGIN "2K Mod"
new const ver[]= "0.97 RC4"
#define AUTHOR "QTM_Peyote (=ToRRent= Edit)"

#define MAX_GRACZY 20
#define MAX_WIELKOSC_NAZWY 32
#define MAX_WIELKOSC_OPISU 256
#define MAX_ILOSC_KLAS 100

#define STANDARDOWA_SZYBKOSC 250

#define ZADANIE_POKAZ_INFORMACJE 672
#define ZADANIE_POKAZ_REKLAME 768
#define ZADANIE_USTAW_SZYBKOSC 832
#define TASK_WYSZKOLENIE_SANITARNE 796

#define COD_MSG_HUD set_hudmessage(255, 255, 60, 0.54, 0.85, 0, 0.0, 0.3, 0.0, 0.0, 4)
#define COD_MSG_NEWS_P set_hudmessage(200, 120, 0, -1.00, 0.25, 0, 0.4, 3.0, 0.2, 0.3, -1)
#define COD_MSG_NEWS_N set_hudmessage(200, 50, 0, -1.00, 0.27, 0, 0.4, 3.0, 0.2, 0.3, -1)

new vault;

new SyncHudObj, SyncHudObj2;
 
new cvar_doswiadczenie_za_zabojstwo,
     cvar_doswiadczenie_za_obrazenia,
     cvar_doswiadczenie_za_wygrana,
     cvar_typ_zapisu,
     cvar_limit_poziomu,
     cvar_proporcja_poziomu;

new klasa_zmieniona;

new nazwa_gracza[MAX_GRACZY + 1][64],
     klasa_gracza[MAX_GRACZY + 1],
     nowa_klasa_gracza[MAX_GRACZY + 1],
     poziom_gracza[MAX_GRACZY + 1],
     doswiadczenie_gracza[MAX_GRACZY + 1];

new Float:maksymalne_zdrowie_gracza[MAX_GRACZY + 1],
     Float:szybkosc_gracza[MAX_GRACZY + 1],
     Float:redukcja_obrazen_gracza[MAX_GRACZY + 1],
     Float:wartosc_grawitacji_gracza[MAX_GRACZY + 1];
     
new punkty_gracza[MAX_GRACZY + 1],
     zdrowie_gracza[MAX_GRACZY + 1],
     inteligencja_gracza[MAX_GRACZY + 1],
     wytrzymalosc_gracza[MAX_GRACZY + 1],
     kondycja_gracza[MAX_GRACZY + 1],
     grawitacja_gracza[MAX_GRACZY + 1],
     przeladowanie_gracza[MAX_GRACZY+1],
     regeneracja_gracza[MAX_GRACZY+1];

new
     bonusowe_zdrowie_gracza[MAX_GRACZY + 1],
     bonusowa_inteligencja_gracza[MAX_GRACZY + 1],
     bonusowa_wytrzymalosc_gracza[MAX_GRACZY + 1],
     bonusowa_kondycja_gracza[MAX_GRACZY + 1],
     bonusowa_grawitacja_gracza[MAX_GRACZY + 1],
     bonusowe_przeladowanie_gracza[MAX_GRACZY+1],
     bonusowa_regeneracja_gracza[MAX_GRACZY+1];

new zdrowie_klas[MAX_ILOSC_KLAS+1],
     kondycja_klas[MAX_ILOSC_KLAS+1], 
     inteligencja_klas[MAX_ILOSC_KLAS+1], 
     wytrzymalosc_klas[MAX_ILOSC_KLAS+1],
     grawitacja_klas[MAX_ILOSC_KLAS+1],
     przeladowanie_klas[MAX_ILOSC_KLAS+1],
     regeneracja_klas[MAX_ILOSC_KLAS+1],
     nazwy_klas[MAX_ILOSC_KLAS+1][MAX_WIELKOSC_NAZWY+1],
     nazwy_kodowe_klas[MAX_ILOSC_KLAS+1][MAX_WIELKOSC_NAZWY+1],
     opisy_klas[MAX_ILOSC_KLAS+1][MAX_WIELKOSC_OPISU+1],
     pluginy_klas[MAX_ILOSC_KLAS+1],
     ilosc_klas;

new bool:freezetime = true;
new Float:tajmer[MAX_GRACZY+1];

// PRZELADOWANIE STALE
const NOCLIP_WPN_BS = ((1<<2)|(1<<CSW_HEGRENADE)|(1<<CSW_SMOKEGRENADE)|(1<<CSW_FLASHBANG)|(1<<CSW_KNIFE)|(1<<CSW_C4))
const SHOTGUNS_BS = ((1<<CSW_M3)|(1<<CSW_XM1014))

// weapons offsets
const m_pPlayer = 41
const m_iId = 43
const m_flTimeWeaponIdle = 48
const m_fInReload = 54

const m_flNextAttack = 83

stock const Float:reloadtime[CSW_P90+1] = {
	0.00, 2.70, 0.00, 2.00, 0.00, 0.55,   0.00, 3.15, 3.30, 0.00, 4.50, 
	2.70, 3.50, 3.35, 2.45, 3.30,   2.70, 2.20, 2.50, 2.63, 4.70, 
	0.55, 3.05, 2.12, 3.50, 0.00,   2.20, 3.00, 2.45, 0.00, 3.40
}

new Float:koordynat_y[33] = 0.83;
new kanal_acg[33] = 0;

public plugin_init() 
{
	register_plugin(PLUGIN, ver, AUTHOR);
	
	cvar_doswiadczenie_za_zabojstwo = register_cvar("cod_killxp", "10");
	cvar_doswiadczenie_za_obrazenia = register_cvar("cod_damagexp", "1"); // ilosc doswiadczenia za 25 obrazen 
	cvar_doswiadczenie_za_wygrana = register_cvar("cod_winxp", "30");
	cvar_typ_zapisu = register_cvar("cod_savetype", "2");  // 1-Nick; 2-SID dla Steam; 3-IP
	cvar_limit_poziomu = register_cvar("cod_maxlevel", "50"); // nie zmieniac
	cvar_proporcja_poziomu = register_cvar("cod_levelratio", "75");  
	
	register_clcmd("say /klasa", "WybierzKlase");
	register_clcmd("say /class", "WybierzKlase");
	register_clcmd("say /klasy", "OpisKlasy");
	register_clcmd("say /reset", "KomendaResetujPunkty");
	register_clcmd("say /statystyki", "PrzydzielPunkty");
	register_clcmd("say /staty", "PrzydzielPunkty");
	
	register_menucmd(register_menuid("Klasy:"), 1023, "OpisKlasy");
	
	RegisterHam(Ham_TakeDamage, "player", "Obrazenia");
	RegisterHam(Ham_TakeDamage, "player", "ObrazeniaPost", 1);
	RegisterHam(Ham_Spawn, "player", "Odrodzenie", 1);
	RegisterHam(Ham_Killed, "player", "SmiercGraczaPost", 1);
	
	register_forward(FM_CmdStart, "CmdStart");
	register_forward(FM_EmitSound, "EmitSound");
	
	//register_message(get_user_msgid("Health"),"MessageHealth");
	
	register_logevent("PoczatekRundy", 2, "1=Round_Start"); 
	
	register_event("SendAudio", "WygranaTerro" , "a", "2&%!MRAD_terwin");
	register_event("SendAudio", "WygranaCT", "a", "2&%!MRAD_ctwin");
	register_event("CurWeapon","CurWeapon","be", "1=1");
	register_event("HLTV", "NowaRunda", "a", "1=0", "2=0");
	//g_msg_screenfade = get_user_msgid("ScreenFade");

	vault = nvault_open("2kMod");
	
	SyncHudObj = CreateHudSyncObj();
	SyncHudObj2 = CreateHudSyncObj();
	
	//register_dictionary("2kcore.txt")
	
	klasa_zmieniona = CreateMultiForward("cod_class_changed", ET_CONTINUE, FP_CELL, FP_CELL);
	
	new weapon[17]
	for(new i=1; i<=CSW_P90; i++)
	{
		if( !(NOCLIP_WPN_BS & (1<<i)) && get_weaponname(i, weapon, charsmax(weapon)) )
		{
			if( !(SHOTGUNS_BS & (1<<i)) )
			{
				RegisterHam(Ham_Weapon_Reload, weapon, "PrzeladowanieBroniPost", 1)
			}
		}
	}
	
	set_task(1.0, "plugin_cfg");
}		

public plugin_cfg()
{
	new lokalizacja_cfg[33];
	get_configsdir(lokalizacja_cfg, charsmax(lokalizacja_cfg));
	server_cmd("exec %s/codmod.cfg", lokalizacja_cfg);
	server_exec();
}
public plugin_precache()
{	
	precache_sound("TM_CodMod/Select.wav");
	precache_sound("TM_CodMod/close.wav");
	//precache_sound("TM_CodMod/wyrzuc.wav");
	precache_sound("TM_CodMod/newlvl.wav");
	//precache_sound("TM_CodMod/leveldown.wav");
	//precache_sound("TM_CodMod/newperk.wav");
	//Orginal
	precache_sound("QTM_CodMod/levelup.wav");
	precache_sound("QTM_CodMod/select.wav");
	precache_sound("QTM_CodMod/start.wav");
	precache_sound("QTM_CodMod/start2.wav");
}

public plugin_natives()
{
	register_native("cod_set_user_xp", "UstawDoswiadczenie", 1);
	register_native("cod_set_user_class", "UstawKlase", 1);
	register_native("cod_set_user_bonus_health", "UstawBonusoweZdrowie", 1);
	register_native("cod_set_user_bonus_intelligence", "UstawBonusowaInteligencje", 1);
	register_native("cod_set_user_bonus_trim", "UstawBonusowaKondycje", 1);
	register_native("cod_set_user_bonus_stamina", "UstawBonusowaWytrzymalosc", 1);
	register_native("cod_set_user_bonus_gravity", "UstawBonusowaGrawitacje", 1);
	register_native("cod_set_user_bonus_reload", "UstawBonusowePrzeladowanie", 1);
	register_native("cod_set_user_bonus_regeneration", "UstawBonusowaRegeneracje", 1);
	
	register_native("cod_points_to_health", "PrzydzielZdrowie", 1);	
	register_native("cod_points_to_intelligence", "PrzydzielInteligencje", 1);	
	register_native("cod_points_to_trim", "PrzydzielKondycje", 1);	
	register_native("cod_points_to_stamina", "PrzydzielWytrzymalosc", 1);
	register_native("cod_points_to_gravity", "PrzydzielGrawitacje", 1);
	register_native("cod_points_to_reload", "PrzydzielPrzeladowanie", 1);
	register_native("cod_points_to_regeneration", "PrzydzielRegeneracje", 1);
	
	register_native("cod_get_user_xp", "PobierzDoswiadczenie", 1);
	register_native("cod_get_user_level", "PobierzPoziom", 1);
	register_native("cod_get_user_points", "PobierzPunkty", 1);
	register_native("cod_get_user_class", "PobierzKlase", 1);
	register_native("cod_get_user_health", "PobierzZdrowie", 1);
	register_native("cod_get_user_intelligence", "PobierzInteligencje", 1);
	register_native("cod_get_user_trim", "PobierzKondycje", 1);
	register_native("cod_get_user_stamina", "PobierzWytrzymalosc", 1);
	register_native("cod_get_user_gravity", "PobierzGrawitacje", 1);
	register_native("cod_get_user_reload", "PobierzPrzeladowanie", 1);
	register_native("cod_get_user_regeneration", "PobierzRegeneracje", 1);
	
	register_native("cod_get_level_xp", "PobierzDoswiadczeniePoziomu", 1);
	
	register_native("cod_get_classid", "PobierzKlasePrzezNazwe", 1);
	register_native("cod_get_classes_num", "PobierzIloscKlas", 1);
	register_native("cod_get_class_name", "PobierzNazweKlasy", 1);
	register_native("cod_get_class_desc", "PobierzOpisKlasy", 1);
	
	register_native("cod_get_class_health", "PobierzZdrowieKlasy", 1);
	register_native("cod_get_class_intelligence", "PobierzInteligencjeKlasy", 1);
	register_native("cod_get_class_trim", "PobierzKondycjeKlasy", 1);
	register_native("cod_get_class_stamina", "PobierzWytrzymaloscKlasy", 1);
	register_native("cod_get_class_gravity", "PobierzGrawitacjeKlasy", 1);
	register_native("cod_get_class_reload", "PobierzPrzeladowanieKlasy", 1);
	register_native("cod_get_class_regeneration", "PobierzRegeneracjeKlasy", 1);
	
	register_native("cod_inflict_damage", "ZadajObrazenia", 1);
	register_native("cod_register_class", "ZarejestrujKlase");
	
	register_native("cod_show_exp_reward", "native_PokazDoswiadczenie", 1);
}

public CmdStart(id, uc_handle)
{		
	if(!is_user_alive(id))
		return FMRES_IGNORED;

	new Float: velocity[3];
	pev(id, pev_velocity, velocity);
	new Float: speed = vector_length(velocity);
	if(szybkosc_gracza[id] > speed*1.8)
		set_pev(id, pev_flTimeStepSound, 300);
	
	return FMRES_IGNORED;
}

public Odrodzenie(id)
{	
	if(!task_exists(id+ZADANIE_POKAZ_INFORMACJE))
		set_task(0.1, "PokazInformacje", id+ZADANIE_POKAZ_INFORMACJE, _, _, "b");
	
	if(nowa_klasa_gracza[id])
		UstawNowaKlase(id);
	
	if(!klasa_gracza[id])
	{
		WybierzKlase(id);
		return PLUGIN_CONTINUE;
	}
	
	//DajBronie(id);
	ZastosujAtrybuty(id);
	
	if(punkty_gracza[id] > 0)
		PrzydzielPunkty(id);

	return PLUGIN_CONTINUE;
}

public PrzeladowanieBroniPost(ent)
{    
	if(get_pdata_int(ent, m_fInReload, 4))
	{
		new id = get_pdata_cbase(ent, m_pPlayer, 4)
		new Float:speed;
		new Float:delay;
		speed = 1.0-float(PobierzPrzeladowanie(id, 1, 1, 1))/30;
		delay = reloadtime[get_pdata_int(ent, m_iId, 4)];
		delay *= speed;
		set_pdata_float(id, m_flNextAttack, delay, 5);
		set_pdata_float(ent, m_flTimeWeaponIdle, delay + 0.5, 4);
	}
}

public UstawNowaKlase(id)
{
	new ret;
		
	new forward_handle = CreateOneForward(pluginy_klas[klasa_gracza[id]], "cod_class_disabled", FP_CELL, FP_CELL);
	ExecuteForward(forward_handle, ret, id, klasa_gracza[id]);
	DestroyForward(forward_handle);
		
	forward_handle = CreateOneForward(pluginy_klas[nowa_klasa_gracza[id]], "cod_class_enabled", FP_CELL, FP_CELL);
	ExecuteForward(forward_handle, ret, id, nowa_klasa_gracza[id]);
	DestroyForward(forward_handle);
	
	
	if(ret == 4)	
	{
		klasa_gracza[id] = 0;
		return PLUGIN_CONTINUE;
	}

	ExecuteForward(klasa_zmieniona, ret, id, klasa_gracza[id]);
	
	if(ret == 4)	
	{
		klasa_gracza[id] = 0;
		return PLUGIN_CONTINUE;
	}
	
	klasa_gracza[id] = nowa_klasa_gracza[id];
	nowa_klasa_gracza[id] = 0;
	
	WczytajDane(id, klasa_gracza[id]);
	return PLUGIN_CONTINUE;
}

public ZastosujAtrybuty(id)
{
	redukcja_obrazen_gracza[id] = 0.7*(1.0-floatpower(1.1,  -0.112311341*PobierzWytrzymalosc(id, 1, 1, 1)));
	
	maksymalne_zdrowie_gracza[id] = 100.0+PobierzZdrowie(id, 1, 1, 1);
	
	szybkosc_gracza[id] = STANDARDOWA_SZYBKOSC+PobierzKondycje(id, 1, 1, 1)*1.3;
	//szybkosc_gracza[id] = gfCSSpeeds[get_user_weapon(id)]+PobierzKondycje(id, 1, 1, 1);
	
	set_pev(id, pev_health, maksymalne_zdrowie_gracza[id]);
	
	wartosc_grawitacji_gracza[id] = float(PobierzGrawitacje(id, 1, 1, 1))/800
	floatclamp(wartosc_grawitacji_gracza[id], 0.0, 0.5)
	set_user_gravity(id, get_user_gravity(id)-wartosc_grawitacji_gracza[id]);
}

public Regeneracja(id)
{
	new czynnik[MAX_GRACZY+1];
	id -= TASK_WYSZKOLENIE_SANITARNE;
	czynnik[id] = PobierzRegeneracje(id, 1, 1, 1)
	tajmer[id] = czynnik[id]*0.05;
       
	if(!is_user_connected(id))
		return PLUGIN_CONTINUE;
		
	if(is_user_alive(id) && float(get_user_health(id)) > 0.0)
	{
		new Float:cur_health = float(get_user_health(id));
		new Float:max_health = float(PobierzZdrowie(id, 1, 1, 1)+100);
		new Float:new_health;
		
		new_health = cur_health+1.0<max_health? cur_health+1.0: max_health;
		
		set_pev(id, pev_health, new_health)
		
		if(float(get_user_health(id)) < max_health && !task_exists(id))
			set_task(1.5-tajmer[id], "Regeneracja", id+TASK_WYSZKOLENIE_SANITARNE);
	}
	return PLUGIN_CONTINUE;
}

public PoczatekRundy()	
{
	freezetime = false;
	for(new id=0;id<=MAX_GRACZY;id++)
	{
		if(!is_user_alive(id))
			continue;

		//Display_Fade(id, 1<<10, 1<<9, 1<<12, 0, 255, 70, 70);
		if(acg_userstatus(id) && !is_user_bot(id) && is_user_connected(id))
			acg_screenfade(id, 0, 255, 70, 70, 0.2, 0.0, 0.1)
		
		set_task(0.1, "UstawSzybkosc", id+ZADANIE_USTAW_SZYBKOSC);
		
		switch(get_user_team(id))
		{
			case 1: client_cmd(id, "spk QTM_CodMod/start2");
			case 2: client_cmd(id, "spk QTM_CodMod/start");
		}
	}
}

public NowaRunda()
	freezetime = true;
		
public Obrazenia(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_alive(idattacker))
		return HAM_IGNORED;

	if(get_user_team(this) == get_user_team(idattacker))
		return HAM_IGNORED;
		
	if(get_user_health(this) <= 1)
		return HAM_IGNORED;
		
	if(PobierzWytrzymalosc(this, 1, 1, 1) <= 0)
		return HAM_IGNORED;
	
	SetHamParamFloat(4, damage*(1.0-redukcja_obrazen_gracza[this]));
		
	return HAM_IGNORED;
}

public ObrazeniaPost(id, idinflictor, attacker, Float:damage, damagebits)
{
	if(!is_user_connected(attacker) || !klasa_gracza[attacker])
		return HAM_IGNORED;
	
	if(get_user_team(id) != get_user_team(attacker))
	{
		new doswiadczenie_za_obrazenia = get_pcvar_num(cvar_doswiadczenie_za_obrazenia);
		while(damage>25)
		{
			damage -= 25;
			doswiadczenie_gracza[attacker] += doswiadczenie_za_obrazenia;
		}
	}
	if(!task_exists(id+TASK_WYSZKOLENIE_SANITARNE))
		set_task(3.0, "Regeneracja", id+TASK_WYSZKOLENIE_SANITARNE);
		
	SprawdzPoziom(attacker);
	return HAM_IGNORED;
}

public SmiercGraczaPost(id, attacker, shouldgib)
{	
	if(!is_user_connected(attacker))
		return HAM_IGNORED;
	
	if(get_user_team(id) != get_user_team(attacker) && klasa_gracza[attacker])
	{
		new doswiadczenie_za_zabojstwo = get_pcvar_num(cvar_doswiadczenie_za_zabojstwo);
		new nowe_doswiadczenie = get_pcvar_num(cvar_doswiadczenie_za_zabojstwo);
		
		if(poziom_gracza[id] > poziom_gracza[attacker])
			nowe_doswiadczenie += (poziom_gracza[id]-poziom_gracza[attacker])*(doswiadczenie_za_zabojstwo/10);
			
		if(get_user_frags(attacker) > 10)
			doswiadczenie_gracza[attacker] += floatround(nowe_doswiadczenie*1.5, floatround_tozero);
		else
			doswiadczenie_gracza[attacker] += nowe_doswiadczenie
				
		//COD_MSG_EXP_P;
		//show_dhudmessage(attacker, "+%i", nowe_doswiadczenie);
		PokazZdobyteDoswiadczenie(attacker, nowe_doswiadczenie, "Frag");
	}	
	SprawdzPoziom(attacker);
	
	return HAM_IGNORED;
}
	

/*public MessageHealth(msg_id, msg_dest, msg_entity)
{
	static health;
	health = get_msg_arg_int(1);
	
	if (health < 256) return;
	
	if (!(health % 256))
		set_pev(msg_entity, pev_health, pev(msg_entity, pev_health)-1);
	
	set_msg_arg_int(1, get_msg_argtype(1), 255);
}*/

public client_authorized(id)
{
	UsunUmiejetnosci(id);

	get_user_name(id, nazwa_gracza[id], 63);
	
	UsunZadania(id);
	
	set_task(10.0, "PokazReklame", id+ZADANIE_POKAZ_REKLAME);
}

public client_disconnect(id)
{
	ZapiszDane(id);
	UsunUmiejetnosci(id);
	UsunZadania(id);
}

public UsunUmiejetnosci(id)
{
	nowa_klasa_gracza[id] = 0;
	UstawNowaKlase(id);
	klasa_gracza[id] = 0;
	poziom_gracza[id] = 0;
	doswiadczenie_gracza[id] = 0;
	punkty_gracza[id] = 0;
	zdrowie_gracza[id] = 0;
	inteligencja_gracza[id] = 0;
	wytrzymalosc_gracza[id] = 0;
	kondycja_gracza[id] = 0;
	grawitacja_gracza[id] = 0;
	przeladowanie_gracza[id] = 0;
	regeneracja_gracza[id] = 0;
	bonusowe_zdrowie_gracza[id] = 0;
	bonusowa_wytrzymalosc_gracza[id] = 0;
	bonusowa_inteligencja_gracza[id] = 0;
	bonusowa_kondycja_gracza[id] = 0;
	bonusowa_grawitacja_gracza[id] = 0;
	bonusowe_przeladowanie_gracza[id] = 0;
	bonusowa_regeneracja_gracza[id] = 0;
	maksymalne_zdrowie_gracza[id] = 0.0;
	szybkosc_gracza[id] = 0.0;
}

public UsunZadania(id)
{
	remove_task(id+ZADANIE_POKAZ_INFORMACJE);
	remove_task(id+ZADANIE_POKAZ_REKLAME);	
	remove_task(id+ZADANIE_USTAW_SZYBKOSC);
}
	
public WygranaTerro()
	WygranaRunda("TERRORIST");
	
public WygranaCT()
	WygranaRunda("CT");

public WygranaRunda(const Team[])
{
	new Players[32], playerCount, id;
	get_players(Players, playerCount, "aeh", Team);
	new doswiadczenie_za_wygrana = get_pcvar_num(cvar_doswiadczenie_za_wygrana);
		
	for (new i=0; i<playerCount; i++) 
	{
		id = Players[i];
		if(!klasa_gracza[id])
			continue;
		
		if(get_user_frags(id) > 10)
			doswiadczenie_gracza[id] += floatround(doswiadczenie_za_wygrana*1.5, floatround_tozero);
		else
			doswiadczenie_gracza[id] += doswiadczenie_za_wygrana;
			
		//COD_MSG_EXP_N;
		//show_dhudmessage(id, "Wygrana runda^n+%i", doswiadczenie_za_wygrana);
		PokazZdobyteDoswiadczenie(id, doswiadczenie_za_wygrana, "Wygrana Runda")
		
		//client_print(id, print_chat, "[XP MOD] Dostales %i doswiadczenia za wygrana runde.", doswiadczenie_za_wygrana);
		SprawdzPoziom(id);
	}
}

public OpisKlasy(id)
{
	new menu = menu_create("Wybierz Postac:", "OpisKlasy_Handle");
	for(new i=1; i <= ilosc_klas; i++)
		menu_additem(menu, nazwy_klas[i]);
	menu_setprop(menu, MPROP_EXITNAME, "Wyjdz");
	menu_setprop(menu, MPROP_BACKNAME, "Poprzednia strona");
	menu_setprop(menu, MPROP_NEXTNAME, "Nastepna strona");
	menu_display(id, menu);
	
	client_cmd(id, "spk QTM_CodMod/select");
}

public OpisKlasy_Handle(id, menu, item)
{
	client_cmd(id, "spk TM_CodMod/Select");
	
	if(item++ == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	new opis[416+MAX_WIELKOSC_OPISU];
	format(opis, charsmax(opis), "\yImie: \w%s^n\yPseudo: \w%s^n\yInteligencja: \w%i^n\yZdrowie: \w%i^n\yWytrzymalosc: \w%i^n\yKondycja: \w%i^n\yGrawitacja: \w%i^n\yPrzeladowanie: \w%i^n\yRegeneracja: \w%i^n\yOpis: \w%s^n%s", nazwy_klas[item], nazwy_kodowe_klas[item], inteligencja_klas[item], zdrowie_klas[item], wytrzymalosc_klas[item], kondycja_klas[item], grawitacja_klas[item],  przeladowanie_klas[item],  regeneracja_klas[item], opisy_klas[item], opisy_klas[item][79]);
	show_menu(id, 1023, opis);
	
	return PLUGIN_HANDLED;
}

public WybierzKlase(id)
{
	new menu = menu_create("Wybierz Postac:", "WybierzKlase_Handle");
	new klasa[50];
	for(new i=1; i <= ilosc_klas; i++)
	{
		WczytajDane(id, i);
		format(klasa, charsmax(klasa), "%s \r[%s] \yPoziom: %i", nazwy_klas[i], nazwy_kodowe_klas[i], poziom_gracza[id]);
		menu_additem(menu, klasa);
	}
	
	WczytajDane(id, klasa_gracza[id]);
	
	menu_setprop(menu, MPROP_BACKNAME, "Poprzednia strona");
	menu_setprop(menu, MPROP_NEXTNAME, "Nastepna strona");
	menu_setprop(menu, MPROP_EXITNAME, "Wyjdz");
	//menu_setprop(menu, MPROP_PERPAGE, 7);
	menu_display(id, menu);
		
	client_cmd(id, "spk QTM_CodMod/select");
}

public WybierzKlase_Handle(id, menu, item)
{
	client_cmd(id, "spk QTM_CodMod/select");
	
	if(item++ == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}	
	
	if(item == klasa_gracza[id] && !nowa_klasa_gracza[id])
		return PLUGIN_CONTINUE;
	
	nowa_klasa_gracza[id] = item;
	
	if(klasa_gracza[id])
		client_print(id, print_center, "Klasa zostanie zmieniona w nastepnej rundzie.");
	else
	{
		UstawNowaKlase(id);
		ZastosujAtrybuty(id);
	}
	
	return PLUGIN_CONTINUE;
}

public PrzydzielPunkty(id)
{
	new inteligencja[65];
	new zdrowie[60];
	new wytrzymalosc[60];
	new kondycja[60];
	new grawitacja[60];
	new przeladowanie[60];
	new regeneracja[60];
	new tytul[25];
	format(inteligencja, charsmax(inteligencja), "Inteligencja: \r%i\w/25 \y(Zwieksza sile umiejetnosci klasy)", PobierzInteligencje(id, 1, 1, 1));
	format(zdrowie, charsmax(zdrowie), "Zdrowie: \r%i\w/50 \y(Zwieksza HP)", PobierzZdrowie(id, 1, 1, 1));
	format(wytrzymalosc, charsmax(wytrzymalosc), "Wytrzymalosc: \r%i\w/20 \y(Redukuje twoje dmg)", PobierzWytrzymalosc(id, 1, 1, 1));
	format(kondycja, charsmax(kondycja), "Kondycja: \r%i\w/25 \y(Zwieksza tempo chodu)", PobierzKondycje(id, 1, 1, 1));
	format(grawitacja, charsmax(grawitacja), "Grawitacja: \r%i\w/15 \y(Zmniejsza grawitacje)", PobierzGrawitacje(id, 1, 1, 1));
	format(przeladowanie, charsmax(przeladowanie), "Przeladowanie: \r%i\w/20 \y(Przyspiesza przeladowanie broni)", PobierzPrzeladowanie(id, 1, 1, 1));
	format(regeneracja, charsmax(regeneracja), "Regeneracja: \r%i\w/25 \y(Przyspiesza regeneracje zdrowia)", PobierzRegeneracje(id, 1, 1, 1));
	format(tytul, charsmax(tytul), "Przydziel Punkty(%i):", punkty_gracza[id]);
	new menu = menu_create(tytul, "PrzydzielPunkty_Handler");
	menu_additem(menu, inteligencja);
	menu_additem(menu, zdrowie);
	menu_additem(menu, wytrzymalosc);
	menu_additem(menu, kondycja);
	menu_additem(menu, grawitacja);
	menu_additem(menu, przeladowanie);
	menu_additem(menu, regeneracja);
	menu_setprop(menu, MPROP_EXIT, 0);
	menu_display(id, menu);
}

public PrzydzielPunkty_Handler(id, menu, item)
{
	client_cmd(id, "spk TM_CodMod/Select");
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	
	if(punkty_gracza[id] < 1)
		return PLUGIN_CONTINUE;
	
	//new limit_poziomu = get_pcvar_num(cvar_limit_poziomu);
	switch(item) 
	{ 
		case 0: 
		{	
			if(inteligencja_gracza[id] < 25)
			{
				inteligencja_gracza[id]++;
				punkty_gracza[id]--;
			}
			else 
				client_print(id, print_chat, "[XP MOD] Maxymalny poziom inteligencji osiagniety");
		}
		case 1: 
		{	
			if(zdrowie_gracza[id] < 50)
			{
				zdrowie_gracza[id]++;
				punkty_gracza[id]--;
			}
			else 
				client_print(id, print_chat, "[XP MOD] Maxymalny poziom sily osiagniety");
		}
		case 2: 
		{	
			if(wytrzymalosc_gracza[id] < 20)
			{
				wytrzymalosc_gracza[id]++;
				punkty_gracza[id]--;
			}
			else 
				client_print(id, print_chat, "[XP MOD] Maxymalny poziom zrecznosci osiagniety");
		}
		case 3: 
		{	
			if(kondycja_gracza[id] < 25)
			{
				kondycja_gracza[id]++;
				punkty_gracza[id]--;
			}
			else
				client_print(id, print_chat, "[XP MOD] Maxymalny poziom kondycji osiagniety");
		}
		case 4: 
		{	
			if(grawitacja_gracza[id] < 15)
			{
				grawitacja_gracza[id]++;
				punkty_gracza[id]--;
			}
			else
				client_print(id, print_chat, "[XP MOD] Maksymalny poziom grawitacji osiagniety");
		}
		case 5: 
		{	
			if(przeladowanie_gracza[id] < 20)
			{
				przeladowanie_gracza[id]++;
				punkty_gracza[id]--;
			}
			else
				client_print(id, print_chat, "[XP MOD] Maksymalny poziom szybkosci przeladowania osiagniety");
		}
		case 6: 
		{	
			if(regeneracja_gracza[id] < 25)
			{
				regeneracja_gracza[id]++;
				punkty_gracza[id]--;
			}
			else
				client_print(id, print_chat, "[XP MOD] Maksymalny poziom regeneracji osiagniety");
		}
	}
	
	if(punkty_gracza[id] > 0)
		PrzydzielPunkty(id);
		
	return PLUGIN_HANDLED;
}

public KomendaResetujPunkty(id)
{	
	client_print(id, print_chat, "[XP MOD] Umiejetnosci zostana zresetowane.");
	client_cmd(id, "spk TM_CodMod/close");
	
	ResetujPunkty(id);
	
	return PLUGIN_HANDLED
}

public ResetujPunkty(id)
{
	punkty_gracza[id] = (poziom_gracza[id]-1)*2;
	inteligencja_gracza[id] = 0;
	zdrowie_gracza[id] = 0;
	kondycja_gracza[id] = 0;
	wytrzymalosc_gracza[id] = 0;
	grawitacja_gracza[id] = 0;
	przeladowanie_gracza[id] = 0;
	regeneracja_gracza[id] = 0;
	
	if(punkty_gracza[id])
		PrzydzielPunkty(id);
}

public CurWeapon(id)
{
	if(!is_user_connected(id) || !is_user_alive(id))
		return;
		
	new team = get_user_team(id);
	
	if(team > 2)
		return;
		
	UstawSzybkosc(id);
}

public EmitSound(id, iChannel, szSound[], Float:fVol, Float:fAttn, iFlags, iPitch ) 
{
	if(!is_user_alive(id))
		return FMRES_IGNORED;
		
	if(equal(szSound, "common/wpn_denyselect.wav"))
	{
		new forward_handle = CreateOneForward(pluginy_klas[klasa_gracza[id]], "cod_class_skill_used", FP_CELL);
		ExecuteForward(forward_handle, id, id);
		DestroyForward(forward_handle);
		return FMRES_SUPERCEDE;
	}

	/*if(equal(szSound, "items/ammopickup2.wav"))
	{
		cs_set_user_armor(id, 0, CS_ARMOR_NONE);
		return FMRES_SUPERCEDE;
	}*/
	
	return FMRES_IGNORED;
}

public ZapiszDane(id)
{
	if(!klasa_gracza[id])
		return PLUGIN_CONTINUE;
		
	new vaultkey[128],vaultdata[256], identyfikator[64];
	format(vaultdata, charsmax(vaultdata),"#%i#%i#%i#%i#%i#%i#%i#%i#%i", doswiadczenie_gracza[id], poziom_gracza[id], inteligencja_gracza[id], zdrowie_gracza[id], wytrzymalosc_gracza[id], kondycja_gracza[id], grawitacja_gracza[id], przeladowanie_gracza[id], regeneracja_gracza[id]);
	
	new typ_zapisu = get_pcvar_num(cvar_typ_zapisu);
	
	switch(typ_zapisu)
	{
		case 1: copy(identyfikator, charsmax(identyfikator), nazwa_gracza[id]);
		case 2: get_user_authid(id, identyfikator, charsmax(identyfikator));
		case 3: get_user_ip(id, identyfikator, charsmax(identyfikator));
	}
		
	format(vaultkey, charsmax(vaultkey),"%s-%s-%i-2k", identyfikator, nazwy_klas[klasa_gracza[id]], typ_zapisu);
	nvault_set(vault,vaultkey,vaultdata);
	
	return PLUGIN_CONTINUE;
}

public WczytajDane(id, klasa)
{
	new vaultkey[128],vaultdata[256], identyfikator[64];
	
	new typ_zapisu = get_pcvar_num(cvar_typ_zapisu);
	
	switch(typ_zapisu)
	{
		case 1: copy(identyfikator, charsmax(identyfikator), nazwa_gracza[id]);
		case 2: get_user_authid(id, identyfikator, charsmax(identyfikator));
		case 3: get_user_ip(id, identyfikator, charsmax(identyfikator));
	}
	
	format(vaultkey, charsmax(vaultkey),"%s-%s-%i-2k", identyfikator, nazwy_klas[klasa], typ_zapisu);
	

	if(!nvault_get(vault,vaultkey,vaultdata,255)) // Jezeli nie ma danych gracza sprawdza stary zapis. 
	{
		format(vaultkey, charsmax(vaultkey), "%s-%i-2k", nazwa_gracza[id], klasa);
		nvault_get(vault,vaultkey,vaultdata,255);
	}

	replace_all(vaultdata, 255, "#", " ");
	 
	new danegracza[9][32];
	
	parse(vaultdata, danegracza[0], 31, danegracza[1], 31, danegracza[2], 31, danegracza[3], 31, danegracza[4], 31, danegracza[5], 31, danegracza[6], 31, danegracza[7] ,31, danegracza[8], 31);
	
	doswiadczenie_gracza[id] = str_to_num(danegracza[0]);
	poziom_gracza[id] = str_to_num(danegracza[1])>0?str_to_num(danegracza[1]):1;
	inteligencja_gracza[id] = str_to_num(danegracza[2]);
	zdrowie_gracza[id] = str_to_num(danegracza[3]);
	wytrzymalosc_gracza[id] = str_to_num(danegracza[4]);
	kondycja_gracza[id] = str_to_num(danegracza[5]);
	grawitacja_gracza[id] = str_to_num(danegracza[6]);
	przeladowanie_gracza[id] = str_to_num(danegracza[7]);
	regeneracja_gracza[id] = str_to_num(danegracza[8]);
	punkty_gracza[id] = (poziom_gracza[id]-1)*2-inteligencja_gracza[id]-zdrowie_gracza[id]-wytrzymalosc_gracza[id]-kondycja_gracza[id]-grawitacja_gracza[id]-przeladowanie_gracza[id]-regeneracja_gracza[id];
	
	return PLUGIN_CONTINUE;
} 

public SprawdzPoziom(id)
{	
	new limit_poziomu = get_pcvar_num(cvar_limit_poziomu);
	
	new bool:zdobyl_poziom = false, bool:stracil_poziom = false;
	
	while(doswiadczenie_gracza[id] >= PobierzDoswiadczeniePoziomu(poziom_gracza[id]) && poziom_gracza[id] < limit_poziomu)
	{
		poziom_gracza[id]++;
		punkty_gracza[id] = (poziom_gracza[id]-1)*2-inteligencja_gracza[id]-zdrowie_gracza[id]-wytrzymalosc_gracza[id]-kondycja_gracza[id]-grawitacja_gracza[id];
		zdobyl_poziom = true;
	}
		
	while(doswiadczenie_gracza[id] < PobierzDoswiadczeniePoziomu(poziom_gracza[id]-1))
	{
		poziom_gracza[id]--;
		punkty_gracza[id] = (poziom_gracza[id]-1)*2-inteligencja_gracza[id]-zdrowie_gracza[id]-wytrzymalosc_gracza[id]-kondycja_gracza[id]-grawitacja_gracza[id];
		stracil_poziom = true;
	}	
	if(poziom_gracza[id] >= limit_poziomu)
	{
		poziom_gracza[id] = limit_poziomu;
		ResetujPunkty(id);
		COD_MSG_NEWS_P;
		show_hudmessage(id, "Gratulacje !^nZdobyles ostatni 50 poziom ta klasa");
		client_cmd(id, "spk QTM_CodMod/levelup");
	}
	if(stracil_poziom)
	{
		punkty_gracza[id] = (poziom_gracza[id]-1)*2-inteligencja_gracza[id]-zdrowie_gracza[id]-wytrzymalosc_gracza[id]-kondycja_gracza[id]-grawitacja_gracza[id];
		ResetujPunkty(id);
		//client_cmd(id, "spk TM_CodMod/leveldown");
		COD_MSG_NEWS_N;
		ShowSyncHudMsg(id, SyncHudObj2,"Spadles do %i poziomu!", poziom_gracza[id]);
	}
	else if(zdobyl_poziom)
	{
		punkty_gracza[id] = (poziom_gracza[id]-1)*2-inteligencja_gracza[id]-zdrowie_gracza[id]-wytrzymalosc_gracza[id]-kondycja_gracza[id]-grawitacja_gracza[id];
		COD_MSG_NEWS_P;
		ShowSyncHudMsg(id, SyncHudObj2,"Awansowales do %i poziomu!", poziom_gracza[id]);
		client_cmd(id, "spk TM_CodMod/newlvl");
	}		
	ZapiszDane(id);
}

public PokazInformacje(id) 
{
	id -= ZADANIE_POKAZ_INFORMACJE;
		
	if(!is_user_connected(id))
	{
		remove_task(id+ZADANIE_POKAZ_INFORMACJE);
		return PLUGIN_CONTINUE;
	}
	
	if(!is_user_alive(id))
	{
		new target = pev(id, pev_iuser2);
	
		if(!target)
			return PLUGIN_CONTINUE;
			
		set_hudmessage(255, 255, 255, 0.03, 0.93, 0, 0.0, 0.3, 0.0, 0.0, 2);
		ShowSyncHudMsg(id, SyncHudObj2, "Klasa : %s^nPoziom : %i", nazwy_klas[klasa_gracza[target]], poziom_gracza[target]);
		return PLUGIN_CONTINUE;
	}
	new Float:procenpoziom;	
	if(poziom_gracza[id] == 1)
		procenpoziom = doswiadczenie_gracza[id]*100.0/PobierzDoswiadczeniePoziomu(poziom_gracza[id])
	else
		procenpoziom = (doswiadczenie_gracza[id]-PobierzDoswiadczeniePoziomu(poziom_gracza[id]-1))*100.0/(PobierzDoswiadczeniePoziomu(poziom_gracza[id])-PobierzDoswiadczeniePoziomu(poziom_gracza[id]-1))
	
	if(klasa_gracza[id])
	{
		COD_MSG_HUD;
		ShowSyncHudMsg(id, SyncHudObj, "Postac: %s (%i lvl.) | VIP: %s^nEXP: %i / %i (%0.1f%%) | Nowy poziom za: %i dosw.", nazwy_klas[klasa_gracza[id]], poziom_gracza[id], (get_user_frags(id) > 10) ? "TAK" : "NIE", doswiadczenie_gracza[id], PobierzDoswiadczeniePoziomu(poziom_gracza[id]), procenpoziom, (PobierzDoswiadczeniePoziomu(poziom_gracza[id])-doswiadczenie_gracza[id]));
	}
	else
	{
		COD_MSG_HUD;
		ShowSyncHudMsg(id, SyncHudObj, "Nie wybrales zadnej klasy !^nSay /cod, /klasa lub wcisnij / by wybrac postac");
	}
	
	return PLUGIN_CONTINUE;
}

public PokazReklame(id)
{
	id-=ZADANIE_POKAZ_REKLAME;
	//client_print(id, print_chat, "[XP MOD] Say /sklep zeby wymienic swoja gotowke na umiejetnosc");
	client_print(id, print_chat, "[XP MOD] Ten serwer uzywa 2K Mod v%s by =ToRRent= ktory wykorzystuje core QTM_CodMod by Peyote", ver);
	client_print(id, print_chat, "[XP MOD] say /cod lub wcisnij / aby skorzystac z menu modyfikacji");
}

/*public Float:UstawSzybkosc(id)
{
	id -= id>32? ZADANIE_USTAW_SZYBKOSC: 0;
	
	if(klasa_gracza[id] && is_user_alive(id) && !freezetime){
		set_user_maxspeed(id, szybkosc_gracza[id]);
		return szybkosc_gracza[id];
	}
	return 0.0;
}*/

public Float:UstawSzybkosc(id)
{
	id -= id>32? ZADANIE_USTAW_SZYBKOSC: 0;
	
	if(klasa_gracza[id] && is_user_alive(id) && !freezetime)
		set_pev(id, pev_maxspeed, szybkosc_gracza[id]);
}

public UstawDoswiadczenie(id, wartosc)
{
	doswiadczenie_gracza[id] = wartosc;
	SprawdzPoziom(id);
}

public native_PokazDoswiadczenie(id, exp_wartosc, za_co[]) 
{
        param_convert(3);
        PokazZdobyteDoswiadczenie(id, exp_wartosc, za_co);
}

public PokazZdobyteDoswiadczenie(id, exp_wartosc, za_co[])        
{
	new Text_reward[128];
	format(Text_reward, 127, "+%i %s", exp_wartosc, za_co)
	if(koordynat_y[id] < 0.75  && kanal_acg[id] > 8)
	{
		koordynat_y[id] = 0.83
		kanal_acg[id] = 0;
	}
	acg_drawtext(id, 0.54, koordynat_y[id], Text_reward, 255, 255, 60, 255, 0.1, 0.5, 3.5, 0, TS_NONE, 1, 0, kanal_acg[id])
	koordynat_y[id] -= 0.01
	kanal_acg[id]++;
}
	
public UstawKlase(id, klasa, zmien)
{
	nowa_klasa_gracza[id] = klasa;
	if(zmien)
	{
		UstawNowaKlase(id);
		ZastosujAtrybuty(id);
	}
}

public UstawBonusoweZdrowie(id, wartosc)
	bonusowe_zdrowie_gracza[id] = wartosc;

public UstawBonusowaInteligencje(id, wartosc)
	bonusowa_inteligencja_gracza[id] = wartosc;

public UstawBonusowaKondycje(id, wartosc)
	bonusowa_kondycja_gracza[id] = wartosc;
	
public UstawBonusowaWytrzymalosc(id, wartosc)
	bonusowa_wytrzymalosc_gracza[id] = wartosc;
	
public UstawBonusowaGrawitacje(id, wartosc)
	bonusowa_grawitacja_gracza[id] = wartosc;
	
public UstawBonusowePrzeladowanie(id, wartosc)
	bonusowe_przeladowanie_gracza[id] = wartosc;
	
public UstawBonusowaRegeneracje(id, wartosc)
	bonusowa_regeneracja_gracza[id] = wartosc;

public PrzydzielZdrowie(id, wartosc)
{
	//new max_statystyka = get_pcvar_num(cvar_limit_poziomu)/2;
	wartosc = min(min(punkty_gracza[id], wartosc), 50-zdrowie_gracza[id]-zdrowie_klas[klasa_gracza[id]]);
	
	punkty_gracza[id] -= wartosc;
	zdrowie_gracza[id] += wartosc;
}

public PrzydzielInteligencje(id, wartosc)
{
	//new max_statystyka = get_pcvar_num(cvar_limit_poziomu)/2;
	wartosc = min(min(punkty_gracza[id], wartosc), 25-inteligencja_gracza[id]-inteligencja_klas[klasa_gracza[id]]);
	
	punkty_gracza[id] -= wartosc;
	inteligencja_gracza[id] += wartosc;
}

public PrzydzielKondycje(id, wartosc)
{
	//new max_statystyka = get_pcvar_num(cvar_limit_poziomu)/2;
	wartosc = min(min(punkty_gracza[id], wartosc),25-kondycja_gracza[id]-kondycja_klas[klasa_gracza[id]]);
	
	punkty_gracza[id] -= wartosc;
	kondycja_gracza[id] += wartosc;
}

public PrzydzielWytrzymalosc(id, wartosc)
{
	//new max_statystyka = get_pcvar_num(cvar_limit_poziomu)/2;
	wartosc = min(min(punkty_gracza[id], wartosc), 20-wytrzymalosc_gracza[id]-wytrzymalosc_klas[klasa_gracza[id]]);
	
	punkty_gracza[id] -= wartosc;
	wytrzymalosc_gracza[id] += wartosc;
}

public PrzydzielGrawitacje(id, wartosc)
{
	//new max_statystyka = get_pcvar_num(cvar_limit_poziomu);
	wartosc = min(min(punkty_gracza[id], wartosc), 15-grawitacja_gracza[id]-grawitacja_klas[klasa_gracza[id]]);
	
	punkty_gracza[id] -= wartosc;
	grawitacja_gracza[id] += wartosc;
}

public PrzydzielPrzeladowanie(id, wartosc)
{
	//new max_statystyka = get_pcvar_num(cvar_limit_poziomu);
	wartosc = min(min(punkty_gracza[id], wartosc), 20-przeladowanie_gracza[id]-przeladowanie_klas[klasa_gracza[id]]);
	
	punkty_gracza[id] -= wartosc;
	przeladowanie_gracza[id] += wartosc;
}

public PrzydzielRegeneracje(id, wartosc)
{
	//new max_statystyka = get_pcvar_num(cvar_limit_poziomu);
	wartosc = min(min(punkty_gracza[id], wartosc), 25-regeneracja_gracza[id]-regeneracja_klas[klasa_gracza[id]]);
	
	punkty_gracza[id] -= wartosc;
	regeneracja_gracza[id] += wartosc;
}

public PobierzDoswiadczeniePoziomu(poziom)
	return power(poziom, 2)*get_pcvar_num(cvar_proporcja_poziomu);

public PobierzDoswiadczenie(id)
	return doswiadczenie_gracza[id];
	
public PobierzPunkty(id)
	return punkty_gracza[id];
	
public PobierzPoziom(id)
	return poziom_gracza[id];

public PobierzZdrowie(id, zdrowie_zdobyte, zdrowie_klasy, zdrowie_bonusowe)
{
	new zdrowie;
	
	if(zdrowie_zdobyte)
		zdrowie += zdrowie_gracza[id];
	if(zdrowie_bonusowe)
		zdrowie += bonusowe_zdrowie_gracza[id];
	if(zdrowie_klasy)
		zdrowie += zdrowie_klas[klasa_gracza[id]];
	
	return zdrowie;
}

public PobierzInteligencje(id, inteligencja_zdobyta, inteligencja_klasy, inteligencja_bonusowa)
{
	new inteligencja;
	
	if(inteligencja_zdobyta)
		inteligencja += inteligencja_gracza[id];
	if(inteligencja_bonusowa)
		inteligencja += bonusowa_inteligencja_gracza[id];
	if(inteligencja_klasy)
		inteligencja += inteligencja_klas[klasa_gracza[id]];
	
	return inteligencja;
}

public PobierzKondycje(id, kondycja_zdobyta, kondycja_klasy, kondycja_bonusowa)
{
	new kondycja;
	
	if(kondycja_zdobyta)
		kondycja += kondycja_gracza[id];
	if(kondycja_bonusowa)
		kondycja += bonusowa_kondycja_gracza[id];
	if(kondycja_klasy)
		kondycja += kondycja_klas[klasa_gracza[id]];
	
	return kondycja;
}

public PobierzWytrzymalosc(id, wytrzymalosc_zdobyta, wytrzymalosc_klasy, wytrzymalosc_bonusowa)
{
	new wytrzymalosc;
	
	if(wytrzymalosc_zdobyta)
		wytrzymalosc += wytrzymalosc_gracza[id];
	if(wytrzymalosc_bonusowa)
		wytrzymalosc += bonusowa_wytrzymalosc_gracza[id];
	if(wytrzymalosc_klasy)
		wytrzymalosc += wytrzymalosc_klas[klasa_gracza[id]];
	
	return wytrzymalosc;
}

public PobierzGrawitacje(id, grawitacja_zdobyta, grawitacja_klasy, grawitacja_bonusowa)
{
	new grawitacja;
	
	if(grawitacja_zdobyta)
		grawitacja += grawitacja_gracza[id];
	if(grawitacja_bonusowa)
		grawitacja += bonusowa_grawitacja_gracza[id];
	if(grawitacja_klasy)
		grawitacja += grawitacja_klas[klasa_gracza[id]];
	
	return grawitacja;
}

public PobierzPrzeladowanie(id, przeladowanie_zdobyte, przeladowanie_klasy, przeladowanie_bonusowe)
{
	new przeladowanie;
	
	if(przeladowanie_zdobyte)
		przeladowanie += przeladowanie_gracza[id];
	if(przeladowanie_bonusowe)
		przeladowanie += bonusowe_przeladowanie_gracza[id];
	if(przeladowanie_klasy)
		przeladowanie += przeladowanie_klas[klasa_gracza[id]];
	
	return przeladowanie;
}

public PobierzRegeneracje(id, regeneracja_zdobyta, regeneracja_klasy, regeneracja_bonusowa)
{
	new regeneracja;
	
	if(regeneracja_zdobyta)
		regeneracja += regeneracja_gracza[id];
	if(regeneracja_bonusowa)
		regeneracja += bonusowa_regeneracja_gracza[id];
	if(regeneracja_klasy)
		regeneracja += regeneracja_klas[klasa_gracza[id]];
	
	return regeneracja;
}

public PobierzKlase(id)
	return klasa_gracza[id];
	
public PobierzIloscKlas()
	return ilosc_klas;
	
public PobierzNazweKlasy(klasa, Return[], len)
{
	if(klasa <= ilosc_klas)
	{
		param_convert(2);
		copy(Return, len, nazwy_klas[klasa]);
	}
}

public PobierzOpisKlasy(klasa, Return[], len)
{
	if(klasa <= ilosc_klas)
	{
		param_convert(2);
		copy(Return, len, opisy_klas[klasa]);
	}
}

public PobierzKlasePrzezNazwe(const nazwa[])
{
	param_convert(1);
	for(new i=1; i <= ilosc_klas; i++)
		if(equal(nazwa, nazwy_klas[i]))
			return i;
	return 0;
}

public PobierzZdrowieKlasy(klasa)
{
	if(klasa <= ilosc_klas)
		return zdrowie_klas[klasa];
	return -1;
}

public PobierzInteligencjeKlasy(klasa)
{
	if(klasa <= ilosc_klas)
		return inteligencja_klas[klasa];
	return -1;
}

public PobierzKondycjeKlasy(klasa)
{
	if(klasa <= ilosc_klas)
		return kondycja_klas[klasa];
	return -1;
}

public PobierzWytrzymaloscKlasy(klasa)
{
	if(klasa <= ilosc_klas)
		return wytrzymalosc_klas[klasa];
	return -1;
}

public PobierzGrawitacjeKlasy(klasa)
{
	if(klasa <= ilosc_klas)
		return grawitacja_klas[klasa];
	return -1;
}

public PobierzPrzeladowanieKlasy(klasa)
{
	if(klasa <= ilosc_klas)
		return przeladowanie_klas[klasa];
	return -1;
}

public PobierzRegeneracjeKlasy(klasa)
{
	if(klasa <= ilosc_klas)
		return regeneracja_klas[klasa];
	return -1;
}

public ZadajObrazenia(atakujacy, ofiara, Float:obrazenia, Float:czynnik_inteligencji, byt_uszkadzajacy, dodatkowe_flagi)
	ExecuteHam(Ham_TakeDamage, ofiara, byt_uszkadzajacy, atakujacy, obrazenia+PobierzInteligencje(atakujacy, 1, 1, 1)*czynnik_inteligencji, (1<<31)|dodatkowe_flagi);

public ZarejestrujKlase(plugin, params)
{
	if(params != 10)
		return PLUGIN_CONTINUE;
		
	if(++ilosc_klas > MAX_ILOSC_KLAS)
		return -1;

	pluginy_klas[ilosc_klas] = plugin;
	
	get_string(1, nazwy_klas[ilosc_klas], MAX_WIELKOSC_NAZWY);
	get_string(2, opisy_klas[ilosc_klas], MAX_WIELKOSC_OPISU);
	get_string(10, nazwy_kodowe_klas[ilosc_klas], MAX_WIELKOSC_NAZWY);
	
	grawitacja_klas[ilosc_klas] = get_param(3);
	zdrowie_klas[ilosc_klas] = get_param(4);
	kondycja_klas[ilosc_klas] = get_param(5);
	inteligencja_klas[ilosc_klas] = get_param(6);
	wytrzymalosc_klas[ilosc_klas] = get_param(7);
	przeladowanie_klas[ilosc_klas] = get_param(8);
	regeneracja_klas[ilosc_klas] = get_param(9);
	
	return ilosc_klas;
}

stock fm_give_item(index, const item[]) {
	if (!equal(item, "weapon_", 7) && !equal(item, "ammo_", 5) && !equal(item, "item_", 5) && !equal(item, "tf_weapon_", 10))
		return 0;

	new ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, item));
	if (!pev_valid(ent))
		return 0;

	new Float:origin[3];
	pev(index, pev_origin, origin);
	set_pev(ent, pev_origin, origin);
	set_pev(ent, pev_spawnflags, pev(ent, pev_spawnflags) | SF_NORESPAWN);
	dllfunc(DLLFunc_Spawn, ent);

	new save = pev(ent, pev_solid);
	dllfunc(DLLFunc_Touch, ent, index);
	if (pev(ent, pev_solid) != save)
		return ent;

	engfunc(EngFunc_RemoveEntity, ent);

	return -1;
}
