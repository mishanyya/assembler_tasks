SECTION .data        ;для инициализированных данных

message1 db "Полдень прошел?",0xa,0             ;сообщение вопроса, адрес начала строки
ln equ $-message1                               ;длина сообщения
                                                 ;0xa - перенос строки
                                                 ;0 - не обязателен, но иногда может понадобиться, например при работе с C
nmessage db "Доброе утро!",0xa,0
nln equ $-nmessage

ymessage db "Добрый день!",0xa,0
yln equ $-ymessage

SECTION .bss           ;для НЕинициализированных данных
enter: resb 1                              ;выделение памяти в 1 байт переменной enter
lne equ $-enter                            ;длина сообщения

;начало самой программы
SECTION .text
GLOBAL _start

    _start:

;действия для вывода содержимого по умолчанию с началом в ecx, с длиной edx - вывод вопроса
mov eax,4        ;эта строка №1 обязательна для вывода!
mov ebx,1        ;эта строка №2 обязательна для вывода!
mov ecx, message1       ;в ecx помещается адрес первого символа переменной
mov edx, ln            ;в edx помещается количество символов в переменной
int 0x80         ;эта строка №3 обязательна для вывода!

 m3repeat:             ;метка для перехода, если введено другое значение
;действия для ввода содержимого по умолчанию с началом в ecx, с длиной edx - ввод ответа
mov eax, 3       ;эта строка №1 обязательна для ввода!
mov ebx, 0       ;эта строка №2 обязательна для ввода!
mov ecx, enter         ;в ecx помещается адрес первого символа из enter
mov edx, lne           ;в edx помещается количество символов в переменной, остальные заполнятся нулями
int 0x80        ;эта строка №3 обязательна для ввода!

;действия для сравнения содержимого
 cmp byte [ecx], 'n'    ;при вводе данных через клавиатуру в ecx помещается адрес первого символа из всех существующих
                        ;поэтому при выводе надо указывать ecx в квадратных скобках, так как это адрес символа  [ecx]
                        ;и обязательно указывать размер, в данном случае byte, так как изначально резервировался размер в байтах resb
    je m1               ;если введено 'n'
    ;действия для сравнения содержимого
 cmp byte [ecx], 'y'    ;при вводе данных через клавиатуру в ecx помещается адрес первого символа из всех существующих
                        ;поэтому при выводе надо указывать ecx в квадратных скобках, так как это адрес символа  [ecx]
                        ;и обязательно указывать размер, в данном случае byte, так как изначально резервировался размер в байтах resb
    je m2               ;если введено 'y'
    jne m3repeat        ;если введено не 'n' и не 'y'

m1:                      ;переходит сюда, если введено 'n'
;действия для вывода содержимого по умолчанию с началом в ecx, с длиной edx - вывод вопроса
mov eax,4        ;эта строка №1 обязательна для вывода!
mov ebx,1        ;эта строка №2 обязательна для вывода!
mov ecx, nmessage       ;в ecx помещается адрес первого символа переменной
mov edx, nln            ;в edx помещается количество символов в переменной
int 0x80         ;эта строка №3 обязательна для вывода!
jmp exit              ;выход из условия и переход к метке exit

m2:                    ;переходит сюда, если введено 'y'
;действия для вывода содержимого по умолчанию с началом в ecx, с длиной edx - вывод вопроса
mov eax,4        ;эта строка №1 обязательна для вывода!
mov ebx,1        ;эта строка №2 обязательна для вывода!
mov ecx, ymessage       ;в ecx помещается адрес первого символа переменной
mov edx, yln            ;в edx помещается количество символов в переменной
int 0x80         ;эта строка №3 обязательна для вывода!

exit:
mov eax, 1 ;содержимое помещается в регистр в EAX помещается 1 - номер системного вызова "exit"
mov ebx, 0 ;содержимое помещается в регистр в EBX помещается 0 - параметр вызова "exit" означает код с которым завершится выполнение программы
int 0x80 ;системный вызов. После системного вызова "exit" выполнение программы завершается
mov eax, 1          ;содержимое помещается в регистр в EAX помещается 1 - номер системного вызова "exit"
mov ebx, 0          ;содержимое помещается в регистр в EBX помещается 0 - параметр вызова "exit" означает код с которым завершится выполнение программы
int 0x80            ;системный вызов. После системного вызова "exit" выполнение программы завершается