; ob Attempt
;  include "exec/types.i"
;  include "intuition/intuition.i"
;  include "graphics/gels.i"
;  include "graphics/rastport.i"

viewportaddress equ -300
closewindow equ -72
movescreen  equ -162
openscreen  equ -198
openwindow  equ -204
closescreen equ -66
closelibrary equ -414
openlib     equ -408      ;open libraryrta 
execbase    equ  4        ;EXEC base address
joy2        equ $dff00c   ;joystick 2 Data
fire        equ $bfe001   ;fire button 2:Bit 7
setrgb4     equ  -288
AddBob		equ	-96
DrawGList	equ	-114
InitGels	equ	-120
InitMasks	equ	-126
SortGList	equ	-150
RastPort	equ	50
gi_collHandler	equ	18
vs_VSBob	equ	$34
draw		equ 	-180
setApen		equ	-342

run:
       bsr     openint         ;Open library
	bsr	opengfx
       bsr     scropen         ;Open Screen
	bsr 	windowopen

	move.l	raster,a1
	move.l	#160,d0
	move.l	#100,d1
	move.l	#60,d2
	move.l	#60,d3
	move.l	gfxbase,a6
	jsr	draw(a6)

	nop
	nop


setcolor:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	#1,d0
	move.l	raster,a1
	move.l	gfxbase,a6
	jsr	setApen(a6)
	movem.l	(sp)+,d0-d7/a0-a6


;	bra	ende



       
;	lea 	gelinfo(pc),a2


;	move.l	#0,10(a2)
;	move.l	#0,14(a2)
;	lea 	colltable(pc),a4
;	move.l	a4,gi_collHandler(a2)


	lea 	gelinfo(pc),a2
	move.l	raster,a4
	move.l  a2,20(a4)		; works up to this point


	lea	vshead(pc),a0
	lea	vstail(pc),a1
	move.l	gfxbase,a6	
 	jsr	InitGels(a6)


;	lea 	bob,a1
	lea	v,a0
;	move.l	a1,vs_VSBob(a0)



	move.l	gfxbase,a6
	jsr	InitMasks(a6)

	lea	bob,a1
	move.l	a1,pbob
	move.w	#0,(a1)			; flags for bob
	lea	cmask,a2		; get pointer
	move.l	a2,6(a1)		; coll mask
	lea	v,a2			; address to vsprite
	move.l	a2,$12(a1)		; save it to bob
	move.l	#0,$a(a1)		; Before
	move.l	#0,$e(a1)		; After
	move.l	#0,$16(a1)		; animation comp 
	move.l	#0,$1a(a1)		; Double Buffer
	move.b	#3,56(a2)		; plane pic for bob
	move.b  #0,57(a2)		; plane on/off for bob

	lea 	bob,a1
	move.l  a1,a0
	move.l	raster,a1
	move.l	gfxbase,a6
	jsr	AddBob(a6)

	move.l	raster,a1
	move.l	gfxbase,a6
	jsr	SortGList(a6)


	move.l	raster,a1
	move.l	viewport,a0
	move.l	gfxbase,a6
	jsr	DrawGList(a6)

 
;       move.l  bitplane1,a1
;       add.l   #4019,a1

;       lea     man(pc),a2
;       moveq   #13,d0
placeman:
;       move.b  (a2)+,(a1)      ;place man data on the screen
;       move.b  (a2)+,1(a1)     ;place man data on the screen
;       add.l   #40,a1          ;move plane pointer down one scan line
;       dbra    d0,placeman

        move.l  #0,d0          ;pen
        move.l  #0,d1           ;red
        move.l  #0,d2           ;green
        move.l  #0,d3           ;blue
        move.l  viewport,a0     ;Get Pointer to View Port
        move.l  gfxbase,a6      ;get grapics base
        jsr     setrgb4(a6)     ;set a color registor

        move    joy2,d6         ;Save Joystick Info

loop:
        tst.b   fire            ;Test Fire Button
        bpl     ende            ;Press Down:Done
        move    joy2,d0         ;Basic info D0
        sub     d6,d0           ;Subtract Nw Data
        cmp     #$0100,d0       ;Up?
        bne     noup            ;No
        move.l  #-2,d1          ;dy equ -2 direction Y
        bsr     scrmove         ;Move Up
        bra     loop

noup:

        cmp     #$0001,d0       ;Down?
        bne     loop            ;No
        move.l  #2,d1           ;dy equ 2
        bsr     scrmove         ;move down
        bra     loop

ende:

	bsr    windowclose
        bsr     scrclose        ;close screen
	bsr	closegfx
        bsr     closeint        ;close intuition
        rts                     ;Done !

