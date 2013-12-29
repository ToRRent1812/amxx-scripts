#include <amxmodx>
#include <amxmisc>
#include <fakemeta_util>
#include <hamsandwich>
#include <torreinc>
#include <engine>
#include <acg>

#define MAKE_ENTITY 564

#define MAX 20

new const W_MODEL[] = "models/w_battery.mdl";
//new const SOUND_APPROACH[] = "ioncannon/ic_approaching.wav"
new const SOUND_BEACON[] = "ioncannon/ic_beacon_set.wav"
new const SOUND_STOP[] = "vox/_comma.wav"
new const SOUND_BEEP[] = "ioncannon/ic_beacon_beep.wav"
new const SOUND_ATTACK[] = "ioncannon/ic_attack.wav"
new const SOUND_READY[] = "ioncannon/ic_ready.wav"
//new const SOUND_PLANT[] = "ioncannon/ic_beacon_plant.wav"
new const SOUND_COUNT[] = "TM_Codmod/tszy.wav"
new const SOUND_COUNT2[] = "TM_Codmod/tsztery.wav"
new const SOUND_UWAGA[] = "TM_Codmod/uwaga.wav"

new const klasa[] = "Ela";
new const nazwa_kodowa[] = "3334";
new const opis[] = "Moze wystrzelic wiazke laserowa niszczaca wszystkich wrogow w zasiegu 750u!";
new const grawitacja = 0;
new const zdrowie = 0;
new const inteligencja = 15;
new const kondycja = 5;
new const wytrzymalosc = 0;
new const przeladowanie = 10;
new const regeneracja = 0;

new BlueFire, 
	LaserFlame, 
	IonBeam, 
	Shockwave, 
	BlueFlare;

new IonShake;

new bool:g_bUsed[MAX + 1];

new Float:g_fBeamOrigin[MAX + 1][8][3],
	Float:g_fBeamMidOrigin[MAX + 1][3],
	Float:g_fRotationSpeed[MAX + 1],
	Float:g_fDegrees[MAX + 1][8],
	Float:g_fDistance[MAX + 1],
	Float:g_fBeaconTime[MAX + 1]
;
	

new g_iEnt[MAX + 1],
	g_iPitch[MAX + 1],
	g_iIonState[MAX + 1]
;


enum {
	NONE = 0,
	PLANTING,
	PLANTED
};

new mapname[32];
	
new ma_klase[MAX + 1], uzywa[MAX + 1], Count[MAX + 1];

public plugin_init() {
	//if(is_plugin_loaded("2kmod.amxx", true) == -1)
		//return;
	
	register_plugin(klasa, "1.1a", "MarWit (ToRRent Edit)");
	cod_register_class(klasa, opis, grawitacja, zdrowie, kondycja, inteligencja, wytrzymalosc, przeladowanie, regeneracja, nazwa_kodowa);
	
	register_forward(FM_CmdStart, "CmdStart")
	RegisterHam(Ham_Spawn, "player", "Spawn", 1);
	
	IonShake = get_user_msgid("ScreenShake")
	get_mapname(mapname, 31)
}

public plugin_precache()
{
	LaserFlame = precache_model("sprites/ioncannon/ic_laserflame.spr");
	IonBeam = precache_model("sprites/ioncannon/ic_ionbeam.spr");
	Shockwave = precache_model("sprites/shockwave.spr")
	BlueFlare = precache_model("sprites/ioncannon/ic_bflare.spr")
	
	//precache_sound(SOUND_BEACON)
	//engfunc(EngFunc_PrecacheSound, SOUND_APPROACH)
	engfunc(EngFunc_PrecacheSound, SOUND_BEACON)
	engfunc(EngFunc_PrecacheSound, SOUND_BEEP)
	engfunc(EngFunc_PrecacheSound, SOUND_STOP)
	engfunc(EngFunc_PrecacheSound, SOUND_ATTACK)
	engfunc(EngFunc_PrecacheSound, SOUND_READY)
	//engfunc(EngFunc_PrecacheSound, SOUND_PLANT)
	engfunc(EngFunc_PrecacheSound, SOUND_COUNT)
	engfunc(EngFunc_PrecacheSound, SOUND_COUNT2)
	engfunc(EngFunc_PrecacheSound, SOUND_UWAGA)
	
	precache_model(W_MODEL)
}

