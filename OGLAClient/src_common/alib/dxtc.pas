//############################################################################//
// Made in 2003-2010 by Artyom Litvinovich
// AlgorLib: DXTC encoder/decoder
//############################################################################//
unit dxtc;
interface
uses asys,grph;  
//############################################################################//
procedure DecodeDXT1toBitmap32(enc,dec:pbytea;w,h:dword;var trans:boolean);
procedure DecodeDXT3toBitmap32(enc,dec:pbytea;w,h:dword);
procedure DecodeDXT5toBitmap32(enc,dec:pbytea;w,h:dword);
                
procedure encodebitmap32toDXT1(src,enc:pbytea;w,h:integer);      
procedure encodebitmap32toDXT3(src,enc:pbytea;w,h:integer); 
procedure encodebitmap32toDXT5(src,enc:pbytea;w,h:integer);     
//############################################################################//
implementation  
//############################################################################//
function  ecol565(r,g,b:byte):word;begin result:=(r shr 3)+(g shr 2) shl 5+(b shr 3)shl 11;end;
//############################################################################//
//############################################################################//
procedure DecodeDXT1toBitmap32(enc,dec:pbytea;w,h:dword;var trans:boolean);
var x,y,i,j,k,wyx:dword;
col0,col1:word;
colors:array[0..3]of array[0..3]of Byte;
bitmask:dword;
temp:pByte;
r0,g0,b0,r1,g1,b1:byte;
begin
 trans:=false;
 if(enc=nil)or(dec=nil)then exit;
 colors[0][3]:=$FF;colors[1][3]:=$FF;colors[2][3]:=$FF;colors[3][3]:=$FF;

 temp:=pbyte(enc);
 for y:=0 to(h div 4)-1 do for x:=0 to(w div 4)-1 do begin
  col0:=pword(temp)^;inc(temp,2);
  col1:=pword(temp)^;inc(temp,2);
  bitmask:=pdword(temp)^;inc(temp,4);
                                  
  b0:=col0 and $1F;g0:=(col0 shr 5)and $3F;r0:=(col0 shr 11)and $1F;
  b1:=col1 and $1F;g1:=(col1 shr 5)and $3F;r1:=(col1 shr 11)and $1F;
  
  colors[0][0]:=r0 shl 3;
  colors[0][1]:=g0 shl 2;
  colors[0][2]:=b0 shl 3;
  colors[1][0]:=r1 shl 3;
  colors[1][1]:=g1 shl 2;
  colors[1][2]:=b1 shl 3;

  if col0>col1 then begin
   colors[2][0]:=(2*colors[0][0]+colors[1][0]+1) div 3;
   colors[2][1]:=(2*colors[0][1]+colors[1][1]+1) div 3;
   colors[2][2]:=(2*colors[0][2]+colors[1][2]+1) div 3;
   colors[3][0]:=(colors[0][0]+2*colors[1][0]+1) div 3;
   colors[3][1]:=(colors[0][1]+2*colors[1][1]+1) div 3;
   colors[3][2]:=(colors[0][2]+2*colors[1][2]+1) div 3;
  end else begin
   trans:=True;
   colors[2][0]:=(colors[0][0]+colors[1][0]) div 2;
   colors[2][1]:=(colors[0][1]+colors[1][1]) div 2;
   colors[2][2]:=(colors[0][2]+colors[1][2]) div 2;
   colors[3][0]:=(colors[0][0]+2*colors[1][0]+1) div 3;
   colors[3][1]:=(colors[0][1]+2*colors[1][1]+1) div 3;
   colors[3][2]:=(colors[0][2]+2*colors[1][2]+1) div 3;
  end;

  k:=0; 
  for j:=0 to 3 do begin
   wyx:=16*w*y+16*x+4*j*w;
   for i:=0 to 3 do begin
    pdword(@dec[wyx+4*i])^:=dword(colors[(bitmask shr k)and 3]);
    inc(k,2);
   end;
  end;

 end;
