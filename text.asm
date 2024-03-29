SECTION .data        ;для инициализированных данных

filetoopen db "exampledir",0
lfiletoopen equ $-filetoopen

newfolder db "exampledir/",0
lnewfolder equ $-newfolder

n db 0xa                   ;переменная для переноса строки


warning db "Показывает все имена файлов, но пишет Файл существует, если этот файл скопирован из главной папки и присутствует в главной папке, пишет Файл не существует, если файла нет в главной папке, и пишет Файл не существует, если он был создан в общей прапке, затем скопирован в каталог поиска, и затем удален в общей папке! Заняться этим позже! ",0xa,0;
lwarning equ $-warning

text db "Вывести имена файлов: ",0xa,0;
ltext equ $-text

er db "Файл существует!",0xa,0;
ler equ $-er

er1 db "Файл НЕ существует!",0xa,0;
ler1 equ $-er1

er2 db "До сюда работает!",0xa,0;
ler2 equ $-er2


SECTION .bss         ;для НЕинициализированных данных

input: resb 1000               ;память для структур каталога
linput equ $-input

input2: resb 60000               ;память куда помещаются данные из отраженной памяти

filename: resb 100            ;имя для каждого файла (не каталога!)
newfilename: resb 100         ; имя для каждого файла в новом каталоге
createnewfilaname: resb 100   ;память для создания новых имен файлов
filenameadress: resd 1            ;адрес первого символа имя для каждого файла (не каталога!)




nfcountinter: resb 1   ;память для счетчика символов

reserv: resb 1               ;промеж память
reserb: resb 4               ;промеж память
reserc: resb 4               ;промеж память


descofcat: resd 1         ;дескриптор каталога, resd = 4 байта

descoffile: resd 1         ;дескриптор файла, resd = 4 байта



eaxvalue: resd 1  ;промеж. величина
ebxvalue: resd 1  ;промеж. величина
ecxvalue: resd 1  ;промеж. величина
edxvalue: resd 1  ;промеж. величина
esivalue: resd 1  ;промеж. величина
edivalue: resd 1  ;промеж. величина
ebpvalue: resd 1  ;промеж. величина

amount: resd 1         ;amount - кол-во символов в файле, resd = 4 байта

adress: resd 1         ;adress - адрес,куда отражаются данные resd = 4 байта


adress1: resd 1         ;adress1 - адрес, resd = 4 байта
ladress1 equ $-adress1

SECTION .text      ;начало кода самой программы
GLOBAL _start
            ;прописать подпрограммы

;Result:      ;начало подпрограммы
;ret          ;конец подпрограммы


                       ;начало исполнения
      _start:

;вывод текста
;mov ecx,warning        ;ввод полученного адреса памяти
;mov edx,lwarning        ;ввод количества символов
;mov eax,4
;mov ebx,1
;int 80h

;текст
;mov ecx,text        ;ввод полученного адреса памяти
;mov edx,ltext        ;ввод количества символов
;mov eax,4
;mov ebx,1
;int 80h

xor eax,eax ;обнуление eax
xor ebx,ebx ;обнуление ebx
xor ecx,ecx ;обнуление ecx
xor edx,edx ;обнуление edx



;открыть директорию и получить ее дескриптор
mov eax,5                 ;open
mov ebx,filetoopen       ;имя/адрес файла, этого параметра для открытия каталога достаточно!
;mov ecx,2               ;Для директории/каталога этот аргумент не указывать или закомментировать!
int 80h
mov [descofcat],eax

;Для получения списка файлов в таком универсальном формате существует
;системный вызов getdents с номером 141:
;int getdents(unsigned int fd, struct dirent *dirp,unsigned int count);
;возвращает несколько структур в память input размером linput

mov eax,141      ;141 - 4 элемента структуры или 220 - ;системный вызов getdents
mov ebx,[descofcat]   ;unsigned int fd - файловый дескриптор этой директории, полученный, системным вызовом open
mov ecx,input    ;struct dirent *dirp - адрес буфера в памяти, куда запишется информация о содержимом
                 ;текущего каталога в виде следующих друг за другом структур
mov edx,linput   ;unsigned int count - размер буфера, в который должна быть записана информация
int 80h

mov esi,input    ;адрес начала памяти
add esi,10       ;сдвинуть адрес на ячейки памяти с именем первого файла
                 ;8 байт - метаданные по файлу, тип long int
                 ;2 байта - смещение следующей структуры = 0, тип off_t
                 ;в esi помещается адрес именно имени файла из каждой структуры