public cod_class_enabled(id)
{
	if(equali(mapname, "gg_", 3) || equali(mapname, "aim_", 4) || equali(mapname, "fun_", 4) || equali(mapname, "awp_", 4))
	{
		return COD_CONTINUE;
	}
	else
	{
		acg_drawtext(id, 0.04, 0.69, "Zeby postawic dzialko orbitalne^nstojac nieruchomo wcisnij USE (domyslnie E)^n \rUWAGA ! jezeli wcisniesz USE, nie mozesz juz zrezygnowac z dzialka", 0, 212, 255, 255, 0.0, 2.5, 4.5, 0, TS_NONE, 1, 1, 11)
	}
	//COD_MSG_SKILL_D;
	//show_hudmessage(id, "Zeby postawic dzialko orbitalne^nStojac nieruchomo wcisnij USE (domyslnie E)");
	g_bUsed[id] = false;
	ma_klase[id] = true;
	uzywa[id] = false;
	
	return COD_CONTINUE;
}

public cod_class_disabled(id)
{
	ma_klase[id] = false;
	uzywa[id] = false;
}

public cod_class_skill_used(id)
{
	if(equali(mapname, "gg_", 3) || equali(mapname, "aim_", 4) || equali(mapname, "fun_", 4) || equali(mapname, "awp_", 4))
	{
		client_print(id, print_center, "Umiejetnosci klas nie sa dostepne w tym trybie gry !");
	}
	else
	{	
		if(is_user_alive(id) && ma_klase[id])
			uzywa[id] = true;
	}
}

public CmdStart(id, uc_handle)
{
	if(!is_user_alive(id))
		return FMRES_IGNORED
	
	if(g_iIonState[id] == NONE && !g_bUsed[id] && ma_klase[id] && uzywa[id])
	{
		g_iPitch[id] = 97
		g_fBeaconTime[id] = 1.12
	
		emit_sound(id, CHAN_VOICE, SOUND_BEACON, 0.4, ATTN_NORM, 0, PITCH_NORM)
	
		message_begin(MSG_ONE, get_user_msgid("BarTime"), {0, 0, 0}, id)
		write_byte(2)
		write_byte(0)
		message_end()
		g_iIonState[id] = PLANTING
		set_task(2.0, "MakeTransmiter", id+MAKE_ENTITY)
		
		return FMRES_IGNORED
	}
	
	if(g_iIonState[id] == PLANTING && (get_user_button(id) & (IN_BACK | IN_FORWARD | IN_CANCEL | IN_JUMP | IN_MOVELEFT | IN_MOVERIGHT | IN_RIGHT)))
	{
		remove_task(id+MAKE_ENTITY)
		message_begin(MSG_ONE, get_user_msgid("BarTime"), {0, 0, 0}, id)
		write_byte(2)
		write_byte(0)
		message_end()
		emit_sound(id, CHAN_VOICE, SOUND_BEACON, 0.4, ATTN_NORM, 0, PITCH_NORM)
		g_iIonState[id] = NONE
		return FMRES_IGNORED
	}
	if(g_iIonState[id] == PLANTING && !is_user_alive(id))
	{
		remove_task(id+MAKE_ENTITY)
		g_iIonState[id] = NONE
		message_begin(MSG_ONE, get_user_msgid("BarTime"), {0, 0, 0}, id)
		write_byte(0)
		write_byte(0)
		message_end()
		return FMRES_IGNORED;
	}
	return FMRES_IGNORED
}
public MakeTransmiter(id)
{
	id-=MAKE_ENTITY
	
	COD_MSG_NEWS_P;
	show_hudmessage(id, "UWAGA PANOWIE !");
	emit_sound(id, CHAN_WEAPON, SOUND_UWAGA, 0.7, ATTN_NORM, 0, PITCH_NORM)
	//client_cmd(0, "spk %s", SOUND_PLANT)
	
	g_iIonState[id] = PLANTED
	g_bUsed[id] = true
	
	g_iEnt[id] = engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,"info_target"));
	set_pev(g_iEnt[id],pev_classname,"info_target_ion");
	engfunc(EngFunc_SetModel,g_iEnt[id], W_MODEL);
	set_pev(g_iEnt[id],pev_owner, id);
	set_pev(g_iEnt[id],pev_movetype, MOVETYPE_TOSS);
	set_pev(g_iEnt[id],pev_solid, SOLID_TRIGGER);
	
	StartPosition(id, 0, 0, 50);
	set_pev(g_iEnt[id],pev_origin,g_fBeamMidOrigin[id]);

	BeconSound(id)
	set_task(2.1, "Approach", id+768);
	return PLUGIN_CONTINUE
}