end;
//############################################################################//
//############################################################################//
procedure DecodeDXT3toBitmap32(enc,dec:pbytea;w,h:dword);
var x,y,i,j,k,wyx:dword;
col0,col1,wrd:word;
colors:array[0..3]of array[0..3]of byte;
bitmask,offset:dword;
temp:pbyte;
r0,g0,b0,r1,g1,b1:byte;
alpha:array[0..3] of word;
begin
 if(enc=nil)or(dec=nil)then exit;
 temp:=pbyte(enc);  
 colors[0][3]:=$FF;colors[1][3]:=$FF;colors[2][3]:=$FF;colors[3][3]:=$FF;
 
 for y:=0 to (h div 4)-1 do for x:=0 to (w div 4)-1 do begin
  alpha[0]:=pword(temp)^;inc(temp,2);alpha[1]:=pword(temp)^;inc(temp,2);alpha[2]:=pword(temp)^;inc(temp,2);alpha[3]:=pword(temp)^;inc(temp,2);
  col0:=pword(temp)^;inc(temp,2);col1:=pword(temp)^;inc(temp,2);
  bitmask:=pdword(temp)^;inc(temp,4);

  b0:=col0 and $1F;g0:=(col0 shr 5)and $3F;r0:=(col0 shr 11)and $1F;
  b1:=col1 and $1F;g1:=(col1 shr 5)and $3F;r1:=(col1 shr 11)and $1F;

  colors[0][0]:=r0 shl 3;
  colors[0][1]:=g0 shl 2;
  colors[0][2]:=b0 shl 3;
  colors[1][0]:=r1 shl 3;
  colors[1][1]:=g1 shl 2;
  colors[1][2]:=b1 shl 3;
  colors[2][0]:=(2*colors[0][0]+colors[1][0]+1) div 3;
  colors[2][1]:=(2*colors[0][1]+colors[1][1]+1) div 3;
  colors[2][2]:=(2*colors[0][2]+colors[1][2]+1) div 3;
  colors[3][0]:=(colors[0][0]+2*colors[1][0]+1) div 3;
  colors[3][1]:=(colors[0][1]+2*colors[1][1]+1) div 3;
  colors[3][2]:=(colors[0][2]+2*colors[1][2]+1) div 3;

  k:=0;
  for j:=0 to 3 do begin
   wyx:=16*w*y+16*x+4*j*w;
   for i:=0 to 3 do begin
    pdword(@dec[wyx+4*i])^:=dword(colors[(bitmask shr k)and 3]);
    inc(k,2);
   end;
  end;
      
  for j:=0 to 3 do begin
   wrd:=alpha[j];  
   wyx:=16*w*y+16*x+4*j*w;
   for i:=0 to 3 do begin
    offset:=wyx+4*i+3;
    dec[offset]:=wrd and $0F;
    dec[offset]:=dec[offset] or (dec[offset] shl 4);
    wrd:=wrd shr 4;
   end;
  end;
  
 end;
