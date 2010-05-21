//############################################################################//
// Orbiter Visualisation Project OpenGL client
// OGLA and OGLAClient shaders file
// Released under GNU General Public License
// Made in 2007-2010 by Artlav
//############################################################################//
unit oglashaders;
interface
uses maths,{$ifdef win32}windows,{$endif}sysutils,asys,ogladata,strval,opengl1x,glgr,raleygpu;
//############################################################################//
var          
shmapmat:tmatrix4f;  

var
{
vv,fv,vp,fp,vr,fr,vc,fc,vs,fs,vessh,plnsh,ringsh,cldsh,starsh:cardinal;   
vsv,fsv,vsp,fsp,vsr,fsr,vsc,fsc,vss,fss:pchar;

starsh_drwm:integer;
cldsh_drwm,cldsh_tex,cldsh_tex1,cldsh_sdist,cldsh_fdist,cldsh_dst:integer;
plnsh_shadmap,plnsh_airshade,plnsh_lt_cnt,plnsh_smap,plnsh_istx2,plnsh_subtex,plnsh_rad,plnsh_alt,plnsh_hfo,plnsh_FogColor,plnsh_FogDensity:integer;
vessh_shadmap,vessh_tex,vessh_ltex,vessh_stex,vessh_lt_cnt,vessh_tex0,vessh_ltex0,vessh_stex0,vessh_smap,vessh_crgba:integer;
ringsh_drwm,ringsh_tex,ringsh_tex1,ringsh_sdist,ringsh_fdist,ringsh_pov:integer;   
}
vessh_shm,plnsh_ml,plnsh_shm:boolean; 

ves_sh:array[0..7]of ogl_shader;
pln_sh:array[0..15]of ogl_shader;
haz_sh:ogl_shader;

lights_count,lights_limit:integer;

