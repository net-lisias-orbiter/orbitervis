//############################################################################//
// Orbiter Visualisation Project OpenGL client
// OGLA linux init and update file
// Released under GNU General Public License
// Made in 2005-2010 by Artyom Litvinovich
//############################################################################//
unit otutil;
interface   
uses asys,sysutils,math,mfd_api,glgr,dogl,log,grph,maths,oglctypes,oglc_common,ogladata,oglautil,otvar,otnet,grpcam; 
//############################################################################//  
procedure camprc_ogla(scn:poglascene);  
procedure prop_obs(scn:poglascene;dt:double);
procedure initogla; 
  
procedure glgr_frmevent(evt,x,y:integer;key:word;shift:tshiftstate); 
//############################################################################//
implementation   
//############################################################################//       
procedure camprc_ogla(scn:poglascene);   
var mp,d:double;
i,c:integer; 
begin
 mp:=1e100;
 c:=-1;
 for i:=0 to length(scn.plnt)-1 do begin
  d:=modv(subv(scn.cam.pos,scn.plnt[i].pos));
  if d<mp then begin mp:=d; c:=i;end;
 end;
 if c<>-1 then brtmat[2]:=getrtmat1(subv(scn.cam.pos,scn.plnt[c].pos));   
 
 scn.cam.rot:=tamat(scn.cam.rtmat);
 scn.cam.dir:=tvec(0,0,1); 
 vrotz(scn.cam.dir,-scn.cam.rot.z);
 vroty(scn.cam.dir,-scn.cam.rot.y);
 vrotx(scn.cam.dir,-scn.cam.rot.x);  
end;      
//############################################################################//
procedure add_evt(tp:byte;x,y,key:word);
begin
 mutex_lock(net_mx);
 kpre:=true;
 evt_net[evt_net_cur].tp:=tp;
 evt_net[evt_net_cur].x:=y;
 evt_net[evt_net_cur].y:=y;
 evt_net[evt_net_cur].key:=key;
 evt_net_cur:=evt_net_cur+1;
 if evt_net_cur>=length(evt_net)then evt_net_cur:=0;
 
 mutex_release(net_mx);
end;
//############################################################################//
function sh2ms(shift:tshiftstate):word;
begin
 result:=0;
 if ssleft in shift then result:=result+1;
 if ssright in shift then result:=result+2;
 if ssup in shift then result:=result+4;
 if ssdown in shift then result:=result+8;
end;
//############################################################################//
procedure glgr_frmevent(evt,x,y:integer;key:word;shift:tshiftstate); 
begin
 case evt of
  glgr_evclose :begin halt;end;
  glgr_evmsup  :begin add_evt(1,x,y,sh2ms(shift));pmx:=x;pmy:=y; end;
  glgr_evmsdwn :begin
   add_evt(2,x,y,sh2ms(shift));
   //camzstep(shift,scene.cam);
   pmx:=x;pmy:=y; 
  end; 
  glgr_evmsmove:begin
   add_evt(3,x,y,sh2ms(shift));
   //if ssright in shift then rotcam(scene.cam,x-pmx,-(y-pmy));
   pmx:=x;pmy:=y;
  end; 
  glgr_evkeydwn:begin
   add_evt(4,x,y,key);
   common_input(@scene,0,key,ord(ssctrl in shift)*2);
   case key of                              //Esc
    73:shinf:=not shinf;                    //I
    115:if ssalt in shift then halt;  
    27:halt;
    48..57:if key-48<length(scene.smobs) then begin cur_ves:=key-48; upd_cur_ves;end;
   end;
  end;
  glgr_evkeyup:add_evt(5,x,y,key);
 end;
end;
//############################################################################//
//############################################################################//
procedure setstars;
var i,nstar:integer;
brt,cnt,v1,v2,c0,a,b,eps,xz,c:double;
begin try
 nstar:=3000;  
 setlength(stars,nstar);
 setlength(strpnt,nstar);
 setlength(strpnta,nstar);
 for i:=0 to nstar-1 do begin stars[i].lng:=lrandom*pi*2-pi; stars[i].lat:=lrandom*pi-pi/2; stars[i].mag:=lrandom*2;end;
 //for i:=0 to nstar-1 do begin stars[i].lng:=lrandom*360-180; stars[i].lat:=lrandom*180-90; stars[i].mag:=lrandom*2;end;
  
 for i:=0 to nstar-1 do strpnta[i]:=i;                                                                    
 starcount:=nstar;  
   
 eps:=1e-2;
 brt:=1;
 cnt:=1;
 v1:=brt*2-2/(cnt+eps)+2;  // mv threshold for maximum intensity
 v2:=brt*2+2/(cnt+eps)+3;  // mv threshold for minimum intensity
 c0:=0;          // minimum intensity, applied to stars with mv > v2
 a:=(1-c0)/(v1-v2);
 b:=1-a*v1;
 for i:=0 to nstar-1 do begin
  xz:=100*cos(stars[i].lat);
	strpnt[i].pos.x:=(xz*cos(stars[i].lng));
	strpnt[i].pos.z:=(xz*sin(stars[i].lng));
	strpnt[i].pos.y:=(100*sin(stars[i].lat));

	c:=min(1,max(c0,a*stars[i].mag+b));
	strpnt[i].cold:=tcrgbad(c,c,c,1);
 end;   
 except stderr('OGLAUX','Error in setstars'); end;
end;
//############################################################################//
procedure prop_obs(scn:poglascene;dt:double);
var i:integer;
d:double;
mi:integer;
begin
 for i:=0 to length(scn.smobs)-1 do scn.smobs[i].pos:=addv(scn.smobs[i].pos,nmulv(scn.smobs[i].vel,dt));   
 for i:=0 to length(scn.plnt)-1 do scn.plnt[i].pos:=addv(scn.plnt[i].pos,nmulv(scn.plnt[i].vel,dt));

 if cur_ves>=length(scn.smobs) then exit;
 mi:=-1;
 d:=1e100; 
 for i:=0 to length(scn.plnt)-1 do if modvs(subv(scn.plnt[i].pos,scn.smobs[cur_ves].pos))<d then begin
  d:=modvs(subv(scn.plnt[i].pos,scn.smobs[cur_ves].pos));
  mi:=i;
 end;
 if mi<>-1 then csw_ob.ref:=swmg_planets[mi];
end;
//############################################################################//
//############################################################################//
procedure initogla;
begin
 setstars;
 scene.firstrun:=true;
 
 ords:=modv(subv(scene.cam.pos,scene.cam.tgt));
 ortg:=scene.cam.tgt;
end;   
//############################################################################//   
begin
end.
//############################################################################//