public BeconSound(id)
{
	if(!g_iEnt[id]) return PLUGIN_CONTINUE
	
	g_iPitch[id] += 4
	g_fBeaconTime[id] -= 0.06
	if(g_iPitch[id] > 255) g_iPitch[id] = 255
	if(g_fBeaconTime[id] < 0.30) g_fBeaconTime[id] = 0.30
	emit_sound(g_iEnt[id], CHAN_ITEM, SOUND_BEEP, 0.4, ATTN_NORM, 0, g_iPitch[id])
	set_task(g_fBeaconTime[id], "BeconSound", id)
	return PLUGIN_CONTINUE
}

public Spawn(id)
{
	if(!is_user_alive(id) || !is_user_connected(id))
		return PLUGIN_CONTINUE;
	
	if(ma_klase[id])
	{
		uzywa[id] = false;
		g_bUsed[id] = false;
	}
	
	return PLUGIN_CONTINUE;
}

public Approach(id)
{
	id-=768
	//client_cmd(0, "spk ^"%s^"", SOUND_APPROACH)
	
	Start(id);
	set_task(4.0, "StartUp", id+785)
}

public Start(id)
{
	Count[id] = 4
        
	if(task_exists(id + 6969))
	{
		remove_task(id + 6969)
	}
	set_task(1.0, "CDN", id + 6969, _, _, "b")
        
	return PLUGIN_CONTINUE
}

public CDN(task_id)
{
	new id = task_id - 6969

	if(Count[id] > 1 && Count[id] <= 4)
	{	
		set_hudmessage(255, 100, 0, -1.00, 0.76, 2, 0.02, 0.8, 0.01, _, 1);
		show_hudmessage(id, "TSZY");
		emit_sound(id, CHAN_VOICE, SOUND_COUNT, 0.5, ATTN_NORM, 0, PITCH_NORM)
	}
	else if(Count[id] == 1)
	{
		set_hudmessage(255, 100, 0, -1.00, 0.76, 2, 0.02, 1.2, 0.01, _, 1);
		show_hudmessage(id, "TSZTEEERYY !!!");
		emit_sound(id, CHAN_VOICE, SOUND_COUNT2, 0.5, ATTN_NORM, 0, PITCH_NORM)
	}
	Count[id] --; 
        
	if(Count[id] <= 0)
	{
		if(task_exists(task_id))
		{
			remove_task(task_id)
		}
	}
}
	