var lt_pos,lt_diff,lt_dir:array of mvec;
lt_sco,lt_quad:array of single;
//############################################################################//
//Shaders initialization    
procedure oglaset_shaders(scn:poglascene);  
procedure fill_common;
//############################################################################//
implementation          
//############################################################################//
var frag_ves_hdr,vert_ves,vert_haz,vert_plnt,shm,fixdlt_a_ves,fixdlt_b_ves,fixdlt_a1_plnt,fixdlt_subtx_plnt,fixdlt_a2_plnt,fixdlt_b_plnt,fixdlt_a_haz,fixdlt_b_haz,airshade:string;
frag_haz_hdr,frag_plnt_hdr_airsh,frag_plnt_hdr,nvis,ml2,ml2_pl:string;
frag_hdr_ml:array[0..9]of string;
ml,ml_pl:array[0..15]of string;
//############################################################################//
procedure fill_vert_and_hdr;
var i:integer;
begin
 vert_ves:=
 'varying vec3 v_nml,halfVec,ecPos,lv,hv;'+#10+
 'varying vec4 ProjShadow;'+#10+  
 'varying mat3 tsp;'+#10+  
 'attribute vec3 tangent;'+#10+   
 ''+#10+
 'void main(void)'+#10+
 '{'+#10+
 ' ecPos=(gl_ModelViewMatrix*gl_Vertex).xyz;'+#10+
 ' v_nml=normalize(gl_NormalMatrix*gl_Normal);'+#10+
 ''+#10+
 ' halfVec=normalize(normalize(gl_LightSource[0].position.xyz-ecPos)-normalize(ecPos));'+#10+
 ' ProjShadow=gl_TextureMatrix[2]*gl_ModelViewMatrix*gl_Vertex;'+#10+
 ' '+#10+  
 ' vec3 n,t,b;'+#10+
 ' n=normalize(gl_NormalMatrix*gl_Normal);'+#10+
 ' t=normalize(gl_NormalMatrix*tangent);'+#10+
 ' b=cross(n,t);'+#10+
 ' mat3 tangentspace=mat3(t,b,n);'+#10+
 ''+#10+
 ' lv=normalize(normalize(gl_LightSource[0].position.xyz-ecPos)*tangentspace);'+#10+  
 ' hv=normalize(halfVec*tangentspace);'+#10+ 
 ' tsp=tangentspace;'+#10+  
 ''+#10+
 ' gl_Position=gl_ModelViewProjectionMatrix*gl_Vertex;'+#10+ 
 ' gl_TexCoord[0]=gl_TextureMatrix[0]*gl_MultiTexCoord0;'+#10+
 ' gl_TexCoord[1]=gl_TextureMatrix[1]*gl_MultiTexCoord1;'+#10+
 '}'+#10;
     
 vert_plnt:=
 'varying vec3 normal,halfVector,ecPos;'+#10+
 'varying vec4 ProjShadow;'+#10+
 'varying vec3 verscreen,verglobal;'+#10+ 
 ''+#10+
 'void main(void)'+#10+
 '{'+#10+
 ' ecPos=vec3(gl_ModelViewMatrix*gl_Vertex);'+#10+
 ' normal=normalize(gl_NormalMatrix*gl_Normal);'+#10+
 ''+#10+
 ' halfVector=normalize(normalize(gl_LightSource[0].position.xyz-ecPos)-normalize(ecPos));'+#10+
 ' ProjShadow=gl_TextureMatrix[2]*gl_ModelViewMatrix*gl_Vertex;'+#10+
 ''+#10+
 ' verscreen=(gl_ModelViewMatrix*gl_Vertex).xyz;'+#10+
 ' verglobal=gl_Vertex.xyz;'+#10+
 ''+#10+  
 ' gl_Position=gl_ModelViewProjectionMatrix*gl_Vertex;'+#10+ 
 ' gl_TexCoord[0]=gl_TextureMatrix[0]*gl_MultiTexCoord0;'+#10+
 '}'+#10;
     
 vert_haz:=
 'varying vec3 verscreen,verglobal;'+#10+ 
 ''+#10+
 'void main(void)'+#10+
 '{'+#10+
 ' verscreen=(gl_ModelViewMatrix*gl_Vertex).xyz;'+#10+
 ' verglobal=gl_Vertex.xyz;'+#10+
 ''+#10+  
 ' gl_Position=gl_ModelViewProjectionMatrix*gl_Vertex;'+#10+ 
 ' gl_TexCoord[0]=gl_TextureMatrix[0]*gl_MultiTexCoord0;'+#10+
 '}'+#10;

 frag_ves_hdr:=
 'uniform sampler2D tex,ltex,nstex;'+#10+
 'uniform sampler2DShadow smap;'+#10+
 'uniform vec4 crgba;'+#10+
 'uniform float tex0,ltex0,ltex1,nstex0;'+#10+ 
 'varying vec3 v_nml,halfVec,ecPos,lv,hv;'+#10+    
 'varying mat3 tsp;'+#10+  
 'varying vec4 ProjShadow;'+#10;   
 
 frag_hdr_ml[0]:='';
 for i:=1 to 4 do begin
  frag_hdr_ml[i]:=
  'uniform vec3  lt_pos ['+stri(i*10)+'];'+#10+
  'uniform vec3  lt_diff['+stri(i*10)+'];'+#10+
  'uniform float lt_sco ['+stri(i*10)+'];'+#10+
  'uniform vec3  lt_dir ['+stri(i*10)+'];'+#10+
  'uniform float lt_quad['+stri(i*10)+'];'+#10+ 
  'uniform int lt_cnt;'+#10;
 end; 
 
 frag_plnt_hdr:=
 'uniform bool shadmap;'+#10+
 'uniform sampler2D tex;'+#10+
 'uniform sampler2DShadow smap;'+#10+
 'varying vec3 normal,halfVector,ecPos;'+#10+
 'varying vec4 ProjShadow;'+#10+  
 'uniform sampler2D subtex;'+#10+
 'uniform float istx2;'+#10;
 
 frag_haz_hdr:=
 'uniform sampler2D tex;'+#10;
 
 frag_plnt_hdr_airsh:=
 'varying vec3 verscreen,verglobal;'+#10+
 'uniform float rad;'+#10+
 'uniform float alt;'+#10+
 'uniform float hfo;'+#10+
 'uniform float cufo;'+#10+
 'uniform vec4 FogColor;'+#10+
 'uniform float FogDensity;'+#10;
