//############################################################################//
// OAPI to pascal interface
// Released under GNU General Public License
// Made in 2007-2010 by Artlav
//############################################################################//
struct ilt {
 DWORD dbgp;
 DWORD oags,oagm,oagon;
 DWORD oagh,oagfh,oaga,oagfa,oagta,oagep,oagfep;
 DWORD oacamap,oacamgp,oacamgd,oacamt,oaggbbi,oaggbbn,oaggp,oaggv,oagobc,oagobbi,oagplac,oagplap,oagplapn,oagobt,oagfob,oagbsc,oagbsbi;
 DWORD oagsimt,oagsimm,oacamrm,oacamm,oagrotm,oacampg,oaplha,oagobp,oagvi,oagfi,oadm,oamgc,oamgex,oamtc,oaci,oacm,oagth;
 DWORD oawrss,oardss,oagdc,oardc;
 DWORD oasfo,oagobn,oagem,oastac,oagvc,oagvbi,oadv;
 DWORD vgetmc,vgetmt,vgetmvm,vcmft,vgetmo,cvesso,cvessl;
 DWORD vgetcn,vgpmat,vggmat,vg2l,vl2g,vgetsr,vgetped,vgetapd,vaf,vsetst;
 DWORD vgethav,vgetpt,vgetbk,vgetaoa,vgetrotvel,vsettgld,vgettgld,vsettgl,vgettgl,vsetcsl,vgetcsl,vsetadcm,vgetar,vgetvr;
 DWORD vgettdp,vsettdp,vgetwbl,vgetsav,vgetav,vgetpmi,vgetls,vdosw,vdorsw,vdovw,vdorw,vsets,vgetasp,vgetanp,vgetmgtr,vsetmgtr;
 DWORD oamm,oaca,oada,oaasp,oaast,oagsav,oagfas,oagfsasv,oactd,oacsd;
 DWORD vgetec,vgetel,vgetes,vgetcoge;
 DWORD oauxgetplmat,oamg,oast,oacts,oagpau,oasvsc,oagbspl,oaisves;
};

typedef union{
	double data[3];
	struct {double x,y,z;};
}VECTOR4;

struct mgroup_transform{
 int tp;
	UINT mesh,ngrp;
	UINT *grp;

	VECTOR3 ref,axis,scale,shift;
	float angle;
};

//############################################################################//
//############################################################################//
HMODULE hlib,hlibbtn;
void (__stdcall *initint)(ilt*);

ilt itl;

void dbgprint(char *s){sprintf(oapiDebugString(),s);}

//############################################################################//
//Vessel class

#define beta

