segment .bss
	var1 resb 8
	var2 resb 8
	var3 resb 8
	var4 resb 8
	var5 resb 8
	var6 resb 8
	var7 resb 8
	var8 resb 8
	var9 resb 8
	var10 resb 8
	var11 resb 8
	var12 resb 8
	var13 resb 8
	var14 resb 8
	var15 resb 8
	var16 resb 8
	var17 resb 8
	var18 resb 8
	var19 resb 8
	var20 resb 8
	var21 resb 8
	var22 resb 8
	var23 resb 8
	var24 resb 8
	var25 resb 8
	var26 resb 8
	decstr resb 10
	ct1 resd 1

section .text

global _start

_start:
	pushad

	mov	ecx, str1
	mov	edx, 5
	mov	eax, 4
	mov	ebx, 1
	int	0x80

	popad

	mov	eax, 5

	push	eax

	mov	eax, 5

	mov	edx, eax

	pop	eax

	cmp	eax, edx
	jne	l1
	jmp	l2

l1:
	jmp	l3

l2:
	pushad

	mov	ecx, str2
	mov	edx, 3
	mov	eax, 4
	mov	ebx, 1
	int	0x80

	popad

	jmp	l4

l3:
	mov	eax, 7

	push	eax

	mov	eax, 7

	mov	edx, eax

	pop	eax

	cmp	eax, edx
	jne	l5
	jmp	l6

l5:
	jmp	l7

l6:
	pushad

	mov	ecx, str3
	mov	edx, 4
	mov	eax, 4
	mov	ebx, 1
	int	0x80

	popad

l4:

l7:
	pushad

	mov	ecx, str4
	mov	edx, 6
	mov	eax, 4
	mov	ebx, 1
	int	0x80

	popad

	pushad

	mov	ecx, str5
	mov	edx, 2
	mov	eax, 4
	mov	ebx, 1
	int	0x80

	popad

	mov	eax, 1
	int	0x80

section .data
	str1 db "Print"
	str2 db "reg"
	str3 db "else"
	str4 db "Finish"
	str5 db "if"
	nl db 10
