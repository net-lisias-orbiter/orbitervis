//############################################################################//
// Pascal OrbiterAPI interface
// Released under GNU General Public License
// Made in 2007-2010 by Artlav
//############################################################################//
unit oapi;
interface
uses maths,asys,grph;

const
OAPI_KEY_ESCAPE  =$01;
OAPI_KEY_1    =$02;
OAPI_KEY_2    =$03;
OAPI_KEY_3    =$04;
OAPI_KEY_4    =$05;
OAPI_KEY_5    =$06;
OAPI_KEY_6    =$07;
OAPI_KEY_7    =$08;
OAPI_KEY_8    =$09;
OAPI_KEY_9    =$0A;
OAPI_KEY_0    =$0B;
OAPI_KEY_MINUS  =$0C;  // on main keyboard
OAPI_KEY_EQUALS  =$0D;
OAPI_KEY_BACK   =$0E;  // backspace
OAPI_KEY_TAB   =$0F;
OAPI_KEY_Q    =$10;
OAPI_KEY_W    =$11;
OAPI_KEY_E    =$12;
OAPI_KEY_R    =$13;
OAPI_KEY_T    =$14;
OAPI_KEY_Y    =$15;
OAPI_KEY_U    =$16;
OAPI_KEY_I    =$17;
OAPI_KEY_O    =$18;
OAPI_KEY_P    =$19;
OAPI_KEY_LBRACKET  =$1A;
OAPI_KEY_RBRACKET  =$1B;
OAPI_KEY_RETURN   =$1C;  // Enter on main keyboard
OAPI_KEY_LCONTROL  =$1D;
OAPI_KEY_A    =$1E;
OAPI_KEY_S    =$1F;
OAPI_KEY_D    =$20;
OAPI_KEY_F    =$21;
OAPI_KEY_G    =$22;
OAPI_KEY_H    =$23;
OAPI_KEY_J    =$24;
OAPI_KEY_K    =$25;
OAPI_KEY_L    =$26;
OAPI_KEY_SEMICOLON  =$27;
OAPI_KEY_APOSTROPHE  =$28;
OAPI_KEY_GRAVE   =$29;  // accent grave
OAPI_KEY_LSHIFT   =$2A;
OAPI_KEY_BACKSLASH  =$2B;
OAPI_KEY_Z    =$2C;
OAPI_KEY_X    =$2D;
OAPI_KEY_C    =$2E;
OAPI_KEY_V    =$2F;
OAPI_KEY_B    =$30;
OAPI_KEY_N    =$31;
OAPI_KEY_M    =$32;
OAPI_KEY_COMMA   =$33;
OAPI_KEY_PERIOD   =$34;  // . on main keyboard
OAPI_KEY_SLASH   =$35;  // / on main keyboard
OAPI_KEY_RSHIFT   =$36;
OAPI_KEY_MULTIPLY  =$37;  // * on numeric keypad
OAPI_KEY_LALT   =$38;  // left Alt
OAPI_KEY_SPACE   =$39;
OAPI_KEY_CAPITAL  =$3A;  // caps lock key
OAPI_KEY_F1    =$3B;
OAPI_KEY_F2    =$3C;
OAPI_KEY_F3    =$3D;
OAPI_KEY_F4    =$3E;
OAPI_KEY_F5    =$3F;
OAPI_KEY_F6    =$40;
OAPI_KEY_F7    =$41;
OAPI_KEY_F8    =$42;
OAPI_KEY_F9    =$43;
OAPI_KEY_F10   =$44;
OAPI_KEY_NUMLOCK  =$45;
OAPI_KEY_SCROLL   =$46;  // Scroll lock
OAPI_KEY_NUMPAD7  =$47;
OAPI_KEY_NUMPAD8  =$48;
OAPI_KEY_NUMPAD9  =$49;
OAPI_KEY_SUBTRACT  =$4A;  // - on numeric keypad
OAPI_KEY_NUMPAD4  =$4B;
OAPI_KEY_NUMPAD5  =$4C;
OAPI_KEY_NUMPAD6  =$4D;
OAPI_KEY_ADD   =$4E; // + on numeric keypad
OAPI_KEY_NUMPAD1  =$4F;
OAPI_KEY_NUMPAD2  =$50;
OAPI_KEY_NUMPAD3  =$51;
OAPI_KEY_NUMPAD0  =$52;
OAPI_KEY_DECIMAL  =$53;  // . on numeric keypad
OAPI_KEY_OEM_102  =$56;  // | < > on UK/German keyboards
OAPI_KEY_F11   =$57;
OAPI_KEY_F12   =$58;
OAPI_KEY_NUMPADENTER =$9C;  // Enter on numeric keypad
OAPI_KEY_RCONTROL  =$9D;  // right Control key
OAPI_KEY_DIVIDE   =$B5;  // / on numeric keypad
OAPI_KEY_RALT           =$B8;  // right Alt
OAPI_KEY_HOME           =$C7;  // Home on cursor keypad
OAPI_KEY_UP             =$C8;  // up-arrow on cursor keypad
OAPI_KEY_PRIOR          =$C9;  // PgUp on cursor keypad
OAPI_KEY_LEFT           =$CB;  // left-arrow on cursor keypad
OAPI_KEY_RIGHT          =$CD;  // right-arrow on cursor keypad
OAPI_KEY_END            =$CF;  // End on cursor keypad
OAPI_KEY_DOWN           =$D0;  // down-arrow on cursor keypad
OAPI_KEY_NEXT           =$D1;  // PgDn on cursor keypad
OAPI_KEY_INSERT         =$D2;  // Insert on cursor keypad
OAPI_KEY_DELETE         =$D3;  // Delete on cursor keypad



