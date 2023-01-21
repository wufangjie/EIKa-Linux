assume cs:code
code segment

	mov ax, cache
	mov ds, ax
	mov si, 0
	mov ax, data
	mov es, ax
	mov di, 0

	mov dh, 2		; 行

	call clear_screen
	mov cx, 21
print_one_line:
	push cx
	mov dl, 4		; 列

	mov ax, es:[di]		; 年份
	mov ds:[0], ax
	mov ax, es:[di+2]
	mov ds:[2], ax
	mov ds:[4], 0

	mov cl, 00000111B	; 黑底白字
	call show_str

	mov ax, es:[di+84]
	push dx
	mov dx, es:[di+86]
	call ddtoc
	pop dx
	mov dl, 16
	call show_str

	shr di, 1
	mov ax, es:[di+168]
	push ax			; 临时记录, 下一部分会用到
	call dwtoc
	mov dl, 32
	call show_str
	shl di, 1
	pop cx			; pop ax to cx

	mov ax, es:[di+84]
	push dx
	mov dx, es:[di+86]
	call divdw
	call ddtoc
	mov cl, 00000111B	; 黑底白字
	pop dx
	mov dl, 44
	call show_str

	pop cx
	inc dh
	add di, 4
	loop print_one_line

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
	add ax, ax
	mov di, ax		; 显示开始列*2

	mov ax, 0b800H		; 显示段地址
	mov es, ax

	mov al, 160
	mul dh
	mov bx, ax		; 计算开始行 bx

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


dwtoc:				; ax (待转换) ; ds, si (结果字符位置)
	push ax
	push bx
	push cx
	push dx
	push si
	mov bx, 0		; 记录有多少个字符
div_last_w:
	mov dl, 10		; 这句可以移到循环外
	call divdb
	add dh, 30h		; 加 0, 变成 ascii
	push dx			; 存储当前最后一位的字符, 其实有用的只有 dh
	inc bx
	mov cx, ax
	inc cx
	loop div_last_w

	mov cx, bx
pop_d_w:
	pop ax
	mov [si], ah
	inc si
	loop pop_d_w
	mov byte ptr [si], 0		; 最后补0

	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret


ddtoc:				; dxax (待转换) ; ds, si (结果字符位置)
	push ax
	push bx
	push cx
	push dx
	push si
	mov bx, 0		; 记录有多少个字符
div_last_d:
	mov cx, 10
	call divdw
	add cl, 30h		; 加 0, 变成 ascii
	push cx			; 存储当前最后一位的字符, 其实有用的只有 ch
	inc bx
	mov cx, ax
	or cx, dx		; ax, dx 都为 0 才会结束
	inc cx
	loop div_last_d

	mov cx, bx
pop_d_d:
	pop ax
	mov [si], al		; 注意和 dwtoc 的区别, 这里是低位
	inc si
	loop pop_d_d
	mov byte ptr [si], 0		; 最后补0

	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret



code ends

data segment
	db '1975', '1976', '1977', '1978', '1979', '1980', '1981', '1982', '1983'
	db '1984', '1985', '1986', '1987', '1988', '1989', '1990', '1991', '1992'
	db '1993', '1994', '1995'
	; 以上是表示21 年的21 个字符串
	dd 16,22,382,1356,2390, 8000, 16000, 24486, 50065, 97479, 140417, 197514
	dd 345980, 590827, 803530, 1183000, 1843000, 2759000, 3753000, 4649000, 5937000
	; 以上是表示21 年公司点收入的21 个dword 型数据
	dw 3,7,9, 13,28,38, 130, 220, 476, 778, 1001,1442, 2258, 2793, 4037,5635, 8226
	dw 11542,14430, 15257, 17800
	; 以上是表示21年公司雇员人数的21个word 型数据
data ends

cache segment
	db 32 dup (0)
cache ends

end