end;
//############################################################################//
procedure fill_bases;
begin
 fixdlt_a_ves:=
 ' vec4 ct,cl,amb,dif,spec,ntx;'+#10+
 ' float cs,dist,intensity,at,al,as,NdotHV;'+#10+
 ' vec3 ns,normal,lightDir,halfVector;'+#10+   
 ' vec3 tldr,thlv,hlv;'+#10+
 ' '+#10+
 ' //Normal&specular mapping'+#10+
 ' ntx=texture2D(nstex,gl_TexCoord[0].st);'+#10+ 
 ' ns=normalize(ntx.xyz*2.0-1.0);'+#10+   
 ' cs=nstex0*ntx.a;'+#10+   
 ' normal    =nstex0*ns+(1.0-nstex0)*v_nml;'+#10+
 ' lightDir  =nstex0*lv+(1.0-nstex0)*normalize(gl_LightSource[0].position.xyz);'+#10+
 ' halfVector=nstex0*hv+(1.0-nstex0)*halfVec;'+#10+
 ' intensity=max(dot(lightDir,normal),0.0);'+#10+
 ' '+#10+
 ' //Lightmap'+#10+
 ' cl=ltex0*texture2D(ltex,gl_TexCoord[0].st)+ltex1*texture2D(ltex,gl_TexCoord[1].st);'+#10+
 ' cl+=gl_FrontMaterial.emission;'+#10+
 ''+#10+
 ' //Texture'+#10+
 ' ct=(1.0-tex0)*vec4(1.0,1.0,1.0,1.0)+tex0*texture2D(tex,gl_TexCoord[0].st);'+#10+
 ' ct.rgb*=max(crgba.rgb,cl.rgb);'+#10+ 
 ''+#10+  
 ' //Specular'+#10+
 ' spec=vec4(0.0,0.0,0.0,0.0);'+#10+        
 ' if(intensity>0.0){'+#10+
 '  spec=max(cs*vec4(1.0,1.0,1.0,1.0),gl_FrontMaterial.specular)*pow(max(0.0,dot(normal,halfVector)),max(cs*15.0,gl_FrontMaterial.shininess));'+#10+
 //' spec*=clamp(intensity*100.0,0.0,1.0);'+#10+
 ' }'+#10+
 ''+#10+
 ' //Light'+#10+
 ' amb=(gl_FrontMaterial.ambient*(gl_LightSource[0].ambient+gl_LightModel.ambient))*(1.0-intensity);'+#10+
 ' dif=gl_LightSource[0].diffuse*intensity;'+#10;  
 
 fixdlt_b_ves:=
 ' //Summ'+#10+
 ' color=ct*(max(cl,dif)+amb)+spec;'+#10+
 ' color.a=min(crgba.a,ct.a);'+#10+   
 ''+#10;

  
 fixdlt_a1_plnt:=
 ' vec4 ct,st,amb,dif,spec;'+#10+
 ' float cs,dist,intensity,at,al,as,NdotHV;'+#10+
 ' vec3 lightDir;'+#10+         
 ' vec3 tldr,thlv,hlv;'+#10+
 ''+#10+
 ' lightDir=normalize(gl_LightSource[0].position.xyz);'+#10+
 ' intensity=max(dot(lightDir,normal),0.0);'+#10+
 ' cs=0.0;'+#10+
 ''+#10+
 ' //Texture'+#10+
 ' ct=texture2D(tex,gl_TexCoord[0].st);'+#10+
 ''+#10;
 
 
 fixdlt_a2_plnt:=  
 ' //Specular'+#10+
 ' spec=vec4(0.0,0.0,0.0,0.0);'+#10+
 ' spec=gl_FrontMaterial.specular*pow(max(0.0,dot(normal,halfVector)),gl_FrontMaterial.shininess);'+#10+
 ' spec*=clamp(intensity*100.0,0.0,1.0);'+#10+
 ''+#10+
 ' //Light'+#10+
 ' amb=gl_FrontMaterial.ambient*(gl_LightSource[0].ambient+gl_LightModel.ambient);'+#10+
 ' dif=gl_LightSource[0].diffuse*intensity;'+#10;
 
 fixdlt_b_plnt:=
 ' //Summ'+#10+    
 ' //color=ct*FogColor;'+#10+
 ' color=ct*(dif+amb)+spec;'+#10+
 ' color.a=ct.a;'+#10;
    
 fixdlt_a_haz:=
 ' vec4 ct;'+#10+
 ''+#10+
 ' //Texture'+#10+
 ' ct=texture2D(tex,gl_TexCoord[0].st);'+#10;
 
 fixdlt_b_haz:=
 ' //Summ'+#10+    
 ' color=ct*FogColor;'+#10+
 ' color.a=ct.a;'+#10;
