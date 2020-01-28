include "include/franco.i"

num_shots	equ	4 
num_enemy	equ	80

	OpenDos
	IFERR	ErrorDos
	OpenIntuition
	IFERR	ErrorIntuition
	OpenScreen
	IFERR   ErrorScreen
	OpenWindow
	IFERR	ErrorWindow
	OpenGraphics
	IFERR 	ErrorGfx	

**************************************************************

	move.l	screenhd,a0
	move.l	$c0(a0),bitplane1
	move.l	$c4(a0),bitplane2
	
	move.l	windowhd,a0
	move.l	intbase,a6
	jsr	viewportaddress(a6)
	move.l	a0,viewport

       move.l  #0,d0           ;pen
       move.l  #0,d1           ;red
       move.l  #0,d2           ;green
       move.l  #0,d3           ;blue
       move.l  viewport,a0     ;Get Pointer to View Port
       move.l  gfxbase,a6      ;get grapics base
       jsr     setrgb4(a6)     ;set a color registor


	
;	lea 	enemyh,a0		; A0 hit value
;	lea	enemyx,a1
;	lea	enemyy,a2
;	move.l	#num_shots,d0
;	move.w	#2,0(a2,d0.w)			;sub 1 from y value	
;	move.w	#80,0(a1,d0.w)
;	move.w	#1,0(a0,d0.w)

	moveq	#2,d0

*************************************************************

main:

	bsr	checkjoy
	bsr	TestFire
	bsr	keepmovingshot
	bsr	calcenemy
	
	bsr	heywait

	btst	#6,ciaapra
	bne	main
	bra	EndPgm


TestFire:
	subq	#1,d0
	bne.s	noshoot
	
	moveq	#2,d0

	btst.b	#7,ciaapra		;test fire button
	bne.s	noshoot
	bsr	acc_shoot
	

noshoot:
	rts


;*******************************************************


acc_shoot:

* Variable name for arry for shooting will be
* shotx, shoty

	movem.l d0-d7/a0-a6,-(sp)
	move.l	#num_shots,d0
	lea 	hitval,a0

checkshot:
	
	cmp.w	#0,0(a0,d0.w)
	beq.s	continue1
	subq.w	#2,d0
	bne.s	checkshot
	bra	acc_exit

continue1:

	move.w	#1,0(a0,d0.w)
	lea	shotx,a2
	lea	shoty,a1
	move.w	#176,0(a1,d0.w)		;  y save the y then x co-ordinates1
	move.w	shipx,0(a2,d0.w)	;  x of where the ship was and start
	add.w	#12,0(a2,d0.w)		;  x of where the ship was and start

acc_exit:
	movem.l (sp)+,d0-d7/a0-a6
	rts

***************************************************************************
*		Keep Moving shot					  *
***************************************************************************

keepmovingshot:

	movem.l d0-d7/a0-a6,-(sp)

	move.l	#num_shots,d0
	lea 	hitval,a0		; A0 hit value
	lea	shotx,a1
	lea	shoty,a2

checkshot2:
	
	cmp.w	#0,0(a0,d0.w)		;check a0 hit value
	beq.s	continue2
	bsr	placeshot
	bsr	check_collision

	
	sub.w	#4,0(a2,d0.w)		;sub 1 from y value	
	cmp.w	#4,0(a2,d0.w)		;compare y value to top of screen  
	bne.s	continue2		;if not past, continue
	move.w	#0,0(a0,d0.w)		;clear hit value

continue2:
	subq.w	#2,d0
	bne.s	checkshot2
	movem.l (sp)+,d0-d7/a0-a6
	rts
	
*********************************************************************
*			placeshot				    *
*********************************************************************

placeshot:

	movem.l d0-d7/a0-a6,-(sp)
	move.l	#7,d5
	move.l	bitplane1,a3
	moveq	#0,d3
	moveq	#0,d4
	move.w	0(a1,d0.w),d3		; x value
	move.w	0(a2,d0.w),d4		; y value
	mulu.w	#40,d4
	ror.l	#3,d3			;divide by 8 for by©te boundry
	add.w	d3,d4
	move.w	#0,d3
	rol.l	#3,d3
	lea	shot,a4
