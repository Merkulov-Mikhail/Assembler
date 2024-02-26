.model tiny
.286
.code
org 100h

Start:
    mov ax, 15h
    mov bx, 29h
    call .Main
    jmp .Check


.Check:
    push ax
    push bx
    mov ax, es
    mov bx, WORD ptr [CODE]
    xchg bh, bl
    cmp ax, bx
    jne NoAccess
    pop bx
    pop ax
    jmp Access

.Main:
        push ax
        push bx
        mov bx, offset CODE
staCyc: mov ax, 0c08h
        int 21h
        cmp al, 0dh
        je  endCyc
        mov dx, 0ffh
        mov [bx], al
        inc bx
        jmp staCyc
endCyc: pop bx
        pop ax
        ret

Access:

    cmp ax, 15h
    jne NoAccess ; i'm 15h and 29h must not be touched
    cmp bx, 29h
    jne NoAccess

    mov dx, offset CONGRATS
    mov ah, 09h
    int 21h
    call Terminate

NoAccess:
    mov dx, offset FAILURE
    mov ah, 09h
    int 21h
    call Terminate

Terminate:
    mov ax, 4c00h
    int 21h


CONGRATS: db 'succ ass', '$'
FAILURE:  db 'failure',  '$'
CODE: db 0

end Start
