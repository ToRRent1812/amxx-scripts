/* 
[SPECIAL]
1 - Silencer/ Burst mode
2 - Shoot through shield
3 - Reactive zoom
4 - Dual weapon 
5 - Shotgun-like weapon
6 - Minigun
7 - RPG
8 - Nitro glyxeryl bullet 
9 - Reload like a shotgun and re-active zoom*/

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <csx>
#include <engine>
#include <torreinc>

#define PLUGIN "G4U RIFLE (ToRRent edit)"
#define VERSION "8.4"
#define AUTHOR "Nguyen Duy Linh"
#define max_wpn 100
#define max_nade_type 7
#define max_message 64
#define max_spawn_point 255
#define task_register_function 255113
#define task_reactive_my_zoom 22229999444566292
#define TASK_USE_FLASHLIGHT 223344001100
#define riffles (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6)|(1<<7)|(1<<8)|(1<<9) // Keys: 1234567890
#define key_menu (1<<9) // Keys: 0
#define key_menu (1<<9) // Keys: 0
#define PRIMARY_WEAPONS_BITSUM ((1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90))
#define BUY_BPAMMO "items/9mmclip1.wav"
#define TASK_SET_ME_MODEL 100020001500
#define addition_sight_begin 4
#define addition_sight_end 5
#define pready 29302
#define pwait 293022
#define rready 29304
#define rwait 293024
#define normal_wait 20302010
#define normal_ready 20312010
#define pnwait 200920102011
#define pnready 200820092010
#define shotgun_wait 30101995
#define shotgun_ready 30111996
#define shotgun_normal 20101995
#define shotgun_normal_ready 881994
#define reload_my_weapon 100010011002
#define active_my_grenade 900100010011002
#define show_my_ruler 25251325
#define show_nade_amount 66772508
#define reload_type_2 24102985
#define start_launcher 26032009
#define knife_attack 20111945
#define task_remove_my_weapon 19451946194719481949
#define task_active_iron 1234569876
#define task_reload_my_weapon 292827262524
#define task_insert_animation 5577392583473
#define task_active_atk 200300500
#define task_finish_reload 100300200500
#define task_add_me_ammo 300500
#define task_advertise 500300100
#define HIT_SHIELD 8
#define HUD_DRAW_CROSS (1<<7)
#define INSERT_ANIMATION 2
#define AFTER_INSERT_ANIMATION 3
#define LAUNCHER_ANIM_SILENCER_ADD 2
#define TASK_RELOAD_RPG 5000
#define ZOOM_DELAYED 0.5
#define is_user_valid_connected(%1) (1 <= %1 <= g_maxplayers && is_connected[%1])
new weapon_name[max_wpn][64], weapon_change[max_wpn], weapon_clip[max_wpn], weapon_bpa[max_wpn]
new Float:weapon_speed[max_wpn], Float:weapon_recoil[max_wpn], weapon_zoom_type[max_wpn]
new weapon_silencer[max_wpn], weapon_special_mode[max_wpn], weapon_hud_kill[max_wpn][100]
new Float:damage_player[max_wpn], Float:weapon_reload_time[max_wpn], Float:weapon_deploy_time[max_wpn]
new Float:damage_entity[max_wpn]
new Float:damage_hostage[max_wpn], Float:cl_pushangle[33][3]
new weapon_cost[max_wpn], weapon_level[max_wpn];/*weapon_cost_type[max_wpn]*/
new weapon_v_model[max_wpn][128], weapon_w_model[max_wpn][128], weapon_p_model[max_wpn][128], weapon_launching_nade[max_wpn][128]
new bool:in_zoom[33], has_weapon[33], ammo_cost[max_wpn], can_pick_ad[max_wpn]
new weapon_nade[max_wpn], Float:weapon_nade_delay[max_wpn], weapon_nade_type[max_wpn], Float:weapon_weight[max_wpn], weapon_nade_hud[max_wpn][256], weapon_nade_cost_type[max_wpn], weapon_nade_cost[max_wpn]
new Float:time_delay[33], user_nade[33][max_wpn], weapon_w_nade_model[max_wpn][256], weapon_nade_rendering[max_wpn][256]
new Float:weapon_start_firing[max_wpn], Float:weapon_finish_firing[max_wpn]
//new W_MODEL_PRECACHED[max_wpn][128], W_NADEMODE_PRECACHED[max_wpn][128]
new const riffle_model[][] = {"w_mp5", "w_tmp", "w_ump45", "w_p90", "w_mac10", "w_famas", "w_scout", "w_galil", "w_m4a1", "w_aug", "w_sg550", "w_g3sg1", "w_sg552", "w_ak47", "w_m249", "w_awp"}
new const riffle_length[] = {5, 5, 7, 5, 7, 7, 7, 7, 6, 5, 7, 7, 7, 6, 6, 5}
new const rifle_sound[][] = {"mp5-1.wav", "tmp-1.wav", "ump45-1.wav", "p90-1.wav", "mac10-1.wav","famas-1.wav", "scout_fire-1.wav", "galil-1.wav", "m4a1-1.wav", "aug-1.wav", "sg550-1.wav", "g3sg1-1.wav", "sg552-1.wav", "ak47-1.wav", "m249-1.wav", "awp1.wav", "famas-2.wav"}
new const riffle_name[][] = {"weapon_mp5navy", "weapon_tmp", "weapon_ump45","weapon_p90","weapon_mac10", "weapon_famas","weapon_scout", "weapon_galil", "weapon_m4a1", "weapon_aug", "weapon_sg550","weapon_g3sg1", "weapon_sg552", "weapon_ak47", "weapon_m249", "weapon_awp"}
new const rifle_change_mode[] = {6, 6, 6, 6, 6, 6, 5, 6, 14, 6, 6, 5, 6, 6, 5, 6}
new const weapon_shoot_animation[] = {3, 3, 3, 3, 3, 3, 1, 3, 1, 3, 1, 1, 3, 3, 1, 1}
new const weapon_max_animation[] =   {5, 5, 5, 5, 5, 5, 4, 5, 13, 5, 4, 4, 5, 5, 4, 5}
new const rifle_sequence_couch[] = {36, 16, 10, 10, 16, 10, 30, 77, 30, 10, 30, 36, 36, 77, 48, 30}
new const rifle_sequence_couch_shoot[] = {37, 17, 11, 11, 17, 11, 31, 78, 31, 11, 31, 37, 37, 78, 49, 31}
new const rifle_sequence_reload_couch[] = {38, 18, 12, 12, 18, 12, 32, 79, 32, 12, 32, 38, 38, 79, 50, 32}
new const rifle_sequence_stand[] = {39, 19, 13, 13, 19, 13, 33,  80, 33, 13, 33, 39, 39, 80, 51, 33} 
new const rifle_sequence_stand_shoot[] = {40, 20, 14, 14, 20, 14, 34, 81, 34, 14, 34, 40, 40, 81, 52, 34}
new const rifle_sequence_reload_stand[] = {41, 21, 15, 15, 21, 15, 35, 82, 35, 15, 35, 41, 41, 82, 53, 35}
new rifle_shoot_animation[3][16]
//new iWModelPrecached, iNadeModelPrecached
new iZoomLevel[33]
new g_weapon_count = 0
new const sound_directory[] = "weapons/"
new g_page[32], bool:in_touch[33], Float:zoom_delay[33]
new ent_nade_amount[max_wpn + 1024], ent_nade_clip[max_wpn + 1024], Float:nade_damage[max_wpn]
new weapon_sound[max_wpn][256], nade_sprite[max_wpn][256], nsprite_index[max_wpn]
new weapon_launch_type[max_wpn], Float:weapon_dspeed[max_wpn]
new Float:weapon_finish_reload[max_wpn], Float:weapon_time_per_bullet[max_wpn]
new Float:weapon_start_iron_time[max_wpn], Float:weapon_finish_iron_time[max_wpn], weapon_FOV[max_wpn]
new frame[max_wpn], nade_radius[max_wpn], bool:in_fshot[33], Float:shot_delay[33], Float:user_delay[33], bool:can_shot[33], in_tshot[33]
new g_weapon, g_result, laser, tspr
new weapon_file[max_wpn][256], weapon_kdistance[max_wpn], Float:weapon_knockback[max_wpn], Float:Weapon_MeleeRange[max_wpn], Float:Weapon_MeleeDamage[max_wpn]
new weapon_scope[max_wpn][2], weapon_PrecacheType[max_wpn], weapon_AlternativeModel[max_wpn][128], weapon_SubBody[max_wpn], weapon_nadePretype[max_wpn], weapon_nadeSub[max_wpn]
new rifle_menu 
new Float:weapon_nade_reload_time[max_wpn], weapon_SpriteScale[max_wpn]
new Float:Weapon_AtkTime[max_wpn], Float:Weapon_DmgTime[max_wpn]
new bool:ent_reload[max_wpn + 1024], bool:ent_launcher[max_wpn + 1024]
new FlashLightRadius[max_wpn], FlashLightColor[max_wpn][3], FlashLightType[max_wpn]
new weapon_BackModel[max_wpn][128], weapon_iBackSub[max_wpn]
new weapon_ASMAP[max_wpn]
new weapon_ExpSound[max_wpn][128]
new WeaponClass[max_wpn][128]
new weapon_type[max_wpn]
const m_pPlayer			= 41
const m_iId				= 43
const m_fKnown				= 44
const m_flNextPrimaryAttack	= 46
const m_flNextSecondaryAttack	= 47
const m_flTimeWeaponIdle		= 48
const m_iPrimaryAmmoType		= 49
const m_iClip				= 51
const m_fInReload			= 54
const m_fInSpecialReload		= 55
const m_fSilent			= 74
const m_flNextAttack		= 83
const m_rgAmmo_player_Slot0	= 376
stock const reload_animation[CSW_P90+1] = {
	-1,  5, -1, 3, -1,  6,   -1, 1, 1, -1, 14, 
		4,  1, 3,  1,  1,   13, 7, 4,  1,  3, 
		6, 11, 1,  3, -1,    4, 1, 1, -1,  1}
		
stock const Float:g_fDelay[CSW_P90+1] = {
	0.00, 2.70, 0.00, 2.00, 0.00, 0.55,   0.00, 3.15, 3.30, 0.00, 4.50, 
		 2.70, 3.50, 3.35, 2.45, 3.30,   2.70, 2.20, 2.50, 2.63, 4.70, 
		 0.55, 3.05, 2.12, 3.50, 0.00,   2.20, 3.00, 2.45, 0.00, 3.40
}

new bool:is_connected[33] 
new RIFLE_DEFAULT_MODEL[] = {"models/default_weapon.mdl"}
new g_maxplayers
enum
{
	TYPE_SMG = 3,
	TYPE_RIFLE,
	TYPE_MACHINEGUN,
	TYPE_RPG,
	TYPE_SUPERSNIPER,
}

new const CSWPN_AMMOID[] = { -1, 9, -1, 2, 12, 5, 14, 6, 4, 13, 10, 7, 6, 4, 4, 4, 6, 10,
            1, 10, 3, 5, 4, 10, 2, 11, 8, 4, 2, -1, 7
}

new const Float:kb_weapon_power[] = 
{
	-1.0,	// ---
	2.4,	// P228
	-1.0,	// ---
	1.5,	// SCOUT
	-1.0,	// ---
	8.0,	// XM1014
	-1.0,	// ---
	2.3,	// MAC10
	5.0,	// AUG
	-1.0,	// ---
	1.4,	// ELITE
	1.0,	// FIVESEVEN
	1.4,	// UMP45
	2.3,	// SG550
	1.5,	// GALIL
	1.5,	// FAMAS
	1.2,	// USP
	1.0,	// GLOCK18
	2.0,	// AWP
	2.5,	// MP5NAVY
	5.2,	// M249
	2.0,	// M3
	5.0,	// M4A1
	2.4,	// TMP
	1.5,	// G3SG1
	-1.0,	// ---
	1.3,	// DEAGLE
	1.15,	// SG552
	1.0,	// AK47
	-1.0,	// ---
	2.0	// P90
}

enum
{
	MODEL_NULL = 0,
	MODEL_FAMAS,
	MODEL_AK47,
	MODEL_AUG,
	MODEL_AWM,
	MODEL_G3SG1,
	MODEL_GALIL,
	MODEL_M3,
	MODEL_M4A1,
	MODEL_M249,
	MODEL_SG552,
	MODEL_TMP,
	MODEL_UMP45,
	MODEL_MAC10,
	MODEL_MP5NAVY,
	MODEL_XM1014,
	MODEL_P90,
	MODEL_DEAGLE,
	MODEL_ELITE,
	MODEL_FIVESEVEN,
	MODEL_USP,
	MODEL_P228,
	MODEL_GLOCK,
	MODEL_HEGRENADE,
	MODEL_SMOKEGRENADE,
	MODEL_FLASHBANG,
	MODEL_MEDKIT,
	MODEL_C4,
	MODEL_PISTOLSHEL,
	MODEL_RIFLESHEL,
	MODEL_SHOTGUNSHEL,
	MODEL_SG550,
	MODEL_SCOUT
}
new const DEFAULT_RMODEL[][] = {"models/w_mp5.mdl", "models/w_tmp.mdl", "models/w_ump45.mdl", "models/w_p90.mdl", "models/w_mac10.mdl", "models/w_famas.mdl", "models/w_scout.mdl", "models/w_galil.mdl", "models/w_m4a1.mdl", "models/w_aug.mdl", "models/w_sg550.mdl", "models/w_g3sg1.mdl", "models/w_sg552.mdl", "models/w_ak47.mdl", "models/w_m249.mdl", "models/w_awp.mdl"}
new const weapon_bpa_default[] = {90, 90, 100, 100, 100, 60, 20, 70, 60, 60, 40, 40, 60, 60, 100, 20}
//new const weapon_clip_default[] = {30, 30, 25, 50, 30, 25, 10, 35, 30, 30, 20, 20, 30, 30, 100, 10}
new const sprite_grenade_trail[] = { "sprites/laserbeam.spr" }
new g_trailSpr, launcher_nade_kill
new nade_clip[33][max_wpn], bool:in_launcher[33], bool:nade_reload[33]
new hud_column, hud_row, hud_nade
new spawn_menu
new g_knife_kill, g_function_active, g_reload, g_drop, g_animation
new g_RifleAttached
new g_weapon_selected; /*g_normal_selected*/
new g_WeaponEquiped, g_GLauncherActivated
new g_GLauncherDeactivated
new g_preload
new bool:ham_cz
enum
{
	anim_idle,
	anim_reload,
	anim_launch,
	anim_deploy
}

new cloth_sound[] = {"weapons/ak47_cloth.wav"}
new weapon_files[max_wpn][256]
new iCurrentZoom[33]
new bool:fInIdle[33]
new StartAtk[33], Float:fOpenFire[33]
new bool:Update[33]
new g_FOV[33]
new cvar_message, m_spriteTexture
new g_LoadType, g_RifleGetClip
new g_ReceivedRifle;/* g_DropRifle*/
new g_GetRecoil, Float:fRecoilReturn[33]
new g_GetShootSpeed, Float:fShootSpeedReturn[33]
new g_RifleDroped, g_RiflePickedUp
new iBpaReturn[33]
new g_ArmouryCreated, g_ArmourySetInfo, g_ArmouryPickedUp
new g_ActiveGLauncher
new g_GetGrenadeRadius, g_GetGrenadeDmg
new g_WeaponUseSpecialFunction, g_UpdateWpnClass, g_SetViewModel, g_SetWorldModel
new g_StartRegister
new Float:fGrenadeRadiusReturn[33], Float:fGrenadeDmgReturn[33]
new bool:fUseFlash[33]
enum
{
	LOAD_NONE = 0,
	LOAD_FULL,
	LOAD_SNIPER
}

new const WeaponMaxClip[] = {-1,  13, -1, 10,  1,  7,    1, 30, 30,  1,  30, 
		20, 25, 30, 35, 25,   12, 20, 10, 30, 100, 
		8 , 30, 30, 20,  2,    7, 30, 30, -1,  50}

new const MAXBPAMMO[] = { -1, 39, -1, 20, 1, 21, 1, 90, 60, 1, 90, 80, 75, 60, 70, 60, 72, 90,
			20, 90, 100, 24, 60, 90, 40, 1, 28, 60, 60, -1, 100 }
new weapon_HideVModel[max_wpn]
new bool:StartRegister
new sExplo

// FOR CS RED DOUBLE WEAPON
new g_GetDeployTime, g_GetReloadTime, g_GetWeight, g_GetDSpeed, g_GetRecoilPre, g_DeathHud, g_ClipPre, g_WeaponPlaySound
new Float:g_DeployTimeReturn[33], Float:g_ReloadTimeReturn[33], Float:fWeightReturn[33], Float:fDSpeedReturn[33]


// MSG ID
new iCrosshairMessage, iSetFOVMessage
public plugin_natives()
{
	/*register_native("g4u_get_user_riffle", "_get_riffle", 1)
	register_native("g4u_force_user_buy_riffle", "_force_buy", 1)
	register_native("g4u_force_user_drop_riffle", "_force_drop", 1)
	register_native("g4u_force_user_buy_rnade", "_force_nade", 1)
	register_native("g4u_get_riffle_wpnchange", "_get_wpnchange", 1)
	register_native("g4u_get_rifle_amount", "_get_weaponcount")
	register_native("g4u_give_weapon_bpa", "_give_ammo", 1)
	register_native("g4u_user_has_riffle", "_user_has_riffle", 1)
	register_native("g4u_equip_riffle", "_equip_player", 1)
	register_native("g4u_get_riffle_hud", "_riffle_hud", 1)
	register_native("g4u_get_riffle_name", "_riffle_name", 1)
	register_native("g4u_strip_user_riffle", "_set_weapon", 1)
	register_native("g4u_set_rifle_full_ammo", "_set_reload", 1)
	register_native("g4u_set_rifle_full_grenade", "_set_full_grenade", 1)
	register_native("g4u_current_rifle_weight", "_get_weapon_weight", 1)
	register_native("g4u_rifle_id_by_model", "_rifle_id_by_model", 1)
	register_native("g4u_nrifle_id_by_model", "_nrifle_id_by_model", 1)
	register_native("g4u_current_rifle_dspeed", "_get_rifle_dspeed", 1)
	register_native("g4u_equip_rifle_level", "_equip_with_level", 1)
	register_native("g4u_rifle_cost", "_rifle_cost", 1)
	register_native("g4u_rifle_get_bpammo", "_get_rifle_bpammo", 1)
	register_native("g4u_get_rifle_weight", "_get_weight", 1)
	register_native("g4u_get_rifle_dspeed", "_get_dspeed", 1)
	register_native("g4u_execute_rifle_file", "_execute_wpn_file", 1)
	register_native("g4u_set_rifle_load_type", "_set_rifle_load_type", 1)
	register_native("csred_rifle_clip", "_rifle_clip", 1)
	register_native("csred_give_rifle_clip", "_give_clip", 1)
	register_native("csred_rifle_bpammo", "_rifle_bpammo", 1)
	register_native("csred_rifle_set_bpa", "_rifle_set_bpa", 1)
	register_native("csred_set_bpa_return", "_set_bpa_return", 1)
	register_native("csred_using_glauncher", "_using_glauncher", 1)
	register_native("csred_get_nade_clip", "csred_get_nade_clip", 1)
	register_native("csred_rifle_nade_bpa", "_nade_bpa", 1)
	register_native("csred_get_rifle_nade", "_get_rifle_nade", 1)
	register_native("csred_is_launcher_wpn", "_is_launcher_wpn",1 )
	register_native("csred_set_user_gnade", "_set_user_gnade",1 )
	register_native("csred_get_weapon_type", "_get_weapon_type", 1)
	register_native("csred_rifle_func", "_get_func", 1)
	register_native("csred_get_rifle_recoil", "_get_recoil", 1)
	register_native("csred_get_rifle_speed", "_get_shoot_speed", 1)
	register_native("csred_set_shoot_speed", "_set_shoot_speed", 1)
	register_native("csred_set_recoil_return", "_set_recoil_return", 1)
	register_native("csred_SetRifleSpawn", "_SetRifleSpawn", 1)
	register_native("csred_RifleSetGrRadius", "_SetGrRadius", 1)
	register_native("csred_RifleSetGrDmg", "_SetGrDmg", 1)
	register_native("csred_RifleASmap", "_RifleASMAP", 1)
	
	register_native("csred_RifleCreateWpn", "_RifleCreateWpn", 1)
	register_native("csred_RifleStringSection", "_RifleStringSection", 1)
	register_native("csred_RifleIntegerSection", "_RifleIntegerSection", 1)
	register_native("csred_RifleFloatSection", "_RifleFloatSection", 1)
	register_native("csred_RifleInMap", "_SetNewRifleSpawn", 1)
	register_native("csred_IronsightOption", "_SetAdditionalInfoIronsight", 1)
	register_native("csred_SetSpecialFunc", "_SetSpecialFunc", 1)
	register_native("csred_ZoomOption", "_SetWeaponZoomOption", 1)
	register_native("_RifleSetDeployReturn", "_SetDeployReturn", 1)
	register_native("_RifleReloadTimeReturn", "_SetReloadTime", 1)
	register_native("_RifleSetWeightReturn", "_SetWeightReturn", 1)
	register_native("_RifleSetDSpeedReturn", "_SetDSpeedReturn", 1)
	register_native("_RifleSetShootSpeed", "_SetShootSpeed", 1)
	register_native("_RifleGetBackSub", "RifleGetBackSub", 1)
	register_native("_RifleGetBackModel", "RifleGetBackModel", 1)
	register_native("RifleRegisterDamage", "RegisterDamage", 1)*/
}

