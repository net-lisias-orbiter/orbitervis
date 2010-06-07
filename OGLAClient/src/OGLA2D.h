//############################################################################//
// Orbiter Visualisation Project OpenGL client
// 2D system headers
// Released under GNU General Public License
// Made in 2007-2010 by Artlav
//############################################################################//
#ifndef __OGLA2D_H
#define __OGLA2D_H
//############################################################################//
struct glfntrec{
 int weight,height,orientation;
	DWORD italic,underline;
 char *face;
};
//############################################################################//
#ifdef _o2d
int font_mode=1;
#else
extern int font_mode;
#endif
//############################################################################//
void render_font(int fntn,char *str,int mode);
int text_width(int fntn,char *str);
void init_o2d();
//############################################################################//
//############################################################################//
///The OGLAPad class defines the context for Sketchpad 2D drawing using OGLA.
class OGLAPad:public oapi::Sketchpad{
public:
	OGLAPad(SURFHANDLE s,DWORD opfnc,DWORD gdc,DWORD rdc);
	~OGLAPad();
	oapi::Font *SetFont(oapi::Font *font) const;
	oapi::Pen *SetPen(oapi::Pen *pen) const;
	oapi::Brush *SetBrush(oapi::Brush *brush) const;
	
	void SetTextAlign(TAlign_horizontal tah=LEFT,TAlign_vertical tav=TOP);
	DWORD SetTextColor(DWORD col);
	DWORD SetBackgroundColor(DWORD col);
	void SetBackgroundMode(BkgMode mode);
	DWORD GetCharSize();
	DWORD GetTextWidth(const char *str,int len=0);
	
	void SetOrigin(int x,int y);
	bool Text     (int x,int y,const char *str,int len);
	void Pixel    (int x,int y,DWORD col);
	void MoveTo   (int x,int y);
	void LineTo   (int x,int y);
	void Line     (int x0,int y0,int x1,int y1);
	void Rectangle(int x0,int y0,int x1,int y1);
	void Ellipse  (int x0,int y0,int x1,int y1);
	void Polygon  (const oapi::IVECTOR2 *pt,int npt);
	void Polyline (const oapi::IVECTOR2 *pt,int npt);

 HDC GetDC() const;


private:
	UINT txalign;
 int bkmode;
 DWORD txcol,txbcol;
 SURFHANDLE sh;
 int (__stdcall *o2_op) (int tp,SURFHANDLE s,int x0,int y0,int x1,int y1,const char *fnam,DWORD len);       
 HDC (__stdcall *getsdc)(SURFHANDLE s);
 void(__stdcall *relsdc)(SURFHANDLE s,HDC dc);
 HDC dc;

	mutable oapi::Font *cfont;   ///currently selected font(NULL if none)
	mutable oapi::Pen *cpen;     ///currently selected pen(NULL if none)
	mutable oapi::Brush *cbrush; ///currently selected brush(NULL if none)
};
//############################################################################//
//############################################################################//
class OGLAFont:public oapi::Font{
friend class OGLAPad;
public:
	OGLAFont(int height,bool prop,char *face,Style style=NORMAL,int orientation=0);
	~OGLAFont();
	
 //FTPolygonFont *ftfnt; //Syntax eroorr... WHHYYY???
 int fntn;
 int fnt_height;
 glfntrec fnt;
};
//############################################################################//
//############################################################################//
class OGLAPen:public oapi::Pen{
friend class OGLAPad;
public:
	OGLAPen(int style,int width,DWORD col);
	~OGLAPen();

	int pstyle,pwidth;
 DWORD pcol;
};
//############################################################################//
//############################################################################//
class OGLABrush:public oapi::Brush{
friend class OGLAPad;
public:
	OGLABrush(DWORD col);
	~OGLABrush();

 DWORD pcol;
};
//############################################################################//
#endif
//############################################################################//
