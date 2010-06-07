//############################################################################//
// Orbiter Visualisation Project OpenGL client
// OGLA rendering system interface
// Released under GNU General Public License
// Made in 2007-2010 by Artlav
//############################################################################//
#ifndef __OGLA_H
#define __OGLA_H
//############################################################################//
//#define no_render
//############################################################################//
struct basetp{
	MESHHANDLE *sbs,*sas;
	DWORD nsbs,nsas;
};
//############################################################################//
struct ogla_interface{
 //In
 void       (__stdcall *initgl)  (HWND hwnd,DWORD *w,DWORD *h,DWORD vd);
 int        (__stdcall *render)  (int fps);
 SURFHANDLE (__stdcall *loadtex) (const char* fnam,DWORD flags);
 bool       (__stdcall *reltex)  (SURFHANDLE s);
 HDC        (__stdcall *getsdc)  (SURFHANDLE s);
 void       (__stdcall *relsdc)  (SURFHANDLE s,HDC dc);
 bool       (__stdcall *gsrfsiz) (SURFHANDLE surf,DWORD *w,DWORD *h);
 SURFHANDLE (__stdcall *maksrf)  (DWORD w,DWORD h,SURFHANDLE tmp,int tp);
 bool       (__stdcall *fillsr)  (SURFHANDLE surf,DWORD tx,DWORD ty,DWORD w,DWORD h,DWORD col);
 void       (__stdcall *out2d)   ();
 void       (__stdcall *firstrun)();
 void       (__stdcall *meshop)  (int tp,DEVMESHHANDLE *hMesh,VISHANDLE vis,SURFHANDLE tex,DWORD grpidx,GROUPEDITSPEC *ges);
 void       (__stdcall *render2D)(SURFHANDLE *hSurf,MESHHANDLE hMesh,MATRIX3 *T,int transparent);
 void       (__stdcall *addps)   (int tp,DWORD es,PARTICLESTREAMSPEC *pss,OBJHANDLE hVessel,const double *lvl,const VECTOR3 *ref,const VECTOR3 *dir);
 bool       (__stdcall *blit)    (int tp,SURFHANDLE tgt,DWORD tgtx,DWORD tgty,DWORD tgtw,DWORD tgth,SURFHANDLE src,DWORD srcx,DWORD srcy,DWORD srcw,DWORD srch,DWORD flag);
 void       (__stdcall *keydown) (WORD k,BYTE sh);
 void       (__stdcall *keyup)   (WORD k,BYTE sh);
 void       (__stdcall *mouse)   (int t,int x,int y,BYTE sh);
 int        (__stdcall *o2_op)   (int,SURFHANDLE,int,int,int,int,const char*,DWORD);
 
 //Out 
 void       (__cdecl *render_font)   (int fntn,char *str,int mode);
 int        (__cdecl *text_width)    (int fntn,char *str);
 DWORD      (__cdecl *getbase)       (OBJHANDLE _hObj);
 void       (__cdecl *visop)         (int op,OBJHANDLE ob,VISHANDLE v);
 SURFHANDLE (__cdecl *vcsurf)        (int op,int n,void* mf);
 void*      (__cdecl *getconfigparam)(DWORD paramtype);
 SURFHANDLE (__cdecl *getmsurf)      (int tp,int p);
 int *font_mode;
 int show_fps;
};
//############################################################################//
basetp cbt;
int pks[256],mbtns[3];
char cshift;
ogla_interface ogla;
//############################################################################//
void (__stdcall *ogla_interface_get)(ogla_interface* ogl);
void (__stdcall *oglacfg_button)();
//############################################################################//
#endif
//############################################################################//

