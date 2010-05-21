//############################################################################//
unit raleygpu;
interface
uses sysutils,raleydata,raleysoft,math,opengl1x,asys,maths,vecmat,strval,grph,grplib,glgr,dogl,dds,jpg,bmp;  
//############################################################################//  
const 
reflectanceUnit=0;
transmittanceUnit=1;
irradianceUnit=2;
inscatterUnit=3;

var 
transmittanceTexture:dword;//unit 1,T table
irradianceTexture:dword;   //unit 2,E table
inscatterTexture:dword;    //unit 3,S table
scatter_sh:ogl_shader;
//############################################################################//
function precompute_gpu(trans,irr,ins:string):boolean;
procedure load_precomp_gpu(trans,irr,ins:string);    
//############################################################################//
implementation   
//############################################################################//
//############################################################################//
var main_const,mainsep,copyIrradiance,irradiance1,transmittance,common,copyInscatterN,copyInscatter1,inscatterN,inscatter1,irradianceN,inscatterS:string;
//############################################################################//
//############################################################################//
procedure make_shaders;
begin 
 main_const:=
 'const float Rg='+stri(Rg)+'.0;'#10+
 'const float Rt='+stri(Rt)+'.0;'#10+
 'const float RL='+stri(RL)+'.0;'#10+
 ''#10+
 'const int TRANSMITTANCE_W='+stri(TRANSMITTANCE_W)+';'#10+
 'const int TRANSMITTANCE_H='+stri(TRANSMITTANCE_H)+';'#10+
 ''#10+
 'const int SKY_W='+stri(SKY_W)+';'#10+
 'const int SKY_H='+stri(SKY_H)+';'#10+
 ''#10+
 'const int RES_R='+stri(RES_R)+';'#10+
 'const int RES_MU='+stri(RES_MU)+';'#10+
 'const int RES_MU_S='+stri(RES_MU_S)+';'#10+
 'const int RES_NU='+stri(RES_NU)+';'#10+
 ''#10+
 '// Rayleigh'#10+
 'const float HR=8.0;'#10+
 'const vec3 betaR=vec3(5.8e-3,1.35e-2,3.31e-2);'#10+
 ''#10+
 '// Mie'#10+
 '// DEFAULT'#10+
 ''#10+
 'const float HM=1.2;'#10+
 'const vec3 betaMSca=vec3(4e-3);'#10+
 'const vec3 betaMEx=betaMSca / 0.9;'#10+
 'const float mieG=0.8;'#10+
 ''#10+
 '// CLEAR SKY'#10+
 '/*'#10+
 'const float HM=1.2;'#10+
 'const vec3 betaMSca=vec3(20e-3);'#10+
 'const vec3 betaMEx=betaMSca / 0.9;'#10+
 'const float mieG=0.76;'#10+
 '*/'#10+
 '// PARTLY CLOUDY'#10+
 '/*'#10+
 'const float HM=3.0;'#10+
 'const vec3 betaMSca=vec3(3e-3);'#10+
 'const vec3 betaMEx=betaMSca / 0.9;'#10+
 'const float mieG=0.65;'#10+
 '*/'#10;

 mainsep:=
 '//############################################################################//'#10+
 'uniform vec3 c;'#10+
 'uniform vec3 s;'#10+
 'uniform float exposure;'#10+
 '//############################################################################//'#10+
 'uniform sampler2D reflectanceSampler;//ground reflectance texture'#10+
 'uniform sampler2D irradianceSampler;//precomputed skylight irradiance (E table)'#10+
 'uniform sampler3D inscatterSampler;//precomputed inscattered light (S table)'#10+
 'uniform sampler2D transmittanceSampler;'#10+
 'uniform sampler2D depth;'#10+
 '//############################################################################//'#10+
 'varying vec3 ray;'#10+
 'varying vec2 coords;'#10+
 '//############################################################################//'#10+
 'const float pi=3.141592657;'#10+
 'const float ISun=100.0;'#10+
 '//############################################################################//'#10+
 'float sqrtgl(float x){if(x<0.0)return 0.0;else return sqrt(x);}'#10+
 'float powgl(float x,float n){if(x==0.0&&n==0.0)return 0.0;else if(n>0.0)return pow(x,n);else return 1.0/pow(x,-n);} '#10+
 '//############################################################################//'#10+
 'float phaseFunctionR    (float mu)         {return (3.0/(16.0*pi))*(1.0+mu*mu);}'#10+
 'float phaseFunctionM    (float mu)         {return 1.5*1.0/(4.0*pi)*(1.0-mieG*mieG)*powgl(1.0+(mieG*mieG)-2.0*mieG*mu,-3.0/2.0)*(1.0+mu*mu)/(2.0+mieG*mieG);}'#10+
 'vec3  getMie            (vec4 rayMie)      {return rayMie.rgb*rayMie.w/max(rayMie.r,1e-4)*(betaR.r/betaR);}'#10+
 'vec2  getIrradianceUV   (float r,float muS){float uR=(r-Rg)/(Rt-Rg);float uMuS=(muS+0.2)/(1.0+0.2);return vec2(uMuS,uR);}'#10+
 'vec2  getTransmittanceUV(float r,float mu) {float uR=sqrtgl((r-Rg)/(Rt-Rg));float uMu=atan((mu+0.15)/(1.0+0.15)*tan(1.5))/1.5;return vec2(uMu,uR);}'#10+
 '//############################################################################//'#10+
 'vec3  irradiance             (sampler2D sampler,float r,float muS){vec2 uv=getIrradianceUV(r,muS);return texture2D(sampler,uv).rgb;}'#10+
 'vec3  transmittance          (float r,float mu)                   {vec2 uv=getTransmittanceUV(r,mu);return texture2D(transmittanceSampler,uv).rgb;}'#10+
 'vec3  transmittanceWithShadow(float r,float mu)                   {return mu<-sqrtgl(1.0-(Rg/r)*(Rg/r))?vec3(0.0):transmittance(r,mu);}'#10+
 '//############################################################################//'#10+
 'float opticalDepth(float H,float r,float mu,float d)'#10+
 '{'#10+
 ' float a=sqrtgl((0.5/H)*r);'#10+
 ' vec2 a01=a*vec2(mu,mu+d/r);'#10+
 ' vec2 a01s=sign(a01);'#10+
 ' vec2 a01sq=a01*a01;'#10+
 ' float x=a01s.y > a01s.x ? exp(a01sq.x) : 0.0;'#10+
 ' vec2 y=a01s/(2.3193*abs(a01)+sqrt(1.52*a01sq+4.0))*vec2(1.0,exp(-d/H*(d/(2.0*r)+mu)));'#10+
 ' return sqrtgl((6.2831*H)*r)*exp((Rg-r)/H)*(x+dot(y,vec2(1.0,-1.0)));'#10+
 '}'#10+
 '//############################################################################//'#10+
 'vec3 analyticTransmittance(float r,float mu,float d){return exp(-betaR*opticalDepth(HR,r,mu,d)-betaMEx*opticalDepth(HM,r,mu,d));}'#10+
 '//############################################################################//'#10+
 'vec4 texture4D(sampler3D table,float r,float mu,float muS,float nu)'#10+
 '{'#10+
 ' float H=sqrtgl(Rt*Rt-Rg*Rg);'#10+
 ' float rho=sqrtgl(r*r-Rg*Rg);'#10+
 ''#10+
 ' float rmu=r*mu;'#10+
 ' float delta=rmu*rmu-r*r+Rg*Rg;'#10+
 ' vec4 cst=rmu < 0.0 && delta > 0.0 ? vec4(1.0,0.0,0.0,0.5-0.5/float(RES_MU)) : vec4(-1.0,H*H,H,0.5+0.5/float(RES_MU));'#10+
 ' float uR=0.5/float(RES_R)+rho/H*(1.0-1.0/float(RES_R));'#10+
 ' float k=rho+cst.z;'#10+
 ' float uMu=cst.w+(rmu*cst.x+sqrtgl(delta+cst.y))/k*(0.5-1.0/float(RES_MU));'#10+
 ' float uMuS=0.5/float(RES_MU_S)+(atan(max(muS,-0.1975)*tan(1.26*1.1))/1.1+(1.0-0.26))*0.5*(1.0-1.0/float(RES_MU_S));'#10+
 ''#10+
 ' float lerp=(nu+1.0)/2.0*(float(RES_NU)-1.0);'#10+
 ' float uNu=floor(lerp);'#10+
 ' lerp=lerp-uNu;'#10+
 ' return texture3D(table,vec3((uNu+uMuS)/float(RES_NU),uMu,uR))*(1.0-lerp) +'#10+
 '        texture3D(table,vec3((uNu+uMuS+1.0)/float(RES_NU),uMu,uR))*lerp;'#10+
 '}'#10+
 '//############################################################################//'#10+
 '//############################################################################//'#10+
 'vec3 inscatter(inout vec3 x,inout float t,vec3 v,vec3 s,out float r,out float mu,out vec3 attenuation)'#10+
 '{'#10+
 ' vec3 result;'#10+
 ' r=length(x);'#10+
 ' mu=dot(x,v)/r;'#10+
 ' float d=-r*mu-sqrtgl(r*r*(mu*mu-1.0)+Rt*Rt);'#10+
 ' if(d>0.0){'#10+
 '  //if x in space and ray intersects atmosphere'#10+
 '  //move x to nearest intersection of ray with top atmosphere boundary'#10+
 '  x+=d*v;'#10+
 '  t-=d;'#10+
 '  mu=(r*mu+d)/Rt;'#10+
 '  r=Rt;'#10+
 ' }'#10+
 ' if(r<=Rt){'#10+
 '  //if ray intersects atmosphere'#10+
 '  float nu=dot(v,s);'#10+
 '  float muS=dot(x,s)/r;'#10+
 '  float phaseR=phaseFunctionR(nu);'#10+
 '  float phaseM=phaseFunctionM(nu);'#10+
 '  vec4 inscatter=max(texture4D(inscatterSampler,r,mu,muS,nu),0.0);'#10+
 '  if(t>0.0){'#10+
 '   vec3 x0=x+t*v;'#10+
 '   float r0=length(x0);'#10+
 '   float rMu0=dot(x0,v);'#10+
 '   float mu0=rMu0/r0;'#10+
 '   float muS0=dot(x0,s)/r0;'#10+
 ''#10+
 '   //avoids imprecision problems in transmittance computations based on textures'#10+
 '   attenuation=analyticTransmittance(r,mu,t);'#10+
 '   if(r0>Rg+0.01){'#10+
 '    //computes S[L]-T(x,x0)S[L]|x0'#10+
 '    inscatter=max(inscatter-attenuation.rgbr*texture4D(inscatterSampler,r0,mu0,muS0,nu),0.0);'#10+
 '    //avoids imprecision problems near horizon by interpolating between two points above and below horizon'#10+
 '    const float EPS=0.004;'#10+
 '    float muHoriz=-sqrtgl(1.0-(Rg/r)*(Rg/r));'#10+
 '    if(abs(mu-muHoriz)<EPS){'#10+
 '     float a=((mu-muHoriz)+EPS)/(2.0*EPS);'#10+
 ''#10+
 '     mu=muHoriz-EPS;'#10+
 '     r0=sqrtgl(r*r+t*t+2.0*r*t*mu);'#10+
 '     mu0=(r*mu+t)/r0;'#10+
 '     vec4 inScatter0=texture4D(inscatterSampler,r,mu,muS,nu);'#10+
 '     vec4 inScatter1=texture4D(inscatterSampler,r0,mu0,muS0,nu);'#10+
 '     vec4 inScatterA=max(inScatter0-attenuation.rgbr*inScatter1,0.0);'#10+
 ''#10+
 '     mu=muHoriz+EPS;'#10+
 '     r0=sqrtgl(r*r+t*t+2.0*r*t*mu);'#10+
 '     mu0=(r*mu+t)/r0;'#10+
 '     inScatter0=texture4D(inscatterSampler,r,mu,muS,nu);'#10+
 '     inScatter1=texture4D(inscatterSampler,r0,mu0,muS0,nu);'#10+
 '     vec4 inScatterB=max(inScatter0-attenuation.rgbr*inScatter1,0.0);'#10+
 ''#10+
 '     inscatter=mix(inScatterA,inScatterB,a);'#10+
 '    }'#10+
 '   }'#10+
 '  }'#10+
 '  //avoids imprecision problems in Mie scattering when sun is below horizon'#10+
 '  inscatter.w *= smoothstep(0.00,0.02,muS);'#10+
 '  result=max(inscatter.rgb*phaseR+getMie(inscatter)*phaseM,0.0);'#10+
 ' }else result=vec3(0.0);//x in space and ray looking in space'#10+
 ''#10+
 ' return result*ISun;'#10+
 '}'#10+
 '//############################################################################//'#10+
 '//ground radiance at end of ray x+tv,when sun in direction s attenuated bewteen ground and viewer (=R[L0]+R[L*])'#10+
 'vec3 groundColor(vec3 x,float t,vec3 v,vec3 s,float r,float mu,vec3 attenuation)'#10+
 '{'#10+
 ' vec3 result;'#10+
 ' if(t>0.0){'#10+
 '  //if ray hits ground surface'#10+
 ''#10+
 '  //ground reflectance at end of ray,x0'#10+
 '  vec3 x0=x+t*v;'#10+
 '  float r0=length(x0);'#10+
 '  vec3 n=x0/r0;'#10+
 '  vec2 coords=vec2(atan(n.y,n.x),acos(n.z))*vec2(0.5,1.0)/pi+vec2(0.5,0.0);'#10+
 '  vec4 reflectance=texture2D(reflectanceSampler,coords)*vec4(0.2,0.2,0.2,1.0);'#10+
 '  if(r0>Rg+0.01)reflectance=vec4(0.4,0.4,0.4,0.0);'#10+
 ''#10+
 '  //direct sun light (radiance) reaching x0'#10+
 '  float muS=dot(n,s);'#10+
 '  vec3 sunLight=transmittanceWithShadow(r0,muS);'#10+
 ''#10+
 '  //precomputed sky light (irradiance) at x0'#10+
 '  vec3 groundSkyLight=irradiance(irradianceSampler,r0,muS);'#10+
 ''#10+
 '  //light reflected at x0'#10+
 '  vec3 groundColor=reflectance.rgb*(max(muS,0.0)*sunLight+groundSkyLight)*ISun/pi;'#10+
 ''#10+
 '  //water specular color due to sunLight'#10+
 '  if(reflectance.w>0.0){'#10+
 '   vec3 h=normalize(s-v);'#10+
 '   float fresnel=0.02+0.98*powgl(1.0-dot(-v,h),5.0);'#10+
 '   float waterBrdf=fresnel*powgl(max(dot(h,n),0.0),150.0);'#10+
 '   groundColor+=reflectance.w*max(waterBrdf,0.0)*sunLight*ISun;'#10+
 '  }'#10+
 ''#10+
 '  result=attenuation*groundColor;'#10+
 ' }else result=vec3(0.0); //ray looking at the sky'#10+
 ''#10+
 ' return result;'#10+
 '}'#10+
 '//############################################################################//'#10+
 'vec3 sunColor(vec3 x,float t,vec3 v,vec3 s,float r,float mu)'#10+
 '{'#10+
 ' if(t>0.0){'#10+
 '  return vec3(0.0);'#10+
 ' }else{'#10+
 '  vec3 transmittance=r<=Rt?transmittanceWithShadow(r,mu):vec3(1.0);'#10+
 '  float isun=step(cos(pi/360.0),dot(v,s))*ISun;'#10+
 '  return transmittance*isun;'#10+
 ' }'#10+
 '}'#10+
 '//############################################################################//'#10+
 'vec3 HDR(vec3 L)'#10+
 '{'#10+
 ' L=L*exposure;'#10+
 ' L.r=L.r<1.413?powgl(L.r*0.38317,1.0/2.2):1.0-exp(-L.r);'#10+
 ' L.g=L.g<1.413?powgl(L.g*0.38317,1.0/2.2):1.0-exp(-L.g);'#10+
 ' L.b=L.b<1.413?powgl(L.b*0.38317,1.0/2.2):1.0-exp(-L.b);'#10+
 ' return L;'#10+
 '}'#10+
 '//############################################################################//'#10+
 'void main()'#10+
 '{'#10+
 ' vec3 x=c;'#10+
 ' vec3 v=normalize(ray);'#10+
 ''#10+
 ' float r=length(x);'#10+
 ' float mu=dot(x,v)/r;'#10+
 ' float t=r*r*(mu*mu-1.0)+Rg*Rg;'#10+
 ' if(t<0.0)t=0.0;'#10+
 ' else t=-r*mu-sqrt(t);'#10+
 ''#10+
 ' vec3 g=x-vec3(0.0,0.0,Rg+10.0);'#10+
 ' float a=v.x*v.x+v.y*v.y-v.z*v.z;'#10+
 ' float b=2.0*(g.x*v.x+g.y*v.y-g.z*v.z);'#10+
 ' float cc=g.x*g.x+g.y*g.y-g.z*g.z;'#10+
 ' float d=b*b-4.0*a*cc;'#10+
 ' if(d<0.0)d=0.0;else d=-(b+sqrt(d))/(2.0*a);'#10+
 ' bool cone=(d>0.0)&&(abs(x.z+d*v.z-Rg)<=10.0);'#10+
 ''#10+
 ' if(t>0.0){'#10+
 '  if(cone &&(d<t))t=d;'#10+
 ' }else if(cone)t=d;'#10+
 ' '#10+
 ' vec4 depthSample=texture2D(depth,coords);'#10+
 ' float depth=depthSample.x*255.0/256.0+depthSample.y*255.0/65536.0+depthSample.z*255.0/16777216.0;'#10+
 ' vec4 screenPos=vec4(coords.x,coords.y,depth,1.0)*2.0-1.0;'#10+
 ' vec4 viewPosition=gl_ProjectionMatrixInverse*screenPos;'#10+
 ' float z=-(viewPosition.z/viewPosition.w)/70000.0;'#10+
 ' z=clamp(z,0.0,1.0);'#10+
 ' '#10+
 ' vec3 attenuation;'#10+
 ' vec3 inscatterColor=inscatter(x,t,v,s,r,mu,attenuation);'#10+
 ' vec3 groundColor=groundColor(x,t,v,s,r,mu,attenuation);'#10+
 ' vec3 sunColor=sunColor(x,t,v,s,r,mu);'#10+
 ' '#10+
 ' float alpha;'#10+
 ' groundColor=vec3(0.0);'#10+
 ' vec3 color=HDR(sunColor+groundColor+inscatterColor);'#10+
 ' if(t>0.0){'#10+
 '  alpha=clamp(t/sqrt(16.0*r),0.0,1.0);'#10+
 ' }else alpha=clamp(max(color.r,min(color.g,color.b)),0.0,1.0);'#10+
 ' alpha*=z;'#10+
 ' '#10+
 ' gl_FragColor=vec4(color,alpha);'#10+
 ' '#10+
 ' //gl_FragColor=vec4(HDR(sunColor+groundColor+inscatterColor),1.0);'#10+
 ' //gl_FragColor=vec4(ttt,ttt,ttt,1.0);'#10+
 ' //gl_FragColor=vec4(sqrt(ray.x),sqrt(ray.y),sqrt(ray.z),1.0);'#10+
 ' //gl_FragColor=vec4(vec3(coords,0.0),1.0);'#10+
 ' //gl_FragColor=texture3D(inscatterSampler,vec3(coords,(s.x+1.0)/2.0));'#10+
 ' //gl_FragColor=vec4(texture2D(irradianceSampler,coords).rgb*5.0,1.0);'#10+
 ' //gl_FragColor=texture2D(transmittanceSampler,coords);'#10+
 '}'#10+
 '//############################################################################//'#10+
 ''#10;
