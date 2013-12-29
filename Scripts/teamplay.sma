#include <amxmodx>
#include <amxmisc>
#include <acg>
#include <fun>
#include <fakemeta>
#include <hamsandwich>
#include <colorchat>

/*                      Plugin Team_Play Modification by Syczaj.
                        Pomys³ zaczerpniety z GunGame TeamPlay by Avalanche.              
	Kazde zabicie przybliza nas do zmiany poziomu.
	Zdobycie poziomu wymaga zabicia rownowartosci liczby czlonkow twojej druzyny.
	Terrorysci dostana punkty za polozenie bomby, tylko jesli ktorys z przeciwnikow jest nadal zywy.
	Za polozenie bomby dostaja rownowartosc punktow brakujacych do poziomu.
	Terrorysci dostana jeden poziom za wybuch bomby, jesli ktorys z przeciwnikow zyje.
	Antyterrorysci dostaja 2 poziomy za rozbrojenie bomby.
	Gdy minie czas, a terrorysci sa nadal zywi, CT dostana 1 poziom.
	Jesli druzyna posiada poziom wiekszy niz 11, kazde zabicie z granatu cofa ja o 1 punkt.
	Zabicie nozem zeruje punkty druzyny przeciwnej na danym poiomie. Jesli liczba punktow byla rowna zero, cofa poziom.
	Zabicie nozem kradnie punkty druzyny przeciwnej, jesli poziom druzyny przeciwnej jest rowny zero.
	Druzyna traci punkt za zabicie Teamate'a.
	Gra konczy sie, gdy jedna z druzyn zdobedzie 15 poziom.
	Podczas rozgrywania modyfikacji Team-Play obowiazuje bezwzgledny zakaz przechodzenia miedzy team'ami.
*/
new ct_score, tt_score, ct_level = 1, tt_level = 1, tt_num, ct_num, ct_alive_num,/* tt_alive_num,*/ tt_level_old, ct_level_old/*, g_bomb*/;
new Players[32], nextmap[32];
new bool:g_chmap;
new Float:gr_timelimit, gr_maxrounds, gr_winlimit;
new Float:gr_roundtime;

//new tp_brassbell, tp_takenlead, tp_levelup, tp_lostlead;

public plugin_init(){
	register_plugin("Team_play", "1.3", "Syczaj");
	register_event("HLTV", "Nowa_Runda", "a", "1=0", "2=0")
	register_event( "SendAudio", "ct_win", "a", "2&%!MRAD_ctwin");
	register_event("TextMsg","GameComm","a","2&#Game_C") 
	
	register_event("TeamInfo", "eventJoinTeam", "a", "2=TERRORIST", "2=CT");
	//set_task (1.5, "updatescoreboard", _, _, _,"b")
	RegisterHam(Ham_Spawn, "player", "Spawn", 1);
	register_event("DeathMsg", "DeathEvent", "a");
	
	/*register_clcmd("say !wynik", "pokaz_wynik");
	register_clcmd("say /wynik", "pokaz_wynik");*/
	register_menucmd(register_menuid("vote"),(1<<9),"glosowanie");
	
	/*** RESET STATYSTYK ***/
	tt_score = 0 ;
	ct_score = 0 ;
	ct_level = 1 ;
	tt_level = 1 ;
	tt_num = 2 ;
	ct_num = 2 ;
	g_chmap = false ;
	
	set_task(5.0,"wczytaj_cvary");
}
public wczytaj_cvary(){
	gr_timelimit = get_cvar_float("mp_timelimit");
	gr_maxrounds = get_cvar_num("mp_maxrounds");
	gr_winlimit = get_cvar_num("mp_winlimit");
	gr_roundtime = get_cvar_float("mp_roundtime");
	
	set_cvar_float("mp_timelimit",90.0);
	set_cvar_num("mp_maxrounds",0);
	set_cvar_num("mp_winlimit",0);
	set_cvar_float("mp_roundtime",2.5);
	set_cvar_num("sv_alltalk", 0);
}

public plugin_end(){
	set_cvar_float("mp_timelimit",gr_timelimit);
	set_cvar_num("mp_maxrounds",gr_maxrounds);
	set_cvar_num("mp_winlimit",gr_winlimit);
	set_cvar_float("mp_roundtime",gr_roundtime);
	set_cvar_num("sv_alltalk", 0);
}