THGROUP_MAIN=$0;
THGROUP_RETRO=$1;
THGROUP_HOVER=$2;
THGROUP_ATT_PITCHUP=$3;
THGROUP_ATT_PITCHDOWN=$4;
THGROUP_ATT_YAWLEFT=$5;
THGROUP_ATT_YAWRIGHT=$6;
THGROUP_ATT_BANKLEFT=$7;
THGROUP_ATT_BANKRIGHT=$8;
THGROUP_ATT_RIGHT=$9;
THGROUP_ATT_LEFT=$A;
THGROUP_ATT_UP=$B;
THGROUP_ATT_DOWN=$C;
THGROUP_ATT_FORWARD=$D;
THGROUP_ATT_BACK=$E;
THGROUP_USER=$F;

LIFT_VERTICAL=$0;
LIFT_HORIZONTAL=$1;

AIRCTRL_AXIS_AUTO=$0;
AIRCTRL_AXIS_YPOS=$1;
AIRCTRL_AXIS_YNEG=$2;
AIRCTRL_AXIS_XPOS=$3;
AIRCTRL_AXIS_XNEG=$4;

AIRCTRL_ELEVATOR=$0;
AIRCTRL_RUDDER=$1;
AIRCTRL_AILERON=$2;
AIRCTRL_FLAP=$3;
AIRCTRL_ELEVATORTRIM=$4;
AIRCTRL_RUDDERTRIM=$5;

CAM_COCKPIT              =0;
CAM_TARGETRELATIVE       =1;
CAM_ABSDIRECTION         =2;
CAM_GLOBALFRAME          =3;
CAM_TARGETTOOBJECT       =4;
CAM_TARGETFROMOBJECT     =5;
CAM_GROUNDOBSERVER       =6;

OBJTP_INVALID            =0 ;
OBJTP_GENERIC            =1 ;
OBJTP_CBODY              =2 ;
OBJTP_STAR               =3 ;
OBJTP_PLANET             =4 ;
OBJTP_VESSEL             =10;
OBJTP_SURFBASE           =20;


CFGPRM_SURFACEMAXLEVEL =$0001;
CFGPRM_SURFACEREFLECT  =$0002;
CFGPRM_SURFACERIPPLE   =$0003;
CFGPRM_SURFACELIGHTS   =$0004;
CFGPRM_SURFACEPATCHAP  =$0005;
CFGPRM_SURFACELIGHTBRT =$0006;
CFGPRM_ATMHAZE         =$0007;
CFGPRM_ATMFOG          =$0008;
 CFGPRM_CLOUDS          =$0009;
 CFGPRM_CLOUDSHADOWS    =$000A;
CFGPRM_PLANETARIUMFLAG =$000B;
CFGPRM_STARRENDERPRM   =$000C;
 CFGPRM_AMBIENTLEVEL    =$000E;
CFGPRM_VESSELSHADOWS   =$000F;
CFGPRM_OBJECTSHADOWS   =$0010;
CFGPRM_OBJECTSPECULAR  =$0011;
CFGPRM_SURFACESPECULAR =$0012;

               
OBJPRM_PLANET_SURFACEMAXLEVEL    =$0001;
OBJPRM_PLANET_SURFACERIPPLE      =$0002;
OBJPRM_PLANET_HAZEEXTENT         =$0003;
OBJPRM_PLANET_HAZEDENSITY        =$0004;
OBJPRM_PLANET_HAZESHIFT          =$0005;
OBJPRM_PLANET_HAZECOLOUR         =$0006;
OBJPRM_PLANET_FOGPARAM           =$0007;
OBJPRM_PLANET_SHADOWCOLOUR       =$0008;
OBJPRM_PLANET_HASCLOUDS          =$0009;
OBJPRM_PLANET_CLOUDALT           =$000A;
OBJPRM_PLANET_CLOUDROTATION      =$000B;
OBJPRM_PLANET_CLOUDSHADOWCOL     =$000C;
OBJPRM_PLANET_CLOUDMICROTEX      =$000D;
OBJPRM_PLANET_CLOUDMICROALTMIN   =$000E;
OBJPRM_PLANET_CLOUDMICROALTMAX   =$000F;
OBJPRM_PLANET_HASRINGS           =$0010;
OBJPRM_PLANET_RINGMINRAD         =$0011;
OBJPRM_PLANET_RINGMAXRAD         =$0012;
                    