end;
//############################################################################//
procedure make_gen_shaders;
begin 
 common:=
 'const float AVERAGE_GROUND_REFLECTANCE=0.1;'#10+
 'const int TRANSMITTANCE_INTEGRAL_SAMPLES=500;'#10+
 'const int INSCATTER_INTEGRAL_SAMPLES=50;'#10+
 'const int IRRADIANCE_INTEGRAL_SAMPLES=32;'#10+
 'const int INSCATTER_SPHERICAL_INTEGRAL_SAMPLES=16;'#10+
 'const float M_PI=3.141592657;'#10+
 ''#10+
 'uniform sampler2D transmittanceSampler;'#10+
 ''#10+
 '#ifdef _FRAGMENT_'#10+
 'void getTransmittanceRMu(out float r,out float muS)'#10+
 '{'#10+
 ' r=gl_FragCoord.y/float(TRANSMITTANCE_H);'#10+
 ' muS=gl_FragCoord.x/float(TRANSMITTANCE_W);'#10+
 ' r=Rg+(r*r)*(Rt-Rg);'#10+
 ' muS=-0.15+tan(1.5*muS)/tan(1.5)*(1.0+0.15);'#10+
 '}'#10+
 'void getIrradianceRMuS(out float r,out float muS)'#10+
 '{'#10+
 ' r=Rg+(gl_FragCoord.y-0.5)/(float(SKY_H)-1.0)*(Rt-Rg);'#10+
 ' muS=-0.2+(gl_FragCoord.x-0.5)/(float(SKY_W)-1.0)*(1.0+0.2);'#10+
 '}'#10+
 '#endif'#10+
 'vec2 getTransmittanceUV(float r,float mu)'#10+
 '{'#10+
 ' float uR,uMu;'#10+
 '	uR=sqrt((r-Rg)/(Rt-Rg));'#10+
 '	uMu=atan((mu+0.15)/(1.0+0.15)*tan(1.5))/1.5;'#10+
 ' return vec2(uMu,uR);'#10+
 '}'#10+
 'vec2 getIrradianceUV(float r,float muS)'#10+
 '{'#10+
 ' float uR=(r-Rg)/(Rt-Rg);'#10+
 ' float uMuS=(muS+0.2)/(1.0+0.2);'#10+
 ' return vec2(uMuS,uR);'#10+
 '}'#10+
 'vec4 texture4D(sampler3D table,float r,float mu,float muS,float nu)'#10+
 '{'#10+
 ' float H=sqrt(Rt*Rt-Rg*Rg);'#10+
 ' float rho=sqrt(r*r-Rg*Rg);'#10+
 ' float rmu=r*mu;'#10+
 ' float delta=rmu*rmu-r*r+Rg*Rg;'#10+
 ' vec4 cst=rmu<0.0 && delta>0.0?vec4(1.0,0.0,0.0,0.5-0.5/float(RES_MU)):vec4(-1.0,H*H,H,0.5+0.5/float(RES_MU));'#10+
 ' float uR=0.5/float(RES_R)+rho/H*(1.0-1.0/float(RES_R));'#10+
 ' float uMu=cst.w+(rmu*cst.x+sqrt(delta+cst.y))/(rho+cst.z)*(0.5-1.0/float(RES_MU));'#10+
 ' float uMuS=0.5/float(RES_MU_S)+(atan(max(muS,-0.1975)*tan(1.26*1.1))/1.1+(1.0-0.26))*0.5*(1.0-1.0/float(RES_MU_S));'#10+
 ' float lerp=(nu+1.0)/2.0*(float(RES_NU)-1.0);'#10+
 ' float uNu=floor(lerp);'#10+
 ' lerp=lerp-uNu;'#10+
 ' return texture3D(table,vec3((uNu+uMuS)/float(RES_NU),uMu,uR))*(1.0-lerp)+'#10+
 '        texture3D(table,vec3((uNu+uMuS+1.0)/float(RES_NU),uMu,uR))*lerp;'#10+
 '}'#10+
 '#ifdef _FRAGMENT_'#10+
 'void getMuMuSNu(float r,vec4 dhdH,out float mu,out float muS,out float nu)'#10+
 '{'#10+
 ' float x=gl_FragCoord.x-0.5;'#10+
 ' float y=gl_FragCoord.y-0.5;'#10+
 ' if(y<float(RES_MU)/2.0){'#10+
 '  float d=1.0-y/(float(RES_MU)/2.0-1.0);'#10+
 '  d=min(max(dhdH.z,d*dhdH.w),dhdH.w*0.999);'#10+
 '  mu=(Rg*Rg-r*r-d*d)/(2.0*r*d);'#10+
 '  mu=min(mu,-sqrt(1.0-(Rg/r)*(Rg/r))-0.001);'#10+
 ' }else{'#10+
 '  float d=(y-float(RES_MU)/2.0)/(float(RES_MU)/2.0-1.0);'#10+
 '  d=min(max(dhdH.x,d*dhdH.y),dhdH.y*0.999);'#10+
 '  mu=(Rt*Rt-r*r-d*d)/(2.0*r*d);'#10+
 ' }'#10+
 ' muS=mod(x,float(RES_MU_S))/(float(RES_MU_S)-1.0);'#10+
 ' muS=tan((2.0*muS-1.0+0.26)*1.1)/tan(1.26*1.1);'#10+
 ' nu=-1.0+floor(x/float(RES_MU_S))/(float(RES_NU)-1.0)*2.0;'#10+
 '}'#10+
 '#endif'#10+
 
 'float limit(float r,float mu)'#10+
 '{'#10+
 ' float dout=-r*mu+sqrt(r*r*(mu*mu-1.0)+RL*RL);'#10+
 ' float delta2=r*r*(mu*mu-1.0)+Rg*Rg;'#10+
 ' if (delta2>=0.0){'#10+
 '  float din=-r*mu-sqrt(delta2);'#10+
 '  if(din>=0.0)dout=min(dout,din);'#10+
 ' }'#10+
 ' return dout;'#10+
 '}'#10+
 
 'vec3 transmittance(float r,float mu){vec2 uv=getTransmittanceUV(r,mu);return texture2D(transmittanceSampler,uv).rgb;}'#10+
 'vec3 transmittanceWithShadow(float r,float mu){return mu<-sqrt(1.0-(Rg/r)*(Rg/r))?vec3(0.0):transmittance(r,mu);}'#10+
 'vec3 transmittance(float r,float mu,vec3 v,vec3 x0)'#10+
 '{'#10+
 ' vec3 result;'#10+
 ' float r1=length(x0);'#10+
 ' float mu1=dot(x0,v)/r;'#10+
 ' if(mu>0.0){'#10+
 '  result=min(transmittance(r,mu)/transmittance(r1,mu1),1.0);'#10+
 ' }else{'#10+
 '  result=min(transmittance(r1,-mu1)/transmittance(r,-mu),1.0);'#10+
 ' }'#10+
 ' return result;'#10+
 '}'#10+
 'float opticalDepth(float H,float r,float mu,float d)'#10+
 '{'#10+
 ' float a=sqrt((0.5/H)*r);'#10+
 ' vec2 a01=a*vec2(mu,mu+d/r);'#10+
 ' vec2 a01s=sign(a01);'#10+
 ' vec2 a01sq=a01*a01;'#10+
 ' float x=a01s.y > a01s.x ? exp(a01sq.x) : 0.0;'#10+
 ' vec2 y=a01s/(2.3193*abs(a01)+sqrt(1.52*a01sq+4.0))*vec2(1.0,exp(-d/H*(d/(2.0*r)+mu)));'#10+
 ' return sqrt((6.2831*H)*r)*exp((Rg-r)/H)*(x+dot(y,vec2(1.0,-1.0)));'#10+
 '}'#10+
 'vec3 analyticTransmittance(float r,float mu,float d){return exp(- betaR*opticalDepth(HR,r,mu,d)-betaMEx*opticalDepth(HM,r,mu,d));}'#10+
 'vec3 transmittance(float r,float mu,float d)'#10+
 '{'#10+
 ' vec3 result;'#10+
 ' float r1=sqrt(r*r+d*d+2.0*r*mu*d);'#10+
 ' float mu1=(r*mu+d)/r1;'#10+
 ' if(mu>0.0){'#10+
 '  result=min(transmittance(r,mu)/transmittance(r1,mu1),1.0);'#10+
 ' }else{'#10+
 '  result=min(transmittance(r1,-mu1)/transmittance(r,-mu),1.0);'#10+
 ' }'#10+
 ' return result;'#10+
 '}'#10+
 'vec3 irradiance(sampler2D sampler,float r,float muS){vec2 uv=getIrradianceUV(r,muS);return texture2D(sampler,uv).rgb;}'#10+
 'float phaseFunctionR(float mu){return (3.0/(16.0*M_PI))*(1.0+mu*mu);}'#10+
 'float phaseFunctionM(float mu){return 1.5*1.0/(4.0*M_PI)*(1.0-mieG*mieG)*pow(1.0+(mieG*mieG)-2.0*mieG*mu,-3.0/2.0)*(1.0+mu*mu)/(2.0+mieG*mieG);}'#10+
 'vec3 getMie(vec4 rayMie){return rayMie.rgb*rayMie.w/max(rayMie.r,1e-4)*(betaR.r/betaR);}'#10;

 copyIrradiance:=
 'uniform float k; //k=0 for line 4,k=1 for line 10'#10+
 'uniform sampler2D deltaESampler;'#10+
 '#ifdef _VERTEX_'#10+
 'void main(){gl_Position=gl_Vertex;}'#10+
 '#endif'#10+
 '#ifdef _FRAGMENT_'#10+
 'void main(){vec2 uv=gl_FragCoord.xy/vec2(SKY_W,SKY_H);gl_FragColor=k*texture2D(deltaESampler,uv);} //k=0 for line 4,k=1 for line 10'#10+
 '#endif'#10;

 irradiance1:=
 '#ifdef _VERTEX_'#10+
 'void main(){gl_Position=gl_Vertex;}'#10+
 '#endif'#10+
 '#ifdef _FRAGMENT_'#10+
 'void main(){float r,muS;getIrradianceRMuS(r,muS);gl_FragColor=vec4(transmittance(r,muS)*max(muS,0.0),0.0);}'#10+
 '#endif'#10;
 
 transmittance:=
 '#ifdef _VERTEX_'#10+
 'void main(){gl_Position=gl_Vertex;}'#10+
 '#else'#10+
 'float opticalDepth(float H,float r,float mu)'#10+
 '{'#10+
 ' float result=0.0;'#10+
 ' float dx=limit(r,mu)/float(TRANSMITTANCE_INTEGRAL_SAMPLES);'#10+
 ' float xi=0.0;'#10+
 ' float yi=exp(-(r-Rg)/H);'#10+
 ' for(int i=1;i <=TRANSMITTANCE_INTEGRAL_SAMPLES;++i){'#10+
 '  float xj=float(i)*dx;'#10+
 '  float yj=exp(-(sqrt(r*r+xj*xj+2.0*xj*r*mu)-Rg)/H);'#10+
 '  result+=(yi+yj)/2.0*dx;'#10+
 '  xi=xj;'#10+
 '  yi=yj;'#10+
 ' }'#10+
 ' return mu<-sqrt(1.0-(Rg/r)*(Rg/r))?1e9:result;'#10+
 '}'#10+
 'void main(){'#10+
 ' float r,muS;'#10+
 ' getTransmittanceRMu(r,muS);'#10+
 ' vec3 depth=betaR*opticalDepth(HR,r,muS)+betaMEx*opticalDepth(HM,r,muS);'#10+
 ' gl_FragColor=vec4(exp(-depth),0.0);'#10+
 '}'#10+
 '#endif'#10;

 copyInscatterN:=
 'uniform float r;'#10+
 'uniform vec4 dhdH;'#10+
 'uniform int layer;'#10+
 'uniform sampler3D deltaSSampler;'#10+
 '#ifdef _VERTEX_'#10+
 'void main(){gl_Position=gl_Vertex;}'#10+
 '#endif'#10+
 '#ifdef _GEOMETRY_'#10+
 '#extension GL_EXT_geometry_shader4 : enable'#10+
 'void main()'#10+
 '{'#10+
 ' gl_Position=gl_PositionIn[0];'#10+
 ' gl_Layer=layer;'#10+
 ' EmitVertex();'#10+
 ' gl_Position=gl_PositionIn[1];'#10+
 ' gl_Layer=layer;'#10+
 ' EmitVertex();'#10+
 ' gl_Position=gl_PositionIn[2];'#10+
 ' gl_Layer=layer;'#10+
 ' EmitVertex();'#10+
 ' EndPrimitive();'#10+
 '}'#10+
 '#endif'#10+
 '#ifdef _FRAGMENT_'#10+
 'void main()'#10+
 '{'#10+
 ' float mu,muS,nu;'#10+
 ' getMuMuSNu(r,dhdH,mu,muS,nu);'#10+
 ' vec3 uvw=vec3(gl_FragCoord.xy,float(layer)+0.5)/vec3(ivec3(RES_MU_S*RES_NU,RES_MU,RES_R));'#10+
 ' gl_FragColor=vec4(texture3D(deltaSSampler,uvw).rgb/phaseFunctionR(nu),0.0);'#10+
 '}'#10+
 '#endif'#10;
 
 copyInscatter1:=
 'uniform float r;'#10+
 'uniform vec4 dhdH;'#10+
 'uniform int layer;'#10+
 'uniform sampler3D deltaSRSampler;'#10+
 'uniform sampler3D deltaSMSampler;'#10+
 '#ifdef _VERTEX_'#10+
 'void main(){gl_Position=gl_Vertex;}'#10+
 '#endif'#10+
 '#ifdef _GEOMETRY_'#10+
 '#extension GL_EXT_geometry_shader4 : enable'#10+
 'void main()'#10+
 '{'#10+
 ' gl_Position=gl_PositionIn[0];'#10+
 ' gl_Layer=layer;'#10+
 ' EmitVertex();'#10+
 ' gl_Position=gl_PositionIn[1];'#10+
 ' gl_Layer=layer;'#10+
 ' EmitVertex();'#10+
 ' gl_Position=gl_PositionIn[2];'#10+
 ' gl_Layer=layer;'#10+
 ' EmitVertex();'#10+
 ' EndPrimitive();'#10+
 '}'#10+
 '#endif'#10+
 '#ifdef _FRAGMENT_'#10+
 'void main()'#10+
 '{'#10+
 ' vec3 uvw=vec3(gl_FragCoord.xy,float(layer)+0.5)/vec3(ivec3(RES_MU_S*RES_NU,RES_MU,RES_R));'#10+
 ' vec4 ray=texture3D(deltaSRSampler,uvw);'#10+
 ' vec4 mie=texture3D(deltaSMSampler,uvw);'#10+
 ' gl_FragColor=vec4(ray.rgb,mie.r); //store only red component of single Mie scattering (cf. "Angular precision")'#10+
 '}'#10+
 '#endif'#10;
 
 inscatterN:=
 'uniform float r;'#10+
 'uniform vec4 dhdH;'#10+
 'uniform int layer;'#10+
 'uniform sampler3D deltaJSampler;'#10+
 '#ifdef _VERTEX_'#10+
 'void main(){gl_Position=gl_Vertex;}'#10+
 '#endif'#10+
 '#ifdef _GEOMETRY_'#10+
 '#extension GL_EXT_geometry_shader4 : enable'#10+
 'void main()'#10+
 '{'#10+
 ' gl_Position=gl_PositionIn[0];'#10+
 ' gl_Layer=layer;'#10+
 ' EmitVertex();'#10+
 ' gl_Position=gl_PositionIn[1];'#10+
 ' gl_Layer=layer;'#10+
 ' EmitVertex();'#10+
 ' gl_Position=gl_PositionIn[2];'#10+
 ' gl_Layer=layer;'#10+
 ' EmitVertex();'#10+
 ' EndPrimitive();'#10+
 '}'#10+
 '#endif'#10+
 '#ifdef _FRAGMENT_'#10+
 'vec3 integrand(float r,float mu,float muS,float nu,float t)'#10+
 '{'#10+
 ' float ri=sqrt(r*r+t*t+2.0*r*mu*t);'#10+
 ' float mui=(r*mu+t)/ri;'#10+
 ' float muSi=(nu*t+muS*r)/ri;'#10+
 ' return texture4D(deltaJSampler,ri,mui,muSi,nu).rgb*transmittance(r,mu,t);'#10+
 '}'#10+
 'vec3 inscatter(float r,float mu,float muS,float nu)'#10+
 '{'#10+
 ' vec3 raymie=vec3(0.0);'#10+
 ' float dx=limit(r,mu)/float(INSCATTER_INTEGRAL_SAMPLES);'#10+
 ' float xi=0.0;'#10+
 ' vec3 raymiei=integrand(r,mu,muS,nu,0.0);'#10+
 ' for(int i=1;i<=INSCATTER_INTEGRAL_SAMPLES;++i){'#10+
 '  float xj=float(i)*dx;'#10+
 '  vec3 raymiej=integrand(r,mu,muS,nu,xj);'#10+
 '  raymie+=(raymiei+raymiej)/2.0*dx;'#10+
 '  xi=xj;'#10+
 '  raymiei=raymiej;'#10+
 ' }'#10+
 ' return raymie;'#10+
 '}'#10+
 'void main(){float mu,muS,nu;getMuMuSNu(r,dhdH,mu,muS,nu);gl_FragColor.rgb=inscatter(r,mu,muS,nu);}'#10+
 '#endif'#10;

 inscatter1:=
 'uniform float r;'#10+
 'uniform vec4 dhdH;'#10+
 'uniform int layer;'#10+
 '#ifdef _VERTEX_'#10+
 'void main(){gl_Position=gl_Vertex;}'#10+
 '#endif'#10+
 '#ifdef _GEOMETRY_'#10+
 '#extension GL_EXT_geometry_shader4 : enable'#10+
 'void main()'#10+
 '{'#10+
 ' gl_Position=gl_PositionIn[0];'#10+
 ' gl_Layer=layer;'#10+
 ' EmitVertex();'#10+
 ' gl_Position=gl_PositionIn[1];'#10+
 ' gl_Layer=layer;'#10+
 ' EmitVertex();'#10+
 ' gl_Position=gl_PositionIn[2];'#10+
 ' gl_Layer=layer;'#10+
 ' EmitVertex();'#10+
 ' EndPrimitive();'#10+
 '}'#10+
 '#endif'#10+
 '#ifdef _FRAGMENT_'#10+
 'void integrand(float r,float mu,float muS,float nu,float t,out vec3 ray,out vec3 mie)'#10+
 '{'#10+
 ' ray=vec3(0.0);'#10+
 ' mie=vec3(0.0);'#10+
 ' float ri=sqrt(r*r+t*t+2.0*r*mu*t);'#10+
 ' float muSi=(nu*t+muS*r)/ri;'#10+
 ' ri=max(Rg,ri);'#10+
 ' if(muSi >= -sqrt(1.0 - Rg*Rg/(ri*ri))){'#10+
 '  vec3 ti=transmittance(r,mu,t)*transmittance(ri,muSi);'#10+
 '  ray=exp(-(ri - Rg)/HR)*ti;'#10+
 '  mie=exp(-(ri - Rg)/HM)*ti;'#10+
 ' }'#10+
 '}'#10+
 'void inscatter(float r,float mu,float muS,float nu,out vec3 ray,out vec3 mie)'#10+
 '{'#10+
 ' ray=vec3(0.0);'#10+
 ' mie=vec3(0.0);'#10+
 ' float dx=limit(r,mu)/float(INSCATTER_INTEGRAL_SAMPLES);'#10+
 ' float xi=0.0;'#10+
 ' vec3 rayi;'#10+
 ' vec3 miei;'#10+
 ' integrand(r,mu,muS,nu,0.0,rayi,miei);'#10+
 ' for (int i=1; i <= INSCATTER_INTEGRAL_SAMPLES; ++i) {'#10+
 '  float xj=float(i)*dx;'#10+
 '  vec3 rayj;'#10+
 '  vec3 miej;'#10+
 '  integrand(r,mu,muS,nu,xj,rayj,miej);'#10+
 '  ray += (rayi+rayj)/2.0*dx;'#10+
 '  mie += (miei+miej)/2.0*dx;'#10+
 '  xi=xj;'#10+
 '  rayi=rayj;'#10+
 '  miei=miej;'#10+
 ' }'#10+
 ' ray *= betaR;'#10+
 ' mie *= betaMSca;'#10+
 '}'#10+
 'void main()'#10+
 '{'#10+
 ' vec3 ray;'#10+
 ' vec3 mie;'#10+
 ' float mu,muS,nu;'#10+
 ' getMuMuSNu(r,dhdH,mu,muS,nu);'#10+
 ' inscatter(r,mu,muS,nu,ray,mie);'#10+
 ' gl_FragData[0].rgb=ray;'#10+
 ' gl_FragData[1].rgb=mie;'#10+
 '}'#10+
 '#endif'#10;

 irradianceN:=
 'uniform sampler3D deltaSRSampler;'#10+
 'uniform sampler3D deltaSMSampler;'#10+
 'uniform float first;'#10+
 '#ifdef _VERTEX_'#10+
 'void main(){gl_Position=gl_Vertex;}'#10+
 '#endif'#10+
 '#ifdef _FRAGMENT_'#10+
 'const float dphi=M_PI/float(IRRADIANCE_INTEGRAL_SAMPLES);'#10+
 'const float dtheta=M_PI/float(IRRADIANCE_INTEGRAL_SAMPLES);'#10+
 'void main()'#10+
 '{'#10+
 ' float r,muS;'#10+
 ' getIrradianceRMuS(r,muS);'#10+
 ' vec3 s=vec3(sqrt(1.0-muS*muS),0.0,muS);'#10+
 ' vec3 result=vec3(0.0);'#10+
 ' for(int iphi=0;iphi<2*IRRADIANCE_INTEGRAL_SAMPLES; ++iphi){'#10+
 '  float phi=(float(iphi)+0.5)*dphi;'#10+
 '  for(int itheta=0; itheta < IRRADIANCE_INTEGRAL_SAMPLES/2; ++itheta) {'#10+
 '   float theta=(float(itheta)+0.5)*dtheta;'#10+
 '   float dw=dtheta*dphi*sin(theta);'#10+
 '   vec3 w=vec3(cos(phi)*sin(theta),sin(phi)*sin(theta),cos(theta));'#10+
 '   float nu=dot(s,w);'#10+
 '   if(first==1.0){'#10+
 '    float pr1=phaseFunctionR(nu);'#10+
 '    float pm1=phaseFunctionM(nu);'#10+
 '    vec3 ray1=texture4D(deltaSRSampler,r,w.z,muS,nu).rgb;'#10+
 '    vec3 mie1=texture4D(deltaSMSampler,r,w.z,muS,nu).rgb;'#10+
 '    result+=(ray1*pr1+mie1*pm1)*w.z*dw;'#10+
 '   }else result+=texture4D(deltaSRSampler,r,w.z,muS,nu).rgb*w.z*dw;'#10+
 '  }'#10+
 ' }'#10+
 ' gl_FragColor=vec4(result,0.0);'#10+
 '}'#10+
 '#endif'#10;

 inscatterS:=
 'uniform float r;'#10+
 'uniform vec4 dhdH;'#10+
 'uniform int layer;'#10+
 'uniform sampler2D deltaESampler;'#10+
 'uniform sampler3D deltaSRSampler;'#10+
 'uniform sampler3D deltaSMSampler;'#10+
 'uniform float first;'#10+
 '#ifdef _VERTEX_'#10+
 'void main(){gl_Position=gl_Vertex;}'#10+
 '#endif'#10+
 '#ifdef _GEOMETRY_'#10+
 '#extension GL_EXT_geometry_shader4 : enable'#10+
 'void main()'#10+
 '{'#10+
 ' gl_Position=gl_PositionIn[0];gl_Layer=layer;EmitVertex();'#10+
 ' gl_Position=gl_PositionIn[1];gl_Layer=layer;EmitVertex();'#10+
 ' gl_Position=gl_PositionIn[2];gl_Layer=layer;EmitVertex();'#10+
 ' EndPrimitive();'#10+
 '}'#10+
 '#endif'#10+
 '#ifdef _FRAGMENT_'#10+
 'const float dphi=M_PI/float(INSCATTER_SPHERICAL_INTEGRAL_SAMPLES);'#10+
 'const float dtheta=M_PI/float(INSCATTER_SPHERICAL_INTEGRAL_SAMPLES);'#10+
 'void inscatter(float r,float mu,float muS,float nu,out vec3 raymie)'#10+
 '{'#10+
 ' r=clamp(r,Rg,Rt);'#10+
 ' mu=clamp(mu,-1.0,1.0);'#10+
 ' muS=clamp(muS,-1.0,1.0);'#10+
 ' float var=sqrt(1.0-mu*mu)*sqrt(1.0-muS*muS);'#10+
 ' nu=clamp(nu,muS*mu-var,muS*mu + var);'#10+
 ' float cthetamin=-sqrt(1.0-(Rg/r)*(Rg/r));'#10+
 ' vec3 v=vec3(sqrt(1.0-mu*mu),0.0,mu);'#10+
 ' float sx=v.x==0.0?0.0:(nu-muS*mu)/v.x;'#10+
 ' vec3 s=vec3(sx,sqrt(max(0.0,1.0-sx*sx-muS*muS)),muS);'#10+
 ' raymie=vec3(0.0);'#10+
 ' for(int itheta=0;itheta<INSCATTER_SPHERICAL_INTEGRAL_SAMPLES;++itheta){'#10+
 '  float theta=(float(itheta)+0.5)*dtheta;'#10+
 '  float ctheta=cos(theta);'#10+
 '  float greflectance=0.0;'#10+
 '  float dground=0.0;'#10+
 '  vec3 gtransp=vec3(0.0);'#10+
 '  if(ctheta<cthetamin){'#10+
 '   greflectance=AVERAGE_GROUND_REFLECTANCE/M_PI;'#10+
 '   dground=-r*ctheta-sqrt(r*r*(ctheta*ctheta-1.0) + Rg*Rg);'#10+
 '   gtransp=transmittance(Rg,-(r*ctheta + dground)/Rg,dground);'#10+
 '  }'#10+
 '  for(int iphi=0;iphi<2*INSCATTER_SPHERICAL_INTEGRAL_SAMPLES;++iphi){'#10+
 '   float phi=(float(iphi) + 0.5)*dphi;'#10+
 '   float dw=dtheta*dphi*sin(theta);'#10+
 '   vec3 w=vec3(cos(phi)*sin(theta),sin(phi)*sin(theta),ctheta);'#10+
 '   float nu1=dot(s,w);'#10+
 '   float nu2=dot(v,w);'#10+
 '   float pr2=phaseFunctionR(nu2);'#10+
 '   float pm2=phaseFunctionM(nu2);'#10+
 '   vec3 gnormal=(vec3(0.0,0.0,r) + dground*w)/Rg;'#10+
 '   vec3 girradiance=irradiance(deltaESampler,Rg,dot(gnormal,s));'#10+
 '   vec3 raymie1;'#10+
 '   raymie1=greflectance*girradiance*gtransp;'#10+
 '   if(first==1.0){'#10+
 '    float pr1=phaseFunctionR(nu1);'#10+
 '    float pm1=phaseFunctionM(nu1);'#10+
 '    vec3 ray1=texture4D(deltaSRSampler,r,w.z,muS,nu1).rgb;'#10+
 '    vec3 mie1=texture4D(deltaSMSampler,r,w.z,muS,nu1).rgb;'#10+
 '    raymie1 += ray1*pr1 + mie1*pm1;'#10+
 '   }else raymie1 += texture4D(deltaSRSampler,r,w.z,muS,nu1).rgb;'#10+
 '   raymie += raymie1*(betaR*exp(-(r-Rg)/HR)*pr2 + betaMSca*exp(-(r-Rg)/HM)*pm2)*dw;'#10+
 '  }'#10+
 ' }'#10+
 '}'#10+
 'void main()'#10+
 '{'#10+
 ' vec3 raymie;'#10+
 ' float mu,muS,nu;'#10+
 ' getMuMuSNu(r,dhdH,mu,muS,nu);'#10+
 ' inscatter(r,mu,muS,nu,raymie);'#10+
 ' gl_FragColor.rgb=raymie;'#10+
 '}'#10+
 '#endif'#10;
