//############################################################################//
unit jpg;
{$ifdef FPC}{$MODE delphi}{$endif}
{$ifdef ape3}{$define bgr}{$endif}
interface
uses asys,grph,grplib,strval,tim{$ifdef VFS},vfs,vfsutils{$endif}{$ifdef ape3},vfsint,akernel{$endif};
//############################################################################//      
function ldjpgbuf(ibuf:pointer;ibs:integer;wtx,wa:boolean;trc:crgb;var bx,by:integer;var p:pointer):pointer;     
function isjpgbuf(ibuf:pointer;ibs:integer):boolean; 
function ldjpg(fn:string;wtx,wa:boolean;trc:crgb;var bx,by:integer;var p:pointer):pointer;  
function isjpg(fn:string):boolean;  
procedure jpg_mode_set(isint:boolean);
//############################################################################//
var jpg_cur_dec_prc:double;      
jpg_use_int:boolean=false;
{$ifdef jpg_stat}jpg_stat_str:string;{$endif}
//############################################################################//
implementation  
//############################################################################//
const
SOI=$D8;
EOI=$D9;
APP0=$E0;
APP1=$E1;
SOF=$C0;
DQT=$DB;
DHT=$C4;
SOS=$DA;
DRI=$DD;
COM=$FE;
  
zigzag:array[0..63]of byte=
(0, 1, 5, 6,14,15,27,28,
 2, 4, 7,13,16,26,29,42,
 3, 8,12,17,25,30,41,43,
 9,11,18,24,31,40,44,53,
10,19,23,32,39,45,52,54,
20,22,33,38,46,51,55,60,
21,34,37,47,50,56,59,61,
35,36,48,49,57,58,62,63);
neg_pow2:array[0..15]of smallint=(0,-1,-3,-7,-15,-31,-63,-127,-255,-511,-1023,-2047,-4095,-8191,-16383,-32767);
RANGE_MASK=1023;
//############################################################################//
type
a63s=array[0..63]of smallint;
pa63s=^a63s;
a63b=array[0..63]of byte;
a16w=array[0..16]of word;
a65535b=array[0..65535]of byte;

Huffman_table=record
 Length:array[0..16]of byte;  // k =1-16 ; L[k] indicates the number of Huffman codes of length k
 minor_code:a16w;  // indicates the value of the smallest Huffman code of length k
 major_code:a16w;  // similar, but the highest code
 V:a65535b;  // V[k][j] = Value associated to the j-th Huffman code of length k
 // High nibble = nr of previous 0 coefficients
 // Low nibble = size (in bits) of the coefficient which will be taken from the data stream
end;
pHuffman_table=^Huffman_table;

jpg_header=packed record
 h0,h1:byte;
 h2,h3:byte;
 h4,h5:byte;
 jfif:array[0..3]of char;
 jfifz:byte;
 vers,vers_lo,units:byte;
 Xdensity,Ydensity:word;
 Xthumbnail,Ythumbnail:byte; 
end;
//############################################################################//
jpg_dec_rec=record
 buf,ibuf:pbytea; // the buffer we use for storing the entire JPG file
 ibs:integer;
 byte_pos:dword; // current byte position

 X_round,Y_round:word; // The dimensions rounded to multiple of Hmax*8 (X_round) and Ymax*8 (Y_round)

 out_buffer:pbytea; // RGBA image buffer
 X_image_bytes:dword; // size in bytes of 1 line of the image = X_round * 4
 y_inc_value:dword; // 32*X_round; // used by decode_MCU_1x2,2x1,2x2

 YH,YV,CbH,CbV,CrH,CrV:byte; // sampling factors (horizontal and vertical) for Y,Cb,Cr
 Hmax,Vmax:word;

 f_QT:array[0..3]of array[0..63]of single; // quantization tables, no more than 4 quantization tables (QT[0..3])
 i_QT:array[0..3]of array[0..63]of integer; // quantization tables, no more than 4 quantization tables (QT[0..3])
 HTDC:array[0..3]of Huffman_table; //DC huffman tables , no more than 4 (0..3)
 HTAC:array[0..3]of Huffman_table; //AC huffman tables                  (0..3)

 YQ_nr,CbQ_nr,CrQ_nr:byte; // quantization table number for Y, Cb, Cr
 YDC_nr,CbDC_nr,CrDC_nr:byte; // DC Huffman table number for Y,Cb, Cr
 YAC_nr,CbAC_nr,CrAC_nr:byte; // AC Huffman table number for Y,Cb, Cr

 Restart_markers:byte; // if 1 => Restart markers on , 0 => no restart markers
 MCU_restart:word; //Restart markers appears every MCU_restart MCU blocks

 DCY,DCCb,DCCr:smallint; // Coeficientii DC pentru Y,Cb,Cr
 DCT_coeff:a63s; // Current DCT_coefficients
 Y,Cb,Cr:a63b; // Y, Cb, Cr of the current 8x8 block for the 1x1 case
 Y_1,Y_2,Y_3,Y_4:a63b;
 tab_1,tab_2,tab_3,tab_4:a63b; // tabelele de supraesantionare pt cele 4 blocuri

 d_k:byte;      //Bit displacement in memory, relative to the offset of w1. it's always <16
 w1,w2:word;    //w1=First word in memory; w2=Second word
 wordval:word; //the actual used value in Huffman decoding.
end;
pjpg_dec_rec=^jpg_dec_rec;
//############################################################################//
var
mask:array[0..16]of dword;
Cr_tab,Cb_tab:array[0..255]of smallint; // Precalculated Cr, Cb tables
Cr_Cb_green_tab:array[0..65535]of smallint;               
rlimit_table:pbytea;   
//############################################################################//   
IDCT_transform:procedure(j:pjpg_dec_rec;var incoeff:a63s;var outcoeff:a63b;Q_nr:byte);
//############################################################################//  
{$ifdef jpg_stat}t_h,t_i:int64;{$endif}
//############################################################################//  
//############################################################################//
function read_byte(j:pjpg_dec_rec):byte; {$ifndef ape3}{$ifdef fpc}inline;{$endif}{$endif}
begin
 result:=j.buf[j.byte_pos];
 inc(j.byte_pos);
end;   
//############################################################################//  
function read_word(j:pjpg_dec_rec):word; {$ifndef ape3}{$ifdef fpc}inline;{$endif}{$endif}
begin
 result:=j.buf[j.byte_pos] shl 8+j.buf[j.byte_pos+1]; 
 j.byte_pos:=j.byte_pos+2
end;
//############################################################################//  
function RIGHT_SHIFT(x,shft:integer):integer;{$ifndef ape3}{$ifdef fpc}inline;{$endif}{$endif}
var shift_temp:integer;  
begin
 shift_temp:=x;
 if shift_temp<0 then 
  result:=(shift_temp shr shft)or((not 0) shl (32-(shft))) else
  result:=(shift_temp shr shft)
