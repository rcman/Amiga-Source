

sysbase		equ	4
execbase	equ	4
forbid		equ	 -132
permit		equ	 -138
intreqr		equ	$01e
intreq		equ	$09c
DMAB_BLTDONE	equ	14
custom		equ	$dff000
intena		equ	$9a	;Interupt enable register
dmacon		equ	$96	;DMA-control register (Write)
dmaconr		equ	$2	;DMA-control register (Read)
DMACONR		equ	$2	;DMA-control register (Read)
color00		equ 	$180	;Color palette register
vhposr		equ	$6	;Position (read)
write		equ	-48	; text to screen

; Copper Registers

cop1lc		equ	$80	;Address of 1st. Copper list
COP1LC		equ	$dff080	;Address of 1st. Copper-list
cop2lc		equ	$84	;Address of 2nd. Copper-list
copjmp1		equ	$88	;Junp to Copper-List 1
copjmp2		equ	$8a	;Jump to Copper-List 2

; Bitplane Registers

bplcon0		equ	$100	;Bit plane control register 0
bplcon1		equ	$102	;1 (Scroll Value)
bplcon2		equ	$104	;2 (Sprite<>Playfield Priority)
bpl1pth		equ	$0e0	;Pointer to 1st. bitplane
bpl1ptl		equ	$0e2	;Low
bpl1mod		equ	$108	;Modulo value  sfor odd bit planes
bpl2mod		equ	$10a	;Modulo value for even bit planes
diwstrt		equ	$08e	;Start of screen window
diwstop		equ	$090	;End of screen window
ddfstrt		equ	$092	;bit plane DMA start
ddfstop		equ 	$094	;bit plane DMA stop
bltcon0		equ	$40	;Blitter control register 0(ShiftA,Usex,LFx)
bltcon1		equ	$42	;Blitter control register 1(ShiftB,misc. Bits)
bltafwm		equ	$44	;Mask for first data wrod from source A
bltalwm		equ	$46	;Mask for first data word from source B
bltcpth		equ	$48	;Pointer to source C
bltcptl		equ	$4a
bltbpth		equ     $4c	;Pointer to source B
bltbptl		equ	$4e
bltapt		equ	$50	;Pointer to source A
bltapth		equ	$50	;Pointer to source A
bltaptl		equ	$52	
bltdpth		equ	$54	;Pointer to target data D
bltdptl		equ	$56	
bltsize		equ	$58	;HBlitter window width/height
bltcmod		equ	$60	;Modulo value for source C
bltbmod		equ	$62	;Modulo value for source B
bltamod		equ	$64	;Modulo value for source A
bltdmod		equ	$66	;Modulo value for target D
bltcdat		equ	$70	;Source C data register
bltbdat		equ	$72	;Source B data register
bltadat		equ	$74	;Source A data register
BLTCON0		equ	$40	;Blitter control register 0(ShiftA,Usex,LFx)
BLTCON1		equ	$42	;Blitter control register 1(ShiftB,misc. Bits)
BLTAFWM		equ	$44	;Mask for first data wrod from source A
BLTALWM		equ	$46	;Mask for first data word from source B

bltcpt		equ	$48	;Pointer to source C
BLTCPT		equ	$48	;Pointer to source C
BLTCPTH		equ	$48	;Pointer to source C
BLTCPTL		equ	$4a
BLTBPT		equ	$4c	;Pointer to source B
bltbpt		equ	$4c	;Pointer to source B
BLTBPTH		equ	$4c	;Pointer to source B
BLTBPTL		equ	$4e
BLTAPT		equ	$50	;Pointer to source A
BLTAPTH		equ	$50	;Pointer to source A
BLTAPTL		equ	$52	
bltdpt		equ	$54	;Pointer to target D
BLTDPT		equ	$54	;Pointer to target D
BLTDPTH		equ	$54	;Pointer to target data D
BLTDPTL		equ	$56	
BLTSIZE		equ	$58	;HBlitter window width/height
BLTCMOD		equ	$60	;Modulo value for source C
BLTBMOD		equ	$62	;Modulo value for source B
BLTAMOD		equ	$64	;Modulo value for source A
BLTDMOD		equ	$6  	;Modulo value for target D
BLTCDAT		equ	$70	;Source C data register
BLTBDAT		equ	$72	;Source B data register
BLTADAT		equ	$74	;Source A data register

;CIA-A port register A (Mouse key)
ciaapra		equ	$bfe001
delay		equ	-198

; Set pen colors 

setrgb4     	equ 	 -288
viewportaddress equ	-300 


;Wait for button to be pressed
;Button selection 0 is for mouse
;Button selection 1 is for joystick

WaitButton	MACRO

ButtonWait\1:
	
	btst.b	#6+0\1,$bfe001
	bne.s	ButtonWait\1

		ENDM

