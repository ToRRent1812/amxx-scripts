#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <acg>

new ctwin = 0, twin = 0

public plugin_init() {
	register_plugin("ScoreBoard", "0.1", "clester993@gmail.com")
	register_event("TeamScore","calc_teamscore","a") 
	register_event("TeamInfo", "eventJoinTeam", "a", "2=TERRORIST", "2=CT");
	set_task (2.5, "updatescoreboard", _, _, _,"b")
	RegisterHam(Ham_Spawn, "player", "Spawn", 1);
	register_event("DeathMsg", "DeathEvent", "a");
}

public plugin_precache()
{	
	precache_model("sprites/scoreboard.spr")
	precache_model("sprites/scoreboard_text.spr")
}

public calc_teamscore()
{
		new parm[16] 
		read_data(1,parm,charsmax(parm)) 
		if (parm[0] == 'T')
			twin = read_data(2) 
		else
			ctwin = read_data(2) 
}

public updatescoreboard()
{
	new Players[32]
	new cts, ts, total, i, id
	get_players(Players, cts, "ae", "CT") 
	get_players(Players, ts, "ae", "TERRORIST") 
	get_players(Players, total, "c") 
	for (i=0; i<total; i++) 
	{
		id = Players[i] 
		acg_updatescoreboard(id, twin, ctwin + twin + 1, ctwin, ts, cts, 2)
	}
}

public client_putinserver(id)
{
	if (acg_userstatus(id))
		set_task(2.0,"showsb",id)
	else
		client_print(id, print_center, "Nie korzystasz z ACG wiec nie niektore opcje nie beda dostepne")
}

public client_disconnect(id)
{
	remove_task(id)
}

public eventJoinTeam(){        
	new id = read_data(1);
	
	if(get_user_team(id) == 0 && is_user_connected(id) && acg_userstatus(id) && !is_user_bot(id))
	{
		acg_setscoreboardspr(id, SB_DISABLED, SB_T_CT, SB_ROUND)
	}
}
		
public Spawn(id)
{
	if(is_user_connected(id) && acg_userstatus(id) && !is_user_bot(id))
		acg_setscoreboardspr(id, SB_NORMAL, SB_T_CT, SB_ROUND)
}

public DeathEvent()
{
	new vid = read_data(2);
	if(is_user_connected(vid) && acg_userstatus(vid) && !is_user_bot(vid))
		acg_setscoreboardspr(vid, SB_DISABLED, SB_T_CT, SB_ROUND)
}

public showsb(id)
{
	if(is_user_connected(id) && !is_user_bot(id))
		acg_setscoreboardspr(id, SB_NORMAL, SB_T_CT, SB_ROUND)
}