COCKPIT_GENERIC=1;
COCKPIT_PANELS =2;
COCKPIT_VIRTUAL=3;

MESHVIS_NEVER   =$00;
MESHVIS_EXTERNAL=$01;
MESHVIS_COCKPIT =$02;
MESHVIS_ALWAYS  =MESHVIS_EXTERNAL+MESHVIS_COCKPIT;
MESHVIS_VC      =$04;
MESHVIS_EXTPASS =$10;

MAXMFD=10;
MFD_LEFT=0;
MFD_RIGHT=  1;
MFD_USER1=  2;
MFD_USER2=  3;
MFD_USER3=  4;
MFD_USER4=  5;
MFD_USER5=  6;
MFD_USER6=  7;
MFD_USER7=  8;
MFD_USER8=  9;

PANEL_LEFT= 0;
PANEL_RIGHT=1;
PANEL_UP=   2;
PANEL_DOWN= 3;

TEXIDX_MFD0:dword=$FFFFFFFF-MAXMFD;

MAXTEX=1;

type
ohnd=dword;

ilt=record
 dbgp:dword;
 oags,oagm,oagon:dword;
 oagh,oagfh,oaga,oagfa,oagta,oagep,oagfep:dword;
 oacamap,oacamgp,oacamgd,oacamt,oaggbbi,oaggbbn,oaggp,oaggv,oagobc,oagobbi,oagplac,oagplap,oagplapn,oagobt,oagfob,oagbsc,oagbsbi:dword;
 oagsimt,oagsimm,oacamrm,oacamm,oagrotm,oacampg,oaplha,oagobp,oagvi,oagfi,oadm,oamgc,oamgex,oamtc,oaci,oacm,oagth:dword;
 oawrss,oardss,oagdc,oardc:dword;
 oasfo,oagobn,oagem,oastac,oagvc,oagvbi,oadv:dword;
 vgetmc,vgetmt,vgetmvm,vcmft,vgetmo,cvesso,cvessl:dword;
 vgetcn,vgpmat,vggmat,vg2l,vl2g,vgetsr,vgetped,vgetapd,vaf,vsetst:dword;
 vgethav,vgetpt,vgetbk,vgetaoa,vgetrotvel,vsettgld,vgettgld,vsettgl,vgettgl,vsetcsl,vgetcsl,vsetadcm,vgetar,vgetvr:dword;
 vgettdp,vsettdp,vgetwbl,vgetsav,vgetav,vgetpmi,vgetls,vdosw,vdorsw,vdovw,vdorw,vsets,vgetasp,vgetanp,vgetmgtr,vsetmgtr:dword;
 oamm,oaca,oada,oaasp,oaast,oagsav,oagfas,oagfsasv,oactd,oacsd:dword;
 vgetec,vgetel,vgetes,vgetcoge:dword;
 oauxgetplmat,oamg,oast,oacts,oagpau,oasvsc,oagbspl,oaisves:dword;
end;
ilp=^ilt;

type
ATMCONST=record     // Planetary atmospheric constants
 p0:double;         //     pressure at mean radius ('sea level') [Pa]
 rho0:double;       //     density at mean radius
 R:double;          //     specific gas constant [J/(K kg)]
 gamma:double;      //     ratio of specific heats, c_p/c_v
 C:double;          //     exponent for pressure equation (temporary)
 O2pp:double;       //     partial pressure of oxygen
 altlimit:double;   //     atmosphere altitude limit [m]
 radlimit:double;   //     radius limit (altlimit + mean radius)
 horizonalt:double; //     horizon rendering altitude
 color0:vec;        //     sky colour at sea level during daytime
end;
pATMCONST=^ATMCONST;

ATMPARAM=record
 T:double;          //     temperature [K]
 p:double;          //     pressure [Pa]
 rho:double;        //     density [kg/m^3]
end;
pATMPARAM=^ATMPARAM;

MESHGROUP=record
 Vtx:pNTVERTEX; // vertex list
 Idx:pword; // index list
 nVtx:dword; // vertex count
 nIdx:dword; // index count
 MtrlIdx:dword; // material index (>= 1, 0=none)
 TexIdx:dword; // texture index (>= 1, 0=none)
 UsrFlag:dword; // user-defined flag
 zBias:word; // z bias
 Flags:word; // internal flags
end;
pMESHGROUP=^MESHGROUP;

COLOUR4=record
 r,g,b,a:single;
end;

MATERIAL=record
 diffuse:COLOUR4; // diffuse component
 ambient:COLOUR4; // ambient component
 specular:COLOUR4; // specular component
 emissive:COLOUR4; // emissive component
 power:single; // specular power
end;
pMATERIAL=^MATERIAL;

MESHGROUPEX=record
 Vtx:pNTVERTEX; // vertex list
 Idx:pword; // index list
 nVtx:dword; // vertex count
 nIdx:dword; // index count
 MtrlIdx:dword; // material index (>= 1, 0=none)
 TexIdx:dword; // texture index (>= 1, 0=none)
 UsrFlag:dword; // user-defined flag
 zBias:word; // z bias
 Flags:word; // internal flags
 TexIdxEx:array[0..MAXTEX-1]of dword; // additional texture indices
 TexMixEx:array[0..MAXTEX-1]of single; // texture mix values
