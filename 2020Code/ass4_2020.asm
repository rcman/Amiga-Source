  include "include/franco.i"


	OpenIntuition
	IFERR	ErrorIntuition
	OpenDos
	IFERR	ErrorDos
	OpenScreen
	IFERR   ErrorScreen
	OpenWindow
	IFERR	ErrorWindow
	AllocMem	98000,chip
	move.l	d0,MemArea
	IFERR	ErrorMem

	move.l	screenhd,a0
	move.l	$c0(a0),bitplane1
	move.l	$c4(a0),bitplane2
	move.l	$c8(a0),bitplane3
	move.l	$cc(a0),bitplane4
	move.l	$d0(a0),bitplane5

	Open	picture1,old
	IFERR	EndPgm

	Read	8000,bitplane1
	Read	8000,bitplane2
	Read	8000,bitplane3
	Read	8000,bitplane4
	Read	8000,bitplane5

	Close
	
	lea	car,a0
	lea	carmask,a1
	move.w	#14,d0

makemask:

	move.l	(a0)+,d1
	eor.l	#$ffffffff,d1
	move.l	d1,(a1)+
	dbra	d0,makemask

	
	move.l	MemArea,a0
	lea	car,a1
	move.l	#MemArea-car,d0

movecar:	
	move.l	(a1)+,(a0)+
	dbra	d0,movecar

	move.l	bitplane1,a0
	move.l	#100,d0
	move.l	#100,d1

	bsr	CopyBob

	WaitButton	0

	bsr	PlaceBob

	WaitButton	1





EndPgm:
	FreeMem		98000,MemArea
ErrorMem:
	CloseWindow
ErrorWindow:
	CloseScreen
ErrorScreen:
	CloseDos
ErrorDos:
	CloseIntuition
ErrorIntuition:
	rts


; Copy From Blitter Routine ---------------------------------------------
; a0 = pointer to screen to source object
; a1 = pointer to where to place object
; d0 = X coordinates
; d1 = Y coordinates

CopyBob:
	movem.l	d0-d7/a0-a3,-(sp)
	
	move.l	#$dff000,a2
	btst.b	#6,dmaconr(a2)		;DMAB_BLTDONE-8,dmaconr(a1)
waitblit:
	btst.b	#6,dmaconr(a2)		;DMAB_BLTDONE-8,dmaconr(a1)
	bne.s	waitblit
	
	move.l	d0,d2
	lsr.l	#3,d0
	add.l	d0,a0
	mulu	#40,d1
	add.l	d1,a0

	move.w	#$9f0,d4		;Shift Value
	
	move.w	d4,bltcon0(a2)		;Set to LF and registers to use
	move.w	#0,bltcon1(a2)		;Set to 0 for area mode

	move.w	#8,bltamod(a2)		;modulus for A Source
	move.w	#0,bltdmod(a2)		;modulus for D destination

	move.w	#$ffff,bltafwm(a2)	;Mask for source (first word A)
	move.w	#$ffff,bltalwm(a2)	;Mask for source (last word A)

	move.l	a0,bltapth(a2)		;source A pointer
	move.l	a1,bltdpth(a2)		;destination pointer

	move.w	#$0802,bltsize(a2)	;height
	movem.l	(sp)+,d0-d7/a0-a3
	rts

; Copy To Blitter Routine ---------------------------------------------
; a0 = pointer to screen to source object
; a1 = pointer to where to place object
; d0 = X coordinates
; d1 = Y coordinates

PlaceBob:
	movem.l	d0-d7/a0-a3,-(sp)
	

	move.l	#$dff000,a2
	btst.b	#6,dmaconr(a2)		;DMAB_BLTDONE-8,dmaconr(a1)
waitblit2:
	btst.b	#6,dmaconr(a2)		;DMAB_BLTDONE-8,dmaconr(a1)
	bne.s	waitblit2
	
	move.l	d0,d2
	lsr.l	#3,d0			; is this 5 or 3
	add.l	d0,a0
	mulu	#40,d1
	add.l	d1,a0

	move.w	#0*4096,d4		;Shift Value
;	or.w	#$bca,d4
	or.w	#$9f0,d4

	
	move.w	d4,bltcon0(a2)		;Set to LF and registers to use
	move.w	#$000a,bltcon1(a2)		;Set to 0 for area mode

	move.w	#$ffff,bltafwm(a2)	;Mask for source (first word A)
	move.w	#$ffff,bltalwm(a2)	;Mask for source (last word A)

	move.w	#0,bltamod(a2)		;modulus for A Source mask
	move.w	#0,bltbmod(a2)		;modulus for B destination car
	move.w	#0,bltcmod(a2)		;modulus for C destination 
	move.w	#0,bltdmod(a2)		;modulus for D destination

	move.l	MemArea,d0
	move.l	d0,bltbpth(a2)		;source B pointer
	add.l	#carmask-car,d0		;ptr to mask
	move.l	d0,bltapth(a2)		;source A pointer

	move.l	bitplane1,bltcpth(a2)		;source C pointer
	move.l	a0,bltdpth(a2)		;destination pointer

;	move.w	#$0382,bltsize(a2)	;height and width
	move.w	#$0802,bltsize(a2)	;height and width
	movem.l	(sp)+,d0-d7/a0-a3
	rts

; Data Area ------------------------------------------------

	Screen_Defs	320,200,5,Y,<framco was here>
	Window		320,200,Y
	Setup_Intuition_Data
	Setup_Dos_Data

car:
	dc.l	%00000000000000000000000000000000
	dc.l	%00000000000000000000000011100000
	dc.l	%00000000000000000000000100000000
	dc.l	%00000000000000000000000100000000
	dc.l	%00000000111111111110000100000000
	dc.l	%11111111000000000001111111111110
	dc.l	%10000000001000000000000000000001
	dc.l	%10000000000000000000000000000010
	dc.l	%11111100000111111110000000111100
	dc.l	%00000010000100000001100000100000
	dc.l	%000000011110000000000111110
	