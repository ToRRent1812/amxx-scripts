#include <amxmodx>
#include <acg>
#include <hamsandwich>

public plugin_init()
{
	register_plugin("Show Teammate Names Throught Walls", "0.1", "clester993@gmail.com")
	register_event("DeathMsg", "DeathEvent", "a");
	register_event("TeamInfo", "eventJoinTeam", "a", "2=TERRORIST", "2=CT");
	RegisterHam(Ham_Spawn, "player", "Spawn", 1);
	register_clcmd("say /nicki", "pokaz")
}

/*public client_putinserver(id)
{
	set_task (2.0, "task_showteammatenames", id)
	return PLUGIN_CONTINUE
}*/

public eventJoinTeam(){        
	new id = read_data(1);
	
	if(get_user_team(id) == 0 && is_user_connected(id) && acg_userstatus(id) && !is_user_bot(id))
	{
		set_task (2.0, "task_showteammatenames", id)
	}
}

public task_showteammatenames(id)
{
	if(acg_userstatus(id) && is_user_connected(id) && !is_user_bot(id))
		acg_showteammate(id, 1)
}

public DeathEvent()
{
	new victim = read_data(2)
	if(acg_userstatus(victim) && is_user_connected(victim) && !is_user_bot(victim))
		acg_showteammate(victim, 0)
}

public Spawn(id)
{
	if(acg_userstatus(id) && is_user_connected(id) && !is_user_bot(id))
		acg_showteammate(id, 1)
}

public pokaz(id)
{
	if(acg_userstatus(id) && is_user_connected(id) && !is_user_bot(id))
	{
		acg_showteammate(id,0)
		acg_showteammate(id, 1)
	}
}
