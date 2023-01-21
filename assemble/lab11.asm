assume cs:code
code segment

	mov ax, data
	mov ds, ax
	mov si, 0
	call letterc

	call clear_screen
	mov dh, 8		; 第八行
	mov dl, 3		; 第三列
	mov cl, 00000111B	; 黑底白字
	call show_str

	mov ax, 4c00H
	int 21H

letterc:			; ds:si
	push ax
	push si
process_char:
	mov al, [si]
	cmp al, 0
	je ok
	cmp al, 'a'
	jb next_char
	cmp al, 'z'
	ja next_char
	and al, 11011111B
	mov [si], al
next_char:
	inc si
	jmp short process_char
ok:	pop si
	pop ax
	ret

show_str:			; 设置 ds, si 和 dx, cl (列, 行, 属性)
	push si
	push di
	push cx
	push bx
	push ax
	push es
	mov ch, 0

	mov al, dl
	mov ah, 0
	add ax, ax		; 每行开始显示的地址: 列*2
	mov di, ax

	mov ax, 0b800H		; 显示段地址
	mov es, ax

	mov al, 160
	mul dh
	mov bx, ax		; 计算开始行偏移地址 bx

	mov ah, cl		; 设置属性
scan_char:
	mov cl, [si]
	jcxz show_str_ok
	mov al, cl
	mov es:[bx+di], ax	; 输出到指定位置, dh 就是属性
	inc si
	add di, 2
	jmp short scan_char
show_str_ok:
	pop es
	pop ax
	pop bx
	pop cx
	pop di
	pop si
	ret

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

data segment
	db "Hello, what's your name, 123!"
data ends

end