IFER    T     �  u�%���ROR		MACRO
	beq	\1
		ENDM

IFERR		MACRO
	beq	\1
		ENDM

Setup_Intuition_Data	MACRO

intname:	dc.b	'intuition.library',0
		cnop	0,2
intbase:	dc.l	0

		ENDM
Setup_Graphics_Data	MACRO

gfxname:	dc.b	'graphics.library',0
		cnop	0,2
gfxbase:	dc.l	0

		ENDM
		
Setup_Dos_Data	MACRO

dosname:	dc.b	'dos.library',0
		cnop	0,2
dosbase:	dc.l	0
filehandle:	dc.l	0
		ENDM

AddPort		MACRO
		move.l	$4,a6 
		jsr	-330(a6)	;alloc signal
		cmp.b	#$ff,d0
		beq.s	endaddport

		move.b	d0,signal

		move.l	#0,a1
		move.l	$4,a6
		jsr	-294(a6)	;find task

		move.l	d0,thistask

		lea	\1(pc),a1
		move.l	$4,a6
		jsr	-354(a6)	;add port
		move.l	d0,MsgPort
endaddport:

		ENDM

SendMsg		MACRO
; \1 - portname
; \2 - ptr to msg
		lea	\1(pc),a1
		move.l	$4,a6
		jsr	-390(a6)	;find port

		move.l	d0,a0
		move.l	\2,a1
		move.l	$4,a6
		jsr	-366(a6)	;send msg
		ENDM

GetMsg		MACRO
; \1 - portname
; \2 - ptr to msg

		lea	\1(pc),a1
		move.l	$4,a6
		jsr	-390(a6)	;find port

		move.l	d0,a0
		move.l	$4,a6
		jsr	-372(a6)	;get msg
		move.l	d0,\2

		ENDM

RemovePort	MACRO
; \1 - portname
		lea	\1(pc),a1
		move.l	$4,a6
		jsr	-390(a6)	;find port

		move.l	d0,a1
		move.l	$4,a6
		jsr	-360(a6)	;remove port
		ENDM

PrintHexNum	MACRO
; Print a Hex Number -----------------------------------------
;	D0=Binary Number


	movem.l	d0-d7/a0-a6,-(sp)

		move.l	dosbase,a6
		jsr	-60(a6)
		move.l	d0,outhandle			;output handle

	movem.l	(sp)+,d0-d7/a0-a6
	movem.l	d0-d7/a0-a6,-(sp)

	moveq	#7,d1			;length of digits

	moveq	#1,d2
	move.l	d0,d5
doit2:
	move.l	d5,d0
	rol.l	#4,d0
	move.l	d0,d5
	and.l	#$f,d0
	cmp.b	#0,d2
	beq.s	zeros2
	cmp.b	#0,d0
	beq.s	nozeros2
zeros2:
	moveq	#0,d2
	cmp.b	#$a,d0
	blt.s	noletter
	add.b	#7,d0
noletter:
	move.b	d0,prtchr
	add.b	#$30,prtchr
	lea	prtchr(pc),a1
	moveq	#1,d3

	movem.l	d0-d7/a0-a6,-(sp)
		move.l	a1,d2			;text pointer
		move.l	outhandle,d1
		move.l	dosbase,a6
		jsr	-48(a6)			;write text
	movem.l	(sp)+,d0-d7/a0-a6

nozeros2:
	dbra	d1,doit2

	movem.l	(sp)+,d0-d7/a0-a6
	bra.s	endhexnum

outhandle	dc.l	0
prtchr		dc.b	0,0,0
		cnop	0,2

endhexnum:
		ENDM


; Print a Carrige Return and a Line Feed
PrintCRLF	MACRO
		movem.l	d0-d7/a0-a6,-(sp)

		move.l	dosbase,a6
		jsr	-60(a6)
		move.l	d0,d1			;output handle

		lea	crlf(pc),a1
		moveq	#2,d3			;length

		move.l	a1,d2			;text pointer
		move.l	dosbase,a6
		jsr	-48(a6)

		movem.l	(sp)+,d0-d7/a0-a6
		bra.s	endprintcr

crlf:		dc.b	13,10
		cnop	0,2
endprintcr:

		ENDM

Setup_Msg	MACRO
MsgPort	
		dc.l	0

		ENDM

