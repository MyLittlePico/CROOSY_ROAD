; Copyright © MyLittlePico 2022
; CROOSY ROAD™
; ALL RIGHT RESEVERED TO YU,GUO-WEI
; B1105150
;

		AREA	HelloW,CODE,READONLY
SWI_WriteC	EQU	&0
SWI_Exit		EQU	&11
SWI_ReadC	EQU	&4
SWI_Write0	EQU	&2
SWI_Clock	EQU	&61
SWI_Time		EQU	&63
SWI_CLI		EQU	&5

		ENTRY

START	
	
	ADRL	r1,SEED		; SEED preset
	SWI	SWI_Time
	STR	r0,[r1]

	ADRL	r0,START_MENU
	SWI	SWI_Write0

START1
	SWI	SWI_ReadC
	CMP	r0,#&1b		; escape
	BEQ	EXIT
	CMP	r0,#&0a		; enter
	BNE	START1

GAME_START
	BL	GAME_SET
	BL	GAME
	B	START


	
;---------------------------------------------------------------------------------------------
;			DATA SPACE
CHICK_X
	DCD	0	; default 37
CHICK_Y
	DCD	0	; default 33
;------------------------------
CAR_1A
	DCD	0,0,0	; car type, car x axis, distance to the next car
CAR_1B
	DCD	0,0,0
CAR_1C
	DCD	0,0,0
CAR_1D
	DCD	0,0,0
CAR_1E
	DCD	0,0,0
;------------------------------
CAR_2A
	DCD	0,0,0
CAR_2B
	DCD	0,0,0
CAR_2C
	DCD	0,0,0
CAR_2D
	DCD	0,0,0
;------------------------------
CAR_3A
	DCD	0,0,0
CAR_3B
	DCD	0,0,0
CAR_3C
	DCD	0,0,0
;------------------------------
CAR_4A
	DCD	0,0,0
CAR_4B
	DCD	0,0,0
CAR_4C
	DCD	0,0,0
;------------------------------
CAR_5A
	DCD	0,0,0
CAR_5B
	DCD	0,0,0
CAR_5C
	DCD	0,0,0
CAR_5D
	DCD	0,0,0
;------------------------------
CAR_6A
	DCD	0,0,0
CAR_6B
	DCD	0,0,0
CAR_6C
	DCD	0,0,0
CAR_6D
	DCD	0,0,0
CAR_6E
	DCD	0,0,0
;End of data section

BYE	=	&0a,&0d,&0a,&0d,&0a,&0d,"OK,BYE.",&0a,&0d,&0a,&0d,&0a,&0d,0

ALIGN
;---------------------------------------------------------------------------------------------

EXIT
	ADR	r0,BYE
	SWI	SWI_Write0
	SWI	SWI_Exit

;---------------------------------------------------------------------------------------------

GAME
	STMFD	SP!,{LR}
GAME_1	
	BL	DRAW_MAP
	BL	DRAW_CHICK
	BL	FLIP_SCREEN

	BL	CLEAN_CHICK
	BL	CLEAR_MAP

	BL	MOVE_CHICK	
	BL	MOVE_CAR
	BL	CHICK_CHECK	; if dead, return 1 in r0 ; if win, return 2 in r0

	CMP	r0,#1
	BEQ	GAME_DEAD
	CMP	r0,#2
	BEQ	GAME_WIN

	B	GAME_1

GAME_WIN
	ADRL	r0,SCREEN_BUFFER
	SWI	SWI_Write0
	ADRL	r0,WIN
	SWI	SWI_Write0	
GAME_WIN_1
	SWI	SWI_ReadC
	CMP	r0,#&0a		; enter
	BEQ	GAME_RESTART
	CMP	r0,#&1B		; escape
	BLEQ	EXIT
	B	GAME_WIN_1
	
GAME_DEAD
	ADRL	r0,SCREEN_BUFFER
	SWI	SWI_Write0
	ADRL	r0,DEAD
	SWI	SWI_Write0
GAME_DEAD_1
	SWI	SWI_ReadC
	CMP	r0,#&0a		; enter
	BEQ	GAME_RESTART
	CMP	r0,#&1B		; escape
	BLEQ	EXIT
	B	GAME_DEAD_1

GAME_RESTART
	LDMFD	SP!,{LR}
	MOV	pc,LR

;---------------------------------------------------------------------------------------------
FLIP_SCREEN
	ADRL	r0,SCREEN_BUFFER
	SWI	SWI_Write0
	ADRL	r0,MAP
	SWI	SWI_Write0
	MOV	pc,LR
;---------------------------------------------------------------------------------------------
CHICK_CHECK
	ADRL	r1,CHICK_Y
	LDR	r2,[r1]
	SUB	r1,r1,#4

	CMP	r2,#2
	BEQ	CHICK_CHECK_WIN
	CMP	r2,#6
	BLT	CHICK_CHECK_LANE1
	CMP	r2,#10
	BLT	CHICK_CHECK_LANE2
	CMP	r2,#14
	BLT	CHICK_CHECK_LANE3
	CMP	r2,#31
	BGT	CHICK_CHECK_FINE
	CMP	r2,#27
	BGT	CHICK_CHECK_LANE6
	CMP	r2,#23
	BGT	CHICK_CHECK_LANE5
	CMP	r2,#19
	BGT	CHICK_CHECK_LANE4
	B	CHICK_CHECK_FINE

CHICK_CHECK_LANE1				; r1 : data address	r4 : car X
	LDR	r2,[r1]				; r2 : chicken X	r5 : number of car
	ADRL	r1,CAR_1A			; r3 : car width
	MOV	r5,#5				

CHICK_CHECK_LANE1_1
	LDR	r0,[r1],#4		; get car type
	CMP	r0,#2
	MOVEQ	r3,#16
	MOVNE	r3,#11
	LDR	r0,[r1],#8
	SUB	r0,r0,#1
	CMP	r2,r0
	BLT	CHICK_CHECK_LANE1_2	;safe
	ADD	r0,r0,r3
	CMP	r2,r0
	BGT	CHICK_CHECK_LANE1_2	;safe
	B	CHICK_CHECK_DEAD
	
