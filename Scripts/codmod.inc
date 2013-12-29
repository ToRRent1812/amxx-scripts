#if defined _codmod_included
  #endinput
#endif
#define _codmod_included

#define COD_CONTINUE 0

#define COD_STOP 4

#define DMG_CODSKILL (1<<31)

#define COD_MSG_HUD set_hudmessage(255, 255, 60, 0.14, 0.02, 0, 0.0, 0.3, 0.0, 0.0, -1)
#define COD_MSG_NEWS_P set_hudmessage(200, 120, 0, -1.00, 0.25, 0, 0.4, 3.0, 0.2, 0.3, -1)
#define COD_MSG_NEWS_N set_hudmessage(200, 50, 0, -1.00, 0.27, 0, 0.4, 3.0, 0.2, 0.3, -1)
#define COD_MSG_SKILL_K set_hudmessage(0, 212, 255, 0.04, 0.69, 0, 6.0, 0.5, _, _, -1)
#define COD_MSG_SKILL_D set_hudmessage(0, 212, 255, 0.04, 0.69, 0, 6.0, 4.0, _, _, -1)

native cod_get_user_xp(id);
/*------------------------------
Zwraca doswiadczenie gracza
------------------------------*/


native cod_get_user_level(id);
/*------------------------------
Zwraca poziom gracza
------------------------------*/


native cod_get_user_points(id)
/*------------------------------
Zwraca punkty gracza
------------------------------*/


native cod_set_user_xp(id, wartosc);
/*------------------------------
Ustawia doswiadczenie gracza
------------------------------*/


native cod_get_user_class(id);
/*------------------------------
Zwraca klase gracza
------------------------------*/


native cod_set_user_class(id, klasa, zmien=0);
/*------------------------------
Ustawia klase gracza, 
jezeli zmien=1 zmienia ja natychmiast
------------------------------*/


native cod_get_user_perk(id, &wartosc=0);
/*------------------------------
Zwraca perk gracza, 
oraz przypisuje zmiennej wartosc perku
------------------------------*/


native cod_set_user_perk(id, perk, wartosc=-1, pokaz_info=1);
/*------------------------------
Ustawia perk gracza. 
Jezeli wartosc = -1,
wartosc perku bedzie losowa.
Jezeli perk = -1 perk
bedzie losowy
------------------------------*/


native cod_get_user_health(id, zdrowie_zdobyte=1, zdrowie_klasy=1, zdrowie_bonusowe=1);
/*------------------------------
Zwraca punkty statystyki zdrowie
------------------------------*/


native cod_set_user_bonus_health(id, wartosc);
/*------------------------------
Ustawia dodatkowe punkty statystyki zdrowie
------------------------------*/


native cod_get_user_intelligence(id, inteligencja_zdobyta=1, inteligencja_klasy=1, inteligencja_bonusowa=1);
/*------------------------------
Zwraca punkty statystyki inteligencja
------------------------------*/


native cod_set_user_bonus_intelligence(id, wartosc);
/*------------------------------
Ustawia dodatkowe punkty statystyki inteligencja
------------------------------*/


native cod_get_user_trim(id, kondycja_zdobyta=1, kondycja_klasy=1, kondycja_bonusowa=1);
/*------------------------------
Zwraca punkty statystyki kondycja
------------------------------*/


native cod_set_user_bonus_trim(id, wartosc);
/*------------------------------
Ustawia dodatkowe punkty statystyki kondycja
------------------------------*/


native cod_get_user_stamina(id, wytrzymalosc_zdobyta=1, wytrzymalosc_klasy=1, wytrzymalosc_bonusowa=1);
/*------------------------------
Zwraca punkty statystyki wytrzymalosc
------------------------------*/


native cod_set_user_bonus_stamina(id, wartosc);
/*------------------------------
Ustawia dodatkowe punkty statystyki wytrzymalosc
------------------------------*/

native cod_get_user_gravity(id, grawitacja_zdobyta=1, grawitacja_klasy=1, grawitacja_bonusowa=1);
/*------------------------------
Zwraca punkty statystyki grawitacja
------------------------------*/

native cod_set_user_bonus_gravity(id, wartosc);
/*------------------------------
Ustawia dodatkowe punkty statystyki grawitacja
------------------------------*/

native cod_get_user_reload(id, przeladowanie_zdobyte=1, przeladowanie_klasy=1, przeladowanie_bonusowe=1);
/*------------------------------
Zwraca punkty statystyki przeladowanie
------------------------------*/

native cod_set_user_bonus_reload(id, wartosc);
/*------------------------------
Ustawia dodatkowe punkty statystyki przeladowanie
------------------------------*/

native cod_get_user_regeneration(id, regeneracja_zdobyta=1, regeneracja_klasy=1, regeneracja_bonusowa=1);
/*------------------------------
Zwraca punkty statystyki regeneracja
------------------------------*/

native cod_set_user_bonus_regeneration(id, wartosc);
/*------------------------------
Ustawia dodatkowe punkty statystyki regeneracja
------------------------------*/

native cod_points_to_health(id, ilosc);
/*------------------------------
Przydziela punkty do statystyki zdrowie
------------------------------*/


native cod_points_to_intelligence(id, ilosc);
/*------------------------------
Przydziela punkty do statystyki inteligencja
------------------------------*/


native cod_points_to_trim(id, ilosc);
/*------------------------------
Przydziela punkty do statystyki kondycja
------------------------------*/


native cod_points_to_stamina(id, ilosc);
/*------------------------------
Przydziela punkty do statystyki wytrzymalosc
------------------------------*/