public StartUp(id)
{
	id -= 785 ;

	new Float:mid_origin[MAX + 1][3];
	pev(g_iEnt[id], pev_origin,mid_origin[id]);
	new Float:fTmpDegress = 0.0
	g_fDistance[id] = 190.5 * 1.85;
	g_fRotationSpeed[id] = 0.0;
	for(new i=1; i<8; i++){
		g_fDegrees[id][i] = fTmpDegress;
		fTmpDegress += 45.0;
	}
	g_fBeamOrigin[id][0][0] = mid_origin[id][0] + 300.0
	g_fBeamOrigin[id][1][0] = mid_origin[id][0] + 300.0
	g_fBeamOrigin[id][2][0] = mid_origin[id][0] - 300.0
	g_fBeamOrigin[id][3][0] = mid_origin[id][0] - 300.0
	g_fBeamOrigin[id][4][0] = mid_origin[id][0] + 150.0
	g_fBeamOrigin[id][5][0] = mid_origin[id][0] + 150.0
	g_fBeamOrigin[id][6][0] = mid_origin[id][0] - 150.0
	g_fBeamOrigin[id][7][0] = mid_origin[id][0] - 150.0
	
	g_fBeamOrigin[id][0][1] = mid_origin[id][1] + 150.0
	g_fBeamOrigin[id][1][1] = mid_origin[id][1] - 150.0
	g_fBeamOrigin[id][2][1] = mid_origin[id][1] - 150.0
	g_fBeamOrigin[id][3][1] = mid_origin[id][1] + 150.0
	g_fBeamOrigin[id][4][1] = mid_origin[id][1] + 300.0
	g_fBeamOrigin[id][5][1] = mid_origin[id][1] - 300.0
	g_fBeamOrigin[id][6][1] = mid_origin[id][1] - 300.0
	
	g_fBeamMidOrigin[id] = mid_origin[id]
	
	new Float:addtime
	for(new i = 0; i < 8; i++) {
		addtime = addtime + 0.3
		new param[3]
		param[0] = i
		param[1] = id
		set_task(0.0 + addtime, "Trace_Start", _,param, 2)
	}
	
	//client_cmd(0, "spk ^"%s^"", SOUND_READY)
	emit_sound(g_iEnt[id], CHAN_VOICE, SOUND_READY, 0.5, ATTN_NORM, 0, PITCH_NORM)
	BeamRotate(id)
	for(new Float:i = 0.0; i < 7.5; i += 0.01)
		set_task(i+3.0, "BeamRotate", id)
	
	new Float:fire = random_float(13.0, 14.5)
	set_task(2.9,"IncreaseSpeed", id)
	set_task(12.5,"RemoveLasers", id)
	set_task(fire,"FireCannon", id)
	return PLUGIN_CONTINUE
}

public IncreaseSpeed(id) {
	if(g_fRotationSpeed[id] > 1.0) g_fRotationSpeed[id] = 1.0
	g_fRotationSpeed[id] += 0.1
	set_task(0.6,"IncreaseSpeed", id)
	return PLUGIN_CONTINUE
}

public RemoveLasers(id) remove_task(1018+id)

public BeamRotate(id)
{
	g_fDistance[id] -= 0.467
	//g_distance[id] -= 0.254
	for(new i = 0; i < 8; i++) {
		g_fDegrees[id][i] += g_fRotationSpeed[id]
		if(g_fDegrees[id][i] > 360.0)
			g_fDegrees[id][i] -= 360.0
		
		new Float:tmp[MAX + 1][3]
		tmp[id] = g_fBeamMidOrigin[id]
		
		tmp[id][0] += floatsin(g_fDegrees[id][i], degrees) * g_fDistance[id]
		tmp[id][1] += floatcos(g_fDegrees[id][i], degrees) * g_fDistance[id] 
		tmp[id][2] += 0.0 // -.-
		g_fBeamOrigin[id][i] = tmp[id]
	}
}

public Trace_Start(param[]) {
	new i = param[0]
	new id = param[1]
	
	new Float:get_random_z,Float:SkyOrigin[3]
	SkyOrigin = tlx_distance_to_sky(g_iEnt[id])
	get_random_z = random_float(300.0,SkyOrigin[2])
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, g_fBeamOrigin[id][i], 0)
	write_byte(TE_SPRITE)
	engfunc(EngFunc_WriteCoord, g_fBeamOrigin[id][i][0])
	engfunc(EngFunc_WriteCoord, g_fBeamOrigin[id][i][1])
	engfunc(EngFunc_WriteCoord, g_fBeamOrigin[id][i][2] + get_random_z)
	write_short(BlueFire)
	write_byte(10)
	write_byte(100)
	message_end()
	
	TraceAll(param)
}

