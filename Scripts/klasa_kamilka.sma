#include <amxmodx>
#include <hamsandwich>
#include <torreinc>
#include <engine>
#include <fakemeta_util>
#include <acg>

#define MAX 20
native cod_add_wskrzes(id, ile)

new sprite_white;
new ilosc_apteczek_gracza[MAX + 1];

new const nazwa[] = "Kamilka [VIP]";
new const nazwa_kodowa[] = "Debile";
new const opis[] = "Posiada apteczke oraz defibrylator ktorym moze wskrzeszac";
new const grawitacja = 0;
new const zdrowie = 30;
new const kondycja = 5;
new const inteligencja = 0;
new const wytrzymalosc = 20;
new const przeladowanie = 0;
new const regeneracja = 25;

new ma_klase[MAX + 1];
new mapname[32];

/*new const medkit_icon_spr[] = "sprites/heal.spr";
new g_medkit_icon_id;*/

public plugin_init() 
{	
	register_plugin("Kamilka", "1.0", "ToRRent");
	
	cod_register_class(nazwa, opis, grawitacja, zdrowie, kondycja, inteligencja, wytrzymalosc,przeladowanie, regeneracja, nazwa_kodowa);
	
	register_think("medkit","MedkitThink");
	RegisterHam(Ham_Spawn, "player", "Spawn", 1);
	
	get_mapname(mapname, 31)
}

public plugin_precache()
{
	sprite_white = precache_model("sprites/white.spr");
	precache_model("models/w_medkit.mdl");
	//g_medkit_icon_id = engfunc(EngFunc_PrecacheModel, medkit_icon_spr)
}

public cod_class_enabled(id)
{
	if(!(get_user_frags(id) > 10 ) && !is_user_bot(id))
	{
		client_print(id, print_center, "%s Dostepna od zdobycia 10 fragow na mapie", nazwa);
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
			acg_drawtext(id, 0.04, 0.69, "Aby postawic na mapie apteczke, stojac wcisnij USE (domyslnie E)^nAby wskrzesic kumpla / Usunac cialo wroga naceluj na niego, i kucajac wcisnij USE", 0, 212, 255, 255, 0.0, 2.5, 4.5, 0, TS_NONE, 0, 1, 11)
		}
		//COD_MSG_SKILL_D;
		//show_hudmessage(id, "Aby postawic na mapie apteczke, stojac wcisnij USE (domyslnie E)^nAby wskrzesic kumpla / Usunac cialo wroga naceluj na niego, i kucajac wcisnij USE")
		ilosc_apteczek_gracza[id] = 1;
		ma_klase[id] = true
		if(equali(mapname, "gg_", 3) || equali(mapname, "aim_", 4) || equali(mapname, "fun_", 4) || equali(mapname, "awp_", 4))
			cod_add_wskrzes(id, 0)
		else
			cod_add_wskrzes(id, 1)
	}
	
	return COD_CONTINUE;
}

public cod_class_disabled(id)
{
	cod_add_wskrzes(id, 0)
	ma_klase[id] = false
}

public cod_class_skill_used(id)
{
	if(equali(mapname, "gg_", 3) || equali(mapname, "aim_", 4) || equali(mapname, "fun_", 4) || equali(mapname, "awp_", 4))
	{
		client_print(id, print_center, "Umiejetnosci klas nie sa dostepne w tym trybie gry !");
	}
	else
	{
		if (!ilosc_apteczek_gracza[id])
		{
			client_print(id, print_center, "Do dyspozycji masz tylko 1 apteczke na spawn !");
			return PLUGIN_CONTINUE;
		}
	
		if(fm_get_user_button(id) & IN_DUCK)
		{
			return PLUGIN_CONTINUE;
		}
		
		ilosc_apteczek_gracza[id]--;
	
		new Float:origin[3];
		entity_get_vector(id, EV_VEC_origin, origin);
		//acg_drawentityicon(
	
		new ent = create_entity("info_target");
		entity_set_string(ent, EV_SZ_classname, "medkit");
		entity_set_edict(ent, EV_ENT_owner, id);
		entity_set_int(ent, EV_INT_solid, SOLID_NOT);
		entity_set_vector(ent, EV_VEC_origin, origin);
		entity_set_float(ent, EV_FL_ltime, halflife_time() + 7 + 0.1);
	
		entity_set_model(ent, "models/w_medkit.mdl");
		set_rendering ( ent, kRenderFxGlowShell, 255,0,0, kRenderFxNone, 255 ) 	;
		drop_to_floor(ent);
	
		entity_set_float(ent, EV_FL_nextthink, halflife_time() + 0.1);
	}
	
	return PLUGIN_CONTINUE;
}