CHICK_CHECK_LANE1_2
	SUB	r5,r5,#1
	CMP	r5,#0
	BEQ	CHICK_CHECK_FINE
	B	CHICK_CHECK_LANE1_1


CHICK_CHECK_LANE2				; r1 : data address	r4 : car X
	LDR	r2,[r1]				; r2 : chicken X	r5 : number of car
	ADRL	r1,CAR_2A			; r3 : car width
	MOV	r5,#4				

CHICK_CHECK_LANE2_1
	LDR	r0,[r1],#4		; get car type
	CMP	r0,#2
	MOVEQ	r3,#16
	MOVNE	r3,#11
	LDR	r0,[r1],#8
	SUB	r0,r0,#1
	CMP	r2,r0
	BLT	CHICK_CHECK_LANE2_2	;safe
	ADD	r0,r0,r3
	CMP	r2,r0
	BGT	CHICK_CHECK_LANE2_2	;safe
	B	CHICK_CHECK_DEAD
	
CHICK_CHECK_LANE2_2
	SUB	r5,r5,#1
	CMP	r5,#0
	BEQ	CHICK_CHECK_FINE
	B	CHICK_CHECK_LANE1_1


CHICK_CHECK_LANE3				; r1 : data address	r4 : car X
	LDR	r2,[r1]				; r2 : chicken X	r5 : number of car
	ADRL	r1,CAR_3A			; r3 : car width
	MOV	r5,#3				

CHICK_CHECK_LANE3_1
	LDR	r0,[r1],#4		; get car type
	CMP	r0,#2
	MOVEQ	r3,#16
	MOVNE	r3,#11
	LDR	r0,[r1],#8
	SUB	r0,r0,#1
	CMP	r2,r0
	BLT	CHICK_CHECK_LANE3_2	;safe
	ADD	r0,r0,r3
	CMP	r2,r0
	BGT	CHICK_CHECK_LANE3_2	;safe
	B	CHICK_CHECK_DEAD
	
CHICK_CHECK_LANE3_2
	SUB	r5,r5,#1
	CMP	r5,#0
	BEQ	CHICK_CHECK_FINE
	B	CHICK_CHECK_LANE3_1


CHICK_CHECK_LANE4				; r1 : data address	r4 : car X
	LDR	r2,[r1]				; r2 : chicken X	r5 : number of car
	ADRL	r1,CAR_4A			; r3 : car width
	MOV	r5,#3				

CHICK_CHECK_LANE4_1
	LDR	r0,[r1],#4		; get car type
	CMP	r0,#2
	MOVEQ	r3,#16
	MOVNE	r3,#11
	LDR	r0,[r1],#8
	SUB	r0,r0,#1
	CMP	r2,r0
	BLT	CHICK_CHECK_LANE4_2	;safe
	ADD	r0,r0,r3
	CMP	r2,r0
	BGT	CHICK_CHECK_LANE4_2	;safe
	B	CHICK_CHECK_DEAD
	
CHICK_CHECK_LANE4_2
	SUB	r5,r5,#1
	CMP	r5,#0
	BEQ	CHICK_CHECK_FINE
	B	CHICK_CHECK_LANE3_1
	

CHICK_CHECK_LANE5				; r1 : data address	r4 : car X
	LDR	r2,[r1]				; r2 : chicken X	r5 : number of car
	ADRL	r1,CAR_5A			; r3 : car width
	MOV	r5,#4				

CHICK_CHECK_LANE5_1
	LDR	r0,[r1],#4		; get car type
	CMP	r0,#2
	MOVEQ	r3,#16
	MOVNE	r3,#11
	LDR	r0,[r1],#8
	SUB	r0,r0,#1
	CMP	r2,r0
	BLT	CHICK_CHECK_LANE5_2	;safe
	ADD	r0,r0,r3
	CMP	r2,r0
	BGT	CHICK_CHECK_LANE5_2	;safe
	B	CHICK_CHECK_DEAD
	
CHICK_CHECK_LANE5_2
	SUB	r5,r5,#1
	CMP	r5,#0
	BEQ	CHICK_CHECK_FINE
	B	CHICK_CHECK_LANE1_1

CHICK_CHECK_LANE6				; r1 : data address	r4 : car X
	LDR	r2,[r1]				; r2 : chicken X	r5 : number of car
	ADRL	r1,CAR_6A			; r3 : car width
	MOV	r5,#5				

CHICK_CHECK_LANE6_1
	LDR	r0,[r1],#4		; get car type
	CMP	r0,#2
	MOVEQ	r3,#16
	MOVNE	r3,#11
	LDR	r0,[r1],#8
	SUB	r0,r0,#1
	CMP	r2,r0
	BLT	CHICK_CHECK_LANE6_2	;safe
	ADD	r0,r0,r3
	CMP	r2,r0
	BGT	CHICK_CHECK_LANE6_2	;safe
	B	CHICK_CHECK_DEAD
	
CHICK_CHECK_LANE6_2
	SUB	r5,r5,#1
	CMP	r5,#0
	BEQ	CHICK_CHECK_FINE
	B	CHICK_CHECK_LANE6_1



CHICK_CHECK_FINE
	MOV	r0,#0
	MOV	pc,LR

CHICK_CHECK_DEAD
	MOV	r0,#1
	MOV	pc,LR

CHICK_CHECK_WIN
	MOV	r0,#2
	MOV	pc,LR

;---------------------------------------------------------------------------------------------