end;
//############################################################################//           
//############################################################################//
procedure shot(xs,ys:integer;fn:string);
var p:pointer;
f:file;
begin
 getmem(p,xs*ys*4*3);   
 //fillchar(p^,xs*ys*4*3,0);   
 //glGetTexImage(GL_TEXTURE_2D,0,GL_BGRA,GL_UNSIGNED_INT_8_8_8_8_REV,p);
 //storeBMP32(fn+'.bmp',p,xs,ys,false,false);  
 fillchar(p^,xs*ys*4*3,0);
 
 glGetTexImage(GL_TEXTURE_2D,0,GL_RGB,GL_FLOAT,p);
 assignfile(f,fn);
 rewrite(f,1);
 blockwrite(f,p^,xs*ys*4*3);
 closefile(f);
 freemem(p);
end;              
//############################################################################//
procedure shot3d(xs,ys,zs:integer;fn:string);
var p:pointer;
f:file;
begin
 getmem(p,xs*ys*zs*4*4);  
 fillchar(p^,xs*ys*zs*4*4,0);
                                          
 glGetTexImage(GL_TEXTURE_3D,0,GL_RGBA,GL_FLOAT,p);
 assignfile(f,fn);
 rewrite(f,1);
 blockwrite(f,p^,xs*ys*zs*4*4);
 closefile(f);
 freemem(p);
