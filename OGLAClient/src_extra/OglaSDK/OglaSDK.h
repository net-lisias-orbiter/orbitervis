//############################################################################//
//OGLAClient interface calls
//Made by Artlav in 2007-2009
//############################################################################//
#if !defined(_OGLASDK_H)
#define _OGLASDK_H
//############################################################################//
//Constants
///Render shadows in VC
#define OGLC_VCSHADOWS   1
///Change nothing,return current.
#define OGLC_READ_FLAGS 0xFFFFFFFF
//############################################################################//
///Spot light
#define OGLA_LIGHT_SPOT 0
///Point light
#define OGLA_LIGHT_OMNI 1
///Animation turns the light on and off abruptly
#define OGLA_ANIM_DISCRETE 2
//############################################################################//
//Normal and specular texture (rgb-normal, a-specular)
#define OGLA_TX_NORMAL_SPECULAR 1
//Emission light texture
#define OGLA_TX_EMISSION 2
//############################################################################//
///Light info structure
typedef struct{
 bool ison;       ///Light enabled
 int type;        ///Type of light
 double spot;     ///Spotlight - angle size of the spot
 double vis_rad;  ///Distance from camera up to which the light is rendered
 double pwr;      ///Power
 double set_pwr;  ///Set power (0.0 to 1.0)
 VECTOR3 pos,dir; ///Position and direction
} oglc_light_rec;
//############################################################################//
//Functions
//############################################################################//
///Set option flags
///Returns previous settings
DWORD oglcSetFlags(
 VISHANDLE VesselHandle,	///Vishandle of the vessel to apply to
 DWORD flags			///Flags to set
);
//############################################################################//
void oglcBindLightThruster(
 VISHANDLE VesselHandle,
 oglc_light_rec *lt,	///Light to bind
 THGROUP_HANDLE th	///Thruster group index to bind the light to
);
//############################################################################//
void oglcBindLightAnim(
 VISHANDLE VesselHandle,
 oglc_light_rec *lt,	///Light to bind
 int off_is,		///Animation state value considered light On
 UINT anim			///Animation to bind to
);
//############################################################################//
oglc_light_rec *oglcAddLight(
 VISHANDLE VesselHandle,
 int type,		///Light type
 VECTOR3 pos,	///Light position
 VECTOR3 dir,	///Spotlight - light direction
 VECTOR3 col,	///Light colour
 double spot,	///Spotlight - spot angular size in degrees
 double vis_rad,	///Distance from camera up to which the light is rendered
 double pwr		///Power
);
//############################################################################//
void oglcBindTexture(
 VISHANDLE VesselHandle,
 int type,			///Type of texture
 int mesh,			///Mesh number to apply texture to group of (0-...)
 int group,			///Mesh group to apply texture to (0-...)
 SURFHANDLE tex		///Handle of the texture to be applied
);
//############################################################################//
void oglcBindExtMesh(
 VISHANDLE VesselHandle,
 int mesh,			///Mesh number to apply extension to (0-...)
 char *mshname 	///Name of the msh to load
);
//############################################################################//
#endif // _OGLASDK_H
//############################################################################//
