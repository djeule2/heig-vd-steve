--
-- OpenGL 1.1 Ada binding, package GLU
--
-- W. M. Richards, NiEstu, Phoenix AZ, December 1997
-- 
-- Converted from Brian Paul's Mesa package glu.h header file, version 2,5.
-- As noted below in Brian's original comments, this code is distributed
-- under the terms of the GNU Library General Public License.
--
-- Version 0.1, 21 December 1997
--
--
-- Here are the original glu.h comments:
--
-- Mesa 3-D graphics library
-- Version:  2.4
-- Copyright (C) 1995-1997  Brian Paul
--
-- This library is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Library General Public
-- License as published by the Free Software Foundation; either
-- version 2 of the License, or (at your option) any later version.
--
-- This library is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- Library General Public License for more details.
--
-- You should have received a copy of the GNU Library General Public
-- License along with this library; if not, write to the Free
-- Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
--


with Interfaces.C;

with GL;
use  GL;


package GLU is

GLU_VERSION_1_1                     : constant := 1;


-- The GLU boolean constants
GLU_FALSE                           : constant := GL_FALSE;
GLU_TRUE                            : constant := GL_TRUE;

------------------------------------------------------------------------------

type GLviewPortRec      is record
   X, Y:           aliased GLint;
   Width, Height:  aliased GLint;
end record;

type GLfloatMatrix      is array ( 0..3, 0..3 ) of GLfloat;
type GLdoubleMatrix     is array ( 0..3, 0..3 ) of GLdouble;

type GLviewPortRecPtr   is access all GLviewPortRec;
type GLfloatMatrixPtr   is access all GLfloatMatrix;
type GLdoubleMatrixPtr  is access all GLdoubleMatrix;

type GLUquadricObj      is private;
type GLUtriangulatorObj is private;
type GLUnurbsObj        is private;

type GLUquadricObjPtr      is access all GLUquadricObj;
type GLUtriangulatorObjPtr is access all GLUtriangulatorObj;
type GLUnurbsObjPtr        is access all GLUnurbsObj;

------------------------------------------------------------------------------


-- Error string
type ErrorEnm is
(
   GL_NO_ERROR,
   GL_INVALID_ENUM,
   GL_INVALID_VALUE,
   GL_INVALID_OPERATION,
   GL_STACK_OVERFLOW,
   GL_STACK_UNDERFLOW,
   GL_OUT_OF_MEMORY,
   GLU_INVALID_ENUM,
   GLU_INVALID_VALUE,
   GLU_OUT_OF_MEMORY,
   GLU_INCOMPATIBLE_GL_VERSION
);
for ErrorEnm use
(
   GL_NO_ERROR                                => 16#0000#,
   GL_INVALID_ENUM                            => 16#0500#,
   GL_INVALID_VALUE                           => 16#0501#,
   GL_INVALID_OPERATION                       => 16#0502#,
   GL_STACK_OVERFLOW                          => 16#0503#,
   GL_STACK_UNDERFLOW                         => 16#0504#,
   GL_OUT_OF_MEMORY                           => 16#0505#,
   GLU_INVALID_ENUM                           => 16#18A24#,
   GLU_INVALID_VALUE                          => 16#18A25#,
   GLU_OUT_OF_MEMORY                          => 16#18A26#,
   GLU_INCOMPATIBLE_GL_VERSION                => 16#18A27#  -- Mesa-specific?
);
for ErrorEnm'Size use GLenum'size;

function gluErrorString (errorCode: ErrorEnm)
return GLubytePtr;


-- Scale image
function gluScaleImage (format   : PixelFormatEnm;
                        widthin  : GLint;
                        heightin : GLint;
                        typein   : PixelDataTypeEnm;
                        datain   : GLpointer;
                        widthout : GLint;
                        heightout: GLint;
                        typeout  : PixelDataTypeEnm;
                        dataout  : GLpointer)
return GLint;


-- Build mipmaps
function gluBuild1DMipmaps (target    : TargetTex1DOnlyEnm;
                            components: GLint;
                            width     : GLint;
                            format    : TexPixelFormatEnm;
                            c_type    : PixelDataTypeEnm;
                            data      : GLpointer)