mov r8d,linput          ;присвоить регистру r8d значение счетчика, в соответствии
                        ;с объемом памяти (в байтах) всех символов для всех структур

                        ;esi - адрес начала памяти всех структур, начало с имени файла
                        ;r8d - счетчик (кол-во байтов выделенной памяти под все структуры)
                        ;bp - 2-х байтный регистр для хранеия данных типа short int / для 64 байтной ОС

;закрыть каталог
mov eax,6
mov ebx,[descofcat]    ;filedes
int 0x80
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;вывод имен файлов из структур в цикле AGAIN побайтово!!!


again:
cmp byte[esi],0     ;сравнение символов структур с 0
je next             ;если 0, т.е. символы имени кончились и вышел 0-символ, то идем на выход из цикла AGAIN

;;;;;;;;;;;;;;
;esi - адрес начала памяти всех структур, начало с имени файла
;r8d - счетчик (кол-во байтов выделенной памяти под все структуры)
;bp - 2-х байтный регистр для хранеия данных типа short int / для 64 байтной ОС



;вывод имени каждого файла


mov edi,esi         ;адрес имени файла
sub edi,2           ;уменьшить адрес на 2

mov [filenameadress],esi  ;адрес с началом именем каждого файла

mov bp,word[edi]    ;получить 2-х байтное значение из памяти - расстояние до следующего изменений
                    ;т.к. short=2 байта

;вывод имени файла, полученный из структуры
mov ecx,esi      ;ввод полученного адреса памяти с именем файла
sub bp,10        ;высчитать из размера структуры все поля кроме имени
mov edx,ebp       ;ввод количества символов имени файла
add bp,10        ;вернуть размер регистра ebp


mov [eaxvalue],eax
mov [ebxvalue],ebx
mov [ecxvalue],ecx
mov [edxvalue],edx
mov [esivalue],esi
mov [edivalue],edi
mov [ebpvalue],ebp

mov r10d,ebp ;сохраняем число из ebp
mov eax,4
mov ebx,1
int 80h

;на новую строку
mov ecx,n        ;ввод полученного адреса памяти
mov edx,1        ;ввод количества символов
mov eax,4
mov ebx,1
int 80h

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;newfolder  =  'newfolder/',0
;lnewfolder - кол-во символов в имени папки

;[filenameadress] - адрес первого символа каждого имени
;[edxvalue] ;кол-во символов в имени каждого файла

;свободная память
;filename

;поместить имя каталога в память filename
mov eax,newfolder ;адрес начала имени каталога
mov ebx,filename ;свободная память
xor ecx,ecx ;обнуляем для счетчика и символов и использования в виде ch

;вставляем в newfilename значение filename
step2:
mov ch,byte[eax]
mov byte[ebx],ch
inc eax
inc ebx
cmp ch,0
jne step2 ;если не найден 0-символ
;если найден, то добавляем имя файла
dec ebx
mov eax,[filenameadress] ;адрес первого символа каждого имени

step3:
mov ch,byte[eax]
mov byte[ebx],ch
inc eax
inc ebx
cmp ch,0
jne step3 ;если не найден 0-символ
dec ebx


;;;;;открыть существующий файл filename (каталог/имя файла)
mov eax,5                 ;open
mov ebx,filename       ;имя/адрес файла
mov ecx,2               ;0-read, 1-write, 2-read and write,100-create
int 80h

mov [descoffile],eax  ;filedes
;возвращаемое значение — неотрицательное целое число, равное дескриптору файла.
;в случае ошибки возвращается значение -1.

cmp eax,0
jl error
jge noerror
error:


mov ecx,er1        ;ввод полученного адреса памяти
mov edx,ler1       ;ввод количества символов
mov eax,4
mov ebx,1
int 80h

jmp skipall

noerror:
;кол-во символов в файле
mov eax,19       ;системный номер функции
mov ebx,[descoffile]   ;filedes
mov ecx,0        ;offset
mov edx,2        ;whence
int 80h



mov [amount],eax  ;length - длина отображаемого участка файла с начала или с символа offset (по умолчанию = 0)

