#include <amxmodx>
#include <fakemeta>
#include <acg>

#define LEVELS 8
new kills[33], Float:timekill[33], revenge[33], oneshot[33]
new g_firstkill, g_lastkill
new g_FM_Running

new const spr_combo[][] =
{
	"sprites/effectskill/1shot_2kill.spr", 
	"sprites/effectskill/1shot_3kill.spr", 
	"sprites/effectskill/c4_defuse.spr", 
	"sprites/effectskill/c4_set.spr", 
	//"sprites/effectskill/ghost_shot.spr",
	"sprites/effectskill/kill_1.spr",
	"sprites/effectskill/kill_2.spr",
	"sprites/effectskill/kill_3.spr",
	"sprites/effectskill/kill_4.spr",
	"sprites/effectskill/kill_5.spr",
	"sprites/effectskill/kill_6.spr",
	"sprites/effectskill/kill_7.spr",
	"sprites/effectskill/kill_8.spr",
	"sprites/effectskill/kill_first.spr",
	"sprites/effectskill/kill_he.spr",
	"sprites/effectskill/kill_headshot.spr",
	"sprites/effectskill/kill_knife.spr",
	"sprites/effectskill/kill_last.spr",
	"sprites/effectskill/kill_revenge.spr",
	"sprites/effectskill/wall_shot.spr",
	"sprites/effectskill/wall_shot_hs.spr"
}

new const spr_combo2[][] =
{
	"effectskill/kill_1",
	"effectskill/kill_2",
	"effectskill/kill_3",
	"effectskill/kill_4",
	"effectskill/kill_5",
	"effectskill/kill_6",
	"effectskill/kill_7",
	"effectskill/kill_8",
	"effectskill/kill_first",
	"effectskill/c4_defuse", 
	"effectskill/c4_set", 
	"effectskill/kill_he",
	"effectskill/kill_headshot",
	"effectskill/kill_knife",
	"effectskill/kill_last",
	"effectskill/kill_revenge",
	"effectskill/wall_shot",
	"effectskill/wall_shot_hs",
	"effectskill/1shot_2kill", 
	"effectskill/1shot_3kill"
}

enum
{
	KILL_1 = 0,
	KILL_2,
	KILL_3,
	KILL_4,
	KILL_5,
	KILL_6,
	KILL_7,
	KILL_8,
	KILL_FIRST,
	C4_DEFUSE,
	C4_SET,
	KILL_HEGRENADE,
	KILL_HEADSHOT,
	KILL_KNIFE,
	KILL_LAST,
	KILL_REVENGE,
	WALLSHOT,
	WALLSHOT_HEADSHOT,
	ONESHOT_2KILL,
	ONESHOT_3KILL
}

public plugin_precache()
{
	for (new i = 0; i <= 17; i++)
	{
		precache_model(spr_combo[i])
	}
}

public plugin_init()
{
	register_plugin("Effects Kill", "0.2", "modified from CSO-NST")
	
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
	register_event("DeathMsg", "event_DeathMsg", "a")
}

public event_round_start()
{
	new reset_value[33]

	g_firstkill = 1
	kills = reset_value
	revenge = reset_value
	oneshot = reset_value
}

