assume cs:code
code segment

	mov ax, cache
	mov ds, ax		; 字符串的段地址
	mov si, 0		; 打印字符串首地址
	mov ax, data
	mov es, ax
	mov di, 0		; 数字首地址

	mov cx, 6		; 六个数字
	mov dh, 8		; 第八行
	mov dl, 3		; 第三列

	call clear_screen

print_d:
	mov ax, es:[di]
	call dtoc

	push cx
	mov cl, 00000111B	; 黑底白字
	call show_str
	pop cx
	inc dh			; 打印到下一行
	add di, 2
	loop print_d

	mov ax, 4c00H
	int 21H

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

divdw:			       ; dxax / cx -> dxax ... cx
	push bx			; ax, cx, dx 都是需要返回的就不用暂存了
	mov bx, ax		; 暂存低16位
	mov ax, dx
	mov dx, 0
	div cx			; 此时 dx 为余数正是我们希望的
	push ax			; 此时的商ax即是结果的高16位, 暂存
	mov ax, bx
	div cx
	mov cx, dx
	pop dx
	pop bx
	ret
divdb:			       ; ax / dl -> ax ... dh, 注意这里返回的是 dh, 这样我们就不用重复设置 dl 了,
	push bx			; ax, dx 都是需要返回的就不用暂存了
	mov bl, al		; 暂存低8位
	mov al, ah
	mov ah, 0
	div dl			; 此时 ah 为余数正是我们希望的
	mov bh, al		; 此时的商al即是结果的高8位, 暂存
	mov al, bl
	div dl
	mov dh, ah		; 余数
	mov ah, bh
	pop bx
	ret

dtoc:				; ax (待转换) ; ds, si (结果字符位置)
	push ax
	push bx
	push cx
	push dx
	push si
	mov bx, 0		; 记录有多少个字符
div_last:
	mov dl, 10
	call divdb
	add dh, 30h		; 加 0, 变成 ascii
	push dx			; 存储当前最后一位的字符, 其实有用的只有 dh
	inc bx
	mov cx, ax
	inc cx
	loop div_last

	mov cx, bx
pop_d:
	pop ax
	mov [si], ah
	inc si
	loop pop_d
	mov byte ptr [si], 0		; 最后补0

	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret


code ends

data segment
	dw 123, 12666, 1, 8, 3, 38
data ends

cache segment
	db 32 dup (0)
cache ends

end
