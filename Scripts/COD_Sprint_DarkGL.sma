#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <codmod>

#define PLUGIN "Sprint"
#define VERSION "1.1"
#define AUTHOR "DarkGL"

#define SZYBKOSC_GRACZA 250.0

new Float:gfPitch[33];
new Float:gfYaw[33];

new Float:gfMoveOffset[33][2];
new giMoves[33];
new bool:gFast[33];
new gZmeczenie[33];

//pcvary
new pSpeed,pZmeczenie;

public plugin_init() {
        register_plugin(PLUGIN, VERSION, AUTHOR)
        
        pSpeed = register_cvar("sprint_szybkosc","60.0")
        pZmeczenie = register_cvar("sprint_zmeczenie","3"); // nie zmieniac !
        
        register_forward(FM_PlayerPreThink, "fwPreThink");
        register_forward(FM_UpdateClientData, "UpdateClientData_Post", 1) 
        
        RegisterHam(Ham_Spawn,"player","spawned",1)
        register_event("DeathMsg", "Death", "a")
        
        register_event("CurWeapon","CurWeapon","be", "1=1");
        
        register_clcmd("+fastrun","startMove")
        register_clcmd("-fastrun","stopMove")

        //SyncObj = CreateHudSyncObj();
        //set_task(0.6,"Pokaz",_,_,_,"b");
}

public startMove(id){
	if(!gFast[id] && is_user_alive(id) && cs_get_user_zoom(id) == CS_SET_NO_ZOOM)
	{
		gfPitch[id] = gfYaw[id] = 0.0;
		moveTo(id, 0.0, 21.5);
		gFast[id] = true;
		engfunc(EngFunc_SetClientMaxspeed, id, SZYBKOSC_GRACZA+get_pcvar_float(pSpeed));
		remove_task(id)
		set_task(0.1,"addZmeczenie",id,_,_,"b")
	}
	return PLUGIN_HANDLED
}

public stopMove(id){
	if(gFast[id] && is_user_alive(id))
	{
		moveTo(id, 0.0, 0.0, 20);
		gFast[id] = false;
		engfunc(EngFunc_SetClientMaxspeed, id, SZYBKOSC_GRACZA);
		remove_task(id)
		set_task(0.4,"odejZmecznie",id,_,_,"b")
	}
	return PLUGIN_HANDLED
}

moveTo(id, Float:fPitch, Float:fYaw, moves=25){
	gfMoveOffset[id][0] = (fPitch - gfPitch[id])/moves;
	gfMoveOffset[id][1] = (fYaw - gfYaw[id])/moves;
	giMoves[id] = moves;
}

public Death()
{
	new victim = read_data(2);
	if(!is_user_alive(victim))
		stopMove(victim)
}
public fwPreThink(id){
	if(!is_user_alive(id)) return;
        
	if(gFast[id])
	{
		set_pev(id, pev_button, pev(id,pev_button) & ~IN_ATTACK) 
		set_pev(id, pev_button, pev(id,pev_button) & ~IN_ATTACK2) 
		if(gZmeczenie[id] >= get_pcvar_num(pZmeczenie)*10)
		{
			stopMove(id);
			client_print(id, print_center, "Jestes zmeczony ! Odpocznij chwile");
		}
	}

	if(giMoves[id] > 0)
	{
		giMoves[id]--;
		gfPitch[id] += gfMoveOffset[id][0];
		gfYaw[id] += gfMoveOffset[id][1];
		engfunc(EngFunc_CrosshairAngle, id, gfPitch[id], gfYaw[id]);
	}
}

public spawned(id){
        if(is_user_alive(id)){
                gZmeczenie[id] = 0;
        }
}

public addZmeczenie(id){
        gZmeczenie[id]++;
}

public odejZmecznie(id){
        if(gZmeczenie[id] > 0){
                gZmeczenie[id]--;
        }
}

/*public Pokaz()
{
	for(new id=1; id<=32; id++)
	{
		new zm[128];
		if(!is_user_alive(id) || is_user_bot(id) || gZmeczenie[id] <= 0)
			return;
			
		if(gZmeczenie[id] > 0 && gZmeczenie[id] <= 6)	
			format(zm, sizeof(zm),  "Zmeczenie: [|....]")
		if(gZmeczenie[id] > 6 && gZmeczenie[id] <= 12)	
			format(zm, sizeof(zm),  "Zmeczenie: [||...]")
		if(gZmeczenie[id] > 12 && gZmeczenie[id] <= 18)	
			format(zm, sizeof(zm),  "Zmeczenie: [|||..]")	
		if(gZmeczenie[id] > 18 && gZmeczenie[id] <= 24)	
			format(zm, sizeof(zm),  "Zmeczenie: [||||.]")	
		if(gZmeczenie[id] > 24 && gZmeczenie[id] <= 30)	
			format(zm, sizeof(zm),  "Zmeczenie: [|||||]")
		if(gZmeczenie[id] >= 30)	
			format(zm, sizeof(zm),  "Zmeczenie: [ MAX ]")
		COD_MSG_HUD;
		ShowSyncHudMsg(id, SyncObj, "^n^n^n^n^n^n^n^n^n%s", zm)	
	}
}*/
public UpdateClientData_Post(id, sendweapons, cd_handle) 
{ 
        if(!is_user_alive(id)){ 
                return FMRES_IGNORED
        }
        
        if(gFast[id]){
                set_cd(cd_handle, CD_ID, 0) 
                return FMRES_HANDLED 
        }     
        return FMRES_IGNORED
}  

public CurWeapon(id)
{
        if(!is_user_alive(id)){
                return PLUGIN_CONTINUE;
        }
        static iOldWeap[33];
        new weapon = read_data(2);
        
        if(gFast[id] && iOldWeap[id] != weapon){
                new szName[64];
                get_weaponname(iOldWeap[id],szName,charsmax(szName));
                engclient_cmd(id,szName);
                engfunc(EngFunc_SetClientMaxspeed, id, SZYBKOSC_GRACZA+get_pcvar_float(pSpeed));
                return PLUGIN_CONTINUE;
        }
        
        iOldWeap[id] = weapon;
        return PLUGIN_CONTINUE;
}
