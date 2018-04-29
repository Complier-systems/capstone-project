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

	mov	eax, 0

	mov	[var1], eax

	popad

	pushad

	mov	eax, 0

	mov	[var2], eax

	popad

	mov	eax, [var1]

	push	eax

	mov	eax, 5

	push	eax
	mov	eax, 5

	mov	ebx, eax
	pop	eax
	add	eax, ebx

	pop	ebx

	sub	eax, ebx

	cmp	eax, 0
	jl	l2

	mov	ecx, eax

l1:
	push	ecx
	call	l3
	pop	ecx

	loop	l1

l2:
	jmp l4

l3:
	mov	eax, [var1]

	push	eax
	mov	eax, 02h

	mov	ebx, eax
	pop	eax
	idiv	ebx
	mov	eax, edx

	push	eax

	mov	eax, 0

	mov	edx, eax

	pop	eax

	cmp	eax, edx
	jne	l5
	jmp	l6

l5:
	jmp	l7

l6:
	pushad

	mov	ecx, str1
	mov	edx, 25
	mov	eax, 4
	mov	ebx, 1
	int	0x80

	popad

	pushad

	mov	eax, [var1]

	mov	dword[ct1], 0
	mov	edi, decstr
	add	edi, 9
	xor	edx, edx

	push	0
	cmp	eax, 0
	jge	l8
	neg	eax
	pop	ebx
	push	'-'

l8:
	mov	ebx, 10
	div	ebx
	add	edx, '0'
	mov	byte[edi], dl
	dec	edi
	inc	dword[ct1]
	xor	edx, edx
	cmp	eax, 0
	jne	l8

	pop	edx
	cmp	edx, 0
	je	l9
	mov	byte[edi], dl
	dec	edi
	inc	dword[ct1]
	xor	edx, edx

l9:
	inc	edi
	mov	ecx, edi
	mov	edx, [ct1]
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

	mov	ecx, str2
	mov	edx, 25
	mov	eax, 4
	mov	ebx, 1
	int	0x80

	popad

	pushad

	mov	eax, [var1]

	mov	dword[ct1], 0
	mov	edi, decstr
	add	edi, 9
	xor	edx, edx

l10:
	mov	ebx, 16
	div	ebx
	add	edx, '0'

	cmp	edx, '9'
	jle	l11
	add	edx, 7

l11:
	mov	byte[edi], dl
	dec	edi
	inc	dword[ct1]
	xor	edx, edx
	cmp	eax, 0
	jne	l10

	mov	byte[edi], 'x'
	dec	edi
	inc	dword[ct1]
	xor	edx, edx

	mov	byte[edi], '0'
	dec	edi
	inc	dword[ct1]
	xor	edx, edx

	inc	edi
	mov	ecx, edi
	mov	edx, [ct1]
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

	mov	eax, [var2]

	push	eax
	mov	eax, [var1]

	mov	ebx, eax
	pop	eax
	add	eax, ebx

	mov	[var2], eax

	popad

l7:
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

l4:
	pushad

	mov	ecx, str3
	mov	edx, 31
	mov	eax, 4
	mov	ebx, 1
	int	0x80

	popad

	pushad

	mov	eax, [var2]

	mov	dword[ct1], 0
	mov	edi, decstr
	add	edi, 9
	xor	edx, edx

	push	0
	cmp	eax, 0
	jge	l12
	neg	eax
	pop	ebx
	push	'-'

l12:
	mov	ebx, 10
	div	ebx
	add	edx, '0'
	mov	byte[edi], dl
	dec	edi
	inc	dword[ct1]
	xor	edx, edx
	cmp	eax, 0
	jne	l12

	pop	edx
	cmp	edx, 0
	je	l13
	mov	byte[edi], dl
	dec	edi
	inc	dword[ct1]
	xor	edx, edx

l13:
	inc	edi
	mov	ecx, edi
	mov	edx, [ct1]
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

	mov	eax, 5

	push	eax

	mov	eax, 10

	mov	edx, eax

	pop	eax

	cmp	eax, edx
	jne	l14
	jmp	l15

l14:
	jmp	l16

l15:
	mov	eax, [var2]

	push	eax

	mov	eax, 20

	pop	ebx

	sub	eax, ebx

	cmp	eax, 0
	jl	l18

	mov	ecx, eax

l17:
	push	ecx
	call	l19
	pop	ecx

	loop	l17

l18:
	jmp l20

l19:
	pushad

	mov	eax, 5

	mov	dword[ct1], 0
	mov	edi, decstr
	add	edi, 9
	xor	edx, edx

	push	0
	cmp	eax, 0
	jge	l21
	neg	eax
	pop	ebx
	push	'-'

l21:
	mov	ebx, 10
	div	ebx
	add	edx, '0'
	mov	byte[edi], dl
	dec	edi
	inc	dword[ct1]
	xor	edx, edx
	cmp	eax, 0
	jne	l21

	pop	edx
	cmp	edx, 0
	je	l22
	mov	byte[edi], dl
	dec	edi
	inc	dword[ct1]
	xor	edx, edx

l22:
	inc	edi
	mov	ecx, edi
	mov	edx, [ct1]
	mov	eax, 4
	mov	ebx, 1
	int	0x80

	popad

	ret

l20:
l16:
	pushad

	mov	ecx, str4
	mov	edx, 4
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

	mov	eax, 1
	int	0x80

section .data
	str1 db "The value of var1 (dec): "
	str2 db "The value of var1 (hex): "
	str3 db "Sum of even number from 0-9 is "
	str4 db "TEST"
	nl db 10