public GameComm(){
	/*** RESET STATYSTYK ***/
	tt_score = 0 ;
	ct_score = 0 ;
	ct_level = 1 ;
	tt_level = 1 ;
	tt_num = 2 ;
	ct_num = 2 ;
	g_chmap = false ;
}


public plugin_precache(){
	precache_sound("gungame/brass_bell_C.wav")
	precache_sound("gungame/smb3_powerup.wav")
	precache_sound("gungame/smb3_powerdown.wav")
	
	precache_model("sprites/scoreboard.spr")
	precache_model("sprites/scoreboard_text.spr")
	//client_cmd(id,"spk ^"%s^"",value);
}

public bomb_planted(planter){
	get_players(Players, tt_num, "eh", "TERRORIST");
	get_players(Players, ct_num, "eh", "CT");
	get_players(Players, ct_alive_num, "aeh", "CT");
	if( ct_alive_num > 0){
		if( tt_level < 11){
			tt_level += 1;
			ColorChat(0, NORMAL, "^x04[TeamPlay]^x01 Terrorysci zyskali ^x04 ::^x03 %d^x04 ::^x01 fragow za polozenie bomby.", ct_num - ct_score);
			//tutorMake(0,TUTOR_GREEN,4.0,"Terrorysci zyskali :: %d :: fragow za polozenie bomby.", tt_num - tt_score) ;
			tt_score = 0 ;
			}
	}
	//g_bomb = 1 ;
}
public bomb_defused(defuser){
	if(ct_level < 13){
		ct_level += 2 ;
		ColorChat(0, NORMAL, "^x04[TeamPlay]^x01 Antyterrorysci zyskali ^x04 ::^x03 2^x04 ::^x01 poziomy za rozbrojenie bomby.");
		//tutorMake(0,TUTOR_GREEN,4.0,"Antyterrorysci zyskali :: 2 :: poziomy za rozbrojenie bomby.");
	}
	else if(ct_level >= 13){
		ct_level = 15
		ct_score = ct_num - 1;
		ColorChat(0, NORMAL, "^x04[TeamPlay]^x01 Antyterrorysci zyskali ^x04 ::^x03 2^x04 ::^x01 poziomy za rozbrojenie bomby.");
		//tutorMake(0,TUTOR_GREEN,4.0,"Antyterrorysci zyskali :: 2 :: poziomy za rozbrojenie bomby.");
	}
}

public bomb_explode(planter, defuser){
	new ct_alive_num ;
	get_players(Players, ct_alive_num, "aeh", "CT");
	if( ct_alive_num > 0){
		if(tt_level < 14){
			tt_level += 1;
			ColorChat(0, NORMAL, "^x04[TeamPlay]^x01 Terrorysci zyskali ^x04 ::^x03 1^x04 ::^x01 poziom za wybuch bomby.");
			//tutorMake(0,TUTOR_GREEN,4.0,"Terrorysci zyskali :: 1 :: poziom za wysadzenie BSa.");
		}
	}
}

public Nowa_Runda(){
	//g_bomb = 0;
	for(new i = 0; i < 32; i++){
		if(is_user_connected(i)){
			if(get_user_team(i) == 1){
				set_user_frags(i, tt_level)
			}
			if(get_user_team(i) == 2){
				set_user_frags(i, ct_level)
			}
		}
	}
	/*if(tt_level > ct_level){
		ColorChat(0, NORMAL, "^x04[TeamPlay]^x01 Terrorysci prowadza bedac na poziomie ^x04 ::^x03 %d^x04 ::", tt_level);
	}
	else if(tt_level < ct_level){
		ColorChat(0, NORMAL, "^x04[TeamPlay]^x01 Antyterrorysci prowadza bedac na poziomie ^x04 ::^x03 %d^x04 ::", ct_level);
	}
	else if(tt_level == ct_level){
		ColorChat(0, NORMAL, "^x04[TeamPlay]^x01 Remis! Antyterrorysci i terrorysci sa na poziomie ^x04 ::^x03 %d^x04 ::", ct_level);
	}*/
	
	if(tt_level >= 11 || ct_level >= 11){
		if(!g_chmap){
			g_chmap = true ;
			set_task(10.0,"wybor_mapy");
			//ColorChat(0, NORMAL, "^x04[TeamPlay]^x01 Za chwile rozpocznie sie^x03 glosowanie^x01 na nastepna mape.");
		}
	}

}