/*public RegisterDamage(iEnt, iType)
{
	if (!pev_valid(iEnt))
		return 
	if (iType < 0 || iType > 3)
		return
		
	if (iType == 1)
		RegisterHamFromEntity(Ham_TakeDamage, iEnt ,"pl_take_damage")
	else if (iType == 2)
		RegisterHamFromEntity(Ham_TakeDamage, iEnt, "hs_take_damage")
	else if (iType == 3)
		RegisterHamFromEntity(Ham_TakeDamage, iEnt, "ent_take_damage")
}


public _SetShootSpeed(id, Float:fSpeed)
	fShootSpeedReturn[id] = fSpeed
	
public _SetSpecialFunc(weaponid, iSpecial, iSpecialMode)
{
	weapon_silencer[weaponid] = iSpecial
	weapon_special_mode[weaponid] = iSpecialMode
}
	
public _SetDeployReturn(id, Float:fDeployTime)
	g_DeployTimeReturn[id] = fDeployTime
	
public _SetReloadTime(id, Float:fReloadTime)
	g_ReloadTimeReturn[id] = fReloadTime
	
public _SetWeightReturn(id, Float:fWeight)
	fWeightReturn[id] = fWeight
	
public _SetDSpeedReturn(id, Float:fDspeed)
	fDSpeedReturn[id] = fDspeed
	
public Float:_GetDeployTime(id, weaponid)
{
	if (weaponid < 0 || weaponid > max_wpn - 1)
		return 0.0
	ExecuteForward(g_GetDeployTime , g_result, id, weaponid, weapon_deploy_time[weaponid])
	if (g_result != PLUGIN_CONTINUE)
		return g_DeployTimeReturn[id]
	return weapon_deploy_time[weaponid]
}

public Float:_GetReloadTime(id, weaponid)
{
	if (weaponid < 0 || weaponid > max_wpn - 1)
		return 0.0
	ExecuteForward(g_GetReloadTime , g_result, id, weaponid, weapon_reload_time[weaponid])
	if (g_result != PLUGIN_CONTINUE)
		return g_ReloadTimeReturn[id]
	return weapon_reload_time[weaponid]
}

public _RifleASMAP(weaponid)
{
	if (weaponid < 0 || weaponid > max_wpn - 1)
		return 0
	return weapon_ASMAP[weaponid]
}

public _SetGrRadius(id, Float:fRadius)
	fGrenadeRadiusReturn[id] = fRadius

public _SetGrDmg(id, Float:fDmg)
	fGrenadeDmgReturn[id] = fDmg
	
public Float:_get_GLauncherDmg(id, weaponid)
{
	ExecuteForward(g_GetGrenadeDmg, g_result, id, weaponid, nade_damage[weaponid])
	if (g_result != PLUGIN_CONTINUE)
		return fGrenadeDmgReturn[id]
	return nade_damage[weaponid]
}
	
public Float:_get_GLauncherRadius(id, weaponid)
{
	ExecuteForward(g_GetGrenadeRadius, g_result, id, weaponid, float(nade_radius[weaponid]))
	if (g_result != PLUGIN_CONTINUE)
		return fGrenadeRadiusReturn[id]
	return float(nade_radius[weaponid])
}
	
public _set_recoil_return(id, Float:fRecoil)
	fRecoilReturn[id] = fRecoil
	
public _set_shoot_speed(id, Float:fSpeed)
	fShootSpeedReturn[id] = fSpeed
	
public Float:_get_shoot_speed(id, weaponid, IsNewWeapon)
{
	if (IsNewWeapon)
	{
		ExecuteForward(g_GetShootSpeed, g_result, id, weaponid, weapon_speed[weaponid])
		if (g_result != PLUGIN_CONTINUE)
			return fShootSpeedReturn[id]
		return weapon_speed[weaponid]
	}
	ExecuteForward(g_GetShootSpeed, g_result, id, weaponid, 1.0)
	if (g_result != PLUGIN_CONTINUE)
		return fShootSpeedReturn[id]
	return 1.0
}

public Float:_get_recoil(id, weaponid, IsNewWeapon)
{
	if (IsNewWeapon)
	{
		ExecuteForward(g_GetRecoilPre, g_result, id, weaponid, weapon_recoil[weaponid])
		if (g_result == PLUGIN_CONTINUE)
		{
			ExecuteForward(g_GetRecoil, g_result, id, weaponid, weapon_recoil[weaponid])
			if (g_result != PLUGIN_CONTINUE)
				return fRecoilReturn[id]
		}
		else
		{
			ExecuteForward(g_GetRecoil, g_result, id, weaponid, fRecoilReturn[id])
			if (g_result != PLUGIN_CONTINUE)
				return fRecoilReturn[id]
		}
		return weapon_recoil[weaponid]
	}
	ExecuteForward(g_GetRecoil, g_result, id, weaponid, 1.0)
	if (g_result != PLUGIN_CONTINUE)
		return fRecoilReturn[id]
	return 1.0
}

public _get_func(weaponid)
	return weapon_special_mode[weaponid]
	
public _get_weapon_type(weaponid)
{
	if (weaponid < 0 || weaponid > g_weapon_count - 1)
		return 0
	return weapon_type[weaponid]
}

public _set_user_gnade(id, weaponid, amount)
{
	if (weaponid < 0 || weaponid > g_weapon_count - 1)
		return 0
	if (weapon_special_mode[weaponid] != 2 && weapon_special_mode[weaponid] != 3)
		return 0
	user_nade[id][weaponid] = amount
	return 1
}

public _is_launcher_wpn(weaponid)
{
	if (weaponid < 0 || weaponid > g_weapon_count - 1)
		return 0
	if (weapon_special_mode[weaponid] != 2 && weapon_special_mode[weaponid] != 3)
		return 0
	return 1
}
public _get_rifle_nade(weaponid)
{
	if (weaponid < 0 || weaponid > g_weapon_count - 1)
		return 0
	return weapon_nade[weaponid]
}

public _nade_bpa(id, weaponid)
{
	if (!is_user_alive(id))
		return 0
	if (weaponid > g_weapon_count - 1)
		return 0
	return user_nade[id][weaponid]
}

public csred_get_nade_clip(id, weaponid)
{
	if (!is_user_alive(id))
		return 0
	if (weaponid > g_weapon_count - 1)
		return 0
	return nade_clip[id][weaponid]
}

public _using_glauncher(id)
{
	if (in_launcher[id])
		return 1
	return 0
}

public Float:_get_weight(id, wid)
{
	if (wid < 0 || wid > max_wpn - 1)
		return 0.0
	ExecuteForward(g_GetWeight, g_result, id, wid, weapon_weight[wid])
	if (g_result != PLUGIN_CONTINUE)
		return fWeightReturn[id]
	return weapon_weight[wid]
}

public Float:_get_dspeed(id, wid)
{
	if (wid < 0 || wid > g_weapon_count - 1)
		return 0.0
	ExecuteForward(g_GetDSpeed, g_result, id, wid, weapon_dspeed[wid])
	if (g_result != PLUGIN_CONTINUE)
		return fDSpeedReturn[id]
	return weapon_dspeed[wid]
}

public _rifle_bpammo(weaponid)
{
	if (weaponid < 0 || weaponid > g_weapon_count - 1)
		return 0
	return weapon_bpa[weaponid]
}

public _get_maxclip(id, weaponid, IsNewWeapon)
{
	if (IsNewWeapon)
	{
		if (weaponid < 0 || weaponid > g_weapon_count - 1)
			return 0
		if (weapon_silencer[weaponid] == 7)
			return 1
		ExecuteForward(g_ClipPre, g_result, id, weaponid, weapon_clip[weaponid])
		if (g_result == PLUGIN_CONTINUE)
		{
			ExecuteForward(g_RifleGetClip, g_result, id, weaponid, weapon_clip[weaponid])
			if (g_result != PLUGIN_CONTINUE)
				return g_result
		}
		else
		{
			new iClip = g_result
			ExecuteForward(g_RifleGetClip, g_result, id, weaponid, iClip)
			if (g_result != PLUGIN_CONTINUE)
				return g_result
		}
		return weapon_clip[weaponid]
	}
	else
	{
		ExecuteForward(g_RifleGetClip, g_result, id, weaponid, WeaponMaxClip[weaponid])
		if (g_result != PLUGIN_CONTINUE)
			return g_result
		return WeaponMaxClip[weaponid]
	}
	return 0
}

stock _execute_file(const con_file[], trash, const con_dir[], const mapname[], const txt[])
{
	if (g_weapon_count > max_wpn - 1)
		return
	weapon_PrecacheType[g_weapon_count] = 0
	new text[256]
	read_file(con_file, 0, text, 255, trash)
	replace(text, 255, "[name]", "")
	format(weapon_name[g_weapon_count], 255, "%s", text)
	read_file(con_file, 1, text, 255, trash)
	replace(text, 255, "[wpn_change]", "")
	weapon_change[g_weapon_count] = str_to_num(text)
	if (get_model(weapon_change[g_weapon_count]) < 0)
	{
		server_print("This weapon index is not supported, skip %s", con_file)
		return
	}
	if (g_LoadType == LOAD_NONE)
		return
	if (g_LoadType == LOAD_SNIPER)
	{
		new iId = weapon_change[g_weapon_count]
		if (iId != CSW_SCOUT && iId != CSW_AWP && iId != CSW_SG550 && iId != CSW_G3SG1)
			return
	}
	read_file(con_file, 2, text, 255, trash)
	replace(text, 255, "[clip]", "")
	weapon_clip[g_weapon_count] = str_to_num(text)
	if (weapon_clip[g_weapon_count] < 0)
		weapon_clip[g_weapon_count] = 1
	read_file(con_file, 3, text, 255, trash)
	replace(text, 255, "[bpa]", "")
	weapon_bpa[g_weapon_count] = str_to_num(text)
	read_file(con_file, 4, text, 255, trash)
	replace(text, 255, "[speed]", "")
	new start_iron_time[32], finish_iron_time[32], delay[32]
	parse(text, delay, 31, start_iron_time, 31, finish_iron_time, 31)
	weapon_speed[g_weapon_count] = str_to_float(delay)
	weapon_start_iron_time[g_weapon_count] = weapon_start_firing[g_weapon_count] = str_to_float(start_iron_time)
	weapon_finish_iron_time[g_weapon_count] = weapon_finish_firing[g_weapon_count] = str_to_float(finish_iron_time)
	if (weapon_start_iron_time[g_weapon_count] <= 0.0)
		weapon_start_iron_time[g_weapon_count] = weapon_finish_firing[g_weapon_count] = 0.4
	if (weapon_finish_iron_time[g_weapon_count] <= 0.0)
		weapon_finish_iron_time[g_weapon_count] = weapon_finish_firing[g_weapon_count] = 0.4
	read_file(con_file, 5, text, 255, trash)
	replace(text, 255, "[recoil]", "")
	weapon_recoil[g_weapon_count] = str_to_float(text)
	read_file(con_file, 6, text, 255, trash)
	replace(text, 255, "[zoom_type]", "")
	new ztype[32], ftype[32], stype[32]
	parse(text, ztype, 31, ftype, 31, stype, 31)
	weapon_zoom_type[g_weapon_count] = str_to_num(ztype)
	weapon_FOV[g_weapon_count] = 90 - str_to_num(ftype)
	weapon_scope[g_weapon_count][0] = str_to_num(ftype)
	weapon_scope[g_weapon_count][1] = str_to_num(stype)
	read_file(con_file, 7, text, 255, trash)
	replace(text, 255, "[special]", "")
	weapon_silencer[g_weapon_count] = str_to_num(text)
	if (weapon_silencer[g_weapon_count] < 0 || weapon_silencer[g_weapon_count] > 8)
		weapon_silencer[g_weapon_count] = 0
	read_file(con_file, 8, text, 255, trash)
	replace(text, 255, "[special_mode]", "")
	new fSpecialMode[3], fHideVModel[3]
	parse(text, fSpecialMode, 2, fHideVModel, 2)
	weapon_special_mode[g_weapon_count] = str_to_num(fSpecialMode)
	weapon_HideVModel[g_weapon_count] = str_to_num(fHideVModel)
	if (weapon_special_mode[g_weapon_count] < 0 || weapon_special_mode[g_weapon_count] > 13)
		weapon_special_mode[g_weapon_count] = 0
	if (weapon_silencer[g_weapon_count] == 7)
		weapon_clip[g_weapon_count] = 1
	if (weapon_silencer[g_weapon_count] == 4)
		weapon_special_mode[g_weapon_count] = 0
	read_file(con_file, 9, text, 255, trash)
	replace(text, 255, "[hud_kill]", "")
	format(weapon_hud_kill[g_weapon_count], 255, "%s", text)
	read_file(con_file, 10, text, 255, trash)
	replace(text, 255, "[damage_player]", "")
	damage_player[g_weapon_count] = str_to_float(text)
	read_file(con_file, 11, text, 255, trash)
	replace(text, 255, "[damage_entity]", "")
	damage_entity[g_weapon_count] = str_to_float(text)
	read_file(con_file, 12, text, 255, trash)
	replace(text, 255, "[damage_hostage]", "")
	damage_hostage[g_weapon_count] = str_to_float(text)
	read_file(con_file, 13, text, 255, trash)
	replace(text, 255, "[cost]", "")
	weapon_cost[g_weapon_count] = str_to_num(text)
	read_file(con_file, 14, text, 255, trash)
	replace(text, 255, "[model]", "")
	new cPreType[3], AlterModel[128], cSubBody[3], RealModel[128]
	parse(text, RealModel, 127, cPreType, 2, AlterModel, 127, cSubBody, 2)
	format(weapon_w_model[g_weapon_count], 127, "models/w_%s.mdl",RealModel)
	format(weapon_p_model[g_weapon_count], 127, "models/p_%s.mdl", RealModel)
	format(weapon_v_model[g_weapon_count], 127, "models/v_%s.mdl", RealModel)
	if (weapon_special_mode[g_weapon_count] == 2 || weapon_special_mode[g_weapon_count] == 3)
	{
		format(weapon_launching_nade[g_weapon_count], 127, "models/v_%s_l.mdl", RealModel)
		engfunc(EngFunc_PrecacheModel, weapon_launching_nade[g_weapon_count])
	}
	if (weapon_special_mode[g_weapon_count] == 12)
	{
		if (!weapon_HideVModel[g_weapon_count])
		{
			format(weapon_launching_nade[g_weapon_count], 127, "models/v_%s_s.mdl", RealModel)
			engfunc(EngFunc_PrecacheModel, weapon_launching_nade[g_weapon_count])
		}
		else	format(weapon_launching_nade[g_weapon_count], 127, "")
	}
	if (str_to_num(cPreType) > 0)
	{
		weapon_PrecacheType[g_weapon_count] = str_to_num(cPreType)
		format(weapon_AlternativeModel[g_weapon_count], 127, "models/w_%s.mdl", AlterModel)
		weapon_SubBody[g_weapon_count] = str_to_num(cSubBody)
		//precache_model(weapon_AlternativeModel[g_weapon_count])
		engfunc(EngFunc_PrecacheModel, weapon_AlternativeModel[g_weapon_count])
		//format(W_MODEL_PRECACHED[iWModelPrecached], 127, weapon_AlternativeModel[g_weapon_count])
		//	iWModelPrecached++
		//}
	}
	else engfunc(EngFunc_PrecacheModel, weapon_w_model[g_weapon_count])
	//precache_model(weapon_w_model[g_weapon_count])
	//precache_model(weapon_v_model[g_weapon_count])
	//precache_model(weapon_p_model[g_weapon_count])
	engfunc(EngFunc_PrecacheModel, weapon_v_model[g_weapon_count])
	engfunc(EngFunc_PrecacheModel, weapon_p_model[g_weapon_count])
	// If weapon is a grenade launcher
	//if (weapon_special_mode[g_weapon_count] == 2 || weapon_special_mode[g_weapon_count] == 3 || weapon_special_mode[g_weapon_count] == 12)
		//precache_model(weapon_launching_nade[g_weapon_count])
	
	read_file(con_file, 15, text, 255, trash)
	replace(text, 255, "[level]", "")
	weapon_level[g_weapon_count] = str_to_num(text)
	if (weapon_level[g_weapon_count] > get_cvar_num("cod_maxlevel"))
		weapon_level[g_weapon_count] =  get_cvar_num("cod_maxlevel")
	read_file(con_file, 16, text, 255, trash)
	replace(text, 255, "[ammo_cost]", "")
	ammo_cost[g_weapon_count] = str_to_num(text)
	if (ammo_cost[g_weapon_count] < 0)
		ammo_cost[g_weapon_count] = 10
	read_file(con_file, 17, text, 255, trash)
	replace(text, 255, "[can_pick_after_death]", "")
	can_pick_ad[g_weapon_count] = str_to_num(text)
	if (can_pick_ad[g_weapon_count] < 0)
		can_pick_ad[g_weapon_count] = 0
	if (can_pick_ad[g_weapon_count] > 1)
		can_pick_ad[g_weapon_count] = 1
	read_file(con_file, 18, text, 255, trash)
	replace(text, 255, "[nade_amount]", "")
	weapon_nade[g_weapon_count] = str_to_num(text)
	if (weapon_nade[g_weapon_count] < 0)
		weapon_nade[g_weapon_count] = 0
	read_file(con_file, 19, text, 255, trash)
	replace(text, 255, "[nade_delay]", "")
	new weapon_delay[32], weapon_reload[32]
	parse(text, weapon_delay, 31, weapon_reload, 31)
	weapon_nade_delay[g_weapon_count] = str_to_float(weapon_delay)
	weapon_nade_reload_time[g_weapon_count] = str_to_float(weapon_reload)
	if (weapon_nade_delay[g_weapon_count] <= 0.0)
		weapon_nade_delay[g_weapon_count] = 1.5
	if (weapon_nade_reload_time[g_weapon_count] <= 0.0)
		weapon_nade_reload_time[g_weapon_count] = 1.5
	read_file(con_file, 20, text, 255, trash)
	replace(text, 255, "[nade_type]", "")
	new type_launch[3], type_nade[3]
	parse(text, type_nade, 2, type_launch, 2)
	weapon_nade_type[g_weapon_count] = str_to_num(type_nade)
	weapon_launch_type[g_weapon_count] = str_to_num(type_launch)
	if (weapon_silencer[g_weapon_count] == 7)
		weapon_nade_type[g_weapon_count] = 1
	read_file(con_file, 21, text, 255, trash)
	replace(text, 255, "[nade_hud]", "")
	format(weapon_nade_hud[g_weapon_count], 255, "%s", text)
	read_file(con_file, 22, text, 255, trash)
	replace(text, 255, "[nade_cost]", "")
	weapon_nade_cost[g_weapon_count] = str_to_num(text)
	if (weapon_nade_cost[g_weapon_count] < 0)
		weapon_nade_cost[g_weapon_count] = 10
	read_file(con_file, 23, text, 255, trash)
	replace(text, 255, "[nade_model]", "")
	parse(text, RealModel, 127, cPreType, 2, cSubBody, 2)
	if (str_to_num(cPreType) > 0)
	{
		weapon_nadePretype[g_weapon_count] = 1
		weapon_nadeSub[g_weapon_count] = str_to_num(cSubBody)
		format(weapon_w_nade_model[g_weapon_count], 255, "models/w_%s.mdl", RealModel)
	}
	// Incase user doesnt wanna create a Laucher grenade weapon
	else format(weapon_w_nade_model[g_weapon_count], 255, "models/w_%s.mdl", RealModel)
	if (weapon_special_mode[g_weapon_count] == 2 || weapon_special_mode[g_weapon_count] == 3 || weapon_silencer[g_weapon_count] == 7)
	{
		//new iMdlCount = 0
		//for (new iModel = 0; iModel < iNadeModelPrecached; iModel++)
		//	if (equal(weapon_w_nade_model[g_weapon_count], W_NADEMODE_PRECACHED[iNadeModelPrecached]))
		//		iMdlCount++
		//		
		//if (iMdlCount < 1)
		//{
		//precache_model(weapon_w_nade_model[g_weapon_count])
		engfunc(EngFunc_PrecacheModel, weapon_w_nade_model[g_weapon_count]) 
		//	format(W_NADEMODE_PRECACHED[iNadeModelPrecached], 127, weapon_w_nade_model[g_weapon_count])
		//	iNadeModelPrecached++
		//}
	}
	read_file(con_file, 24, text, 255, trash)
	replace(text, 255, "[nade_render]", "")
	if (weapon_special_mode[g_weapon_count] == 2 || weapon_special_mode[g_weapon_count] == 3 || weapon_silencer[g_weapon_count] == 7)
		format(weapon_nade_rendering[g_weapon_count], 255, text)
	read_file(con_file, 25, text, 255, trash)
	replace(text, 255, "[sound]", "")
	format(weapon_sound[g_weapon_count], 255, "weapons/%s.wav", text)
	//precache_sound(weapon_sound[g_weapon_count])
	engfunc(EngFunc_PrecacheSound, weapon_sound[g_weapon_count])
	//server_print("%s precached %s", con_file, weapon_sound[g_weapon_count])
	read_file(con_file, 26, text, 255, trash)
	replace(text, 255, "[sprite]", "")
	format(nade_sprite[g_weapon_count], 255, "sprites/%s.spr", text)
	if (weapon_special_mode[g_weapon_count] == 2 || weapon_special_mode[g_weapon_count] == 3 || weapon_silencer[g_weapon_count] == 7)
		if (weapon_nade_type[g_weapon_count] == 3 || weapon_nade_type[g_weapon_count] == 1)
			//nsprite_index[g_weapon_count] = precache_model(nade_sprite[g_weapon_count])
			nsprite_index[g_weapon_count] = engfunc(EngFunc_PrecacheModel, nade_sprite[g_weapon_count])
	read_file(con_file, 27, text, 255, trash)
	if (weapon_special_mode[g_weapon_count] == 2 || weapon_special_mode[g_weapon_count] == 3 || weapon_silencer[g_weapon_count] == 7)
	{
		replace(text, 255, "[ninfo]", "")
		new cframe[4], cradius[32], cdamage[4], cscale[4], cSound[128]
		parse(text, cframe, 3, cradius, 31, cdamage, 3, cscale, 3, cSound, 127)
		frame[g_weapon_count] = str_to_num(cframe)
		nade_radius[g_weapon_count] = str_to_num(cradius)
		nade_damage[g_weapon_count] = str_to_float(cdamage)
		weapon_SpriteScale[g_weapon_count] = str_to_num(cscale)
		if (weapon_SpriteScale[g_weapon_count] <= 0)
			weapon_SpriteScale[g_weapon_count] = 10
		format(weapon_ExpSound[g_weapon_count], 127, "weapons/%s.wav", cSound)
		engfunc(EngFunc_PrecacheSound, weapon_ExpSound[g_weapon_count])
	}
	if (weapon_special_mode[g_weapon_count] == 9)
	{
		replace(text, 255, "[weapon_melee]", "")
		new cWeaponAtkTime[32], cWeaponDmgTime[32], cWeaponRange[32], cWeaponDamage[32]
		parse(text, cWeaponAtkTime, 31, cWeaponDmgTime, 31, cWeaponRange, 31, cWeaponDamage, 31)
		replace(cWeaponDmgTime, 31, "[DmgTime]", "")
		replace(cWeaponRange, 31, "[MeleeRange]", "")
		replace(cWeaponDamage, 31, "[MeleeDmg]", "")
		Weapon_AtkTime[g_weapon_count] = str_to_float(cWeaponAtkTime)
		Weapon_DmgTime[g_weapon_count] = str_to_float(cWeaponDmgTime)
		Weapon_MeleeRange[g_weapon_count] = str_to_float(cWeaponRange)
		Weapon_MeleeDamage[g_weapon_count] = str_to_float(cWeaponDamage)
	}
	read_file(con_file, 28, text, 255, trash)
	replace(text, 255, "[weight]", "")
	weapon_weight[g_weapon_count] = str_to_float(text)
	read_file(con_file, 29, text, 255, trash)
	replace(text, 29, "[dspeed]", "")
	weapon_dspeed[g_weapon_count] = str_to_float(text)
	read_file(con_file, 30, text, 255, trash)
	replace(text, 30, "[knockback-power]", "")
	weapon_knockback[g_weapon_count] = str_to_float(text)
	if (weapon_knockback[g_weapon_count] < 0.0)
		weapon_knockback[g_weapon_count] = 0.0
	read_file(con_file, 31, text, 255, trash)
	replace(text, 255, "[knockback-distance]", "")
	weapon_kdistance[g_weapon_count] = str_to_num(text)
	if (weapon_kdistance[g_weapon_count] < 0)
		weapon_kdistance[g_weapon_count] = 0
	read_file(con_file, 32, text, 255, trash)
	replace(text, 255, "[reload_time]", "")
	if (weapon_silencer[g_weapon_count] != 5)
		weapon_reload_time[g_weapon_count] = str_to_float(text)
	else 
	{
		new finfo[32], sinfo[32], tinfo[32]
		parse(text, finfo, 31, sinfo, 31, tinfo, 31)
		weapon_reload_time[g_weapon_count] = str_to_float(finfo)
		weapon_time_per_bullet[g_weapon_count] = str_to_float(sinfo)
		weapon_finish_reload[g_weapon_count] = str_to_float(tinfo)
	}
	read_file(con_file, 33, text, 255, trash)
	replace(text, 255, "[deploy_time]", "")
	weapon_deploy_time[g_weapon_count] = str_to_float(text)
	if (weapon_deploy_time[g_weapon_count] <= 0.0)
		weapon_deploy_time[g_weapon_count] = 1.5
	read_file(con_file, 34, text, 255, trash)
	replace(text, 255, "[wpn_type]", "")
	weapon_type[g_weapon_count] = str_to_num(text)
	if (weapon_type[g_weapon_count] < 1)
	{
		if (IsSmg(weapon_change[g_weapon_count]))
		{
			write_file(con_file, "[wpn_type]3", 36)
			weapon_type[g_weapon_count] = TYPE_SMG
		}
		else if (IsRifle(weapon_change[g_weapon_count]))
		{
			write_file(con_file, "[wpn_type]4", 36)
			weapon_type[g_weapon_count] = TYPE_RIFLE
		}
		else if (weapon_change[g_weapon_count] == CSW_M249)
		{
			write_file(con_file, "[wpn_type]5", 36)
			weapon_type[g_weapon_count] = TYPE_MACHINEGUN
		}
		
		if (weapon_silencer[g_weapon_count] == 7)
		{
			write_file(con_file, "[wpn_type]6", 36)
			weapon_type[g_weapon_count] = TYPE_RPG
		}
	}
	if (weapon_special_mode[g_weapon_count] == 10)
	{
		read_file(con_file, 35, text, 255, trash)
		replace(text, 255, "[FlashLightInfo]", "")
		new finfo[32], sinfo[32], tinfo[32], ftinfo[32], ftfinfo[32]
		parse(text, finfo, 31, sinfo, 31, tinfo, 31, ftinfo, 31, ftfinfo, 31)
		FlashLightType[g_weapon_count] = str_to_num(finfo)
		FlashLightColor[g_weapon_count][0] = str_to_num(sinfo)
		FlashLightColor[g_weapon_count][0] = str_to_num(tinfo)
		FlashLightColor[g_weapon_count][0] = str_to_num(ftinfo)
		FlashLightRadius[g_weapon_count] = str_to_num(ftfinfo)
	}
	read_file(con_file, 36, WeaponClass[g_weapon_count], 127, trash)
	replace(WeaponClass[g_weapon_count], 127, "[WpnClass]", "")
	register_clcmd(WeaponClass[g_weapon_count], "fw_ChangeWeapon")
	read_file(con_file, 36, text, 127, trash)
	replace(text, 127, "[AS-MAP]", "")
	weapon_ASMAP[g_weapon_count] = str_to_num(text)

	//ExecuteForward(g_precache, g_result, g_weapon_count)
	//server_print("Excute %s complete", con_file)
	// Add weapon to menu
	new info[3]
	format(info, 2, "%d", g_weapon_count)
	menu_additem(spawn_menu, weapon_name[g_weapon_count], info, ADMIN_ALL, -1)
	menu_additem(rifle_menu, weapon_name[g_weapon_count], info, ADMIN_ALL, -1)
	new spawn_file[256]
	format(spawn_file, 255, "%s/weapon_spawn/%s/%s.cfg", con_dir, mapname, txt)
	format(weapon_files[g_weapon_count], 255, "%s/weapon_config/%s.ini", con_dir, txt)
	format(weapon_file[g_weapon_count], 255, "%s", spawn_file)
	if (file_exists(spawn_file))
	{
		new Data[124], len;
		new line = 0;
		new pos[11][8];
		new g_SpawnVecs[max_spawn_point][3]
		new g_TotalSpawns = 0
		while(g_TotalSpawns < max_spawn_point && (line = read_file(spawn_file , line , Data , 123 , len) ) != 0 ) 
		{
			if (strlen(Data)<2) continue;
			parse(Data, pos[1], 7, pos[2], 7, pos[3], 7)
			// Origin
			g_SpawnVecs[g_TotalSpawns][0] = str_to_num(pos[1]);
			g_SpawnVecs[g_TotalSpawns][1] = str_to_num(pos[2]);
			g_SpawnVecs[g_TotalSpawns][2] = str_to_num(pos[3])
			
			ExecuteForward(g_ArmouryCreated, g_result)
			if (g_result != PLUGIN_CONTINUE)
				continue
			new ent = create_entity("info_target")
			
			ExecuteForward(g_ArmourySetInfo, g_result, ent)
			
			if (g_result != PLUGIN_CONTINUE)
				continue
			set_pev(ent, pev_classname, "new_riffle")
			set_pev(ent, pev_solid, SOLID_TRIGGER)
			set_pev(ent, pev_iuser1, weapon_clip[g_weapon_count])
			set_pev(ent, pev_iuser2, weapon_bpa[g_weapon_count])
			set_pev(ent, pev_iuser3, g_weapon_count)
			set_pev(ent, pev_iuser4, 1)
			set_pev(ent, pev_mins, {-3.0, -3.0, -3.0})
			set_pev(ent, pev_maxs, {3.0, 3.0, 3.0})
			new Float:origin[3], Float:vEnd[3]
			origin[0] = float(g_SpawnVecs[g_TotalSpawns][0])
			origin[1] = float(g_SpawnVecs[g_TotalSpawns][1])
			origin[2] = float(g_SpawnVecs[g_TotalSpawns][2])
			vEnd[0] = origin[0];
			vEnd[1] = origin[1];
			vEnd[2] = -1337.0;
			engfunc(EngFunc_TraceLine, origin, vEnd, 0, ent, 0);
			get_tr2(0, TR_vecEndPos, vEnd);
			set_pev(ent, pev_origin, vEnd)
			if (weapon_PrecacheType[g_weapon_count] > 0)
			{
				engfunc(EngFunc_SetModel, ent, weapon_AlternativeModel[g_weapon_count])
				set_pev(ent, pev_body, weapon_SubBody[g_weapon_count])
			}
			else engfunc(EngFunc_SetModel, ent, weapon_w_model[g_weapon_count])
			
			g_TotalSpawns++;
		}
	}
	g_weapon_count++
}

public _execute_wpn_file(const file[], trash, const cfgdir[], const mapname[], const txt[])
{
	param_convert(1)
	param_convert(3)
	param_convert(4)
	param_convert(5)
	_execute_file(file, trash, cfgdir, mapname, txt)
}

public _set_rifle_load_type(loadtype)
{
	if (loadtype != LOAD_FULL && loadtype != LOAD_SNIPER && loadtype != LOAD_NONE)
		return
	g_LoadType = loadtype
}

public _rifle_clip(weaponid)
{
	if (weaponid < 0 || weaponid > g_weapon_count -1)
		return 0
	return weapon_clip[weaponid]
}

public _give_clip(id, weaponid)
{
	if (weaponid < 0 || weaponid > g_weapon_count - 1)
		return 0
	new iBpa = cs_get_user_bpammo(id, weapon_change[weaponid])
	cs_set_user_bpammo(id, weapon_change[weaponid], iBpa + weapon_clip[weaponid])
	return 1
}

public _rifle_set_bpa(id, weaponid, iBpa)
{
	if (weaponid < 0 || weaponid > g_weapon_count - 1)
		return 0
	cs_set_user_bpammo(id, weapon_change[weaponid], iBpa)
	return 1
}

public _set_bpa_return(id, iAmount)
	iBpaReturn[id] = iAmount

public _SetRifleSpawn(iEnt)
{
	if(pev_valid(iEnt))
	{
		set_pev(iEnt, pev_effects, pev(iEnt, pev_effects) &~ EF_NODRAW)
		set_pev(iEnt, pev_iuser4, 1)
	}
}*/

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	cvar_message = register_cvar("wpn_reklama", "0")
	register_concmd("make_pspawn", "cmdmakespawn", ADMIN_ADMIN)
	register_clcmd("buyammo1", "cmdammo")
	register_clcmd("primammo", "cmdammo")
	register_clcmd("wpn_kup", "cmdbuy")
	register_clcmd("wpn_menu", "cmdmenu")
	//register_clcmd("wpn_sprzedaj", "cmdsell")
	register_clcmd("nade", "cmdnade")
	register_clcmd("-zmout", "cmdzoomout")
	register_clcmd("+zmin", "cmdzoomin")
	register_concmd("RifleBug", "cmdBug")
	register_event("CurWeapon","checkWeapon","be","1=1")
	//register_logevent("round_begin" , 2 , "1=Round_Start")
	register_event("HLTV", "round_begin", "a", "1=0", "2=0")
	register_touch("weaponbox", "player", "fw_touch")
	register_touch("weapon_shield", "player", "fw_shield_touch")
	register_touch("explosive_nade", "*", "fw_explo")
	register_touch("flash_nade", "*", "fw_flash_think")
	register_touch("smoke_nade", "*", "fw_smoke_touch")
	register_touch("new_riffle", "player", "fw_rtouch")
	register_touch("player_weaponstrip", "player", "fw_strip_own_weapon")
	register_think("smoke_nade","fw_smoke")
	register_think("child_grenade", "fw_child_think")
	register_think("other_class_nade", "fw_other_think")
	register_touch("child_grenade", "*", "fw_child_touch")
	register_touch("other_class_nade", "*", "fw_smoke_touch")
	register_touch("AirMissle", "*", "fw_missle")
	//register_think("AirMissle", "fw_MissleThink")
	register_message(get_user_msgid("DeathMsg"), "func_death")
	register_message(get_user_msgid("WeapPickup"),"message_weappickup")
	//register_message(get_user_msgid("Crosshair"), "message_crosshair")
	// menuid = register_menuid("[PRIMARY WEAPON LIST]")
	g_weapon = CreateMultiForward("g4u_player_equip", ET_IGNORE, FP_CELL, FP_CELL)
	launcher_nade_kill = CreateMultiForward("g4u_launcher_nade_kill", ET_IGNORE, FP_CELL, FP_CELL)
	g_knife_kill = CreateMultiForward("g4u_secondary_kill", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL)
	g_function_active = CreateMultiForward("g4u_rifle_special_function", ET_IGNORE, FP_CELL)
	g_reload = CreateMultiForward("g4u_rifle_reload", ET_IGNORE, FP_CELL)
	g_drop = CreateMultiForward("g4u_rifle_drop", ET_IGNORE, FP_CELL)
	g_animation = CreateMultiForward("g4u_rifle_play_animation", ET_IGNORE, FP_CELL, FP_CELL)
	g_weapon_selected = CreateMultiForward("g4u_rifle_selected", ET_IGNORE, FP_CELL, FP_CELL, FP_STRING, FP_STRING, FP_STRING)
	//g_normal_selected = CreateMultiForward("g4u_normal_rifle_selected", ET_IGNORE, FP_CELL, FP_CELL, FP_STRING)
	g_WeaponEquiped = CreateMultiForward("csred_user_equiped_bpa", ET_CONTINUE, FP_CELL, FP_CELL, FP_CELL, FP_CELL)
	g_GLauncherActivated = CreateMultiForward("csred_glauncher_activated", ET_IGNORE, FP_CELL, FP_CELL)
	g_GLauncherDeactivated = CreateMultiForward("csred_glauncher_deactivated", ET_IGNORE, FP_CELL, FP_CELL)
	g_RifleGetClip = CreateMultiForward("csred_rifle_get_clip", ET_CONTINUE, FP_CELL, FP_CELL, FP_CELL)
	g_ReceivedRifle = CreateMultiForward("csred_rifle_attached", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL)
	g_GetRecoil = CreateMultiForward("csred_rifle_get_recoil", ET_CONTINUE, FP_CELL, FP_CELL, FP_FLOAT)
	g_GetShootSpeed = CreateMultiForward("csred_rifle_get_speed", ET_CONTINUE, FP_CELL, FP_CELL, FP_FLOAT)
	g_RifleDroped = CreateMultiForward("csred_DropedRifle", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL, FP_CELL)
	g_RiflePickedUp = CreateMultiForward("csred_PickedRifle", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL, FP_CELL)
	g_RifleAttached = CreateMultiForward("csred_AttachedRifle", ET_IGNORE, FP_CELL, FP_CELL)
	g_ArmouryCreated = CreateMultiForward("csred_RifleCreated", ET_CONTINUE)
	g_ArmourySetInfo = CreateMultiForward("csred_RifleSetInfo", ET_IGNORE, FP_CELL)
	g_ArmouryPickedUp = CreateMultiForward("csred_RiflePickedUp", ET_IGNORE, FP_CELL, FP_CELL)
	g_ActiveGLauncher = CreateMultiForward("csred_GLauncherActivated", ET_CONTINUE, FP_CELL, FP_CELL)
	g_GetGrenadeRadius = CreateMultiForward("csred_RifleGrenadeRadius", ET_CONTINUE, FP_CELL, FP_CELL, FP_FLOAT)
	g_GetGrenadeDmg = CreateMultiForward("csred_RifleGrenadeDmg", ET_CONTINUE, FP_CELL, FP_CELL, FP_FLOAT)
	g_StartRegister = CreateMultiForward("csred_RifleStartRegister", ET_CONTINUE, FP_CELL)
	g_WeaponUseSpecialFunction = CreateMultiForward("csred_RifleSpecialFuncAtv", ET_CONTINUE, FP_CELL, FP_CELL)
	g_UpdateWpnClass = CreateMultiForward("csred_RifleUpdateWpnClass", ET_CONTINUE, FP_CELL, FP_CELL, FP_CELL)
	g_SetViewModel  = CreateMultiForward("csred_RifleSetViewModel", ET_CONTINUE, FP_CELL, FP_CELL)
	g_SetWorldModel = CreateMultiForward("csred_RifleSetWorldModel", ET_CONTINUE, FP_CELL, FP_CELL, FP_CELL)
	g_GetDeployTime = CreateMultiForward("csred_RifleDeployTime", ET_CONTINUE, FP_CELL, FP_CELL, FP_FLOAT)
	g_GetReloadTime = CreateMultiForward("csred_RifleReloadTime", ET_CONTINUE, FP_CELL, FP_CELL, FP_FLOAT)
	g_GetWeight = CreateMultiForward("csred_RifleWeight", ET_CONTINUE, FP_CELL, FP_CELL, FP_FLOAT)
	g_GetDSpeed = CreateMultiForward("csred_RifleDSpeed", ET_CONTINUE, FP_CELL, FP_CELL, FP_FLOAT)
	g_GetRecoilPre = CreateMultiForward("csred_RifleRecoilPre", ET_CONTINUE, FP_CELL, FP_CELL, FP_FLOAT)
	g_DeathHud = CreateMultiForward("csred_RifleDeathHud", ET_CONTINUE, FP_CELL, FP_CELL, FP_STRING)
	g_ClipPre = CreateMultiForward("csred_RifleGetClipPre", ET_CONTINUE, FP_CELL, FP_CELL,FP_CELL)
	g_WeaponPlaySound = CreateMultiForward("csred_RiflePlaySound", ET_CONTINUE, FP_CELL, FP_CELL, FP_STRING)
	
	iCrosshairMessage = get_user_msgid("Crosshair")
	iSetFOVMessage = get_user_msgid("SetFOV")
	hud_column = CreateHudSyncObj(1)
	hud_row = CreateHudSyncObj(2)
	hud_nade = CreateHudSyncObj(3)
	// register_menucmd(menuid, riffles, "show_weapon")
	register_forward(FM_EmitSound, "fw_emitsound")
	//register_forward(FM_SetClientMaxspeed, "fw_speed", 1)
	register_forward(FM_CmdStart, "fm_cmdstart")
	register_forward(FM_UpdateClientData, "fw_updatedata", 1)
	//register_forward(FM_PlayerPostThink, "pl_alive", 1)
	register_forward(FM_TraceLine, "onTraceLinePost")
	RegisterHam(Ham_Spawn, "player", "pl_spawn", 1)
	RegisterHam(Ham_Use, "player_weaponstrip", "fw_strip")
	RegisterHam(Ham_TakeDamage, "player", "pl_take_damage")
	RegisterHam(Ham_TakeDamage, "hostage_entity", "hs_take_damage")
	RegisterHam(Ham_TakeDamage, "monster_scientist", "hs_take_damage")
	RegisterHam(Ham_TakeDamage, "func_breakable", "ent_take_damage")
	RegisterHam(Ham_TakeDamage, "func_pushable", "ent_take_damage")
	RegisterHam(Ham_TraceAttack, "player", "fw_trace")
	RegisterHam(Ham_Player_PostThink, "player", "pl_alive", 1)
	for (new i = 0; i < sizeof riffle_name; i++)
	{
		RegisterHam(Ham_Weapon_PrimaryAttack, riffle_name[i], "pistol_primattack")
		RegisterHam(Ham_Weapon_PrimaryAttack, riffle_name[i], "pistol_primattack_post", 1)
		RegisterHam(Ham_Item_Deploy, riffle_name[i], "fw_item_deploy", 1)
		RegisterHam(Ham_Weapon_SecondaryAttack, riffle_name[i], "fw_weapon_special_attack")
		RegisterHam(Ham_Weapon_Reload, riffle_name[i], "fw_weaponreload", 1)
		RegisterHam(Ham_Item_PostFrame, riffle_name[i], "fw_itempostframe")
		RegisterHam(Ham_Item_AttachToPlayer, riffle_name[i], "Item_AttachToPlayer")
	}
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_m4a1", "fw_m4a1_secondary_atk")
	new con_dir[256], trash, mapname[32]
	get_mapname(mapname, 31)
	get_configsdir(con_dir, 255)
	rifle_menu = menu_create("PRIMARY WEAPON", "fw_primary_selection", -1)
	spawn_menu = menu_create("[G4U WEAPON] Weapon spawn list", "fw_wspawn", -1)
	new manager[256]
	ham_cz = false
	g_LoadType = LOAD_FULL
	ExecuteForward(g_preload, g_result)
	//iWModelPrecached = 0
	//iNadeModelPrecached = 0
	format(manager, 255, "%s/map_specific/%s.ngocvinh", con_dir, mapname)
	if (file_exists(manager))
	{
		for (new i = 0; i < file_size(manager, 1); i++)
		{
			if (i < max_wpn)
			{
				new con_file[256], txt[256], lenn
				read_file(manager, i, txt, 255, lenn)
				format(con_file, 255, "%s/weapon_config/%s.ini", con_dir, txt)
				// Create a weapon storage menu
				if (file_exists(con_file))
					_execute_file(con_file, trash, con_dir, mapname, txt)
			}
		}
	}
	else
	{
		format(manager, 255, "%s/manager.cfg", con_dir)
		for (new i = 0; i < file_size(manager, 1); i++)
		{
			if (i < max_wpn)
			{
				new con_file[256], txt[256], lenn
				read_file(manager, i, txt, 255, lenn)
				format(con_file, 255, "%s/weapon_config/%s.ini", con_dir, txt)
				// Create a weapon storage menu
				if (file_exists(con_file))
					_execute_file(con_file, trash, con_dir, mapname, txt)
			}
		}
	}
	format(manager, 255, "%s/map_addition/%s.cfg", con_dir, mapname)
	if (file_exists(manager))
	{
		for (new i = 0; i < file_size(manager, 1); i++)
		{
			new con_file[256], txt[256], lenn
			read_file(manager, i, txt, 255, lenn)
			format(con_file, 255, "%s/weapon_config/%s.redplane", con_dir, txt)
			if (file_exists(con_file))
				_execute_file(con_file, trash, con_dir, mapname, txt)
		}
	}
	StartRegister = true
	ExecuteForward(g_StartRegister, g_result, g_LoadType) 
	laser = engfunc(EngFunc_PrecacheModel, "sprites/ledglow.spr")
	engfunc(EngFunc_PrecacheSound, "weapons/glauncher.wav")
	engfunc(EngFunc_PrecacheSound, "items/9mmclip2.wav")
	engfunc(EngFunc_PrecacheSound, cloth_sound)
	engfunc(EngFunc_PrecacheModel, RIFLE_DEFAULT_MODEL)
	g_trailSpr = engfunc(EngFunc_PrecacheModel, sprite_grenade_trail)
	m_spriteTexture = engfunc(EngFunc_PrecacheModel, "sprites/laserbeam.spr")
	for (new psound = 0; psound < sizeof rifle_sound; psound++)
	{
		new presound[256]
		format(presound, 255, "%s/%s", sound_directory, rifle_sound[psound])
		//if (file_exists(presound))
		//precache_sound(presound)
		engfunc(EngFunc_PrecacheSound, presound)
	}
	// Load some informations of shooting animation
	rifle_shoot_animation[0] = {3, 3, 3, 3, 3, 3, 1, 3, 8, 3, 1, 1, 3, 3, 1, 1}
	rifle_shoot_animation[1] = {4, 4, 4, 4, 4, 4, 1, 4, 9, 4, 1, 1, 4, 4, 1, 2}
	rifle_shoot_animation[2] = {5, 5, 5, 5, 5, 5, 2, 5, 10,5, 2, 2, 5, 5, 2, 3}
	
	g_maxplayers = get_maxplayers()
	
	sExplo = engfunc(EngFunc_PrecacheModel, "sprites/zerogxplode.spr")
}