end;
pMESHGROUPEX=^MESHGROUPEX;

VIDEODATA=record
 fullscreen:boolean;  ///< fullscreen mode flag
 forceenum:boolean;   ///< enforce device enumeration flag
 trystencil:boolean;  ///< stencil buffer flag
 novsync:boolean;     ///< no vsync flag
 deviceidx:integer;   ///< video device index
 modeidx:integer;     ///< video mode index
 winw:integer;        ///< window width
 winh:integer;        ///< window height
end;
pVIDEODATA=^VIDEODATA;

const
EMISSIVE=0;
DIFFUSE=1;

LVL_FLAT =0;
LVL_LIN  =1;
LVL_SQRT =2;
LVL_PLIN =3;
LVL_PSQRT=4;

ATM_FLAT=0;
ATM_PLIN=1;
ATM_PLOG=2;

type
//Particle stream parameters
PARTICLESTREAMSPEC=record
 flags:dword;       //     streamspec bitflags
 srcsize:double;    //     particle size at creation [m]
 srcrate:double;    //     average particle creation rate [Hz]
 v0:double;         //     emission velocity [m/s]
 srcspread:double;  //     velocity spread during creation
 lifetime:double;   //     average particle lifetime
 growthrate:double; //     particle growth rate [m/s]
 atmslowdown:double;//     slowdown rate in atmosphere
 ltype:integer;     //EMISSIVE, DIFFUSE  render lighting method
 levelmap:integer;  // LVL_FLAT, LVL_LIN, LVL_SQRT, LVL_PLIN, LVL_PSQRT  mapping from level to alpha
 lmin,lmax:double;  //     min and max levels for level PLIN and PSQRT mapping types
 atmsmap:integer;    //ATM_FLAT, ATM_PLIN, ATM_PLOG // mapping from atmospheric params to alpha
 amin,amax:double;  //     min and max densities for atms PLIN mapping
 tex:DWORD;         //     particle texture handle (NULL for default)
end;
pPARTICLESTREAMSPEC=^PARTICLESTREAMSPEC;

const
GRPEDIT_SETUSERFLAG =$0001; ///< replace the group's UsrFlag entry with the value in the GROUPEDITSPEC structure.
GRPEDIT_ADDUSERFLAG =$0002; ///< Add the UsrFlag value to the group's UsrFlag entry
GRPEDIT_DELUSERFLAG =$0004; ///< Remove the UsrFlag value from the group's UsrFlag entry
GRPEDIT_VTXCRDX     =$0008; ///< Replace vertex x-coordinates
GRPEDIT_VTXCRDY     =$0010; ///< Replace vertex y-coordinates
GRPEDIT_VTXCRDZ     =$0020; ///< Replace vertex z-coordinates
GRPEDIT_VTXCRD      =(GRPEDIT_VTXCRDX or GRPEDIT_VTXCRDY or GRPEDIT_VTXCRDZ); ///< Replace vertex coordinates
GRPEDIT_VTXNMLX     =$0040; ///< Replace vertex x-normals
GRPEDIT_VTXNMLY     =$0080; ///< Replace vertex y-normals
GRPEDIT_VTXNMLZ     =$0100; ///< Replace vertex z-normals
GRPEDIT_VTXNML      =(GRPEDIT_VTXNMLX or GRPEDIT_VTXNMLY or GRPEDIT_VTXNMLZ); ///< Replace vertex normals
GRPEDIT_VTXTEXU     =$0200; ///< Replace vertex u-texture coordinates
GRPEDIT_VTXTEXV     =$0400; ///< Replace vertex v-texture coordinates
GRPEDIT_VTXTEX      =(GRPEDIT_VTXTEXU or GRPEDIT_VTXTEXV); ///< Replace vertex texture coordinates
GRPEDIT_VTX         =(GRPEDIT_VTXCRD or GRPEDIT_VTXNML or GRPEDIT_VTXTEX); ///< Replace vertices

EVENT_VESSEL_INSMESH     =0; ///< Insert a mesh (context: mesh index)
EVENT_VESSEL_DELMESH     =1; ///< Delete a mesh (context: mesh index, or -1 for all)
EVENT_VESSEL_MESHVISMODE =2; ///< Set mesh visibility mode (context: mesh index)
EVENT_VESSEL_CLEARANIM   =4; ///< Clear all animations (context: UINT (1=reset animations, 0=leave animations at current state)
EVENT_VESSEL_DELANIM     =5; ///< Delete an animation (context: animation index)
EVENT_VESSEL_NEWANIM     =6; ///< Create a new animation (context: animation index)
EVENT_VESSEL_MESHOFS     =7; ///< Shift a mesh (context: mesh index)
EVENT_VESSEL_MODMESHGROUP=8; ///< A mesh group has been modified


