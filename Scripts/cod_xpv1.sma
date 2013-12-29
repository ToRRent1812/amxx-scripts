#include <amxmodx>
#include <torreinc>
//#include <dhudmessage>

new const msg[][] = { "Podlozenie paki", "Rozbrojenie paki"}

new cod_cvars[2];

public plugin_init() {
	register_plugin("cod_xp", "1.1", "byQQ");
	
	register_logevent("logevent_przydziel", 3, "1=triggered");
	
	cod_cvars[0] = register_cvar("cod_plantxp", "25");
	cod_cvars[1] = register_cvar("cod_defusxp", "25");
}

public logevent_przydziel()
{
	new loguser[80], akcja[64], name[32];
	read_logargv(0, loguser, 79);
	read_logargv(2, akcja, 63);
	parse_loguser(loguser, name, 31);
	
	new id = get_user_index(name);
	
	if(equal(akcja, "Planted_The_Bomb")) { PrzydzielExp(id, 0); }
	else if(equal(akcja, "Defused_The_Bomb")) { PrzydzielExp(id, 1); }
}

public PrzydzielExp(id, typ)
{
	new exp = get_pcvar_num(cod_cvars[typ]); 
	
	if(get_playersnum() >= 3)
	{
		if(get_user_frags(id) > 10)
		{
			cod_set_user_xp(id, cod_get_user_xp(id) + exp + 5);
			new wiado[128]
			format(wiado, 127, "%s", msg[typ])
			cod_show_exp_reward(id, exp+5, wiado)
			//COD_MSG_EXP_N;
			//show_dhudmessage(id, "%s^n+%i", msg[typ], exp+5);
		}
		else
		{
			cod_set_user_xp(id, cod_get_user_xp(id) + exp);
			new wiado[128]
			format(wiado, 127, "%s", msg[typ])
			cod_show_exp_reward(id, exp, wiado)
			//COD_MSG_EXP_N;
			//show_dhudmessage(id, "%s^n+%i", msg[typ], exp);
		}
		//client_print(id, print_chat, "[COD:MW] Dostales %d doswiadczenia za %s.", exp, msg[typ]);
	}
}