end;
//############################################################################//
procedure fill_effects;
var i,j:integer;
begin

 nvis:=
 ' float elapsedTime=1.0;'+#10+
 ' float luminanceThreshold=0.2;'+#10+
 ' float colorAmplification=4.0;'+#10+
 ' vec4 finalColor=color;'+#10+
 ' vec2 uv;'+#10+
 ' uv.x=0.4*sin(elapsedTime*50.0);'+#10+
 ' uv.y=0.4*cos(elapsedTime*50.0);'+#10+    
 ' vec3 n=vec3(0.0,0.0,0.0);//texture2D(noiseTex,(gl_TexCoord[0].st*3.5)+uv).rgb;'+#10+
 ' vec3 c=color.rgb;//texture2D(sceneBuffer,gl_TexCoord[0].st+(n.xy*0.005)).rgb;'+#10+
 ''+#10+
 ' float lum=dot(vec3(0.30,0.59,0.11),c);'+#10+
 ' if(lum<luminanceThreshold)c*=colorAmplification;'+#10+
 ''+#10+      
 ' vec3 visionColor=vec3(0.1,0.95,0.2);'+#10+
 ' finalColor.rgb=(c+(n*0.2))*visionColor;'+#10+          
 ' color=finalColor;'+#10+ 
 ''+#10;
   
 shm:=
 ' vec3 smcoord=ProjShadow.xyz/ProjShadow.w;'+#10+
 ' float c=0.5+0.5*shadow2D(smap,smcoord).x;'+#10+
 ' color.rgb*=c;'+#10;

 for i:=0 to 7 do begin
  ml[i]:='';
  for j:=1 to i do ml[i]:=ml[i]+
  ' tldr=normalize(gl_LightSource['+stri(j)+'].position.xyz-ecPos);'+#10+        
  ' thlv=normalize(tldr-normalize(ecPos));'+#10+
  ' lightDir=nstex0*tldr*tsp+(1.0-nstex0)*tldr;'+#10+        
  ' hlv=nstex0*thlv*tsp+(1.0-nstex0)*thlv;'+#10+
  ' intensity=max(dot(lightDir,normal),0.0);'+#10+
  ' dist=length(gl_LightSource['+stri(j)+'].position.xyz-ecPos);'+#10+
  ' if((dot(normalize(gl_LightSource['+stri(j)+'].spotDirection),-tldr)>gl_LightSource['+stri(j)+'].spotCosCutoff)&&(intensity>0.0)){'+#10+
  '  dif+=gl_LightSource['+stri(j)+'].diffuse*(intensity'+#10+
  '       /(1.0+gl_LightSource['+stri(j)+'].quadraticAttenuation*dist*dist));'+#10+
  '  spec+=(max(cs*vec4(1.0,1.0,1.0,1.0),gl_FrontMaterial.specular)*pow(max(0.0,dot(normal,hlv)),max(cs*15.0,gl_FrontMaterial.shininess)))*clamp(intensity*100.0,0.0,1.0);'+#10+
  ' }'+#10;
 end;
 for i:=0 to 7 do begin
  ml_pl[i]:='';
  for j:=1 to i do ml_pl[i]:=ml_pl[i]+
  ' tldr=normalize(gl_LightSource['+stri(j)+'].position.xyz-ecPos);'+#10+        
  ' thlv=normalize(tldr-normalize(ecPos));'+#10+
  ' lightDir=tldr;'+#10+        
  ' hlv=thlv;'+#10+
  ' intensity=max(dot(lightDir,normal),0.0);'+#10+
  ' dist=length(gl_LightSource['+stri(j)+'].position.xyz-ecPos);'+#10+
  ' if((dot(normalize(gl_LightSource['+stri(j)+'].spotDirection),-tldr)>gl_LightSource['+stri(j)+'].spotCosCutoff)&&(intensity>0.0)){'+#10+
  '  dif+=gl_LightSource['+stri(j)+'].diffuse*(intensity'+#10+
  '       /(1.0+gl_LightSource['+stri(j)+'].quadraticAttenuation*dist*dist));'+#10+
  '  spec+=(max(cs*vec4(1.0,1.0,1.0,1.0),gl_FrontMaterial.specular)*pow(max(0.0,dot(normal,hlv)),max(cs*15.0,gl_FrontMaterial.shininess)))*clamp(intensity*100.0,0.0,1.0);'+#10+
  ' }'+#10;
 end;

 ml2:=                   
 ' for(int i=0;i<lt_cnt;i++){'+#10+
 '  tldr=normalize(lt_pos[i]-ecPos);'+#10+        
 '  thlv=normalize(tldr-normalize(ecPos));'+#10+
 '  lightDir=nstex0*tldr*tsp+(1.0-nstex0)*tldr;'+#10+        
 '  hlv=nstex0*thlv*tsp+(1.0-nstex0)*thlv;'+#10+
 '  intensity=max(dot(lightDir,normal),0.0);'+#10+
 '  dist=length(lt_pos[i]-ecPos);'+#10+
 '  if((dot(normalize(lt_dir[i]),-tldr)>lt_sco[i])&&(intensity>0.0)){'+#10+
 '   float att=1.0/(1.0+lt_quad[i]*dist*dist);'+#10+ 
 '   att=clamp(att,0.001,1.0);'+#10+ 
 '   float spcpow=pow(max(0.0,dot(normal,hlv)),max(cs*15.0,gl_FrontMaterial.shininess))*att;'+#10+
 '   spcpow=clamp(spcpow,0.0,1.0);'+#10+
 '   dif.rgb+=lt_diff[i]*intensity*att;'+#10+    
 '   spec+=(max(cs*vec4(1.0,1.0,1.0,1.0),gl_FrontMaterial.specular)*spcpow)*clamp(intensity*100.0,0.0,1.0);'+#10+
 '  }'+#10+   
 ' }'+#10;
 
 ml2_pl:=                   
 ' for(int i=0;i<lt_cnt;i++){'+#10+
 '  tldr=normalize(lt_pos[i]-ecPos);'+#10+        
 '  thlv=normalize(tldr-normalize(ecPos));'+#10+
 '  lightDir=tldr;'+#10+        
 '  hlv=thlv;'+#10+
 '  intensity=max(dot(lightDir,normal),0.0);'+#10+
 '  dist=length(lt_pos[i]-ecPos);'+#10+
 '  if((dot(normalize(lt_dir[i]),-tldr)>lt_sco[i])&&(intensity>0.0)){'+#10+
 '   float att=1.0/(1.0+lt_quad[i]*dist*dist);'+#10+ 
 '   att=clamp(att,0.001,1.0);'+#10+ 
 '   float spcpow=pow(max(0.0,dot(normal,hlv)),max(cs*15.0,gl_FrontMaterial.shininess))*att;'+#10+
 '   spcpow=clamp(spcpow,0.0,1.0);'+#10+
 '   dif.rgb+=lt_diff[i]*intensity*att;'+#10+    
 '   spec+=(max(cs*vec4(1.0,1.0,1.0,1.0),gl_FrontMaterial.specular)*spcpow)*clamp(intensity*100.0,0.0,1.0);'+#10+
 '  }'+#10+   
 ' }'+#10;  
 
 fixdlt_subtx_plnt:=
 ' st=texture2D(subtex,gl_TexCoord[0].st);'+#10+ 
 ' st.a*=istx2;'+#10+
 ' ct.rgb=mix(ct.rgb,st.rgb,st.a);'+#10+
 ''+#10;    
  
 airshade:=
 ' float cwp=length(verglobal+vec3(0,rad,0))-rad-alt;'+#10+
 ' float fog_distance=length(verscreen)*cufo;'+#10+
 ' if(abs(cwp)>0.01){'+#10+
 '  float t=hfo*cwp;'+#10+
 '  fog_distance*=(1.0-exp2(-t))/t;'+#10+
 ' }'+#10+ 
 ' float fog_factor=exp2(-abs(FogDensity*fog_distance));'+#10+
 ' fog_factor=clamp(fog_factor,0.0,1.0);'+#10+
 ' '+#10+    
 ' color.rgb=mix(FogColor.rgb,color.rgb,fog_factor);'+#10;    
  
