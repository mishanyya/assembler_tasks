SECTION .data        ;для инициализированных данных

invite db "Введите первое число от 0 до 65535 включительно:",0xa,0
linvite equ $-invite

invite1 db "Введите второе число от 0 до 65535 включительно:",0xa,0
linvite1 equ $-invite1

invite2 db "Введите знак операции:",0xa,0
linvite2 equ $-invite2

invite3 db "Результат:",0xa,0
linvite3 equ $-invite3

invite4 db "Остаток:",0xa,0
linvite4 equ $-invite4

nosign db "Знак не введен!",0xa,0
lnosign equ $-nosign

nocorrectvalue db "Введено некорректное значение!",0xa,0
lnocorrectvalue equ $-nocorrectvalue


n db 0xa                   ;переменная для переноса строки
ln equ $-n


SECTION .bss         ;для НЕинициализированных данных
;при выделении памяти лучше выделить больше чем надо, хотя бы на 1 байт

;ввод символов
value1: resb 6                              ;выделение памяти в 5 байт, где value1 - адрес первого символа
lvalue1 equ $-value1                        ;адрес с длиной сообщения

;ввод символов
value2: resb 6                              ;выделение памяти в 5 байт, где value2 - адрес первого символа
lvalue2 equ $-value2

;ввод знака
sign: resb 2                                ;выделение памяти в 1 байт, где sign - адрес первого символа
lsign equ $-sign

;вывод целого результата
output: resb 10                             ;выделение памяти в 10 байт
loutput equ $-output                        ;адрес с длиной сообщения

;вывод остатка от деления
output1: resb 10                             ;выделение памяти в 10 байт
loutput1 equ $-output1                        ;адрес с длиной сообщения

SECTION .text     ;начало кода самой программы

;инструкция ret подпрограммы использует стек и регистр RSP/ESP, поэтому его не трогать!
;вывод записи, использование стандартных обязательных данных
PRINT:
mov eax,4
mov ebx,1
int 80h       ;данные из rdx копируются в rax
ret

;ввод записи
WRITE:
mov eax,3
mov ebx,0
int 80h      ;в rax помещается 0
ret

GLOBAL _start
    _start:
;вывод приглашения ввести символы
mov ecx,invite       ;ввод адреса
mov edx,linvite      ;ввод количества символов
call PRINT

;ввод первого значения
mov ecx,value1       ;ввод адреса
mov edx,lvalue1    ;ввод количества символов
call WRITE

mov ecx,invite2       ;ввод адреса
mov edx,linvite2    ;ввод количества символов
call PRINT

;ввод арифметического знака
mov ecx,sign       ;ввод адреса
mov edx,lsign    ;ввод количества символов
call WRITE

;вывод приглашения ввести символы
mov ecx,invite1       ;ввод адреса
mov edx,linvite1      ;ввод количества символов
call PRINT

;ввод второго значения
mov ecx,value2       ;ввод адреса
mov edx,lvalue2    ;ввод количества символов
call WRITE

;вывод результата
mov ecx,invite3       ;ввод адреса
mov edx,linvite3      ;ввод количества символов
call PRINT

;переставить первое число в памяти в обратном порядке
;проверка на символ '-' №45 в начале строки
cmp byte[value1],45
je incorrectvalue

mov edi,value1   ;поместить адрес, т.е. указатель в регистр
xor rdx,rdx        ;для счета значений
xor rax,rax
mov cx,5           ; счетчик
input:
mov al,byte[edi]    ;поместить значение в al
;проверка на число
cmp al,48
jge nextto
jl exitto
nextto:
cmp al,57
jle inputok
jg exitto
inputok:
inc dx
inc edi
push rax
loop input
exitto:  ;выход из цикла
mov ecx,edx        ;счетчик
mov edi,value1     ;поместить адрес, т.е. указатель в регистр

;если ничего не вводилось, перепрыгиваем извлечение из стека
cmp edx,0
jle novalue
opo:
pop rax
mov byte[edi],al
inc edi
loop opo
novalue:

