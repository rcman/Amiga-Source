
	include	'include/inc.i'

;-------------------------------------
	OpenIntuition
	IFERROR	ErrorIntuition
	OpenScreen
	IFERROR	ErrorScreen

	move.l	D0,A0			;get screen ptr
	move.l	$C0(A0),bitplane1	;save bitplane ptrs 1-3
	move.l	$C4(A0),bitplane2
	move.l	$C8(A0),bitplane3

	AllocMem	80000,Chip
	move.l	D0,MemArea
	IFERROR	ErrorMem

	lea	enemy(pc),a0		;Shape Data ptr
	move.l	D0,a1			;Chip ram location ptr
	moveq	#64,d0			;length of shape
moveshape1:
	move.l	(a0)+,(a1)+		;move data to chip ram
	dbra	d0,moveshape1

	lea	enemym(pc),a0		;Shape Data ptr
	move.l	MemArea,a1		;Chip ram location ptr
	add.l	#100,a1
	moveq	#64,d0			;length of shape
moveshape2:
	move.l	(a0)+,(a1)+		;move data to chip ram
	dbra	d0,moveshape2

	WaitButton	1


	bsr	BlitShape


	WaitButton	0

EndPgm:
	FreeMem		80000,MemArea
ErrorMem:
	CloseScreen
ErrorScreen:
	CloseIntuition
ErrorIntuition:
	rts

;-------------------------------------
;  Blit Shape to screen
;-------------------------------------

BlitShape:
	move.l	#$dff000,a5
	move.w	#0,bltamod(a5)
	move.w	#0,bltbmod(a5)
	move.w	#36,bltcmod(a5)
	move.w	#36,bltdmod(a5)

	move.w	#$FFFF,bltafwm(a5)
	move.w	#$0,bltalwm(a5)

	move.w	#0,bltcon1(a5)
	move.w	#$0FCA,bltcon0(a5)

	move.l	MemArea,a0
	move.l	a0,bltbpth(a5)		;image ptr
	add.l	#100,a0
	move.l	a0,bltapth(a5)		;mask ptr
	move.l	bitplane1,a1
	move.l	a1,bltcpth(a5)		;screen ptr =
	move.l	a1,bltdpth(a5)		;destination ptr

	move.w	#$0382,bltsize(a5)
	rts

;-------------------------------------
;  Data Area
;-------------------------------------

	Setup_Intuition_Data
	Setup_Dos_Data
	Screen_Defs	320,200,3

MemArea:	dc.l	0


enemy:	dc.w	0,0
	dc.b	%00111000,%00011100,0,0
	dc.b	%01000110,%01100010,0,0
	dc.b	%10000001,%10000001,0,0
	dc.b	%11000100,%00100011,0,0
	dc.b	%10000010,%01000001,0,0
	dc.b	%10000100,%00100001,0,0
	dc.b	%01000000,%00000010,0,0
	dc.b	%00110000,%00001100,0,0
	dc.b	%00001110,%01110000,0,0
	dc.b	%00010001,%10001000,0,0
	dc.b	%00100010,%01000100,0,0
	dc.b	%01000100,%00100010,0,0
	dc.b	%01000010,%01000010,0,0
	dc.b	%00000000,%00000000,0,0
	dc.w	0,0

enemym:	dc.w	0,0
	dc.b	%00111000,%00011100,0,0
	dc.b	%01111110,%01111110,0,0
	dc.b	%11111111,%11111111,0,0
	dc.b	%11111111,%11111111,0,0
	dc.b	%11111111,%11111111,0,0
	dc.b	%11111111,%11111111,0,0
	dc.b	%01111111,%11111110,0,0
	dc.b	%00111111,%11111100,0,0
	dc.b	%00001111,%11110000,0,0
	dc.b	%00011011,%11011000,0,0
	dc.b	%00110011,%11001100,0,0
	dc.b	%01100110,%01100110,0,0
	dc.b	%01100011,%11000110,0,0
	dc.b	%00000000,%00000000,0,0
	dc.w	0,0


	END

