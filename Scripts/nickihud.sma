#include < amxmodx >
#include < fakemeta >

public plugin_init()
{
	register_plugin( "WHAT", "ARE U", "DOING THERE?!" );
	register_forward( FM_PlayerPreThink, "fwd_PlayerPreThink", 0 );
}

public fwd_PlayerPreThink( id )
{
	static Float:origin[3], players[32], num, num2, team;

	team = get_user_team( id );
	arrayset( players, 0, 32 );

	pev( id, pev_origin, origin );

	get_players_distance(origin,players,num,"a")

	static Float:hudpos[2]
	static Float:origin2[3]
	num2=0
	for( new i=0; i < num; i++ )
	{
		if(players[ i ] && get_user_team( players[ i ] ) == team )
		{
			static name[33];
			get_user_name( players[i], name, 32 );
			pev( players[i], pev_origin, origin2 );
			origin2[2] = origin[2] + 10.0;
			if(get_hudmessage_locs(id,origin2,hudpos))
			{
				num2++
				set_hudmessage( 125, 125, 125, hudpos[0], hudpos[1], 0, 6.0, 0.2, 0.1, 0.2, num2 );
				show_hudmessage(id, "%s",name)
				if(num2==4) break;
			}
		}
	}
}
// <chr_engine.inc>
stock get_players_distance(const Float:origin2[3],players[32], &num,const flags[]="",index=0,const team[]="") // GHW_Chronic
{
	new bool:flag1, bool:flag2
	if(containi(flags,"j")!=-1) flag2 = true
	if(containi(flags,"i")!=-1)
	{
		if(!pev_valid(index))
		return 0;
		flag1 = true
	}

	static Float:origin[3]
	origin[0] = origin2[0]
	origin[1] = origin2[1]
	origin[2] = origin2[2]

	static players2[32]
	new num2
	arrayset(players2,0,32)
	get_players(players2,num2,flags,team)
	static Float:origin3[3]
	static Float:distance[32]
	for(new i=0;i<32;i++) distance[i]=0.0
	num = num2

	static Float:hit[3]
	new bool:continuea=true
	for(new i=0;i<num2;i++)
	{
		pev(players2[i],pev_origin,origin3)
		if(flag2)
		{
			engfunc(EngFunc_TraceLine,origin2,origin3,1,index,0)
			get_tr2(0,TR_vecEndPos,hit)
			if(hit[0]==origin3[0] && hit[1]==origin3[1] && hit[2]==origin3[2])
			{
				distance[i] = vector_distance(origin,origin3)
			}
			else
			{
				continuea=false
				distance[i] = 9999999.1337
				num--
			}
		}
		if(flag1 && continuea)
		{
			static Float:angles[3], Float:diff[3], Float:reciprocalsq, Float:norm[3], Float:dot, Float:fov
			pev(index, pev_angles, angles)
			engfunc(EngFunc_MakeVectors, angles)
			global_get(glb_v_forward, angles)
			angles[2] = 0.0

			pev(index, pev_origin, origin)
			diff[0] = origin3[0] - origin[0]
			diff[1] = origin3[1] - origin[1]
			diff[2] = origin3[2] - origin[2]
			//diff[2]=0.0// - for 2D viewcone

			reciprocalsq = 1.0 / floatsqroot(diff[0]*diff[0] + diff[1]*diff[1] + diff[2]*diff[2])
			norm[0] = diff[0] * reciprocalsq
			norm[1] = diff[1] * reciprocalsq
			norm[2] = diff[2] * reciprocalsq

			dot = norm[0]*angles[0] + norm[1]*angles[1] + norm[2]*angles[2]
			pev(index, pev_fov, fov)
			if(dot >= floatcos(fov * 3.1415926535 / 360.0))
			{
				distance[i] = vector_distance(origin,origin3)
			}
			else
			{
				continuea=false
				distance[i] = 9999999.1337
				num--
			}
		}
		if(continuea)
		{
			distance[i] = vector_distance(origin,origin3)
		}
	}
	static distance_cnt[32]
	arrayset(distance_cnt,0,32)
	for(new i=0;i<num2;i++)
	{
		if(distance[i]!=9999999.1337)
		{
			for(new i2=0;i2<num;i2++)
			{
				if(distance[i2]<distance[i]) distance_cnt[i]++
			}
			players[distance_cnt[i]]=players2[i]
		}
	}
	return 1;
}

stock get_hudmessage_locs(ent,const Float:origin[3],Float:hudpos[2])
{
	if(!is_user_connected(ent))
	return 0;

	static Float:origin2[3]
	origin2[0] = origin[0]
	origin2[1] = origin[1]
	origin2[2] = origin[2]

	static Float:ent_origin[3]

	pev(ent,pev_origin,ent_origin)

	static Float:ent_angles[3]

	pev(ent,pev_v_angle,ent_angles)

	origin2[0] -= ent_origin[0]
	origin2[1] -= ent_origin[1]
	origin2[2] -= ent_origin[2]

	new Float:v_length
	v_length = vector_length(origin2)

	static Float:aim_vector[3]
	aim_vector[0] = origin2[0] / v_length
	aim_vector[1] = origin2[1] / v_length
	aim_vector[2] = origin2[2] / v_length

	static Float:new_angles[3]
	vector_to_angle(aim_vector,new_angles)

	new_angles[0] *= -1

	if(new_angles[1]>180.0) new_angles[1] -= 360.0
	if(new_angles[1]<-180.0) new_angles[1] += 360.0
	if(new_angles[1]==180.0 || new_angles[1]==-180.0) new_angles[1]=-179.999999

	if(new_angles[0]>180.0) new_angles[0] -= 360.0
	if(new_angles[0]<-180.0) new_angles[0] += 360.0
	if(new_angles[0]==90.0) new_angles[0]=89.999999
	else if(new_angles[0]==-90.0) new_angles[0]=-89.999999

	new Float:fov
	pev(ent,pev_fov,fov)

	if(!fov)
		fov = 90.0

	if(floatabs(ent_angles[0] - new_angles[0]) <= fov/2 && floatabs((180.0 - floatabs(ent_angles[1])) - (180.0 - floatabs(new_angles[1]))) <= fov/2)
	{
		hudpos[1] = 1 - ( ( (ent_angles[0] - new_angles[0]) + fov/2 ) / fov )
		hudpos[0] = ( (ent_angles[1] - new_angles[1]) + fov/2 ) / fov
	}
	else
	return 0;

	return 1;
}
