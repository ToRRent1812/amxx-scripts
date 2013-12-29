#define DRAW_NORMAL (1<<0)
#define DRAW_ADDITIVE (1<<1)
#define DRAW_HOLES (1<<2)

#define FX_NONE (1<<0)
#define FX_FADE (1<<1)
#define FX_FLASH (1<<2)
#define FX_FADE_INTERVAL (1<<3)

#define ALIGN_RIGHT (1<<1)
#define ALIGN_BOTTOM (1<<2)

#define SB_DISABLED 0
#define SB_NORMAL 1
#define SB_DEATH 2
#define SB_T_CT 0
#define SB_ZB_HM 1
#define SB_ROUND 0
#define SB_KILL 1

#define TS_NONE 0
#define TS_BORDER 1
#define TS_SHADOW 2

// Function: Get a player's status(if he is using ACG or not)
// Parma(s): (1)
// - id: Target player ID
// Return (2, byte)
// - 1: The player is using Acfun Guard
// - 0: The player is not using Acfun Guard
native acg_userstatus(id);

// acg_createnotice
// Function: Create a CZ-like notice box. (Tutor)
// Parma(s): (3)
// - id: Target player ID
// - Style:
// ---- 1 :[!]Green
// ---- 2 :[×]Red
// ---- 4 :[×]Blue
// ---- 8 :[!]Yellow
// ---- 16:[!]Pink
// ---- 32:[!]Orange
// ---- 64:[!]Cyan
// ---- 128:[!]Purple
// ---- 256:[!]White
// - Text: (Must in UTF-8 if it's not English)
native acg_createnotice(id, style, const szText[]);

// acg_closenotice
// Function: Close the CZ-like notice box created before.
// Parma(s): (1)
// - id: Target player ID
native acg_closenotice(id);

// acg_setextraammo
// Function: Set the amount of "extra ammo"
// Parma(s): (2)
// - id: Target player ID
// - AmmoCount
native acg_setextraammo(id, ammocount);

// acg_showextraammo
// Function: Set "extra ammo" visible or not
// Parma(s): (2)
// - id: Target player ID
// - bVisible [1= Show, 0= Hide]
native acg_showextraammo(id, bVisible);

// acg_setextraammotext
// Function: Set the text under "extra ammo"
// Parma(s): (2)
// - id: Target player ID
// - szText: Text you want to show
// - sprAmmo: Sprite of ammo type (MUST be defined in hud.txt. This parma is the name of sprite defined in hud.txt)
native acg_setextraammotext(id, const szText[], const sprAmmo[]);

// acg_showteammate
// Function: Make the client-side ACG show the teammates' name.
// Parma(s): (2)
// - id: Player you want to enable this function.
// - bEnable: [1= Enabled, 0= Disabled]
native acg_showteammate(id, bEnable);

// acg_drawspr
// Function: Draw a sprite on screen
// Parma(s):
// - id: Target player ID
// - szSpr: Full path of the .spr file. Extension is not required.
// For example: myfolder/myspr means sprites\myfolder\myspr.spr [*] Precache is required!
// - red green blue: Saturation of Red/Green/Blue. 255 for general.
// - x y: X coord and Y coord. Range: 0.0~1.0.
// - center: Put the spr center on X coord and Y coord. [1= Yes, 0= No]
// - effects: Visual effects [FX_NONE= No effects, FX_FADE= Fade, FX_FLASH= Flash]
// - fadeintime fadeouttime: Duration of fade in/out. 0 means disabled. (unit: second)
// - fxtime: Duration of flashing. 0 means disabled. (unit: second)
// - holdtime: Hold time.(Holdtime<0 means you want to draw it all the time. Notice: On this occasion should the value of "channel" be in 0~31, and fadeout effect is NOT available)
// - (Q: Then how to stop drawing? A: Call acg_removedrawnimage)
// - mode: Mode of drawing: DRAW_NORMAL/DRAW_ADDITIVE/DRAW_HOLES
// - channel: Range: 0~999. This means you can draw 32 sprs at most at the same time. Any other value (-1, 1001 etc...) will make ACG to find an empty channel to draw spr.
native acg_drawspr(id, const szSpr[], red, green, blue, Float:x, Float:y, center,effects, Float:fadeintime, Float:fadeouttime, Float:fxtime, Float:holdtime, mode, channel=-1)

