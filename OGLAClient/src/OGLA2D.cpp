//############################################################################//
// Orbiter Visualisation Project OpenGL client
// 2D system
// Released under GNU General Public License
// Made in 2007-2010 by Artlav
//############################################################################//
#include "orbitersdk.h"
#include <FTGL/ftgl.h>
#define _o2d
#include "OGLA2D.h"
using namespace oapi;
//############################################################################//
char windir[1024];
FTFont* ftfnt[100];
//############################################################################//
void init_o2d()
{
 GetWindowsDirectory(windir,1024);
 strcat(windir,"\\fonts\\");
 int i;
 for(i=0;i<100;i++)ftfnt[i]=NULL;
} 
//############################################################################//
void render_font(int fntn,char *str)
{
 if(fntn!=-1)ftfnt[fntn]->Render(str);
}
//############################################################################//
int text_width(int fntn,char *str)
{
 if(fntn!=-1)return ftfnt[fntn]->Advance(str);else return 1;
}
//############################################################################//
//############################################################################//
//############################################################################//
OGLAPad::OGLAPad(SURFHANDLE s,DWORD opfnc):Sketchpad(s)
{
 cfont =NULL;
 cpen  =NULL;
 cbrush=NULL;

 sh=s;
 bkmode=0;
 o2_op=(int(__stdcall *)(int,SURFHANDLE,int,int,int,int,const char*,DWORD))opfnc;
 
 o2_op(99,sh,bkmode,0,0,0,0,0);
 // Default initial drawing settings
 // transparent text background
 // no fill
 // no outline
}
OGLAPad::~OGLAPad(){o2_op(98,sh,0,0,0,0,0,0);}
//############################################################################//
Font *OGLAPad::SetFont(Font *font)const
{
 Font *tf=cfont;
 if(font==NULL)o2_op(17,sh,0,0,1,0,0,0);
          else o2_op(17,sh,((OGLAFont*)font)->fntn,0,0,0,0,((OGLAFont*)font)->fnt_height);
 cfont=font;
 return tf;
}
Pen *OGLAPad::SetPen(Pen *pen)const
{
 Pen *tp=cpen;
 if(pen==NULL)o2_op(11,sh,0,1,1,0,0,0);
         else o2_op(11,sh,((OGLAPen*)pen)->pstyle,((OGLAPen*)pen)->pwidth,0,0,0,((OGLAPen*)pen)->pcol);
 cpen=pen;
 return tp;
}
Brush *OGLAPad::SetBrush(Brush *brush)const
{
 Brush *tb=cbrush;
 if(brush==NULL)o2_op(12,sh,0,0,1,0,0,0);
           else o2_op(12,sh,0,0,0,0,0,((OGLABrush*)brush)->pcol);
 cbrush=brush;
 return tb;
}
//############################################################################//
void OGLAPad::SetTextAlign(TAlign_horizontal tah,TAlign_vertical tav)
{
 UINT alignv=0,alignh=0;
 switch(tah){
  case LEFT:    alignh=0;break;
  case CENTER:  alignh=1;break;
  case RIGHT:   alignh=2;break;
 }
 switch(tav){
  case TOP:     alignv=0;break;
  case BASELINE:alignv=1;break;
  case BOTTOM:  alignv=2;break;
 }
 o2_op(20,sh,alignh,alignv,0,0,0,0);
}
DWORD OGLAPad::SetTextColor(DWORD col)
{
 DWORD pc=txcol;
 o2_op(15,sh,0,0,0,0,0,col);
 txcol=col;
 return pc;
}
DWORD OGLAPad::SetBackgroundColor(DWORD col)
{
 DWORD pc=txbcol;
 o2_op(16,sh,0,0,0,0,0,col);
 txbcol=col;
 return pc;
}
void  OGLAPad::SetBackgroundMode(BkgMode mode)
{
 switch(mode){
  case BK_TRANSPARENT:bkmode=0;break;
  case BK_OPAQUE:     bkmode=1;break;
 }
}
DWORD OGLAPad::GetCharSize(){return o2_op(19,sh,0,0,0,0,0,0);}
DWORD OGLAPad::GetTextWidth(const char *str){return o2_op(18,sh,0,0,0,0,str,0);}
void  OGLAPad::SetOrigin(int x,int y){o2_op(14,sh,x,y,0,0,0,0);}
//############################################################################//
bool OGLAPad::Text     (int x ,int y,const char *str,int len){return (o2_op(0,sh,x ,y ,0,0,str,len)!=0);}
void OGLAPad::MoveTo   (int x ,int y)                        {        o2_op(1,sh,x ,y ,0,0,0,0);}
void OGLAPad::LineTo   (int x ,int y)                        {        o2_op(2,sh,x ,y ,0,0,0,0);}
void OGLAPad::Pixel    (int x ,int y,DWORD col)              {        o2_op(8,sh,x ,y ,0,0,0,0);}
void OGLAPad::Line     (int x0,int y0,int x1,int y1)         {        o2_op(3,sh,x0,y0,x1,y1,0,0);}
void OGLAPad::Rectangle(int x0,int y0,int x1,int y1)         {        o2_op(4,sh,x0,y0,x1,y1,0,0);}
void OGLAPad::Ellipse  (int x0,int y0,int x1,int y1)         {        o2_op(5,sh,x0,y0,x1,y1,0,0);}
//############################################################################//
void OGLAPad::Polygon (const IVECTOR2 *pt,int npt){o2_op(6,sh,npt,0,0,0,0,(DWORD)pt);}
void OGLAPad::Polyline(const IVECTOR2 *pt,int npt){o2_op(7,sh,npt,0,0,0,0,(DWORD)pt);}
//############################################################################//
//############################################################################//
//############################################################################//
OGLAFont::OGLAFont(int height,bool prop,char *face,Style style,int orientation):oapi::Font(height,prop,face,style,orientation)
{
 char facei[1024];
  
 char *def_fixedface="cour.ttf";
 char *def_sansface ="arial.ttf";
 char *def_serifface="times.ttf";

      if(!_stricmp(face,"fixed"))      {face=def_fixedface;}
 else if(!_stricmp(face,"sans" ))      {face=def_sansface;}
 else if(!_stricmp(face,"serif"))      {face=def_serifface;}
 else if(_stricmp(face,def_fixedface)&&
         _stricmp(face,def_sansface)&&
         _stricmp(face,def_serifface)) {face=(prop?def_sansface:def_fixedface);}
        
 strcpy(facei,windir);
 strcat(facei,face);

 int weight=(style & BOLD ? FW_BOLD : FW_NORMAL);
 DWORD italic=(style & ITALIC ? TRUE : FALSE);
 DWORD underline=(style & UNDERLINE ? TRUE : FALSE);

 fnt_height=height;
 
 fnt.height=height;
 fnt.face=face;
 fnt.orientation=orientation;
 fnt.weight=weight;
 fnt.italic=italic;
 fnt.underline=underline;
 
 int i;
 for(i=0;i<100;i++)if(!ftfnt[i]){fntn=i;break;}
 if(font_mode==0)ftfnt[fntn]=new FTGLTextureFont(facei); 
 if(font_mode==1)ftfnt[fntn]=new FTBufferFont(facei);
 if(font_mode==2)ftfnt[fntn]=new FTGLPolygonFont(facei); 
 if(font_mode==3)ftfnt[fntn]=new FTGLBitmapFont(facei); 
 if(ftfnt[fntn]->Error())return;
 ftfnt[fntn]->FaceSize(abs(height));
}
//############################################################################//
OGLAFont::~OGLAFont(){ftfnt[fntn]->~FTFont();ftfnt[fntn]=NULL;} 
//############################################################################//
//############################################################################//
OGLAPen::OGLAPen(int style,int width,DWORD col):oapi::Pen (style,width,col)
{
 switch(style){
  case 0: pstyle=0;break;
  case 2: pstyle=1;break;
  default:pstyle=1;break;
 }
 pwidth=width;
 pcol=col;
}
OGLAPen::~OGLAPen(){}
//############################################################################//
//############################################################################//
OGLABrush::OGLABrush(DWORD col):oapi::Brush(col){pcol=col;}
OGLABrush::~OGLABrush(){}
//############################################################################//