type
GROUPEDITSPEC=record
 flags:dword;   ///< flags (see \ref grpedit)
 UsrFlag:dword; ///< Replacement for group UsrFlag entry
 Vtx:paNTVERTEX; ///< Replacement for group vertices
 nVtx:dword;    ///< Number of vertices to be replaced
 vIdx:pworda;    ///< Index list for vertices to be replaced
end;
pGROUPEDITSPEC=^GROUPEDITSPEC;


VCHUDSPEC=record
 nmesh,ngroup:dword;
 hudcnt:vec;
 size:double;
end;
pVCHUDSPEC=^VCHUDSPEC;

VCMFDSPEC=record
 nmesh,ngroup:dword;
end;
pVCMFDSPEC=^VCMFDSPEC;

  


var     
dbgprint:procedure(s:pchar); cdecl;
oapiGetSize:function(hObj:dword):double;cdecl;
oapiGetMass:function(hObj:dword):double;cdecl;

oapiGetObjectName:procedure(hObj:dword;name:pchar;siz:integer);cdecl; 

oapiGetHeading:function(hObj:dword;hdg:pdouble):integer;cdecl; 
oapiGetFocusHeading:function(hdg:pdouble):integer;cdecl; 
oapiGetAltitude:function(hObj:dword;alt:pdouble):integer;cdecl; 
oapiGetFocusAltitude:function(alt:pdouble):integer;cdecl; 

oapiGetTimeAcceleration:function:double;cdecl;

oapiGetEquPos:function(hObj:dword;lon,lat,rad:pdouble):integer;cdecl;  
oapiGetFocusEquPos:function(lon,lat,rad:pdouble):integer;cdecl; 


oapiCameraAperture:function:double;cdecl; 
oapiCameraGlobalPos:procedure(gpos:pvec);cdecl; 
oapiCameraGlobalDir:procedure(gdir:pvec);cdecl; 
oapiCameraTarget:function:ohnd;cdecl; 

oapiGetGbodyByIndex:function(index:integer):ohnd;cdecl; 
oapiGetGbodyByName:function(name:pchar):ohnd;cdecl; 
oapiGetGlobalPos:procedure(hObj:ohnd;pos:pvec);cdecl; 
oapiGetGlobalVel:procedure(hObj:ohnd;vel:pvec);cdecl; 
oapiGetObjectCount:function:integer;cdecl; 
oapiGetObjectByIndex:function(index:integer):ohnd;cdecl; 

oapiGetPlanetAtmConstants:function(hObj:ohnd):pATMCONST;cdecl; 
oapiGetPlanetAtmParams:procedure(hObj:ohnd;rad:double;prm:pATMPARAM);cdecl; 
oapiGetPlanetAtmParamsnew:procedure(hObj:ohnd;alt,lng,lat:double;prm:pATMPARAM);cdecl; 

oapiGetObjectType:function(hObj:ohnd):integer;cdecl; 
oapiGetFocusObject:function:ohnd;cdecl; 
oapiGetBaseCount:function(hObj:ohnd):integer;cdecl; 
oapiGetBaseByIndex:function(hPlanet:ohnd;index:integer):ohnd;cdecl;

oapiGetSimTime:function:double;cdecl; 
oapiGetSimMJD:function:double;cdecl; 

oapiCameraRotationMatrix:procedure(rmat:pmat);cdecl; 
oapiCameraMode:function:integer;cdecl; 

oapiGetRotationMatrix:procedure(hObj:ohnd;rmat:pmat);cdecl; 


oapiCameraProxyGbody:function:ohnd;cdecl; 
oapiPlanetHasAtmosphere:function(hObj:ohnd):boolean;cdecl; 

oapiGetObjectParam:function(hObj:ohnd;paramtype:dword):pointer;cdecl;

oapiGetVesselInterface:function(hObj:ohnd):pointer;cdecl;
oapiGetFocusInterface:function:pointer;cdecl;

oapiDeleteMesh:procedure(hMesh:pointer);cdecl;
oapiMeshGroupCount:function(hMesh:pointer):dword;cdecl;
oapiMeshGroupEx:function(hMesh:pointer;idx:dword):pMESHGROUPEX;cdecl;
oapiMeshTextureCount:function(hMesh:pointer):dword;cdecl;

oapiCameraInternal:function:boolean;cdecl;
oapiCockpitMode:function:integer;cdecl;

oapiGetTextureHandle:function(hMesh:pointer;texidx:dword):pointer;cdecl;

oapiWriteScenario_string:procedure(scn:DWORD;item,str:pchar);  cdecl;
oapiReadScenario_nextline:function(scn:DWORD;str:pchar):integer;cdecl;

oapiGetDC:function(surf:dword):DWORD;cdecl; 
oapiReleaseDC:procedure(surf:dword;hDC:DWORD);cdecl; 

oapiSetFocusObject:function(hVessel:dword):dword;cdecl;
oapiGetObjectByName:function(name:pchar):dword;cdecl;
oapiGetEmptyMass:function(hObj:dword):double;cdecl;    
oapiSetTimeAcceleration:procedure(warp:double);cdecl;

