[org 0x100]
jmp start
string1:db'MISSED:'
length1:dw 6
string2:db'SCORE'
length2:dw 5
string3: db'START!'
length3:dw 6
string4:db 'loading game in...'
length4:dw 18
string5: db  'You Scored:'
length5: dw  11
string6:db 'Better Luck Next Time!'
length6:dw 22
string7: db 'Good Job!'
length7: dw 9

boxloc:dw 3760
randc:dw 0
randcp:dw 0
rand: dw 0
randnum: dw 0
oldisr: dd   0                  ; space for saving old isr 
oldtimer: dd 0
char1:dw 0
char1loc:dw 0
charflag1:dw 0
chartime1:dw 0
life:dw 0
score:dw 0
char3:dw 0
char3loc:dw 0
charflag3:dw 0
chartime3:dw 0
char2:dw 0
char2loc:dw 0
charflag2:dw 0
chartime2:dw 0
char4:dw 0
char4loc:dw 0
charflag4:dw 0
chartime4:dw 0
char5:dw 0
char5loc:dw 0
charflag5:dw 0
chartime5:dw 0
kbisr: 
              push ax 
              in   al, 0x60           ; read a char from keyboard port 
              cmp  al, 0x4B           ; is the key left 
              jne  nextcmp            ; no, try next comparison 
              call left
              jmp exit
                         ; leave interrupt routine 
nextcmp:      cmp  al, 0x4D           ; is the key right shift 
              jne  exit           ; no, leave interrupt routine 
              call right
            
exit: 
mov al, 0x20
out 0x20, al ; send EOI to PIC
pop ax
jmp far [cs:oldisr] 
iret ; 
left:
    push es
    push di
    push ax     
    push 0xb800
    pop es
    mov di,word[boxloc]
checkend1:
    cmp di,3680
    je line_end1
    mov word[es:di],0x0720
    mov ax, 0x07DC
    sub di, 2              ; Move left
    mov [es:di], ax
    mov [boxloc],di
    jmp exit1
exit1:
pop ax
pop di
pop es
ret
right:
    push es
    push di
    push ax     
    push 0xb800
    pop es
    mov di,word[boxloc]
checkend2:
    cmp di,3838
    je line_end1
    mov word[es:di],0x0720
    mov ax, 0x07DC
    add di, 2              ; Move left
    mov [es:di], ax
    mov [boxloc],di
    jmp exit1
line_end1:
    add di,2
    jmp checkend1
line_end2:
    sub di,2
    jmp checkend2
clrscr:
    push ax 
    push cx 
    push di 
    mov  ax, 0xb800 
    mov  es, ax             ; point es to video base 
    xor  di, di             ; point di to top left column 
    mov  ax, 0x0720         ; space char in normal attribute 
    mov  cx, 2000           ; number of screen locations 
    cld                     ; auto increment mode 
    rep  stosw              ; clear the whole screen 
    pop  di 
    pop  cx 
    pop  ax 
    ret
randG:
    mov word [rand],0
    mov word [randnum],0
    push bp
    mov bp, sp
    pusha
    cmp word [rand], 0
    jne next
    MOV AH, 00h 
    INT 1AH
    inc word [rand]
    mov [randnum], dx
    jmp next1
next:
    mov ax, 25173
    mul word  [randnum]
    add ax, 13849
    mov [randnum], ax
next1:xor dx, dx
    mov ax, [randnum]
    mov cx, [bp+4]
    inc cx
    div cx
    add dl,'A'
    mov [bp+6], dx
    popa
    pop bp
    ret 2               ; Return, cleaning up 2 bytes from the stack
