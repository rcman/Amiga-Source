; This program draws lines with blitter using DMA channels as well as 
; copper and A,B,C and D DMA blitter channels

; Written By: Franco Gaetan
; Date of Last Revision: June 27, 1991
; File BLITTER.ASM
; Status: Working 


intena		equ	$9a	;Interupt enable register
dmacon		equ	$96	;DMA-control register (Write)
dmaconr		equ	$2	;DMA-control register (Read)
color00		equ 	$180	;Color palette register
vhposr		equ	$6	;Position (read)


; Copper Registers

cop1lc		equ	$80	;Address of 1st. Copper-list
cop2lc		equ	$84	;Address of 2nd. Copper-list
copjmp1		equ	$88	;Junp to Copper-List 1
copjmp2		equ	$8a	;Jump to Copper-List 2

; Bitplane Registers

bplcon0		equ	$100	;Bit plane control register 0
bplcon1		equ	$102	;1 (Scroll Value)
bplcon2		equ	$104	;2 (Sprite<>Playfield Priority)
bpl1pth		equ	$0e0	;Pointer to 1st. bitplane
bpl1ptl		equ	$0e2	;Low
bpl1mod		equ	$108	;Modulo value for odd bit planes
bpl2mod		equ	$10a	;Modulo value for even bit planes
diwstrt		equ	$08e	;Start of screen window
diwstop		equ	$090	;End of screen window
ddfstrt		equ	$092	;bit plane DMA start
ddfstop		equ 	$094	;bit plane DMA stop
bltcon0		equ	$40	;Blitter control register 0(ShiftA,Usex,LFx)
bltcon1		equ	$42	;Blitter control register 1(ShiftB,misc. Bits)
bltcpth		equ	$48	;Pointer to source C
bltcptl		equ	$4a
bltbpth		equ	$4c	;Pointer to source B
bltbptl		equ	$4e
bltapth		equ	$50	;Pointer to source A
bltaptl		equ	$52	
bltdpth		equ	$54	;Pointer to target data D
bltdptl		equ	$56	
bltcmod		equ	$60	;Modulo value for source C
bltbmod		equ	$62	;Modulo value for source B
bltamod		equ	$64	;Modulo value for source A
bltdmod		equ	$66	;Modulo value for target D
bltsize		equ	$58	;HBlitter window width/height
bltcdat		equ	$70	;Source C data register
bltbdat		equ	$72	;Source B data register
bltadat		equ	$74	;Source A data register
bltafwm		equ	$44	;Mask for first data wrod from source A
bltalwn		equ	$46	;Mask for first data word from source B

;CIA-A port register A (Mouse key)
ciaapra		equ	$bfe001

; Exec Library Base Offsets

OpenLibrary	equ	-30-522
Forbid		equ	-30-102
Permit		equ	-30-108
AllocMem	equ	-198	 ;ByteSize,Requirements/d0,d1
FreeMem		equ	-210 ;MemoryBlock,ByteSize/a1,d0

; Graphics Library Base Offsets

OwnBlitter	equ	-30-426
DisownBlitter	equ	-30-432

; Graphics Base

StartList	equ	38

;Other Labels

Execbase	equ	4
Planesize	equ	80*200*4 ;Bitplane size :80 bytes by 200 lines
Planewidth	equ	80
CLsize		equ	3*4	;The Copper-List contains 2\3 commands
Chip		equ	2 	;Allocate Chip-RAM
Clear		equ	Chip+$10000 ; Clear Chip-RAM first

; Initialization

Start:

; Allocate Memrory for bit plane

	move.l	Execbase,a6
	move.l	#Planesize,d0	;Memory requirment for bit plane
	move.l	#Clear,d1	
	jsr	AllocMem(a6)	;Allocate Memory
	move.l	d0,CLadr
	add.l	#10000,d0
	move.l	d0,Planeadr

; Allocate Memory for Copper-List




; Create Copper-List
	
	
	move.l	d0,a0		;Address of Copper-List from a0
	move.l	Planeadr,d0	;Address of Bit-Plane
	move.w	#bpl1pth,(a0)+	;First Copper command in RAM
	swap	d0
	move.w	d0,(a0)+	;Lo-Word of Bitplane address in RAM
	move.w	#bpl1ptl,(a0)+
	swap	d0
	move.w	d0,(a0)+
	move.l	#$fffffffe,(a0)	;End of Copper list



; Allocate Blitter

	move.l	#GRname,a1
	clr.l	d0
	jsr	OpenLibrary(a6)
	move.l	a6,-(sp)	;Execbase from the Stack
	move.l	d0,a6
	move.l	a6,-(sp)
	jsr	OwnBlitter(a6)	;Take over Blitter

; Main Program ****************************
; DMA and Task-Swithing off

	move.l	4(sp),a6	;Execbase to a6
	jsr	Forbid(a6)	;Task swithing off
	lea	$dff000,a5	
	move.w	#$03e0,dmacon(a5)

;Copper initialization

	move.l	CLadr,cop1lc(a5)
	clr.w	copjmp1(a5)

;Set color

	move.w	#$0000,color00(a5)	;Black background
	move.w	#$0fa0,color00+2(a5)	;Yellow line

