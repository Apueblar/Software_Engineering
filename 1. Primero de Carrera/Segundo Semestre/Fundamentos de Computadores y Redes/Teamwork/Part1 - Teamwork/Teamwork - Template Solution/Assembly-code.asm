.386
.model flat, C

.code

; Complete the procedure
areEqualAssembly PROC

	push ebp
	mov ebp, esp 

	push ebx
	push ecx
	push edx

	mov ebx, [ebp + 8] ; ebx = first parameter
	mov ecx, [ebp + 12] ; ecx = second parameter

	; The AND of both number only leaves set to 1
	; the bits that are 1 in both numbers
	xor ebx, ecx

	; In EBX we've got the bits that are 1 in both.
	; Check that it is the same as the second parameter
	
	cmp ebx, 0
	jz equal

	; If they aren't equal we jump. Return 0
	mov eax, 0
	jmp notEqual

equal:
	; If they are equal, the result is valid. Return 1
	mov eax, 1

notEqual:
	pop edx
	pop ecx
	pop ebx

	pop ebp
	ret

areEqualAssembly ENDP

END