public plugin_precache()
{
	register_forward(FM_PrecacheModel, "fw_precache")
	register_forward(FM_SetModel, "fm_model")
	register_forward(FM_SetModel, "fm_model_post", 1)
	g_preload = CreateMultiForward("g4u_rifle_load_data", ET_IGNORE)
	register_dictionary("csred_rifle.txt")
}

public _get_riffle(id)
	return has_weapon[id]

public _force_buy(id, weaponid)
	buy_weapon(id, weaponid)

public _force_drop(id)
{
	if (has_weapon[id] <= -1)
		return 0
	if (user_has_weapon(id, weapon_change[has_weapon[id]]))
		return 0
	primary_wpn_drop(id)
	return 1
}

public _force_nade(id)
	cmdnade(id)

public _get_wpnchange(wpnid)
{
	if (wpnid < 0 || wpnid > g_weapon_count - 1)
		return -1
	return weapon_change[wpnid]
}

public _get_weaponcount()
	return g_weapon_count

public _give_ammo(id, weaponid)
{
	if (weaponid > g_weapon_count)
		return 0
	cs_set_user_bpammo(id, weapon_change[weaponid], weapon_bpa[weaponid])
	return 1
}

public _user_has_riffle(id)
	return has_weapon[id]
public _riffle_name(wpnid, name[], len)
{
	param_convert(2)
	if (wpnid > g_weapon_count || wpnid < 0)
		format(name, len,  "NULL")
	format(name, len, "%s", weapon_name[wpnid])
}


public Float:_get_rifle_dspeed(id)
{
	if (has_weapon[id] < 0)
		return 0.0
	return weapon_dspeed[has_weapon[id]]
}
	
public _equip_player(id, weaponid, client_message, server_message)
{
	if (weaponid > g_weapon_count - 1 || weaponid < 0)
		return
	if (!is_connected[id])
		return
	if (!pev_valid(id))
		return
	if (!is_user_alive(id))
		return 
		
	new iVip = cs_get_user_vip(id)
	if ((!iVip && weapon_ASMAP[weaponid] == 1) || (iVip && !weapon_ASMAP[weaponid]))
		return 
		
	if (iVip)
		cs_set_user_vip(id, 0, 0, 0)
		
	new weapon_give[256]
	primary_wpn_drop(id)
	in_touch[id] = true
	get_weaponname(weapon_change[weaponid], weapon_give, 255)
	has_weapon[id] = weaponid
	in_launcher[id] = false
	in_tshot[id] = false
	in_fshot[id] = false
	new ent = fm_give_item(id, weapon_give)
	if (!ent)
		return
	if (weapon_silencer[weaponid] == 1 && weapon_special_mode[weaponid] != 5 && weapon_special_mode[weaponid] != 11)
	{
		if (weapon_change[weaponid] == CSW_M4A1)
			cs_set_weapon_silen(ent, 1, 0)
		if (weapon_change[weaponid] == CSW_FAMAS)
			cs_set_weapon_burst(ent, 1)
	}
	if (weapon_special_mode[weaponid] != 10)
	{
		cs_set_weapon_ammo(ent, _get_maxclip(id, weaponid, 1))
		ExecuteForward(g_WeaponEquiped, g_result, id, weaponid, weapon_bpa[weaponid], _get_maxclip(id, weaponid, 1))
	}
	else
	{
		cs_set_weapon_ammo(ent, 1)
		ExecuteForward(g_WeaponEquiped, g_result, id, weaponid, weapon_bpa[weaponid], 1)
	}
	if (g_result != PLUGIN_HANDLED)
		cs_set_user_bpammo(id, weapon_change[weaponid], weapon_bpa[weaponid])
	else	cs_set_user_bpammo(id, weapon_change[weaponid], iBpaReturn[id])
	if (weapon_special_mode[weaponid] == 2 || weapon_special_mode[weaponid] == 3)
	{
		nade_clip[id][weaponid] = 1
		user_nade[id][weaponid] = weapon_nade[weaponid]
		
	}
	new name[32]
	get_user_name(id, name, 31)
	if (client_message > 0)
		client_print(id, print_center, "%L", id, "RECEIVED_WPN", weapon_name[weaponid])
	if (server_message > 0)
	{
		new players[32], number
		get_players(players, number, "agh")
		for (new i = 0; i < number; i++)
		{
			new player = players[i]
			if (player != id)
				client_print(player, print_center, "%L", id, "PLAYER_RECEIVED", name, weapon_name[weaponid])
		}
	}
	ExecuteForward(g_ReceivedRifle, g_result, id, 1, weaponid)
	if (iVip)
	{
		iVip = 0
		cs_set_user_vip(id, 1, 1, 1)
	}
	in_touch[id] = false
}


public _riffle_hud(weaponid, hud[], len)
{
	param_convert(2)
	if (weaponid > g_weapon_count)
		format(hud, len, "NULL")
	format(hud, len, weapon_hud_kill[weaponid])
}

public _set_weapon(id)
{
	new result = check_prim(id)
	if (result > -1)
	{
		new wid
		if (has_weapon[id] < 0)
		{
			wid = get_weaponid(riffle_name[result])
			ham_strip_weapon(id, riffle_name[result])
			cs_set_user_bpammo(id, wid, 0)
		}
		else
		{
			new name[32]
			get_weaponname(weapon_change[has_weapon[id]], name, 31)
			ham_strip_weapon(id, name)
			cs_set_user_bpammo(id, weapon_change[has_weapon[id]], 0)
			has_weapon[id] = -1
		}
	}
	has_weapon[id] = -1
	in_tshot[id] = false
	in_fshot[id] = false
}

public _set_reload(id, client_message, server_message)
{
	if (has_weapon[id] < 0)
	{
		new wid = check_prim(id)
		if (wid > -1)
		{
			new ent = find_ent_by_owner(-1, riffle_name[wid], id)
			if (!ent)
				return
			new weaponid = get_weaponid(riffle_name[wid])
			cs_set_weapon_ammo(ent, _get_maxclip(id, wid, 0))
			cs_set_user_bpammo(id, weaponid, weapon_bpa_default[wid])
		}
	}
	if (has_weapon[id] > -1)
	{
		cs_set_user_bpammo(id, weapon_change[has_weapon[id]], weapon_bpa[has_weapon[id]])
		new ent = fm_find_ent_by_owner(-1, riffle_name[get_model(weapon_change[has_weapon[id]])], id)
		if (weapon_special_mode[has_weapon[id]] != 10)
			cs_set_weapon_ammo(ent, _get_maxclip(id, has_weapon[id], 1))
		else	cs_set_weapon_ammo(ent, 1)
	}
	if (client_message)
		// client_printcolor(id, "[G4U MSG] Vu khi chinh da duoc nap dan")
		client_print(id, print_center, "PRIMARY_WPN_RELOADED")
	if (server_message)
	{
		new players[32], number
		get_players(players, number, "agh")
		new name[32]
		get_user_name(id, name, 31)
		for (new i = 0; i < number; i++)
		{
			new player = players[i]
			if (player != id)
				client_print(id, print_center, "%L", id, "PLAYER_RELOADED_PRIMARY", name)
		}
	}
}						

public _set_full_grenade(id, client_message, server_message)
{
	if (weapon_special_mode[has_weapon[id]] == 2 || weapon_special_mode[has_weapon[id]] == 3)
	{
		user_nade[id][has_weapon[id]] = weapon_nade[has_weapon[id]]
		nade_reload[id] = false
		remove_task(id + reload_my_weapon)
		remove_task(id + active_my_grenade)
		remove_task(id + reload_type_2)
		remove_task(id + start_launcher)
		nade_clip[id][has_weapon[id]] = 1
		SendWeaponAnim(id, 0)
	}	
	if (client_message)
		client_print(id, print_chat, "%L", id, "GLAUNCHER_RELOADED")
	if (server_message)
	{
		new players[32], number
		get_players(players, number, "agh")
		new name[32]
		get_user_name(id, name, 31)
		for (new i = 0; i < number; i++)
		{
			new player = players[i]
			if (player != id)
				client_print(id, print_center, "%s", player, "PLAYER_RELOADED_GLAUNCHER", name)
		}
	}
}

public Float:_get_weapon_weight(id)
{
	if (has_weapon[id] > -1 )
		return weapon_weight[has_weapon[id]]
	return 0.0
}

public _rifle_id_by_model(const model[], len)
{
	param_convert(1)
	for (new i = 0; i < g_weapon_count; i++)
		if (equal(model, weapon_w_model[i], len))
			return i
	return -1
}

public _nrifle_id_by_model(const model[], len)
{
	param_convert(1)
	for (new i = 0; i < sizeof riffle_model; i++)
	{
		new checkmodel[31]
		format(checkmodel, 31,  "models/%s.mdl", riffle_model[i])
		if (equal(model, checkmodel, 31))
			return get_weaponid(riffle_name[i])
	}
	return -1
}

public _equip_with_level(id, const model[], len)
{
	param_convert(2)
	new weaponid = get_rifle_id_by_model(model, len)
	if (!is_user_alive(id))
		return 0
	if (weaponid > g_weapon_count || weaponid < 0)
		return 0
	if (cod_get_user_level(id) < weapon_level[weaponid])
	{
		client_print(id, print_chat, "Potrzebujesz pozoim %d by dostac ta bron")
		return 0
	}
	new iVip = cs_get_user_vip(id)
	if ((!iVip && weapon_ASMAP[weaponid] == 1) || (iVip && !weapon_ASMAP[weaponid]))
		return 0
		
	if (iVip)
		cs_set_user_vip(id, 0, 0, 0)
	new weapon_give[256]
	//primary_wpn_drop(id)
	primary_wpn_strip(id)
	has_weapon[id] = weaponid
	in_touch[id] = true
	get_weaponname(weapon_change[weaponid], weapon_give, 255)
	new ent = fm_give_item(id, weapon_give)
	set_ability(weaponid, ent, id)
	if (weapon_special_mode[weaponid] != 10)
		cs_set_weapon_ammo(ent, _get_maxclip(id, weaponid, 1))
	else	cs_set_weapon_ammo(ent, 1)
	client_print(id, print_chat, "%L", id, "EQUIPED_WEAPON", weapon_name[weaponid])
	ExecuteForward(g_weapon, g_result, id, weaponid)
	if (weapon_special_mode[weaponid] == 2 || weapon_special_mode[weaponid] == 3)
		nade_clip[id][weaponid] = 1
	if (weapon_silencer[weaponid] == 7)
	{
		cs_set_weapon_ammo(ent, 1)
		ExecuteForward(g_WeaponEquiped, g_result, id, weaponid, 0, 1)
		if (g_result != PLUGIN_HANDLED)
			set_bpammo(id, weapon_change[weaponid], 0)
		else
			set_bpammo(id, weapon_change[weaponid], iBpaReturn[id])
	}
	//update_hud_WeaponList(id, weapon_change[weaponid], weapon_clip[weaponid] , WeaponClass[has_weapon[id]], weapon_bpa[has_weapon[id]], 1)
	in_touch[id] = false
	ExecuteForward(g_ReceivedRifle, g_result, id, 1, weaponid)
	if (iVip)
	{
		iVip = 0
		cs_set_user_vip(id, 1, 1, 1)
	}
	return 1
}

public _rifle_cost(wid)
{
	if (wid < 0 || wid > g_weapon_count - 1)
		return -1
	return weapon_cost[wid]
}

public _get_rifle_bpammo(wid)
{
	if (wid < 0 || wid > g_weapon_count - 1)
		return -1
	return weapon_bpa[wid]
}

public fw_precache(const model[])
{
	for (new unprecache = 0; unprecache < sizeof DEFAULT_RMODEL; unprecache ++)
		if (equal(model, DEFAULT_RMODEL[unprecache]))
			return FMRES_SUPERCEDE
	return FMRES_IGNORED
}

public client_putinserver(id)
{
	is_connected[id] = true
	//client_cmd(id, "bind MWHEELDOWN -zmout")
	//client_cmd(id, "bind MWHEELUP +zmin")
	//console_cmd(id, "bind MWHEELDOWN -zmout")
	//console_cmd(id, "bind MWHEELUP +zmin")
	//console_cmd(id, "bind [ g4u_menu")
}

public client_disconnect(id)
	is_connected[id] = false
public client_connect(id)
{
	has_weapon[id] = -1
	in_launcher[id] = false
	nade_reload[id] = false
	if (is_user_bot(id))
		set_task(0.1, "register_bot_function", id + task_register_function)
	//set_task(0.5, "show_launcher_ruler", id + show_my_ruler, _, _, "b")
	//set_task(0.5, "display_my_nade", id + show_nade_amount, _, _, "b")
}

public show_launcher_ruler(taskid)
{
	new id = taskid - show_my_ruler
	if (is_user_alive(id) && has_weapon[id] > -1)
	{
		if (weapon_special_mode[has_weapon[id]] == 2 || weapon_special_mode[has_weapon[id]] == 3)
		{
			if (get_user_weapon(id) == weapon_change[has_weapon[id]] && in_launcher[id] && !in_zoom[id])
			{
				set_hudmessage(0, 255, 0, -1.0, 0.52, 0, 0.0, 0.5, 0.0, 0.0, -1)
				ShowSyncHudMsg(id, hud_column, "|^n|^n|^n|^n|^n|")
				show_launcher_row(id)
			}
		}
	}
}

public executeRInfo()
{
	new fArg[128], sArg[128], trash
	read_argv(1, fArg, 127)
	read_argv(2, sArg, 127)
	new cfgdir[128], MapName[32]
	get_configsdir(cfgdir, 127)
	get_mapname(MapName, 31)
	_execute_file(fArg, trash, cfgdir, MapName, sArg)
}

public display_my_nade(taskid)
{
	new id = taskid - show_nade_amount
	if (is_user_alive(id) && has_weapon[id] > -1)
	{
		if (weapon_special_mode[has_weapon[id]] == 2 || weapon_special_mode[has_weapon[id]] == 3)
		{
			if (get_user_weapon(id) == weapon_change[has_weapon[id]] && in_launcher[id])
			{		
				set_hudmessage(255, 0, 0, 0.8, 0.7, 0, 0.0, 0.5, 0.0, 0.0, -1)
				ShowSyncHudMsg(id, hud_nade, "[Grenade Amount] %d", user_nade[id][has_weapon[id]])
			}
		}
	}
}

stock show_launcher_row(id)
{
	set_hudmessage(0, 0, 255, -1.0, 0.52, 0, 0.0, 0.5, 0.0, 0.0, -1)
	ShowSyncHudMsg(id, hud_row, "_________^n _______^n  _____^n ___^n__")
}
public register_bot_function(taskid)
{
	new id = taskid - task_register_function
	if (pev_valid(id) && !ham_cz && get_cvar_num("bot_quota"))
	{
		RegisterHamFromEntity(Ham_TakeDamage, id, "pl_take_damage")
		RegisterHamFromEntity(Ham_Spawn, id, "pl_spawn", 1)
		RegisterHamFromEntity(Ham_TraceAttack, id, "fw_trace")
		RegisterHamFromEntity(Ham_Player_UpdateClientData, id, "pl_alive_bot")
		ham_cz = true
	}
}

/*public g4u_zombie_appear_post(zombieid)
	has_weapon[zombieid] = -1
	
public g4u_infected_post(victim, infector)
	has_weapon[victim] = -1

*/	
public cmdBug(id)
{
	new cfgdir[128], FILE_NAME[256]
	get_configsdir(cfgdir, 127)
	format(FILE_NAME, 255, "%s/RifleBUG.txt", cfgdir)
	for (new i = 0; i < g_weapon_count; i++)
		write_file(FILE_NAME, weapon_w_model[i], -1)
}

public client_death(killer, victim)
{
	if (pev_valid(victim))
	{
		cs_set_user_zoom(victim, CS_RESET_ZOOM, 0)
		in_zoom[victim] = false
		reset_nade(victim)
		in_fshot[victim] = false
		in_tshot[victim] = false
		// in_launcher[victim] = false
		// nade_reload[victim] = false
		remove_task(victim + task_active_iron)
		remove_task(victim - task_active_iron)
		new menuid, key
		get_user_menu(victim, menuid, key)
		if (menuid)
		{
			if (menuid == spawn_menu)
				menu_cancel(victim)
			if (menuid == rifle_menu)
				menu_cancel(victim)
		}
		iZoomLevel[victim] = 0
		if (task_exists(victim + knife_attack))
			remove_task(victim + knife_attack)
	}
}

public cmdmakespawn(id)
{
	if (!is_user_alive(id))
		return
	menu_display(id, spawn_menu, 0)
	client_print(id, print_center ,"WPN_LIST_SHOWN")
}

public cmdammo(id)
{
	if (has_weapon[id] < 0)
		return PLUGIN_CONTINUE
	new money = cs_get_user_money(id)
	if (money < ammo_cost[has_weapon[id]])
		return PLUGIN_HANDLED
	if (weapon_silencer[has_weapon[id]] == 7)
		return PLUGIN_HANDLED
	if (!(cs_get_user_mapzones(id) & CS_MAPZONE_BUY))
		return PLUGIN_CONTINUE
	if (cs_get_user_bpammo(id, weapon_change[has_weapon[id]]) >= weapon_bpa[has_weapon[id]])
		return PLUGIN_HANDLED
	cs_set_user_bpammo(id, weapon_change[has_weapon[id]], weapon_bpa[has_weapon[id]])
	cs_set_user_money(id, money - ammo_cost[has_weapon[id]], 1)
	emit_sound(id, CHAN_VOICE, BUY_BPAMMO, 0.9, ATTN_STATIC, 0, PITCH_NORM)
	return PLUGIN_HANDLED
}

public cmdbuy(id, level, cid)
{
	if (cmd_access(id, level, cid, 2))
	{
		new fArg[3]
		read_argv(1, fArg, 3)
		new weapon_id = str_to_num(fArg)
		buy_weapon(id, weapon_id)
	}
}

public get_rifle_id_by_model(const model[], len)
{
	for (new i = 0; i < g_weapon_count; i++)
		if (equal(model, weapon_w_model[i], len))
			return i
	return -1
}
public cmdmenu(id)
{
	if (!is_user_alive(id))
		return
	menu_display(id, rifle_menu, 0)
}

public fw_wspawn(id, menu, item)
{
	if (!is_user_alive(id))
		return
	if (item == MENU_EXIT)
		return
	new name[32], info[3], cb, acc
	menu_item_getinfo(menu, item, acc, info, 2, name, 31, cb)
	new weaponid = str_to_num(info)
	new cfgdir[256], mapname[128]
	get_mapname(mapname, 127)
	get_configsdir(cfgdir, 255)
	new weapon_directory[256]
	format(weapon_directory, 255, "%s/weapon_spawn/%s", cfgdir, mapname)
	if (!dir_exists(weapon_directory))
		mkdir(weapon_directory)
	new ent = create_entity("info_target")
	set_pev(ent, pev_classname, "new_riffle")
	set_pev(ent, pev_solid, SOLID_TRIGGER)
	set_pev(ent, pev_iuser1, weapon_clip[weaponid])
	set_pev(ent, pev_iuser2, weapon_bpa[weaponid])
	set_pev(ent, pev_iuser3, weaponid)
	set_pev(ent, pev_iuser4, 0)
	set_pev(ent, pev_mins, {-3.0, -3.0, -3.0})
	set_pev(ent, pev_maxs, {3.0, 3.0, 3.0})
	new Float:origin[3], Float:vEnd[3]
	pev(id, pev_origin, origin)
	// origin[0] = float(g_SpawnVecs[g_TotalSpawns][0])
	// origin[1] = float(g_SpawnVecs[g_TotalSpawns][1])
	// origin[2] = float(g_SpawnVecs[g_TotalSpawns][2])
	vEnd[0] = origin[0];
	vEnd[1] = origin[1];
	vEnd[2] = -1337.0;
	engfunc(EngFunc_TraceLine, origin, vEnd, 0, ent, 0);
	get_tr2(0, TR_vecEndPos, vEnd);
	set_pev(ent, pev_origin, vEnd)
	if (weapon_PrecacheType[weaponid] > 0)
	{
		engfunc(EngFunc_SetModel, ent, weapon_AlternativeModel[weaponid])
		set_pev(ent, pev_body, weapon_SubBody[weaponid])
	}
	else engfunc(EngFunc_SetModel, ent, weapon_w_model[weaponid])
	//engfunc(EngFunc_SetModel, ent, weapon_w_model[weaponid])
	new line[128]
	format(line, 127, "%d %d %d", floatround(origin[0]),floatround(origin[1]), floatround(origin[2]))
	write_file(weapon_file[weaponid], line, -1)
	if (file_exists(weapon_file[weaponid]))
		client_print(id, print_center, "ADD_SPAWN_POINT_SUCCESS")
	menu_display(id, menu, 0)
}

