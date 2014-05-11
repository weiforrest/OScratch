;;; string.asm   (c) weiforrest
[SECTION .text]

;;; void* memcpy(void* dest, void* src, int isize);
global memcpy

memcpy:
		push ebp
		mov ebp, esp

		push edi
		push esi
		push ecx

		mov ecx, [ebp + 16]
		mov esi, [ebp + 12]
		mov edi, [ebp + 8]
		cmp ecx, 0
		jz	.memcpydone
		cld
		rep movsb

.memcpydone:
		mov eax, [ebp + 8]
		pop ecx
		pop esi
		pop edi
		pop ebp
		ret
		
;;; void* memset(void *dest, u8, u32 size);
global memset

memset:
		push ebp
		mov ebp,esp
		
		push edi
		push ecx
		mov ecx, [ebp + 16]
		mov eax, [ebp + 12]
		mov edi, [ebp + 8]
		cmp ecx, 0
		jz .memsetdone
		cld
		rep stosb
.memsetdone:
		mov eax, [ebp + 8]
		pop ecx
		pop edi
		pop ebp
		ret