return GLint;

function gluBuild2DMipmaps (target    : TargetTex2DOnlyEnm;
                            components: GLint;
                            width     : GLint;
                            height    : GLint;
                            format    : TexPixelFormatEnm;
                            c_type    : PixelDataTypeEnm;
                            data      : GLpointer)
return GLint;


-- Quadric objects
type DrawStyleEnm is
(
   GLU_POINT,
   GLU_LINE,
   GLU_FILL,
   GLU_SILHOUETTE
);
for DrawStyleEnm use
(
   GLU_POINT                                  => 16#186AA#,
   GLU_LINE                                   => 16#186AB#,
   GLU_FILL                                   => 16#186AC#,
   GLU_SILHOUETTE                             => 16#186AD#
);
for DrawStyleEnm'Size use GLenum'size;

type OrientationEnm is
(
   GLU_OUTSIDE,
   GLU_INSIDE
);
for OrientationEnm use
(
   GLU_OUTSIDE                                => 16#186B4#,
   GLU_INSIDE                                 => 16#186B5#
);
for OrientationEnm'Size use GLenum'size;

type NormalsEnm is
(
   GLU_SMOOTH,
   GLU_FLAT,
   GLU_NONE
);
for NormalsEnm use
(
   GLU_SMOOTH                                 => 16#186A0#,
   GLU_FLAT                                   => 16#186A1#,
   GLU_NONE                                   => 16#186A2#
);
for NormalsEnm'Size use GLenum'size;

type CallbackEnm is
(
   GLU_ERROR
);
for CallbackEnm use
(
   GLU_ERROR                                  => 16#18707#
);
for CallbackEnm'Size use GLenum'size;

type QuadricCallbackFunction is access procedure (Error:  ErrorEnm);

function gluNewQuadric
return GLUquadricObjPtr;

procedure gluDeleteQuadric (state: GLUquadricObjPtr);

procedure gluQuadricDrawStyle (quadObject: GLUquadricObjPtr;
                               drawStyle : DrawStyleEnm);

procedure gluQuadricOrientation (quadObject : GLUquadricObjPtr;
                                 orientation: OrientationEnm);

procedure gluQuadricNormals (quadObject: GLUquadricObjPtr;
                             normals   : NormalsEnm);

procedure gluQuadricTexture (quadObject   : GLUquadricObjPtr;
                             textureCoords: GLboolean);

procedure gluQuadricCallback (qobj : GLUquadricObjPtr;
                              which: CallbackEnm;
                              fn   : QuadricCallbackFunction);

procedure gluCylinder (qobj      : GLUquadricObjPtr;
                       baseRadius: GLdouble;
                       topRadius : GLdouble;
                       height    : GLdouble;
                       slices    : GLint;
                       stacks    : GLint);

procedure gluSphere (qobj  : GLUquadricObjPtr;
                     radius: GLdouble;
                     slices: GLint;
                     stacks: GLint);

procedure gluDisk (qobj       : GLUquadricObjPtr;
                   innerRadius: GLdouble;
                   outerRadius: GLdouble;
                   slices     : GLint;
                   loops      : GLint);

procedure gluPartialDisk (qobj       : GLUquadricObjPtr;
                          innerRadius: GLdouble;
                          outerRadius: GLdouble;
                          slices     : GLint;
                          loops      : GLint;
                          startAngle : GLdouble;
                          sweepAngle : GLdouble);


