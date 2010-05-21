{
 Copyright (C) 2003-2007 by Artyom Litvinovich
 AlgorLib: Polis VM
}
unit polis;
//{$define lexandbg}
//{$define thedbg}
interface
uses asys,strval,maths,sysutils,curv,math;
type codtyp=record
 typ,pos:integer;
 vl:double;
 p:string;
 ln,sy:integer;
end;
codt=array of codtyp;
pcodt=^codt;

ppolcodtree=^polcodtree;
polcodtree=record
 tp:integer;
 nam:string;
 vl:double;
 ch:array of ppolcodtree;
 
 x,y,xs,ys,xo,yo,l,id:integer;
 vis,drg:boolean;
 
 pr:ppolcodtree;
end;
appolct=array of ppolcodtree;

function evalexpr(noi,e:pointer;s:string):double;
function compexpr(s:string):codt;  
function tree2expr(t:ppolcodtree):string;
function expr2tree(var mcod:codt;var ap:appolct):ppolcodtree;
function runexpr (noi,e:pointer;var c:codt):double;  
procedure addifc(nam:string;pc:integer;lnk:pointer);

implementation

{$i polis-glcs.inc}
type alphas=set of char; 
const alpha:alphas =['a'..'z','A'..'Z','_','"'];
const digit:alphas =['0'..'9'];
const hdigit:alphas =['a'..'f','A'..'F','0'..'9'];
type astr=array of ansistring;
//##############################################################################
type
tabltyp=record
 num:double;
 str:string;
end;
tabl=array of tabltyp;
lextyp=record
 cl,pos:integer;
 ln,sy:integer;
end;
lext=array of lextyp;
var
tw,td,tid,tst,tnum:tabl;
//##############################################################################
type
vartyp=record
 nam:string;
 vl:double;
end;
intftyp=record
 nam:string;
 p:pointer;
 pc:integer;
end;

var
intfs:array of intftyp;
vars:array of vartyp;   
//##############################################################################

//##############################################################################
//##############################################################################
//##############################################################################
procedure stderr(n,l,c:integer;s:string);
begin
 writeln('Error(',n,'):',l,':',c,':',s);
end;
procedure haltprog; begin halt; end;
//##############################################################################
//##############################################################################
//##############################################################################
//##############################################################################
//##############################################################################
//##############################################################################
//##############################################################################
//##############################################################################
//##############################################################################
procedure lexan(fil:astr;var olex:lext);
var
buf:string;
tc:integer;
c:char;
d,l,j:integer;
r:real;
s:integer;
cln,csy,rsl:integer;