/*public cmdsell(id)
{
	if (!is_user_alive(id))	
		return
	if (!cs_get_user_buyzone(id))
	{
		client_print(id, print_chat, "[G4U MSG] Giao dich chi duoc thuc hien tai Cua hang")
		return
	}
	if (has_weapon[id] >= 0)
	{
		if (weapon_change[has_weapon[id]] == get_user_weapon(id))
		{
			new weaponname[256]
			get_weaponname(weapon_change[has_weapon[id]], weaponname, 255)
			ham_strip_weapon(id, weaponname)
			if (weapon_cost_type[has_weapon[id]] == 1)
				cs_set_user_money(id, cs_get_user_money(id) + weapon_cost[has_weapon[id]] * (25/100), 1)
			else if (weapon_cost_type[has_weapon[id]] == 2)
				g4u_set_user_coin(id, g4u_get_user_coin(id) + weapon_cost[has_weapon[id]] * (25/100))
			has_weapon[id] = -1
			client_print(id, print_chat, "[G4U MSG] Giao dich thanh cong")
		}
	}
	else if (has_weapon[id] < 0)
	{
		new weaponid = get_user_weapon(id)
		if (get_model(weaponid) != -1)
		{
			new weaponname[32]
			get_weaponname(weaponid, weaponname, 31)
			ham_strip_weapon(id, weaponname)
			cs_set_user_money(id, cs_get_user_money(id) + weapon_price[get_model(weaponid)] * 25/100, 1)
			primary_wpn_drop(id)
			client_print(id, print_chat, "[G4U MSG] Giao dich thanh cong")
		}
	}
}
*/
public cmdnade(id)
{
	if (!is_user_alive(id))
		return PLUGIN_HANDLED
	if (has_weapon[id] <= -1)
		return PLUGIN_HANDLED
	if (!(cs_get_user_mapzones(id) & CS_MAPZONE_BUY))
		return PLUGIN_HANDLED
	new weaponid = has_weapon[id]
	if (weapon_special_mode[weaponid] != 2 && weapon_special_mode[weaponid] != 3 )
		return PLUGIN_HANDLED
	if (weapon_silencer[weaponid] == 7)
		return PLUGIN_HANDLED
	if (user_nade[id][weaponid] >= weapon_nade[weaponid])
		return PLUGIN_HANDLED
	new money = cs_get_user_money(id)
	new ent = find_ent_by_owner(-1, riffle_name[get_model(weapon_change[has_weapon[id]])], id)
	if (weapon_nade_cost_type[weaponid] == 1)
	{
		if (money >= weapon_nade_cost[weaponid])
		{
			user_nade[id][weaponid]++
			cs_set_user_money(id, money - weapon_nade_cost[weaponid], 1)
			emit_sound(id, CHAN_ITEM, "items/9mmclip2.wav", 0.3, ATTN_NORM, 0, PITCH_NORM)
			if (nade_clip[id][weaponid] < 1 && in_launcher[id] && get_user_weapon(id) == weapon_change[has_weapon[id]])
				release_my_grenade(ent)
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_HANDLED
}

public cmdzoomout(id)
{
	if (!is_user_alive(id))
		return
	if (has_weapon[id] < 0)
		return
	if (get_user_weapon(id) != weapon_change[has_weapon[id]])
		return
	if (weapon_special_mode[has_weapon[id]] != 13)
		return
	if (get_gametime() - zoom_delay[id] >= 0.1 && !in_launcher[id] && in_zoom[id])
	{	
		if (g_FOV[id] <= weapon_scope[has_weapon[id]][0])
		{
			g_FOV[id] = 0
			SetFOV(id, 90)
			in_zoom[id] = false
		}
		else 
		{	
			g_FOV[id]--
			SetFOV(id, 90 - g_FOV[id])
			client_cmd(id, "spk weapons/zoom.wav")
		}
		zoom_delay[id] = get_gametime()
	}
}

public cmdzoomin(id)
{
	if (!is_user_alive(id))
		return
	if (has_weapon[id] < 0)
		return
	if (get_user_weapon(id) != weapon_change[has_weapon[id]])
		return
	if (weapon_special_mode[has_weapon[id]] != 13)
		return
	if (get_gametime() - zoom_delay[id] >= 0.1 && !in_launcher[id] && in_zoom[id])
	{	
		if (g_FOV[id] >= weapon_scope[has_weapon[id]][1])
		{
			g_FOV[id] = 0
			SetFOV(id, 90)
			in_zoom[id] = false
		}
		else 
		{	
			g_FOV[id]++
			SetFOV(id, 90 - g_FOV[id])
			client_cmd(id, "spk weapons/zoom.wav")
		}
		zoom_delay[id] = get_gametime()
	}
}

public fw_ChangeWeapon(id)
{
	if (!is_user_alive(id))
		return PLUGIN_CONTINUE
	if (has_weapon[id] < 0)
		return PLUGIN_CONTINUE
	new WeaponName[32]
	get_weaponname(weapon_change[has_weapon[id]], WeaponName, 31)
	client_cmd(id, WeaponName)
	return PLUGIN_HANDLED
}

public checkWeapon(id)
{
	if (!is_user_alive(id))
		return
	if (has_weapon[id] > -1)
	{
		//format(hud, 255, "p_%s", weapon_hud_kill[has_weapon[id]])
		new clip, ammo
		new iWeaponid = get_user_weapon(id, clip, ammo)
		if ( iWeaponid == weapon_change[has_weapon[id]])
		{
			new number_change = get_model(weapon_change[has_weapon[id]])
			if (number_change < 0)
				return
			new Ent = fm_find_ent_by_owner(-1, riffle_name[number_change], id)
			new specmode = weapon_special_mode[has_weapon[id]]
			if (specmode == 5 && get_user_weapon(id) != CSW_M4A1 || specmode == 11 && get_user_weapon(id) != CSW_M4A1)
			{
				remove_task(id + task_active_iron)
				remove_task(id - task_active_iron)
				draw_cross(id)
				in_zoom[id] = false
				cs_set_weapon_silen(Ent, 0, 0)
			}
			
			ExecuteForward(g_SetViewModel, g_result, id, has_weapon[id])
			if (g_result == PLUGIN_CONTINUE)
			{
				if (specmode == 2 || specmode == 3)
				{
					if (in_launcher[id])
						set_pev(id, pev_viewmodel2, weapon_launching_nade[has_weapon[id]])
					else
						set_pev(id, pev_viewmodel2, weapon_v_model[has_weapon[id]])
				}		
				if (specmode !=2 && specmode != 3)
				{
					if (specmode == 12)
					{
						if (in_zoom[id])
							set_pev(id, pev_viewmodel2, weapon_launching_nade[has_weapon[id]])
						else set_pev(id, pev_viewmodel2, weapon_v_model[has_weapon[id]])
					}
					else set_pev(id, pev_viewmodel2, weapon_v_model[has_weapon[id]])
				}
				set_pev(id, pev_weaponmodel2, weapon_p_model[has_weapon[id]])
			}
			ExecuteForward(g_UpdateWpnClass, g_result, id, has_weapon[id], iWeaponid)
			if (g_result == PLUGIN_CONTINUE)
				update_hud_WeaponList(id, iWeaponid, clip , WeaponClass[has_weapon[id]], weapon_bpa[has_weapon[id]], 1)
			// show_icon(id, hud, 1)
			ExecuteForward(g_weapon_selected, g_result, id, has_weapon[id], weapon_name[has_weapon[id]], weapon_hud_kill[has_weapon[id]], weapon_files[has_weapon[id]])
		}
		// else reset_icon(id)
	}
	//else
	//{
		//if (cs_get_user_hasprim(id))
		//{
			//new hud[128]
			//new wid = get_user_weapon(id)
			/*new iGetId  = get_model(wid)
			if (get_model(wid) > -1)
			{
				format(hud, 127, "%s", riffle_name[iGetId])
				replace(hud, 127, "weapon_", "")
				ExecuteForward(g_normal_selected, g_result, id, wid, hud)
				// show_icon(id, hud, 1)
			}
			else reset_icon(id)*/
	//	}
	//}
}

public round_begin()
{
	fm_remove_entity_name("explosive_nade")		
	fm_remove_entity_name("flash_nade")	
	fm_remove_entity_name("smoke_nade")	
	fm_remove_entity_name("other_class_nade")
	fm_remove_entity_name("AirMissle")
	new players[32], number
	get_players(players, number, "agh")
	/*for (new i = 0; i < number; i++)
	{
		new id = players[i]
		if (has_weapon[id] > -1 && get_user_weapon(id) == weapon_change[has_weapon[id]])
		{
			new ent = fm_find_ent_by_owner(-1, riffle_name[get_model(weapon_change[has_weapon[id]])], id)
			new fInReload = get_pdata_int(ent, m_fInReload, 4)
			if (fInReload)
			{
				reload_without_ammo(id)
				cs_set_weapon_ammo(ent, ammo_reload[id])
				cs_set_user_bpammo(id, weapon_change[has_weapon[id]], user_bpa[id])
				set_pdata_int(ent, m_fInReload, 0, 4)
			}
		}
	}*/
	new iEnt
	while((iEnt = engfunc(EngFunc_FindEntityByString, iEnt, "classname", "new_riffle")))
	{
		if(pev_valid(iEnt))
		{
			set_pev(iEnt, pev_effects, pev(iEnt, pev_effects) &~ EF_NODRAW)
			set_pev(iEnt, pev_iuser4, 1)
		}
	}
	/*for (new i = 0; i < entity_count(); i++)
	{
		if (!pev_valid(i))
		{
			new classname[32]
			pev(i, pev_classname, classname, 31)
			if (equal(classname, "hostage_entity", 14) || equal(classname, "monster_scientist",  17))
				if (pev(i, pev_iuser1) > 0)
					set_pev(i, pev_iuser1, 0)
		}
	}*/
}

public fw_speed(id, Float:speed)
{
	if (has_weapon[id] > -1 && get_user_weapon(id) == weapon_change[has_weapon[id]])
	{
		new Float:myspeed = speed
		set_pev(id, pev_maxspeed, speed - (weapon_weight[has_weapon[id]] / 100) * speed)
		engfunc(EngFunc_SetClientMaxspeed, id, myspeed - (weapon_weight[has_weapon[id]] / 100) * myspeed)
	}
	return FMRES_IGNORED
}

public fm_model(ent, const model[])
{
	for (new unprecache = 0; unprecache < sizeof DEFAULT_RMODEL; unprecache ++)
	{
		if (equal(model[7], riffle_model[unprecache], riffle_length[unprecache]))
		{
			new classname[32]
			pev(ent, pev_classname, classname, 31)
			if (!equal(classname, "weaponbox", 9))
			{
				engfunc(EngFunc_SetModel, ent, RIFLE_DEFAULT_MODEL)
				set_pev(ent, pev_model, RIFLE_DEFAULT_MODEL)
				//engfunc(EngFunc_SetModel, ent, "models/p_m4a1.mdl")
				new weaponid = get_weaponid(riffle_name[unprecache])
				set_pev(ent, pev_body, get_weapon_backmodel(weaponid))
				//set_pev(ent, pev_iuser1, get_weapon_backmodel(weaponid))
				//set_task(0.5, "SetModelToMe", ent + TASK_SET_ME_MODEL)
			}
			return FMRES_SUPERCEDE
		}
	}
	return FMRES_IGNORED
}

public fm_model_post(ent, const model[])
{
	if (!pev_valid(ent))
		return FMRES_IGNORED
	new id = pev(ent, pev_owner)
	if (!pev_valid(id))
		return FMRES_IGNORED
	new classname[32]
	pev(ent, pev_classname, classname, 31)
	if (equal(classname, "weaponbox", 9))
	{
		if (has_weapon[id] > -1)
		{
			new cmodel[256]
			new model_num = get_model(weapon_change[has_weapon[id]])
			format(cmodel, 255, "%s", riffle_model[model_num])
			if (equal(model[7], cmodel, riffle_length[model_num]))
			{
				new clip, ammo
				get_user_ammo(pev(ent, pev_owner), weapon_change[has_weapon[id]], clip, ammo)
				set_pev(ent, pev_iuser1, clip)
				set_pev(ent, pev_iuser2, ammo)
				set_pev(ent, pev_iuser3, has_weapon[id])
				set_pev(ent, pev_iuser4, rwait)
				// set_pev(ent, pev_owner, id)
				if (can_pick_ad[has_weapon[id]] == 0)
					if (!is_user_alive(id))
						set_pev(ent, pev_nextthink, get_gametime() + 0.01)
				set_pev(ent, pev_solid, SOLID_TRIGGER)
				ExecuteForward(g_SetWorldModel, g_result, id, has_weapon[id], ent)
				if (g_result == PLUGIN_CONTINUE)
				{
					if (weapon_PrecacheType[has_weapon[id]] > 0)
					{
						engfunc(EngFunc_SetModel, ent, weapon_AlternativeModel[has_weapon[id]])
						set_pev(ent, pev_body, weapon_SubBody[has_weapon[id]])
					}
					else engfunc(EngFunc_SetModel, ent, weapon_w_model[has_weapon[id]])
				}
				if (weapon_special_mode[has_weapon[id]] != 10)
					cs_set_user_bpammo(id, weapon_change[has_weapon[id]], 0)
				set_task(0.4, "task_active", ent)
				cs_set_user_zoom(id, CS_RESET_ZOOM, 0)
				iZoomLevel[id] = 0
				in_fshot[id] = false
				in_tshot[id] = false
				if (in_zoom[id])
					in_zoom[id] = false
				iZoomLevel[id] = 0
				g_FOV[id] = 0
				eSetFOV(id, 90)
				remove_task(id + task_reactive_my_zoom)
				if (weapon_special_mode[has_weapon[id]] == 2 || weapon_special_mode[has_weapon[id]] == 3)
				{
					ent_nade_amount[ent] = user_nade[id][has_weapon[id]]
					user_nade[id][has_weapon[id]] = 0
					ent_nade_clip[ent] = nade_clip[id][has_weapon[id]]
					if (nade_reload[id])	
						ent_reload[ent] = true
					if (in_launcher[id])
						ent_launcher[ent] = true
					if (task_exists(id + reload_my_weapon))
						remove_task(id + reload_my_weapon)
					if (task_exists(id + active_my_grenade))
						remove_task(id + active_my_grenade)
				}
				if (weapon_special_mode[has_weapon[id]] == 5 || weapon_special_mode[has_weapon[id]] == 11)
					draw_cross(id)
				ExecuteForward(g_RifleDroped, g_result, id, has_weapon[id], ent, 1)
				has_weapon[id] = -1
				//ExecuteForward(g_RifleDroped, g_result, id, weaponid, ent)
				ExecuteForward(g_drop, g_result, id)
			}
		}
		else 
		{
			for (new i = 0; i < sizeof riffle_model; i++)
			{
				new cmodel[256]
				format(cmodel, 255, "%s", riffle_model[i])
				if (equal(model[7], cmodel, riffle_length[i]))
				{
					new clip, ammo
					new weaponid = get_weaponid(riffle_name[i])
					get_user_ammo(id, weaponid, clip, ammo)
					set_pev(ent, pev_iuser1, clip)
					set_pev(ent, pev_iuser2, ammo)
					set_pev(ent, pev_iuser3, i)
					set_pev(ent, pev_iuser4, normal_wait)
					cs_set_user_bpammo(id, weaponid, 0)
					set_task(0.4, "task_rnormal_active", ent)
					ExecuteForward(g_drop, g_result, id)
					engfunc(EngFunc_SetModel, ent, RIFLE_DEFAULT_MODEL)
					set_pev(ent, pev_body, get_weapon_backmodel(weaponid))
					ExecuteForward(g_RifleDroped, g_result, id, weaponid, ent, 0)
					return FMRES_SUPERCEDE
				}
			}
		}
		in_launcher[id] = false
		nade_reload[id] = false
	}
	else
	{
		if (!equal(classname, "armoury_entity"))
		{
			for (new unprecache = 0; unprecache < sizeof DEFAULT_RMODEL; unprecache ++)
			{
				if (equal(model[7], riffle_model[unprecache], riffle_length[unprecache]))
				{
					engfunc(EngFunc_SetModel, ent, RIFLE_DEFAULT_MODEL)
					new weaponid = get_weaponid(riffle_name[unprecache])
					set_pev(ent, pev_body, get_weapon_backmodel(weaponid))
					return FMRES_SUPERCEDE
				}
			}
		}
	}	
	return FMRES_IGNORED
}

public fm_cmdstart(id, ucHandle, seed)
{
	if (!is_user_alive(id) || has_weapon[id] < 0)
		return FMRES_IGNORED
	new clip, ammo
	new WeaponId = get_user_weapon(id, clip, ammo)
	if (has_weapon[id] >-1)
	{
		if (WeaponId == weapon_change[has_weapon[id]])
		{
			new fInReload, button
			button = get_uc(ucHandle, UC_Buttons)
			new ent = fm_find_ent_by_owner(-1, riffle_name[get_model(weapon_change[has_weapon[id]])], id)
			//new Float:Delay = get_pdata_float(ent, 46, 4) * weapon_speed[has_weapon[id]]	
			fInReload = get_pdata_int(ent, m_fInReload, 4)
			new Float:next_attack = get_pdata_float(id, m_flNextAttack, 5)
			new Float:fCurrentTime = get_gametime()
			if (button & IN_RELOAD)
			{
				set_uc(ucHandle, UC_Buttons, button &= ~IN_RELOAD)
				if (!in_launcher[id])
				{
					if (!fInReload && next_attack <= 0.0)
					{
						if (clip < _get_maxclip(id, has_weapon[id], 1))
						{
							if (ammo > 0)
							{
								cs_set_user_zoom(id, CS_RESET_ZOOM, 0)
								iZoomLevel[id] = 0
								remove_task(id + task_reactive_my_zoom)
								if (weapon_special_mode[has_weapon[id]] != 4)
									in_zoom[id] = false
								if (weapon_special_mode[has_weapon[id]] == 5 || weapon_special_mode[has_weapon[id]] == 11)
									cs_set_weapon_silen(ent, 0, 0)
								draw_cross(id)
								if (weapon_special_mode[has_weapon[id]] == 12)
								{
									emessage_begin(MSG_ONE_UNRELIABLE, get_user_msgid("CurWeapon"), _, id)
									ewrite_byte(1) // active
									ewrite_byte(weapon_change[has_weapon[id]]) // weapon
									ewrite_byte(cs_get_weapon_ammo(ent)) // clip
									emessage_end()
									set_pev(id, pev_viewmodel2, weapon_v_model[has_weapon[id]])
								}
								if (weapon_change[has_weapon[id]] == CSW_M4A1)
								{
									if (weapon_special_mode[has_weapon[id]] == 5 || weapon_special_mode[has_weapon[id]] == 11)
										SendWeaponAnim(id, 11)
									else
									{
										if (cs_get_weapon_silen(ent))
											SendWeaponAnim(id, 4)
										if (!cs_get_weapon_silen(ent))
											SendWeaponAnim(id, 11)
									}
								}
								else SendWeaponAnim(id, reload_animation[weapon_change[has_weapon[id]]])
								ExecuteHamB(Ham_Weapon_Reload, ent)
								//set_pdata_int(ent, m_fInReload, 1, 4)
								//if (weapon_reload_time[has_weapon[id]] > 0.0)
								//{
								//	set_pdata_float(id, m_flNextAttack, weapon_reload_time[has_weapon[id]], 5)
								//	set_pdata_float(ent, m_flTimeWeaponIdle, weapon_reload_time[has_weapon[id]] + 0.5, 4)
								//}
								//else 
								//{
								//	set_pdata_float(id, m_flNextAttack, g_fDelay[get_user_weapon(id)], 5)
								//	set_pdata_float(ent, m_flTimeWeaponIdle,  g_fDelay[get_user_weapon(id)] + 0.5, 4)
								//}
								ExecuteForward(g_reload, g_result, ent)
							}
							else 
								reload_without_ammo(id)
						}
					}
					else if (clip >= _get_maxclip(id, has_weapon[id], 1)) 
						reload_without_ammo(id)
				}
			}
			if (button & IN_ATTACK)
			{
				ExecuteForward(g_WeaponUseSpecialFunction, g_result, id, has_weapon[id])
				if (g_result != PLUGIN_CONTINUE)
					return FMRES_IGNORED
				if (pev(id, pev_button) & IN_ATTACK2 || pev(id, pev_button) & IN_USE)
					set_uc(ucHandle, UC_Buttons, button &= ~IN_ATTACK)
				if (fInReload)
				{
					if (fInIdle[id] && (weapon_silencer[has_weapon[id]] == 5 || weapon_silencer[has_weapon[id]] == 9))
					{
						if (in_tshot[id])
						{
							ExecuteHamB(Ham_Weapon_PrimaryAttack, ent)
							ExecuteHamB(Ham_Weapon_PrimaryAttack, ent)
							ExecuteHamB(Ham_Weapon_PrimaryAttack, ent)
							set_pdata_int(ent, m_fInReload, 0, 4)
							fInIdle[id] = false
							remove_task(id + task_insert_animation)
							remove_task(id + task_add_me_ammo)
							set_pdata_float(id, m_flNextAttack, _GetReloadTime(id, has_weapon[id]) + 0.5, 5)
							can_shot[id] = false
							user_delay[id] = fCurrentTime
						}
						else
						{
							set_pdata_int(ent, m_fInReload, 0, 4)
							set_pdata_float(id, m_flNextAttack, 0.0, 5)
							ExecuteHamB(Ham_Weapon_PrimaryAttack, ent)
							SendWeaponAnim(id, rifle_shoot_animation[random(2)][get_model(weapon_change[has_weapon[id]])])
							fInIdle[id] = false
							remove_task(id + task_insert_animation)
							remove_task(id + task_add_me_ammo)
							set_pdata_float(id, m_flNextAttack, _GetReloadTime(id, has_weapon[id]) + 0.5, 5)
						}
					}
					else
						set_uc(ucHandle, UC_Buttons, button &= ~IN_ATTACK)
				}		
				else
				{
					if (weapon_silencer[has_weapon[id]] == 6)
					{
						new Float:CurrentTime = fCurrentTime
						if (CurrentTime - time_delay[id] >= _GetDeployTime(id, has_weapon[id]) && next_attack <= 0.0)
						{
							if (!StartAtk[id])
							{
								set_uc(ucHandle, UC_Buttons, button &= ~IN_ATTACK)
								SendWeaponAnim(id, weapon_max_animation[get_model(get_user_weapon(id))] + 6)
								fOpenFire[id] = fCurrentTime
								StartAtk[id] = 1
								fOpenFire[id] = fCurrentTime
							}
							else if (StartAtk[id] == 1)
							{
								if (CurrentTime - fOpenFire[id] >= weapon_start_firing[has_weapon[id]])
								{
									Update[id] = true
									StartAtk[id] = 2
									fOpenFire[id] = fCurrentTime
								}
								else
									set_uc(ucHandle, UC_Buttons, button &= ~IN_ATTACK)
							}
						}
					}
					if (next_attack <= 0.0)
					{
						if (weapon_special_mode[has_weapon[id]] == 6|| weapon_special_mode[has_weapon[id]] == 7 || weapon_special_mode[has_weapon[id]] == 8 || weapon_special_mode[has_weapon[id]] == 11)
						{
							if (in_fshot[id])
							{
								set_uc(ucHandle, UC_Buttons, button &= ~IN_ATTACK)
								if (can_shot[id] && fCurrentTime >= shot_delay[id] && fCurrentTime - user_delay[id] >= 0.7)
								{
									ExecuteHamB(Ham_Weapon_PrimaryAttack, ent)
									user_delay[id] = fCurrentTime
									can_shot[id] = false
								}
							}
							if (in_tshot[id])
							{
								set_uc(ucHandle, UC_Buttons, button &= ~IN_ATTACK)
								if (can_shot[id] && fCurrentTime >= shot_delay[id] && fCurrentTime - user_delay[id] >= 0.7)
								{
									ExecuteHamB(Ham_Weapon_PrimaryAttack, ent)
									ExecuteHamB(Ham_Weapon_PrimaryAttack, ent)
									ExecuteHamB(Ham_Weapon_PrimaryAttack, ent)
									user_delay[id] = fCurrentTime
									can_shot[id] = false
									new iClip, iBpAmmo
									get_user_weapon(id, iClip, iBpAmmo)
									if (iClip <= 0)
										ExecuteHamB(Ham_Weapon_Reload, ent)
								}
							}
							
						}
					}
					if (weapon_special_mode[has_weapon[id]] == 2 || weapon_special_mode[has_weapon[id]] == 3)
					{
						if (in_launcher[id])
						{
							set_uc(ucHandle, UC_Buttons, button &= ~IN_ATTACK)
							new Float:fTime = fCurrentTime
							new Float:fDeployTime = _GetDeployTime(id, has_weapon[id])
							if (nade_clip[id][has_weapon[id]] > 0 && !nade_reload[id] && fTime - time_delay[id] >= weapon_nade_delay[has_weapon[id]] && fTime - weapon_nade_delay[has_weapon[id]] >= fDeployTime && !fInReload)
							{
								launch_grenade(id, has_weapon[id])
								time_delay[id] = fTime
								ExecuteForward(g_function_active, g_result, ent)
							}
						}
					}								
				}		
			}
			if (button & IN_ATTACK2)
			{
				ExecuteForward(g_WeaponUseSpecialFunction, g_result, id, has_weapon[id])
				if (g_result != PLUGIN_CONTINUE)
					return FMRES_IGNORED
				if (check_special_mode(id))
				{
					set_uc(ucHandle, UC_Buttons, button &= ~IN_ATTACK2)
					if (!fInReload && next_attack <= 0.0)
					{
						if (weapon_special_mode[has_weapon[id]] == 1)
						{
							if (!in_launcher[id])
							{
								new zoom_mode = weapon_zoom_type[has_weapon[id]]
								if (zoom_mode == 1)
								{
									if (!in_zoom[id])
									{
										cs_set_user_zoom(id, CS_SET_AUGSG552_ZOOM, 0)
										client_cmd(id, "spk weapons/zoom.wav")
										in_zoom[id] = true
									}
									else
									{
										cs_set_user_zoom(id, CS_RESET_ZOOM, 0)
										client_cmd(id, "spk weapons/zoom.wav")
										in_zoom[id] = false
									}
									ExecuteForward(g_function_active, g_result, ent)
								}
								else if (zoom_mode == 2)
								{
									if (!in_zoom[id])
									{
										cs_set_user_zoom(id, CS_SET_FIRST_ZOOM, 0)
										client_cmd(id, "spk weapons/zoom.wav")
										in_zoom[id] = true
									}
									else
									{
										cs_set_user_zoom(id, CS_RESET_ZOOM, 0)
										client_cmd(id, "spk weapons/zoom.wav")
										in_zoom[id] = false
									}
									ExecuteForward(g_function_active, g_result, ent)
								}
								else if (zoom_mode == 3)
								{
									if (!in_zoom[id])
									{
										cs_set_user_zoom(id, CS_SET_SECOND_ZOOM, 0)
										client_cmd(id, "spk weapons/zoom.wav")
										in_zoom[id] = true
									}
									else
									{
										cs_set_user_zoom(id, CS_RESET_ZOOM, 0)
										client_cmd(id, "spk weapons/zoom.wav")
										in_zoom[id] = false
									}
									ExecuteForward(g_function_active, g_result, ent)
								}
								else if (zoom_mode == 4)
								{
									if (iZoomLevel[id] == 0)
									{
										cs_set_user_zoom(id, CS_SET_FIRST_ZOOM, 0)
										client_cmd(id, "spk weapons/zoom.wav")
										iZoomLevel[id] = 1
										in_zoom[id] = true
									}
									else if (iZoomLevel[id] == 1)
									{
										cs_set_user_zoom(id, CS_SET_SECOND_ZOOM, 0)
										client_cmd(id, "spk weapons/zoom.wav")
										iZoomLevel[id] = 2
										in_zoom[id] = true
									}
									else if (iZoomLevel[id] == 2)
									{
										cs_set_user_zoom(id, CS_RESET_ZOOM, 0)
										client_cmd(id, "spk weapons/zoom.wav")
										iZoomLevel[id] = 0
										in_zoom[id] = false
									}
									ExecuteForward(g_function_active, g_result, ent)
								}
								else if (zoom_mode == 5)
								{
									if (!in_zoom[id])
									{
										//cs_set_user_zoom(id, CS_SET_AUGSG552_ZOOM, 0)
										eSetFOV(id, weapon_FOV[has_weapon[id]])
										client_cmd(id, "spk weapons/zoom.wav")
										in_zoom[id] = true
									}
									else
									{
										cs_set_user_zoom(id, CS_RESET_ZOOM, 0)
										emessage_begin(MSG_ONE_UNRELIABLE, get_user_msgid("Crosshair"), _, id)
										ewrite_byte(0)
										emessage_end()
										client_cmd(id, "spk weapons/zoom.wav")
										in_zoom[id] = false
									}
									ExecuteForward(g_function_active, g_result, ent)
								}
								zoom_delay[id] = fCurrentTime
								set_pdata_float(id, m_flNextAttack, ZOOM_DELAYED)
							}
						}
						else if (weapon_special_mode[has_weapon[id]] == 4)
						{
							if (!in_zoom[id])
								in_zoom[id] = true
							else in_zoom[id] = false
							zoom_delay[id] = fCurrentTime
							set_task(0.3, "show_laser", id + 5230, _, _, "b")
							ExecuteForward(g_function_active, g_result, ent)
							set_pdata_float(id, m_flNextAttack, ZOOM_DELAYED , 5)
						}
						else if (weapon_special_mode[has_weapon[id]] == 5 || weapon_special_mode[has_weapon[id]] == 11)
						{
							if (weapon_change[has_weapon[id]] == CSW_M4A1 && !fInReload && next_attack <= 0.0)
							{
								new ent = fm_find_ent_by_owner(-1, "weapon_m4a1", id)
								if (in_zoom[id])
								{
									in_zoom[id] = false
									cs_set_user_zoom(id, CS_RESET_ZOOM, 0)
									cs_set_weapon_silen(ent, 0, 1)
									if (task_exists(id - task_active_iron))
										remove_task(id - task_active_iron)
									set_task(weapon_finish_iron_time[has_weapon[id]], "deactive_iron", id - task_active_iron)
									set_pdata_float(id, m_flNextAttack, weapon_finish_iron_time[has_weapon[id]] + 0.2 , 5)
									eSetFOV(id, 90)
									hide_dcross(id)
								}
								else
								{
									in_zoom[id] = true
									cs_set_weapon_silen(ent, 1, 1)
									if (task_exists(id + task_active_iron))
										remove_task(id + task_active_iron)
									set_task(weapon_start_iron_time[has_weapon[id]], "active_iron", id + task_active_iron)
									set_pdata_float(id, m_flNextAttack, weapon_start_iron_time[has_weapon[id]] + 0.2 , 5)
								}
								zoom_delay[id] = fCurrentTime
								//set_pdata_float(id, m_flNextAttack, ZOOM_DELAYED , 5)
								ExecuteForward(g_function_active, g_result, ent)
							}
						}
						else if (weapon_special_mode[has_weapon[id]] == 6)
						{
							if (fCurrentTime - zoom_delay[id] >= 0.5 && next_attack <= 0.0)
							{
								if (!in_fshot[id])
								{
									in_fshot[id] = true
									in_tshot[id] = false
									client_print(id, print_center, "Zmieniono na tryb pojedynczy")
								}
								else
								{
									in_fshot[id] = false
									in_tshot[id] = false
									client_print(id, print_center, "Zmieniono na tryb automatcyzny")
								}
								zoom_delay[id] = fCurrentTime
								ExecuteForward(g_function_active, g_result, ent)
							}
						}
						else if (weapon_special_mode[has_weapon[id]] == 7)
						{
							if (fCurrentTime - zoom_delay[id] >= 0.7)
							{
								if (!in_tshot[id])
								{
									in_tshot[id] = true
									client_print(id, print_center, "Zmieniono na tryb serii")
								}
								else
								{
									in_tshot[id] = false
									client_print(id, print_center, "Zmieniono na tryb automatcyzny")
								}
								zoom_delay[id] = fCurrentTime
								ExecuteForward(g_function_active, g_result, ent)
							}
						}
						else if (weapon_special_mode[has_weapon[id]] == 8)
						{
							if (fCurrentTime - zoom_delay[id] >= 0.7)
							{
								if (!in_fshot[id] && !in_tshot[id])
								{
									in_fshot[id] = true
									in_tshot[id] = false
									client_print(id, print_center, "Zmieniono na tryb pojedynczy")
								}
								else if (in_fshot[id] && !in_tshot[id])
								{
									in_fshot[id] = false
									in_tshot[id] = true
									client_print(id, print_center, "Zmieniono na tryb serii")
								}
								else if (in_tshot[id] && !in_fshot[id])
								{
									in_fshot[id] = false
									in_tshot[id] = false
									client_print(id, print_center, "Zmieniono na tryb automatcyzny")
								}
								zoom_delay[id] = fCurrentTime
								user_delay[id] = fCurrentTime
								ExecuteForward(g_function_active, g_result, ent)
							}
						}
						else if (weapon_special_mode[has_weapon[id]] == 3)
						{
							set_uc(ucHandle, UC_Buttons, button &= ~IN_ATTACK2)
							if (!fInReload && !in_launcher[id])
							{
								if (fCurrentTime - zoom_delay[id] >= ZOOM_DELAYED)
								{
									new zoom_mode = weapon_zoom_type[has_weapon[id]]
									if (zoom_mode == 1)
									{
										if (!in_zoom[id])
										{
											cs_set_user_zoom(id, CS_SET_AUGSG552_ZOOM, 0)
											in_zoom[id] = true
										}
										else
										{
											cs_set_user_zoom(id, CS_RESET_ZOOM, 0)
											in_zoom[id] = false
										}
									}
									else if (zoom_mode == 2)
									{
										if (!in_zoom[id])
										{
											cs_set_user_zoom(id, CS_SET_FIRST_ZOOM, 0)
											in_zoom[id] = true
										}
										else
										{
											cs_set_user_zoom(id, CS_RESET_ZOOM, 0)
											in_zoom[id] = false
										}
									}
									zoom_delay[id] = fCurrentTime
									client_cmd(id, "spk weapons/zoom.wav")
									time_delay[id] = fCurrentTime
								}
							}
						}
						else if (weapon_special_mode[has_weapon[id]] == 9)
						{
							if (!cs_get_weapon_silen(ent))
								SendWeaponAnim(id, rifle_change_mode[get_model(weapon_change[has_weapon[id]])])
							else	SendWeaponAnim(id, rifle_change_mode[get_model(weapon_change[has_weapon[id]])] + 3)
							set_task(Weapon_AtkTime[has_weapon[id]], "special_attack", id + knife_attack) 
							set_pdata_float(id, m_flNextAttack, Weapon_DmgTime[has_weapon[id]], 5)
							emit_sound(id, CHAN_AUTO, cloth_sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
							ExecuteForward(g_function_active, g_result, ent)	
						}
						else if (weapon_special_mode[has_weapon[id]] == 12)
						{
							if (in_zoom[id])
							{
								in_zoom[id] = false
								cs_set_user_zoom(id, CS_RESET_ZOOM, 0)
								if (task_exists(id - task_active_iron))
									remove_task(id - task_active_iron)
								new weaponname[32]
								get_weaponname(weapon_change[has_weapon[id]], weaponname, 31)
								// new ent = find_ent_by_owner(-1, weaponname, id)
								emessage_begin(MSG_ONE_UNRELIABLE, get_user_msgid("CurWeapon"), _, id)
								ewrite_byte(1) // active
								ewrite_byte(weapon_change[has_weapon[id]]) // weapon
								ewrite_byte(cs_get_weapon_ammo(ent)) // clip
								emessage_end()
								set_pev(id, pev_viewmodel2, weapon_v_model[has_weapon[id]])
								new wid = check_prim(id)
								if (wid != -1)
									SendWeaponAnim(id, weapon_max_animation[wid] + addition_sight_end)
								set_task(weapon_finish_iron_time[has_weapon[id]], "deactive_iron", id - task_active_iron)
								set_pdata_float(id, m_flNextAttack, weapon_finish_iron_time[has_weapon[id]] + 0.3 , 5)
								eSetFOV(id, 90)
								hide_dcross(id)
							}
							else
							{
								cs_set_user_zoom(id, CS_RESET_ZOOM, 0)
								if (!weapon_HideVModel[has_weapon[id]])
								{
									eSetFOV(id, 90)
									hide_dcross(id)
								}
								in_zoom[id] = true
								if (task_exists(id + task_active_iron))
									remove_task(id + task_active_iron)
								set_task(weapon_start_iron_time[has_weapon[id]], "active_iron", id + task_active_iron)
								set_pdata_float(id, m_flNextAttack, weapon_start_iron_time[has_weapon[id]] + 0.3 , 5)
								new wid = check_prim(id)
								if (wid != -1)
									SendWeaponAnim(id, weapon_max_animation[wid] + addition_sight_begin)
							}
						}
						else if (weapon_special_mode[has_weapon[id]] == 13)
						{
							if (!in_zoom[id])
							{
								if (fCurrentTime - zoom_delay[id] >= ZOOM_DELAYED)
								{	
									g_FOV[id] = weapon_scope[has_weapon[id]][0] 
									SetFOV(id, 90 - g_FOV[id])
									client_cmd(id, "spk weapons/zoom.wav")
									in_zoom[id] = true
									zoom_delay[id] = fCurrentTime
									set_pdata_float(id, m_flNextAttack, ZOOM_DELAYED , 5)
								}
							}
							else
							{
								if (fCurrentTime - zoom_delay[id] >= ZOOM_DELAYED)
								{
									in_zoom[id] = false
									zoom_delay[id] = fCurrentTime
									g_FOV[id] = 0
									SetFOV(id, 90)
									set_pdata_float(id, m_flNextAttack, ZOOM_DELAYED , 5)
								}
							}
							ExecuteForward(g_function_active, g_result, ent)
						}
					}
				}
			}
			new button2 = get_uc(ucHandle, UC_Impulse)
			if (button2 == 201)
			{
				ExecuteForward(g_WeaponUseSpecialFunction, g_result, id, has_weapon[id])
				if (g_result != PLUGIN_CONTINUE)
					return FMRES_IGNORED
				if (weapon_special_mode[has_weapon[id]] == 3 || weapon_special_mode[has_weapon[id]] == 2)
				{
					set_uc(ucHandle, UC_Impulse, 0)
					if (!fInReload && get_gametime() - zoom_delay[id] > 0.7)
					{
						if (in_launcher[id])
						{
							in_zoom[id] = false
							cs_set_user_zoom(id, CS_RESET_ZOOM, 0)
							if (weapon_launch_type[has_weapon[id]] == 1)
							{
								in_launcher[id] = false
								engclient_cmd(id, riffle_name[get_model(weapon_change[has_weapon[id]])])
								emessage_begin(MSG_ONE_UNRELIABLE, get_user_msgid("CurWeapon"), _, id)
								ewrite_byte(1) // active
								ewrite_byte(weapon_change[has_weapon[id]]) // weapon
								ewrite_byte(cs_get_weapon_ammo(ent)) // clip
								emessage_end()
								set_pev(id, pev_viewmodel2, weapon_v_model[has_weapon[id]])
								fw_item_deploy(ent)
								set_pdata_float(id, m_flNextAttack, 0.0, 5)
								if (weapon_change[has_weapon[id]] == CSW_M4A1)
								{
									if (cs_get_weapon_silen(ent))
										SendWeaponAnim(id, 0)
									else	SendWeaponAnim(id, 7)
								}
								else	SendWeaponAnim(id, 0)
								ExecuteForward(g_GLauncherDeactivated, g_result, id, has_weapon[id])
							}
							else if (weapon_launch_type[has_weapon[id]] == 2)
							{
								new iMaxAnim = weapon_max_animation[get_model(get_user_weapon(id))]
								if (weapon_silencer[has_weapon[id]] == 5)
								{
									if (!cs_get_weapon_silen(ent))
										SendWeaponAnim(id,  iMaxAnim + 4)
									else	SendWeaponAnim(id, iMaxAnim + 5)
								}
								else
								{
									if (!cs_get_weapon_silen(ent))
										SendWeaponAnim(id,  iMaxAnim + 1)
									else	SendWeaponAnim(id, iMaxAnim + 2)
								}
								set_pdata_float(id, m_flNextAttack, 1.5, 5)
								// set_pev(id, pev_viewmodel2, weapon_v_model[has_weapon[id]])
								set_task(1.2, "end_action", id - start_launcher)
								in_launcher[id] = false
								ExecuteForward(g_GLauncherDeactivated, g_result, id, has_weapon[id])
								
							}
							client_print(id, print_center, "DEACTIVE_GLAUNCHER_FUNCTION")
							
						}
						else
						{
							ExecuteForward(g_ActiveGLauncher, g_result, id, has_weapon[id])
							if (g_result != PLUGIN_HANDLED)
							{
								in_zoom[id] = false
								cs_set_user_zoom(id, CS_RESET_ZOOM, 0)
								if (weapon_launch_type[has_weapon[id]] == 1)
								{
									in_launcher[id] = true
									engclient_cmd(id, riffle_name[get_model(weapon_change[has_weapon[id]])])
									emessage_begin(MSG_ONE_UNRELIABLE, get_user_msgid("CurWeapon"), _, id)
									ewrite_byte(1) // active
									ewrite_byte(weapon_change[has_weapon[id]]) // weapon
									ewrite_byte(cs_get_weapon_ammo(ent)) // clip
									emessage_end()
									set_pev(id, pev_viewmodel2, weapon_launching_nade[has_weapon[id]])
									fw_item_deploy(ent)
									SendWeaponAnim(id, anim_deploy)
									ExecuteForward(g_GLauncherActivated, g_result, id, has_weapon[id])
								}
								else if (weapon_launch_type[has_weapon[id]] == 2)
								{
									new iMaxAnim = weapon_max_animation[get_model(get_user_weapon(id))]
									if (weapon_silencer[has_weapon[id]] == 5 || weapon_silencer[has_weapon[id]] == 9)
									{
										if (!cs_get_weapon_silen(ent))
											SendWeaponAnim(id, iMaxAnim + 4)
										else	SendWeaponAnim(id, iMaxAnim + 5)
									}
									else
									{
										if (!cs_get_weapon_silen(ent))
											SendWeaponAnim(id, iMaxAnim + 1)
										else	SendWeaponAnim(id, iMaxAnim + 2)
									}
									set_task(0.7, "start_action", id + start_launcher)
									//set_task(0.5, "start_reload_launcher", id + reload_type_2)
									// set_pev(id, pev_viewmodel2, weapon_launching_nade[has_weapon[id]])
									in_launcher[id] = true
									ExecuteForward(g_GLauncherActivated, g_result, id , has_weapon[id])
								}
								client_print(id, print_center, "OPEN_GLAUNCHER_FUNCTION")
								set_pdata_float(id, m_flNextAttack, 0.0, 5)
							}
							zoom_delay[id] = fCurrentTime
							time_delay[id] = fCurrentTime
						}
						
					}
				}
				else if (weapon_special_mode[has_weapon[id]] == 11)
				{
					set_uc(ucHandle, UC_Impulse, 0)
					if (!fInReload && next_attack <= 0.0 && get_user_weapon(id) == CSW_M4A1)
					{
						if (!in_tshot[id])
						{
							in_tshot[id] = true
							client_print(id, print_chat, "Zmieniono na tryb serii")
						}
						else
						{
							in_tshot[id] = false
							client_print(id, print_chat, "Zmieniono na tryb automatyczny")
						}
						set_pdata_float(id, m_flNextAttack, 0.75, 5)
					}
				}
			}
			else if (button2 == 100) // Use flash light
			{
				ExecuteForward(g_WeaponUseSpecialFunction, g_result, id, has_weapon[id])
				if (g_result != PLUGIN_CONTINUE)
					return FMRES_IGNORED
				if (weapon_special_mode[has_weapon[id]] == 10)
				{
					if (fUseFlash[id])
					{
						fUseFlash[id] = false
						remove_task(id + TASK_USE_FLASHLIGHT)
					}
					else
					{
						fUseFlash[id] = true
						set_task(0.2, "ShowFlashLight", id + TASK_USE_FLASHLIGHT, _, _, "b")
					}
				}
			}
		}
	}
	else
	{
		new button = get_uc(ucHandle, UC_Buttons)
		if (button & IN_RELOAD)
		{
			if (clip >= _get_maxclip(id, WeaponId, 0))
			{
				set_uc(ucHandle, UC_Buttons , button &~ IN_RELOAD)
				if (WeaponId == CSW_M4A1)
				{
					new ent = fm_find_ent_by_owner(-1, riffle_name[get_model(WeaponId)], id)
					if (cs_get_weapon_silen(ent))
						SendWeaponAnim(id, 0)
					if (!cs_get_weapon_silen(ent))
						SendWeaponAnim(id, 7)
				}
				else SendWeaponAnim(id, 0)
			}
		}
	}			
	return FMRES_IGNORED
}

public ShowFlashLight(TASKID)
{
	new id = TASKID - TASK_USE_FLASHLIGHT
	if (!is_user_alive(id))
	{
		fUseFlash[id] = false
		remove_task(TASKID)
		return
	}
	if (has_weapon[id] < 0)
	{
		fUseFlash[id] = false
		remove_task(TASKID)
		return
	}
	if (get_user_weapon(id) != weapon_change[has_weapon[id]])
	{
		fUseFlash[id] = false
		remove_task(TASKID)
		return
	}
	if (weapon_special_mode[has_weapon[id]] != 10)
	{
		fUseFlash[id] = false
		remove_task(TASKID)
		return
	}
	new iOrigin[3]
	get_user_origin(id, iOrigin, 3)
	if (FlashLightType[has_weapon[id]] == 1)
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	else 	message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, _, id)
	write_byte(TE_DLIGHT) // TE id
	write_coord(iOrigin[0]) // x
	write_coord(iOrigin[1]) // y
	write_coord(iOrigin[2]) // z
	write_byte(FlashLightRadius[has_weapon[id]]) // radius
	// Human / Spectator in normal round
	write_byte(FlashLightColor[has_weapon[id]][0]) // r
	write_byte(FlashLightColor[has_weapon[id]][1]) // g
	write_byte(FlashLightColor[has_weapon[id]][2]) // b
	write_byte(2) // life
	write_byte(0) // decay rate
	message_end()
}
	
public active_iron(taskid)
{
	new id = taskid - task_active_iron
	if (!is_user_alive(id))
		return
	new iWeaponid = get_user_weapon(id)
	if (weapon_special_mode[has_weapon[id]] == 5 || weapon_special_mode[has_weapon[id]] == 11)
	{
		if (iWeaponid != CSW_M4A1)
			return
			
		SendWeaponAnim(id, 0)
		if (weapon_zoom_type[has_weapon[id]] == 1)
		{
			if (!iCheckSniper(iWeaponid))
				hide_cross(id)
			cs_set_user_zoom(id, CS_SET_AUGSG552_ZOOM, 0)
			hide_dcross(id)
		}
		if (weapon_zoom_type[has_weapon[id]] == 2)
		{
			cs_set_user_zoom(id, CS_SET_FIRST_ZOOM, 0)
			// Remove Half Life crosshair 
			if (!weapon_HideVModel[has_weapon[id]])
				hide_dcross(id)
		}			
		if (weapon_zoom_type[has_weapon[id]] == 3)
		{
			cs_set_user_zoom(id, CS_SET_SECOND_ZOOM, 0)
			// Remove Half Life crosshair 
			if (!weapon_HideVModel[has_weapon[id]])
				hide_dcross(id)	
		}
		if (weapon_zoom_type[has_weapon[id]] == 5)
		{
			if (weapon_FOV[has_weapon[id]] > 44)
				hide_cross(id)
			eSetFOV(id, weapon_FOV[has_weapon[id]])
		}
		hide_dcross(id)
	}
	else if (weapon_special_mode[has_weapon[id]] == 12)
	{
		if (weapon_zoom_type[has_weapon[id]] == 1)
		{
			if (!iCheckSniper(iWeaponid))
				hide_cross(id)
			cs_set_user_zoom(id, CS_SET_AUGSG552_ZOOM, 0)
		}
		if (weapon_zoom_type[has_weapon[id]] == 2)
		{
			cs_set_user_zoom(id, CS_SET_FIRST_ZOOM, 0)
			// Remove Half Life crosshair 
			if (!weapon_HideVModel[has_weapon[id]])
				hide_dcross(id)
			//else	Draw_DCross(id)
		}
		if (weapon_zoom_type[has_weapon[id]] == 3)
		{
			cs_set_user_zoom(id, CS_SET_SECOND_ZOOM, 0)
			// Remove Half Life crosshair 
			if (!weapon_HideVModel[has_weapon[id]])
				hide_dcross(id)
			//else	Draw_DCross(id)
		}
		if (weapon_zoom_type[has_weapon[id]] == 5)
		{
			if (weapon_FOV[has_weapon[id]] > 44)
				hide_cross(id)
			eSetFOV(id, weapon_FOV[has_weapon[id]])
		}
			
		new weaponname[32]
		get_weaponname(weapon_change[has_weapon[id]], weaponname, 31)
		new ent = find_ent_by_owner(-1, weaponname, id)
		emessage_begin(MSG_ONE_UNRELIABLE, get_user_msgid("CurWeapon"), _, id)
		ewrite_byte(1) // active
		ewrite_byte(weapon_change[has_weapon[id]]) // weapon
		ewrite_byte(cs_get_weapon_ammo(ent)) // clip
		emessage_end()
		
		new iGetZoom = cs_get_user_zoom(id)
		
		if (iGetZoom != CS_SET_FIRST_ZOOM && iGetZoom != CS_SET_SECOND_ZOOM)
			hide_dcross(id)
	}
	in_zoom[id] = true
}

public deactive_iron(taskid)
{
	new id = taskid + task_active_iron
	if (!is_user_alive(id))
		return
	in_zoom[id] = false
	if (weapon_special_mode[has_weapon[id]] == 5 || weapon_special_mode[has_weapon[id]] == 11)
	{
		if (get_user_weapon(id) != CSW_M4A1)
			return
		draw_cross(id)
		hide_dcross(id)
		SendWeaponAnim(id, 7)
	}
	if (weapon_special_mode[has_weapon[id]] == 12)
	{
		new weaponname[32]
		get_weaponname(weapon_change[has_weapon[id]], weaponname, 31)
		new ent = find_ent_by_owner(-1, weaponname, id)
		//emessage_begin(MSG_ONE_UNRELIABLE, get_user_msgid("CurWeapon"), _, id)
		//ewrite_byte(1) // active
		//ewrite_byte(weapon_change[has_weapon[id]]) // weapon
		//ewrite_byte(cs_get_weapon_ammo(ent)) // clip
		//emessage_end()
		//set_pev(id, pev_viewmodel2, weapon_v_model[has_weapon[id]])
		if (weapon_change[has_weapon[id]] == CSW_M4A1)
		{
			if (cs_get_weapon_silen(ent))
				SendWeaponAnim(id, 0)
			else	SendWeaponAnim(id, 8)
		}
		else SendWeaponAnim(id, 0)
		draw_cross(id)
		hide_dcross(id)
	}
}

public special_attack(taskid)
{
	new id = taskid - knife_attack
	if (!is_user_alive(id))
		return
	if (has_weapon[id] < 0 || get_user_weapon(id) != weapon_change[has_weapon[id]])
		return
	if (weapon_special_mode[has_weapon[id]] != 9)
		return
	new Float:range = Weapon_MeleeRange[has_weapon[id]]
	new sample[64], random_sound = random_num(1, 2)
	format(sample, 63, "weapons/knife_slash%d.wav", random_sound)
	emit_sound(id, CHAN_AUTO, sample, 1.0, ATTN_NORM, 0, PITCH_NORM)
	testbulet(id, weapon_nade_hud[has_weapon[id]], Weapon_MeleeDamage[has_weapon[id]], range ) 
}

public fw_updatedata(id, sw, cd_handle)
{
	if (!is_user_alive(id))
		return FMRES_IGNORED
	if (has_weapon[id] < 0)
		return FMRES_IGNORED
	new WeaponId = get_user_weapon(id)
	if ( WeaponId != weapon_change[has_weapon[id]])
		return FMRES_IGNORED
	if (weapon_silencer[has_weapon[id]] == 6)
	{
		if (!Update[id])
		{
			set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0,001)
			return FMRES_HANDLED
		}
	}
	//if (weapon_silencer[has_weapon[id]] == 7)
	//{
	//	set_cd(cd_handle, CD_flNextAttack, halflife_time() + 0.01)
	//	return FMRES_HANDLED
	//}
	if (weapon_special_mode[has_weapon[id]] == 2 || weapon_special_mode[has_weapon[id]] == 3)
	{
		if (in_launcher[id])
		{
			set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0.001)
			return FMRES_HANDLED
		}
	}
	if (weapon_special_mode[has_weapon[id]] == 6 || weapon_special_mode[has_weapon[id]] == 7 || weapon_special_mode[has_weapon[id]] == 8 || weapon_special_mode[has_weapon[id]] == 11)
	{
		if (!in_fshot[id] && !in_tshot[id])
			return FMRES_IGNORED
		if (!can_shot[id])
		{
			set_cd(cd_handle, CD_flNextAttack, halflife_time() + 0.001)
			return FMRES_HANDLED
		}	
	}
	if (weapon_special_mode[has_weapon[id]] == 5 || weapon_special_mode[has_weapon[id]] == 11)
	{
		new animation = get_cd(cd_handle, CD_WeaponAnim)
		if (!in_zoom[id])
		{
			if (animation < 7 && animation != 6)
				set_cd(cd_handle, CD_WeaponAnim, animation + 7)
		}
		else 
		{
			if (animation >= 7 && animation != 13)
				set_cd(cd_handle, CD_WeaponAnim, animation - 7)
		}
	}
	if (weapon_special_mode[has_weapon[id]] == 0)
	{
		if (weapon_silencer[has_weapon[id]] == 4)
		{
			new animation = pev(id, pev_sequence)
			new wid = get_model(weapon_change[has_weapon[id]])
			if (animation == rifle_sequence_couch[wid])
				set_pev(id, pev_sequence, 22)
			else if (animation == rifle_sequence_couch_shoot[wid])
				set_pev(id, pev_sequence, random_num(23,24))
			else if (animation == rifle_sequence_stand[wid])
				set_pev(id, pev_sequence, 26)
			else if (animation == rifle_sequence_stand_shoot[wid])
				set_pev(id, pev_sequence, random_num(27, 28))
			else if (animation == rifle_sequence_reload_couch[wid])
				set_pev(id, pev_sequence, 25)
			else if (animation == rifle_sequence_reload_stand[wid])
				set_pev(id, pev_sequence, 29)
			//return FMRES_HANDLED
		}
	}
	return FMRES_IGNORED
}
		