MOVE_CAR
	STMFD	SP!,{LR}
	ADRL	r1,CAR_1A
	MOV	r2,#5		;number
	MOV	r3,#1		;speed
	BL	MOVE_CAR_LEFT
	ADRL	r1,CAR_2A
	MOV	r2,#4		;number
	MOV	r3,#2		;speed
	BL	MOVE_CAR_LEFT
	ADRL	r1,CAR_3A
	MOV	r2,#3		;number
	MOV	r3,#3		;speed
	BL	MOVE_CAR_LEFT
	ADRL	r1,CAR_4A
	MOV	r2,#3		;number
	MOV	r3,#3		;speed
	BL	MOVE_CAR_RIGHT
	ADRL	r1,CAR_5A
	MOV	r2,#4		;number
	MOV	r3,#2		;speed
	BL	MOVE_CAR_RIGHT
	ADRL	r1,CAR_6A
	MOV	r2,#5		;number
	MOV	r3,#1		;speed
	BL	MOVE_CAR_RIGHT
	
	LDMFD	SP!,{LR}
	MOV	pc,LR

; r1 : address r2 : number r3 : speed
; r4 : x axis     r5 ; width
; r6 : rightmost position 
; r7 : trigger
; r8 : address.
; r9 ; rightmost space
; r10 


MOVE_CAR_LEFT
	MOV	r7,#0		; trigger
	MOV	r8,#0
	MOV	r10,#0
	

MOVE_CAR_LEFT_1
	LDR	r5,[r1],#4		; get car type
	LDR	r4,[r1],#4		; get x
	LDR	r0,[r1]		; get dist

	CMP	r5,#2
	MOVEQ	r5,#16
	MOVNE	r5,#11		; get width
	SUB	r4,r4,r3		; move left
	ADD	r6,r4,r5		; get rightmost
	ADD	r9,r4,r0
	CMP	r9,r10
	MOVGT	r10,r9

	CMP	r6,#0
	MOVLT	r7,#1
	SUBLT	r8,r1,#4
	
	SUB	r1,r1,#4
	STR	r4,[r1],#8		; save new x

	SUB	r2,r2,#1
	CMP	r2,#0
	BNE	MOVE_CAR_LEFT_1	
	CMP	r7,#0
	BEQ	MOVE_CAR_LEFT_2
	
	STR	r10,[r8]		; sace fixed x

MOVE_CAR_LEFT_2
	MOV	pc,LR



; r1 : address r2 : number r3 : speed
; r4 : x axis     r5 ; width
; r6 : leftmost position 
; r7 : trigger
; r8 : address.
; r9 ; leftmost space
; r10 

MOVE_CAR_RIGHT
	MOV	r7,#0		; trigger
	MOV	r8,#0
	MOV	r10,#100
	

MOVE_CAR_RIGHT_1

	ADD	r1,r1,#4		
	LDR	r4,[r1]		; get x

	
	ADD	r4,r4,r3		; move RIGHT

	MOV	r9,r4
	CMP	r9,r10
	MOVLT	r10,r9

	CMP	r4,#74
	MOVGT	r7,#1
	MOVGT	r8,r1

	STR	r4,[r1],#8	; save new x

	SUB	r2,r2,#1
	CMP	r2,#0
	BNE	MOVE_CAR_RIGHT_1	
	CMP	r7,#0
	BEQ	MOVE_CAR_RIGHT_2
	
	ADD	r8,r8,#4
	LDR	r1,[r8]
	SUB	r8,r8,#4
	SUB	r10,r10,r1
	STR	r10,[r8]		; sace fixed x
	

MOVE_CAR_RIGHT_2
	MOV	pc,LR





;---------------------------------------------------------------------------------------------
MOVE_CHICK
	ADRL	r0,CHICK_X
	LDR	r1,[r0],#4		; x
	LDR	r2,[r0]		; y
MOVE_CHICK_1
	SWI	SWI_ReadC
	
	CMP	r0,#&77		; w
	BEQ	MOVE_UP
	CMP	r0,#&57		; W
	BEQ	MOVE_UP

	CMP	r0,#&61		; a
	BEQ	MOVE_LEFT
	CMP	r0,#&41		; A
	BEQ	MOVE_LEFT

	CMP	r0,#&73		; s
	BEQ	MOVE_DOWN
	CMP	r0,#&53		; S
	BEQ	MOVE_DOWN

	CMP	r0,#&64		; d
	BEQ	MOVE_RIGHT
	CMP	r0,#&44		; D
	BEQ	MOVE_RIGHT
	B	MOVE_CHICK_1

MOVE_UP
	SUB	r2,r2,#1
	
	CMP	r2,#31		;  <- can't stand on the strip
	SUBEQ	r2,r2,#1
	CMP	r2,#27
	SUBEQ	r2,r2,#1
	CMP	r2,#23
	SUBEQ	r2,r2,#1
	CMP	r2,#19
	SUBEQ	r2,r2,#1
	CMP	r2,#14
	SUBEQ	r2,r2,#1
	CMP	r2,#10
	SUBEQ	r2,r2,#1
	CMP	r2,#6
	SUBEQ	r2,r2,#1
	B	MOVE_CHICK_CHECK_POS

MOVE_DOWN
	ADD	r2,r2,#1

	CMP	r2,#31		;  <- can't stand on the strip
	ADDEQ	r2,r2,#1
	CMP	r2,#27
	ADDEQ	r2,r2,#1
	CMP	r2,#23
	ADDEQ	r2,r2,#1
	CMP	r2,#19
	ADDEQ	r2,r2,#1
	CMP	r2,#14
	ADDEQ	r2,r2,#1
	CMP	r2,#10
	ADDEQ	r2,r2,#1
	CMP	r2,#6
	ADDEQ	r2,r2,#1
	B	MOVE_CHICK_CHECK_POS

MOVE_LEFT
	SUB	r1,r1,#1
	B	MOVE_CHICK_CHECK_POS

MOVE_RIGHT
	ADD	r1,r1,#1
	B	MOVE_CHICK_CHECK_POS