public event_DeathMsg()
{
	// get value data
	static killer, headshot, weapon[32], wpnindex, victim
	killer = read_data(1)
	victim = read_data(2)

	headshot = read_data(3)
	read_data(4, weapon, charsmax(weapon))
	if (equali(weapon, "grenade"))
		format(weapon, charsmax(weapon), "hegrenade")
	format(weapon, charsmax(weapon), "weapon_%s", weapon)
	wpnindex = get_weaponid(weapon)
	
	// none killer = victim
	if (!is_user_connected(killer) || !is_user_connected(victim) || killer==victim) return;
	if (!acg_userstatus(killer))
	{
		if (g_firstkill)
			g_firstkill = 0
		return;
	}
	//if (get_user_team(killer)==get_user_team(victim) && !get_cvar_num("mp_friendlyfire")) return;
	
	// reset kills of victim
	kills[victim] = 0

	// set revenge of victim
	revenge[victim] = killer

	// get num kill & one shoot multikill
	new Float:timeleft = get_gametime()-timekill[killer]
	if (timeleft <= 3.0) kills[killer] += 1
	else kills[killer] = 1
	if (kills[killer]>LEVELS) kills[killer] = LEVELS
	timekill[killer] = get_gametime()

	if (!oneshot[killer]) oneshot[killer] = 1
	if (!timeleft && wpnindex != CSW_HEGRENADE) oneshot[killer] += 1
	else oneshot[killer] = 1
	oneshot[killer] = min(3, oneshot[killer])
	//client_print(killer, print_chat, "%i", oneshot[killer])
	
	// get last kill
	new players_ct[32], players_t[32], ict, ite
	get_players(players_ct,ict,"ae","CT")   
	get_players(players_t,ite,"ae","TERRORIST")
	if (ict == 0 || ite == 0) g_lastkill = 1
	
	// check revenge
	new m_revenge
	if (victim == revenge[killer])
	{
		m_revenge = 1
		revenge[killer] = 0
	}

	if (oneshot[killer] > 1)
	{
		if (oneshot[killer] == 2)
			acg_drawspr(killer, spr_combo2[ONESHOT_2KILL], 255, 255, 255, 0.7, 0.3, 1, FX_FADE, 0.0, 0.4, 0.0, 3.0, DRAW_ADDITIVE, 1)
		else if (oneshot[killer] == 3)
			acg_drawspr(killer, spr_combo2[ONESHOT_3KILL], 255, 255, 255, 0.7, 0.3, 1, FX_FADE, 0.0, 0.4, 0.0, 3.0, DRAW_ADDITIVE, 1)
	}
	
	if (g_lastkill)
	{
		g_lastkill = 0
		acg_drawspr(killer, spr_combo2[KILL_LAST], 255, 255, 255, 0.6, 0.3, 1, FX_FADE, 0.0, 0.4, 0.0, 3.0, DRAW_ADDITIVE, 2)
	}	
	
	if (m_revenge)
		acg_drawspr(killer, spr_combo2[KILL_REVENGE], 255, 255, 255, 0.5, 0.65, 1, FX_FADE, 0.0, 0.4, 0.0, 3.0, DRAW_ADDITIVE, 3)
	
	if ((wpnindex != CSW_KNIFE) && (wpnindex != CSW_HEGRENADE) && !can_see_fm(killer, victim)) 
	{
		if (headshot)
			acg_drawspr(killer, spr_combo2[WALLSHOT_HEADSHOT], 255, 255, 255, 0.5, 0.75, 1, FX_FADE, 0.0, 0.4, 0.0, 3.0, DRAW_ADDITIVE, 4)
		else
			acg_drawspr(killer, spr_combo2[WALLSHOT], 255, 255, 255, 0.5, 0.75, 1, FX_FADE, 0.0, 0.4, 0.0, 3.0, DRAW_ADDITIVE, 4)
	}
	
	if (headshot && wpnindex)
	{
		acg_drawspr(killer, spr_combo2[KILL_HEADSHOT], 255, 255, 255, 0.4, 0.3, 1, FX_FADE, 0.0, 0.4, 0.0, 3.0, DRAW_ADDITIVE, 5)
	}
	else if (wpnindex == CSW_KNIFE)
	{
		acg_drawspr(killer, spr_combo2[KILL_KNIFE], 255, 255, 255, 0.4, 0.3, 1, FX_FADE, 0.0, 0.4, 0.0, 3.0, DRAW_ADDITIVE, 5)
	}
	else if (wpnindex == CSW_HEGRENADE)
	{
		acg_drawspr(killer, spr_combo2[KILL_HEGRENADE], 255, 255, 255, 0.4, 0.3, 1, FX_FADE, 0.0, 0.4, 0.0, 3.0, DRAW_ADDITIVE, 5)
	}
	
	
	// hud 2
	if (g_firstkill)
	{
		g_firstkill = 0
		acg_drawspr(killer, spr_combo2[KILL_FIRST], 255, 255, 255, 0.6, 0.3, 1, FX_FADE, 0.0, 0.4, 0.0, 3.0, DRAW_ADDITIVE, 6)
	}
	else
	{
		acg_drawspr(killer, spr_combo2[kills[killer] - 1], 255, 255, 255, 0.55, 0.3, 1, FX_FADE, 0.0, 0.4, 0.0, 3.0, DRAW_ADDITIVE, 6)
	}
}
public bomb_defused(id)
{
	acg_drawspr(id, spr_combo2[C4_DEFUSE], 255, 255, 255, 0.5, 0.75, 1, FX_FADE, 0.0, 0.4, 0.0, 3.0, DRAW_ADDITIVE, 7)
}