/*public ct_win(){
	get_players(Players, tt_alive_num, "aeh", "TERRORIST");
	if(g_bomb < 1 && tt_alive_num > 0){
		if(ct_level < 24){
			ct_level += 1 ;
			//tutorMake(0,TUTOR_GREEN,4.0,"Antyterrorysci zyskali :: 1 :: poziom. Terrorysci nie wykonali celow mapy.");
			ColorChat(0, NORMAL, "Antyterrorysci zyskali :: 1 :: poziom. Terrorysci nie wykonali celow mapy");
		}
		if(ct_level == 24){
			ct_score = ct_num - 1 ;
			ColorChat(0, NORMAL, "Antyterrorysci zyskali :: 1 :: poziom. Terrorysci nie wykonali celow mapy");
		}
	}
}*/


public client_death(kid, vid, wid, hitbox, tk){
					/** POBIERANIE ILOSCI GRACZY **/
	get_players(Players, tt_num, "eh", "TERRORIST");
	get_players(Players, ct_num, "eh", "CT");
	
	/** JESLI TEAMY GRACZY SA ROZNE **/
	if(is_user_connected(kid) && is_user_connected(vid) && get_user_team(kid) != get_user_team(vid)){
		/** ZABICIE NOZEM **/
		if(wid == CSW_KNIFE){
			if(get_user_team(kid) == 1){
				if(ct_level < 2){
					if(ct_score >= tt_num - tt_score){
						tt_score = ct_score - (tt_num - tt_score) ;
						tt_level += 1 ;
						ColorChat(0, NORMAL, "^x04[TeamPlay]^x01 Terrorysci ukradli antyterrorystom^x04 ::^x03 %d^x04 ::^x01 punkty/ow.", ct_score);
						//tutorMake(0,TUTOR_BLUE,4.0,"Terrorysci ukradli przeciwnikom :: %d :: fragow", ct_score);
						ct_score = 0;
					}
					else if(ct_score < tt_num - tt_score){
						tt_score += ct_score ;
						ColorChat(0, NORMAL, "^x04[TeamPlay]^x01 Terrorysci ukradli antyterrorystom^x04 ::^x03 %d^x04 ::^x01 punkty/ow.", ct_score);
						//tutorMake(0,TUTOR_BLUE,4.0,"Terrorysci ukradli przeciwnikom :: %d :: fragow", ct_score);
						ct_score = 0 ;
					}
				}
				if(ct_level >= 2){
					if(ct_score > 0){
						ColorChat(0, NORMAL, "^x04[TeamPlay]^x01 Antyterrorysci stracili^x04 ::^x03 %d^x04 ::^x01 punkty/ow.", ct_score);
						//tutorMake(0,TUTOR_BLUE,4.0,"Antyterrorysci stracili :: %d :: fragow", ct_score);
						ct_score = 0 ;
						tt_score += 1 ;
					}
					else if(ct_score == 0){
						tt_score += 1 ;
						ct_level -= 1 ;
						ColorChat(0, NORMAL, "^x04[TeamPlay]^x01 Antyterrorysci stracili^x04 ::^x03 1^x04 ::^x01 poziom.");
						//tutorMake(0,TUTOR_BLUE,4.0,"Antyterrorysci stracili :: 1 :: poziom");
					}
				}
			}
			if(get_user_team(kid) == 2){
				if(tt_level < 2){
					if(tt_score >= ct_num - ct_score){
						ct_score = tt_score - (ct_num - ct_score) ;
						ct_level += 1 ;
						ColorChat(0, NORMAL, "^x04[TeamPlay]^x01 Antyerrorysci ukradli terrorystom^x04 ::^x03 %d^x04 ::^x01 punkty/ow.", tt_score);
						//tutorMake(0,TUTOR_RED,4.0,"Antyterrorysci ukradli przeciwnikom :: %d :: fragow", tt_score);
						tt_score = 0;
					}
					else if(tt_score < ct_num - ct_score){
						ct_score += tt_score ;
						//ColorChat(0, NORMAL, "^x04[TeamPlay]^x01 Antyterrorysci ukradli terrorystom^x04 ::^x03 %d^x04 ::^x01 punkty/ow.", tt_score);
						//tutorMake(0,TUTOR_RED,4.0,"Antyterrorysci ukradli przeciwnikom :: %d :: fragow", tt_score);
						tt_score = 0 ;
					}
				}
				if(tt_level >= 2){
					if(tt_score > 0){
						ColorChat(0, NORMAL, "^x04[TeamPlay]^x01 Terrorysci stracili^x04 ::^x03 %d^x04 ::^x01 punkty/ow.", ct_score);
						//tutorMake(0,TUTOR_RED,4.0,"Terrorysci stracili :: %d :: fragow", tt_score);
						tt_score = 0 ;
						ct_score += 1 ;
					}
					else if(tt_score == 0){
						ct_score += 1 ;
						tt_level -= 1 ;
						ColorChat(0, NORMAL, "^x04[TeamPlay]^x01 Terrorysci stracili^x04 ::^x03 1^x04 ::^x01 poziom.");
						//tutorMake(0,TUTOR_RED,4.0,"Terrorysci stracili :: 1 :: poziom", tt_score);
					}
				}
			}
		}
		/** ZABICIE Z HE **/
		else if(wid == CSW_HEGRENADE){	
			if(get_user_team(kid) == 1){
				if(ct_level > 11){
					if(ct_score > 0){
						ct_score -= 1 ;
						tt_score += 1 ;
					}
					else if(ct_score == 0){
						ct_score = ct_num - 1 ;
						ct_level -= 1 ;
						tt_score += 1 ;
					}
				}
			}
			if(get_user_team(kid) == 2){
				if(tt_level > 11){
					if(tt_score > 0){
						tt_score -= 1 ;
						ct_score += 1 ;
					}
					else if(tt_score == 0){
						tt_score = tt_num - 1 ;
						tt_level -= 1 ;
						ct_score += 1 ;
					}
				}
			}
		}
		/** INNE ZABICIE **/
		else{
			if(get_user_team(kid) == 1){
				tt_score += 1 ;
			}
			if(get_user_team(kid) == 2){
				ct_score += 1 ;
			}
		}
	}
	/** JEŒLI TEAMY SA SOBIE ROWNE == TK **/
	if(is_user_connected(kid) && is_user_connected(vid) && get_user_team(kid) == get_user_team(vid) && tk > 0){
		if(get_user_team(kid) == 1){
			if(tt_score > 0){
				tt_score -= 1 ;
				ColorChat(0, NORMAL, "^x04[TeamPlay]^x01 Terrorysci stracili^x04 ::^x03 1^x04 ::^x01 frag za TK.");
			}
			else if(tt_score == 0){
				if(tt_level == 1){
					tt_level = 1;
					tt_score = 0;
				}
				else{
					tt_level -= 1 ;
					tt_score = tt_num - 1 ;
					ColorChat(0, NORMAL, "^x04[TeamPlay]^x01 Terrorysci stracili^x04 ::^x03 1^x04 ::^x01 frag za TK.");
				}
			}
		}
		if(get_user_team(kid) == 2){
			if(ct_score > 0){
				ct_score -= 1 ;
				ColorChat(0, NORMAL, "^x04[TeamPlay]^x01 Antyterrorysci stracili^x04 ::^x03 1^x04 ::^x01 frag za TK.");
			}
			else if(ct_score == 0){
				if(ct_level == 1){
					ct_level = 1;
					ct_score = 0;
				}
				else{
					ct_level -= 1 ;
					ct_score = ct_num - 1 ;
					ColorChat(0, NORMAL, "^x04[TeamPlay]^x01 Antyterrorysci stracili^x04 ::^x03 1^x04 ::^x01 frag za TK.");
				}
			}
		}
	}
	/** OPERACJE NA POZIOMACH **/
	operacje_napoziomach() ;

	/** RESETUJ < 0 **/
	res_if_mniejsze() ;
	
	/** POKAZ AWANSE/SPADKI **/
	awanse_spadki() ;
	
	/** POKAZ INFO O ZABOJSTWACH **/
	//pokaz_wymagane() ;
	
	/** ZAPAMIETANIE POPRZEDNIEGO LVLU **/
	zapamietaj_level() ;
	
	/** Aktualizuj tabele **/
	updatescoreboard() ;
	
	if(tt_level == 15 || ct_level == 15){
		koniec_teamplay(kid, vid)
	}
	
}