public fw_touch(ent, id)
{
	if (!pev_valid(ent))
		return PLUGIN_HANDLED
	if (pev(ent, pev_iuser4) == rwait || pev(ent, pev_iuser4) == pwait || pev(ent, pev_iuser4) == normal_wait || pev(ent, pev_iuser4) == pnwait || pev(ent, pev_iuser4) == shotgun_wait || pev(ent, pev_iuser4) == shotgun_normal)
		return PLUGIN_HANDLED
	if (pev(ent, pev_iuser4) != shotgun_ready && pev(ent, pev_iuser4) != shotgun_normal_ready && pev(ent, pev_iuser4) != rwait && pev(ent, pev_iuser4) != pwait && pev(ent, pev_iuser4) != rready && pev(ent, pev_iuser4) != pready && pev(ent, pev_iuser4) != normal_ready && pev(ent, pev_iuser4) != normal_wait && pev(ent, pev_iuser4) != shotgun_wait && pev(ent, pev_iuser4) != shotgun_normal && pev(ent, pev_iuser4) != pnready && pev(ent, pev_iuser4) != pnwait)
		return PLUGIN_CONTINUE
	if (cs_get_user_vip(id))
		return PLUGIN_HANDLED
	if (pev(ent, pev_iuser4) == rready)
	{
		if (cs_get_user_hasprim(id))
			return PLUGIN_HANDLED
		if (!is_user_alive(id) || !is_user_connected(id))
			return PLUGIN_HANDLED
		in_touch[id] = true
		has_weapon[id] = pev(ent, pev_iuser3)
		new weaponid = weapon_change[has_weapon[id]]
		ExecuteForward(g_ReceivedRifle, g_result, id, 1, weaponid)
		new weapon_give[32]
		get_weaponname(weaponid, weapon_give, 31)
		new fInLauncher = 0
		nade_reload[id] = false
		in_launcher[id] = false
		if (weapon_special_mode[has_weapon[id]] == 2 || weapon_special_mode[has_weapon[id]] == 3)
		{
			user_nade[id][has_weapon[id]] = ent_nade_amount[ent]
			nade_clip[id][has_weapon[id]] = ent_nade_clip[ent]
			if (ent_reload[ent])
				nade_reload[id] = true
			if (ent_launcher[ent])
				in_launcher[id] = true
			fInLauncher = 1
		}
		new iEnt = fm_give_item(id, weapon_give)
		new iClip = pev(ent, pev_iuser1)
		cs_set_weapon_ammo(iEnt, iClip)
		cs_set_user_bpammo(id, weapon_change[has_weapon[id]], pev(ent, pev_iuser2))
		if (fInLauncher)
		{
			engclient_cmd(id, "%s", weapon_give)
			in_launcher[id] = true
			set_pev(id, pev_viewmodel2, weapon_launching_nade[has_weapon[id]])
			if (weapon_launch_type[has_weapon[id]] == 1)
				SendWeaponAnim(id, anim_deploy)
			if (nade_clip[id][has_weapon[id]] < 1 && user_nade[id][has_weapon[id]] > 0 && nade_reload[id])
			{
				if (weapon_launch_type[has_weapon[id]] == 1)
					set_task(0.7, "reload_my_launcher", id + reload_my_weapon)
				if (weapon_launch_type[has_weapon[id]] == 2)
					set_task(0.5,"start_reload_launcher", id + reload_type_2)
				nade_reload[id] = true	
			}
		}
		if (weapon_special_mode[has_weapon[id]] != 5)
		{
			if (weapon_special_mode[has_weapon[id]] != 11)
			{
				if (weapon_silencer[has_weapon[id]] == 1)
				{
					if (weapon_change[has_weapon[id]] == CSW_M4A1)
						cs_set_weapon_silen(iEnt, 1, 0)
					if (weapon_change[has_weapon[id]] == CSW_FAMAS)
						cs_set_weapon_burst(iEnt, 1)
				}
			}
		}
		remove_entity(ent)
		//update_hud_WeaponList(id, weapon_change[has_weapon[id]], iClip, WeaponClass[has_weapon[id]], weapon_bpa[has_weapon[id]], 1)
		ExecuteForward(g_RiflePickedUp, g_result, id, has_weapon[id], ent, 1)
		in_touch[id] = false
		return PLUGIN_HANDLED
	}
	if (pev(ent, pev_iuser4) == normal_ready)
	{
		if (cs_get_user_hasprim(id))
			return PLUGIN_HANDLED
		if (!is_user_alive(id) || !is_user_connected(id))
			return PLUGIN_HANDLED
		new ient = fm_give_item(id, riffle_name[pev(ent, pev_iuser3)])
		new weaponid = get_weaponid(riffle_name[pev(ent, pev_iuser3)])
		cs_set_weapon_ammo(ient, pev(ent, pev_iuser1))
		cs_set_user_bpammo(id, weaponid , pev(ent, pev_iuser2))
		remove_entity(ent)
		ExecuteForward(g_RiflePickedUp, g_result, id, weaponid, ent, 0)
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}	

public fw_shield_touch(ent, id)
{
	if (!pev_valid(ent))
		return PLUGIN_HANDLED
	if (cs_get_user_hasprim(id))
		return PLUGIN_HANDLED
	return PLUGIN_CONTINUE
}

public fw_explo(ient, ent)
{
	if (!pev_valid(ient))
		return
	new id = pev(ient, pev_owner)
	new iWeaponid = pev(ient, pev_iuser3)
	new spr_index = nsprite_index[iWeaponid]
	new hud[256], Float:damage = _get_GLauncherDmg(id, iWeaponid)
	new Float:radius
	radius = _get_GLauncherRadius(id, iWeaponid)
	format(hud, 255, "%s", weapon_nade_hud[iWeaponid])
	damage_calculate(1, ient, radius  , damage , damage, damage, hud, spr_index )
}

public fw_flash_think(ient, ent)
{
	new weaponid = pev(ient, pev_iuser3)
	new owner = pev(ent, pev_owner)
	new hud[256]
	format(hud, 255, "%s", weapon_nade_hud[pev(ient, pev_iuser1)])
	damage_calculate(2, ient, _get_GLauncherRadius(owner, weaponid), 200.0, 100.0, 100.0, hud , tspr )
}
	
public fw_child_touch(ient, ent)
{
	if (!pev_valid(ient))
		return PLUGIN_HANDLED
	new classname[32]
	pev(ent, pev_classname, classname, 31)
	new weaponid = pev(ent, pev_iuser3)
	if (equal(classname, "player", 6) || equal(classname, "func_breakable", 14) || equal(classname, "func_pushable", 13))
		damage_calculate(1, ient, random_float(5.0, 10.0), random_float(10.0, 50.0), random_float(10.0, 50.0), random_float(10.0, 50.0), weapon_nade_hud[weaponid], tspr)
	remove_entity(ient)
	return PLUGIN_HANDLED
}
	
public fw_smoke_touch(ient, ent)
{
	if (!pev_valid(ient))
		return
	new Float:origin[3], Float:vEnd[3]
	pev(ient, pev_origin, origin)
	vEnd[0] = origin[0]
	vEnd[1] = origin[1]
	vEnd[2] = -1337.0
	engfunc(EngFunc_TraceLine, origin, vEnd, 0, ient, 0);
	get_tr2(0, TR_vecEndPos, vEnd);
	set_pev(ient, pev_origin, vEnd)
	set_pev(ient, pev_movetype, MOVETYPE_TOSS)
}

public fw_rtouch(ent, id)
{
	if (!pev_valid(ent))
		return PLUGIN_HANDLED
	if (pev(ent, pev_iuser4) == 0)
		return PLUGIN_HANDLED
	if (pev(ent, pev_iuser4) == 1)
	{
		if (cs_get_user_hasprim(id))
			return PLUGIN_HANDLED
		if (!is_user_alive(id) || !is_user_connected(id))
			return PLUGIN_HANDLED
		in_touch[id] = true
		new weaponid = weapon_change[pev(ent, pev_iuser3)]
		new weapon_give[32]
		get_weaponname(weaponid, weapon_give, 31)
		has_weapon[id] = pev(ent, pev_iuser3)
		new iEnt = fm_give_item(id, weapon_give)
		cs_set_weapon_ammo(iEnt, pev(ent, pev_iuser1))
		cs_set_user_bpammo(id, weapon_change[has_weapon[id]], pev(ent, pev_iuser2))
		if (weapon_special_mode[has_weapon[id]] == 2 || weapon_special_mode[has_weapon[id]] == 3)
		{
			user_nade[id][has_weapon[id]] = ent_nade_amount[ent]
			nade_clip[id][has_weapon[id]] = 1
		}
		set_ability(has_weapon[id], iEnt, id)
		set_pev(ent, pev_effects, EF_NODRAW)
		set_pev(ent, pev_iuser4, 0)
		in_touch[id] = false
		ExecuteForward(g_ArmouryPickedUp, g_result, id, ent)
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public fw_strip_own_weapon(ent, id)
{
	has_weapon[id] = -1
	in_launcher[id] = false
	in_fshot[id] = false
	in_tshot[id] = false
	for (new i = 0; i < g_weapon_count; i++)
		user_nade[id][i] = 0
}

public fw_smoke(ient, ent)
{
	if (!pev_valid(ient))
		return
	if (pev(ient, pev_iuser1) <= 0)
		remove_entity(ient)
	new Float:fOrigin[3], iOrigin[3]
	pev(ient, pev_origin, fOrigin )
	FVecIVec(fOrigin, iOrigin )
	new x = iOrigin[ 0 ]
	new y = iOrigin[ 1 ]
	new z = iOrigin[ 2 ]
	new wpnid = pev(ient, pev_iuser3)
	create_little_smoke( x, y, z, nsprite_index[wpnid], frame[wpnid], nade_radius[wpnid])
	set_pev(ient, pev_iuser1, pev(ient, pev_iuser1) - 1)
	set_pev(ient, pev_nextthink, get_gametime() + 1.5)
}

public fw_missle(ient, ent)
{
	if (!pev_valid(ient))
		return
	new id = pev(ient, pev_owner)
	new iWeaponid = pev(ient, pev_iuser3)
	new spr_index = nsprite_index[iWeaponid]
	new hud[256], Float:damage = _get_GLauncherDmg(id, iWeaponid)
	new Float:radius
	radius = _get_GLauncherRadius(id, iWeaponid)
	format(hud, 255, "%s", weapon_nade_hud[iWeaponid])
	damage_calculate(1, ient, radius  , damage , damage_hostage[has_weapon[id]], damage_entity[has_weapon[id]], hud, spr_index )
	//client_print(id, print_center, "%d", floatround(damage_player[has_weapon[id]]))
}

public fw_MissleThink(ient)
{
	if (!pev_valid(ient))
		return
	new weaponid = pev(ient, pev_iuser3)
	new spr_index = nsprite_index[weaponid]
	new hud[256], Float:player_damage, Float:hostage_damage, Float:entity_damage
	new Float:radius
	radius = float(nade_radius[weaponid])
	player_damage = damage_player[weaponid]
	hostage_damage = damage_hostage[weaponid]
	entity_damage = damage_entity[weaponid]
	format(hud, 255, "%s", weapon_hud_kill[weaponid])
	damage_calculate(1, ient, radius  , player_damage, hostage_damage, entity_damage,  hud, spr_index )
}

public fw_child_think(ent)
{
	if (!pev_valid(ent))
		return PLUGIN_HANDLED
	set_pev(ent, pev_classname, "explosive_nade")
	return PLUGIN_HANDLED
}

public fw_other_think(ient)
{
	if (!pev_valid(ient))
		return
	if (pev(ient, pev_iuser1) < 1)
	{
		set_pev(ient, pev_iuser1, 1)
		new effect = pev(ient, pev_iuser2)
		if (effect == 4)
			set_pev(ient, pev_effects, EF_BRIGHTFIELD)
		if (effect == 5)
			set_pev(ient, pev_effects, EF_BRIGHTLIGHT)
		if (effect == 6)
			set_pev(ient, pev_effects,  EF_INVLIGHT)
		set_pev(ient, pev_nextthink, get_gametime() + weapon_nade_delay[pev(ient, pev_iuser3)])
		return
	}
	else if (pev(ient, pev_iuser1) > 0)
		engfunc(EngFunc_RemoveEntity, ient)
}

public func_death(msg_id, msg_dest, msg_entity)
{
	static szTruncatedWeapon[33], iAttacker //, iVictim
	get_msg_arg_string(4, szTruncatedWeapon, charsmax(szTruncatedWeapon))
	// Get attacker and victim
	iAttacker = get_msg_arg_int(1)
	// iVictim = get_msg_arg_int(2)
	// Non-player attacker or self kill
	if(!is_user_connected(iAttacker))
		return PLUGIN_CONTINUE
	if (equal(szTruncatedWeapon, "explosive_nade") || equal(szTruncatedWeapon, "AirMissle"))
		return PLUGIN_HANDLED
	if (has_weapon[iAttacker] >-1 && get_user_weapon(iAttacker) == weapon_change[has_weapon[iAttacker]])
	{
		new weaponname[32]
		get_weaponname(weapon_change[has_weapon[iAttacker]], weaponname, 31)
		replace(weaponname, 31, "weapon_", "")
		if(equal(szTruncatedWeapon, weaponname) && get_user_weapon(iAttacker) == weapon_change[has_weapon[iAttacker]])
		{
			ExecuteForward(g_DeathHud, g_result, iAttacker, has_weapon[iAttacker], weapon_hud_kill[has_weapon[iAttacker]])
			if (g_result == PLUGIN_CONTINUE)
				set_msg_arg_string(4, weapon_hud_kill[has_weapon[iAttacker]])
			else return PLUGIN_HANDLED
		}
	}
	if (equal(szTruncatedWeapon, "runknown", 8))
		return PLUGIN_HANDLED
	return PLUGIN_CONTINUE
}

public message_weappickup(msg_id, msg_dest, msg_entity)
{
	if (in_touch[msg_entity])
		return PLUGIN_HANDLED
	return PLUGIN_CONTINUE
}

public message_crosshair(msg_id, msg_dest, msg_entity)
{
	new iFov = pev(msg_entity, pev_fov)
	if (iFov == 55)
		return PLUGIN_HANDLED
	return PLUGIN_CONTINUE
}

public fw_primary_selection(id, menu, item)
{
	if (!is_user_alive(id))
		return
	if (item == MENU_EXIT)
		return
	new info[32], name[32], cb, acc
	menu_item_getinfo(menu, item, acc, info, 31, name, 31, cb)
	new weaponid = str_to_num(info)
	buy_weapon(id, weaponid)
}

public show_weapon(id, key) 
{	
	if (key < 7)
	{
		new weapon_index = g_page[id] * 7 + key 
		buy_weapon(id, weapon_index)
	}
	if (key == 7)
	{ // 8
		if (g_page[id] - 1 < 0)
			g_page[id] = 0
		else  g_page[id]--
		show_weapon_now(id, g_page[id])
	}
	if (key == 8) 
	{ 
		new start = g_page[id] * 7
		if (start > g_weapon_count)
			show_weapon_now(id, g_page[id])
		else
		{
			g_page[id]++
			show_weapon_now(id, g_page[id])
		}
	}
	if (key == 9)
	{}
}

public fw_emitsound(entity, channel, const sample[], Float:volume, Float:attenuation, fFlags, pitch)	
{
	if (!pev_valid(entity) || !is_user_alive(entity)	)
		return FMRES_IGNORED
	if (equal(sample[7], "dryfire_rifle", 13))
	{
		new clip, ammo
		get_user_weapon(entity, clip, ammo)
		if (clip > 0)
			return FMRES_SUPERCEDE
		return FMRES_IGNORED
	}
	return FMRES_IGNORED
}

public pl_spawn(id)
{
	if (has_weapon[id] > -1)
		if (!user_has_weapon(id, weapon_change[has_weapon[id]]))
			has_weapon[id] = -1	
	if (get_pcvar_num(cvar_message))
	{
		client_print(id, print_chat, "[G4U] you have to type wpn_menu in your console")
	}
}			

public pl_alive(id)
{
	if (!is_user_alive(id))
		return FMRES_IGNORED
	if (!pev_valid(id))
		return FMRES_IGNORED
	if (is_user_bot(id))
		return FMRES_IGNORED
	if (has_weapon[id] >-1)
	{
		
		new ent, clip, ammo
		new iWeaponId = get_user_weapon(id, clip, ammo)
		ent = fm_find_ent_by_owner(-1, riffle_name[get_model(weapon_change[has_weapon[id]])], id)
		new fInReload = get_pdata_int(ent, m_fInReload, 4)
		if ( iWeaponId != weapon_change[has_weapon[id]])
		{
			set_pdata_int(ent, m_fInReload, 0, 4)
			if (in_zoom[id])
			{
				cs_set_user_zoom(id, CS_RESET_ZOOM, 0)
				in_zoom[id] = false
				iZoomLevel[id] = 0
				remove_task(id + task_reactive_my_zoom)
				if (weapon_special_mode[has_weapon[id]] == 5 || weapon_special_mode[has_weapon[id]] == 11)
				{
					//if (!weapon_RemoveCrosshair[has_weapon[id]])
					draw_cross(id)
					cs_set_weapon_silen(ent, 0, 0)
					eSetFOV(id, 90)
				}
				else if (weapon_special_mode[has_weapon[id]] == 12)
				{
					//if (!weapon_RemoveCrosshair[has_weapon[id]])
					draw_cross(id)
					eSetFOV(id, 90)
				}
				hide_dcross(id)
			}
			if (task_exists(id + reload_my_weapon))
				remove_task(id + reload_my_weapon)
			if (task_exists(id + active_my_grenade))
				remove_task(id + active_my_grenade)
			if (task_exists(id + reload_type_2))
				remove_task(id + reload_type_2)
			if (task_exists(id + start_launcher))
				remove_task(id + start_launcher)
			if (task_exists(id - start_launcher))
				remove_task(id - start_launcher)
			if (task_exists(id + knife_attack))
				remove_task(id + knife_attack)
			if (task_exists(id  + task_reload_my_weapon))
				remove_task(id + task_reload_my_weapon)
			if (task_exists(id + task_insert_animation))
				remove_task(id + task_insert_animation)
			if (task_exists(id + task_add_me_ammo))
				remove_task(id + task_add_me_ammo)
			if (task_exists(id + task_active_atk))
				remove_task(id + task_active_atk)
			if (task_exists(id + task_finish_reload))
				remove_task(id + task_finish_reload)
			fInIdle[id] = false
			StartAtk[id] = 0
			Update[id] = false
		}
		else 
		{
			if (in_zoom[id])
			{
				if (weapon_special_mode[has_weapon[id]] == 12 || weapon_special_mode[has_weapon[id]] == 5 || weapon_special_mode[has_weapon[id]] == 11)
				{
					new iZoomMode = weapon_zoom_type[has_weapon[id]]
					if (iZoomMode == 1)
					{
						if (!iCheckSniper(weapon_change[has_weapon[id]]))
							hide_cross(id)	
						message_begin(MSG_ONE_UNRELIABLE, iCrosshairMessage, _, id)
						write_byte(0)
						message_end()
					}
					else if (iZoomMode == 5)
					{
						if (weapon_FOV[has_weapon[id]] > 44)
						{
							hide_dcross(id)
							hide_cross(id)
						}
					}
				}
			}
			if (clip > _get_maxclip(id, has_weapon[id], 1))
			{
				cs_set_weapon_ammo(ent, _get_maxclip(id, has_weapon[id], 1))
				cs_set_user_bpammo(id, weapon_change[has_weapon[id]], cs_get_user_bpammo(id, weapon_change[has_weapon[id]]) + clip - _get_maxclip(id, has_weapon[id], 1))
			}
			//if (ammo > weapon_bpa[has_weapon[id]])
			//	cs_set_user_bpammo(id, weapon_change[has_weapon[id]], weapon_bpa[has_weapon[id]])
			if (get_gametime() - user_delay[id] >= 0.7)
				can_shot[id] = true
			if (fInReload)
			{
				if (cs_get_weapon_silen(ent) && (weapon_special_mode[has_weapon[id]] == 5 || weapon_special_mode[has_weapon[id]] == 11))
				{
					cs_set_weapon_silen(ent, 0, 0)
					in_zoom[id] = false
				}
			}
			if (weapon_silencer[has_weapon[id]] == 6)
			{
				new Float:CurrentTime = get_gametime()
				if (StartAtk[id] == 1)
				{
					if (CurrentTime - fOpenFire[id] >= weapon_start_firing[has_weapon[id]] + 0.25)
					{
						Update[id] = false
						StartAtk[id] = 0
					}
				}
				if (StartAtk[id] == 2)
				{
					if (CurrentTime - fOpenFire[id] >= weapon_finish_firing[has_weapon[id]])
					{
						Update[id] = false
						StartAtk[id] = 0
					}
				}
			}
		}
		
	}
	return FMRES_IGNORED
}

public pl_alive_bot(id)
{
	if (!is_user_alive(id))
		return FMRES_IGNORED
	if (!pev_valid(id))
		return FMRES_IGNORED
	if (!is_user_bot(id))
		return FMRES_IGNORED
	if (has_weapon[id] >-1)
	{
		new ent, clip, ammo
		ent = fm_find_ent_by_owner(-1, riffle_name[get_model(weapon_change[has_weapon[id]])], id)
		new fInReload = get_pdata_int(ent, m_fInReload, 4)
		if (get_user_weapon(id) != weapon_change[has_weapon[id]])
		{
			set_pdata_int(ent, m_fInReload, 0, 4)
			if (in_zoom[id])
			{
				cs_set_user_zoom(id, CS_RESET_ZOOM, 0)
				in_zoom[id] = false
				iZoomLevel[id] = 0
				remove_task(id + task_reactive_my_zoom)
				if (weapon_special_mode[has_weapon[id]] == 5 || weapon_special_mode[has_weapon[id]] == 11)
				{
					draw_cross(id)
					cs_set_weapon_silen(ent, 0, 0)
					eSetFOV(id, 90)
				}
				else if (weapon_special_mode[has_weapon[id]] == 12)
				{
					//if (!weapon_RemoveCrosshair[has_weapon[id]])
					draw_cross(id)
					eSetFOV(id, 90)
				}
				hide_dcross(id)
			}
			if (task_exists(id + reload_my_weapon))
				remove_task(id + reload_my_weapon)
			if (task_exists(id + active_my_grenade))
				remove_task(id + active_my_grenade)
			if (task_exists(id + reload_type_2))
				remove_task(id + reload_type_2)
			if (task_exists(id + start_launcher))
				remove_task(id + start_launcher)
			if (task_exists(id - start_launcher))
				remove_task(id - start_launcher)
			if (task_exists(id + knife_attack))
				remove_task(id + knife_attack)
			if (task_exists(id  + task_reload_my_weapon))
				remove_task(id + task_reload_my_weapon)
			if (task_exists(id + task_insert_animation))
				remove_task(id + task_insert_animation)
			if (task_exists(id + task_add_me_ammo))
				remove_task(id + task_add_me_ammo)
			if (task_exists(id + task_active_atk))
				remove_task(id + task_active_atk)
			if (task_exists(id + task_finish_reload))
				remove_task(id + task_finish_reload)
			if (task_exists(id + TASK_USE_FLASHLIGHT))
				remove_task(id + TASK_USE_FLASHLIGHT)
			fInIdle[id] = false
			StartAtk[id] = 0
			Update[id] = false
		}
		else if (get_user_weapon(id, clip, ammo) == weapon_change[has_weapon[id]])
		{
			if (in_zoom[id])
			{
				if (weapon_special_mode[has_weapon[id]] == 12 || weapon_special_mode[has_weapon[id]] == 5 || weapon_special_mode[has_weapon[id]] == 11)
					hide_cross(id)	
				if (weapon_zoom_type[has_weapon[id]] == 1)
				{
					message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("Crosshair"), _, id)
					write_byte(0)
					message_end()
				}
			}
			if (clip > _get_maxclip(id, has_weapon[id], 1))
			{
				cs_set_weapon_ammo(ent, weapon_clip[has_weapon[id]])
				cs_set_user_bpammo(id, weapon_change[has_weapon[id]], cs_get_user_bpammo(id, weapon_change[has_weapon[id]]) + clip - _get_maxclip(id, has_weapon[id], 1))
			}
			//if (ammo > weapon_bpa[has_weapon[id]])
			//	cs_set_user_bpammo(id, weapon_change[has_weapon[id]], weapon_bpa[has_weapon[id]])
			if (get_gametime() - user_delay[id] >= 0.7)
				can_shot[id] = true
			if (fInReload)
			{
				if (cs_get_weapon_silen(ent) && (weapon_special_mode[has_weapon[id]] == 5 || weapon_special_mode[has_weapon[id]] == 11))
				{
					cs_set_weapon_silen(ent, 0, 0)
					in_zoom[id] = false
				}
			}
			if (weapon_silencer[has_weapon[id]] == 6)
			{
				new Float:CurrentTime = get_gametime()
				if (StartAtk[id] == 1)
				{
					if (CurrentTime - fOpenFire[id] >= weapon_start_firing[has_weapon[id]] + 0.25)
					{
						Update[id] = false
						StartAtk[id] = 0
					}
				}
				if (StartAtk[id] == 2)
				{
					if (CurrentTime - fOpenFire[id] >= weapon_finish_firing[has_weapon[id]])
					{
						Update[id] = false
						StartAtk[id] = 0
					}
				}
			}
			if (weapon_special_mode[has_weapon[id]] == 5 || weapon_special_mode[has_weapon[id]] == 11)
			{
				if (cs_get_weapon_silen(ent))
					hide_cross(id)
				else
				{
					draw_cross(id)
					hide_dcross(id)
				}
			}
			if (weapon_special_mode[has_weapon[id]] == 0)
			{
				if (weapon_silencer[has_weapon[id]] == 4)
				{
					new animation = pev(id, pev_sequence)
					new wid = get_model(weapon_change[has_weapon[id]])
					if (animation == rifle_sequence_couch[wid])
						set_pev(id, pev_sequence, 22)
					else if (animation == rifle_sequence_couch_shoot[wid])
						set_pev(id, pev_sequence, random_num(23,24))
					else if (animation == rifle_sequence_stand[wid])
						set_pev(id, pev_sequence, 26)
					else if (animation == rifle_sequence_stand_shoot[wid])
						set_pev(id, pev_sequence, random_num(27, 28))
					else if (animation == rifle_sequence_reload_couch[wid])
						set_pev(id, pev_sequence, 25)
					else if (animation == rifle_sequence_reload_stand[wid])
						set_pev(id, pev_sequence, 29)
					//return FMRES_HANDLED
				}
			}
			hide_cross(id)
		}
	}
	return FMRES_IGNORED
}
public onTraceLinePost(Float:v1[3], Float:v2[3], fNoMonsters, pentToSkip, ptr)
{
	//engfunc(EngFunc_TraceLine, v1, v2, fNoMonsters, pentToSkip, ptr)
	new victim; victim = get_tr2(ptr, TR_pHit)
	if (!is_user_valid_connected(victim))
		return
	new attacker = get_user_attacker(victim)
	if (!is_user_valid_connected(attacker))
		return
	if(has_weapon[attacker] < 0)
		return
	if(weapon_silencer[has_weapon[attacker]] != 2)
		return
	if (get_tr2(ptr, TR_iHitgroup) != HIT_SHIELD)
		return
	if (get_user_weapon(attacker) != weapon_change[has_weapon[attacker]])
		return
	set_tr2(ptr, TR_iHitgroup, HIT_GENERIC)
	//return FMRES_SUPERCEDE
}

public fw_strip(ient, id)
{
	if (!pev_valid(ient))
		return PLUGIN_HANDLED
	if (!is_user_alive(id))	
		return PLUGIN_HANDLED
	has_weapon[id] = -1
	reset_nade(id)
	return PLUGIN_CONTINUE
}


public pl_take_damage(victim, inflictor, attacker, Float:damage, damagebit)
{
	new classname[32]
	pev(attacker, pev_classname, classname, 31)
	if (equal(classname, "trigger_hurt", 12))
		return HAM_IGNORED
	if (!(1 <= attacker <= get_maxplayers()))
		return HAM_IGNORED
	if (has_weapon[attacker] < 0)
		return HAM_IGNORED
	if (weapon_silencer[has_weapon[attacker]] == 7)
	{
		if (damagebit & DMG_BULLET)
			return HAM_SUPERCEDE
		else	return HAM_IGNORED
	}
	
	if (damagebit & DMG_SLASH)
		return HAM_IGNORED
	if ((damagebit & (1<<24)) && weapon_silencer[has_weapon[attacker]] == 8)
		return HAM_IGNORED
	if (pev_valid(attacker) && pev_valid(victim) && get_user_weapon(attacker) == weapon_change[has_weapon[attacker]])
		SetHamParamFloat(4, damage * damage_player[has_weapon[attacker]])
	return HAM_IGNORED
}


public hs_take_damage(victim, inflictor, attacker, Float:damage, damagebit)
{
	new classname[32]
	pev(attacker, pev_classname, classname, 31)
	if (equal(classname, "trigger_hurt", 12))
		return HAM_IGNORED
	if (has_weapon[attacker] < 0)
		return HAM_IGNORED
	if (weapon_silencer[has_weapon[attacker]] == 7)
	{
		if (damagebit & DMG_BULLET)
			return HAM_SUPERCEDE
		else	return HAM_IGNORED
	}
	if ((damagebit & (1<<24)) && weapon_silencer[has_weapon[attacker]] == 8)
		return HAM_IGNORED
	if (damagebit & DMG_SLASH)
		return HAM_IGNORED
	if (pev_valid(attacker) && pev_valid(victim) && get_user_weapon(attacker) == weapon_change[has_weapon[attacker]])
		SetHamParamFloat(4, damage * damage_hostage[has_weapon[attacker]])
	return HAM_IGNORED
}

public ent_take_damage(victim, inflictor, attacker, Float:damage, damagebit)
{
	new classname[32]
	pev(attacker, pev_classname, classname, 31)
	if (equal(classname, "trigger_hurt", 12))
		return HAM_IGNORED
	if (has_weapon[attacker] < 0)
		return HAM_IGNORED
	if (weapon_silencer[has_weapon[attacker]] == 7)
	{
		if (damagebit & DMG_BULLET)
			return HAM_SUPERCEDE
		else	return HAM_IGNORED
	}
	if ((damagebit & (1<<24)) && weapon_silencer[has_weapon[attacker]] == 8)
		return HAM_IGNORED
	if (damagebit & DMG_SLASH)
		return HAM_IGNORED
	if (pev_valid(attacker) && pev_valid(victim) && get_user_weapon(attacker) == weapon_change[has_weapon[attacker]])
		SetHamParamFloat(4, damage * damage_entity[has_weapon[attacker]])
	return HAM_IGNORED
}

public fw_trace(victim, attacker, Float:damage, Float:direction[3], tracehandle, damage_type)
{
	// Non-player damage or self damage
	if (victim == attacker || !is_user_connected(victim))
		return HAM_IGNORED
	// Victim isn't a zombie or not bullet damage, nothing else to do here
	if (!(damage_type & DMG_BULLET))
		return HAM_IGNORED;
	if (get_model(get_user_weapon(attacker)) != -1)
		return HAM_IGNORED
	// Get whether the victim is in a crouch state
	static ducking
	ducking = pev(victim, pev_flags) & (FL_DUCKING | FL_ONGROUND) == (FL_DUCKING | FL_ONGROUND)
	//if (pev(victim, pev_flags) &~ FL_ONGROUND)
	//	return HAM_IGNORED
	// Get distance between players
	static origin1[3], origin2[3]
	get_user_origin(victim, origin1)
	get_user_origin(attacker, origin2)
	// Max distance exceeded
	if (has_weapon[attacker] > -1)
	{
		damage *= damage_player[has_weapon[attacker]]
		if (get_distance(origin1, origin2) > weapon_kdistance[has_weapon[attacker]])
			return HAM_IGNORED
	}
	if (has_weapon[attacker] < 0)
		if (get_distance(origin1, origin2) > 500)
			return HAM_IGNORED
	// Get victim's velocity
	static Float:velocity[3]
	pev(victim, pev_velocity, velocity)
	// Use damage on knockback calculation
	xs_vec_mul_scalar(direction, damage, direction)
	// Use weapon power on knockback calculation
	if (has_weapon[attacker] < 0 )
		if (kb_weapon_power[get_user_weapon(attacker)] > 0.0)
			xs_vec_mul_scalar(direction, kb_weapon_power[get_user_weapon(attacker)], direction)
	if (has_weapon[attacker] > -1)
		if (weapon_knockback[has_weapon[attacker]] > 0.0)
			xs_vec_mul_scalar(direction, weapon_knockback[has_weapon[attacker]], direction)
	// Apply ducking knockback multiplier
	if (ducking)
		xs_vec_mul_scalar(direction, 0.75, direction)
	// Apply zombie class/nemesis knockback multiplier
	//xs_vec_mul_scalar(direction, g4u_get_zombie_knockback(victim), direction)
	// Add up the new vector
	xs_vec_add(velocity, direction, direction)
	// Set the knockback'd victim's velocity
	set_pev(victim, pev_velocity, direction)
	return HAM_IGNORED;
}

public pistol_primattack(ent)
{
	new id = pev(ent,pev_owner)
	new clip, ammo
	new iWeaponId = get_user_weapon(id, clip, ammo)
	if(has_weapon[id] > -1 && iWeaponId  == weapon_change[has_weapon[id]])
	{
		if ((weapon_special_mode[has_weapon[id]] != 5 && weapon_special_mode[has_weapon[id]] != 11)  && !cs_get_weapon_silen(ent) || weapon_special_mode[has_weapon[id]] == 5 || weapon_special_mode[has_weapon[id]] == 11)
		{
			if (clip > 0)
			{
				ExecuteForward(g_WeaponPlaySound, g_result, id, has_weapon[id], weapon_sound[has_weapon[id]])
				if (g_result == PLUGIN_CONTINUE)
					emit_sound(id, CHAN_AUTO, weapon_sound[has_weapon[id]], 1.0, ATTN_NORM, 0, PITCH_NORM)
			}
		}
		if (in_zoom[id] && weapon_special_mode[has_weapon[id]] == 1 && 0 < weapon_zoom_type[has_weapon[id]] <= 4)
		{
			if (weapon_silencer[has_weapon[id]] == 3 || weapon_silencer[has_weapon[id]] == 9)
			{
				new Float:Delay = get_pdata_float(ent, 46, 4) * weapon_speed[has_weapon[id]]	
				iCurrentZoom[id] = cs_get_user_zoom(id)
				cs_set_user_zoom(id, CS_RESET_ZOOM, 0)
				set_task(Delay + ZOOM_DELAYED, "reactive_my_zoom", id + task_reactive_my_zoom)
			}
		}
		if (weapon_silencer[has_weapon[id]] == 6)
		{
			if (clip > 0)
			{
				fOpenFire[id] = get_gametime()
				if (StartAtk[id] == 1)
					StartAtk[id] = 2
			}
		}
		if (weapon_silencer[has_weapon[id]] == 7)
		{
			set_pdata_float(id, m_flNextAttack, 0.1, 5)
			//if (weapon_silencer[has_weapon[id]] == 7)
			//		{
			//			set_uc(ucHandle, UC_Buttons, button &= ~IN_ATTACK)
			//		new Float:CurrentTime = get_gametime()
			//			if (CurrentTime - time_delay[id] >= weapon_deploy_time[has_weapon[id]])
			if (clip)
				launch_missle(id, has_weapon[id])
			return HAM_SUPERCEDE
		}
	}
	else if (has_weapon[id] < 0)
	{
		new clip, ammo
		get_user_weapon(id, clip, ammo)
		if (clip > 0)
		{
			if (!cs_get_weapon_silen(ent))
			{
				new RealId = check_prim(id)
				if (!cs_get_weapon_burst(ent))
				{
					new sound[256]
					format(sound, 255, "%s/%s", sound_directory, rifle_sound[RealId])
					//if (file_exists(sound))
					emit_sound(id, CHAN_AUTO, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
				}
				else
				{
					new sound[256]
					format(sound, 255, "%s/%s", sound_directory, rifle_sound[RealId])
					//if (file_exists(sound))
					replace(sound, 255, "-1.wav", "-2.wav")
					emit_sound(id, CHAN_AUTO, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
				}	
			}
		}
	}
	pev(id,pev_punchangle,cl_pushangle[id])	
	return HAM_IGNORED
}

public reactive_my_zoom(taskid)
{
	new id = taskid - task_reactive_my_zoom
	if (!is_user_alive(id))
		return
	if (has_weapon[id] < 0)
		return
	if (get_user_weapon(id) != weapon_change[has_weapon[id]])
		return
	new ent = fm_find_ent_by_owner(-1, riffle_name[get_model(weapon_change[has_weapon[id]])], id)
	//new Float:Delay = get_pdata_float(ent, 46, 4) * weapon_speed[has_weapon[id]]	
	new fInReload = get_pdata_int(ent, m_fInReload, 4)
	if (fInReload)
		return
	new Float:next_attack = get_pdata_float(id, m_flNextAttack, 5)
	if (next_attack > 0.0)
	{
		set_task(next_attack + ZOOM_DELAYED, "reactive_my_zoom", taskid)
		return
	}
	if (!in_zoom[id])
		return
	cs_set_user_zoom(id, iCurrentZoom[id], 0)
}
	
public pistol_primattack_post(ent)
{
	new id = pev(ent,pev_owner)
	new clip, ammo
	new Float:push[3]
	pev(id,pev_punchangle,push)
	xs_vec_sub(push,cl_pushangle[id],push)
	new weaponid = get_user_weapon(id, clip, ammo)
	if(has_weapon[id] > -1)
	{
		if (weaponid == weapon_change[has_weapon[id]])
		{
			if ((weapon_special_mode[has_weapon[id]] != 5 || weapon_special_mode[has_weapon[id]] == 5 && !in_zoom[id]) && (weapon_special_mode[has_weapon[id]] != 11 || weapon_special_mode[has_weapon[id]] == 11 && !in_zoom[id]) && (weapon_special_mode[has_weapon[id]] != 12 || weapon_special_mode[has_weapon[id]] == 12 && !in_zoom[id]))
				xs_vec_mul_scalar(push,_get_recoil(id, has_weapon[id], 1),push)
			if (weapon_special_mode[has_weapon[id]] == 5 && in_zoom[id] || weapon_special_mode[has_weapon[id]] == 11 && in_zoom[id] || weapon_special_mode[has_weapon[id]] == 12 && in_zoom[id])
				xs_vec_mul_scalar(push,_get_recoil(id, has_weapon[id], 1) * random_float(0.5, 0.75),push)
			xs_vec_add(push,cl_pushangle[id],push)
			set_pev(id,pev_punchangle,push)
			if(ent) 
			{
				new Float:Delay = get_pdata_float(ent, 46, 4) * _get_shoot_speed(id, has_weapon[id], 1)	
				if (Delay > 0.0) 
					set_pdata_float(ent, 46, Delay, 4)
			}
			if (weapon_silencer[has_weapon[id]] == 6)
				SendWeaponAnim(id, weapon_max_animation[get_model(weapon_change[has_weapon[id]])] + 7)
			fOpenFire[id] = get_gametime()
			if (weapon_special_mode[has_weapon[id]] == 13 && 90 - g_FOV[id] > 20)
				hide_dcross(id)
			if (weapon_silencer[has_weapon[id]] == 7)
				return HAM_SUPERCEDE
				
			if (weapon_silencer[has_weapon[id]] == 8)
			{
				if (clip)
				{
					new Float:fOrigin[3], tr_result
					new iViewOrigin[3]
					get_user_origin(id, iViewOrigin, 1)
					
					IVecFVec(iViewOrigin, fOrigin)
					new iEndOrigin[3], Float:fEndOrigin[3]
					get_user_origin(id, iEndOrigin, 3)
					
					IVecFVec(iEndOrigin, fEndOrigin)
					engfunc(EngFunc_TraceLine, fOrigin, fEndOrigin, DONT_IGNORE_MONSTERS, id, tr_result)
					get_tr2(tr_result, TR_vecEndPos, fEndOrigin)
					FVecIVec(fEndOrigin, iEndOrigin)
					message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
					write_byte(TE_EXPLOSION)
					write_coord(iEndOrigin[0])
					write_coord(iEndOrigin[1])
					write_coord(iEndOrigin[2])
					write_short(sExplo)
					write_byte(10) // Scale
					write_byte(15) // Framerate
					write_byte(4)
					message_end()
					DmgCalculate(id, ent, fEndOrigin, 100.0, 100.0, 100.0, 100.0)
				}
				
			}
		}
	}
	else
	{
		xs_vec_mul_scalar(push,_get_recoil(id, weaponid, 0),push)
		xs_vec_add(push,cl_pushangle[id],push)
		set_pev(id,pev_punchangle,push)
		if(ent) 
		{
			new Float:Delay = get_pdata_float(ent, 46, 4) * _get_shoot_speed(id, weaponid, 0)	
			if (Delay > 0.0) 
				set_pdata_float(ent, 46, Delay, 4)
		}
	}
	return HAM_IGNORED
}

public fw_item_deploy(ent)
{
	new owner = pev(ent, pev_owner)
	if (!is_user_alive(owner) || has_weapon[owner] < 0)
		return HAM_IGNORED
	zoom_delay[owner] = get_gametime()
	shot_delay[owner] = get_gametime()
	can_shot[owner] = true
	time_delay[owner] = get_gametime()
	
	set_pdata_float(owner, m_flNextAttack, _GetDeployTime(owner, has_weapon[owner]) + 0.25, 5)
	set_pdata_float(ent, m_flTimeWeaponIdle, _GetDeployTime(owner, has_weapon[owner]), 4)
	
	if (get_user_weapon(owner) == weapon_change[has_weapon[owner]])
	{
		if (weapon_special_mode[has_weapon[owner]] == 2 || weapon_special_mode[has_weapon[owner]] == 3)
		{
			if (in_launcher[owner])
			{
				set_pev(owner, pev_viewmodel2, weapon_launching_nade[has_weapon[owner]])
				if (weapon_launch_type[has_weapon[owner]] == 1)
					SendWeaponAnim(owner, anim_deploy)
				if (nade_clip[owner][has_weapon[owner]] < 1 && user_nade[owner][has_weapon[owner]] > 0 && !task_exists(owner + reload_my_weapon) && !task_exists(owner + active_my_grenade) && !task_exists(owner + reload_type_2))
				{
					if (weapon_launch_type[has_weapon[owner]] == 1)
						set_task(0.7, "reload_my_launcher", owner + reload_my_weapon)
					if (weapon_launch_type[has_weapon[owner]] == 2)
						set_task(0.5,"start_reload_launcher", owner + reload_type_2)
					nade_reload[owner] = true	
				}
			}
		}
	}
	StartAtk[owner] = 0
	Update[owner] = false
	return HAM_IGNORED
}

public fw_weapon_special_attack(ent)
	ExecuteForward(g_function_active, g_result, ent)

public fw_weaponreload(ent)
{
	new owner = pev(ent, pev_owner)
	ExecuteForward(g_reload, g_result, owner)
	new id = owner
	set_pdata_int(ent, m_fInReload, 1, 4)
	hide_dcross(id)
	eSetFOV(id, 90)
	if (has_weapon[owner] >= 0)
	{
		if (get_user_weapon(id) == weapon_change[has_weapon[id]])
		{
			
			cs_set_user_zoom(id, CS_RESET_ZOOM, 0)
			iZoomLevel[id] = 0
			remove_task(id + task_reactive_my_zoom)
			Update[id] = false
			StartAtk[id] = 0
			hide_dcross(id)
			if (weapon_special_mode[has_weapon[id]] != 4)
				in_zoom[id] = false
			if (weapon_special_mode[has_weapon[id]] == 5 || weapon_special_mode[has_weapon[id]] == 11)
			{
				cs_set_weapon_silen(ent, 0, 0)
				draw_cross(id)
			}
			if (weapon_special_mode[has_weapon[id]] == 12)
			{
				draw_cross(id)
				emessage_begin(MSG_ONE_UNRELIABLE, get_user_msgid("CurWeapon"), _, id)
				ewrite_byte(1) // active
				ewrite_byte(weapon_change[has_weapon[id]]) // weapon
				ewrite_byte(cs_get_weapon_ammo(ent)) // clip
				emessage_end()
				set_pev(id, pev_viewmodel2, weapon_v_model[has_weapon[id]])
			}
			zoom_delay[owner] = get_gametime()
			shot_delay[owner] = get_gametime()
			if (weapon_silencer[has_weapon[id]] != 5)
			{
				set_pdata_float(id, m_flNextAttack, _GetReloadTime(id, has_weapon[id]) + 0.25, 5)
				set_pdata_float(ent, m_flTimeWeaponIdle, _GetReloadTime(id, has_weapon[id]), 4)
				
				/*if (weapon_silencer[has_weapon[id]] == 7)
				{
					set_pdata_float(id, m_flNextAttack, 100000000.0, 5)
					set_pdata_float(ent, m_flNextPrimaryAttack, 100000000.0, 4)
					set_pdata_float(ent, m_flNextSecondaryAttack, 1000000000.0, 4)
					set_pdata_float(ent, m_flTimeWeaponIdle, 1000000000.0, 4)
					return HAM_SUPERCEDE
				}*/
			}
			else if (weapon_silencer[has_weapon[id]] == 5 || weapon_silencer[has_weapon[id]] == 9)
			{
				fInIdle[id] = false
				set_pdata_float(id, m_flNextAttack, 100000000.0 + _GetReloadTime(id, has_weapon[id]), 5)
				set_pdata_float(ent, m_flNextPrimaryAttack, 100000000.0 + _GetReloadTime(id, has_weapon[id]), 4)
				set_pdata_float(ent, m_flNextSecondaryAttack, 1000000000.0 + _GetReloadTime(id, has_weapon[id]), 4)
				set_pdata_float(ent, m_flTimeWeaponIdle, 1000000000.0 + _GetReloadTime(id, has_weapon[id]), 4)
				if (task_exists(id + task_insert_animation))
					remove_task(id + task_insert_animation)
				if (task_exists(id + task_add_me_ammo))
					remove_task(id + task_add_me_ammo)
				set_task(_GetReloadTime(id, has_weapon[id]), "show_insert_animation", id + task_insert_animation)
				//set_task(2.0, "show_insert_animation", id + task_insert_animation)
			}
			
		}
	}
	return HAM_IGNORED
}

public show_insert_animation(taskid)
{
	new id = taskid - task_insert_animation
	if (!is_user_alive(id) || has_weapon[id] < 0)
		return
	new iWeaponid = get_user_weapon(id)
	if (iWeaponid != weapon_change[has_weapon[id]])
		return
	fInIdle[id] = false
	new WeaponName[32]
	get_weaponname(iWeaponid, WeaponName, 31)
	new ent = find_ent_by_owner(-1, WeaponName, id)
	if (!cs_get_weapon_silen(ent))
		SendWeaponAnim(id, weapon_max_animation[get_model(get_user_weapon(id))] + INSERT_ANIMATION)
	else	SendWeaponAnim(id, weapon_max_animation[get_model(get_user_weapon(id))] + INSERT_ANIMATION + 4)
	emit_sound(id, CHAN_ITEM, random_num(0,1) ? "weapons/reload1.wav" : "weapons/reload3.wav", 1.0, ATTN_NORM, 0, 85 + random_num(0,0x1f))
	set_task(weapon_time_per_bullet[has_weapon[id]], "add_ammo_to_my_weapon", id + task_add_me_ammo)
}

public add_ammo_to_my_weapon(taskid)
{
	new id = taskid - task_add_me_ammo
	if (!is_user_alive(id) || has_weapon[id] < 0)
		return
	if (get_user_weapon(id) != weapon_change[has_weapon[id]])
		return
	new WeaponName[32]
	get_weaponname(weapon_change[has_weapon[id]], WeaponName, 31)
	new iEnt = find_ent_by_owner(-1, WeaponName, id)
	static iAmmoType ; iAmmoType = m_rgAmmo_player_Slot0 + get_pdata_int(iEnt, m_iPrimaryAmmoType, 4)
	static iBpAmmo ; iBpAmmo = get_pdata_int(id, iAmmoType, 5)
	static iClip ; iClip = get_pdata_int(iEnt, m_iClip, 4)
	set_pdata_int(iEnt, m_iClip, iClip + 1, 4)
	set_pdata_int(id, iAmmoType, iBpAmmo-1, 5)
	if (iClip + 1 < _get_maxclip(id, has_weapon[id], 1) && iBpAmmo > 0)
	{
		if (task_exists(id + task_active_atk))
			remove_task(id + task_active_atk)
		set_task(weapon_time_per_bullet[has_weapon[id]] + 0.05, "active_atk", id + task_active_atk)
		set_task(weapon_time_per_bullet[has_weapon[id]] + 0.2, "show_insert_animation", id + task_insert_animation)
	}
	else
	{
		new iMaxAnim = weapon_max_animation[get_model(get_user_weapon(id))] 
		if (!cs_get_weapon_silen(iEnt))
			SendWeaponAnim(id, iMaxAnim + AFTER_INSERT_ANIMATION)
		else	SendWeaponAnim(id, iMaxAnim + AFTER_INSERT_ANIMATION + 4)
		fInIdle[id] = false
		set_pdata_float(id, m_flNextAttack, 1000.0, 5)
		if (task_exists(id + task_finish_reload))
			remove_task(id + task_finish_reload)
		set_task(weapon_finish_reload[has_weapon[id]], "finish_my_reload", id + task_finish_reload)
		set_pdata_float(iEnt, m_flTimeWeaponIdle,  weapon_finish_reload[has_weapon[id]] + 0.25, 4)
	}
}

public active_atk(taskid)
{
	new id = taskid - task_active_atk
	if (!fInIdle[id])
		fInIdle[id] = true
}

public finish_my_reload(taskid)
{
	new id = taskid - task_finish_reload
	if (!is_user_alive(id) || has_weapon[id] < 0)
		return
	if (get_user_weapon(id) != weapon_change[has_weapon[id]])
		return
	new WeaponName[32]
	get_weaponname(weapon_change[has_weapon[id]], WeaponName, 31)
	new iEnt = find_ent_by_owner(-1, WeaponName, id)
	set_pdata_int(iEnt, m_fInReload, 0, 4)
	set_pdata_float(id, m_flNextAttack, 0.5, 5)
	set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.5, 4)
	set_pdata_float(iEnt, m_flNextSecondaryAttack, 0.5, 4)
}

public fw_itempostframe(iEnt)
{
	if (!pev_valid(iEnt))
		return
	static fInReload ; fInReload = get_pdata_int(iEnt, m_fInReload, 4)
	static id ; id = get_pdata_cbase(iEnt, m_pPlayer, 4)
	static Float:flNextAttack ; flNextAttack = get_pdata_float(id, m_flNextAttack, 5)

	static iAmmoType ; iAmmoType = m_rgAmmo_player_Slot0 + get_pdata_int(iEnt, m_iPrimaryAmmoType, 4)
	static iBpAmmo ; iBpAmmo = get_pdata_int(id, iAmmoType, 5)
	static iClip ; iClip = get_pdata_int(iEnt, m_iClip, 4)
	if (has_weapon[id] < 0)
	{
		new WeaponName[32]
		pev(iEnt, pev_classname, WeaponName, 31)
		new Weaponid = get_weaponid(WeaponName)
		static iMaxClip ; iMaxClip = _get_maxclip(id, Weaponid, 0)
		if(fInReload && flNextAttack <= 0.0 )
		{
			new j = min(iMaxClip - iClip, iBpAmmo)
			set_pdata_int(iEnt, m_iClip, iClip + j, 4)
			set_pdata_int(id, iAmmoType, iBpAmmo-j, 5)
			
			set_pdata_int(iEnt, m_fInReload, 0, 4)
			fInReload = 0
			hide_dcross(id)
		}
	}
	else
	{
		static iMaxClip 
		if (weapon_silencer[has_weapon[id]] != 7)
			iMaxClip = _get_maxclip(id, has_weapon[id], 1)
		else	iMaxClip = 1
		if(fInReload && flNextAttack <= 0.0 )
		{
			new j = min(iMaxClip - iClip, iBpAmmo)
			set_pdata_int(iEnt, m_iClip, iClip + j, 4)
			set_pdata_int(id, iAmmoType, iBpAmmo-j, 5)
			
			set_pdata_int(iEnt, m_fInReload, 0, 4)
			fInReload = 0
			hide_dcross(id)
		}
	}
}

public Item_AttachToPlayer(iEnt, id)
{
	if(get_pdata_int(iEnt, m_fKnown, 4))
	{
		return
	}
	ExecuteForward(g_RifleAttached , g_result, id, iEnt)
	if (has_weapon[id] >= 0)
	{
		new weaponid = has_weapon[id]
		ExecuteForward(g_UpdateWpnClass, g_result, id, has_weapon[id], weapon_change[weaponid])
		if (g_result == PLUGIN_CONTINUE)
			update_hud_WeaponList(id, weapon_change[weaponid], weapon_clip[weaponid] , WeaponClass[weaponid], weapon_bpa[weaponid], 0)
		return
	}
	
	new WeaponName[32]
	pev(iEnt, pev_classname, WeaponName, 31)
	new weaponid = get_weaponid(WeaponName)
	new iClip =  _get_maxclip(id, weaponid, 0)
	set_pdata_int(iEnt, m_iClip, iClip , 4)
	new iBpa = MAXBPAMMO[weaponid]
	ExecuteForward(g_ReceivedRifle, g_result, id, 0, weaponid)
	update_hud_WeaponList(id, weaponid, iClip  , WeaponName, iBpa, 0)
}

public fw_m4a1_secondary_atk(ent)
{
	new id = pev(ent, pev_owner)
	if (!is_user_alive(id))
		return HAM_IGNORED
	if (has_weapon[id] < 0)
		return HAM_SUPERCEDE
	return HAM_IGNORED
}

stock release_my_grenade(ent)
{
	new owner = pev(ent, pev_owner)
	if (!is_user_alive(owner) || has_weapon[owner] < 0)
		return
	zoom_delay[owner] = get_gametime()
	shot_delay[owner] = get_gametime()
	can_shot[owner] = true
	time_delay[owner] = get_gametime()
	if (get_user_weapon(owner) == weapon_change[has_weapon[owner]])
	{
		if (weapon_special_mode[has_weapon[owner]] == 2 || weapon_special_mode[has_weapon[owner]] == 3)
		{
			if (in_launcher[owner])
			{
				set_pev(owner, pev_viewmodel2, weapon_launching_nade[has_weapon[owner]])
				if (nade_clip[owner][has_weapon[owner]] < 1 && user_nade[owner][has_weapon[owner]] > 0 && !task_exists(owner + reload_my_weapon) && !task_exists(owner + active_my_grenade) && !task_exists(owner + reload_type_2))
				{
					if (weapon_launch_type[has_weapon[owner]] == 1)
						set_task(0.7, "reload_my_launcher", owner + reload_my_weapon)
					if (weapon_launch_type[has_weapon[owner]] == 2)
						set_task(0.5,"start_reload_launcher", owner + reload_type_2)
					nade_reload[owner] = true
				}	
			}
		}
		//else if (weapon_special_mode[has_weapon[owner]] == 10)
		//	SendWeaponAnim(owner, weapon_draw)
	}
}

public task_active(ent)
	if (pev_valid(ent))
		set_pev(ent, pev_iuser4, rready)

public task_rnormal_active(ent)
	if (pev_valid(ent))
		set_pev(ent, pev_iuser4, normal_ready)

public show_laser(taskid)
{
	new id = taskid - 5230
	if (is_user_alive(id) && in_zoom[id] == true && has_weapon[id] >= 0 && weapon_special_mode[has_weapon[id]] == 4)
	{
		new origin[3]
		message_begin(MSG_ALL, SVC_TEMPENTITY)
		get_user_origin(id, origin, 3)
		write_byte(TE_SPRITE)
		write_coord(origin[0])
		write_coord(origin[1])
		write_coord(origin[2])
		write_short(laser) 
		write_byte(1) 
		write_byte(200)
		message_end()
	}
	else remove_task(taskid)
}
public start_action(taskid)
{
	new id = taskid - start_launcher
	new weaponname[32]
	get_weaponname(weapon_change[has_weapon[id]], weaponname, 31)
	new ent = find_ent_by_owner(-1, weaponname, id)
	// in_launcher[id] = true
	engclient_cmd(id, riffle_name[get_model(weapon_change[has_weapon[id]])])
	emessage_begin(MSG_ONE_UNRELIABLE, get_user_msgid("CurWeapon"), _, id)
	ewrite_byte(1) // active
	ewrite_byte(weapon_change[has_weapon[id]]) // weapon
	ewrite_byte(cs_get_weapon_ammo(ent)) // clip
	emessage_end()
	set_pev(id, pev_viewmodel2, weapon_launching_nade[has_weapon[id]])
	set_pev(id, pev_viewmodel2, weapon_launching_nade[has_weapon[id]])
	reload_without_ammo(id)
	set_task(0.5, "start_reload_launcher", id + reload_type_2)
}

public end_action(taskid)
{
	new id = taskid + start_launcher
	new weaponname[32]
	get_weaponname(weapon_change[has_weapon[id]], weaponname, 31)
	new ent = find_ent_by_owner(-1, weaponname, id)
	engclient_cmd(id, riffle_name[get_model(weapon_change[has_weapon[id]])])
	emessage_begin(MSG_ONE_UNRELIABLE, get_user_msgid("CurWeapon"), _, id)
	ewrite_byte(1) // active
	ewrite_byte(weapon_change[has_weapon[id]]) // weapon
	ewrite_byte(cs_get_weapon_ammo(ent)) // clip
	emessage_end()
	set_pev(id, pev_viewmodel2, weapon_v_model[has_weapon[id]])
	SendWeaponAnim(id, 0)
}

stock buy_weapon(id, weaponid)
{ 
	if (!is_user_alive(id))
		return 
	if (weaponid > g_weapon_count || weaponid < 0)
		return 
	if (!(cs_get_user_mapzones(id) & CS_MAPZONE_BUY))
	{
		client_print(id, print_center, "you can only buy weapon in your BUY ZONE ")
		return 
	}
	if (cod_get_user_level(id) < weapon_level[weaponid])
	{
		client_print(id, print_center, "You have to reach LEVEL %d to equip %s", weapon_level[weaponid], weapon_name[weaponid])
		return 
	}
	new money = cs_get_user_money(id)
	if (money >= weapon_cost[weaponid])
	{
		new weapon_give[256]
		primary_wpn_drop(id)
		in_touch[id] = true
		get_weaponname(weapon_change[weaponid], weapon_give, 255)
		new ent = fm_give_item(id, weapon_give)
		set_ability(weaponid, ent, id)
		if (weapon_special_mode[weaponid] != 10)
			cs_set_weapon_ammo(ent, weapon_clip[weaponid])
		cs_set_user_money(id, money - weapon_cost[weaponid], 1)
		client_print(id, print_center, "[G4U MSG] Ban da trang bi %s", weapon_name[weaponid])
		ExecuteForward(g_weapon, g_result, id, weaponid)
		if (weapon_special_mode[weaponid] == 2 || weapon_special_mode[weaponid] == 3)
			nade_clip[id][weaponid] = 1
		has_weapon[id] = weaponid
		ExecuteForward(g_ReceivedRifle, g_result, id, 1, weaponid)
		in_touch[id] = false
	}
	else client_print(id, print_center, "[G4U MSG] Ban khong du tien de trang bi %s", weapon_name[weaponid])
}

stock primary_wpn_drop(index)
{
	new weapons[32], num, Weapon
	get_user_weapons(index, weapons, num)
	
	for (new i = 0; i < num; i++) 
	{
		Weapon = weapons[i]
		
		if (PRIMARY_WEAPONS_BITSUM & (1<<Weapon))
		{
			static wname[32]
			get_weaponname(Weapon, wname, sizeof wname - 1)
			engclient_cmd(index, "drop", wname)
		}
		if (cs_get_user_shield(index))
			engclient_cmd(index, "drop", "weapon_shield")
	}
}

stock primary_wpn_strip(index)
{
	new weapons[32], num, Weapon
	get_user_weapons(index, weapons, num)
	
	for (new i = 0; i < num; i++) 
	{
		Weapon = weapons[i]
		
		if (PRIMARY_WEAPONS_BITSUM & (1<<Weapon))
		{
			static wname[32]
			get_weaponname(Weapon, wname, sizeof wname - 1)
			//engclient_cmd(index, "drop", wname)
			ham_strip_weapon(index, wname)
		}
		if (cs_get_user_shield(index))
			ham_strip_weapon(index, "weapon_shield")
	}
}
			
stock fm_give_item(index, const item[]) {
	if (!equal(item, "weapon_", 7) && !equal(item, "ammo_", 5) && !equal(item, "item_", 5) && !equal(item, "tf_weapon_", 10))
		return 0;

	new ent = fm_create_entity(item)
	if (!pev_valid(ent))
		return 0;

	new Float:origin[3];
	pev(index, pev_origin, origin);
	set_pev(ent, pev_origin, origin);
	set_pev(ent, pev_spawnflags, pev(ent, pev_spawnflags) | SF_NORESPAWN);
	dllfunc(DLLFunc_Spawn, ent);

	new save = pev(ent, pev_solid);
	dllfunc(DLLFunc_Touch, ent, index);
	if (pev(ent, pev_solid) != save)
		return ent;

	engfunc(EngFunc_RemoveEntity, ent);

	return -1;
}

stock fm_create_entity(const classname[])
	return engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, classname))

stock fm_find_ent_by_owner(index, const classname[], owner, jghgtype = 0) {
	new strtype[11] = "classname", ent = index;
	switch (jghgtype) {
		case 1: strtype = "target";
		case 2: strtype = "targetname";
	}

	while ((ent = engfunc(EngFunc_FindEntityByString, ent, strtype, classname)) && pev(ent, pev_owner) != owner) {}

	return ent;
}

stock get_model(weaponchange)
{
	if (weaponchange == CSW_MP5NAVY)
		return 0
	if (weaponchange == CSW_TMP)
		return 1
	if (weaponchange == CSW_UMP45)
		return 2
	if (weaponchange == CSW_P90)
		return 3
	if (weaponchange == CSW_MAC10)
		return 4
	if (weaponchange == CSW_FAMAS)
		return 5
	if (weaponchange == CSW_SCOUT)
		return 6
	if (weaponchange == CSW_GALIL)
		return 7
	if (weaponchange == CSW_M4A1)
		return 8
	if (weaponchange == CSW_AUG)
		return 9
	if (weaponchange == CSW_SG550)
		return 10
	if (weaponchange == CSW_G3SG1)
		return 11
	if (weaponchange == CSW_SG552)
		return 12
	if (weaponchange == CSW_AK47)
		return 13
	if (weaponchange == CSW_M249)
		return 14
	if (weaponchange == CSW_AWP)
		return 15
	return -1
}
			
stock fm_remove_entity_name(const classname[]) {
	new ent = -1, num = 0;
	while ((ent = fm_find_ent_by_class(ent, classname)))
		num += fm_remove_entity(ent);

	return num;
}

stock str_count(const str[], searchchar)
{
	new count, i
	//count = 0
	
	for (i = 0; i <= strlen(str); i++)
	{
		if(str[i] == searchchar)
			count++
	}
	
	return count;
}

stock fm_find_ent_by_class(index, const classname[])
	return engfunc(EngFunc_FindEntityByString, index, "classname", classname) 

stock fm_remove_entity(index)
	return engfunc(EngFunc_RemoveEntity, index)

stock fm_set_user_origin(index, origin[3]) {
	new Float:orig[3];
	IVecFVec(origin, orig);
	return fm_entity_set_origin(index, orig)
}

stock fm_entity_set_origin(index, const Float:origin[3]) {
	new Float:mins[3], Float:maxs[3];
	pev(index, pev_mins, mins);
	pev(index, pev_maxs, maxs);
	engfunc(EngFunc_SetSize, index, mins, maxs);
	return engfunc(EngFunc_SetOrigin, index, origin);
}

stock SendWeaponAnim(id, iAnim)
{
	set_pev(id, pev_weaponanim, iAnim)
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, _, id)
	write_byte(iAnim)
	write_byte(pev(id, pev_body))
	message_end()
	ExecuteForward(g_animation, g_result, id, iAnim)
}

