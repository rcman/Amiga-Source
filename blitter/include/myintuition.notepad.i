    T
     è  vòhó* intuition screen & window setup
*

* Paramaters Screen & Window
*	\1 - Title
*	\2 - Width
*	\3 - Height
*	\4 - # of Bit Planes (Screen only)
*	\4 - On Custom Screen Y/N (Window only)

Screen		MACRO
sname:		dc.b	\1	;Screen Title
		dc.b	0
		cnop 0,2
screen:
x_pos:		dc.w    0	;x-position
y_pos:		dc.w    0	;y-position
width:		dc.w    \2	;width
height:		dc.w    \3	;height
depth:		dc.w    \4	;Number of Bit Planes 2
detail_pen:	dc.b    1	;Text Colour equ  White
block_pen:	dc.b    3	;Backg    T
     è  v	ƒçround Color equ  Red
view_modes:	dc.w    2	;Representation Mode
screen_types:	dc.w    15	;Screen Type:Custom Screen
font:		dc.l    0	;Standard Character Set
title:		dc.l    sname	;Pointer to title text
gadgets:	dc.l    0	;No gadgets
bitmap:		dc.l    0	;No Bit Map
		dc.l	0
bitplane1:	dc.l	0
bitplane2:	dc.l	0
bitplane3:	dc.l	0
bitplane4:	dc.l	0
bitplane5:	dc.l	0
bitplane6:	dc.l	0
		IFND	ScreenHandle
screenhd:	dc.l	0
		ENDC

		ENDM

WindowNOB	MACRO
windowhd:	dc.l	0

		IFNC	'\1','0'
wnam    T
     è  v
–”e:		dc.b	\1	;Window Title
		dc.b	0
		cnop 0,2
		ENDC

window:		dc.w	0,0
		dc.w	\2
		dc.w	\3
		dc.b	0,1
		dc.l	0		; flags
		dc.l	$1800		; active and borderless
		dc.l	0
		dc.l	0
		IFNC	'\1','0'
		dc.l	wname
		ENDC
		IFC	'\1','0'
		dc.l	0
		ENDC
		IFC	'A\4','AY'
screenhd:	dc.l	0
ScreenHandle	equ	1
		ENDC
		IFNC	'A\4','AY'
		dc.l	0
		ENDC
		dc.l	0		; Bitmap
		dc.w	0,0		; Min W & H
		dc.w	\2		; Max W
		dc.w	\3		; Max H

		IFC	'A\4','AY'
		dc.w	$f
		ENDC
		IFNC	'A\4','AY'
		dc.w	1
		ENDC
    T
     è  vš8
		dc.l	0,0
		ENDM

OpenIntuition	MACRO
		lea	intname(pc),a1
		move.l	$4,a6
		jsr	-408(a6)
		move.l	d0,intbase
		ENDM

OpenScreen	MACRO
		lea	screen(pc),a0
		move.l	intbase,a6
		jsr	-198(a6)
		move.l	d0,screenhd
		ENDM

OpenWindow	MACRO
		lea	window(pc),a0
		move.l	intbase,a6
		jsr	-204(a6)
		move.l	d0,windowhd
		ENDM

CloseWindow	MACRO
		move.l	windowhd,a0
		move.l	intbase,a6
		jsr	-72(a6)
		ENDM

CloseScreen	MACRO
		move.l	screenhd,a0
		move.l	intbase,a6
		jsr	-66(a6)
		ENDM

Close    T
     è  vˆê	`Intuition	MACRO
		move.l	intbase,a1
		move.l	$4,a6
		jsr	-414(a6)
		ENDM

GetViewPortAddress	MACRO
		move.l	windowhd,a0
		move.l	intbase,a6
		jsr	-300(a6)
		move.l	a0,viewport
		ENDM

GetRastPort	MACRO
		move.l	windowhd,a1
		move.l	50(a1),rastport
		ENDM

		IFND	buttonsaway123
WaitForButton	MACRO
waitforbutton\1:
		btst.b	#6+0\1,$bfe001
		bne.s	waitforbutton\1
buttonsaway123	equ	1
		ENDM
		ENDC

SetupIntui