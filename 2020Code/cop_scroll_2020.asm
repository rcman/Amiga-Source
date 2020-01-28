openscreen	equ	-198
closescreen	equ	-66
openwindow	equ	-204
closewindow	equ	-72
SetMenuStrip	equ	-264
ClearMenuStrip	equ	-54

openlib		equ	-408
closelib	equ	-414
open		equ	-30
close		equ	-36
write		equ	-48
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


;--- Allocate Memory -----------------------

		move.l	sysbase,a6
		move.l	#98000,d0
		move.l	#$10002,d1
		jsr	AllocMem(a6)
		move.l	d0,Memarea
		move.l	d0,buffers
		beq	errormem
		move.l	d0,bufferp
		add.l	#2000,d0
		move.l	d0,screenptr

;--- Get DosÀlC`> base --------------------------
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
notopened:
		

;---------------------------------------------
		move.l	screenptr,a0
		move.l	a0,d2
		move.w	#200,d0

		
loopline:
		move.b	#$ff,(a0)
		add.l	#81,a0
		dbra	d0,loopline
	
;
; move sprite to $25000 this is where sprite 1 sits
;

	move.l	#$25000,a1		; point a1 at sprite destination
	lea 	SPRITE(pc),a2		; point a2 at sprite source

SPRLOOP1:
	move.l	(a2)+,(a1)+		; move long word
	cmp.l 	#$00000000,(a2)+  	; ckeck for end of sprite
	bne	SPRLOOP1		; loop until entire sprite is moved


		move.b	#64,$25000
		move.b	#44,$25001
		move.b	#50,$25002
		

		move.w	d2,pln1h
		swap.w	d2
		move.w	d2,pln1l

		swap	d2
		add.l	#5,d2

		move.w	d2,pln2h
		swap.w	d2
		move.w	d2,pln2l

		move.l	bufferp,a1
		lea	copper_ins(pc),a0
		move.w	#dosname-copper_ins,d0
movecop:
		move.b	(a0)+,(a1)+
		dbra	d0,movecop

		move.l	bufferp,a0	;get the \ûaddress of copper instructions
		move.l	a0,COP1LC	;copper jump location address




		move.l	screenptr,d2
		move.l	bufferp,a0
		add.l	#pln1h-copper_ins,a0	; a0 points at copper bitplane

gohere:
		movem.l	a0/d2,-(sp)
		move.l	#5,d1			; Set # to Wait time
		move.l	dosbase,a6
		jsr	delay(a6)
		movem.l	(sp)+,a0/d2
	
		move.w	d2,(a0)
		swap.w	d2
		move.w	d2,-4(a0)
		swap.w	d2

		add.l	#16000,d2
;		add.l	#1,d2
		move.w	d2,-8(a0)
		swap.w	d2
		move.w	d2,-$c(a0)
		swap.w	d2
		sub.l	#16000,d2


		add.l	#1,d2		; Increment scroll by 1


		btst.b	#6,$bfe001
		bne.s	gohere
	
		move.l	copperloc,a0     ;get the address of copper instructions
		move.l	a0,COP1LC         ;copper jump location address


;--- Exit program ------------------------
exit:
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
            dc.w $0120,$0002	; Sprite 0 location
            dc.w $0122,$5000
            dc.w $0124,$0002
            dc.w $0126,$5000
            dc.w $0128,$0002
            dc.w $012a,$5000
            dc.w $012c,$0002
            dc.w $012e,$5000
            dc.w $0130,$0002
            dc.w $0132,$5000
            dc.w $0134,$0002
            dc.w $0136,$5000
            dc.w $0138,$0002
            dc.w $013a,$5000
	    
            dc.w $01a2,$0ff0		; Sprite Color 0
	    dc.w $01a4,$0fff
	    dc.w $01a6,$0999
			
            dc.w $2801,$fffe
            dc.w $0100,$0200
            dc.w $008e,$0581         ;diwstart
            dc.w $0090,$ffc1         ;diwstop
	    dc.w $00e4
pln2l:	    dc.w $0000    *    ;bit plane display area 2(low)
            dc.w $00e6
pln2h:	    dc.w $0000    *    ;bit plane display area 2(high)
            dc.w $00e0
pln1l:	    dc.w $0000    *    ;                       1(low)
            dc.w $00e2
pln1h:	    dc.w $0000    *    ;                       1(high)
            dc.w $0092,$003c
            dc.w $0094,$00d4
            dc.w $0104,$0024
            dc.w $0102,$0000 	;
            dc.w $0108,$0028	; modulo playfield 1
            dc.w $010a,$0028	; modulo playfield 2
            dc.w $0100,$2200	;bit plane control 
            dc.w $0182,$0000
            dc.w $0184,$0000
            dc.w $0186,$0f80
            dc.w $3001,$fffe         ;wait for line 30
            dc.w $0180,$0000         ;move black to color register (180)
            dc.w $4001,$fffe         ;wait for line 132
            dc.w $0180,$0000         ;move sky blue to color register
            dc.w $5001,$fffe         ;wait for line 200
            dc.w $0180,$0000         ;move pink to color register
            dc.w $6001,$fffe
            dc.w $0180,$0000         ;green
            dc.w $7001,$fffe
            dc.w $0180,$0000         ;orange
            dc.w $8001,$fffe
            dc.w $0180,$0000         ;brown
            dc.w $9001,$fffe
            dc.w $0180,$0ff0         ;magenta
            dc.w $a001,$fffe
            dc.w $0180,$00f0         ;medium grey
            dc.w $b001,$fffe
            dc.w $0180,$0111         ;red
            dc.w $c001,$fffe
            dc.w $0180,$0000         ;blue
            dc.w $d001,$fffe
            dc.w $0180,$0000      
            dc.w $e001,$fffe
            dc.w $0180,$0000         ;tan
            dc.w $f001,$fffe         ;wait for end of screen
            dc.w $0100,$0200         ;turn off bit planes
            dc.w $ffff,$fffe         ;wait until you jump again



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
whichplan