end;
function idescale(x,n:integer):integer;{$ifndef ape3}{$ifdef fpc}inline;{$endif}{$endif}begin result:=RIGHT_SHIFT(x+(1 shl (n-1)),n);end; 
function descale(x,n:integer):integer;{$ifndef ape3}{$ifdef fpc}inline;{$endif}{$endif}begin result:=RIGHT_SHIFT(x,n);end; 
//function descale(x,n:integer):dword;{$ifndef ape3}{$ifdef fpc}inline;{$endif}{$endif}begin result:=(x+(1 shl (n-1)))shr n;end; 
function lookKbits(j:pjpg_dec_rec;k:byte):word;{$ifndef ape3}{$ifdef fpc}inline;{$endif}{$endif}
begin 
 result:=j.wordval shr (16-k);
 //writeln('j.wordval=',j.wordval,' k=',k);
end;
function WORD_hi_lo(bhigh,blow:byte):word;{$ifndef ape3}{$ifdef fpc}inline;{$endif}{$endif}begin result:=blow+bhigh shl 8;end;
//############################################################################//  
// k>0 always
// Takes k bits out of the BIT stream (wordval), and makes them a signed value
function get_svalue(j:pjpg_dec_rec;k:byte):smallint;
var r:dword;
begin   
 r:=j.wordval;
 r:=r shl k;
 r:=r shr 16;
 dec(k);
 
 if not((r and (1 shl k))<>0) then r:=r+dword(neg_pow2[k+1]);
 result:=smallint(r);
end;
//############################################################################//    
procedure skipKbits(j:pjpg_dec_rec;k:byte);
var b_high,b_low,b:byte;
begin  
 j.d_k:=j.d_k+k;
 if(j.d_k>=16)then begin 
  j.d_k:=j.d_k-16;
  j.w1:=j.w2;

  //Get the next word in j.w2
  b:=read_byte(j);
  if(b<>$FF)then b_high:=b else begin
   if (j.buf[j.byte_pos]=0)then inc(j.byte_pos) //skip 00
                           else dec(j.byte_pos); // stop j.byte_pos pe restart marker
   b_high:=$FF;
  end;
  b:=read_byte(j);
  if (b<>$FF)then b_low:=b else begin
   if (j.buf[j.byte_pos]=0)then inc(j.byte_pos) //skip 00
                           else dec(j.byte_pos); // stop j.byte_pos pe restart marker
   b_low:=$FF;
  end;
  j.w2:=WORD_hi_lo(b_high,b_low);
 end;

 j.wordval:=(((j.w1 shl 16)+j.w2)shl j.d_k)shr 16; 
end;
//############################################################################//  
function getKbits(j:pjpg_dec_rec;k:byte):smallint;{$ifndef ape3}{$ifdef fpc}inline;{$endif}{$endif}
begin
 result:=get_svalue(j,k);
 skipKbits(j,k);
end;
//############################################################################//  
procedure load_quant_table(j:pjpg_dec_rec;quant_table:psinglea);
const scalefactor:array[0..7]of single=(1,1.387039845,1.306562965,1.175875602,1,0.785694958,0.541196100,0.275899379); 
var k,row,col:byte;
begin
 //from zig-zag order
 for k:=0 to 63 do quant_table[k]:=j.buf[j.byte_pos+zigzag[k]];
 k:=0;
 for row:=0 to 7 do for col:=0 to 7 do begin
  quant_table[k]:=quant_table[k]*scalefactor[row]*scalefactor[col];
  k:=k+1;
 end;
 j.byte_pos:=j.byte_pos+64;
end;
//############################################################################//  
procedure int_load_quant_table(j:pjpg_dec_rec;quant_table:pinta);
const aanscales:array[0..63]of integer=(
	  16384, 22725, 21407, 19266, 16384, 12873,  8867,  4520,
	  22725, 31521, 29692, 26722, 22725, 17855, 12299,  6270,
	  21407, 29692, 27969, 25172, 21407, 16819, 11585,  5906,
	  19266, 26722, 25172, 22654, 19266, 15137, 10426,  5315,
	  16384, 22725, 21407, 19266, 16384, 12873,  8867,  4520,
	  12873, 17855, 16819, 15137, 12873, 10114,  6967,  3552,
	   8867, 12299, 11585, 10426,  8867,  6967,  4799,  2446,
	   4520,  6270,  5906,  5315,  4520,  3552,  2446,  1247
	);
var k:integer;
begin
 for k:=0 to 63 do quant_table[k]:=iDESCALE(integer(j.buf[j.byte_pos+zigzag[k]])*aanscales[k],14-2);
 j.byte_pos:=j.byte_pos+64;
end;
//############################################################################//  
procedure load_Huffman_table(j:pjpg_dec_rec;HT:pHuffman_table);
var k,i:integer;
code:dword; 
begin
 for i:=1 to 16 do HT^.Length[i]:=read_byte(j);
 for k:=1 to 16 do for i:=0 to HT^.Length[k]-1 do HT^.V[WORD_hi_lo(k,i)]:=read_byte(j);

 code:=0;
 for k:=1 to 16 do begin
  HT^.minor_code[k]:=code;
  for i:=1 to HT^.Length[k] do inc(code);
  HT^.major_code[k]:=code-dword(1*ord(code<>0));
  code:=code*2;
  if(HT^.Length[k]=0)then begin
   HT^.minor_code[k]:=$FFFF;
   HT^.major_code[k]:=0;
  end;
 end;
