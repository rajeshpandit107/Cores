	code
	align	16
public code putch:
	      	subui	sp,sp,#16
	      	push 	bp
	      	mov  	bp,sp
	      	     	        push    r6
		lw		r1,24[bp]
		ldi     r6,#14    ; Teletype output function
        sys     #410      ; Video BIOS call
        pop     r6
	
stdio_1:
	      	mov  	sp,bp
	      	pop  	bp
	      	rtl  	#24
endpublic

public code putnum:
	      	push 	lr
	      	push 	xlr
	      	push 	bp
	      	ldi  	xlr,#stdio_3
	      	mov  	bp,sp
	      	subui	sp,sp,#64
	      	push 	r11
	      	lea  	r3,-58[bp]
	      	mov  	r11,r3
	      	lw   	r3,32[bp]
	      	blt  	r3,stdio_6
	      	lw   	r3,32[bp]
	      	cmp  	r3,r3,#200
	      	ble  	r3,stdio_4
stdio_6:
	      	sw   	r0,32[bp]
stdio_4:
	      	lw   	r3,24[bp]
	      	bge  	r3,stdio_7
	      	ldi  	r3,#45
	      	bra  	stdio_8
stdio_7:
	      	ldi  	r4,#43
	      	mov  	r3,r4
stdio_8:
	      	sc   	r3,-18[bp]
	      	lw   	r3,24[bp]
	      	bge  	r3,stdio_9
	      	lw   	r3,24[bp]
	      	neg  	r3,r3
	      	sw   	r3,24[bp]
stdio_9:
	      	sw   	r0,-8[bp]
stdio_11:
	      	lw   	r3,-8[bp]
	      	and  	r3,r3,#3
	      	cmp  	r3,r3,#3
	      	bne  	r3,stdio_13
	      	lcu  	r3,40[bp]
	      	sxc  	r3,r3
	      	beq  	r3,stdio_13
	      	lw   	r3,-8[bp]
	      	asli 	r3,r3,#1
	      	lcu  	r4,40[bp]
	      	sc   	r4,0[r11+r3]
	      	inc  	-8[bp],#1
stdio_13:
	      	lw   	r3,24[bp]
	      	mod  	r3,r3,#10
	      	sw   	r3,-16[bp]
	      	lw   	r3,-16[bp]
	      	cmp  	r3,r3,#9
	      	bgt  	r3,stdio_17
	      	lw   	r3,-16[bp]
	      	bge  	r3,stdio_15
stdio_17:
	      	push 	#stdio_2
	      	bsr  	printf
	      	addui	sp,sp,#8
stdio_15:
	      	lw   	r3,-16[bp]
	      	addu 	r3,r3,#48
	      	lw   	r4,-8[bp]
	      	asli 	r4,r4,#1
	      	sc   	r3,0[r11+r4]
	      	lw   	r3,24[bp]
	      	divs 	r3,r3,#10
	      	sw   	r3,24[bp]
	      	inc  	-8[bp],#1
	      	lw   	r3,24[bp]
	      	beq  	r3,stdio_18
	      	lw   	r3,-8[bp]
	      	cmp  	r3,r3,#18
	      	ble  	r3,stdio_11
stdio_18:
stdio_12:
	      	lcu  	r3,-18[bp]
	      	cmp  	r3,r3,#45
	      	bne  	r3,stdio_19
	      	lw   	r3,-8[bp]
	      	asli 	r3,r3,#1
	      	lcu  	r4,-18[bp]
	      	sc   	r4,0[r11+r3]
	      	inc  	-8[bp],#1
stdio_19:
stdio_21:
	      	lw   	r3,-8[bp]
	      	lw   	r4,32[bp]
	      	cmp  	r3,r3,r4
	      	bge  	r3,stdio_22
	      	lcu  	r3,48[bp]
	      	push 	r3
	      	bsr  	putch
stdio_23:
	      	dec  	32[bp],#1
	      	bra  	stdio_21
stdio_22:
stdio_24:
	      	lw   	r3,-8[bp]
	      	ble  	r3,stdio_25
	      	dec  	-8[bp],#1
	      	lw   	r3,-8[bp]
	      	asli 	r3,r3,#1
	      	lcu  	r3,0[r11+r3]
	      	push 	r3
	      	bsr  	putch
	      	bra  	stdio_24
stdio_25:
stdio_26:
	      	pop  	r11
	      	mov  	sp,bp
	      	pop  	bp
	      	pop  	xlr
	      	pop  	lr
	      	rtl  	#32
stdio_3:
	      	lw   	lr,8[bp]
	      	sw   	lr,16[bp]
	      	bra  	stdio_26
endpublic

