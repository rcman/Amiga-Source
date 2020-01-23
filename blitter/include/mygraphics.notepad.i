    T     è  v$éS.* Graphics
*

OpenGfx		MACRO
		lea	gfxname(pc),a1
		move.l	$4,a6
		jsr	-408(a6)
		move.l	d0,gfxbase
		ENDM

CloseGfx	MACRO
		move.l	gfxbase,a1
		move.l	$4,a6
		jsr	-414(a6)
		ENDM

* \1 - Buffer Area
* \2 - Length
* \3 - File Handle (if not Given will default)
Move		MACRO
		IFC	'A\3','A'
		move.l	rastport,a1		;default
		ENDC
		IFNC	'A\3','A'
		move.l	\3,a1			;your file handle
		ENDC
		move.l	\1,d0			;x - coor
		move.l	\2,d1			;y - coor
		move.l	gfxbase,a6
		jsr	-240(a6)
		ENDM

* \1     T     è  v¼Æ¾- Buffer Area
* \2 - Length
* \3 - File Handle (if not Given will default)
Read		MACRO
		IFC	'A\3','A'
		move.l	filehandle0,d1		;default
		ENDC
		IFNC	'A\3','A'
		move.l	\3,d1			;your file handle
		ENDC
		move.l	\1,d2
		move.l	\2,d3
		move.l	dosbase,a6
		jsr	-42(a6)
		ENDM

* \1 - File Handle
Close		MACRO
		IFC	'A\1','A'
		move.l	filehandle0,d1		;default
		ENDC
		IFNC	'A\1','A'
		move.l	\1,d1			;your file handle
		ENDC
		move.l	dosbase,a6
		jsr	-36(a6)
		ENDM

* \1 - Name of file
* \    T     è  vf«2 - Access Mode (New or Old)
Open		MACRO
		lea	\1(pc),a1

		IFC	'A\2','AOLD'
		move.l	#1005,d2		;old
		ENDC
		IFC	'A\2','Aold'
		move.l	#1005,d2		;old
		ENDC
		IFC	'A\2','AOld'
		move.l	#1005,d2		;old
		ENDC
		IFC	'A\2','AO'
		move.l	#1005,d2		;old
		ENDC
		IFC	'A\2','Ao'
		move.l	#1005,d2		;old
		ENDC
		IFC	'A\2','ANEW'
		move.l	#1006,d2		;new
		ENDC
		IFC	'A\2','ANew'
		move.l	#1006,d2		;new
		ENDC
		IFC	'A\2','Anew'
		move.l	#1006,d2		;new
		ENDC
		IFC	'A\2','AN'
		move.l	#1006,d2    T     Â    FáŽ‡		;new
		ENDC
		IFC	'A\2','An'
		move.l	#1006,d2		;new
		ENDC

		move.l	a1,d1
		move.l	dosbase,a6
		jsr	-30(a6)
		IFC	'A\3','A'
		move.l	d0,filehandle0		;default
		ENDC
		IFNC	'A\3','A'
		move.l	d0,\3			;your file handle
		ENDC
		ENDM


IFERR		MACRO
		beq	\1
		ENDM
IFERROR		MACRO
		beq	\1
		ENDM
iferror		MACRO
		beq	\1
		ENDM
iferr		MACRO
		beq	\1
		EN