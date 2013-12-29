/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <hamsandwich>
#include <dhudmessage>
#include <torreinc>
#include <engine>
#include <fakemeta>

#define PLUGIN "DeathStreak"
#define VERSION "0.55"
#define AUTHOR "ToRRent"

#define dMSG set_dhudmessage(255, 255, 85, -1.0, 0.18, 0, 6.0, 5.0, 0.5, 2.0, false)
#define MSG set_dhudmessage(255, 255, 255, -1.0, 0.18, 0, 6.0, 5.0, 0.5, 2.0, false)
#define TASK_EKSCYTACJI 12383
#define MAX 20
#define SZYBKOSC_GRACZA(%1) (250+cod_get_user_trim(%1, 1, 1, 1)*1.3)

new licznik_zgonow[MAX+1], bool:ekscytacja[MAX+1], /*bool:zemsta[MAX+1], */bool:destrukcja[MAX+1], bool:moc[MAX+1]/*, bool:meczennik[MAX+1]*/;
new bool:wybral[MAX + 1], bool:frag[MAX + 1];
new Float:Timer[MAX + 1];

new sprite_blast;

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	//register_event("CurWeapon","CurWeapon","be", "1=1");
	register_logevent("Poczatek_Rundy", 2, "1=Round_Start");
	register_event("DeathMsg", "DeathMsg", "a")
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
	
	register_clcmd("ds", "wybor_nagrody")
}

public plugin_precache()
{
	sprite_blast = precache_model("sprites/dexplo.spr");
	precache_sound("TM_CodMod/ekscytacja.wav");
	precache_sound("TM_CodMod/moc.wav");
	//precache_sound("TM_CodMod/meczennik.wav");
	precache_sound("TM_CodMod/close.wav");
}

public wybor_nagrody(id)
{
	if(wybral[id])
		return PLUGIN_HANDLED;
		
	if(!cod_get_user_class(id) || get_user_team(id) == 3 || is_user_bot(id))
		return PLUGIN_HANDLED;
		
	new menu = menu_create("Wybierz DeathStreak na ta mape:", "Nagrody_Handler");
	new cb = menu_makecallback("Nagrody_CallBack");
	//menu_additem(menu, "Zemsta \y[5x]", _, _, cb);
	menu_additem(menu, "Moc Obalajaca \y[3x]", _, _, cb);
	menu_additem(menu, "Ekscytacja \y[4x]", _, _, cb);
	//menu_additem(menu, "Meczennik \y[5x]", _, _, cb);
	menu_additem(menu, "Destrukcja \y[5x]", _, _, cb);
	menu_additem(menu, "\yInformacje o nagrodach", _, _, cb);
	menu_display(id, menu)
	
	
	return PLUGIN_CONTINUE;
}

public Nagrody_CallBack(id, menu, item)
{
	if(wybral[id] && (item == 0 || item == 1 || item == 2 /*|| item == 3*/))
		return ITEM_DISABLED;
		
	return ITEM_ENABLED;
}

public Nagrody_Handler(id, menu, item)
{
	if(!is_user_alive(id) || is_user_bot(id))
		return PLUGIN_HANDLED;
	
	client_cmd(id, "spk TM_CodMod/close.wav");
	switch(item)
	{
		case 0:
		{
			moc[id] = true;
			wybral[id] = true;
			menu_destroy(menu);
			
		}
		/*case 1:
		{
			zemsta(id)[id] = true;
			wybral[id] = true;
			menu_destroy(menu)
		}*/
		case 1:
		{
			ekscytacja[id] = true;
			wybral[id] = true;
			menu_destroy(menu);
		} 
		/*case 2:
		{
			meczennik[id] = true;
			wybral[id] = true;
			menu_destroy(menu);
			
		}*/
		case 2:
		{
			destrukcja[id] = true;
			wybral[id] = true;
			menu_destroy(menu);
		}
		case 3:
		{
			PokazInfo(id);
		}
	}
	return PLUGIN_HANDLED;
}

public PokazInfo(id)
{
	client_cmd(id, "ds");
	show_motd(id, "<b>Moc Obalajaca</b><br />Zadajesz 50 % obrazen wiecej dopoki kogos nie zabijesz<br /><b>Ekscytacja</b><br />Od momentu odrodzenia sie przez 7 sekund szybciej chodzisz<br /><b>Destrukcja</b><br />Wybuchasz po smierci<br />", "Informacje o DeathStreakach");
}

public Poczatek_Rundy()
{
	new num, players[32];
	get_players(players, num, "gh");
	for(new id = 1; id <= num; id++)
	{
		frag[id] = false
		
		if(licznik_zgonow[id] >= 4 && ekscytacja[id] == true )
			StartEkscytacja(id);
		
		/*if(licznik_zgonow[id] >= 5 && meczennik[id] == true )
			StartMeczennik(id);*/
		
		if(licznik_zgonow[id] >= 3 && moc[id] == true)
			StartMoc(id);
		
		if(licznik_zgonow[id] >= 5 && destrukcja[id] == true)
			StartDestrukcja(id);
			
		if(!wybral[id])
			client_cmd(id, "ds");	
		
		
		
		/*if(zemsta[id] && licznik_zgonow[id] => 5)
			StartZemsta(id);*/
	}
	
}
	
public client_putinserver(id)
{
	licznik_zgonow[id] = 0;
	frag[id] = false
	ekscytacja[id] = false;
	//zemsta[id] = false;
	destrukcja[id] = false;
	moc[id] = false;
	//meczennik[id] = false;
	
	if(is_user_bot(id) && is_user_alive(id) && !wybral[id])
	{
		new rn = random_num(0,2)
		switch(rn)
		{
			case 0:
			{
				ekscytacja[id] = true;
				wybral[id] = true;
			}
		/*case 1:
		{
			zemsta(id)[id] = true;
			wybral[id] = true;
			menu_destroy(menu)
		}*/
			case 1:
			{
				destrukcja[id] = true;
				wybral[id] = true;
			} 
			case 2:
			{
				moc[id] = true;
				wybral[id] = true;
			} 
			/*case 3:
			{
				meczennik[id] = true;
				wybral[id] = true;
			}*/
		}
	}
}