public code puthexnum:
	      	push 	lr
	      	push 	xlr
	      	push 	bp
	      	ldi  	xlr,#stdio_27
	      	mov  	bp,sp
	      	subui	sp,sp,#64
	      	push 	r11
	      	lea  	r3,-58[bp]
	      	mov  	r11,r3
	      	lw   	r3,32[bp]
	      	blt  	r3,stdio_30
	      	lw   	r3,32[bp]
	      	cmp  	r3,r3,#200
	      	ble  	r3,stdio_28
stdio_30:
	      	sw   	r0,32[bp]
stdio_28:
	      	sw   	r0,-8[bp]
	      	lw   	r3,24[bp]
	      	bge  	r3,stdio_31
	      	ldi  	r3,#45
	      	bra  	stdio_32
stdio_31:
	      	ldi  	r4,#43
	      	mov  	r3,r4
stdio_32:
	      	sc   	r3,-18[bp]
	      	lw   	r3,24[bp]
	      	bge  	r3,stdio_33
	      	lw   	r3,24[bp]
	      	neg  	r3,r3
	      	sw   	r3,24[bp]
stdio_33:
stdio_35:
	      	lw   	r3,24[bp]
	      	and  	r3,r3,#15
	      	sw   	r3,-16[bp]
	      	lw   	r3,-16[bp]
	      	cmp  	r3,r3,#10
	      	bge  	r3,stdio_37
	      	lw   	r3,-16[bp]
	      	addu 	r3,r3,#48
	      	lw   	r4,-8[bp]
	      	asli 	r4,r4,#1
	      	sc   	r3,0[r11+r4]
	      	bra  	stdio_38
stdio_37:
	      	lw   	r3,40[bp]
	      	beq  	r3,stdio_39
	      	lw   	r3,-16[bp]
	      	subu 	r3,r3,#-55
	      	lw   	r4,-8[bp]
	      	asli 	r4,r4,#1
	      	sc   	r3,0[r11+r4]
	      	bra  	stdio_40
stdio_39:
	      	lw   	r3,-16[bp]
	      	subu 	r3,r3,#-87
	      	lw   	r4,-8[bp]
	      	asli 	r4,r4,#1
	      	sc   	r3,0[r11+r4]
stdio_40:
stdio_38:
	      	lw   	r3,24[bp]
	      	asri 	r3,r3,#4
	      	sw   	r3,24[bp]
	      	inc  	-8[bp],#1
	      	lw   	r3,24[bp]
	      	bne  	r3,stdio_35
stdio_36:
	      	lcu  	r3,-18[bp]
	      	cmp  	r3,r3,#45
	      	bne  	r3,stdio_41
	      	lw   	r3,-8[bp]
	      	asli 	r3,r3,#1
	      	lcu  	r4,-18[bp]
	      	sc   	r4,0[r11+r3]
	      	inc  	-8[bp],#1
stdio_41:
stdio_43:
	      	lw   	r3,-8[bp]
	      	lw   	r4,32[bp]
	      	cmp  	r3,r3,r4
	      	bge  	r3,stdio_44
	      	lcu  	r3,48[bp]
	      	push 	r3
	      	bsr  	putch
	      	dec  	32[bp],#1
	      	bra  	stdio_43
stdio_44:
stdio_45:
	      	lw   	r3,-8[bp]
	      	ble  	r3,stdio_46
	      	dec  	-8[bp],#1
	      	lw   	r3,-8[bp]
	      	asli 	r3,r3,#1
	      	lcu  	r3,0[r11+r3]
	      	push 	r3
	      	bsr  	putch
	      	bra  	stdio_45
stdio_46:
stdio_47:
	      	pop  	r11
	      	mov  	sp,bp
	      	pop  	bp
	      	pop  	xlr
	      	pop  	lr
	      	rtl  	#32
stdio_27:
	      	lw   	lr,8[bp]
	      	sw   	lr,16[bp]
	      	bra  	stdio_47
endpublic

public code putstr:
	      	push 	lr
	      	push 	xlr
	      	push 	bp
	      	ldi  	xlr,#stdio_48
	      	mov  	bp,sp
	      	subui	sp,sp,#8
	      	push 	r11
	      	lw   	r11,24[bp]
	      	sw   	r11,-8[bp]
stdio_49:
	      	lcu  	r3,[r11]
	      	beq  	r3,stdio_50
	      	lw   	r3,32[bp]
	      	ble  	r3,stdio_50
	      	lcu  	r3,[r11]
	      	push 	r3
	      	bsr  	putch
stdio_51:
	      	addui	r11,r11,#2
	      	dec  	32[bp],#1
	      	bra  	stdio_49
