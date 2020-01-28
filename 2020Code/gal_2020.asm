ctlw equ  $dff096
c0thi equ  $dff0a0
c0tlo equ  c0thi+2
c0tl equ   c0thi+4
c0per equ  c0thi+6
c0vol equ  c0thi+8
mode_old	equ	1005
IoErr		equ	-132
alloc_abs	equ	-$cc
text		equ	-54

openscreen	equ	-198
closescreen	equ	-66
openwindow	equ	-204
closewindow	equ	-72
SetMenuStrip	equ	-264
ClearMenuStrip	equ	-54
ciaapra 	equ $bfe001


openlib		equ	-408
closelib	equ	-414
open		equ	-30
close		equ	-36
Write		equ	-48
read 		equ 	-42
AllocMem	equ	-198
FreeMem		equ	-210
GetMsg		equ	-372
delay		equ	-198
sysbase		equ	4
Draw		equ	-246	;(rp,x,y) (a1,d0,d1)
_Move		equ	-240	;(rp,x,y) (a1,d0,d1)
SetAPen		equ	-342	;(rp,pen) (a1,d0)
SetDrMd		equ	-354
RectFill	equ	-306
WritePixel	equ	-324
PolyDraw	equ	-336

serwrt		equ	$dff030
IntREQW		equ	$dff09c
serreg		equ	$dff01e
serbaud		equ	$dff032
serdatr		equ	$dff018
serdat		equ	$dff030


DMACONW  EQU $DFF096
COP1LC   EQU $DFF080
COP2LC   EQU $DFF084
COPJMP1  EQU $DFF088
COPJMP2  EQU $DFF08A
clxdat	 equ $DFF00e		; Sprite Collision Detect
clxcon   equ $DFF098		; Sprite Collision Control


;--- Allocate Memory -----------------------

		move.l	sysbase,a6
		move.l	#98000,d0


		move.l	#$10002,d1
		jsr	AllocMem(a6)
		move.l	d0,Memarea
		add.l	#1000,d0
		move.l	d0,buffers
		beq	errormem
		move.l	d0,bufferp
		add.l	#2000,d0
		move.l	d0,spriteloc
		add.l	#1000,d0
		move.l	d0,sprite2loc
		add.l	#1000,d0
		move.l	d0,sprite3loc
		add.l	#200,d0
		move.l	d0,screenptr


		move.l	Memarea,a1
		lea	sinwave,a0
movesound:
		move.l	(a0)+,(a1)+
		cmp.b	#65,(a0)
		bne	movesound

;--- Get Dos base --------------------------
		moveq	#0,d0
		move.l	sysbase,a6
		lea	dosname(pc),a1
		jsr	openlib(a6)
		move.l	d0,dosbase
		beq	errordos

;--- Get Graphics base --------------------------
		moveq	#0,d0
		move.l	sysbase,a6
		lea	gfxname(pc),a1
		jsr	openlib(a6)
		move.l	d0,gfxbase
		beq	errorgfx

		move.l	d0,a0
		move.l	$26(a0),copperloc

;----- load screen -------------------------

		move.l	dosbase,a6
		lea	filename(pc),a0
		move.l	a0,d1
		move.l	#1005,d2
		jsr	open(a6)
		move.l	d0,filehd
		beq	notopened

		move.l	screenptr,d2
		move.l	#32000,d3
		move.l	d0,d1
		jsr	read(a6)

		move.l	filehd,d1
		jsr	close(a6)

****************************************************************************
* 			Load Sprite 1 Data				   *
****************************************************************************

		
		move.l	spriteloc,a1
		lea 	SPRITE(pc),a2		; point a2 at sprite source

SPRLOOP1:
		move.l	(a2),(a1)+		; move long word
		cmp.l 	#$00000000,(a2)+  	; ckeck for end of sprite
		bne	SPRLOOP1		; loop until entire sprite is moved
		
		move.l	spriteloc,d3
		move.l	d3,a4
		move.w	d3,spr1h
		swap.w	d3
		move.w	d3,spr1l
		move.b	#164,(a4)+
		move.b  #164,(a4)+

****************************************************************************
* 			Load Sprite 2 Data				   *
****************************************************************************

		
		move.l	sprite2loc,a1
		lea 	SPRITE2(pc),a2		; pointa2 at sprite source

SPRLOOP2:
		move.l	(a2),(a1)+		; move long word
		cmp.l 	#$00000000,(a2)+  	; ckeck for end of sprite
		bne	SPRLOOP2		; loop until entire sprite is moved
		
		move.l	sprite2loc,d3
		move.l	d3,a4
		move.w	d3,spr2h
		swap.w	d3
		move.w	d3,spr2l
;		move.b	#104,(a4)+
;		move.b  #164,(a4)+