-- Non-uniform rational B-splines (NURBS)
type NurbsPropertyEnm is
(
   GLU_AUTO_LOAD_MATRIX,
   GLU_CULLING,
   GLU_PARAMETRIC_TOLERANCE,
   GLU_SAMPLING_TOLERANCE,
   GLU_DISPLAY_MODE,
   GLU_SAMPLING_METHOD,
   GLU_U_STEP,
   GLU_V_STEP
);
for NurbsPropertyEnm use
(
   GLU_AUTO_LOAD_MATRIX                       => 16#18768#,
   GLU_CULLING                                => 16#18769#,
   GLU_PARAMETRIC_TOLERANCE                   => 16#1876A#,
   GLU_SAMPLING_TOLERANCE                     => 16#1876B#,
   GLU_DISPLAY_MODE                           => 16#1876C#,
   GLU_SAMPLING_METHOD                        => 16#1876D#,
   GLU_U_STEP                                 => 16#1876E#,
   GLU_V_STEP                                 => 16#1876F#
);
for NurbsPropertyEnm'Size use GLenum'size;

type NurbsDisplayModeEnm is
(
   GLU_FILL,
   GLU_OUTLINE_POLYGON,
   GLU_OUTLINE_PATCH
);
for NurbsDisplayModeEnm use
(
   GLU_FILL                                   => 16#186AC#,
   GLU_OUTLINE_POLYGON                        => 16#18790#,
   GLU_OUTLINE_PATCH                          => 16#18791#
);
for NurbsDisplayModeEnm'Size use GLenum'size;

-- NURBS property values
GLU_PATH_LENGTH                     : constant := 16#18777#;
GLU_PARAMETRIC_ERROR                : constant := 16#18778#;
GLU_DOMAIN_DISTANCE                 : constant := 16#18779#;

