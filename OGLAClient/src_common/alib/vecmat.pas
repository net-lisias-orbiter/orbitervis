//############################################################################//
unit vecmat;
{$ifdef FPC}{$MODE delphi}{$endif}
interface
uses math,maths;
//############################################################################//
const
tess:array[0..31]of array[0..1]of quat=(
 ((x: 1;y: 1;z: 1;w: 1),(x:-1;y: 1;z: 1;w: 1)),
 ((x: 1;y: 1;z: 1;w: 1),(x: 1;y:-1;z: 1;w: 1)),
 ((x: 1;y: 1;z: 1;w: 1),(x: 1;y: 1;z:-1;w: 1)),
 ((x: 1;y: 1;z: 1;w: 1),(x: 1;y: 1;z: 1;w:-1)),
 ((x:-1;y: 1;z: 1;w: 1),(x:-1;y:-1;z: 1;w: 1)),
 ((x:-1;y: 1;z: 1;w: 1),(x:-1;y: 1;z:-1;w: 1)),
 ((x:-1;y: 1;z: 1;w: 1),(x:-1;y: 1;z: 1;w:-1)), 
 ((x: 1;y:-1;z: 1;w: 1),(x:-1;y:-1;z: 1;w: 1)),
 ((x: 1;y:-1;z: 1;w: 1),(x: 1;y:-1;z:-1;w: 1)),
 ((x: 1;y:-1;z: 1;w: 1),(x: 1;y:-1;z: 1;w:-1)),                                                
 ((x: 1;y: 1;z:-1;w: 1),(x:-1;y: 1;z:-1;w: 1)),
 ((x: 1;y: 1;z:-1;w: 1),(x: 1;y:-1;z:-1;w: 1)),
 ((x: 1;y: 1;z:-1;w: 1),(x: 1;y: 1;z:-1;w:-1)),
 ((x: 1;y: 1;z: 1;w:-1),(x:-1;y: 1;z: 1;w:-1)),
 ((x: 1;y: 1;z: 1;w:-1),(x: 1;y:-1;z: 1;w:-1)),
 ((x: 1;y: 1;z: 1;w:-1),(x: 1;y: 1;z:-1;w:-1)), 
 ((x:-1;y:-1;z: 1;w: 1),(x:-1;y:-1;z:-1;w: 1)),
 ((x:-1;y:-1;z: 1;w: 1),(x:-1;y:-1;z: 1;w:-1)),
 ((x:-1;y: 1;z:-1;w: 1),(x:-1;y:-1;z:-1;w: 1)),
 ((x:-1;y: 1;z:-1;w: 1),(x:-1;y: 1;z:-1;w:-1)),
 ((x:-1;y: 1;z: 1;w:-1),(x:-1;y:-1;z: 1;w:-1)),
 ((x:-1;y: 1;z: 1;w:-1),(x:-1;y: 1;z:-1;w:-1)),
 ((x: 1;y:-1;z:-1;w: 1),(x:-1;y:-1;z:-1;w: 1)),
 ((x: 1;y:-1;z:-1;w: 1),(x: 1;y:-1;z:-1;w:-1)),
 ((x: 1;y:-1;z: 1;w:-1),(x:-1;y:-1;z: 1;w:-1)),
 ((x: 1;y:-1;z: 1;w:-1),(x: 1;y:-1;z:-1;w:-1)),
 ((x: 1;y: 1;z:-1;w:-1),(x:-1;y: 1;z:-1;w:-1)),
 ((x: 1;y: 1;z:-1;w:-1),(x: 1;y:-1;z:-1;w:-1)),
 ((x:-1;y:-1;z:-1;w: 1),(x:-1;y:-1;z:-1;w:-1)),
 ((x:-1;y:-1;z: 1;w:-1),(x:-1;y:-1;z:-1;w:-1)),
 ((x:-1;y: 1;z:-1;w:-1),(x:-1;y:-1;z:-1;w:-1)),
 ((x: 1;y:-1;z:-1;w:-1),(x:-1;y:-1;z:-1;w:-1))
);   
//############################################################################//
cub:array[0..11]of array[0..1]of quat=(
 ((x: 1;y: 1;z: 1;w: 0),(x:-1;y: 1;z: 1;w: 0)),
 ((x: 1;y: 1;z: 1;w: 0),(x: 1;y:-1;z: 1;w: 0)),
 ((x: 1;y: 1;z: 1;w: 0),(x: 1;y: 1;z:-1;w: 0)),
 ((x:-1;y: 1;z: 1;w: 0),(x:-1;y:-1;z: 1;w: 0)),
 ((x:-1;y: 1;z: 1;w: 0),(x:-1;y: 1;z:-1;w: 0)),
 ((x: 1;y:-1;z: 1;w: 0),(x:-1;y:-1;z: 1;w: 0)),
 ((x: 1;y:-1;z: 1;w: 0),(x: 1;y:-1;z:-1;w: 0)),
 ((x: 1;y: 1;z:-1;w: 0),(x:-1;y: 1;z:-1;w: 0)),
 ((x: 1;y: 1;z:-1;w: 0),(x: 1;y:-1;z:-1;w: 0)),
 ((x:-1;y:-1;z: 1;w: 0),(x:-1;y:-1;z:-1;w: 0)),
 ((x:-1;y: 1;z:-1;w: 0),(x:-1;y:-1;z:-1;w: 0)),
 ((x: 1;y:-1;z:-1;w: 0),(x:-1;y:-1;z:-1;w: 0))
);   
//############################################################################//  
function rot_z(a:double):matq;
function rot_y(a:double):matq;
function rot_x(a:double):matq;  
function translate3d(v:vec):matq;

