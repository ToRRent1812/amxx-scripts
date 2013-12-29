#include <amxmodx>
#include <torreinc>
#include <colorchat>

#define PLUGIN "[COD] EXP dla najlepszych 3 graczy"
#define VERSION "0.9"
#define AUTHOR "pRED (edit by =ToRRent=)"

// Dla tych nie kumatych ;) jest to przerobiony plugin bf2medals autorstwa pRED

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	register_cvar("cod_exp1", "200"); // ilosc doswiadczenia za 1 miejsce 
	register_cvar("cod_exp2", "100"); // ilosc doswiadczenia za 2 miejsce 
	register_cvar("cod_exp3", "50"); // ilosc doswiadczenia za 3 miejsce
	
	set_task(0.1, "przyznanie_doswiadczenia", _, _, _, "c")
}
public przyznanie_doswiadczenia()
{
	//uruchom tuz przed zmiana mapy
	//Znajdz 3 najlepszych graczy z najwieksza liczba fragow i przyznaj doswiadczenie

	new players[32], num;
	get_players(players, num, "h");

	new tempfrags, id;

	new swapfrags, swapid;

	new starfrags[3]; //0 - 3 miejsce / 1 - 2 miejsce / 2 - 1 miejsce
	new starid[3];

	for (new i = 0; i < num; i++)
	{
		id = players[i];
		tempfrags = get_user_frags(id);
		if ( tempfrags > starfrags[0] )
		{
			starfrags[0] = tempfrags;
			starid[0] = id;
			cod_set_user_xp(starid[0], cod_get_user_xp(starid[0])+get_cvar_num("cod_exp3"));
			if ( tempfrags > starfrags[1] )
			{
				swapfrags = starfrags[1];
				swapid = starid[1];
				starfrags[1] = tempfrags;
				starid[1] = id;
				starfrags[0] = swapfrags;
				starid[0] = swapid;
				cod_set_user_xp(starid[1], cod_get_user_xp(starid[1])+get_cvar_num("cod_exp2"));

				if ( tempfrags > starfrags[2] )
				{
					swapfrags = starfrags[2];
					swapid = starid[2];
					starfrags[2] = tempfrags;
					starid[2] = id;
					starfrags[1] = swapfrags;
					starid[1] = swapid;
					cod_set_user_xp(starid[2], cod_get_user_xp(starid[2])+get_cvar_num("cod_exp1"));

				}
			}
		}
	}
	new name[32];
	new winner = starid[2];

	if ( !winner )
		return;

	ColorChat(0, GREY, "Najlepsi gracze na tej mapie:")
	get_user_name(starid[2], name, charsmax(name));
	ColorChat(0, GREEN, "1. %s - %i Fragow (+%d dosw.)", name, starfrags[2], get_cvar_num("cod_exp1"));

	get_user_name(starid[1], name, charsmax(name));
	ColorChat(0, GREEN, "2. %s - %i Fragow (+%d dosw.)", name, starfrags[1], get_cvar_num("cod_exp2"));

	get_user_name(starid[0], name, charsmax(name));
	ColorChat(0, GREEN, "3. %s - %i Fragow (+%d dosw.)", name, starfrags[0], get_cvar_num("cod_exp3"));
}