// acg_drawsprdefined
// Function: Draw a sprite which is already defined in hud.txt on screen
// Parma(s):
// - id: Target player ID
// - szSpr: Sprite name defined in hud.txt
// For example: myfolder/myspr means sprites\myfolder\myspr.spr [*] Precache is required!
// - red green blue: Saturation of Red/Green/Blue. 255 for general.
// - x y: X coord and Y coord. Range: 0.0~1.0.
// - center: Put the spr center on X coord and Y coord. [1= Yes, 0= No]
// - effects: Visual effects [FX_NONE= No effects, FX_FADE= Fade, FX_FLASH= Flash]
// - fadeintime fadeouttime: Duration of fade in/out. 0 means disabled. (unit: second)
// - fxtime: Duration of flashing. 0 means disabled. (unit: second)
// - holdtime: Hold time.(Holdtime<0 means you want to draw it all the time. Notice: On this occasion // should the value of "channel" be in 0~31, and fadeout effect is NOT available)
// - (Q: Then how to stop drawing? A: Call acg_removedrawnimage)
// - mode: Mode of drawing: DRAW_NORMAL/DRAW_ADDITIVE/DRAW_HOLES
// - channel: Range: 0~999. This means you can draw 32 sprs at most at the same time. Any other value (-1, 1001 etc...) will make ACG to find an empty channel to draw spr.
native acg_drawsprdefined(id, const szSpr[], red, green, blue, Float:x, Float:y, center,effects, Float:fadeintime, Float:fadeouttime, Float:fxtime, Float:holdtime, mode, channel=-1)

// acg_setscoreboardspr
// Function: Draw a score board on screen.
// Parma(s): (4)
// - id: Target player ID
// - backgroundtype: Type [SB_DISABLED= Disabled, SB_NORMAL= Normal mode, SB_DEATH=Death mode]
// - teamtype: Team type [SB_T_CT= Show "T/CT", SB_ZB_HM= Show "ZB/HM"]
// - round_or_kill: [SB_ROUND= Show "ROUND", SB_KILL= Show "KILL"]
native acg_setscoreboardspr(id, backgroundtype, teamtype, round_or_kill)

// acg_updatescoreboard
// Function: Update the figure on score board
// Parma(s): (7)
// - id: Target player ID
// - twins: T wins
// - round: Rounds/Total kills
// - ctwin: CT wins
// - tleft: T remaining [Only available when backgroundtype = SB_NORMAL]
// - ctleft: CT remaining[Only available when backgroundtype = SB_NORMAL]
// - reservedzeros: Digits (2~3)
native acg_updatescoreboard(id, twins, round, ctwin, tleft, ctleft, reservedzeros)

// acg_showstatstable
// Function: Open or close the stats table
// Parma(s): (3)
// - id: Target player ID
// - bEnable: [1= Enabled, 0= Disabled] (When the stats table enabled, you can use command "statswindow" to expand or shrink it.)
// - bReset: Reset the stats table? [1= Yes, 0= No] 
native acg_showstatstable(id, bEnable, bReset)

// acg_setstatstableweaponspr
// Function: Draw a specified weapon spr in the stats table
// Parma(s): (2)
// - id: Target player ID
// - szSpr: the spr defined in hud.txt.
native acg_setstatstableweaponspr(id, const szSpr[])

// acg_setstatstabletext
// Function: Set the text in the stats table
// Parma(s): (3)
// - id: Target player ID
// - line: Which line (1~4) to set?
// - szText: Text you want to show
native acg_setstatstabletext(id, line, const szText[])

// acg_statstableaddupdamagepoint
// Function: Tell the client-side ACG how many damage points the player caused.
// Parma(s): (3)
// - attacker: Attacker ID
// - victim: Victim ID
// - HealthDamaged
native acg_statstableaddupdamagepoint(id, victim, HealthDamaged)

// acg_drawoverviewradar
// Function: Enable or disable the overview radar. Notice: Only available in OpenGL mode.
// Parma(s):
// - id: Target player ID
// - bEnable: [1= Enabled, 0= Disabled]
// - bDrawAllPlayers: Draw all players including enemies? [1= Yes, 0= No]
// - bDrawBombToCT: Draw planted C4 on CTs' radar? [1= Yes, 0= No]
// - Width: Width of radar[50~300]
// - Height: Height of radar [50~300]
// - r,g,b: Red/Green/Blue color saturation of radar [0~255]
native acg_drawoverviewradar(id, bEnable, bDrawAllPlayers, bDrawBombToCT, Width, Height, r, g, b)