//Beta//
#ifdef beta
UINT vesGetMeshCount(VESSEL *v){return v->GetMeshCount();}
MESHHANDLE vesGetMeshTemplate(VESSEL *v,UINT idx){return v->GetMeshTemplate(idx);}
WORD vesGetMeshVisibilityMode(VESSEL *v,UINT idx){return v->GetMeshVisibilityMode(idx);}
MESHHANDLE vesCopyMeshFromTemplate(VESSEL *v,UINT idx){return v->CopyMeshFromTemplate(idx);}
bool vesGetMeshOffset(VESSEL *v,UINT idx,VECTOR3 &ofs){return v->GetMeshOffset(idx,ofs);}
UINT vesGetAnimPtr(VESSEL *v,ANIMATION **anim){return v->GetAnimPtr(anim);}
int vesGetExhaustCount(VESSEL *v){return v->GetExhaustCount();}
double vesGetExhaustLevel(VESSEL *v,UINT idx){return v->GetExhaustLevel(idx);}
bool vesGetExhaustSpec(VESSEL *v,UINT idx,double *lscale,double *wscale,VECTOR3 *pos,VECTOR3 *dir,SURFHANDLE *tex){return v->GetExhaustSpec(idx,lscale,wscale,pos,dir,tex);}
mgroup_transform vesGetMGroup_Transform(VESSEL *v,MGROUP_TRANSFORM *mgt)
{
 mgroup_transform res;

 res.mesh=mgt->mesh;
 res.ngrp=mgt->ngrp;
 res.grp=mgt->grp;
 if(mgt->Type()==MGROUP_TRANSFORM::NULLTRANSFORM){
  res.tp=0;
  return res;
 }
 if(mgt->Type()==MGROUP_TRANSFORM::ROTATE){
  MGROUP_ROTATE *mgta=(MGROUP_ROTATE*)mgt;
  res.tp=1;
  res.ref=mgta->ref;
  res.axis=mgta->axis;
  res.angle=mgta->angle;
  return res;
 }
 if(mgt->Type()==MGROUP_TRANSFORM::TRANSLATE){
  MGROUP_TRANSLATE *mgta=(MGROUP_TRANSLATE*)mgt;
  res.tp=2;
  res.shift=mgta->shift;
  return res;
 }
 if(mgt->Type()==MGROUP_TRANSFORM::SCALE){
  MGROUP_SCALE *mgta=(MGROUP_SCALE*)mgt;
  res.tp=3;
  res.ref=mgta->ref;
  res.scale=mgta->scale;
  return res;
 }
 return res;
}
void vesSetMGroup_Transform(VESSEL *v,MGROUP_TRANSFORM *mgt,mgroup_transform *res)
{
/*
 res.mesh=mgt->mesh;
 res.ngrp=mgt->ngrp;
 res.grp=mgt->grp;
 */
 if(res->tp==1){
  MGROUP_ROTATE *mgta=(MGROUP_ROTATE*)mgt;
  mgta->ref=res->ref;
  mgta->axis=res->axis;
  mgta->angle=res->angle;
  return;
 }
 if(res->tp==2){
  MGROUP_TRANSLATE *mgta=(MGROUP_TRANSLATE*)mgt;
  mgta->shift=res->shift;
  return;
 }
 if(res->tp==3){
  MGROUP_SCALE *mgta=(MGROUP_SCALE*)mgt;
  mgta->ref=res->ref;
  mgta->scale=res->scale;
  return;
 }
}
//############################################################################//
void doapiGetPlanetAtmParams(OBJHANDLE hPlanet,double rad,ATMPARAM *prm)
{oapiGetPlanetAtmParams(hPlanet,rad,prm);}
void doapiGetPlanetAtmParamsn(OBJHANDLE hPlanet,double alt,double lng,double lat,ATMPARAM *prm)
{oapiGetPlanetAtmParams(hPlanet,alt,lng,lat,prm);}
#endif
//############################################################################//
void vesAddForce(VESSEL *v,VECTOR3 f,VECTOR3 r){v->AddForce(f,r);}
void vesGetClassName(VESSEL *v,char *s){for (int ii=1;ii<255;ii++) s[ii]=0;if (v->GetClassName()!=NULL) strncpy(s,v->GetClassName(),254);}
VECTOR3 vesGlobal2Local(VESSEL *v,VECTOR3 vc){ VECTOR3 n=_V(0,0,0); v->Global2Local(vc,n); return n;}
VECTOR3 vesLocal2Global(VESSEL *v,VECTOR3 vc){ VECTOR3 n=_V(0,0,0); v->Local2Global(vc,n); return n;}
OBJHANDLE vesGetSurfaceRef(VESSEL *v){ return v->GetSurfaceRef();}

double vesGetPeDist(VESSEL *v){double r;v->GetPeDist(r);return r;}
double vesGetApDist(VESSEL *v){double r;v->GetApDist(r);return r;}
VECTOR3 vesGetHorizonAirspeedVector(VESSEL *v){VECTOR3 r;v->GetHorizonAirspeedVector(r);return r;}
double vesGetPitch(VESSEL *v){return v->GetPitch();}
double vesGetBank(VESSEL *v){return v->GetBank();}
double vesGetAOA(VESSEL *v){return v->GetAOA();}
double vesGetCOG_elev(VESSEL *v){return v->GetCOG_elev();}