end;        
//############################################################################//
procedure setLayer(prog:dword;layer:integer);
var dhdH:quat;
r:double;
begin   
 comp_layer(layer,dhdH,r);
 glUniform1f(glGetUniformLocation(prog,'r'),r);
 glUniform4f(glGetUniformLocation(prog,'dhdH'),dhdH.x,dhdH.y,dhdH.z,dhdH.w);
 glUniform1i(glGetUniformLocation(prog,'layer'),layer);
end;   
//############################################################################//
//############################################################################//
//############################################################################//             
//############################################################################//
function precompute_gpu(trans,irr,ins:string):boolean;
const 
deltaEUnit=4;
deltaSRUnit=5;
deltaSMUnit=6;
deltaJUnit=7;

var 
f,maco:string;   
bufs:array[0..1]of dword;
layer,order:integer;

deltaETexture:dword; //unit 4,deltaE table
deltaSRTexture:dword;//unit 5,deltaS table (Rayleigh part)
deltaSMTexture:dword;//unit 6,deltaS table (Mie part)
deltaJTexture:dword; //unit 7,deltaJ table          
fbo:dword;
transmittanceProg,irradiance1Prog,inscatter1Prog,copyIrradianceProg,copyInscatter1Prog,jProg,irradianceNProg,inscatterNProg,copyInscatterNProg:ogl_shader;
begin
 result:=false;
 glActiveTexturearb(GL_TEXTURE0_ARB+transmittanceUnit);
 glGenTextures(1,@transmittanceTexture);
 glBindTexture(GL_TEXTURE_2D,transmittanceTexture);
 glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
 glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
 glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
 glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
 glBindBufferarb(GL_PIXEL_UNPACK_BUFFER_ARB,0);
 glTexImage2D(GL_TEXTURE_2D,0,GL_RGB16F_ARB,TRANSMITTANCE_W,TRANSMITTANCE_H,0,GL_RGB,GL_FLOAT,nil);

 glActiveTexturearb(GL_TEXTURE0_ARB+irradianceUnit);
 glGenTextures(1,@irradianceTexture);
 glBindTexture(GL_TEXTURE_2D,irradianceTexture);
 glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
 glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
 glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
 glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
 glBindBufferarb(GL_PIXEL_UNPACK_BUFFER_ARB,0);
 glTexImage2D(GL_TEXTURE_2D,0,GL_RGB16F_ARB,SKY_W,SKY_H,0,GL_RGB,GL_FLOAT,nil);

 glActiveTexturearb(GL_TEXTURE0_ARB+inscatterUnit);
 glGenTextures(1,@inscatterTexture);
 glBindTexture(GL_TEXTURE_3D,inscatterTexture);
 glTexParameteri(GL_TEXTURE_3D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
 glTexParameteri(GL_TEXTURE_3D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
 glTexParameteri(GL_TEXTURE_3D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
 glTexParameteri(GL_TEXTURE_3D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
 glTexParameteri(GL_TEXTURE_3D,GL_TEXTURE_WRAP_R,GL_CLAMP_TO_EDGE);
 glBindBufferarb(GL_PIXEL_UNPACK_BUFFER_ARB,0);
 glTexImage3D(GL_TEXTURE_3D,0,GL_RGBA16F_ARB,RES_MU_S*RES_NU,RES_MU,RES_R,0,GL_RGB,GL_FLOAT,nil);

 glActiveTexturearb(GL_TEXTURE0_ARB+deltaEUnit);
 glGenTextures(1,@deltaETexture);
 glBindTexture(GL_TEXTURE_2D,deltaETexture);
 glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
 glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
 glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
 glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
 glBindBufferarb(GL_PIXEL_UNPACK_BUFFER_ARB,0);
 glTexImage2D(GL_TEXTURE_2D,0,GL_RGB16F_ARB,SKY_W,SKY_H,0,GL_RGB,GL_FLOAT,nil);

 glActiveTexturearb(GL_TEXTURE0_ARB+deltaSRUnit);
 glGenTextures(1,@deltaSRTexture);
 glBindTexture(GL_TEXTURE_3D,deltaSRTexture);
 glTexParameteri(GL_TEXTURE_3D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
 glTexParameteri(GL_TEXTURE_3D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
 glTexParameteri(GL_TEXTURE_3D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
 glTexParameteri(GL_TEXTURE_3D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
 glTexParameteri(GL_TEXTURE_3D,GL_TEXTURE_WRAP_R,GL_CLAMP_TO_EDGE);
 glBindBufferarb(GL_PIXEL_UNPACK_BUFFER_ARB,0);
 glTexImage3D(GL_TEXTURE_3D,0,GL_RGB16F_ARB,RES_MU_S*RES_NU,RES_MU,RES_R,0,GL_RGB,GL_FLOAT,nil);

 glActiveTexturearb(GL_TEXTURE0_ARB+deltaSMUnit);
 glGenTextures(1,@deltaSMTexture);
 glBindTexture(GL_TEXTURE_3D,deltaSMTexture);
 glTexParameteri(GL_TEXTURE_3D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
 glTexParameteri(GL_TEXTURE_3D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
 glTexParameteri(GL_TEXTURE_3D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
 glTexParameteri(GL_TEXTURE_3D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
 glTexParameteri(GL_TEXTURE_3D,GL_TEXTURE_WRAP_R,GL_CLAMP_TO_EDGE);
 glBindBufferarb(GL_PIXEL_UNPACK_BUFFER_ARB,0);
 glTexImage3D(GL_TEXTURE_3D,0,GL_RGB16F_ARB,RES_MU_S*RES_NU,RES_MU,RES_R,0,GL_RGB,GL_FLOAT,nil);

 glActiveTexturearb(GL_TEXTURE0_ARB+deltaJUnit);
 glGenTextures(1,@deltaJTexture);
 glBindTexture(GL_TEXTURE_3D,deltaJTexture);
 glTexParameteri(GL_TEXTURE_3D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
 glTexParameteri(GL_TEXTURE_3D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
 glTexParameteri(GL_TEXTURE_3D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
 glTexParameteri(GL_TEXTURE_3D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
 glTexParameteri(GL_TEXTURE_3D,GL_TEXTURE_WRAP_R,GL_CLAMP_TO_EDGE);
 glBindBufferarb(GL_PIXEL_UNPACK_BUFFER_ARB,0);
 glTexImage3D(GL_TEXTURE_3D,0,GL_RGB16F_ARB,RES_MU_S*RES_NU,RES_MU,RES_R,0,GL_RGB,GL_FLOAT,nil);


 maco:=main_const+common;
 f:=maco+transmittance; if not mkshader(pchar('#define _VERTEX_'#10+f),pchar('#define _FRAGMENT_'#10+f),nil                             ,transmittanceProg ,'transmittance:' )then exit;  
 f:=maco+irradiance1;   if not mkshader(pchar('#define _VERTEX_'#10+f),pchar('#define _FRAGMENT_'#10+f),nil                             ,irradiance1Prog   ,'irradiance1:'   )then exit; 
 f:=maco+inscatter1;    if not mkshader(pchar('#define _VERTEX_'#10+f),pchar('#define _FRAGMENT_'#10+f),pchar('#define _GEOMETRY_'#10+f),inscatter1Prog    ,'inscatter1:'    )then exit; 
 f:=maco+copyIrradiance;if not mkshader(pchar('#define _VERTEX_'#10+f),pchar('#define _FRAGMENT_'#10+f),nil                             ,copyIrradianceProg,'copyIrradiance:')then exit; 
 f:=maco+copyInscatter1;if not mkshader(pchar('#define _VERTEX_'#10+f),pchar('#define _FRAGMENT_'#10+f),pchar('#define _GEOMETRY_'#10+f),copyInscatter1Prog,'copyInscatter1:')then exit; 
 f:=maco+inscatterS;    if not mkshader(pchar('#define _VERTEX_'#10+f),pchar('#define _FRAGMENT_'#10+f),pchar('#define _GEOMETRY_'#10+f),jProg             ,'inscatterS:'    )then exit; 
 f:=maco+irradianceN;   if not mkshader(pchar('#define _VERTEX_'#10+f),pchar('#define _FRAGMENT_'#10+f),nil                             ,irradianceNProg   ,'irradianceN:'   )then exit; 
 f:=maco+inscatterN;    if not mkshader(pchar('#define _VERTEX_'#10+f),pchar('#define _FRAGMENT_'#10+f),pchar('#define _GEOMETRY_'#10+f),inscatterNProg    ,'inscatterN:'    )then exit; 
 f:=maco+copyInscatterN;if not mkshader(pchar('#define _VERTEX_'#10+f),pchar('#define _FRAGMENT_'#10+f),pchar('#define _GEOMETRY_'#10+f),copyInscatterNProg,'copyInscatterN:')then exit; 
 
 writeln(#10#10'--Shaders compiled,generating...'#10);
 glGenFramebuffersEXT(1,@fbo);
 glBindFramebufferEXT(GL_FRAMEBUFFER_EXT,fbo);
 glReadBuffer(GL_COLOR_ATTACHMENT0_EXT);
 glDrawBuffer(GL_COLOR_ATTACHMENT0_EXT);

 //computes transmittance texture T (line 1 in algorithm 4.1)
 glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT,GL_COLOR_ATTACHMENT0_EXT,GL_TEXTURE_2D,transmittanceTexture,0);
 glViewport(0,0,TRANSMITTANCE_W,TRANSMITTANCE_H);
 glUseProgram(transmittanceProg.prg);
 glBegin(GL_TRIANGLE_STRIP);glVertex2f(-1,-1);glVertex2f(-1,+1);glVertex2f(+1,-1);glVertex2f(+1,+1);glEnd;

 //computes irradiance texture deltaE (line 2 in algorithm 4.1)
 glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT,GL_COLOR_ATTACHMENT0_EXT,GL_TEXTURE_2D,deltaETexture,0);
 glViewport(0,0,SKY_W,SKY_H);
 glUseProgram(irradiance1Prog.prg);
 glUniform1i(glGetUniformLocation(irradiance1Prog.prg,'transmittanceSampler'),transmittanceUnit);
 glBegin(GL_TRIANGLE_STRIP);glVertex2f(-1,-1);glVertex2f(-1,+1);glVertex2f(+1,-1);glVertex2f(+1,+1);glEnd;
 
 //computes single scattering texture deltaS (line 3 in algorithm 4.1)
 //Rayleigh and Mie separated in deltaSR+deltaSM
 glFramebufferTexture3DEXT(GL_FRAMEBUFFER_EXT,GL_COLOR_ATTACHMENT0_EXT,GL_TEXTURE_3D,deltaSRTexture,0,0);
 glFramebufferTexture3DEXT(GL_FRAMEBUFFER_EXT,GL_COLOR_ATTACHMENT1_EXT,GL_TEXTURE_3D,deltaSMTexture,0,0);
 bufs[0]:=GL_COLOR_ATTACHMENT0_EXT;
 bufs[1]:=GL_COLOR_ATTACHMENT1_EXT;
 glDrawBuffers(2,@bufs);
 glViewport(0,0,RES_MU_S*RES_NU,RES_MU);
 glUseProgram(inscatter1Prog.prg);
 glUniform1i(glGetUniformLocation(inscatter1Prog.prg,'transmittanceSampler'),transmittanceUnit);
 for layer:=0 to RES_R-1 do begin
  setLayer(inscatter1Prog.prg,layer);
  glBegin(GL_TRIANGLE_STRIP);glVertex2f(-1,-1);glVertex2f(-1,+1);glVertex2f(+1,-1);glVertex2f(+1,+1);glEnd;
 end;
 glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT,GL_COLOR_ATTACHMENT1_EXT,GL_TEXTURE_2D,0,0);
 glDrawBuffer(GL_COLOR_ATTACHMENT0_EXT);
 
 // copies deltaE into irradiance texture E (line 4 in algorithm 4.1)
 glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT,GL_COLOR_ATTACHMENT0_EXT,GL_TEXTURE_2D,irradianceTexture,0);
 glViewport(0,0,SKY_W,SKY_H);
 glUseProgram(copyIrradianceProg.prg);
 glUniform1f(glGetUniformLocation(copyIrradianceProg.prg,'k'),0.0);
 glUniform1i(glGetUniformLocation(copyIrradianceProg.prg,'deltaESampler'),deltaEUnit);
 glBegin(GL_TRIANGLE_STRIP);glVertex2f(-1,-1);glVertex2f(-1,+1);glVertex2f(+1,-1);glVertex2f(+1,+1);glEnd;

 // copies deltaS into inscatter texture S (line 5 in algorithm 4.1)
 glFramebufferTexture3DEXT(GL_FRAMEBUFFER_EXT,GL_COLOR_ATTACHMENT0_EXT,GL_TEXTURE_3D,inscatterTexture,0,0);
 glViewport(0,0,RES_MU_S*RES_NU,RES_MU);
 glUseProgram(copyInscatter1Prog.prg);
 glUniform1i(glGetUniformLocation(copyInscatter1Prog.prg,'deltaSRSampler'),deltaSRUnit);
 glUniform1i(glGetUniformLocation(copyInscatter1Prog.prg,'deltaSMSampler'),deltaSMUnit);
 for layer:=0 to RES_R-1 do begin
  setLayer(copyInscatter1Prog.prg,layer);
  glBegin(GL_TRIANGLE_STRIP);glVertex2f(-1,-1);glVertex2f(-1,+1);glVertex2f(+1,-1);glVertex2f(+1,+1);glEnd;
 end;

 // loop for each scattering order (line 6 in algorithm 4.1)
 for order:=2 to 4 do begin
  // computes deltaJ (line 7 in algorithm 4.1)
  glFramebufferTexture3DEXT(GL_FRAMEBUFFER_EXT,GL_COLOR_ATTACHMENT0_EXT,GL_TEXTURE_3D,deltaJTexture,0,0);
  glViewport(0,0,RES_MU_S*RES_NU,RES_MU);
  glUseProgram(jProg.prg);
  if order=2 then glUniform1f(glGetUniformLocation(jProg.prg,'first'),1)
             else glUniform1f(glGetUniformLocation(jProg.prg,'first'),0);
  glUniform1i(glGetUniformLocation(jProg.prg,'transmittanceSampler'),transmittanceUnit);
  glUniform1i(glGetUniformLocation(jProg.prg,'deltaESampler'),deltaEUnit);
  glUniform1i(glGetUniformLocation(jProg.prg,'deltaSRSampler'),deltaSRUnit);
  glUniform1i(glGetUniformLocation(jProg.prg,'deltaSMSampler'),deltaSMUnit);
  for layer:=0 to RES_R-1 do begin
   setLayer(jProg.prg,layer);
   glBegin(GL_TRIANGLE_STRIP);glVertex2f(-1,-1);glVertex2f(-1,+1);glVertex2f(+1,-1);glVertex2f(+1,+1);glEnd;
  end;

  // computes deltaE (line 8 in algorithm 4.1)
  glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT,GL_COLOR_ATTACHMENT0_EXT,GL_TEXTURE_2D,deltaETexture,0);
  glViewport(0,0,SKY_W,SKY_H);
  glUseProgram(irradianceNProg.prg);                        
  if order=2 then glUniform1f(glGetUniformLocation(irradianceNProg.prg,'first'),1)
             else glUniform1f(glGetUniformLocation(irradianceNProg.prg,'first'),0);
  glUniform1i(glGetUniformLocation(irradianceNProg.prg,'transmittanceSampler'),transmittanceUnit);
  glUniform1i(glGetUniformLocation(irradianceNProg.prg,'deltaSRSampler'),deltaSRUnit);
  glUniform1i(glGetUniformLocation(irradianceNProg.prg,'deltaSMSampler'),deltaSMUnit);
  glBegin(GL_TRIANGLE_STRIP);glVertex2f(-1,-1);glVertex2f(-1,+1);glVertex2f(+1,-1);glVertex2f(+1,+1);glEnd;

  // computes deltaS (line 9 in algorithm 4.1)
  glFramebufferTexture3DEXT(GL_FRAMEBUFFER_EXT,GL_COLOR_ATTACHMENT0_EXT,GL_TEXTURE_3D,deltaSRTexture,0,0);
  glViewport(0,0,RES_MU_S*RES_NU,RES_MU);
  glUseProgram(inscatterNProg.prg);                     
  if order=2 then glUniform1f(glGetUniformLocation(inscatterNProg.prg,'first'),1)
             else glUniform1f(glGetUniformLocation(inscatterNProg.prg,'first'),0);
  glUniform1i(glGetUniformLocation(inscatterNProg.prg,'transmittanceSampler'),transmittanceUnit);
  glUniform1i(glGetUniformLocation(inscatterNProg.prg,'deltaJSampler'),deltaJUnit);
  for layer:=0 to RES_R-1 do begin
   setLayer(inscatterNProg.prg,layer);
   glBegin(GL_TRIANGLE_STRIP);glVertex2f(-1,-1);glVertex2f(-1,+1);glVertex2f(+1,-1);glVertex2f(+1,+1);glEnd;
  end;
  glEnable(GL_BLEND);
  glBlendEquationSeparate(GL_FUNC_ADD,GL_FUNC_ADD);
  glBlendFuncSeparateext(GL_ONE,GL_ONE,GL_ONE,GL_ONE);

  // adds deltaE into irradiance texture E (line 10 in algorithm 4.1)
  glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT,GL_COLOR_ATTACHMENT0_EXT,GL_TEXTURE_2D,irradianceTexture,0);
  glViewport(0,0,SKY_W,SKY_H);
  glUseProgram(copyIrradianceProg.prg);
  glUniform1f(glGetUniformLocation(copyIrradianceProg.prg,'k'),1.0);
  glUniform1i(glGetUniformLocation(copyIrradianceProg.prg,'deltaESampler'),deltaEUnit);
  glBegin(GL_TRIANGLE_STRIP);glVertex2f(-1,-1);glVertex2f(-1,+1);glVertex2f(+1,-1);glVertex2f(+1,+1);glEnd;

  // adds deltaS into inscatter texture S (line 11 in algorithm 4.1)
  glFramebufferTexture3DEXT(GL_FRAMEBUFFER_EXT,GL_COLOR_ATTACHMENT0_EXT,GL_TEXTURE_3D,inscatterTexture,0,0);
  glViewport(0,0,RES_MU_S*RES_NU,RES_MU);
  glUseProgram(copyInscatterNProg.prg);
  glUniform1i(glGetUniformLocation(copyInscatterNProg.prg,'deltaSSampler'),deltaSRUnit);
  for layer:=0 to RES_R-1 do begin
   setLayer(copyInscatterNProg.prg,layer);
   glBegin(GL_TRIANGLE_STRIP);glVertex2f(-1,-1);glVertex2f(-1,+1);glVertex2f(+1,-1);glVertex2f(+1,+1);glEnd;
  end;
  
  glDisable(GL_BLEND);
 end;

 glBindFramebufferEXT(GL_FRAMEBUFFER_EXT,0);

 
 glBindTexture(GL_TEXTURE_2D,transmittanceTexture);
 shot(TRANSMITTANCE_W,TRANSMITTANCE_H,trans);     
 glBindTexture(GL_TEXTURE_2D,irradianceTexture);
 shot(SKY_W,SKY_H,irr);                
 glBindTexture(GL_TEXTURE_2D,0);
 glBindTexture(GL_TEXTURE_3D,inscatterTexture);
 shot3d(RES_MU_S*RES_NU,RES_MU,RES_R,ins);
           
 glActiveTexturearb(GL_TEXTURE0_ARB);   
 glBindTexture(GL_TEXTURE_2D,0);
 glBindTexture(GL_TEXTURE_3D,0);
 glFinish;
  
 glDeleteTextures(1,@deltaETexture);
 glDeleteTextures(1,@deltaSRTexture);
 glDeleteTextures(1,@deltaSMTexture);
 glDeleteTextures(1,@deltaJTexture);  
    
 glDeleteProgram(transmittanceProg.prg);
 glDeleteProgram(irradiance1Prog.prg);
 glDeleteProgram(inscatter1Prog.prg);
 glDeleteProgram(copyIrradianceProg.prg);
 glDeleteProgram(copyInscatter1Prog.prg);
 glDeleteProgram(jProg.prg);
 glDeleteProgram(irradianceNProg.prg);
 glDeleteProgram(inscatterNProg.prg);
 glDeleteProgram(copyInscatterNProg.prg);  
  
 glDeleteFramebuffersEXT(1,@fbo);
 result:=true;
end; 
//############################################################################//
procedure load_precomp_gpu(trans,irr,ins:string);
var f,v:string;   
fb:file;
//ft:text;
p:pointer;
xs,ys,zs:integer;
begin       
 if(not fileexists(trans))or(not fileexists(irr))or(not fileexists(ins))then exit;
 xs:=TRANSMITTANCE_W;
 ys:=TRANSMITTANCE_H;
 getmem(p,xs*ys*4*3); 
 assignfile(fb,trans);reset(fb,1);blockread(fb,p^,xs*ys*4*3);closefile(fb);
 glActiveTexturearb(GL_TEXTURE0_ARB+transmittanceUnit);
 glGenTextures(1,@transmittanceTexture);
 glBindTexture(GL_TEXTURE_2D,transmittanceTexture);
 glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
 glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
 glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
 glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
 glBindBufferarb(GL_PIXEL_UNPACK_BUFFER_ARB,0);
 glTexImage2D(GL_TEXTURE_2D,0,GL_RGB16F_ARB,xs,ys,0,GL_RGB,GL_FLOAT,p); 
 freemem(p);
         
 xs:=SKY_W;
 ys:=SKY_H;
 getmem(p,xs*ys*4*3); 
 assignfile(fb,irr);reset(fb,1);blockread(fb,p^,xs*ys*4*3);closefile(fb);
 glActiveTexturearb(GL_TEXTURE0_ARB+irradianceUnit);
 glGenTextures(1,@irradianceTexture);
 glBindTexture(GL_TEXTURE_2D,irradianceTexture);
 glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
 glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
 glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
 glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
 glBindBufferarb(GL_PIXEL_UNPACK_BUFFER_ARB,0);
 glTexImage2D(GL_TEXTURE_2D,0,GL_RGB16F_ARB,xs,ys,0,GL_RGB,GL_FLOAT,p);
 freemem(p);
           
 xs:=RES_MU_S*RES_NU;
 ys:=RES_MU;
 zs:=RES_R;
 getmem(p,xs*ys*zs*4*4); 
 assignfile(fb,ins);reset(fb,1);blockread(fb,p^,xs*ys*zs*4*4);closefile(fb);
 glActiveTexturearb(GL_TEXTURE0_ARB+inscatterUnit);
 glGenTextures(1,@inscatterTexture);
 glBindTexture(GL_TEXTURE_3D,inscatterTexture);
 glTexParameteri(GL_TEXTURE_3D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
 glTexParameteri(GL_TEXTURE_3D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
 glTexParameteri(GL_TEXTURE_3D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
 glTexParameteri(GL_TEXTURE_3D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
 glTexParameteri(GL_TEXTURE_3D,GL_TEXTURE_WRAP_R,GL_CLAMP_TO_EDGE);
 glBindBufferarb(GL_PIXEL_UNPACK_BUFFER_ARB,0);
 glTexImage3D(GL_TEXTURE_3D,0,GL_RGBA16F_ARB,xs,ys,zs,0,GL_RGBA,GL_FLOAT,p);   
 freemem(p);

 v:= 
 'varying vec3 ray;'#10+      
 'varying vec2 coords;'#10+  
 'uniform mat4 projInverse;'#10+
 'uniform mat4 viewInverse;'#10+
 'void main()'#10+
 '{'#10+
 ' coords=gl_Vertex.xy*0.5+0.5;'#10+
 ' ray=(viewInverse*vec4((projInverse*gl_Vertex).xyz,0.0)).xyz;'#10+
 ' gl_Position=gl_Vertex;'#10+
 '}'#10;
 f:=main_const+mainsep;
 
 //assignfile(ft,'out.frag');rewrite(ft);writeln(ft,f);closefile(ft);
 if mkshader(pchar(v),pchar(f),nil,scatter_sh,'Scatter program:')then begin    
  setlength(scatter_sh.unis,9);
  scatter_sh.unis[0]:=glGetUniformLocation(scatter_sh.prg,'reflectanceSampler');
  scatter_sh.unis[1]:=glGetUniformLocation(scatter_sh.prg,'transmittanceSampler');
  scatter_sh.unis[2]:=glGetUniformLocation(scatter_sh.prg,'irradianceSampler');
  scatter_sh.unis[3]:=glGetUniformLocation(scatter_sh.prg,'inscatterSampler');   
  scatter_sh.unis[4]:=glGetUniformLocation(scatter_sh.prg,'c');
  scatter_sh.unis[5]:=glGetUniformLocation(scatter_sh.prg,'s');
  scatter_sh.unis[6]:=glGetUniformLocation(scatter_sh.prg,'projInverse');
  scatter_sh.unis[7]:=glGetUniformLocation(scatter_sh.prg,'viewInverse');
  scatter_sh.unis[8]:=glGetUniformLocation(scatter_sh.prg,'exposure');
 end;
 
 glActiveTexturearb(GL_TEXTURE0_ARB);   
 glBindTexture(GL_TEXTURE_2D,0);
 glBindTexture(GL_TEXTURE_3D,0);
 glFinish();
end; 
//############################################################################//
//############################################################################//
begin
 make_shaders;
 make_gen_shaders;
end.   
//############################################################################//
