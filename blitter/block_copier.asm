; This program loads a screen, lifts a block from the screen then uses that 
; block to make a srceen design using a table listed at the bottom of this
; program. The table can be changed to form any shap on the screem.
; Size of block is 4 bytes wide and 25 lines high. 32 x 25 = 320 x 200



; Written By: Franco Gaetan
; Date of Last Revision: June 3, 1991
; From File PASTE.ASM
; Status: Working 
; Last Date Complete: January 5, 1992

 include	'dh0:obj/spriteos.o'


open        equ -30
close       equ -36
read        equ -42
mode_old    equ 1005
viewportaddress equ -300
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
***************************************************************************
no_of_bytes	equ	36	; no of bytes one scan line down
x_size		equ	3	; no of words in width (32 bits 0 - 3)
y_size		equ	24	; no of pixels in height
***************************************************************************


run:
       bsr     openint         ;Open library
       bsr     opengfx         ;Open graphics
       bsr     scropen         ;Open Screen
       bsr     windowopen      ;Open window

       move.l  #0,d0           ;pen
       move.l  #0,d1           ;red
       move.l  #0,d2           ;green
       move.l  #0,d3           ;blue
       move.l  viewport,a0     ;Get Pointer to View Port
       move.l  gfxbase,a6      ;get grapics base
       jsr     setrgb4(a6)     ;set a color registor

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
	beq	ende	

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

	bsr	SaveArea
	bsr	waitleave
	bsr	Clear
	bsr	PlaceBob
	bsr 	MouseCheck
	bra 	ende

Clear:	
	lea 	bitplane1(pc),a3
	move.l	#4,d4

clmore:
        move.l  (a3)+,a1
	move.l	#8000,d0

man2:
        move.b  #0,(a1)+      ;place man data on the screen
	dbra    d0,man2

out2:        

	dbra	d4,clmore
	rts

*****************************************************************
*		Place Blocks  on screen	              		*
*****************************************************************
; a2 = area to place save data
; x = d5 x coordinates
; y = d6 y coordinates

BlockStart:

	move.l	#0,d5		; Set x start value
	move.l	#0,d6		; Set y start value
	move.l	#10,accros	; how many boxes to draw accross the screen
	move.l	#8,down		; how many boxes down
	move.l	#50,count	; this is just a pre-caution so there is'nt 
	lea	table,a5	; an endless loop.

PlaceBlock:

	move.b	(a5)+,on_off	; Load value from screen table
	cmp.b	#2,on_off	; if its a 2 it is the end of screen
	beq	out		; so quit
	cmp.b	#0,on_off	; if its a 0 then put the block down
	beq	Pb2		; and continue
	add.l	#30,d5		; if its not, skip 1 block and continue
	sub.l	#1,accros	; subtract 1 from count of 10 accross
	bra 	PlaceBlock	; loop back
Pb2:
	
	movem.l d0-d7/a0-a6,-(sp)
	move.l	#4,d4
	lea 	bitplane1(pc),a3
	lea	temp2,a1

getblock2:
	 move.l  (a3)+,a1
	movem.l	d5-d6,-(sp)

	move.l	d6,d0
        add.l   #16,d0		; how many bytes long
	move.l	d0,d3
	move.l	#32,d0

noblocking:

	move.l	d5,d7
	and.l	#7,d7
	lsr.l	#3,d5
        add.l   d5,a1
	move.w	d6,d1
	mulu.w	#40,d6
	add.l	d6,a1
        movem.l	(sp)+,d5-d6

getblock:
	move.l	#3,d3
	
	move.w 	#16,d0

make:
	move.w 	#17,d1
        move.l  #16,d0
	
placeblock2:
        move.b  (a2)+,(a1)+      
	dbra	d3,placeblock2

	move.l	#3,d3
        add.l   #36,a1          ;move plane pointer down one scan line

	cmp.w	#0,d1
	sub.w	#1,d1
        dbra    d0,placeblock2