// acg_drawspronradar
// Function: Draw a sprite on ovewview radar.
// Parma(s):
// - id: Target player ID
// - szSpr: Full path of the .spr file. No extension is required.
// For example: myfolder/myspr means sprites\myfolder\myspr.spr [*] Precache is required!
// - red green blue: Saturation of Red/Green/Blue. 255 for general.
// - origin[3]: Origin of the object in game
// - entityid: Id of entity
// - effects: Visual effects [FX_NONE= No effects, FX_FADE= Fade, FX_FLASH= Flash]
// - fadeintime fadeouttime: Duration of fade in/out. 0 means disabled. (unit: second)
// - fxtime: Duration of flashing. 0 means disabled. (unit: second)
// - holdtime: Hold time.(Holdtime<0 means you want to draw it all the time. Notice: On this occasion // should the value of "channel" be in 0~31, and fadeout effect is NOT available)
// - (Q: Then how to stop drawing? A: Call acg_removedrawnimage)
// - mode: Mode of drawing: DRAW_NORMAL/DRAW_ADDITIVE/DRAW_HOLES
// - channel: Range: 0~999. This means you can draw 1000 sprs at most at the same time. Any other value // (-1, 1001 etc...) will make ACG to find an empty channel to draw spr.
// - alwaysdraw:
// alwaysdraw = 1: When the object is out of radar sight, draw it on border.
// alwaysdraw = 0: When the object is out of radar sight, don't draw it.
native acg_drawspronradar(id, const szSpr[], red, green, blue, origin[3]={0,0,0}, entityid, effects, Float:fadeintime, Float:fadeouttime, Float:fxtime, Float:holdtime, mode, channel, alwaysdraw)

// acg_drawdefinedspronradar
// Function: Draw a sprite which is already defined in hud.txt on ovewview radar.
// Parma(s):
// - id: Target player ID
// - szSpr: Full path of the .spr file. No extension is required.
// For example: myfolder/myspr means sprites\myfolder\myspr.spr [*] Precache is required!
// - red green blue: Saturation of Red/Green/Blue. 255 for general.
// - origin[3]: Origin of the object in game.
// - entityid: Id of entity
// - effects: Visual effects [FX_NONE= No effects, FX_FADE= Fade, FX_FLASH= Flash]
// - fadeintime fadeouttime: Duration of fade in/out. 0 means disabled. (unit: second)
// - fxtime: Duration of flashing. 0 means disabled. (unit: second)
// - holdtime: Hold time.(Holdtime<0 means you want to draw it all the time. Notice: On this occasion // should the value of "channel" be in 0~31, and fadeout effect is NOT available)
// - (Q: Then how to stop drawing? A: Call acg_removedrawnimage)
// - mode: Mode of drawing: DRAW_NORMAL/DRAW_ADDITIVE/DRAW_HOLES
// - channel: Range: 0~999. This means you can draw 1000 sprs at most at the same time. Any other value // (-1, 1001 etc...) will make ACG to find an empty channel to draw spr.
// - alwaysdraw:
// alwaysdraw = 1: When the object is out of radar sight, draw it on border.
// alwaysdraw = 0: When the object is out of radar sight, don't draw it.
native acg_drawdefinedspronradar(id, const szSpr[], red, green, blue, origin[3]={0,0,0}, entityid, effects, Float:fadeintime, Float:fadeouttime, Float:fxtime, Float:holdtime, mode, channel=-1, alwaysdraw)
			
// acg_removedrawnimage
// Function: Remove a picture or text being drawn by Acfun Guard
// Parma(s):
// - id: Target player ID
// - whichnative: Being drawn by which native?
// 0 = acg_drawspr/definedspr
// 1 = acg_drawspronradar/drawdefinedspronradar
// 2 = acg_drawtga
// 3 = acg_drawtext
// 4 = acg_drawentityicon/acg_drawentityicondefined
// 5 = acg_screenfade
// - channel: The channel number of the picture
native acg_removedrawnimage(id, whichnative, channel)

// acg_setviewentityofbody
// Function: Change the camera position of player body
// Parma(s):
// - id: Target player ID
// - bchanged: Make your change enabled? [1=Yes 0=No]
// - body: position
native acg_setviewentityofbody(id, bchanged, body)

