SECTION .data        ;для инициализированных данных

invite db "Введите несколько букв и цифр:",0xa,0
linvite equ $-invite

n db 0xa                   ;переменная для переноса строки
ln equ $-n


SECTION .bss         ;для НЕинициализированных данных
;ввод символов
input: resb 100                               ;выделение памяти в 100 байт, где input- адрес первого символа
linput equ $-input                           ;адрес с длиной сообщения

;вывод повторяющихся символов
output: resb 100                              ;выделение памяти в 100 байт
loutput equ $-output                            ;адрес с длиной сообщения

;вывод неповторяющихся символов
nodub: resb 10                              ;выделение памяти в 10 байт
lnodub equ $-nodub                            ;адрес с длиной сообщения

;вывод байтов
byteout: resb 16                             ;выделение памяти в 16 байт
lbyteout equ $-byteout                            ;адрес с длиной сообщения

SECTION .text     ;начало кода самой программы

;инструкция ret подпрограммы использует стек и регистр RSP/ESP
;вывод записи, использование стандартных обязательных данных
PRINT:
mov eax,4
mov ebx,1
int 80h
ret

;ввод записи
WRITE:
mov eax,3
mov ebx,0
int 80h
ret

GLOBAL _start
    _start:
                                              ;1 ввод символов в input:

;вывод приглашения ввести символы
mov ecx,invite       ;ввод адреса
mov edx,linvite      ;ввод количества символов
call PRINT

;ввод символов
mov ecx,input       ;ввод адреса
mov edx,linput     ;ввод количества символов
call WRITE
                                    ;2 проверка символов из input на цифры и ввод цифр в память output:

;поместить адрес из памяти в регистр
mov ebx,input
mov edx,output

;кол-во циклов для ввода найденных чисел в память output
mov ecx,linput

;следующий символ
next:
;перенос значений из input в output через 1-байтный регистр al для сравнения
mov al,byte[ebx]
;проверяем каждый символ на совпадение с цифрой от от 0 до 9
;в ASCII с 48 по 57 номера цифр
cmp al,48
jge continue1
jl no
continue1:
cmp al,57
jle yes
jg no
;если не найдена цифра
no:
;увеличение адресов на 1, т.е. получение следующей ячейки памяти
inc ebx          ;только для адреса ввода, для вывода не надо!!! иначе память вывода расходуется впустую!!!
;на проверку следующего символа
loop next
;при завершении цикла - на выход
jmp exit
;ввод цифры в память out
yes:
;перенос значений в output через 1-байтный регистр al
mov byte[edx],al

;увеличение адресов на 1, т.е. получение следующей ячейки памяти
inc ebx
inc edx

;на проверку следующего символа
loop next
;при завершении цикла - на выход
jmp exit

exit:
;вывод введенных символов
mov ecx,output       ;ввод адреса
mov edx,loutput      ;ввод количества символов
call PRINT

;переход на новую строку
mov ecx,n
mov edx,ln
call PRINT

            ;3 символы цифр из output сравнить и дублированные заменить любым одинаковым символом

;замена значений в памяти
mov edi,loutput
mov ebx,loutput
mov esi,output
mov ebp,esi

dec edi
mov ecx,edi

two:
mov dh,byte[esi]
inc esi

one:
cmp dh,byte[esi]
jg greater
jl less
je equal
greater:
;если символы кончились, то выходим

mov dl,byte[esi]
mov byte[ebp],dl
mov byte[esi],dh
mov dh,dl

nextto:
inc esi
loop one
jmp toend

less:
jmp nextto
equal:

;при одинаковых значениях символ меняется на больший по размеру
;и соответственно сдвигается вправо!
;потом их можно отрезать и все, вместо того, чтобы циклом сдвигать все следующие значения!

mov byte[esi],58          ;замена символа на символ с номером 58
jmp nextto

toend:
mov ecx,ebx
dec ebx
inc ebp
mov esi,ebp
loop two

toexit:

mov ecx, output
mov edx,loutput
call PRINT

;переход на новую строку
mov ecx,n
mov edx,ln
call PRINT

;Обычно ошибка сегментации segmentation fault происходит потому, что:
;указатель/адрес нулевой,
;указатель указывает на произвольный участок памяти (возможно потому, что не был инициализирован),
;указатель указывает на удалённый участок памяти.
;в качестве размера массива указана неинициализированная переменная

                                  ;4 выбрать только отсортированные цифры

;выбрать только цифры из output
;ecx - счетчик
mov ecx,loutput
;адрес первого символа для ввода
mov ebx,output

;адрес первого символа для вывода
mov edx,nodub

again1:
;ввод первого символа в регистр
mov al,byte[ebx]

;проверка на число
;проверяем каждый символ на совпадение с цифрой от от 0 до 9
;в ASCII с 48 по 57 номера цифр
cmp al,48
jge continue11
jl nomatch
continue11:
cmp al,57
jle match
jg nomatch
;если не найдена цифра

nomatch:
inc ebx
loop again1
jmp away

match:
mov byte[edx],al
inc ebx      ;увеличить номер ячейки памяти ввода
inc edx      ;увеличить номер ячейки памяти для вывода
loop again1
jmp away

