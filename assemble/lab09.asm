assume cs:code

code segment
	mov ax, data
	mov ds, ax
	mov ax, 0b800H
	mov es, ax
	mov cx, 3
	mov bx, 1760		; 从第 11 行开始打印
	mov bp, 0
	call clear_screen
s:	push cx
	mov cx, 16
	mov si, 0
	mov di, 0
s2:	mov al, [si]
	mov ah, ds:[bp+16]	; 16 是字符串长度, 这里是取字符属性
	mov es:[bx+di+64], ax	; 从第 32 列开始
	add si, 1
	add di, 2
	loop s2

	pop cx
	add bx, 160
	inc bp
	loop s

	mov ax, 4c00H
	int 21H

clear_screen:			; 做这个 lab 之前应该还没有写 call, 去掉就行
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

data segment
	db 'welcome to masm!'
	db 00000010B, 00100100B, 01110001B ; 每一行的文字属性
data ends

end