function rot_xy(a:double):mat5;
function rot_xz(a:double):mat5;
function rot_xw(a:double):mat5;
function rot_yz(a:double):mat5;
function rot_yw(a:double):mat5;
function rot_zw(a:double):mat5;   
function translate4d(v:quat):mat5;

function plane_sec(var ax,bx,ay,by,az,bz:double;ks:double):boolean;   
function proj_matrix(np,fp,fov,a:double):matq;   
function proj_matrix_transp(np,fp,fov,a:double):matq;

function det_matq(m:matq):double;  
function isinv_matq(ma:matq):boolean; 
function inv_matq(m:matq):matq; 
function transpmq(m:matq):matq;   
 
function det_mat(m:mat):double;
function isinv_mat(ma:mat):boolean;  
function inv_mat(ma:mat):mat;  
function transpm(m:mat):mat;
//############################################################################//
implementation
//############################################################################//
function rot_z(a:double):matq;
begin
 result[0]:=tquat( cos(a), sin(a),      0,      0);
 result[1]:=tquat(-sin(a), cos(a),      0,      0);
 result[2]:=tquat(      0,      0,      1,      0);
 result[3]:=tquat(      0,      0,      0,      1);
end;
//############################################################################//
function rot_y(a:double):matq;
begin
 result[0]:=tquat( cos(a),      0,-sin(a),      0);
 result[1]:=tquat(      0,      1,      0,      0);
 result[2]:=tquat( sin(a),      0, cos(a),      0);
 result[3]:=tquat(      0,      0,      0,      1);
end;  
//############################################################################//
function rot_x(a:double):matq;
begin
 result[0]:=tquat(      1,      0,      0,      0);
 result[1]:=tquat(      0, cos(a), sin(a),      0);
 result[2]:=tquat(      0,-sin(a), cos(a),      0);
 result[3]:=tquat(      0,      0,      0,      1);
end;  
//############################################################################//
function translate3d(v:vec):matq;
begin        
 result[0]:=tquat(1,0,0,v.x);
 result[1]:=tquat(0,1,0,v.y);
 result[2]:=tquat(0,0,1,v.z);
 result[3]:=tquat(0,0,0,  1);
end;
//############################################################################//
function rot_xy(a:double):mat5;
begin
 result[0]:=tvec5( cos(a), sin(a),      0,      0,0);
 result[1]:=tvec5(-sin(a), cos(a),      0,      0,0);
 result[2]:=tvec5(      0,      0,      1,      0,0);
 result[3]:=tvec5(      0,      0,      0,      1,0);
 result[4]:=tvec5(      0,      0,      0,      0,1);
end;   
//############################################################################//
function rot_xz(a:double):mat5;
begin
 result[0]:=tvec5( cos(a),      0,-sin(a),      0,0);
 result[1]:=tvec5(      0,      1,      0,      0,0);
 result[2]:=tvec5( sin(a),      0, cos(a),      0,0);
 result[3]:=tvec5(      0,      0,      0,      1,0);
 result[4]:=tvec5(      0,      0,      0,      0,1);