oapiGetVesselCount:function:integer;cdecl;
oapiIsVessel:function(hObj:dword):boolean;cdecl;
oapiGetVesselByIndex:function(index:integer):dword;cdecl; 

oapiDeleteVessel:function(hVessel,hAlternativeCameraTarget:ohnd):boolean;cdecl;

oapiMeshMaterial:function(hMesh:pointer;idx:dword):pmaterial;cdecl;
                                                                          
oapiCreateAnnotation:function(exclusive:boolean;size:double;col:pvec):dword;cdecl;   
oapiDelAnnotation:function(hNote:dword):boolean;cdecl;             
oapiAnnotationSetText:procedure(hNote:dword;note:pchar);cdecl;
oapiAnnotationSetPos:procedure(hNote:dword;x1,y1,x2,y2:double);cdecl;  

oapiGetShipAirspeedVector:function(hVessel:ohnd;speedvec:pvec):boolean;cdecl;
oapiGetFocusAirspeed:function(speedvec:pdouble):boolean;cdecl;
oapiGetFocusShipAirspeedVector:function(speedvec:pvec):boolean;cdecl;

oapiCameraTargetDist:function:double;cdecl;  
oapiCameraScaleDist:procedure(dscale:double);cdecl;  


//oapiMeshGroup:function(hMesh:pointer;idx:dword):pMESHGROUP;cdecl;
//oapiSetTexture:function(hMesh:pointer;texidx,tex:dword):boolean;cdecl;
oapiCreateTextureSurface:function(width,height:integer):dword;cdecl;

oapiGetPause:function:boolean;cdecl;    
oapiSaveScenario:function(fname,desc:pchar):boolean;cdecl;    
oapiGetBasePlanet:function(hbase:dword):dword;cdecl; 
 


vesGetMeshCount:function(v:pointer):dword;cdecl;
vesGetMeshTemplate:function(v:pointer;idx:dword):pointer;cdecl;  

vesGetAnimPtr:function(v:pointer;a:pointer):integer; cdecl;  
vesGetMGroup_Transform:function(v:pointer;mgt:pointer):mgroup_transform; cdecl;
vesSetMGroup_Transform:procedure(v:pointer;mgt:pointer;grp:pmgroup_transform); cdecl;  

vesGetMeshVisibilityMode:function(v:pointer;idx:dword):word;cdecl;
vesCopyMeshFromTemplate:function(v:pointer;idx:dword):pointer;cdecl;
vesGetMeshOffset:function(v:pointer;idx:dword;ofs:pvec):boolean;cdecl;

Createvesselorb:function(name,classnam,gbody:pchar;rp,rv,ar,vr:vec):integer;cdecl;
Createvessellnd:function(name,classnam,gbody:pchar;lat,lon,hdg:double):integer;cdecl;

vesGetClassName:procedure(v:pointer;name:pchar);cdecl;
vesgetpmat:procedure(v:pointer;p1,p2,p3:pvec);cdecl; 
vesgetgmat:procedure(v:pointer;p1,p2,p3:pvec);cdecl; 
vesGlobal2Local:function(v:pointer;vc:vec):vec; cdecl; 
vesLocal2Global:function(v:pointer;vc:vec):vec; cdecl; 

vesGetSurfaceRef:function(v:pointer):ohnd; cdecl; 
vesGetPeDist:function(v:pointer):double; cdecl; 
vesGetApDist:function(v:pointer):double; cdecl;  
vesAddForce:procedure(v:pointer;f,r:vec);cdecl; 


vesGetHorizonAirspeedVector:function(v:pointer):vec; cdecl;  
vesGetPitch:function(v:pointer):double; cdecl;  
vesGetBank:function(v:pointer):double; cdecl;  
vesGetAOA:function(v:pointer):double; cdecl;  

vesGetRotVelocity:function(v:pointer;t:integer):double; cdecl;  


vesSetThrusterGroupLeveld:procedure(v:pointer;thgt:dword;level:double); cdecl; 
vesGetThrusterGroupLeveld:function(v:pointer;thgt:dword):double; cdecl; 
vesSetThrusterGroupLevel:procedure(v:pointer;thg:dword;level:double); cdecl; 
vesGetThrusterGroupLevel:function(v:pointer;thg:dword):double; cdecl; 
vesSetControlSurfaceLevel:procedure(v:pointer;thgt:dword;level:double); cdecl;  
vesGetControlSurfaceLevel:function(v:pointer;thgt:dword):double; cdecl;  
vesSetADCtrlMode:procedure(v:pointer;mode:dword); cdecl;  

vesGetarot:function(v:pointer):vec; cdecl;
vesGetvrot:function(v:pointer):vec; cdecl;


vesGetTouchdownPoints:procedure(v:pointer;p1,p2,p3:pvec);cdecl; 
vesSetTouchdownPoints:procedure(v:pointer;p1,p2,p3:pvec);cdecl; 
vesGetWheelbrakeLevel:function(v:pointer;n:integer):double; cdecl;                       
vesGetShipAirspeedVector:function(v:pointer):vec; cdecl;                      
vesGetAirspeed:function(v:pointer):double; cdecl;  