end;
//############################################################################//                                                                         
// Process one data unit. A data unit = 64 DCT coefficients
// Data is decompressed by Huffman decoding, then the array is dezigzag-ed
// The result is a 64 DCT coefficients array: DCT_coeff
procedure process_Huffman_data_unit(j:pjpg_dec_rec;DC_nr,AC_nr:byte;previous_DC:psmallint);
var nr,k,i,EOB_found,size_val,count_0,byte_temp:byte;
tmp_Hcode:word;
min_code,maj_code:^a16w;
max_val,min_val:word;
huff_values:^a65535b;
DCT_tcoeff:array[0..63]of smallint; 
min_valn,max_valn:integer; 
begin        
 {$ifdef jpg_stat}dt:=getdt;stdt(dt);{$endif}
 //Start Huffman decoding
 //First the DC coefficient decoding    
 min_code:=@j.htdc[DC_nr].minor_code;  
 maj_code:=@j.htdc[DC_nr].major_code; 
 huff_values:=@j.htdc[DC_nr].V;
                                
 for nr:=0 to 63 do DCT_tcoeff[nr]:=0; //Initialize DCT_tcoeff
                       
 min_valn:=1;max_valn:=1;
 min_val:=min_code[1]; max_val:=maj_code[1]; 
 for k:=1 to 16 do begin
  tmp_Hcode:=lookKbits(j,k);
  if ( (tmp_Hcode<=max_val) and (tmp_Hcode>=min_val) )then begin //Found a valid Huffman code
   skipKbits(j,k);
   size_val:=huff_values[WORD_hi_lo(k,tmp_Hcode-min_val)];
   if (size_val=0)then DCT_tcoeff[0]:=previous_DC^ else begin
    DCT_tcoeff[0]:=previous_DC^+getKbits(j,size_val);
    previous_DC^:=DCT_tcoeff[0];
   end;
   break;
  end;
  min_valn:=min_valn+1; max_valn:=max_valn+1; 
  min_val:=min_code[min_valn]; max_val:=maj_code[max_valn];
 end;            
         
 // Second, AC coefficient decoding
 min_code:=@j.htac[AC_nr].minor_code;
 maj_code:=@j.htac[AC_nr].major_code;
 huff_values:=@j.htac[AC_nr].V;  
       
 nr:=1; // AC coefficient
 EOB_found:=0;
 //writeln('48119');   
           
 while ( (nr<=63) and (EOB_found=0) )do begin  
 //writeln('48119a, nr=',nr,' EOB_found=',EOB_found);   
  min_valn:=1;max_valn:=1;  
  max_val:=maj_code[1]; min_val:=min_code[1];   
  for k:=1 to 16 do begin       
   tmp_Hcode:=lookKbits(j,k); 
   //writeln('k=',k,' tmp_Hcode=',tmp_Hcode);
   if ( (tmp_Hcode<=max_val) and (tmp_Hcode>=min_val) )then begin
    skipKbits(j,k);
    byte_temp:=huff_values[WORD_hi_lo(k,tmp_Hcode-min_val)];
    size_val:=byte_temp and $F;
    count_0:=byte_temp shr 4;
    if (size_val=0)then begin 
     if (count_0=0)then EOB_found:=1 else if (count_0=$F)then nr:=nr+16; //skip 16 zeroes
    end else begin
     nr:=nr+count_0; //skip count_0 zeroes
     DCT_tcoeff[nr]:=getKbits(j,size_val);
     nr:=nr+1;
    end;
    break;
   end;
   min_valn:=min_valn+1; max_valn:=max_valn+1; 
   min_val:=min_code[min_valn]; max_val:=maj_code[max_valn];
  end;  
  if(k>16)then inc(nr);  // This should not occur   
 //writeln('48119e, k=',k,' nr=',nr);
 //readln;   
 end; 
                 
 for i:=0 to 63 do j.DCT_coeff[i]:=DCT_tcoeff[zigzag[i]];  
 {$ifdef jpg_stat}t_h:=t_h+rtdt(dt);freedt(dt);{$endif} 
end;
//############################################################################//                 
// Fast float IDCT transform
procedure flt_IDCT_transform(j:pjpg_dec_rec;var incoeff:a63s;var outcoeff:a63b;Q_nr:byte);
type a63f=array[0..63]of single;
var x:byte;
y:integer;
inptr:^a63s;
outptr:^a63b;
workspace:a63f;
wsptr:^a63f;//Workspace pointer
quantptr:psinglea; // Quantization table pointer
dcval,tmp0,tmp1,tmp2,tmp3,tmp4,tmp5,tmp6,tmp7,tmp10,tmp11,tmp12,tmp13,z5,z10,z11,z12,z13:single;
range_limit:pbytea;   
begin 
 {$ifdef jpg_stat}dt:=getdt;stdt(dt);{$endif}
 range_limit:=@rlimit_table[128]; 
            
 //Pass 1: process COLUMNS from input and store into work array.
 wsptr:=@workspace[0];
 inptr:=@incoeff;
 quantptr:=@j.f_qt[Q_nr][0];     
 for y:=0 to 7 do begin
  if( (inptr[8] or inptr[16] or inptr[24] or inptr[32] or inptr[40] or inptr[48] or inptr[56])=0)then begin
   //AC terms all zero (in a column)
   dcval:=inptr^[0]*quantptr[0];
   wsptr[0] :=dcval;
   wsptr[8] :=dcval;
   wsptr[16]:=dcval;
   wsptr[24]:=dcval;
   wsptr[32]:=dcval;
   wsptr[40]:=dcval;
   wsptr[48]:=dcval;
   wsptr[56]:=dcval;
   //advance pointers to next column
   inptr:=@inptr[1];
   quantptr:=@quantptr[1];
   wsptr:=@wsptr[1];
   continue;
  end;      
   //Even part
  tmp0:=inptr[0] *quantptr[0];
  tmp1:=inptr[16]*quantptr[16];
  tmp2:=inptr[32]*quantptr[32];
  tmp3:=inptr[48]*quantptr[48];

  tmp10:=tmp0+tmp2;//phase 3
  tmp11:=tmp0-tmp2;

  tmp13:=tmp1+tmp3;//phases 5-3
  tmp12:=(tmp1-tmp3)*1.414213562-tmp13;

  tmp0:=tmp10+tmp13;//phase 2
  tmp3:=tmp10-tmp13;
  tmp1:=tmp11+tmp12;
  tmp2:=tmp11-tmp12;

  //Odd part
  tmp4:=inptr[8] *quantptr[8];
  tmp5:=inptr[24]*quantptr[24];
  tmp6:=inptr[40]*quantptr[40];
  tmp7:=inptr[56]*quantptr[56];

  z13:=tmp6+tmp5;//phase 6
  z10:=tmp6-tmp5;
  z11:=tmp4+tmp7;
  z12:=tmp4-tmp7;

  tmp7:=z11+z13;//phase 5
  tmp11:=(z11-z13)*1.414213562;

  z5:=(z10+z12)*1.847759065;
  tmp10:=1.082392200*z12-z5;
  tmp12:=-2.613125930*z10+z5;

  tmp6:=tmp12-tmp7;//phase 2
  tmp5:=tmp11-tmp6;
  tmp4:=tmp10+tmp5;

  wsptr[0] :=tmp0+tmp7;
  wsptr[56]:=tmp0-tmp7;
  wsptr[8] :=tmp1+tmp6;
  wsptr[48]:=tmp1-tmp6;
  wsptr[16]:=tmp2+tmp5;
  wsptr[40]:=tmp2-tmp5;
  wsptr[32]:=tmp3+tmp4;
  wsptr[24]:=tmp3-tmp4;
  //advance pointers to next column
  inptr:=@inptr[1];
  quantptr:=@quantptr[1];
  wsptr:=@wsptr[1];
 end;      
              
 //Pass 2: process ROWS from work array, store into output array.
 //Note that we must descale the results by a factor of 8 = 2^3
 outptr:=@outcoeff;
 wsptr:=@workspace[0];  
 for x:=0 to 7 do begin    
  //Even part
  tmp10:=wsptr[0]+wsptr[4];
  tmp11:=wsptr[0]-wsptr[4];

  tmp13:= wsptr[2]+wsptr[6];
  tmp12:=(wsptr[2]-wsptr[6])*1.414213562-tmp13;

  tmp0:=tmp10+tmp13;
  tmp3:=tmp10-tmp13;
  tmp1:=tmp11+tmp12;
  tmp2:=tmp11-tmp12;

  //Odd part
  z13:=wsptr[5]+wsptr[3];
  z10:=wsptr[5]-wsptr[3];
  z11:=wsptr[1]+wsptr[7];
  z12:=wsptr[1]-wsptr[7];

  tmp7:=z11+z13;
  tmp11:=(z11-z13)*1.414213562;

  z5:=(z10+z12)*1.847759065;
  tmp10:=1.082392200*z12-z5;
  tmp12:=-2.613125930*z10+z5;

  tmp6:=tmp12-tmp7;
  tmp5:=tmp11-tmp6;
  tmp4:=tmp10+tmp5;
                         
  //Final output stage: scale down by a factor of 8
  outptr[0]:=range_limit[(iDESCALE(round(tmp0+tmp7),3))and 1023];  
  outptr[7]:=range_limit[(iDESCALE(round(tmp0-tmp7),3))and 1023];  
  outptr[1]:=range_limit[(iDESCALE(round(tmp1+tmp6),3))and 1023];
  outptr[6]:=range_limit[(iDESCALE(round(tmp1-tmp6),3))and 1023];
  outptr[2]:=range_limit[(iDESCALE(round(tmp2+tmp5),3))and 1023];    
  outptr[5]:=range_limit[(iDESCALE(round(tmp2-tmp5),3))and 1023];
  outptr[4]:=range_limit[(iDESCALE(round(tmp3+tmp4),3))and 1023];
  outptr[3]:=range_limit[(iDESCALE(round(tmp3-tmp4),3))and 1023];  
                         
  //advance pointer to the next row
  wsptr:=@wsptr[8];
  outptr:=@outptr[8];
 end;     
 {$ifdef jpg_stat}t_i:=t_i+rtdt(dt);freedt(dt);{$endif}