public MedkitThink(ent)
{
	if(!is_valid_ent(ent))
		return PLUGIN_CONTINUE;
	
	new id = entity_get_edict(ent, EV_ENT_owner);
	new dist = 300;
	new heal = 10+cod_get_user_intelligence(id);

	if (entity_get_edict(ent, EV_ENT_euser2) == 1)
	{		
		new Float:forigin[3];
		entity_get_vector(ent, EV_VEC_origin, forigin);
		
		new entlist[MAX + 1];
		new numfound = find_sphere_class(0,"player", float(dist),entlist, MAX,forigin);
		
		for (new i=0; i < numfound; i++)
		{		
			new pid = entlist[i];
			
			if (get_user_team(pid) != get_user_team(id))
				continue;
			
			new maksymalne_zdrowie = 100+cod_get_user_health(pid);
			new zdrowie = get_user_health(pid);
			new Float:nowe_zdrowie = (zdrowie+heal<maksymalne_zdrowie)?zdrowie+heal+0.0:maksymalne_zdrowie+0.0;
			if (is_user_alive(pid)) entity_set_float(pid, EV_FL_health, nowe_zdrowie);	
		}
		
		entity_set_edict(ent, EV_ENT_euser2, 0);
		entity_set_float(ent, EV_FL_nextthink, halflife_time() + 1.5);
		
		return PLUGIN_CONTINUE;
	}
	
	if (entity_get_float(ent, EV_FL_ltime) < halflife_time() || !is_user_alive(id))
	{
		remove_entity(ent);
		return PLUGIN_CONTINUE;
	}
	
	if (entity_get_float(ent, EV_FL_ltime)-2.0 < halflife_time())
		set_rendering ( ent, kRenderFxNone, 255,255,255, kRenderTransAlpha, 100 );
		
	new Float:forigin[3];
	entity_get_vector(ent, EV_VEC_origin, forigin);
					
	new iOrigin[3];
	for(new i=0;i<3;i++)
		iOrigin[i] = floatround(forigin[i]);
		
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_BEAMCYLINDER );
	write_coord( iOrigin[0] );
	write_coord( iOrigin[1] );
	write_coord( iOrigin[2] );
	write_coord( iOrigin[0] );
	write_coord( iOrigin[1] + dist );
	write_coord( iOrigin[2] + dist );
	write_short( sprite_white );
	write_byte( 0 ); // startframe
	write_byte( 0 ); // framerate
	write_byte( 10 ); // life
	write_byte( 10 ); // width
	write_byte( 255 ); // noise
	write_byte( 255 ); // r, g, b
	write_byte( 100 );// r, g, b
	write_byte( 100 ); // r, g, b
	write_byte( 128 ); // brightness
	write_byte( 0 ); // speed
	message_end();
	
	entity_set_edict(ent, EV_ENT_euser2 ,1);
	entity_set_float(ent, EV_FL_nextthink, halflife_time() + 0.5);
	
	return PLUGIN_CONTINUE;
}

/*public client_PreThink(id)
{
	if(is_user_alive(id) && is_user_connected(id) && !is_user_bot(id))
	{
		new ent = find_object(id, "medkit")
		if(is_valid_ent(ent))
			create_icon_origin(id, ent, g_medkit_icon_id)
	}
}*/
public client_disconnect(id)
{
	new ent = -1
	while((ent = find_ent_by_class(ent, "medkit")))
	{
		if(entity_get_int(ent, EV_ENT_owner) == id)
			remove_entity(ent);
	}
}

public Spawn(id)
{
	if(!is_user_alive(id) || !is_user_connected(id))
		return PLUGIN_CONTINUE;

	if(ma_klase[id])
	{
		cod_add_wskrzes(id, 1)
		ilosc_apteczek_gracza[id] = 1;
	}
	return PLUGIN_CONTINUE;
}
