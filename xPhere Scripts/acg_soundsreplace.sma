#include <amxmodx>
#include <acg>

public plugin_init() {
	register_plugin("Sounds Replacement", "0.2", "clester993@gmail.com")
}

public plugin_precache()
{	
	precache_sound("weapons/knife_hitwall1.wav")
	precache_sound("weapons/ak47-2.wav")
}

public client_putinserver(id)
{
	if (acg_userstatus(id))
	{
		set_task(1.0,"makechangeenabled",id)
		set_task(20.0,"makechangedisabled",id)
	}
}

public makechangeenabled(id)
{
	acg_replacesound(id, 1, 0, 123, "weapons/knife_hitwall1.wav", "weapons/ak47-2.wav")
}

public makechangedisabled(id)
{
	acg_replacesound(id, 0, 0, 123, "", "")
}