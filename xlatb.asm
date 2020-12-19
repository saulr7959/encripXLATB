include emu8086.inc ;biblioteca de definiciones de macros para facilitar la entrada / salida

;macro para imprimir en pantalla - La macro debe llamarse "imprimir".

imprimir macro texto
    mov ah, 9
    mov dx, offset texto
    int 21h
endm


leer macro texto
        mov ah, 1
        xor si, si
        
        capturar2:
        int 21h
        cmp al, 13
        jz descifrar
        mov txtEncri[si], al
        inc si
        jmp capturar2 
endm  

;fin de macros 

jmp creacionC ;Salto a crear el directorio

;Definicion de variables para capturar texto 

txtEncri db 120 dup('$') ;variable para guardar el texto que sera cifrado
  
msg0 db 'Ingrese una cadena de texto: $' 

;agregar variables titulo, alumno, carnet, salto, 
alumno db ' $' 
carnet db ' $'  
salto db 10,13,'$'   
titulo db 'Programa: Encriptacion usando XLATB  $'

;Mensajes de cifrado
mensaje2 db 10,13,'Mensaje Descifrado: $'
mensaje3 db 10,13,'Mensaje Cifrado: $'

;comienza el programa ;capturar valores
inicio: 
imprimir archivoCreado 
imprimir salto

 
    ;Datos del progrma
    imprimir titulo   ;*
    imprimir salto    ;*                      
    imprimir salto    ;*
    imprimir alumno   ;*
    imprimir salto    ;*
    imprimir carnet   ;*
    imprimir salto    ;*
    ;*******************
   
     
    ;limpiar el registro "si", poner a cero
    xor si, si  
    imprimir salto 
    imprimir msg0   
    mov ah,1  
    ;catura de texto
    
    capturar: 
    int 21h 
    ;codigo para comprobar si es enter 
    cmp al, 13 
    jz start 
    mov txtEncri[si],al
    inc si  ;
    inc contador
    jmp capturar
     
    
jmp start
;                        la cadena tiene '$' al final:


;                       'abcdefghijklmnopqrstvuwxyz'

tabla1 db 97 dup (' '), 'klmnxyzabcopqrstvuwdefghij'

tabla2 db 97 dup (' '), 'hijtuvwxyzabcdklmnoprqsefg' 

                        


start:
; cifrar:
lea bx, tabla1
lea si, txtEncri
call parse

;Escribir en el archivo
mov ah, 40h
mov bx, handler
mov cx, contador
mov dx, offset txtEncri
int 21h
;si hay error en la escritura, CF = 1
jc error2

;cerrar archivo
mov ah, 3eh
mov bx, handler
int 21h 
imprimir salto
imprimir salto
imprimir archivoEditado


;Mostrar resultado:
    mov ah, 3dh 
    mov al, 0   ;indicar que abrimos en modo lectura 
    mov dx, offset archivoLec 
    int 21h 
    ;si el archivo no existe cf=1 
    jc error3 
    mov handler, ax

leer: 
    mov ah, 3fh 
    mov bx, handler ; movemos puntero 
    mov dx, offset fragmento ;preparamos variable para capturar caracteres 
    mov cx, contador      ;cantidad de caracteres a leer 
    int 21h 
    ;si no se puede leer el archivo cf=1 
    jc error4 
    cmp ax, 0 ; si ax = 0 significa EOF 
    jz salir1
    
    imprimir salto
    imprimir salto
    imprimir mensaje3 
    imprimir fragmento
    imprimir salto
    ;jmp descifrar ;descomentar si quieres que lo haga automatico
    imprimir cadena2 
    leer txtEncri ;uso macro leer 
    jmp descifrar 

descifrar:
; descifra:
lea bx, tabla2
lea si, txtEncri
call parse

; mostrar resultado:
imprimir salto
imprimir mensaje2


lea dx, txtEncri
; salida de una cadena en ds: dx
mov ah, 09
int 21h
jmp salir1

;si hay error en la creacion, CF=1

error1:
 imprimir msgError1  
        jmp salir1
error2:
 imprimir msgError2
        jmp salir1
error3: 
 imprimir msgError3 
        jmp salir1 
 
error4: 
 imprimir msgError4 
        jmp salir1
 
 ;fin del programa     
   
salir1:
ret

;**************BLOQUE PARA ENCRIPTAR CADENA***********
 
; subrutina para cifrar / descifrar
; parámetros:
; si - direccion de la cadena para cifrar
; bx - tabla para usar.
; Un procedimiento o sub rutina, es un sub programa que ejecuta un proceso específico
parse proc near
    
siguiente_caracter:
	cmp [si], '$'      ; fin del string?
	je fin_del_string
	mov al, [si]
	cmp al, 'a'
	jb  skip
	cmp al, 'z'
	ja  skip	
; algoritmo xlat: al = ds: [bx + unsigned al]
	xlatb     ; cifrar usando table2  
	mov [si], al
skip:
	inc si	
	jmp siguiente_caracter

fin_del_string:
ret
  
parse endp
;************** FIN BLOQUE PARA ENCRIPTAR CADENA***********


;**********BLOQUE PARA CREAR DIRECTORIO***************************

creacionC:

;crear directorio
mov ah, 39h
mov dx, offset directorio
int 21h

;crear archivo
mov ah, 3Ch
mov cx, 0
mov dx, offset archivo
int 21h

;si hay error en la creacion, CF=1
jc error1
mov handler, ax

jmp inicio ; Despues de haber creado Comienza a mostrar texto en pantalla

;variables para escribir
archivoCreado db '¡¡¡ Carpeta y archivo creado con exito !!! $'
directorio db 'E:\test',0
archivo db 'E:\test\prueba.txt',0
 
contador dw 0

msgError1 db 'Error: No se puede crear archivo',10,13,'$'   
msgError2 db 'Error: No se puede escribir en el archivo',10,13,'$'
archivoEditado db 'Cadena guardada con exito!!! $'
handler dw ? 
;**********FIN BLOQUE PARA CREAR DIRECTORIO*************************** 




;**********BLOQUE PARA LEER ARCHIVO ***************************
 
;Variables para leer
archivoLec db 'E:\test\prueba.txt',0 
msgError3 db 10,13,'Error: No se puede abrir el archivo. $' 
msgError4 db 10,13,'Error: No se puede leer el archivo. $'
fragmento db 120 dup('$') 
limpiar db 120 dup('$')

cadena1 db 120 dup('$')
cadena2 db 10,13,'Escriba texto a descifrar: $'  

;**********FIN BLOQUE PARA LEER ARCHIVO *************************** 

end