type NurbsErrorEnm is
(
   GLU_NURBS_ERROR1,                                       -- spline order un-supported ,
   GLU_NURBS_ERROR2,                                       -- too few knots ,
   GLU_NURBS_ERROR3,                                       -- valid knot range is empty ,
   GLU_NURBS_ERROR4,                                       -- decreasing knot sequence ,
   GLU_NURBS_ERROR5,                                       -- knot multiplicity > spline order ,
   GLU_NURBS_ERROR6,                                       -- endcurve() must follow bgncurve() ,
   GLU_NURBS_ERROR7,                                       -- bgncurve() must precede endcurve() ,
   GLU_NURBS_ERROR8,                                       -- ctrlarray or knot vector is NULL ,
   GLU_NURBS_ERROR9,                                       -- can't draw pwlcurves ,
   GLU_NURBS_ERROR10,                                      -- missing gluNurbsCurve() ,
   GLU_NURBS_ERROR11,                                      -- missing gluNurbsSurface() ,
   GLU_NURBS_ERROR12,                                      -- endtrim() must precede endsurface() ,
   GLU_NURBS_ERROR13,                                      -- bgnsurface() must precede endsurface() ,
   GLU_NURBS_ERROR14,                                      -- curve of improper type passed as trim curve ,
   GLU_NURBS_ERROR15,                                      -- bgnsurface() must precede bgntrim() ,
   GLU_NURBS_ERROR16,                                      -- endtrim() must follow bgntrim() ,
   GLU_NURBS_ERROR17,                                      -- bgntrim() must precede endtrim(),
   GLU_NURBS_ERROR18,                                      -- invalid or missing trim curve,
   GLU_NURBS_ERROR19,                                      -- bgntrim() must precede pwlcurve() ,
   GLU_NURBS_ERROR20,                                      -- pwlcurve referenced twice,
   GLU_NURBS_ERROR21,                                      -- pwlcurve and nurbscurve mixed ,
   GLU_NURBS_ERROR22,                                      -- improper usage of trim data type ,
   GLU_NURBS_ERROR23,                                      -- nurbscurve referenced twice ,
   GLU_NURBS_ERROR24,                                      -- nurbscurve and pwlcurve mixed ,
   GLU_NURBS_ERROR25,                                      -- nurbssurface referenced twice ,
   GLU_NURBS_ERROR26,                                      -- invalid property ,
   GLU_NURBS_ERROR27,                                      -- endsurface() must follow bgnsurface() ,
   GLU_NURBS_ERROR28,                                      -- intersecting or misoriented trim curves ,
   GLU_NURBS_ERROR29,                                      -- intersecting trim curves ,
   GLU_NURBS_ERROR30,                                      -- UNUSED ,
   GLU_NURBS_ERROR31,                                      -- unconnected trim curves ,
   GLU_NURBS_ERROR32,                                      -- unknown knot error ,
   GLU_NURBS_ERROR33,                                      -- negative vertex count encountered ,
   GLU_NURBS_ERROR34,                                      -- negative byte-stride ,
   GLU_NURBS_ERROR35,                                      -- unknown type descriptor ,
   GLU_NURBS_ERROR36,                                      -- null control point reference ,
   GLU_NURBS_ERROR37                                       -- duplicate point on pwlcurve 
);
for NurbsErrorEnm use
(
   GLU_NURBS_ERROR1                           => 16#1879B#,
   GLU_NURBS_ERROR2                           => 16#1879C#,
   GLU_NURBS_ERROR3                           => 16#1879D#,
   GLU_NURBS_ERROR4                           => 16#1879E#,
   GLU_NURBS_ERROR5                           => 16#1879F#,
   GLU_NURBS_ERROR6                           => 16#187A0#,
   GLU_NURBS_ERROR7                           => 16#187A1#,
   GLU_NURBS_ERROR8                           => 16#187A2#,
   GLU_NURBS_ERROR9                           => 16#187A3#,
   GLU_NURBS_ERROR10                          => 16#187A4#,
   GLU_NURBS_ERROR11                          => 16#187A5#,
   GLU_NURBS_ERROR12                          => 16#187A6#,
   GLU_NURBS_ERROR13                          => 16#187A7#,
   GLU_NURBS_ERROR14                          => 16#187A8#,
   GLU_NURBS_ERROR15                          => 16#187A9#,
   GLU_NURBS_ERROR16                          => 16#187AA#,
   GLU_NURBS_ERROR17                          => 16#187AB#,
   GLU_NURBS_ERROR18                          => 16#187AC#,
   GLU_NURBS_ERROR19                          => 16#187AD#,
   GLU_NURBS_ERROR20                          => 16#187AE#,
   GLU_NURBS_ERROR21                          => 16#187AF#,
   GLU_NURBS_ERROR22                          => 16#187B0#,
   GLU_NURBS_ERROR23                          => 16#187B1#,
   GLU_NURBS_ERROR24                          => 16#187B2#,
   GLU_NURBS_ERROR25                          => 16#187B3#,
   GLU_NURBS_ERROR26                          => 16#187B4#,
   GLU_NURBS_ERROR27                          => 16#187B5#,
   GLU_NURBS_ERROR28                          => 16#187B6#,
   GLU_NURBS_ERROR29                          => 16#187B7#,
   GLU_NURBS_ERROR30                          => 16#187B8#,
   GLU_NURBS_ERROR31                          => 16#187B9#,
   GLU_NURBS_ERROR32                          => 16#187BA#,
   GLU_NURBS_ERROR33                          => 16#187BB#,
   GLU_NURBS_ERROR34                          => 16#187BC#,
   GLU_NURBS_ERROR35                          => 16#187BD#,
   GLU_NURBS_ERROR36                          => 16#187BE#,
   GLU_NURBS_ERROR37                          => 16#187BF#
);
for NurbsErrorEnm'Size use GLenum'size;

type PwlCurveTypeEnm is
(
   GLU_MAP1_TRIM_2,
   GLU_MAP1_TRIM_3
);
for PwlCurveTypeEnm use
(
   GLU_MAP1_TRIM_2                            => 16#18772#,
   GLU_MAP1_TRIM_3                            => 16#18773#
);
for PwlCurveTypeEnm'Size use GLenum'size;

type NurbsCallbackFunction is access procedure (Error:  NurbsErrorEnm);

function gluNewNurbsRenderer
return GLUnurbsObjPtr;

procedure gluDeleteNurbsRenderer (nobj: GLUnurbsObjPtr);

procedure gluLoadSamplingMatrices (nobj       : GLUnurbsObjPtr;
                                   modelMatrix: GLfloatMatrixPtr;
                                   projMatrix : GLfloatMatrixPtr;
                                   viewport   : GLviewPortRecPtr);