mov eax,192     ;90-возможно устаревший системный вызов, № системного вызова  192 работает, а 90 - нет
mov ebx,0     ;*address - указатель/адрес участка памяти процесса, в который отображается содержимое файла, обычно 0
mov ecx,[amount]    ;length - длина отображаемого участка файла с начала или с символа offset (по умолчанию = 0)
mov edx,1|2     ;protect - защита файла, 0 - доступ запрещен, 1 - read, 2 - write, 4 - для исполнения кода
mov esi,1     ;flags - 1 или 2 передача изменений: да или нет
mov edi,[descoffile]   ;filedes - дескриптор отображаемого файла,
mov ebp,0     ;offset - от какого символа считать начало отображаемого текста
int 80h
;возвращает fffffffffffffff2 в rax
mov [adress],eax ;адрес вывода
skipall:
;вывод содержимого каждого существующего файла
 mov ecx,[adress]   ;ввод полученного адреса памяти от mmap
 mov edx,[amount]      ;ввод количества символов
 mov eax,4
 mov ebx,1
 int 80h

 ;поменять символы местами
 mov esi,input2        ;память, куда помещаются отображенные символы
 mov ecx,[amount]       ;счетчик от lseek
 mov edi,[adress]        ;адрес откуда берутся символы - от mmap
 add edi,[amount]     ;получить номер ячейки памяти последнего символа
 dec edi              ;увеличить адрес от mmap на кол-во символов

 again1:
 mov al,byte[edi]  ;из mmap
 mov byte[esi],al  ;в input3
 dec edi           ;уменьшить номер ячейки памяти в mmap
 inc esi           ;увеличить номер ячейки памяти в input3
 loop again1



 ;вывод в терминал перевернутого текста
  mov ecx,input2   ;ввод адреса памяти в который помещены символы
  xor rdx,rdx       ;обнулить весь rdx, чтобы не было ошибок
  mov edx,[amount]      ;ввод количества символов от lseek
  mov eax,4
  mov ebx,1
  int 80h

  ;замена данных, но в файле идет запись с новой строки! почему-то?
  ;это в файле автоматически вставляется перенос строки в конце текста!
  ;изменения в файле будут видны после его повторного открытия!

  ;вывести заменить текст в отображенной памяти на текст из памяти с перевернутыми символами
  mov esi,input2        ;адрес для вывода символов
  mov ecx,[amount]       ;счетчик = кол-во символов от lseek
  mov edi,[adress]        ;адрес имеющейся строки от mmap

  again2:
  mov al,byte[esi]        ; из памяти input2 взять символ
  mov byte[edi],al        ; поместить этот символ в адрес выделенной памяти
  inc edi                 ; увеличить номер символа в памяти
  inc esi                 ; увеличить номер символа в памяти
  loop again2

  ;закрыть отображение файла в память
  ;int munmap(void *start, size_t length);
  mov eax,91        ;91-возможно устаревший системный вызов, № системного вызова  192 работает, а 90 - нет
  mov ebx,[adress]  ;*address - указатель/адрес участка памяти процесса, в который отображается содержимое файла
  mov ecx,[amount]  ;length - длина отображаемого участка файла


   ;закрыть открытый файл
   mov eax,6
   mov ebx,[descoffile]    ;filedes
   int 0x80
  ;возвращаемое значение — 0; значение -1 возвращается в случае ошибки.



mov ebp,[ebpvalue]
mov esi,[filenameadress]  ;адрес с началом именем каждого файла

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;filename - адрес полного имени с каталогом
;newfilename - адрес нового полного имени с каталогом

mov ebx,filename ;поместить в ebx адрес первого символа памяти
mov ecx,newfilename ;поместить в ecx адрес первого символа памяти

;КАК добавить символ ~ №126
;dec al  ;уменьшить счетчик на 1, чтобы не считать последний символ 0 из старого имени

sub:

mov ah,byte[ebx]
mov byte[ecx],ah

cmp ah,0
je isnull


inc ecx
inc ebx
jmp sub