stock show_weapon_now(id, page)
{
	new start = page * 7
	new end = (page * 7) + 7
	static menu[8192], len
	len = 0
	new count = 1
	if (end > g_weapon_count)
		end = g_weapon_count
	len += formatex(menu[len], sizeof menu - 1 - len, "\y[G4U SHOP - RIFFLE, SUBMACHINE, MACHINE GUN]^n")
	for (new i = start; i < end; i++)
	{
		//new level_name[256]
		//g4u_get_level_name(weapon_level[i], level_name, 255)
		len += formatex(menu[len], sizeof menu - 1 - len, "^n\w%d. \r%s \w[MONEY] %d \w[LEVEL]: %d", count, weapon_name[i], weapon_cost[i], weapon_level[i])
		count++
	}
	len += formatex(menu[len], sizeof menu - 1 - len, "^n^n\y8.Back^n\w9.Next^n\r0.Exit")
	show_menu(id, riffles, menu, -1, "[PRIMARY WEAPON LIST]")
}

stock fm_set_rendering(entity, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 16) {
	new Float:RenderColor[3];
	RenderColor[0] = float(r);
	RenderColor[1] = float(g);
	RenderColor[2] = float(b);

	set_pev(entity, pev_renderfx, fx);
	set_pev(entity, pev_rendercolor, RenderColor);
	set_pev(entity, pev_rendermode, render);
	set_pev(entity, pev_renderamt, float(amount));

	return 1;
}

