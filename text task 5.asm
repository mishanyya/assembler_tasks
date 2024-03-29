SECTION .data        ;для инициализированных данных

invite1 db "Введите с клавиатуры строку, в которой будем искать",0xa,0
linvite1 equ $-invite1

match db "Найдено",0xa,0
lmatch equ $-match

nomatch db "Не найдено",0xa,0
lnomatch equ $-nomatch

n db 0xa                   ;переменная для переноса строки

SECTION .bss         ;для НЕинициализированных данных
input1: resb 100                              ;выделение памяти в 10 байт, где input- адрес первого символа
linput1 equ $-input1                           ;адрес с длиной сообщения

SECTION .text      ;начало кода самой программы

GLOBAL _start
    _start:
;поиск символов в строке
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
mov eax,'q'          ;символы или их номер в ASCII, которые ищем
mov edi,input1       ;адрес памяти/строки, в которой ищем
repne scasb
                     ;rep,repne,repe - циклы вместо loop, только для поиска,
                     ;но метку возврата им не надо
                     ;rep - повтор любых действий
                     ;repne и repe - поиск до тех пор, пока не найдено
                     ;или найдено соответственно

                     ;scasb,scasw,scasd - сканирование строки из байт, слов, двойных слов
                     ;1 символ, например 'q' - это байт, нужен scasb,
                     ;2 символа, например 'qw' - это слово, нужен scasw,
                     ;4 символа, например 'qwer' - это двойное слово, нужен scasd,
                     ;если указать несколько
                     ;символов, то например 'qw' будет искать первый символ 'q'
                     ;но если указать три символа, например 'qwe'
                     ;а искать с использованием кода для четырех символов,
                     ;то искать не будет!
                     ;может не корректно работать с кириллицей!

je yes  ;если найдено
jne no  ;если не найдено


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
