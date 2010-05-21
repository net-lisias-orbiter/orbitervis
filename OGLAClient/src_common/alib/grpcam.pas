//############################################################################//
unit grpcam;
interface  
uses maths,grph;
//############################################################################//
type
camrec=record
 pos,dir,up,rt,tgt,tgtvel,tgtoff,rot:vec;
 pitch,yaw,dist:double;

 gps,gpsold,glp,etgt,tgtgps,tgtglp:vec;
              
 apr:double;
 rtx,rty:double;
 brtmat:pmat;
 rtmat:mat;

 mode:integer; 
 isr,isp:boolean;
end;
pcamrec=^camrec;
//############################################################################//
var
brtmat:array[0..3]of mat;
rtcur:integer;
cam_prec:double=1;
//############################################################################//
procedure rotcam(var cam:camrec;x,y:integer;md:integer=0);
procedure zoomcam(var cam:camrec;dif:double;md:integer=0);   
procedure camzstep(Shift:TShiftState;var cam:camrec;md:integer=0); 
function  getcamtgtdist(var cam:camrec):double;
procedure setcamtgt(var cam:camrec;tgt:vec;dst:double);   
//############################################################################//
implementation  
//############################################################################//
//############################################################################//
procedure rotcam(var cam:camrec;x,y:integer;md:integer=0);
var dst:double;
begin
 cam.rtx:=cam.rtx-x/180*pi/2;
 cam.rty:=cam.rty+y/180*pi/2;
 
 cam.rtmat:=emat;     
 rtmaty(cam.rtmat,-cam.rtx);
 rtmatx(cam.rtmat,cam.rty);
 
 cam.rtmat:=mulm(cam.brtmat^,cam.rtmat);   
 
 if cam.mode=3 then exit;
 dst:=0;
 if md=0 then dst:=modv(subv(cam.pos,cam.tgt));  
 if md=1 then dst:=modv(cam.tgtoff);                
 cam.rot:=tamat(cam.rtmat);
 cam.dir:=tvec(0,0,dst); 
 vrotz(cam.dir,-cam.rot.z);
 vroty(cam.dir,-cam.rot.y);
 vrotx(cam.dir,-cam.rot.x);
 
 if md=0 then cam.pos:=addv(cam.tgt,nmulv(cam.dir,-1));  
 if md=1 then cam.tgtoff:=nmulv(cam.dir,-1);  
end;   
//############################################################################//
procedure zoomcam(var cam:camrec;dif:double;md:integer=0);
var n:double;
begin
 if cam.mode<3 then begin
  if md=0 then cam.pos:=addv(cam.tgt,nmulv(subv(cam.pos,cam.tgt),dif));      
  if md=1 then cam.tgtoff:=nmulv(cam.tgtoff,dif); 
 end else begin
  cam.dir:=tvec(0,0,1); 
  cam.rot:=tamat(cam.rtmat);
  vrotz(cam.dir,-cam.rot.z);
  vroty(cam.dir,-cam.rot.y);
  vrotx(cam.dir,-cam.rot.x);
  if dif<1 then n:=1/dif-1 else n:=-dif+1;
  if md=0 then cam.pos:=addv(cam.pos,nmulv(cam.dir,n*1e4));
  if md=1 then cam.tgtoff:=addv(cam.tgtoff,nmulv(cam.dir,n*1e4));  
 end;
end;                    
//############################################################################//
procedure camzstep(Shift:TShiftState;var cam:camrec;md:integer=0);
begin
 if (ssalt in shift) then begin 
  if ssup in shift then zoomcam(cam,1/(1+99*cam_prec),md);
  if ssdown in shift then zoomcam(cam,1+99*cam_prec,md);
 end else if (ssshift in shift) then begin 
  if ssup in shift then zoomcam(cam,1/(1+9*cam_prec),md);
  if ssdown in shift then zoomcam(cam,1+9*cam_prec,md);
 end else if (ssctrl in shift) then begin 
  if ssup in shift then zoomcam(cam,1/(1+0.01*cam_prec),md);
  if ssdown in shift then zoomcam(cam,1+0.01*cam_prec,md);
 end else begin
  if ssup in shift then zoomcam(cam,1/(1+0.1*cam_prec),md);
  if ssdown in shift then zoomcam(cam,1+0.1*cam_prec,md); 
 end;
end;                  
//############################################################################//
function getcamtgtdist(var cam:camrec):double;
begin
 result:=modv(cam.tgtoff);
end;
//############################################################################//
procedure setcamtgt(var cam:camrec;tgt:vec;dst:double);
begin
 cam.dir:=tvec(0,0,1); 
 cam.rot:=tamat(cam.rtmat);
 vrotz(cam.dir,-cam.rot.z);
 vroty(cam.dir,-cam.rot.y);
 vrotx(cam.dir,-cam.rot.x);
 
 cam.tgt:=tgt;
 cam.pos:=addv(cam.tgt,nmulv(cam.dir,-dst));     
 cam.tgtoff:=subv(cam.pos,cam.tgt);
end;   
//############################################################################//
begin
end.  
//############################################################################//