public client_connect(id)
{
	wybral[id] = false;
}

public DeathMsg()
{
	new killer = read_data(1);
	new victim = read_data(2);
	
	if(is_user_alive(killer) && is_user_connected(killer))
	{
		if(get_user_team(killer) != get_user_team(victim))
		{
			if(wybral[victim] == true)
			{
				licznik_zgonow[victim]++;
			}
			licznik_zgonow[killer] = 0;
				
			if(moc[killer] && !frag[killer])
				frag[killer] = true;
				
			if(destrukcja[victim] && licznik_zgonow[victim] >= 5)
				WybuchInit(victim);
		}
	}
}

public StartEkscytacja(id)
{
	dMSG;
	show_dhudmessage(id, "Ekscytacja");
	MSG;
	show_dhudmessage(id, "^nPrzez 7 sekund poruszasz sie szybciej");
	Timer[id] = 7.0
	client_cmd(id, "spk TM_CodMod/ekscytacja.wav");
        
	if(task_exists(id + TASK_EKSCYTACJI))
	{
		remove_task(id + TASK_EKSCYTACJI)
	}
	set_task(0.1, "EkscytacjaDalej", id + TASK_EKSCYTACJI, _, _, "b")
        
	return PLUGIN_CONTINUE
}

public EkscytacjaDalej(task_id)
{
	new id = task_id - TASK_EKSCYTACJI;
	
	Timer[id] -= 0.1;
	engfunc(EngFunc_SetClientMaxspeed, id, SZYBKOSC_GRACZA(id)+100.0);
	set_dhudmessage(255, 255, 0, -1.0, 0.6, 0, 6.0, 0.15, 0.0, 0.0, false);
	show_dhudmessage(id, "%0.1f", Timer[id]);
	
	if(Timer[id] <= 0.1)
	{
		if(task_exists(task_id))
		{
			remove_task(task_id)
			engfunc(EngFunc_SetClientMaxspeed, id, SZYBKOSC_GRACZA(id));
		}
	}
}
/* ----- */
public StartDestrukcja(id)
{
	dMSG;
	show_dhudmessage(id, "Destrukcja");
	MSG;
	show_dhudmessage(id, "^nWybuchasz po smierci zabijajac wrogow w poblizu");
}

public WybuchInit(id)
{
	if(!is_user_connected(id))
		return PLUGIN_CONTINUE;
		
	new Float:fOrigin[3], iOrigin[3];
	entity_get_vector( id, EV_VEC_origin, fOrigin);
	iOrigin[0] = floatround(fOrigin[0]);
	iOrigin[1] = floatround(fOrigin[1]);
	iOrigin[2] = floatround(fOrigin[2]);
	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY, iOrigin);
	write_byte(TE_EXPLOSION);
	write_coord(iOrigin[0]);
	write_coord(iOrigin[1]);
	write_coord(iOrigin[2]);
	write_short(sprite_blast);
	write_byte(32);
	write_byte(20);
	write_byte(0);
	message_end();
	
	new entlist[MAX + 1];
	new numfound = find_sphere_class(id, "player", 400.0 , entlist, MAX);
		
	for (new i=0; i < numfound; i++)
	{		
		new pid = entlist[i];
	
		if (is_user_alive(pid) && get_user_team(id) != get_user_team(pid))
			cod_inflict_damage(id, pid, float(get_user_health(pid))+10.0, 0.0);
	}
	user_silentkill(id);
		
	return PLUGIN_CONTINUE;
}
/* ----- */

public StartMoc(id)
{
	frag[id] = false;
	dMSG;
	show_dhudmessage(id, "Moc Obalajaca");
	MSG;
	show_dhudmessage(id, "^nZadajesz 50 % dmg wiecej dopoki kogos nie zabijesz");
	client_cmd(id, "spk TM_CodMod/moc.wav");
}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker) || !is_user_alive(idattacker) || this == idattacker)
		return HAM_IGNORED;
		
	if(moc[idattacker] && !frag[idattacker])
		SetHamParamFloat(4, (damage * 1.5) + (cod_get_user_intelligence(idattacker) * 0.2))
	//cod_inflict_damage(idattacker, this, damage*0.5, 0.0, idinflictor, damagebits);

	/*if(meczennik[this])
	{
		if(damage < pev(this, pev_health))
				return HAM_IGNORED;
			
		if(task_exists(this)) return HAM_SUPERCEDE;
			
		fm_give_item(this, "weapon_hegrenade");
		engclient_cmd(this, "weapon_hegrenade")
			
		set_pev(this, pev_angles, { 88.0, 0.0, 0.0 });
		set_pev(this, pev_fixangle, 1)
			
		new iGrenade = fm_find_ent_by_owner(-1, "weapon_hegrenade", this) 
		ExecuteHamB(Ham_Weapon_PrimaryAttack, iGrenade);
			
		//giUserOtherInfo[this] = iAttacker
		set_task(1.0, "KoniecMeczennik", this)
			
		return HAM_SUPERCEDE
	}*/
	
	return HAM_IGNORED;
}

/* ----- */
/*public StartMeczennik(id)
{
	dMSG;
	show_dhudmessage(id, "Meczennik");
	MSG;
	show_dhudmessage(id, "^nPo smierci rzucasz odbezpieczony granat");
	client_cmd(id, "spk TM_CodMod/meczennik.wav");
}*/			