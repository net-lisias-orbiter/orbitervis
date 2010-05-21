{
 Copyright (C) 2002-2007 by Artyom Litvinovich
 AlgorLib: Str and Val 
}
{$ifdef FPC}{$MODE delphi}{$endif}
unit strval;
interface
uses maths,sysutils,asys;

type numa=array of integer;

function getfsymp(st:string;sb:char):integer;
function getnsymp(st:string;sb:char;n:integer):integer;
function getlsymp(st:string;sb:char):integer; 
function trimsr(s:string;n:integer;c:char):string;
function trimsl(s:string;n:integer;c:char):string;                                                                   
function trse(e:double):string;
function stri(par:longint):string;
function vali(par:string):integer;
function stre(par:double;dec:integer=-99):string;
function strlat(par:longint):string; 
function vale(par:string):double;overload;
function valep(par:pchar):double;overload;
function strcv(par:double;tp:integer=1):string;
function valvec2(st:string):vec2;
function valvec (st:string):vec;    
function valquat(st:string):quat; 
function valvec5(st:string):vec5;
function valhex(ins:string):dword;
function strbin(bit:dword):string;
function strhex2(bit:dword):string;
function strhex4(bit:dword):string;
function strhex(bit:dword):string;
function strboolx(b:boolean;t,f:string):string;
function valbin(ins:string):dword;  
function valbinrev(ins:string):dword;
procedure valnuma(ins:string;var res:numa);
function vala(ins:string):dword;
function valexp(par:string):double;

function wcmatch(s,mask:string;igcase:boolean):boolean;

function strdat6cs(i:integer):string;
function strdat6cf(i:integer):string;

implementation
//##############################################################################

