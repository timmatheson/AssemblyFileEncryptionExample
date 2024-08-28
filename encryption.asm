section .data
    outputFile db 'output.enc', 0
    key db 0xAA ; Simple XOR key

section .bss
    buffer resb 256   ; Buffer to hold file content
    filename resb 256 ; Buffer to hold filename

section .text
    extern fopen, fread, fwrite, fclose
    global _start

_start:
    ; Read the filename from command line arguments
    ; Arguments are passed on the stack.
    mov eax, [esp + 4] ; First argument (filename)
    mov [filename], eax ; Store filename in buffer

    ; Open the input file
    push outputFile
    push eax
    call fopen
    add esp, 8
    mov ebx, eax ; Save file handle to ebx

    ; Read from the input file
    push 256
    push buffer
    push 1
    push ebx
    call fread
    add esp, 16

    ; Encrypt/Decrypt using XOR
    mov ecx, eax ; Number of bytes read
    xor_loop:
        test ecx, ecx
        jz write_file ; If no bytes left, go to write file
        dec ecx
        mov al, [buffer + ecx]
        xor al, [key]
        mov [buffer + ecx], al
        jmp xor_loop

    ; Close input file
    push ebx
    call fclose
    add esp, 4

    ; Open the output file
    push outputFile
    push 0 ; No mode means create or overwrite
    call fopen
    add esp, 8
    mov ebx, eax ; Save output file handle to ebx

    ; Write to the output file
    push 256
    push buffer
    push 1
    push ebx
    call fwrite
    add esp, 16

    ; Close output file
    push ebx
    call fclose
    add esp, 4

    ; Exit program
    mov eax, 1 ; sys_exit
    xor ebx, ebx
    int 0x80