randGnum:
mov word [rand],0
mov word [randnum],0
push bp
mov bp, sp
pusha
cmp word [rand], 0
jne nextt
MOV AH, 00h 
INT 1AH
inc word [rand]
mov [randnum], dx
jmp next2
nextt:
mov ax, 25173         
mul word  [randnum]   
add ax, 13849     
mov [randnum], ax
next2:xor dx, dx
mov ax, [randnum]
mov cx, [bp+4]
inc cx
div cx
mov [bp+6], dx
popa
pop bp
ret 2
printbox:
push ax
mov ax, 0xB800
mov es, ax
mov di, 3760
mov ax, 0x07DC
mov word[es:di], ax
pop ax
ret
numberdisplay:
call missed_string
call score_string
mov ax, 34
push ax
push word[score]
call printnum
mov ax, 14
push ax
push word[life]
call printnum
ret
printnum:
push bp
mov bp, sp
push es
push ax
push bx
push cx
push dx
push di
mov ax, 0xb800
mov es, ax ; point es to video base
mov ax, [bp+4] ; load number in ax
mov bx, 10 ; use base 10 for division
mov cx, 0 ; initialize count of digits
nextdigitt: mov dx, 0 ; zero upper half of dividend
div bx ; divide by 10
add dl, 0x30 ; convert digit into ascii value
push dx ; save ascii value on stack
inc cx ; increment count of values
cmp ax, 0 ; is the quotient zero
jnz nextdigitt ; if no divide it again
mov di, [bp+6] ; point di to 70th column
nextposs: pop dx ; remove a digit from the stack
mov dh, 00001111b ; use normal attribute
mov [es:di], dx ; print char on screen
add di, 2 ; move to next screen location
loop nextposs ; repeat for all digits on stack
pop di
pop dx
pop cx
pop bx
pop ax
pop es
pop bp
ret 4

score_string:
push ax
mov ax, 11
push ax ; push x position
mov ax, 0
push ax ; push y position
mov ax, 00001111b ; blue on black attribute
push ax ; push attribute
mov ax, string2
push ax ; push address of message
push word [length2] ; push message length
call printstr ; call the printstr subrouti
ret

missed_string:
push ax
mov ax, 0
push ax ; push x position
mov ax, 0
push ax ; push y position
mov ax, 00001111b ; blue on black attribute
push ax ; push attribute
mov ax, string1
push ax ; push address of message
push word [length1] ; push message length
call printstr ; call the printstr subrouti
ret

printstr: push bp
mov bp, sp
push es
push ax
push cx
push si
push di
mov ax, 0xb800
mov es, ax ; point es to video base
mov al, 80 ; load al with columns per row
mul byte [bp+10] ; multiply with y position
add ax, [bp+12] ; add x position
shl ax, 1 ; turn into byte offset
mov di,ax ; point di to required location
mov si, [bp+6] ; point si to string
mov cx, [bp+4] ; load length of string in cx
mov ah, [bp+8]
cld ; auto increment mode
nextchar: lodsb ; load next char in al
stosw ; print char/attribute pair
loop nextchar ; repeat for the whole string
pop di
pop si
pop cx
pop ax
pop es
pop bp
ret 12


generate_random_char:
 call numberdisplay
inc word[chartime1]
cmp word[chartime1],7
jne midend
mov word[chartime1],0
cmp word[charflag1],0
jne movdown1
push ax
push 25
call randG
pop ax
mov ah,0x0D
mov word[char1],ax
mov ax,0
sub sp,2
push 80
call randGnum
pop ax
shl ax, 1
add ax, 128
cmp ax, 160
jae mover21
add ax, 160
mover21:
mov word[char1loc],ax
mov ax,0xb800
mov es,ax
mov di,[char1loc]
mov ax,[char1]
mov word[es:di],ax
inc word[charflag1]
jmp stop
movdown1:
mov di,[char1loc]
mov word[es:di],0x0720
add word[char1loc],160
cmp word[char1loc],3680
ja changechar1
mov di,[char1loc]
mov ax,[char1]
mov word[es:di],ax
midend
jmp stop
changechar1:
   push ax
   mov ax,[char1loc]
   cmp ax,[boxloc] 
   jne inclife
   pop ax
   inc word[score]
   mov word[char1loc],0
   mov word[char1],0
   mov word[charflag1],0
   jmp stop
   inclife:
   pop ax
   inc word[life]
   mov word[char1loc],0
   mov word[char1],0
   mov word[charflag1],0
stop: ret

generate_random_char2:

call numberdisplay
inc word[chartime2]
cmp word[chartime2],8
jne midend2
mov word[chartime2],0
cmp word[charflag2],0
jne movdown2
push ax
push 25
call randG
pop ax
mov ah,0x0C
mov word[char2],ax
mov ax,0
sub sp,2
push 80
call randGnum
pop ax
shl ax, 1
add ax, 128
cmp ax, 160
jae mover22
add ax, 160
mover22:
mov word[char2loc],ax
mov ax,0xb800
mov es,ax
mov di,[char2loc]
mov ax,[char2]
mov word[es:di],ax
inc word[charflag2]
jmp stop2
movdown2:
mov di,[char2loc]
mov word[es:di],0x0720
add word[char2loc],160
cmp word[char2loc],3680
ja changechar2
mov di,[char2loc]
mov ax,[char2]
mov word[es:di],ax
midend2
jmp stop2
changechar2:
   push ax
   mov ax,[char2loc]
   cmp ax,[boxloc] 
   jne inclife2
   pop ax
   inc word[score]
   mov word[char2loc],0
   mov word[char2],0
   mov word[charflag2],0
   jmp stop2
   inclife2:
   pop ax
   inc word[life]
   mov word[char2loc],0
   mov word[char2],0
   mov word[charflag2],0
    stop2:
    ret
generate_random_char3:

call numberdisplay
inc word[chartime3]
cmp word[chartime3],6
jne midend3
mov word[chartime3],0
cmp word[charflag3],0
jne movdown3
push ax
push 25
call randG
pop ax
mov ah,0x0E
mov word[char3],ax
mov ax,0
sub sp,2
push 80
call randGnum
pop ax
shl ax, 1
add ax, 128
cmp ax, 160
jae mover23
add ax, 160
mover23:
mov word[char3loc],ax
mov ax,0xb800
mov es,ax
mov di,[char3loc]
mov ax,[char3]
mov word[es:di],ax
inc word[charflag3]
jmp stop3
movdown3:
mov di,[char3loc]
mov word[es:di],0x0720
add word[char3loc],160
cmp word[char3loc],3680
ja changechar3
mov di,[char3loc]
mov ax,[char3]
mov word[es:di],ax
midend3
jmp stop3
changechar3:
   push ax
   mov ax,[char3loc]
   cmp ax,[boxloc] 
   jne inclife3
   pop ax
   inc word[score]
   mov word[char3loc],0
   mov word[char3],0
   mov word[charflag3],0
   jmp stop3
   inclife3:
   pop ax
   inc word[life]
   mov word[char3loc],0
   mov word[char3],0
   mov word[charflag3],0
stop3:
 ret

generate_random_char4:

call numberdisplay
inc word[chartime4]
cmp word[chartime4],5
jne midend4
mov word[chartime4],0
cmp word[charflag4],0
jne movdown4
push ax
push 25
call randG
pop ax
mov ah,0x03
mov word[char4],ax
mov ax,0
sub sp,2
push 80
call randGnum
pop ax
shl ax, 1
add ax, 128
cmp ax, 160
jae mover24
add ax, 160
mover24:
mov word[char4loc],ax
mov ax,0xb800
mov es,ax
mov di,[char4loc]
mov ax,[char4]
mov word[es:di],ax
inc word[charflag4]
jmp stop4
movdown4:
mov di,[char4loc]
mov word[es:di],0x0720
add word[char4loc],160
cmp word[char4loc],3680
ja changechar4
mov di,[char4loc]
mov ax,[char4]
mov word[es:di],ax
midend4
jmp stop4
changechar4:
   push ax
   mov ax,[char4loc]
   cmp ax,[boxloc] 
   jne inclife4
   pop ax
   inc word[score]
   mov word[char4loc],0
   mov word[char4],0
   mov word[charflag4],0
   jmp stop4
   inclife4:
   pop ax
   inc word[life]
   mov word[char4loc],0
   mov word[char4],0
   mov word[charflag4],0
stop4:
 ret

generate_random_char5:

call numberdisplay
inc word[chartime5]
cmp word[chartime5],3
jne midend5
mov word[chartime5],0
cmp word[charflag5],0
jne movdown5
push ax
push 25
call randG
pop ax
mov ah,0x01
mov word[char5],ax
mov ax,0
sub sp,2
push 80
call randGnum
pop ax
shl ax, 1
add ax, 128
cmp ax, 160
jae mover25
add ax, 160
mover25:
mov word[char5loc],ax
mov ax,0xb800
mov es,ax
mov di,[char5loc]
mov ax,[char5]
mov word[es:di],ax
inc word[charflag5]
jmp stop5
movdown5:
mov di,[char5loc]
mov word[es:di],0x0720
add word[char5loc],160
cmp word[char5loc],3680
ja changechar5
mov di,[char5loc]
mov ax,[char5]
mov word[es:di],ax
midend5
jmp stop5
changechar5:
   push ax
   mov ax,[char5loc]
   cmp ax,[boxloc] 
   jne inclife5
   pop ax
   inc word[score]
   mov word[char5loc],0
   mov word[char5],0
   mov word[charflag5],0
   jmp stop5
   inclife5:
   pop ax
   inc word[life]
   mov word[char5loc],0
   mov word[char5],0
   mov word[charflag5],0
   stop5:
   ret
timer:
call generate_random_char
call generate_random_char2
call generate_random_char3
call generate_random_char4
call generate_random_char5
jmp far [cs:oldtimer]



_start:
push ax
mov ax, 36
push ax ; push x position
mov ax, 11
push ax ; push y position
mov ax, 10001010b 
push ax ; push attribute
mov ax, string3
push ax ; push address of message
push word [length3] ; push message length
call printstr ; call the printstr subrouti
ret

_loading:
push ax
mov ax, 33
push ax ; push x position
mov ax, 12
push ax ; push y position
mov ax, 00001111b 
push ax ; push attribute
mov ax, string4
push ax ; push address of message
push word [length4] ; push message length
call printstr ; call the printstr subrouti
ret


display_start:
pusha
call _start
call delay
call delay
call _loading

mov ax,0xb800
mov es,ax
mov ah,00001111b
call short_pause
mov al,'3'
mov [es:2022],ax
call short_pause
mov al,'2'
mov [es:2022],ax
call short_pause
mov al,'1'
mov [es:2022],ax
call short_pause


popa
ret


display_end:
pusha
call clrscr
call _end
mov ax, 1854
push ax
push word[score]
call printnum
cmp word[score],4
ja _end2
jmp _end1

here:
call short_pause
popa
ret

_end1:
call end_string1
jmp here

_end2:
call end_string2
jmp here


end_string1:
push ax
mov ax, 33
push ax ; push x position
mov ax, 12
push ax ; push y position
mov ax, 10001010b ; blue on black attribute
push ax ; push attribute
mov ax, string6
push ax ; push address of message
push word [length6] ; push message length
call printstr ; call the printstr subrouti
ret
end_string2:
push ax
mov ax, 36
push ax ; push x position
mov ax, 12
push ax ; push y position
mov ax, 10001100b ; blue on black attribute
push ax ; push attribute
mov ax, string7
push ax ; push address of message
push word [length7] ; push message length
call printstr ; call the printstr subrouti
ret

_end:
push ax
mov ax, 36
push ax ; push x position
mov ax, 11
push ax ; push y position
mov ax, 00001111b ; blue on black attribute
push ax ; push attribute
mov ax, string5
push ax ; push address of message
push word [length5] ; push message length
call printstr ; call the printstr subrouti
ret

delay:
pusha
mov cx,0xFFFF
l1:
loop l1
popa
ret

_pause:
pusha
mov cx,300
l2:
call delay
loop l2
popa
ret
short_pause:
pusha
mov cx,50
l0:
call delay
loop l0
popa
ret



start:
    call clrscr
    call display_start
    call clrscr
    call printbox

xor ax, ax
mov es, ax
mov ax,[es:9*4]
mov word[oldisr],ax
mov ax,[es:9*4+2]
mov word[oldisr+2],ax
mov ax,[es:8*4]
mov word[oldtimer],ax
mov ax,[es:8*4+2]
mov word[oldtimer+2],ax
cli
mov word[es:9*4],kbisr
mov [es:9*4+2],cs
mov word[es:8*4],timer
mov [es:8*4+2],cs
sti
label:
cmp word[life], 10
jae finalexit
jmp label

finalexit:
cli
xor ax, ax
mov es, ax
mov cx, [oldtimer]
mov dx, [oldtimer+2]
mov word [es:8*4], cx
mov word [es:8*4+2], dx
sti
call clrscr
mov word[life], 10
call display_end
mov dx, start
add dx,15
mov cl, 4
shr dx, cl
mov ax, 0x3100
int 21h