end;   
//############################################################################//
procedure fill_common;
begin     
 fill_vert_and_hdr;
 fill_bases;
 fill_effects;
end;   
//############################################################################//
procedure write_shader_to_file(s:string;tg:integer);
var fn:text;
begin
 assignfile(fn,'out-'+stri(tg)+'.frag');
 rewrite(fn);
 write(fn,s);
 closefile(fn);
end;
//############################################################################//                                                                  
//############################################################################//
procedure mk_vessel_shader(is_ml,is_shm:boolean);
var v,f:string;
i:integer;
begin
 for i:=0 to length(ves_sh)-1 do if ves_sh[i].prg<>0 then begin
  if(vessh_shm=is_shm)then exit;
  glDeleteProgram(ves_sh[i].prg);
  glDeleteShader(ves_sh[i].vs);
  glDeleteShader(ves_sh[i].fs);
  ves_sh[i].prg:=0;
 end;
 vessh_shm:=is_shm;

 v:=vert_ves;

 for i:=0 to 7 do begin  
  f:='';
  if gl_shm4 then if i>4 then break;
  if gl_shm4 then f:=frag_hdr_ml[i];
  f:=f+frag_ves_hdr;   
  f:=f+
  'void main()'+#10+ 
  '{'+#10+
  ' vec4 color;'+#10+fixdlt_a_ves;
  if gl_shm4 then if i<>0 then f:=f+ml2;
  if not gl_shm4 then f:=f+ml[i];
  f:=f+fixdlt_b_ves;
  if is_shm then f:=f+shm;
  f:=f+
  //nvis+
  ' gl_FragColor=color;'+#10+
  '}'+#10;   
   
  //write_shader_to_file(f,i);
 
  if mkshader(pchar(v),pchar(f),nil,ves_sh[i],'Vessel program '+stri(i)+':') then begin
   setlength(ves_sh[i].unis,17);
   ves_sh[i].unis[0]:=glGetUniformLocation(ves_sh[i].prg,'shadmap');    
   ves_sh[i].unis[1]:=glGetUniformLocation(ves_sh[i].prg,'crgba');  
   ves_sh[i].unis[2]:=glGetUniformLocation(ves_sh[i].prg,'tex0');
   ves_sh[i].unis[3]:=glGetUniformLocation(ves_sh[i].prg,'ltex0');
   ves_sh[i].unis[4]:=glGetUniformLocation(ves_sh[i].prg,'nstex0');
   ves_sh[i].unis[5]:=glGetUniformLocation(ves_sh[i].prg,'tex');
   ves_sh[i].unis[6]:=glGetUniformLocation(ves_sh[i].prg,'ltex');
   ves_sh[i].unis[7]:=glGetUniformLocation(ves_sh[i].prg,'nstex');
   ves_sh[i].unis[8]:=glGetUniformLocation(ves_sh[i].prg,'smap'); 
       
   ves_sh[i].unis[9]:=glGetUniformLocation(ves_sh[i].prg,'lt_pos'); 
   ves_sh[i].unis[10]:=glGetUniformLocation(ves_sh[i].prg,'lt_diff'); 
   ves_sh[i].unis[11]:=glGetUniformLocation(ves_sh[i].prg,'lt_sco'); 
   ves_sh[i].unis[12]:=glGetUniformLocation(ves_sh[i].prg,'lt_dir'); 
   ves_sh[i].unis[13]:=glGetUniformLocation(ves_sh[i].prg,'lt_quad'); 
   ves_sh[i].unis[14]:=glGetUniformLocation(ves_sh[i].prg,'lt_cnt'); 

   ves_sh[i].unis[15]:=glGetAttribLocationARB(ves_sh[i].prg,'tangent');  
   ves_sh[i].unis[16]:=glGetUniformLocation(ves_sh[i].prg,'ltex1');
  end;
 end;
