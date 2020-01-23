    T     è  vö}4Ñ* Dos
*



*		IFNC	'A\4','AY'
*		dc.l	0
*		ENDC
*
*		IFC	'A\4','AY'
*		dc.w	$f
*		ENDC
*		IFNC	'A\4','AY'
*		dc.w	1
*		ENDC

OpenDos		MACRO
		lea	dosname(pc),a1
		move.l	$4,a6
		jsr	-408(a6)
		move.l	d0,dosbase
		ENDM

CloseDos	MACRO
		move.l	dosbase,a1
		move.l	$4,a6
		jsr	-414(a6)
		ENDM

* \1 - Buffer Area
* \2 - Length
* \3 - File Handle (if not Given will default)
Write		MACRO
		IFC	'A\3','A'
		move.l	filehandle0,d1		;default
		ENDC
		IFNC	'A\3','A'
		move.l	\3,d1			;your file h    T     è  vé×C[andle
		ENDC
		move.l	\1,d2
		move.l	\2,d3
		move.l	dosbase,a6
		jsr	-48(a6)
		ENDM

* \1 - Buffer Area
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
		move.l	\1,d1			    T     è  vQ¬j;your file handle
		ENDC
		move.l	dosbase,a6
		jsr	-36(a6)
		ENDM

* \1 - Name of file
* \2 - Access Mode (New or Old)
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
	    T     è  v˜RN	ENDC
		IFC	'A\2','Anew'
		move.l	#1006,d2		;new
		ENDC
		IFC	'A\2','AN'
		move.l	#1006,d2		;new
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
		ENDM

SetupDosDat