****************************************************************************
* 			Load Sprite 3 Data				   *
***************************************************************************

		
		move.l	sprite3loc,a1
		lea 	SPRITE3(pc),a2		; point a2 at sprite source

SPRLOOP3:
		move.l	(a2),(a1)+		; move long word
		cmp.l 	#$00000000,(a2)+  	; ckeck for end of sprite
		bne	SPRLOOP3		; loop until entire sprite is moved
		
		move.l	sprite3loc,d3
		move.l	d3,a4
		move.w	d3,spr3h
		swap.w	d3
		move.w	d3,spr3l
;		move.b	#74,(a4)+
;		move.b  #74,(a4)+



notopened:
	
;---------------------------------------------
;		move.l	screenptr,a0
;		move.l	a0,d2
;		move.w	#200,d0
;		
;loopline:
;		move.b	#$ff,(a0)
;		add.l	#81,a0
;		dbra	d0,loopline
		

		move.w	d2,pln1h
		swap.w	d2
		move.w	d2,pln1l

		swap	d2
		add.l	#1,d2

		move.w	d2,pln2h
		swap.w	d2
		move.w	d2,pln2l

		move.l	bufferp,a1
		lea	copper_ins(pc),a0
		move.w	#dosname-copper_ins,d0
movecop:
		move.b	(a0)+,(a1)+
		dbra	d0,movecop
		
		move.l	bufferp,a0	;get the address of copper instructions
		move.l	a0,COP1LC	;copper jump location address;
					; program counter
		move.w 	#$83a0,DMACONW	;  bit-plane, copper, and sprite DMA
		move.l	screenptr,d2
		move.l	bufferp,a0
		add.l	#pln1h-copper_ins,a0

gohere:

;		movem.l	a0/d2,-(sp)
;		move.l	#4,d1			; Set # to Wait time
;		move.l	dosbase,a6
;		jsr	delay(a6)
;		movem.l	(sp)+,a0/d2
	
;		move.w	d2,(a0)
;		swap.w	d2
;		move.w	d2,-4(a0)
;		swap.w	d2

;		add.l	#16000,d2
;		move.w	d2,-8(a0)
;		swap.w	d2
;		move.w	d2,-$c(a0)
;		swap.w	d2
;		sub.l	#16000,d2

;
;		add.l	#1,d2



**********************************************************************
*			Program MainLine			     *
**********************************************************************
	move.l	sprite2loc,a5
	move.l	spriteloc,a4
;	move.l	d4,(a4)
;	move.b	#190,(a4)
	move.b	#$e0,(a4)
	move.l	#151,saved6
;	bsr	bobsetup
;	bsr	paste

;=========================================================================

Vloop:	
	bsr 	movenemy
	bsr 	checkjoy
	bsr	checkcollision
	bsr	TestFire
;	bsr	keepplaceing
	bsr	heywait
	btst	#6,ciaapra
	bne	Vloop
;	bsr	textgo
;	bsr	topjmp
	bra	EndProgram


TestFire:
	cmp.l	#1,shtg
	beq	going
	btst.b	#7,ciaapra		;test fire button
	bne	noshoot
	move.b	(a4),d6			; ypos
	move.b	1(a4),d5		; xpos
	sub.b	#2,d6
	move.b	d6,(a5)
	sub.b	#3,d5
	move.b	d5,1(a5)
	add.b	#6,d6
	move.b	d6,2(a5)
	move.l	#1,shtg

noshoot:
	rts

going:
	sub.b	#1,d6
	cmp.b	#20,d6
	beq	zeroit
	move.b	d6,(a5)
	rts
zeroit:
	move.b	#0,(a5)

	move.l	#0,shtg
	rts

movenemy:
	
	cmp.l	#1,setflghit
	bne	cont
	move.l	sprite3loc,a1
	move.b	#1,(a1)
	move.l	0,setflghit

cont:

	movem.l	d0-d6/a0-a6,-(sp)
	move.l	sprite3loc,a1
	move.l	spriteloc,a2
	lea	shipx,a3
	move.w	myx,d0
	cmp.w   (a3),d0
	beq	done
	blt	movlef
	add.w	#1,(a3)
	add.b	#1,1(a1)
	bra	done
movlef:
	sub.w	#1,(a3)
	sub.b	#1,1(a1)
done:
	add.b	#1,(a1)
	movem.l	(sp)+,d0-d6/a0-a6
	rts



**************************************************************************

checkcollision:

	movem.l	d0-d6/a0-a6,-(sp)
	move.w	clxdat,d0
	
	btst	#9,d0
	beq	okayfornow
	movem.l	(sp)+,d0-d6/a0-a6
	move.l	#0,shtg
	move.l	sprite2loc,a5
	move.b	#0,1(a5)
	move.l	#1,setflghit

	rts

okayfornow:

	movem.l	(sp)+,d0-d6/a0-a6
	rts
	