MOVE_CHICK_CHECK_POS
	CMP	r1,#0
	BLT	MOVE_INVALID
	CMP	r1,#72
	BGT	MOVE_INVALID
	CMP	r2,#34
	BGE	MOVE_INVALID
	
	CMP	r2,#15		; <- can't collide with tree
	BLT	MOVE_VALID
	CMP	r2,#18
	BGT	MOVE_VALID

	CMP	r1,#5
	BLT	MOVE_VALID
	CMP	r1,#8
	BLE	MOVE_INVALID
	CMP	r1,#20
	BLT	MOVE_VALID
	CMP	r1,#23
	BLE	MOVE_INVALID
	CMP	r1,#35
	BLT	MOVE_VALID
	CMP	r1,#38
	BLE	MOVE_INVALID
	CMP	r1,#50
	BLT	MOVE_VALID
	CMP	r1,#53
	BLE	MOVE_INVALID
	CMP	r1,#65
	BLT	MOVE_VALID
	CMP	r1,#68
	BLE	MOVE_INVALID
	B	MOVE_VALID


MOVE_INVALID
	MOV	pc,LR

MOVE_VALID
	ADRL	r0,CHICK_X
	STR	r1,[r0],#4
	STR	r2,[r0]
	MOV	pc,LR



;---------------------------------------------------------------------------------------------
CLEAN_CHICK
	ADRL	r0,CHICK_X
	LDR	r1,[r0],#4		; x value
	ADRL	r2,MAP
	ADD	r2,r2,r1
	LDR	r1,[r0]		; y value
CLEAN_CHICK_1
	CMP	r1,#0
	BEQ	CLEAN_CHICK_2
	ADD	r2,r2,#76
	SUB	r1,r1,#1
	B	CLEAN_CHICK_1
CLEAN_CHICK_2
	MOV	r0,#&20		;" "
	STRB	r0,[r2],#1
	STRB	r0,[r2]

	MOV	pc,LR
;---------------------------------------------------------------------------------------------
DRAW_CHICK
	ADRL	r0,CHICK_X
	LDR	r1,[r0],#4		; x value
	ADRL	r2,MAP
	ADD	r2,r2,r1
	LDR	r1,[r0]		; y value
DRAW_CHICK_1
	CMP	r1,#0
	BEQ	DRAW_CHICK_2
	ADD	r2,r2,#76
	SUB	r1,r1,#1
	B	DRAW_CHICK_1

DRAW_CHICK_2
	MOV	r0,#&40		;"@"
	STRB	r0,[r2],#1
	MOV	r0,#&3e		;">"
	STRB	r0,[r2]

	MOV	pc,LR

;---------------------------------------------------------------------------------------------

CLEAR_MAP
	MOV	r0,#&20
	ADRL	r1,M3
	MOV	r2,#74	; loop
	MOV	r3,#3	;   |
	MOV	r4,#3	;   |
	MOV	r5,#2	; loop

CLEAR_MAP_1
	STRB	r0,[r1],#1
	SUB	r2,r2,#1		; 74 times
	CMP	r2,#0
	BNE	CLEAR_MAP_1

	ADD	r1,r1,#2	;next lane
	MOV	r2,#74
	SUB	r3,r3,#1		; 3 times
	CMP	r3,#0
	BNE	CLEAR_MAP_1
	
	ADD	r1,r1,#76
	MOV	r3,#3
	SUB	r4,r4,#1		; 3 times
	CMP	r4,#0
	BNE	CLEAR_MAP_1

	ADD	r1,r1,#190	; can not use  r1,r1,#382
	ADD	r1,r1,#190	; why?
	MOV	r4,#3
	SUB	r5,r5,#1		; 2 times
	CMP	r5,#0
	BNE	CLEAR_MAP_1

	MOV	pc,LR

;---------------------------------------------------------------------------------------------
;		row diff = #76 = #&4C
DRAW_MAP
	MOV	r1,#5		; car number for each lane
	MOV	r2,#4
	MOV	r3,#3
	MOV	r4,#3
	MOV	r5,#4
	MOV	r6,#5
	STMFD	SP!,{LR,R1-R6}

	ADRL	r1,CAR_1A	; car data
	MOV	r2,#0		; car image address
	ADRL	r3,M3		; map address
	MOV	r4,#3		; loop, a car contains 3 rows
	LDMFD	SP!,{r5}		; loop, car number in current lane
	MOV	r6,#3		; loop, half a map contains 3 lanes
	MOV	r7,#2		; loop, upper and lower half
	MOV	r9,r3		; copy map address to r9



DRAW_MAP_1
	CMP	r7,#1
	BEQ	DRAW_MAP_LOWER

DRAW_MAP_UPPER			; upper half
	ADRL	r2,CAR_REVERSE		; drive leftward
	B	DRAW_MAP_2
DRAW_MAP_LOWER			; lower half
	ADRL	r2,CAR			; drive rightward

DRAW_MAP_2
	LDR	r8,[r1],#4		; get car type
	CMP	r8,#1
	ADDEQ	r2,r2,#36		; shift to track's address
	CMP	r8,#2	
	ADDEQ	r2,r2,#72		; shift to tank's address

DRAW_MAP_3
	LDR	r8,[r1]		; get car x-axis
	ADD	r9,r9,r8		; coresponding map address

DRAW_MAP_4
	CMP	r8,#0		; r8 is x-axis
	BLT	DRAW_MAP_OFR_N
	CMP	r8,#73
	BGT	DRAW_MAP_OFR_P

	LDRB	r0,[r2],#1			; get image segement
	CMP	r0,#0
	BEQ	DRAW_MAP_5
	STRB	r0,[r9],#1			; put it on the map
	ADD	r8,r8,#1			; current x position
	B	DRAW_MAP_4

DRAW_MAP_OFR_N	; out of range , negative
	LDRB	r0,[r2],#1
	CMP	r0,#0
	BEQ	DRAW_MAP_5
	ADD	r8,r8,#1		; r8 is x axis
	ADD	r9,r9,#1
	CMP	r8,#0
	BEQ	DRAW_MAP_4	; when r8 increment equal 0 , draw the rest
	B	DRAW_MAP_OFR_N

DRAW_MAP_OFR_P	; out of range , postive
	LDRB	r0,[r2],#1
	CMP	r0,#0
	BEQ	DRAW_MAP_5		; next row
	B	DRAW_MAP_OFR_P

