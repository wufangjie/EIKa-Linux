assume cs:code
code segment

s1: 	db 'Good, better, best,', '$'
s2: 	db 'Never let it rest,', '$'
s3: 	db 'Till good is better,', '$'
s4: 	db 'And better, best.', '$'
s:  	dw offset s1, offset s2, offset s3, offset s4
row: 	db 2, 4, 6, 8

start:
	call clear_screen
	mov ax, cs
	mov ds, ax
	mov bx, offset s
	mov si, offset row
	mov cx, 4
ok:
	mov bh, 0
	mov dh, [si]
	mov dl, 0
	mov ah, 2
	int 10h

	mov dx, [bx]
	mov ah, 9
	int 21h
	add bx, 2
	inc si
	loop ok

	mov ax,4c00h
	int 21h

clear_screen:			; 清空屏幕
	push ax
	push cx
	push di
	push es
	mov ax, 0b800H
	mov es, ax
	mov cx, 4000
	mov ah, 00000111B	; 黑底白字
	mov di, 0
set_one_char:
	mov al, 0		; ascii 0
	mov es:[di], ax
	add di, 2
	loop set_one_char
	pop es
	pop di
	pop cx
	pop ax
	ret


code ends

end start