procedure gluNurbsProperty (nobj    : GLUnurbsObjPtr;
                            property: NurbsPropertyEnm;
                            value   : GLfloat);

procedure gluGetNurbsProperty (nobj    : GLUnurbsObjPtr;
                               property: NurbsPropertyEnm;
                               value   : GLfloatPtr);

procedure gluBeginCurve (nobj: GLUnurbsObjPtr);

procedure gluEndCurve (nobj: GLUnurbsObjPtr);

procedure gluNurbsCurve (nobj    : GLUnurbsObjPtr;
                         nknots  : GLint;
                         knot    : GLfloatPtr;
                         stride  : GLint;
                         ctlarray: GLfloatPtr;
                         order   : GLint;
                         c_type  : Map1TargetEnm);

procedure gluBeginSurface (nobj: GLUnurbsObjPtr);

procedure gluEndSurface (nobj: GLUnurbsObjPtr);

procedure gluNurbsSurface (nobj       : GLUnurbsObjPtr;
                           sknot_count: GLint;
                           sknot      : GLfloatPtr;
                           tknot_count: GLint;
                           tknot      : GLfloatPtr;
                           s_stride   : GLint;
                           t_stride   : GLint;
                           ctlarray   : GLfloatPtr;
                           sorder     : GLint;
                           torder     : GLint;
                           c_type     : Map2TargetEnm);

procedure gluBeginTrim (nobj: GLUnurbsObjPtr);

procedure gluEndTrim (nobj: GLUnurbsObjPtr);

procedure gluPwlCurve (nobj   : GLUnurbsObjPtr;
                       count  : GLint;
                       c_array: GLfloatPtr;
                       stride : GLint;
                       c_type : PwlCurveTypeEnm);

procedure gluNurbsCallback (nobj : GLUnurbsObjPtr;
                            which: CallbackEnm;
                            fn   : NurbsCallbackFunction);


-- Polygon tesselation
type TessCallbackEnm is
(
   GLU_BEGIN,
   GLU_VERTEX,
   GLU_END,
   GLU_ERROR,
   GLU_EDGE_FLAG
);
for TessCallbackEnm use
(
   GLU_BEGIN                                  => 16#18704#,  -- Note: some implementations use "GLU_TESS_..."
   GLU_VERTEX                                 => 16#18705#,
   GLU_END                                    => 16#18706#,
   GLU_ERROR                                  => 16#18707#,
   GLU_EDGE_FLAG                              => 16#18708#
);
for TessCallbackEnm'Size use GLenum'size;

type TessBeginEnm is
(
   GL_LINE_LOOP,
   GL_TRIANGLES,
   GL_TRIANGLE_STRIP,
   GL_TRIANGLE_FAN
);
for TessBeginEnm use
(
   GL_LINE_LOOP                               => 16#0002#,
   GL_TRIANGLES                               => 16#0004#,
   GL_TRIANGLE_STRIP                          => 16#0005#,
   GL_TRIANGLE_FAN                            => 16#0006#
);
for TessBeginEnm'Size use GLenum'size;
type TessBeginCallbackFunction is access procedure (ObjType:  TessBeginEnm);

type TessVertexCallbackFunction is access procedure (VertexData:  GLpointer);

type TessEndCallbackFunction is access procedure;

type TessErrorEnm is
(
   GLU_TESS_ERROR1,                                        -- missing gluEndPolygon ,
   GLU_TESS_ERROR2,                                        -- missing gluBeginPolygon ,
   GLU_TESS_ERROR3,                                        -- misoriented contour ,
   GLU_TESS_ERROR4,                                        -- vertex/edge intersection ,
   GLU_TESS_ERROR5,                                        -- misoriented or self-intersecting loops ,
   GLU_TESS_ERROR6,                                        -- coincident vertices ,
   GLU_TESS_ERROR7,                                        -- all vertices collinear ,
   GLU_TESS_ERROR8,                                        -- intersecting edges ,
   GLU_TESS_ERROR9                                         -- not coplanar contours 
);
for TessErrorEnm use
(
   GLU_TESS_ERROR1                            => 16#18737#,
   GLU_TESS_ERROR2                            => 16#18738#,
   GLU_TESS_ERROR3                            => 16#18739#,
   GLU_TESS_ERROR4                            => 16#1873A#,
   GLU_TESS_ERROR5                            => 16#1873B#,
   GLU_TESS_ERROR6                            => 16#1873C#,
   GLU_TESS_ERROR7                            => 16#1873D#,
   GLU_TESS_ERROR8                            => 16#1873E#,
   GLU_TESS_ERROR9                            => 16#1873F#
);
for TessErrorEnm'Size use GLenum'size;
type TessErrorCallbackFunction is access procedure (Error:  TessErrorEnm);