;переставить второе число в памяти в обратном порядке
mov edi,value2    ;поместить адрес, т.е. указатель в регистр
xor dx,dx            ;для счета значений
mov cx,5              ; счетчик
input1:
mov al,byte[edi]       ;поместить значение в al
;проверка на число
cmp al,48
jge nextto1
jl exitto1
nextto1:
cmp al,57
jle inputok1
jg exitto1
inputok1:
inc dx
inc edi
push rax
loop input1
exitto1:  ;выход из цикла
mov ecx,edx        ;счетчик
mov edi,value2     ;поместить адрес, т.е. указатель в регистр

;если ничего не вводилось, перепрыгиваем извлечение из стека
cmp edx,0
jle novalue1
opo1:
pop rax
mov byte[edi],al
inc edi
loop opo1
novalue1:

;;;;;;;;;;;
;поместить первое число в регистр esi, проверить его на корректность
;перенести его в si, сдвинуть вправо и поместить в стек
xor esi,esi         ;обнуление регистра для хранения промежуточного и итогового результата
xor rax,rax         ;обнуление регистра
xor edx,edx         ;обнуление регистра
mov edi,value1      ;поместить адрес, т.е. указатель в регистр
mov bx,10         ;для хранения чисел со степенями 10
mov al,byte[edi]        ;поместить значение в ax
;проверка на число
cmp al,48
jge next
jl exit
next:
cmp al,57
jle multi
jg exit
multi:
sub al,'0'              ;получить числовое значение символа
movzx esi,al           ;поместить 1-байтное значение из al в 4-байтный регистр esi
inc edi                 ;увеличить адрес памяти на 1
mov ecx,3            ;счетчик по количеству символов
mult:
mov al,byte[edi]       ;поместить значение в ax
;проверка на число
cmp al,48
jge next1
jl exit
next1:
cmp al,57
jle multi1
jg exit
multi1:
sub al,'0'          ;получить числовое значение символа
mul bx            ;умножить ax*bx=dx ax
mov bp,ax          ;внесение результата степени
add esi,ebp            ;добавить число к промежуточному значению
mov eax,10            ;поместить 10 в eax
mul bx               ;умножить ax*bx=dx ax, dx и ax 100.000 4 байта
mov bx,ax            ;поместить в bx = 100
xor eax,eax             ;обнулить eax
inc edi              ;увеличить адрес памяти на 1
loop mult
mov al,byte[edi]   ;поместить значение в ax
;проверка на число
cmp al,48
jge next2
jl exit
next2:
cmp al,57
jle multi2
jg exit
multi2:
sub al,'0'           ;получить числовое значение символа
mul bx            ;умножить ax*bx=dx ax  3*10000
mov bp,ax         ;внесение результата степени = 30000
add esi,ebp         ;добавить число к промежуточному значению
exit:
;;;;;;;;;;;;;;;;;;;;;;;;;
;проверка вводимого числа в регистре si, оно должно быть
;не меньше 0 и не больше 65535, которое помещается в 2-х байтном регистре
cmp esi,65535
jg incorrectvalue
;sub si,65536
;js incorrectvalue       ;если флаг знака SF=1
;по идее отрицательный результат операции можно проверить по флагу SF,
;но иногда проще проверить наличие знака '-' при вводе
;числа, номер символа 'минус' в ASCII №45


;;;;;;;;;;;;;;;;;;;;;;;
shl esi,16      ;в связи с отсутствием свободных регистров
                ;переносим результат для хранения в старшие 3 и 4 биты регистра esi
                ;и тогда можно снова использовать регистр si
push rsi   ;поместить значение из регистра rsi в стек

;;;;;;;;;;;
;проверка на символ '-' №45 в начале строки (ввод отрицательного числа)
cmp byte[value2],45
je incorrectvalue

;поместить второе число в регистр esi, проверить его на корректность
;перенести его в si, затем скопировать из si в di,
;обнулить rsi, взять данные из стека,
;поместить в rsi и сложить с di

