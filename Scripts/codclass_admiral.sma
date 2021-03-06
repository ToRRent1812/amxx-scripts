/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <codmod>
#include <fakemeta>

new const nazwa[] = "Admiral";
new const opis[] = "Za kazdego fraga +25 HP oraz pelen magazynek";
new const bronie = 1<<CSW_FAMAS | 1<<CSW_FLASHBANG;
new const zdrowie = 10;
new const kondycja = 5;
new const inteligencja = 10;
new const wytrzymalosc = 15;

new bool:ma_klase[33];
new admiral;

new const maxClip[31] = { -1, 13, -1, 10,  1,  7,  1,  30, 30,  1,  30,  20,  25, 30, 35, 25,  12,  20, 
10,  30, 100,  8, 30,  30, 20,  2,  7, 30, 30, -1,  50 };

public plugin_init() {
	register_plugin(nazwa, "1.0", "QTM_Peyote");
	
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	
	register_forward(FM_CmdStart, "CmdStart");
	register_event("DeathMsg", "DeathMsg", "ade");
}

public cod_class_enabled(id)
{
	admiral = cod_get_classid("Admiral");
	ma_klase[id] = true;
	return COD_CONTINUE;
}

public cod_class_disabled(id)
	ma_klase[id] = false;

public DeathMsg()
{
	new killer = read_data(1);
	
	if(!is_user_connected(killer))
		return PLUGIN_CONTINUE;
	
	if(ma_klase[killer] && cod_get_user_class(killer) == admiral)
	{
		new cur_health = pev(killer, pev_health);
		new Float:max_health = 100.0+cod_get_user_health(killer);
		new Float:new_health = cur_health+25.0<max_health? cur_health+25.0: max_health;
		set_pev(killer, pev_health, new_health);
		
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
