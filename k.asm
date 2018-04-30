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

	mov	eax, 3

	mov	[var1], eax

	popad

	pushad

	mov	eax, 15

	mov	[var4], eax

	popad

	mov	eax, [var1]

	push	eax

	mov	eax, 3

	mov	edx, eax

	pop	eax

	cmp	eax, edx
	jne	l1
	jmp	l2

l1:
	jmp	l3

l2:
	pushad

	mov	eax, [var1]

	push	eax
	mov	eax, 2

	mov	ebx, eax
	pop	eax
	sub	eax, ebx

	mov	[var1], eax

	popad

	mov	eax, [var4]

	push	eax

	mov	eax, 15

	mov	edx, eax

	pop	eax

	cmp	eax, edx
	jne	l4
	jmp	l5

l4:
	jmp	l6

l5:
	mov	eax, [var1]

	push	eax

	mov	eax, [var4]

	pop	ebx

	sub	eax, ebx

	cmp	eax, 0
	jle	l8

	mov	ecx, eax

l7:
	push	ecx
	call	l9
	pop	ecx

	loop	l7

l8:
	jmp l10

l9:
	pushad

	mov	eax, 5

	mov	dword[ct1], 0
	mov	edi, decstr
	add	edi, 9
	xor	edx, edx

	push	0
	cmp	eax, 0
	jge	l11
	neg	eax
	pop	ebx
	push	'-'

l11:
	mov	ebx, 10
	div	ebx
	add	edx, '0'
	mov	byte[edi], dl
	dec	edi
	inc	dword[ct1]
	xor	edx, edx
	cmp	eax, 0
	jne	l11

	pop	edx
	cmp	edx, 0
	je	l12
	mov	byte[edi], dl
	dec	edi
	inc	dword[ct1]
	xor	edx, edx

l12:
	inc	edi
	mov	ecx, edi
	mov	edx, [ct1]
	mov	eax, 4
	mov	ebx, 1
	int	0x80

	popad

	pushad

	mov	eax, [var1]

	push	eax
	mov	eax, 1

	mov	ebx, eax
	pop	eax
	add	eax, ebx

	mov	[var1], eax

	popad

	ret

l10:
	pushad

	mov	ecx, str1
	mov	edx, 1
	mov	eax, 4
	mov	ebx, 1
	int	0x80

	popad

	pushad

	mov	ecx, nl
	mov	edx, 1
	mov	eax, 4
	mov	ebx, 1
	int	0x80

	popad

	pushad

	mov	eax, 0

	mov	[var2], eax

	popad

	mov	eax, [var1]

	push	eax

	mov	eax, [var4]

	pop	ebx

	sub	eax, ebx

	cmp	eax, 0
	jle	l14

	mov	ecx, eax

l13:
	push	ecx
	call	l15
	pop	ecx

	loop	l13

l14:
	jmp l16

l15:
	mov	eax, [var2]

	push	eax

	mov	eax, [var1]

	mov	edx, eax

	pop	eax

	cmp	eax, edx
	jne	l17
	jmp	l18

l17:
	jmp	l19

l18:
	pushad

	mov	ecx, str2
	mov	edx, 10
	mov	eax, 4
	mov	ebx, 1
	int	0x80

	popad

	pushad

	mov	ecx, nl
	mov	edx, 1
	mov	eax, 4
	mov	ebx, 1
	int	0x80

	popad

l19:
	pushad

	mov	eax, [var2]

	push	eax
	mov	eax, 1

	mov	ebx, eax
	pop	eax
	add	eax, ebx

	mov	[var2], eax

	popad

	ret

l16:
l6:
l3:
	mov	eax, 1
	int	0x80

section .data
	str1 db " "
	str2 db "Reach var1"
	nl db 10
