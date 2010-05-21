//############################################################################//
// OpenGL headers
// Released under GNU General Public License
//############################################################################//
unit opengl1x;
interface
{$i GLC.inc}
{.$define MULTITHREADOPENGL}
//############################################################################//
uses sysutils,
{$ifdef MSWINDOWS}windows{$endif}
{$ifdef LINUX}X,Xlib,dynlibs,xutil,types{$endif}
;
//############################################################################//
type
TRCOptions=set of(opDoubleBuffered,opGDI,opStereo);
{$ifdef LINUX}
 XID=TXID;
 pixmap=tpixmap;
 font=tfont;
 window=twindow;
 colormap=tcolormap;
{$endif}
//############################################################################//
{$ifdef MSWINDOWS}
PWGLSwap = ^TWGLSwap;
_WGLSWAP = packed record
  hdc: HDC;
  uiFlags: UINT;
end;
TWGLSwap = _WGLSWAP;
WGLSWAP = _WGLSWAP;
{$endif}

// Linux type
{$ifdef LINUX}
GLXContext    = Pointer;
GLXPixmap     = XID;
GLXDrawable   = XID;

// GLX 1.3 and later
GLXFBConfig   = Pointer;
GLXFBConfigID = XID;
GLXContextID  = XID;
GLXWindow     = XID;
GLXPbuffer    = XID;
{$endif}    
//############################################################################//
//############################################################################//
{$ifdef MULTITHREADOPENGL}threadvar{$else}var{$endif}
GL_VERSION_1_0,
GL_VERSION_1_1,
GL_VERSION_1_2,
GL_VERSION_1_3,
GL_VERSION_1_4,
GL_VERSION_1_5,
GLU_VERSION_1_1,
GLU_VERSION_1_2,
GLU_VERSION_1_3: Boolean;
//############################################################################//
// Extensions (gl)
GL_3DFX_multisample,
GL_3DFX_tbuffer,
GL_3DFX_texture_compression_FXT1,

GL_ARB_imaging,
GL_ARB_multisample,
GL_ARB_multitexture,
GL_ARB_depth_texture,
GL_ARB_shadow,
GL_ARB_texture_border_clamp,
GL_ARB_texture_compression,
GL_ARB_texture_cube_map,
GL_ARB_transpose_matrix,
GL_ARB_vertex_blend,
GL_ARB_point_parameters,
GL_ARB_texture_env_combine,
GL_ARB_texture_env_crossbar,
GL_ARB_texture_env_dot3,
GL_ARB_vertex_program,
GL_ARB_vertex_buffer_object,
GL_ARB_shader_objects,
GL_ARB_vertex_shader,
GL_ARB_fragment_shader,
GL_ARB_fragment_program,

GL_EXT_abgr,
GL_EXT_bgra,
GL_EXT_blend_color,
GL_EXT_blend_func_separate,
GL_EXT_blend_logic_op,
GL_EXT_blend_minmax,
GL_EXT_blend_subtract,
GL_EXT_Cg_shader,
GL_EXT_compiled_vertex_array,
GL_EXT_copy_texture,
GL_EXT_draw_range_elements,
GL_EXT_fog_coord,
GL_EXT_multi_draw_arrays,
GL_EXT_multisample,
GL_EXT_packed_pixels,
GL_EXT_paletted_texture,
GL_EXT_polygon_offset,
GL_EXT_rescale_normal,
GL_EXT_secondary_color,
GL_EXT_separate_specular_color,
GL_EXT_shared_texture_palette,
GL_EXT_stencil_wrap,
GL_EXT_stencil_two_side,
GL_EXT_texture_compression_s3tc,
GL_EXT_texture_cube_map,
GL_EXT_texture_edge_clamp,
GL_EXT_texture_env_add,
GL_EXT_texture_env_combine,
GL_EXT_texture_filter_anisotropic,
GL_EXT_texture_lod_bias,
GL_EXT_texture_object,
GL_EXT_texture3D,
GL_EXT_clip_volume_hint,

GL_HP_occlusion_test,

GL_IBM_rasterpos_clip,

GL_KTX_buffer_region,

GL_MESA_resize_buffers,

GL_NV_blend_square,
GL_NV_fog_distance,
GL_NV_light_max_exponent,
GL_NV_register_combiners,
GL_NV_texgen_reflection,
GL_NV_texture_env_combine4,
GL_NV_vertex_array_range,
GL_NV_vertex_program,
GL_NV_multisample_filter_hint,
GL_NV_fence,
GL_NV_occlusion_query,
GL_NV_texture_rectangle,

GL_ATI_texture_float,
GL_ATI_draw_buffers,

GL_SGI_color_matrix,

GL_SGIS_generate_mipmap,
GL_SGIS_multisample,
GL_SGIS_texture_border_clamp,
GL_SGIS_texture_color_mask,
GL_SGIS_texture_edge_clamp,
GL_SGIS_texture_lod,

GL_SGIX_depth_texture,
GL_SGIX_shadow,
GL_SGIX_shadow_ambient,

GL_WIN_swap_hint,

//WGL Extensions
WGL_EXT_swap_control,
WGL_ARB_multisample,
WGL_ARB_extensions_string,
WGL_ARB_pixel_format,
WGL_ARB_pbuffer,
WGL_ARB_buffer_region,
WGL_ATI_pixel_format_float,

//Extensions (glu)
GLU_EXT_Texture,
GLU_EXT_object_space_tess,
GLU_EXT_nurbs_tessellator:Boolean;
//############################################################################//
//############################################################################//
const
{$ifdef MSWINDOWS}
 opengl32='OpenGL32.dll';
 glu32='GLU32.dll';
{$endif}
{$ifdef LINUX}
 opengl32='libGL.so';
 glu32='libGLU.so'; 
{$endif} 
//############################################################################//
{$i glconst.inc}
//############################################################################//
type
// GLU types
TGLUNurbs = record end;
TGLUQuadric = record end;
TGLUTesselator = record end;

PGLUNurbs = ^TGLUNurbs;
PGLUQuadric = ^TGLUQuadric;
PGLUTesselator=  ^TGLUTesselator;

// backwards compatibility
TGLUNurbsObj = TGLUNurbs;
TGLUQuadricObj = TGLUQuadric;
TGLUTesselatorObj = TGLUTesselator;
TGLUTriangulatorObj = TGLUTesselator;

PGLUNurbsObj = PGLUNurbs;
PGLUQuadricObj = PGLUQuadric;
PGLUTesselatorObj = PGLUTesselator;
PGLUTriangulatorObj = PGLUTesselator;

// Callback function prototypes
// GLUQuadricCallback
TGLUQuadricErrorProc = procedure(errorCode: TGLEnum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}