// acg_setviewentityrenderingmode
// Function: Change some parameters of view entity
// Parma(s):
// - id: Target player ID
// - bchanged: Make your change enabled? [1=Yes 0=No]
// - rendermode: Render mode
// [kRenderNormal/kRenderTransColor/kRenderTransTexture/kRenderGlow/
// kRenderTransAlpha/kRenderTransAdd]
// - renderfx: Render FX (from HLSDK 2.1)
// enum
// {
// kRenderFxNone = 0,
// kRenderFxPulseSlow,
// kRenderFxPulseFast,
// kRenderFxPulseSlowWide,
// kRenderFxPulseFastWide,
// kRenderFxFadeSlow,
// kRenderFxFadeFast,
// kRenderFxSolidSlow,
// kRenderFxSolidFast,
// kRenderFxStrobeSlow,
// kRenderFxStrobeFast,
// kRenderFxStrobeFaster,
// kRenderFxFlickerSlow,
// kRenderFxFlickerFast,
// kRenderFxNoDissipation,
// kRenderFxDistort,
// kRenderFxHologram,
// kRenderFxDeadPlayer,
// kRenderFxExplode,
// kRenderFxGlowShell,
// kRenderFxClampMinScale,
// };
// - renderamt: Render amount (0~255)
// - red, green, blue: Saturation of Red/Green/Blue. 255 for general.
native acg_setviewentityrenderingmode(id, bchanged, rendermode, renderfx, renderamt, red, green, blue)

// Function: Draw a picture in TGA format.
// Notice: Only available in OpenGL mode. TGA files should be precached by acg_precachetga first.
// - id: Target player ID
// - szTGA: Full path of the .tga file. Extension is not required.
// e.g. "mypicture" means you want to draw "gfx\mypicture.tga"
// - NOTICE: TGA should be placed in [GAME]\gfx folder.
// - [GAME] stands for game mode. For example, if you play Counter-Strike, [GAME] = cstrike.
// - red green blue: Saturation of Red/Green/Blue. 255 for general.
// - alpha: Transparency (0~255)
// - x y: X coord and Y coord. Range: 0.0~1.0.
// - center: Put the spr center on X coord and Y coord. [1= Yes, 0= No]
// - effects: Visual effects [FX_NONE= No effects, FX_FADE= Fade, FX_FLASH= Flash]
// - fadeintime fadeouttime: Duration of fade in/out. 0 means disabled. (unit: second)
// - fxtime: Duration of flashing. 0 means disabled. (unit: second)
// - holdtime: Hold time.(Holdtime<0 means you want to draw it all the time. Notice: On this occasion. should the value of "channel" be in 0~31, and fadeout effect is NOT available)
// - (Q: Then how to stop drawing? A: Call acg_removedrawnimage)
// - mode: Mode of drawing: DRAW_NORMAL/DRAW_ADDITIVE/DRAW_HOLES
// - bfullscreen: Stretch picture to full screen? [1=Yes 0=No]
// - align: Alignment [0= None, ALIGN_RIGHT = X coord counts from right, ALIGN_BOTTOM = Y coord counts. from bottom, ALIGN_RIGHT|ALIGN_BOTTOM = Two combined]
// - channel: Range: 0~999. This means you can draw 32 pictures at most at the same time. Any other. value (-1, 1001 etc...) will make ACG to find an empty channel to draw TGA.
native acg_drawtga(id, const szTGA[], red, green, blue, alpha, Float:x, Float:y, center, effects, Float:fadeintime, Float:fadeouttime, Float:fxtime, Float:holdtime, mode, bfullscreen, align, channel)
			
// acg_replacesound
// Function: Replace sound
// Parma(s):
// - id: Target player ID
// - bEnabled: Make change enabled? [1=Yes 0=No]
// - Entity: Replace sound given out by this entity. 0 for all entities.
// - Channel: Range: 0~511. This means you can replace 512 sounds at most at the same time.
// - szOriginal: Sound to replace e.g. weapons/ak47-2.wav
// - szReplaced: Sound to play e.g. weapons/knife_hitwall1.wav
native acg_replacesound(id, bEnabled, Entity, Channel, szOriginal[], szReplaced[])