public bomb_planted(id)
{
	acg_drawspr(id, spr_combo2[C4_SET], 255, 255, 255, 0.5, 0.75, 1, FX_FADE, 0.0, 0.4, 0.0, 3.0, DRAW_ADDITIVE, 7)
}

bool:can_see_fm(entindex1, entindex2)
{
	if (!entindex1 || !entindex2)
		return false
//  new ent1, ent2

	if (pev_valid(entindex1) && pev_valid(entindex1))
	{
		new flags = pev(entindex1, pev_flags)
		if (flags & EF_NODRAW || flags & FL_NOTARGET)
		{
			return false
		}

		new Float:lookerOrig[3]
		new Float:targetBaseOrig[3]
		new Float:targetOrig[3]
		new Float:temp[3]

		pev(entindex1, pev_origin, lookerOrig)
		pev(entindex1, pev_view_ofs, temp)
		lookerOrig[0] += temp[0]
		lookerOrig[1] += temp[1]
		lookerOrig[2] += temp[2]

		pev(entindex2, pev_origin, targetBaseOrig)
		pev(entindex2, pev_view_ofs, temp)
		targetOrig[0] = targetBaseOrig [0] + temp[0]
		targetOrig[1] = targetBaseOrig [1] + temp[1]
		targetOrig[2] = targetBaseOrig [2] + temp[2]

		engfunc(EngFunc_TraceLine, lookerOrig, targetOrig, 0, entindex1, 0) //  checks the had of seen player
		if (get_tr2(0, TraceResult:TR_InOpen) && get_tr2(0, TraceResult:TR_InWater))
		{
			return false
		} 
		else 
		{
			new Float:flFraction
			get_tr2(0, TraceResult:TR_flFraction, flFraction)
			if (flFraction == 1.0 || (get_tr2(0, TraceResult:TR_pHit) == entindex2))
			{
				return true
			}
			else
			{
				targetOrig[0] = targetBaseOrig [0]
				targetOrig[1] = targetBaseOrig [1]
				targetOrig[2] = targetBaseOrig [2]
				engfunc(EngFunc_TraceLine, lookerOrig, targetOrig, 0, entindex1, 0) //  checks the body of seen player
				get_tr2(0, TraceResult:TR_flFraction, flFraction)
				if (flFraction == 1.0 || (get_tr2(0, TraceResult:TR_pHit) == entindex2))
				{
					return true
				}
				else
				{
					targetOrig[0] = targetBaseOrig [0]
					targetOrig[1] = targetBaseOrig [1]
					targetOrig[2] = targetBaseOrig [2] - 17.0
					engfunc(EngFunc_TraceLine, lookerOrig, targetOrig, 0, entindex1, 0) //  checks the legs of seen player
					get_tr2(0, TraceResult:TR_flFraction, flFraction)
					if (flFraction == 1.0 || (get_tr2(0, TraceResult:TR_pHit) == entindex2))
					{
						return true
					}
				}
			}
		}
	}
	return false
}