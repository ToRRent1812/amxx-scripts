#include <amxmodx>
#include <codmod>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>
#include <engine>

#define MAX 20
new const perk_name[] = "Elektromagnes Haliny";
new const perk_desc[] = "Co spawn mozesz polozyc elektromagnes ktory przyciaga bron";

new bool:ma_perk[MAX + 1];
new pozostale_elektromagnesy[MAX + 1];

new pcvar_ilosc_elektromagnesow, pcvar_zasieg, pcvar_czas_dzialania, pcvar_widocznosc_fali;

new sprite_white;
public plugin_init()
{
	register_plugin(perk_name, "1.0", "QTM_Peyote");
	
	register_event("ResetHUD", "ResetHUD", "abe");
	pcvar_ilosc_elektromagnesow = register_cvar("cod_magnets", "1");
	pcvar_zasieg = register_cvar("cod_magnetradius", "150");
	pcvar_czas_dzialania = register_cvar("cod_magnettime", "15");
	pcvar_widocznosc_fali = register_cvar("cod_wavesvisibility", "15");
	cod_register_perk(perk_name, perk_desc);
	register_think("magnet","MagnetThink");
	
}
public plugin_precache()
{
	precache_model("models/QTM_CodMod/electromagnet.mdl");
	precache_sound("weapons/mine_charge.wav");
	precache_sound("weapons/mine_activate.wav");
	precache_sound("weapons/mine_deploy.wav");
	sprite_white = precache_model("sprites/white.spr") ;
}
public cod_perk_enabled(id)
{
	if(cod_get_user_class(id) == cod_get_classid("Halina"))
		return COD_STOP;
		
	COD_MSG_SKILL_D;
	show_hudmessage(id, "Aby postawic na mapie elektromagnes^n uzyj komendy useperk lub radio3");
	ma_perk[id] = true
	NowaRunda_magnet();
	
	return COD_CONTINUE;
}
public cod_perk_disabled(id)
{
	ma_perk[id] = false
}
public cod_perk_used(id)
{	
	if (pozostale_elektromagnesy[id] < 1)
	{
		client_print(id, print_center, "Do dyspozycji masz tylko 1 elektromagnes na spawn !");
		return PLUGIN_CONTINUE;
	}
	
	pozostale_elektromagnesy[id]--;
	
	new Float:origin[3];
	entity_get_vector(id, EV_VEC_origin, origin);
	
	new ent = create_entity("info_target");
	entity_set_string(ent, EV_SZ_classname, "magnet");
	entity_set_edict(ent, EV_ENT_owner, id);
	entity_set_int(ent, EV_INT_solid, SOLID_NOT);
	entity_set_vector(ent, EV_VEC_origin, origin);
	entity_set_float(ent, EV_FL_ltime, halflife_time() + get_pcvar_num(pcvar_czas_dzialania) + 3.5);
	
	
	entity_set_model(ent, "models/QTM_CodMod/electromagnet.mdl");
	drop_to_floor(ent);
	
	emit_sound(ent, CHAN_VOICE, "weapons/mine_charge.wav", 0.5, ATTN_NORM, 0, PITCH_NORM );
	emit_sound(ent, CHAN_ITEM, "weapons/mine_deploy.wav", 0.5, ATTN_NORM, 0, PITCH_NORM );
	
	entity_set_float(ent, EV_FL_nextthink, halflife_time() + 3.5);
	
	return PLUGIN_CONTINUE;
}
public ResetHUD(id)
{
	NowaRunda_magnet()
	pozostale_elektromagnesy[id] = get_pcvar_num(pcvar_ilosc_elektromagnesow);
}
public client_disconnect(id)
{
	new ent	    
	while((ent = fm_find_ent_by_owner(ent, "magnet", id)) != 0)
		remove_entity(ent)
	/*new ent = find_ent_by_class(0, "magnet");
	while(ent > 0)
	{
		if(entity_get_edict(ent, EV_ENT_owner) == id)
			remove_entity(ent);
		ent = find_ent_by_class(ent, "magnet");
	}*/
}

