#include <amxmodx>
#include <hamsandwich>
#include <acg>

public plugin_init() {
	register_plugin("ACG Text", "0.1", "clester993@gmail.com")
	register_event("TeamInfo", "eventJoinTeam", "a", "2=TERRORIST", "2=CT");
}


public eventJoinTeam()
{        
	new id = read_data(1);
	if (acg_userstatus(id))
	{
		set_task(0.5, "wyswietl", id)
	}
}

public wyswietl(id)
{
	if(!is_user_connected(id) || is_user_bot(id))
		return PLUGIN_CONTINUE;
	
	acg_drawtext(id, "W razie problemow z wyswietleniem nickow nad glowa graczy say /nicki", 255, 200, 255, 6.0, 0.02, 0.49, 0, -1)
	
		
	return PLUGIN_CONTINUE;	
}
