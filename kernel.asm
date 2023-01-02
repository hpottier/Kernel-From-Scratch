BITS 32

VGA_WIDTH equ 80
VGA_HEIGHT equ 25

VGA_COLOR_BLACK equ 0
VGA_COLOR_BLUE equ 1
VGA_COLOR_GREEN equ 2
VGA_COLOR_CYAN equ 3
VGA_COLOR_RED equ 4
VGA_COLOR_MAGENTA equ 5
VGA_COLOR_BROWN equ 6
VGA_COLOR_LIGHT_GREY equ 7
VGA_COLOR_DARK_GREY equ 8
VGA_COLOR_LIGHT_BLUE equ 9
VGA_COLOR_LIGHT_GREEN equ 10
VGA_COLOR_LIGHT_CYAN equ 11
VGA_COLOR_LIGHT_RED equ 12
VGA_COLOR_LIGHT_MAGENTA equ 13
VGA_COLOR_LIGHT_BROWN equ 14
VGA_COLOR_WHITE equ 15


global kfs_main
kfs_main:
    mov dh, VGA_COLOR_GREEN
    mov dl, VGA_COLOR_BLACK
    call terminal_set_color

    mov esi, string42
    call terminal_write_string

    jmp $


; IN = dl: bg color, dh: fg color
; OUT = none
terminal_set_color:
    shl dl, 4
    or dl, dh
    mov [terminal_color], dl

    ret


; IN = dl: y, dh: x
; OUT = dx: Index with offset 0xB8000 at VGA buffer
; Other registers preserved
terminal_getidx:
    push ax
	xor ebx, ebx
	mov bl, dh
	mov dh, 0

	mov eax, VGA_WIDTH
	mul edx
	mov edx, eax

	add edx, ebx
	shl edx, 1 ; multiply by two because every entry is a word that takes up 2 bytes

    pop ax
    ret


; IN = dl: y, dh: x, al: ASCII char
; OUT = none
terminal_putentryat:
    pusha
    call terminal_getidx

    mov ah, [terminal_color]
    mov word [0xB8000 + edx], ax

    popa
    ret


; IN = al: ASCII char
terminal_putchar:
    mov dx, [terminal_cursor_pos] ; This loads terminal_column at DH, and terminal_row at DL

    cmp al, 0xA
    je .new_line

    call terminal_putentryat

    inc dh
    cmp dh, VGA_WIDTH
    jne .cursor_moved

.new_line:
	xor dh, dh
    inc dl

    cmp dl, VGA_HEIGHT
    jne .cursor_moved

	xor dl, dl

.cursor_moved:
    mov [terminal_cursor_pos], dx ; Store new cursor position

    ret


; IN = cx: length of string, ESI: string location
; OUT = none
terminal_write:
    pusha

.loopy:
    mov al, [esi]
    cmp al, 0
    je .done

    call terminal_putchar

    inc esi
    jmp .loopy

.done:
    popa
    ret


; IN = ESI: string location
; OUT = none
terminal_write_string:
    pusha
    call terminal_write
    popa
    ret


string42 db "                                   :::      ::::::::", 0xA \
          , "                                 :+:      :+:    :+:", 0xA \
          , "                               +:+ +:+         +:+", 0xA \
          , "                             +#+  +:+       +#+", 0xA \
          , "                           +#+#+#+#+#+   +#+", 0xA \
          , "                                #+#    #+#", 0xA \
          , "                               ###   ########.fr", 0x0

terminal_color db 0

terminal_cursor_pos:
terminal_row db 0
terminal_column db 0
