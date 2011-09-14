use16

org 0x7C00

jmp 0x0000:_start

rainbow_offset db 0

_start:

push    cs
pop     es
mov     ax,0x0201
mov     bx,0x7E00
mov     cx,0x0002
xor     dh,dh

int     0x13


push    cs
pop     ds

push    word 0xB800
pop     es

mov     si,palette
mov     cx,14
palette_loop:
mov     dx,0x3C8
outsb
inc     dx
outsb
outsb
outsb
loop    palette_loop


pinkie_pie:
xor     di,di
mov     ax,0x00DB
mov     cx,2000
rep     stosw


mov     ah,0xDB

xor     ch,ch

mov     dl,[rainbow_offset]
mov     si,479

mov     bp,53

draw_rainbow:
add     si,2
mov     di,si

mov     al,dl
shr     al,4
jnc     no_inc
add     di,160
no_inc:
mov     al,8
mov     cl,6
draw_bows:
mov     bl,3
draw_bow_line:
stosw
add     di,158
dec     bl
jnz     draw_bow_line
inc     al
loop    draw_bows

inc     dl
dec     bp
jnz     draw_rainbow

inc     byte [rainbow_offset]

call    draw_pic

call    sleep_some
jmp     pinkie_pie


draw_pic:
mov     di,427
mov     si,pic
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
test    al,al
jz      draw_pic_quit
mov     cl,al
lodsb
test    al,al
jz      draw_pic_transp
rep     stosw
jmp     draw_pic_repeat
draw_pic_quit:
ret

draw_pixel_transp:
mov     cl,1

draw_pic_transp:
add     di,cx
add     di,cx
jmp     draw_pic_repeat

draw_tart_start:
mov     al,1
stosw
inc     al
stosw
jmp     draw_pic_repeat

draw_tart_stop:
mov     al,2
stosw
mov     dl,1

draw_single_pixel:
mov     al,dl
stosw
jmp     draw_pic_repeat


sleep_some:
mov     ah,0x86
mov     dx,0x4000
xor     cx,cx
int     0x15
ret


palette:
;  bg blue     black     cream?       frosting     pieces of stuff  cat fur      cat cheeks    white        red         orange       yellow       green       blue         violet
db 0,0,13,25,  1,0,0,0,  2,63,50,38,  3,63,38,63,  4,63,13,38,      5,38,38,38,  20,63,38,38,  7,63,63,63,  56,63,0,0,  57,63,38,0,  58,63,63,0,  59,0,63,0,  60,0,38,63,  61,25,13,63


times 510-($-$$) db 0

dw 0xAA55

pic:
db 18,1, 61,0
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