stock damage_calculate(type,ent, Float:range, Float:damage_player, Float:damage_hostage, Float:damage_entity, const hud[], sprite_index)
{
	static Float:vOrigin[3], Float:origin[3], Float:fDistance, Float:fTmpDmg;
	new players[32], number
	new owner = pev(ent, pev_owner)
	pev(ent, pev_origin, origin)
	get_players(players, number, "agh")
	//new weaponent = fm_find_ent_by_owner(-1, riffle_name[get_model(weapon_change[has_weapon[owner]])], owner)
	if (type == 1)
	{
		for(new i = 0 ; i <= number ; i++)
		{
			new victim = players[i]
			if(!is_user_alive(victim))
				continue
			if (!get_cvar_num("mp_friendlyfire"))
				if (get_user_team(owner) == get_user_team(victim))
					continue
			pev(victim, pev_origin, vOrigin)
			fDistance = vector_distance(origin, vOrigin)
			if(fDistance <= range)
			{
				fTmpDmg = damage_player - ((damage_player / range) * fDistance)
				if (fTmpDmg > damage_player)
					fTmpDmg = damage_player
				if (fTmpDmg < 0.0)
					fTmpDmg = 0.0
				ExecuteHamB(Ham_TakeDamage, victim, ent, owner, fTmpDmg, (1<<24))
				// fakedamage(victim, hud , fTmpDmg, DMG_BLAST)
				//if (g4u_get_user_zombie(victim))
				//	make_knockback(victim, vOrigin, weapon_knockback[has_weapon[owner]] * fTmpDmg)
				if (!is_user_alive(victim))
				{
					if (get_user_team(victim) == get_user_team(owner))
					{
						UpdateFrags(owner, victim, 2, 1, 1)
					}
					make_deathmsg(owner, victim, 0, hud)
					ExecuteForward(launcher_nade_kill, g_result, victim, owner)
				}
			}
		}
		for (new j = 0; j < entity_count(); j++)
		{
			if (!pev_valid(j))
				continue
			new classname[32]
			pev(j, pev_classname, classname, 31)
			if (equal(classname, "hostage_entity") || equal(classname, "monster_scientist"))
			{
				new Float:fHealth
				pev(j, pev_health, fHealth)
				if (fHealth <= 0.0)
					continue
				pev(j, pev_origin, vOrigin)
				fDistance = vector_distance(origin, vOrigin)
				if(fDistance <= range)
				{
					fTmpDmg = damage_hostage - (damage_hostage / range) * fDistance;
					ExecuteHamB(Ham_TakeDamage, j, hud, owner, fTmpDmg, (1<<24))
					//fakedamage(j, "grenade", fTmpDmg, DMG_BLAST)
				
				}
			}
			if (equal(classname, "func_breakable") || equal(classname, "func_pushable") || equal(classname, "npc_"))
			{
				pev(j, pev_origin, vOrigin);
				fDistance = vector_distance(origin, vOrigin)
				if(fDistance <= range)
				{
					fTmpDmg = damage_entity - (damage_entity / range) * fDistance;
					//ExecuteHamB(Ham_TakeDamage, j, weaponent, owner, fTmpDmg, DMG_BLAST)
					fakedamage(j, hud, fTmpDmg, DMG_BLAST)
				}
			}
		}
		if (range > 25.0)
		{
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(TE_EXPLOSION)
			write_coord(floatround(origin[0]))
			write_coord(floatround(origin[1]))
			write_coord(floatround(origin[2]))
			write_short(sprite_index)
			write_byte(weapon_SpriteScale[has_weapon[owner]])
			write_byte(frame[has_weapon[owner]]) 
			write_byte(4)
			message_end()
			emit_sound(ent, CHAN_AUTO, weapon_ExpSound[g_weapon_count], 1.0, ATTN_NORM, 0, PITCH_HIGH)
		}
		remove_entity(ent)
	}
	if (type == 2)
	{
		for(new i = 0 ; i <= number ; i++)
		{
			new victim = players[i]
			if(!is_user_alive(victim))
				continue
			pev(victim, pev_origin, vOrigin)
			fDistance = vector_distance(origin, vOrigin)
			if(fDistance <= range)
				ScreenBlind(victim, 255, floatround(weapon_nade_delay[has_weapon[owner]]))
		}
		remove_entity(ent)
	}
}

stock DmgCalculate(id, ent, Float:fOrigin[3], Float:range, Float:damage_player, Float:damage_hostage, Float:damage_entity)
{
	static Float:vOrigin[3], Float:fDistance, Float:fTmpDmg;
	new players[32], number
	get_players(players, number, "agh")
	for(new i = 0 ; i <= number ; i++)
	{
		new victim = players[i]
		if(!is_user_alive(victim))
			continue
		pev(victim, pev_origin, vOrigin)
		fDistance = vector_distance(fOrigin, vOrigin)
		if(fDistance <= range)
		{
			fTmpDmg = damage_player - ((damage_player / range) * fDistance)
			if (fTmpDmg > damage_player)
				fTmpDmg = damage_player
			if (fTmpDmg < 0.0)
				fTmpDmg = 0.0
			if (!get_cvar_num("mp_friendlyfire") && get_user_team(id) == get_user_team(victim))
				continue
			ExecuteHamB(Ham_TakeDamage, victim, ent, id, fTmpDmg, (1<<24))
		}
	}
	for (new j = 0; j < entity_count(); j++)
	{
		if (!pev_valid(j))
			continue
		new classname[32]
		pev(j, pev_classname, classname, 31)
		if (equal(classname, "hostage_entity") || equal(classname, "monster_scientist"))
		{
			pev(j, pev_origin, vOrigin);
			fDistance = vector_distance(fOrigin, vOrigin)
			if(fDistance <= range)
			{
				fTmpDmg = damage_hostage - (damage_hostage / range) * fDistance;
				new cWeaponName[32]
				pev(ent, pev_classname, cWeaponName, 31)
				ExecuteHamB(Ham_TakeDamage, j, cWeaponName, id, fTmpDmg, (1<<24))
				//fakedamage(j, "grenade", fTmpDmg, DMG_BLAST)
			
			}
		}
		if (equal(classname, "func_breakable") || equal(classname, "func_pushable") || equal(classname, "npc_"))
		{
			pev(j, pev_origin, vOrigin);
			fDistance = vector_distance(fOrigin, vOrigin)
			if(fDistance <= range)
			{
				fTmpDmg = damage_entity - (damage_entity / range) * fDistance;
				//ExecuteHamB(Ham_TakeDamage, j, weaponent, owner, fTmpDmg, DMG_BLAST)
				new cWeaponName[32]
				pev(ent, pev_classname, cWeaponName, 31)
				ExecuteHamB(Ham_TakeDamage, j, cWeaponName, id, fTmpDmg, (1<<24))
			}
		}
	}
}



stock FixDeadAttrib(id)
{
	message_begin(MSG_BROADCAST, get_user_msgid("ScoreAttrib"))
	write_byte(id) // id
	write_byte(0) // attrib
	message_end()
}

stock UpdateFrags(attacker, victim, frags, deaths, scoreboard)
{
	set_pev(attacker, pev_frags, float(pev(attacker, pev_frags) + frags))
	cs_set_user_deaths(victim, cs_get_user_deaths(victim) + deaths)
	if (scoreboard)
	{
		message_begin(MSG_BROADCAST, get_user_msgid("ScoreInfo"))
		write_byte(attacker) // id
		write_short(pev(attacker, pev_frags)) // frags
		write_short(cs_get_user_deaths(attacker)) // deaths
		write_short(0) // class?
		write_short(get_user_team(attacker)) // team
		message_end()
		message_begin(MSG_BROADCAST, get_user_msgid("ScoreInfo"))
		write_byte(victim) // id
		write_short(pev(victim, pev_frags)) // frags
		write_short(cs_get_user_deaths(victim)) // deaths
		write_short(0) // class?
		write_short(get_user_team(victim)) // team
		message_end()
	}
}

stock bool:fm_is_visible(index, const Float:point[3], ignoremonsters = 0) {
	new Float:start[3], Float:view_ofs[3];
	pev(index, pev_origin, start);
	pev(index, pev_view_ofs, view_ofs);
	xs_vec_add(start, view_ofs, start);

	engfunc(EngFunc_TraceLine, start, point, ignoremonsters, index, 0);

	new Float:fraction;
	get_tr2(0, TR_flFraction, fraction);
	if (fraction == 1.0)
		return true;

	return false;
}

stock ScreenBlind(id,iAmount, second) 
{
	emessage_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenFade"), _, id)
	ewrite_short((1<<12)*second) // duration
	ewrite_short((1<<12)*second) // hold time
	ewrite_short(0x0000) // fade type
	ewrite_byte(255) // red
	ewrite_byte(255) // green
	ewrite_byte(255) // blue
	ewrite_byte(iAmount) // alpha
	emessage_end()
}

stock create_little_smoke( x, y, z, sprite_index, frame, radius)
{
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY) 
	write_byte(3) 
	write_coord(x)	// start position
	write_coord(y)
	write_coord(z)
	write_short(sprite_index) 
	write_byte(radius)		// byte (scale in 0.1's) 188 
	write_byte(frame)		// byte (framerate) 
	write_byte(14)		// byte flags 
	message_end()
}

stock ham_strip_weapon(id,weapon[])
{
	if(!equal(weapon,"weapon_",7)) return 0;
	
	new wId = get_weaponid(weapon);
	if(!wId) return 0;
	
	new wEnt;
	while((wEnt = engfunc(EngFunc_FindEntityByString, wEnt, "classname", weapon)) && pev(wEnt, pev_owner) != id) {}
	if(!wEnt) return 0;
	
	new iTmp;
	if(get_user_weapon(id, iTmp, iTmp) == wId) ExecuteHamB(Ham_Weapon_RetireWeapon, wEnt);
	
	if(!ExecuteHamB(Ham_RemovePlayerItem, id, any:wEnt)) return 0;
	
	ExecuteHamB(Ham_Item_Kill, wEnt);
	set_pev(id, pev_weapons, pev(id, pev_weapons) & ~(1<<wId));
	
	return 1;
}

stock check_prim(id)
{
	for (new i = 0; i < sizeof riffle_name; i++)
	{
		new wid = get_weaponid(riffle_name[i])
		if (user_has_weapon(id, wid))
			return i
	}
	return -1
}

stock show_trail(ent, red, green, blue)
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMFOLLOW) // TE id
	write_short(ent) // entity
	write_short(g_trailSpr) // sprite
	write_byte(10) // life
	write_byte(10) // width
	write_byte(red) // r
	write_byte(green) // g
	write_byte(blue) // b
	write_byte(100) // brightness
	message_end()
}

stock set_ability(weaponid, ent, id)
{
	if (weapon_silencer[weaponid] == 1 && weapon_special_mode[weaponid] != 5 && weapon_special_mode[has_weapon[id]] != 11)
	{
		if (weapon_change[weaponid] == CSW_M4A1)
		{
			cs_set_weapon_silen(ent, 1, 0)
			if (get_user_weapon(id) == CSW_M4A1)
				SendWeaponAnim(id, 0)
		}
		if (weapon_change[weaponid] == CSW_FAMAS)
			cs_set_weapon_burst(ent, 1)
	}
}

stock reload_without_ammo(id)
{
	if (weapon_change[has_weapon[id]] == CSW_M4A1)
	{
		new ent = fm_find_ent_by_owner(-1, riffle_name[get_model(weapon_change[has_weapon[id]])], id)
		if (weapon_special_mode[has_weapon[id]] == 5 || weapon_special_mode[has_weapon[id]] == 11)
		{
			if (!in_zoom[id])
				SendWeaponAnim(id, 7)
			else SendWeaponAnim(id, 0)
		}
		else
		{
			if (cs_get_weapon_silen(ent))
				SendWeaponAnim(id, 0)
			if (!cs_get_weapon_silen(ent))
				SendWeaponAnim(id, 7)
		}
	}
	else SendWeaponAnim(id, 0)
}

stock launch_grenade(id, weaponid)
{
	new Float:fOrigin[3], Float:fAngle[3], Float:fVelocity[3], ipOrigin[3]
	get_user_origin(id, ipOrigin, 1)
	IVecFVec(ipOrigin, fOrigin)
	pev(id, pev_v_angle, fAngle)
	new weaponname1[32]
	get_weaponname(weapon_change[weaponid], weaponname1, 31)
	new weaponent = find_ent_by_owner(-1, weaponname1, id)
	new modelindex = get_model(weapon_change[weaponid])
	if (weapon_launch_type[weaponid] == 1)
		SendWeaponAnim(id, anim_launch)
	if (weapon_launch_type[weaponid] == 2)
	{
		if (user_nade[id][weaponid] > 0) // Plays random animation 
		{
			if (weapon_change[has_weapon[id]] == CSW_M4A1)
			{
				if(cs_get_weapon_silen(weaponent))
					SendWeaponAnim(id, rifle_shoot_animation[random(2)][modelindex] - 7 )
				else	SendWeaponAnim(id, rifle_shoot_animation[random(2)][modelindex])
			}
			else	SendWeaponAnim(id, rifle_shoot_animation[random(2)][modelindex])
		}
		else
		{
			// Plays last-shot animation
			if (weapon_change[has_weapon[id]] == CSW_M4A1)
			{
				if(cs_get_weapon_silen(weaponent))
					SendWeaponAnim(id, rifle_shoot_animation[2][modelindex] - 7 + 3)
				else	SendWeaponAnim(id, rifle_shoot_animation[2][modelindex] + 3)
			}
			else	SendWeaponAnim(id, rifle_shoot_animation[2][modelindex] + 3)
		}
	}
	// New ent
	new ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	// Not ent
	if (!ent) return FMRES_IGNORED
	cs_set_user_zoom(id, CS_RESET_ZOOM, 0)
	in_zoom[id] =  false
	if (weapon_nade_type[weaponid] == 1)
	{
		set_pev(ent, pev_classname, "child_grenade")
		set_pev(ent, pev_nextthink, get_gametime() + 0.25)
	}
	if (weapon_nade_type[weaponid] == 2)
		set_pev(ent, pev_classname, "flash_nade")
	if (weapon_nade_type[weaponid] == 3)
	{
		set_pev(ent, pev_classname, "smoke_nade")
		set_pev(ent, pev_iuser1, 30)
		set_pev(ent, pev_nextthink, get_gametime() + 1.5)
	}
	if (3 < weapon_nade_type[weaponid] < max_nade_type)
	{
		set_pev(ent, pev_classname, "other_class_nade")
		set_pev(ent, pev_nextthink, get_gametime() + 1.5)
		set_pev(ent, pev_iuser1, 0)
		set_pev(ent, pev_iuser2, weapon_nade_type[weaponid])
	}
	set_pev(ent, pev_iuser3, weaponid)
	new active[3], trail[3], red[3], green[3], blue[3]
	new iactive, itrail, ired, igreen, iblue
	parse(weapon_nade_rendering[has_weapon[id]], active, 2, trail, 2, red, 2, green, 2, blue, 2)
	iactive = str_to_num(active)
	itrail = str_to_num(trail)
	ired = str_to_num(red)
	igreen = str_to_num(green)
	iblue = str_to_num(blue)
	if (iactive > 0)
		fm_set_rendering(ent, kRenderFxGlowShell, ired, igreen, iblue, kRenderTransAlpha, 16)
	if (iactive < 0)
		set_pev(ent, pev_effects, 128)
	if (itrail > 0)
		show_trail(ent, ired, igreen, iblue)
	new Float:push[3], Float:pangles[3], Float:angles[3]
	pev(id, pev_punchangle, pangles)
	angles[0] = pangles[0] + random_float(0.0, 0.0)
	angles[1] = pangles[1] + random_float(-3.0, 3.0)
	angles[2] = pangles[2] + random_float(0.0, 0.0)
	pev(id,pev_punchangle,push)
	xs_vec_sub(push,angles,push)
	xs_vec_mul_scalar(push,random_float(1.2, 1.5),push)
	xs_vec_add(push,cl_pushangle[id],push)
	set_pev(id,pev_punchangle,push)
	//set_pev(id, pev_punchangle, {12.0,6.0,0.0})
	entity_set_model(ent, weapon_w_nade_model[has_weapon[id]])
	if (weapon_nadePretype[has_weapon[id]] > 0)
		set_pev(ent, pev_body, weapon_nadeSub[has_weapon[id]])
	emit_sound(id, CHAN_ITEM, "weapons/glauncher.wav", 0.3, ATTN_NORM, 0, PITCH_NORM)
	entity_set_origin(ent, fOrigin)
	entity_set_vector(ent, EV_VEC_angles, fAngle)
	new Float:MinBox[3] = {-1.0, -1.0, -1.0}
	new Float:MaxBox[3] = {1.0, 1.0, 1.0}
	entity_set_vector(ent, EV_VEC_mins, MinBox)
	entity_set_vector(ent, EV_VEC_maxs, MaxBox)
	set_pev(ent, pev_solid, SOLID_TRIGGER ) 
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_BOUNCE)
	set_pev(ent, pev_gravity, 0.5)
	entity_set_edict(ent, EV_ENT_owner, id)
	VelocityByAim(id, 2000, fVelocity)
	entity_set_vector(ent, EV_VEC_velocity, fVelocity)
	set_pev(ent, pev_owner, id)
	time_delay[id] = get_gametime()
	nade_clip[id][has_weapon[id]] = 0
	nade_reload[id] = true
	if (user_nade[id][has_weapon[id]] > 0)
	{
		if (weapon_launch_type[weaponid] == 1)
			set_task(0.7, "reload_my_launcher", id + reload_my_weapon)
		if (weapon_launch_type[weaponid] == 2)
			set_task(weapon_nade_reload_time[has_weapon[id]], "active_launcher", id + active_my_grenade)
	}
	return FMRES_IGNORED
}

public reload_my_launcher(taskid)
{
	new id = taskid - reload_my_weapon
	new ent = fm_find_ent_by_owner(-1, riffle_name[get_model(weapon_change[has_weapon[id]])], id)
	new fInReload = get_pdata_int(ent, m_fInReload, 4)
	if (!is_user_alive(id) || has_weapon[id] < 0 || !in_launcher[id] || user_nade[id][has_weapon[id]] < 1 || !nade_reload[id] || fInReload || nade_clip[id][has_weapon[id]] > 0)
		return 
	set_task(weapon_nade_reload_time[has_weapon[id]], "active_launcher", id + active_my_grenade)
	SendWeaponAnim(id, anim_reload)
	set_pev(id, pev_sequence, anim_reload)
	client_cmd(id, "spk weapons/greload.wav")
}

public active_launcher(taskid)
{
	new id = taskid - active_my_grenade
	new ent = fm_find_ent_by_owner(-1, riffle_name[get_model(weapon_change[has_weapon[id]])], id)
	new fInReload = get_pdata_int(ent, m_fInReload, 4)
	if (!is_user_alive(id) || has_weapon[id] < 0 || !in_launcher[id] || user_nade[id][has_weapon[id]] < 1 || !nade_reload[id] || fInReload || nade_clip[id][has_weapon[id]] > 0)
		return 
	nade_clip[id][has_weapon[id]] = 1
	user_nade[id][has_weapon[id]]--
	nade_reload[id] = false
	zoom_delay[id] = get_gametime()
	time_delay[id] = get_gametime()
}

public start_reload_launcher(taskid)
{
	new id = taskid - reload_type_2
	new ent = fm_find_ent_by_owner(-1, riffle_name[get_model(weapon_change[has_weapon[id]])], id)
	new fInReload = get_pdata_int(ent, m_fInReload, 4)
	if (!is_user_alive(id) || has_weapon[id] < 0 || !in_launcher[id] || user_nade[id][has_weapon[id]] < 1 || !nade_reload[id] || fInReload || nade_clip[id][has_weapon[id]] > 0)
		return
	new wid = get_user_weapon(id)
	if (wid == CSW_M4A1)
	{
		if (cs_get_weapon_silen(ent))
			SendWeaponAnim(id, reload_animation[wid] - 7)
		else 	SendWeaponAnim(id, reload_animation[wid])
	}
	else	SendWeaponAnim(id, reload_animation[wid])
	client_cmd(id, "spk weapons/greload.wav")
	set_task(weapon_nade_reload_time[has_weapon[id]], "active_launcher", id + active_my_grenade)
}
	
	
stock reset_nade(id)
	for (new i = 0; i < g_weapon_count; i++)
		user_nade[id][i] = 0
		