procedure gc;
begin {$ifdef lexandbg} write('gc:');{$endif}
 if csy<length(fil[cln])then csy:=csy+1 else begin
  if cln<length(fil)-1 then begin cln:=cln+1; csy:=0; c:=' '; exit; end else begin
   c:=#0; exit;
  end;
 end;
 c:=fil[cln][csy];
 
 if (c=#$09) then begin c:=' '; end;
 if (c=#$0D) then begin c:=' '; end;
 if (c=#$0A) then begin c:=' '; end;
end;

procedure clean;
begin {$ifdef lexandbg} write('clean:');{$endif}
 buf:='';
end;

procedure add;
begin {$ifdef lexandbg} write('add:');{$endif}
 buf:=buf+c;
end;

procedure mlex(cl,po:integer);
var k:integer;
begin {$ifdef lexandbg} write('mlex:');{$endif}
 k:=length(olex);
 setlength(olex,k+1);
 olex[k].cl:=cl;
 olex[k].pos:=po;
 olex[k].ln:=cln;
 olex[k].sy:=csy;
end;

function putl(var t:tabl):integer;
var k,i:integer;
begin {$ifdef lexandbg} write('putl:');{$endif}
 for i:=0 to length(t)-1 do if t[i].str=buf then begin
  result:=i;
  exit;
 end;
 k:=length(t);
 setlength(t,k+1);
 t[k].str:=buf;
 result:=k;
end;

function putni:integer;
var k,i:integer;
begin {$ifdef lexandbg} write('putni:');{$endif}
 for i:=0 to length(TNUM)-1 do if TNUM[i].num=s*d then begin
  result:=i;
  exit;
 end;
 k:=length(TNUM);
 setlength(TNUM,k+1);
 TNUM[k].num:=s*d;
 TNUM[k].str:=stri(s*d);    
 result:=k;
end;

function putnr:integer;
var k,i:integer;
begin {$ifdef lexandbg} write('putnr:');{$endif}   
 for i:=0 to length(TNUM)-1 do if TNUM[i].num=s*r then begin
  result:=i;
  exit;
 end;
 k:=length(TNUM);
 setlength(TNUM,k+1);
 TNUM[k].num:=s*r;
 TNUM[k].str:=stre(s*r);    
 result:=k;
end;

function look(t:tabl):integer;
var k,j:integer;
begin {$ifdef lexandbg} write('look:');{$endif}
 result:=-1;
 k:=length(t);
 if k=0 then begin result:=-1; exit; end;
 for j:=0 to k-1 do if t[j].str=buf then begin result:=j; exit; end;
end;

procedure isdlm;
begin {$ifdef lexandbg} write('isdlm:');{$endif}
 j:=look(TD);
 if j>=0 then begin mlex(CL_SEP,j); gc; end else begin stderr(ERR_USYM,cln,csy-2,'Undefined symbol "'+c+'"'); haltprog; end;
end;

function hcv(b:char):integer;
var n:integer;
begin {$ifdef lexandbg} write('hcv:');{$endif}
 n:=0;
 if b in digit then n:=vali(b);
 if (b>='A')and(b<='F') then n:=10+ord(b)-ord('A');
 if (b>='a')and(b<='f') then n:=10+ord(b)-ord('a');
 result:=n;
end; 

procedure chinc;
var c,s1,s2:string;
i:integer;
begin {$ifdef lexandbg} write('chinc:');{$endif}
 s1:='';
 s2:='';
 for i:=1 to length(buf) do begin
  c:=copy(buf,i,1);
  if c<>' ' then s1:=s1+c;
  if c=' ' then begin
   s2:=copy(buf,i+1,length(buf));
   break;
  end;
 end;
 s1:=lowercase(s1);
 s2:=lowercase(trim(s2));
end;

begin
 cln:=0;csy:=0;l:=0;
 tc:=TC_H;
 {$ifdef lexandbg} write('stolexan:');{$endif}
 gc;
 while(tc<>TC_FIN)and(tc<>TC_ERR)do case tc of
 TC_H:if c=' ' then gc else
       if c in alpha then begin clean; add; gc; tc:=TC_ID; end else
        if c in digit then begin s:=1; r:=ord(c)-ord('0'); gc; tc:=TC_NUM; end else
         if c='$' then begin s:=1; d:=0; gc; tc:=TC_HNUM; end else
          if c='{' then begin gc; tc:=TC_COMP; end else
           if c='''' then begin clean; gc; tc:=TC_SCON; end else
            if c=':' then begin gc; tc:=TC_ASS; end else
             if c='/' then begin gc; tc:=TC_CS; end else
              if c='<' then begin gc; tc:=TC_SM; end else
               if c='>' then begin gc; tc:=TC_BG; end else
                if c='+' then begin gc; tc:=TC_ADC; end else
                 if c='-' then begin gc; tc:=TC_SBC; end else
                  if c='.' then begin gc; tc:=TC_PP; end else
                   if c=#00 then begin TC:=TC_FIN; end else tc:=TC_DLM;
 TC_SCON:if c=#00 then begin stderr(ERR_NCC,cln,csy,'String not closed.'); haltprog; end else
           if c='''' then begin gc; tc:=TC_SCONE; end else begin add; gc; end;
 TC_SCONE:if c=#00 then begin stderr(ERR_NCC,cln,csy,'String not closed.'); haltprog; end else
           if c='''' then begin add; gc; tc:=TC_SCON; end else
            if c<>'''' then begin mlex(CL_STR,putl(TST)); tc:=TC_H; end;
 TC_COMP:if c=#00 then begin stderr(ERR_NCC,cln,csy,'Comment not closed.'); haltprog; end else
          if c='$' then begin gc; clean; tc:=TC_DIR; end else
           if c='}' then begin gc; tc:=TC_H; end else tc:=TC_COM;
 TC_COM:if c=#00 then begin stderr(ERR_NCC,cln,csy,'Comment not closed.'); haltprog; end else
           if c='}' then begin gc; tc:=TC_H; end else gc;
 TC_DIR:if c='}' then begin chinc; end else
         if c=#00 then begin stderr(ERR_NCC,cln,csy,'Comment not closed.'); haltprog; end else begin add; gc; end;
 TC_ID:if (c in alpha)or(c in digit) then begin add; gc; end else begin
        j:=look(TW);
        if j>=0 then mlex(CL_RW,j) else begin
         j:=putl(TID);
         mlex(CL_ID,j);
        end;
        tc:=TC_H;
       end;
 TC_NUM:if c in digit then begin r:=r*10+(ord(c)-ord('0')); gc; end else
         if c='.' then begin l:=0; gc; tc:=TC_RNUM; end
          else begin d:=round(r); mlex(CL_NUM,putni); tc:=TC_H; end;
 TC_RNUM:if c in digit then begin l:=l+1; r:=r+(ord(c)-ord('0'))*(1/pow(10,l)); gc; end 
          else begin mlex(CL_NUM,putnr); tc:=TC_H; end;
 TC_HNUM:if c in hdigit then begin d:=d*16+hcv(c); gc; end else begin
         mlex(CL_NUM,putni);
         tc:=TC_H;
        end;
 TC_ASS:if c ='=' then begin gc; mlex(CL_SEP,S_ASS); tc:=TC_H; end else begin mlex(CL_SEP,S_PP); tc:=TC_H; end;
 TC_SM:if c ='>' then begin gc; mlex(CL_SEP,S_NEQU); tc:=TC_H; end else
        if c='=' then begin gc; mlex(CL_SEP,S_LE); tc:=TC_H; end else begin mlex(CL_SEP,S_LW); tc:=TC_H; end;
 TC_BG:if c ='=' then begin gc; mlex(CL_SEP,S_GE); tc:=TC_H; end else begin mlex(CL_SEP,S_GR); tc:=TC_H; end;
 TC_ADC:if c ='+' then begin gc; mlex(CL_SEP,S_INC); tc:=TC_H; end else
         if (c in digit)and(olex[length(olex)-1].cl=CL_SEP)and(olex[length(olex)-1].pos<>S_RSK)then begin s:=1; r:=ord(c)-ord('0'); gc; tc:=TC_NUM; end           
          else begin mlex(CL_SEP,S_ADD); tc:=TC_H; end;
 TC_PP:if c ='.' then begin gc; mlex(CL_SEP,S_DBP); tc:=TC_H; end else begin mlex(CL_SEP,S_PNT); tc:=TC_H; end;
 TC_SBC:if c ='-' then begin gc; mlex(CL_SEP,S_DEC); tc:=TC_H; end else
         if (c in digit)and(((olex[length(olex)-1].cl=CL_SEP)and(olex[length(olex)-1].pos<>S_RSK))) then begin s:=-1; r:=ord(c)-ord('0'); gc; tc:=TC_NUM; end 
          else begin mlex(CL_SEP,S_SUB); tc:=TC_H; end;
 TC_CS:if c ='/' then begin rsl:=cln; repeat gc; until rsl<>cln; gc; tc:=TC_H; end else begin mlex(CL_SEP,S_DIV); tc:=TC_H; end;
 TC_DLM:begin clean; add; isdlm; tc:=TC_H; end;


 TC_IFDEF:if c=#00 then begin stderr(ERR_NCC,cln,csy,'Condition not closed.'); haltprog; end else
           if c='{' then begin gc; clean; tc:=TC_IFDEFC; end else gc;
 TC_IFDEFC:if c=#00 then begin stderr(ERR_NCC,cln,csy,'Condition not closed.'); haltprog; end else
          if c='$' then begin gc; clean; tc:=TC_IFDEFD; end else tc:=TC_IFDEF;
 TC_IFDEFD:if c='}' then begin chinc; end else
         if c=#00 then begin stderr(ERR_NCC,cln,csy,'Condition not closed.'); haltprog; end else begin add; gc; end;
 end;
end;

procedure wrotb(var ouf:text;t:tabl);
var j:integer;
begin
 if length(t)>0 then for j:=0 to length(t)-1 do begin
  writeln(ouf,stri(j)+':'+t[j].str);
 end;
end;

procedure lexngen(fn:string;mlex:lext);
var 
ouf:text;
i:integer;
s1:string;
begin
 assign(ouf,fn);
 rewrite(ouf);

 writeln(ouf,'Reserved:');
 wrotb(ouf,tw);
 writeln(ouf,'');
 writeln(ouf,'Separators:');
 wrotb(ouf,td);
 writeln(ouf,'');
 writeln(ouf,'Identifiers:');
 wrotb(ouf,tid);
 writeln(ouf,'');
 writeln(ouf,'Numbers:');
 wrotb(ouf,tnum);
 writeln(ouf,'');
 writeln(ouf,'Strings:');
 wrotb(ouf,tst);
 //writeln(ouf,'');
 //writeln(ouf,'Defined:');
 //for i:=0 to length(dirs)-1 do writeln(ouf,dirs[i]);
 writeln(ouf,'');
 writeln(ouf,'-------------------------------');
 for i:=0 to length(mlex)-1 do begin
  case mlex[i].cl of
   CL_SEP:s1:='SEP';
   CL_RW:s1:='RW';
   CL_NUM:s1:='NUM';
   CL_ID:s1:='ID';
   CL_STR:s1:='STR';
   else s1:='etc'+stri(mlex[i].cl);
  end;

  write(ouf,s1+':',mlex[i].pos,' ');
 end;

 writeln(ouf);
 closefile(ouf);
end;
//##############################################################################
//##############################################################################
//##############################################################################
//##############################################################################
//##############################################################################
//##############################################################################
//##############################################################################
//##############################################################################
//##############################################################################
function lgen(olex:lext):codt;
var ocod:codt;
p,st:integer;
i,j:integer; 

procedure addnum(n:double);
var k:integer;
begin {$ifdef thedbg}write('lgen.addnum:');{$endif}
 k:=length(ocod);
 setlength(ocod,k+1);
 ocod[k].typ:=TP_NUM;
 ocod[k].pos:=0;
 ocod[k].vl:=n;
 ocod[k].p:='';
 ocod[k].ln:=olex[p].ln;
 ocod[k].sy:=olex[p].sy;
end;
procedure addop(o:integer);
var k:integer;
begin {$ifdef thedbg}write('lgen.addop:');{$endif}
 k:=length(ocod);
 setlength(ocod,k+1);
 ocod[k].typ:=TP_OP;
 ocod[k].pos:=o;
 ocod[k].vl:=0;
 ocod[k].p:='';
 ocod[k].ln:=olex[p].ln;
 ocod[k].sy:=olex[p].sy;
end;
procedure addvar(v:string);
var k,j,i:integer;
begin {$ifdef thedbg}write('lgen.addvar:');{$endif}
 k:=length(ocod);
 setlength(ocod,k+1);
 j:=-1;
 for i:=0 to length(vars)-1 do if vars[i].nam=v then begin j:=i; break; end;
 if j=-1 then begin
  j:=length(vars);
  setlength(vars,j+1);
  vars[j].nam:=v;
  vars[j].vl:=0; 
 end;
 ocod[k].typ:=TP_VAR;
 ocod[k].pos:=j;
 ocod[k].vl:=0;
 ocod[k].p:=v;
 ocod[k].ln:=olex[p].ln;
 ocod[k].sy:=olex[p].sy;
end;
procedure addfnc(v:integer);
var k:integer;
begin {$ifdef thedbg}write('lgen.addfnc:');{$endif}
 k:=length(ocod);
 setlength(ocod,k+1);
 ocod[k].typ:=TP_FUN;
 ocod[k].pos:=v;
 ocod[k].vl:=0;
 ocod[k].p:=intfs[v].nam;
 ocod[k].ln:=olex[p].ln;
 ocod[k].sy:=olex[p].sy;
end;

begin {$ifdef thedbg}write('lgen:');{$endif}
 p:=0;
 setlength(ocod,0);

 st:=GST_H;
 if length(olex)<>0 then while not(((olex[p].cl=CL_SEP)and(olex[p].pos=S_EOP))or(st=GST_FIN)or(p>=length(olex))) do case st of
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////// Interface segment /////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  GST_H:case olex[p].cl of
   CL_RW:begin
//    if TW[olex[p].pos].str='div' then begin progset(PT_PROG); continue; end;
    if TW[olex[p].pos].str='and' then begin addop(S_RAND); p:=p+1; continue; end;
    if TW[olex[p].pos].str='or' then begin addop(S_ROR); p:=p+1; continue; end;
    if TW[olex[p].pos].str='xor' then begin addop(S_RXOR); p:=p+1; continue; end;
    if TW[olex[p].pos].str='not' then begin addop(S_RNOT); p:=p+1; continue; end;
    if TW[olex[p].pos].str='shl' then begin addop(S_RSHL); p:=p+1; continue; end;
    if TW[olex[p].pos].str='shr' then begin addop(S_RSHR); p:=p+1; continue; end;
    {$ifdef thedbg}writeln('Unknown word');{$endif} haltprog;
   end;
   CL_NUM:begin
    addnum(tnum[olex[p].pos].num);
    p:=p+1;
   end;
   CL_ID:begin
    j:=-1;
    for i:=0 to length(intfs)-1 do if intfs[i].nam=tid[olex[p].pos].str then begin addfnc(i); j:=i; break; end;
    if j=-1 then addvar(tid[olex[p].pos].str);
    p:=p+1;
   end;
   CL_SEP:case olex[p].pos of
    S_ASS:begin addop(S_ASS); p:=p+1; end;
    S_NEQU:begin addop(S_NEQU); p:=p+1; end;
    S_EQU:begin addop(S_EQU); p:=p+1; end;
    S_LE:begin addop(S_LE); p:=p+1; end;
    S_GE:begin addop(S_GE); p:=p+1; end;
    S_LW:begin addop(S_LW); p:=p+1; end;
    S_GR:begin addop(S_GR); p:=p+1; end;
    S_MUL:begin addop(S_MUL); p:=p+1; end;
    S_ADD:begin addop(S_ADD); p:=p+1; end;
    S_SUB:begin addop(S_SUB); p:=p+1; end;
    S_INC:begin addop(S_INC); p:=p+1; end;
    S_DEC:begin addop(S_DEC); p:=p+1; end;
    S_DIV:begin addop(S_DIV); p:=p+1; end;
    else begin {$ifdef thedbg}writeln('Unknown sep.');{$endif} haltprog; end;
   end;
   else begin p:=p+1; end;
  end;
 end;
 result:=ocod;
end;
//##############################################################################
//##############################################################################
//##############################################################################
//##############################################################################
//##############################################################################
//##############################################################################
//##############################################################################
//##############################################################################
//##############################################################################
function lrun(noi,e:pointer;var mcod:codt):double;
var p,i,c:integer;
sp:integer;
c1:codtyp;
n1,n2:double;           
stk:array[0..99]of codtyp;    
ps:array[0..99]of double;

fn:function(noi:pointer;e:pointer;pc:integer;v:array of double):double;   
             
function popn:double;
begin {$ifdef thedbg}write('lrun.popn:');{$endif}
 result:=0;
 if sp>=99 then begin {$ifdef thedbg}writeln('stk>=99');{$endif} haltprog; end;
 if stk[sp].typ=TP_OP then begin {$ifdef thedbg}writeln('typ<>TP_NUM');{$endif} haltprog; end;
 case stk[sp].typ of
  TP_NUM:result:=stk[sp].vl;
  TP_VAR:result:=vars[stk[sp].pos].vl;
 end;
 sp:=sp+1;
end;
function popc:codtyp;
begin {$ifdef thedbg}write('lrun.popc:');{$endif}
 if sp>=99 then begin {$ifdef thedbg}writeln('stk>=99');{$endif} haltprog; end;
 result:=stk[sp];
 sp:=sp+1;
end;
procedure pushc(c:codtyp);
begin {$ifdef thedbg}write('lrun.pushc:');{$endif}
 if sp<=0 then begin {$ifdef thedbg}writeln('<=0');{$endif} haltprog; end;
 sp:=sp-1;
 stk[sp]:=c;
end; 
procedure pushn(n:double);
begin {$ifdef thedbg}write('lrun.pushn:');{$endif}
 if sp<=0 then begin {$ifdef thedbg}writeln('<=0');{$endif} haltprog; end;
 sp:=sp-1;
 stk[sp].typ:=TP_NUM;
 stk[sp].vl:=n;
end; 
procedure pushvn(n:double;c:codtyp);
begin {$ifdef thedbg}write('lrun.pushvn:');{$endif}
 if sp<=0 then begin {$ifdef thedbg}writeln('<=0');{$endif} haltprog; end;
 sp:=sp-1;
 stk[sp]:=c;
 vars[c.pos].vl:=n;
end; 

begin {$ifdef thedbg}write('lrun:');{$endif}
 sp:=99; result:=0; p:=0;
 if length(mcod)<>0 then while p<length(mcod) do case mcod[p].typ of
  TP_FUN:begin 
   c:=intfs[mcod[p].pos].pc;
   if c>=0 then begin        
    if c>=99 then begin {$ifdef thedbg}writeln('pc>=99');{$endif} haltprog; end;
    for i:=0 to c-1 do ps[i]:=popn;
    fn:=intfs[mcod[p].pos].p;
    pushn(fn(noi,e,c,ps)); 
   end;
   if c=-1 then begin
    c:=round(popn);    
    if c>=99 then begin {$ifdef thedbg}writeln('pc>=99');{$endif} haltprog; end;
    for i:=0 to c-1 do ps[i]:=popn;
    fn:=intfs[mcod[p].pos].p;
    pushn(fn(noi,e,c,ps)); 
   end;   
   p:=p+1; 
  end;
  TP_VAR:begin pushc(mcod[p]); p:=p+1; end;
  TP_NUM:begin pushc(mcod[p]); p:=p+1; end;
  TP_OP:case mcod[p].pos of
   S_ASS:begin n1:=popn; c1:=popc; pushvn(n1,c1); p:=p+1; end;
   S_ADD:begin pushn(popn+popn); p:=p+1; end;
   S_SUB:begin n1:=popn; n2:=popn; pushn(n2-n1); p:=p+1; end;
   S_MUL:begin pushn(popn*popn); p:=p+1; end;
   S_DIV:begin n1:=popn; n2:=popn; pushn(n2/n1); p:=p+1; end;
   S_DEC:begin pushn(-popn); p:=p+1; end;
   else begin {$ifdef thedbg}writeln('Unknown sep.');{$endif} haltprog; end;
  end;
  else begin {$ifdef thedbg}writeln('Unknown sep.');{$endif} haltprog; end;
 end;
 if sp<>99 then case stk[sp].typ of
  TP_NUM:result:=stk[sp].vl;
  TP_VAR:result:=vars[stk[sp].pos].vl;  
 end;
end;
//##############################################################################
//##############################################################################
//##############################################################################
//##############################################################################
//##############################################################################
//##############################################################################
//##############################################################################
//##############################################################################
//##############################################################################
function ifccurv(e:pointer;pc:integer;v:array of double):double;
var k,i:integer;
xd,yd:adouble;
begin
 k:=(pc-1)div 2;
 setlength(xd,k);setlength(yd,k);
 for i:=0 to k-1 do begin xd[i]:=v[1+2*i+0]; yd[i]:=v[1+2*i+1];end;
 result:=l(v[0],xd,yd);
end;
function ifctrimz(e:pointer;pc:integer;v:array of double):double;begin result:=v[0]; if v[0]<v[1] then result:=v[1] else if v[0]>v[2] then result:=2*v[2]-v[0];end;
function ifctrim(e:pointer;pc:integer;v:array of double):double;begin result:=v[0]; if v[0]<v[1] then result:=v[1] else if v[0]>v[2] then result:=v[2];end;
function ifcsin(e:pointer;pc:integer;v:array of double):double;begin result:=sin(v[0]);end;
function ifccos(e:pointer;pc:integer;v:array of double):double;begin result:=cos(v[0]);end;
function ifcsqrt(e:pointer;pc:integer;v:array of double):double;begin result:=sqrt(v[0]);end;
function ifcsqr(e:pointer;pc:integer;v:array of double):double;begin result:=sqr(v[0]);end;
function ifctan(e:pointer;pc:integer;v:array of double):double;begin result:=tan(v[0]);end;
function ifcln(e:pointer;pc:integer;v:array of double):double;begin result:=ln(v[0]);end;
function ifcpow(e:pointer;pc:integer;v:array of double):double;begin result:=pow(v[0],v[1]);end;    
function ifcround(e:pointer;pc:integer;v:array of double):double;begin result:=round(v[0]);end;
function ifctrunc(e:pointer;pc:integer;v:array of double):double;begin result:=trunc(v[0]);end;
function ifcmax2(e:pointer;pc:integer;v:array of double):double;begin result:=max2(v[0],v[1]);end;
function ifcmax3(e:pointer;pc:integer;v:array of double):double;begin result:=max3(v[0],v[1],v[2]);end;
function ifcmin2(e:pointer;pc:integer;v:array of double):double;begin result:=min2(v[0],v[1]);end;
function ifcmin3(e:pointer;pc:integer;v:array of double):double;begin result:=min3(v[0],v[1],v[2]);end;
  

procedure addifc(nam:string;pc:integer;lnk:pointer);
var n:integer;
begin
 n:=length(intfs);
 setlength(intfs,n+1);
 intfs[n].nam:=nam; 
 intfs[n].pc:=pc; 
 intfs[n].p:=lnk;
end;
procedure initsys;
begin 
 setlength(tnum,2);
 tnum[0].num:=0; tnum[0].str:=stri(0);
 tnum[1].num:=1; tnum[1].str:=stri(1);

//------------------------------------------------------------------------------------//
 
 setlength(intfs,0); 
 addifc('sin',1,@ifcsin);
 addifc('cos',1,@ifccos);
 addifc('sqrt',1,@ifcsqrt);
 addifc('sqr',1,@ifcsqr);
 addifc('tan',1,@ifctan);  
 addifc('ln',1,@ifcln);
 addifc('pow',2,@ifcpow);
 addifc('round',1,@ifcround);
 addifc('trunc',1,@ifctrunc);
 addifc('max2',2,@ifcmax2);
 addifc('max3',3,@ifcmax3);
 addifc('min2',2,@ifcmin2);
 addifc('min3',3,@ifcmin3);
 addifc('curv',-1,@ifccurv);  
 addifc('trim',3,@ifctrim);
 addifc('trimz',3,@ifctrimz);
 {addifc('halt',0,nil,@ifchalt);
 addifc('val',0,nil,@ifcval);
 addifc('str',0,nil,@ifcstr);
 addifc('valfi',0,bstyp[03],@ifcvalfi);
 addifc('valfd',0,bstyp[10],@ifcvalfd);
 addifc('strf',0,bstyp[08],@ifcstrf);
 addifc('inc',0,nil,@ifcinc);
 addifc('dec',0,nil,@ifcdec);
 addifc('sin',0,bstyp[10],@ifcsin);
 addifc('cos',0,bstyp[10],@ifccos);
 addifc('exp',0,bstyp[10],@ifcexp);
 addifc('arctan',0,bstyp[10],@ifcarctan);
 addifc('frac',0,bstyp[10],@ifcfrac);
 addifc('int',0,bstyp[10],@ifcint);
 addifc('ln',0,bstyp[10],@ifcln);
 addifc('pi',0,bstyp[10],@ifcpi);
 addifc('sqrt',0,bstyp[10],@ifcsqrt);
 addifc('tan',0,bstyp[10],@ifctan);
 addifc('round',0,bstyp[03],@ifcround);
 addifc('trunc',0,bstyp[03],@ifctrunc);
 
 ci:=length(intfs);
 cu:=length(uifs);
 setlength(intfs,ci+cu);
 for i:=ci to ci+cu-1 do intfs[i]:=uifs[i-ci]; 

 ci:=length(bscns);
 cu:=length(ucns);
 setlength(bscns,ci+cu); 
 for i:=ci to ci+cu-1 do new(bscns[i]);
 for i:=ci to ci+cu-1 do new(bscns[i].value);  
 for i:=ci to ci+cu-1 do bscns[i]^:=ucns[i-ci]^; 
 for i:=ci to ci+cu-1 do bscns[i]^.value^:=ucns[i-ci]^.value^; 
 }
end;

procedure maininit;
begin
 setlength(TD,30);
 td[00].str:=' ';  td[01].str:=';';  td[02].str:=',';  td[03].str:='.';
 td[04].str:='=';  td[05].str:=':';  td[06].str:=':='; td[07].str:='^';
 td[08].str:='#';  td[09].str:='$';  td[10].str:='@';  td[11].str:='[';
 td[12].str:=']';  td[13].str:='(';  td[14].str:=')';  td[15].str:='''';
 td[16].str:='/';  td[17].str:='//'; td[18].str:='>';  td[19].str:='<';  
 td[20].str:='>='; td[21].str:='<='; td[22].str:='<>'; td[23].str:='\';
 td[24].str:='*';  td[25].str:='+';  td[26].str:='-';  td[27].str:='++'; 
 td[28].str:='--'; td[29].str:='..';
 
//------------------------------------------------------------------------------------//
 
 setlength(TW,11);
 tw[00].str:='nil';
 tw[01].str:='div'; tw[02].str:='mod'; tw[03].str:='and'; tw[04].str:='or';
 tw[05].str:='xor'; tw[06].str:='not'; tw[07].str:='shr'; tw[08].str:='shl';
 tw[09].str:='true'; tw[10].str:='false';

//------------------------------------------------------------------------------------//
end;
//##############################################################################
//##############################################################################
//##############################################################################
//##############################################################################
//##############################################################################
//##############################################################################
//##############################################################################
//##############################################################################
//##############################################################################
function evalexpr(noi,e:pointer;s:string):double;
var a:astr;
mlex:lext;
mcod:codt;
begin
 setlength(a,1); a[0]:=s;
 lexan(a,mlex);
 //lexngen('lex.out',mlex);
 mcod:=lgen(mlex);
 result:=lrun(noi,e,mcod);
end;

function compexpr(s:string):codt;
var a:astr;
mlex:lext;
begin
 setlength(a,1); a[0]:=s;
 lexan(a,mlex);
 //lexngen('lex.out',mlex);
 result:=lgen(mlex);
end;

function runexpr(noi,e:pointer;var c:codt):double;
begin
 if length(c)=0 then begin result:=0; exit; end;
 if (length(c)=1)and(c[0].typ=TP_NUM) then begin result:=c[0].vl; exit; end;
 result:=lrun(noi,e,c);
end;

function tree2expr(t:ppolcodtree):string;
function clnode(cn:ppolcodtree):string;
var i:integer;
begin
 result:=cn.nam;
 for i:=0 to length(cn.ch)-1 do result:=clnode(cn.ch[i])+' '+result;
end;
begin
 result:=clnode(t);
end;

function expr2tree(var mcod:codt;var ap:appolct):ppolcodtree;
var ch:array of ppolcodtree;
n:ppolcodtree;
i,p,c:integer;
begin
 p:=0;
 c:=0;
 setlength(ch,0);
 setlength(ap,0);
 //result:=nil;
 if length(mcod)<>0 then while p<length(mcod) do begin
  case mcod[p].typ of
   TP_FUN:begin   
    new(n);            
    n.tp:=1;
    c:=intfs[mcod[p].pos].pc;  
    if c=-1 then n.tp:=11;
    if c=-1 then c:=round(ch[length(ch)-1].vl)+1;
    n.nam:=intfs[mcod[p].pos].nam;
    n.vl:=0;
    setlength(n.ch,c);
    for i:=0 to c-1 do n.ch[i]:=ch[length(ch)-1-i];
    setlength(ch,length(ch)-c+1);
    ch[length(ch)-1]:=n;
    setlength(ap,length(ap)+1);ap[length(ap)-1]:=n;n.id:=length(ap)-1;
   end;
   TP_VAR:begin
    new(n);n.tp:=2;n.nam:=vars[mcod[p].pos].nam;n.vl:=vars[mcod[p].pos].vl;
    setlength(n.ch,0);
    setlength(ch,length(ch)+1);ch[length(ch)-1]:=n;
    setlength(ap,length(ap)+1);ap[length(ap)-1]:=n;n.id:=length(ap)-1;
   end;
   TP_NUM:begin
    new(n);n.tp:=3;n.nam:=stre(mcod[p].vl);n.vl:=mcod[p].vl;
    setlength(n.ch,0);
    setlength(ch,length(ch)+1);ch[length(ch)-1]:=n;
    setlength(ap,length(ap)+1);ap[length(ap)-1]:=n;n.id:=length(ap)-1;
   end;
   TP_OP:begin
    new(n);n.tp:=4;n.vl:=0;
    case mcod[p].pos of
     S_ASS:begin n.nam:='='; c:=2; end;
     S_ADD:begin n.nam:='+'; c:=2; end;
     S_SUB:begin n.nam:='-'; c:=2; end;
     S_MUL:begin n.nam:='*'; c:=2; end;
     S_DIV:begin n.nam:='/'; c:=2; end;
     S_DEC:begin n.nam:='--'; c:=1; end;
    end;
    setlength(n.ch,c);
    for i:=0 to c-1 do n.ch[i]:=ch[length(ch)-1-i];
    setlength(ch,length(ch)-c+1);
    ch[length(ch)-1]:=n;
    setlength(ap,length(ap)+1);ap[length(ap)-1]:=n;n.id:=length(ap)-1;
   end;
  end;
  p:=p+1;
 end;
 result:=ch[0]; 
end;

begin
 maininit;
 initsys;
// if paramcount<>1 then exit;

// writeln(evalexpr(paramstr(1)):10:10);
end.

