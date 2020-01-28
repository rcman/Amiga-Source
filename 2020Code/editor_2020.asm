ctlw equ  $dff096
c0thi equ  $dff0a0
c0tlo equ  c0thi+2
c0tl equ   c0thi+4
c0per equ  c0thi+6
c0vol equ  c0thi+8

Openlib		equ 	-408
Closelib	equ	-414
Open		equ	-30
mode_old	equ	1005
IoErr		equ	-132
alloc_abs	equ	-$cc
Close		equ	-30-6
Write		equ	-48
Read		equ	-42
delay		equ	-198
text		equ	-54
AllocMem	equ	-198
FreeMem		equ	-210
sysbase		equ	$4
output		equ	-60
input		equ	-54

;--- Allocate Memory -----------------------

	move.l	sysbase,a6
	move.l	#9000,d0
	move.l	#$10002,d1
	jsr	AllocMem(a6)
	move.l	d0,Memarea
	beq	errordos
	move.l	Memarea,a1
	lea	sinwave,a0
movesound:
	move.l	(a0)+,(a1)+
	cmp.b	#65,(a0)
	bne	movesound
	
run:
	bsr	Init
	bsr	test1
	nop
	bra	qu
	
test1:
	lea	title(pc),a0


test:
	movem.l d0/a0,-(sp)
	bsr	pmsg
	cmp.b	#20,(a0)
	beq	jmpsound
	bsr	sound
jmpsound:
	bsr 	heywait
	bsr	soundoff
	bsr 	heywait
	movem.l	(sp)+,d0/a0

	cmp.b	#0,(a0)+
	bne	test
	rts


Init:
	move.l	sysbase,a6
	lea	dosname(pc),a1
	moveq	#0,d0
	jsr	Openlib(a6)
	move.l	d0,dosbase
	beq	error
	
;	lea	consolname(pc),a1
;	move.l	#mode_old,d0
;	bsr	Openfile
;	beq	error
	move.l	d0,a6
	jsr	output(a6)
	move.l	d0,conhandle

	move.l	dosbase,a6
	jsr	input(a6)
	move.l	d0,inputhand

	move.l	d0,d1
	lea	bufferin(pc),a2
	move.l	a2,d2
	move.l	#2,d3
	move.l	dosbase,a6
	jsr	Read(a6)


	lea	bufferin(pc),a2
	move.l	a2,d2
	move.l	#2,d3
	move.l	conhandle,d1
	move.l	dosbase,a6
	jsr	Write(a6)

	rts

pmsg:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	a0,d2
	move.l	#1,d3	
	
pmsg2:
	move.l	conhandle,d1
	move.l	dosbase,a6
	jsr	Write(a6)
	movem.l (sp)+,d0-d7/a0-a6
	rts
pcrlf:	
	move	#10,d0
	bsr	pchar
	move	#13,d0

pchar:

	movem.l	d0-d7/a0-a6,-(sp)
	move.l	conhandle,d1


sound:
	movem.l	d0-d7/a0-a6,-(sp)
        move.w  #$01,ctlw
	move.l	Memarea,a0
        move.l  a0,c0thi
        move.w  #4,c0tl
        move.w  #64,c0vol
        move.w  #447,c0per
        move.w  #$8001,ctlw
	movem.l	(sp)+,d0-d7/a0-a6
	rts

soundoff:

	move.w	#$01,ctlw
	rts


pch1:
	lea	outline,a1
	move.b	d0,(a1)
	move.l	a1,d2
	move.l	#1,d3
	move.l	dosbase,a6
	jsr	Write(a6)
	movem.l	(sp)+,d0-d7/a0-a6
	rts

getchr:
	move.l	#1,d3
	move.l	conhandle,d1
	lea	inbuff,a1
	move.l	a1,d2
	move.l	dosbase,a6
	jsr	Read(a6)
	clr.l	d0
	move.b	inbuff,d0
	rts

error:

	move.l	dosbase,a6
	jsr	IoErr(a6)
	move.l	d0,d5
	move.l	#-1,d7

qu:

	btst.b	#6,$bfe001
	bne	qu

	move.l	Memarea,a1
	move.l	#9000,d0
	move.l	sysbase,a6
	jsr	FreeMem(a6)
	clr.l	d0

	move.l	conhandle,d1
	move.l	dosbase,a6
	jsr	Close(a6)

	move.l	dosbase,a1
	move.l	sysbase,a6
	jsr	Closelib(a6)
errordos:
	rts


;*****************************************************************
;*                    Delay                                      *
;*****************************************************************

heywait:
		movem.l d0-d7/a0-a6,-(sp)
		move.l	#1,d1			; Set # to Wait time
		move.l	dosbase,a6
		jsr	delay(a6)
		movem.l (sp)+,d0-d7/a0-a6
		rts



Openfile:
	move.l	a1,d1
	move.l	d0,d2

	move.l	dosbase,a6
	jsr	Open(a6)
	tst.l	d0
	rts

dosname:
		dc.b	'dos.library',0,0
		cnop 0,2

dosbase:	dc.l	0

consolname:	dc.b 'CON:0/0/640/200/Program Window',0
	
		cnop 0,2

conhandle	dc.l	0

title:		dc.b 'Hi Franco Doing a Great Job Man!',13,10
		dc.b ' This is a great job!',13,10
		dc.b 'The Once Was a man named dave!',13,10
		dc.b 'The weather outside is frightful',10,13
		dc.b 'the fire insides delightful!',13,10
		dc.b 'and there simply no place to go!',13,10
		dc.b 'Let it snow, Let it snow, Let it snow!',13,10
		dc.b 'Awesome!',10,10,0
titleend:
		cnop 0,2

mytext:		dc.b 	$9b,'4;31;40m'
		dc.b	'Underline'
		dc.b	$9b,'3;33;40m',$9b,'5;20H'
		dc.b	'This is' 