double vesGetRotVelocity(VESSEL *v,int t)
{	
	VESSELSTATUS Status;
	v->GetStatus(Status);
	
	return Status.vrot.data[t];
}

double vesGetThrusterGroupLeveld(VESSEL *v,DWORD n){return v->GetThrusterGroupLevel(THGROUP_TYPE(THGROUP_MAIN+n));}
double vesGetThrusterGroupLevel(VESSEL *v,THGROUP_HANDLE th){return v->GetThrusterGroupLevel(th);}
void vesSetThrusterGroupLeveld(VESSEL *v,DWORD n,double level){v->SetThrusterGroupLevel(THGROUP_TYPE(THGROUP_MAIN+n),level);}
void vesSetThrusterGroupLevel(VESSEL *v,THGROUP_HANDLE th,double level){v->SetThrusterGroupLevel(th,level);}
void vesSetControlSurfaceLevel(VESSEL *v,DWORD n,double level){v->SetControlSurfaceLevel(AIRCTRL_TYPE(AIRCTRL_ELEVATOR+n),level);}
double vesGetControlSurfaceLevel(VESSEL *v,DWORD n){return v->GetControlSurfaceLevel(AIRCTRL_TYPE(AIRCTRL_ELEVATOR+n));}

void vesSetADCtrlMode(VESSEL *v,DWORD mode){v->SetADCtrlMode(mode);}

VECTOR3 vesGetarot(VESSEL *v){VESSELSTATUS2 vs;vs.version=2;vs.flag=0;v->GetStatusEx(&vs);return vs.arot;}
VECTOR3 vesGetvrot(VESSEL *v){VESSELSTATUS2 vs;vs.version=2;vs.flag=0;v->GetStatusEx(&vs);return vs.vrot;}

double vesGetWheelbrakeLevel(VESSEL *v,int n){return v->GetWheelbrakeLevel(n);}

VECTOR3 vesGetShipAirspeedVector(VESSEL *v){VECTOR3 r;v->GetShipAirspeedVector(r);return r;}
double vesGetAirspeed(VESSEL *v){return v->GetAirspeed();}

VECTOR3 vesGetAngularVel(VESSEL *v){VECTOR3 r;v->GetAngularVel(r);return r;}
VECTOR3 vesGetPMI(VESSEL *v){VECTOR3 r;v->GetPMI(r);return r;}
int vesLndStatus(VESSEL *v){VESSELSTATUS2 vs;vs.version=2;vs.flag=0;v->GetStatusEx(&vs);return vs.status;}

void vesSetSize(VESSEL *v,double s){v->SetSize(s);}

//############################################################################//

int CreateVesselorb(char *name,char *classname,char *gbody,VECTOR3 rp,VECTOR3 rv,VECTOR3 ar,VECTOR3 vr)
{
 OBJHANDLE v=NULL;
 v=oapiGetVesselByName(name);
 if(v!=NULL)return 0;

	VESSELSTATUS2 vs;
	memset(&vs,0,sizeof(vs));
	vs.version=2;

	vs.rbody=oapiGetGbodyByName(gbody);

	vs.rpos=rp;
	vs.rvel=rv;
 vs.arot=ar;
 vs.vrot=vr;

	OBJHANDLE newvessel=oapiCreateVesselEx(name,classname,&vs);
	if (!newvessel) return 0;
	return 1;
}
int CreateVessellnd(char *name,char *classname,char *gbody,double lat,double lon,double hdg)
{
 OBJHANDLE v=NULL;
 v=oapiGetVesselByName(name);
 if(v!=NULL)return 0;

	VESSELSTATUS2 vs;
	memset(&vs,0,sizeof(vs));
	vs.version=2;
	vs.status=1;

	vs.rbody=oapiGetGbodyByName(gbody);

	vs.surf_lng=lon;
	vs.surf_lat=lat;
 vs.surf_hdg=hdg;

	OBJHANDLE newvessel=oapiCreateVesselEx(name,classname,&vs);
	if (!newvessel) return 0;
	return 1;
}