public TraceAll(param[]) {
	new i = param[0]
	new id = param[1]
	
	new Float:SkyOrigin[3]
	SkyOrigin = tlx_distance_to_sky(g_iEnt[id])
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, g_fBeamOrigin[id][i], 0)
	write_byte(TE_BEAMPOINTS)
	engfunc(EngFunc_WriteCoord, g_fBeamOrigin[id][i][0])		//start point (x)
	engfunc(EngFunc_WriteCoord, g_fBeamOrigin[id][i][1])		//start point (y)
	engfunc(EngFunc_WriteCoord, SkyOrigin[2])			//start point (z)
	
	engfunc(EngFunc_WriteCoord, g_fBeamOrigin[id][i][0])		//end point (x)
	engfunc(EngFunc_WriteCoord, g_fBeamOrigin[id][i][1])		//end point (y)
	engfunc(EngFunc_WriteCoord, g_fBeamOrigin[id][i][2])		//end point (z)
	write_short(IonBeam)	//model
	write_byte(0)		//startframe
	write_byte(0)		//framerate
	write_byte(1)		//life
	write_byte(50)		//width
	write_byte(0)		//noise
	write_byte(255)		//r
	write_byte(255)		//g
	write_byte(255)		//b
	write_byte(255)		//brightness
	write_byte(0)		//speed
	message_end()
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, g_fBeamOrigin[id][i], 0)
	write_byte(TE_SPRITE)
	engfunc(EngFunc_WriteCoord, g_fBeamOrigin[id][i][0])
	engfunc(EngFunc_WriteCoord, g_fBeamOrigin[id][i][1])
	engfunc(EngFunc_WriteCoord, g_fBeamOrigin[id][i][2])
	write_short(LaserFlame)
	write_byte(5)
	write_byte(200)
	message_end()
	
	set_task(0.08,"TraceAll", 1018+id, param, 2)
}


public FireCannon(id) {
	new i = -1
	new className[33]
	//new Float:int = cod_get_user_intelligence(id)*10.0
	while((i = engfunc(EngFunc_FindEntityInSphere, i, g_fBeamMidOrigin[id], 750.0/*+int*/)) != 0) {
		pev(i, pev_classname, className, 32)
		if(pev_valid(i) && equal(className, "player")) {
			message_begin(MSG_ONE, IonShake, {0,0,0}, i)
			write_short(255<<14) //ammount
			write_short(10<<14) //lasts this long
			write_short(255<<14) //frequency
			message_end()
		}
		//next player in spehre.
		continue
	}

	new Float:skyOrigin[3]
	skyOrigin = tlx_distance_to_sky(g_iEnt[id])

	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, g_fBeamMidOrigin[id], 0)
	write_byte(TE_BEAMPOINTS) 
	engfunc(EngFunc_WriteCoord, skyOrigin[0])	//start point (x)
	engfunc(EngFunc_WriteCoord, skyOrigin[1])	//start point (y)
	engfunc(EngFunc_WriteCoord, skyOrigin[2])	//start point (z)

	engfunc(EngFunc_WriteCoord, g_fBeamMidOrigin[id][0])		//end point (x)
	engfunc(EngFunc_WriteCoord, g_fBeamMidOrigin[id][1])		//end point (y)
	engfunc(EngFunc_WriteCoord, g_fBeamMidOrigin[id][2])		//end point (z)
	write_short(IonBeam)	//model
	write_byte(0)		//startframe
	write_byte(0)		//framerate
	write_byte(15)		//life
	write_byte(255)		//width
	write_byte(0)		//noise
	write_byte(255)		//r
	write_byte(255)		//g
	write_byte(255)		//b
	write_byte(255)		//brightness
	write_byte(0)		//speed
	message_end()

	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY,g_fBeamMidOrigin, 0)
	write_byte(TE_BEAMCYLINDER)
	engfunc(EngFunc_WriteCoord, g_fBeamMidOrigin[id][0]) // start X
	engfunc(EngFunc_WriteCoord, g_fBeamMidOrigin[id][1]) // start Y
	engfunc(EngFunc_WriteCoord, g_fBeamMidOrigin[id][2]) // start Z

	engfunc(EngFunc_WriteCoord, g_fBeamMidOrigin[id][0]) // something X
	engfunc(EngFunc_WriteCoord, g_fBeamMidOrigin[id][1]) // something Y
	engfunc(EngFunc_WriteCoord, g_fBeamMidOrigin[id][2] + 2000.0 - 1000.0) // something Z
	write_short(Shockwave) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(100) // life
	write_byte(150) // width
	write_byte(0) // noise
	write_byte(0) // red
	write_byte(100) // green
	write_byte(250) // blue
	write_byte(150) // brightness
	write_byte(0) // speed
	message_end()

	for(new i = 1; i < 6; i++) {
		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, g_fBeamMidOrigin[id], 0)
		write_byte(TE_SPRITETRAIL)	// line of moving glow sprites with gravity, fadeout, and collisions
		engfunc(EngFunc_WriteCoord, g_fBeamMidOrigin[id][0])
		engfunc(EngFunc_WriteCoord, g_fBeamMidOrigin[id][1])
		engfunc(EngFunc_WriteCoord, g_fBeamMidOrigin[id][2])
		engfunc(EngFunc_WriteCoord, g_fBeamMidOrigin[id][0])
		engfunc(EngFunc_WriteCoord, g_fBeamMidOrigin[id][1])
		engfunc(EngFunc_WriteCoord, g_fBeamMidOrigin[id][2] + 200)
		write_short(BlueFlare) // (sprite index)
		write_byte(10) // (count)
		write_byte(random_num(15,20)) // (life in 0.1's)
		write_byte(10) // byte (scale in 0.1's)
		write_byte(random_num(30,70)) // (velocity along vector in 10's)
		write_byte(40) // (randomness of velocity in 10's)
		message_end()
	}
	
	remove_task(id)

	new attacker = pev(g_iEnt[id],pev_owner)
	
	while((i = engfunc(EngFunc_FindEntityInSphere, i, g_fBeamMidOrigin[id], 750.0/*+int*/)) != 0)
	{
		pev(i, pev_classname, className, 32)
		if(pev_valid(i) && equal(className, "player") && is_user_connected(i) && is_user_alive(i) && get_user_team(i) != get_user_team(attacker))
			ExecuteHamB(Ham_Killed, i, attacker, 2)
			
		continue;
	}
	
	//client_cmd(0, "spk ^"%s^"", SOUND_ATTACK)
	emit_sound(g_iEnt[id], CHAN_ITEM, SOUND_ATTACK, 0.6, ATTN_NORM, 0, PITCH_NORM)

	set_pev(g_iEnt[id], pev_flags, FL_KILLME)
	g_iEnt[id] = 0;
	g_iIonState[id] = NONE;
}