openint:

        move.l  execbase,a6     ;EXEC base address
        lea     intname,a1      ;name of intuition library
        jsr     openlib(a6)     ;Open intuition
        move.l  d0,intbase      ;Save Intuition base address
        rts

closeint:

        move.l  execbase,a6     ;*close Intuition
        move.l  intbase,a1      ;intuition base address in A1
        jsr     closelibrary(a6);close intuition
        rts                     ;Done
scropen:
      
	move.l  intbase,a6    	        ;Intuition base address in A6
        lea     screen_defs,a0 	        ;Pointer to Table
        jsr     openscreen(a6)          ;OPen
	move.l  d0,screenhd             ;Save Screen Handle
        move.l  d0,a0                   ;get screen pointer ready
	move.l  $c0(a0),bitplane1       ;get pointer to bit plane # 1
        move.l  $c4(a0),bitplane2       ;get pointer to bit plane # 2
        move.l  $2c(a0),viewport        ;get pointer to view port
;        move.l  RastPort(a0),raster
;	move.l  execbase,a6             ;EXEC base address
;   	lea     gfxname,a1              ;name of graphics library
;	jsr     openlib(a6)             ;Open graphics library
;        move.l  d0,gfxbase              ;Save graphics base address
        

	rts                     ;Return to Main Program

opengfx:

        move.l  execbase,a6     ;EXEC base address
        lea     gfxname,a1      ;name of intuition library
        jsr     openlib(a6)     ;Open intuition
        move.l  d0,gfxbase      ;Save Intuition base address
        rts


closegfx:

        move.l  execbase,a6     ;*close Intuition
        move.l  gfxbase,a1      ;intuition base address in A1
        jsr     closelibrary(a6);close intuition
        rts                     ;Done

windowopen:
       move.l  intbase,a6      ;Intuition base address in A6
       lea     window_defs,a0  ;Pointer to Table
       jsr     openwindow(a6)  ;OPen
       move.l  d0,window       ;Save Screen Handle
	move.l	d0,a0
        move.l  RastPort(a0),raster
	move.l	intbase,a6
	jsr	viewportaddress(a6)
	move.l	a0,viewport
       rts

windowclose:
       move.l  intbase,a6      ;Intuition base address in A6
       move.l  window,a0       ;Screen Handle in A0
       jsr     closewindow(a6) ;And Move
       rts                     ;Done



scrclose:

       move.l intbase,a6      ;Intuition base address in A6
       move.l  screenhd,a0     ;Screen Handle in A0
       jsr     closescreen(a6) ;And Move
       rts                     ;Done

scrmove:

       move.l  intbase,a6      ;Intuition base in A6
       move.l  screenhd,a0     ;Screen Handle in A0
       clr.l   d0              ;No horizontal movement
       jsr     movescreen(a6)  ;And Move
       rts                     ;Done

       cnop 0,2

screen_defs:
x_pos:         dc.w    0       ;x-position
y_pos:         dc.w    0       ;y-position
width:         dc.w    320     ;width
height:        dc.w    200     ;height
depth:         dc.w    2       ;Number of Bit Planes 2

detail_pen:    dc.b    1       ;Text Colour equ  White
block_pen:     dc.b    3       ;Background Color equ  Red
view_modes:    dc.w    2       ;Representation Mode
screen_types:  dc.w    15      ;Screen Type:Custom Screen
font:          dc.l    0       ;Standard Character Set
title:         dc.l    sname   ;Pointer to title text
gadgets:       dc.l    0       ;No gadgets
bitmap:        dc.l    0       ;No Bit Map
       
window_defs:
         dc.w    0     ;x-position
         dc.w    0       ;y-position
         dc.w    320      ;width
         dc.w    200       ;height
         dc.b    1,0     ;Number of Bit Planes 2
         dc.l    $1800   ;IDCMPF
         dc.l    0       ;flags
         dc.l    0       ;gadget
         dc.l    0       ;image
	 dc.l	 0 	 ;title
screenhd:	dc.l    0       ;screen
         dc.l    0       ;bitmap
         dc.w    0,0     ;min
         dc.w    320,200   ;maX
         dc.w    $f       ;


intbase:       dc.l    0       ;Base Address of Intuition
window:      dc.l    0       ;Screen Handle
intname:       dc.b    'intuition.library',0
       cnop 0,2
gfxname:       dc.b    'graphics.library',0
       cnop 0,2

sname:         dc.b    'BOB Screen',0 ;Screen Title
       cnop 0,2
raster:      dc.l    0
viewport:      dc.l    0
gfxbase:       dc.l    0

bitplane1:     dc.l    0
bitplane2:     dc.l    0