AllocMem	MACRO

		IFC	'\2A','A'
		move.l	#$10002,d1
		ENDC
		IFC	'\2A','ChipA'
		move.l	#$10002,d1
		ENDC
		IFC	'\2A','chipA'
		move.l	#$10002,d1
		ENDC
		IFC	'\2A','CHIPA'
		move.l	#$10002,d1
		ENDC
		IFC	'\2A','CA'
		move.l	#$10002,d1
		ENDC
		IFC	'\2A','cA'
		move.l	#$10002,d1
		ENDC
		IFC	'\2A','FastA'
		move.l	#$10004,d1
		ENDC
		IFC	'\2A','fastA'
		move.l	#$10004,d1
		ENDC
		IFC	'\2A','FASTA'
		move.l	#$10004,d1
		ENDC
		IFC	'\2A','FA'
		move.l	#$10004,d1
		END
		IFC	'\2A','fA'
		move.l	#$10004,d1
		ENDC
		IFC	'\2A','PUBLICA'
		move.l	#$10001,d1
		ENDC
		IFC	'\2A','publicA'
		move.l	#$10001,d1
		ENDC
		IFC	'\2A','PublicA'
		move.l	#$10001,d1
		ENDC
		IFC	'\2A','PA'
		move.l	#$10001,d1
		ENDC
		IFC	'\2A','pA'
		move.l	#$10001,d1
		ENDC
		move.l	#\1,d0		;length
		move.l	$4,a6
		jsr	-198(a6)

		ENDM

FreeMem		MACRO

		move.l	#\1,d0		;size of ram
		move.l	\2,a1		;pointer to ram location
		move.l	$4,a6
		jsr	-210(a6)

		ENDM

OpenIntuition	MACRO

       move.l  $4,a6 	       ;EXEC base address
       lea     intname,a1      ;name of intuition library
       jsr     -408(a6)        ;Open intuition
       move.l  d0,intbase      ;Save Intuition base address

		ENDM

CloseIntuition	MACRO

       move.l  $4,a6		;*close Intuition
       move.l  intbase,a1       ;intuition base address in A1
       jsr     -414(a6)		;close intuition

       		ENDM


OpenDos		MACRO

       move.l  $4,a6 	       ;EXEC base address
       lea dosname,a1      ;name of intuition library
       jsr     -408(a6)        ;Open intuition
       move.l  d0,dosbase      ;Save Intuition base address

		ENDM

CloseDos	MACRO

       move.l  $4,a6		;*close Intuition
       move.l  dosbase,a1       ;intuition base address in A1
       jsr     -414(a6)		;close intuition

       		ENDM

Read		MACRO
		
		move.l	\2,d2		;pointer
		move.l	#\1,d3		;length
		IFC	'\3A','A'
		move.l	filehandle,d1	;filehandle
		ENDC
		IFNC	'\3A','A'
		move.l	\3,d1
		ENDC

		move.l	dosbase,a6
		jsr	-42(a6)
  
     		ENDM

Write		MACRO

		move.l	\2,d2		;pointer
		move.l	#\1,d3		;length
		IFC	'\3A','A'
		move.l	filehandle,d1
		ENDC
		IFNC	'\3A','A'
		move.l	\3,d1
		ENDC
		move.l	dosbase,a6
		jsr	-42(a6)

		ENDM


Open		MACRO
		move.l	dosbase,a6

		lea	\1,a0

		move.l	a0,d1

		IFC	'\2A','A'
		move.l	#1005,d2	;Mode Old
		ENDC
		IFC	'\2A','oldA'
		move.l	#1005,d2	;Mode Old
		ENDC
		IFC	'\2A','oA'
		move.l	#1005,d2	;Mode Old
		ENDC
		IFC	'\2A','OldA'
		move.l	#1005,d2	;Mode Old
		ENDC
		IFC	'\2A','OLDA'
		move.l	#1005,d2	;Mode Old
		ENDC
		IFC	'\2A','OA'
		move.l	#1005,d2	;Mode Old
		ENDC
		IFC	'\2A','NewA'
		move.l	#1006,d2	;Mode New
		ENDC
		IFC	'\2A','newA'
		move.l	#1006,d2	;Mode New
		ENDC
		IFC	'\2A','NA'
		move.l	#1006,d2	;Mode New
		ENDC
		IFC	'\2A','nA'
		move.l	#1006,d2	;Mode New
		ENDC
		IFC	'\2A','NEWA'
		move.l	#1006,d2	;Mode New
		ENDC
		jsr	-30(a6)

		IFC	'\3A','A'
		move.l	d0,filehandle
		ENDC
		IFNC	'\3A','A'
		move.l	d0,\3
		ENDC

		ENDM

Close		MACRO

		move.l	dosbase,a6
		IFC	'\1A','A'
		move.l	filehandle,d1
		ENDC
		IFNC	'\1A','A'
		move.l	\1,d1
		ENDC
		jsr	-36(a6)

		ENDM

OpenWindow	MACRO

	move.l	intbase,a6
	lea	window(pc),a0
	jsr	-204(a6)
;	move.l	d0,a1			;These 2 lines were taken
;	move.l	50(a1),a2		;out 
	move.l	d0,windowhd

		ENDM

CloseWindow	MACRO

	move.l  intbase,a6
	move.l	windowhd,a0
	jsr 	-72(a6)

		ENDM