DRAW_MAP_5
	SUB	r4,r4,#1			; count down	loop r4 : 3 rows in a car's image
	CMP	r4,#0
	BEQ	DRAW_MAP_NEXT
	ADD	r9,r3,#76			; shift to second row
	CMP	r4,#1
	ADDEQ	r9,r9,#76			; sihft to third row
	B	DRAW_MAP_3

DRAW_MAP_NEXT				; draw next car
	MOV	r4,#3			; reset r4
	MOV	r9,r3			; reset address
	ADD	r1,r1,#8			; shift to next car's data
	SUB	r5,r5,#1			; count down 	loop r5 : car number in a lane
	CMP	r5,#0
	BEQ	DRAW_MAP_NEXT_1	; go to next lane
	B	DRAW_MAP_1

DRAW_MAP_NEXT_1
	SUB	r6,r6,#1			; count down	loop r6 : upper 3 lanes or lower 3 lanes
	CMP	r6,#0
	BEQ	DRAW_MAP_NEXT_2	; go to next half of map
	ADD	r3,r3,#304		; shift 4 rows
	MOV	r9,r3			; copy address to r9
	LDMFD	SP!,{r5}			; load car number of new lane
	B	DRAW_MAP_1

DRAW_MAP_NEXT_2
	MOV	r6,#3			; reset r6
	SUB	r7,r7,#1			; count down	loop r7 : upper half and lower half
	CMP	r7,#0
	BEQ	DRAW_MAP_EXIT
	ADD	r3,r3,#684		; shift to frist lane of lower half
	MOV	r9,r3
	LDMFD	SP!,{r5}
	B	DRAW_MAP_1
	
DRAW_MAP_EXIT
	LDMFD	SP!,{LR}
	MOV	pc,LR

;---------------------------------------------------------------------------------------------

GAME_SET
	STMFD	SP!,{LR}
	BL	RANDOMIZE_CAR_TYPE
	BL	RANDOMIZE_CAR_LOCATION
	BL	SET_CHICKEN


	LDMFD	SP!,{LR}
	MOV	pc,LR

;---------------------------------------------------------------------------------------------

SET_CHICKEN
	ADRL	r0,CHICK_X
	MOV	r1,#37
	STR	r1,[r0],#4		; x axis
	MOV	r1,#33
	STR	r1,[r0]		; y axis
	MOV	pc,LR

;---------------------------------------------------------------------------------------------

RANDOMIZE_CAR_TYPE
	STMFD	SP!,{LR}
	MOV	r6,#24		; repeat 24 times
	ADRL	r5,CAR_1A

RANDOMIZE_CAR_TYPE_1
	BL	RAND
	AND	r1,r0,#&f		; reduce the range to 0~15
	MOV	r2,#3
	BL	MODULO		; r0=r1%r2	
	STR	r0,[r5],#8		; also go to the next address
	CMP	r0,#2		; if the vehicel is a tank
	MOVEQ	r0,#16		; tank length
	MOVNE	r0,#11		; other
	STR	r0,[r5],#4		; distribute car length

	SUB	r6,r6,#1			; count down
	CMP	r6,#0
	BNE	RANDOMIZE_CAR_TYPE_1
	LDMFD	SP!,{LR}
	MOV	pc,LR

;---------------------------------------------------------------------------------------------

RANDOMIZE_CAR_LOCATION
	MOV	r1,#5		; distribute car number to rows
	MOV	r2,#4
	MOV	r3,#3
	MOV	r4,#3
	MOV	r5,#4
	MOV	r6,#5
	MOV	r7,#0		; trigger

	STMFD	SP!,{LR,R1-R7}

	ADRL	r5,CAR_1A	; type-> x axis -> distance
	ADD	r5,r5,#4		; move to car's x-axis data space

RANDOMIZE_CAR_LOCATION_1

	LDMFD	SP!,{r6}
	CMP	r6,#0
	BEQ	RANDOMIZE_CAR_LOCATION_EXIT
	CMP	r6,#5
	BEQ	RAND_CAR_S
	CMP	r6,#4
	BEQ	RAND_CAR_M
	CMP	r6,#3

RAND_CAR_F	;	randomize car location , lane fast
	MOV	r7,#0		; value to x-axis

	BL	RAND
	AND	r1,r0,#&3f
	MOV	r2,#7
	BL	MODULO		
	ADD	r7,r7,r0		; initial position	

RAND_CAR_F_1
	CMP	r6,#0
	BEQ	RANDOMIZE_CAR_LOCATION_1	; go to next row

	BL	RAND
	AND	r1,r0,#&3f		; reduce the range to 0~63
	MOV	r2,#7
	BL	MODULO		; r0=r1%r2

	
	STR	r7,[r5],#4		; store x value
	LDR	r1,[r5]		; get distance to the next
	ADD	r1,r1,r0		; add ramdon value
	ADD	r1,r1,#12		; add fixed value
	STR	r1,[r5],#8
	ADD	r7,r7,r1
	SUB	r6,r6,#1

	B	RAND_CAR_F_1

RAND_CAR_M	;	randomize car location , lane medium
	MOV	r7,#0		; value to x-axis

	BL	RAND
	AND	r1,r0,#&3f
	MOV	r2,#5
	BL	MODULO		
	ADD	r7,r7,r0		; initial position	

RAND_CAR_M_1
	CMP	r6,#0
	BEQ	RANDOMIZE_CAR_LOCATION_1	; go to next row

	BL	RAND
	AND	r1,r0,#&3f		; reduce the range to 0~63
	MOV	r2,#5
	BL	MODULO		; r0=r1%r2

	
	STR	r7,[r5],#4		; store x value
	LDR	r1,[r5]		; get distance to the next
	ADD	r1,r1,r0		; add ramdon value
	ADD	r1,r1,#8		; add fixed value
	STR	r1,[r5],#8
	ADD	r7,r7,r1
	SUB	r6,r6,#1

	B	RAND_CAR_M_1