sht:
	move.b	(a4)+,d6
	lsr.b	d3,d6
	move.b	d6,0(a3,d4.w)

	add.w	#40,d4
	dbra	d5,sht
	movem.l (sp)+,d0-d7/a0-a6
	rts


*********************************************************************
*			placeshot 2				    *
*********************************************************************

placeship2:

	movem.l d0-d7/a0-a6,-(sp)
	moveq	#5,d5
	move.l	bitplane1,a3
	moveq	#0,d3
	moveq	#0,d4
	move.w	shipx,d3		; x value
	move.w	#18,d4			; y value
	mulu.w	#40,d4
	ror.l	#3,d3			;divide by 8 for byte boundry
	add.w	d3,d4
	move.w	#0,d3
	rol.l	#3,d3
	lea	ship,a4
sht2:
	move.b	#0,0(a3,d4.w)		;write to screen
	move.b	#0,1(a3,d4.w)		;write to screen
	move.b	#0,2(a3,d4.w)		;write to screen
	moveq	#2,d1
	movem.l	d4,-(sp)
shipp2:
	moveq	#0,d6
	move.b	(a4)+,d6
	ror.w	d3,d6			;first part of data
	move.b	0(a3,d4.w),d2		;read from screen
	or.b	d6,d2
	move.b	d2,0(a3,d4.w)		;write to screen

	move.b	#0,d6
	rol.w	d3,d6
	ror.b	d3,d6			;the rest of the data
	move.b	1(a3,d4.w),d2		;read from screen
	or.b	d6,d2
	move.b	d2,1(a3,d4.w)		;write to screen

	addq	#1,d4
	dbra	d1,shipp2
	movem.l	(sp)+,d4

	add.w	#40,d4
	dbra	d5,sht2
	movem.l (sp)+,d0-d7/a0-a6
	rts


*********************************************************************
*			place enemy				    *
*********************************************************************

placeenemy:

	movem.l d0-d7/a0-a6,-(sp)
	moveq	#11,d5
	move.l	bitplane1,a3
	move.l	bitplane2,a5
	moveq	#0,d3
	moveq	#0,d4
	move.w	0(a1,d0.w),d3		; x value
	move.w	0(a2,d0.w),d4		; y value
	mulu.w	#40,d4
	ror.l	#3,d3			;divide by 8 for byte boundry
	add.w	d3,d4
	move.w	#0,d3
	rol.l	#3,d3
	lea	enemy,a4
	lea	enemy2,a6

	cmp.w	#2,0(a0,d0.w)
	bne.s	sht3
	lea	enemy3,a4
	lea	enemy4,a6
	move.w	#0,0(a0,d0.w)

sht3:
	move.b	#0,-1(a3,d4.w)		;write to screen
	move.b	#0,0(a3,d4.w)		;write to screen
	move.b	#0,1(a3,d4.w)		;write to screen
	move.b	#0,2(a3,d4.w)		;write to screen

	move.b	#0,-1(a5,d4.w)		;write to screen
	move.b	#0,0(a5,d4.w)		;write to screen
	move.b	#0,1(a5,d4.w)		;write to screen
	move.b	#0,2(a5,d4.w)		;write to screen

	moveq	#1,d1
	movem.l	d4,-(sp)
enemyloop:
	moveq	#0,d6
	move.b	(a4)+,d6
	ror.w	d3,d6			;first part of data
	move.b	0(a3,d4.w),d2		;read from screen
	or.b	d6,d2
	move.b	d2,0(a3,d4.w)		;write to screen

	move.b	#0,d6
	rol.w	d3,d6
	ror.b	d3,d6			;the rest of the data
	move.b	1(a3,d4.w),d2		;read from screen
	or.b	d6,d2
	move.b	d2,1(a3,d4.w)		;write to screen

	moveq	#0,d6
	move.b	(a6)+,d6
	ror.w	d3,d6			;first part of data
	move.b	0(a5,d4.w),d2		;read from screen
	or.b	d6,d2
	move.b	d2,0(a5,d4.w)		;write to screen

	move.b	#0,d6
	rol.w	d3,d6
	ror.b	d3,d6			;the rest of the data
	move.b	1(a5,d4.w),d2		;read from screen
	or.b	d6,d2
	move.b	d2,1(a5,d4.w)		;write to screen

	addq	#1,d4
	dbra	d1,enemyloop
	movem.l	(sp)+,d4

	add.w	#40,d4
	dbra	d5,sht3
	movem.l (sp)+,d0-d7/a0-a6
	rts

