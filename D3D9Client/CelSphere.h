// ==============================================================
// CelSphere.h
// Part of the ORBITER VISUALISATION PROJECT (OVP)
// Released under GNU General Public License
// Copyright (C) 2006-2007 Martin Schweiger
// ==============================================================

// ==============================================================
// Class CelestialSphere (interface)
//
// This class is responsible for rendering the celestial sphere
// background (stars, constellations, grids, labels, etc.)
// ==============================================================

#ifndef __CELSPHERE_H
#define __CELSPHERE_H

#include "D3D9Client.h"
#include "D3D9Util.h"

#define D3DMAXNUMVERTICES 10000		// This should be dynamic

/**
 * \brief Rendering methods for the background celestial sphere.
 *
 * Loads star and constellation information from data bases and uses them to
 * celestial sphere background.
 */
class CelestialSphere {
public:
	CelestialSphere (oapi::D3D9Client *_gc);
	~CelestialSphere ();

	/**
	 * \brief Render stars as pixels on the celestial sphere
	 * \param dev render device
	 * \param nmax max. number of stars (default is all available stars)
	 * \param bgcol pointer to background color (default is black)
	 * \note If a background colour is passed into this function, the rendering
	 *   of stars darker than the background is suppressed.
	 * \note All device parameters are assumed to be set correctly on call.
	 */
	void RenderStars (LPDIRECT3DDEVICE9 dev, DWORD nmax = (DWORD)-1, const VECTOR3 *bgcol = 0);

	/**
	 * \brief Render constellation lines on the celestial sphere
	 * \param dev render device
	 * \param col line colour
	 * \note All device parameters are assumed to be set correctly on call.
	 * \note Suggestion: render additively onto background, so that the lines
	 *   are never darker than the background sky.
	 */
	void RenderConstellations (LPDIRECT3DDEVICE9 dev, VECTOR3 &col);

	/**
	 * \brief Render a great circle on the celestial sphere in a given colour.
	 * \param dev render device
	 * \param col RGB line colour (0..1 for each component)
	 * \note By default (i.e. for identity world matrix), the circle is
	 *   drawn along the plane of the ecliptic. To render a circle in any
	 *   other orientation, the world matrix must be adjusted accordingly
	 *   before the call.
	 */
	void RenderGreatCircle (LPDIRECT3DDEVICE9 dev, VECTOR3 &col);

	/**
	 * \brief Render grid lines on the celestial sphere in a given colour.
	 * \param dev render device
	 * \param col RGB line colour (0..1 for each component)
	 * \param eqline indicates if the equator line should be drawn
	 * \note By default (i.e. for identity world matrix), this draws the
	 *   ecliptic grid. To render a grid for any other reference frame,
	 *   the world matrix must be adjusted accordingly before call.
	 * \note If eqline==false, then the latitude=0 line is not drawn.
	 *   This is useful if the line should be drawn in a different colour
	 *   with RenderGreatCircle().
	 */
	void RenderGrid (LPDIRECT3DDEVICE9 dev, VECTOR3 &col, bool eqline = true);

	/**
	 * \brief Number of stars loaded from the data base
	 * \return Number of stars available
	 */
	inline DWORD NStar() const { return nstar; }

protected:
	void LoadStars ();
	// Load star coordinates from file

	void LoadConstellationLines ();
	// Load constellation line data from file

	void AllocGrids ();
	// Allocate vertex list for rendering grid lines
	// (e.g. celestial or ecliptic)

private:
	oapi::D3D9Client *gc;
	float sphere_r;       // render radius for celestial sphere
	DWORD nsbuf;          // number of vertex buffers for star positions
	DWORD nstar;          // total number of stars across all buffers
	LPDIRECT3DVERTEXBUFFER9 *svtx; // star vertex buffers
	int lvlid[256];       // star brightness hash table
	DWORD ncline;         // number of constellation lines
	VERTEX_XYZ  *cnstvtx; // vertex list of constellation lines
	LPDIRECT3DVERTEXBUFFER9 grdlng, grdlat; // vertex buffers for grid lines
};

#endif // !__CELSPHERE_H