type TessEdgeFlagCallbackFunction is access procedure (Flag:  GLboolean);

type ContourTypeEnm is
(
   GLU_CW,
   GLU_CCW,
   GLU_INTERIOR,
   GLU_EXTERIOR,
   GLU_UNKNOWN
);
for ContourTypeEnm use
(
   GLU_CW                                     => 16#18718#,
   GLU_CCW                                    => 16#18719#,
   GLU_INTERIOR                               => 16#1871A#,
   GLU_EXTERIOR                               => 16#1871B#,
   GLU_UNKNOWN                                => 16#1871C#
);
for ContourTypeEnm'Size use GLenum'size;

function gluNewTess
return GLUtriangulatorObjPtr;

procedure gluTessCallback (tobj : GLUtriangulatorObjPtr;
                           which: TessCallbackEnm;
                           fn   : TessBeginCallbackFunction);
procedure gluTessCallback (tobj : GLUtriangulatorObjPtr;
                           which: TessCallbackEnm;
                           fn   : TessVertexCallbackFunction);
procedure gluTessCallback (tobj : GLUtriangulatorObjPtr;
                           which: TessCallbackEnm;
                           fn   : TessEndCallbackFunction);
procedure gluTessCallback (tobj : GLUtriangulatorObjPtr;
                           which: TessCallbackEnm;
                           fn   : TessErrorCallbackFunction);
procedure gluTessCallback (tobj : GLUtriangulatorObjPtr;
                           which: TessCallbackEnm;
                           fn   : TessEdgeFlagCallbackFunction);

procedure gluDeleteTess (tobj: GLUtriangulatorObjPtr);

procedure gluBeginPolygon (tobj: GLUtriangulatorObjPtr);

procedure gluEndPolygon (tobj: GLUtriangulatorObjPtr);

procedure gluNextContour (tobj  : GLUtriangulatorObjPtr;
                          c_type: ContourTypeEnm);

procedure gluTessVertex (tobj: GLUtriangulatorObjPtr;
                         v   : GLdoublePtr;
                         data: GLpointer);


-- GLU strings
type StringEnm is
(
   GLU_VERSION,
   GLU_EXTENSIONS
);
for StringEnm use
(
   GLU_VERSION                                => 16#189C0#,
   GLU_EXTENSIONS                             => 16#189C1#
);
for StringEnm'Size use GLenum'size;

function gluGetString (name: StringEnm)
return GLubytePtr;


-- Projections
procedure gluLookAt (eyex   : GLdouble;
                     eyey   : GLdouble;
                     eyez   : GLdouble;
                     centerx: GLdouble;
                     centery: GLdouble;
                     centerz: GLdouble;
                     upx    : GLdouble;
                     upy    : GLdouble;
                     upz    : GLdouble);

procedure gluOrtho2D (left  : GLdouble;
                      right : GLdouble;
                      bottom: GLdouble;
                      top   : GLdouble);

procedure gluPerspective (fovy  : GLdouble;
                          aspect: GLdouble;
                          zNear : GLdouble;
                          zFar  : GLdouble);

procedure gluPickMatrix (x       : GLdouble;
                         y       : GLdouble;
                         width   : GLdouble;
                         height  : GLdouble;
                         viewport: GLviewPortRecPtr);

