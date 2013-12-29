#include <amxmodx>
#include <amxmisc>
#include <codmod>

#define PLUGIN "COD MOTS Stats"
#define VERSION "1.0"
#define AUTHOR "Hleb & DarkGL"


new Float: redukcja_obrazen_gracza[33];
new Float: procent_szybkosci[33];
public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_clcmd("say /stats", "PokazStatyMOTD");
}

public PokazStatyMOTD(id)
{	
	new nazwa[33];
	cod_get_class_name(cod_get_user_class(id), nazwa, charsmax(nazwa))
	redukcja_obrazen_gracza[id] = 0.7*(1.0-floatpower(1.1, -0.112311341*cod_get_user_stamina(id, 1, 1, 1)))
	procent_szybkosci[id] = (250.0+cod_get_user_trim(id, 1,1,1)*1.3)/2.5;
	static host_name[32];
	get_cvar_string("hostname", host_name, 31);
	
	static motd[1501], len;
	
	len = format(motd, 1500,"<body bgcolor=#2F4F4F><font color=#87cefa><pre>");
	len += format(motd[len], 1500-len,"<center><h4><font color=^"blue^"> Twoje statystyki serwera: '%s' </font></h4></center>", host_name);
	len += format(motd[len], 1500-len,"<left><font color=^"red^"><B>Klasa: </B><font color=^"white^">%s</color></left>^n", nazwa);
	len += format(motd[len], 1500-len,"<left><font color=^"red^"><B>Poziom: </B><font color=^"white^">%i</color></left>^n^n", cod_get_user_level(id));
	len += format(motd[len], 1500-len,"<left><font color=^"red^"><B>Inteligencja: </B><font color=^"white^">%i</color></left>^n", cod_get_user_intelligence(id, 1, 1, 1));
	len += format(motd[len], 1500-len,"<left><font color=^"red^"><B>Zdrowie: </B> <font color=^"white^">%i</color></B></left>^n", cod_get_user_health(id, 1,1,1));
	len += format(motd[len], 1500-len,"<left><font color=^"red^"><B>Wytrzymalosc: </B><font color=^"white^">%i</color></B></left>^n", cod_get_user_stamina(id, 1,1,1));
	len += format(motd[len], 1500-len,"<left><font color=^"red^"><B>Kondycja: </B><font color=^"white^">%i</color></B></left>^n", cod_get_user_trim(id, 1,1,1));
	len += format(motd[len], 1500-len,"<left><font color=^"red^"><B>Na start masz <font color=^"white^">%i <font color=^"red^">HP</color></B></left>^n", 100+cod_get_user_health(id, 1,1,1));
	len += format(motd[len], 1500-len,"<left><font color=^"red^"><B>Redukcja obrazen o <font color=^"white^">%0.1f<font color=^"red^"> procent</color></B></left>^n", redukcja_obrazen_gracza[id]*100.0);
	if(cod_get_user_trim(id, 1,1,1) >= 0)
		len += format(motd[len], 1500-len,"<left><font color=^"red^"><B>Jestes szybszy o <font color=^"white^">%0.1f<font color=^"red^"> procent</color></B></left>^n", procent_szybkosci[id]-100.0);
	else
		len += format(motd[len], 1500-len,"<left><font color=^"red^"><B>Jestes wolniejszy o <font color=^"white^">%0.1f<font color=^"red^"> procent</color></B></left>^n", ((procent_szybkosci[id]-100.0)*-1.0));
	if(cod_get_user_class(id) == cod_get_classid("Demolitions"))
	{
		len += format(motd[len], 1500-len,"^n<left><font color=^"red^"><B>Klasa: </B><font color=^"white^">Demolitions</color></left>^n");
		len += format(motd[len], 1500-len,"<left><font color=^"red^"><B>Jego dynamit zadaje </B><font color=^"white^">%0.1f DMG</color></left>^n", 95.0+(cod_get_user_intelligence(id, 1, 1, 1)*0.8));
	}
	if(cod_get_user_class(id) == cod_get_classid("Medyk"))
	{
		len += format(motd[len], 1500-len,"^n<left><font color=^"red^"><B>Klasa:  </B><font color=^"white^">Medyk</color></left>^n");
		len += format(motd[len], 1500-len,"<left><font color=^"red^"><B>Impuls apteczki regeneruje </B><font color=^"white^">%0.1f HP</color></left>^n", 5.0+(cod_get_user_intelligence(id, 1, 1, 1)*0.5));
	}
	if(cod_get_user_class(id) == cod_get_classid("Wsparcie Ogniowe"))
	{
		len += format(motd[len], 1500-len,"^n<left><font color=^"red^"><B>Klasa: </B><font color=^"white^">Wsparcie Ogniowe</color></left>^n");
		len += format(motd[len], 1500-len,"<left><font color=^"red^"><B>Jego rakieta zadaje </B><font color=^"white^">%0.1f DMG</color></left>^n", 55.0+(cod_get_user_intelligence(id, 1, 1, 1)*0.9));
	}
	if(cod_get_user_class(id) == cod_get_classid("Saper"))
	{
		len += format(motd[len], 1500-len,"^n<left><font color=^"red^"><B>Klasa: </B><font color=^"white^">Saper</color></left>^n");
		len += format(motd[len], 1500-len,"<left><font color=^"red^"><B>Jego mina zadaje </B><font color=^"white^">%0.1f DMG</color></left>^n", 70.0+(cod_get_user_intelligence(id, 1, 1, 1)*0.8));
	}
	if(cod_get_user_perk(id) == cod_get_perkid("Narzedzia Demolitions"))
	{
		len += format(motd[len], 1500-len,"^n<left><font color=^"red^"><B>Perk: </B><font color=^"white^">Narzedzia Demolitions</color></left>^n");
		len += format(motd[len], 1500-len,"<left><font color=^"red^"><B>Jego dynamit zadaje </B><font color=^"white^">%0.1f DMG</color></left>^n", 95.0+(cod_get_user_intelligence(id, 1, 1, 1)*0.8));
	}
	if(cod_get_user_perk(id) == cod_get_perkid("Modul Odrzutowy"))
	{
		len += format(motd[len], 1500-len,"^n<left><font color=^"red^"><B>Perk: </B><font color=^"white^">Modul Odrzutowy</color></left>^n");
		len += format(motd[len], 1500-len,"<left><font color=^"red^"><B>Wyrzuca cie z predkoscia </B><font color=^"white^">%0.1f units/sec</color></left>^n", 666.0+float(cod_get_user_intelligence(id, 1, 1, 1)));
	}
	if(cod_get_user_perk(id) == cod_get_perkid("Naboje Pulkownika"))
	{
		len += format(motd[len], 1500-len,"^n<left><font color=^"red^"><B>Perk: </B><font color=^"white^">Naboje Pulkownika</color></left>^n");
		len += format(motd[len], 1500-len,"<left><font color=^"red^"><B>Zadajesz </B><font color=^"white^">%0.1f<font color=^"red^"><B> obrazen wiecej</B></color></left>^n", 10.0+(cod_get_user_intelligence(id, 1, 1, 1)*0.25));
	}
	if(cod_get_user_perk(id) == cod_get_perkid("Notatki Sapera"))
	{
		len += format(motd[len], 1500-len,"^n<left><font color=^"red^"><B>Perk: </B><font color=^"white^">Notatki Sapera</color></left>^n");
		len += format(motd[len], 1500-len,"<left><font color=^"red^"><B>Jego mina zadaje </B><font color=^"white^">%0.1f DMG</color></left>^n", 70.0+(cod_get_user_intelligence(id, 1, 1, 1)*0.8));
	}
	if(cod_get_user_perk(id) == cod_get_perkid("Podrecznik Szpiega"))
	{
		len += format(motd[len], 1500-len,"^n<left><font color=^"red^"><B>Perk: </B><font color=^"white^">Podrecznik Szpiega</color></left>^n");
		len += format(motd[len], 1500-len,"<left><font color=^"red^"><B>Granat zadaje </B><font color=^"white^">%0.1f DMG</color></left>^n", 101.0+float(cod_get_user_intelligence(id, 1, 1, 1)));
	}
	if(cod_get_user_perk(id) == cod_get_perkid("Rozblysk"))
	{
		len += format(motd[len], 1500-len,"^n<left><font color=^"red^"><B>Perk: </B><font color=^"white^">Rozblysk</color></left>^n");
		len += format(motd[len], 1500-len,"<left><font color=^"red^"><B>Zasieg razenia to </B><font color=^"white^">%0.1f units</color></left>^n", 250.0+(cod_get_user_intelligence(id, 1, 1, 1)*1.0));
	}
	if(cod_get_user_perk(id) == cod_get_perkid("Wyposazenie Wsparcia"))
	{
		len += format(motd[len], 1500-len,"^n<left><font color=^"red^"><B>Perk: </B><font color=^"white^">Wyposazenie Wsparcia</color></left>^n");
		len += format(motd[len], 1500-len,"<left><font color=^"red^"><B>Jego rakieta zadaje </B><font color=^"white^">%0.1f DMG</color></left>^n", 55.0+(cod_get_user_intelligence(id, 1, 1, 1)*0.9));
	}
	if(cod_get_user_perk(id) == cod_get_perkid("Tajemnica Generala"))
	{
		len += format(motd[len], 1500-len,"^n<left><font color=^"red^"><B>Perk: </B><font color=^"white^">Tajemnica Generala</color></left>^n");
		len += format(motd[len], 1500-len,"<left><font color=^"red^"><B>Granat zadaje </B><font color=^"white^">%0.1f DMG</color></left>^n", 101.0+float(cod_get_user_intelligence(id, 1, 1, 1)));
	}
	if(cod_get_user_perk(id) == cod_get_perkid("Tytanowe Naboje"))
	{
		len += format(motd[len], 1500-len,"^n<left><font color=^"red^"><B>Perk: </B><font color=^"white^">Tytanowe Naboje</color></left>^n");
		len += format(motd[len], 1500-len,"<left><font color=^"red^"><B>Zadajesz </B><font color=^"white^">%0.1f<font color=^"red^"><B> obrazen wiecej</B></color></left>^n", 5.0+(cod_get_user_intelligence(id, 1, 1, 1)*0.25));
	}
	show_motd(id, motd, "COD:MW MOD STATS!!");
	
	return 0;
}

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
