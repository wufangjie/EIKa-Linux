assume cs:code
code segment

	mov ax, data
	mov es, ax
	mov di, 0

	mov ax, cache
	mov ds, ax
	mov dx, 0

	mov cx, 6
	mov ah, 9

s:
	push cx
	mov al, es:[di]
	out 70h, al
	in al, 71h

	mov bl, al
	and al, 11110000B
	mov cl, 4
	shr al, cl
	add al, '0'
	mov ds:[0], al
	int 21h

	mov al, bl
	and al, 1111B
	add al, '0'
	mov ds:[0], al
	int 21h

	mov al, es:[di+6]
	cmp al, 0
	je ok
	mov ds:[0], al
	int 21h

	pop cx
	inc di
	jmp short s
ok:
	mov ax, 4c00h
	int 21h

code ends

data segment
	db 9, 8, 7, 4, 2, 0
	db "// ::", 0
data ends

cache segment
	db 0, '$'		; for output
cache ends

end