// GLUTessCallback
TGLUTessBeginProc = procedure(AType: TGLEnum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
TGLUTessEdgeFlagProc = procedure(Flag: TGLboolean); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
TGLUTessVertexProc = procedure(VertexData: Pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
TGLUTessEndProc = procedure; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
TGLUTessErrorProc = procedure(ErrNo: TGLEnum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
TGLUTessCombineProc = procedure(const Coords: TVector3d; const VertexData: TVector4p; const Weight: TVector4f; OutData: PGLPointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
TGLUTessBeginDataProc = procedure(AType: TGLEnum; UserData: Pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
TGLUTessEdgeFlagDataProc = procedure(Flag: TGLboolean; UserData: Pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
TGLUTessVertexDataProc = procedure(VertexData: Pointer; UserData: Pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
TGLUTessEndDataProc = procedure(UserData: Pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
TGLUTessErrorDataProc = procedure(ErrNo: TGLEnum; UserData: Pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
TGLUTessCombineDataProc = procedure(const Coords: TVector3d; const VertexData: TVector4p; const Weight: TVector4f; OutData: PGLPointer; UserData: Pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}

// GLUNurbsCallback
TGLUNurbsErrorProc = procedure(ErrorCode: TGLEnum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
//############################################################################//
//############################################################################//
// GL functions and procedures
procedure glAccum(op: TGLuint; value: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glAlphaFunc(func: TGLEnum; ref: TGLclampf); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
function  glAreTexturesResident(n: TGLsizei; Textures: PGLuint; residences: PGLboolean): TGLboolean; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glArrayElement(i: TGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glBegin(mode: TGLEnum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glBindTexture(target: TGLEnum; texture: TGLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glBitmap(width: TGLsizei; height: TGLsizei; xorig, yorig: TGLfloat; xmove: TGLfloat; ymove: TGLfloat; bitmap: Pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glBlendFunc(sfactor: TGLEnum; dfactor: TGLEnum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glCallList(list: TGLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glCallLists(n: TGLsizei; atype: TGLEnum; lists: Pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glClear(mask: TGLbitfield); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glClearAccum(red, green, blue, alpha: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glClearColor(red, green, blue, alpha: TGLclampf); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glClearDepth(depth: TGLclampd); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glClearIndex(c: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glClearStencil(s: TGLint ); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glClipPlane(plane: TGLEnum; equation: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;

procedure glColor3b(red, green, blue: TGLbyte); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glColor3bv(v: PGLbyte); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glColor3d(red, green, blue: TGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glColor3dv(v: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glColor3f(red, green, blue: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glColor3fv(v: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glColor3i(red, green, blue: TGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glColor3iv(v: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glColor3s(red, green, blue: TGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glColor3sv(v: PGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glColor3ub(red, green, blue: TGLubyte); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glColor3ubv(v: PGLubyte); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glColor3ui(red, green, blue: TGLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glColor3uiv(v: PGLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glColor3us(red, green, blue: TGLushort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glColor3usv(v: PGLushort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glColor4b(red, green, blue, alpha: TGLbyte); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glColor4bv(v: PGLbyte); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glColor4d(red, green, blue, alpha: TGLdouble ); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glColor4dv(v: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glColor4f(red, green, blue, alpha: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glColor4fv(v: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glColor4i(red, green, blue, alpha: TGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glColor4iv(v: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glColor4s(red, green, blue, alpha: TGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glColor4sv(v: TGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glColor4ub(red, green, blue, alpha: TGLubyte); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glColor4ubv(v: PGLubyte); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glColor4ui(red, green, blue, alpha: TGLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glColor4uiv(v: PGLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glColor4us(red, green, blue, alpha: TGLushort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glColor4usv(v: PGLushort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;

procedure glColorMask(red, green, blue, alpha: TGLboolean); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glColorMaterial(face: TGLEnum; mode: TGLEnum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glColorPointer(size: TGLint; atype: TGLEnum; stride: TGLsizei; data: pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glCopyPixels(x, y: TGLint; width, height: TGLsizei; atype: TGLEnum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glCopyTexImage1D(target: TGLEnum; level: TGLint; internalFormat: TGLEnum; x, y: TGLint; width: TGLsizei; border: TGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glCopyTexImage2D(target: TGLEnum; level: TGLint; internalFormat: TGLEnum; x, y: TGLint; width, height: TGLsizei; border: TGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glCopyTexSubImage1D(target: TGLEnum; level, xoffset, x, y: TGLint; width: TGLsizei); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glCopyTexSubImage2D(target: TGLEnum; level, xoffset, yoffset, x, y: TGLint; width, height: TGLsizei); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glCullFace(mode: TGLEnum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glDeleteLists(list: TGLuint; range: TGLsizei); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glDeleteTextures(n: TGLsizei; textures: PGLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glDepthFunc(func: TGLEnum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glDepthMask(flag: TGLboolean); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glDepthRange(zNear, zFar: TGLclampd); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glDisable(cap: TGLEnum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glDisableClientState(aarray: TGLEnum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glDrawArrays(mode: TGLEnum; first: TGLint; count: TGLsizei); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glDrawBuffer(mode: TGLEnum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glDrawElements(mode: TGLEnum; count: TGLsizei; atype: TGLEnum; indices: Pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glDrawPixels(width, height: TGLsizei; format, atype: TGLEnum; pixels: Pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;

procedure glEdgeFlag(flag: TGLboolean); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glEdgeFlagPointer(stride: TGLsizei; data: pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glEdgeFlagv(flag: PGLboolean); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glEnable(cap: TGLEnum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glEnableClientState(aarray: TGLEnum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glEnd; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glEndList; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glEvalCoord1d(u: TGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glEvalCoord1dv(u: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glEvalCoord1f(u: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glEvalCoord1fv(u: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glEvalCoord2d(u: TGLdouble; v: TGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glEvalCoord2dv(u: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glEvalCoord2f(u, v: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glEvalCoord2fv(u: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glEvalMesh1(mode: TGLEnum; i1, i2: TGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glEvalMesh2(mode: TGLEnum; i1, i2, j1, j2: TGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glEvalPoint1(i: TGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glEvalPoint2(i, j: TGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;

procedure glFeedbackBuffer(size: TGLsizei; atype: TGLEnum; buffer: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glFinish; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glFlush; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glFogf(pname: TGLEnum; param: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glFogfv(pname: TGLEnum; params: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glFogi(pname: TGLEnum; param: TGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glFogiv(pname: TGLEnum; params: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glFrontFace(mode: TGLEnum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glFrustum(left, right, bottom, top, zNear, zFar: TGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
function  glGenLists(range: TGLsizei): TGLuint; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glGenTextures(n: TGLsizei; textures: PGLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glGetBooleanv(pname: TGLEnum; params: PGLboolean); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glGetClipPlane(plane: TGLEnum; equation: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glGetDoublev(pname: TGLEnum; params: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
function  glGetError: TGLuint; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glGetFloatv(pname: TGLEnum; params: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glGetIntegerv(pname: TGLEnum; params: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glGetLightfv(light, pname: TGLEnum; params: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glGetLightiv(light, pname: TGLEnum; params: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glGetMapdv(target, query: TGLEnum; v: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glGetMapfv(target, query: TGLEnum; v: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glGetMapiv(target, query: TGLEnum; v: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glGetMaterialfv(face, pname: TGLEnum; params: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glGetMaterialiv(face, pname: TGLEnum; params: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glGetPixelMapfv(map: TGLEnum; values: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glGetPixelMapuiv(map: TGLEnum; values: PGLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glGetPixelMapusv(map: TGLEnum; values: PGLushort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glGetPointerv(pname: TGLEnum; var params); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glGetPolygonStipple(mask: PGLubyte); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
function  glGetString(name: TGLEnum): PChar; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glGetTexEnvfv(target, pname: TGLEnum; params: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glGetTexEnviv(target, pname: TGLEnum; params: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glGetTexGendv(coord, pname: TGLEnum; params: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glGetTexGenfv(coord, pname: TGLEnum; params: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glGetTexGeniv(coord, pname: TGLEnum; params: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glGetTexImage(target: TGLEnum; level: TGLint; format, atype: TGLEnum; pixels: Pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glGetTexLevelParameterfv(target: TGLEnum; level: TGLint; pname: TGLEnum; params: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glGetTexLevelParameteriv(target: TGLEnum; level: TGLint; pname: TGLEnum; params: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glGetTexParameterfv(target, pname: TGLEnum; params: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glGetTexParameteriv(target, pname: TGLEnum; params: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;

procedure glHint(target, mode: TGLEnum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glIndexMask(mask: TGLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glIndexPointer(atype: TGLEnum; stride: TGLsizei; data: pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glIndexd(c: TGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glIndexdv(c: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glIndexf(c: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glIndexfv(c: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glIndexi(c: TGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glIndexiv(c: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glIndexs(c: TGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glIndexsv(c: PGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glIndexub(c: TGLubyte); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glIndexubv(c: PGLubyte); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glInitNames; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glInterleavedArrays(format: TGLEnum; stride: TGLsizei; data: pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
function  glIsEnabled(cap: TGLEnum): TGLboolean; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
function  glIsList(list: TGLuint): TGLboolean; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
function  glIsTexture(texture: TGLuint): TGLboolean; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glLightModelf(pname: TGLEnum; param: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glLightModelfv(pname: TGLEnum; params: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glLightModeli(pname: TGLEnum; param: TGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glLightModeliv(pname: TGLEnum; params: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glLightf(light, pname: TGLEnum; param: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glLightfv(light, pname: TGLEnum; params: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glLighti(light, pname: TGLEnum; param: TGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glLightiv(light, pname: TGLEnum; params: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glLineStipple(factor: TGLint; pattern: TGLushort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glLineWidth(width: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glListBase(base: TGLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glLoadIdentity; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glLoadMatrixd(m: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glLoadMatrixf(m: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glLoadName(name: TGLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glLogicOp(opcode: TGLEnum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;

procedure glMap1d(target: TGLEnum; u1, u2: TGLdouble; stride, order: TGLint; points: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glMap1f(target: TGLEnum; u1, u2: TGLfloat; stride, order: TGLint; points: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glMap2d(target: TGLEnum; u1, u2: TGLdouble; ustride, uorder: TGLint; v1, v2: TGLdouble; vstride,
                  vorder: TGLint; points: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glMap2f(target: TGLEnum; u1, u2: TGLfloat; ustride, uorder: TGLint; v1, v2: TGLfloat; vstride,
                  vorder: TGLint; points: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glMapGrid1d(un: TGLint; u1, u2: TGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glMapGrid1f(un: TGLint; u1, u2: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glMapGrid2d(un: TGLint; u1, u2: TGLdouble; vn: TGLint; v1, v2: TGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glMapGrid2f(un: TGLint; u1, u2: TGLfloat; vn: TGLint; v1, v2: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glMaterialf(face, pname: TGLEnum; param: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glMaterialfv(face, pname: TGLEnum; params: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glMateriali(face, pname: TGLEnum; param: TGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glMaterialiv(face, pname: TGLEnum; params: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glMatrixMode(mode: TGLEnum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glMultMatrixd(m: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glMultMatrixf(m: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glNewList(list: TGLuint; mode: TGLEnum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glNormal3b(nx, ny, nz: TGLbyte); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glNormal3bv(v: PGLbyte); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glNormal3d(nx, ny, nz: TGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glNormal3dv(v: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glNormal3f(nx, ny, nz: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glNormal3fv(v: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glNormal3i(nx, ny, nz: TGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glNormal3iv(v: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glNormal3s(nx, ny, nz: TGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glNormal3sv(v: PGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glNormalPointer(atype: TGLEnum; stride: TGLsizei; data: pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;

procedure glOrtho(left, right, bottom, top, zNear, zFar: TGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glPassThrough(token: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glPixelMapfv(map: TGLEnum; mapsize: TGLsizei; values: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glPixelMapuiv(map: TGLEnum; mapsize: TGLsizei; values: PGLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glPixelMapusv(map: TGLEnum; mapsize: TGLsizei; values: PGLushort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glPixelStoref(pname: TGLEnum; param: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glPixelStorei(pname: TGLEnum; param: TGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glPixelTransferf(pname: TGLEnum; param: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glPixelTransferi(pname: TGLEnum; param: TGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glPixelZoom(xfactor, yfactor: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glPointSize(size: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glPolygonMode(face, mode: TGLEnum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glPolygonOffset(factor, units: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glPolygonStipple(mask: PGLubyte); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glPopAttrib; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glPopClientAttrib; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glPopMatrix; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glPopName; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glPrioritizeTextures(n: TGLsizei; textures: PGLuint; priorities: PGLclampf); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glPushAttrib(mask: TGLbitfield); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glPushClientAttrib(mask: TGLbitfield); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glPushMatrix; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glPushName(name: TGLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;

procedure glRasterPos2d(x, y: TGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glRasterPos2dv(v: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glRasterPos2f(x, y: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glRasterPos2fv(v: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glRasterPos2i(x, y: TGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glRasterPos2iv(v: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glRasterPos2s(x, y: PGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glRasterPos2sv(v: PGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glRasterPos3d(x, y, z: TGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glRasterPos3dv(v: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glRasterPos3f(x, y, z: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glRasterPos3fv(v: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glRasterPos3i(x, y, z: TGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glRasterPos3iv(v: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glRasterPos3s(x, y, z: TGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glRasterPos3sv(v: PGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glRasterPos4d(x, y, z, w: TGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glRasterPos4dv(v: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glRasterPos4f(x, y, z, w: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glRasterPos4fv(v: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glRasterPos4i(x, y, z, w: TGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glRasterPos4iv(v: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glRasterPos4s(x, y, z, w: TGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glRasterPos4sv(v: PGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glReadBuffer(mode: TGLEnum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glReadPixels(x, y: TGLint; width, height: TGLsizei; format, atype: TGLEnum; pixels: Pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glRectd(x1, y1, x2, y2: TGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glRectdv(v1, v2: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glRectf(x1, y1, x2, y2: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glRectfv(v1, v2: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glRecti(x1, y1, x2, y2: TGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glRectiv(v1, v2: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glRects(x1, y1, x2, y2: TGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glRectsv(v1, v2: PGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
function  glRenderMode(mode: TGLEnum): TGLint; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glRotated(angle, x, y, z: TGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glRotatef(angle, x, y, z: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;

procedure glScaled(x, y, z: TGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glScalef(x, y, z: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glScissor(x, y: TGLint; width, height: TGLsizei); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glSelectBuffer(size: TGLsizei; buffer: PGLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glShadeModel(mode: TGLEnum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glStencilFunc(func: TGLEnum; ref: TGLint; mask: TGLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glStencilMask(mask: TGLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glStencilOp(fail, zfail, zpass: TGLEnum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexCoord1d(s: TGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexCoord1dv(v: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexCoord1f(s: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexCoord1fv(v: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexCoord1i(s: TGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexCoord1iv(v: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexCoord1s(s: TGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexCoord1sv(v: PGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexCoord2d(s, t: TGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexCoord2dv(v: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexCoord2f(s, t: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexCoord2fv(v: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexCoord2i(s, t: TGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexCoord2iv(v: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexCoord2s(s, t: TGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexCoord2sv(v: PGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexCoord3d(s, t, r: TGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexCoord3dv(v: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexCoord3f(s, t, r: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexCoord3fv(v: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexCoord3i(s, t, r: TGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexCoord3iv(v: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexCoord3s(s, t, r: TGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexCoord3sv(v: PGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexCoord4d(s, t, r, q: TGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexCoord4dv(v: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexCoord4f(s, t, r, q: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexCoord4fv(v: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexCoord4i(s, t, r, q: TGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexCoord4iv(v: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexCoord4s(s, t, r, q: TGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexCoord4sv(v: PGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexCoordPointer(size: TGLint; atype: TGLEnum; stride: TGLsizei; data: pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexEnvf(target, pname: TGLEnum; param: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexEnvfv(target, pname: TGLEnum; params: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexEnvi(target, pname: TGLEnum; param: TGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexEnviv(target, pname: TGLEnum; params: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexGend(coord, pname: TGLEnum; param: TGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexGendv(coord, pname: TGLEnum; params: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexGenf(coord, pname: TGLEnum; param: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexGenfv(coord, pname: TGLEnum; params: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexGeni(coord, pname: TGLEnum; param: TGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexGeniv(coord, pname: TGLEnum; params: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexImage1D(target: TGLEnum; level, internalformat: TGLint; width: TGLsizei; border: TGLint; format,
                       atype: TGLEnum; pixels: Pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexImage2D(target: TGLEnum; level, internalformat: TGLint; width, height: TGLsizei; border: TGLint;
                       format, atype: TGLEnum; Pixels:Pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexParameterf(target, pname: TGLEnum; param: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexParameterfv(target, pname: TGLEnum; params: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexParameteri(target, pname: TGLEnum; param: TGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexParameteriv(target, pname: TGLEnum; params: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexSubImage1D(target: TGLEnum; level, xoffset: TGLint; width: TGLsizei; format, atype: TGLEnum;
                          pixels: Pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTexSubImage2D(target: TGLEnum; level, xoffset, yoffset: TGLint; width, height: TGLsizei; format,
                          atype: TGLEnum; pixels: Pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTranslated(x, y, z: TGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glTranslatef(x, y, z: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;

procedure glVertex2d(x, y: TGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glVertex2dv(v: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glVertex2f(x, y: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glVertex2fv(v: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glVertex2i(x, y: TGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glVertex2iv(v: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glVertex2s(x, y: TGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glVertex2sv(v: PGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glVertex3d(x, y, z: TGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glVertex3dv(v: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glVertex3f(x, y, z: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glVertex3fv(v: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glVertex3i(x, y, z: TGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glVertex3iv(v: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glVertex3s(x, y, z: TGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glVertex3sv(v: PGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glVertex4d(x, y, z, w: TGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glVertex4dv(v: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glVertex4f(x, y, z, w: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glVertex4fv(v: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glVertex4i(x, y, z, w: TGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glVertex4iv(v: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glVertex4s(x, y, z, w: TGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glVertex4sv(v: PGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glVertexPointer(size: TGLint; atype: TGLEnum; stride: TGLsizei; data: pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;
procedure glViewport(x, y: TGLint; width, height: TGLsizei); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external opengl32;

// GL utility functions and procedures
function  gluErrorString(errCode: TGLEnum): PChar; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
function  gluGetString(name: TGLEnum): PChar; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
procedure gluOrtho2D(left, right, bottom, top: TGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
procedure gluPerspective(fovy, aspect, zNear, zFar: TGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
procedure gluPickMatrix(x, y, width, height: TGLdouble; const viewport: TVector4i); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
procedure gluLookAt(eyex, eyey, eyez, centerx, centery, centerz, upx, upy, upz: TGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
function  gluProject(objx, objy, objz: TGLdouble; const modelMatrix: TMatrix4d; const projMatrix: TMatrix4d; const viewport: TVector4i;
                     winx, winy, winz: PGLdouble): TGLint; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
function  gluUnProject(winx, winy, winz: TGLdouble; const modelMatrix: TMatrix4d; const projMatrix: TMatrix4d; const viewport: TVector4i;
                       objx, objy, objz: PGLdouble): TGLint; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
function  gluScaleImage(format: TGLEnum; widthin, heightin: TGLint; typein: TGLEnum; datain: Pointer; widthout,
                        heightout: TGLint; typeout: TGLEnum; dataout: Pointer): TGLint; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
function  gluBuild1DMipmaps(target: TGLEnum; components, width: TGLint; format, atype: TGLEnum;
                            data: Pointer): TGLint; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
function  gluBuild2DMipmaps(target: TGLEnum; components, width, height: TGLint; format, atype: TGLEnum;
                            data: Pointer): TGLint; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
function  gluNewQuadric: PGLUquadric; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
procedure gluDeleteQuadric(state: PGLUquadric); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
procedure gluQuadricNormals(quadObject: PGLUquadric; normals: TGLEnum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
procedure gluQuadricTexture(quadObject: PGLUquadric; textureCoords: TGLboolean); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
procedure gluQuadricOrientation(quadObject: PGLUquadric; orientation: TGLEnum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
procedure gluQuadricDrawStyle(quadObject: PGLUquadric; drawStyle: TGLEnum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
procedure gluCylinder(quadObject: PGLUquadric; baseRadius, topRadius, height: TGLdouble; slices,
                      stacks: TGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
procedure gluDisk(quadObject: PGLUquadric; innerRadius, outerRadius: TGLdouble; slices, loops: TGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
procedure gluPartialDisk(quadObject: PGLUquadric; innerRadius, outerRadius: TGLdouble; slices, loops: TGLint;
                         startAngle, sweepAngle: TGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
procedure gluSphere(quadObject: PGLUquadric; radius: TGLdouble; slices, stacks: TGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
procedure gluQuadricCallback(quadObject: PGLUquadric; which: TGLEnum; fn: TGLUQuadricErrorProc); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
function  gluNewTess: PGLUtesselator; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
procedure gluDeleteTess(tess: PGLUtesselator); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
procedure gluTessBeginPolygon(tess: PGLUtesselator; polygon_data: Pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
procedure gluTessBeginContour(tess: PGLUtesselator); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
procedure gluTessVertex(tess: PGLUtesselator; const coords: TVector3d; data: Pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
procedure gluTessEndContour(tess: PGLUtesselator); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
procedure gluTessEndPolygon(tess: PGLUtesselator); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
procedure gluTessProperty(tess: PGLUtesselator; which: TGLEnum; value: TGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
procedure gluTessNormal(tess: PGLUtesselator; x, y, z: TGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
procedure gluTessCallback(tess: PGLUtesselator; which: TGLEnum; fn: Pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
procedure gluGetTessProperty(tess: PGLUtesselator; which: TGLEnum; value: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
function  gluNewNurbsRenderer: PGLUnurbs; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
procedure gluDeleteNurbsRenderer(nobj: PGLUnurbs); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
procedure gluBeginSurface(nobj: PGLUnurbs); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
procedure gluBeginCurve(nobj: PGLUnurbs); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
procedure gluEndCurve(nobj: PGLUnurbs); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
procedure gluEndSurface(nobj: PGLUnurbs); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
procedure gluBeginTrim(nobj: PGLUnurbs); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
procedure gluEndTrim(nobj: PGLUnurbs); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
procedure gluPwlCurve(nobj: PGLUnurbs; count: TGLint; points: PGLfloat; stride: TGLint; atype: TGLEnum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
procedure gluNurbsCurve(nobj: PGLUnurbs; nknots: TGLint; knot: PGLfloat; stride: TGLint; ctlarray: PGLfloat; order: TGLint; atype: TGLEnum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
procedure gluNurbsSurface(nobj: PGLUnurbs; sknot_count: TGLint; sknot: PGLfloat; tknot_count: TGLint; tknot: PGLfloat; s_stride, t_stride: TGLint; ctlarray: PGLfloat; sorder, torder: TGLint; atype: TGLEnum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
procedure gluLoadSamplingMatrices(nobj: PGLUnurbs; const modelMatrix: TMatrix4f; const projMatrix: TMatrix4f; const viewport: TVector4i); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
procedure gluNurbsProperty(nobj: PGLUnurbs; aproperty: TGLEnum; value: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
procedure gluGetNurbsProperty(nobj: PGLUnurbs; aproperty: TGLEnum; value: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
procedure gluNurbsCallback(nobj: PGLUnurbs; which: TGLEnum; fn: TGLUNurbsErrorProc); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
procedure gluBeginPolygon(tess: PGLUtesselator); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
procedure gluNextContour(tess: PGLUtesselator; atype: TGLEnum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
procedure gluEndPolygon(tess: PGLUtesselator); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif} external glu32;
//############################################################################//
// window support functions
{$ifdef MSWINDOWS}
 function wglGetProcAddress(ProcName: PChar): Pointer; stdcall; external opengl32;
 function wglCopyContext(p1: HGLRC; p2: HGLRC; p3: Cardinal): BOOL; stdcall; external opengl32;
 function wglCreateContext(DC: HDC): HGLRC; stdcall; external opengl32;
 function wglCreateLayerContext(p1: HDC; p2: Integer): HGLRC; stdcall; external opengl32;
 function wglDeleteContext(p1: HGLRC): BOOL; stdcall; external opengl32;
 function wglDescribeLayerPlane(p1: HDC; p2, p3: Integer; p4: Cardinal; var p5: TLayerPlaneDescriptor): BOOL; stdcall; external opengl32;
 function wglGetCurrentContext: HGLRC; stdcall; external opengl32;
 function wglGetCurrentDC: HDC; stdcall; external opengl32;
 function wglGetLayerPaletteEntries(p1: HDC; p2, p3, p4: Integer; var pcr): Integer; stdcall; external opengl32;
 function wglMakeCurrent(DC: HDC; p2: HGLRC): BOOL; stdcall; external opengl32;
 function wglRealizeLayerPalette(p1: HDC; p2: Integer; p3: BOOL): BOOL; stdcall; external opengl32;
 function wglSetLayerPaletteEntries(p1: HDC; p2, p3, p4: Integer; var pcr): Integer; stdcall; external opengl32;
 function wglShareLists(p1, p2: HGLRC): BOOL; stdcall; external opengl32;
 function wglSwapLayerBuffers(p1: HDC; p2: Cardinal): BOOL; stdcall; external opengl32;
 function wglSwapMultipleBuffers(p1: UINT; const p2: PWGLSwap): DWORD; stdcall; external opengl32;
 function wglUseFontBitmapsA(DC: HDC; p2, p3, p4: DWORD): BOOL; stdcall; external opengl32;
 function wglUseFontOutlinesA (p1: HDC; p2, p3, p4: DWORD; p5, p6: Single; p7: Integer; p8: PGlyphMetricsFloat): BOOL; stdcall; external opengl32;
 function wglUseFontBitmapsW(DC: HDC; p2, p3, p4: DWORD): BOOL; stdcall; external opengl32;
 function wglUseFontOutlinesW (p1: HDC; p2, p3, p4: DWORD; p5, p6: Single; p7: Integer; p8: PGlyphMetricsFloat): BOOL; stdcall; external opengl32;
 function wglUseFontBitmaps(DC: HDC; p2, p3, p4: DWORD): BOOL; stdcall; external opengl32 name 'wglUseFontBitmapsA';
 function wglUseFontOutlines(p1: HDC; p2, p3, p4: DWORD; p5, p6: Single; p7: Integer; p8: PGlyphMetricsFloat): BOOL; stdcall; external opengl32 name 'wglUseFontOutlinesA';
{$endif}
//############################################################################//
// Linux support functions
{$ifdef LINUX}
 function glXChooseVisual(dpy: PDisplay; screen: TGLint; attribList: PGLint): PXVisualInfo; cdecl; external opengl32;
 function glXCreateContext(dpy: PDisplay; vis: PXVisualInfo; shareList: GLXContext; direct: TGLboolean): GLXContext; cdecl; external opengl32;
 procedure glXDestroyContext(dpy: PDisplay; ctx: GLXContext); cdecl; external opengl32;
 function glXMakeCurrent(dpy: PDisplay; drawable: GLXDrawable; ctx: GLXContext): TGLboolean; cdecl; external opengl32;
 procedure glXCopyContext(dpy: PDisplay; src: GLXContext; dst: GLXContext; mask: TGLuint); cdecl; external opengl32;
 procedure glXSwapBuffers(dpy: PDisplay; drawable: GLXDrawable); cdecl; external opengl32;
 function glXCreateGLXPixmap(dpy: PDisplay; visual: PXVisualInfo; pixmap: Pixmap): GLXPixmap; cdecl; external opengl32;
 procedure glXDestroyGLXPixmap(dpy: PDisplay; pixmap: GLXPixmap); cdecl; external opengl32;
 function glXQueryExtension(dpy: PDisplay; errorb: PGLInt; event: PGLInt): TGLboolean; cdecl; external opengl32;
 function glXQueryVersion(dpy: PDisplay; maj: PGLInt; min: PGLINT): TGLboolean; cdecl; external opengl32;
 function glXIsDirect(dpy: PDisplay; ctx: GLXContext): TGLboolean; cdecl; external opengl32;
 function glXGetConfig(dpy: PDisplay; visual: PXVisualInfo; attrib: TGLInt; value: PGLInt): TGLInt; cdecl; external opengl32;
 function glXGetCurrentContext: GLXContext; cdecl; external opengl32;
 function glXGetCurrentDrawable: GLXDrawable; cdecl; external opengl32;
 procedure glXWaitGL; cdecl; external opengl32;
 procedure glXWaitX; cdecl; external opengl32;
 procedure glXUseXFont(font: Font; first: TGLInt; count: TGLInt; list: TGLint); cdecl; external opengl32;

 // GLX 1.1 and later
 function glXQueryExtensionsString(dpy: PDisplay; screen: TGLInt): PChar; cdecl; external opengl32;
 function glXQueryServerString(dpy: PDisplay; screen: TGLInt; name: TGLInt): PChar; cdecl; external opengl32;
 function glXGetClientString(dpy: PDisplay; name: TGLInt): PChar; cdecl; external opengl32;

 // GLX 1.2 and later
 function glXGetCurrentDisplay: PDisplay; cdecl; external opengl32;

 // GLX 1.3 and later
 function glXChooseFBConfig(dpy: PDisplay; screen: TGLInt; attribList: PGLInt; nitems: PGLInt): GLXFBConfig; cdecl; external opengl32;
 function glXGetFBConfigAttrib(dpy: PDisplay; config: GLXFBConfig; attribute: TGLInt; value: PGLInt): TGLInt; cdecl; external opengl32;
 function glXGetFBConfigs(dpy: PDisplay; screen: TGLInt; nelements: PGLInt): GLXFBConfig; cdecl; external opengl32;
 function glXGetVisualFromFBConfig(dpy: PDisplay; config: GLXFBConfig): PXVisualInfo; cdecl; external opengl32;
 function glXCreateWindow(dpy: PDisplay; config: GLXFBConfig; win: Window; const attribList: PGLInt): GLXWindow; cdecl; external opengl32;
 procedure glXDestroyWindow(dpy: PDisplay; window: GLXWindow); cdecl; external opengl32;
 function glXCreatePixmap(dpy: PDisplay; config: GLXFBConfig; pixmap: Pixmap; attribList: PGLInt): GLXPixmap; cdecl; external opengl32;
 procedure glXDestroyPixmap(dpy: PDisplay; pixmap: GLXPixmap); cdecl; external opengl32;
 function glXCreatePbuffer(dpy: PDisplay; config: GLXFBConfig; attribList: PGLInt): GLXPBuffer; cdecl; external opengl32;
 procedure glXDestroyPbuffer(dpy: PDisplay; pbuf: GLXPBuffer); cdecl; external opengl32;
 procedure glXQueryDrawable(dpy: PDisplay; draw: GLXDrawable; attribute: TGLInt; value: PGLuint); cdecl; external opengl32;
 function glXCreateNewContext(dpy: PDisplay; config: GLXFBConfig; renderType: TGLInt; shareList: GLXContext; direct: TGLboolean): GLXContext; cdecl; external opengl32;
 function glXMakeContextCurrent(dpy: PDisplay; draw: GLXDrawable; read: GLXDrawable; ctx: GLXContext): TGLboolean; cdecl; external opengl32;
 function glXGetCurrentReadDrawable: GLXDrawable; cdecl; external opengl32;
 function glXQueryContext(dpy: PDisplay; ctx: GLXContext; attribute: TGLInt; value: PGLInt): TGLInt; cdecl; external opengl32;
 procedure glXSelectEvent(dpy: PDisplay; drawable: GLXDrawable; mask: TGLsizei); cdecl; external opengl32;
 procedure glXGetSelectedEvent(dpy: PDisplay; drawable: GLXDrawable; mask: TGLsizei); cdecl; external opengl32;
 function glXGetVideoSyncSGI(count: PGLuint): TGLInt; cdecl; external opengl32;
 function glXWaitVideoSyncSGI(divisor: TGLInt; remainder: TGLInt; count: PGLuint): TGLInt; cdecl; external opengl32;
 procedure glXFreeContextEXT(dpy: PDisplay; context: GLXContext); cdecl; external opengl32;
 function glXGetContextIDEXT(const context: GLXContext): GLXContextID; cdecl; external opengl32;
 function glXGetCurrentDisplayEXT: PDisplay; cdecl; external opengl32;
 function glXImportContextEXT(dpy: PDisplay; contextID: GLXContextID): GLXContext; cdecl; external opengl32;
 function glXQueryContextInfoEXT(dpy: PDisplay; context: GLXContext; attribute: TGLInt; value: PGLInt): TGLInt; cdecl; external opengl32;
 procedure glXCopySubBufferMESA(dpy: PDisplay; drawable: GLXDrawable; x: TGLInt; y: TGLInt; width: TGLInt; height: TGLInt); cdecl; external opengl32;
 function glXCreateGLXPixmapMESA(dpy: PDisplay; visual: PXVisualInfo; pixmap: Pixmap; cmap: Colormap): GLXPixmap; cdecl; external opengl32;
 function glXReleaseBuffersMESA(dpy: PDisplay; d: GLXDrawable): TGLboolean; cdecl; external opengl32;
 function glXSet3DfxModeMESA(mode: TGLint): TGLboolean; cdecl; external opengl32;
{$endif}
//############################################################################//
//############################################################################//
//############################################################################//
{$ifdef MULTITHREADOPENGL}threadvar{$else}var{$endif}
// GL 1.2
glDrawRangeElements: procedure(mode: TGLEnum; Astart, Aend: TGLuint; count: TGLsizei; Atype: TGLEnum;indices: Pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glTexImage3D: procedure(target: TGLEnum; level: TGLint; internalformat: TGLEnum; width, height, depth: TGLsizei;border: TGLint; format: TGLEnum; Atype: TGLEnum; pixels: Pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}

// GL 1.2 ARB imaging
glBlendColor: procedure(red, green, blue, alpha: TGLclampf); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glBlendEquation: procedure(mode: TGLEnum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glColorSubTable: procedure(target: TGLEnum; start, count: TGLsizei; format, Atype: TGLEnum; data: Pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glCopyColorSubTable: procedure(target: TGLEnum; start: TGLsizei; x, y: TGLint; width: TGLsizei); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glColorTable: procedure(target, internalformat: TGLEnum; width: TGLsizei; format, Atype: TGLEnum;table: Pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glCopyColorTable: procedure(target, internalformat: TGLEnum; x, y: TGLint; width: TGLsizei); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glColorTableParameteriv: procedure(target, pname: TGLEnum; params: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glColorTableParameterfv: procedure(target, pname: TGLEnum; params: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetColorTable: procedure(target, format, Atype: TGLEnum; table: Pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetColorTableParameteriv: procedure(target, pname: TGLEnum; params: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetColorTableParameterfv: procedure(target, pname: TGLEnum; params: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glConvolutionFilter1D: procedure(target, internalformat: TGLEnum; width: TGLsizei; format, Atype: TGLEnum;image: Pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glConvolutionFilter2D: procedure(target, internalformat: TGLEnum; width, height: TGLsizei; format, Atype: TGLEnum;image: Pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glCopyConvolutionFilter1D: procedure(target, internalformat: TGLEnum; x, y: TGLint; width: TGLsizei); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glCopyConvolutionFilter2D: procedure(target, internalformat: TGLEnum; x, y: TGLint; width, height: TGLsizei); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetConvolutionFilter: procedure(target, internalformat, Atype: TGLEnum; image: Pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glSeparableFilter2D: procedure(target, internalformat: TGLEnum; width, height: TGLsizei; format, Atype: TGLEnum; row,column: Pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetSeparableFilter: procedure(target, format, Atype: TGLEnum; row, column, span: Pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glConvolutionParameteri: procedure(target, pname: TGLEnum; param: TGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glConvolutionParameteriv: procedure(target, pname: TGLEnum; params: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glConvolutionParameterf: procedure(target, pname: TGLEnum; param: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glConvolutionParameterfv: procedure(target, pname: TGLEnum; params: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetConvolutionParameteriv: procedure(target, pname: TGLEnum; params: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetConvolutionParameterfv: procedure(target, pname: TGLEnum; params: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glHistogram: procedure(target: TGLEnum; width: TGLsizei; internalformat: TGLEnum; sink: TGLboolean); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glResetHistogram: procedure(target: TGLEnum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetHistogram: procedure(target: TGLEnum; reset: TGLboolean; format, Atype: TGLEnum; values: Pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetHistogramParameteriv: procedure(target, pname: TGLEnum; params: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetHistogramParameterfv: procedure(target, pname: TGLEnum; params: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glMinmax: procedure(target, internalformat: TGLEnum; sink: TGLboolean); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glResetMinmax: procedure(target: TGLEnum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetMinmax: procedure(target: TGLEnum; reset: TGLboolean; format, Atype: TGLEnum; values: Pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetMinmaxParameteriv: procedure(target, pname: TGLEnum; params: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetMinmaxParameterfv: procedure(target, pname: TGLEnum; params: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}

{$ifdef MSWINDOWS}
 // ARB wgl extensions
 wglGetExtensionsStringARB: function(DC: HDC): PChar; stdcall;
 wglGetPixelFormatAttribivARB: function(DC: HDC; iPixelFormat, iLayerPlane: Integer; nAttributes: TGLenum;const piAttributes: PGLint; piValues : PGLint) : BOOL; stdcall;
 wglGetPixelFormatAttribfvARB: function(DC: HDC; iPixelFormat, iLayerPlane: Integer; nAttributes: TGLenum;const piAttributes: PGLint; piValues: PGLFloat) : BOOL; stdcall;
 wglChoosePixelFormatARB: function(DC: HDC; const piAttribIList: PGLint; const pfAttribFList: PGLFloat;nMaxFormats: GLint; piFormats: PGLint; nNumFormats: PGLenum) : BOOL; stdcall;
 wglCreatePbufferARB: function(DC: HDC; iPixelFormat: Integer; iWidth, iHeight : Integer;const piAttribList: PGLint) : HPBUFFERARB; stdcall;
 wglGetPbufferDCARB: function(hPbuffer: HPBUFFERARB) : HDC; stdcall;
 wglReleasePbufferDCARB: function(hPbuffer: HPBUFFERARB; DC: HDC) : Integer; stdcall;
 wglDestroyPbufferARB: function(hPbuffer: HPBUFFERARB): BOOL; stdcall;
 wglQueryPbufferARB: function(hPbuffer: HPBUFFERARB; iAttribute : Integer;piValue: PGLint) : BOOL; stdcall;

 wglCreateBufferRegionARB: function(DC: HDC; iLayerPlane: Integer; uType: TGLenum) : Integer; stdcall;
 wglDeleteBufferRegionARB: procedure(hRegion: Integer); stdcall;
 wglSaveBufferRegionARB: function(hRegion: Integer; x, y, width, height: Integer): BOOL; stdcall;
 wglRestoreBufferRegionARB: function(hRegion: Integer; x, y, width, height: Integer;xSrc, ySrc: Integer): BOOL; stdcall;

 // non-ARB wgl extensions
 wglSwapIntervalEXT: function(interval : Integer) : BOOL; stdcall;
 wglGetSwapIntervalEXT: function : Integer; stdcall;
{$endif}

// ARB_multitexture
glMultiTexCoord1dARB: procedure(target: TGLenum; s: TGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glMultiTexCoord1dVARB: procedure(target: TGLenum; v: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glMultiTexCoord1fARB: procedure(target: TGLenum; s: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glMultiTexCoord1fVARB: procedure(target: TGLenum; v: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glMultiTexCoord1iARB: procedure(target: TGLenum; s: TGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glMultiTexCoord1iVARB: procedure(target: TGLenum; v: PGLInt); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glMultiTexCoord1sARB: procedure(target: TGLenum; s: TGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glMultiTexCoord1sVARB: procedure(target: TGLenum; v: PGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glMultiTexCoord2dARB: procedure(target: TGLenum; s, t: TGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glMultiTexCoord2dvARB: procedure(target: TGLenum; v: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glMultiTexCoord2fARB: procedure(target: TGLenum; s, t: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glMultiTexCoord2fvARB: procedure(target: TGLenum; v: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glMultiTexCoord2iARB: procedure(target: TGLenum; s, t: TGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glMultiTexCoord2ivARB: procedure(target: TGLenum; v: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glMultiTexCoord2sARB: procedure(target: TGLenum; s, t: TGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glMultiTexCoord2svARB: procedure(target: TGLenum; v: PGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glMultiTexCoord3dARB: procedure(target: TGLenum; s, t, r: TGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glMultiTexCoord3dvARB: procedure(target: TGLenum; v: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glMultiTexCoord3fARB: procedure(target: TGLenum; s, t, r: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glMultiTexCoord3fvARB: procedure(target: TGLenum; v: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glMultiTexCoord3iARB: procedure(target: TGLenum; s, t, r: TGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glMultiTexCoord3ivARB: procedure(target: TGLenum; v: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glMultiTexCoord3sARB: procedure(target: TGLenum; s, t, r: TGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glMultiTexCoord3svARB: procedure(target: TGLenum; v: PGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glMultiTexCoord4dARB: procedure(target: TGLenum; s, t, r, q: TGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glMultiTexCoord4dvARB: procedure(target: TGLenum; v: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glMultiTexCoord4fARB: procedure(target: TGLenum; s, t, r, q: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glMultiTexCoord4fvARB: procedure(target: TGLenum; v: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glMultiTexCoord4iARB: procedure(target: TGLenum; s, t, r, q: TGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glMultiTexCoord4ivARB: procedure(target: TGLenum; v: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glMultiTexCoord4sARB: procedure(target: TGLenum; s, t, r, q: TGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glMultiTexCoord4svARB: procedure(target: TGLenum; v: PGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glActiveTextureARB: procedure(target: TGLenum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glClientActiveTextureARB: procedure(target: TGLenum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}

// GLU extensions
gluNurbsCallbackDataEXT: procedure(nurb: PGLUnurbs; userData: Pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
gluNewNurbsTessellatorEXT: function: PGLUnurbs; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
gluDeleteNurbsTessellatorEXT: procedure(nurb: PGLUnurbs); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}

// Extension functions
glAreTexturesResidentEXT: function(n: TGLsizei; textures: PGLuint; residences: PGLBoolean): TGLboolean; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glArrayElementArrayEXT: procedure(mode: TGLEnum; count: TGLsizei; pi: Pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glBeginSceneEXT: procedure; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glBindTextureEXT: procedure(target: TGLEnum; texture: TGLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glColorTableEXT: procedure(target, internalFormat: TGLEnum; width: TGLsizei; format, atype: TGLEnum; data: Pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glColorSubTableExt: procedure(target: TGLEnum; start, count: TGLsizei; format, atype: TGLEnum; data: Pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glCopyTexImage1DEXT: procedure(target: TGLEnum; level: TGLint; internalFormat: TGLEnum; x, y: TGLint; width: TGLsizei; border: TGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glCopyTexSubImage1DEXT: procedure(target: TGLEnum; level, xoffset, x, y: TGLint; width: TGLsizei); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glCopyTexImage2DEXT: procedure(target: TGLEnum; level: TGLint; internalFormat: TGLEnum; x, y: TGLint; width, height: TGLsizei; border: TGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glCopyTexSubImage2DEXT: procedure(target: TGLEnum; level, xoffset, yoffset, x, y: TGLint; width, height: TGLsizei); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glCopyTexSubImage3DEXT: procedure(target: TGLEnum; level, xoffset, yoffset, zoffset, x, y: TGLint; width, height: TGLsizei); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glDeleteTexturesEXT: procedure(n: TGLsizei; textures: PGLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glEndSceneEXT: procedure; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGenTexturesEXT: procedure(n: TGLsizei; textures: PGLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetColorTableEXT: procedure(target, format, atype: TGLEnum; data: Pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetColorTablePameterfvEXT: procedure(target, pname: TGLEnum; params: Pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetColorTablePameterivEXT: procedure(target, pname: TGLEnum; params: Pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glIndexFuncEXT: procedure(func: TGLEnum; ref: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glIndexMaterialEXT: procedure(face: TGLEnum; mode: TGLEnum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glIsTextureEXT: function(texture: TGLuint): TGLboolean; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glPolygonOffsetEXT: procedure(factor, bias: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glPrioritizeTexturesEXT: procedure(n: TGLsizei; textures: PGLuint; priorities: PGLclampf); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glTexSubImage1DEXT: procedure(target: TGLEnum; level, xoffset: TGLint; width: TGLsizei; format, Atype: TGLEnum; pixels: Pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glTexSubImage2DEXT: procedure(target: TGLEnum; level, xoffset, yoffset: TGLint; width, height: TGLsizei; format, Atype: TGLEnum; pixels: Pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glTexSubImage3DEXT: procedure(target: TGLEnum; level, xoffset, yoffset, zoffset: TGLint; width, height, depth: TGLsizei; format, Atype: TGLEnum; pixels: Pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}

// EXT_compiled_vertex_array
glLockArraysEXT: procedure(first: TGLint; count: TGLsizei); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glUnlockArraysEXT: procedure; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}

// EXT_stencil_two_side
glActiveStencilFaceEXT: procedure(face: TGLenum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}

// WIN_swap_hint
glAddSwapHintRectWIN: procedure(x, y: TGLint; width, height: TGLsizei); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}

// GL_ARB_point_parameter
glPointParameterfARB: procedure(pname: TGLenum; param: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glPointParameterfvARB: procedure(pname: TGLenum; params: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}

// GL_ARB_transpose_matrix
glLoadTransposeMatrixfARB: procedure(m: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glLoadTransposeMatrixdARB: procedure(m: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glMultTransposeMatrixfARB: procedure(m: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glMultTransposeMatrixdARB: procedure(m: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}

// GL_ARB_multisample
glSampleCoverageARB: procedure(Value: TGLclampf; invert: TGLboolean); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glSamplePassARB: procedure(pass: TGLenum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}

// GL_ARB_texture_compression
glCompressedTexImage3DARB: procedure(target: TGLenum; level: TGLint; internalformat: TGLenum; Width, Height, depth: TGLsizei; border: TGLint; imageSize: TGLsizei; data: pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glCompressedTexImage2DARB: procedure(target: TGLenum; level: TGLint; internalformat: TGLenum; Width, Height: TGLsizei; border: TGLint; imageSize: TGLsizei; data: pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glCompressedTexImage1DARB: procedure(target: TGLenum; level: TGLint; internalformat: TGLenum; Width: TGLsizei; border: TGLint; imageSize: TGLsizei; data: pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glCompressedTexSubImage3DARB: procedure(target: TGLenum; level: TGLint; xoffset, yoffset, zoffset: TGLint; width, height, depth: TGLsizei; Format: TGLenum; imageSize: TGLsizei; data: pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glCompressedTexSubImage2DARB: procedure(target: TGLenum; level: TGLint; xoffset, yoffset: TGLint; width, height: TGLsizei; Format: TGLenum; imageSize: TGLsizei; data: pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glCompressedTexSubImage1DARB: procedure(target: TGLenum; level: TGLint; xoffset: TGLint; width: TGLsizei; Format: TGLenum; imageSize: TGLsizei; data: pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetCompressedTexImageARB: procedure(target: TGLenum; level: TGLint; img: pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}

// GL_ARB_vertex_program
glVertexAttrib1sARB: procedure(index: GLuint; x: GLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib1fARB: procedure(index: GLuint; x: GLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib1dARB: procedure(index: GLuint; x: GLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib2sARB: procedure(index: GLuint; x: GLshort; y: GLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib2fARB: procedure(index: GLuint; x: GLfloat; y: GLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib2dARB: procedure(index: GLuint; x: GLdouble; y: GLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib3sARB: procedure(index: GLuint; x: GLshort; y: GLshort; z: GLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib3fARB: procedure(index: GLuint; x: GLfloat; y: GLfloat; z: GLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib3dARB: procedure(index: GLuint; x: GLdouble; y: GLdouble; z: GLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib4sARB: procedure(index: GLuint; x: GLshort; y: GLshort; z: GLshort; w: GLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib4fARB: procedure(index: GLuint; x: GLfloat; y: GLfloat; z: GLfloat; w: GLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib4dARB: procedure(index: GLuint; x: GLdouble; y: GLdouble; z: GLdouble; w: GLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib4NubARB: procedure(index: GLuint; x: GLubyte; y: GLubyte; z: GLubyte; w: GLubyte); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib1svARB: procedure(index: GLuint; const v: PGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib1fvARB: procedure(index: GLuint; const v: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib1dvARB: procedure(index: GLuint; const v: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib2svARB: procedure(index: GLuint; const v: PGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib2fvARB: procedure(index: GLuint; const v: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib2dvARB: procedure(index: GLuint; const v: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib3svARB: procedure(index: GLuint; const v: PGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib3fvARB: procedure(index: GLuint; const v: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib3dvARB: procedure(index: GLuint; const v: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib4bvARB: procedure(index: GLuint; const v: PGLbyte); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib4svARB: procedure(index: GLuint; const v: PGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib4ivARB: procedure(index: GLuint; const v: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib4ubvARB: procedure(index: GLuint; const v: PGLubyte); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib4usvARB: procedure(index: GLuint; const v: PGLushort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib4uivARB: procedure(index: GLuint; const v: PGLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib4fvARB: procedure(index: GLuint; const v: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib4dvARB: procedure(index: GLuint; const v: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib4NbvARB: procedure(index: GLuint; const v: PGLbyte); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib4NsvARB: procedure(index: GLuint; const v: PGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib4NivARB: procedure(index: GLuint; const v: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib4NubvARB: procedure(index: GLuint; const v: PGLubyte); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib4NusvARB: procedure(index: GLuint; const v: PGLushort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib4NuivARB: procedure(index: GLuint; const v: PGLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttribPointerARB: procedure(index: GLuint; size: GLint; _type: GLenum; normalized: GLboolean; stride: GLsizei; const _pointer: pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glEnableVertexAttribArrayARB: procedure(index: GLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glDisableVertexAttribArrayARB: procedure(index: GLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glProgramStringARB: procedure(target: GLenum; format: GLenum; len: GLsizei; const _string: pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glBindProgramARB: procedure(target: GLenum; _program: GLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glDeleteProgramsARB: procedure(n: GLsizei; const programs: PGLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGenProgramsARB: procedure(n: GLsizei; programs: PGLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glProgramEnvParameter4dARB: procedure(target: GLenum; index: GLuint; x: GLdouble; y: GLdouble; z: GLdouble; w: GLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glProgramEnvParameter4dvARB: procedure(target: GLenum; index: GLuint; const params: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glProgramEnvParameter4fARB: procedure(target: GLenum; index: GLuint; x: GLfloat; y: GLfloat; z: GLfloat; w: GLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glProgramEnvParameter4fvARB: procedure(target: GLenum; index: GLuint; const params: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glProgramLocalParameter4dARB: procedure(target: GLenum; index: GLuint; x: GLdouble; y: GLdouble; z: GLdouble; w: GLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glProgramLocalParameter4dvARB: procedure(target: GLenum; index: GLuint; const params: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glProgramLocalParameter4fARB: procedure(target: GLenum; index: GLuint; x: GLfloat; y: GLfloat; z: GLfloat; w: GLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glProgramLocalParameter4fvARB: procedure(target: GLenum; index: GLuint; const params: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetProgramEnvParameterdvARB: procedure(target: GLenum; index: GLuint; params: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetProgramEnvParameterfvARB: procedure(target: GLenum; index: GLuint; params: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetProgramLocalParameterdvARB: procedure(target: GLenum; index: GLuint; params: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetProgramLocalParameterfvARB: procedure(target: GLenum; index: GLuint; params: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetProgramivARB: procedure(target: GLenum; pname: GLenum; params: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetProgramStringARB: procedure(target: GLenum; pname: GLenum; _string: pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetVertexAttribdvARB: procedure(index: GLuint; pname: GLenum; params: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetVertexAttribfvARB: procedure(index: GLuint; pname: GLenum; params: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetVertexAttribivARB: procedure(index: GLuint; pname: GLenum; params: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetVertexAttribPointervARB: procedure(index: GLuint; pname: GLenum; _pointer: pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glIsProgramARB: function(_program: GLuint): GLboolean; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}

// GL_ARB_vertex_buffer_object
glBindBufferARB: procedure(target: GLenum; buffer: GLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glDeleteBuffersARB: procedure(n: GLsizei; const buffers: PGLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGenBuffersARB: procedure(n: GLsizei; buffers: PGLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glIsBufferARB: function(buffer: GLuint): GLboolean; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glBufferDataARB: procedure(target: GLenum; size: GLsizei; const data: Pointer; usage: GLenum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glBufferSubDataARB: procedure(target: GLenum; offset: GLuint; size: GLsizei; const data: Pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetBufferSubDataARB: procedure(target: GLenum; offset: GLuint; size: GLsizei; data: Pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glMapBufferARB: function(target: GLenum; access: GLenum): Pointer; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glUnmapBufferARB: function(target: GLenum): GLboolean; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetBufferParameterivARB: procedure(target: GLenum; pname: GLenum; params: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetBufferPointervARB: procedure(target: GLenum; pname: GLenum; params: Pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}

// GL_ARB_shader_objects
glDeleteObjectARB: procedure(obj: GLhandleARB); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetHandleARB: function(pname: GLenum): GLhandleARB; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glDetachObjectARB: procedure(containerObj: GLhandleARB; attachedObj: GLhandleARB); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glCreateShaderObjectARB: function(shaderType: GLenum): GLhandleARB; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glShaderSourceARB: procedure(shaderObj: GLhandleARB; count: GLsizei; const _string: PGLPCharArray; const length: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glCompileShaderARB: procedure(shaderObj: GLhandleARB); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glCreateProgramObjectARB: function(): GLhandleARB; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glAttachObjectARB: procedure(containerObj: GLhandleARB; obj: GLhandleARB); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glLinkProgramARB: procedure(programObj: GLhandleARB); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glUseProgramObjectARB: procedure(programObj: GLhandleARB); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glValidateProgramARB: procedure(programObj: GLhandleARB); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glUniform1fARB: procedure(location: GLint; v0: GLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glUniform2fARB: procedure(location: GLint; v0: GLfloat; v1: GLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glUniform3fARB: procedure(location: GLint; v0: GLfloat; v1: GLfloat; v2: GLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glUniform4fARB: procedure(location: GLint; v0: GLfloat; v1: GLfloat; v2: GLfloat; v3: GLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glUniform1iARB: procedure(location: GLint; v0: GLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glUniform2iARB: procedure(location: GLint; v0: GLint; v1: GLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glUniform3iARB: procedure(location: GLint; v0: GLint; v1: GLint; v2: GLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glUniform4iARB: procedure(location: GLint; v0: GLint; v1: GLint; v2: GLint; v3: GLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glUniform1fvARB: procedure(location: GLint; count: GLsizei; value: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glUniform2fvARB: procedure(location: GLint; count: GLsizei; value: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glUniform3fvARB: procedure(location: GLint; count: GLsizei; value: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glUniform4fvARB: procedure(location: GLint; count: GLsizei; value: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glUniform1ivARB: procedure(location: GLint; count: GLsizei; value: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glUniform2ivARB: procedure(location: GLint; count: GLsizei; value: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glUniform3ivARB: procedure(location: GLint; count: GLsizei; value: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glUniform4ivARB: procedure(location: GLint; count: GLsizei; value: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glUniformMatrix2fvARB: procedure(location: GLint; count: GLsizei; transpose: GLboolean; value: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glUniformMatrix3fvARB: procedure(location: GLint; count: GLsizei; transpose: GLboolean; value: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glUniformMatrix4fvARB: procedure(location: GLint; count: GLsizei; transpose: GLboolean; value: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetObjectParameterfvARB: procedure(obj: GLhandleARB; pname: GLenum; params: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetObjectParameterivARB: procedure(obj: GLhandleARB; pname: GLenum; params: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetInfoLogARB: procedure(obj: GLhandleARB; maxLength: GLsizei; length: PGLsizei; infoLog: PChar); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetAttachedObjectsARB: procedure(containerObj: GLhandleARB; maxCount: GLsizei; count: PGLsizei; obj: PGLhandleARB); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetUniformLocationARB: function(programObj: GLhandleARB; const name: PChar): GLint; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetActiveUniformARB: procedure(programObj: GLhandleARB; index: GLuint; maxLength: GLsizei; length: PGLsizei; size: PGLint; _type: PGLenum; name: PChar); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetUniformfvARB: procedure(programObj: GLhandleARB; location: GLint; params: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetUniformivARB: procedure(programObj: GLhandleARB; location: GLint; params: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetShaderSourceARB: procedure(obj: GLhandleARB; maxLength: GLsizei; length: PGLsizei; source: PChar); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
   
// GL_ARB_vertex_shader
glBindAttribLocationARB: procedure(programObj: GLhandleARB; index: GLuint; const name: PChar); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetActiveAttribARB: procedure(programObj: GLhandleARB; index: GLuint; maxLength: GLsizei; length: PGLsizei; size: PGLint; _type: PGLenum; name: PChar); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetAttribLocationARB: function(programObj: GLhandleARB; const name: PChar): GLint; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}

// GL_EXT_blend_color
glBlendColorEXT: procedure(red, green, blue: TGLclampf; alpha: TGLclampf); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}

// GL_EXT_texture3D
glTexImage3DEXT: procedure(target: TGLenum; level: TGLint; internalformat: TGLenum; width, height, depth: TGLsizei; border: TGLint; Format, AType: TGLenum; pixels: Pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}

// GL_SGIS_multisample
glSampleMaskSGIS: procedure(Value: TGLclampf; invert: TGLboolean); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glSamplePatternSGIS: procedure(pattern: TGLenum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}

// GL_EXT_blend_minmax
glBlendEquationEXT: procedure(mode: TGLenum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}

// GL_EXT_paletted_texture
glGetColorTableParameterivEXT: procedure(target, pname: TGLenum; params: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetColorTableParameterfvEXT: procedure(target, pname: TGLenum; params: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}

// GL_EXT_draw_range_elements
glDrawRangeElementsEXT: procedure(mode: TGLenum; start, Aend: TGLuint; Count: TGLsizei; Atype: TGLenum; indices: Pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}

// GL_EXT_secondary_color
glSecondaryColor3bEXT: procedure(red, green, blue: TGLbyte); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glSecondaryColor3bvEXT: procedure(v: PGLbyte); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glSecondaryColor3dEXT: procedure(red, green, blue: TGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glSecondaryColor3dvEXT: procedure(v: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glSecondaryColor3fEXT: procedure(red, green, blue: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glSecondaryColor3fvEXT: procedure(v: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glSecondaryColor3iEXT: procedure(red, green, blue: TGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glSecondaryColor3ivEXT: procedure(v: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}

glSecondaryColor3sEXT: procedure(red, green, blue: TGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glSecondaryColor3svEXT: procedure(v: PGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glSecondaryColor3ubEXT: procedure(red, green, blue: TGLubyte); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glSecondaryColor3ubvEXT: procedure(v: PGLubyte); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glSecondaryColor3uiEXT: procedure(red, green, blue: TGLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glSecondaryColor3uivEXT: procedure(v: PGLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glSecondaryColor3usEXT: procedure(red, green, blue: TGLushort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glSecondaryColor3usvEXT: procedure(v: PGLushort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glSecondaryColorPointerEXT: procedure(Size: TGLint; Atype: TGLenum; stride: TGLsizei; p: pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}

// GL_EXT_multi_draw_arrays
glMultiDrawArraysEXT: procedure(mode: TGLenum; First: PGLint; Count: PGLsizei; primcount: TGLsizei); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glMultiDrawElementsEXT: procedure(mode: TGLenum; Count: PGLsizei; AType: TGLenum; var indices; primcount: TGLsizei); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}

// GL_EXT_fog_coord
glFogCoordfEXT: procedure(coord: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glFogCoordfvEXT: procedure(coord: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glFogCoorddEXT: procedure(coord: TGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glFogCoorddvEXT: procedure(coord: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glFogCoordPointerEXT: procedure(AType: TGLenum; stride: TGLsizei; p: Pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}

// GL_EXT_blend_func_separate
glBlendFuncSeparateEXT: procedure(sfactorRGB, dfactorRGB, sfactorAlpha, dfactorAlpha: TGLenum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}

// GL_NV_vertex_array_range
glFlushVertexArrayRangeNV: procedure; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexArrayRangeNV: procedure(Size: TGLsizei; p: pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
wglAllocateMemoryNV: function(size: TGLsizei; readFrequency, writeFrequency, priority: Single): Pointer; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
wglFreeMemoryNV: procedure(ptr: Pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}

// GL_NV_register_combiners
glCombinerParameterfvNV: procedure(pname: TGLenum; params: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glCombinerParameterfNV: procedure(pname: TGLenum; param: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glCombinerParameterivNV: procedure(pname: TGLenum; params: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glCombinerParameteriNV: procedure(pname: TGLenum; param: TGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glCombinerInputNV: procedure(stage, portion, variable, input, mapping, componentUsage: TGLenum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glCombinerOutputNV: procedure(stage, portion, abOutput, cdOutput, sumOutput, scale, bias: TGLenum; abDotProduct, cdDotProduct, muxSum: TGLboolean); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glFinalCombinerInputNV: procedure(variable, input, mapping, componentUsage: TGLenum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetCombinerInputParameterfvNV: procedure(stage, portion, variable, pname: TGLenum; params: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetCombinerInputParameterivNV: procedure(stage, portion, variable, pname: TGLenum; params: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetCombinerOutputParameterfvNV: procedure(stage, portion, pname: TGLenum; params: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetCombinerOutputParameterivNV: procedure(stage, portion, pname: TGLenum; params: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetFinalCombinerInputParameterfvNV: procedure(variable, pname: TGLenum; params: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetFinalCombinerInputParameterivNV: procedure(variable, pname: TGLenum; params: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}

// GL_NV_fence
glGenFencesNV: procedure(n: TGLsizei; fences: PGLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glDeleteFencesNV: procedure(n: TGLsizei; fences: PGLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glSetFenceNV: procedure(fence: TGLuint; condition: TGLenum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glTestFenceNV: function(fence: TGLuint): TGLboolean; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glFinishFenceNV: procedure(fence: TGLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glIsFenceNV: function(fence: TGLuint): TGLboolean; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetFenceivNV: procedure(fence: TGLuint; pname: TGLenum; params: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}

// GL_NV_occlusion_query
glGenOcclusionQueriesNV: procedure(n: TGLsizei; ids: PGLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glDeleteOcclusionQueriesNV: procedure(n: TGLsizei; const ids: PGLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glIsOcclusionQueryNV: function(id: TGLuint): TGLboolean; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glBeginOcclusionQueryNV: procedure(id: TGLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glEndOcclusionQueryNV: procedure; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetOcclusionQueryivNV: procedure(id: TGLuint; pname: TGLenum; params: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetOcclusionQueryuivNV: procedure(id: TGLuint; pname: TGLenum; params: PGLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}

// GL_MESA_resize_buffers
glResizeBuffersMESA: procedure; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}

// GL_3DFX_tbuffer
glTbufferMask3DFX: procedure(mask: TGLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}

// GL_EXT_multisample
glSampleMaskEXT: procedure(Value: TGLclampf; invert: TGLboolean); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glSamplePatternEXT: procedure(pattern: TGLenum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}

// GL_SGIS_texture_color_mask
glTextureColorMaskSGIS: procedure(red, green, blue, alpha: TGLboolean); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}

// GL_NV_vertex_program
glAreProgramsResidentNV: procedure(n: TGLSizei; programs: PGLuint; residences: PGLboolean); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glBindProgramNV: procedure(target: TGLenum; id: TGLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glDeleteProgramsNV: procedure(n: TGLSizei; programs: PGLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glExecuteProgramNV: procedure(target: TGLenum; id: TGLuint; params: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGenProgramsNV: procedure(n: TGLSizei; programs: PGLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetProgramParameterdvNV: procedure (target: TGLenum; index: TGLuint; pname: TGLenum; params: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetProgramParameterfvNV: procedure (target: TGLenum; index: TGLuint; pname: TGLenum; params: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetProgramivNV: procedure (id: TGLuint; pname: TGLenum; params: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetProgramStringNV: procedure (id: TGLuint; pname: TGLenum; programIdx: PGLubyte); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetTrackMatrixivNV: procedure (target: TGLenum; address: TGLuint; pname: TGLenum; params: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetVertexAttribdvNV: procedure (index: TGLuint; pname: TGLenum; params: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetVertexAttribfvNV: procedure (index: TGLuint; pname: TGLenum; params: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetVertexAttribivNV: procedure (index: TGLuint; pname: TGLenum; params: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetVertexAttribPointervNV: procedure (index: TGLuint; pname: TGLenum; pointer: PGLPointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glIsProgramNV: function (id: TGLuint): TGLboolean; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glLoadProgramNV: procedure (target: TGLenum; id: TGLuint; len: TGLSizei; programIdx: PGLubyte); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glProgramParameter4dNV: procedure (target: TGLenum; index: TGLuint; x, y, z, w: TGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glProgramParameter4dvNV: procedure (target: TGLenum; index: TGLuint; v: PGLdouble ); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glProgramParameter4fNV: procedure (target: TGLenum; index: TGLuint; x, y, z, w: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glProgramParameter4fvNV: procedure (target: TGLenum; index: TGLuint; v: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glProgramParameters4dvNV: procedure (target: TGLenum; index: TGLuint; count: TGLSizei; v: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glProgramParameters4fvNV: procedure (target: TGLenum; index: TGLuint; count: TGLSizei; v: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glRequestResidentProgramsNV: procedure (n: TGLSizei; programs: PGLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glTrackMatrixNV: procedure (target: TGLenum; address: TGLuint; matrix: TGLenum; transform: TGLenum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttribPointerNV: procedure (index: TGLuint; fsize: TGLint; vertextype: TGLenum; stride: TGLSizei; pointer: Pointer); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib1dNV: procedure (index: TGLuint; x: TGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib1dvNV: procedure (index: TGLuint; v: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib1fNV: procedure (index: TGLuint; x: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib1fvNV: procedure (index: TGLuint; v: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib1sNV: procedure (index: TGLuint; x: TGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib1svNV: procedure (index: TGLuint; v: PGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib2dNV: procedure (index: TGLuint; x: TGLdouble; y: TGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib2dvNV: procedure (index: TGLuint; v: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib2fNV: procedure (index: TGLuint; x: TGLfloat; y: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib2fvNV: procedure (index: TGLuint; v: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib2sNV: procedure (index: TGLuint; x: TGLshort; y: TGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib2svNV: procedure (index: TGLuint; v: PGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib3dNV: procedure (index: TGLuint; x: TGLdouble; y: TGLdouble; z: TGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib3dvNV: procedure (index: TGLuint; v: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib3fNV: procedure (index: TGLuint; x: TGLfloat; y: TGLfloat; z: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib3fvNV: procedure (index: TGLuint; v: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib3sNV: procedure (index: TGLuint; x: TGLshort; y: TGLshort; z: TGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib3svNV: procedure (index: TGLuint; v: PGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib4dNV: procedure (index: TGLuint; x: TGLdouble; y: TGLdouble; z: TGLdouble; w: TGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib4dvNV: procedure (index: TGLuint; v: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib4fNV: procedure(index: TGLuint; x: TGLfloat; y: TGLfloat; z: TGLfloat; w: TGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib4fvNV: procedure(index: TGLuint; v: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib4sNV: procedure (index: TGLuint; x: TGLshort; y: TGLshort; z: TGLdouble; w: TGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib4svNV: procedure (index: TGLuint; v: PGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib4ubvNV: procedure (index: TGLuint; v: PGLubyte); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttribs1dvNV: procedure (index: TGLuint; count: TGLSizei; v: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttribs1fvNV: procedure (index: TGLuint; count: TGLSizei; v: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttribs1svNV: procedure (index: TGLuint; count: TGLSizei; v: PGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttribs2dvNV: procedure (index: TGLuint; count: TGLSizei; v: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttribs2fvNV: procedure (index: TGLuint; count: TGLSizei; v: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttribs2svNV: procedure (index: TGLuint; count: TGLSizei; v: PGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttribs3dvNV: procedure (index: TGLuint; count: TGLSizei; v: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttribs3fvNV: procedure (index: TGLuint; count: TGLSizei; v: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttribs3svNV: procedure (index: TGLuint; count: TGLSizei; v: PGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttribs4dvNV: procedure (index: TGLuint; count: TGLSizei; v: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttribs4fvNV: procedure (index: TGLuint; count: TGLSizei; v: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttribs4svNV: procedure (index: TGLuint; count: TGLSizei; v: PGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttribs4ubvNV: procedure (index: TGLuint; count: TGLSizei; v: PGLubyte); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}

// GL_ATI_draw_buffers
glDrawBuffersATI: procedure(n: GLsizei; const bufs: PGLenum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
//############################################################################//




//############################################################################//
//GL_EXT_framebuffer_object
const
GL_FRAMEBUFFER_EXT = $8D40;
GL_RENDERBUFFER_EXT = $8D41;
GL_STENCIL_INDEX_EXT = $8D45;
GL_STENCIL_INDEX1_EXT = $8D46;
GL_STENCIL_INDEX4_EXT = $8D47;
GL_STENCIL_INDEX8_EXT = $8D48;
GL_STENCIL_INDEX16_EXT = $8D49;
GL_RENDERBUFFER_WIDTH_EXT = $8D42;
GL_RENDERBUFFER_HEIGHT_EXT = $8D43;
GL_RENDERBUFFER_INTERNAL_FORMAT_EXT = $8D44;
GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE_EXT = $8CD0;
GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME_EXT = $8CD1;
GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_LEVEL_EXT = $8CD2;
GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_CUBE_MAP_FACE_EXT = $8CD3;
GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_3D_ZOFFSET_EXT = $8CD4;
GL_COLOR_ATTACHMENT0_EXT = $8CE0;
GL_COLOR_ATTACHMENT1_EXT = $8CE1;
GL_COLOR_ATTACHMENT2_EXT = $8CE2;
GL_COLOR_ATTACHMENT3_EXT = $8CE3;
GL_COLOR_ATTACHMENT4_EXT = $8CE4;
GL_COLOR_ATTACHMENT5_EXT = $8CE5;
GL_COLOR_ATTACHMENT6_EXT = $8CE6;
GL_COLOR_ATTACHMENT7_EXT = $8CE7;
GL_COLOR_ATTACHMENT8_EXT = $8CE8;
GL_COLOR_ATTACHMENT9_EXT = $8CE9;
GL_COLOR_ATTACHMENT10_EXT = $8CEA;
GL_COLOR_ATTACHMENT11_EXT = $8CEB;
GL_COLOR_ATTACHMENT12_EXT = $8CEC;
GL_COLOR_ATTACHMENT13_EXT = $8CED;
GL_COLOR_ATTACHMENT14_EXT = $8CEE;
GL_COLOR_ATTACHMENT15_EXT = $8CEF;
GL_DEPTH_ATTACHMENT_EXT = $8D00;
GL_STENCIL_ATTACHMENT_EXT = $8D20;
GL_FRAMEBUFFER_COMPLETE_EXT = $8CD5;
GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT_EXT = $8CD6;
GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT_EXT = $8CD7;
GL_FRAMEBUFFER_INCOMPLETE_DUPLICATE_ATTACHMENT_EXT = $8CD8;
GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS_EXT = $8CD9;
GL_FRAMEBUFFER_INCOMPLETE_FORMATS_EXT = $8CDA;
GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER_EXT = $8CDB;
GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER_EXT = $8CDC;
GL_FRAMEBUFFER_UNSUPPORTED_EXT = $8CDD;
GL_FRAMEBUFFER_STATUS_ERROR_EXT = $8CDE;
GL_FRAMEBUFFER_BINDING_EXT = $8CA6;
GL_RENDERBUFFER_BINDING_EXT = $8CA7;
GL_MAX_COLOR_ATTACHMENTS_EXT = $8CDF;
GL_MAX_RENDERBUFFER_SIZE_EXT = $84E8;
GL_INVALID_FRAMEBUFFER_OPERATION_EXT = $0506;  
//############################################################################//
var
glIsRenderbufferEXT: function(renderbuffer: GLuint): GLboolean; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glBindRenderbufferEXT: procedure(target: GLenum; renderbuffer: GLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glDeleteRenderbuffersEXT: procedure(n: GLsizei; const renderbuffers: PGLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGenRenderbuffersEXT: procedure(n: GLsizei; renderbuffers: PGLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glRenderbufferStorageEXT: procedure(target: GLenum; internalformat: GLenum; width: GLsizei; height: GLsizei); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetRenderbufferParameterivEXT: procedure(target: GLenum; pname: GLenum; params: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glIsFramebufferEXT: function(framebuffer: GLuint): GLboolean; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glBindFramebufferEXT: procedure(target: GLenum; framebuffer: GLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glDeleteFramebuffersEXT: procedure(n: GLsizei; const framebuffers: PGLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGenFramebuffersEXT: procedure(n: GLsizei; framebuffers: PGLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glCheckFramebufferStatusEXT: function(target: GLenum): GLenum; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glFramebufferTexture1DEXT: procedure(target: GLenum; attachment: GLenum; textarget: GLenum; texture: GLuint; level: GLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glFramebufferTexture2DEXT: procedure(target: GLenum; attachment: GLenum; textarget: GLenum; texture: GLuint; level: GLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glFramebufferTexture3DEXT: procedure(target: GLenum; attachment: GLenum; textarget: GLenum; texture: GLuint; level: GLint; zoffset: GLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glFramebufferRenderbufferEXT: procedure(target: GLenum; attachment: GLenum; renderbuffertarget: GLenum; renderbuffer: GLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetFramebufferAttachmentParameterivEXT: procedure(target: GLenum; attachment: GLenum; pname: GLenum; params: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGenerateMipmapEXT: procedure(target: GLenum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}

//############################################################################//

function Load_GL_EXT_framebuffer_object: Boolean;
//############################################################################//




//############################################################################//
//GL_version_2_0
const
GL_BLEND_EQUATION_RGB = $8009;
GL_VERTEX_ATTRIB_ARRAY_ENABLED = $8622;
GL_VERTEX_ATTRIB_ARRAY_SIZE = $8623;
GL_VERTEX_ATTRIB_ARRAY_STRIDE = $8624;
GL_VERTEX_ATTRIB_ARRAY_TYPE = $8625;
GL_CURRENT_VERTEX_ATTRIB = $8626;
GL_VERTEX_PROGRAM_POINT_SIZE = $8642;
GL_VERTEX_PROGRAM_TWO_SIDE = $8643;
GL_VERTEX_ATTRIB_ARRAY_POINTER = $8645;
GL_STENCIL_BACK_FUNC = $8800;
GL_STENCIL_BACK_FAIL = $8801;
GL_STENCIL_BACK_PASS_DEPTH_FAIL = $8802;
GL_STENCIL_BACK_PASS_DEPTH_PASS = $8803;
GL_MAX_DRAW_BUFFERS = $8824;
GL_DRAW_BUFFER0 = $8825;
GL_DRAW_BUFFER1 = $8826;
GL_DRAW_BUFFER2 = $8827;
GL_DRAW_BUFFER3 = $8828;
GL_DRAW_BUFFER4 = $8829;
GL_DRAW_BUFFER5 = $882A;
GL_DRAW_BUFFER6 = $882B;
GL_DRAW_BUFFER7 = $882C;
GL_DRAW_BUFFER8 = $882D;
GL_DRAW_BUFFER9 = $882E;
GL_DRAW_BUFFER10 = $882F;
GL_DRAW_BUFFER11 = $8830;
GL_DRAW_BUFFER12 = $8831;
GL_DRAW_BUFFER13 = $8832;
GL_DRAW_BUFFER14 = $8833;
GL_DRAW_BUFFER15 = $8834;
GL_BLEND_EQUATION_ALPHA = $883D;
GL_POINT_SPRITE = $8861;
GL_COORD_REPLACE = $8862;
GL_MAX_VERTEX_ATTRIBS = $8869;
GL_VERTEX_ATTRIB_ARRAY_NORMALIZED = $886A;
GL_MAX_TEXTURE_COORDS = $8871;
GL_MAX_TEXTURE_IMAGE_UNITS = $8872;   
  
GL_PIXEL_UNPACK_BUFFER_ARB = $88EC;
GL_TEXTURE_RED_TYPE_ARB = $8C10;
GL_TEXTURE_GREEN_TYPE_ARB = $8C11;
GL_TEXTURE_BLUE_TYPE_ARB = $8C12;
GL_TEXTURE_ALPHA_TYPE_ARB = $8C13;
GL_TEXTURE_LUMINANCE_TYPE_ARB = $8C14;
GL_TEXTURE_INTENSITY_TYPE_ARB = $8C15;
GL_TEXTURE_DEPTH_TYPE_ARB = $8C16;
GL_UNSIGNED_NORMALIZED_ARB = $8C17;
GL_RGBA32F_ARB = $8814;
GL_RGB32F_ARB = $8815;
GL_ALPHA32F_ARB = $8816;
GL_INTENSITY32F_ARB = $8817;
GL_LUMINANCE32F_ARB = $8818;
GL_LUMINANCE_ALPHA32F_ARB = $8819;
GL_RGBA16F_ARB = $881A;
GL_RGB16F_ARB = $881B;
GL_ALPHA16F_ARB = $881C;
GL_INTENSITY16F_ARB = $881D;
GL_LUMINANCE16F_ARB = $881E;
GL_LUMINANCE_ALPHA16F_ARB = $881F;

GL_FRAGMENT_SHADER = $8B30;
GL_VERTEX_SHADER = $8B31;
GL_GEOMETRY_SHADER_EXT=$8DD9;

GL_MAX_FRAGMENT_UNIFORM_COMPONENTS = $8B49;
GL_MAX_VERTEX_UNIFORM_COMPONENTS = $8B4A;
GL_MAX_VARYING_FLOATS = $8B4B;
GL_MAX_VERTEX_TEXTURE_IMAGE_UNITS = $8B4C;
GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS = $8B4D;
GL_SHADER_TYPE = $8B4F;
GL_FLOAT_VEC2 = $8B50;
GL_FLOAT_VEC3 = $8B51;
GL_FLOAT_VEC4 = $8B52;
GL_INT_VEC2 = $8B53;
GL_INT_VEC3 = $8B54;
GL_INT_VEC4 = $8B55;
GL_BOOL = $8B56;
GL_BOOL_VEC2 = $8B57;
GL_BOOL_VEC3 = $8B58;
GL_BOOL_VEC4 = $8B59;
GL_FLOAT_MAT2 = $8B5A;
GL_FLOAT_MAT3 = $8B5B;
GL_FLOAT_MAT4 = $8B5C;
GL_SAMPLER_1D = $8B5D;
GL_SAMPLER_2D = $8B5E;
GL_SAMPLER_3D = $8B5F;
GL_SAMPLER_CUBE = $8B60;
GL_SAMPLER_1D_SHADOW = $8B61;
GL_SAMPLER_2D_SHADOW = $8B62;
GL_DELETE_STATUS = $8B80;
GL_COMPILE_STATUS = $8B81;
GL_LINK_STATUS = $8B82;
GL_VALIDATE_STATUS = $8B83;
GL_INFO_LOG_LENGTH = $8B84;
GL_ATTACHED_SHADERS = $8B85;
GL_ACTIVE_UNIFORMS = $8B86;
GL_ACTIVE_UNIFORM_MAX_LENGTH = $8B87;
GL_SHADER_SOURCE_LENGTH = $8B88;
GL_ACTIVE_ATTRIBUTES = $8B89;
GL_ACTIVE_ATTRIBUTE_MAX_LENGTH = $8B8A;
GL_FRAGMENT_SHADER_DERIVATIVE_HINT = $8B8B;
GL_SHADING_LANGUAGE_VERSION = $8B8C;
GL_CURRENT_PROGRAM = $8B8D;
GL_POINT_SPRITE_COORD_ORIGIN = $8CA0;
GL_LOWER_LEFT = $8CA1;
GL_UPPER_LEFT = $8CA2;
GL_STENCIL_BACK_REF = $8CA3;
GL_STENCIL_BACK_VALUE_MASK = $8CA4;
GL_STENCIL_BACK_WRITEMASK = $8CA5;   
//############################################################################//
var
glBlendEquationSeparate: procedure(modeRGB: GLenum; modeAlpha: GLenum);{$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glDrawBuffers: procedure(n: GLsizei; const bufs: PGLenum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glStencilOpSeparate: procedure(face: GLenum; sfail: GLenum; dpfail: GLenum; dppass: GLenum); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glStencilFuncSeparate: procedure(frontfunc: GLenum; backfunc: GLenum; ref: GLint; mask: GLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glStencilMaskSeparate: procedure(face: GLenum; mask: GLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glAttachShader: procedure(_program: GLuint; shader: GLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glBindAttribLocation: procedure(_program: GLuint; index: GLuint; const name: Pchar); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glCompileShader: procedure(shader: GLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glCreateProgram: function(): GLuint; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glCreateShader: function(_type: GLenum): GLuint; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glDeleteProgram: procedure(_program: GLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glDeleteShader: procedure(shader: GLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glDetachShader: procedure(_program: GLuint; shader: GLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glDisableVertexAttribArray: procedure(index: GLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glEnableVertexAttribArray: procedure(index: GLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetActiveAttrib: procedure(_program: GLuint; index: GLuint; bufSize: GLsizei; length: PGLsizei; size: PGLint; _type: PGLenum; name: Pchar); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetActiveUniform: procedure(_program: GLuint; index: GLuint; bufSize: GLsizei; length: PGLsizei; size: PGLint; _type: PGLenum; name: Pchar); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetAttachedShaders: procedure(_program: GLuint; maxCount: GLsizei; count: PGLsizei; obj: PGLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetAttribLocation: function(_program: GLuint; const name: Pchar): GLint; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetProgramiv: procedure(_program: GLuint; pname: GLenum; params: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetProgramInfoLog: procedure(_program: GLuint; bufSize: GLsizei; length: PGLsizei; infoLog: Pchar); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetShaderiv: procedure(shader: GLuint; pname: GLenum; params: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetShaderInfoLog: procedure(shader: GLuint; bufSize: GLsizei; length: PGLsizei; infoLog: Pchar); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetShaderSource: procedure(shader: GLuint; bufSize: GLsizei; length: PGLsizei; source: Pchar); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetUniformLocation: function(_program: GLuint; const name: Pchar): GLint; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetUniformfv: procedure(_program: GLuint; location: GLint; params: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetUniformiv: procedure(_program: GLuint; location: GLint; params: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetVertexAttribdv: procedure(index: GLuint; pname: GLenum; params: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetVertexAttribfv: procedure(index: GLuint; pname: GLenum; params: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetVertexAttribiv: procedure(index: GLuint; pname: GLenum; params: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glGetVertexAttribPointerv: procedure(index: GLuint; pname: GLenum; pointer: PGLvoid); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glIsProgram: function(_program: GLuint): GLboolean; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glIsShader: function(shader: GLuint): GLboolean; {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glLinkProgram: procedure(_program: GLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glShaderSource: procedure(shader: GLuint; count: GLsizei; const _string: Pchar; const length: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glUseProgram: procedure(_program: GLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glUniform1f: procedure(location: GLint; v0: GLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glUniform2f: procedure(location: GLint; v0: GLfloat; v1: GLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glUniform3f: procedure(location: GLint; v0: GLfloat; v1: GLfloat; v2: GLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glUniform4f: procedure(location: GLint; v0: GLfloat; v1: GLfloat; v2: GLfloat; v3: GLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glUniform1i: procedure(location: GLint; v0: GLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glUniform2i: procedure(location: GLint; v0: GLint; v1: GLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glUniform3i: procedure(location: GLint; v0: GLint; v1: GLint; v2: GLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glUniform4i: procedure(location: GLint; v0: GLint; v1: GLint; v2: GLint; v3: GLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glUniform1fv: procedure(location: GLint; count: GLsizei; const value: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glUniform2fv: procedure(location: GLint; count: GLsizei; const value: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glUniform3fv: procedure(location: GLint; count: GLsizei; const value: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glUniform4fv: procedure(location: GLint; count: GLsizei; const value: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glUniform1iv: procedure(location: GLint; count: GLsizei; const value: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glUniform2iv: procedure(location: GLint; count: GLsizei; const value: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glUniform3iv: procedure(location: GLint; count: GLsizei; const value: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glUniform4iv: procedure(location: GLint; count: GLsizei; const value: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glUniformMatrix2fv: procedure(location: GLint; count: GLsizei; transpose: GLboolean; const value: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glUniformMatrix3fv: procedure(location: GLint; count: GLsizei; transpose: GLboolean; const value: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glUniformMatrix4fv: procedure(location: GLint; count: GLsizei; transpose: GLboolean; const value: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glValidateProgram: procedure(_program: GLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib1d: procedure(index: GLuint; x: GLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib1dv: procedure(index: GLuint; const v: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib1f: procedure(index: GLuint; x: GLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib1fv: procedure(index: GLuint; const v: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib1s: procedure(index: GLuint; x: GLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib1sv: procedure(index: GLuint; const v: PGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib2d: procedure(index: GLuint; x: GLdouble; y: GLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib2dv: procedure(index: GLuint; const v: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib2f: procedure(index: GLuint; x: GLfloat; y: GLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib2fv: procedure(index: GLuint; const v: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib2s: procedure(index: GLuint; x: GLshort; y: GLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib2sv: procedure(index: GLuint; const v: PGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib3d: procedure(index: GLuint; x: GLdouble; y: GLdouble; z: GLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib3dv: procedure(index: GLuint; const v: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib3f: procedure(index: GLuint; x: GLfloat; y: GLfloat; z: GLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib3fv: procedure(index: GLuint; const v: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib3s: procedure(index: GLuint; x: GLshort; y: GLshort; z: GLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib3sv: procedure(index: GLuint; const v: PGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib4Nbv: procedure(index: GLuint; const v: PGLbyte); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib4Niv: procedure(index: GLuint; const v: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib4Nsv: procedure(index: GLuint; const v: PGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib4Nub: procedure(index: GLuint; x: GLubyte; y: GLubyte; z: GLubyte; w: GLubyte); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib4Nubv: procedure(index: GLuint; const v: PGLubyte); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib4Nuiv: procedure(index: GLuint; const v: PGLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib4Nusv: procedure(index: GLuint; const v: PGLushort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib4bv: procedure(index: GLuint; const v: PGLbyte); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib4d: procedure(index: GLuint; x: GLdouble; y: GLdouble; z: GLdouble; w: GLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib4dv: procedure(index: GLuint; const v: PGLdouble); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib4f: procedure(index: GLuint; x: GLfloat; y: GLfloat; z: GLfloat; w: GLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib4fv: procedure(index: GLuint; const v: PGLfloat); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib4iv: procedure(index: GLuint; const v: PGLint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib4s: procedure(index: GLuint; x: GLshort; y: GLshort; z: GLshort; w: GLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib4sv: procedure(index: GLuint; const v: PGLshort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib4ubv: procedure(index: GLuint; const v: PGLubyte); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib4uiv: procedure(index: GLuint; const v: PGLuint); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttrib4usv: procedure(index: GLuint; const v: PGLushort); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
glVertexAttribPointer: procedure(index: GLuint; size: GLint; _type: GLenum; normalized: GLboolean; stride: GLsizei; const pointer: PGLvoid); {$ifdef MSWINDOWS} stdcall; {$endif} {$ifdef LINUX} cdecl; {$endif}
//############################################################################//
function Load_GL_version_2_0: Boolean;

//############################################################################//




//############################################################################//

procedure CloseOpenGL;
function InitOpenGL : Boolean;
function InitOpenGLFromLibrary(const GLName, GLUName : String) : Boolean;
function IsOpenGLInitialized: Boolean;

procedure UnloadOpenGL;
function LoadOpenGL:Boolean;
function LoadOpenGLFromLibrary(GLName, GLUName: String):Boolean;
function IsOpenGLLoaded:Boolean;
function IsMesaGL:Boolean;
//############################################################################//
function GLGetProcAddress(ProcName: PChar):Pointer;
procedure ReadExtensions;
procedure ReadImplementationProperties;
{$ifdef MSWINDOWS}
 procedure ReadWGLExtensions;
 procedure ReadWGLImplementationProperties;
{$endif}
//############################################################################//
//Buffer ID's for Multiple-Render-Targets (using GL_ATI_draw_buffers)
const MRT_BUFFERS: array [0..3] of GLenum = (GL_FRONT_LEFT, GL_AUX0, GL_AUX1, GL_AUX2);
//############################################################################//
function glext_ExtensionSupported(const extension,searchIn:string):boolean;
function Load_GL_EXT_blend_minmax:boolean;
function Load_GL_vbo:boolean;
function Load_GL_ARB_vertex_buffer_object: Boolean;
function EXT_fog_coord_Init:boolean;
//############################################################################//
//############################################################################//
//############################################################################//
implementation
uses asys;
//############################################################################//
//############################################################################//
//############################################################################//
//Windows specific
{$ifdef MSWINDOWS}
 resourcestring
 SDefaultGLLibrary= 'OpenGL32.dll';
 SDefaultGLULibrary= 'GLU32.dll';
 const INVALID_MODULEHANDLE = 0;
 var GLHandle,GLUHandle:HINST;
 function GLGetProcAddress(ProcName:PChar):Pointer;begin result:=wglGetProcAddress(ProcName);end;   
{$endif}
//############################################################################//
//Linux specific
{$ifdef LINUX}
 resourcestring
 SDefaultGLLibrary= 'libGL.so'; 
 SDefaultGLULibrary= 'libGLU.so'; 
 const INVALID_MODULEHANDLE =0;// nil;
 var GLHandle,GLUHandle:integer;//Pointer;
 function GLGetProcAddress(ProcName:PChar):Pointer;begin result:=GetProcAddress(Cardinal(GLHandle),ProcName);end;
{$endif}   
//############################################################################//
//Extensions
procedure ReadExtensions;
begin
 // GL 1.2
 glDrawRangeElements := GLGetProcAddress('glDrawRangeElements');
 glTexImage3D := GLGetProcAddress('glTexImage3D');

 // GL 1.2 ARB imaging
 glBlendColor := GLGetProcAddress('glBlendColor');
 glBlendEquation := GLGetProcAddress('glBlendEquation');
 glColorSubTable := GLGetProcAddress('glColorSubTable'); 
 glCopyColorSubTable := GLGetProcAddress('glCopyColorSubTable');
 glColorTable := GLGetProcAddress('glCopyColorSubTable');
 glCopyColorTable := GLGetProcAddress('glCopyColorTable'); 
 glColorTableParameteriv := GLGetProcAddress('glColorTableParameteriv'); 
 glColorTableParameterfv := GLGetProcAddress('glColorTableParameterfv');
 glGetColorTable := GLGetProcAddress('glGetColorTable'); 
 glGetColorTableParameteriv := GLGetProcAddress('glGetColorTableParameteriv');
 glGetColorTableParameterfv := GLGetProcAddress('glGetColorTableParameterfv');
 glConvolutionFilter1D := GLGetProcAddress('glConvolutionFilter1D'); 
 glConvolutionFilter2D := GLGetProcAddress('glConvolutionFilter2D'); 
 glCopyConvolutionFilter1D := GLGetProcAddress('glCopyConvolutionFilter1D');
 glCopyConvolutionFilter2D := GLGetProcAddress('glCopyConvolutionFilter2D');
 glGetConvolutionFilter := GLGetProcAddress('glGetConvolutionFilter'); 
 glSeparableFilter2D := GLGetProcAddress('glSeparableFilter2D'); 
 glGetSeparableFilter := GLGetProcAddress('glGetSeparableFilter');
 glConvolutionParameteri := GLGetProcAddress('glConvolutionParameteri'); 
 glConvolutionParameteriv := GLGetProcAddress('glConvolutionParameteriv');
 glConvolutionParameterf := GLGetProcAddress('glConvolutionParameterf');
 glConvolutionParameterfv := GLGetProcAddress('glConvolutionParameterfv');
 glGetConvolutionParameteriv := GLGetProcAddress('glGetConvolutionParameteriv');
 glGetConvolutionParameterfv := GLGetProcAddress('glGetConvolutionParameterfv'); 
 glHistogram := GLGetProcAddress('glHistogram');
 glResetHistogram := GLGetProcAddress('glResetHistogram');
 glGetHistogram := GLGetProcAddress('glGetHistogram');
 glGetHistogramParameteriv := GLGetProcAddress('glGetHistogramParameteriv');
 glGetHistogramParameterfv := GLGetProcAddress('glGetHistogramParameterfv');
 glMinmax := GLGetProcAddress('glMinmax');
 glResetMinmax := GLGetProcAddress('glResetMinmax');
 glGetMinmax := GLGetProcAddress('glGetMinmax');
 glGetMinmaxParameteriv := GLGetProcAddress('glGetMinmaxParameteriv');
 glGetMinmaxParameterfv := GLGetProcAddress('glGetMinmaxParameterfv');

 // GL extensions
 glArrayElementArrayEXT := GLGetProcAddress('glArrayElementArrayEXT');
 glColorTableEXT := GLGetProcAddress('glColorTableEXT');
 glColorSubTableEXT := GLGetProcAddress('glColorSubTableEXT');
 glGetColorTableEXT := GLGetProcAddress('glGetColorTableEXT');
 glGetColorTablePameterivEXT := GLGetProcAddress('glGetColorTablePameterivEXT');
 glGetColorTablePameterfvEXT := GLGetProcAddress('glGetColorTablePameterfvEXT');
 glCopyTexImage1DEXT := GLGetProcAddress('glCopyTexImage1DEXT');
 glCopyTexSubImage1DEXT := GLGetProcAddress('glCopyTexSubImage1DEXT');
 glCopyTexImage2DEXT := GLGetProcAddress('glCopyTexImage2DEXT');
 glCopyTexSubImage2DEXT := GLGetProcAddress('glCopyTexSubImage2DEXT');
 glCopyTexSubImage3DEXT := GLGetProcAddress('glCopyTexSubImage3DEXT');
 glIndexFuncEXT := GLGetProcAddress('glIndexFuncEXT');
 glIndexMaterialEXT := GLGetProcAddress('glIndexMaterialEXT');
 glPolygonOffsetEXT := GLGetProcAddress('glPolygonOffsetEXT');
 glTexSubImage1dEXT := GLGetProcAddress('glTexSubImage1DEXT');
 glTexSubImage2dEXT := GLGetProcAddress('glTexSubImage2DEXT');
 glTexSubImage3dEXT := GLGetProcAddress('glTexSubImage3DEXT');
 glGenTexturesEXT := GLGetProcAddress('glGenTexturesEXT');
 glDeleteTexturesEXT := GLGetProcAddress('glDeleteTexturesEXT');
 glBindTextureEXT := GLGetProcAddress('glBindTextureEXT');
 glPrioritizeTexturesEXT := GLGetProcAddress('glPrioritizeTexturesEXT');
 glAreTexturesResidentEXT := GLGetProcAddress('glAreTexturesResidentEXT');
 glIsTextureEXT := GLGetProcAddress('glIsTextureEXT');

 // EXT_compiled_vertex_array
 glLockArraysEXT := GLGetProcAddress('glLockArraysEXT');
 glUnlockArraysEXT := GLGetProcAddress('glUnlockArraysEXT');

 // ARB_multitexture
 glMultiTexCoord1dARB := GLGetProcAddress('glMultiTexCoord1dARB');
 glMultiTexCoord1dVARB := GLGetProcAddress('glMultiTexCoord1dVARB');
 glMultiTexCoord1fARB := GLGetProcAddress('glMultiTexCoord1fARB');
 glMultiTexCoord1fVARB := GLGetProcAddress('glMultiTexCoord1fVARB');
 glMultiTexCoord1iARB := GLGetProcAddress('glMultiTexCoord1iARB'); 
 glMultiTexCoord1iVARB := GLGetProcAddress('glMultiTexCoord1iVARB'); 
 glMultiTexCoord1sARB := GLGetProcAddress('glMultiTexCoord1sARB'); 
 glMultiTexCoord1sVARB := GLGetProcAddress('glMultiTexCoord1sVARB'); 
 glMultiTexCoord2dARB := GLGetProcAddress('glMultiTexCoord2dARB');
 glMultiTexCoord2dvARB := GLGetProcAddress('glMultiTexCoord2dvARB'); 
 glMultiTexCoord2fARB := GLGetProcAddress('glMultiTexCoord2fARB');
 glMultiTexCoord2fvARB := GLGetProcAddress('glMultiTexCoord2fvARB');
 glMultiTexCoord2iARB := GLGetProcAddress('glMultiTexCoord2iARB');
 glMultiTexCoord2ivARB := GLGetProcAddress('glMultiTexCoord2ivARB');
 glMultiTexCoord2sARB := GLGetProcAddress('glMultiTexCoord2sARB'); 
 glMultiTexCoord2svARB := GLGetProcAddress('glMultiTexCoord2svARB'); 
 glMultiTexCoord3dARB := GLGetProcAddress('glMultiTexCoord3dARB'); 
 glMultiTexCoord3dvARB := GLGetProcAddress('glMultiTexCoord3dvARB'); 
 glMultiTexCoord3fARB := GLGetProcAddress('glMultiTexCoord3fARB'); 
 glMultiTexCoord3fvARB := GLGetProcAddress('glMultiTexCoord3fvARB'); 
 glMultiTexCoord3iARB := GLGetProcAddress('glMultiTexCoord3iARB'); 
 glMultiTexCoord3ivARB := GLGetProcAddress('glMultiTexCoord3ivARB'); 
 glMultiTexCoord3sARB := GLGetProcAddress('glMultiTexCoord3sARB'); 
 glMultiTexCoord3svARB := GLGetProcAddress('glMultiTexCoord3svARB');
 glMultiTexCoord4dARB := GLGetProcAddress('glMultiTexCoord4dARB'); 
 glMultiTexCoord4dvARB := GLGetProcAddress('glMultiTexCoord4dvARB');
 glMultiTexCoord4fARB := GLGetProcAddress('glMultiTexCoord4fARB');
 glMultiTexCoord4fvARB := GLGetProcAddress('glMultiTexCoord4fvARB'); 
 glMultiTexCoord4iARB := GLGetProcAddress('glMultiTexCoord4iARB');
 glMultiTexCoord4ivARB := GLGetProcAddress('glMultiTexCoord4ivARB');
 glMultiTexCoord4sARB := GLGetProcAddress('glMultiTexCoord4sARB');
 glMultiTexCoord4svARB := GLGetProcAddress('glMultiTexCoord4svARB'); 
 glActiveTextureARB := GLGetProcAddress('glActiveTextureARB');
 glClientActiveTextureARB := GLGetProcAddress('glClientActiveTextureARB');

 // EXT_stencil_two_side
 glActiveStencilFaceEXT := GLGetProcAddress('glActiveStencilFaceEXT');

 // WIN_swap_hint
 glAddSwapHintRectWIN := GLGetProcAddress('glAddSwapHintRectWIN'); 

 // GL_ARB_point_parameter
 glPointParameterfARB := GLGetProcAddress('glPointParameterfARB');
 glPointParameterfvARB := GLGetProcAddress('glPointParameterfvARB');

 // GL_ARB_transpose_matrix
 glLoadTransposeMatrixfARB := GLGetProcAddress('glLoadTransposeMatrixfARB');
 glLoadTransposeMatrixdARB := GLGetProcAddress('glLoadTransposeMatrixdARB'); 
 glMultTransposeMatrixfARB := GLGetProcAddress('glMultTransposeMatrixfARB'); 
 glMultTransposeMatrixdARB := GLGetProcAddress('glMultTransposeMatrixdARB'); 

 glSampleCoverageARB := GLGetProcAddress('glSampleCoverageARB');
 glSamplePassARB := GLGetProcAddress('glSamplePassARB'); 

 // GL_ARB_multisample
 glCompressedTexImage3DARB := GLGetProcAddress('glCompressedTexImage3DARB');
 glCompressedTexImage2DARB := GLGetProcAddress('glCompressedTexImage2DARB');
 glCompressedTexImage1DARB := GLGetProcAddress('glCompressedTexImage1DARB');
 glCompressedTexSubImage3DARB := GLGetProcAddress('glCompressedTexSubImage3DARB');
 glCompressedTexSubImage2DARB := GLGetProcAddress('glCompressedTexSubImage2DARB');
 glCompressedTexSubImage1DARB := GLGetProcAddress('glCompressedTexSubImage1DARB');
 glGetCompressedTexImageARB := GLGetProcAddress('glGetCompressedTexImageARB');

 // GL_ARB_vertex_program
 glVertexAttrib1sARB := GLGetProcAddress('glVertexAttrib1sARB');
 glVertexAttrib1fARB := GLGetProcAddress('glVertexAttrib1fARB');
 glVertexAttrib1dARB := GLGetProcAddress('glVertexAttrib1dARB');
 glVertexAttrib2sARB := GLGetProcAddress('glVertexAttrib2sARB');
 glVertexAttrib2fARB := GLGetProcAddress('glVertexAttrib2fARB');
 glVertexAttrib2dARB := GLGetProcAddress('glVertexAttrib2dARB');
 glVertexAttrib3sARB := GLGetProcAddress('glVertexAttrib3sARB');
 glVertexAttrib3fARB := GLGetProcAddress('glVertexAttrib3fARB');
 glVertexAttrib3dARB := GLGetProcAddress('glVertexAttrib3dARB');
 glVertexAttrib4sARB := GLGetProcAddress('glVertexAttrib4sARB');
 glVertexAttrib4fARB := GLGetProcAddress('glVertexAttrib4fARB');
 glVertexAttrib4dARB := GLGetProcAddress('glVertexAttrib4dARB');
 glVertexAttrib4NubARB := GLGetProcAddress('glVertexAttrib4NubARB');
 glVertexAttrib1svARB := GLGetProcAddress('glVertexAttrib1svARB');
 glVertexAttrib1fvARB := GLGetProcAddress('glVertexAttrib1fvARB');
 glVertexAttrib1dvARB := GLGetProcAddress('glVertexAttrib1dvARB');
 glVertexAttrib2svARB := GLGetProcAddress('glVertexAttrib2svARB');
 glVertexAttrib2fvARB := GLGetProcAddress('glVertexAttrib2fvARB');
 glVertexAttrib2dvARB := GLGetProcAddress('glVertexAttrib2dvARB');
 glVertexAttrib3svARB := GLGetProcAddress('glVertexAttrib3svARB');
 glVertexAttrib3fvARB := GLGetProcAddress('glVertexAttrib3fvARB');
 glVertexAttrib3dvARB := GLGetProcAddress('glVertexAttrib3dvARB');
 glVertexAttrib4bvARB := GLGetProcAddress('glVertexAttrib4bvARB');
 glVertexAttrib4svARB := GLGetProcAddress('glVertexAttrib4svARB');
 glVertexAttrib4ivARB := GLGetProcAddress('glVertexAttrib4ivARB');
 glVertexAttrib4ubvARB := GLGetProcAddress('glVertexAttrib4ubvARB');
 glVertexAttrib4usvARB := GLGetProcAddress('glVertexAttrib4usvARB');
 glVertexAttrib4uivARB := GLGetProcAddress('glVertexAttrib4uivARB');
 glVertexAttrib4fvARB := GLGetProcAddress('glVertexAttrib4fvARB');
 glVertexAttrib4dvARB := GLGetProcAddress('glVertexAttrib4dvARB');
 glVertexAttrib4NbvARB := GLGetProcAddress('glVertexAttrib4NbvARB');
 glVertexAttrib4NsvARB := GLGetProcAddress('glVertexAttrib4NsvARB');
 glVertexAttrib4NivARB := GLGetProcAddress('glVertexAttrib4NivARB');
 glVertexAttrib4NubvARB := GLGetProcAddress('glVertexAttrib4NubvARB');
 glVertexAttrib4NusvARB := GLGetProcAddress('glVertexAttrib4NusvARB');
 glVertexAttrib4NuivARB := GLGetProcAddress('glVertexAttrib4NuivARB');
 glVertexAttribPointerARB := GLGetProcAddress('glVertexAttribPointerARB');
 glEnableVertexAttribArrayARB := GLGetProcAddress('glEnableVertexAttribArrayARB');
 glDisableVertexAttribArrayARB := GLGetProcAddress('glDisableVertexAttribArrayARB');
 glProgramStringARB := GLGetProcAddress('glProgramStringARB');
 glBindProgramARB := GLGetProcAddress('glBindProgramARB');
 glDeleteProgramsARB := GLGetProcAddress('glDeleteProgramsARB');
 glGenProgramsARB := GLGetProcAddress('glGenProgramsARB');
 glProgramEnvParameter4dARB := GLGetProcAddress('glProgramEnvParameter4dARB');
 glProgramEnvParameter4dvARB := GLGetProcAddress('glProgramEnvParameter4dvARB');
 glProgramEnvParameter4fARB := GLGetProcAddress('glProgramEnvParameter4fARB');
 glProgramEnvParameter4fvARB := GLGetProcAddress('glProgramEnvParameter4fvARB');
 glProgramLocalParameter4dARB := GLGetProcAddress('glProgramLocalParameter4dARB');
 glProgramLocalParameter4dvARB := GLGetProcAddress('glProgramLocalParameter4dvARB');
 glProgramLocalParameter4fARB := GLGetProcAddress('glProgramLocalParameter4fARB');
 glProgramLocalParameter4fvARB := GLGetProcAddress('glProgramLocalParameter4fvARB');
 glGetProgramEnvParameterdvARB := GLGetProcAddress('glGetProgramEnvParameterdvARB');
 glGetProgramEnvParameterfvARB := GLGetProcAddress('glGetProgramEnvParameterfvARB');
 glGetProgramLocalParameterdvARB := GLGetProcAddress('glGetProgramLocalParameterdvARB');
 glGetProgramLocalParameterfvARB := GLGetProcAddress('glGetProgramLocalParameterfvARB');
 glGetProgramivARB := GLGetProcAddress('glGetProgramivARB');
 glGetProgramStringARB := GLGetProcAddress('glGetProgramStringARB');
 glGetVertexAttribdvARB := GLGetProcAddress('glGetVertexAttribdvARB');
 glGetVertexAttribfvARB := GLGetProcAddress('glGetVertexAttribfvARB');
 glGetVertexAttribivARB := GLGetProcAddress('glGetVertexAttribivARB');
 glGetVertexAttribPointervARB := GLGetProcAddress('glGetVertexAttribPointervARB');
 glIsProgramARB := GLGetProcAddress('glIsProgramARB');

 // GL_ARB_vertex_buffer_object
 glBindBufferARB := GLGetProcAddress('glBindBufferARB');
 glDeleteBuffersARB := GLGetProcAddress('glDeleteBuffersARB');
 glGenBuffersARB := GLGetProcAddress('glGenBuffersARB');
 glIsBufferARB := GLGetProcAddress('glIsBufferARB');
 glBufferDataARB := GLGetProcAddress('glBufferDataARB');
 glBufferSubDataARB := GLGetProcAddress('glBufferSubDataARB');
 glGetBufferSubDataARB := GLGetProcAddress('glGetBufferSubDataARB');
 glMapBufferARB := GLGetProcAddress('glMapBufferARB');
 glUnmapBufferARB := GLGetProcAddress('glUnmapBufferARB');
 glGetBufferParameterivARB := GLGetProcAddress('glGetBufferParameterivARB');
 glGetBufferPointervARB := GLGetProcAddress('glGetBufferPointervARB');

 // GL_ARB_shader_objects
 glDeleteObjectARB := GLGetProcAddress('glDeleteObjectARB');
 glGetHandleARB := GLGetProcAddress('glGetHandleARB');
 glDetachObjectARB := GLGetProcAddress('glDetachObjectARB');
 glCreateShaderObjectARB := GLGetProcAddress('glCreateShaderObjectARB');
 glShaderSourceARB := GLGetProcAddress('glShaderSourceARB');
 glCompileShaderARB := GLGetProcAddress('glCompileShaderARB');
 glCreateProgramObjectARB := GLGetProcAddress('glCreateProgramObjectARB');
 glAttachObjectARB := GLGetProcAddress('glAttachObjectARB');
 glLinkProgramARB := GLGetProcAddress('glLinkProgramARB');
 glUseProgramObjectARB := GLGetProcAddress('glUseProgramObjectARB');
 glValidateProgramARB := GLGetProcAddress('glValidateProgramARB');
 glUniform1fARB := GLGetProcAddress('glUniform1fARB');
 glUniform2fARB := GLGetProcAddress('glUniform2fARB');
 glUniform3fARB := GLGetProcAddress('glUniform3fARB');
 glUniform4fARB := GLGetProcAddress('glUniform4fARB');
 glUniform1iARB := GLGetProcAddress('glUniform1iARB');
 glUniform2iARB := GLGetProcAddress('glUniform2iARB');
 glUniform3iARB := GLGetProcAddress('glUniform3iARB');
 glUniform4iARB := GLGetProcAddress('glUniform4iARB');
 glUniform1fvARB := GLGetProcAddress('glUniform1fvARB');
 glUniform2fvARB := GLGetProcAddress('glUniform2fvARB');
 glUniform3fvARB := GLGetProcAddress('glUniform3fvARB');
 glUniform4fvARB := GLGetProcAddress('glUniform4fvARB');
 glUniform1ivARB := GLGetProcAddress('glUniform1ivARB');
 glUniform2ivARB := GLGetProcAddress('glUniform2ivARB');
 glUniform3ivARB := GLGetProcAddress('glUniform3ivARB');
 glUniform4ivARB := GLGetProcAddress('glUniform4ivARB');
 glUniformMatrix2fvARB := GLGetProcAddress('glUniformMatrix2fvARB');
 glUniformMatrix3fvARB := GLGetProcAddress('glUniformMatrix3fvARB');
 glUniformMatrix4fvARB := GLGetProcAddress('glUniformMatrix4fvARB');
 glGetObjectParameterfvARB := GLGetProcAddress('glGetObjectParameterfvARB');
 glGetObjectParameterivARB := GLGetProcAddress('glGetObjectParameterivARB');
 glGetInfoLogARB := GLGetProcAddress('glGetInfoLogARB');
 glGetAttachedObjectsARB := GLGetProcAddress('glGetAttachedObjectsARB');
 glGetUniformLocationARB := GLGetProcAddress('glGetUniformLocationARB');
 glGetActiveUniformARB := GLGetProcAddress('glGetActiveUniformARB');
 glGetUniformfvARB := GLGetProcAddress('glGetUniformfvARB');
 glGetUniformivARB := GLGetProcAddress('glGetUniformivARB');
 glGetShaderSourceARB := GLGetProcAddress('glGetShaderSourceARB');
   
 // GL_ARB_vertex_shader
 glBindAttribLocationARB := GLGetProcAddress('glBindAttribLocationARB');
 glGetActiveAttribARB := GLGetProcAddress('glGetActiveAttribARB');
 glGetAttribLocationARB := GLGetProcAddress('glGetAttribLocationARB');

 // GL_EXT_blend_color
 glBlendColorEXT := GLGetProcAddress('glBlendColorEXT');

 // GL_EXT_texture3D
 glTexImage3DEXT := GLGetProcAddress('glTexImage3DEXT');

 // GL_SGIS_multisample
 glSampleMaskSGIS := GLGetProcAddress('glSampleMaskSGIS');
 glSamplePatternSGIS := GLGetProcAddress('glSamplePatternSGIS');

 // GL_EXT_blend_minmax
 glBlendEquationEXT := GLGetProcAddress('glBlendEquationEXT');

 // GL_EXT_paletted_texture
 glGetColorTableParameterivEXT := GLGetProcAddress('glGetColorTableParameterivEXT');
 glGetColorTableParameterfvEXT := GLGetProcAddress('glGetColorTableParameterfvEXT');

 // GL_EXT_draw_range_elements
 glDrawRangeElementsEXT := GLGetProcAddress('glDrawRangeElementsEXT');

 // GL_EXT_secondary_color
 glSecondaryColor3bEXT := GLGetProcAddress('glSecondaryColor3bEXT');
 glSecondaryColor3bvEXT := GLGetProcAddress('glSecondaryColor3bvEXT');
 glSecondaryColor3dEXT := GLGetProcAddress('glSecondaryColor3dEXT'); 
 glSecondaryColor3dvEXT := GLGetProcAddress('glSecondaryColor3dvEXT'); 
 glSecondaryColor3fEXT := GLGetProcAddress('glSecondaryColor3fEXT'); 
 glSecondaryColor3fvEXT := GLGetProcAddress('glSecondaryColor3fvEXT'); 
 glSecondaryColor3iEXT := GLGetProcAddress('glSecondaryColor3iEXT'); 
 glSecondaryColor3ivEXT := GLGetProcAddress('glSecondaryColor3ivEXT'); 
 glSecondaryColor3sEXT := GLGetProcAddress('glSecondaryColor3sEXT'); 
 glSecondaryColor3svEXT := GLGetProcAddress('glSecondaryColor3svEXT'); 
 glSecondaryColor3ubEXT := GLGetProcAddress('glSecondaryColor3ubEXT'); 
 glSecondaryColor3ubvEXT := GLGetProcAddress('glSecondaryColor3ubvEXT'); 
 glSecondaryColor3uiEXT := GLGetProcAddress('glSecondaryColor3uiEXT'); 
 glSecondaryColor3uivEXT := GLGetProcAddress('glSecondaryColor3uivEXT'); 
 glSecondaryColor3usEXT := GLGetProcAddress('glSecondaryColor3usEXT');
 glSecondaryColor3usvEXT := GLGetProcAddress('glSecondaryColor3usvEXT');
 glSecondaryColorPointerEXT := GLGetProcAddress('glSecondaryColorPointerEXT'); 

 // GL_EXT_multi_draw_arrays
 glMultiDrawArraysEXT := GLGetProcAddress('glMultiDrawArraysEXT'); 
 glMultiDrawElementsEXT := GLGetProcAddress('glMultiDrawElementsEXT');

 // GL_EXT_fog_coord
 glFogCoordfEXT := GLGetProcAddress('glFogCoordfEXT'); 
 glFogCoordfvEXT := GLGetProcAddress('glFogCoordfvEXT'); 
 glFogCoorddEXT := GLGetProcAddress('glFogCoorddEXT'); 
 glFogCoorddvEXT := GLGetProcAddress('glFogCoorddvEXT'); 
 glFogCoordPointerEXT := GLGetProcAddress('glFogCoordPointerEXT'); 

 // GL_EXT_blend_func_separate
 glBlendFuncSeparateEXT := GLGetProcAddress('glBlendFuncSeparateEXT');

 // GL_NV_vertex_array_range
 glFlushVertexArrayRangeNV := GLGetProcAddress('glFlushVertexArrayRangeNV'); 
 glVertexArrayRangeNV := GLGetProcAddress('glVertexArrayRangeNV'); 
 wglAllocateMemoryNV := GLGetProcAddress('wglAllocateMemoryNV'); 
 wglFreeMemoryNV := GLGetProcAddress('wglFreeMemoryNV'); 

 // GL_NV_register_combiners
 glCombinerParameterfvNV := GLGetProcAddress('glCombinerParameterfvNV'); 
 glCombinerParameterfNV := GLGetProcAddress('glCombinerParameterfNV');
 glCombinerParameterivNV := GLGetProcAddress('glCombinerParameterivNV'); 
 glCombinerParameteriNV := GLGetProcAddress('glCombinerParameteriNV'); 
 glCombinerInputNV := GLGetProcAddress('glCombinerInputNV');
 glCombinerOutputNV := GLGetProcAddress('glCombinerOutputNV'); 
 glFinalCombinerInputNV := GLGetProcAddress('glFinalCombinerInputNV'); 
 glGetCombinerInputParameterfvNV := GLGetProcAddress('glGetCombinerInputParameterfvNV');
 glGetCombinerInputParameterivNV := GLGetProcAddress('glGetCombinerInputParameterivNV'); 
 glGetCombinerOutputParameterfvNV := GLGetProcAddress('glGetCombinerOutputParameterfvNV');
 glGetCombinerOutputParameterivNV := GLGetProcAddress('glGetCombinerOutputParameterivNV');
 glGetFinalCombinerInputParameterfvNV := GLGetProcAddress('glGetFinalCombinerInputParameterfvNV'); 
 glGetFinalCombinerInputParameterivNV := GLGetProcAddress('glGetFinalCombinerInputParameterivNV');

 // GL_NV_fence
 glGenFencesNV := GLGetProcAddress('glGenFencesNV');
 glDeleteFencesNV := GLGetProcAddress('glDeleteFencesNV');
 glSetFenceNV := GLGetProcAddress('glSetFenceNV');
 glTestFenceNV := GLGetProcAddress('glTestFenceNV');
 glFinishFenceNV := GLGetProcAddress('glFinishFenceNV');
 glIsFenceNV := GLGetProcAddress('glIsFenceNV');
 glGetFenceivNV := GLGetProcAddress('glGetFenceivNV');

 // GL_NV_occlusion_query
 glGenOcclusionQueriesNV := GLGetProcAddress('glGenOcclusionQueriesNV');
 glDeleteOcclusionQueriesNV := GLGetProcAddress('glDeleteOcclusionQueriesNV');
 glIsOcclusionQueryNV := GLGetProcAddress('glIsOcclusionQueryNV');
 glBeginOcclusionQueryNV := GLGetProcAddress('glBeginOcclusionQueryNV');
 glEndOcclusionQueryNV := GLGetProcAddress('glEndOcclusionQueryNV');
 glGetOcclusionQueryivNV := GLGetProcAddress('glGetOcclusionQueryivNV');
 glGetOcclusionQueryuivNV := GLGetProcAddress('glGetOcclusionQueryuivNV');

 // GL_MESA_resize_buffers
 glResizeBuffersMESA := GLGetProcAddress('glResizeBuffersMESA');

 // GL_3DFX_tbuffer
 glTbufferMask3DFX := GLGetProcAddress('glTbufferMask3DFX');

 // GL_EXT_multisample
 glSampleMaskEXT := GLGetProcAddress('glSampleMaskEXT');
 glSamplePatternEXT := GLGetProcAddress('glSamplePatternEXT');

 // GL_SGIS_texture_color_mask
 glTextureColorMaskSGIS := GLGetProcAddress('glTextureColorMaskSGIS');

 // GLU extensions
 gluNurbsCallbackDataEXT := GLGetProcAddress('gluNurbsCallbackDataEXT');
 gluNewNurbsTessellatorEXT := GLGetProcAddress('gluNewNurbsTessellatorEXT'); 
 gluDeleteNurbsTessellatorEXT := GLGetProcAddress('gluDeleteNurbsTessellatorEXT');

 // GL_NV_vertex_program
 glAreProgramsResidentNV := GLGetProcAddress('glAreProgramsResidentNV'); 
 glBindProgramNV := GLGetProcAddress('glBindProgramNV');
 glDeleteProgramsNV := GLGetProcAddress('glDeleteProgramsNV'); 
 glExecuteProgramNV := GLGetProcAddress('glExecuteProgramNV'); 
 glGenProgramsNV := GLGetProcAddress('glGenProgramsNV');
 glGetProgramParameterdvNV := GLGetProcAddress('glGetProgramParameterdvNV'); 
 glGetProgramParameterfvNV := GLGetProcAddress('glGetProgramParameterfvNV');
 glGetProgramivNV := GLGetProcAddress('glGetProgramivNV');
 glGetProgramStringNV := GLGetProcAddress('glGetProgramStringNV'); 
 glGetTrackMatrixivNV := GLGetProcAddress('glGetTrackMatrixivNV'); 
 glGetVertexAttribdvNV:= GLGetProcAddress('glGetVertexAttribdvNV'); 
 glGetVertexAttribfvNV:= GLGetProcAddress('glGetVertexAttribfvNV'); 
 glGetVertexAttribivNV:= GLGetProcAddress('glGetVertexAttribivNV');
 glGetVertexAttribPointervNV := GLGetProcAddress ('glGetVertexAttribPointervNV');
 glIsProgramNV := GLGetProcAddress('glIsProgramNV'); 
 glLoadProgramNV := GLGetProcAddress('glLoadProgramNV'); 
 glProgramParameter4dNV := GLGetProcAddress('glProgramParameter4dNV'); 
 glProgramParameter4dvNV := GLGetProcAddress('glProgramParameter4dvNV'); 
 glProgramParameter4fNV := GLGetProcAddress('glProgramParameter4fNV'); 
 glProgramParameter4fvNV := GLGetProcAddress('glProgramParameter4fvNV'); 
 glProgramParameters4dvNV := GLGetProcAddress ('glProgramParameters4dvNV'); 
 glProgramParameters4fvNV := GLGetProcAddress ('glProgramParameters4fvNV');
 glRequestResidentProgramsNV := GLGetProcAddress ('glRequestResidentProgramsNV');
 glTrackMatrixNV := GLGetProcAddress('glTrackMatrixNV'); 
 glVertexAttribPointerNV := GLGetProcAddress('glVertexAttribPointerNV');
 glVertexAttrib1dNV := GLGetProcAddress('glVertexAttrib1dNV'); 
 glVertexAttrib1dvNV := GLGetProcAddress('glVertexAttrib1dvNV'); 
 glVertexAttrib1fNV := GLGetProcAddress('glVertexAttrib1fNV');
 glVertexAttrib1fvNV := GLGetProcAddress('glVertexAttrib1fvNV'); 
 glVertexAttrib1sNV := GLGetProcAddress('glVertexAttrib1sNV'); 
 glVertexAttrib1svNV := GLGetProcAddress('glVertexAttrib1svNV'); 
 glVertexAttrib2dNV := GLGetProcAddress('glVertexAttrib2dNV');
 glVertexAttrib2dvNV := GLGetProcAddress('glVertexAttrib2dvNV');
 glVertexAttrib2fNV := GLGetProcAddress('glVertexAttrib2fNV'); 
 glVertexAttrib2fvNV := GLGetProcAddress('glVertexAttrib2fvNV');
 glVertexAttrib2sNV := GLGetProcAddress('glVertexAttrib2sNV'); 
 glVertexAttrib2svNV := GLGetProcAddress('glVertexAttrib2svNV'); 
 glVertexAttrib3dNV := GLGetProcAddress('glVertexAttrib3dNV'); 
 glVertexAttrib3dvNV := GLGetProcAddress('glVertexAttrib3dvNV');
 glVertexAttrib3fNV := GLGetProcAddress('glVertexAttrib3fNV');
 glVertexAttrib3fvNV := GLGetProcAddress('glVertexAttrib3fvNV');
 glVertexAttrib3sNV := GLGetProcAddress('glVertexAttrib3sNV');
 glVertexAttrib3svNV := GLGetProcAddress('glVertexAttrib3svNV');
 glVertexAttrib4dNV := GLGetProcAddress('glVertexAttrib4dNV');
 glVertexAttrib4dvNV := GLGetProcAddress('glVertexAttrib4dvNV');
 glVertexAttrib4fNV := GLGetProcAddress('glVertexAttrib4fNV');
 glVertexAttrib4fvNV := GLGetProcAddress('glVertexAttrib4fvNV');
 glVertexAttrib4sNV := GLGetProcAddress('glVertexAttrib4sNV');
 glVertexAttrib4svNV := GLGetProcAddress('glVertexAttrib4svNV');
 glVertexAttrib4ubvNV := GLGetProcAddress('glVertexAttrib4ubvNV');
 glVertexAttribs1dvNV := GLGetProcAddress('glVertexAttribs1dvNV');
 glVertexAttribs1fvNV := GLGetProcAddress('glVertexAttribs1fvNV');
 glVertexAttribs1svNV := GLGetProcAddress('glVertexAttribs1svNV');
 glVertexAttribs2dvNV := GLGetProcAddress('glVertexAttribs2dvNV');
 glVertexAttribs2fvNV := GLGetProcAddress('glVertexAttribs2fvNV');
 glVertexAttribs2svNV := GLGetProcAddress('glVertexAttribs2svNV');
 glVertexAttribs3dvNV := GLGetProcAddress('glVertexAttribs3dvNV');
 glVertexAttribs3fvNV := GLGetProcAddress('glVertexAttribs3fvNV');
 glVertexAttribs3svNV := GLGetProcAddress('glVertexAttribs3svNV');
 glVertexAttribs4dvNV := GLGetProcAddress('glVertexAttribs4dvNV');
 glVertexAttribs4fvNV := GLGetProcAddress('glVertexAttribs4fvNV');
 glVertexAttribs4svNV := GLGetProcAddress('glVertexAttribs4svNV');
 glVertexAttribs4ubvNV := GLGetProcAddress('glVertexAttribs4ubvN');

 // GL_ATI_draw_buffers
 glDrawBuffersATI := GLGetProcAddress('glDrawBuffersATI');

 {$ifdef MSWINDOWS}ReadWGLExtensions;{$endif}
end;
//############################################################################//
//############################################################################//
{$ifdef MSWINDOWS}
procedure ReadWGLExtensions;
begin
 // ARB wgl extensions
 wglGetExtensionsStringARB := GLGetProcAddress('wglGetExtensionsStringARB');
 wglGetPixelFormatAttribivARB := GLGetProcAddress('wglGetPixelFormatAttribivARB');
 wglGetPixelFormatAttribfvARB := GLGetProcAddress('wglGetPixelFormatAttribfvARB');
 wglChoosePixelFormatARB := GLGetProcAddress('wglChoosePixelFormatARB');

 wglCreatePbufferARB := GLGetProcAddress('wglCreatePbufferARB');
 wglGetPbufferDCARB := GLGetProcAddress('wglGetPbufferDCARB');
 wglReleasePbufferDCARB := GLGetProcAddress('wglReleasePbufferDCARB');
 wglDestroyPbufferARB := GLGetProcAddress('wglDestroyPbufferARB');
 wglQueryPbufferARB := GLGetProcAddress('wglQueryPbufferARB');

 wglCreateBufferRegionARB := GLGetProcAddress('wglCreateBufferRegionARB');
 wglDeleteBufferRegionARB := GLGetProcAddress('wglDeleteBufferRegionARB');
 wglSaveBufferRegionARB := GLGetProcAddress('wglSaveBufferRegionARB');
 wglRestoreBufferRegionARB := GLGetProcAddress('wglRestoreBufferRegionARB');

 // -EGG- ----------------------------
 wglSwapIntervalEXT := GLGetProcAddress('wglSwapIntervalEXT');
 wglGetSwapIntervalEXT := GLGetProcAddress('wglGetSwapIntervalEXT');
end;
{$endif}
//############################################################################//
// TrimAndSplitVersionString
procedure TrimAndSplitVersionString(Buffer: String; var Max, Min: Integer);
// Peels out the X.Y form from the given Buffer which must contain a version string like "text Minor.Major.Build text"
// at least however "Major.Minor".
var Separator:Integer;
begin try
 // There must be at least one dot to separate major and minor version number.
 Separator := Pos('.', Buffer);
 // At least one number must be before and one after the dot.
 if (Separator > 1) and (Separator < Length(Buffer)) and (Buffer[Separator - 1] in ['0'..'9']) and (Buffer[Separator + 1] in ['0'..'9']) then begin
  // OK, it's a valid version string. Now remove unnecessary parts.
  Dec(Separator); 
  // Find last non-numeric character before version number.
  while (Separator > 0) and (Buffer[Separator] in ['0'..'9']) do
    Dec(Separator); 
  // Delete leading characters which do not belong to the version string.
  Delete(Buffer, 1, Separator);
  Separator := Pos('.', Buffer) + 1;
  // Find first non-numeric character after version number
  while (Separator <= Length(Buffer)) and (Buffer[Separator] in ['0'..'9']) do
    Inc(Separator);
  // delete trailing characters not belonging to the version string
  Delete(Buffer, Separator, 255);
  // Now translate the numbers.
  Separator := Pos('.', Buffer); // This is necessary because the buffer length might have changed.
  Max := StrToInt(Copy(Buffer, 1, Separator - 1));
  Min := StrToInt(Copy(Buffer, Separator + 1, 255));
 end else begin exit;Min:=0;Max:=0;end;//Abort;
 except Min:=0;Max:=0;end;
end;
//############################################################################//
procedure ReadImplementationProperties;
var Buffer:String;
MajorVersion, MinorVersion: Integer;

//Checks if the given Extension string is in Buffer.
function CheckExtension(const Extension: string): Boolean;
var ExtPos: Integer;
begin
 // First find the position of the extension string as substring in Buffer.
 ExtPos := Pos(Extension, Buffer);
 Result := ExtPos > 0;
 // Now check that it isn't only a substring of another extension.
 if Result then Result := ((ExtPos + Length(Extension) - 1)= Length(Buffer)) or (Buffer[ExtPos + Length(Extension)]=' ');
end;

begin
 // determine version of implementation
 // GL
 buffer:=glGetString(GL_VERSION);
 TrimAndSplitVersionString(buffer, majorversion, minorVersion);
 GL_VERSION_1_0:=True;
 GL_VERSION_1_1:=(minorVersion>=1) or (majorVersion>1);
 GL_VERSION_1_2:=(minorVersion>=2) or (majorVersion>1);
 GL_VERSION_1_3:=(minorVersion>=3) or (majorVersion>1);
 GL_VERSION_1_4:=(minorVersion>=4) or (majorVersion>1);
 GL_VERSION_1_5:=(minorVersion>=5) or (majorVersion>1);

 // GLU
 buffer:=gluGetString(GLU_VERSION);
 TrimAndSplitVersionString(buffer, majorversion, minorVersion);
 GLU_VERSION_1_1:=True; // won't load without at least GLU 1.1
 GLU_VERSION_1_2:=(minorVersion>1) or (majorVersion>1);
 GLU_VERSION_1_3:=(minorVersion>2) or (majorVersion>1);

 // check supported extensions
 // GL
 Buffer := StrPas(glGetString(GL_EXTENSIONS));

 GL_3DFX_multisample := CheckExtension('GL_3DFX_multisample');
 GL_3DFX_tbuffer := CheckExtension('GL_3DFX_tbuffer');
 GL_3DFX_texture_compression_FXT1 := CheckExtension('GL_3DFX_texture_compression_FXT1');

 GL_ARB_imaging := CheckExtension('GL_ARB_imaging');
 GL_ARB_multisample := CheckExtension(' GL_ARB_multisample'); // ' ' to avoid collision with WGL variant
 GL_ARB_multitexture := CheckExtension('GL_ARB_multitexture');
 GL_ARB_depth_texture := CheckExtension('GL_ARB_depth_texture');
 GL_ARB_shadow := CheckExtension('GL_ARB_shadow');
 GL_ARB_texture_border_clamp := CheckExtension('GL_ARB_texture_border_clamp');
 GL_ARB_texture_compression := CheckExtension('GL_ARB_texture_compression');
 GL_ARB_texture_cube_map := CheckExtension('GL_ARB_texture_cube_map');
 GL_ARB_transpose_matrix := CheckExtension('GL_ARB_transpose_matrix');
 GL_ARB_vertex_blend := CheckExtension('GL_ARB_vertex_blend');
 GL_ARB_point_parameters := CheckExtension('GL_ARB_point_parameters');
 GL_ARB_texture_env_combine := CheckExtension('GL_ARB_texture_env_combine');
 GL_ARB_texture_env_crossbar := CheckExtension('GL_ARB_texture_env_crossbar');
 GL_ARB_texture_env_dot3 := CheckExtension('GL_ARB_texture_env_dot3');
 GL_ARB_vertex_program := CheckExtension('GL_ARB_vertex_program');
 GL_ARB_vertex_buffer_object := CheckExtension('GL_ARB_vertex_buffer_object');
 GL_ARB_shader_objects := CheckExtension('GL_ARB_shader_objects');
 GL_ARB_vertex_shader := CheckExtension('GL_ARB_vertex_shader');
 GL_ARB_fragment_shader := CheckExtension('GL_ARB_fragment_shader');
 GL_ARB_fragment_program := CheckExtension('GL_ARB_fragment_program');

 GL_EXT_abgr := CheckExtension('GL_EXT_abgr');
 GL_EXT_bgra := CheckExtension('GL_EXT_bgra');
 GL_EXT_blend_color := CheckExtension('GL_EXT_blend_color');
 GL_EXT_blend_func_separate := CheckExtension('GL_EXT_blend_func_separate');
 GL_EXT_blend_logic_op := CheckExtension('GL_EXT_blend_logic_op');
 GL_EXT_blend_minmax := CheckExtension('GL_EXT_blend_minmax');
 GL_EXT_blend_subtract := CheckExtension('GL_EXT_blend_subtract');
 GL_EXT_Cg_shader := CheckExtension('GL_EXT_Cg_shader');
 GL_EXT_compiled_vertex_array := CheckExtension('GL_EXT_compiled_vertex_array');
 GL_EXT_copy_texture := CheckExtension('GL_EXT_copy_texture');
 GL_EXT_draw_range_elements := CheckExtension('GL_EXT_draw_range_elements');
 GL_EXT_fog_coord := CheckExtension('GL_EXT_fog_coord');
 GL_EXT_multi_draw_arrays := CheckExtension('GL_EXT_multi_draw_arrays');
 GL_EXT_multisample := CheckExtension('GL_EXT_multisample');
 GL_EXT_packed_pixels := CheckExtension('GL_EXT_packed_pixels');
 GL_EXT_paletted_texture := CheckExtension('GL_EXT_paletted_texture');
 GL_EXT_polygon_offset := CheckExtension('GL_EXT_polygon_offset');
 GL_EXT_rescale_normal := CheckExtension('GL_EXT_rescale_normal');
 GL_EXT_secondary_color := CheckExtension('GL_EXT_secondary_color');
 GL_EXT_separate_specular_color := CheckExtension('GL_EXT_separate_specular_color');
 GL_EXT_shared_texture_palette := CheckExtension('GL_EXT_shared_texture_palette');
 GL_EXT_stencil_wrap := CheckExtension('GL_EXT_stencil_wrap');
 GL_EXT_stencil_two_side := CheckExtension('EXT_stencil_two_side');
 GL_EXT_texture_compression_s3tc := CheckExtension('GL_EXT_texture_compression_s3tc');
 GL_EXT_texture_cube_map := CheckExtension('GL_EXT_texture_cube_map');
 GL_EXT_texture_edge_clamp := CheckExtension('GL_EXT_texture_edge_clamp');
 GL_EXT_texture_env_add := CheckExtension('GL_EXT_texture_env_add');
 GL_EXT_texture_env_combine := CheckExtension('GL_EXT_texture_env_combine');
 GL_EXT_texture_filter_anisotropic := CheckExtension('GL_EXT_texture_filter_anisotropic');
 GL_EXT_texture_lod_bias := CheckExtension('GL_EXT_texture_lod_bias');
 GL_EXT_texture_object := CheckExtension('GL_EXT_texture_object');
 GL_EXT_texture3D := CheckExtension('GL_EXT_texture3D');
 GL_EXT_clip_volume_hint := CheckExtension('GL_EXT_clip_volume_hint');

 GL_HP_occlusion_test := CheckExtension('GL_HP_occlusion_test');

 GL_IBM_rasterpos_clip := CheckExtension('GL_IBM_rasterpos_clip');

 GL_KTX_buffer_region := CheckExtension('GL_KTX_buffer_region');

 GL_MESA_resize_buffers := CheckExtension('GL_MESA_resize_buffers');

 GL_NV_blend_square := CheckExtension('GL_NV_blend_square');
 GL_NV_fog_distance := CheckExtension('GL_NV_fog_distance');
 GL_NV_light_max_exponent := CheckExtension('GL_NV_light_max_exponent');
 GL_NV_register_combiners := CheckExtension('GL_NV_register_combiners');
 GL_NV_texgen_reflection := CheckExtension('GL_NV_texgen_reflection');
 GL_NV_texture_env_combine4 := CheckExtension('GL_NV_texture_env_combine4');
 GL_NV_vertex_array_range := CheckExtension('GL_NV_vertex_array_range');
 GL_NV_multisample_filter_hint  := CheckExtension('GL_NV_multisample_filter_hint');
 GL_NV_vertex_program := CheckExtension('GL_NV_vertex_program');
 GL_NV_fence := CheckExtension('GL_NV_fence');
 GL_NV_occlusion_query := CheckExtension('GL_NV_occlusion_query');
 GL_NV_texture_rectangle := CheckExtension('GL_NV_texture_rectangle');

 GL_ATI_texture_float := CheckExtension('GL_ATI_texture_float');
 GL_ATI_draw_buffers := CheckExtension('GL_ATI_draw_buffers');

 GL_SGI_color_matrix := CheckExtension('GL_SGI_color_matrix');

 GL_SGIS_generate_mipmap := CheckExtension('GL_SGIS_generate_mipmap');
 GL_SGIS_multisample := CheckExtension('GL_SGIS_multisample');
 GL_SGIS_texture_border_clamp := CheckExtension('GL_SGIS_texture_border_clamp');
 GL_SGIS_texture_color_mask := CheckExtension('GL_SGIS_texture_color_mask');
 GL_SGIS_texture_edge_clamp := CheckExtension('GL_SGIS_texture_edge_clamp');
 GL_SGIS_texture_lod := CheckExtension('GL_SGIS_texture_lod');

 GL_SGIX_depth_texture := CheckExtension('GL_SGIX_depth_texture');
 GL_SGIX_shadow := CheckExtension('GL_SGIX_shadow'); 
 GL_SGIX_shadow_ambient := CheckExtension('GL_SGIX_shadow_ambient');

 GL_WIN_swap_hint := CheckExtension('GL_WIN_swap_hint');

 WGL_ARB_extensions_string := CheckExtension('WGL_ARB_extensions_string');

 // GLU
 Buffer := gluGetString(GLU_EXTENSIONS);
 GLU_EXT_TEXTURE := CheckExtension('GLU_EXT_TEXTURE');
 GLU_EXT_object_space_tess := CheckExtension('GLU_EXT_object_space_tess');
 GLU_EXT_nurbs_tessellator := CheckExtension('GLU_EXT_nurbs_tessellator');

 {$ifdef MSWINDOWS}ReadWGLImplementationProperties;{$endif}
end;
//############################################################################//
{$ifdef MSWINDOWS}
procedure ReadWGLImplementationProperties;
var buffer: string;
// Checks if the given Extension string is in Buffer.
function CheckExtension(const extension : String) : Boolean;begin Result:=(Pos(extension, Buffer)>0);end;
begin
 // ARB wgl extensions
 if Assigned(wglGetExtensionsStringARB) then
    Buffer:=wglGetExtensionsStringARB(wglGetCurrentDC)
 else Buffer:='';
 WGL_ARB_multisample:=CheckExtension('WGL_ARB_multisample');
 WGL_EXT_swap_control:=CheckExtension('WGL_EXT_swap_control');
 WGL_ARB_buffer_region:=CheckExtension('WGL_ARB_buffer_region');
 WGL_ARB_extensions_string:=CheckExtension('WGL_ARB_extensions_string');
 WGL_ARB_pbuffer:=CheckExtension('WGL_ARB_pbuffer ');
 WGL_ARB_pixel_format:=CheckExtension('WGL_ARB_pixel_format');
 WGL_ATI_pixel_format_float:=CheckExtension('WGL_ATI_pixel_format_float');
end;
{$endif}
//############################################################################//
procedure CloseOpenGL;
begin
 if GLHandle<>INVALID_MODULEHANDLE then begin
  FreeLibrary(Cardinal(GLHandle));
  GLHandle:=INVALID_MODULEHANDLE;
 end;
 if GLUHandle<>INVALID_MODULEHANDLE then begin
  FreeLibrary(Cardinal(GLUHandle));
  GLUHandle:=INVALID_MODULEHANDLE;
 end;
end;
//############################################################################//
function InitOpenGL:Boolean;
begin
 if (GLHandle=INVALID_MODULEHANDLE) or (GLUHandle=INVALID_MODULEHANDLE) then Result:=InitOpenGLFromLibrary(SDefaultGLLibrary, SDefaultGLULibrary)
                                                                        else Result:=True;
end;
//############################################################################//
function InitOpenGLFromLibrary(const GLName, GLUName : String) : Boolean;
begin
 Result := False;
 CloseOpenGL;

 //{$ifdef Win32}
  GLHandle:=LoadLibrary(PChar(GLName));
  GLUHandle:=LoadLibrary(PChar(GLUName));
 //{$endif}

 //{$ifdef LINUX}
 // GLHandle:=dlopen(PChar(GLName), RTLD_GLOBAL or RTLD_LAZY);
 // GLUHandle:=dlopen(PChar(GLUName), RTLD_GLOBAL or RTLD_LAZY);
 //{$endif}

 if (GLHandle<>INVALID_MODULEHANDLE) and (GLUHandle<>INVALID_MODULEHANDLE) then Result:=True else begin
  if GLHandle<>INVALID_MODULEHANDLE then FreeLibrary(Cardinal(GLHandle));
  if GLUHandle<>INVALID_MODULEHANDLE then FreeLibrary(Cardinal(GLUHandle));
 end;
end;
//############################################################################//
function IsOpenGLInitialized: Boolean;begin Result:=(GLHandle<>INVALID_MODULEHANDLE);end;
procedure UnloadOpenGL;begin CloseOpenGL; end; 
function LoadOpenGL: Boolean;begin Result := InitOpenGL;end;
function LoadOpenGLFromLibrary(GLName, GLUName: String): Boolean;begin Result := InitOpenGLFromLibrary(GLName, GLUName);end;
function IsOpenGLLoaded: Boolean;begin Result:=(GLHandle<>INVALID_MODULEHANDLE);end;
function IsMesaGL : Boolean;begin Result:=(GetProcAddress(Cardinal(GLHandle), 'glResizeBuffersMESA')<>nil);end;
//############################################################################//
function Load_GL_EXT_framebuffer_object: Boolean;
begin
 result:=false;
 
 glIsRenderbufferEXT := GLGetProcAddress('glIsRenderbufferEXT');
 if not Assigned(glIsRenderbufferEXT) then exit;
 glBindRenderbufferEXT := GLGetProcAddress('glBindRenderbufferEXT');
 if not Assigned(glBindRenderbufferEXT) then exit;
 glDeleteRenderbuffersEXT := GLGetProcAddress('glDeleteRenderbuffersEXT');
 if not Assigned(glDeleteRenderbuffersEXT) then exit;
 glGenRenderbuffersEXT := GLGetProcAddress('glGenRenderbuffersEXT');
 if not Assigned(glGenRenderbuffersEXT) then exit;
 glRenderbufferStorageEXT := GLGetProcAddress('glRenderbufferStorageEXT');
 if not Assigned(glRenderbufferStorageEXT) then exit;
 glGetRenderbufferParameterivEXT := GLGetProcAddress('glGetRenderbufferParameterivEXT');
 if not Assigned(glGetRenderbufferParameterivEXT) then exit;
 glIsFramebufferEXT := GLGetProcAddress('glIsFramebufferEXT');
 if not Assigned(glIsFramebufferEXT) then exit;
 glBindFramebufferEXT := GLGetProcAddress('glBindFramebufferEXT');
 if not Assigned(glBindFramebufferEXT) then exit;
 glDeleteFramebuffersEXT := GLGetProcAddress('glDeleteFramebuffersEXT');
 if not Assigned(glDeleteFramebuffersEXT) then exit;
 glGenFramebuffersEXT := GLGetProcAddress('glGenFramebuffersEXT');
 if not Assigned(glGenFramebuffersEXT) then exit;
 glCheckFramebufferStatusEXT := GLGetProcAddress('glCheckFramebufferStatusEXT');
 if not Assigned(glCheckFramebufferStatusEXT) then exit;
 glFramebufferTexture1DEXT := GLGetProcAddress('glFramebufferTexture1DEXT');
 if not Assigned(glFramebufferTexture1DEXT) then exit;
 glFramebufferTexture2DEXT := GLGetProcAddress('glFramebufferTexture2DEXT');
 if not Assigned(glFramebufferTexture2DEXT) then exit;
 glFramebufferTexture3DEXT := GLGetProcAddress('glFramebufferTexture3DEXT');
 if not Assigned(glFramebufferTexture3DEXT) then exit;
 glFramebufferRenderbufferEXT := GLGetProcAddress('glFramebufferRenderbufferEXT');
 if not Assigned(glFramebufferRenderbufferEXT) then exit;
 glGetFramebufferAttachmentParameterivEXT := GLGetProcAddress('glGetFramebufferAttachmentParameterivEXT');
 if not Assigned(glGetFramebufferAttachmentParameterivEXT) then exit;
 glGenerateMipmapEXT := GLGetProcAddress('glGenerateMipmapEXT');
 if not Assigned(glGenerateMipmapEXT) then exit;
 result:=true;
end;

//############################################################################//

function Load_GL_version_2_0: Boolean;
var extstring: String;
begin
 Result := FALSE;
 extstring := String(PChar(glGetString(GL_EXTENSIONS)));

 glBlendEquationSeparate := GLGetProcAddress('glBlendEquationSeparate');
 if not Assigned(glBlendEquationSeparate) then exit;
 glDrawBuffers := GLGetProcAddress('glDrawBuffers');
 if not Assigned(glDrawBuffers) then exit;
 glStencilOpSeparate := GLGetProcAddress('glStencilOpSeparate');
 if not Assigned(glStencilOpSeparate) then exit;
 glStencilFuncSeparate := GLGetProcAddress('glStencilFuncSeparate');
 if not Assigned(glStencilFuncSeparate) then exit;
 glStencilMaskSeparate := GLGetProcAddress('glStencilMaskSeparate');
 if not Assigned(glStencilMaskSeparate) then exit;
 glAttachShader := GLGetProcAddress('glAttachShader');
 if not Assigned(glAttachShader) then exit;
 glBindAttribLocation := GLGetProcAddress('glBindAttribLocation');
 if not Assigned(glBindAttribLocation) then exit;
 glCompileShader := GLGetProcAddress('glCompileShader');
 if not Assigned(glCompileShader) then exit;
 glCreateProgram := GLGetProcAddress('glCreateProgram');
 if not Assigned(glCreateProgram) then exit;
 glCreateShader := GLGetProcAddress('glCreateShader');
 if not Assigned(glCreateShader) then exit;
 glDeleteProgram := GLGetProcAddress('glDeleteProgram');
 if not Assigned(glDeleteProgram) then exit;
 glDeleteShader := GLGetProcAddress('glDeleteShader');
 if not Assigned(glDeleteShader) then exit;
 glDetachShader := GLGetProcAddress('glDetachShader');
 if not Assigned(glDetachShader) then exit;
 glDisableVertexAttribArray := GLGetProcAddress('glDisableVertexAttribArray');
 if not Assigned(glDisableVertexAttribArray) then exit;
 glEnableVertexAttribArray := GLGetProcAddress('glEnableVertexAttribArray');
 if not Assigned(glEnableVertexAttribArray) then exit;
 glGetActiveAttrib := GLGetProcAddress('glGetActiveAttrib');
 if not Assigned(glGetActiveAttrib) then exit;
 glGetActiveUniform := GLGetProcAddress('glGetActiveUniform');
 if not Assigned(glGetActiveUniform) then exit;
 glGetAttachedShaders := GLGetProcAddress('glGetAttachedShaders');
 if not Assigned(glGetAttachedShaders) then exit;
 glGetAttribLocation := GLGetProcAddress('glGetAttribLocation');
 if not Assigned(glGetAttribLocation) then exit;
 glGetProgramiv := GLGetProcAddress('glGetProgramiv');
 if not Assigned(glGetProgramiv) then exit;
 glGetProgramInfoLog := GLGetProcAddress('glGetProgramInfoLog');
 if not Assigned(glGetProgramInfoLog) then exit;
 glGetShaderiv := GLGetProcAddress('glGetShaderiv');
 if not Assigned(glGetShaderiv) then exit;
 glGetShaderInfoLog := GLGetProcAddress('glGetShaderInfoLog');
 if not Assigned(glGetShaderInfoLog) then exit;
 glGetShaderSource := GLGetProcAddress('glGetShaderSource');
 if not Assigned(glGetShaderSource) then exit;
 glGetUniformLocation := GLGetProcAddress('glGetUniformLocation');
 if not Assigned(glGetUniformLocation) then exit;
 glGetUniformfv := GLGetProcAddress('glGetUniformfv');
 if not Assigned(glGetUniformfv) then exit;
 glGetUniformiv := GLGetProcAddress('glGetUniformiv');
 if not Assigned(glGetUniformiv) then exit;
 glGetVertexAttribdv := GLGetProcAddress('glGetVertexAttribdv');
 if not Assigned(glGetVertexAttribdv) then exit;
 glGetVertexAttribfv := GLGetProcAddress('glGetVertexAttribfv');
 if not Assigned(glGetVertexAttribfv) then exit;
 glGetVertexAttribiv := GLGetProcAddress('glGetVertexAttribiv');
 if not Assigned(glGetVertexAttribiv) then exit;
 glGetVertexAttribPointerv := GLGetProcAddress('glGetVertexAttribPointerv');
 if not Assigned(glGetVertexAttribPointerv) then exit;
 glIsProgram := GLGetProcAddress('glIsProgram');
 if not Assigned(glIsProgram) then exit;
 glIsShader := GLGetProcAddress('glIsShader');
 if not Assigned(glIsShader) then exit;
 glLinkProgram := GLGetProcAddress('glLinkProgram');
 if not Assigned(glLinkProgram) then exit;
 glShaderSource := GLGetProcAddress('glShaderSource');
 if not Assigned(glShaderSource) then exit;
 glUseProgram := GLGetProcAddress('glUseProgram');
 if not Assigned(glUseProgram) then exit;
 glUniform1f := GLGetProcAddress('glUniform1f');
 if not Assigned(glUniform1f) then exit;
 glUniform2f := GLGetProcAddress('glUniform2f');
 if not Assigned(glUniform2f) then exit;
 glUniform3f := GLGetProcAddress('glUniform3f');
 if not Assigned(glUniform3f) then exit;
 glUniform4f := GLGetProcAddress('glUniform4f');
 if not Assigned(glUniform4f) then exit;
 glUniform1i := GLGetProcAddress('glUniform1i');
 if not Assigned(glUniform1i) then exit;
 glUniform2i := GLGetProcAddress('glUniform2i');
 if not Assigned(glUniform2i) then exit;
 glUniform3i := GLGetProcAddress('glUniform3i');
 if not Assigned(glUniform3i) then exit;
 glUniform4i := GLGetProcAddress('glUniform4i');
 if not Assigned(glUniform4i) then exit;
 glUniform1fv := GLGetProcAddress('glUniform1fv');
 if not Assigned(glUniform1fv) then exit;
 glUniform2fv := GLGetProcAddress('glUniform2fv');
 if not Assigned(glUniform2fv) then exit;
 glUniform3fv := GLGetProcAddress('glUniform3fv');
 if not Assigned(glUniform3fv) then exit;
 glUniform4fv := GLGetProcAddress('glUniform4fv');
 if not Assigned(glUniform4fv) then exit;
 glUniform1iv := GLGetProcAddress('glUniform1iv');
 if not Assigned(glUniform1iv) then exit;
 glUniform2iv := GLGetProcAddress('glUniform2iv');
 if not Assigned(glUniform2iv) then exit;
 glUniform3iv := GLGetProcAddress('glUniform3iv');
 if not Assigned(glUniform3iv) then exit;
 glUniform4iv := GLGetProcAddress('glUniform4iv');
 if not Assigned(glUniform4iv) then exit;
 glUniformMatrix2fv := GLGetProcAddress('glUniformMatrix2fv');
 if not Assigned(glUniformMatrix2fv) then exit;
 glUniformMatrix3fv := GLGetProcAddress('glUniformMatrix3fv');
 if not Assigned(glUniformMatrix3fv) then exit;
 glUniformMatrix4fv := GLGetProcAddress('glUniformMatrix4fv');
 if not Assigned(glUniformMatrix4fv) then exit;
 glValidateProgram := GLGetProcAddress('glValidateProgram');
 if not Assigned(glValidateProgram) then exit;
 glVertexAttrib1d := GLGetProcAddress('glVertexAttrib1d');
 if not Assigned(glVertexAttrib1d) then exit;
 glVertexAttrib1dv := GLGetProcAddress('glVertexAttrib1dv');
 if not Assigned(glVertexAttrib1dv) then exit;
 glVertexAttrib1f := GLGetProcAddress('glVertexAttrib1f');
 if not Assigned(glVertexAttrib1f) then exit;
 glVertexAttrib1fv := GLGetProcAddress('glVertexAttrib1fv');
 if not Assigned(glVertexAttrib1fv) then exit;
 glVertexAttrib1s := GLGetProcAddress('glVertexAttrib1s');
 if not Assigned(glVertexAttrib1s) then exit;
 glVertexAttrib1sv := GLGetProcAddress('glVertexAttrib1sv');
 if not Assigned(glVertexAttrib1sv) then exit;
 glVertexAttrib2d := GLGetProcAddress('glVertexAttrib2d');
 if not Assigned(glVertexAttrib2d) then exit;
 glVertexAttrib2dv := GLGetProcAddress('glVertexAttrib2dv');
 if not Assigned(glVertexAttrib2dv) then exit;
 glVertexAttrib2f := GLGetProcAddress('glVertexAttrib2f');
 if not Assigned(glVertexAttrib2f) then exit;
 glVertexAttrib2fv := GLGetProcAddress('glVertexAttrib2fv');
 if not Assigned(glVertexAttrib2fv) then exit;
 glVertexAttrib2s := GLGetProcAddress('glVertexAttrib2s');
 if not Assigned(glVertexAttrib2s) then exit;
 glVertexAttrib2sv := GLGetProcAddress('glVertexAttrib2sv');
 if not Assigned(glVertexAttrib2sv) then exit;
 glVertexAttrib3d := GLGetProcAddress('glVertexAttrib3d');
 if not Assigned(glVertexAttrib3d) then exit;
 glVertexAttrib3dv := GLGetProcAddress('glVertexAttrib3dv');
 if not Assigned(glVertexAttrib3dv) then exit;
 glVertexAttrib3f := GLGetProcAddress('glVertexAttrib3f');
 if not Assigned(glVertexAttrib3f) then exit;
 glVertexAttrib3fv := GLGetProcAddress('glVertexAttrib3fv');
 if not Assigned(glVertexAttrib3fv) then exit;
 glVertexAttrib3s := GLGetProcAddress('glVertexAttrib3s');
 if not Assigned(glVertexAttrib3s) then exit;
 glVertexAttrib3sv := GLGetProcAddress('glVertexAttrib3sv');
 if not Assigned(glVertexAttrib3sv) then exit;
 glVertexAttrib4Nbv := GLGetProcAddress('glVertexAttrib4Nbv');
 if not Assigned(glVertexAttrib4Nbv) then exit;
 glVertexAttrib4Niv := GLGetProcAddress('glVertexAttrib4Niv');
 if not Assigned(glVertexAttrib4Niv) then exit;
 glVertexAttrib4Nsv := GLGetProcAddress('glVertexAttrib4Nsv');
 if not Assigned(glVertexAttrib4Nsv) then exit;
 glVertexAttrib4Nub := GLGetProcAddress('glVertexAttrib4Nub');
 if not Assigned(glVertexAttrib4Nub) then exit;
 glVertexAttrib4Nubv := GLGetProcAddress('glVertexAttrib4Nubv');
 if not Assigned(glVertexAttrib4Nubv) then exit;
 glVertexAttrib4Nuiv := GLGetProcAddress('glVertexAttrib4Nuiv');
 if not Assigned(glVertexAttrib4Nuiv) then exit;
 glVertexAttrib4Nusv := GLGetProcAddress('glVertexAttrib4Nusv');
 if not Assigned(glVertexAttrib4Nusv) then exit;
 glVertexAttrib4bv := GLGetProcAddress('glVertexAttrib4bv');
 if not Assigned(glVertexAttrib4bv) then exit;
 glVertexAttrib4d := GLGetProcAddress('glVertexAttrib4d');
 if not Assigned(glVertexAttrib4d) then exit;
 glVertexAttrib4dv := GLGetProcAddress('glVertexAttrib4dv');
 if not Assigned(glVertexAttrib4dv) then exit;
 glVertexAttrib4f := GLGetProcAddress('glVertexAttrib4f');
 if not Assigned(glVertexAttrib4f) then exit;
 glVertexAttrib4fv := GLGetProcAddress('glVertexAttrib4fv');
 if not Assigned(glVertexAttrib4fv) then exit;
 glVertexAttrib4iv := GLGetProcAddress('glVertexAttrib4iv');
 if not Assigned(glVertexAttrib4iv) then exit;
 glVertexAttrib4s := GLGetProcAddress('glVertexAttrib4s');
 if not Assigned(glVertexAttrib4s) then exit;
 glVertexAttrib4sv := GLGetProcAddress('glVertexAttrib4sv');
 if not Assigned(glVertexAttrib4sv) then exit;
 glVertexAttrib4ubv := GLGetProcAddress('glVertexAttrib4ubv');
 if not Assigned(glVertexAttrib4ubv) then exit;
 glVertexAttrib4uiv := GLGetProcAddress('glVertexAttrib4uiv');
 if not Assigned(glVertexAttrib4uiv) then exit;
 glVertexAttrib4usv := GLGetProcAddress('glVertexAttrib4usv');
 if not Assigned(glVertexAttrib4usv) then exit;
 glVertexAttribPointer := GLGetProcAddress('glVertexAttribPointer');
 if not Assigned(glVertexAttribPointer) then exit;
 Result := TRUE;
end;    

//############################################################################//
function glext_ExtensionSupported(const extension,searchIn:string):boolean;
var extensions,start,where,terminator:pchar;
begin
 if(Pos(' ',extension)<>0)or(extension='')then begin result:=FALSE;Exit;end;

 if searchIn='' then extensions:=PChar(glGetString(GL_EXTENSIONS))else extensions:=PChar(searchIn);
 start:=extensions;
 while TRUE do begin
  where:=StrPos(start,pchar(extension));
  if where=nil then Break;
  terminator:=pointer(intptr(where)+dword(length(extension)));
  if(where=start)or(PChar(intptr(where)-1)^=' ')then if(terminator^=' ')or(terminator^=#0)then begin result:=TRUE;Exit;end;
  start:=terminator;
 end;
 result:=FALSE;
end;       
//############################################################################//
function Load_GL_EXT_blend_minmax:boolean;
var extstring: String;
begin
 result:=FALSE;
 extstring:=String(PChar(glGetString(GL_EXTENSIONS)));

 if glext_ExtensionSupported('GL_EXT_blend_minmax', extstring)then begin
  glBlendEquationEXT := GLGetProcAddress('glBlendEquationEXT');
  glBlendColor:= GLGetProcAddress('glBlendColor');
  if not Assigned(glBlendEquationEXT) then Exit;
  result := TRUE;
 end;
end;   
//############################################################################//
function Load_GL_vbo:boolean;
var extstring: String;
begin
 result:=FALSE;
 extstring:=String(PChar(glGetString(GL_EXTENSIONS)));

 if glext_ExtensionSupported('GL_ARB_vertex_buffer_object', extstring)then begin

 
  result:=true;
 end;
end;
//############################################################################//
function Load_GL_ARB_vertex_buffer_object: Boolean;
var extstring: String;
begin

 result := FALSE;
 extstring := String(PChar(glGetString(GL_EXTENSIONS)));

 if glext_ExtensionSupported('GL_ARB_vertex_buffer_object', extstring) then begin
  glBindBufferARB := GLGetProcAddress('glBindBufferARB');
  if not Assigned(glBindBufferARB) then Exit;
  glDeleteBuffersARB := GLGetProcAddress('glDeleteBuffersARB');
  if not Assigned(glDeleteBuffersARB) then Exit;
  glGenBuffersARB := GLGetProcAddress('glGenBuffersARB');
  if not Assigned(glGenBuffersARB) then Exit;
  glIsBufferARB := GLGetProcAddress('glIsBufferARB');
  if not Assigned(glIsBufferARB) then Exit;
  glBufferDataARB := GLGetProcAddress('glBufferDataARB');
  if not Assigned(glBufferDataARB) then Exit;
  glBufferSubDataARB := GLGetProcAddress('glBufferSubDataARB');
  if not Assigned(glBufferSubDataARB) then Exit;
  glGetBufferSubDataARB := GLGetProcAddress('glGetBufferSubDataARB');
  if not Assigned(glGetBufferSubDataARB) then Exit;
  glMapBufferARB := GLGetProcAddress('glMapBufferARB');
  if not Assigned(glMapBufferARB) then Exit;
  glUnmapBufferARB := GLGetProcAddress('glUnmapBufferARB');
  if not Assigned(glUnmapBufferARB) then Exit;
  glGetBufferParameterivARB := GLGetProcAddress('glGetBufferParameterivARB');
  if not Assigned(glGetBufferParameterivARB) then Exit;
  glGetBufferPointervARB := GLGetProcAddress('glGetBufferPointervARB');
  if not Assigned(glGetBufferPointervARB) then Exit;
  result := TRUE;
 end;
end;
//############################################################################//
function EXT_fog_coord_Init:boolean;
var Extension_Name:string;
glextstring:string;
begin
 {$ifdef win32}
 Extension_Name:='EXT_fog_coord';
 glextstring:=glGetString(GL_EXTENSIONS);
 
 if Pos(Extension_Name,glextstring)=0 then begin result:=false;exit;end;
 glFogCoordfEXT:=GLGetProcAddress('glFogCoordfEXT');
 result:=true; 
 {$else} 
 result:=false;
 {$endif}
end;

//############################################################################//

initialization Set8087CW($133F);
finalization CloseOpenGL;
end.  
//############################################################################//