stdio_50:
	      	lw   	r3,-8[bp]
	      	asli 	r3,r3,#1
	      	subu 	r11,r11,r3
	      	lsri 	r11,r11,#1
	      	mov  	r1,r11
stdio_52:
	      	pop  	r11
	      	mov  	sp,bp
	      	pop  	bp
	      	pop  	xlr
	      	pop  	lr
	      	rtl  	#16
stdio_48:
	      	lw   	lr,8[bp]
	      	sw   	lr,16[bp]
	      	bra  	stdio_52
endpublic

public code putstr2:
	      	subui	sp,sp,#16
	      	push 	bp
	      	mov  	bp,sp
	      	     	        push    r6
        lw      r1,24[bp]
        ldi     r6,#$1B   ; Video BIOS DisplayString16 function
        sys     #410
        pop     r6
    
stdio_54:
	      	mov  	sp,bp
	      	pop  	bp
	      	rtl  	#24
endpublic

public code getcharNoWait:
	      	     	        push    r6
        ld      r6,#3    ; KeybdGetCharNoWait
        sys     #10
        pop     r6
        rtl
	
endpublic

public code getchar:
	      	push 	lr
	      	push 	xlr
	      	push 	bp
	      	ldi  	xlr,#stdio_57
	      	mov  	bp,sp
	      	subui	sp,sp,#8
stdio_58:
	      	bsr  	getcharNoWait
	      	mov  	r3,r1
	      	sw   	r3,-8[bp]
	      	lw   	r3,-8[bp]
	      	cmp  	r3,r3,#-1
	      	beq  	r3,stdio_58
stdio_59:
	      	lw   	r3,-8[bp]
	      	and  	r3,r3,#255
	      	mov  	r1,r3
stdio_60:
	      	mov  	sp,bp
	      	pop  	bp
	      	pop  	xlr
	      	pop  	lr
	      	rtl  	#0
stdio_57:
	      	lw   	lr,8[bp]
	      	sw   	lr,16[bp]
	      	bra  	stdio_60
endpublic

public code printf:
	      	push 	lr
	      	push 	xlr
	      	push 	bp
	      	ldi  	xlr,#stdio_62
	      	mov  	bp,sp
	      	subui	sp,sp,#40
	      	push 	r11
	      	push 	r12
	      	lea  	r3,24[bp]
	      	mov  	r11,r3
	      	mov  	r12,r11
stdio_63:
	      	lw   	r3,[r11]
	      	lcu  	r3,[r3]
	      	beq  	r3,stdio_64
	      	ldi  	r3,#32
	      	sc   	r3,-34[bp]
	      	lw   	r3,[r11]
	      	lcu  	r3,[r3]
	      	cmp  	r3,r3,#37
	      	bne  	r3,stdio_66
	      	sw   	r0,-16[bp]
	      	ldi  	r3,#65535
	      	sw   	r3,-24[bp]
	      	inc  	[r11],#2
stdio_61:
	      	lw   	r3,[r11]
	      	lcu  	r3,[r3]
	      	cmp  	r4,r3,#37
	      	beq  	r4,stdio_69
	      	cmp  	r4,r3,#99
	      	beq  	r4,stdio_70
	      	cmp  	r4,r3,#100
	      	beq  	r4,stdio_71
	      	cmp  	r4,r3,#120
	      	beq  	r4,stdio_72
	      	cmp  	r4,r3,#88
	      	beq  	r4,stdio_73
	      	cmp  	r4,r3,#115
	      	beq  	r4,stdio_74
	      	cmp  	r4,r3,#48
	      	beq  	r4,stdio_75
	      	cmp  	r4,r3,#57
	      	beq  	r4,stdio_76
	      	cmp  	r4,r3,#56
	      	beq  	r4,stdio_76
	      	cmp  	r4,r3,#55
	      	beq  	r4,stdio_76
	      	cmp  	r4,r3,#54
	      	beq  	r4,stdio_76
	      	cmp  	r4,r3,#53
	      	beq  	r4,stdio_76
	      	cmp  	r4,r3,#52
	      	beq  	r4,stdio_76
	      	cmp  	r4,r3,#51
	      	beq  	r4,stdio_76
	      	cmp  	r4,r3,#50
	      	beq  	r4,stdio_76
	      	cmp  	r4,r3,#49
	      	beq  	r4,stdio_76
	      	cmp  	r4,r3,#46
	      	beq  	r4,stdio_77
	      	bra  	stdio_68
stdio_69:
	      	push 	#37
	      	bsr  	putch
	      	bra  	stdio_68
stdio_70:
	      	addui	r12,r12,#8
	      	push 	[r12]
	      	bsr  	putch
	      	bra  	stdio_68