away:

mov ecx,nodub
mov edx,lnodub
call PRINT

;переход на новую строку
mov ecx,n
mov edx,ln
call PRINT

                                         ;4 убрать дублирование и установить биты в 1

;0 - 48 или 00110000b, для поиска ставим 11001111b
;1 - 49 или 00110001b, для поиска ставим 11001110b и т.д.
;проверим каждое значение методом test
;сравнение символа через его номер в ASCII в 2-м формате с инвертированной маской этого номера в том же виде
;при замене 0 на 1 и наоборот - при операции И или TEST во флаг ZF помещается 1,  и можно осуществить переход по условию
;например ,если для поиска 001100b использовать 110011b, то искомый результат будет 0, а при любом другом значении - 1
;если совпадает
;jnz yes  ;ZF = 0    1 и 1 = 1, а остальные комбинации = 0
;если не совпадает
;jz   ZF = 1

;xor ax,ax                          ;задать нулевое значение для регистра ax
;mov rsi,0                            ;задать нулевое значение для регистра rsi, а потом перенести его в rax
xor si,si                            ;обнулить регистр
mov ebx,nodub        ;адрес первой ячейки nodub
mov ecx,lnodub      ;счетчик по количеству символов в строке (10)

;попробовать ввести в память символы, какие-либо символы, не числа! может тогда '0' не будет в памяти
toshift:

mov dl,byte[ebx]   ;значение по адресу ebx

mov dh,'0'        ;номер в регистре обычно обозначает номер символа в ASCII
not dh   ;инвертирует значение, т.е. меняет 1 и 0 наоборот, т.е. на 0 и 1 соответственно
test dl,dh                ;проверяем на 0, обозначение символа в таблице ASCII в двоичном формате
jz match0

mov dh,'1'        ;номер в регистре обычно обозначает номер символа в ASCII
not dh   ;инвертирует значение, т.е. меняет 1 и 0 наоборот, т.е. на 0 и 1 соответственно
test dl,dh                ;проверяем на 0, обозначение символа в таблице ASCII в двоичном формате
jz match1

mov dh,'2'        ;номер в регистре обычно обозначает номер символа в ASCII
not dh   ;инвертирует значение, т.е. меняет 1 и 0 наоборот, т.е. на 0 и 1 соответственно
test dl,dh                ;проверяем на 0, обозначение символа в таблице ASCII в двоичном формате
jz match2

mov dh,'3'        ;номер в регистре обычно обозначает номер символа в ASCII
not dh   ;инвертирует значение, т.е. меняет 1 и 0 наоборот, т.е. на 0 и 1 соответственно
test dl,dh                ;проверяем на 0, обозначение символа в таблице ASCII в двоичном формате
jz match3

mov dh,'4'        ;номер в регистре обычно обозначает номер символа в ASCII
not dh   ;инвертирует значение, т.е. меняет 1 и 0 наоборот, т.е. на 0 и 1 соответственно
test dl,dh                ;проверяем на 0, обозначение символа в таблице ASCII в двоичном формате
jz match4

mov dh,'5'        ;номер в регистре обычно обозначает номер символа в ASCII
not dh   ;инвертирует значение, т.е. меняет 1 и 0 наоборот, т.е. на 0 и 1 соответственно
test dl,dh                ;проверяем на 0, обозначение символа в таблице ASCII в двоичном формате
jz match5

mov dh,'6'        ;номер в регистре обычно обозначает номер символа в ASCII
not dh   ;инвертирует значение, т.е. меняет 1 и 0 наоборот, т.е. на 0 и 1 соответственно
test dl,dh                ;проверяем на 0, обозначение символа в таблице ASCII в двоичном формате
jz match6

mov dh,'7'        ;номер в регистре обычно обозначает номер символа в ASCII
not dh   ;инвертирует значение, т.е. меняет 1 и 0 наоборот, т.е. на 0 и 1 соответственно
test dl,dh                ;проверяем на 0, обозначение символа в таблице ASCII в двоичном формате
jz match7

mov dh,'8'        ;номер в регистре обычно обозначает номер символа в ASCII
not dh   ;инвертирует значение, т.е. меняет 1 и 0 наоборот, т.е. на 0 и 1 соответственно
test dl,dh                ;проверяем на 0, обозначение символа в таблице ASCII в двоичном формате
jz match8

mov dh,'9'        ;номер в регистре обычно обозначает номер символа в ASCII
not dh   ;инвертирует значение, т.е. меняет 1 и 0 наоборот, т.е. на 0 и 1 соответственно
test dl,dh                ;проверяем на 0, обозначение символа в таблице ASCII в двоичном формате
jz match9




;or si,1 - это не срабатывает никогда
match0:    ;это срабатывает при любых условиях, т.е. символ 0 всегда есть в dl,byte[ebx] или dh
          ;если в памяти остаются свободные ячейки они автоматически заполняются символом '0'
          ;поэтому этот символ программа находит в памяти!!!
;or ax,0000000000000001b
or si,1
jmp again3