xor esi,esi         ;обнуление регистра для хранения промежуточного и итогового результата
xor rax,rax         ;обнуление регистра
xor edx,edx         ;обнуление регистра
mov edi,value2    ;поместить адрес, т.е. указатель в регистр
mov bx,10         ;для хранения чисел со степенями 10
mov al,byte[edi]        ;поместить значение в ax
;проверка на число
cmp al,48
jge next3
jl exit1
next3:
cmp al,57
jle multi3
jg exit1
multi3:
sub al,'0'              ;получить числовое значение символа
movzx esi,al           ;поместить 2-байтное значение из al в 2-байтный регистр si
inc edi                 ;увеличить адрес памяти на 1
mov ecx,3            ;счетчик по количеству символов
mult1:
mov al,byte[edi]  ;поместить значение в ax
;проверка на число
cmp al,48
jge next4
jl exit1
next4:
cmp al,57
jle multi4
jg exit1
multi4:
sub al,'0'        ;получить числовое значение символа
mul bx            ;умножить ax*bx=dx ax
mov bp,ax         ;внесение результата степени
add esi,ebp         ;добавить число к промежуточному значению
mov eax,10        ;поместить 10 в eax
mul bx            ;умножить ax*bx=dx ax, dx и ax 100.000 4 байта
mov bx,ax         ;поместить в bx = 100
xor eax,eax       ;обнулить eax
inc edi           ;увеличить адрес памяти на 1
loop mult1
mov al,byte[edi]  ;поместить значение в ax
;проверка на число
cmp al,48
jge next5
jl exit1
next5:
cmp al,57
jle multi5
jg exit1
multi5:
sub al,'0'        ;получить числовое значение символа
mul bx            ;умножить ax*bx=dx ax  3*10000
mov bp,ax         ;внесение результата степени = 30000
add esi,ebp         ;добавить число к промежуточному значению
exit1:

;поместить второе число в регистр esi, скопировать из esi в edi,
;проверить его на корректность

;обнулить rsi, взять данные из стека,
;поместить в rsi и сложить с di

;копируем для сохранения из esi в edi
mov edi,esi

;проверка вводимого числа в регистре si, оно должно быть
;не меньше 0 и не больше 65535, которое помещается в 2-х байтном регистре
;esi указан, так как в si большее число не поместится
cmp esi,65535
jg incorrectvalue

xor rsi,rsi
pop rsi
add si,di


xor eax,eax  ;обнуление
xor edx,edx  ;обнуление
;;;;;;;;;;;;;;;

;содержит значение:
;1 байт не больше 255
;2 байта не больше 65535
;4 байта не больше 4.294.967.295
;8 байт не больше 1,844674407×10¹⁹

;поместить одно значение в регистр ax
;а второе поместить в регистр si
mov ax,si          ;получить второе! значение
shr esi,16         ;передвинуть первое! значение в регистр si
;;;;;;;;;;;;;;;;;;;;;
;eax и edx- обнулены
;данные введены
;si - первое! число
;ax - второе! число
;byte[sign] - символ знака
xchg si,ax  ;меняем их местами, так как надо ax - первое , а si - второе число!!!
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;умножение работает
mov cl,byte[sign]   ;перевести числовое значение из byte[sign] в cl
mov ch,'*'        ;номер в регистре обычно обозначает номер символа в ASCII
not ch              ;а затем в обратную двоичную форму
test cl,ch     ;сравнение символа и инвертированной маски
jz yesmul      ;если значения обратно сопоставимы и установился ZF=1

;деление работает
mov cl,byte[sign]   ;перевести числовое значение из byte[sign] в cl
mov ch,'/'        ;номер в регистре обычно обозначает номер символа в ASCII
not ch              ;а затем в обратную двоичную форму
test cl,ch     ;сравнение символа и инвертированной маски
jz yesdiv            ;если значения обратно сопоставимы и установился ZF=1

;сложение и вычитание пока не работает
;test cl,'+'     ;+
;jz             ;если значения обратно сопоставимы и установился ZF=1
;test cl,'-'     ;-
;jz             ;если значения обратно сопоставимы и установился ZF=1

jnz tonosign   ;если значения обратно НЕ сопоставимы и установился ZF=0