stdio_71:
	      	addui	r12,r12,#8
	      	lcu  	r3,-34[bp]
	      	push 	r3
	      	push 	#0
	      	push 	-16[bp]
	      	push 	[r12]
	      	bsr  	putnum
	      	bra  	stdio_68
stdio_72:
	      	addui	r12,r12,#8
	      	lcu  	r3,-34[bp]
	      	push 	r3
	      	push 	#0
	      	push 	-16[bp]
	      	push 	[r12]
	      	bsr  	puthexnum
	      	bra  	stdio_68
stdio_73:
	      	addui	r12,r12,#8
	      	lcu  	r3,-34[bp]
	      	push 	r3
	      	push 	#1
	      	push 	-16[bp]
	      	push 	[r12]
	      	bsr  	puthexnum
	      	bra  	stdio_68
stdio_74:
	      	addui	r12,r12,#8
	      	push 	-24[bp]
	      	push 	[r12]
	      	bsr  	putstr
	      	mov  	r3,r1
	      	sw   	r3,-32[bp]
	      	bra  	stdio_68
stdio_75:
	      	ldi  	r3,#48
	      	sc   	r3,-34[bp]
stdio_76:
	      	lw   	r3,[r11]
	      	lcu  	r3,[r3]
	      	subu 	r3,r3,#48
	      	sw   	r3,-16[bp]
	      	inc  	[r11],#2
stdio_78:
	      	lw   	r3,[r11]
	      	lcu  	r3,[r3]
	      	push 	r3
	      	bsr  	isdigit
	      	addui	sp,sp,#8
	      	mov  	r3,r1
	      	beq  	r3,stdio_79
	      	lw   	r3,-16[bp]
	      	muli 	r3,r3,#10
	      	sw   	r3,-16[bp]
	      	lw   	r3,[r11]
	      	lcu  	r3,[r3]
	      	subu 	r3,r3,#48
	      	lw   	r4,-16[bp]
	      	addu 	r4,r4,r3
	      	sw   	r4,-16[bp]
	      	inc  	[r11],#2
	      	bra  	stdio_78
stdio_79:
	      	lw   	r3,[r11]
	      	lcu  	r3,[r3]
	      	cmp  	r3,r3,#46
	      	beq  	r3,stdio_80
	      	bra  	stdio_61
stdio_80:
stdio_77:
	      	inc  	[r11],#2
	      	lw   	r3,[r11]
	      	lcu  	r3,[r3]
	      	push 	r3
	      	bsr  	isdigit
	      	addui	sp,sp,#8
	      	mov  	r3,r1
	      	bne  	r3,stdio_82
	      	bra  	stdio_61
stdio_82:
	      	lw   	r3,[r11]
	      	lcu  	r3,[r3]
	      	subu 	r3,r3,#48
	      	sw   	r3,-24[bp]
	      	inc  	[r11],#2
stdio_84:
	      	lw   	r3,[r11]
	      	lcu  	r3,[r3]
	      	push 	r3
	      	bsr  	isdigit
	      	addui	sp,sp,#8
	      	mov  	r3,r1
	      	beq  	r3,stdio_85
	      	lw   	r3,-24[bp]
	      	muli 	r3,r3,#10
	      	sw   	r3,-24[bp]
	      	lw   	r3,[r11]
	      	lcu  	r3,[r3]
	      	subu 	r3,r3,#48
	      	lw   	r4,-24[bp]
	      	addu 	r4,r4,r3
	      	sw   	r4,-24[bp]
	      	inc  	[r11],#2
	      	bra  	stdio_84
stdio_85:
	      	bra  	stdio_61
stdio_68:
	      	bra  	stdio_67
stdio_66:
	      	lw   	r3,[r11]
	      	lcu  	r3,[r3]
	      	push 	r3
	      	bsr  	putch
stdio_67:
stdio_65:
	      	inc  	[r11],#2
	      	bra  	stdio_63
stdio_64:
stdio_86:
	      	pop  	r12
	      	pop  	r11
	      	mov  	sp,bp
	      	pop  	bp
	      	pop  	xlr
	      	pop  	lr
	      	rtl  	#0
stdio_62:
	      	lw   	lr,8[bp]
	      	sw   	lr,16[bp]
	      	bra  	stdio_86
endpublic

	rodata
	align	16
	align	8
stdio_2:	; moderr 
	dc	109,111,100,101,114,114,32,0
;	global	putch
;	global	getcharNoWait
;	global	printf
;	global	putnum
;	global	putstr
;	global	getchar
;	global	putstr2
	extern	isdigit
;	global	puthexnum