void EquToRelhere(VESSEL *foc,double vlat, double vlon, double vrad, VECTOR3 &pos)
{
	VECTOR3 a;
	double obliq,theta,rot;
	OBJHANDLE hbody=foc->GetSurfaceRef();
	a.x=cos(vlat)*cos(vlon)*vrad;
	a.z=cos(vlat)*sin(vlon)*vrad;
	a.y=sin(vlat)*vrad;
	obliq=oapiGetPlanetObliquity(hbody);
	theta=oapiGetPlanetTheta(hbody);
	rot=oapiGetPlanetCurrentRotation(hbody);
	pos.x=a.x*(cos(theta)*cos(rot)-sin(theta)*cos(obliq)*sin(rot))-a.y*sin(theta)*sin(obliq)-a.z*(cos(theta)*sin(rot)+sin(theta)*cos(obliq)*cos(rot));
	pos.y=a.x*(-sin(obliq)*sin(rot))+a.y*cos(obliq)-a.z*sin(obliq)*cos(rot);
	pos.z=a.x*(sin(theta)*cos(rot)+cos(theta)*cos(obliq)*sin(rot))+a.y*cos(theta)*sin(obliq)+a.z*(-sin(theta)*sin(rot)+cos(theta)*cos(obliq)*cos(rot));
}
void vesgetpmat(VESSEL *v,VECTOR4 *p1,VECTOR4 *p2,VECTOR4 *p3)
{
 VECTOR3 gp,tp1,tp2,tp3,pt1,pt2,pt3;

	v->GetGlobalPos(gp);
 EquToRelhere(v,0000,PI/2,1,tp2);
	EquToRelhere(v,0000,0000,1,tp1);
	EquToRelhere(v,PI/2,0000,1,tp3); 
	tp1=tp1+gp;tp2=tp2+gp;tp3=tp3+gp;
	v->Global2Local(tp1,pt1);
	v->Global2Local(tp2,pt2);
	v->Global2Local(tp3,pt3);
 p1->x=pt1.x;p1->y=pt1.y;p1->z=pt1.z;
 p2->x=pt2.x;p2->y=pt2.y;p2->z=pt2.z;
 p3->x=pt3.x;p3->y=pt3.y;p3->z=pt3.z;
}

void vesgetgmat(VESSEL *v,VECTOR4 *g1,VECTOR4 *g2,VECTOR4 *g3)
{
 VECTOR3 gp,tp1,tp2,tp3,gt1,gt2,gt3;

	v->GetGlobalPos(gp);
	tp1=gp;tp1.x=tp1.x+1;
	tp2=gp;tp2.y=tp2.y+1;
	tp3=gp;tp3.z=tp3.z+1;
	v->Global2Local(tp1,gt1);
	v->Global2Local(tp2,gt2);
	v->Global2Local(tp3,gt3);
 g1->x=gt1.x;g1->y=gt1.y;g1->z=gt1.z;
 g2->x=gt2.x;g2->y=gt2.y;g2->z=gt2.z;
 g3->x=gt3.x;g3->y=gt3.y;g3->z=gt3.z;
}

void vesGetTouchdownPoints(VESSEL *v,VECTOR3 *p1,VECTOR3 *p2,VECTOR3 *p3){v->GetTouchdownPoints(*p1,*p2,*p3);}
void vesSetTouchdownPoints(VESSEL *v,VECTOR3 *p1,VECTOR3 *p2,VECTOR3 *p3){v->SetTouchdownPoints(*p1,*p2,*p3);}