function getfsymp(st:string;sb:char):integer;
var i:integer;
begin
 result:=0;
 //FIXME?
 //if st<>'' then for i:=0 to length(st)-1 do if (st[i+1]=sb)or((sb=' ')and(st[i+1]=#9)) then begin result:=i; exit; end;
 //if st<>'' then for i:=0 to length(st)-1 do if (st[i]=sb)or((sb=' ')and(st[i]=#9)) then begin result:=i; exit; end;
 if st<>'' then for i:=1 to length(st) do if (st[i]=sb)or((sb=' ')and(st[i]=#9)) then begin result:=i; exit; end;
end;
//##############################################################################

function getnsymp(st:string;sb:char;n:integer):integer;
var i:integer;
begin
 result:=0;    
 //FIXME?
 //if st<>'' then for i:=0 to length(st)-1 do if (st[i+1]=sb)or((sb=' ')and(st[i+1]=#9)) then begin n:=n-1; if n=0 then begin result:=i; exit; end else continue; end;
 //if st<>'' then for i:=0 to length(st)-1 do if (st[i]=sb)or((sb=' ')and(st[i]=#9)) then begin n:=n-1; if n=0 then begin result:=i; exit; end else continue; end;
 if st<>'' then for i:=1 to length(st) do if (st[i]=sb)or((sb=' ')and(st[i]=#9)) then begin n:=n-1; if n=0 then begin result:=i; exit; end else continue; end;
end;

//##############################################################################

function getlsymp(st:string;sb:char):integer;
var i:integer;
begin
 result:=0;
 //if st<>'' then for i:=length(st)-1 downto 0 do if (st[i+1]=sb)or((sb=' ')and(st[i+1]=#9)) then begin result:=i; exit; end;
 //if st<>'' then for i:=length(st)-1 downto 0 do if (st[i]=sb)or((sb=' ')and(st[i]=#9)) then begin result:=i; exit; end;
 if st<>'' then for i:=length(st) downto 1 do if (st[i]=sb)or((sb=' ')and(st[i]=#9)) then begin result:=i; exit; end;
end;
    
//##############################################################################
//##############################################################################

function trimsr(s:string;n:integer;c:char):string;
begin
 result:=s;
 while length(result)<n do result:=result+c;
end;  
function trimsl(s:string;n:integer;c:char):string;
begin
 result:=s;
 while length(result)<n do result:=c+result;
end;
   
//############################################################################//                                                                
function trse(e:double):string;
begin
 if e>=0 then result:='+' else result:='-';
 result:=result+trimsl(stre(abs(e)),9,'0');
end;       
//############################################################################//
function stri(par:longint):string;
begin
 str(par,result);
end;
//############################################################################//
function vali(par:string):integer;
var i,ii:integer;
begin
 val(trim(par),i,ii);
 result:=i;
end;
//############################################################################//
function stre(par:double;dec:integer=-99):string;
begin
 if dec=-99 then dec:=cntfrac(par);
 str(par:1:dec,result);
end;
{
var e,f:int64;
sgn:boolean;
begin
 e:=trunc(par);
 f:=trunc((par-trunc(par+eps)+eps)*10000);
 if (f<0)or(e<0) then sgn:=true else sgn:=false;
 e:=abs(e);
 f:=abs(f);

 if f<>0 then result:=stri(e)+'.'+stri(f);   
 if (f<1000) then result:=stri(e)+'.0'+stri(f);
 if (f<100) then result:=stri(e)+'.00'+stri(f);
 if (f<10) then result:=stri(e)+'.000'+stri(f);
 if (f<1) then result:=stri(e)+'.0000';   

 if f<>0 then while copy(result,length(result),1)='0' do result:=copy(result,1,length(result)-1);
 
 if f=0 then result:=stri(e);
 if sgn then result:='-'+result;
end; }
{$R+}
//##############################################################################

function strlat(par:longint):string;
var st:string;
begin
 st:='';
 while par>=50 do begin
  par:=par-50;
  st:=st+'L';
 end;
 while par>=10 do begin
  if par>40 then begin
   par:=par-40;
   st:=st+'XL';
  end else begin
   par:=par-10;
   st:=st+'X';
  end;
 end;
 while par>=5 do begin
  if par=9 then begin
   par:=0;
   st:=st+'IX';
  end else begin
   par:=par-5;
   st:=st+'V';
  end;
 end;       
 while par>=1 do begin
  if par=4 then begin
   par:=0;
   st:=st+'IV';
  end else begin
   par:=par-1;
   st:=st+'I';
  end;
 end;
 result:=st;
end;
//############################################################################//
//############################################################################//
function vale(par:string):double;overload;
var p:integer;
begin
 //p:=pos('.',par);
 //if(p<>0)then par[p]:='.';
 val(trim(par),result,p);
end;       
//############################################################################//
function valep(par:pchar):double;overload;
var p:integer;
s:string;
begin
 s:=StrPas(par);
 //p:=pos('.',s);
 //if(p<>0)then s[p]:='.';
 val(trim(s),result,p);
end;
//############################################################################//
function vale_ad(par:string):double;
var i,pose,posc,c,bg:integer;
a,b:double;
s1,s2,s3:string;
sgn,sgc:boolean;
begin
 s1:='';
 s2:='';
 s3:='';
 pose:=-1;
 posc:=-1;
 bg:=1;
 sgc:=false;
 sgn:=false;
 if copy(par,1,1)='-' then begin
  sgc:=true;
  bg:=2;
 end;
 if copy(par,1,1)='+' then begin
  sgc:=false;
  bg:=2;
 end;
 for i:=bg to length(par) do if (copy(par,i,1)<>'.')and(copy(par,i,1)<>'e') then s1:=s1+copy(par,i,1) else begin
  if copy(par,i,1)='e' then pose:=i;
  if copy(par,i,1)='.' then posc:=i;
  break;
 end;
 if posc<>-1 then for i:=posc+1 to length(par) do if copy(par,i,1)<>'e' then s2:=s2+copy(par,i,1) else begin
  pose:=i;
  break;
 end;
 if pose<>-1 then for i:=pose+1 to length(par) do if (copy(par,i,1)<>'-')and(copy(par,i,1)<>'+') then s3:=s3+copy(par,i,1) else begin
  if copy(par,i,1)='-' then sgn:=true;
  if copy(par,i,1)='+' then sgn:=false;
 end;
 val(s1,a,i);
 s2:='1'+s2;
 val(s2,b,i);
 val(s3,c,i);
 if sgn then c:=-c;

 for i:=0 to 1000 do if b>=1 then b:=b/10;
 b:=b*10;
 b:=b-1;

 a:=a+b;
 a:=a*pow(10,c);

 if sgc then a:=-a;

 result:=a;
end;
//############################################################################//
//############################################################################//
function strcv(par:double;tp:integer=1):string;
var a:double;
begin
 a:=abs(par);
 if tp=1 then begin
  if(a<1000)then begin      //1km
   result:=stre(par,cntfrac(par));
  end else if(a<1e6)then begin    //1000km
   par:=par/1000;      
   result:=stre(par,cntfrac(par))+'k';
  end else if(a<1e9)then begin    //1 million km
   par:=par/1e6;
   result:=stre(par,cntfrac(par))+'M';
  end else if(a<10e3*au)then begin //10000AU
   par:=par/au;
   result:=stre(par,cntfrac(par))+'AU';
  end else if(a<1000*le)then begin          //1000le
   par:=par/le;
   result:=stre(par,cntfrac(par))+'le';
  end else if(a<1e6*le)then begin             //1Mle
   par:=par/(1000*le);
   result:=stre(par,cntfrac(par))+'kle';
  end else if(a<1e9*le)then begin             //1Gle
   par:=par/(1e6*le);
   result:=stre(par,cntfrac(par))+'Mle';
  end else begin
   par:=par/(1e9*le);
   result:=stre(par,cntfrac(par))+'Gle';
  end;
 end;
 if tp=2 then begin
  if(a<1000)then begin      //1km
   result:=stre(par,cntfrac(par));
  end else if(a<1e6)then begin    //1000km
   par:=par/1000;      
   result:=stre(par,cntfrac(par))+'k';
  end else if(a<1e9)then begin    //1 million km
   par:=par/1e6;
   result:=stre(par,cntfrac(par))+'M';
  end else if(a<10e3*au)then begin //10000AU
   par:=par/au;
   result:=stre(par,cntfrac(par))+'AU';
  end else if(a<1000*parsec)then begin          //1000pc
   par:=par/parsec;
   result:=stre(par,cntfrac(par))+'pc';
  end else if(a<1e6*parsec)then begin             //1Mpc
   par:=par/(1000*parsec);
   result:=stre(par,cntfrac(par))+'kpc';
  end else if(a<1e9*parsec)then begin             //1Gpc
   par:=par/(1e6*parsec);
   result:=stre(par,cntfrac(par))+'Mpc';
  end else begin
   par:=par/(1e9*parsec);
   result:=stre(par,cntfrac(par))+'Gpc';
  end;
 end;
 if tp=3 then begin
  if(a<1024)then begin      //1km
   result:=stre(par,cntfrac(par))+'b';
  end else if(a<1024*1024)then begin    //1000km
   par:=par/1024;      
   result:=stre(par,cntfrac(par))+'Kb';
  end else if(a<1024*1024*1024)then begin    //1 million km
   par:=par/(1024*1024);
   result:=stre(par,cntfrac(par))+'Mb';
  end else if(a<1099511627776)then begin //10000AU
   par:=par/(1024*1024*1024);
   result:=stre(par,cntfrac(par))+'Gb';
  end else begin
   par:=par/(1099511627776);
   result:=stre(par,cntfrac(par))+'Tb';
  end;
 end;
end;

function strsinsym(s:string;c:char):string;
var i:integer;
b:boolean;
begin
 b:=false;
 result:='';
 for i:=1 to length(s) do if s[i]=c then begin 
  if not b then begin 
   result:=result+c; 
   b:=true;
  end; 
 end else begin 
  b:=false; 
  result:=result+s[i];
 end;
end;

function valvec2(st:string):vec2;
var i:integer;
str1,str2:string;
begin
 st:=strsinsym(st,' ');
 i:=getfsymp(st,',');  
 if i=0 then i:=getfsymp(st,' ');
 str1:=copy(st,1,i-1);
 str2:=copy(st,i+1,length(st)-i);
 result.x:=vale(trim(str1));
 result.y:=vale(trim(str2));
end;

function valvec(st:string):vec;
var i,j:integer;
str1,str2,str3:string;
begin    
 st:=strsinsym(st,' ');
 i:=getfsymp(st,',');
 j:=getnsymp(st,',',2);
 if i=0 then i:=getfsymp(st,' ');
 if j=0 then j:=getnsymp(st,' ',2);
 str1:=copy(st,1,i-1);
 str2:=copy(st,i+1,j-i-1);
 str3:=copy(st,j+1,length(st)-j);
 result.x:=vale(trim(str1));
 result.y:=vale(trim(str2));
 result.z:=vale(trim(str3));
end;

function valquat(st:string):quat;
var i,j,k:integer;
str1,str2,str3,str4:string;
begin      
 st:=strsinsym(st,' ');
 i:=getfsymp(st,','); 
 j:=getnsymp(st,',',2);
 k:=getnsymp(st,',',3);
 if i=0 then i:=getfsymp(st,' ');
 if j=0 then j:=getnsymp(st,' ',2);
 if k=0 then k:=getnsymp(st,' ',3);
 str1:=copy(st,1,i-1);
 str2:=copy(st,i+1,j-i-1);
 str3:=copy(st,j+1,k-j-1);
 str4:=copy(st,k+1,length(st)-j);
 result.x:=vale(trim(str1));
 result.y:=vale(trim(str2));
 result.z:=vale(trim(str3));
 result.w:=vale(trim(str4));
end;

function valvec5(st:string):vec5;
var i,j,k,l:integer;
str1,str2,str3,str4,str5:string;
begin      
 st:=strsinsym(st,' ');
 result.w:=0; result.t:=0;
 i:=getfsymp(st,','); 
 j:=getnsymp(st,',',2);
 k:=getnsymp(st,',',3);
 l:=getnsymp(st,',',4);
 if i=0 then i:=getfsymp(st,' ');
 if j=0 then j:=getnsymp(st,' ',2);
 if k=0 then k:=getnsymp(st,' ',3);
 if l=0 then l:=getnsymp(st,' ',4);
 if j=0 then j:=length(st)+1;
 if k=0 then k:=length(st)+1;
 if l=0 then l:=length(st)+1;
 str1:=copy(st,1,i-1);
 str2:=copy(st,i+1,j-i-1);
 str3:=copy(st,j+1,k-j-1);
 str4:=copy(st,k+1,l-k-1);
 str5:=copy(st,l+1,length(st)-j);
 result.x:=vale(trim(str1));
 result.y:=vale(trim(str2));
 result.z:=vale(trim(str3));
 result.w:=vale(trim(str4));
 result.t:=vale(trim(str5));
end;

function valhex(ins:string):dword;
var lg,i:byte;
lt:char;
res:dword;
begin
 res:=0;
 ins:=lowercase(ins);
 lg:=length(ins);
 for i:=lg-1 downto 0 do begin
  lt:=ins[lg-i];
  case lt of
  '0':res:=res;
  '1':res:=res+1*dword(powi(16,i));
  '2':res:=res+2*dword(powi(16,i));
  '3':res:=res+3*dword(powi(16,i));
  '4':res:=res+4*dword(powi(16,i));
  '5':res:=res+5*dword(powi(16,i));
  '6':res:=res+6*dword(powi(16,i));
  '7':res:=res+7*dword(powi(16,i));
  '8':res:=res+8*dword(powi(16,i));
  '9':res:=res+9*dword(powi(16,i));
  'a':res:=res+10*dword(powi(16,i));
  'b':res:=res+11*dword(powi(16,i));
  'c':res:=res+12*dword(powi(16,i));
  'd':res:=res+13*dword(powi(16,i));
  'e':res:=res+14*dword(powi(16,i));
  'f':res:=res+15*dword(powi(16,i));
  end;
 end;
 result:=res;
end;

//##############################################################################

function strbin(bit:dword):string;
var i,r:dword;
re:string;
begin
 re:='';
 for i:=15 downto 0 do begin
  r:=bit shl (15-i);
  re:=re+stri(r shr 15 );
 end;
 result:=re;
end;

//##############################################################################

function strhex(bit:dword):string;
{var i,r:dword;
re:string;}
begin      {
 re:='';
 for i:=15 downto 0 do begin
  r:=bit shl (15-i);
  re:=re+stri(r shr 15 );
 end;    }
 result:=inttohex(bit,8);
end;

//##############################################################################

function strhex2(bit:dword):string;
{var i,r:dword;
re:string;}
begin      {
 re:='';
 for i:=15 downto 0 do begin
  r:=bit shl (15-i);
  re:=re+stri(r shr 15 );
 end;    }
 result:=inttohex(bit,2);
end;


//##############################################################################

function strhex4(bit:dword):string;
{var i,r:dword;
re:string;}
begin      {
 re:='';
 for i:=15 downto 0 do begin
  r:=bit shl (15-i);
  re:=re+stri(r shr 15 );
 end;    }
 result:=inttohex(bit,4);
end;   
//##############################################################################
function strboolx(b:boolean;t,f:string):string;
begin
 if b then result:=t else result:=f;
end;

//##############################################################################

function strdat6cs(i:integer):string;
var y,m,d:integer;
ys,ms,ds:string;
begin      
 y:=i div 10000;
 m:=i div 100-y*100;
 d:=i mod 100;
// writeln('('+stri(d)+' '+stri(m)+' '+stri(y)+')');
 ys:=stri(y+2000);
 ds:=stri(d);
 case m of
  01:ms:='jan';
  02:ms:='feb';
  03:ms:='mar';
  04:ms:='apr';
  05:ms:='may';
  06:ms:='jun';
  07:ms:='jul';
  08:ms:='aug';
  09:ms:='sep';
  10:ms:='oct';
  11:ms:='nov';
  12:ms:='dec';
  else ms:=stri(m);
 end;
 
 result:=ds+' '+ms+' '+ys;
end;

//##############################################################################

function strdat6cf(i:integer):string;
var y,m,d:integer;
ys,ms,ds:string;
begin      
 y:=i div 10000;
 m:=i div 100-y*100;
 d:=i mod 100;
// writeln('('+stri(d)+' '+stri(m)+' '+stri(y)+')');
 ys:=stri(y+2000);
 ds:=stri(d);
 case m of
  01:ms:='january';
  02:ms:='feburary';
  03:ms:='marth';
  04:ms:='april';
  05:ms:='may';
  06:ms:='june';
  07:ms:='july';
  08:ms:='august';
  09:ms:='september';
  10:ms:='october';
  11:ms:='november';
  12:ms:='december';
  else ms:=stri(m);
 end;
 
 result:=ds+' '+ms+' '+ys;
end;

//##############################################################################
   
function valbin(ins:string):dword;
var lg,i:byte;
lt:char;
res:dword;
begin
 res:=0;
 ins:=lowercase(ins);
 lg:=length(ins);
 for i:=lg-1 downto 0 do begin
  lt:=ins[lg-i];
  case lt of
  '0':res:=res;
  '1':res:=res+dword(1*powi(2,i));
  end;
 end;
 result:=res;
end;  
//##############################################################################
function valbinrev(ins:string):dword;
var i:integer;
lt:char;
res:dword;
begin
 res:=0;
 ins:=lowercase(ins);
 for i:=0 to length(ins)-1 do begin
  lt:=ins[i+1];
  case lt of
  '0':res:=res;
  '1':res:=res+dword(1*powi(2,i));
  end;
 end;
 result:=res;
end;
//##############################################################################
procedure valnuma(ins:string;var res:numa);
var i,c,r:integer;
s:string;
label 1;
begin
 c:=0;s:='';
 setlength(res,0);r:=0;
 for i:=1 to length(ins) do begin
  1:
  case c of
   0:case ins[i] of
    ' ',#9:continue;
    else begin c:=1; goto 1;end;
   end;
   1:case ins[i] of
    ' ',#9:begin
     setlength(res,r+1);
     res[r]:=vali(s);
     r:=r+1;
     s:='';
     c:=0; 
     continue;
    end; 
    else begin s:=s+ins[i]; continue; end;
   end;
  end;
 end;
 if length(s)<>0 then begin
  setlength(res,r+1);
  res[r]:=vali(s);
 end;
end;
//##############################################################################

function vala(ins:string):dword;
begin
 result:=vali(ins);
 if copy(ins,1,1)='$' then result:=valhex(copy(ins,2,length(ins)-1));
 if copy(ins,length(ins),1)='h' then result:=valhex(copy(ins,1,length(ins)-1));
 if copy(ins,length(ins),1)='b' then result:=valbin(copy(ins,1,length(ins)-1));
end;

//##############################################################################

function valexp(par:string):double;
var i,pose,posc,c,bg:integer;
a,b:double;
s1,s2,s3:string;
sgn,sgc:boolean;
begin
 s1:='';s2:='';s3:='';
 pose:=-1;posc:=-1;bg:=1;
 sgc:=false;sgn:=false;
 if copy(par,1,1)='-' then begin
  sgc:=true;
  bg:=2;
 end;
 if copy(par,1,1)='+' then begin
  sgc:=false;
  bg:=2;
 end;
 for i:=bg to length(par) do if (copy(par,i,1)<>'.')and(copy(par,i,1)<>'e') then s1:=s1+copy(par,i,1) else begin
  if copy(par,i,1)='e' then pose:=i;
  if copy(par,i,1)='.' then posc:=i;
  break;
 end;
 if posc<>-1 then for i:=posc+1 to length(par) do if copy(par,i,1)<>'e' then s2:=s2+copy(par,i,1) else begin
  pose:=i;
  break;
 end;
 if pose<>-1 then for i:=pose+1 to length(par) do if (copy(par,i,1)<>'-')and(copy(par,i,1)<>'+') then s3:=s3+copy(par,i,1) else begin
  if copy(par,i,1)='-' then sgn:=true;
  if copy(par,i,1)='+' then sgn:=false;
 end;
 val(s1,a,i);
 s2:='1'+s2;
 val(s2,b,i);
 val(s3,c,i);
 if sgn then c:=-c;

 for i:=0 to 1000 do if b>=1 then b:=b/10;
 b:=b*10;
 b:=b-1;

 a:=a+b;
 a:=a*pow(10,c);

 if sgc then a:=-a;

 result:=a;
end;

function posx(substr,s:string;start:integer):integer;
var i,j,len:integer;
begin
 len:=length(substr);
 if len=0 then begin result:=1;exit;end;
 for i:=start to length(s)-len+1 do begin
  j:=1;
  while j<=len do begin
   if not((substr[j]='?')or(substr[j]=s[i+j-1])) then break;
   inc(j);
  end;
  if j>len then begin result:=i;exit;end;
 end;
 result:=0;
end;

function wcmatch(s,mask:string;igcase:boolean):boolean;
const wildsize=0; //minimal number of characters representing a "*"
var mn,mx,i,maskstart,maskend:integer;
t:string;
begin
 if igcase then begin
  for i:=1 to length(s) do s[i]:=upcase(s[i]);
  for i:=1 to length(mask) do mask[i]:=upcase(mask[i]);
 end;
 s:=s+#0;
 mask:=mask+#0;
 mn:=1;
 mx:=1;
 maskend:=0;
 while length(mask)>=maskend do begin
  maskstart:=maskend+1;
  repeat
   inc(maskend);
  until (maskend>length(mask))or(mask[maskend]='*');
  t:=copy(mask,maskstart,maskend-maskstart);
  i:=posx(t,s,mn);
  if(i=0)or(i>mx)then begin result:=false;exit;end;
  mn:=i+length(t)+wildsize;
  mx:=length(s);
 end;
 result:=true;
end;


begin
end.