public NowaRunda_magnet()
	remove_entity_name("magnet")
	
stock get_velocity_to_origin( ent, Float:fOrigin[3], Float:fSpeed, Float:fVelocity[3] )
{
	new Float:fEntOrigin[3];
	entity_get_vector( ent, EV_VEC_origin, fEntOrigin );
	
	// Velocity = Distance / Time
	
	new Float:fDistance[3];
	fDistance[0] = fEntOrigin[0] - fOrigin[0];
	fDistance[1] = fEntOrigin[1] - fOrigin[1];
	fDistance[2] = fEntOrigin[2] - fOrigin[2];
	
	new Float:fTime = -( vector_distance( fEntOrigin,fOrigin ) / fSpeed );
	
	fVelocity[0] = fDistance[0] / fTime;
	fVelocity[1] = fDistance[1] / fTime;
	fVelocity[2] = fDistance[2] / fTime + 50.0;
	
	return ( fVelocity[0] && fVelocity[1] && fVelocity[2] );
}
stock set_velocity_to_origin( ent, Float:fOrigin[3], Float:fSpeed )
{
	new Float:fVelocity[3];
	get_velocity_to_origin( ent, fOrigin, fSpeed, fVelocity )
	
	entity_set_vector( ent, EV_VEC_velocity, fVelocity );
	
	return ( 1 );
} 
public MagnetThink(ent)
{
	if(entity_get_int(ent, EV_INT_iuser2))
		return PLUGIN_CONTINUE;
	
	if(!entity_get_int(ent, EV_INT_iuser1))
		emit_sound(ent, CHAN_VOICE, "weapons/mine_activate.wav", 0.5, ATTN_NORM, 0, PITCH_NORM );
	
	entity_set_int(ent, EV_INT_iuser1, 1);
	
	new id = entity_get_edict(ent, EV_ENT_owner);
	new dist = get_pcvar_num(pcvar_zasieg);
	
	new Float:forigin[3];
	entity_get_vector(ent, EV_VEC_origin, forigin);
	
	new entlist[33];
	new numfound = find_sphere_class(0,"player", float(dist),entlist, 32,forigin);
	
	for (new i=0; i < numfound; i++)
	{		
		new pid = entlist[i];
		
		if (get_user_team(pid) == get_user_team(id))
			continue;
		
		if (is_user_alive(pid))
		{
			new bronie_gracza = entity_get_int(pid, EV_INT_weapons);
			for(new n=1; n <= 32;n++)
			{
				if(1<<n & bronie_gracza)
				{
					new weaponname[33];
					get_weaponname(n, weaponname, 32);
					engclient_cmd(pid, "drop", weaponname);
				}
			}
		}
	}
	
	numfound = find_sphere_class(0,"weaponbox", float(dist)+100.0,entlist, 32,forigin);
	
	for (new i=0; i < numfound; i++)
		if(get_entity_distance(ent, entlist[i]) > 50.0)
		set_velocity_to_origin(entlist[i], forigin, 999.0);
	
	if (entity_get_float(ent, EV_FL_ltime) < halflife_time() || !is_user_alive(id))
	{
		entity_set_int(ent, EV_INT_iuser2, 1);
		return PLUGIN_CONTINUE;
	}
	
	new iOrigin[3];
	FVecIVec(forigin, iOrigin);
	
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
	write_byte( 0 ); // r, g, b
	write_byte( 100 );// r, g, b
	write_byte( 255 ); // r, g, b
	write_byte( get_pcvar_num(pcvar_widocznosc_fali) ); // brightness
	write_byte( 0 ); // speed
	message_end();
	
	entity_set_float(ent, EV_FL_nextthink, halflife_time() + 0.1);
	
	return PLUGIN_CONTINUE;
}