end;     
//############################################################################//
function rot_xw(a:double):mat5;
begin
 result[0]:=tvec5( cos(a),      0,      0, sin(a),0);
 result[1]:=tvec5(      0,      1,      0,      0,0);
 result[2]:=tvec5(      0,      0,      1,      0,0);
 result[3]:=tvec5(-sin(a),      0,      0, cos(a),0);
 result[4]:=tvec5(      0,      0,      0,      0,1);
end;
//############################################################################//
function rot_yz(a:double):mat5;
begin
 result[0]:=tvec5(      1,      0,      0,      0,0);
 result[1]:=tvec5(      0, cos(a), sin(a),      0,0);
 result[2]:=tvec5(      0,-sin(a), cos(a),      0,0);
 result[3]:=tvec5(      0,      0,      0,      1,0);
 result[4]:=tvec5(      0,      0,      0,      0,1);
end;    
//############################################################################//
function rot_yw(a:double):mat5;
begin
 result[0]:=tvec5(      1,      0,      0,      0,0);
 result[1]:=tvec5(      0, cos(a),      0,-sin(a),0);
 result[2]:=tvec5(      0,      0,      1,      0,0);
 result[3]:=tvec5(      0, sin(a),      0, cos(a),0);
 result[4]:=tvec5(      0,      0,      0,      0,1);
end;     
//############################################################################//
function rot_zw(a:double):mat5;
begin
 result[0]:=tvec5(      1,      0,      0,      0,0);
 result[1]:=tvec5(      0,      1,      0,      0,0);
 result[2]:=tvec5(      0,      0, cos(a),-sin(a),0);
 result[3]:=tvec5(      0,      0, sin(a), cos(a),0);
 result[4]:=tvec5(      0,      0,      0,      0,1);
end;  
//############################################################################//
function translate4d(v:quat):mat5;
begin        
 result[0]:=tvec5(1,0,0,0,v.x);
 result[1]:=tvec5(0,1,0,0,v.y);
 result[2]:=tvec5(0,0,1,0,v.z);
 result[3]:=tvec5(0,0,0,1,v.w);
 result[4]:=tvec5(0,0,0,0,  1);
end;   
//############################################################################//
//############################################################################//
function plane_sec(var ax,bx,ay,by,az,bz:double;ks:double):boolean;
var c:double;
begin                
 result:=false;
 if ax<-ks then begin if bx<-ks then begin result:=true;exit;end;c:=abs((bx+ks)/(ax-bx));ax:=-ks;ay:=(ay-by)*c+by;az:=(az-bz)*c+bz;end;                
 if ax> ks then begin if bx> ks then begin result:=true;exit;end;c:=abs((bx-ks)/(ax-bx));ax:= ks;ay:=(ay-by)*c+by;az:=(az-bz)*c+bz;end;  
 if bx<-ks then begin if ax<-ks then begin result:=true;exit;end;c:=abs((ax+ks)/(bx-ax));bx:=-ks;by:=(by-ay)*c+ay;bz:=(bz-az)*c+az;end;                
 if bx> ks then begin if ax> ks then begin result:=true;exit;end;c:=abs((ax-ks)/(bx-ax));bx:= ks;by:=(by-ay)*c+ay;bz:=(bz-az)*c+az;end;  
end;   
//############################################################################//
function det_matq(m:matq):double;
begin
 result:=
 m[0].w*m[1].z*m[2].y*m[3].x-m[0].z*m[1].w*m[2].y*m[3].x-m[0].w*m[1].y*m[2].z*m[3].x+m[0].y*m[1].w*m[2].z*m[3].x+
 m[0].z*m[1].y*m[2].w*m[3].x-m[0].y*m[1].z*m[2].w*m[3].x-m[0].w*m[1].z*m[2].x*m[3].y+m[0].z*m[1].w*m[2].x*m[3].y+
 m[0].w*m[1].x*m[2].z*m[3].y-m[0].x*m[1].w*m[2].z*m[3].y-m[0].z*m[1].x*m[2].w*m[3].y+m[0].x*m[1].z*m[2].w*m[3].y+
 m[0].w*m[1].y*m[2].x*m[3].z-m[0].y*m[1].w*m[2].x*m[3].z-m[0].w*m[1].x*m[2].y*m[3].z+m[0].x*m[1].w*m[2].y*m[3].z+
 m[0].y*m[1].x*m[2].w*m[3].z-m[0].x*m[1].y*m[2].w*m[3].z-m[0].z*m[1].y*m[2].x*m[3].w+m[0].y*m[1].z*m[2].x*m[3].w+
 m[0].z*m[1].x*m[2].y*m[3].w-m[0].x*m[1].z*m[2].y*m[3].w-m[0].y*m[1].x*m[2].z*m[3].w+m[0].x*m[1].y*m[2].z*m[3].w;