OpenScreen	MACRO

       move.l  intbase,a6      ;Intuition base address in A6
       lea     Screen,a0  ;Pointer to Table
       jsr     -198(a6)  ;OPen

;       move.l  d0,a0           ;get screen pointer ready
;       move.l  $c0(a0),bitplane1       ;get pointer to bit plane # 1
;       move.l  $c4(a0),bitplane2       ;get pointer to bit plane # 2
       move.l  d0,screenhd     ;Save Screen Handle

		ENDM

CloseScreen	MACRO
       move.l  intbase,a6      ;Intuition base address in A6
       move.l  screenhd,a0     ;Screen Handle in A0
       jsr     -66(a6) ;And Move

	       ENDM

OpenGraphics	MACRO
      
	move.l  $4,a6     ;EXEC base address
        lea     gfxname,a1      ;name of graphics library
	jsr     -408(a6)     ;Open graphics library
	move.l  d0,gfxbase      ;Save graphics base address

		ENDM

CloseGraphics	MACRO
	
	move.l	gfxbase,a1
	move.l	$4,a6
	jsr	-414(a6)
	
		ENDM

DrawLine	MACRO

	movem.l	d0-d6/a0-a2,-(sp)

	move.l	#$dff000,a1

	sub.w	d0,d2
	bmi	xneg

	sub.w	d1,d3
	bmi	yneg

	cmp.w	d3,d2
	bmi	ygtx

	moveq	#$11,d5			;OCTANT1+LINEMODE,d5
	bra	lineagain

ygtx:
	exg	d2,d3
	moveq	#$1,d5			;OCTANT2+LINEMODE,d5
	bra	lineagain

yneg:
	neg.w	d3
	cmp.w	d3,d2
	bmi	ynygtx

	moveq	#$19,d5			;OCTANT8+LINEMODE,d5
	bra	lineagain

ynygtx:
	exg	d2,d3
	moveq	#5,d5			;OCTANT7+LINEMODE,d5
	bra	lineagain

xneg:
	neg.w	d2
	sub.w	d1,d3
	bmi	xyneg
	cmp.w	d3,d2
	bmi	xnygtx
	moveq	#$15,d5			;OCTANT4+LINEMODE,d5
	bra	lineagain

xnygtx:
	exg	d2,d3
	moveq	#9,d5			;OCTANT3+LINEMODE,d5
	bra	lineagain

xyneg:
	neg.w	d3
	cmp.w	d3,d2
	bmi	xynygtx

	moveq	#$1d,d5			;OCTANT5+LINEMODE,d5
	bra	lineagain

xynygtx:
	exg	d2,d3
	moveq	#$d,d5			;OCTANT6+LINEMODE,d5

lineagain:
	mulu.w	d4,d1
	ror.l	#4,d0
	add.w	d0,d0
	add.l	d1,a0
	add.w	d0,a0
	swap	d0
	or.w	#$bfa,d0
	lsl.w	#2,d3
	add.w	d2,d2
	move.w	d2,d1
	lsl.w	#5,d1
	add.w	#$42,d1

waitblit:
	btst.b	#6,dmaconr(a1)		;DMAB_BLTDONE-8,dmaconr(a1)
	bne.s	waitblit

	move.w	d3,bltbmod(a1)
	sub.w	d2,d3
	ext.l	d3
	move.l	d3,bltapth(a1)
	bpl.s	lineover
	or.w	#$40,d5			;SIGNFLAG,d5
lineover:
	move.w	d0,bltcon0(a1)
	move.w	d5,bltcon1(a1)
	move.w	d4,bltcmod(a1)
	move.w	d4,bltdmod(a1)
	sub.w	d2,d3
	move.w	d3,bltamod(a1)
	move.w	#$8000,bltadat(a1)
	moveq	#-1,d5
	move.l	d5,bltafwm(a1)
	move.l	a0,bltcpth(a1)
	move.l	a0,bltdpth(a1)
	move.w	d1,bltsize(a1)

	movem.l	(sp)+,d0-d6/a0-a2

		ENDM

Screen_Defs	MACRO
Screen:	
	dc.w    0       ;x-position
	dc.w    0       ;y-position
	dc.w    \1      ;width
	dc.w    \2      ;height
	dc.w    \3      ;Number of Bit Planes 2
	dc.b    0       ;Text Colour  equ  White
	dc.b    1       ;Background Color  equ  Red
	dc.w    2       ;Representation Mode
	dc.w    15      ;Screen Type:Custom Screen
	dc.l    0       ;Standard Character Set

	IFC	'\5A','A'
	dc.l	0
	ENDC
	IFNC	'\5A','A'
	dc.l    sname   ;Pointer to title text
	ENDC
	
	dc.l    0       ;No gadgets
	dc.l    0       ;No Bit Map

	IFNC	'\4A','YA'
screenhd:      dc