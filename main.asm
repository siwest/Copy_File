
TITLE MASM Template (main.asm)
INCLUDE Irvine32.inc

; Writes an assembly language program to open a "main.asm" file and read the contents of the file and write to another file named foo.asm.
INCLUDE macros.inc
BUFFER_SIZE = 5000


.data
WriteToFile_1 DWORD ?
ReadFromFile_1 DWORD ?
buffer BYTE BUFFER_SIZE DUP(?)
bufSize = ($-buffer)
filename1 BYTE "main.asm",0
filename2 BYTE "foo.asm",0

bytesWritten DWORD ?
stringLength DWORD LENGTHOF buffer

fileHandle1   HANDLE ?
fileHandle2   HANDLE ?

text1 BYTE "Copying contents of ",0
text2 BYTE " to ",0

cannotOpenFile BYTE "Cannot open file",0
bufferTooSmall BYTE "Error: Buffer too small for the file",0
errorReading BYTE "Error reading file",0
fileSize BYTE "Number characters to copy: ",0
bufferString BYTE "File contents: ",0
copyComplete BYTE "Copy complete. Bytes written: ",0


.code
	main PROC

		mov edx, OFFSET filename1
		mov ecx, SIZEOF filename1
		mov eax, DWORD PTR filename1
;		mov bufSize,eax					;save length in bufSize
		mov edx, OFFSET text1				;writing message to console...
		call WriteString
		mov edx, OFFSET filename1
		call WriteString	
		mov edx, OFFSET text2
		call WriteString	
		mov edx, OFFSET filename2
		call WriteString			
		call crlf	
		 
		mov edx,OFFSET filename1				;open the file for input.
		call OpenInputFile
		mov fileHandle1, eax

		cmp eax, INVALID_HANDLE_VALUE			;check for IO errors
		jne file_ok 
		mov edx, OFFSET cannotOpenFile
		call WriteString
		jmp quit

		file_ok:							;if no errors in IO, check buffer size 
		mov edx,OFFSET buffer 
		mov ecx,bufSize 
		call ReadFromFile
		jnc check_buffer_size 
		mov edx, 0
		mov edx, OFFSET errorReading
		call WriteString
		jmp close_file

		close_file:						;close file
		mov eax,fileHandle1 
		call CloseFile

		check_buffer_size:					;check for sufficient size buffer to hold contents of file
		cmp eax, bufSize
		jb buf_size_ok
		mov edx, 0
		mov edx, OFFSET bufferTooSmall
		call WriteString
		jmp quit

		quit: exit

		buf_size_ok:						;if buffer size ok, print file size
		mov buffer[eax],0 
		mov edx, OFFSET fileSize
		call WriteString
		call WriteDec
		call Crlf

		mov edx, 0						;copy content to buffer
		mov edx, OFFSET bufferString
		call WriteString
		call crlf	
		call crlf	
		call crlf	

		mov edx, OFFSET buffer				;display buffer
		call WriteString
		call Crlf
	
		mov edx, OFFSET filename2			;creates new file "foo.asm"
		call CreateOutputFile 
		mov fileHandle2,eax

		mov eax, fileHandle2				;write the buffer to the output file.
		mov edx, OFFSET buffer
		mov ecx, SIZEOF buffer
		
		call WriteToFile
		mov bytesWritten,eax 
		mov eax, fileHandle2
		call CloseFile

		call crlf
		call crlf
		call crlf
		call crlf
		mov edx, OFFSET copyComplete
		call WriteString	
		mov eax, bytesWritten
		call WriteInt

		exit								;Halt program
	main ENDP								;End procedure

END main									;End program