// Function: Draw a text on screen
// Parma(s):
// - x y: X coord and Y coord. Range: 0.0~1.0.
// - szText: Text to draw
// - r g b alpha: Saturation of Red/Green/Blue/Transparent. 255 for general.
// - fadeintime fadeouttime: Duration of fade in/out. 0 means disabled. (unit: second)
// - holdtime: Hold time.(Holdtime<0 means you want to draw it all the time. Notice: On this occasion should the value of "channel" be in 0~31.)
// - (Q: Then how to stop drawing? A: Call acg_removedrawnimage)
// - center: Put the spr center on X coord and Y coord. [1= Yes, 0= No]
// - style: TS_NONE = No style, TS_BORDER = Text with border, TS_SHADOW = Text with shadow
// - inlinecolor: Enable \r, \y, \b, etc.. to control text color [1=Yes 0=No]
// - background: Draw a translucent black background. [1=Yes 0=No]
// - channel: Range: 0~31. This means you can draw 32 text at most at the same time. Any other value (-1, 33, 35, etc...) are not accepted.
native acg_drawtext(id, Float:x, Float:y, szText[], r, g, b, alpha, Float:fadeintime, Float:fadeouttime, Float:holdtime, center, style, inlinecolor, background, channel)

// Function: Bind a font to the channel for acg_drawtext.
// Notice: Call this native once and everything is OK. There is no need calling acg_initfont before acg_drawtext next time. OpenGL only.
// Parma(s):
// - id: Target player ID
// - fontname: Font name. Empty for system default font.
// - size: Font size. [72 pond= 56, 9 pond= 12]
// - bold: [1= Yes, 0= No]
// - italic:[1= Yes, 0= No]
// - underline: [1= Yes, 0= No]
// - channel: Range: 0~31. This means you can draw 32 text at most at the same time. Any other value (-1, 33, 35, etc...) are not accepted.
native acg_initfont(id, const fontname[] = "", size, bold, italic, underline, channel)

// Function: Draw a spr to indicate the position of an entity
// Parma(s):
// - id: Target player ID
// - spr: Full path of the .spr file. No extension is required.
// For example: myfolder/myspr means sprites\myfolder\myspr.spr [*] Precache is required!
// - r g b: Saturation of Red/Green/Blue. 255 for general.
// - bmeter: Display the distance between player and entity. Unit: meter
// - tr tg tb: Saturation of Red/Green/Blue of meter text. 255 for general.
// - float:origin[3]: Coord of the object in game.
// - holdtime: Hold time.(Holdtime<0 means you want to draw it all the time.)
// - (Q: Then how to stop drawing? A: Call acg_removedrawnimage)
// - mode: Mode of drawing: DRAW_NORMAL/DRAW_ADDITIVE/DRAW_HOLES
// - channel: Range: 0~63. This means you can draw 64 sprs at most at the same time. Any other value will make ACG to find an empty channel to draw spr. (share channel with acg_drawentityicondefined)
native acg_drawentityicon(id, spr[], r, g, b, bmeter, tr, tg, tb, Float:origin[3] = {0.0,0.0,0.0}, entityid, Float:holdtime, mode, channel)

// Function: Draw a spr to indicate the position of an entity (spr is defined in hud.txt)
// Parma(s):
// - id: Target player ID
// - spr: Sprite name defined in hud.txt
// - r g b: Saturation of Red/Green/Blue. 255 for general.
// - bmeter: Display the distance between player and entity. Unit: meter
// - tr tg tb: Saturation of Red/Green/Blue of meter text. 255 for general.
// - float:origin[3]: Coord of the object in game.
// - holdtime: Hold time.(Holdtime<0 means you want to draw it all the time.)
// - (Q: Then how to stop drawing? A: Call acg_removedrawnimage)
// - mode: Mode of drawing: DRAW_NORMAL/DRAW_ADDITIVE/DRAW_HOLES
// - channel: Range: 0~63. This means you can draw 64 sprs at most at the same time. Any other value will make ACG to find an empty channel to draw spr. (share channel with acg_drawentityicon)
native acg_drawentityicondefined(id, spr[], r, g, b, bmeter, tr, tg, tb, Float:origin[3] = {0.0,0.0,0.0}, entityid, Float:holdtime, mode, channel)

// Function: Create a screen fade just like what ScreenFade message does.
// Parma(s):
// - id: Target player ID
// - r g b a: Red/Green/Blue/Alpha
// - holdtime: Hold time.
// (Holdtime<0 means you want to fade all the time. Notice: On this occasion the fadeout effect is NOT available)
// (Q: Then how to stop drawing? A: Call acg_removedrawnimage)
// - fadeintime fadeouttime: Duration of fade in/out. 0 means disabled. (unit: second)
native acg_screenfade(id, r, g, b, a, Float:holdtime, Float:fadeintime, Float:fadeouttime) 