end;    
//############################################################################//  
procedure int_IDCT_transform(j:pjpg_dec_rec;var incoeff:a63s;var outcoeff:a63b;Q_nr:byte);
type a63i=array[0..63]of integer;
var i:integer;
inptr:^a63s;
outptr:^a63b;  
workspace:a63i;      
wsptr:^a63i;//Workspace pointer
quantptr:pinta; // Quantization table pointer
range_limit:pbytea;     
dcval,tmp4,tmp5,tmp6,tmp7,tmp10,tmp11,tmp12,tmp13,z5,z10,z11,z12,z13,tmp0,tmp1,tmp2,tmp3:integer;
begin try
 {$ifdef jpg_stat}dt:=getdt;stdt(dt);{$endif}   
 range_limit:=@rlimit_table[128]; 
 //Pass 1: process COLUMNS from input and store into work array.
 wsptr:=@workspace[0];
 inptr:=@incoeff;
 quantptr:=@j.i_qt[Q_nr][0];  
 for i:=7 downto 0 do begin     
  if(inptr[8]=0)and(inptr[16]=0)and(inptr[24]=0)and(inptr[32]=0)and(inptr[40]=0)and(inptr[48]=0)and(inptr[56]=0)then begin  
   //AC terms all zero (in a column)
   dcval:=inptr[0]*quantptr[0];
   wsptr[0] :=dcval;
   wsptr[8] :=dcval;
   wsptr[16]:=dcval;
   wsptr[24]:=dcval;
   wsptr[32]:=dcval;
   wsptr[40]:=dcval;
   wsptr[48]:=dcval;
   wsptr[56]:=dcval; 
   //advance pointers to next column
   inptr:=@inptr[1];
   quantptr:=@quantptr[1];
   wsptr:=@wsptr[1]; 
   continue;
  end;    
  
  //Even part
  tmp0:=inptr[0] *quantptr[0];
  tmp1:=inptr[16]*quantptr[16];
  tmp2:=inptr[32]*quantptr[32];
  tmp3:=inptr[48]*quantptr[48];

  tmp10:=tmp0+tmp2;//phase 3
  tmp11:=tmp0-tmp2;

  tmp13:=tmp1+tmp3;//phases 5-3
  tmp12:=DESCALE((tmp1-tmp3)*362,8)-tmp13;

  tmp0:=tmp10+tmp13;//phase 2
  tmp3:=tmp10-tmp13;
  tmp1:=tmp11+tmp12;
  tmp2:=tmp11-tmp12;

  //Odd part
  tmp4:=inptr[8] *quantptr[8];
  tmp5:=inptr[24]*quantptr[24];
  tmp6:=inptr[40]*quantptr[40];
  tmp7:=inptr[56]*quantptr[56];

  z13:=tmp6+tmp5;//phase 6
  z10:=tmp6-tmp5;
  z11:=tmp4+tmp7;
  z12:=tmp4-tmp7;

  tmp7:=z11+z13;//phase 5    
  tmp11:=DESCALE((z11-z13)*362,8);

  z5:=DESCALE((z10+z12)*473,8);
  tmp10:=DESCALE(277*z12,8)-z5;
  tmp12:=DESCALE(-669*z10,8)+z5;

  tmp6:=tmp12-tmp7;//phase 2
  tmp5:=tmp11-tmp6;
  tmp4:=tmp10+tmp5;

  wsptr[0] :=tmp0+tmp7;
  wsptr[56]:=tmp0-tmp7;
  wsptr[8] :=tmp1+tmp6;
  wsptr[48]:=tmp1-tmp6;
  wsptr[16]:=tmp2+tmp5;
  wsptr[40]:=tmp2-tmp5;
  wsptr[32]:=tmp3+tmp4;
  wsptr[24]:=tmp3-tmp4;
  //advance pointers to next column
  inptr:=@inptr[1];
  quantptr:=@quantptr[1];
  wsptr:=@wsptr[1];   
 end;            
              
 //Pass 2: process ROWS from work array, store into output array.
 //Note that we must descale the results by a factor of 8 = 2^3
 outptr:=@outcoeff;
 wsptr:=@workspace[0];  
 for i:=7 downto 0 do begin 
  //Even part
  tmp10:=wsptr[0]+wsptr[4];
  tmp11:=wsptr[0]-wsptr[4];

  tmp13:= wsptr[2]+wsptr[6];      
  tmp12:=DESCALE((wsptr[2]- wsptr[6])*362,8)-tmp13;

  tmp0:=tmp10+tmp13;
  tmp3:=tmp10-tmp13;
  tmp1:=tmp11+tmp12;
  tmp2:=tmp11-tmp12;

  //Odd part
  z13:=wsptr[5]+wsptr[3];
  z10:=wsptr[5]-wsptr[3];
  z11:=wsptr[1]+wsptr[7];
  z12:=wsptr[1]-wsptr[7];

  tmp7:=z11+z13;          
  tmp11:=DESCALE((z11-z13)*362,8);
                
  z5:=DESCALE((z10+z12)*473,8);
  tmp10:=DESCALE(277*z12,8)-z5;
  tmp12:=DESCALE(-669*z10,8)+z5;

  tmp6:=tmp12-tmp7;
  tmp5:=tmp11-tmp6;
  tmp4:=tmp10+tmp5;
                         
  //Final output stage: scale down by a factor of 8
  outptr[0]:=range_limit[(iDESCALE(tmp0+tmp7,5))and 1023];  
  outptr[7]:=range_limit[(iDESCALE(tmp0-tmp7,5))and 1023];  
  outptr[1]:=range_limit[(iDESCALE(tmp1+tmp6,5))and 1023];
  outptr[6]:=range_limit[(iDESCALE(tmp1-tmp6,5))and 1023];
  outptr[2]:=range_limit[(iDESCALE(tmp2+tmp5,5))and 1023];    
  outptr[5]:=range_limit[(iDESCALE(tmp2-tmp5,5))and 1023];   
  outptr[4]:=range_limit[(iDESCALE(tmp3+tmp4,5))and 1023];
  outptr[3]:=range_limit[(iDESCALE(tmp3-tmp4,5))and 1023];  
                         
  //advance pointer to the next row
  wsptr:=@wsptr[8];
  outptr:=@outptr[8];      
 end;          
 {$ifdef jpg_stat}t_i:=t_i+rtdt(dt);freedt(dt);{$endif} 
 except
  //tl('except');
 end;