;;;;;;;;;;;;;;;;;;
;операция умножения
yesmul:
;выполнить операцию умножения
mul si             ;умножаем ax на si и результат в dx и ax

;вывод результата умножения из регистров dx ax в память output
;перенести результат из dx ax в память  output
mov edi,output   ;получить адрес output
;add edi,loutput-1  ;адрес последнего символа
;деление 8-и байтных значений
;div 4-х байтный регистр
;edx eax/4-х байтный регистр = eax (результат) и edx (остаток)
;4 байта - число не более 4.294.967.295
mov ecx,10  ;счетчик
mov esi,10  ;для вывода в 10-м формате
;edx 0000fffe и eax 00000001 не работает деление!!!
;пробуем перенести значение из (e)dx в начало регистра eax
shl edx,16     ;сдвинуть значение влево из 2-х байного dx в начало 4-х байтного регистра edx
mov dx,ax      ;перенести значение из ax в dx
mov eax,edx    ;перенести полное значение из edx в eax для деления
xor edx,edx    ;обнулить edx для деления, так как значение оттуда убрали
again:
div esi      ;делим на 4-х байтный регистр, так как делимое в 4-х байтном регистре
             ;eax (результат, так как делим на 4-х байтный регистр)
             ;edx (остаток, так как делим на 4-х байтный регистр)
             ;так как делим на 10, то остаток, который меньше 10 поместится в dl

mov byte[edi],dl
add byte[edi],'0'
xor edx,edx     ;обнуляем edx, так как там есть остаток, участвующий в следующем делении
inc edi

cmp eax,10
jl no   ;если результат <10
Jge nextend
nextend:

loop again
no:            ;далее
mov byte[edi],al
add byte[edi],'0'

;переставить числа в памяти в обратном порядке
mov edi,output    ;поместить адрес, т.е. указатель в регистр
xor dx,dx            ;для счета значений
mov cx,10              ; счетчик

inputout:
mov al,byte[edi]       ;поместить значение в al

;проверка на число
cmp al,48
jge nexttoout
jl exittoout
nexttoout:
cmp al,57
jle inputokout
jg exittoout

inputokout:
inc dx
inc edi
push rax
loop inputout

exittoout:  ;выход из цикла

mov ecx,edx        ;счетчик
mov edi,output     ;поместить адрес, т.е. указатель в регистр

;если ничего не вводилось, перепрыгиваем извлечение из стека
cmp edx,0
jle novalue3
opoout:
pop rax
mov byte[edi],al
inc edi
loop opoout
novalue3:
jmp tofinish

tofinish:
;вывод результата
mov ecx,output       ;ввод адреса
mov edx,loutput     ;ввод количества символов
call PRINT
jmp tomainfinish
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;













yesdiv:

;операция деления

;делимое - 1 или 2 байта
;делитель - 1 или 2 байта
;поэтому используем операцию div 2-байтный регистр
;DX AX / 2-байта = целое AX + остаток DX

;число si не должно равняться 0!
cmp si,0
je incorrectvalue

div si            ;делим dx ax на si, целое в ax остаток в dx
mov bp,dx        ;сдвигаем остаток в регистр bp
;вывод результата деления из регистра ax в память output
mov edi,output   ;получить адрес output
mov ecx,5  ;счетчик, так как если максим число 65535/1 получится целое из 5 знаков
mov si,10  ;для вывода в 10-м формате
xor dx,dx     ;обнуляем dx, так как там есть остаток, участвующий в следующем делении

againdiv:
div si
mov byte[edi],dl   ;остаток
add byte[edi],'0'
xor dx,dx     ;обнуляем dx, так как там есть остаток, участвующий в следующем делении
inc edi
cmp ax,10
jl no1   ;если результат <10
loop againdiv
no1:            ;далее
mov byte[edi],al
add byte[edi],'0'

;переставить числа в памяти в обратном порядке
mov edi,output    ;поместить адрес, т.е. указатель в регистр
xor dx,dx            ;для счета значений и так пустой регистр после деления
mov cx,5             ;счетчик
inputoutdiv:
mov al,byte[edi]