match1:
;or ax,0000000000000010b
or si,2
jmp again3

match2:
;or ax,0000000000000100b
or si,4
jmp again3

match3:
;or ax,0000000000001000b
or si,8
jmp again3

match4:
;or ax,0000000000010000b
or si,16
jmp again3

match5:
;or ax,0000000000100000b
or si,32
jmp again3

match6:
;or ax,0000000001000000b
or si,64
jmp again3

match7:
;or ax,0000000001000000b
or si,128
jmp again3

match8:
;or ax,0000000100000000b
or si,256
jmp again3

match9:
;or ax,0000001000000000b
or si,512 ;512 - не работает Floating point exception (core dumped) 511- работает,а 512 уже нет

                                                ;510 и 511 = 0000000111111111
                        ;возможно проблема с делением
                        ;результат помещается в ah и al - по 8 байтов
                        ;макс.значение каждого до 255 или 11111111
                        ;и если 512/2 получится 256, а оно не помещается в регистр al
jmp again3


again3:
inc ebx            ;увеличить номер ячейки
;если loop toshift не срабатывает из-за длинного кода
;можно использовать следующий код:
dec ecx
jnz toshift


mov edi,byteout     ;указать адрес первого элемента
add edi,lbyteout-1   ;увеличить номер ячейки памяти на lbyteout-1
;номера памяти 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15
;первый номер 0+16-1=15

;всегда в бите №0 выходит значение 1
;и по умолчанию и по указанию
;причина- не все ячейки памяти заполнены значениями
;и если в памяти остается хоть одна пустая ячейка, то в нее автоматически помещается символ '0'
;на который и срабатывает программа

;в памяти надо разместить 16 цифр 0 и 1,
mov ecx,16    ;счетчик

;если делимое не больше 65.535, а результат деления или остаток не больше 255, то используется
;алгоритм деления: ax(делимое 16 бит)/любой 8-битный регистр=al(целое 8 бит) и ah(остаток 8 бит)

;если же делимое не больше 4.294.967.295  , а результат деления или остаток не больше 65.536, то используется
;dx и ax(2 регистра по 16 бит = делимое 32 бит)/ любой 16-битный регистр=ax(целое 16 бит) и dx(остаток 16 бит)
;где dx - старшая часть, а ax - младшая часть делимого
;получить какое число поместить в dx, а какое в ax можно по формуле:
;делимое перевести в 16-ричную форму и 2 младших байта в ax, а 2 старших байта в dx,
;например число 65536 (10-я форма) это 10000 (16-я форма), где
;4 младших знака 0000 помещаются - в ax, а старший знак 1 - в dx

;работающий код для деления 2 байтного числа на 1 байтное с результатом 1 байт
;mov ax,si               ;перенос значения из si в ax, т.к. в ax может добавляться ответ от какой-либо функции
;mov bl,2                ;делитель для степени 2
;metka1:
;div bl
                         ;div делит значение из ax на bl
                         ;целый результат - al
                         ;остаток - ah
;mov byte[edi],ah        ;ввод остатка
;add byte[edi],'0'       ;чтобы вывести число из регистра, его надо перевести в символ путем добавления '0'
                         ;так как №0 в таблице=48 и в итоге получается, что число, например 2 складываем
                         ;с 48 и получаем 50, т.е. № числа 2 в таблице и поэтому оно выводится на экран!
;movzx ax,al             ;перенос целого в ax
;dec edi                 ;уменьшить номер ячейки памяти
;loop metka1             ;повторение цикла 16 раз и вывод только остатка






;работающий код для деления 4 байтного числа на 2 байтное с результатом 2 байта
movzx edx,si             ;перенос значения из si в edx с расширением нулями до большего размера

  ;разделить число по частям в регистры ax и dx для операции деления
  ;dx и ax(16 + 16 бит = делимое 32 бит)/ любой 16-битный регистр=ax(целое 16 бит) и dx(остаток 16 бит)
mov ax,dx                ;младшую часть перенести в регистр ax
shr edx, 16             ;сдвинуть значение регистра вправо на 2 байта или 16 символов/битов
mov bx,2                ;делитель для степени 2
metka2:
div bx
mov byte[edi],dl        ;ввод остатка
add byte[edi],'0'       ;чтобы вывести число из регистра, его надо перевести в символ путем добавления '0'
dec edi                 ;уменьшить номер ячейки памяти
                       ;уменьшить номер ячейки памяти
;xor dx,dx               ;обнулить регистр dx
;mov ax,dx               ;перенос остатка в целое значение для деления
loop metka2             ;повторение цикла 16 раз и вывод только остатка

;вывод битов
mov ecx, byteout
mov edx, lbyteout
call PRINT

;переход на новую строку
mov ecx,n
mov edx,ln
call PRINT


                                             ;6 выход из программы

mov eax, 1          ;содержимое помещается в регистр в EAX помещается 1 - номер системного вызова "exit"
mov ebx, 0          ;содержимое помещается в регистр в EBX помещается 0 - параметр вызова "exit" означает код с которым завершится выполнение программы
int 0x80            ;системный вызов. После системного вызова "exit" выполнение программы завершается