end;  
//############################################################################//
function isinv_matq(ma:matq):boolean;  
var det:double;
begin          
 det:=det_matq(ma);
 result:=abs(det)>=eps;
end; 
//############################################################################//
function inv_matq(m:matq):matq;   
var det:double;
begin        
 det:=det_matq(m);
 if abs(det)<eps then exit;

 result[0].x:=(m[1].z*m[2].w*m[3].y-m[1].w*m[2].z*m[3].y+m[1].w*m[2].y*m[3].z-m[1].y*m[2].w*m[3].z-m[1].z*m[2].y*m[3].w+m[1].y*m[2].z*m[3].w)/det;
 result[0].y:=(m[0].w*m[2].z*m[3].y-m[0].z*m[2].w*m[3].y-m[0].w*m[2].y*m[3].z+m[0].y*m[2].w*m[3].z+m[0].z*m[2].y*m[3].w-m[0].y*m[2].z*m[3].w)/det;
 result[0].z:=(m[0].z*m[1].w*m[3].y-m[0].w*m[1].z*m[3].y+m[0].w*m[1].y*m[3].z-m[0].y*m[1].w*m[3].z-m[0].z*m[1].y*m[3].w+m[0].y*m[1].z*m[3].w)/det;
 result[0].w:=(m[0].w*m[1].z*m[2].y-m[0].z*m[1].w*m[2].y-m[0].w*m[1].y*m[2].z+m[0].y*m[1].w*m[2].z+m[0].z*m[1].y*m[2].w-m[0].y*m[1].z*m[2].w)/det;
 result[1].x:=(m[1].w*m[2].z*m[3].x-m[1].z*m[2].w*m[3].x-m[1].w*m[2].x*m[3].z+m[1].x*m[2].w*m[3].z+m[1].z*m[2].x*m[3].w-m[1].x*m[2].z*m[3].w)/det;
 result[1].y:=(m[0].z*m[2].w*m[3].x-m[0].w*m[2].z*m[3].x+m[0].w*m[2].x*m[3].z-m[0].x*m[2].w*m[3].z-m[0].z*m[2].x*m[3].w+m[0].x*m[2].z*m[3].w)/det;
 result[1].z:=(m[0].w*m[1].z*m[3].x-m[0].z*m[1].w*m[3].x-m[0].w*m[1].x*m[3].z+m[0].x*m[1].w*m[3].z+m[0].z*m[1].x*m[3].w-m[0].x*m[1].z*m[3].w)/det;
 result[1].w:=(m[0].z*m[1].w*m[2].x-m[0].w*m[1].z*m[2].x+m[0].w*m[1].x*m[2].z-m[0].x*m[1].w*m[2].z-m[0].z*m[1].x*m[2].w+m[0].x*m[1].z*m[2].w)/det;
 result[2].x:=(m[1].y*m[2].w*m[3].x-m[1].w*m[2].y*m[3].x+m[1].w*m[2].x*m[3].y-m[1].x*m[2].w*m[3].y-m[1].y*m[2].x*m[3].w+m[1].x*m[2].y*m[3].w)/det;
 result[2].y:=(m[0].w*m[2].y*m[3].x-m[0].y*m[2].w*m[3].x-m[0].w*m[2].x*m[3].y+m[0].x*m[2].w*m[3].y+m[0].y*m[2].x*m[3].w-m[0].x*m[2].y*m[3].w)/det;
 result[2].z:=(m[0].y*m[1].w*m[3].x-m[0].w*m[1].y*m[3].x+m[0].w*m[1].x*m[3].y-m[0].x*m[1].w*m[3].y-m[0].y*m[1].x*m[3].w+m[0].x*m[1].y*m[3].w)/det;
 result[2].w:=(m[0].w*m[1].y*m[2].x-m[0].y*m[1].w*m[2].x-m[0].w*m[1].x*m[2].y+m[0].x*m[1].w*m[2].y+m[0].y*m[1].x*m[2].w-m[0].x*m[1].y*m[2].w)/det;
 result[3].x:=(m[1].z*m[2].y*m[3].x-m[1].y*m[2].z*m[3].x-m[1].z*m[2].x*m[3].y+m[1].x*m[2].z*m[3].y+m[1].y*m[2].x*m[3].z-m[1].x*m[2].y*m[3].z)/det;
 result[3].y:=(m[0].y*m[2].z*m[3].x-m[0].z*m[2].y*m[3].x+m[0].z*m[2].x*m[3].y-m[0].x*m[2].z*m[3].y-m[0].y*m[2].x*m[3].z+m[0].x*m[2].y*m[3].z)/det;
 result[3].z:=(m[0].z*m[1].y*m[3].x-m[0].y*m[1].z*m[3].x-m[0].z*m[1].x*m[3].y+m[0].x*m[1].z*m[3].y+m[0].y*m[1].x*m[3].z-m[0].x*m[1].y*m[3].z)/det;
 result[3].w:=(m[0].y*m[1].z*m[2].x-m[0].z*m[1].y*m[2].x+m[0].z*m[1].x*m[2].y-m[0].x*m[1].z*m[2].y-m[0].y*m[1].x*m[2].z+m[0].x*m[1].y*m[2].z)/det;
