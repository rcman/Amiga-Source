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
clxco    equ $DFF098		; Sprite Collision Control


;--- Allocate Memory -----------------------

		move.l	sysbase,a6
		move.l	#198000,d0


		move.l	#$10002,d1
		jsr	AllocMem(a6)
		move.l	d0,Memarea
		add.l	#1000,d0
		move.l	d0,buffers
		beq	errormem
		move.l	d0,bufferp
		add.l	#2000,d0
		move.l	d0,spriteloc
		add.l	#400,d0
		move.l	d0,sprite2loc
		add.l	#400,d0
		move.l	d0,sprite3loc
		add.l	#200,d0
		move.l	d0,screenptr


		move.l	Memarea,a1

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
		move.l	#16000,d3
		move.l	d0,d1
		jsr	read(a6)

		move.l	filehd,d1
		jsr	close(a6)

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
		move.w	#dosname-copper_ians,d0
movecop:
		move.b	(a0)+,(a1)+
		dbra	d0,movecop
		
		move.l	bufferp,a0	;get the address of copper instructions
		move.l	a0,COP1LC	;copper jump location address;
					; program counter
		move.w 	#$83a0,DMACONW	; bit-plane, copper, and sprite DMA
		
		move.l	screenptr,d2
		move.l	bufferp,a0
		add.l	#pln1h-copper_ins,a0

gohere:



**********************************************************************
*			Program MainLine			     *
*********************************************************************

Vloop:	

	bsr	heywait
	btst	#6,ciaapra
	bne	Vloop
	bsr	topjmp
	bra	EndProgram


	
********************************************************************
* 			Wait (time delay)			   *
********************************************************************


heywait:
		movem.l d0-d7/a0-a6,-(sp)
		move.l	#0,d1			; Set # to Wait time
		move.l	dosbase,a6
		jsr	delay(a6)
		movem.l (sp)+,d0-d7/a0-a6
		rts



***********************************************************************
*                 Transition Start 				       *
************************************************************************


topjmp:
	move.l	#4,d1
	bsr	heywait2

	move.w	#12,d0
	move.l	bufferp,a1
	move.l	#color1-copper_ins,d1
	add.l	d1,a1
	move.l	#color2-color1,d1
loopme:
	move.w	(a1),d4
	beq	nosubt

	bsr	subbits
	move.w	d4,(a1)

nosubt:	
	add.l	d1,a1
	dbra	d0,loopme
	dbra	d5,topjmp
	rts

**************************************************************************
* Transition Stop                                         *
**************************************************************************



***********************************************************************
*              Transition Loop to mask off the bits                   *
***********************************************************************


subbits:
		movem.l	d0-d3/a0-a6,-(sp)
	
		move.l	#3,d0
looprot:
		move.l	d4,d2
		and.l	#$f,d2
		cmp.b	#$0,d2
		beq	noroll
		sub.b	#1,d2
noroll:
		and.w	#$fff0,d4
		or.w	d2,d4
		ror.w	#4,d4
		dbra	d0,looprot

		movem.l	(sp)+,d0-d3/a0-a6
		rts

*************************************************************************
*               End of Transistion Mask                                 *
*************************************************************************


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

		move.l	dosbase,a1
		move.l	sysbase,a6
		jsr	closelib(a6)

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

	dc.w $012c,$0000	; Sprite Pointfor 3
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
pln2h:	dc.w $0000    *    ;bit plane display area 2(high)
        dc.w $00e0
pln1l:	dc.w $0000    *    ;                       1(low)
        dc.w $00e2
pln1h:	dc.w $0000    *    ;                       1(high)
        dc.w $0092,$003c
        dc.w $0094,$00d4
        dc.w $0104,$0024
        dc.w $0102,$0000 	;
        dc.w $0108,$0000	; modulo playfield 1
        dc.w $010a,$0000	; modulo playfield 2
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
        dc.w $0180,$0222         ;green
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

	
;--- data aqÙQ7drea -----------------------------------


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


