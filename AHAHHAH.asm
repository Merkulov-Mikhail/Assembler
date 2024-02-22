.model tiny
.286
.code
org 100h


Start:
    call .SetInteruptVector

    call .EndProg


.SetInteruptVector:
    ;-------------------
    ;| save everything |
    ;-------------------
	push ax
	push bx
	push es

    push 0h
    pop es
    mov bx, 04h * 09h
    cli
        mov es:[bx], offset .Our09H
        push cs
        pop  ax
        mov es:[bx+2], ax
    sti

    mov ax, 3100h
	mov dx, offset .End09H
	shr dx, 4h
	inc dx
	int 21h

    pop es
    pop bx
	pop ax
    ret

.Our09H:
	; save data
		push ax
		push bx
		push es

	; put char in the middle of the screen
		in al, 60h

		push 0b800h
		pop es
		mov bx, (80*5 + 40) * 2
		mov ah, 40h
		mov es:[bx], ax

	call .HouseKeeping

	pop es
	pop bx
	pop ax
	iret


.HouseKeeping:
;--------- As the manual said, housekeeping
	in al, 61h
	or al, 80h
	out 61h, al
	and al, not 80h
	out 61h, al
	mov al, 20h
	out 20h, al
	ret
;----------


.RamOchka:
    push ax
    push bx
    push cx
    push dx
    push es


    mov bx, 0b800h
	mov es, bx
	;--------------------------------------------
	;	Creates shadow
	;--------------------------------------------
		mov bx, (80d * 12d + 30d);
		mov cx, 0A00h
		mov dx, 0050h
		call .DrawRect
	;--------------------------------------------

	mov bx, (80d * 10d + 22d);
	mov ch, 3ch
	mov dl, 10h

	;--------------------------------------------
	;   Creates top line
	;--------------------------------------------
		mov cl, 0c9h      	; left top corner  ╔
		mov es:[bx],   cl	;
		mov es:[bx+1], dl 	;

		add bx, 2		; top line         ═
		mov cl, 0cdh		;
		call .DrawMultipleChar ;

		mov cl, 0bbh		; right top corner ╗
		mov es:[bx],   cl	;
		mov es:[bx+1], dl	;
	;--------------------------------------------
	mov ax, 12d


	  .drawing:
	;--------------------------------------------
	;   Creates main body
	;--------------------------------------------

		mov cx, 3cbah		; i = 60, symb = ║
		push ax
		push bx
		;------------
		;   new line
		;------------
			mov bx, 80d
			mul bx
			pop bx
			mov bx, ax
			pop ax
		;-----------

		add bx, 22d
		mov dl, 10h
		mov es:[bx], 	cl	; add left wall
		mov es:[bx+1],  dl

        add bx, 2		       ;
		mov cl, 020h		   ;
		call .DrawMultipleChar ;

		mov cl, 0bah
		mov es:[bx],    cl
		mov es:[bx+1],  dl	; add right wall

	;--------------------------------------------
	  add ax, 2
	  cmp ax, 28d 	; iteration operators
	  jne .drawing

	;--------------------------------------------
	;   Creates bottom line
	;--------------------------------------------
		add bx, 26h
		mov cx, 0c8h
		mov es:[bx],   cl
		mov es:[bx+1], dl	    ; add left bottom corner   	╚

		add bx, 2
		mov cx, 3ccdh
		call .DrawMultipleChar     ; add bottom line        ═

		mov cl, 0bch
		mov es:[bx], 	cl
		mov es:[bx+1],	dl		; add right bottom corner   ╝
	;--------------------------------------------

    pop es
    pop dx
    pop cx
    pop bx
    pop ax

	ret

;--------------------------------------------
;  Attributes
;		BX     - offset
; 		CL     - symbol
;		DL     - color
;
;  Assumes
;		ES     - Video Mem offset
;
;  Changes
;	    BX += CH * 160 + 80h
;       CH = 0
;--------------------------------------------
.DrawRect:
	push bx
	push cx

	mov ch, 40h
	call .DrawMultipleChar

	pop cx
	pop bx
	add bx, 160d

	dec ch
	cmp ch, 0
	jne .DrawRect
	ret



; /--------------\
; | Ends Program |
; \--------------/
.EndProg:
	mov ax, 4c00h
	int 21h

;--------------------------------------------
;  Attributes
;		BX     - offset
;		CH     - count
; 		CL     - symbol
;		DL     - color
;
;  Assumes
;		ES     - Video Mem offset
;
;  Changes
;	    BX += CH * 2
;       CH = 0
;--------------------------------------------
.DrawMultipleChar:

	cmp cl, 0
	je .pass
		mov es:[bx],   cl
	.pass:

	mov es:[bx+1], dl

	add bx, 02h
	dec ch
	cmp ch, 0
	jne .DrawMultipleChar
	ret

.End09H:

end Start
