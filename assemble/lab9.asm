assume cs:codesg
data segment
	db 'welcome to masm!'
	db 00000010B, 00010100B, 01100001B
data ends
stack segment
	dw 0
stack ends
codesg segment
	mov ax, data
	mov ds, ax
	mov ax, B800H
	mov es, ax
	mov cx, 3
	mov bx, 1760		; 从第 11 行开始打印
s:	push cx
	mov cx, 16
	mov si, 0
	mov di, 0
s2:	mov al, [si]
	mov ah, [si+16+bx]	; 16 是字符串长度, 这里是取字符属性
	mov es:[bx+di+64], ax	; 从第 32 列开始
	add si, 2
	add di, 4
	loop s2

	pop cx
	add bx, 160
	loop s

	mov ax, 4c00H
	int 21H

codesg ends
end
