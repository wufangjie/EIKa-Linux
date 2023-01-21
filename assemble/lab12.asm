assume cs:code
code segment

	mov ax, cs
	mov ds, ax
	mov si, offset do0

	mov ax, 0
	mov es, ax
	mov di, 200h

	mov cx, offset do0_end - offset do0
	cld
	rep movsb

	mov ax, 0
	mov es, ax
	mov word ptr es:[0], 200h
	mov es:[2], ax

	mov ax, 1000h
	mov al, 1
	div al

	mov ax, 4c00H
	int 21H

do0:
	jmp short do0_start
	db "overflow!"
do0_start:
	push ax			; 这里直接用 push, 用的就是前一个程序的 stack
	push cx
	push ds
	push si
	push es
	push di

	mov ax, 0
	mov ds, ax
	mov si, 202h

	mov ax, 0b800H
	mov es, ax
	mov di, 12 * 160 + 36 * 2

	mov ah, 10000111B	; 闪一闪明显一点
	mov cx, 9
print_char:
	mov al, [si]		; 高位先不设置, 0b800H
	mov es:[di], ax
	inc si
	add di, 2
	loop print_char

	pop di
	pop es
	pop si
	pop ds
	pop cx
	pop ax

	mov ax, 4c00H
	int 21H			; NOTE: 其实不是很明白, 用了 iret 会结束不了, 但是默认的除法溢出也是这个效果, 这里就按书里有的代码来吧, 能正常结束
	;; iret
do0_end:
	nop

code ends

data segment
	db "Hello, what's your name, 123!"
data ends

end
