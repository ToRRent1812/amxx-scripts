#include <amxmodx>
#include <acg>

public plugin_init()
{
	register_plugin("Draw texture test", "0.4", "clester993@gmail.com")
}

public client_putinserver(id)
{
	set_task (2.0, "task_drawtext", id)
	return PLUGIN_CONTINUE
}


public task_drawtext(id)
{
	acg_initfont(id, "Tahoma", 12, 1, 0, 0, 1)
	acg_initfont(id, "System", 12, 1, 0, 0, 2)
	acg_initfont(id, "Tahoma", 15, 1, 0, 1, 3)
	// call acg_initfont once and everything is OK.
	// there is no need calling acg_initfont before acg_drawtext next time


	acg_drawtext(id, 0.5, 0.6, "Hello World!!!!!!^n\rThis is new line in red^n\gThis is new line in green", 100, 255, 100, 255, 0.3, 0.3, 6.6, 1, TS_BORDER, 1, 1, 1)
	acg_drawtext(id, 0.5, 0.35, "Text with shadow", 100, 255, 100, 255, 0.3, 0.3, 6.3, 1, TS_SHADOW, 0, 0, 2)
	acg_drawtext(id, 0.5, 0.3, "Chinese character test: 测试", 100, 255, 100, 255, 0.3, 0.3, 6.0, 1, TS_BORDER, 0, 0, 3)
	return PLUGIN_CONTINUE
}