**********************************************************************
*			Check Joystick				     *
**********************************************************************

checkjoy:
	

	movem.l d0-d7/a0-a6,-(sp)
	move.l	saved6,d6
	move.l	saved2,d2
	
	move.w	$dff00c,d0
	
	btst 	#1,d0		; is it right, no?
	beq 	noright

	cmp.b	#221,1(a4)
	beq	noright

	add.w	#1,myx
	Add.b   #1,d2
	move.b	d2,1(a4)



noright:

	btst    #9,d0
 	beq 	noleft		; is it left?
	
	cmp.b	#63,1(a4)
	beq	noleft
	
	sub.w	#1,myx
	Sub.b	#1,d2
 	move.b	d2,1(a4)

noleft:
	move.l	d6,saved6
	move.l	d2,saved2

	movem.l (sp)+,d0-d7/a0-a6
	rts

	
********************************************************************
* 			Wait (time delay)			   *
********************************************************************


heywait:
		movem.l d0-d7/a0-a6,-(sp)
		move.l	#1,d1			; Set # to Wait time
		move.l	dosbase,a6
		jsr	delay(a6)
		movem.l (sp)+,d0-d7/a0-a6
		rts
error2:

	move.l	dosbase,a6
	jsr	IoErr(a6)
	move.l	d0,d5
	move.l	#-1,d7

qu:
	rts

	btst.b	#6,$bfe001
	bne	qu

	move.l	Memarea,a1
	move.l	#9000,d0
	move.l	sysbase,a6
	jsr	FreeMem(a6)
	clr.l	d0

errordos2:
	rts

Openfile:
	move.l	a1,d1
	move.l	d0,d2

	move.l	dosbase,a6
	jsr	open(a6)
	tst.l	d0
	rts
	
********************************************************************
* 			Wait (time delay)			   *
********************************************************************


heywait2:
		movem.l d0-d7/a0-a6,-(sp)
		move.l	#2,d1			; Set # to Wait time
		move.l	dosbase,a6
		jsr	delay(a6)
		movem.l (sp)+,d0-d7/a0-a6
		rts

paste:

		move.l	screenptr,a0
;		lea	obj,a1
		move.l	#8000,d0
		
lun:		move.l	(a1),(a0)+
		dbra	d0,lun
		rts


EndProgram:

		move.l	copperloc,a0     ;get the address of copper instructions
		move.l	a0,COP1LC         ;copper jump location address


;--- Exit program ------------------------
exit:
		move.l	conhandle,d1
		move.l	dosbase,a6
		jsr	close(a6)

		move.l	gfxbase,a1
		move.l	sysbase,a6
		jsr	closelib(a6)
errorgfx:
		move.l	dosbase,a1
		move.l	sysbase,a6
		jsr	closelib(a6)
errordos:
		move.l	Memarea,a1
		move.l	#98000,d0
		move.l	sysbase,a6
		jsr	FreeMem(a6)
		clr.l	d0
errormem:
error:
		rts


*     copper instructions

copper_ins:


	
            dc.w $0100,$0200
            dc.w $0201,$fffe
		
 	dc.w $0120
spr1l:  dc.w $0000	; Sprite Pointer for 0
	dc.w $0122
spr1h:	dc.w $0000

	dc.w $0124
spr2l:	dc.w $0000	; Sprite Pointer for 1
	dc.w $0126
spr2h:  dc.w $0000

	dc.w $0128
spr3l:  dc.w $0000	; Sprite Pointer for 2
	dc.w $012a
spr3h:	dc.w $0000

	dc.w $012c,$0000	; Sprite Pointer for 3
	dc.w $012e,$0000
	dc.w $0130,$0000	; Sprite Pointer for 4
	dc.w $0132,$0000
	dc.w $0134,$0000	; Sprite Pointer for 5
	dc.w $0136,$0000
	dc.w $013a,$0000	; Sprite Pointer for 6
	dc.w $013c,$0000
	dc.w $013e,$0000	; Sprite Pointer for 7
	dc.w $0140,$0000

	dc.w	$01a2,$0f00	; Sprite 0 Color
	dc.w	$01a4,$0fff
	dc.w	$01a6,$0999	
	dc.w	$01aa,$0f00	; Sprite 1 Color
	dc.w	$01ac,$0fff
	dc.w	$01ae,$0999	
	dc.w	$01b2,$0f00	; Sprite 2 Color
	dc.w	$01b4,$0fff
	dc.w	$01b6,$0999	

        dc.w $2801,$fffe
        dc.w $0100,$0200
        dc.w $008e,$0581         ;diwstart
        dc.w $0090,$ffc1         ;diwstop
	dc.w $00e4
pln2l:	dc.w $0000    *    ;bit plane display area 2(low)
        dc.w $00e6