man:           dc.b    1,$80,2,$40,1,$80,7,$e0,$d,$b0,9,$90
               dc.b    $11,$88,3,$c0,2,$40,6,$60,$c0,$30,$18,$18


bob:
		dc.w	0		; 0
		dc.l	savebuffer	; 2
		dc.l	imageshadow	; 6
		dc.l	0		;10 before
		dc.l	0		;14 after		
		dc.l	v		;18
		dc.l	0		;22
		dc.l	0		;26
		dc.l	0		;30
		dc.l	0		;34

savebuffer:	ds.l	100
imageshadow:	ds.l	100
cmask:		ds.l	500
bline:		ds.l	500

v:		dc.l	0		; 0 next v sprite
		dc.l	0		; 4 previous v sprite
		dc.l	0		; 8 draw path
		dc.l	0		; 12 clear path
		dc.w	100		; 16 old Y
		dc.w	160		; 18 old X


		dc.w	6		; 20 flags
		dc.w	100		; 22 Y
		dc.w	160		; 24 X
		dc.w	25		; 26 height
		dc.w	5		; 28 width in words
		dc.w	2		; 30 depth
		dc.w	1		; 32 ME mask
		dc.w	1		; 34 hit mask
		dc.l	imagedata	        ; 38 imagedata
		dc.l	bline		; 42
		dc.l	cmask		; 46
		dc.l	0		; 50 sprite colours
pbob:		dc.l	0		; 54 pointer to bob *** Move HERE!
		dc.b	3,0		; 56 pçlane on/off
		dc.l	0,0,0,0,0	
		dc.l	0

vs:		dc.l	imagedata
		dc.l	0
		dc.w	5		; word width
		dc.w	25		; line height
		dc.w	2		; image depth
		dc.w	100		; x co-ord
		dc.w	160		; y co-or
		dc.w	6		; flags
		dc.w    0

nbob:		dc.l	imagedata
		dc.w	5		; word width
		dc.w	25		; line height
		dc.w	2		; image depth
		dc.w	3		; plane pic
		dc.w	0		; plane on/off
		dc.w	6		; flags
		dc.w	0		; double buufer
		dc.w	2		; raster depth
		dc.w	100		; x co-ord
		dc.w	160		; y co-ord
		dc.w	0



	
gelinfo:dc.b    $fc	;sprites reserved
		dc.b	0		;flags
		dc.l	vshead		; vs gelhead
		dc.l    vstail  	; vs gel tail
		dc.l	nextline	;nextline
		dc.l	lastcolor	;lastcolor
		dc.l	colltable	;collhandler
		dc.w	0		;leftmost
		dc.w	319		;right most
		dc.w	0		;top most
		dc.w	199		;bottom most
		dc.l	0		;first blis object
		dc.l	0		;last blis object
		dc.l	0,0,0,0

nextline:	ds.l	40
lastcolor:	ds.l	40
vshead:		ds.l	400
vstail:		ds.l  	400
colltable:	ds.l	40 	
	


imagedata:
		dc.l	2312,23183,1821,12837
		dc.l	135182,1283828,9199222,2933
		dc.l	93832298,94482829,36623737,2728383
		dc.l	2312,23183,1821,12837
		dc.l	135182,1283828,9199222,2933
		dc.l	93832298,94482829,36623737,2728383
		dc.l	2312,23183,1821,12837
		dc.l	135182,1283828,9199222,2933
		dc.l	93832298,94482829,36623737,2728383
		dc.l	2312,23183,1821,12837
		dc.l	135182,1283828,9199222,2933
		dc.l	93832298,94482829,36623737,2728383
		dc.l	2312,23183,1821,12837
		dc.l	135182,1283828,9199222,2933
		dc.l	93832298,94482829,36623737,2728383
		dc.l	2312,23183,1821,12837
		dc.l	135182,1283828,9199222,2933
		dc.l	93832298,94482829,36623737,2728383
		dc.l	2312,23183,1821,12837
		dc.l	135182,1283828,9199222,2933
		dc.l	93832298,94482829,36623737,2728383
		dc.l	2312,23183,1821,12837
		dc.l	135182,1283828,9199222,2933
		dc.l	93832298,94482829,36623737,2728383
		dc.l	2312,23183,1821,12837
		dc.l	135182,1283828,9199222,2933
		dc.l	93832298,94482829,36623737,2728383
		dc.l	2312,23183,1821,12837
		dc.l	135182,1283828,9199222,2933
		dc.l	93832298,94482829,36623737,2728383
		dc.l	2312,23183,1821,12837
		dc.l	135182,1283828,9199222,2933
		dc.l	93832298,9448