**********************************************************************
*		place enemy					     *
**********************************************************************

calcenemy:
	movem.l d0-d7/a0-a6,-(sp)

	move.l	#num_enemy,d0
	lea 	enemyh,a0		; A0 hit value
	lea	enemyx,a1
	lea	enemyy,a2
	move.w	#0,yflag

checkenemy:
	
	cmp.w	#0,0(a0,d0.w)		;check a0 hit value
	beq.s	continue4
	bsr	placeenemy

	move.w	factx,d6
	add.w	d6,0(a1,d0.w)		;add 1 from x value	
	cmp.w	#304,0(a1,d0.w)
	beq.s	switchdir
	cmp.w	#8,0(a1,d0.w)		;compare y value to top of screen  
	bne.s	continue3		;if not past, continue

switchdir:
	move.w	#1,yflag

continue3:

continue4:
	subq.w	#2,d0
	cmp.w	#-2,d0
	bne.s	checkenemy

	cmp.w	#0,yflag
	beq.s	noswitchdir
	neg.w	factx		;move opposite direction rev value	

	moveq	#num_enemy,d0

loopdown:
	cmp.w	#0,0(a0,d0.w)		;check a0 hit value
	beq.s	nodowning
	add.w	#2,0(a2,d0.w)		;add 1 from y value	
	cmp.w	#170,0(a2,d0.w)		;compare y value to top of screen  
	bne.s	nodowning		;if not pasLr‡Í¡t, continue
	move.w	#2,0(a0,d0.w)		;clear hit value

nodowning:
	subq.w	#2,d0
	cmp.w	#-2,d0
	bne.s	loopdown

noswitchdir:

	movem.l (sp)+,d0-d7/a0-a6
	rts


**********************************************************************
*			Check Joystick				     *
**********************************************************************

checkjoy:
	

	movem.l d0-d7/a0-a6,-(sp)
	move.w	$dff00c,d0
	btst 	#1,d0		; is it right, no?
	beq.s 	noright
	cmp.w	#300,shipx
	beq.s	noright
	Add.w   #2,shipx
	bsr	placeship2

noright:

	btst    #9,d0
 	beq.s 	noleft		; is it left?
	cmp.w	#4,shipx
	beq.s	noleft
	Sub.w	#2,shipx
	bsr	placeship2

noleft:
	movem.l (sp)+,d0-d7/a0-a6
	rts

*******************************************************************
*		Check Collision	of Objects to shots fired	  *
*******************************************************************
; d0 array element of shot
; a0 hit value of shot
; a1 X value of shot
; a2 Y Value of shot

check_collision:

	movem.l d0-d7/a0-a6,-(sp)
	move.w	0(a1,d0.w),d2		; get x co-ordinates of shot
	move.w  0(a2,d0.w),d3		; get y co-ordinates of shot
	move.l	#num_enemy,d1
	lea 	enemyh,a3		; A0 hit value
	lea	enemyx,a4		; enemy x
	lea	enemyy,a5		; enemy y


check1:
	cmp.w	#0,0(a3,d1.w)		;check a0 hit value
	beq.s	noenemyonscn
	move.w  0(a4,d1.w),d4		; get enemy X co-ordinates of enemy
	sub.w	d2,d4			; sub from shot X
	bpl	positive_x		
	neg.w	d4
positive_x:
	move.w  0(a5,d1.w),d5		; get enemy Y co-ordinates of enemy
	sub.w	d3,d5
	bpl	positive_y
	neg.w	d5