end;    
//############################################################################//
function transpmq(m:matq):matq;
begin
 result[0]:=tquat(m[0].x,m[1].x,m[2].x,m[3].x);
 result[1]:=tquat(m[0].y,m[1].y,m[2].y,m[3].y);
 result[2]:=tquat(m[0].z,m[1].z,m[2].z,m[3].z);
 result[3]:=tquat(m[0].w,m[1].w,m[2].w,m[3].w);
end;
//############################################################################//
function proj_matrix(np,fp,fov,a:double):matq;
var h,neg_depth:double;
begin  
 h:=1/tan(fov*pi/360);
 neg_depth:=np-fp;

 result[0]:=tquat(h/a,0,0,0);
 result[1]:=tquat(0,h,0,0);
 result[2]:=tquat(0,0,(fp+np)/neg_depth,-1);
 result[3]:=tquat(0,0,2*(np*fp)/neg_depth,0);
end;
//############################################################################//
function proj_matrix_transp(np,fp,fov,a:double):matq;
var h,neg_depth:double;
begin  
 h:=1/tan(fov*pi/360);
 neg_depth:=np-fp;

 result[0]:=tquat(h/a,0,0,0);
 result[1]:=tquat(0,h,0,0);
 result[2]:=tquat(0,0,(fp+np)/neg_depth,2*(fp*np)/neg_depth);
 result[3]:=tquat(0,0,-1,0);
end;  
//############################################################################//
function det_mat(m:mat):double;
begin
 result:=m[0].x * ( m[1].y*m[2].z - m[2].y*m[1].z )
       - m[0].y * ( m[1].x*m[2].z - m[2].x*m[1].z )
       + m[0].z * ( m[1].x*m[2].y - m[2].x*m[1].y );
end;    
//############################################################################//
function isinv_mat(ma:mat):boolean;  
var det:double;
begin          
 det:=det_mat(ma);
 result:=abs(det)>=eps;
end;           
//############################################################################//
function inv_mat(ma:mat):mat;
var det:double;
begin     
 det:=det_mat(ma);
 if abs(det)<eps then exit;

 result[0].x:=  ( ma[1].y*ma[2].z - ma[1].z*ma[2].y ) / det;
 result[0].y:= -( ma[0].y*ma[2].z - ma[2].y*ma[0].z ) / det;
 result[0].z:=  ( ma[0].y*ma[1].z - ma[1].y*ma[0].z ) / det;
 result[1].x:= -( ma[1].x*ma[2].z - ma[1].z*ma[2].x ) / det;
 result[1].y:=  ( ma[0].x*ma[2].z - ma[2].x*ma[0].z ) / det;
 result[1].z:= -( ma[0].x*ma[1].z - ma[1].x*ma[0].z ) / det;
 result[2].x:=  ( ma[1].x*ma[2].y - ma[2].x*ma[1].y ) / det;
 result[2].y:= -( ma[0].x*ma[2].y - ma[2].x*ma[0].y ) / det;
 result[2].z:=  ( ma[0].x*ma[1].y - ma[0].y*ma[1].x ) / det;
end;  
//############################################################################//
function transpm(m:mat):mat;
begin
 result[0]:=tvec(m[0].x,m[1].x,m[2].x);
 result[1]:=tvec(m[0].y,m[1].y,m[2].y);
 result[2]:=tvec(m[0].z,m[1].z,m[2].z);
end;
//############################################################################//
begin
end.
//############################################################################//
