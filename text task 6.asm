SECTION .data        ;для инициализированных данных

invite db "Введите с клавиатуры одну строку",0xa,0
linvite equ $-invite

invite1 db "Введите с клавиатуры другую строку",0xa,0
linvite1 equ $-invite1

match db "Строки совпали",0xa,0
lmatch equ $-match

nomatch db "Строки не совпали",0xa,0
lnomatch equ $-nomatch

n db 0xa                   ;переменная для переноса строки

SECTION .bss         ;для НЕинициализированных данных
input: resb 100                              ;выделение памяти в 10 байт, где input- адрес первого символа
linput equ $-input                           ;адрес с длиной сообщения

input1: resb 100                              ;выделение памяти в 10 байт, где input- адрес первого символа
linput1 equ $-input1                           ;адрес с длиной сообщения

SECTION .text      ;начало кода самой программы

GLOBAL _start
    _start:
;сравнение строк в строке
;вывод приглашения
mov ecx,invite        ;ввод адреса
mov edx,linvite       ;ввод количества символов
mov eax,4
mov ebx,1
int 80h

;ввод строки, которую ищем
mov ecx,input        ;ввод адреса
mov edx,linput       ;ввод количества символов
mov eax,3
mov ebx,0
int 80h

;вывод приглашения
mov ecx,invite1        ;ввод адреса
mov edx,linvite1       ;ввод количества символов
mov eax,4
mov ebx,1
int 80h

;ввод строки, в которой ищем
mov ecx,input1        ;ввод адреса
mov edx,linput1       ;ввод количества символов
mov eax,3
mov ebx,0
int 80h

mov ecx, 100         ;количество (циклов) попыток поиска, обычно размер строки
mov esi,input
mov edi,input1
repe cmpsb      ;сравнивать, пока совпадают
jne no          ;если символы не совпали

                     ;rep,repne,repe - циклы вместо loop, только для поиска,
                     ;но метку возврата им не надо
                     ;rep - повтор любых действий
                     ;repne и repe - поиск до тех пор, пока не найдено
                     ;или найдено соответственно

je yes  ;если найдено

yes:
 ;вывод результата
 mov ecx,match        ;ввод адреса
 mov edx,lmatch       ;ввод количества символов
 mov eax,4
 mov ebx,1
 int 80h
 jmp end

no:
 ;вывод результата
 mov ecx,nomatch        ;ввод адреса
 mov edx,lnomatch       ;ввод количества символов
 mov eax,4
 mov ebx,1
 int 80h
 jmp end

end:
                     ;здесь заканчивается вывод данных:

mov eax, 1          ;содержимое помещается в регистр в EAX помещается 1 - номер системного вызова "exit"
mov ebx, 0          ;содержимое помещается в регистр в EBX помещается 0 - параметр вызова "exit" означает код с которым завершится выполнение программы
int 0x80            ;системный вызов. После системного вызова "exit" выполнение программы завершается