positive_y:
	cmp.w	#5,d5
	bge	notcloseenough
	cmp.w	#5,d4
	bge	notcloseenough

	move.w	#2,0(a3,d1.w)
	move.w	#0,0(a0,d0.w)

notcloseenough:
	nop
noenemyonscn:
	subq.w	#2,d1
	cmp.w	#-2,d1
	bne.s	check1
	movem.l (sp)+,d0-d7/a0-a6
	rts


********************************************************************
* 			Wait (time delay)			   *
********************************************************************

heywait:
		movem.l d0-d7/a0-a6,-(sp)
		move.l #0,d1			; Set # to Wait time
		move.l	dosbase,a6
		jsr	delay(a6)
		movem.l (sp)+,d0-d7/a0-a6
		rts

score:
		movem.l d0-d7/a0-a6,-(sp)
		move.l	dosbase,a6
		move.l	windowhd,d1
		move.l	#title,d2
		move.l	#titleend-title,d3
		jsr	write(a6)
		movem.l (sp)+,d0-d7/a0-a6
		rts


EndPgm:	
	CloseGraphics
ErrorGfx:
	CloseWindow
ErrorWindow:
	CloseScreen
ErrorScreen:
	CloseIntuition
ErrorIntuition:
	CloseDos
ErrorDos:
	rts



	Screen_Defs	320,200,4,Y,<framco was here>
	Window		320,200,Y
	Setup_Intuition_Data
	Setup_Dos_Data
	Setup_Graphics_Data

yflag:		dc.w	0
factx:		dc.w	$4
shipx:		dc.w	150	
viewport:	dc.l	0

shotx:		ds.w	100
shoty:		ds.w	100
hitval:		ds.w	100

shot:		dc.b	$80,$80,$80,$80,$00,$00,$00,$00,$00,$00
ship:		dc.b	0,$18,0
		dc.b	0,$3c,0
		dc.b	0,$7e,0
		dc.b	0,$ff,0
		dc.b	0,$00,0
		dc.b	0,$00,0
		dc.b	$0,$0,$0

enemy:
		dc.b	0,0
		dc.b	0,0
		dc.b	%00111100,%00111100
		dc.b	%01000010,%01000010
		dc.b	%10001001,%10010001
		dc.b	%10010000,%00001001
		dc.b	%10000000,%00000001
		dc.b	%01000100,%00100010
		dc.b	%00100000,%00000100
		dc.b	%00011101,%10111000
		dc.b	%00010010,%01001000
		dc.b	%00100010,%01000100
		dc.b	0,0
		dc.b	0,0

enemy2:
		dc.b	0,0
		dc.b	0,0
		dc.b	%00000000,%00000000
		dc.b	%00000000,%00000000
		dc.b	%00011001,%10011000
		dc.b	%00110000,%00001100
		dc.b	%00000000,%00000000
		dc.b	%00000100,%00100000
		dc.b	%00001000,%00010000
		dc.b	%00000001,%10000000
		dc.b	%00000000,%00000000
		dc.b	%00000000,%00000000
		dc.b	0,0
		dc.b	0,0

enemy3:
		dc.b	0,0
		dc.b	0,0
		dc.b	0,0
		dc.b	0,0
		dc.b	0,0
		dc.b	0,0
		dc.b	0,0
		dc.b	0,0
		dc.b	0,0
		dc.b	0,0
		dc.b	0,0
		dc.b	0,0
		dc.b	0,0
		dc.b	0,0

enemy4:
		dc.b	0,0
		dc.b	0,0
		dc.b	0,0
		dc.b	0,0
		dc.b	0,0
		dc.b	0,0
		dc.b	0,0
		dc.b	0,0
		dc.b	0,0
		dc.b	0,0
		dc.b	0,0
		dc.b	0,0
		dc.b	0,0
		dc.b	0,0


enemyh:		dc.w	1,1,1,1,1
		dc.w	1,1,1,1,1
		dc.w	1,1,1,1,1
		dc.w	1,1,1,1,1
		dc.w	1,1,1,1,1
		dc.w	1,1,1,1,1
		dc.w	1,1,1,1,1
		dc.w	1,1,1,1,1
		dc.w	0,0,
		
		
		