end;
//############################################################################//  
procedure convert_8x8_YCbCr_to_RGB(Y,Cb,Cr:pbyte;im_loc,X_image_bytes:dword;out_buffer:pbytea);
var xx,yy:dword;
im_nr:byte;
Y_val,Cb_val,Cr_val:pbyte;
ibuffer:pbytea;   
begin   
 Y_val:=Y;Cb_val:=Cb;Cr_val:=Cr;   
 ibuffer:=@out_buffer[im_loc]; 

 for yy:=0 to 8-1 do begin  
  im_nr:=0;     
  for xx:=0 to 8-1 do begin           
   ibuffer[im_nr+0]:=rlimit_table[Y_val^+Cb_tab[Cb_val^]]; //B  
   ibuffer[im_nr+1]:=rlimit_table[Y_val^+Cr_Cb_green_tab[WORD_hi_lo(Cr_val^,Cb_val^)]]; //G 
   ibuffer[im_nr+2]:=rlimit_table[Y_val^+Cr_tab[Cr_val^]]; // R 
   ibuffer[im_nr+3]:=255; // A  
   im_nr:=im_nr+3;  

   inc(Y_val); 
   inc(Cb_val); 
   inc(Cr_val); 
   inc(im_nr);  
  end;         
  ibuffer:=pointer(intptr(ibuffer)+X_image_bytes);
 end;   
end;
//############################################################################//  
procedure convert_8x8_YCbCr_to_RGB_tab(Y,Cb,Cr,tab:pbyte;im_loc,X_image_bytes:dword;out_buffer:pbytea);
var xx,yy:dword;
im_nr,nr,Y_val,Cb_val,Cr_val:byte;  
ibuffer:pbytea;   
begin
 ibuffer:=@out_buffer[im_loc];
 nr:=0;
 for yy:=0 to 7 do begin
  im_nr:=0;
  for xx:=0 to 7 do begin
   Y_val:=pbyte(intptr(y)+nr)^;
   Cb_val:=pbyte(intptr(Cb)+pbyte(intptr(tab)+nr)^)^;
   Cr_val:=pbyte(intptr(Cr)+pbyte(intptr(tab)+nr)^)^;
   ibuffer[im_nr+0]:=rlimit_table[Y_val+dword(Cb_tab[Cb_val])]; //B    
   ibuffer[im_nr+1]:=rlimit_table[Y_val+dword(Cr_Cb_green_tab[WORD_hi_lo(Cr_val,Cb_val)])]; //G    
   ibuffer[im_nr+2]:=rlimit_table[Y_val+dword(Cr_tab[Cr_val])]; // R    
   ibuffer[im_nr+3]:=255; // A  
   im_nr:=im_nr+4;
   inc(nr);
  end;
  ibuffer:=pointer(intptr(ibuffer)+X_image_bytes);
 end;
end;
//############################################################################//  
procedure calculate_tabs(j:pjpg_dec_rec);
var tab_temp:array[0..255]of byte;
x,y:byte;    
begin
 for y:=0 to 16-1 do for x:=0 to 16-1 do tab_temp[y*16+x]:=(y div j.YV)*8+x div j.YH;

 for y:=0 to 8-1 do begin
  for x:=0 to 8-1  do j.tab_1[y*8+x]:=tab_temp[y*16+x];
  for x:=8 to 16-1 do j.tab_2[y*8+(x-8)]:=tab_temp[y*16+x];
 end;
 for y:=8 to 16-1 do begin
  for x:=0 to 8-1 do j.tab_3[(y-8)*8+x]:=tab_temp[y*16+x];
  for x:=8 to 16-1 do j.tab_4[(y-8)*8+(x-8)]:=tab_temp[y*16+x];
 end;
end;
//############################################################################//  
function load_JPEG_header(j:pjpg_dec_rec;var X_image,Y_image:integer):boolean;
var length_of_file,i,old_byte_pos:dword;
comp_id,qt_info,HT_info,SOS_found,SOF_found,b:byte;
w:word;
htable:pHuffman_table;

