;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Copyright (c) 2011 Hanna Reitz                                               ;
;                                                                              ;
; Permission is hereby granted, free of charge, to any person obtaining a copy ;
; of this software and  associated documentation files  (the  "Software"),  to ;
; deal in the  Software without restriction,  including without limitation the ;
; rights to use, copy, modify, merge,  publish, distribute, sublicense, and/or ;
; sell copies of the Software,  and to permit  persons to whom the Software is ;
; furnished to do so, subject to the following conditions:                     ;
;                                                                              ;
; The above copyright notice and this  permission notice  shall be included in ;
; all copies or substantial portions of the Software.                          ;
;                                                                              ;
; THE SOFTWARE IS PROVIDED "AS IS",  WITHOUT WARRANTY OF ANY KIND,  EXPRESS OR ;
; IMPLIED,  INCLUDING BUT NOT  LIMITED TO THE  WARRANTIES OF  MERCHANTABILITY, ;
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE ;
; AUTHORS  OR COPYRIGHT  HOLDERS BE  LIABLE FOR  ANY CLAIM,  DAMAGES OR  OTHER ;
; LIABILITY,  WHETHER IN AN  ACTION OF CONTRACT,  TORT OR  OTHERWISE,  ARISING ;
; FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS ;
; IN THE SOFTWARE.                                                             ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


use16

org 0x7C00

jmp 0x0000:_start

_start:

; RAINBOW OFFSET (bleibt die ganze Zeit in BX)
xor     bx,bx
mov     ds,bx

push    word 0xB800
pop     es

; Entspricht nicht genau den Farben, aber so grob haut es hin
mov     si,palette
mov     cx,13
palette_loop:
mov     dx,0x3C8
outsb
inc     dx
lodsb
out     dx,al
rol     al,3
out     dx,al
shl     al,3
out     dx,al
loop    palette_loop


; Hauptschleife
pinkie_pie:
mov     ax,bx
test    al,0x07
jnz     do_not_change_that_tone

shr     ah,2
and     ax,0x1F8
shr     ax,4
pushf
mov     si,sound
add     si,ax

mov     al,0xB6
out     0x43,al
lodsb
popf
jc      take_lower_of_sound
shr     al,4
take_lower_of_sound:
and     al,0xF
push    ax
in      al,0x61
jz      switch_off
or      al,0x03
jmp     left_on
switch_off:
and     al,0xFC
left_on:
out     0x61,al
pop     ax
mov     si,pitches
add     si,ax
add     si,ax
lodsw
out     0x42,al
mov     al,ah
out     0x42,al

do_not_change_that_tone:


xor     di,di
mov     ax,0x00DB
mov     cx,2000
rep     stosw


mov     ah,al

xor     ch,ch

mov     dl,bl
mov     si,479

mov     bp,53

draw_rainbow:
inc     si
inc     si
mov     di,si

mov     al,dl
shr     al,4
jnc     no_inc
add     di,160
no_inc:
mov     al,8
mov     cl,6
draw_bows:
mov     dh,3
draw_bow_line:
stosw
add     di,158
dec     dh
jnz     draw_bow_line
inc     ax
loop    draw_bows

inc     dx
dec     bp
jnz     draw_rainbow

inc     bx


test    bl,0x10
mov     di,427
jnz     cat_stays_up_here
add     di,160
cat_stays_up_here:


mov     si,pic
draw_pic_repeat:
lodsb
cmp     al,0xFF
je      draw_pic_quit
mov     cl,al
and     al,0xF
shr     cl,4
jnz     standard_procedure
mov     cl,al
add     cx,46
add     di,cx
add     di,cx
jmp     draw_pic_repeat
standard_procedure:
rep     stosw
jmp     draw_pic_repeat
draw_pic_quit:


mov     ah,0x86
mov     dx,0x4000
xor     cx,cx
int     0x15
jmp     pinkie_pie


sleep_some:
ret


