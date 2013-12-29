#include <amxmodx>
#include <dhudmessage>

new ctwin = 0, twin = 0;
new mapname[32];

public plugin_init() {
	register_plugin("ScoreBoard", "0.4", "ToRRent")
	register_event("TeamScore","calc_teamscore","a") 
	set_task(2.0,"Update_ScoresBoard",_,_,_,"b")
}
public calc_teamscore()
{
		new parm[16] 
		read_data(1,parm,charsmax(parm)) 
		if (parm[0] == 'T')
			twin = read_data(2) 
		else
			ctwin = read_data(2) 
}

public Update_ScoresBoard()
{
	new Players[32]
	new cts, ts, total, i, id
	get_players(Players, cts, "ae", "CT") 
	get_players(Players, ts, "ae", "TERRORIST") 
	get_players(Players, total, "c") 
	for (i=0; i<total; i++) 
	{
		id = Players[i] 
		set_dhudmessage(255, 255, 0, -1.0, 0.01, 0, 0.0, 6.0, 0.0, 3.0)
		show_dhudmessage(id, "TT %i:%i CT^n%i Zywych %i", twin, ctwin, ts, cts);
	}
}
