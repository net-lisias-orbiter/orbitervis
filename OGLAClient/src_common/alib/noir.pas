//############################################################################//
//Made in 2002-2010 by Artyom Litvinovich
//AlgorLib: Noise and fractals
//############################################################################//
unit noir;
{$ifdef FPC}{$MODE delphi}{$endif}
interface
uses asys,grph,maths,math,noise;   
//############################################################################//
type noirgradpoint=record
 cl:crgba;
 pos:double;
end;     
//############################################################################//
function gradientcf(f:dword;p:double;cl:array of noirgradpoint):crgba;
//############################################################################//
function perlintf(noi:pnoirec;a:vec;scal:double;bd:integer;dsp:vec):double;      
function ridgetf(noi:pnoirec;a:vec;scal:double;bd:integer;dsp:vec):double; 
function sintf(a:vec;scal:double;dsp:vec):double;
function costf(a:vec;scal:double;dsp:vec):double;  
//############################################################################//

function ifcperlin(noi:pnoirec;e:pvec;pc:integer;v:array of double):double; 
//function ifccell(noi:pnoirec;e:pvec;pc:integer;v:array of double):double;  
function ifcridge(noi:pnoirec;e:pvec;pc:integer;v:array of double):double;
function ifcsealevel(noi:pnoirec;e:pvec;pc:integer;v:array of double):double;
function ifcsintf(noi:pnoirec;e:pvec;pc:integer;v:array of double):double;  
function ifccostf(noi:pnoirec;e:pvec;pc:integer;v:array of double):double; 
function ifcax(noi:pnoirec;e:pvec;pc:integer;v:array of double):double;
function ifcay(noi:pnoirec;e:pvec;pc:integer;v:array of double):double;
function ifcaz(noi:pnoirec;e:pvec;pc:integer;v:array of double):double;    

//############################################################################//
//var noirna,noirnan:vec;
//noirmod,noiralat,noiralon:double;
//var noirna:vec;
//############################################################################//  
implementation    
//############################################################################//                   
const numPoints=64;
height=256;
width=256;
wrapx=256;
wrapy=256;
type aaint=array[0..numPoints-1]of integer;
//############################################################################//
{
procedure getnranro;
var c:vec;
begin 
 c:=trr2l(noirnan);
 vrec2sph(c,noirmod);
 if c.y<0 then c.y:=2*pi+c.y;
 noiralat:=c.x;noiralon:=c.y;  
end;
}
//############################################################################//
function WrapDist(x,y:double;width,height:integer):double;
var dx,dy:double;
begin
 dx:=abs(x);
 dy:=abs(y);
 if (dx>(width shr 1))then dx:= width-dx;
 if (dy>(height shr 1))then dy:= height-dy;
 result:=dx*dx+dy*dy;	
end;
//############################################################################//
function DistToNearestPoint(var xcoords:aaint;var ycoords:aaint;x,y,width,height,numPoints:integer):double;
var mindist,dist:double;
i:integer;
begin
 mindist:=512*512*512;
 for i:=0 to numPoints-1 do begin
  dist:=WrapDist(xcoords[i]-x,ycoords[i]-y,width,height); 
  if dist<mindist then mindist:=dist;
 end;

 result:=sqrt(mindist);
end;   
//############################################################################//
{
function celltx(a:vec):double;
var x,y,i,offs,n:integer;
xcoords,ycoords:aaint;
mindist,maxdist,dist,colorfactor:double;
nearestdist:array[0..width*height-1]of double;
begin
 for i:=0 to numPoints-1 do begin
  xcoords[i]:=random(65535) and 255;
  ycoords[i]:=random(65535) and 255;
 end;

 mindist:=1 shl 16; //A large number.
 maxdist:=0;

 offs:=0;

 for y:=0 to height-1 do
  for x:=0 to width-1 do begin
   dist:=DistToNearestPoint(xcoords,ycoords,x,y,wrapx,wrapy,numPoints);
			
   if dist<mindist then mindist:=dist;
   if dist>maxdist then maxdist:=dist;

   nearestdist[offs]:= dist;

   offs:=offs+1;;
 end;

 offs:=0;
 colorfactor:=255/(maxdist-mindist);
       
 for y:=0 to Height-1 do 
  for x:=0 to Width-1 do begin
   n:=round((nearestdist[offs]-mindist)*colorfactor);

   dest_bits[offs]:=palette[n];        

   offs:=offs+1;;
 end; 
 result:=round((nearestdist[round(a.x)]-mindist)*colorfactor)
end;
//############################################################################//
function celltf(a:vec;scal:double;bd:integer;dsp:vec):double;
var i:integer;
begin
 result:=0;
 result:=celltx(a);
 //for i:=0 to bd-1 do result:=result+pnoiNoise(dsp.x*(a.x/(scal/expa[i])),dsp.y*(a.y/(scal/expa[i])),dsp.z*(a.z/(scal/expa[i])))/expa[i];
end;  }  
//############################################################################//
function perlintf(noi:pnoirec;a:vec;scal:double;bd:integer;dsp:vec):double;
var i:integer;  
d:double;
begin
 result:=0;
 for i:=0 to bd-1 do begin
  d:=1/(scal/expa[i]);
  result:=result+pnoiNoise(noi,dsp.x*a.x*d,dsp.y*a.y*d,dsp.z*a.z*d)/expa[i];
 end; 