public wybor_mapy(){
	if(find_plugin_byfile("mapchooser4.amxx") != INVALID_PLUGIN_ID)
	{
		log_amx("Starting a map vote from mapchooser4.amxx");
	
		new oldWinLimit = get_cvar_num("mp_winlimit"), oldMaxRounds = get_cvar_num("mp_maxrounds");
		set_cvar_num("mp_winlimit",0); // skip winlimit check
		set_cvar_num("mp_maxrounds",1); // trick plugin to think game is almost over

		// deactivate g_buyingtime variable
		if(callfunc_begin("buyFinished","mapchooser4.amxx") == 1)
			callfunc_end();

		// call the vote
		if(callfunc_begin("voteNextmap","mapchooser4.amxx") == 1)
		{
			callfunc_push_str("",false);
			callfunc_end();
		}

		// set maxrounds back
		set_cvar_num("mp_winlimit",oldWinLimit);
		set_cvar_num("mp_maxrounds",oldMaxRounds);
	}
	else
		set_cvar_float("mp_timelimit", 1.15)
}

public koniec_teamplay(winner, loser){
	new motd[2048], len, header[32], loserName[35], winnerName[35]
	if(!is_user_connected(winner)) return 0;
	get_cvar_string("amx_nextmap",nextmap,31);
	set_cvar_num("sv_alltalk", 1);

	if(is_user_connected(loser)){
		get_user_name(loser,loserName,34);
	}
	if(is_user_connected(winner)){
		get_user_name(winner,winnerName,34);
	}
		
	set_task(8.0,"zmiana_mapy");
	new player;
	for(player=1;player<32;player++){
		if(is_user_connected(player)){
			client_cmd(player,"spk ^"sound/gungame/brass_bell_C.wav^"");
			
			if(is_user_alive(player)){
				exec_zagrzeb(player);
				client_cmd(player, "drop");
				client_cmd(player, "drop");
			}
			if(get_user_team(winner) == 1){
				if(!is_user_connected(player)) continue;
				new winnerColor[10], loserColor[10];
				winnerColor = "#FF3F3F" ;
				loserColor = "#99CCFF" ;
				formatex(header,31,"Terrorysci wygrali!");
			
				len = formatex(motd,2047,"<html><body bgcolor=black style=^"line-height:1.0^"><center><font color=#00CC00 size=7 face=Georgia>STER Team-Play<p>");

				len += formatex(motd[len],2047-len,"<font color=%s size=6 style=^"letter-spacing:2px^">",winnerColor);
				len += formatex(motd[len],2047-len,"<table height=1 width=80%% cellpadding=0 cellspacing=0 bgcolor=%s><tr><td> </td></tr></table>",winnerColor);
				len += formatex(motd[len],2047-len,"Druzyna Terrorystow<br><br>");
				len += formatex(motd[len],2047-len,"<table height=1 width=80%% cellpadding=0 cellspacing=0 bgcolor=%s><tr><td> </td></tr></table>",winnerColor);
				len += formatex(motd[len],2047-len,"<font size=4 color=white style=^"letter-spacing:1px^">zwyciezyla osiagajac 15 poziom!<p>");
				len += formatex(motd[len],2047-len,"<font size=3>Swoja druzyne <font color=white>zawiodl <font color=%s>%s<font color=white> zabity przez <font color=%s>%s<font color=white>.<br><br><br><br>",loserColor,loserName,winnerColor,winnerName);
				len += formatex(motd[len],2047-len,"<font color=%s> Nastepna bedzie mapa: <font color=white> %s.",winnerColor,nextmap);
				len += formatex(motd[len],2047-len,"</center></body></html>");
			
				show_motd(player,motd,header);
			}
			else if(get_user_team(winner) == 2){
				if(!is_user_connected(player)) continue;
				new winnerColor[10], loserColor[10];
				winnerColor = "#99CCFF" ;
				loserColor = "#FF3F3F";
				formatex(header,31,"Antyterrorysci wygrali!");
			
				len = formatex(motd,2047,"<html><body bgcolor=black style=^"line-height:1.0^"><center><font color=#00CC00 size=7 face=Georgia>STER Team-Play<p>");

				len += formatex(motd[len],2047-len,"<font color=%s size=6 style=^"letter-spacing:2px^">",winnerColor);
				len += formatex(motd[len],2047-len,"<table height=1 width=80%% cellpadding=0 cellspacing=0 bgcolor=%s><tr><td> </td></tr></table>",winnerColor);
				len += formatex(motd[len],2047-len,"Druzyna Antyterrorystow");
				len += formatex(motd[len],2047-len,"<table height=1 width=80%% cellpadding=0 cellspacing=0 bgcolor=%s><tr><td> </td></tr></table>",winnerColor);
				len += formatex(motd[len],2047-len,"<font size=4 color=white style=^"letter-spacing:1px^">zwyciezyla osiagajac 15 poziom!<p>");
				len += formatex(motd[len],2047-len,"<font size=3>Swoja druzyne <font color=white>zawiodl <font color=%s>%s<font color=white> zabity przez <font color=%s>%s<font color=white>.<br><br><br><br>",loserColor,loserName,winnerColor,winnerName);
				len += formatex(motd[len],2047-len,"<font color=%s> Nastepna bedzie mapa: <font color=white> %s.",winnerColor,nextmap);
				len += formatex(motd[len],2047-len,"</center></body></html>");
			
				show_motd(player,motd,header);
			}
		}
	}
	return 1;
}

