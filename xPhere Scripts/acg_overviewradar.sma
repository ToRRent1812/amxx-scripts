#include <amxmodx>
#include <acg>

public plugin_init()
{
	register_plugin("Overview Radar", "0.1", "clester993@gmail.com")
}

/*public plugin_precache()
{	
	precache_model("sprites/ic4.spr")
}*/

public client_putinserver(id)
{
	set_task (2.0, "task_drawoverviewradar", id)
	//set_task (3.0, "task_drawspronoverviewradar", id)
	return PLUGIN_CONTINUE
}

public task_drawoverviewradar(id)
{
	if(acg_userstatus(id) && is_user_connected(id) && !is_user_bot(id))
	{
		acg_drawoverviewradar (id, 1, 0, 0, 150, 150, 255, 255, 255)
	}
		
	return PLUGIN_CONTINUE
}

/*public task_drawspronoverviewradar(id)
{	
	new origin[3]
	origin[0] = 0
	origin[1] = 0
	origin[2] = 0
	acg_drawspronradar(id, "ic4", 255, 255, 255, origin, FX_NONE, 0.0, 0.0, 0.0, 20.0, DRAW_HOLES, -1, 1)
	return PLUGIN_CONTINUE
}
*/
