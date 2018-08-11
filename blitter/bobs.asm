
;Demo program to open and move a screen
open        equ -30
close       equ -36
read        equ -42
mode_old    equ 1005

movescreen  equ -162
openscreen  equ -198
closescreen equ -66
openwindow  equ -204
closewindow equ -72
closelibrary equ -414
openlib     equ -408      ;open library
execbase    equ  4        ;EXEC base address
joy2        equ $dff00c   ;joystick 2 Data
fire        equ $bfe001   ;fire button 2:Bit 7
setrgb4     equ  -288
delay		equ -198


run:
       bsr     openint         ;Open library
;       bsr     windowopen      ;Open window
       bsr     scropen         ;Open Screen

       move.l  $4,a6
       lea     dosname(pc),a1
       moveq   #0,d0
       jsr     openlib(a6)
       move.l  d0,dosbase

       move.l  d0,a6
       lea     dosfile(pc),a1    ;file name
       move.l  a1,d1
       move.l  #mode_old,d2
       jsr     open(a6)          ;open the file

       move.l  d0,filehandle

       move.l  bitplane1,d2      ;buffer
       move.l  #8000,d3          ;length
       move.l  d0,d1             ;file handle
       move.l  dosbase,a6
       jsr     read(a6)          ;read in the picture

       move.l  bitplane2,d2      ;buffer
       move.l  #8000,d3          ;length
       move.l  filehandle,d1             ;file handle
       move.l  dosbase,a6
       jsr     read(a6)          ;read in the picture

       move.l  bitplane3,d2      ;buffer
       move.l  #8000,d3          ;length
       move.l  filehandle,d1     ;file handle
       move.l  dosbase,a6
       jsr     read(a6)          ;read in the picture

       move.l  bitplane4,d2      ;buffer
       move.l  #8000,d3          ;length
       move.l  filehandle,d1     ;file handle
       move.l  dosbase,a6
       jsr     read(a6)          ;read in the picture

       move.l  bitplane5,d2      ;buffer
       move.l  #8000,d3          ;length
       move.l  filehandle,d1             ;file handle
       move.l  dosbase,a6
       jsr     read(a6)          ;read in the picture
	
       move.l  filehandle,d1
       move.l  dosbase,a6
       jsr     close(a6)

*************************************************************************
*			START						*
*************************************************************************

	lea	temp2,a2
	move.l	#160,d5
	move.l	#120,d6
	bsr	SaveArea
	lea	temp,a2
	move.l	#160,d5
	move.l	#120,d6
	bsr	SaveArea
	bsr	waitleave

	move.l	#160,d0
	move.l	#120,d1

; place screen

keepplaceing:
	move.l	screenhd,a0
	move.w	16(a0),d6
	move.w	18(a0),d5

	cmp.w	d6,d1
	bne.s	achange

	cmp.w	d5,d0
	bne.s	achange

	bra	nochangeman

achange:
	movem.l	d5-d6,-(sp)
	move.l	d0,d5
	move.l	d1,d6
	lea	temp2,a2
	bsr	PlaceBob
        movem.l	(sp)+,d5-d6

	lea	temp2,a2
	bsr	SaveArea

	lea	temp,a2
	bsr	PlaceBob

	move.w	d5,d0
	move.w	d6,d1

nochangeman:
	btst.b	#6,$bfe001
        bne	keepplaceing

ende:
       bsr     scrclose        ;close screen
;       bsr     windowclose     ;close window
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
       move.l  intbase,a6      ;Intuition base address in A6
       lea     screen_defs,a0  ;Pointer to Table
       jsr     openscreen(a6)  ;OPen
       move.l  d0,screenhd     ;Save Screen Handle
       move.l  d0,a0           ;get screen pointer ready
       move.l  $c0(a0),bitplane1       ;get pointer to bit plane # 1
       move.l  $c4(a0),bitplane2       ;get pointer to bit plane # 2
       move.l  $c8(a0),bitplane3 		
       move.l  $cc(a0),bitplane4
       move.l  $d0(a0),bitplane5
       move.l  $2c(a0),viewport        ;get pointer to view port
       rts                     ;Return to Main Program
scrclose:
       move.l  intbase,a6      ;Intuition base address in A6
       move.l  screenhd,a0     ;Screen Handle in A0
       jsr     closescreen(a6) ;And Move
       rts                     ;Done

windowopen:
       move.l  intbase,a6      ;Intuition base address in A6
       lea     window_defs,a0  ;Pointer to Table
       jsr     openwindow(a6)  ;OPen
       move.l  d0,window       ;Save Screen Handle
       rts

windowclose:
       move.l  intbase,a6      ;Intuition base address in A6
       move.l  window,a0       ;Screen Handle in A0
       jsr     closewindow(a6) ;And Move
       rts                     ;Done

;scrmove:
;       move.l  intbase,a6      ;Intuition base in A6
;       move.l  screenhd,a0     ;Screen Handle in A0
;       clr.l   d0              ;No horizontal movement
;       jsr     movescreen(a6)  ;And Move
;       rts             

*****************************************************************


MouseCheck:

	btst.b	#6,$bfe001
	bne	MouseCheck
	rts
	

*****************************************************************
*			Wait					*
*****************************************************************


waitleave:
       move.b  fire,d0
       and.b   #$80,d0
       bne     waitleave
       rts