vesGetAngularVel:function(v:pointer):vec; cdecl;  
vesGetPMI:function(v:pointer):vec; cdecl;  
vesLndStatus:function(v:pointer):integer; cdecl;  

vesdoshwrp:procedure(v:pointer;sh:vec);cdecl; 
vesdorshwrp:procedure(v:pointer;sh:vec);cdecl; 
vesdovelwrp:procedure(v:pointer;sh:vec);cdecl; 
vesdorotwrp:procedure(v:pointer;sh:vec);cdecl; 


vessetstatus:procedure(v:pointer;st:integer);cdecl;   
vessetsize:procedure(v:pointer;s:double);cdecl; 

vesGetExhaustCount:function(v:pointer):integer; cdecl;
vesGetExhaustLevel:function(v:pointer;idx:dword):double; cdecl;
vesGetExhaustSpec :function(v:pointer;idx:dword;lscale,wscale:pdouble;pos,dir:pvec;tex:pointer):boolean; cdecl;

vesGetCOG_elev:function(v:pointer):double; cdecl;


oauxgetplmat:procedure(ho:dword;p1,p2,p3:pvec);cdecl; 
        
procedure initoapi(a:ilp);   
function  str2okey(s:string):dword;

implementation

procedure initoapi(a:ilp);
begin    
 dbgprint:=pointer(a.dbgp); 
 
 oapiGetSize:=pointer(a.oags);
 oapiGetMass:=pointer(a.oagm);

 oapiGetObjectName:=pointer(a.oagon);

 oapiGetHeading:=pointer(a.oagh);
 oapiGetFocusHeading:=pointer(a.oagfh);
 oapiGetAltitude:=pointer(a.oaga);
 oapiGetFocusAltitude:=pointer(a.oagfa);

 oapiGetTimeAcceleration:=pointer(a.oagta);

 oapiGetEquPos:=pointer(a.oagep);
 oapiGetFocusEquPos:=pointer(a.oagfep); 

 oapiCameraAperture:=pointer(a.oacamap);
 oapiCameraGlobalPos:=pointer(a.oacamgp); 
 oapiCameraGlobalDir:=pointer(a.oacamgd); 
 oapiCameraTarget:=pointer(a.oacamt); 

 oapiGetGbodyByIndex:=pointer(a.oaggbbi); 
 oapiGetGbodyByName:=pointer(a.oaggbbn); 
 oapiGetGlobalPos:=pointer(a.oaggp); 
 oapiGetGlobalVel:=pointer(a.oaggv); 
 oapiGetObjectCount:=pointer(a.oagobc); 
 oapiGetObjectByIndex:=pointer(a.oagobbi); 

 oapiGetPlanetAtmConstants:=pointer(a.oagplac); 
 oapiGetPlanetAtmParams:=pointer(a.oagplap); 
 oapiGetPlanetAtmParamsnew:=pointer(a.oagplapn); 

 oapiGetObjectType:=pointer(a.oagobt); 
 oapiGetFocusObject:=pointer(a.oagfob); 
 oapiGetBaseCount:=pointer(a.oagbsc); 
 oapiGetBaseByIndex:=pointer(a.oagbsbi); 

 oapiGetSimTime:=pointer(a.oagsimt); 
 oapiGetSimMJD:=pointer(a.oagsimm); 

 oapiCameraRotationMatrix:=pointer(a.oacamrm); 
 oapiCameraMode:=pointer(a.oacamm); 

 oapiGetRotationMatrix:=pointer(a.oagrotm); 

 oapiCameraProxyGbody:=pointer(a.oacampg); 
 oapiPlanetHasAtmosphere:=pointer(a.oaplha); 

 oapiGetObjectParam:=pointer(a.oagobp); 

 oapiGetVesselInterface:=pointer(a.oagvi); 
 oapiGetFocusInterface:=pointer(a.oagfi); 
 oapiDeleteMesh:=pointer(a.oadm); 
 oapiMeshGroupCount:=pointer(a.oamgc);
 oapiMeshGroupEx:=pointer(a.oamgex); 
 oapiMeshTextureCount:=pointer(a.oamtc);
 
 oapiCameraInternal:=pointer(a.oaci);
 oapiCockpitMode:=pointer(a.oacm);
 oapiGetTextureHandle:=pointer(a.oagth);

 
 oapiWriteScenario_string:=pointer(a.oawrss);
 oapiReadScenario_nextline:=pointer(a.oardss);
 oapiGetDC:=pointer(a.oagdc);
 oapiReleaseDC:=pointer(a.oardc);

 oapiSetFocusObject:=pointer(a.oasfo);   
 oapiGetObjectByName:=pointer(a.oagobn);
 oapiGetEmptyMass:=pointer(a.oagem);    
 oapiSetTimeAcceleration:=pointer(a.oastac); 

 oapiGetVesselCount:=pointer(a.oagvc); 
 oapiGetVesselByIndex:=pointer(a.oagvbi); 
 oapiDeleteVessel:=pointer(a.oadv); 
 oapiMeshMaterial:=pointer(a.oamm); 

                                        
 oapiCreateAnnotation:=pointer(a.oaca);
 oapiDelAnnotation:=pointer(a.oada);
 oapiAnnotationSetText:=pointer(a.oaast);
 oapiAnnotationSetPos:=pointer(a.oaasp); 

 oapiGetShipAirspeedVector:=pointer(a.oagsav);  
 oapiGetFocusAirspeed:=pointer(a.oagfas);  
 oapiGetFocusShipAirspeedVector:=pointer(a.oagfsasv);  

 oapiCameraTargetDist:=pointer(a.oactd);  
 oapiCameraScaleDist:=pointer(a.oacsd);  

 //oapiMeshGroup:=pointer(a.oamg);  
 //oapiSetTexture:=pointer(a.oast);  
 oapiCreateTextureSurface:=pointer(a.oacts);  

 oapiGetPause:=pointer(a.oagpau);
 oapiSaveScenario:=pointer(a.oasvsc);
 oapiGetBasePlanet:=pointer(a.oagbspl);

 oapiIsVessel:=pointer(a.oaisves);

 vesGetMeshCount:=pointer(a.vgetmc); 
 vesGetMeshTemplate:=pointer(a.vgetmt); 
 vesGetMeshVisibilityMode:=pointer(a.vgetmvm);
 vesCopyMeshFromTemplate:=pointer(a.vcmft);
 vesGetMeshOffset:=pointer(a.vgetmo);

 
 

 Createvesselorb:=pointer(a.cvesso);
 Createvessellnd:=pointer(a.cvessl);

 vesGetClassName:=pointer(a.vgetcn);    
 vesgetpmat:=pointer(a.vgpmat);   
 vesgetgmat:=pointer(a.vggmat);  
 
 vesGlobal2Local:=pointer(a.vg2l);  
 vesLocal2Global:=pointer(a.vl2g);   

 vesGetSurfaceRef:=pointer(a.vgetsr);   
 vesGetPeDist:=pointer(a.vgetped);    
 vesGetApDist:=pointer(a.vgetapd); 
 vesAddForce:=pointer(a.vaf); 

 vesGetHorizonAirspeedVector:=pointer(a.vgethav); 
 vesGetPitch:=pointer(a.vgetpt);  
 vesGetBank:=pointer(a.vgetbk);  
 vesGetAOA:=pointer(a.vgetaoa);  
 vesGetRotVelocity:=pointer(a.vgetrotvel);  
 vesSetThrusterGroupLeveld:=pointer(a.vsettgld);
 vesGetThrusterGroupLeveld:=pointer(a.vgettgld);
 vesSetThrusterGroupLevel:=pointer(a.vsettgl);
 vesGetThrusterGroupLevel:=pointer(a.vgettgl);
 vesSetControlSurfaceLevel:=pointer(a.vsetcsl);
 vesGetControlSurfaceLevel:=pointer(a.vgetcsl);
 vesSetADCtrlMode:=pointer(a.vsetadcm);

 vesGetarot:=pointer(a.vgetar);
 vesGetvrot:=pointer(a.vgetvr);

 vesGetTouchdownPoints:=pointer(a.vgettdp);
 vesSetTouchdownPoints:=pointer(a.vsettdp);
 vesGetWheelbrakeLevel:=pointer(a.vgetwbl);
 vesGetShipAirspeedVector:=pointer(a.vgetsav);
 
 vesGetAngularVel:=pointer(a.vgetav);
 vesGetPMI:=pointer(a.vgetpmi);
 vesLndStatus:=pointer(a.vgetls);

 
 vesdoshwrp:=pointer(a.vdosw);
 vesdorshwrp:=pointer(a.vdorsw);
 vesdovelwrp:=pointer(a.vdovw);
 vesdorotwrp:=pointer(a.vdorw);

 vessetstatus:=pointer(a.vsetst);
 vessetsize:=pointer(a.vsets);

 vesGetAirspeed:=pointer(a.vgetasp);

 vesGetAnimPtr:=pointer(a.vgetanp);
 vesGetMGroup_Transform:=pointer(a.vgetmgtr); 
 vesSetMGroup_Transform:=pointer(a.vsetmgtr); 
 
 vesGetExhaustCount:=pointer(a.vgetec); 
 vesGetExhaustLevel:=pointer(a.vgetel); 
 vesGetExhaustSpec :=pointer(a.vgetes); 

 vesGetCOG_elev:=pointer(a.vgetcoge);

 oauxgetplmat:=pointer(a.oauxgetplmat);
end;  
//############################################################################//
function str2okey(s:string):dword;
begin
 result:=0;
 if s='K' then result:=OAPI_KEY_K;
 if s='G' then result:=OAPI_KEY_G;
 if s='J' then result:=OAPI_KEY_J;
 if s='1' then result:=OAPI_KEY_1;
 if s='2' then result:=OAPI_KEY_2;
 if s='3' then result:=OAPI_KEY_3;
end;
//############################################################################//
begin
end.  
//############################################################################//