#include <amxmodx>
#include <codmod>
#include <fakemeta>

#define MAX 20
new const perk_name[] = "Wkurwiator Agi";
new const perk_desc[] = "Gdy strzelasz do przeciwnika masz 1/LW szansy, ze podskoczy";

new bool:ma_perk[MAX + 1];
new wartosc_perku[MAX + 1];

public plugin_init() 
{
	register_plugin(perk_name, "1.0", "Szybcioor");
	
	cod_register_perk(perk_name, perk_desc, 2, 5);
	
	register_event("Damage", "Damage", "b", "2!=0");	
	
}

public cod_perk_enabled(id, wartosc)
{
	if(cod_get_user_class(id) == cod_get_classid("Aga"))
		return COD_STOP;
		
	ma_perk[id] = true;
	wartosc_perku[id] = wartosc;
	
	return COD_CONTINUE;
}

public cod_perk_disabled(id)
{
	ma_perk[id] = false;
}

public Damage(id)
{
	new idattacker = get_user_attacker(id);
	
	if(!is_user_connected(idattacker) || get_user_team(id) == get_user_team(idattacker))
		return PLUGIN_CONTINUE;
	
	if(ma_perk[idattacker] && random_num(1, wartosc_perku[idattacker]) == 1)
		set_pev(id, pev_velocity, Float:{0.0, 0.0, 260.0});
	
	return PLUGIN_CONTINUE;
}