//############################################################################//
void vesdoshwrp(VESSEL *v,VECTOR3 sh)
{
	VESSELSTATUS2 vs;vs.version=2;vs.flag=0;
 v->GetStatusEx(&vs);

	vs.rpos+=sh;

	if(((sh.x!=0)||(sh.y!=0)||(sh.z!=0))&&(vs.status!=1))v->DefSetStateEx(&vs);
}
void vesdorshwrp(VESSEL *v,VECTOR3 sh)
{
	VESSELSTATUS2 vs;vs.version=2;vs.flag=0;
 v->GetStatusEx(&vs);

	vs.arot+=sh;

	if(((sh.x!=0)||(sh.y!=0)||(sh.z!=0)))v->DefSetStateEx(&vs);
}
void vesdovelwrp(VESSEL *v,VECTOR3 sh)
{
	VESSELSTATUS2 vs;vs.version=2;vs.flag=0;
 v->GetStatusEx(&vs);

	vs.rvel+=sh;

	if((sh.x!=0)||(sh.y!=0)||(sh.z!=0))v->DefSetStateEx(&vs);
}
void vesdorotwrp(VESSEL *v,VECTOR3 sh)
{
 VESSELSTATUS2 vs;vs.version=2;vs.flag=0;
 v->GetStatusEx(&vs);

	vs.vrot+=sh;

	if((sh.x!=0)||(sh.y!=0)||(sh.z!=0))v->DefSetStateEx(&vs);
}
void vessetstatus(VESSEL *v,int st)
{
 VESSELSTATUS2 vs;vs.version=2;vs.flag=0;
 v->GetStatusEx(&vs);

	vs.status=st;

	v->DefSetStateEx(&vs);
}