xbuf:pbytea;
jhdr:jpg_header;
begin
 result:=false;
 
 xbuf:=j.ibuf;
 length_of_file:=j.ibs; 
 getmem(j.buf,length_of_file+4);
 if j.buf=nil then exit;  
 
 //move(xbuf[0],jhdr,20);
 //move(xbuf[20],j.buf^[0],length_of_file);
             
 move(xbuf[0],jhdr,4);
 if not((jhdr.h0=$FF)and(jhdr.h1=SOI))then begin freemem(j.buf); exit; end;
 if(jhdr.h2=$FF)and(jhdr.h3=APP0)then begin    
  move(xbuf[0],jhdr,20);     
  move(xbuf[20],j.buf^[0],length_of_file);       
  if(jhdr.jfif<>'JFIF')or(jhdr.jfifz<>0)then begin freemem(j.buf); exit; end;
  if (jhdr.vers<>1)then begin freemem(j.buf); exit; end;
  if ((jhdr.Xthumbnail<>0)or(jhdr.Ythumbnail<>0)) then begin freemem(j.buf); exit; end;
 end else if(jhdr.h2=$FF)and(jhdr.h3=APP1)then begin
  i:=xbuf[5]+xbuf[4]*256+2;
  move(xbuf[i],j.buf^[0],length_of_file-i-2);   
  length_of_file:=length_of_file-i-2;     
 end else begin freemem(j.buf); exit; end;       
 j.byte_pos:=0;
 
 //Start decoding process
 SOS_found:=0; SOF_found:=0; j.Restart_markers:=0;
 while((j.byte_pos<length_of_file)and (SOS_found=0)) do begin
  if(read_byte(j)<>$FF)then continue;
  //A marker was found
  case read_byte(j) of
   SOI:;
   EOI:;
   Dqt:begin
    w:=read_word(j); //length of the Dj.qt marker
    i:=0;
    repeat
     old_byte_pos:=j.byte_pos;
     qt_info:=read_byte(j);
     if (qt_info shr 4)<>0 then begin freemem(j.buf);exit;end;
     if jpg_use_int then int_load_quant_table(j,@j.i_qt[qt_info and $F][0])
                    else     load_quant_table(j,@j.f_qt[qt_info and $F][0]);
     i:=i+j.byte_pos-old_byte_pos;
    until not(i<dword(w-2));
    //FIXME? above
   end;
   DHT:begin
    w:=read_word(j);
    i:=0;
    repeat
     old_byte_pos:=j.byte_pos;
     HT_info:=read_byte(j);
     if ((HT_info and $10)<>0)then htable:=@j.htac[HT_info and $F] else htable:=@j.htdc[HT_info and $F];
     load_Huffman_table(j,htable);
     i:=i+j.byte_pos-old_byte_pos;
    until not(i<dword(w-2));
    //FIXME?
   end;
   COM:j.byte_pos:=j.byte_pos+read_word(j)-2;
   DRI:begin
    j.Restart_markers:=1;
    j.byte_pos:=j.byte_pos+2;
    j.MCU_restart:=read_word(j);
    if (j.MCU_restart=0)then j.Restart_markers:=0;
   end;
   SOF:begin
    j.byte_pos:=j.byte_pos+2;
    if(read_byte(j)<>8)then begin freemem(j.buf); exit; end;//Precision
    Y_image:=read_word(j);
    X_image:=read_word(j);
    if read_byte(j)<>3 then begin freemem(j.buf); exit; end;//Components num
    for i:=1 to 3 do begin
     comp_id:=read_byte(j);
     if(comp_id=0)or(comp_id>3)then begin freemem(j.buf); exit; end;
     case comp_id of
      1:begin //Y
       b:=read_byte(j);
       j.YH:=b shr 4;
       j.YV:=b and $F;
       j.YQ_nr:=read_byte(j);
      end;
      2:begin //Cb
       b:=read_byte(j);
       j.CbH:=b shr 4;
       j.CbV:=b and $F;
       j.CbQ_nr:=read_byte(j);
      end;
      3:begin //Cr
       b:=read_byte(j);
       j.CrH:=b shr 4;
       j.CrV:=b and $F;
       j.CrQ_nr:=read_byte(j);
      end;
     end;
    end;
    SOF_found:=1;
   end;
   SOS:begin
    j.byte_pos:=j.byte_pos+2;
    if read_byte(j)<>3 then begin freemem(j.buf); exit; end;
    for i:=1 to 3 do begin
     comp_id:=read_byte(j);
     if(comp_id=0)or(comp_id>3)then begin freemem(j.buf); exit; end;
     case comp_id of
      1:begin //Y
       b:=read_byte(j);
       j.YDC_nr:=b shr 4;
       j.YAC_nr:=b and $F;
      end;
      2:begin //Cb
       b:=read_byte(j);
       j.CbDC_nr:=b shr 4;
       j.CbAC_nr:=b and $F;
      end;
      3:begin //Cr
       b:=read_byte(j);
       j.CrDC_nr:=b shr 4;
       j.CrAC_nr:=b and $F;
      end;
     end;
    end;
    j.byte_pos:=j.byte_pos+3;
    SOS_found:=1;
   end;
   $FF:;//do nothing for $FFFF, sequence of consecutive $FF are for filling purposes and should be ignored
   else j.byte_pos:=j.byte_pos+read_word(j)-2; //skip unknown marker
  end;
 end;
 if(SOS_found=0)then begin freemem(j.buf);exit; end;
 if(SOF_found=0)then begin freemem(j.buf);exit; end;

 if ((j.CbH>j.YH)or(j.CrH>j.YH))then begin freemem(j.buf);exit; end;
 if ((j.CbV>j.YV)or(j.CrV>j.YV))then begin freemem(j.buf);exit; end;

 if ((j.CbH>=2)or(j.CbV>=2))then begin freemem(j.buf);exit; end;
 if ((j.CrV>=2)or(j.CrV>=2))then begin freemem(j.buf);exit; end;

 //Restricting sampling factors for Y,Cb,Cr should give us 4 possible cases for sampling factors
 //YHxYV,CbHxCbV,CrHxCrV: 2x2,1x1,1x1;  1x2,1x1,1x1; 2x1,1x1,1x1;
 //and 1x1,1x1,1x1 = no upsampling needed

 j.Hmax:=j.YH;j.Vmax:=j.YV;
 if(X_image mod (j.hmax*8))=0 then j.x_round:=X_image else j.x_round:=(X_image div (j.hmax*8)+1)*(j.hmax*8);
 if(Y_image mod (j.vmax*8))=0 then j.y_round:=Y_image else j.y_round:=(Y_image div (j.vmax*8)+1)*(j.vmax*8);

 getmem(j.out_buffer,j.x_round*j.y_round*4);
 if (j.out_buffer=nil)then begin freemem(j.buf); exit; end;

 result:=true;
end;
//############################################################################//  
procedure resync(j:pjpg_dec_rec);
var b:byte;
begin
 j.byte_pos:=j.byte_pos+2;
 b:=read_byte(j);
 if b=$FF then inc(j.byte_pos); //skip 00
 j.w1:=WORD_hi_lo(b,0);
 b:=read_byte(j);
 if b=$FF then inc(j.byte_pos); //skip 00
 j.w1:=j.w1+b;
 b:=read_byte(j);
 if b=$FF then inc(j.byte_pos); //skip 00
 j.w2:=WORD_hi_lo(b,0);
 b:=read_byte(j);
 if b=$FF then inc(j.byte_pos); //skip 00
 j.w2:=j.w2+b;
 j.wordval:=j.w1;j.d_k:=0; //Reinit bitstream decoding
 j.DCY:=0;j.DCCb:=0;j.DCCr:=0; //Init DC coefficients
end;
//############################################################################//  
procedure decode_MCU_1x1(j:pjpg_dec_rec;im_loc:dword);
begin         
 // Y        
 process_Huffman_data_unit(j,j.YDC_nr,j.YAC_nr,@j.DCY);  
 IDCT_transform(j,j.DCT_coeff,j.Y,j.YQ_nr);  
 // Cb        
 process_Huffman_data_unit(j,j.CbDC_nr,j.CbAC_nr,@j.DCCb);  
 IDCT_transform(j,j.DCT_coeff,j.Cb,j.CbQ_nr);   
 // Cr         
 process_Huffman_data_unit(j,j.CrDC_nr,j.CrAC_nr,@j.DCCr);  
 IDCT_transform(j,j.DCT_coeff,j.Cr,j.CrQ_nr);  
                    
 convert_8x8_YCbCr_to_RGB(@j.Y[0],@j.Cb[0],@j.Cr[0],im_loc,j.X_image_bytes,j.out_buffer);                     