isnull:
;почему то последний символ в имя не добавляется((
mov byte[ecx],126    ;добавить требуемый символ ~
inc ecx              ;увеличить ячейку памяти на 1
mov byte[ecx],0      ;добавить нуль-символ в конце строки



;создаются файлы, но без расширения! Надо попробовать изменить имя, т.е. другие символы
;создание файла с добавленным знаком ~
;mov eax,8                 ;create
;mov ebx,newfilename       ;адрес имени файла
;mov ecx, 0777               ;0777 - permission - полный доступ
;int 80h

mov eax,5                 ;open
mov ebx,newfilename       ;имя/адрес файла
mov ecx,100|2               ;0-read, 1-write, 2-read and write,100-create
mov edx,0777
int 80h




mov [descoffile],eax   ;filedes

;кол-во символов в файле
mov eax,19       ;системный номер функции
mov ebx,[descoffile]   ;filedes
mov ecx,0        ;offset
mov edx,2        ;whence
int 80h


;запись в файл [descoffile]
mov eax,4
mov ebx,[descoffile]
mov ecx,input2  ;[adress]
mov edx,[amount]
int 80h

; write into the file
  ;mov	edx,len          ;number of bytes
  ;mov	ecx, msg         ;message to write
;  mov	ebx, [fd_out]    ;file descriptor
;  mov	eax,4            ;system call number (sys_write)
;  int	0x80             ;call kernel


;Что-то там создало, но знака ~ не видать. проверить весь код, может что-то где=то создается непонятно

;временно убираем вывод нового имени
;новое имя из памяти
;mov ecx,createnewfilaname        ;ввод полученного адреса памяти
;mov edx,[nfcountinter]        ;ввод количества символов
;mov eax,4
;mov ebx,1
;int 80h



;Для открытия существующего файла или создания нового используют функцию open (системный вызов номер 5). В
;синтаксисе Си она выглядит следующим образом:
;int open (const char *filename, int flags[, mode_t mode])
;Функция open создает и возвращает новый дескриптор для указанного файла. Индикатор текущей позиции
 ;при этом находится в начале файла. Функция может иметь переменный набор аргументов;
; аргумент mode используется только при создании файла и задает права доступа к нему
  ;(в стандартном для UNIX-систем числовом виде, например восьмеричным числом из трех цифр).

;на новую строку
mov ecx,n        ;ввод полученного адреса памяти
mov edx,1        ;ввод количества символов
mov eax,4
mov ebx,1
int 80h

;открыть и прочитать каждый файл
mov eax,5                 ;open
mov ebx,esi        ;адрес имени файла
mov r9d,esi        ;сохраняем адрес из esi
mov ecx,2                 ;0-read, 1-write, 2-read and write,100-create
int 80h

;получить дескриптор каждого файла
;mov [desc1],eax  ;filedes
;возвращаемое значение — неотрицательное целое число, равное дескриптору файла.
;в случае ошибки возвращается значение -1.



;;;;;;;;;;;;проверка файла на ошибку ENOENT
;ошибки open
;enoent -2
;enotdir -20
;
cmp eax,-2d
jne ok
je neok
ok:
;файл существует
;mov ecx,er        ;ввод полученного адреса памяти
;mov edx,ler        ;ввод количества символов
;mov eax,4
;mov ebx,1
;int 80h
jmp further
neok:
;файл не существует
;mov ecx,er1        ;ввод полученного адреса памяти
;mov edx,ler1        ;ввод количества символов
;mov eax,4
;mov ebx,1
;int 80h

jmp nofurther

further:




nofurther:
;типа конец подпрограммы

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mov esi,r9d ;возвращаем адрес в esi
mov ebp,r10d ;возвращаем число в ebp

add esi,ebp       ;увеличить адрес до следующего имени файла
;если число символов всех имен файлов меньше, чем кол-во выделеной памяти linput, то не выводит ничего!!!
;sub r8d,10 - это исходное значение
sub r8d,ebp  ; - это исправляем значение




;Для открытия существующего файла или создания нового используют функцию open (системный вызов номер 5).
;В синтаксисе Си она выглядит следующим образом:
;int open (const char *filename, int flags[, mode_t mode])
;Функция open создает и возвращает новый дескриптор для указанного файла. Индикатор текущей позиции
;при этом находится в начале файла. Функция может иметь переменный набор аргументов;
;аргумент mode используется только при создании файла и задает права доступа к нему (в
;стандартном для UNIX-систем числовом виде, например восьмеричным числом из трех цифр).





;FINISH вывода имен файлов из структур в цикле AGAIN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


cmp r8d,0
jge again
jl next
next:



;закрыть файл каталога
mov eax,6
mov ebx,[descofcat]    ;filedes
int 0x80
;возвращаемое значение — 0; значение -1 возвращается в случае ошибки.


;- завершить программу.+
exit:

mov eax, 1          ;содержимое помещается в регистр в EAX помещается 1 - номер системного вызова "exit"
mov ebx, 0          ;содержимое помещается в регистр в EBX помещается 0 - параметр вызова "exit" означает код с которым завершится выполнение программы
int 0x80            ;системный вызов. После системного вызова "exit" выполнение программы завершается