public StartPosition(id, forw, right, up)
{
	new Float:vOrigin[3], Float:vAngle[3], Float:vForward[3], Float:vRight[3], Float:vUp[3], Float:vSrc[3]
	
	pev(id, pev_origin, vOrigin)
	pev(id, pev_v_angle, vAngle)
	
	engfunc(EngFunc_MakeVectors, vAngle)
	
	global_get(glb_v_forward, vForward)
	global_get(glb_v_right, vRight)
	global_get(glb_v_up, vUp)
	
	vSrc[0] = vOrigin[0] + vForward[0] * forw + vRight[0] * right + vUp[0] * up
	vSrc[1] = vOrigin[1] + vForward[1] * forw + vRight[1] * right + vUp[1] * up
	vSrc[2] = vOrigin[2] + vForward[2] * forw + vRight[2] * right + vUp[2] * up
	
	g_fBeamMidOrigin[id][0] = vSrc[0]
	g_fBeamMidOrigin[id][1] = vSrc[1]
	g_fBeamMidOrigin[id][2] = vSrc[2]
}

stock Float:tlx_distance_to_sky(id)
{
	new Float:TraceEnd[3]
	pev(id, pev_origin, TraceEnd)

	new Float:f_dest[3]
	f_dest[0] = TraceEnd[0]
	f_dest[1] = TraceEnd[1]
	f_dest[2] = TraceEnd[2] + 8192.0

	new res, Float:SkyOrigin[3]
	engfunc(EngFunc_TraceLine, TraceEnd, f_dest, IGNORE_MONSTERS + IGNORE_GLASS, id, res)
	get_tr2(res, TR_vecEndPos, SkyOrigin)

	return SkyOrigin
}