end;
//############################################################################//  
procedure decode_MCU_2x1(j:pjpg_dec_rec;im_loc:dword);
begin
 // Y
 process_Huffman_data_unit(j,j.YDC_nr,j.YAC_nr,@j.DCY);
 IDCT_transform(j,j.DCT_coeff,j.Y_1,j.YQ_nr);
 process_Huffman_data_unit(j,j.YDC_nr,j.YAC_nr,@j.DCY);
 IDCT_transform(j,j.DCT_coeff,j.Y_2,j.YQ_nr);
 // Cb
 process_Huffman_data_unit(j,j.CbDC_nr,j.CbAC_nr,@j.DCCb);
 IDCT_transform(j,j.DCT_coeff,j.Cb,j.CbQ_nr);
 // Cr
 process_Huffman_data_unit(j,j.CrDC_nr,j.CrAC_nr,@j.DCCr);
 IDCT_transform(j,j.DCT_coeff,j.Cr,j.CrQ_nr);

 convert_8x8_YCbCr_to_RGB_tab(@j.Y_1[0],@j.Cb[0],@j.Cr[0],@j.tab_1[0],im_loc   ,j.X_image_bytes,j.out_buffer);
 convert_8x8_YCbCr_to_RGB_tab(@j.Y_2[0],@j.Cb[0],@j.Cr[0],@j.tab_2[0],im_loc+32,j.X_image_bytes,j.out_buffer);
end;
//############################################################################//  
procedure decode_MCU_2x2(j:pjpg_dec_rec;im_loc:dword);
begin
 // Y
 process_Huffman_data_unit(j,j.YDC_nr,j.YAC_nr,@j.DCY);
 IDCT_transform(j,j.DCT_coeff,j.Y_1,j.YQ_nr);
 process_Huffman_data_unit(j,j.YDC_nr,j.YAC_nr,@j.DCY);
 IDCT_transform(j,j.DCT_coeff,j.Y_2,j.YQ_nr);
 process_Huffman_data_unit(j,j.YDC_nr,j.YAC_nr,@j.DCY);
 IDCT_transform(j,j.DCT_coeff,j.Y_3,j.YQ_nr);
 process_Huffman_data_unit(j,j.YDC_nr,j.YAC_nr,@j.DCY);
 IDCT_transform(j,j.DCT_coeff,j.Y_4,j.YQ_nr);
 // Cb
 process_Huffman_data_unit(j,j.CbDC_nr,j.CbAC_nr,@j.DCCb);
 IDCT_transform(j,j.DCT_coeff,j.Cb,j.CbQ_nr);
 // Cr
 process_Huffman_data_unit(j,j.CrDC_nr,j.CrAC_nr,@j.DCCr);
 IDCT_transform(j,j.DCT_coeff,j.Cr,j.CrQ_nr);

 convert_8x8_YCbCr_to_RGB_tab(@j.Y_1[0],@j.Cb[0],@j.Cr[0],@j.tab_1[0],im_loc                 ,j.X_image_bytes,j.out_buffer);
 convert_8x8_YCbCr_to_RGB_tab(@j.Y_2[0],@j.Cb[0],@j.Cr[0],@j.tab_2[0],im_loc+32              ,j.X_image_bytes,j.out_buffer);
 convert_8x8_YCbCr_to_RGB_tab(@j.Y_3[0],@j.Cb[0],@j.Cr[0],@j.tab_3[0],im_loc+j.y_inc_value   ,j.X_image_bytes,j.out_buffer);
 convert_8x8_YCbCr_to_RGB_tab(@j.Y_4[0],@j.Cb[0],@j.Cr[0],@j.tab_4[0],im_loc+j.y_inc_value+32,j.X_image_bytes,j.out_buffer);
end;
//############################################################################//  
procedure decode_MCU_1x2(j:pjpg_dec_rec;im_loc:dword);
begin
 // Y
 process_Huffman_data_unit(j,j.YDC_nr,j.YAC_nr,@j.DCY);
 IDCT_transform(j,j.DCT_coeff,j.Y_1,j.YQ_nr);
 process_Huffman_data_unit(j,j.YDC_nr,j.YAC_nr,@j.DCY);
 IDCT_transform(j,j.DCT_coeff,j.Y_2,j.YQ_nr);
 // Cb
 process_Huffman_data_unit(j,j.CbDC_nr,j.CbAC_nr,@j.DCCb);
 IDCT_transform(j,j.DCT_coeff,j.Cb,j.CbQ_nr);
 // Cr
 process_Huffman_data_unit(j,j.CrDC_nr,j.CrAC_nr,@j.DCCr);
 IDCT_transform(j,j.DCT_coeff,j.Cr,j.CrQ_nr);

 convert_8x8_YCbCr_to_RGB_tab(@j.Y_1[0],@j.Cb[0],@j.Cr[0],@j.tab_1[0],im_loc,j.X_image_bytes,j.out_buffer);
 convert_8x8_YCbCr_to_RGB_tab(@j.Y_2[0],@j.Cb[0],@j.Cr[0],@j.tab_3[0],im_loc+j.y_inc_value,j.X_image_bytes,j.out_buffer);
end;
//############################################################################//  
procedure decode_JPEG_image(j:pjpg_dec_rec);
var decode_MCU:integer;
x_mcu_cnt,y_mcu_cnt:word;
nr_mcu:dword;
X_MCU_nr,Y_MCU_nr:word; 
MCU_dim_x:dword;
im_loc_inc:dword;
im_loc:dword;
begin            
 j.byte_pos:=j.byte_pos-2;  
 resync(j);     

 j.y_inc_value:=32*j.x_round;  
 calculate_tabs(j);  

 if ((j.YH=1)and(j.YV=1))then decode_MCU:=11 else begin
  if (j.YH=2)then begin
   if (j.YV=2)then decode_MCU:=22 else decode_MCU:=21;
  end else decode_MCU:=12;
 end;               
 MCU_dim_x:=j.hmax*8*4;

 Y_MCU_nr:=round(j.y_round/(j.vmax*8)); // nr of MCUs on Y axis  
 X_MCU_nr:=round(j.x_round/(j.hmax*8)); // nr of MCUs on X axis        

 j.X_image_bytes:=j.x_round*4; im_loc_inc:= dword(j.vmax*8-1) * j.X_image_bytes;    
 nr_mcu:=0; im_loc:=0; // memory location of the current MCU   
 {$ifdef jpg_stat}dt:=getdt;stdt(dt);t_h:=0;t_i:=0;{$endif}     
 for y_mcu_cnt:=0 to Y_MCU_nr-1 do begin    
  jpg_cur_dec_prc:=y_mcu_cnt/Y_MCU_nr;  
  for x_mcu_cnt:=0 to X_MCU_nr-1 do begin   
   case decode_MCU of
    11:decode_MCU_1x1(j,im_loc);
    22:decode_MCU_2x2(j,im_loc);
    21:decode_MCU_2x1(j,im_loc);
    12:decode_MCU_1x2(j,im_loc);
   end;          
   if ((j.Restart_markers<>0) and (((nr_mcu+1)mod j.MCU_restart)=0))then resync(j);        
   inc(nr_mcu);    
   im_loc:=im_loc+MCU_dim_x;      
  end;      
  im_loc:=im_loc+im_loc_inc;   
 end;         
 {$ifdef jpg_stat}jpg_stat_str:='tt='+stri(rtdt(dt))+' huff='+stri(t_h)+' idct='+stri(t_i);freedt(dt);{$endif}       
