// ==============================================================
// Scene.h
// Part of the ORBITER VISUALISATION PROJECT (OVP)
// Released under GNU General Public License
// Copyright (C) 2006 Martin Schweiger
// ==============================================================

// ==============================================================
// Class Scene (interface)
//
// A "Scene" represents the 3-D world as seen from a specific
// viewpoint ("camera"). Each scene therefore has a camera object
// associated with it. The Orbiter core supports a single
// camera, but in principle a graphics client could define
// multiple scenes and render them simultaneously into separate
// windows (or into MFD display surfaces, etc.)
// ==============================================================

#ifndef __SCENE_H
#define __SCENE_H

#include "D3D9Client.h"
#include "CelSphere.h"
#include "VObject.h"
#include "Light.h"

class vObject;
class D3D9ParticleStream;

class Scene {
	friend class Camera;

public:
	Scene (oapi::D3D9Client *_gc, DWORD w, DWORD h);
	~Scene ();

	inline const oapi::D3D9Client *GetClient() const { return gc; }
	// return the client

	inline Camera *GetCamera() const { return cam; }
	// return associated camera

	inline bool hasStencil() const { return bDoStencil; }


	inline const DWORD ViewW() const { return viewW; }
	inline const DWORD ViewH() const { return viewH; }
	// return viewport dimensions

	void CheckVisual (OBJHANDLE hObj);
	// checks if hObj is within visual range, and creates or
	// deletes the associated vObject as required.

	void Initialise ();

	void Update ();
	// Update camera position, visuals, etc.

	void Render ();
	// Render the scene

	/**
	 * \brief Render any shadows cast by vessels on planet surfaces
	 * \param hPlanet handle of planet to cast shadows on
	 * \param depth shadow darkness parameter (0=none, 1=black)
	 * \note Uses stencil buffering if available and requested. Otherwise shadows
	 *   are pure black.
	 * \note Requests for any planet other than that closest to the camera
	 *   are ignored.
	 */
	void RenderVesselShadows (OBJHANDLE hPlanet, float depth) const;

	/**

	/**
	 * \brief Create a visual for a new vessel if within visual range.
	 * \param hVessel vessel object handle
	 */
	void NewVessel (OBJHANDLE hVessel);

	/**
	 * \brief Delete a vessel visual prior to destruction of the logical vessel.
	 * \param hVessel vessel object handle
	 */
	void DeleteVessel (OBJHANDLE hVessel);

	void VesselEvent (OBJHANDLE hVessel, DWORD event, void *context);	
	
	void AddParticleStream (D3D9ParticleStream *_pstream);
	void DelParticleStream (DWORD idx);

protected:
	/**
	 * \brief Return a render window device context for drawing markers.
	 * \param mode marker mode
	 * \return Drawing device context
	 */
	HDC GetLabelDC (int mode);

	/**
	 * \brief Render a single marker for a given direction
	 * \param hDC device context
	 * \param rdir normalised direction from camera in global (ecliptic) frame
	 * \param label1 label above marker
	 * \param label2 label below marker
	 * \param mode marker shape
	 * \param scale marker size
	 */
	void RenderDirectionMarker (HDC hDC, const VECTOR3 &rdir, const char *label1, const char *label2, int mode, int scale);

	/**
	 * \brief Render a single marker at a given global position
	 * \param hDC device context
	 * \param gpos global position (ecliptic frame)
	 * \param label1 label above marker
	 * \param label2 label below marker
	 * \param mode marker shape
	 * \param scale marker size
	 */
	void RenderObjectMarker (HDC hDC, const VECTOR3 &gpos, const char *label1, const char *label2, int mode, int scale);

private:
	oapi::D3D9Client *gc;
	LPDIRECT3DDEVICE9 dev;     // render device
	DWORD viewW, viewH;        // render viewport size
	bool bDoStencil;           // stencil buffer enabled
	Camera *cam;               // camera object
	CelestialSphere *csphere;  // celestial sphere background
	DWORD iVCheck;             // index of last object checked for visibility
	DWORD zclearflag;          // z and stencil buffer clear flag
	LPDIRECT3DVERTEXBUFFER9 p2dOverlayBuffer; // Buffer for the 2d GDI overlay
	D3D9ParticleStream **pstream; // list of particle streams
	DWORD                nstream; // number of streams



	D3D7Light *light;          // only one for now

	struct VOBJREC {           // linked list of object visuals
		vObject *vobj;         // visual instance
		VOBJREC *prev, *next;  // previous and next list entry
	} *vobjFirst, *vobjLast;   // first and last list entry

	VOBJREC *FindVisual (OBJHANDLE hObj);
	// Locate the visual for hObj in the list if present, or return
	// NULL if not found

	void DelVisualRec (VOBJREC *pv);
	// Delete entry pv from the list of visuals

	VOBJREC *AddVisualRec (OBJHANDLE hObj);
	// Add an entry for object hObj in the list of visuals

	VECTOR3 SkyColour ();
	// Sky background colour based on atmospheric parameters of closest planet

	// GDI resources
	static COLORREF labelCol[6];
	HPEN hLabelPen[6];
	HFONT hLabelFont[1];
	int labelSize[1];

	void InitGDIResources();
	void ExitGDIResources();
};

#endif // !__SCENE_H