public zmiana_mapy(){
	server_cmd("amx_map %s", nextmap)
}

public operacje_napoziomach(){
	if(ct_score >= ct_num){
		ct_level += 1 ;
		ct_score = 0 ;

	}
	if(tt_score >= tt_num){
		tt_level += 1 ;
		tt_score = 0 ;
	}
}

public awanse_spadki(){
	if(ct_level > ct_level_old && ct_score == 0){
		ColorChat(0, NORMAL, "^x04[TeamPlay]^x01 Antyterrorysci awansowali do poziomu^x04 ::^x03 %d^x04 ::", ct_level);
		//set_tutor(TUTOR_GREEN,5.0, TPRIORITY_HIGH)
		//show_tutor(0,"Antyterrorysci awansowali do poziomu :: %d ::", ct_level)
		//tutorMake(0,TUTOR_GREEN,5.0,"Antyterrorysci awansowali do poziomu :: %d ::", ct_level)
		for(new i=0;i<32;i++){
			if(is_user_connected(i)){
				if(get_user_team(i) == 2){
					client_cmd(i,"spk ^"gungame/smb3_powerup.wav^"");
				}
			}
		}
	}
	else if(ct_level < ct_level_old){
		ColorChat(0, NORMAL, "^x04[TeamPlay]^x01 Antyterrorysci spadli do poziomu^x04 ::^x03 %d^x04 ::", ct_level);
		//set_tutor(TUTOR_NORMAL,5.0, TPRIORITY_HIGH)
		//show_tutor(0,"Antyterrorysci spadli do poziomu :: %d ::", ct_level)
		//tutorMake(0,TUTOR_NORMAL,5.0,"Antyterrorysci spadli do poziomu :: %d ::", ct_level)
		for(new i=0;i<32;i++){
			if(is_user_connected(i)){
				if(get_user_team(i) == 2){
					client_cmd(i,"spk ^"gungame/smb3_powerdown.wav^"");
				}
			}
		}
	}
	
	if(tt_level > tt_level_old && tt_score == 0){
		ColorChat(0, NORMAL, "^x04[TeamPlay]^x01 Terrorysci awansowali do poziomu^x04 ::^x03 %d^x04 ::", tt_level);
		//set_tutor(TUTOR_GREEN,5.0, TPRIORITY_HIGH)
		//show_tutor(0,"Terrorysci awansowali do poziomu :: %d ::", tt_level)
		//tutorMake(0,TUTOR_GREEN,5.0,"Terrorysci awansowali do poziomu :: %d ::", tt_level)
		for(new i=0;i<32;i++){
			if(is_user_connected(i)){
				if(get_user_team(i) == 1){
					client_cmd(i,"spk ^"gungame/smb3_powerup.wav^"");
				}
			}
		}
	}
	else if(tt_level < tt_level_old){
		ColorChat(0, NORMAL, "^x04[TeamPlay]^x01 Terrorysci spadli do poziomu^x04 ::^x03 %d^x04 ::", tt_level);
		//set_tutor(TUTOR_NORMAL,5.0, TPRIORITY_HIGH)
		//show_tutor(0,"Terrorysci spadli do poziomu :: %d ::", tt_level)
		//tutorMake(0,TUTOR_NORMAL,5.0,"Terrorysci spadli do poziomu :: %d ::", tt_level)
		for(new i=0;i<32;i++){
			if(is_user_connected(i)){
				if(get_user_team(i) == 1){
					client_cmd(i,"spk ^"gungame/smb3_powerdown.wav^"");
				}
			}
		}
	}
}

