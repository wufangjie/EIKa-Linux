assume cs:code
code segment

	mov ax, 20
	call fib

	mov cx, 8
	call frac

	mov cx, 8
	call frac2

	mov ax, 4c00h
	int 21h


fib:	push dx			; 输入 ax, 返回 ax
	cmp ax, 2
	jb fib_ok
	dec ax
	push ax
	call fib
	mov dx, ax

	pop ax
	dec ax
	call fib
	add ax, dx
	jmp short fib_ok
fib_ok:	pop dx
	ret


frac:
	push cx
	mov dx, 0
	mov ax, 1
	call _frac
	pop cx
	ret
_frac:				; NOTE: dxax, 先赋值为 1
	cmp cx, 2
	jb frac_end
	mul cx
	dec cx
	call _frac
frac_end:
	ret

frac2:				; 这个实现我移出了递归函数的 ret, 也能正常工作
	push cx
	mov dx, 0		; NOTE: dxax, 先赋值为 1
	mov ax, 1		; 简单起见这里不考虑非正数
	call _frac
frac2_finished:
	pop cx
	ret

_frac2:
	cmp cx, 2
	jmp short frac2_finished
	mul cx
	dec cx
	call _frac


code ends

data segment
	db 1, 2, 3, 4, 5, 6, 7, 8
	;; db 32 dup ('$')
data ends

end
