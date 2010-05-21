//############################################################################//
// Orbiter Visualisation Project OpenGL client
// OGLA linux variables file
// Released under GNU General Public License
// Made in 2005-2010 by Artyom Litvinovich
//############################################################################//
unit otvar;
interface 
uses asys,grph,maths,dogl,ogladata,mfd_api;   
//############################################################################//
var
//Window
gwin:glwin;
net_mx:mutex_typ;

cur_ves:integer=0;
csw_ob:objtype;
maindr,mfd_dr:drwinfo;

//The scene
scene:oglascene;
sysogla:oglainf;

net_srv:string='127.0.0.1';

tgt:integer;
ortg:vec;
ords:double; 
shinf:boolean;

pmx,pmy:integer;

const 
max_surf_dist = 1e4;
max_centre_dist = 0.9e6;

type
starrec=record
 lng,lat,mag:single;
end;
pstarrec=^starrec;

var
stars:array of starrec;
starcount:integer;
strpnt:aopntyp;
strpnta:adword;  
//############################################################################//
implementation   
//############################################################################//
begin
end.
//############################################################################// 