void EquToRelhereobj(OBJHANDLE hbody,double vlat, double vlon, double vrad,VECTOR3 &pos)
{
	VECTOR3 a;
	double obliq,theta,rot;

	a.x=cos(vlat)*cos(vlon)*vrad;
	a.z=cos(vlat)*sin(vlon)*vrad;
	a.y=sin(vlat)*vrad;
	obliq=oapiGetPlanetObliquity(hbody);
	theta=oapiGetPlanetTheta(hbody);
	rot=oapiGetPlanetCurrentRotation(hbody);
	pos.x=a.x*(cos(theta)*cos(rot)-sin(theta)*cos(obliq)*sin(rot))-a.y*sin(theta)*sin(obliq)-a.z*(cos(theta)*sin(rot)+sin(theta)*cos(obliq)*cos(rot));
	pos.y=a.x*(-sin(obliq)*sin(rot))+a.y*cos(obliq)-a.z*sin(obliq)*cos(rot);
	pos.z=a.x*(sin(theta)*cos(rot)+cos(theta)*cos(obliq)*sin(rot))+a.y*cos(theta)*sin(obliq)+a.z*(-sin(theta)*sin(rot)+cos(theta)*cos(obliq)*cos(rot));
}
void oapiaux_getplmat(OBJHANDLE ho,VECTOR4 *p1,VECTOR4 *p2,VECTOR4 *p3)
{
 VECTOR3 pt1,pt2,pt3;

 EquToRelhereobj(ho,0000,PI/2,1,pt2);
	EquToRelhereobj(ho,0000,0000,1,pt1);
	EquToRelhereobj(ho,PI/2,0000,1,pt3);

 p1->x=pt1.x;p1->y=pt1.y;p1->z=pt1.z;
 p2->x=pt2.x;p2->y=pt2.y;p2->z=pt2.z;
 p3->x=pt3.x;p3->y=pt3.y;p3->z=pt3.z;
}
//############################################################################//
void loadint(char *mod)
{
 hlib=LoadLibrary(mod);
	if(hlib){
  initint=(void(__stdcall *)(ilt*))GetProcAddress(hlib,"initint");

  itl.dbgp=DWORD(dbgprint);

		itl.oagm=DWORD(oapiGetMass);

  itl.oagon=DWORD(oapiGetObjectName);

  itl.oagh=DWORD(oapiGetHeading);
  itl.oagfh=DWORD(oapiGetFocusHeading);
  itl.oaga=DWORD(oapiGetAltitude);
  itl.oagfa=DWORD(oapiGetFocusAltitude);

  itl.oagta=DWORD(oapiGetTimeAcceleration);

  itl.oagep=DWORD(oapiGetEquPos);
  itl.oagfep=DWORD(oapiGetFocusEquPos);

		itl.oags=DWORD(oapiGetSize);

  itl.oacamap=DWORD(oapiCameraAperture);
  itl.oacamgp=DWORD(oapiCameraGlobalPos);
  itl.oacamgd=DWORD(oapiCameraGlobalDir);
  itl.oacamt=DWORD(oapiCameraTarget);

  itl.oaggbbi=DWORD(oapiGetGbodyByIndex);
  itl.oaggbbn=DWORD(oapiGetGbodyByName);
  itl.oaggp=DWORD(oapiGetGlobalPos);
  itl.oaggv=DWORD(oapiGetGlobalVel);
  itl.oagobc=DWORD(oapiGetObjectCount);
  itl.oagobbi=DWORD(oapiGetObjectByIndex);

  itl.oagplac=DWORD(oapiGetPlanetAtmConstants);
 
  itl.oagobt=DWORD(oapiGetObjectType);
  itl.oagfob=DWORD(oapiGetFocusObject);
  itl.oagbsc=DWORD(oapiGetBaseCount);
  itl.oagbsbi=DWORD(oapiGetBaseByIndex);

  itl.oagsimt=DWORD(oapiGetSimTime);
  itl.oagsimm=DWORD(oapiGetSimMJD);

  itl.oacamm=DWORD(oapiCameraMode);

  itl.oagrotm=DWORD(oapiGetRotationMatrix);
  itl.oaplha=DWORD(oapiPlanetHasAtmosphere);

  itl.oagvi=DWORD(oapiGetVesselInterface);
  itl.oagfi=DWORD(oapiGetFocusInterface);

  itl.oadm=DWORD(oapiDeleteMesh);
  itl.oamgc=DWORD(oapiMeshGroupCount);

  itl.oaci=DWORD(oapiCameraInternal);
  itl.oacm=DWORD(oapiCockpitMode);
  itl.oagth=DWORD(oapiGetTextureHandle);

  
  itl.oawrss=DWORD(oapiWriteScenario_string);
		itl.oardss=DWORD(oapiReadScenario_nextline);

  itl.oagdc=DWORD(oapiGetDC);
  itl.oardc=DWORD(oapiReleaseDC);


		itl.oasfo=DWORD(oapiSetFocusObject);
		itl.oagobn=DWORD(oapiGetObjectByName);
		itl.oagem=DWORD(oapiGetEmptyMass);
  itl.oastac=DWORD(oapiSetTimeAcceleration);

  itl.oagvc=DWORD(oapiGetVesselCount);
  itl.oagvbi=DWORD(oapiGetVesselByIndex);
  itl.oadv=DWORD(oapiDeleteVessel);
  itl.oamm=DWORD(oapiMeshMaterial);

  itl.oaca=DWORD(oapiCreateAnnotation);
  itl.oada=DWORD(oapiDelAnnotation);
  itl.oaasp=DWORD(oapiAnnotationSetPos);
  itl.oaast=DWORD(oapiAnnotationSetText);

  itl.oagsav=DWORD(oapiGetShipAirspeedVector);
  itl.oagfas=DWORD(oapiGetFocusAirspeed);
  
  itl.oagfsasv=DWORD(oapiGetFocusShipAirspeedVector);

  itl.oactd=DWORD(oapiCameraTargetDist);
  itl.oacsd=DWORD(oapiCameraScaleDist);

  
  //itl.oamg=DWORD(oapiMeshGroup);
 // itl.oast=DWORD(oapiSetTexture);
  itl.oacts=DWORD(oapiCreateTextureSurface);
  itl.oagpau=DWORD(oapiGetPause);

  itl.oaisves=DWORD(oapiIsVessel);

//Beta
#ifdef beta
  itl.oacamrm=DWORD(oapiCameraRotationMatrix);
  itl.oacampg=DWORD(oapiCameraProxyGbody);
  itl.oagobp=DWORD(oapiGetObjectParam);
  itl.oamgex=DWORD(oapiMeshGroupEx);
  itl.oamtc=DWORD(oapiMeshTextureCount);
  itl.oagplap=DWORD(doapiGetPlanetAtmParams);
  itl.oagplapn=DWORD(doapiGetPlanetAtmParamsn);
  itl.oagbspl=DWORD(oapiGetBasePlanet);

  itl.vgetmc=DWORD(vesGetMeshCount);
  itl.vgetmt=DWORD(vesGetMeshTemplate);
  itl.vgetmvm=DWORD(vesGetMeshVisibilityMode);
  itl.vcmft=DWORD(vesCopyMeshFromTemplate);
  itl.vgetmo=DWORD(vesGetMeshOffset);
  itl.vgetanp=DWORD(vesGetAnimPtr);
  itl.vgetmgtr=DWORD(vesGetMGroup_Transform);
  itl.vsetmgtr=DWORD(vesSetMGroup_Transform);

  itl.vgetec=DWORD(vesGetExhaustCount);
  itl.vgetel=DWORD(vesGetExhaustLevel);
  itl.vgetes=DWORD(vesGetExhaustSpec);
#endif

  itl.cvesso=DWORD(CreateVesselorb);
  itl.cvessl=DWORD(CreateVessellnd);

  itl.vgetcn=DWORD(vesGetClassName);
  itl.vgpmat=DWORD(vesgetpmat);
  itl.vggmat=DWORD(vesgetgmat);
  itl.vg2l=DWORD(vesGlobal2Local);
  itl.vl2g=DWORD(vesLocal2Global);
  itl.vgetsr=DWORD(vesGetSurfaceRef);
  itl.vgetped=DWORD(vesGetPeDist);
  itl.vgetapd=DWORD(vesGetApDist);
  itl.vaf=DWORD(vesAddForce);
  itl.vsetst=DWORD(vessetstatus);

  itl.vgethav=DWORD(vesGetHorizonAirspeedVector);
  itl.vgetpt=DWORD(vesGetPitch);
  itl.vgetbk=DWORD(vesGetBank);
  itl.vgetaoa=DWORD(vesGetAOA);
  itl.vgetrotvel=DWORD(vesGetRotVelocity);
  itl.vsettgld=DWORD(vesSetThrusterGroupLeveld);
  itl.vgettgld=DWORD(vesGetThrusterGroupLeveld);
  itl.vsettgl=DWORD(vesSetThrusterGroupLevel);
  itl.vgettgl=DWORD(vesGetThrusterGroupLevel);
  itl.vsetcsl=DWORD(vesSetControlSurfaceLevel);
  itl.vgetcsl=DWORD(vesGetControlSurfaceLevel);
  itl.vsetadcm=DWORD(vesSetADCtrlMode);

  itl.vgetar=DWORD(vesGetarot);
  itl.vgetvr=DWORD(vesGetvrot);

  itl.vgettdp=DWORD(vesGetTouchdownPoints);
  itl.vsettdp=DWORD(vesSetTouchdownPoints);
  itl.vgetwbl=DWORD(vesGetWheelbrakeLevel);
  itl.vgetsav=DWORD(vesGetShipAirspeedVector);

  itl.vgetav=DWORD(vesGetAngularVel);
  itl.vgetpmi=DWORD(vesGetPMI);
  itl.vgetls=DWORD(vesLndStatus);

  itl.vdosw=DWORD(vesdoshwrp);
  itl.vdorsw=DWORD(vesdorshwrp);
  itl.vdovw=DWORD(vesdovelwrp);
  itl.vdorw=DWORD(vesdorotwrp);
  itl.vsets=DWORD(vesSetSize);

  itl.vgetasp=DWORD(vesGetAirspeed);

  itl.vgetcoge=DWORD(vesGetCOG_elev);

  itl.oauxgetplmat=DWORD(oapiaux_getplmat);

  itl.oasvsc=DWORD(oapiSaveScenario);

  initint(&itl);
 }else {
  char s[255];
  sprintf(s,"%s not found. Check installation.",mod);
  MessageBox(NULL,s,"Error!",MB_OK);
 }
}
//############################################################################//