public zapamietaj_level(){
	ct_level_old = ct_level ;
	tt_level_old = tt_level ;
}

public res_if_mniejsze(){
	if(tt_score < 0)
		tt_score = 0
	if(tt_level < 0)
		tt_level = 0
	if(ct_score < 0)
		ct_score = 0
	if(ct_level < 0)
		ct_level = 0
}

public pokaz_wymagane(){
	for(new i = 0; i < 32; i++){ 
		if(get_user_team(i) == 1){
			set_hudmessage(255, 225, 225, -1.0, 0.84, 0, 6.0, 5.0)
			show_hudmessage(i, "Wymagane zabojstwa :: %d/%d ::", tt_score, tt_num)
		}
		else if(get_user_team(i) == 2){
			set_hudmessage(255, 225, 225, -1.0, 0.84, 0, 6.0, 5.0)
			show_hudmessage(i, "Wymagane zabojstwa :: %d/%d ::", ct_score, ct_num)
		}
	}
}


/*public pokaz_wynik(id){
	set_task(0.1,"wyniki",id+763);
	return PLUGIN_HANDLED;
}


public wyniki(rid){
	new id = rid - 763 ;
	new keys = (1<<9);
	new szMenuBody[193];
	format(szMenuBody, 192, "\yWyniki rozgrywki \rTeamPlay\y:^n\wTerrorysci \d::\y %d/%d \d::\w na poziomie \d::\y %d \d::^n\wAntyterrorysci \d::\y %d/%d \d::\w na poziomie\d ::\y %d \d::^n^n\y0\w. \r Wyjscie", tt_score, tt_num, tt_level,ct_score, ct_num, ct_level);
	show_menu(id,keys, szMenuBody, -1, "vote");
	return PLUGIN_HANDLED; 
}*/