pln2h:	dc.w $0000    *    ;bitplane display area 2(high)
        dc.w $00e0
pln1l:	dc.w $0000    *    ;                       1(low)
        dc.w $00e2
pln1h:	dc.w $0000    *    ;                       1(high)
        dc.w $0092,$003c
        dc.w $0094,$00d4
        dc.w $0104,$0024
        dc.w $0102,$0000 	;
        dc.w $0108,$0028	; modulo playfield 1
        dc.w $010a,$0028	; modulo playfield 2
        dc.w $0100,$2200	;bit plane control 
        dc.w $0182,$0000
        dc.w $0184,$0fff
            dc.w $0186
color1:     dc.w $0000
            dc.w $3001,$fffe     ;wait for line 30
            dc.w $0180
color2:	    dc.w $0000        	 ;move black to color register (180)
            dc.w $4001,$fffe     ;wait for line 132
            dc.w $0180
	    dc.w $0000           ;move sky blue to color register
            dc.w $5001,$fffe     ;wait for line 200
            dc.w $0180
            dc.w $0111       ;move pink to color register
        dc.w $6001,$fffe
        dc.w $0180,$0222 		;green
        dc.w $7001,$fffe
        dc.w $0180,$0333         ;orange
        dc.w $8001,$fffe
        dc.w $0180,$0444        ;brown
        dc.w $9001,$fffe
        dc.w $0180,$0555         ;magenta
        dc.w $a001,$fffe
        dc.w $0180,$0666         ;medium grey
        dc.w $b001,$fffe
        dc.w $0180,$0777         ;red
        dc.w $c001,$fffe
        dc.w $0180,$0888         ;blue
        dc.w $d001,$fffe
        dc.w $0180,$0999         ;lemon yellow
        dc.w $e001,$fffe
        dc.w $0180,$0aaa         ;tan
        dc.w $f001,$fffe         ;wait for end of screen
        dc.w $0100,$0200         ;turn off bit planes
        dc.w $ffff,$fffe         ;wait until you jump again

	
SPRITE:
	DC.W  $001e,$f000,$0180,$0000,$0ff0,$0000,$381c,$0000
        dc.w  $c003,$0000,$ffff
	DC.W  $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

SPRITE3:

	DC.W  $00a0,$f000,$007F,$0082,$1FFF,$1255,$3DA9,$7803
	DC.W  $3800,$CBFE,$0772,$0E00,$010C,$000,$0000,$0000

SPRITE2:

	DC.W  $0060,$a000,$0000,$0001,$0001,$0001,$0001,$0001
	DC.W  $0001,$0001,$0001,$0001,$0001,$0001,$0000,$0000

EXPOLODE:
		DC.W  $0018,$0018,$00FF,$00FF,$07EF,$07DE,$0FFF,$0E8C
		DC.W  $07FF,$0408,$0FFF,$0800,$0FFF,$0802,$0FFF,$0C00
		DC.W  $7FFF,$7C00,$F3FF,$EE00,$7BFF,$4400,$FFFF,$8000
		DC.W  $F7FF,$8C00,$7FFF,$7800,$3FFF,$3800,$07FF,$0400
		DC.W  $0FAF,$0850,$0F7F,$08D8,$07FF,$07F8,$03DF,$03D0
		DC.W  $001E,$0011,$000F,$000F,$0006,$0006,$0000,$0000

;--- data area -----------------------------------


dosname:	dc.b	'dos.library',0
		cnop	0,2

gfxname:	dc.b	'graphics.library',0
		cnop	0,2

filename:	dc.b	'picture1',0
		cnop	0,2

filehd:		dc.l	0
copperloc:	dc.l	0
screenptr:	dc.l	0
dosbase:	dc.l	0
gfxbase:	dc.l	0
Memarea:	dc.l	0
whichplane:	dc.w	0
plane1:		dc.l	0
plane2:		dc.l	0
plane3:		dc.l	0
plane4:		dc.l	0
rastport	dc.l	0
bufferp:	dc.l	0	;bufferarea
buffers:	dc.l	0	;bufferarea
buffere:	dc.l	0	;bufferarea+4000
filehandle	dc.l	0
enddatarea:	dc.l	0
spriteloc:	dc.l	0
sprite2loc:	dc.l	0
sprite3loc:	dc.l	0
saved6:		dc.l	160
saved2:		dc.l	160
temp:	        ds.l    500
temp2:	        ds.l    500
myx		dc.w	160
shipx		dc.w	160
shtg:		dc.l	0


		
man:           dc.b    $00,$00,00,$00,00,$00,00,$00,$00,$00,00,$00
	       dc.b    $00,$00,00,$00,00,$00,00,$00,$00,$00,00,$00



consolname:	dc.b 'CON:0/0/640/200/Program Window',0
	
		cnop 0,2

conh