end;
//############################################################################//
//############################################################################//
procedure decodeDXT5tobitmap32(enc,dec:pbytea;w,h:dword);
var x,y,i,j,k,wyx:dword;
col0,col1:word;
colors:array[0..3] of array[0..3] of byte;
bits,bitmask:dword;
temp,alphamask:pbyte;
r0,g0,b0,r1,g1,b1:byte;
alphas:array[0..7] of byte;
begin try
 if(enc=nil)or(dec=nil)then exit;
 temp:=pbyte(enc);  
 colors[0][3]:=$FF;colors[1][3]:=$FF;colors[2][3]:=$FF;colors[3][3]:=$FF;
   
 for y:=0 to(h div 4)-1 do for x:=0 to(w div 4)-1 do begin
  alphas[0]:=temp^; inc(temp);
  alphas[1]:=temp^; inc(temp);
  alphamask:=temp; inc(temp,6);
  col0:=pword(temp)^; inc(temp,2);
  col1:=pword(temp)^; inc(temp,2);
  bitmask:=pdword(temp)^; inc(temp,4);

  b0:=col0 and $1F;g0:=(col0 shr 5)and $3F;r0:=(col0 shr 11)and $1F;
  b1:=col1 and $1F;g1:=(col1 shr 5)and $3F;r1:=(col1 shr 11)and $1F;
   
  colors[0][0]:=r0 shl 3;
  colors[0][1]:=g0 shl 2;
  colors[0][2]:=b0 shl 3;
  colors[1][0]:=r1 shl 3;
  colors[1][1]:=g1 shl 2;
  colors[1][2]:=b1 shl 3;
  colors[2][0]:=(2*colors[0][0]+colors[1][0]+1)div 3;
  colors[2][1]:=(2*colors[0][1]+colors[1][1]+1)div 3;
  colors[2][2]:=(2*colors[0][2]+colors[1][2]+1)div 3;
  colors[3][0]:=(colors[0][0]+2*colors[1][0]+1)div 3;
  colors[3][1]:=(colors[0][1]+2*colors[1][1]+1)div 3;
  colors[3][2]:=(colors[0][2]+2*colors[1][2]+1)div 3;  
   
  k:=0;
  for j:=0 to 3 do begin
   wyx:=16*w*y+16*x+4*j*w;
   for i:=0 to 3 do begin
    pdword(@dec[wyx+4*i])^:=dword(colors[(bitmask shr k)and 3]);
    inc(k,2);
   end;
  end;
   
  if(alphas[0]>alphas[1]) then begin
   alphas[2]:=(6*alphas[0]+1*alphas[1]+3) div 7;
   alphas[3]:=(5*alphas[0]+2*alphas[1]+3) div 7;
   alphas[4]:=(4*alphas[0]+3*alphas[1]+3) div 7;
   alphas[5]:=(3*alphas[0]+4*alphas[1]+3) div 7;
   alphas[6]:=(2*alphas[0]+5*alphas[1]+3) div 7;
   alphas[7]:=(1*alphas[0]+6*alphas[1]+3) div 7;
  end else begin
   alphas[2]:=(4*alphas[0]+1*alphas[1]+2) div 5;
   alphas[3]:=(3*alphas[0]+2*alphas[1]+2) div 5;
   alphas[4]:=(2*alphas[0]+3*alphas[1]+2) div 5;
   alphas[5]:=(1*alphas[0]+4*alphas[1]+2) div 5;
   alphas[6]:=0;
   alphas[7]:=$FF;
  end;

  bits:=pdword(alphamask)^;
  for j:=0 to 1 do begin  
   wyx:=16*w*y+16*x+4*j*w;
   for i:=0 to 3 do begin
    dec[wyx+4*i+3]:=alphas[bits and 7];
    bits:=bits shr 3;
   end;
  end;

  inc(alphamask,3);
  bits:=pdword(alphamask)^;
  for j:=2 to 3 do begin 
   wyx:=16*w*y+16*x+4*j*w;
   for i:=0 to 3 do begin
    dec[wyx+4*i+3]:=alphas[bits and 7];
    bits:=bits shr 3;
   end;
  end;
   
 end;

 except exit; end;
end;    
//############################################################################//
//############################################################################//
procedure encodebitmap32toDXT1(src,enc:pbytea;w,h:integer);
var col0,col1,cw:word;  
bitmask:dword;   
//alpha:array[0..3] of word;  
cl:array[0..3]of crgba;
temp:pbyte;

x,y,i,j,k,n:integer;
ma,mi,l:integer;
//wrd:pword;
c1,c2,c:crgba;
tr:boolean;

function coldst(c1,c2:crgba):integer;
begin
 result:=sqr(c1[0]-c2[0])+sqr(c1[1]-c2[1])+sqr(c1[2]-c2[2])+sqr(c1[3]-c2[3]);
end;