public glosowanie(id,key)
{
	return PLUGIN_HANDLED;
}

exec_zagrzeb(id)
{
	new Float:vOrigin[ 3 ], Float:vEnd[ 3 ]
	vEnd[ 2 ] = -8192.0
	pev( id, pev_origin, vOrigin )
	engfunc( EngFunc_TraceLine, vOrigin, vEnd, 0, id, 0 )
	get_tr2( 0, TR_vecEndPos, vOrigin )
	set_pev( id, pev_origin, vOrigin )
}

public updatescoreboard()
{
	new Players[32]
	new cts, ts, total, i, id
	get_players(Players, cts, "ae", "CT") 
	get_players(Players, ts, "ae", "TERRORIST") 
	get_players(Players, total, "c") 
	for (i=0; i<total; i++) 
	{
		id = Players[i] 
		if(get_user_team(id) == 2)
			acg_updatescoreboard(id, tt_level, ct_num-ct_score, ct_level, ts, cts, 2)
		else if(get_user_team(id) == 1)
			acg_updatescoreboard(id, tt_level, tt_num-tt_score, ct_level, ts, cts, 2)
	}
}

public client_putinserver(id)
{
	if (acg_userstatus(id))
		set_task(2.0,"showsb",id)
	else
		client_print(id, print_center, "Nie korzystasz z ACG wiec nie niektore opcje nie beda dostepne")
}

public client_disconnect(id)
{
	remove_task(id)
}

public eventJoinTeam(){        
	new id = read_data(1);
	
	if(get_user_team(id) == 3 && is_user_connected(id))
	{
		acg_setscoreboardspr(id, SB_DISABLED, SB_T_CT, SB_KILL)
	}
}
		
public Spawn(id)
{
	if(is_user_connected(id) && acg_userstatus(id))
		acg_setscoreboardspr(id, SB_NORMAL, SB_T_CT, SB_KILL)
}

public DeathEvent()
{
	new vid = read_data(2);
	if(!is_user_alive(vid) && is_user_connected(vid))
		acg_setscoreboardspr(vid, SB_DISABLED, SB_T_CT, SB_KILL)
}

public showsb(id)
{
	acg_setscoreboardspr(id, SB_NORMAL, SB_T_CT, SB_KILL)
}