RAND_CAR_S	;	randomize car location , lane slow
	MOV	r7,#0		; value to x-axis

	BL	RAND
	AND	r1,r0,#&3f
	MOV	r2,#3
	BL	MODULO		
	ADD	r7,r7,r0		; initial position	

RAND_CAR_S_1
	CMP	r6,#0				; r6 number of cars
	BEQ	RANDOMIZE_CAR_LOCATION_1	; go to next row

	BL	RAND
	AND	r1,r0,#&3f		; reduce the range to 0~63
	MOV	r2,#3
	BL	MODULO		; r0=r1%r2

	
	STR	r7,[r5],#4		; store x value
	LDR	r1,[r5]		; get distance to the next
	ADD	r1,r1,r0		; add ramdon value
	ADD	r1,r1,#4		; add fixed value
	STR	r1,[r5],#8
	ADD	r7,r7,r1
	SUB	r6,r6,#1

	B	RAND_CAR_S_1


RANDOMIZE_CAR_LOCATION_EXIT
	LDMFD	SP!,{LR}
	MOV	pc,LR

;---------------------------------------------------------------------------------------------
;		Dandom Value		#r0~r4 used#
; set r0 as seed, output result in r0.	#Using middle-square method#	#Unsigned seed and result#

RAND	
	ADR	r1,SEED
	LDR	r0,[r1]		; load seed
		
	MOV	r3,r0		
	MOV	r4,r0

	SWI	SWI_Clock
	MOV	r0,r0,LSL #3	
	ADD	r3,r3,r0
	SUB	r4,r4,r0
;	^ enhance randomness^

	UMULL	r2,r1,r3,r4		; [r1,r2]=r0*r0	32bits*32bits->64bits
	
	MOV	r2,r2,LSL #16
	MOV	r1,r1,LSR #16
	ORR	r0,r1,r2		; middle 32bits of a 64bits value 

	ADR	r1,SEED
	STR	r0,[r1]		; save as a new seed

	MOV	pc,LR

SEED
	DCD	0	; reserve a 32 bits data space


;---------------------------------------------------------------------------------------------
;		Modulo operation		#r0~r2 used#
;		division remainder return in r0	

MODULO		;{r0=r1%r2}
	CMP	r1,r2
	BLT	MODULO_QUIT
	SUB	r1,r1,r2
	B	MODULO
MODULO_QUIT
	MOV	r0,r1
	MOV	pc,LR

;---------------------------------------------------------------------------------------------





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  IMAGE AREA

SCREEN_BUFFER	=	&0a,&0a,&0a,&0a,&0a,&0a,0


START_MENU
A0	=	&0a,&0d
A1	=	&0a,&0d
A2	=	&0a,&0d
A3	=	"        ,-                 -,         ,,        ,-               ",&0a,&0d
A4	=	"      *X**>    >^*#^     ^X**$,     >#**#~    .X**>   ,X   #",&0a,&0d
A5	=	"      #.       >. .#    -X    #.   .#   .#    ?~       ?, -?",&0a,&0d
A6	=	"     X~        >.  #    >,    ?~   ?     **   ?~       -> #",&0a,&0d
A7	=	"     X,        >. ?>    #     ^*   $     *?   .X?       ?*?",&0a,&0d
A8	=	"     X,        >>??     #     ^*   $     *?     ^#~     ~$,",&0a,&0d
A9	=	"     X-        >. X,    =.    ?~   #.    **      .#      X",&0a,&0d
A10	=	"     ,X        >. ,#    ^=    $    ,$    $        $      X ",&0a,&0d
A11	=	"      =X^>=    >.  =-    >=^>#-     >?>>X-    ==^=?      X       ",&0a,&0d
A12	=	"       ~>>-    ~.  .>     ->>.       ~>>.     .>>*       ^",&0a,&0d
A13	=	&0a,&0d
A14	=	&0a,&0d
A15	=	&0a,&0d
A16	=	&0a,&0d
A17	=	&0a,&0d
A18	=	"             .XXX^      >X#X        X.     .XXXX,                ",&0a,&0d
A19	=	"             .* ,X.    >=  -$.     .=^     .$  ~?~               ",&0a,&0d
A20	=	"             .*  ~~   .X    ,=     = #     .$   .#               ",&0a,&0d
A21	=	"             .*  X    ^*     $     # X-    .$    X               ",&0a,&0d
A22	=	"             .X?X,    =*     #    -= ,^    .$    =               ",&0a,&0d
A23	=	"             .* ?~    ^*     $    ?^^^$    .$    #               ",&0a,&0d
A24	=	"             .*  #     X    ->   .X,,,?~   .$   ,X               ",&0a,&0d
A25	=	"             .*  ~?    =^  .$.   ~?   ,>   .$  ,$.               ",&0a,&0d
A26	=	"             .*  .$     *$#?,    ?.    #   .$$#*,  ",&0a,&0d
A27	=	&0a,&0d
A28	=	&0a,&0d
A29	=	&0a,&0d
A30	=	"                  -> PRESS ENTER TO START <- ",&0a,&0d
A31	=	&0a,&0d
A32	=	&0a,&0d
A33	=	&0a,&0d
A34	=	"________________________________________________________________________",&0a,&0d,0


