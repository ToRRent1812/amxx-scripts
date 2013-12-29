#include <amxmodx>
#include <amxmisc>
#include <torreinc>
#include <fakemeta>
#include <acg>

#define MAX 20

new const nazwa[] = "Szymon [VIP]";
new const nazwa_kodowa[] = "Mysie Pysie";
new const opis[] = "1/8 szans na nacpanie przeciwnika po trafieniu, za kazdego fraga pelen magazynek"
new const grawitacja = 10;
new const zdrowie = 15;
new const inteligencja = 10;
new const kondycja = 15;
new const wytrzymalosc = 5;
new const przeladowanie = 20;
new const regeneracja = 5;

new const maxClip[31] = { -1, 13, -1, 10,  1,  7,  1,  30, 30,  1,  30,  20,  25, 30, 35, 25,  12,  20, 
10,  30, 100,  8, 30,  30, 20,  2,  7, 30, 30, -1,  50 };

new bool:ma_klase[ MAX + 1 ],gmsg_SetFOV;

new mapname[32];

public plugin_init()
{
	register_plugin(nazwa, "0.6", "ToRRent")
	
	cod_register_class(nazwa, opis, grawitacja, zdrowie, kondycja, inteligencja, wytrzymalosc, przeladowanie, regeneracja, nazwa_kodowa);
	
	register_event("Damage", "Damage", "b", "2!=0");
	
	gmsg_SetFOV = get_user_msgid("SetFOV");
	//register_forward(FM_CmdStart, "CmdStart");
	register_event("DeathMsg", "DeathMsg", "ade");
	get_mapname(mapname, 31)
}

public plugin_precache()
{	
	precache_generic("gfx/szymon_efekt.tga")
}

public cod_class_enabled( id )
{
	if(!(get_user_frags(id) > 10 ) && !is_user_bot(id))
	{
		client_print(id, print_center, "%s Dostepny od zdobycia 10 fragow na mapie", nazwa);
		client_cmd(id, "say /klasa");
		return COD_STOP;
	}
	else
	{
		if(equali(mapname, "gg_", 3) || equali(mapname, "aim_", 4) || equali(mapname, "fun_", 4) || equali(mapname, "awp_", 4))
		{
			return COD_CONTINUE;
		}
		else
		{
			acg_drawtext(id, 0.04, 0.69, "Traf w przeciwnika by go nacpac na 5 sek.^nMasz na to 1/8 szans", 0, 212, 255, 255, 0.0, 2.5, 4.5, 0, TS_NONE, 0, 1, 11)
		}
	}
	ma_klase[id] = true;
	
	return COD_CONTINUE;
}

public cod_class_disabled( id )
	ma_klase [ id ] = false;

public Damage(id)
{      
	if(equali(mapname, "gg_", 3) || equali(mapname, "aim_", 4) || equali(mapname, "fun_", 4) || equali(mapname, "awp_", 4))
		return;
		
	new kid = get_user_attacker(id) // Gracz atakujacy
	
	if( ma_klase [ kid ] && random_num( 1 , 8 ) == 1 && get_user_team(kid) != get_user_team(id))
	{
		if(kid != id)
		{
			if(is_user_connected(id) && is_user_connected(kid) && is_user_alive(id))
			{
				client_cmd(id,"default_fov 50")
				//COD_MSG_SKILL_D;
				//show_hudmessage(id, "Szymon cie nacpal !! Efekt zniknie po 5 sek.")
				acg_drawtext(id, 0.04, 0.69, "Szymon cie nacpal !! Efekt zniknie po 5 sek.", 0, 212, 255, 255, 0.0, 2.5, 4.5, 0, TS_NONE, 0, 1, 12)
		
				message_begin( MSG_ONE, gmsg_SetFOV, { 0, 0, 0 }, id )
				write_byte( 140 )
				message_end( )
				acg_drawtga(id, "gfx/szymon_efekt.tga", 255, 255, 255, 250, 0.0, 0.0, 0, FX_FADE_INTERVAL, 1.0, 3.0, 1.5, 5.0, DRAW_ADDITIVE, 1, 1, -1);
		
				remove_task( id );
		
				set_task( 5.0 , "backToNormal" , id )
			}
		}
	}
	//kid = 0 // jak tego nie dam to jest index out of bounds :O
	//id = 0
}

public backToNormal( id ){
	
	if(is_user_connected(id))
	{
		client_cmd(id,"default_fov 90")
	
		message_begin( MSG_ONE, gmsg_SetFOV, { 0, 0, 0 }, id )
		write_byte( 90 )
		message_end( )
	}
	//id = 0
}

public DeathMsg()
{
	if(equali(mapname, "gg_", 3) || equali(mapname, "aim_", 4) || equali(mapname, "fun_", 4) || equali(mapname, "awp_", 4))
		return PLUGIN_CONTINUE;
		
	new killer = read_data(1);
	if(!is_user_connected(killer))
		return PLUGIN_CONTINUE;
	
	if(ma_klase[killer])
	{
		new weapon = get_user_weapon(killer);
		if(maxClip[weapon] != -1)
			set_user_clip(killer, maxClip[weapon]);
	}
	return PLUGIN_CONTINUE;
}

stock set_user_clip(id, ammo)
{
	new weaponname[32], weaponid = -1, weapon = get_user_weapon(id, _, _);
	get_weaponname(weapon, weaponname, 31);
	while ((weaponid = engfunc(EngFunc_FindEntityByString, weaponid, "classname", weaponname)) != 0)
		if (pev(weaponid, pev_owner) == id) {
		set_pdata_int(weaponid, 51, ammo, 4);
		return weaponid;
	}
	return 0;
}