native cod_points_to_gravity(id, ilosc);
/*------------------------------
Przydziela punkty do statystyki grawitacja
------------------------------*/

native cod_points_to_reload(id, ilosc);
/*------------------------------
Przydziela punkty do statystyki przeladowanie
------------------------------*/

native cod_points_to_regeneration(id, ilosc);
/*------------------------------
Przydziela punkty do statystyki regeneracja
------------------------------*/

native cod_inflict_damage(atakujacy, ofiara, Float:obrazenia, Float:czynnik_inteligencji=1.0, byt_uszkadzajacy=0, dodatkowe_flagi=0);
/*------------------------------
Zadaje obrazenia z uwzglednieniem inteligencji
------------------------------*/


native cod_get_perkid(const nazwa_perku[]);
/*------------------------------
Zwaca numer perku o podanej nazwie
------------------------------*/


native cod_get_perks_num();
/*------------------------------
Zwaca ilosc perkow
------------------------------*/


native cod_get_perk_name(perk, Return[], len);
/*------------------------------
Kopiuje nazwe perku do Return
------------------------------*/


native cod_get_perk_desc(perk, Return[], len);
/*------------------------------
Kopiuje opis perku do Return
------------------------------*/


native cod_get_classid(const nazwa_klasy[]);
/*------------------------------
Zwaca numer klasy o podanej nazwie
------------------------------*/


native cod_get_classes_num();
/*------------------------------
Zwaca ilosc klas
------------------------------*/

native cod_get_class_name(class, Return[], len);
/*------------------------------
Kopiuje nazwe klasy do Return
------------------------------*/


native cod_get_class_desc(class, Return[], len);
/*------------------------------
Kopiuje opis klasy do Return
------------------------------*/


native cod_give_weapon(id, bron);
/*------------------------------
Daje okreslona bron oraz pozwala na jej posiadanie
------------------------------*/


native cod_take_weapon(id, bron);
/*------------------------------
Zabiera okreslona bron oraz zabrania jej posiadania
------------------------------*/


native cod_set_user_shield(id, wartosc);
/*------------------------------
Ustawia tarcze gracza. 
------------------------------*/


native cod_set_user_nightvision(id, wartosc);
/*------------------------------
Ustawia noktowizor gracza. 
------------------------------*/


native cod_register_perk(const nazwa[], const opis[], min_wartosc=0, max_wartosc=0);
/*------------------------------
Rejestruje nowy perk oraz zwraca jego numer
------------------------------*/

native cod_register_class(const nazwa[], const opis[], punkty_grawitacji, punkty_zdrowia, punkty_kondycji, punkty_inteligencji, punkty_wytrzymalosci, punkty_przeladowania, punkty_regeneracji, const nazwa_kodowa[]);
/*------------------------------
Rejestruje nowa klase oraz zwraca jej numer
------------------------------*/

native cod_get_level_xp(poziom);
/*------------------------------
Zwraca ilosc potrzebnego doswiadczenia do przejscia danego poziomu
------------------------------*/

native cod_get_class_health(id_klasy)
/*------------------------------
Zwraca podstawowa wartosc zdrowia klasy
------------------------------*/

native cod_get_class_intelligence(id_klasy)
/*------------------------------
Zwraca podstawowa wartosc inteligencji klasy
------------------------------*/

native cod_get_class_trim(id_klasy)
/*------------------------------
Zwraca podstawowa wartosc kondycji klasy
------------------------------*/

native cod_get_class_stamina(id_klasy)
/*------------------------------
Zwraca podstawowa wartosc wytrzymalosci klasy
------------------------------*/

native cod_get_class_gravity(id_klasy)
/*------------------------------
Zwraca podstawowa wartosc grawitacji klasy
------------------------------*/

native cod_get_class_reload(id_klasy)
/*------------------------------
Zwraca podstawowa wartosc przeladowania klasy
------------------------------*/

native cod_get_class_regeneration(id_klasy)
/*------------------------------
Zwraca podstawowa wartosc regeneracji klasy
------------------------------*/

native cod_show_exp_reward(id, exp_reward, za_co[])
/*------------------------------
Pokazuje w exp barze ile i za co dostalismy exp
------------------------------*/

forward cod_perk_changed(id, perk);
/*------------------------------
Forward wysylany do wszystkich pluginow w momencie zmiany perku
------------------------------*/


forward cod_class_changed(id, klasa);
/*------------------------------
Forward wysylany do wszystkich pluginow w momencie zmiany klasy
------------------------------*/


forward cod_perk_enabled(id, wartosc, perk);
/*------------------------------
Forward wysylany do pluginu z ktorego zarejestrowany jest perk w momencie aktywacji
------------------------------*/


forward cod_perk_disabled(id, perk);
/*------------------------------
Forward wysylany do pluginu z ktorego zarejestrowany jest perk w momencie dezaktywacji
------------------------------*/


forward cod_perk_used(id);
/*------------------------------
Forward wysylany do pluginu z ktorego zarejestrowany jest perk w momencie uzycia perku
------------------------------*/


forward cod_class_enabled(id, klasa);
/*------------------------------
Forward wysylany do pluginu z ktorego zarejestrowana jest klasa w momencie aktywacji
------------------------------*/


forward cod_class_disabled(id, klasa);
/*------------------------------
Forward wysylany do pluginu z ktorego zarejestrowana jest klasa w momencie dezaktywacji
------------------------------*/

forward cod_class_skill_used(id);
/*------------------------------
Forward wysylany do pluginu z ktorego zarejestrowana jest klasa w momencie uzycia umiejetnosci klasy
------------------------------*/

