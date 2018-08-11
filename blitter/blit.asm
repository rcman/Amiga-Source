

  include	"include/button.i"


;Demo program to open and move a screen
movescreen  	equ	 -162
openscreen  	equ	 -198
openwindow	equ	 -204
closewindow	equ	 -72
closescreen 	equ	 -66
closelibrary 	equ	 -414
openlib     	equ	 -408      ;open library
execbase    	equ	  4        ;EXEC base address
availfonts	equ	 -36
opendiskfont	equ	 -30
setfont		equ	 -66
closefont	equ	 -78
scrollraster	equ	 -396
viewportaddress equ	-300 
setApen		equ	-342

text		equ 	-216

joy2        	equ	 $dff00c   ;joystick 2 Data
fire        	equ	 $bfe001   ;fire button 2:Bit 7
setrgb4     	equ 	 -288
scrollval	equ	2




run:
        OpenIntuition
	IFERROR	errorint
        bsr     scropen         ;Open Screen
	IFERROR	errorscr
	bsr	openwin
	IFERROR	errorwin

	move.l	windowhd,a0
	move.l	intbase,a6
	jsr	viewportaddress(a6)
	move.l	a0,viewport


	

       move.l  #0,d0           ;pen
       move.l  #0,d1           ;red
       move.l  #0,d2           ;green
       move.l  #0,d3           ;blue
       move.l  viewport,a0     ;Get Pointer to View Port
       move.l  gfxbase,a6      ;get grapics base
       jsr     setrgb4(a6)     ;set a color registor

       move.l  #2,d0           ;pen
       move.l  #10,d1           ;red
       move.l  #10,d2           ;green
       move.l  #10,d3           ;blue
       move.l  viewport,a0     ;Get Pointer to View Port
       move.l  gfxbase,a6      ;get grapics base
       jsr     setrgb4(a6)     ;set a color registor




	WaitButton	1




ende:
       bsr	closewin
errorwin:
       bsr     scrclose        ;close screen
errorscr:
       bsr     closeint        ;close intuition
errorint:	       
	rts                     ;Done !

openwin:
	move.l	intbase,a6
	lea	window(pc),a0
	jsr	openwindow(a6)
	move.l	d0,a1
	move.l	50(a1),rastport
	move.l	d0,windowhd
	rts

closewin:
	move.l intbase,a6
	move.l	windowhd,a0
	jsr 	closewindow(a6)
	rts





closeint:
       move.l  execbase,a6     ;*close Intuition
       move.l  intbase,a1      ;intuition base address in A1
       jsr     closelibrary(a6);close intuition
       rts                     ;Done
scropen:
       move.l  intbase,a6      ;Intuition base address in A6
       lea     screen_defs,a0  ;Pointer to Table
       jsr     openscreen(a6)  ;OPen
       move.l  d0,a0           ;get screen pointer ready
       move.l  $c0(a0),bitplane1       ;get pointer to bit plane # 1
       move.l  $c4(a0),bitplane2       ;get pointer to bit plane # 2
;       move.l  $2c(a0),viewport        ;get pointer to view port
       move.l  d0,screenhd     ;Save Screen Handle
       rts                     ;Return to Main Program
scrclose:
       move.l  intbase,a6      ;Intuition base address in A6
       move.l  screenhd,a0     ;Screen Handle in A0
       jsr     closescreen(a6) ;And Move
       rts                     ;Done

opengfx:
       move.l  execbase,a6     ;EXEC base address
       lea     gfxname,a1      ;name of graphics library
       jsr     openlib(a6)     ;Open graphics library
       move.l  d0,gfxbase      ;Save graphics base address
	rts


screen_defs:
x_pos:         dc.w    0       ;x-position
y_pos:         dc.w    0       ;y-position
width:         dc.w    320     ;width
height:        dc.w    200     ;height
depth:         dc.w    4       ;Number of Bit Planes 2
detail_pen:    dc.b    0       ;Text Colour  equ  White
block_pen:     dc.b    1       ;Background Color  equ  Red
view_modes:    dc.w    2       ;Representation Mode
screen_types:  dc.w    15      ;Screen Type:Custom Screen
font:          dc.l    0       ;Standard Character Set
title:         dc.l    0       ;Pointer to title text
gadgets:       dc.l    0       ;No gadgets
bitmap:        dc.l    0       ;No Bit Map
intbase:       dc.l    0       ;Base Address of Intuition
;screenhd:      dc.l    0       ;Screen Handle
intname:       dc.b    'intuition.library',0
       cnop 0,2
gfxname:       dc.b    'graphics.library',0
       cnop 0,2

sname:         dc.b    'Our Screen',0 ;Screen Title
       cnop 0,2
diskfname:       dc.b    'diskfont.library',0
       cnop 0,2
myfont24:		dc.l	0
myfont15:		dc.l	0

mytext:
color:		dc.b	1,0
		dc.b	1
		dc.w	16
		dc.w	2
		dc.l	0
textname:	dc.l	0
		dc.l	0

;structure font contents

textattr:
		dc.l	helvetica
		dc.w	24
		dc.b	0
		dc.b	2

textattr2:
		dc.l	helvetica
		dc.w	15
		dc.b	0
		dc.b	2

helvetica:

		dc.b	'helvetica.font',0
		dc.l	0


fontbase:	dc.l	0

rastport:      dc.l    0
viewport:      dc.l    0
gfxbase:       dc.l    0
ycoor:		dc.l	200
bitplane1:     dc.l    0
bitplane2:     dc.l    0

numc:		dc.l	13
windowhd:	dc.l	0
window:		dc.w	0,0
		dc.w	320,200
		dc.b	0,1
		dc.l	0
		dc.l	$1800		; active and borderless
		dc.l	0
		dc.l	0
		dc.l	0 ;scroll
screenhd:	dc.l	0
		dc.l	0
		dc.w	0,0
		dc.w	320,200
		dc.w	$f

scroll:		dc.b	' ',0