end;     
//############################################################################//
function ridgetf(noi:pnoirec;a:vec;scal:double;bd:integer;dsp:vec):double;
var i:integer;
d:double;
begin 
 result:=0; 
 for i:=0 to bd-1 do begin
  d:=1/(scal/expa[i]);
  result:=result+pnoiNoise(noi,dsp.x*a.x*d,dsp.y*a.y*d,dsp.z*a.z*d)/expa[i];
 end; 
 if result<-1 then result:=-1; if result>1 then result:=1; 
 result:=result*2;
 if (result>-2)and(result<0)then result:=result+1 else result:=1-result; 
end;     
//############################################################################//
function sintf(a:vec;scal:double;dsp:vec):double;
var s:double;
begin
 s:=2*pi/scal;
 result:=(sin(a.x*s*dsp.x)+sin(a.y*s*dsp.y)+sin(a.z*s*dsp.z))/3;
end;     
//############################################################################//
function costf(a:vec;scal:double;dsp:vec):double;
var s:double;
begin
 s:=2*pi/scal;
 result:=(cos(a.x*s*dsp.x)+cos(a.y*s*dsp.y)+cos(a.z*s*dsp.z))/3;
end;
//############################################################################//                    
//############################################################################//
//############################################################################//
//############################################################################//
function gradientcf(f:dword;p:double;cl:array of noirgradpoint):crgba;
var p1,p2,i:integer;
d:double;
begin
 if f=1 then p:=p/2+0.5;
 p1:=0;
 p2:=length(cl)-1;
 for i:=0 to length(cl)-1 do begin
  if cl[i].pos<p then p1:=i;
  if cl[length(cl)-1-i].pos>p then p2:=length(cl)-1-i;
 end;
 if(p1=p2)or(cl[p2].pos=cl[p1].pos)then begin
  result:=cl[p1].cl;
  exit;
 end;
 d:=(p-cl[p1].pos)/(cl[p2].pos-cl[p1].pos);
 for i:=0 to 3 do result[i]:=round(cl[p1].cl[i]+(cl[p2].cl[i]-cl[p1].cl[i])*d); 
end;      
//############################################################################//
//############################################################################//
//############################################################################//
function ifcax(noi:pnoirec;e:pvec;pc:integer;v:array of double):double;begin result:=e.x;end;
function ifcay(noi:pnoirec;e:pvec;pc:integer;v:array of double):double;begin result:=e.y;end;
function ifcaz(noi:pnoirec;e:pvec;pc:integer;v:array of double):double;begin result:=e.z;end;
function ifcsintf(noi:pnoirec;e:pvec;pc:integer;v:array of double):double;begin result:=sintf(e^,v[0],tvec(v[1],v[2],v[3]));end;
function ifccostf(noi:pnoirec;e:pvec;pc:integer;v:array of double):double;begin result:=costf(e^,v[0],tvec(v[1],v[2],v[3]));end;
function ifcperlin(noi:pnoirec;e:pvec;pc:integer;v:array of double):double;begin result:=perlintf(noi,e^,v[0],round(v[1]),tvec(v[2],v[3],v[4]));end;
//function ifccell(noi:pnoirec;e:pvec;pc:integer;v:array of double):double;begin result:=celltf(e^,v[0],round(v[1]),tvec(v[2],v[3],v[4]));end;
function ifcridge(noi:pnoirec;e:pvec;pc:integer;v:array of double):double;begin result:=ridgetf(noi,e^,v[0],round(v[1]),tvec(v[2],v[3],v[4]));end;
function ifcsealevel(noi:pnoirec;e:pvec;pc:integer;v:array of double):double;begin if v[0]>v[1] then result:=v[0] else result:=v[1];end;
//############################################################################//
begin   
end.  
//############################################################################// 