*****************************************************************
*		Take Data from screen	          		*
*****************************************************************
; a2 = area to place save data
; x = d5 x coordinates
; y = d6 y coordinates
 
SaveArea:

	movem.l d0-d7/a0-a6,-(sp)
	move.l	#4,d4		; no of bitplanes
        lea     bitplane1(pc),a3

getall:

        move.l  (a3)+,a1
	movem.l	d5-d6,-(sp)

	move.l	d6,d0
        add.l   #42,d0		; how many bytes long
	move.l	d0,d3
	move.l	#42,d0
	sub.l	#168,d3		; MAX
	bmi	nomorexing2
	sub.l	d3,d0
nomorexing2:

	move.l	d5,d7
	and.l	#7,d7
	lsr.l	#3,d5
        add.l   d5,a1
	mulu.w	#40,d6
	add.l	d6,a1
        movem.l	(sp)+,d5-d6

;        move.l  #42,d0		; how many bytes long
	move.l	#3,d3		; how many bytes high
placeman:


        move.b  (a1)+,(a2)+      ;place man data on the screen
	dbra	d3,placeman

	move.l	#3,d3
        add.l   #36,a1          ;move plane pointer down one scan line
        dbra    d0,placeman

	dbra	d4,getall
	movem.l (sp)+,d0-d7/a0-a6
	rts


*****************************************************************
*		Place Data back on screen			*
*****************************************************************
; a2 = area to place save data
; x = d5 x coordinates
; y = d6 y coordinates
PlaceBob:

	movem.l d0-d7/a0-a6,-(sp)
	move.l	#4,d4
	lea 	bitplane1(pc),a3
;        lea    temp,a2

getall2:

        move.l  (a3)+,a1
	movem.l	d5-d6,-(sp)

	move.l	d6,d0
        add.l   #42,d0		; how many bytes long
	move.l	d0,d3
	move.l	#42,d0
	sub.l	#158,d3
	bmi	nomorexing
	sub.l	d3,d0
nomorexing:

	move.l	d5,d7
	and.l	#7,d7
	lsr.l	#3,d5
        add.l   d5,a1
	mulu.w	#40,d6
	add.l	d6,a1
        movem.l	(sp)+,d5-d6

getme:
;        move.l  #42,d0
	move.l	#3,d3
placeman2:


        move.b  (a2)+,(a1)+      ;place man data on the screen
	dbra	d3,placeman2

	move.l	#3,d3
        add.l   #36,a1          ;move plane pointer down one scan line
        dbra    d0,placeman2

	dbra	d4,getall2

	movem.l (sp)+,d0-d7/a0-a6
	rts


*****************************************************************
*                    Delay                                      *
*****************************************************************

heywait:
		movem.l d0-d7/a0-a6,-(sp)
		move.l	#8,d1			; Set # to Wait time
		move.l	dosbase,a6
		jsr	delay(a6)
		movem.l (sp)+,d0-d7/a0-a6
		rts


       
window_defs:
         dc.w    100     ;x-position
         dc.w    1       ;y-position
         dc.w    20      ;width
         dc.w    9       ;height
         dc.b    1,0     ;Number of Bit Planes 2
         dc.l    1       ;IDCMPF
         dc.l    3       ;flags
         dc.l    0       ;gadget
         dc.l    0       ;image
         dc.l    0       ;title
         dc.l    0       ;screen
         dc.l    0       ;bitmap
         dc.w    1,1     ;min
         dc.w    20,20   ;maX
         dc.l    0       ;

       
screen_defs:
x_pos:         dc.w    0       ;x-position
y_pos:         dc.w    0       ;y-position
width:         dc.w    320     ;width
height:        dc.w    200     ;height
depth:         dc.w    5       ;Number of Bit Planes 2
detail_pen:    dc.b    1       ;Text Colour equ  White
block_pen:     dc.b    3       ;Background Color equ  Red
view_modes:    dc.w    2       ;Representation Mode
screen_types:  dc.w    15      ;Screen Type:Custom Screen
font:          dc.l    0       ;Standard Character Set
title:         dc.l    sname   ;Pointer to title text
gadgets:       dc.l    0       ;No gadgets
bitmap:        dc.l    0       ;No Bit Map
intbase:       dc.l    0       ;Base Address of Intuition
screenhd:      dc.l    0       ;Screen Handle
intname:       dc.b    'intuition.library',0
       
gfxname:       dc.b    'graphics.library',0
       
dosname:       dc.b    'dos.library',0
       
dosfile        dc.b    'dh0:assem/picture1',0
       
sname:         dc.b    'Our Screen',0 ;Screen Title
       
rastport:      dc.l    0
viewport:      dc.l    0
gfxbase:       dc.l    0
dosbase:       dc.l    0
filehandle:    dc.l    0
window:		dc.l	0
	
bitplane1:     dc.l    0
bitplane2:     dc.l    0
bitplane3:     dc.l    0
bitplane4:     dc.l    0
bitplane5:     dc.l    0
temp:	       ds.l    500
temp2:	       ds.l    500
		
man:           dc.b    $00,$00,00,$00,00,$00,00,$00,$00,$00,00,$00
	       dc.b    $00,$00,00,$00,00,$00,00,$00,$00,$00,00,$00

       end