end;
//############################################################################//  
function get_JPEG_buffer(j:pjpg_dec_rec;X_image,Y_image:integer):pointer;
var y:word;
r,s:pointer;
src_bytes_per_line,dest_bytes_per_line:dword;   
begin   
 dest_bytes_per_line:=X_image*4;
 src_bytes_per_line:=j.x_round*4;

 getmem(result,X_image*Y_image*4);
 if result=nil then exit;
 r:=result;
 s:=j.out_buffer;
 for y:=0 to Y_image-1 do begin
  move(s^,r^,dest_bytes_per_line);
  s:=pointer(intptr(s)+src_bytes_per_line);
  r:=pointer(intptr(r)+dest_bytes_per_line);
 end;
end;
//############################################################################//
//############################################################################//   
//############################################################################//         
function ldjpgbuf(ibuf:pointer;ibs:integer;wtx,wa:boolean;trc:crgb;var bx,by:integer;var p:pointer):pointer;  
var j:pjpg_dec_rec; 
{$ifndef BGR}xi,yi:integer;c:pcrgba;b:byte;{$endif}   
begin     
 new(j);
 result:=nil;   
 j.ibuf:=ibuf;
 j.ibs:=ibs;
 
 j.d_k:=0;      
 if not load_JPEG_header(j,bx,by) then exit;
                 
 decode_JPEG_image(j);  
       
 if((j.x_round=bx)and(j.y_round=by))then p:=j.out_buffer else begin  
  p:=get_JPEG_buffer(j,bx,by); 
  freemem(j.out_buffer);  
  if p=nil then begin freemem(j.buf);dispose(j); exit;end;  
 end;       

 {$ifndef BGR} 
 for yi:=0 to by-1 do for xi:=0 to bx-1 do begin 
  c:=pcrgba(intptr(p)+intptr(xi*4+yi*bx*4));
  c[3]:=255;
  b:=c[2];
  c[2]:=c[0];
  c[0]:=b;
 end;     
 {$endif}      
 freemem(j.buf);  
 dispose(j);  
            
 result:=p;  
end;              
//############################################################################//
function ldjpg(fn:string;wtx,wa:boolean;trc:crgb;var bx,by:integer;var p:pointer):pointer;  
var f:file;
buf:pointer;
bs:integer;
begin    
 assignfile(f,fn);   
 reset(f,1);   
 bs:=filesize(f); 
 getmem(buf,bs);  
 blockread(f,buf^,bs); 
 closefile(f);     
 result:=ldjpgbuf(buf,bs,wtx,wa,trc,bx,by,p); 
 freemem(buf);  
end;
//############################################################################//
//############################################################################//
function isjpg(fn:string):boolean; 
var f:vfile;
buf:pbytea;                     
begin         
 result:=false;    
 if not vfopen(f,fn,1) then exit;
    
 if vffilesize(f)<=12 then begin vfclose(f); exit; end;
 
 getmem(buf,12);
 vfread(f,@buf[0],12);
 vfclose(f);

 if ((buf[0]<>$FF)or(buf[1]<>SOI)) then begin freemem(buf); exit;end;
 if (not((buf[2]=$FF)and(buf[3]=APP0)))and(not((buf[2]=$FF)and(buf[3]=APP1))) then begin freemem(buf); exit;end;
 //if ( (buf[6]<>ord('J'))or(buf[7]<>ord('F'))or(buf[8]<>ord('I'))or(buf[9]<>ord('F'))or(buf[10]<>0) ) then begin freemem(buf); exit;end;     
 freemem(buf);  
 result:=true;;
end; 
//############################################################################//
function isjpgbuf(ibuf:pointer;ibs:integer):boolean; 
var buf:pbytea;                     
begin         
 result:=false;    
 if ibuf=nil then exit;
 if ibs<=12 then exit;
 buf:=ibuf;
        
 if ((buf[0]<>$FF)or(buf[1]<>SOI)) then exit;
 if (not((buf[2]=$FF)and(buf[3]=APP0)))and(not((buf[2]=$FF)and(buf[3]=APP1))) then exit;
 result:=true;
end; 
//############################################################################//  
procedure calculate_mask;
var k:byte;
tmpdv:dword;
begin
 for k:=0 to 16 do begin 
  tmpdv:=$10000;
  mask[k]:=(tmpdv shr k)-1;
 end; //precalculated bit mask
end; 
//############################################################################// 
procedure prepare_range_limit_table;
var j:integer;
begin           
 //Allocate and fill in the sample_range_limit table
 getmem(rlimit_table,5*256+128);
 //First segment of "simple" table: limit[x] = 0 for x < 0
 fillchar(rlimit_table^,256,0);
 rlimit_table:=@rlimit_table[256]; //allow negative subscripts of simple table
 //Main part of "simple" table: limit[x] = x
 for j:=0 to 255 do pbyte(intptr(rlimit_table)+dword(j))^:=j;
 //End of simple table, rest of first half of post-IDCT table
 for j:=256 to 640-1 do pbyte(intptr(rlimit_table)+dword(j))^:=255;
 //Second half of post-IDCT table 
 fillchar(pbyte(intptr(rlimit_table)+640)^,384,0);
 for j:=0 to 128-1 do pbyte(intptr(rlimit_table)+dword(j)+1024)^:=j;  
end;    
//############################################################################// 
procedure precalculate_Cr_Cb_tables;
var k,Cr_v,Cb_v:word;
begin
 for k:=0 to 255 do Cr_tab[k]:=round((k-128.0)*1.402);
 for k:=0 to 255 do Cb_tab[k]:=round((k-128.0)*1.772);

 for Cr_v:=0 to 255 do for Cb_v:=0 to 255 do Cr_Cb_green_tab[(Cr_v shl 8)+Cb_v]:=round(-0.34414*(Cb_v-128)-0.71414*(Cr_v-128));
end;      
//############################################################################// 
procedure jpg_mode_set(isint:boolean);
begin   
 jpg_use_int:=isint;         
 if jpg_use_int then IDCT_transform:=int_IDCT_transform else IDCT_transform:=flt_IDCT_transform;
end; 
//############################################################################// 
begin                
 register_grfmt(nil,isjpg,nil,ldjpg,nil,isjpgbuf,nil,ldjpgbuf);       
 //{$ifdef wince}jpg_mode_set(true);{$endif}   
 jpg_mode_set(true);
 if jpg_use_int then IDCT_transform:=int_IDCT_transform else IDCT_transform:=flt_IDCT_transform;
 calculate_mask;
 precalculate_Cr_Cb_tables;
 prepare_range_limit_table;  
end. 
//############################################################################//


