SYS_WRITE equ 1 ;for OSX 64bit Intel machines 0x2000004
STD_OUT equ 1

%macro s_exit 0
	mov rax, 60
	mov rdi, 0
	syscall
%endmacro

%macro simpleWrite 0
	mov rax, SYS_WRITE
	mov rdi, STD_OUT
	mov rsi, rcx ; the address of string the output, in this case it is 0x005 and it contains value of |00000000|
	mov rdx, 1 ; number of bytes to be printed
	syscall ; write it in to screen
%endmacro

section .bss
	digitSpace resb 100 ; it is a comparator against to rcx.
	digitSpacePos resb 8 ; it is pointer to rcx. It will hold the address of rcx.

section .data
	text db "Hello, World!",10,0

section .text
	global _start

_start:
	mov rax, 999999999999999977 ; mov 123 to rax, it is the value that will be printed on the screen
	call _printRAX
	s_exit

; we passed the value of 123 to RAX as a function paramter
; ** NOT: in division, reminder will be stored inside RDX register **
_printRAX:
	mov rcx, digitSpace ; mov starting address of digitSpace to rcx. Lets say it is 0x001 (the address block).
	mov rbx, 10 ; set 10 aka'new line in ASCII' to rbx
	mov [rcx], rbx ; set 10 to rcx. so now |0x001| -> 00001010
	inc rcx ; incrementing the rcx means |0x002|, and it points actually zero
	mov [digitSpacePos], rcx ; mov 0x002 address to the digitSpacePos. Lets say its address is |0x010|, and now contains |0x002|

_printRAXLoop: ; loop to store values inside RAM.
	mov rdx, 0 ; set 0 to rdx
	mov rbx, 10 ; we are using the rbx as a divider, so first math is 123 / 10
	div rbx ; when we divide 123 / 10 = 12 now outcome will be stored inside RAX again, now RAX contains 12, also remined is stored inside RDX = 3
	push rax ; now we pushed 12 into to stack. Lets say the address is |0x020| -> |12|
	add rdx, 48 ; 48 is equal to 0 in ASCII table. adding 48(0), to the reminder makes it 51(3) which equals to 3 in ASCII table.

	mov rcx, [digitSpacePos] ; now rcx contains 0x002 which is address of rcx + 1
	mov [rcx], dl ; mov 51(3) to the location of rcx to pointing. Now |0x002| -> |3|
	inc rcx ; meaning is rcx + 1, which makes it |0x003|;
	mov [digitSpacePos], rcx ; move 0x003 (which is an address), to the digitSpacePos as a value. Now RAM is looks like this |0x010| -> |0x003|
	
	pop rax ; we are popping the the value of 12 from the address of 0x020. now rax contains 12 and the address of 0x020 -> 0
	cmp rax, 0 ; compairing 12 to 0, and...
	jne _printRAXLoop ; it is not equal to zero, so run _printRAXLoop again.

_printRAXLoop2: ; loop to print values to the screen
	; now RAM looks like this: 0x001=10 & 0x002=3 & 0x003=2 & 0x004=1
	mov rcx, [digitSpacePos] ; now we moved the value of |0x005| which is an address in |0x010|. So digitSpacePos is a pointer in our program, because we used as an address holder

	simpleWrite ; it is a macro, check out macros.

	mov rcx, [digitSpacePos] ; move the value of |0x005| to the rcx. 
	dec rcx ; decrement 0x005 - 1 = 0x004
	mov [digitSpacePos], rcx ; store it back to the digitSpacePos. Now it looks like |0x002| -> |0x004|

	cmp rcx, digitSpace ; compare 0x004 with 800 zero bits
	jge _printRAXLoop2 ; if rcx greater or equal to 0, then loop it back again
	; at the and, in the address of |0x000| we have ASCII 10. So end of the loop it will make a new line.
	ret


; value we want to print 123
; RAM
; ADDRESS      VALUE
; |0x001| -> |   10   | rcx
; |0x002| -> |    3   | rcx
; |0x003| -> |    2   | rcx
; |0x004| -> |    1   | rcx
; |0x005| -> |00000000|
; |0x006| -> |00000000|
; |0x007| -> |00000000|
; |0x008| -> |00000000|
; |0x009| -> |00000000|
; |0x00a| -> |00000000|
; |0x00b| -> |00000000|
; |0x00c| -> |00000000|
; |0x00d| -> |00000000|
; |0x00e| -> |00000000|
; |0x00f| -> |00000000|
; |0x010| -> | 0x002 | (next) |0x003| (next) |0x004| (next) |0x005| (next) |0x004| (next) |0x003| (next) |0x002| (next) |0x001| (next) |0x000| digitSpacePos
; |0x011| -> |00000000|
; |0x012| -> |00000000|
; |0x013| -> |00000000|
; |0x014| -> |00000000|
; |0x015| -> |00000000|
; |0x016| -> |00000000|
; |0x017| -> |00000000|
; |0x018| -> |00000000|
; |0x019| -> |00000000|
; |0x01a| -> |00000000|
; |0x01b| -> |00000000|
; |0x01c| -> |00000000|
; |0x01d| -> |00000000|
; |0x01e| -> |00000000|
; |0x01f| -> |00000000|
; |0x020| -> |   12   | (next) |1| (next) |0| rax
; |0x021| -> |00000000|
; |0x022| -> |00000000|
; |0x023| -> |00000000|
; |0x024| -> |00000000|
; |0x025| -> |00000000|
; |0x026| -> |00000000|
; |0x027| -> |00000000|