end;                                                                 
//############################################################################//
procedure mk_planet_shader(is_ml,is_shm:boolean);
var v,f:string;
i:integer;
begin  
 for i:=0 to length(pln_sh)-1 do if pln_sh[i].prg<>0 then begin
  if(plnsh_ml=is_ml)and(plnsh_shm=is_shm)then exit;
  glDeleteProgram(pln_sh[i].prg);
  glDeleteShader(pln_sh[i].vs);
  glDeleteShader(pln_sh[i].fs);
  pln_sh[i].prg:=0;
 end;
 plnsh_ml:=is_ml;
 plnsh_shm:=is_shm;

 v:=vert_plnt;
 
 for i:=0 to 15 do begin
  if gl_shm4 then if i>9 then exit;
  f:=frag_plnt_hdr;   
  if gl_shm4 then f:=f+frag_hdr_ml[i mod 5];
  if gl_shm4 then if i>4 then f:=f+frag_plnt_hdr_airsh;
  if not gl_shm4 then if i>7 then f:=f+frag_plnt_hdr_airsh;
  f:=f+
  'void main()'+#10+ 
  '{'+#10+
  ' vec4 color;'+#10+fixdlt_a1_plnt+fixdlt_subtx_plnt+fixdlt_a2_plnt;
  if gl_shm4 then if is_ml then if i mod 5<>0 then f:=f+ml2_pl;
  if not gl_shm4 then if is_ml then f:=f+ml_pl[i mod 8];
  f:=f+fixdlt_b_plnt;
  if is_shm then f:=f+shm;
  if gl_shm4 then if i>4 then f:=f+airshade;
  if not gl_shm4 then if i>7 then f:=f+airshade;
  f:=f+
  //nvis+
  ' gl_FragColor=color;'+#10+
  '}'+#10;

  //write_shader_to_file(f,i);
 
  if mkshader(pchar(v),pchar(f),nil,pln_sh[i],'Planet program '+stri(i)+':') then begin    
   setlength(pln_sh[i].unis,16);                           
   glUniform1i(glGetUniformLocation(pln_sh[i].prg,'tex'),0);
   glUniform1i(glGetUniformLocation(pln_sh[i].prg,'subtex'),1);
   glUniform1i(glGetUniformLocation(pln_sh[i].prg,'smap'),2);
   
   pln_sh[i].unis[ 0]:=glGetUniformLocation(pln_sh[i].prg,'subtex');
   pln_sh[i].unis[ 1]:=glGetUniformLocation(pln_sh[i].prg,'smap');
   pln_sh[i].unis[ 2]:=glGetUniformLocation(pln_sh[i].prg,'shadmap');
   pln_sh[i].unis[ 3]:=glGetUniformLocation(pln_sh[i].prg,'istx2');

   pln_sh[i].unis[ 4]:=glGetUniformLocation(pln_sh[i].prg,'rad');
   pln_sh[i].unis[ 5]:=glGetUniformLocation(pln_sh[i].prg,'alt');
   pln_sh[i].unis[ 6]:=glGetUniformLocation(pln_sh[i].prg,'hfo');  
   pln_sh[i].unis[ 7]:=glGetUniformLocation(pln_sh[i].prg,'FogColor'); 
   pln_sh[i].unis[ 8]:=glGetUniformLocation(pln_sh[i].prg,'FogDensity');   
   pln_sh[i].unis[ 9]:=glGetUniformLocation(pln_sh[i].prg,'cufo'); 
   
   pln_sh[i].unis[10]:=glGetUniformLocation(pln_sh[i].prg,'lt_pos'); 
   pln_sh[i].unis[11]:=glGetUniformLocation(pln_sh[i].prg,'lt_diff'); 
   pln_sh[i].unis[12]:=glGetUniformLocation(pln_sh[i].prg,'lt_sco'); 
   pln_sh[i].unis[13]:=glGetUniformLocation(pln_sh[i].prg,'lt_dir'); 
   pln_sh[i].unis[14]:=glGetUniformLocation(pln_sh[i].prg,'lt_quad'); 
   pln_sh[i].unis[15]:=glGetUniformLocation(pln_sh[i].prg,'lt_cnt'); 
  end;
 end;