DEAD
B0	=	&0a,&0d
B1	=	&0a,&0d
B2	=	&0a,&0d
B3	=	"           --.      ,-.    .~^>^~.      ~-       -~              ",&0a,&0d
B4	=	"           ~#^     ,$=   -X#?**^X#X.    $?       ?#.             ",&0a,&0d
B5	=	"           .>#-   ,XX.  *$=,     ,X#-   $?       ?#.             ",&0a,&0d
B6	=	"            .?#. .=#,  ,#X        .#?.  $?       ?#.             ",&0a,&0d
B7	=	"             ,#? ^#-   >$-         >#~  $?       ?#.             ",&0a,&0d
B8	=	"              ~$?#^    =$          ~#*  $?       ?#.             ",&0a,&0d
B9	=	"               >$=.    =$.         *#~  #?       ?#.             ",&0a,&0d
B10	=	"               ,$*     *#>         XX.  #?.      X#              ",&0a,&0d
B11	=	"               ,$*      X$~       >$^   ?X-     -#>              ",&0a,&0d
B12	=	"               ,$*      .=#=-...*?$~    .XX*...*X?.              ",&0a,&0d
B13	=	"               ,=~        ->?##X=^.      .^?##X=*.               ",&0a,&0d
B14	=	&0a,&0d
B15	=	&0a,&0d
B16	=	&0a,&0d
B17	=	"            .-~~~~~-,      ,~   .-~~~~~~,  ,~~~~~~-,             ",&0a,&0d
B18	=	"            ~#=^>=X#$#~    ^$.  ,?X^^^^^-  ^$>^>=##$?-           ",&0a,&0d
B19	=	"            ~#~     ,>$*   ^$.  ,?>        ^$,     -?#~          ",&0a,&0d
B20	=	"            ~#~      .=#,  ^$.  ,?>        ^$,      ,?#.         ",&0a,&0d
B21	=	"            ~#~       *#~  ^$.  ,?=.....   ^$,       ^$-         ",&0a,&0d
B22	=	"            ~#~       ~#^  ^$.  ,?$$$$$$$$$$$$   ^$,       *$~         ",&0a,&0d
B23	=	"            ~#~       *#~  ^$.  ,?>.....   ^$,       >$-         ",&0a,&0d
B24	=	"            ~#~      .=#.  ^$.  ,?>        ^$,      ,?X.         ",&0a,&0d
B25	=	"            ~#~     .>#~   ^$.  ,?>        ^$,     ,?#-          ",&0a,&0d
B26	=	"            ~#^~~~>X$X-    ^$.  ,??~~~~~-  ^$*~~*>X$=,           ",&0a,&0d
B27	=	"            ,^>>>>^~,      ~>.  .*>>>>>>^  ->>>>>^~,             ",&0a,&0d
B28	=	&0a,&0d
B29	=	&0a,&0d
B30	=	"                 -> PRESS ENTER TO RESTART <-",&0a,&0d
B31	=	&0a,&0d
B32	=	"                   -> PRESS ESC TO LEAVE <-",&0a,&0d
B33	=	&0a,&0d
B34	=	"________________________________________________________________________",&0a,&0d,0


WIN
C0	=	" .. . .. .  . .... .  . .. . .. .  . .... .. .  . . .. .. . .  . .. .. . .  .",&0a,&0d
C1	=	".  . . .. .. .  . . .. .. . .  . .. .... .  . .. . .. .  *##^,. .  . .. . .. ",&0a,&0d
C2	=	" .. . .. .  . .... .  . .. . .. .  . .... .. .  . . .. .-=..~^ . .. .. . .  .",&0a,&0d
C3	=	".  . . .. .. .  . . .. .. . .  . .. .... .  . ..-~~~~.. *,...=- .  . .. . .. ",&0a,&0d
C4	=	" .. .... . .. .... .. . .. . .. .  . .... .. .,##????X?=X... .-* .. .. . .  .",&0a,&0d
C5	=	".  . . .. .. .  . . .. .. . .  ..-------,.  .*X>*******?, ,-...=.  . .. . .. ",&0a,&0d
C6	=	" .. . .. .  . .... .. . .. .,*###############=**********=-#X?~*X .. .. . .  .",&0a,&0d
C7	=	".  . . .. .. .  . . .. ...>##XX>**********XXX##*********># .... .  . .. . .. ",&0a,&0d
C8	=	" .. . .. .  . .... .  ..##X**~~~~--------~~~~~*^X#?*****=#, .  . .. .. . .  .",&0a,&0d
C9	=	".  . . .. .. .  . . .,X#X*~~~------------------~~~~##***># .... .  . .. . .. ",&0a,&0d
C10	=	" .. . .. .  . .... .>##*~~~-----------------------~~~*#*#-. .  . .. .. . .  .",&0a,&0d
C11	=	".  . . .. .. .  . .X#=~~-----------~~~~~~------------~*^#X .... .. . *.*#>.. ",&0a,&0d
C12	=	".  . . .. .. .  .,#X*~----------~~~~~~~~~~~~~~~~~~~~~~~**X#,... .  . ^. ,#-. ",&0a,&0d
C13	=	" .. . .. .  . ..*#X*~--------~~~~~~~~~~~~~~~~~~~~~~~~~~***>#??????. ?.  .,X>.",&0a,&0d
C14	=	".  . . .. ..>???#X*~-------~~~~~~~~~~~~~~~~~~~~~~~~~~~****^#******##,... ..#-",&0a,&0d
C15	=	" .. . .. .=X?^^X=~------~~~~~~~~~~~~~~~~~~~**************?*---~~~~~=~.==,..#-",&0a,&0d
C16	=	".  . . ..~#^^^X?~~----~~~~~~~~~~~~~~~~~******^??X##?????^-----~~~***#X#~~X#- ",&0a,&0d
C17	=	" .. .... *#**?=~-----~~~~~~~~~~~~~~~~******?#^~----------------~~~~*>#,. . ..",&0a,&0d
C18	=	".. . . ..*#*XX*~----~~~~~~~~~~~~~~~******^#^--------------~~~~~~~~~*^##.. .. ",&0a,&0d
C19	=	".........,X?#>~----~~~~~~~~~~~~~~~*******#*---------------~~~~******##,......",&0a,&0d
C20	=	".  . . .. ^#=~~---~~~~~~~~~~~~~~********#>-----------------~~~*****=#?. . .. ",&0a,&0d
C21	=	" .. . .. .XX*~---~~~~~~~~~~~~**********^#~~----------------~~~~***=#^. . .  .",&0a,&0d
C22	=	".  . . ..>#>~---~~~~~******************=^~~~-----~~~~~~~--~~~~~**^#~ .. . .. ",&0a,&0d
C23	=	" .. . ~=#X*~~--~~~***********^>>^******=~~~~----~~~~~~~~~~~*****^#. .. . .  .",&0a,&0d
C24	=	".  .~##X*~~---~~~************X-~#=*****=***~~~~~~~~~~~~~~~~*****#- . .. . .. ",&0a,&0d
C25	=	" .*##?~~~---~~~~************~X--~X^****=***~~~~~~*****~~~~~****?>.. .. . .  .",&0a,&0d
C26	=	".~#X*~~~~~~~~~~*************~X--~^#=***^?**~~~~~******~~~~****>#.  . .. . .. ",&0a,&0d
C27	=	",XX**~~~~~~~~~***************X-~~~*#^***#***~~~********~~*****#~ .. .. . .  .",&0a,&0d
C28	=	"-#~**~~~~~~~*******~**~~~^=**X~~~~*=#***~?***~****~******~**^#= .  . .. . .. ",&0a,&0d
C29	=	"-#****~~************~*~~----^^?--~~*#=***>?****************^#~ . .. .. . .  .",&0a,&0d
C30	=	"-#X******************~~--~~---~--~~~*#****^#^**********~*~##~.. .  . .. . .. ",&0a,&0d
C31	=	" =#>***********~*****~~~**~~~--~~~~~*=#*****X##~*****~X####,.  . .. .. . .  .",&0a,&0d
C32	=	"..###?*************X*******~~~~~*****>#^*******########>=#..... .  . .. . .. ",&0a,&0d
C33	=	" ...####X************^X^****~~~~******#=**************^X> . .  . .. .. . .  .",&0a,&0d
C34	=	".  . ,,>###XX=*********^#XX^*********>#=************~X#-.. .... .  . .. . .. ",&0a,&0d
C35	=	"..........-*X##XX>*******^^X##XXXXXXX##***********>X##,......................",&0a,&0d
C36	=	" .. .... . ...-~?#####??******^^^^>>^^**********?##X-. .. . .  . .. .. . .  .",&0a,&0d
C37	=	".  . . .. .. .  . .~~>####X??^************~=??###*,.. . .. .... .. . .... .. ",&0a,&0d
C38	=	" .. .... . .. .... .. . -*~?#####X=====X#####?~-. . .. .. . .. . .. .. . . ..",&0a,&0d
C39	=	".... . .. .. ...... .. .. .....~**********- . .. . .. . .. .... .... .... .. ",&0a,&0d
C40	=	".............................................................................",&0a,&0d
C41	=	&0a,&0d
C42	=	"                         WINNER WINNER CHINKEN DINNER",&0a,&0d
C43	=	"                         -> PRESS ENTER TO RESTART <-",&0a,&0d
C44	=	"                           -> PRESS ESC TO LEAVE <-",&0a,&0d
C45	=	"_____________________________________________________________________________",&0a,&0d,0




	;map size : 74x34