begin
 fillchar(enc^,w*h div 2,0);  
 temp:=pbyte(enc);  
 for y:=0 to (h div 4)-1 do for x:=0 to (w div 4)-1 do begin
  tr:=false;
  c1:=pcrgba(@src[((4*y+3)*w+(4*x+3))*4])^;  
  c2:=pcrgba(@src[((4*y+0)*w+(4*x+0))*4])^; 
  mi:=maxint;ma:=0;
  for j:=0 to 3 do for i:=0 to 3 do if((4*x+i)<w)and((4*y+j)<h)then begin      
   c:=pcrgba(@src[((4*y+j)*w+(4*x+i))*4])^; 
   l:=ecol565(c[2],c[1],c[0]);
   if l>ma then begin c1:=c; ma:=l;end;
   if l<mi then begin c2:=c; mi:=l;end; 
   if c[3]=0 then tr:=true; 
  end;  
  col0:=ecol565(c1[2],c1[1],c1[0]);
  col1:=ecol565(c2[2],c2[1],c2[0]);    

  if tr then begin
   c:=c1;c1:=c2;c2:=c;
   cw:=col0;col0:=col1;col1:=cw;
  end;

  cl[0][0]:=c1[0];cl[0][1]:=c1[1];cl[0][2]:=c1[2];cl[0][3]:=$FF;
  cl[1][0]:=c2[0];cl[1][1]:=c2[1];cl[1][2]:=c2[2];cl[1][3]:=$FF;
  if not tr then begin
   cl[2][0]:=(2*cl[0][0]+cl[1][0]+1) div 3;
   cl[2][1]:=(2*cl[0][1]+cl[1][1]+1) div 3;
   cl[2][2]:=(2*cl[0][2]+cl[1][2]+1) div 3;
   cl[2][3]:=$FF;
   cl[3][0]:=(cl[0][0]+2*cl[1][0]+1) div 3;
   cl[3][1]:=(cl[0][1]+2*cl[1][1]+1) div 3;
   cl[3][2]:=(cl[0][2]+2*cl[1][2]+1) div 3;
   cl[3][3]:=$FF;
  end else begin 
   cl[2][0]:=(cl[0][0]+2*cl[1][0]+1) div 3;
   cl[2][1]:=(cl[0][1]+2*cl[1][1]+1) div 3;
   cl[2][2]:=(cl[0][2]+2*cl[1][2]+1) div 3;
   cl[2][3]:=$FF;
   cl[3][0]:=(2*cl[0][0]+cl[1][0]+1) div 3;
   cl[3][1]:=(2*cl[0][1]+cl[1][1]+1) div 3;
   cl[3][2]:=(2*cl[0][2]+cl[1][2]+1) div 3;
   cl[3][3]:=$00;
  end;

  k:=0;bitmask:=0;
  for j:=0 to 3 do for i:=0 to 3 do if((4*x+i)<w)and((4*y+j)<h)then begin
   c:=pcrgba(@src[((4*y+j)*w+(4*x+i))*4])^;
   n:=0;
   mi:=maxint;
   l:=coldst(c,cl[0]);if l<mi then begin mi:=l; n:=0;end;
   l:=coldst(c,cl[1]);if l<mi then begin mi:=l; n:=1;end;
   l:=coldst(c,cl[2]);if l<mi then begin mi:=l; n:=2;end;
   l:=coldst(c,cl[3]);if l<mi then n:=3;
   bitmask:=bitmask+dword(n shl k);
   k:=k+2
  end;

  pword(temp)^:=col0;Inc(temp,2);
  pword(temp)^:=col1;Inc(temp,2);
  pdword(temp)^:=bitmask;Inc(temp,4);
 end;
end;
//############################################################################//
//############################################################################//
procedure encodebitmap32toDXT3(src,enc:pbytea;w,h:integer);
var col0,col1:word;  
bitmask:dword;   
alpha:array[0..3] of word;  
cl:array[0..3]of crgba;
temp:pbyte;

x,y,i,j,k,n:integer;
ma,mi,l:integer;
wrd:pword;
c1,c2,c:crgba;

function coldst(c1,c2:crgba):integer;
begin
 result:=sqr(c1[0]-c2[0])+sqr(c1[1]-c2[1])+sqr(c1[2]-c2[2]);
end;