;проверка на число
cmp al,48
jge nexttooutdiv
jl exittooutdiv
nexttooutdiv:
cmp al,57
jle inputokoutdiv
jg exittooutdiv

inputokoutdiv:
inc dx
inc edi
push rax
loop inputoutdiv
exittooutdiv:  ;выход из цикла

mov cx,dx        ;счетчик
mov edi,output     ;поместить адрес, т.е. указатель в регистр 1

;если ничего не вводилось, перепрыгиваем извлечение из стека
cmp dx,0
jle novalue2

opooutdiv:
pop rax
mov byte[edi],al
inc edi
loop opooutdiv
novalue2:

;вывод целого значения от результата
mov ecx,output       ;ввод адреса
mov edx,loutput     ;ввод количества символов
call PRINT

;переход на новую строку
mov ecx,n
mov edx,ln
call PRINT


;вывод остатка от деления из регистра bx в память output1
mov ax,bp         ;остаток от основного деления
mov edi,output1   ;получить адрес output1
mov cx,5  ;счетчик, так как если максим число 65535/65534 получится целое из 5 знаков
mov si,10  ;для вывода в 10-м формате
xor dx,dx     ;обнуляем dx, так как там есть остаток, участвующий в следующем делении

againdiv1:
div si
mov byte[edi],dl  ;остаток как и положено помещен из dl в память
add byte[edi],'0'
xor dx,dx    ;обнуляем dx, так как там есть остаток, участвующий в следующем делении
inc edi
cmp ax,10
jl no2   ;если результат <10
loop againdiv1
no2:            ;далее
mov byte[edi],al
add byte[edi],'0'






;переставить числа в памяти в обратном порядке
mov edi,output1   ;поместить адрес, т.е. указатель в регистр
xor dx,dx          ;для счета значений и так пустой регистр после деления
xor rcx,rcx       ;в регистре rcx остался адрес памяти
mov cx,5             ;счетчик

inputoutdiv2:
mov al,byte[edi]
;проверка на число
cmp al,48
jge nexttooutdiv2
jl exittooutdiv2
nexttooutdiv2:
cmp al,57
jle inputokoutdiv2
jg exittooutdiv2
inputokoutdiv2:
inc dx
inc edi
push rax
loop inputoutdiv2

exittooutdiv2:  ;выход из цикла

mov cx,dx       ;счетчик
mov edi,output1     ;поместить адрес, т.е. указатель в регистр 1

;если ничего не вводилось, перепрыгиваем извлечение из стека
cmp dx,0
jle novalue4


opooutdiv2:
pop rax
mov byte[edi],al
inc edi
loop opooutdiv2
novalue4:

;вывод остатка результата
mov ecx,invite4       ;ввод адреса
mov edx,linvite4     ;ввод количества символов
call PRINT

;вывод целого значения от результата
mov ecx,output1       ;ввод адреса
mov edx,loutput1     ;ввод количества символов
call PRINT

;переход на новую строку
mov ecx,n
mov edx,ln
call PRINT

;проверить   655/  650 = ост 5
jmp tomainfinish
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;операция сложения

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;операция вычитания

;;;;;;;;;;;;;;;;;;;;;;;;;
incorrectvalue:
;введено некорректное значение
mov ecx,nocorrectvalue       ;ввод адреса
mov edx,lnocorrectvalue      ;ввод количества символов
call PRINT
jmp tomainfinish

tonosign:
;знак не введен
mov ecx,nosign       ;ввод адреса
mov edx,lnosign      ;ввод количества символов
call PRINT
jmp tomainfinish
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
tomainfinish:
;перенос строки
mov ecx,n       ;ввод адреса
mov edx,ln     ;ввод количества символов
call PRINT                                      ;6 выход из программы

mov eax, 1          ;содержимое помещается в регистр в EAX помещается 1 - номер системного вызова "exit"
mov ebx, 0          ;содержимое помещается в регистр в EBX помещается 0 - параметр вызова "exit" означает код с которым завершится выполнение программы
int 0x80            ;системный вызов. После системного вызова "exit" выполнение программы завершается