; Bilddaten für die Katze.
; Die Daten sind Run-Length-Encoded. Das niederwertige Nibble gibt den Farbwert
; an, das höherwertige die Anzahl der zu setzenden Pixel (eigentlich Zeichen).
; Ist das höherwertige Nibble 0, dann wird als Anzahl der Wert des
; niederwertigen Nibbles plus 46 verwendet, für die sich ergebende Anzahl von
; Pixeln wird keine Farbe gesetzt. Die Startposition befindet sich in Zeile 2
; oder 3 (je nachdem), in Spalte 53 (beides nullbasiert).
; Terminiert werden die Bilddaten durch ein 0xFF-Byte.
pic:
db 0xF1, 0x31, 0x0F
db 0x11, 0xF2, 0x32, 0x11, 0x0D
db 0x11, 0x32, 0xE3, 0x32, 0x11, 0x0C
db 0x11, 0x22, 0x63, 0x14, 0x33, 0x14, 0x53, 0x22, 0x11, 0x0C
db 0x11, 0x12, 0x23, 0x14, 0xF3, 0x12, 0x11, 0x0C
db 0x11, 0x12, 0xC3, 0x21, 0x13, 0x14, 0x23, 0x12, 0x11, 0x20, 0x21, 0x08
db 0x11, 0x12, 0xB3, 0x11, 0x25, 0x11, 0x33, 0x12, 0x11, 0x10, 0x11, 0x25, 0x11, 0x07
db 0x11, 0x12, 0x63, 0x14, 0x43, 0x11, 0x35, 0x11, 0x23, 0x12, 0x21, 0x35, 0x11, 0x07
db 0x11, 0x12, 0xB3, 0x11, 0x45, 0x41, 0x45, 0x11, 0x07
db 0x11, 0x12, 0x33, 0x14, 0x73, 0x11, 0xC5, 0x11, 0x06
db 0x21, 0x12, 0x73, 0x14, 0x23, 0x11, 0xE5, 0x11, 0x02
db 0x51, 0x12, 0x13, 0x14, 0x83, 0x11, 0x35, 0x1F, 0x11, 0x55, 0x1F, 0x11, 0x25, 0x11, 0x00
db 0x21, 0x45, 0x11, 0x12, 0xA3, 0x11, 0x35, 0x21, 0x35, 0x11, 0x15, 0x21, 0x25, 0x11, 0x00
db 0x11, 0x35, 0x31, 0x12, 0x53, 0x14, 0x43, 0x11, 0x15, 0x26, 0x95, 0x26, 0x11, 0x01
db 0x41, 0x1C, 0x11, 0x22, 0x13, 0x14, 0x73, 0x11, 0x15, 0x26, 0x15, 0x11, 0x25, 0x11, 0x25, 0x11, 0x15, 0x26, 0x11, 0x06
db 0x11, 0x32, 0x93, 0x11, 0x35, 0x71, 0x25, 0x11, 0x07
db 0x21, 0xC2, 0x11, 0xA5, 0x11, 0x08
db 0x11, 0x15, 0xF1, 0x81, 0x09
db 0x11, 0x25, 0x11, 0x10, 0x11, 0x25, 0x11, 0x70, 0x11, 0x25, 0x11, 0x10, 0x11, 0x25, 0x11, 0x09
db 0x31, 0x30, 0x31, 0x80, 0x31, 0x20

; Der erste Eintrag ist eh ungenutzt, deshalb können wir da auch einfach
; Bilddaten mit drin haben
pitches:
db 0x31, 0xFF


; Tonhöhen für die Noten
; Werte sind 1193180 / Frequenz (ob der PIT nun 1193180 oder 1193182 Hz hat, wurscht)
dw 3835, 3620, 3224, 2873, 2415, 2152, 2032, 1918, 1810, 1612, 1437
;  dis'  e'    fis'  gis'  h'    cis'' d''   dis'' e''   fis'' gis''


; Werte für die VGA-Palette. Jeder Wert besteht aus zwei Byte: Das erste gibt
; den Palettenindex an, das zweite den Farbwert im Format BRG (blau-rot-grün)
; 2:3:3. Die VGA-Palettenindizes 0 bis 5 sowie 7 entsprechen den gleichen
; CGA-Indizes, 20 ist der CGA-Index 6, und 56 bis 63 entsprechen den Indizes
; 8 bis 15 (63 bzw. 15 ist weiß und wird auch als solches verwendet).
palette:
;  BG-Blau      schwarz      Kuchen       Zuckerguss   Stückchen    Fell         Wangen        Rot           Orange        Gelb          Grün          Blau          Violett
db 0,01000001b, 1,00000000b, 2,10111101b, 3,11111100b, 4,10111001b, 5,10100100b, 20,10111100b, 56,00111000b, 57,00111100b, 58,00111111b, 59,00000111b, 60,11000100b, 61,11010001b


; Zwei Noten sind in einem Byte, zuerst wird das höherwertige Nibble abgespielt,
; dann das niederwertige. Die Werte sind Indizes für das pitches-Array, 0
; bedeutet Stille.
; Zuerst werden die ersten 32 Noten (16 Byte) viermal hintereinander abgespielt,
; dann die letzten, dann wieder die ersten, usw. usf.
sound:
db 0xAA, 0xBB, 0x88, 0x05, 0x76, 0x50, 0x55, 0x66
db 0x77, 0x76, 0x56, 0x8A, 0xB8, 0xA6, 0x85, 0x65
db 0x55, 0x34, 0x55, 0x34, 0x56, 0x85, 0x98, 0x9A
db 0x55, 0x55, 0x34, 0x53, 0x98, 0x65, 0x31, 0x23


times 510-($-$$) db 0

dw 0xAA55
