.model small
.stack 100h

.data 
    keys db 10000*16 dup(0)
    values dw 10000 dup(0)
    key db 16 dup(0)
    value db 6 dup(0)
    amounts dd 0
    char db 0
    pointer dw 0
    counter dw 0


.code
main proc
    mov ax, @data          ; Завантаження адреси сегмента даних у регістр ax
    mov ds, ax             ; Завантаження адреси сегмента даних у регістр ds
    mov si, offset key ; Завантаження адреси початку буфера у регістр si

read_input:
    mov ah, 3Fh            ; Функція для зчитування з файлу
    mov bx, 0h             ; Стандартний ввід
    mov cx, 1             ; Кількість байт для зчитування
    mov dx, offset char             ; Адреса, куди зберігається зчитаний байт (починаючи з поточного розташування si)
    int 21h                ; Виклик системного сервісу DOS для зчитування

    or ax,ax
    jz lastline

    cmp char, 0Dh
    je nextLine

    cmp char, ' '
    je switchOnNumber

    cmp char, 0Ah
    je read_input

    mov al, char
    mov [si], al

    inc si                 
    jmp read_input           
    switchOnNumber:
        mov si, offset value
        jmp read_input
    nextLine:
        call writeInArray
        call clearValueAndKey
        inc pointer
        mov si, offset key
        jmp read_input
    lastline:
        call writeInArray
        call clearValueAndKey
 
    mov bx, 0                       ; покажчик ключа з яким працюємо
    mov counter, 0                  ; лічильник кількості сум (для обчислння average)
findAverage_loop:
    mov dx, bx
    shl dx, 4
    mov si, offset keys
    add si, dx
    cmp bx, pointer                 ; первірка чи дійшли до EOF
    jg findloop_end
    cmp byte ptr [si], 0
    je nextCon
    shl bx, 1                       ; додання до лічильника сум першого входження по ключу
    mov ax,[values + bx]
    shr bx, 1
    mov si, offset amounts   
    add word ptr [si], ax     
    adc word ptr [si + 2], 0  
    inc counter
    mov cx, bx                      ; лічильник для перебіру інших ключів, для порівняння
    inc cx
    inner_loop:
        cmp cx, pointer                
        jg nextFind
        push bx                        
        push cx
        call compareKey
        pop ax
        pop cx
        pop bx
        cmp ax, 1
        je addToValue
        inc cx
        jmp inner_loop
    addToValue:
        call addToAmounts
        call clearElementFromKeys
        inc counter
        inc cx
        jmp inner_loop
    nextFind:
        mov dx, bx
        shl dx, 4
        mov si, offset keys
        add si, dx
        cmp byte ptr [si], 0
        je nextCon
        mov si, offset amounts
        mov ax, [si]
        mov dx, [si + 2]
        div counter
        shl bx, 1
        mov [values + bx], ax
        shr bx, 1
        mov counter, 0
        mov si, offset amounts
        mov word ptr [si], 0
        mov word ptr [si + 2], 0 
        nextCon:
        inc bx
        jmp findAverage_loop
    findloop_end:

    mov cx, word ptr pointer
    mov bx,0
    cmp cx, 0 
    je printResult
SortouterLoop:
    push cx
    lea si, values
    mov counter, 0
    innerLoop:
        mov ax, [si]
        cmp [si+2], ax
        jl nextStep
        xchg [si+2], ax
        mov [si], ax
        call xchgKeys
    nextStep:
        inc counter
        add si, 2
        loop innerLoop
        pop cx
        loop SortouterLoop



    mov bx, 0
printResult:
    mov si, offset keys
    shl bx, 4
    add si, bx
    shr bx, 4

    cmp byte ptr [si], 0
    je end_program

    printKey_loop:
    cmp byte ptr [si], 0
    je printContinue

    mov ah, 02h
    mov dl, [si]
    int 21h

    inc si
    jmp printKey_loop

    printContinue:

    mov ah, 02h
    mov dl, 10
    int 21h




    inc bx
    jmp printResult

end_program:
    mov ah, 4Ch            ; Код функції для завершення програми
    int 21h                ; Виклик системного сервісу DOS

main endp

xchgKeys proc
    push si
    push cx
    push ax

    mov si, offset keys
    shl counter, 4
    add si, counter
    shr counter, 4

    mov cx, 16
    change_loop:
    mov ah, [si]
    xchg [si + 16], ah
    mov [si], ah
    inc si
    loop change_loop
    pop ax
    pop cx
    pop si
    ret
xchgKeys endp

addToAmounts proc
    mov di, offset values
    shl cx, 1
    add di, cx
    shr cx, 1
    mov ax, [di]
    mov si, offset amounts    
    add word ptr [si], ax   
    adc word ptr [si + 2], 0  
    mov [di], -61A8h
    ret
addToAmounts endp

writeInArray proc
    mov si, offset key
    mov bx, pointer
    shl bx, 4
    mov cx, 16
writeKey_loop:
    mov al,[si]
    mov [keys + bx],al
    inc bx
    inc si
    loop writeKey_loop

    call convertToDec
    mov bx, pointer
    shl bx, 1
    mov [values + bx], dx

    ret
writeInArray endp

convertToDec proc
    mov si, offset value
    add si, 5
    mov cx, 6
    mov bh, 0
    mov bl, 0
    mov dx, 0
convertValue_loop:
    mov bh,[si]
    cmp bh, 45
    je negative
    cmp bh, 48
    jl continue
    cmp bh, 57
    jg continue
    sub bh, 48
    push dx
    push bx
    push cx
    call power
    pop cx
    pop bx
    pop dx

    push bx
    mov bl, bh
    xor bh,bh

    push dx
    mul bx
    pop dx
    pop bx
    add dx, ax
    inc bl
    jmp continue
negative:
    neg dx
continue:
    dec si
    loop convertValue_loop
    ret
convertToDec endp

clearValueAndKey proc
    push bx
    mov bx, 0
    mov cx, 16
clearKey_loop:
    mov [key + bx], 0
    inc bx
    loop clearKey_loop

    mov cx, 6
    mov bx, 0
clearValue_loop:
    mov [value + bx], 0
    inc bx
    loop clearValue_loop
    pop bx
    ret
clearValueAndKey endp

clearElementFromKeys proc
    push cx
    push bx
    mov bx, cx
    shl bx, 4
    mov cx, 16
clearKeyFromKeys_loop:
    mov [keys + bx], 0
    inc bx
    loop clearKeyFromKeys_loop
    pop bx
    pop cx
    ret
clearElementFromKeys endp

power proc
    mov ax,1
    mov cx, 10
power_loop:
    cmp bl,0
    je done
    mul cx
    dec bl
    jmp power_loop
done:
    ret
power endp

compareKey proc
    pop bx
    pop ax
    pop dx
    push dx
    push ax
    shl ax, 4
    shl dx, 4
    push bx
    mov si, offset keys
    add si, ax
    mov di, offset keys
    add di, dx
    mov cx, 16
comprasion_loop:
    mov bh, [di]
    cmp byte ptr [si], bh
    jne notEqual
    inc si
    inc di
    loop comprasion_loop
    jmp equal
notEqual:
    pop bx
    push 0
    push bx
    ret
equal:
    pop bx
    push 1
    push bx
    ret
compareKey endp

end main