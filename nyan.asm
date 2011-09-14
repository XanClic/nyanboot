use16

org 0x7C00

jmp 0x0000:_start

rainbow_offset db 0

_start:

xor     ax,ax
mov     ds,ax
; Moving the stack to 0x0000:0x0000 is effectively the same as moving it to
; 0x10000.
mov     ss,ax
; Interrupts are automatically disabled during the nect instruction.
mov     sp,ax


mov     es,ax
mov     ax,0x0201
mov     bx,0x7E00
mov     cx,0x0002
xor     dh,dh

int     0x13


cld

push    0xB800
pop     es

mov     dx,0x3C8
xor     al,al
out     dx,al
inc     dx

mov     cx,3*8
mov     si,palette
rep     outsb

dec     dx
mov     al,20
out     dx,al
inc     dx

sub     si,6
outsb
outsb
outsb

add     si,3

mov     al,56
mov     cx,3*8
high_color_loop:
dec     dx
out     dx,al
inc     dx
inc     al
outsb
outsb
outsb
loop    high_color_loop



pinkie_pie:
xor     di,di
mov     ax,0x00DB
mov     cx,2000
rep     stosw

xor     ch,ch

mov     dl,[rainbow_offset]
mov     si,478

mov     bp,53

draw_rainbow:
add     si,2
mov     di,si

mov     al,dl
shr     al,4
jnc     no_inc
add     di,160
no_inc:
mov     ax,0x08DB
mov     cx,6
draw_bows:
stosw
add     di,158
stosw
add     di,158
stosw
add     di,158
inc     ah
loop    draw_bows

inc     dl
dec     bp
jnz     draw_rainbow

mov     dl,[rainbow_offset]
inc     dl
cmp     dl,16
jb      go_on
xor     dl,dl
go_on:
mov     [rainbow_offset],dl

mov     ax,pic
call    draw_pic

call    sleep_some
jmp     pinkie_pie


draw_pic:
xor     di,di
mov     si,ax
draw_pic_repeat:
lodsb
mov     dl,al
inc     dl
jz      draw_tart_stop
inc     dl
jz      draw_tart_start
sub     dl,246
ja      draw_single_pixel
jz      draw_pixel_transp
or      al,al
jz      draw_pic_quit
movzx   cx,al
lodsb
test    al,al
jz      draw_pic_transp
mov     ah,al
mov     al,0xDB
rep     stosw
jmp     draw_pic_repeat
draw_pic_quit:
ret

draw_pixel_transp:
mov     cx,1

draw_pic_transp:
shl     cx,1
add     di,cx
jmp     draw_pic_repeat

draw_tart_start:
mov     ax,0x01DB
stosw
inc     ah
stosw
jmp     draw_pic_repeat

draw_tart_stop:
mov     ax,0x02DB
stosw
mov     dl,1

draw_single_pixel:
mov     ah,dl
mov     al,0xDB
stosw
jmp     draw_pic_repeat


sleep_some:
mov     ah,0x86
mov     dx,0x4000
xor     cx,cx
int     0x15
ret


palette:
;  bg blue   black   cream?     frosting   pieces of stuff  cat fur    cat cheeks  white     red      orange    yellow    green    blue      violet
db 0,13,25,  0,0,0,  63,50,38,  63,38,63,  63,13,38,        38,38,38,  63,38,38,   63,63,63, 63,0,0,  63,38,0,  63,63,0,  0,63,0,  0,38,63,  25,13,63


times 510-($-$$) db 0

dw 0xAA55


pic:
db 213,0, 18,1, 61,0
db 245, 18,2, 245, 59,0
db 245, 3,2, 14,3, 3,2, 245, 58,0
db 245, 2,2, 6,3, 248, 3,3, 248, 5,3, 2,2, 245, 58,0
db 254, 2,3, 248, 15,3, 255, 58,0
db 254, 12,3, 2,1, 247, 248, 2,3, 255, 2,0, 2,1, 54,0
db 254, 11,3, 245, 2,5, 245, 3,3, 255, 244, 245, 2,5, 245, 53,0
db 254, 6,3, 248, 4,3, 245, 3,5, 245, 2,3, 255, 245, 3, 5, 245, 53,0
db 254, 11,3, 245, 4,5, 4,1, 4,5, 245, 53,0
db 254, 3,3, 248, 7,3, 245, 12,5, 245, 52,0
db 245, 254, 7,3, 248, 2,3, 245, 14,5, 245, 48,0
db 4,1, 254, 247, 248, 8,3, 245, 3,5, 251, 245, 5,5, 251, 245, 2,5, 245, 46,0
db 2,1, 4,5, 254, 10,3, 245, 3,5, 2,1, 3,5, 245, 249, 2,1, 2,5, 245, 46,0
db 245, 3,5, 2,1, 254, 5,3, 248, 4,3, 245, 249, 2,6, 9,5, 2,6, 245, 47,0
db 4,1, 244, 245, 2,2, 247, 248, 7,3, 245, 249, 2,6, 249, 245, 2,5, 245, 2,5, 245, 249, 2,6, 245, 52,0
db 245, 3,2, 9,3, 245, 3,5, 7,1, 2,5, 245, 53,0
db 2,1, 12,2, 245, 10,5, 245, 54,0
db 245, 249, 23,1, 55,0
db 245, 2,5, 245, 244, 245, 2,5, 245, 7,0, 245, 2,5, 245, 244, 245, 2,5, 245, 55,0
db 3,1, 3,0, 3,1, 8,0, 3,1, 2,0, 3,1

times 1024-($-$$) db 0
