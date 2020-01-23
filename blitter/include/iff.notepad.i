    T     è  v lHÊÆ
Find_Color_Map	MACRO

	move.l	windowhd,a0
	move.l	intbase,a6
	jsr	viewportaddress(a6)
	move.l	a0,viewport

	move.l	iff_screen,a0
	lea	bitplane1(pc),a3
	move.b	$1c(a0),d5	;num of bit planes
	move.w	#600,d1

lookcolor:
	cmp.l	#'CMAP',(a0)
	beq.s	setcolor
	add.l	#2,a0
	dbra	d1,lookcolor

setcolor:
	move.l	4(a0),d7	;length of color map
	divu	#3,d7		;num of pens
	add.l	#8,a0

	move.l	a0,a1
        move.l  viewport,a0     ;Get Pointer to View Port
        move.l  gfxbase,a6      ;get grap    T     è  vÉÎ­ics base
	moveq	#0,d0		;pen number
	moveq	#0,d1		;clear r,g,b
	moveq	#0,d2
	moveq	#0,d3

setthecolor:
	move.b	(a1)+,d1	;red
	ror.b	#4,d1
	move.b	(a1)+,d2	;green
	ror.b	#4,d2
	move.b	(a1)+,d3	;blue
	ror.b	#4,d3
	movem.l	d0-d7/a0-a6,-(sp)
        jsr     setrgb4(a6)     ;set a color registor
	movem.l	(sp)+,d0-d7/a0-a6
	addq.l	#1,d0
	dbra	d7,setthecolor

	ENDM


**************************************************************
;a0 = iff_data pointer  	\1
;d0 = row length		\2
;number of lin    T     è  v8Ìuœes		\3
;pointer to bitplane table  	\4

UnPack_IFF	MACRO	


	move.l	\1,d1
	and.b	#$fe,d1
	move.l	d1,a0
	move.w	#600,d1
	move.b	$1c(a0),d5	;num of bit planes

lookbodyxx:
	cmp.l	#'BODY',(a0)
	beq.s	decompressxx
	add.l	#2,a0
	dbra	d1,lookbodyxx

	rts



decompressxx:
;	move.l	4(a0),d7	;length of body
	move.l	#\3,d7		;no. of  lines
 	add.l	#8,a0		;correct offset of data

new_planexx:
	lea	\4(pc),a3
	move.b	d5,d4

decomscreenxx:

	move.l	#\2,d0
	move.l	(a3),a1			;get bit plane pointer
	
    T     è  vK\ÒŽ	
		
dolinexx:
	moveq	#0,d1
	move.b	(a0)+,d1		;read the byte of data
	bmi.s	repeatxx

;----- write out bytes n+1 data ------------

keepthemovexx:
	move.b	(a0)+,(a1)+
	subq	#1,d0
	dble	d1,keepthemovexx
	bra.s	endlinexx

repeatxx:
;----- repeat n+1 bytes out ----------------

	neg.b	d1 
	bmi.s	endlinexx  
	move.b	(a0)+,tempxx

keepmovingxx:

	move.b	tempxx,(a1)+
	subq	#1,d0
	dble	d1,keepmovingxx

endlinexx:
	tst.w	d0
	bgt.s	dolinexx

	add.l	iff_mod,a1
	move.l	a1,(a3)+
	
	subq.w	#1,d4
    T      p