; Playfield initialization

	move.w	#$2081,diwstrt(a5)
	move.w	#$20c1,diwstop(a5)
	move.w	#$003c,ddfstrt(a5)	;Normal Hires Screen
	move.w	#$00d4,ddfstop(a5)
	move.w	#%1001001000000000,bplcon0(a5)
	clr.w	bplcon1(a5)
	clr.w	bplcon2(a5)
	clr.w	bpl1mod(a5)
	clr.w	bpl2mod(a5)

; DMA on

	move.w	#$83c0,dmacon(a5)












Here:
	btst	#6,ciaapra	;Mouse key pressed
	bne	Here		;No, Continue


;End Program
;Wait till blitter is ready

Done:

Wait:
	btst	#14,dmaconr(a5)
	bne	Wait

;Activate old copper-list

	move.l	(sp)+,a6	;Get GraphicsBase from stack
	move.l	StartList(a6),cop1lc(a5)
	clr.w	copjmp1(a5)	
	move.w	#$8020,dmacon(a5)
	jsr	DisownBlitter(a6)
	move.l	(sp)+,a6
	jsr	Permit(a6)


	move.l	CLadr,a1
	move.l	Execbase,a6
	move.l	#Planesize,d0
	jsr	FreeMem(a6)



Ende:
	clr.l	d0
	rts

;Variables

CLadr:		dc.l	0
Planeadr:	dc.l	0
GRname:		dc.b	'graphics.library',0
		cnop	0,2

; DrawLine draws a line with the Blitter
; The following parameters are used
; d0 = x1  X-coordinates of start points
; d1 = y1  Y-coordinates od start points
; d2 = x2  X-coordinates of end points
; d3 = y2  Y-coordinates of end points
; a0 must point to the first word of the bitplane
; a2 word written directly to mask register
; d4 to d6 are used  as work registers

; Compute the starting address

DrawLine:

	move.l	a1,d4		;width in work register
	mulu	d1,d4		;y1 * bytes per line
	moveq	#-$10,d5	;No leading characters: $f0
	and.w	d0,d5		;bottom four bits masked from X1
	lsr.w	#3,d5		;remainder divided by 8
	add.w	d5,d4		;Y1 * vytes per line + x1/8
	add.l	a0,d4		;plus starting address of the bitplane
				;d4 now contains the starting address
				;of the line
				;compute octants and deltas

	clr.l	d5		;clear work register
	sub.w	d1,d3		;Y2-Y1 DeltaY from d3
	roxl.b	#1,d5        	;restore N-Flag
	tst.w	d3
	bge.s	y2gy1		;When deltaY positive, goto y2gy1
	neg.w	d3
y2gy1:
	sub.w	d0,d2		;X2-X1 DeltaX to d2
	roxl.b	#1,d5		;move leading char in deltaX to d5
	tst.w	d2		;restore N-Flag
	bge.s	x2gx1		;when deltax positive,goto x2gx1
	neg.w	d2		;deltax invert (if not positive)
	
x2gx1:
	move.w	d3,d1		;delta Y to d1
	sub.w	d2,d1		;deltaY-DeltaX
	bge.s	dygdx		;when deltaY >deltaX goto dygdx
	exg	d2,d3		;smaller delta goto d2
	
dygdx:
	roxl.b	#1,d5		;d5 conatins the result of 3 conparisons
	move.b	Octant_Table(pc,d5),d5	;get matching octants
	add.w	d2,d2		;Smaller delta * 2

WBlit:
	btst	#14,dmaconr(a5)	;BBusy-Bit test
	bne.s	WBlit
	
	move.w	d2,bltbmod(a5)	;2 * smaller delta to bltbmod
	sub.w	d3,d2		;2 * smaller delta - larger delta
	bge.s	signn1		;when 2* small delta >large delta
				;to signn1
	or.b	#$40,d5		;sign flag set
	
signn1:
	move.w	d2,bltaptl(a5)	;2*small delta-large delta in bltaptl
	sub.w	d3,d2		;2*smaller delta 2* larger delta
	move.w	d2,bltamod(a5)	;to bltamod

	move.w	#$8000,bltadat(a5)	
	move.w	a2,bltbdat(a5)	;mask from a2 in bltbdat
	move.w	#$ffff,bltafwm(a5)
	and.w	#$000f,d0	;bottom 4 bits of X1
	ror.w	#4,d0		;to start0-3
	or.w	#$0bca,d0	;usex abd LFx set
	move.w	d0,bltcon0(a5)
	move.w	d5,bltcon1(a5)	;octant in blitter
	move.l	d4,bltcpth(a5)	;start address of line to
	move.l	d4,bltdpth(a5)	;bltcpt and bltdpt
	move.w	a1,bltcmod(a5)	;width of bitplane in both
	move.w	a1,bltdmod(a5)	;modulo regsiters

;BLTSIZE initialization
	
	lsl.w	#6,d3		;length * 64
	addq.w	#2,d3		;plus (width =2)
	move.w	d3,bltsize(a5)

	rts

;octant table with line =1 
;the octant table contains code values
;for each octant, shifted to the correct position

Octant_Table:
	
	dc.b	0 *4+1	
	dc.b	4 *4+1
	dc.b	2 *4+1	
	dc.b	5 *4+1
	dc.b	1 *4+1	
	dc.b	6 *4+1
	dc.b	3 *4+1	
	dc.b	7 *4+1

	end
	

	
	



