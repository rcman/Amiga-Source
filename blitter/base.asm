sysbase		equ	4
openlib		equ	-408
closelib	equ	-414

		moveq	#0,d0
		move.l	sysbase,a6
		lea	gfxname(pc),a1
		jsr	openlib(a6)
		move.l	d0,gfxbase
		beq	errorgfx

		move.l	d0,a0
		move.l	$26(a0),copperloc


exit:
		move.l	gfxbase,a1
		move.l	sysbase,a6
		jsr	closelib(a6)
errorgfx:

		rts

gfxbase:
		dc.l	0
copperloc:
		dc.l	0
gfxname:
		dc.b	'graphics.library',0
		cnop	0,2