end;                                                         
//############################################################################//
procedure mk_haze_shader;
var v,f:string;
begin
 v:=vert_haz;
 f:=frag_haz_hdr+frag_plnt_hdr_airsh;
 f:=f+
 'void main()'+#10+ 
 '{'+#10+
 ' vec4 color;'+#10+fixdlt_a_haz+airshade+fixdlt_b_haz+
 ' gl_FragColor=color;'+#10+
 '}'+#10;

 //write_shader_to_file(v,0);
 //write_shader_to_file(f,0);
 
 if mkshader(pchar(v),pchar(f),nil,haz_sh,'Haze program 0:') then begin    
  setlength(haz_sh.unis,7);                           
  glUniform1i(glGetUniformLocation(haz_sh.prg,'tex'),0);

  haz_sh.unis[ 1]:=glGetUniformLocation(haz_sh.prg,'rad');
  haz_sh.unis[ 2]:=glGetUniformLocation(haz_sh.prg,'alt');
  haz_sh.unis[ 3]:=glGetUniformLocation(haz_sh.prg,'hfo');  
  haz_sh.unis[ 4]:=glGetUniformLocation(haz_sh.prg,'FogColor'); 
  haz_sh.unis[ 5]:=glGetUniformLocation(haz_sh.prg,'FogDensity');   
  haz_sh.unis[ 6]:=glGetUniformLocation(haz_sh.prg,'cufo'); 
 end;