MAP	
M0	=	"                                                                          ",&0a,&0d
M1	=	"  GOAL  GOAL  GOAL  GOAL  GOAL  GOAL  GOAL  GOAL  GOAL  GOAL  GOAL  GOAL  ",&0a,&0d
M2	=	"__________________________________________________________________________",&0a,&0d
M3	=	"                                                                          ",&0a,&0d
M4	=	"                                                                          ",&0a,&0d
M5	=	"                                                                          ",&0a,&0d
M6	=	"--------------------------------------------------------------------------",&0a,&0d
M7	=	"                                                                          ",&0a,&0d
M8	=	"                                                                          ",&0a,&0d
M9	=	"                                                                          ",&0a,&0d
M10	=	"--------------------------------------------------------------------------",&0a,&0d
M11	=	"                                                                          ",&0a,&0d
M12	=	"                                                                          ",&0a,&0d
M13	=	"                                                                          ",&0a,&0d
M14	=	"__________________________________________________________________________",&0a,&0d 
M15	=	"       &              &              &              &              &      ",&0a,&0d
M16	=	"      &&&            &&&            &&&            &&&            &&&     ",&0a,&0d
M17	=	"      &&&            &&&            &&&            &&&            &&&     ",&0a,&0d
M18	=	"       [              [              |              ]              ]      ",&0a,&0d
M19	=	"__________________________________________________________________________",&0a,&0d
M20	=	"                                                                          ",&0a,&0d
M21	=	"                                                                          ",&0a,&0d
M22	=	"                                                                          ",&0a,&0d          
M23	=	"--------------------------------------------------------------------------",&0a,&0d
M24	=	"                                                                          ",&0a,&0d
M25	=	"                                                                          ",&0a,&0d
M26	=	"                                                                          ",&0a,&0d
M27	=	"--------------------------------------------------------------------------",&0a,&0d
M28	=	"                                                                          ",&0a,&0d
M29	=	"                                                                          ",&0a,&0d
M30	=	"                                                                          ",&0a,&0d
M31	=	"__________________________________________________________________________",&0a,&0d
M32	=	"                                                                          ",&0a,&0d     
M33	=	"                                                                          ",&0a,&0d
M34	=	"__________________________________________________________________________",&0a,&0d,0




CHICK	=	"@>",0

CAR	; langth 11
CAR1	=	" =======__ ",0
CAR2	=	"|_^___^___\\",0
CAR3	=	"  O   O    ",0

TRACK	; langth 11
TRACK1	=	" =======|\\ ",0
TRACK2	=	"|_______|_|",0
TRACK3	=	"( )   ( )  ",0

TANK	; langth 16
TANK1	=	"  A#######======",0
TANK2	=	"{[[[||||]]]}    ",0
TANK3	=	" OOOOOOOOOO     ",0


CAR_REVERSE	; langth 11
CAR4	=	" __======= ",0
CAR5	=	"/___^___^_|",0
CAR6	=	"    O   O  ",0

TRACK_REVERSE	; langth 11
TRACK4	=	" /|======= ",0
TRACK5	=	"|_|_______|",0
TRACK6	=	"  ( )   ( )",0

TANK_REVERSE	; langth 16	
TANK4	=	"======#######A  ",0
TANK5	=	"    {[[[||||]]]}",0
TANK6	=	"     OOOOOOOOOO ",0
	END