function gluProject (objx       : GLdouble;
                     objy       : GLdouble;
                     objz       : GLdouble;
                     modelMatrix: GLdoubleMatrixPtr;
                     projMatrix : GLdoubleMatrixPtr;
                     viewport   : GLviewPortRecPtr;
                     winx       : GLdoublePtr;
                     winy       : GLdoublePtr;
                     winz       : GLdoublePtr)
return GLint;

function gluUnProject (winx       : GLdouble;
                       winy       : GLdouble;
                       winz       : GLdouble;
                       modelMatrix: GLdoubleMatrixPtr;
                       projMatrix : GLdoubleMatrixPtr;
                       viewport   : GLviewPortRecPtr;
                       objx       : GLdoublePtr;
                       objy       : GLdoublePtr;
                       objz       : GLdoublePtr)
return GLint;

------------------------------------------------------------------------------

private

type GLUquadricObj      is record null; end record;
type GLUtriangulatorObj is record null; end record;
type GLUnurbsObj        is record null; end record;

pragma Import (C, gluLookAt, "gluLookAt");
pragma Import (C, gluOrtho2D, "gluOrtho2D");
pragma Import (C, gluPerspective, "gluPerspective");
pragma Import (C, gluPickMatrix, "gluPickMatrix");
pragma Import (C, gluProject, "gluProject");
pragma Import (C, gluUnProject, "gluUnProject");
pragma Import (C, gluErrorString, "gluErrorString");
pragma Import (C, gluScaleImage, "gluScaleImage");
pragma Import (C, gluBuild1DMipmaps, "gluBuild1DMipmaps");
pragma Import (C, gluBuild2DMipmaps, "gluBuild2DMipmaps");
pragma Import (C, gluNewQuadric, "gluNewQuadric");
pragma Import (C, gluDeleteQuadric, "gluDeleteQuadric");
pragma Import (C, gluQuadricDrawStyle, "gluQuadricDrawStyle");
pragma Import (C, gluQuadricOrientation, "gluQuadricOrientation");
pragma Import (C, gluQuadricNormals, "gluQuadricNormals");
pragma Import (C, gluQuadricTexture, "gluQuadricTexture");
pragma Import (C, gluQuadricCallback, "gluQuadricCallback");
pragma Import (C, gluCylinder, "gluCylinder");
pragma Import (C, gluSphere, "gluSphere");
pragma Import (C, gluDisk, "gluDisk");
pragma Import (C, gluPartialDisk, "gluPartialDisk");
pragma Import (C, gluNewNurbsRenderer, "gluNewNurbsRenderer");
pragma Import (C, gluDeleteNurbsRenderer, "gluDeleteNurbsRenderer");
pragma Import (C, gluLoadSamplingMatrices, "gluLoadSamplingMatrices");
pragma Import (C, gluNurbsProperty, "gluNurbsProperty");
pragma Import (C, gluGetNurbsProperty, "gluGetNurbsProperty");
pragma Import (C, gluBeginCurve, "gluBeginCurve");
pragma Import (C, gluEndCurve, "gluEndCurve");
pragma Import (C, gluNurbsCurve, "gluNurbsCurve");
pragma Import (C, gluBeginSurface, "gluBeginSurface");
pragma Import (C, gluEndSurface, "gluEndSurface");
pragma Import (C, gluNurbsSurface, "gluNurbsSurface");
pragma Import (C, gluBeginTrim, "gluBeginTrim");
pragma Import (C, gluEndTrim, "gluEndTrim");
pragma Import (C, gluPwlCurve, "gluPwlCurve");
pragma Import (C, gluNurbsCallback, "gluNurbsCallback");
pragma Import (C, gluNewTess, "gluNewTess");
pragma Import (C, gluTessCallback, "gluTessCallback");
pragma Import (C, gluDeleteTess, "gluDeleteTess");
pragma Import (C, gluBeginPolygon, "gluBeginPolygon");
pragma Import (C, gluEndPolygon, "gluEndPolygon");
pragma Import (C, gluNextContour, "gluNextContour");
pragma Import (C, gluTessVertex, "gluTessVertex");
pragma Import (C, gluGetString, "gluGetString");

end GLU;