begin
 fillchar(enc^,w*h,0);  
 temp:=pbyte(enc);  
 for y:=0 to (h div 4)-1 do for x:=0 to (w div 4)-1 do begin
  c1:=pcrgba(@src[((4*y+3)*w+(4*x+3))*4])^;  
  c2:=pcrgba(@src[((4*y+0)*w+(4*x+0))*4])^; 
  mi:=maxint;ma:=0;
  for j:=0 to 3 do for i:=0 to 3 do if((4*x+i)<w)and((4*y+j)<h)then begin  
   c:=pcrgba(@src[((4*y+j)*w+(4*x+i))*4])^; 
   l:=ecol565(c[2],c[1],c[0]);     
   if l>ma then begin c1:=c; ma:=l;end;
   if l<mi then begin c2:=c; mi:=l;end;
  end;  
  col0:=ecol565(c1[2],c1[1],c1[0]);
  col1:=ecol565(c2[2],c2[1],c2[0]);    

  cl[0][0]:=c1[0];cl[0][1]:=c1[1];cl[0][2]:=c1[2];cl[0][3]:=$FF;
  cl[1][0]:=c2[0];cl[1][1]:=c2[1];cl[1][2]:=c2[2];cl[1][3]:=$FF;
  cl[2][0]:=(2*cl[0][0]+cl[1][0]+1) div 3;
  cl[2][1]:=(2*cl[0][1]+cl[1][1]+1) div 3;
  cl[2][2]:=(2*cl[0][2]+cl[1][2]+1) div 3;
  cl[2][3]:=$FF;
  cl[3][0]:=(cl[0][0]+2*cl[1][0]+1) div 3;
  cl[3][1]:=(cl[0][1]+2*cl[1][1]+1) div 3;
  cl[3][2]:=(cl[0][2]+2*cl[1][2]+1) div 3;
  cl[3][3]:=$FF;

  k:=0;bitmask:=0;
  for j:=0 to 3 do for i:=0 to 3 do if((4*x+i)<w)and((4*y+j)<h)then begin
   c:=pcrgba(@src[((4*y+j)*w+(4*x+i))*4])^;
   n:=0;
   mi:=maxint;
   l:=coldst(c,cl[0]);if l<mi then begin mi:=l; n:=0;end;
   l:=coldst(c,cl[1]);if l<mi then begin mi:=l; n:=1;end;
   l:=coldst(c,cl[2]);if l<mi then begin mi:=l; n:=2;end;
   l:=coldst(c,cl[3]);if l<mi then n:=3;
   bitmask:=bitmask+dword(n shl k);
   k:=k+2
  end;
  
  for j:=0 to 3 do begin
   wrd:=@alpha[j];
   wrd^:=0;
   for i:=3 downto 0 do if(((4*x+i)<w)and((4*y+j)<h))then begin
    wrd^:=wrd^+src[((4*y+j)*w+(4*x+i))*4+3] shr 4;
    if i<>0 then wrd^:=wrd^ shl 4;
   end;
  end;

  pword(temp)^:=alpha[0];Inc(temp,2);
  pword(temp)^:=alpha[1];Inc(temp,2);
  pword(temp)^:=alpha[2];Inc(temp,2);
  pword(temp)^:=alpha[3];Inc(temp,2);
  pword(temp)^:=col0;Inc(temp,2);
  pword(temp)^:=col1;Inc(temp,2);
  pdword(temp)^:=bitmask;Inc(temp,4);
 end;
end;
//############################################################################//
//############################################################################//
procedure encodebitmap32toDXT5(src,enc:pbytea;w,h:integer);
var col0,col1,cw:word;  
bitmask:dword;   
alphas:array[0..7] of Byte;
cl:array[0..3]of crgba;
temp,am:pbyte;
alphamask:array[0..5]of byte;
sht:boolean;

x,y,i,j,k,n,r:integer;
ma,mi,l:integer;
//wrd:pword;
c1,c2,c:crgba;

function coldst(c1,c2:crgba):integer;
begin
 result:=sqr(c1[0]-c2[0])+sqr(c1[1]-c2[1])+sqr(c1[2]-c2[2]);
end;