kickblock2:        

	clr.l	d2
	move.w	d0,d2
	lsl.w	#2,d2
	dbra	d4,getblock2
	movem.l (sp)+,d0-d7/a0-a6
	
	add.l	#30,d5		; add 30 lines to block location
	sub.l	#1,accros	; subtract 1 from count accross
	bgt	PlaceBlock	

	add.l	#19,d6		; add 19 to lines down
	move.l	#10,accros	; start of with 10 blocks again
	move.l	#5,d5		; starting location of first block
	sub.l	#1,count	; subtract 1 from count for safety
	beq	out		; if it gone to far exit
	sub.l	#1,down		; subtract from 1 line down being used
	bgt	PlaceBlock


out:
	rts			; Return


ende:
       bsr     windowclose     ;close window
       bsr     scrclose        ;close screen

       bsr     closegfx        ;close gfxbase
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
;       move.l  $2c(a0),viewport        ;get pointer to view port
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
	move.l	d0,a0
	move.l	intbase,a6
	jsr	viewportaddress(a6)
	move.l	a0,viewport
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
	lea	temp2,a2

getall:

        move.l  (a3)+,a1	;Get me next bitplane 

	move.l	#y_size,d0		; how many lines high
doagain:
	move.l	#x_size,d3		; how many bytes wide 32 pixels (4 bytes)
placeman:


        move.b  (a1)+,(a2)+      ;read source destination 1 bitplane at
	dbra	d3,placeman	 ; a time

        add.l   #no_of_bytes,a1          ;move plane pointer down one scan line
        dbra    d0,doagain	; get all the data block for one bitplane

	dbra	d4,getall	        ; get all the bitplanes
	movem.l (sp)+,d0-d7/a0-a6	;restore the variables
	rts


*****************************************************************
*		Place Data back on screen			*
*****************************************************************
PlaceBob:
	
	movem.l d0-d7/a0-a6,-(sp)
	move.l	#4,d4
	lea 	bitplane1(pc),a3
        lea     temp2,a2

getall2:

        move.l  (a3)+,a1
	add.l	#4019,a1

	move.l	#y_size,d0		; how many lines high
again:
	move.l	#x_size,d3		; how many bytes wide 32 pixels (4 bytes)

placeman2:
        move.b  (a2)+,(a1)+      ;place man data on the screen
	dbra	d3,placeman2
        
	add.l   #no_of_bytes,a1          ;move plane pointer down one scan line
       	dbra    d0,again

kickout2:        

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
screenhd:      dc.l    0       ;screen
         dc.l    0       ;bitmap
         dc.w    0,0     ;min
         dc.w    320,200   ;maX
         dc.w    $f       ;

       
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
;screenhd:      dc.l    0       ;Screen Handle
intname:       dc.b    'intuition.library',0
       
gfxname:       dc.b    'graphics.library',0
       
dosname:       dc.b    'dos.library',0
       
dosfile        dc.b    'picture1',0
       
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
temp:	       ds.l    2500
temp2:	       ds.l    2000
addr:		dc.l	0
on_off		dc.l	0
down		dc.l	0
accros		dc.l	0
safe:		dc.l	5
safed:		dc.l	5
count:		dc.l	20
endit:		dc.l	0
		
man:           dc.b    $00,$00,00,$00,00,$00,00,$00,$00,$00,00,$00
	       dc.b    $00,$00,00,$00,00,$00,00,$00,$00,$00,00,$00

; This is screen 1 it is 10 x 10


table:		dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00		
		dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00		
		dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00		
		dc.b	$00,$00,$00,$01,$01,$01,$01,$00,$00,$00		
		dc.b	$00,$00,$00,$01,$00,$00,$00,$00,$00,$00		
		dc.b	$00,$00,$00,$01,$00,$00,$00,$00,$00,$00		
		dc.b	$00,$00,$00,$01,$01,$00,$00,$00,$00,$00		
		dc.b	$00,$00,$00,$01,$00,$00,$00,$00,$00,$00		
		dc.b	$00,$00,$00,$01,$00,$00,$00,$00,$00,$00		
		dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$02		
		
		; 1 = block offcopy 
		; 0 = block on
		; 2 = end of screen


       end