stock hide_cross(id)
{
	emessage_begin(MSG_ONE_UNRELIABLE, get_user_msgid("HideWeapon"), _, id)
	ewrite_byte(1<<6)
	emessage_end()
}

stock draw_cross(id)
{
	// Show Counter strike crosshair
	emessage_begin(MSG_ONE_UNRELIABLE, get_user_msgid("HideWeapon"), _, id)
	ewrite_byte(HUD_DRAW_CROSS)
	emessage_end()
	// Hide Half Life crosshar
	emessage_begin(MSG_ONE_UNRELIABLE, get_user_msgid("Crosshair"), _, id)
	ewrite_byte(0)
	emessage_end()
}

stock play_newsound(id, ent, clip, ammo)
{
	if(has_weapon[id] > -1 && get_user_weapon(id, clip, ammo) == weapon_change[has_weapon[id]])
	{
		if (weapon_special_mode[has_weapon[id]] != 5 && !cs_get_weapon_silen(ent) || weapon_special_mode[has_weapon[id]] == 5)
		{
			if (clip > 0)
			{
				ExecuteHamB(Ham_Weapon_PlayEmptySound, ent)
				emit_sound(id, CHAN_AUTO, weapon_sound[has_weapon[id]], 1.0, ATTN_NORM, 0, PITCH_NORM)
			}
		}
	}
}

stock testbulet(id, const hud[], Float:damage, Float:distance)
{
	// Find target
	new Float:ftorigin[3]
	new Float:faimOrigin[3]
	new aimOrigin[3], target, body
	get_user_origin(id, aimOrigin, 0)
	get_user_aiming(id, target, body)
	new ItOrigin[3]
	get_user_origin(id, ItOrigin, 3)
	IVecFVec(ItOrigin, ftorigin)
	IVecFVec(aimOrigin, faimOrigin)
	new hitplace
	new weaponname[32]
	get_weaponname(weapon_change[has_weapon[id]], weaponname, 31)
	new ent = find_ent_by_owner(-1, weaponname, id)
	if(target > 0 && target <= get_maxplayers())
	{	
		new Float:range = vector_distance(faimOrigin, ftorigin)
		if (range <= distance)
		{
			if (body != 8)
			{
				if (!get_cvar_num("mp_friendlyfire"))
					if (get_user_team(id) == get_user_team(target))
						return
				new tr_result
				engfunc(EngFunc_TraceLine, faimOrigin, ftorigin, DONT_IGNORE_MONSTERS, id, tr_result)
				new Float:fTmpDmg = damage - (damage / distance) * range
				ExecuteHamB(Ham_TakeDamage, target, ent, id, fTmpDmg, DMG_SLASH)
				//fakedamage(target, "", damage , DMG_BULLET)
				body = get_tr2(tr_result, TR_iHitgroup)
				if (body == HIT_HEAD)
					hitplace = 1
				if (body != HIT_HEAD)
					hitplace = 0
				new random_sound = random_num(1, 4)
				new random_file[256]
				format(random_file, 255, "weapons/knife_hit%d.wav", random_sound)
				emit_sound(target, CHAN_AUTO, random_file, 1.0, ATTN_NORM, 0, PITCH_NORM)
				if (!is_user_alive(target))
				{
					ExecuteForward(g_knife_kill, g_result, target, id, hitplace)
				}
				//if (!is_user_alive(target))
				//{
				//	new victim = target
				//	new owner = id
				//	if (get_user_team(victim) == get_user_team(owner))
				//	{
				//		if (get_cvar_num("sgm_option/active"))
				//		{
				//			UpdateFrags(owner, victim, 1, 1, 1)
				//			cs_set_user_money(owner, cs_get_user_money(owner) + 300, 1)
				//		}
				//		else
				//		{
				//			FixDeadAttrib(owner)
				//			UpdateFrags(owner, victim, -1, 1, 1)
				//			cs_set_user_money(owner, cs_get_user_money(owner) - 3300, 1)
				//			client_print(0, print_chat, " #Cstrike_TitlesTXT_Game_teammate_attack")
				//		}
				//	}
				//	if (get_user_team(victim) != get_user_team(owner))
				//	{
				//		FixDeadAttrib(owner)
				//		UpdateFrags(owner, victim, 1, 1, 1)
				//		cs_set_user_money(owner, cs_get_user_money(owner) + 300, 1)
				//	}
				// 	make_deathmsg(id, victim, hitplace, hud)
				//}
				
			}
			else
			{
				new random_sound = random_num(1, 2)
				new random_file[256]
				format(random_file, 255, "weapons/ric_metal-%d.wav", random_sound)
				emit_sound(target, CHAN_AUTO, random_file, 1.0, ATTN_NORM, 0, PITCH_NORM)
			}
		} 
	}
	else 
	{
		if(target)
		{
			new Float:range = vector_distance(faimOrigin, ftorigin)
			if (range <= distance)
			{
				new classname[32]
				pev(target, pev_classname, classname, 31)
				if (equal(classname, "hostage_entity", 14) || equal(classname, "monster_scientist", 17))
				{
					new Float:hdamage = random_float(damage, damage * 1.5)
					fakedamage(target, hud, hdamage , DMG_BLAST)
					new health = pev(target, pev_health)
					if (pev(target, pev_iuser1) < 1)
					{
						if (float(health) - hdamage > 0.0 )
						{
							client_print(id, print_center, "#Injured_Hostage")
							cs_set_user_money(id, cs_get_user_money(id) - 300, 1)
						}
						else
						{
							client_print(id, print_center, "#Killed_Hostage")
							cs_set_user_money(id, cs_get_user_money(id) - 3300, 1)
							cs_set_user_hostagekills(id, cs_get_user_hostagekills(id) + 1)
							set_pev(target, pev_iuser1, 1)
						}
					}
					//ExecuteHamB(Ham_TakeDamage, target, ent, id, random_float(damage, damage * 1.5), DMG_SLASH)
				}
				if (equal(classname, "func_breakable", 14 ) || equal(classname, "func_pushable", 13))
				{
					new flags = pev(target, pev_spawnflags)
					if (flags != SF_BREAK_TRIGGER_ONLY)
						ExecuteHamB(Ham_TakeDamage, target, ent, id, random_float(damage, damage * 1.7), DMG_SLASH)
					//fakedamage(target, hud, random_float(damage, damage * 1.7) , DMG_SLASH)
					emit_sound(id, CHAN_AUTO, "weapons/knife_hitwall1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
				}
			} 
		}
		else 
		{
			new Float:range = vector_distance(faimOrigin, ftorigin)
			if (range <= distance)
				emit_sound(id, CHAN_AUTO, "weapons/knife_hitwall1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		}
	}
}

stock launch_missle(id, weaponid)
{
	new Float:fOrigin[3], Float:fAngle[3], Float:fVelocity[3], ipOrigin[3]
	get_user_origin(id, ipOrigin, 1)
	IVecFVec(ipOrigin, fOrigin)
	pev(id, pev_v_angle, fAngle)
	new ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	// Not ent
	if (!ent) return PLUGIN_HANDLED
	new weaponname[32]
	get_weaponname(weapon_change[weaponid], weaponname, 31)
	new iEnt = find_ent_by_owner(-1, weaponname, id)
	if (!iEnt)
		return PLUGIN_HANDLED
	//missle_clip[id][weaponid] = 0
	cs_set_user_zoom(id, CS_RESET_ZOOM, 0)
	eSetFOV(id, 90)
	in_zoom[id] =  false
	set_pev(ent, pev_classname, "AirMissle")
	set_pev(ent, pev_iuser3, weaponid)
	new active[3], trail[3], red[3], green[3], blue[3]
	new iactive, itrail, ired, igreen, iblue
	parse(weapon_nade_rendering[has_weapon[id]], active, 2, trail, 2, red, 2, green, 2, blue, 2)
	iactive = str_to_num(active)
	itrail = str_to_num(trail)
	ired = str_to_num(red)
	igreen = str_to_num(green)
	iblue = str_to_num(blue)
	if (iactive > 0)
		fm_set_rendering(ent, kRenderFxGlowShell, ired, igreen, iblue, kRenderTransAlpha, 16)
	if (iactive < 0)
		set_pev(ent, pev_effects, 128)
	if (itrail > 0)
		show_trail(ent, ired, igreen, iblue)
		
	new iCheckPrimary = check_prim(id)
	if (!cs_get_weapon_silen(iEnt))
		SendWeaponAnim(id, weapon_shoot_animation[iCheckPrimary])
	else	SendWeaponAnim(id, weapon_shoot_animation[iCheckPrimary] - 7)
	new Float:push[3], Float:pangles[3], Float:angles[3]
	pev(id, pev_punchangle, pangles)
	angles[0] = pangles[0] + random_float(0.0, 0.0)
	angles[1] = pangles[1] + random_float(-3.0, 3.0)
	angles[2] = pangles[2] + random_float(0.0, 0.0)
	pev(id,pev_punchangle,push)
	xs_vec_sub(push,angles,push)
	xs_vec_mul_scalar(push, _get_recoil(id, has_weapon[id], 1),push)
	xs_vec_add(push,cl_pushangle[id],push)
	set_pev(id,pev_punchangle,push)
	//set_pev(id, pev_punchangle, {12.0,6.0,0.0})
	entity_set_model(ent, weapon_w_nade_model[has_weapon[id]])
	if (weapon_nadePretype[has_weapon[id]] > 0)
		set_pev(ent, pev_body, weapon_nadeSub[has_weapon[id]])
	emit_sound(id, CHAN_AUTO, weapon_sound[weaponid], 1.0, ATTN_NORM, 0, PITCH_NORM)
	entity_set_origin(ent, fOrigin)
	pev(id, pev_angles, fAngle)
	entity_set_vector(ent, EV_VEC_angles, fAngle)
	new mAimOrigin[3], Float:fAimOrigin[3]
	get_user_origin(id, mAimOrigin, 3)
	IVecFVec(mAimOrigin, fAimOrigin)
	set_pev(ent , pev_vuser1, fAimOrigin)
	set_pev(ent, pev_effects, EF_LIGHT)
	new Float:MinBox[3] = {-1.0, -1.0, -1.0}
	new Float:MaxBox[3] = {1.0, 1.0, 1.0}
	entity_set_vector(ent, EV_VEC_mins, MinBox)
	entity_set_vector(ent, EV_VEC_maxs, MaxBox)
	set_pev(ent, pev_solid, SOLID_BBOX) 
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_FLYMISSILE)
	set_pev(ent, pev_gravity, 0.5)
	set_pev(ent, pev_owner, id)
	VelocityByAim(id, 1450, fVelocity)
	entity_set_vector(ent, EV_VEC_velocity, fVelocity)
	cs_set_weapon_ammo(iEnt, 0)
	set_pev(ent, pev_nextthink, get_gametime() + 5.0)
	///ExecuteHamB(Ham_Weapon_Reload, iEnt)
	//time_delay[id] = get_gametime()
	//time_delay[id] = get_gametime()
	return PLUGIN_HANDLED
}
	
stock DirectedVec(Float:start[3],Float:end[3],Float:reOri[3])
{
//-------code from Hydralisk's 'Admin Advantage'-------//	
	new Float:v3[3]
	v3[0]=start[0]-end[0]
	v3[1]=start[1]-end[1]
	v3[2]=start[2]-end[2]
	new Float:vl = vector_length(v3)
	reOri[0] = v3[0] / vl
	reOri[1] = v3[1] / vl
	reOri[2] = v3[2] / vl
}

stock set_bpammo(id, type, amount)
	cs_set_user_bpammo(id, type, amount)
	
stock make_knockback (Victim, Float:origin [3], Float:maxspeed )
{
	// Get and set velocity
	new Float:fVelocity[3];
	kickback (Victim, origin, maxspeed, fVelocity)
	entity_set_vector( Victim, EV_VEC_velocity, fVelocity);

	return (1);
}

// Extra calulation for knockback
stock kickback( ent, Float:fOrigin[3], Float:fSpeed, Float:fVelocity[3])
{
	// Find origin
	new Float:fEntOrigin[3];
	entity_get_vector( ent, EV_VEC_origin, fEntOrigin );

	// Do some calculations
	new Float:fDistance[3];
	fDistance[0] = fEntOrigin[0] - fOrigin[0];
	fDistance[1] = fEntOrigin[1] - fOrigin[1];
	fDistance[2] = fEntOrigin[2] - fOrigin[2];
	new Float:fTime = (vector_distance( fEntOrigin,fOrigin ) / fSpeed);
	fVelocity[0] = fDistance[0] / fTime;
	fVelocity[1] = fDistance[1] / fTime;
	fVelocity[2] = fDistance[2] / fTime;

	return (fVelocity[0] && fVelocity[1] && fVelocity[2]);
}

stock eSetFOV(id, FOV)
{
	emessage_begin(MSG_ONE_UNRELIABLE, iSetFOVMessage, _, id)
	ewrite_byte(FOV)
	emessage_end()
	if (FOV > 20)
		hide_dcross(id)
	if (FOV == 90)
		cs_set_user_zoom(id, CS_RESET_ZOOM, 0)
	set_pev(id, pev_fov, FOV)
}

stock SetFOV(id, FOV)
{
	message_begin(MSG_ONE_UNRELIABLE, iSetFOVMessage, _, id)
	write_byte(FOV)
	message_end()
	if (FOV > 20)
		hide_dcross(id)
	if (FOV == 90)
		cs_set_user_zoom(id, CS_RESET_ZOOM, 0)
	set_pev(id, pev_fov, FOV)
}
stock hide_dcross(id)
{
	message_begin(MSG_ONE_UNRELIABLE, iCrosshairMessage, _, id)
	write_byte(0)
	message_end()
	emessage_begin(MSG_ONE_UNRELIABLE, iCrosshairMessage, _, id)
	ewrite_byte(0)
	emessage_end()
}

stock Draw_DCross(id)
{
	message_begin(MSG_ONE_UNRELIABLE, iCrosshairMessage, _, id)
	write_byte(1)
	message_end()
	emessage_begin(MSG_ONE_UNRELIABLE, iCrosshairMessage, _, id)
	ewrite_byte(1)
	emessage_end()
}

stock check_special_mode(id)
{
	new  spec_mode = weapon_special_mode[has_weapon[id]]
	if (spec_mode == 1 || spec_mode == 4 || spec_mode == 5 || spec_mode == 6 || spec_mode == 13 ||spec_mode == 7 || spec_mode == 8 || spec_mode == 3 || spec_mode == 9 || spec_mode == 11 || spec_mode == 12)
		return 1
	return 0
}

stock make_tracer(id)
{
	new vec1[3], vec2[3]
	get_user_origin(id, vec2, 4)
	get_user_origin(id, vec1, 1) // origin; your camera point.
	message_begin( MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte (0)     //TE_BEAMENTPOINTS 0
	write_coord(vec1[0])
	write_coord(vec1[1])
	write_coord(vec1[2])
	write_coord(vec2[0])
	write_coord(vec2[1])
	write_coord(vec2[2])
	write_short(m_spriteTexture)
	write_byte(0)			// start frame
	write_byte(0)			// framerate
	write_byte(4)			// life in 0.1's
	write_byte(10)			// line width in 0.1's
	write_byte(0)			// noise amplitude in 0.01's
	write_byte(255)     // r, g, b
	write_byte(215)       // r, g, b
	write_byte(0)       // r, g, b
	write_byte(200) // brightness
	write_byte(250) // speed
	message_end()
}

stock get_weapon_backmodel(weapon)
{
	switch(weapon)
	{
		case CSW_SCOUT:	return MODEL_SCOUT   
		case CSW_FAMAS:	return MODEL_FAMAS
		case CSW_AK47:	return MODEL_AK47
		case CSW_AUG:	return MODEL_AUG
		case CSW_AWP:	return MODEL_AWM
		case CSW_G3SG1: return MODEL_G3SG1
		case CSW_GALIL:	return MODEL_GALIL
		case CSW_M3:	return MODEL_M3
		case CSW_M4A1:	return MODEL_M4A1
		case CSW_M249:	return MODEL_M249
		case CSW_SG552:	return MODEL_SG552
		case CSW_TMP:	return MODEL_TMP
		case CSW_UMP45:	return MODEL_UMP45
		case CSW_MAC10:	return MODEL_MAC10
		case CSW_MP5NAVY:	return MODEL_MP5NAVY
		case CSW_XM1014:	return MODEL_XM1014
		case CSW_P90:	return MODEL_P90
		case CSW_DEAGLE:	return MODEL_DEAGLE
		case CSW_ELITE:	return MODEL_ELITE
		case CSW_FIVESEVEN:	return MODEL_FIVESEVEN
		case CSW_USP:	return MODEL_USP
		case CSW_P228:	return MODEL_P228
		case CSW_GLOCK18:	return MODEL_GLOCK
		case CSW_HEGRENADE:	return MODEL_HEGRENADE
		case CSW_SMOKEGRENADE:	return MODEL_SMOKEGRENADE
		case CSW_FLASHBANG:	return MODEL_FLASHBANG
		case CSW_C4:	return MODEL_C4		
	}
	return 0
}

stock IsRifle(weaponid)
{
	if (weaponid == CSW_FAMAS)
		return 1
	if (weaponid == CSW_GALIL)
		return 1
	if (weaponid == CSW_AK47)
		return 1
	if (weaponid == CSW_SG552)
		return 1
	if (weaponid == CSW_M4A1)
		return 1
	if (weaponid == CSW_AUG)
		return 1
	if (weaponid == CSW_SCOUT)
		return 1
	if (weaponid == CSW_AWP)
		return 1
	if (weaponid == CSW_G3SG1)
		return 1
	if (weaponid == CSW_SG550)
		return 1
	return 0
}

stock IsSmg(weaponid)
{
	if (weaponid == CSW_MP5NAVY)
		return 1
	if (weaponid == CSW_TMP)
		return 1
	if (weaponid == CSW_P90)
		return 1
	if (weaponid == CSW_MAC10)
		return 1
	if (weaponid == CSW_UMP45)
		return 1
	return 0
}

stock update_hud_WeaponList(id, iCsWpnId, iCsWpnClip, WpnClass[], iMaxBp ,iSendMsg)
{
	new sWeaponName[128], iPriAmmoId, iPriAmmoMax, iSecAmmoId, iSecAmmoMax, iSlotId, iNumberInSlot, iWeaponId, iFlags
	format(sWeaponName, 127, "%s", WpnClass)    
	iPriAmmoId = CSWPN_AMMOID[iCsWpnId]
	iPriAmmoMax = iMaxBp
	iSecAmmoId = -1
	iSecAmmoMax = -1
	iNumberInSlot = get_cswpn_position(iCsWpnId)
	iWeaponId = iCsWpnId

	send_message_WeaponList(id, sWeaponName, iPriAmmoId, iPriAmmoMax, iSecAmmoId, iSecAmmoMax, iSlotId, iNumberInSlot, iWeaponId, iFlags)
	if (iSendMsg)
		send_message_CurWeapon(id, 1, iWeaponId, iCsWpnClip)
}

stock send_message_CurWeapon(id, isActive, iWeaponID, iClip)
{
	if (is_user_bot(id))
		return
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("CurWeapon"), _, id)
	write_byte(isActive)
	write_byte(iWeaponID)
	write_byte(iClip)
	message_end()
}

stock send_message_WeaponList(id, const sWeaponName[], iPriAmmoID, iPriAmmoMax, iSecAmmoID, iSecAmmoMax, iSlotId, iNumberInSlot, iWeaponId, iFlags)
{
	if (is_user_bot(id))
		return
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("WeaponList"), _, id)
	write_string(sWeaponName)
	write_byte(iPriAmmoID)
	write_byte(iPriAmmoMax)
	write_byte(iSecAmmoID)
	write_byte(iSecAmmoMax)
	write_byte(iSlotId)
	write_byte(iNumberInSlot)
	write_byte(iWeaponId)
	write_byte(iFlags)
	message_end()
}  

stock get_cswpn_position(cswpn)
{
	new iPosition
    
	switch (cswpn)
	{
		case CSW_P228: iPosition = 3
		case CSW_SCOUT: iPosition = 9
		case CSW_HEGRENADE: iPosition = 1
		case CSW_XM1014: iPosition = 12
		case CSW_C4: iPosition = 3
		case CSW_MAC10: iPosition = 13
		case CSW_AUG: iPosition = 14
		case CSW_SMOKEGRENADE: iPosition = 3
		case CSW_ELITE: iPosition = 5
		case CSW_FIVESEVEN: iPosition = 6
		case CSW_UMP45: iPosition = 15
		case CSW_SG550: iPosition = 16
		case CSW_GALIL: iPosition = 17
		case CSW_FAMAS: iPosition = 18
		case CSW_USP: iPosition = 4
		case CSW_GLOCK18: iPosition = 2
		case CSW_AWP: iPosition = 2
		case CSW_MP5NAVY: iPosition = 7
		case CSW_M249: iPosition = 4
		case CSW_M3: iPosition = 5
		case CSW_M4A1: iPosition = 6
		case CSW_TMP: iPosition = 11
		case CSW_G3SG1: iPosition = 3
		case CSW_FLASHBANG: iPosition = 2
		case CSW_DEAGLE: iPosition = 1
		case CSW_SG552: iPosition = 10
		case CSW_AK47: iPosition = 1
		case CSW_KNIFE: iPosition = 1
		case CSW_P90: iPosition = 8
		default: iPosition = 0
	}
	return iPosition
}

stock get_cswpn_slotid_flags(iCsWpn, &iSlotId, &iFlags)
{
	new iCsWpnType = get_cswpn_type(iCsWpn)
	switch (iCsWpnType)
	{
		case 1:
		{
			iSlotId = 0
			iFlags = 0
		}
		case 2:
		{
			iSlotId = 1
			iFlags = 0
		}
		case 3:
		{
			iSlotId = 2
			iFlags = 0
		}
		case 4:
		{    
			iSlotId = 3
			iFlags = 24
		}
		case 5:
		{    
			iSlotId = 4
			iFlags = 24
		}
		default:
		{
			iSlotId = 0
			iFlags = 0
		}
	}
}

stock get_cswpn_type(cswpn)
{
	new iType
	switch (cswpn)
	{
		case CSW_MAC10, CSW_UMP45, CSW_MP5NAVY, CSW_TMP, CSW_P90, CSW_SCOUT, CSW_AUG, CSW_SG550, CSW_GALIL, CSW_FAMAS, CSW_AWP, CSW_M4A1, CSW_G3SG1, CSW_SG552, CSW_AK47, CSW_M249:
		{
			iType = 1
		}
		case CSW_P228, CSW_ELITE, CSW_FIVESEVEN, CSW_USP, CSW_GLOCK18, CSW_DEAGLE:
		{
			iType = 2
		}
		case CSW_KNIFE:
		{
			iType = 3
		}
		case CSW_HEGRENADE,  CSW_FLASHBANG, CSW_SMOKEGRENADE:
		{
			iType = 4
		}
		case CSW_C4:
		{
			iType = 5
		}
		default:
		{
			iType = 0
		}
	}
	return iType
}



public _RifleCreateWpn(WeaponName[])
{
	param_convert(1)
	if (!StartRegister)
		return -1
	if (g_weapon_count >= max_wpn)
		return -1
	format(weapon_name[g_weapon_count], 255, WeaponName)
	new info[3]
	format(info, 2, "%d", g_weapon_count)
	menu_additem(spawn_menu, weapon_name[g_weapon_count], info, ADMIN_ALL, -1)
	menu_additem(rifle_menu, weapon_name[g_weapon_count], info, ADMIN_ALL, -1)
	new iReturn = g_weapon_count
	g_weapon_count++
	return iReturn
}


public _RifleStringSection(weaponid, model[], AlterModel[], sound[] ,WpnClass[], HudKill[], Wpn_Class[]) 
{
	if (weaponid < 0 || weaponid > g_weapon_count - 1)
		return 0
	param_convert(2)
	param_convert(3)
	param_convert(4)
	param_convert(5)
	param_convert(6)
	param_convert(7)
	
	format(weapon_w_model[weaponid], 127, "models/w_%s.mdl", model)
	format(weapon_p_model[weaponid], 127, "models/p_%s.mdl",  model)
	format(weapon_v_model[weaponid], 127, "models/v_%s.mdl",model)
	if (weapon_PrecacheType[weaponid] > 0)
	{
		format(weapon_AlternativeModel[weaponid], 127, "models/w_%s.mdl", AlterModel)
		engfunc(EngFunc_PrecacheModel, weapon_AlternativeModel[weaponid])
	}
	else engfunc(EngFunc_PrecacheModel, weapon_w_model[weaponid])
	engfunc(EngFunc_PrecacheModel, weapon_p_model[weaponid])
	engfunc(EngFunc_PrecacheModel, weapon_v_model[weaponid])
	
	format(weapon_sound[weaponid], 255, "weapons/%s.wav", sound)
	engfunc(EngFunc_PrecacheSound, weapon_sound[weaponid])
	
	format(WeaponClass[weaponid], 127, Wpn_Class)
	register_clcmd(Wpn_Class, "fw_ChangeWeapon")
	//format(weapon_file[weaponid], 127, "%s/g4u_weapon/riffle/weapon_spawn/%s/%s.cfg", con_dir, mapname, WeaponClass[weaponid]))
	format(weapon_hud_kill[weaponid], 255, HudKill)
	return 1
	
}

public _RifleIntegerSection(weaponid, iWeaponChange,  iClip, iBpa, iCostType, iCost , iPrecacheType, iSubModel, iLevel , iAmmoCost, iTreasure, iWpnType, iASMAP)
{
	if (weaponid < 0 || weaponid > g_weapon_count - 1)
		return 0
	
	weapon_change[weaponid] = iWeaponChange
	weapon_clip[weaponid] = iClip
	weapon_bpa[weaponid] = iBpa

	weapon_cost[weaponid] = iCost
	weapon_PrecacheType[weaponid] = iPrecacheType
	weapon_SubBody[weaponid] = iSubModel


	weapon_level[weaponid] = iLevel
	ammo_cost[weaponid] = iAmmoCost
	can_pick_ad[weaponid] = iTreasure
	
	weapon_type[weaponid] = iWpnType
	weapon_ASMAP[weaponid] = iASMAP
	return 1
}

public _RifleFloatSection(weaponid, Float:fDelay, Float:fRecoil, Float:DmgPlayer, Float:DmgHostage, Float:DmgEntity, Float:fDspeed, Float:fWeight, Float:fReloadTime, Float:fDeployTime)
{
	if (weaponid < 0 || weaponid > g_weapon_count - 1)
		return 0
	weapon_speed[weaponid] = fDelay
	weapon_recoil[weaponid] = fRecoil
	damage_player[weaponid] = DmgPlayer
	damage_hostage[weaponid] = DmgHostage
	damage_entity[weaponid] = DmgEntity
	weapon_dspeed[weaponid] = fDspeed
	weapon_weight[weaponid] = fWeight
	weapon_reload_time[weaponid] = fReloadTime
	if (!fReloadTime)
		weapon_reload_time[weaponid] = g_fDelay[weapon_change[weaponid]]
	weapon_deploy_time[weaponid] = fDeployTime
	if (fDeployTime <= 0.0)
		weapon_deploy_time[weaponid] = 1.25
	return 1
}

public _SetAdditionalInfoIronsight(weaponid, model[], iSpecial, iIronType , Float:fStartTime , Float:fFinishTime, iHideVModel) 
{
	if (weaponid < 0)
		return 0
	
	param_convert(2)
	weapon_silencer[weaponid] = iSpecial
	weapon_start_iron_time[weaponid] = fStartTime
	weapon_finish_iron_time[weaponid]  = fFinishTime
	weapon_HideVModel[weaponid] = iHideVModel
	
	if (iIronType == 1)
	{
		weapon_special_mode[weaponid] = 5
		if (iSpecial)
			weapon_silencer[weaponid] = 0
	}
	else if (iIronType == 2)
	{
		weapon_special_mode[weaponid] = 11
		if (iSpecial)
			weapon_silencer[weaponid] = 0
	}
	else	
	{
		weapon_special_mode[weaponid] = 12
		if (!iHideVModel)
		{
			format(weapon_launching_nade[weaponid], 127, "models/v_%s_s.mdl", model, model)
			engfunc(EngFunc_PrecacheModel, weapon_launching_nade[weaponid])
		}
		else	format(weapon_launching_nade[g_weapon_count], 127, "")
	}
	return 1
}

public _SetWeaponZoomOption(weaponid, iZoomType, iFov, iStartZoom, iEndZoom)
{
	if (weaponid < 0)
		return 0
	weapon_zoom_type[weaponid] = iZoomType
	weapon_FOV[weaponid] = 90 - iFov
	weapon_scope[weaponid][0] = iStartZoom
	weapon_scope[weaponid][1] = iEndZoom
	return 1
}

public _SetNewRifleSpawn(weaponid)
{
	if (weaponid < 0 || weaponid > g_weapon_count - 1)
		return 0
	new spawn_file[256], mapname[32]
	get_mapname(mapname, 31)
	new con_dir[128]
	get_configsdir(con_dir, 127)
	format(spawn_file, 255, "%s/weapon_spawn/%s/%s.cfg", con_dir, mapname, WeaponClass[weaponid])
	format(weapon_files[weaponid], 255, "%s/weapon_config/%s.ini", con_dir, WeaponClass[weaponid])
	format(weapon_file[weaponid], 255, "%s", spawn_file)
	if (file_exists(spawn_file))
	{
		new Data[124], len;
		new line = 0;
		new pos[11][8];
		new g_SpawnVecs[max_spawn_point][3]
		new g_TotalSpawns = 0
		while(g_TotalSpawns < max_spawn_point && (line = read_file(spawn_file , line , Data , 123 , len) ) != 0 ) 
		{
			if (strlen(Data)<2) continue;
			parse(Data, pos[1], 7, pos[2], 7, pos[3], 7)
			// Origin
			g_SpawnVecs[g_TotalSpawns][0] = str_to_num(pos[1]);
			g_SpawnVecs[g_TotalSpawns][1] = str_to_num(pos[2]);
			g_SpawnVecs[g_TotalSpawns][2] = str_to_num(pos[3])
			
			ExecuteForward(g_ArmouryCreated, g_result)
			if (g_result != PLUGIN_CONTINUE)
				continue
			new ent = create_entity("info_target")
			
			ExecuteForward(g_ArmourySetInfo, g_result, ent)
			
			if (g_result != PLUGIN_CONTINUE)
				continue
			set_pev(ent, pev_classname, "new_riffle")
			set_pev(ent, pev_solid, SOLID_TRIGGER)
			set_pev(ent, pev_iuser1, weapon_clip[weaponid])
			set_pev(ent, pev_iuser2, weapon_bpa[weaponid])
			set_pev(ent, pev_iuser3, weaponid)
			set_pev(ent, pev_iuser4, 1)
			set_pev(ent, pev_mins, {-3.0, -3.0, -3.0})
			set_pev(ent, pev_maxs, {3.0, 3.0, 3.0})
			new Float:origin[3], Float:vEnd[3]
			origin[0] = float(g_SpawnVecs[g_TotalSpawns][0])
			origin[1] = float(g_SpawnVecs[g_TotalSpawns][1])
			origin[2] = float(g_SpawnVecs[g_TotalSpawns][2])
			vEnd[0] = origin[0];
			vEnd[1] = origin[1];
			vEnd[2] = -1337.0;
			engfunc(EngFunc_TraceLine, origin, vEnd, 0, ent, 0);
			get_tr2(0, TR_vecEndPos, vEnd);
			set_pev(ent, pev_origin, vEnd)
			if (weapon_PrecacheType[weaponid] > 0)
			{
				engfunc(EngFunc_SetModel, ent, weapon_AlternativeModel[weaponid])
				set_pev(ent, pev_body, weapon_SubBody[weaponid])
			}
			else engfunc(EngFunc_SetModel, ent, weapon_w_model[weaponid])
			
			g_TotalSpawns++;
		}
	}
	return 1
}

stock iCheckSniper(iWeaponId)
{
	if (iWeaponId == CSW_SCOUT)
		return 1
	if (iWeaponId == CSW_AWP)
		return 1
	if (iWeaponId == CSW_G3SG1)
		return 1
	if (iWeaponId == CSW_SG550)
		return 1
	return 0
}