begin
 fillchar(enc^,w*h,0);  
 temp:=pbyte(enc);  
 for y:=0 to (h div 4)-1 do for x:=0 to (w div 4)-1 do begin
  c1:=pcrgba(@src[((4*y+3)*w+(4*x+3))*4])^;  
  c2:=pcrgba(@src[((4*y+0)*w+(4*x+0))*4])^; 
  mi:=maxint;ma:=0;
  for j:=0 to 3 do for i:=0 to 3 do if((4*x+i)<w)and((4*y+j)<h)then begin  
   c:=pcrgba(@src[((4*y+j)*w+(4*x+i))*4])^; 
   l:=ecol565(c[2],c[1],c[0]);     
   if l>ma then begin c1:=c; ma:=l;end;
   if l<mi then begin c2:=c; mi:=l;end;
  end;  
  col0:=ecol565(c1[2],c1[1],c1[0]);
  col1:=ecol565(c2[2],c2[1],c2[0]);    

  cl[0][0]:=c1[0];cl[0][1]:=c1[1];cl[0][2]:=c1[2];cl[0][3]:=$FF;
  cl[1][0]:=c2[0];cl[1][1]:=c2[1];cl[1][2]:=c2[2];cl[1][3]:=$FF;
  cl[2][0]:=(2*cl[0][0]+cl[1][0]+1) div 3;
  cl[2][1]:=(2*cl[0][1]+cl[1][1]+1) div 3;
  cl[2][2]:=(2*cl[0][2]+cl[1][2]+1) div 3;
  cl[2][3]:=$FF;
  cl[3][0]:=(cl[0][0]+2*cl[1][0]+1) div 3;
  cl[3][1]:=(cl[0][1]+2*cl[1][1]+1) div 3;
  cl[3][2]:=(cl[0][2]+2*cl[1][2]+1) div 3;
  cl[3][3]:=$FF;

  k:=0;bitmask:=0;
  for j:=0 to 3 do for i:=0 to 3 do if((4*x+i)<w)and((4*y+j)<h)then begin
   c:=pcrgba(@src[((4*y+j)*w+(4*x+i))*4])^;
   n:=0;
   mi:=maxint;
   l:=coldst(c,cl[0]);if l<mi then begin mi:=l; n:=0;end;
   l:=coldst(c,cl[1]);if l<mi then begin mi:=l; n:=1;end;
   l:=coldst(c,cl[2]);if l<mi then begin mi:=l; n:=2;end;
   l:=coldst(c,cl[3]);if l<mi then n:=3;
   bitmask:=bitmask+dword(n shl k);
   k:=k+2
  end;
        
  sht:=false;
  alphas[0]:=pcrgba(@src[((4*y+3)*w+(4*x+3))*4])^[3];  
  alphas[1]:=pcrgba(@src[((4*y+0)*w+(4*x+0))*4])^[3]; 
  mi:=maxint;ma:=0;
  for j:=0 to 3 do for i:=0 to 3 do if((4*x+i)<w)and((4*y+j)<h)then begin  
   l:=pcrgba(@src[((4*y+j)*w+(4*x+i))*4])^[3]; 
   if (l=0)or(l=$FF)then sht:=true;
   if l>ma then begin alphas[0]:=l; ma:=l;end;
   if l<mi then begin alphas[1]:=l; mi:=l;end;
  end;  
  
  if sht then begin
   cw:=alphas[0];alphas[0]:=alphas[1];alphas[1]:=cw;
  end;

  if not sht then begin
   alphas[2]:=(6*alphas[0]+1*alphas[1]+3) div 7;
   alphas[3]:=(5*alphas[0]+2*alphas[1]+3) div 7;
   alphas[4]:=(4*alphas[0]+3*alphas[1]+3) div 7;
   alphas[5]:=(3*alphas[0]+4*alphas[1]+3) div 7;
   alphas[6]:=(2*alphas[0]+5*alphas[1]+3) div 7;
   alphas[7]:=(1*alphas[0]+6*alphas[1]+3) div 7;
  end else begin
   alphas[2]:=(4*alphas[0]+1*alphas[1]+2) div 5;
   alphas[3]:=(3*alphas[0]+2*alphas[1]+2) div 5;
   alphas[4]:=(2*alphas[0]+3*alphas[1]+2) div 5;
   alphas[5]:=(1*alphas[0]+4*alphas[1]+2) div 5;
   alphas[6]:=0;
   alphas[7]:=$FF;
  end;  
  
  k:=0;for i:=0 to 5 do alphamask[i]:=0;am:=@alphamask[0];
  for j:=0 to 3 do for i:=0 to 3 do if((4*x+i)<w)and((4*y+j)<h)then begin
   cw:=pcrgba(@src[((4*y+j)*w+(4*x+i))*4])^[3];
   n:=0;
   mi:=maxint;
   for r:=0 to 7 do begin l:=abs(cw-alphas[r]);if l<mi then begin mi:=l; n:=r;end;end;
   pdword(am)^:=pdword(am)^+dword(n shl k);
   k:=k+3;
   if k=24 then begin k:=0;am:=@alphamask[3];end;
  end;

  temp^:=alphas[0];Inc(temp);temp^:=alphas[1];Inc(temp);  
  temp^:=alphamask[0];Inc(temp);temp^:=alphamask[1];Inc(temp);temp^:=alphamask[2];Inc(temp);temp^:=alphamask[3];Inc(temp);temp^:=alphamask[4];Inc(temp);temp^:=alphamask[5];Inc(temp);
  pword(temp)^:=col0;Inc(temp,2);
  pword(temp)^:=col1;Inc(temp,2);
  pdword(temp)^:=bitmask;Inc(temp,4);
 end;
end;
//############################################################################//
//############################################################################//
begin
end. 
//############################################################################//