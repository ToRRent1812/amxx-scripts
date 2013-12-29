#include <amxmodx>
#include <amxmisc>
#include <acg>

public plugin_init()
{
	register_plugin ("[ACG] Stats Table", "0.1", "clester993@gmail.com")

	register_event("ResetHUD", "eventResetHud", "be")
	register_event("Damage", "eventDamage", "b", "2!0", "3=0", "4!0")
	register_event("DeathMsg","eventDeath","a") 
	register_logevent("eventEndRound", 2, "1=Round_End")
}

public plugin_precache()
{
	// Precache your weapon spr here, and define them in hud.txt
	// Example: wpn_m79 640 640hudxxxxxx 0 225	170 45

	// Then use native when DeathMsg like acg_setstatstableweaponspr(victim, "wpn_m79")

	// precache_model ("sprites/640hudxxxxxx.spr")
}

public client_putinserver(id)
{
	set_task(2.0, "task_settabletext", id)
}

public eventResetHud(id)
{
        acg_showstatstable (id, 0, 1)
}

public eventDamage(victim)
{
        if (victim<1 || victim>32)
                return
        new attacker = get_user_attacker(victim)
        if (attacker<1 || attacker>32)
                return
                
        // Send the damage info to client-side ACG
        // We don't need to make sure whether the attacker is using ACG or not
        acg_statstableaddupdamagepoint(attacker, victim, read_data(2))
}

public eventDeath()
{
        new victim = read_data(2)
        if (victim<1 || victim>32)
                return
        
        update_rankinfo(victim)
	// 测试一下, wpn_m79 已在 hud.txt 中定义了
	// For test, wpn_m79 has been defined in hud.txt
        //acg_setstatstableweaponspr(victim, "wpn_m79")
        acg_showstatstable (victim, 1, 0)
}

public eventEndRound()
{
        for(new i = 1;i <= 32;i ++)
                if (is_user_connected(i))
                if (acg_userstatus(i))
                {
                        update_rankinfo(i)
                        acg_showstatstable (i, 1, 0)
                }
}

stock update_rankinfo(id)
{
        new hudmessage[128];
        new float:kdratio = 1.0 // KD 比
        new float:headshotratio = 1.0 // 爆头率
        new float:shotratio = 1.0     // 命中率
        formatex(hudmessage, charsmax(hudmessage), "你的排行：%d   KD:%2.1f", 126/*排行*/, kdratio);
        acg_setstatstabletext(id, 2, hudmessage)
        formatex(hudmessage, charsmax(hudmessage), "爆头率:%2.1f%% 命中率:%2.1f%%", headshotratio, shotratio);
        acg_setstatstabletext(id, 3, hudmessage)        
}

public task_settabletext(id)
{
        client_cmd (id, "bind BACKSPACE statswindow")
        acg_setstatstabletext(id, 1, "退格键: 战术统计")
}
