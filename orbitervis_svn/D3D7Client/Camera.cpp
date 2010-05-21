// ==============================================================
// Camera.cpp
// Part of the ORBITER VISUALISATION PROJECT (OVP)
// Released under GNU General Public License
// Copyright (C) 2006 Martin Schweiger
// ==============================================================

// ==============================================================
// Class Camera (implementation)
//
// The camera defines the observer position in the 3D world.
// Each scene consists of a camera and a collection of vObjects
// within visual range around it.
// The "render space" (i.e. the coordinate system in which the
// camera and visual objects live) is translated against the
// "global frame" in which orbiter's logical objects live, such
// that the camera is always at the origin. Global and render
// space have however the same orientation.
// ==============================================================

#include "Camera.h"
#include "OrbiterAPI.h"
#include "D3D7Util.h"

Camera::Camera (LPDIRECT3DDEVICE7 _dev, DWORD w, DWORD h)
{
	dev = _dev;
	viewW = w, viewH = h;
	aspect = (double)h/(double)w;
	SetAperture (RAD*50.0);
	hObj_proxy = 0;

	D3DMAT_Identity (&mView);
	bProjView_valid = false;
	SetFustrumLimits (2.5f, 5e6f); // initial limits
}

const D3DMATRIX *Camera::GetProjectionViewMatrix () const
{
	if (!bProjView_valid) {
		D3DMAT_MatrixMultiply (&mProjView, &mProj, &mView);
		bProjView_valid = true;
	}
	return &mProjView;
}

void Camera::UpdateProjectionMatrix ()
{
	ZeroMemory (&mProj, sizeof(D3DMATRIX));
	mProj._11 = (float)(aspect / tan_ap);
	mProj._22 = (float)(1.0    / tan_ap);
	mProj._43 = (mProj._33 = farplane / (farplane-nearplane)) * (-nearplane);
	mProj._34 = 1.0f;

	// register new projection matrix
	dev->SetTransform (D3DTRANSFORMSTATE_PROJECTION, &mProj);
}

void Camera::SetAperture (double _ap)
{
	ap = _ap;
	tan_ap = tan (ap);
	UpdateProjectionMatrix ();
}

void Camera::SetFustrumLimits (double nearlimit, double farlimit)
{
	nearplane = (float)nearlimit;
	farplane = (float)farlimit;
	UpdateProjectionMatrix ();
}

void Camera::Update ()
{
	if (ap != oapiCameraAperture()) // check aperture
		SetAperture (oapiCameraAperture());

	oapiCameraGlobalPos (&gpos);
	oapiCameraGlobalDir (&gdir);
	oapiCameraRotationMatrix (&grot);
	D3DMAT_SetRotation (&mView, &grot);
	dev->SetTransform (D3DTRANSFORMSTATE_VIEW, &mView);
	bProjView_valid = false;

	// note: in render space, the camera is always placed at the origin,
	// so that render coordinates are precise in the vicinity of the
	// observer (before they are translated into D3D single-precision
	// format). However, the orientation of the render space is the same
	// as orbiter's global coordinate system. Therefore there is a
	// translational transformation between orbiter global coordinates
	// and render coordinates.

	// find the planet closest to the current camera position
	double d, r, alt, ralt, ralt_proxy = 1e100;
	int i, n = oapiGetGbodyCount();
	VECTOR3 ppos;
	for (i = 0; i < n; i++) {
		OBJHANDLE hObj = oapiGetGbodyByIndex (i);
		oapiGetGlobalPos (hObj, &ppos);
		r = oapiGetSize(hObj);
		d = dist(gpos, ppos);
		alt = d - r;
		ralt = alt/r;
		if (ralt < ralt_proxy) {
			ralt_proxy = ralt;
			alt_proxy = alt;
			hObj_proxy = hObj;
		}
	}
}
