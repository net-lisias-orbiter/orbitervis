  {
function cpuid_support:boolean;assembler;
asm
 push   ebx
 pushf
 pushf
 pop     eax
 mov     ebx,eax
 xor     eax,200000h
 push    eax
 popf
 pushf
 pop     eax
 popf
 and     eax,200000h
 and     ebx,200000h
 cmp     eax,ebx
 setnz   al
 pop     ebx
end;    }  
function cpuid_support:boolean;
begin
 cpuid_support:=true;
end;  

function sse_support:boolean;
var _edx:longint;
begin
 if cpuid_support then begin
  asm
   push ebx
   mov eax,1
   cpuid
   mov _edx,edx
   pop ebx          
  end;
  sse_support:=(_edx and $2000000)<>0;
 end else sse_support:=false;
end;

function mmx_support:boolean;
var _edx:longint;
begin
 if cpuid_support then begin
  asm
   push ebx
   mov eax,1
   cpuid
   mov _edx,edx
   pop ebx            
  end;
  mmx_support:=(_edx and $800000)<>0;
 end else mmx_support:=false;
end;

  
procedure filldword(var x;count : Integer;value : dword);assembler;
var saveedi:longint;
asm
        mov    saveedi,edi

        mov    edi,x
        mov    ecx,count
        mov    eax,value
        
        cmp    ecx,0
        jle    @LFillDWordEnd
        cld
        rep    stosd
@LFillDWordEnd:
        mov    edi,saveedi    
end;

//BAD
{
procedure filldwordmmx(var x;count : Integer;value : dword);assembler;
var saveedi:longint;
asm
        mov    saveedi,edi

        mov    edi,x
        mov    eax,count

        xor    esi,esi
        
  movd    mm0,esi
  movd    mm1,esi
  movd    mm2,esi
  movd    mm3,esi
  movd    mm4,esi
  movd    mm5,esi
  movd    mm6,esi
  movd    mm7,esi
  
@MMXcopyloop:
  movq    [edi   ],mm0
  movq    [edi+ 8],mm1
  movq    [edi+16],mm2
  movq    [edi+24],mm3
  movq    [edi+32],mm4
  movq    [edi+40],mm5
  movq    [edi+48],mm6
  movq    [edi+56],mm7
  add     edi,64
  dec     eax
  jnz     @MMXcopyloop

  emms

  
@LFillDWordEnd:
        mov    edi,saveedi
        
end;
}