end;
//############################################################################//
procedure oglaset_shaders(scn:poglascene);
begin   
 if gl_2_sup and scn.feat.advanced then begin 
  mk_vessel_shader(scn.feat.multilight,(scn.feat.shres=5)and(scn.feat.shadows));   
  mk_planet_shader(scn.feat.multilight and scn.feat.mlight_terrain,(scn.feat.shres=5)and(scn.feat.shadows));
  mk_haze_shader;   
  load_precomp_gpu('textures/transmittance.bin','textures/irradiance.bin','textures/inscatter.bin');
 end;
 
{
 if gl_2_sup then begin
                     
  if mkshader(vsr,fsr,vr,fr,ringsh,'ring','Ring program:')then begin
   glUniform1i(glGetUniformLocation(ringsh,'tex'),0);
   glUniform1i(glGetUniformLocation(ringsh,'tex1'),1);
   
   ringsh_tex:=glGetUniformLocation(ringsh,'tex');
   ringsh_tex1:=glGetUniformLocation(ringsh,'tex1');
   ringsh_sdist:=glGetUniformLocation(ringsh,'sdist');
   ringsh_fdist:=glGetUniformLocation(ringsh,'fdist');
   ringsh_pov:=glGetUniformLocation(ringsh,'pov');
  end;                        
  
  if mkshader(vsc,fsc,vc,fc,cldsh,'clouds','Clouds program:')then begin
   glUniform1i(glGetUniformLocation(cldsh,'tex'),0);
   glUniform1i(glGetUniformLocation(cldsh,'tex1'),1);
   cldsh_drwm:=glGetUniformLocation(cldsh,'drwm');   
   cldsh_tex:=glGetUniformLocation(cldsh,'tex');
   cldsh_tex1:=glGetUniformLocation(cldsh,'tex1');
   cldsh_sdist:=glGetUniformLocation(cldsh,'sdist');
   cldsh_fdist:=glGetUniformLocation(cldsh,'fdist');
   cldsh_dst:=glGetUniformLocation(cldsh,'dst');
  end;
  
  if mkshader(vss,fss,vs,fs,starsh,'star','Star program:')then begin
   glUniform1i(glGetUniformLocation(starsh,'tex'),0);
   glUniform1i(glGetUniformLocation(starsh,'tex1'),1);
   starsh_drwm:=glGetUniformLocation(starsh,'drwm');
  end; 
  }
end;    
//############################################################################//
var i:integer;
begin  
 lights_limit:=40;
 fill_common;
 for i:=0 to length(ves_sh)-1 do ves_sh[i].prg:=0;
 for i:=0 to length(pln_sh)-1 do pln_sh[i].prg:=0;
 //ringsh:=0;
 //cldsh:=0;
 //starsh:=0; 
end. 
//############################################################################//
