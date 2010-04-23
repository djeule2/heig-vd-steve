--
-- OpenGL 1.1 Ada binding, package GL
--
-- W. M. Richards, NiEstu, Phoenix AZ, December 1997
-- 
-- Converted from Brian Paul's Mesa package gl.h header file, version 2,5.
-- As noted below in Brian's original comments, this code is distributed
-- under the terms of the GNU Library General Public License.
--
-- Version 0.1, 21 December 1997
--
--
-- Here are the original gl.h comments:
--
-- Mesa 3-D graphics library
-- Version:  2.5
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


package GL is

package C renames Interfaces.C;

------------------------------------------------------------------------------

MESA_MAJOR_VERSION             : constant := 2;
MESA_MINOR_VERSION             : constant := 5;
GL_VERSION_1_1                 : constant := 1;
GL_EXT_BLEND_COLOR             : constant := 1;
GL_EXT_BLEND_LOGIC_OP          : constant := 1;
GL_EXT_BLEND_MINMAX            : constant := 1;
GL_EXT_BLEND_SUBTRACT          : constant := 1;
GL_EXT_POLYGON_OFFSET          : constant := 1;
GL_EXT_VERTEX_ARRAY            : constant := 1;
GL_EXT_TEXTURE_OBJECT          : constant := 1;
GL_EXT_TEXTURE3D               : constant := 1;
GL_EXT_PALETTED_TEXTURE        : constant := 1;
GL_EXT_SHARED_TEXTURE_PALETTE  : constant := 1;
GL_EXT_POINT_PARAMETERS        : constant := 1;
GL_MESA_WINDOW_POS             : constant := 1;
GL_MESA_RESIZE_BUFFERS         : constant := 1;


GL_CURRENT_BIT                 : constant := 16#00000001#;
GL_POINT_BIT                   : constant := 16#00000002#;
GL_LINE_BIT                    : constant := 16#00000004#;
GL_POLYGON_BIT                 : constant := 16#00000008#;
GL_POLYGON_STIPPLE_BIT         : constant := 16#00000010#;
GL_PIXEL_MODE_BIT              : constant := 16#00000020#;
GL_LIGHTING_BIT                : constant := 16#00000040#;
GL_FOG_BIT                     : constant := 16#00000080#;
GL_DEPTH_BUFFER_BIT            : constant := 16#00000100#;
GL_ACCUM_BUFFER_BIT            : constant := 16#00000200#;
GL_STENCIL_BUFFER_BIT          : constant := 16#00000400#;
GL_VIEWPORT_BIT                : constant := 16#00000800#;
GL_TRANSFORM_BIT               : constant := 16#00001000#;
GL_ENABLE_BIT                  : constant := 16#00002000#;
GL_COLOR_BUFFER_BIT            : constant := 16#00004000#;
GL_HINT_BIT                    : constant := 16#00008000#;
GL_EVAL_BIT                    : constant := 16#00010000#;
GL_LIST_BIT                    : constant := 16#00020000#;
GL_TEXTURE_BIT                 : constant := 16#00040000#;
GL_SCISSOR_BIT                 : constant := 16#00080000#;
GL_ALL_ATTRIB_BITS             : constant := 16#000FFFFF#;
GL_CLIENT_PIXEL_STORE_BIT      : constant := 16#00000001#;
GL_CLIENT_VERTEX_ARRAY_BIT     : constant := 16#00000002#;
GL_CLIENT_ALL_ATTRIB_BITS      : constant := 16#0000FFFF#;

------------------------------------------------------------------------------

-- Base types
type GLbitfield  is new C.unsigned;        -- 4-byte unsigned 
type GLboolean   is new C.unsigned_char;   -- 1-byte unsigned in [0,1]
type GLbyte      is new C.char;            -- 1-byte signed 
type GLshort     is new C.short;           -- 2-byte signed 
type GLint       is new C.int;             -- 4-byte signed 
type GLubyte     is new C.unsigned_char;   -- 1-byte unsigned 
type GLushort    is new C.unsigned_short;  -- 2-byte unsigned 
type GLuint      is new C.unsigned;        -- 4-byte unsigned 
type GLsizei     is new C.int;             -- 4-byte signed 
type GLfloat     is new C.C_float;         -- single precision float 
type GLclampf    is new C.C_float;         -- single precision float in [0,1] 
type GLdouble    is new C.double;          -- double precision float 
type GLclampd    is new C.double;          -- double precision float in [0,1] 

-- Pointer types
type GLbooleanPtr is access all GLboolean;
type GLbytePtr    is access all GLbyte;
type GLshortPtr   is access all GLshort;
type GLintPtr     is access all GLint;
type GLubytePtr   is access all GLubyte;
type GLushortPtr  is access all GLushort;
type GLuintPtr    is access all GLuint;
type GLfloatPtr   is access all GLfloat;
type GLclampfPtr  is access all GLclampf;
type GLdoublePtr  is access all GLdouble;

type GLpointer   is access all GLubyte;  -- our substitute for "void *"

------------------------------------------------------------------------------

-- GLenum is used only for sizing of the real enumeration types
type GLenum is new c.unsigned;

-- The boolean constants
GL_FALSE                       : constant GLboolean := GLboolean'Val (0);
GL_TRUE                        : constant GLboolean := GLboolean'Val (1);


-- Get pointer values
type GetPointerEnm is
(
   GL_FEEDBACK_BUFFER_POINTER,
   GL_VERTEX_ARRAY_POINTER,
   GL_NORMAL_ARRAY_POINTER,
   GL_COLOR_ARRAY_POINTER,
   GL_INDEX_ARRAY_POINTER,
   GL_TEXTURE_COORD_ARRAY_POINTER,
   GL_EDGE_FLAG_ARRAY_POINTER,
   GL_SELECTION_BUFFER_POINTER
);
for GetPointerEnm use
(
   GL_FEEDBACK_BUFFER_POINTER                 => 16#0DF0#,
   GL_VERTEX_ARRAY_POINTER                    => 16#808E#,
   GL_NORMAL_ARRAY_POINTER                    => 16#808F#,
   GL_COLOR_ARRAY_POINTER                     => 16#8090#,
   GL_INDEX_ARRAY_POINTER                     => 16#8091#,
   GL_TEXTURE_COORD_ARRAY_POINTER             => 16#8092#,
   GL_EDGE_FLAG_ARRAY_POINTER                 => 16#8093#,
   GL_SELECTION_BUFFER_POINTER                => 16#FFFF#   -- fixme: Mesa 2.5 does not support!!  What's the real value?
);
for GetPointerEnm'Size use GLenum'Size;

procedure glGetPointerv (pname : GetPointerEnm;
                         params: GLpointer);


-- Alpha, stencil, and depth tests
type FuncEnm is
(
   GL_NEVER,
   GL_LESS,
   GL_EQUAL,
   GL_LEQUAL,
   GL_GREATER,
   GL_NOTEQUAL,
   GL_GEQUAL,
   GL_ALWAYS
);
for FuncEnm use
(
   GL_NEVER                                   => 16#0200#,
   GL_LESS                                    => 16#0201#,
   GL_EQUAL                                   => 16#0202#,
   GL_LEQUAL                                  => 16#0203#,
   GL_GREATER                                 => 16#0204#,
   GL_NOTEQUAL                                => 16#0205#,
   GL_GEQUAL                                  => 16#0206#,
   GL_ALWAYS                                  => 16#0207#
);
for FuncEnm'Size use GLenum'Size;

procedure glAlphaFunc (func: FuncEnm;
                       ref : GLclampf);

procedure glDepthFunc (func: FuncEnm);

procedure glStencilFunc (func: FuncEnm;
                         ref : GLint;
                         mask: GLuint);


-- Stencil operations
type StencilOpEnm is
(
   GL_ZERO,
   GL_INVERT,
   GL_KEEP,
   GL_REPLACE,
   GL_INCR,
   GL_DECR
);
for StencilOpEnm use
(
   GL_ZERO                                    => 16#0000#,
   GL_INVERT                                  => 16#150A#,
   GL_KEEP                                    => 16#1E00#,
   GL_REPLACE                                 => 16#1E01#,
   GL_INCR                                    => 16#1E02#,
   GL_DECR                                    => 16#1E03#
);
for StencilOpEnm'Size use GLenum'Size;

procedure glStencilOp (fail : StencilOpEnm;
                       zfail: StencilOpEnm;
                       zpass: StencilOpEnm);


-- Blending functions
type BlendSrcEnm is
(
   GL_ZERO,
   GL_ONE,
   GL_SRC_ALPHA,
   GL_ONE_MINUS_SRC_ALPHA,
   GL_DST_ALPHA,
   GL_ONE_MINUS_DST_ALPHA,
   GL_DST_COLOR,
   GL_ONE_MINUS_DST_COLOR,
   GL_SRC_ALPHA_SATURATE,
   GL_CONSTANT_COLOR,
   GL_ONE_MINUS_CONSTANT_COLOR,
   GL_CONSTANT_ALPHA,
   GL_ONE_MINUS_CONSTANT_ALPHA
);
for BlendSrcEnm use
(
   GL_ZERO                                    => 16#0000#,
   GL_ONE                                     => 16#0001#,
   GL_SRC_ALPHA                               => 16#0302#,
   GL_ONE_MINUS_SRC_ALPHA                     => 16#0303#,
   GL_DST_ALPHA                               => 16#0304#,
   GL_ONE_MINUS_DST_ALPHA                     => 16#0305#,
   GL_DST_COLOR                               => 16#0306#,
   GL_ONE_MINUS_DST_COLOR                     => 16#0307#,
   GL_SRC_ALPHA_SATURATE                      => 16#0308#,
   GL_CONSTANT_COLOR                          => 16#8001#,  -- are these four Mesa-specific?
   GL_ONE_MINUS_CONSTANT_COLOR                => 16#8002#,
   GL_CONSTANT_ALPHA                          => 16#8003#,
   GL_ONE_MINUS_CONSTANT_ALPHA                => 16#8004#
);
for BlendSrcEnm'Size use GLenum'Size;

type BlendDstEnm is
(
   GL_ZERO,
   GL_ONE,
   GL_SRC_COLOR,
   GL_ONE_MINUS_SRC_COLOR,
   GL_SRC_ALPHA,
   GL_ONE_MINUS_SRC_ALPHA,
   GL_DST_ALPHA,
   GL_ONE_MINUS_DST_ALPHA
);
for BlendDstEnm use
(
   GL_ZERO                                    => 16#0000#,
   GL_ONE                                     => 16#0001#,
   GL_SRC_COLOR                               => 16#0300#,
   GL_ONE_MINUS_SRC_COLOR                     => 16#0301#,
   GL_SRC_ALPHA                               => 16#0302#,
   GL_ONE_MINUS_SRC_ALPHA                     => 16#0303#,
   GL_DST_ALPHA                               => 16#0304#,
   GL_ONE_MINUS_DST_ALPHA                     => 16#0305#
);
for BlendDstEnm'Size use GLenum'Size;

type BlendEquationEnm is
(
   GL_LOGIC_OP,
   GL_FUNC_ADD_EXT,
   GL_MIN_EXT,
   GL_MAX_EXT,
   GL_FUNC_SUBTRACT_EXT,
   GL_FUNC_REVERSE_SUBTRACT_EXT
);
for BlendEquationEnm use
(
   GL_LOGIC_OP                                => 16#0BF1#,
   GL_FUNC_ADD_EXT                            => 16#8006#,
   GL_MIN_EXT                                 => 16#8007#,
   GL_MAX_EXT                                 => 16#8008#,
   GL_FUNC_SUBTRACT_EXT                       => 16#800A#,
   GL_FUNC_REVERSE_SUBTRACT_EXT               => 16#800B#
);
for BlendEquationEnm'Size use GLenum'size;

procedure glBlendFunc (sfactor: BlendSrcEnm;
                       dfactor: BlendDstEnm);

procedure glBlendEquationEXT (mode: BlendEquationEnm);

procedure glBlendColorEXT (red  : GLclampf;
                           green: GLclampf;
                           blue : GLclampf;
                           alpha: GLclampf);


-- Locic operation function
type LogicOpEnm is
(
   GL_CLEAR,
   GL_AND,
   GL_AND_REVERSE,
   GL_COPY,
   GL_AND_INVERTED,
   GL_NOOP,
   GL_XOR,
   GL_OR,
   GL_NOR,
   GL_EQUIV,
   GL_INVERT,
   GL_OR_REVERSE,
   GL_COPY_INVERTED,
   GL_OR_INVERTED,
   GL_NAND,
   GL_SET
);
for LogicOpEnm use
(
   GL_CLEAR                                   => 16#1500#,
   GL_AND                                     => 16#1501#,
   GL_AND_REVERSE                             => 16#1502#,
   GL_COPY                                    => 16#1503#,
   GL_AND_INVERTED                            => 16#1504#,
   GL_NOOP                                    => 16#1505#,
   GL_XOR                                     => 16#1506#,
   GL_OR                                      => 16#1507#,
   GL_NOR                                     => 16#1508#,
   GL_EQUIV                                   => 16#1509#,
   GL_INVERT                                  => 16#150A#,
   GL_OR_REVERSE                              => 16#150B#,
   GL_COPY_INVERTED                           => 16#150C#,
   GL_OR_INVERTED                             => 16#150D#,
   GL_NAND                                    => 16#150E#,
   GL_SET                                     => 16#150F#
);
for LogicOpEnm'Size use GLenum'size;

procedure glLogicOp (opcode: LogicOpEnm);


-- Face culling
type FaceEnm is
(
   GL_FRONT,
   GL_BACK,
   GL_FRONT_AND_BACK
);
for FaceEnm use
(
   GL_FRONT                                   => 16#0404#,
   GL_BACK                                    => 16#0405#,
   GL_FRONT_AND_BACK                          => 16#0408#
);
for FaceEnm'Size use GLenum'size;

procedure glCullFace (mode: FaceEnm);


-- Polygon orientation
type OrientationEnm is
(
   GL_CW,
   GL_CCW
);
for OrientationEnm use
(
   GL_CW                                      => 16#0900#,
   GL_CCW                                     => 16#0901#
);
for OrientationEnm'Size use GLenum'size;

procedure glFrontFace (mode: OrientationEnm);


-- Polygon mode
type PolygonModeEnm is
(
   GL_POINT,
   GL_LINE,
   GL_FILL
);
for PolygonModeEnm use
(
   GL_POINT                                   => 16#1B00#,
   GL_LINE                                    => 16#1B01#,
   GL_FILL                                    => 16#1B02#
);
for PolygonModeEnm'Size use GLenum'size;

procedure glPolygonMode (face: FaceEnm;
                         mode: PolygonModeEnm);


-- Clipping plane operations
type ClipPlaneEnm is
(
   GL_CLIP_PLANE0,
   GL_CLIP_PLANE1,
   GL_CLIP_PLANE2,
   GL_CLIP_PLANE3,
   GL_CLIP_PLANE4,
   GL_CLIP_PLANE5
);
for ClipPlaneEnm use
(
   GL_CLIP_PLANE0                             => 16#3000#,
   GL_CLIP_PLANE1                             => 16#3001#,
   GL_CLIP_PLANE2                             => 16#3002#,
   GL_CLIP_PLANE3                             => 16#3003#,
   GL_CLIP_PLANE4                             => 16#3004#,
   GL_CLIP_PLANE5                             => 16#3005#
);
for ClipPlaneEnm'Size use GLenum'size;

procedure glClipPlane (plane   : ClipPlaneEnm;
                       equation: GLdoublePtr);

procedure glGetClipPlane (plane   : ClipPlaneEnm;
                          equation: GLdoublePtr);


-- Buffer selection
type DrawBufferEnm is
(
   GL_NONE,
   GL_FRONT_LEFT,
   GL_FRONT_RIGHT,
   GL_BACK_LEFT,
   GL_BACK_RIGHT,
   GL_FRONT,
   GL_BACK,
   GL_LEFT,
   GL_RIGHT,
   GL_FRONT_AND_BACK,
   GL_AUX0,
   GL_AUX1,
   GL_AUX2,
   GL_AUX3
);
for DrawBufferEnm use
(
   GL_NONE                                    => 16#0000#,
   GL_FRONT_LEFT                              => 16#0400#,
   GL_FRONT_RIGHT                             => 16#0401#,
   GL_BACK_LEFT                               => 16#0402#,
   GL_BACK_RIGHT                              => 16#0403#,
   GL_FRONT                                   => 16#0404#,
   GL_BACK                                    => 16#0405#,
   GL_LEFT                                    => 16#0406#,
   GL_RIGHT                                   => 16#0407#,
   GL_FRONT_AND_BACK                          => 16#0408#,
   GL_AUX0                                    => 16#0409#,
   GL_AUX1                                    => 16#040A#,
   GL_AUX2                                    => 16#040B#,
   GL_AUX3                                    => 16#040C#
);
for DrawBufferEnm'Size use GLenum'size;

procedure glDrawBuffer (mode: DrawBufferEnm);

type ReadBufferEnm is
(
   GL_FRONT_LEFT,
   GL_FRONT_RIGHT,
   GL_BACK_LEFT,
   GL_BACK_RIGHT,
   GL_FRONT,
   GL_BACK,
   GL_LEFT,
   GL_RIGHT,
   GL_AUX0,
   GL_AUX1,
   GL_AUX2,
   GL_AUX3
);
for ReadBufferEnm use
(
   GL_FRONT_LEFT                              => 16#0400#,
   GL_FRONT_RIGHT                             => 16#0401#,
   GL_BACK_LEFT                               => 16#0402#,
   GL_BACK_RIGHT                              => 16#0403#,
   GL_FRONT                                   => 16#0404#,
   GL_BACK                                    => 16#0405#,
   GL_LEFT                                    => 16#0406#,
   GL_RIGHT                                   => 16#0407#,
   GL_AUX0                                    => 16#0409#,
   GL_AUX1                                    => 16#040A#,
   GL_AUX2                                    => 16#040B#,
   GL_AUX3                                    => 16#040C#
);
for ReadBufferEnm'Size use GLenum'size;

procedure glReadBuffer (mode: ReadBufferEnm);


-- Server-side capabilities
type ServerCapabilityEnm is
(
   GL_POINT_SMOOTH,
   GL_LINE_SMOOTH,
   GL_LINE_STIPPLE,
   GL_POLYGON_SMOOTH,
   GL_POLYGON_STIPPLE,
   GL_CULL_FACE,
   GL_LIGHTING,
   GL_COLOR_MATERIAL,
   GL_FOG,
   GL_DEPTH_TEST,
   GL_STENCIL_TEST,
   GL_NORMALIZE,
   GL_ALPHA_TEST,
   GL_DITHER,
   GL_BLEND,
   GL_INDEX_LOGIC_OP,
   GL_COLOR_LOGIC_OP,
   GL_SCISSOR_TEST,
   GL_TEXTURE_GEN_S,
   GL_TEXTURE_GEN_T,
   GL_TEXTURE_GEN_R,
   GL_TEXTURE_GEN_Q,
   GL_AUTO_NORMAL,
   GL_MAP1_COLOR_4,
   GL_MAP1_INDEX,
   GL_MAP1_NORMAL,
   GL_MAP1_TEXTURE_COORD_1,
   GL_MAP1_TEXTURE_COORD_2,
   GL_MAP1_TEXTURE_COORD_3,
   GL_MAP1_TEXTURE_COORD_4,
   GL_MAP1_VERTEX_3,
   GL_MAP1_VERTEX_4,
   GL_MAP2_COLOR_4,
   GL_MAP2_INDEX,
   GL_MAP2_NORMAL,
   GL_MAP2_TEXTURE_COORD_1,
   GL_MAP2_TEXTURE_COORD_2,
   GL_MAP2_TEXTURE_COORD_3,
   GL_MAP2_TEXTURE_COORD_4,
   GL_MAP2_VERTEX_3,
   GL_MAP2_VERTEX_4,
   GL_TEXTURE_1D,
   GL_TEXTURE_2D,
   GL_POLYGON_OFFSET_POINT,
   GL_POLYGON_OFFSET_LINE,
   GL_CLIP_PLANE0,
   GL_CLIP_PLANE1,
   GL_CLIP_PLANE2,
   GL_CLIP_PLANE3,
   GL_CLIP_PLANE4,
   GL_CLIP_PLANE5,
   GL_LIGHT0,
   GL_LIGHT1,
   GL_LIGHT2,
   GL_LIGHT3,
   GL_LIGHT4,
   GL_LIGHT5,
   GL_LIGHT6,
   GL_LIGHT7,
   GL_POLYGON_OFFSET_FILL,
   GL_TEXTURE_3D_EXT
);
for ServerCapabilityEnm use
(
   GL_POINT_SMOOTH                            => 16#0B10#,
   GL_LINE_SMOOTH                             => 16#0B20#,
   GL_LINE_STIPPLE                            => 16#0B24#,
   GL_POLYGON_SMOOTH                          => 16#0B41#,
   GL_POLYGON_STIPPLE                         => 16#0B42#,
   GL_CULL_FACE                               => 16#0B44#,
   GL_LIGHTING                                => 16#0B50#,
   GL_COLOR_MATERIAL                          => 16#0B57#,
   GL_FOG                                     => 16#0B60#,
   GL_DEPTH_TEST                              => 16#0B71#,
   GL_STENCIL_TEST                            => 16#0B90#,
   GL_NORMALIZE                               => 16#0BA1#,
   GL_ALPHA_TEST                              => 16#0BC0#,
   GL_DITHER                                  => 16#0BD0#,
   GL_BLEND                                   => 16#0BE2#,
   GL_INDEX_LOGIC_OP                          => 16#0BF1#,
   GL_COLOR_LOGIC_OP                          => 16#0BF2#,
   GL_SCISSOR_TEST                            => 16#0C11#,
   GL_TEXTURE_GEN_S                           => 16#0C60#,
   GL_TEXTURE_GEN_T                           => 16#0C61#,
   GL_TEXTURE_GEN_R                           => 16#0C62#,
   GL_TEXTURE_GEN_Q                           => 16#0C63#,
   GL_AUTO_NORMAL                             => 16#0D80#,
   GL_MAP1_COLOR_4                            => 16#0D90#,
   GL_MAP1_INDEX                              => 16#0D91#,
   GL_MAP1_NORMAL                             => 16#0D92#,
   GL_MAP1_TEXTURE_COORD_1                    => 16#0D93#,
   GL_MAP1_TEXTURE_COORD_2                    => 16#0D94#,
   GL_MAP1_TEXTURE_COORD_3                    => 16#0D95#,
   GL_MAP1_TEXTURE_COORD_4                    => 16#0D96#,
   GL_MAP1_VERTEX_3                           => 16#0D97#,
   GL_MAP1_VERTEX_4                           => 16#0D98#,
   GL_MAP2_COLOR_4                            => 16#0DB0#,
   GL_MAP2_INDEX                              => 16#0DB1#,
   GL_MAP2_NORMAL                             => 16#0DB2#,
   GL_MAP2_TEXTURE_COORD_1                    => 16#0DB3#,
   GL_MAP2_TEXTURE_COORD_2                    => 16#0DB4#,
   GL_MAP2_TEXTURE_COORD_3                    => 16#0DB5#,
   GL_MAP2_TEXTURE_COORD_4                    => 16#0DB6#,
   GL_MAP2_VERTEX_3                           => 16#0DB7#,
   GL_MAP2_VERTEX_4                           => 16#0DB8#,
   GL_TEXTURE_1D                              => 16#0DE0#,
   GL_TEXTURE_2D                              => 16#0DE1#,
   GL_POLYGON_OFFSET_POINT                    => 16#2A01#,
   GL_POLYGON_OFFSET_LINE                     => 16#2A02#,
   GL_CLIP_PLANE0                             => 16#3000#,
   GL_CLIP_PLANE1                             => 16#3001#,
   GL_CLIP_PLANE2                             => 16#3002#,
   GL_CLIP_PLANE3                             => 16#3003#,
   GL_CLIP_PLANE4                             => 16#3004#,
   GL_CLIP_PLANE5                             => 16#3005#,
   GL_LIGHT0                                  => 16#4000#,
   GL_LIGHT1                                  => 16#4001#,
   GL_LIGHT2                                  => 16#4002#,
   GL_LIGHT3                                  => 16#4003#,
   GL_LIGHT4                                  => 16#4004#,
   GL_LIGHT5                                  => 16#4005#,
   GL_LIGHT6                                  => 16#4006#,
   GL_LIGHT7                                  => 16#4007#,
   GL_POLYGON_OFFSET_FILL                     => 16#8037#,
   GL_TEXTURE_3D_EXT                          => 16#806F#
);
for ServerCapabilityEnm'Size use GLenum'size;

procedure glEnable (cap: ServerCapabilityEnm);

procedure glDisable (cap: ServerCapabilityEnm);

function glIsEnabled (cap: ServerCapabilityEnm)
return GLboolean;


-- Client state
type ClientCapabilityEnm is
(
   GL_VERTEX_ARRAY,
   GL_NORMAL_ARRAY,
   GL_COLOR_ARRAY,
   GL_INDEX_ARRAY,
   GL_TEXTURE_COORD_ARRAY,
   GL_EDGE_FLAG_ARRAY
);
for ClientCapabilityEnm use
(
   GL_VERTEX_ARRAY                            => 16#8074#,
   GL_NORMAL_ARRAY                            => 16#8075#,
   GL_COLOR_ARRAY                             => 16#8076#,
   GL_INDEX_ARRAY                             => 16#8077#,
   GL_TEXTURE_COORD_ARRAY                     => 16#8078#,
   GL_EDGE_FLAG_ARRAY                         => 16#8079#
);
for ClientCapabilityEnm'Size use GLenum'size;

procedure glEnableClientState (cap: ClientCapabilityEnm);

procedure glDisableClientState (cap: ClientCapabilityEnm);


-- Parameter fetches
type ParameterNameEnm is
(
   GL_CURRENT_COLOR,
   GL_CURRENT_INDEX,
   GL_CURRENT_NORMAL,
   GL_CURRENT_TEXTURE_COORDS,
   GL_CURRENT_RASTER_COLOR,
   GL_CURRENT_RASTER_INDEX,
   GL_CURRENT_RASTER_TEXTURE_COORDS,
   GL_CURRENT_RASTER_POSITION,
   GL_CURRENT_RASTER_POSITION_VALID,
   GL_CURRENT_RASTER_DISTANCE,
   GL_POINT_SMOOTH,
   GL_POINT_SIZE,
   GL_POINT_SIZE_RANGE,
   GL_POINT_SIZE_GRANULARITY,
   GL_LINE_SMOOTH,
   GL_LINE_WIDTH,
   GL_LINE_WIDTH_RANGE,
   GL_LINE_WIDTH_GRANULARITY,
   GL_LINE_STIPPLE,
   GL_LINE_STIPPLE_PATTERN,
   GL_LINE_STIPPLE_REPEAT,
   GL_LIST_MODE,
   GL_MAX_LIST_NESTING,
   GL_LIST_BASE,
   GL_LIST_INDEX,
   GL_POLYGON_MODE,
   GL_POLYGON_SMOOTH,
   GL_POLYGON_STIPPLE,
   GL_EDGE_FLAG,
   GL_CULL_FACE,
   GL_CULL_FACE_MODE,
   GL_FRONT_FACE,
   GL_LIGHTING,
   GL_LIGHT_MODEL_LOCAL_VIEWER,
   GL_LIGHT_MODEL_TWO_SIDE,
   GL_LIGHT_MODEL_AMBIENT,
   GL_SHADE_MODEL,
   GL_COLOR_MATERIAL_FACE,
   GL_COLOR_MATERIAL_PARAMETER,
   GL_COLOR_MATERIAL,
   GL_FOG,
   GL_FOG_INDEX,
   GL_FOG_DENSITY,
   GL_FOG_START,
   GL_FOG_END,
   GL_FOG_MODE,
   GL_FOG_COLOR,
   GL_DEPTH_RANGE,
   GL_DEPTH_TEST,
   GL_DEPTH_WRITEMASK,
   GL_DEPTH_CLEAR_VALUE,
   GL_DEPTH_FUNC,
   GL_ACCUM_CLEAR_VALUE,
   GL_STENCIL_TEST,
   GL_STENCIL_CLEAR_VALUE,
   GL_STENCIL_FUNC,
   GL_STENCIL_VALUE_MASK,
   GL_STENCIL_FAIL,
   GL_STENCIL_PASS_DEPTH_FAIL,
   GL_STENCIL_PASS_DEPTH_PASS,
   GL_STENCIL_REF,
   GL_STENCIL_WRITEMASK,
   GL_MATRIX_MODE,
   GL_NORMALIZE,
   GL_VIEWPORT,
   GL_MODELVIEW_STACK_DEPTH,
   GL_PROJECTION_STACK_DEPTH,
   GL_TEXTURE_STACK_DEPTH,
   GL_MODELVIEW_MATRIX,
   GL_PROJECTION_MATRIX,
   GL_TEXTURE_MATRIX,
   GL_ATTRIB_STACK_DEPTH,
   GL_CLIENT_ATTRIB_STACK_DEPTH,
   GL_ALPHA_TEST,
   GL_ALPHA_TEST_FUNC,
   GL_ALPHA_TEST_REF,
   GL_DITHER,
   GL_BLEND_DST,
   GL_BLEND_SRC,
   GL_BLEND,
   GL_LOGIC_OP_MODE,
   GL_INDEX_LOGIC_OP,
   GL_COLOR_LOGIC_OP,
   GL_AUX_BUFFERS,
   GL_DRAW_BUFFER,
   GL_READ_BUFFER,
   GL_SCISSOR_BOX,
   GL_SCISSOR_TEST,
   GL_INDEX_CLEAR_VALUE,
   GL_INDEX_WRITEMASK,
   GL_COLOR_CLEAR_VALUE,
   GL_COLOR_WRITEMASK,
   GL_INDEX_MODE,
   GL_RGBA_MODE,
   GL_DOUBLEBUFFER,
   GL_STEREO,
   GL_RENDER_MODE,
   GL_PERSPECTIVE_CORRECTION_HINT,
   GL_POINT_SMOOTH_HINT,
   GL_LINE_SMOOTH_HINT,
   GL_POLYGON_SMOOTH_HINT,
   GL_FOG_HINT,
   GL_TEXTURE_GEN_S,
   GL_TEXTURE_GEN_T,
   GL_TEXTURE_GEN_R,
   GL_TEXTURE_GEN_Q,
   GL_PIXEL_MAP_I_TO_I_SIZE,
   GL_PIXEL_MAP_S_TO_S_SIZE,
   GL_PIXEL_MAP_I_TO_R_SIZE,
   GL_PIXEL_MAP_I_TO_G_SIZE,
   GL_PIXEL_MAP_I_TO_B_SIZE,
   GL_PIXEL_MAP_I_TO_A_SIZE,
   GL_PIXEL_MAP_R_TO_R_SIZE,
   GL_PIXEL_MAP_G_TO_G_SIZE,
   GL_PIXEL_MAP_B_TO_B_SIZE,
   GL_PIXEL_MAP_A_TO_A_SIZE,
   GL_UNPACK_SWAP_BYTES,
   GL_UNPACK_LSB_FIRST,
   GL_UNPACK_ROW_LENGTH,
   GL_UNPACK_SKIP_ROWS,
   GL_UNPACK_SKIP_PIXELS,
   GL_UNPACK_ALIGNMENT,
   GL_PACK_SWAP_BYTES,
   GL_PACK_LSB_FIRST,
   GL_PACK_ROW_LENGTH,
   GL_PACK_SKIP_ROWS,
   GL_PACK_SKIP_PIXELS,
   GL_PACK_ALIGNMENT,
   GL_MAP_COLOR,
   GL_MAP_STENCIL,
   GL_INDEX_SHIFT,
   GL_INDEX_OFFSET,
   GL_RED_SCALE,
   GL_RED_BIAS,
   GL_ZOOM_X,
   GL_ZOOM_Y,
   GL_GREEN_SCALE,
   GL_GREEN_BIAS,
   GL_BLUE_SCALE,
   GL_BLUE_BIAS,
   GL_ALPHA_SCALE,
   GL_ALPHA_BIAS,
   GL_DEPTH_SCALE,
   GL_DEPTH_BIAS,
   GL_MAX_EVAL_ORDER,
   GL_MAX_LIGHTS,
   GL_MAX_CLIP_PLANES,
   GL_MAX_TEXTURE_SIZE,
   GL_MAX_PIXEL_MAP_TABLE,
   GL_MAX_ATTRIB_STACK_DEPTH,
   GL_MAX_MODELVIEW_STACK_DEPTH,
   GL_MAX_NAME_STACK_DEPTH,
   GL_MAX_PROJECTION_STACK_DEPTH,
   GL_MAX_TEXTURE_STACK_DEPTH,
   GL_MAX_VIEWPORT_DIMS,
   GL_MAX_CLIENT_ATTRIB_STACK_DEPTH,
   GL_SUBPIXEL_BITS,
   GL_INDEX_BITS,
   GL_RED_BITS,
   GL_GREEN_BITS,
   GL_BLUE_BITS,
   GL_ALPHA_BITS,
   GL_DEPTH_BITS,
   GL_STENCIL_BITS,
   GL_ACCUM_RED_BITS,
   GL_ACCUM_GREEN_BITS,
   GL_ACCUM_BLUE_BITS,
   GL_ACCUM_ALPHA_BITS,
   GL_NAME_STACK_DEPTH,
   GL_AUTO_NORMAL,
   GL_MAP1_COLOR_4,
   GL_MAP1_INDEX,
   GL_MAP1_NORMAL,
   GL_MAP1_TEXTURE_COORD_1,
   GL_MAP1_TEXTURE_COORD_2,
   GL_MAP1_TEXTURE_COORD_3,
   GL_MAP1_TEXTURE_COORD_4,
   GL_MAP1_VERTEX_3,
   GL_MAP1_VERTEX_4,
   GL_MAP2_COLOR_4,
   GL_MAP2_INDEX,
   GL_MAP2_NORMAL,
   GL_MAP2_TEXTURE_COORD_1,
   GL_MAP2_TEXTURE_COORD_2,
   GL_MAP2_TEXTURE_COORD_3,
   GL_MAP2_TEXTURE_COORD_4,
   GL_MAP2_VERTEX_3,
   GL_MAP2_VERTEX_4,
   GL_MAP1_GRID_DOMAIN,
   GL_MAP1_GRID_SEGMENTS,
   GL_MAP2_GRID_DOMAIN,
   GL_MAP2_GRID_SEGMENTS,
   GL_TEXTURE_1D,
   GL_TEXTURE_2D,
   GL_POLYGON_OFFSET_UNITS,
   GL_POLYGON_OFFSET_POINT,
   GL_POLYGON_OFFSET_LINE,
   GL_POLYGON_OFFSET_FILL,
   GL_POLYGON_OFFSET_FACTOR,
   GL_TEXTURE_BINDING_1D,
   GL_TEXTURE_BINDING_2D,
   GL_VERTEX_ARRAY,
   GL_NORMAL_ARRAY,
   GL_COLOR_ARRAY,
   GL_INDEX_ARRAY,
   GL_TEXTURE_COORD_ARRAY,
   GL_EDGE_FLAG_ARRAY,
   GL_VERTEX_ARRAY_SIZE,
   GL_VERTEX_ARRAY_TYPE,
   GL_VERTEX_ARRAY_STRIDE,
   GL_NORMAL_ARRAY_TYPE,
   GL_NORMAL_ARRAY_STRIDE,
   GL_COLOR_ARRAY_SIZE,
   GL_COLOR_ARRAY_TYPE,
   GL_COLOR_ARRAY_STRIDE,
   GL_INDEX_ARRAY_TYPE,
   GL_INDEX_ARRAY_STRIDE,
   GL_TEXTURE_COORD_ARRAY_SIZE,
   GL_TEXTURE_COORD_ARRAY_TYPE,
   GL_TEXTURE_COORD_ARRAY_STRIDE,
   GL_EDGE_FLAG_ARRAY_STRIDE
);
for ParameterNameEnm use
(
   GL_CURRENT_COLOR                           => 16#0B00#,
   GL_CURRENT_INDEX                           => 16#0B01#,
   GL_CURRENT_NORMAL                          => 16#0B02#,
   GL_CURRENT_TEXTURE_COORDS                  => 16#0B03#,
   GL_CURRENT_RASTER_COLOR                    => 16#0B04#,
   GL_CURRENT_RASTER_INDEX                    => 16#0B05#,
   GL_CURRENT_RASTER_TEXTURE_COORDS           => 16#0B06#,
   GL_CURRENT_RASTER_POSITION                 => 16#0B07#,
   GL_CURRENT_RASTER_POSITION_VALID           => 16#0B08#,
   GL_CURRENT_RASTER_DISTANCE                 => 16#0B09#,
   GL_POINT_SMOOTH                            => 16#0B10#,
   GL_POINT_SIZE                              => 16#0B11#,
   GL_POINT_SIZE_RANGE                        => 16#0B12#,
   GL_POINT_SIZE_GRANULARITY                  => 16#0B13#,
   GL_LINE_SMOOTH                             => 16#0B20#,
   GL_LINE_WIDTH                              => 16#0B21#,
   GL_LINE_WIDTH_RANGE                        => 16#0B22#,
   GL_LINE_WIDTH_GRANULARITY                  => 16#0B23#,
   GL_LINE_STIPPLE                            => 16#0B24#,
   GL_LINE_STIPPLE_PATTERN                    => 16#0B25#,
   GL_LINE_STIPPLE_REPEAT                     => 16#0B26#,
   GL_LIST_MODE                               => 16#0B30#,
   GL_MAX_LIST_NESTING                        => 16#0B31#,
   GL_LIST_BASE                               => 16#0B32#,
   GL_LIST_INDEX                              => 16#0B33#,
   GL_POLYGON_MODE                            => 16#0B40#,
   GL_POLYGON_SMOOTH                          => 16#0B41#,
   GL_POLYGON_STIPPLE                         => 16#0B42#,
   GL_EDGE_FLAG                               => 16#0B43#,
   GL_CULL_FACE                               => 16#0B44#,
   GL_CULL_FACE_MODE                          => 16#0B45#,
   GL_FRONT_FACE                              => 16#0B46#,
   GL_LIGHTING                                => 16#0B50#,
   GL_LIGHT_MODEL_LOCAL_VIEWER                => 16#0B51#,
   GL_LIGHT_MODEL_TWO_SIDE                    => 16#0B52#,
   GL_LIGHT_MODEL_AMBIENT                     => 16#0B53#,
   GL_SHADE_MODEL                             => 16#0B54#,
   GL_COLOR_MATERIAL_FACE                     => 16#0B55#,
   GL_COLOR_MATERIAL_PARAMETER                => 16#0B56#,
   GL_COLOR_MATERIAL                          => 16#0B57#,
   GL_FOG                                     => 16#0B60#,
   GL_FOG_INDEX                               => 16#0B61#,
   GL_FOG_DENSITY                             => 16#0B62#,
   GL_FOG_START                               => 16#0B63#,
   GL_FOG_END                                 => 16#0B64#,
   GL_FOG_MODE                                => 16#0B65#,
   GL_FOG_COLOR                               => 16#0B66#,
   GL_DEPTH_RANGE                             => 16#0B70#,
   GL_DEPTH_TEST                              => 16#0B71#,
   GL_DEPTH_WRITEMASK                         => 16#0B72#,
   GL_DEPTH_CLEAR_VALUE                       => 16#0B73#,
   GL_DEPTH_FUNC                              => 16#0B74#,
   GL_ACCUM_CLEAR_VALUE                       => 16#0B80#,
   GL_STENCIL_TEST                            => 16#0B90#,
   GL_STENCIL_CLEAR_VALUE                     => 16#0B91#,
   GL_STENCIL_FUNC                            => 16#0B92#,
   GL_STENCIL_VALUE_MASK                      => 16#0B93#,
   GL_STENCIL_FAIL                            => 16#0B94#,
   GL_STENCIL_PASS_DEPTH_FAIL                 => 16#0B95#,
   GL_STENCIL_PASS_DEPTH_PASS                 => 16#0B96#,
   GL_STENCIL_REF                             => 16#0B97#,
   GL_STENCIL_WRITEMASK                       => 16#0B98#,
   GL_MATRIX_MODE                             => 16#0BA0#,
   GL_NORMALIZE                               => 16#0BA1#,
   GL_VIEWPORT                                => 16#0BA2#,
   GL_MODELVIEW_STACK_DEPTH                   => 16#0BA3#,
   GL_PROJECTION_STACK_DEPTH                  => 16#0BA4#,
   GL_TEXTURE_STACK_DEPTH                     => 16#0BA5#,
   GL_MODELVIEW_MATRIX                        => 16#0BA6#,
   GL_PROJECTION_MATRIX                       => 16#0BA7#,
   GL_TEXTURE_MATRIX                          => 16#0BA8#,
   GL_ATTRIB_STACK_DEPTH                      => 16#0BB0#,
   GL_CLIENT_ATTRIB_STACK_DEPTH               => 16#0BB1#,
   GL_ALPHA_TEST                              => 16#0BC0#,
   GL_ALPHA_TEST_FUNC                         => 16#0BC1#,
   GL_ALPHA_TEST_REF                          => 16#0BC2#,
   GL_DITHER                                  => 16#0BD0#,
   GL_BLEND_DST                               => 16#0BE0#,
   GL_BLEND_SRC                               => 16#0BE1#,
   GL_BLEND                                   => 16#0BE2#,
   GL_LOGIC_OP_MODE                           => 16#0BF0#,
   GL_INDEX_LOGIC_OP                          => 16#0BF1#,
   GL_COLOR_LOGIC_OP                          => 16#0BF2#,
   GL_AUX_BUFFERS                             => 16#0C00#,
   GL_DRAW_BUFFER                             => 16#0C01#,
   GL_READ_BUFFER                             => 16#0C02#,
   GL_SCISSOR_BOX                             => 16#0C10#,
   GL_SCISSOR_TEST                            => 16#0C11#,
   GL_INDEX_CLEAR_VALUE                       => 16#0C20#,
   GL_INDEX_WRITEMASK                         => 16#0C21#,
   GL_COLOR_CLEAR_VALUE                       => 16#0C22#,
   GL_COLOR_WRITEMASK                         => 16#0C23#,
   GL_INDEX_MODE                              => 16#0C30#,
   GL_RGBA_MODE                               => 16#0C31#,
   GL_DOUBLEBUFFER                            => 16#0C32#,
   GL_STEREO                                  => 16#0C33#,
   GL_RENDER_MODE                             => 16#0C40#,
   GL_PERSPECTIVE_CORRECTION_HINT             => 16#0C50#,
   GL_POINT_SMOOTH_HINT                       => 16#0C51#,
   GL_LINE_SMOOTH_HINT                        => 16#0C52#,
   GL_POLYGON_SMOOTH_HINT                     => 16#0C53#,
   GL_FOG_HINT                                => 16#0C54#,
   GL_TEXTURE_GEN_S                           => 16#0C60#,
   GL_TEXTURE_GEN_T                           => 16#0C61#,
   GL_TEXTURE_GEN_R                           => 16#0C62#,
   GL_TEXTURE_GEN_Q                           => 16#0C63#,
   GL_PIXEL_MAP_I_TO_I_SIZE                   => 16#0CB0#,
   GL_PIXEL_MAP_S_TO_S_SIZE                   => 16#0CB1#,
   GL_PIXEL_MAP_I_TO_R_SIZE                   => 16#0CB2#,
   GL_PIXEL_MAP_I_TO_G_SIZE                   => 16#0CB3#,
   GL_PIXEL_MAP_I_TO_B_SIZE                   => 16#0CB4#,
   GL_PIXEL_MAP_I_TO_A_SIZE                   => 16#0CB5#,
   GL_PIXEL_MAP_R_TO_R_SIZE                   => 16#0CB6#,
   GL_PIXEL_MAP_G_TO_G_SIZE                   => 16#0CB7#,
   GL_PIXEL_MAP_B_TO_B_SIZE                   => 16#0CB8#,
   GL_PIXEL_MAP_A_TO_A_SIZE                   => 16#0CB9#,
   GL_UNPACK_SWAP_BYTES                       => 16#0CF0#,
   GL_UNPACK_LSB_FIRST                        => 16#0CF1#,
   GL_UNPACK_ROW_LENGTH                       => 16#0CF2#,
   GL_UNPACK_SKIP_ROWS                        => 16#0CF3#,
   GL_UNPACK_SKIP_PIXELS                      => 16#0CF4#,
   GL_UNPACK_ALIGNMENT                        => 16#0CF5#,
   GL_PACK_SWAP_BYTES                         => 16#0D00#,
   GL_PACK_LSB_FIRST                          => 16#0D01#,
   GL_PACK_ROW_LENGTH                         => 16#0D02#,
   GL_PACK_SKIP_ROWS                          => 16#0D03#,
   GL_PACK_SKIP_PIXELS                        => 16#0D04#,
   GL_PACK_ALIGNMENT                          => 16#0D05#,
   GL_MAP_COLOR                               => 16#0D10#,
   GL_MAP_STENCIL                             => 16#0D11#,
   GL_INDEX_SHIFT                             => 16#0D12#,
   GL_INDEX_OFFSET                            => 16#0D13#,
   GL_RED_SCALE                               => 16#0D14#,
   GL_RED_BIAS                                => 16#0D15#,
   GL_ZOOM_X                                  => 16#0D16#,
   GL_ZOOM_Y                                  => 16#0D17#,
   GL_GREEN_SCALE                             => 16#0D18#,
   GL_GREEN_BIAS                              => 16#0D19#,
   GL_BLUE_SCALE                              => 16#0D1A#,
   GL_BLUE_BIAS                               => 16#0D1B#,
   GL_ALPHA_SCALE                             => 16#0D1C#,
   GL_ALPHA_BIAS                              => 16#0D1D#,
   GL_DEPTH_SCALE                             => 16#0D1E#,
   GL_DEPTH_BIAS                              => 16#0D1F#,
   GL_MAX_EVAL_ORDER                          => 16#0D30#,
   GL_MAX_LIGHTS                              => 16#0D31#,
   GL_MAX_CLIP_PLANES                         => 16#0D32#,
   GL_MAX_TEXTURE_SIZE                        => 16#0D33#,
   GL_MAX_PIXEL_MAP_TABLE                     => 16#0D34#,
   GL_MAX_ATTRIB_STACK_DEPTH                  => 16#0D35#,
   GL_MAX_MODELVIEW_STACK_DEPTH               => 16#0D36#,
   GL_MAX_NAME_STACK_DEPTH                    => 16#0D37#,
   GL_MAX_PROJECTION_STACK_DEPTH              => 16#0D38#,
   GL_MAX_TEXTURE_STACK_DEPTH                 => 16#0D39#,
   GL_MAX_VIEWPORT_DIMS                       => 16#0D3A#,
   GL_MAX_CLIENT_ATTRIB_STACK_DEPTH           => 16#0D3B#,
   GL_SUBPIXEL_BITS                           => 16#0D50#,
   GL_INDEX_BITS                              => 16#0D51#,
   GL_RED_BITS                                => 16#0D52#,
   GL_GREEN_BITS                              => 16#0D53#,
   GL_BLUE_BITS                               => 16#0D54#,
   GL_ALPHA_BITS                              => 16#0D55#,
   GL_DEPTH_BITS                              => 16#0D56#,
   GL_STENCIL_BITS                            => 16#0D57#,
   GL_ACCUM_RED_BITS                          => 16#0D58#,
   GL_ACCUM_GREEN_BITS                        => 16#0D59#,
   GL_ACCUM_BLUE_BITS                         => 16#0D5A#,
   GL_ACCUM_ALPHA_BITS                        => 16#0D5B#,
   GL_NAME_STACK_DEPTH                        => 16#0D70#,
   GL_AUTO_NORMAL                             => 16#0D80#,
   GL_MAP1_COLOR_4                            => 16#0D90#,
   GL_MAP1_INDEX                              => 16#0D91#,
   GL_MAP1_NORMAL                             => 16#0D92#,
   GL_MAP1_TEXTURE_COORD_1                    => 16#0D93#,
   GL_MAP1_TEXTURE_COORD_2                    => 16#0D94#,
   GL_MAP1_TEXTURE_COORD_3                    => 16#0D95#,
   GL_MAP1_TEXTURE_COORD_4                    => 16#0D96#,
   GL_MAP1_VERTEX_3                           => 16#0D97#,
   GL_MAP1_VERTEX_4                           => 16#0D98#,
   GL_MAP2_COLOR_4                            => 16#0DB0#,
   GL_MAP2_INDEX                              => 16#0DB1#,
   GL_MAP2_NORMAL                             => 16#0DB2#,
   GL_MAP2_TEXTURE_COORD_1                    => 16#0DB3#,
   GL_MAP2_TEXTURE_COORD_2                    => 16#0DB4#,
   GL_MAP2_TEXTURE_COORD_3                    => 16#0DB5#,
   GL_MAP2_TEXTURE_COORD_4                    => 16#0DB6#,
   GL_MAP2_VERTEX_3                           => 16#0DB7#,
   GL_MAP2_VERTEX_4                           => 16#0DB8#,
   GL_MAP1_GRID_DOMAIN                        => 16#0DD0#,
   GL_MAP1_GRID_SEGMENTS                      => 16#0DD1#,
   GL_MAP2_GRID_DOMAIN                        => 16#0DD2#,
   GL_MAP2_GRID_SEGMENTS                      => 16#0DD3#,
   GL_TEXTURE_1D                              => 16#0DE0#,
   GL_TEXTURE_2D                              => 16#0DE1#,
   GL_POLYGON_OFFSET_UNITS                    => 16#2A00#,
   GL_POLYGON_OFFSET_POINT                    => 16#2A01#,
   GL_POLYGON_OFFSET_LINE                     => 16#2A02#,
   GL_POLYGON_OFFSET_FILL                     => 16#8037#,
   GL_POLYGON_OFFSET_FACTOR                   => 16#8038#,
   GL_TEXTURE_BINDING_1D                      => 16#8068#,
   GL_TEXTURE_BINDING_2D                      => 16#8069#,
   GL_VERTEX_ARRAY                            => 16#8074#,
   GL_NORMAL_ARRAY                            => 16#8075#,
   GL_COLOR_ARRAY                             => 16#8076#,
   GL_INDEX_ARRAY                             => 16#8077#,
   GL_TEXTURE_COORD_ARRAY                     => 16#8078#,
   GL_EDGE_FLAG_ARRAY                         => 16#8079#,
   GL_VERTEX_ARRAY_SIZE                       => 16#807A#,
   GL_VERTEX_ARRAY_TYPE                       => 16#807B#,
   GL_VERTEX_ARRAY_STRIDE                     => 16#807C#,
   GL_NORMAL_ARRAY_TYPE                       => 16#807E#,
   GL_NORMAL_ARRAY_STRIDE                     => 16#807F#,
   GL_COLOR_ARRAY_SIZE                        => 16#8081#,
   GL_COLOR_ARRAY_TYPE                        => 16#8082#,
   GL_COLOR_ARRAY_STRIDE                      => 16#8083#,
   GL_INDEX_ARRAY_TYPE                        => 16#8085#,
   GL_INDEX_ARRAY_STRIDE                      => 16#8086#,
   GL_TEXTURE_COORD_ARRAY_SIZE                => 16#8088#,
   GL_TEXTURE_COORD_ARRAY_TYPE                => 16#8089#,
   GL_TEXTURE_COORD_ARRAY_STRIDE              => 16#808A#,
   GL_EDGE_FLAG_ARRAY_STRIDE                  => 16#808C#
);
for ParameterNameEnm'Size use GLenum'size;

procedure glGetBooleanv (pname : ParameterNameEnm;
                         params: GLbooleanPtr);

procedure glGetDoublev (pname : ParameterNameEnm;
                        params: GLdoublePtr);

procedure glGetFloatv (pname : ParameterNameEnm;
                       params: GLfloatPtr);

procedure glGetIntegerv (pname : ParameterNameEnm;
                         params: GLintPtr);


-- Render mode
type RenderModeEnm is
(
   GL_RENDER,
   GL_FEEDBACK,
   GL_SELECT
);
for RenderModeEnm use
(
   GL_RENDER                                  => 16#1C00#,
   GL_FEEDBACK                                => 16#1C01#,
   GL_SELECT                                  => 16#1C02#
);
for RenderModeEnm'Size use GLenum'size;

function glRenderMode(mode: RenderModeEnm)
return GLint;


-- Error information
type ErrorEnm is
(
   GL_NO_ERROR,
   GL_INVALID_ENUM,
   GL_INVALID_VALUE,
   GL_INVALID_OPERATION,
   GL_STACK_OVERFLOW,
   GL_STACK_UNDERFLOW,
   GL_OUT_OF_MEMORY
);
for ErrorEnm use
(
   GL_NO_ERROR                                => 16#0000#,
   GL_INVALID_ENUM                            => 16#0500#,
   GL_INVALID_VALUE                           => 16#0501#,
   GL_INVALID_OPERATION                       => 16#0502#,
   GL_STACK_OVERFLOW                          => 16#0503#,
   GL_STACK_UNDERFLOW                         => 16#0504#,
   GL_OUT_OF_MEMORY                           => 16#0505#
);
for ErrorEnm'Size use GLenum'size;

function glGetError
return ErrorEnm;


-- Connection description
type StringEnm is
(
   GL_VENDOR,
   GL_RENDERER,
   GL_VERSION,
   GL_EXTENSIONS
);
for StringEnm use
(
   GL_VENDOR                                  => 16#1F00#,
   GL_RENDERER                                => 16#1F01#,
   GL_VERSION                                 => 16#1F02#,
   GL_EXTENSIONS                              => 16#1F03#
);
for StringEnm'Size use GLenum'size;

function glGetString (name: StringEnm)
return GLubytePtr;


-- Behavior hints
type HintEnm is
(
   GL_PERSPECTIVE_CORRECTION_HINT,
   GL_POINT_SMOOTH_HINT,
   GL_LINE_SMOOTH_HINT,
   GL_POLYGON_SMOOTH_HINT,
   GL_FOG_HINT
);
for HintEnm use
(
   GL_PERSPECTIVE_CORRECTION_HINT             => 16#0C50#,
   GL_POINT_SMOOTH_HINT                       => 16#0C51#,
   GL_LINE_SMOOTH_HINT                        => 16#0C52#,
   GL_POLYGON_SMOOTH_HINT                     => 16#0C53#,
   GL_FOG_HINT                                => 16#0C54#
);
for HintEnm'Size use GLenum'size;

type HintModeEnm is
(
   GL_DONT_CARE,
   GL_FASTEST,
   GL_NICEST
);
for HintModeEnm use
(
   GL_DONT_CARE                               => 16#1100#,
   GL_FASTEST                                 => 16#1101#,
   GL_NICEST                                  => 16#1102#
);
for HintModeEnm'Size use GLenum'size;

procedure glHint (target: HintEnm;
                  mode  : HintModeEnm);


-- Accumulation buffer
type AccumEnm is
(
   GL_ACCUM,
   GL_LOAD,
   GL_RETURN,
   GL_MULT,
   GL_ADD
);
for AccumEnm use
(
   GL_ACCUM                                   => 16#0100#,
   GL_LOAD                                    => 16#0101#,
   GL_RETURN                                  => 16#0102#,
   GL_MULT                                    => 16#0103#,
   GL_ADD                                     => 16#0104#
);
for AccumEnm'Size use GLenum'size;

procedure glAccum (op   : AccumEnm;
                   value: GLfloat);


-- Matrix mode
type MatrixModeEnm is
(
   GL_MODELVIEW,
   GL_PROJECTION,
   GL_TEXTURE
);
for MatrixModeEnm use
(
   GL_MODELVIEW                               => 16#1700#,
   GL_PROJECTION                              => 16#1701#,
   GL_TEXTURE                                 => 16#1702#
);
for MatrixModeEnm'Size use GLenum'size;

procedure glMatrixMode (mode: MatrixModeEnm);


-- Display liststype ListModeEnm is
type ListModeEnm is
(
   GL_COMPILE,
   GL_COMPILE_AND_EXECUTE
);
for ListModeEnm use
(
   GL_COMPILE                                 => 16#1300#,
   GL_COMPILE_AND_EXECUTE                     => 16#1301#
);
for ListModeEnm'Size use GLenum'size;

type OffsetTypeEnm is
(
   GL_BYTE,
   GL_UNSIGNED_BYTE,
   GL_SHORT,
   GL_UNSIGNED_SHORT,
   GL_INT,
   GL_UNSIGNED_INT,
   GL_FLOAT,
   GL_2_BYTES,
   GL_3_BYTES,
   GL_4_BYTES
);
for OffsetTypeEnm use
(
   GL_BYTE                                    => 16#1400#,
   GL_UNSIGNED_BYTE                           => 16#1401#,
   GL_SHORT                                   => 16#1402#,
   GL_UNSIGNED_SHORT                          => 16#1403#,
   GL_INT                                     => 16#1404#,
   GL_UNSIGNED_INT                            => 16#1405#,
   GL_FLOAT                                   => 16#1406#,
   GL_2_BYTES                                 => 16#1407#,
   GL_3_BYTES                                 => 16#1408#,
   GL_4_BYTES                                 => 16#1409#
);
for OffsetTypeEnm'Size use GLenum'size;

function glIsList (list: GLuint)
return GLboolean;

procedure glDeleteLists (list   : GLuint;
                         c_range: GLsizei);

function glGenLists (c_range: GLsizei)
return GLuint;

procedure glNewList (list: GLuint;
                     mode: ListModeEnm);

procedure glEndList;

procedure glCallList (list: GLuint);

procedure glCallLists (n     : GLsizei;
                       c_type: OffsetTypeEnm;
                       lists : GLpointer);

procedure glListBase (base: GLuint);


-- Object definition
type ObjectTypeEnm is
(
   GL_POINTS,
   GL_LINES,
   GL_LINE_LOOP,
   GL_LINE_STRIP,
   GL_TRIANGLES,
   GL_TRIANGLE_STRIP,
   GL_TRIANGLE_FAN,
   GL_QUADS,
   GL_QUAD_STRIP,
   GL_POLYGON
);
for ObjectTypeEnm use
(
   GL_POINTS                                  => 16#0000#,
   GL_LINES                                   => 16#0001#,
   GL_LINE_LOOP                               => 16#0002#,
   GL_LINE_STRIP                              => 16#0003#,
   GL_TRIANGLES                               => 16#0004#,
   GL_TRIANGLE_STRIP                          => 16#0005#,
   GL_TRIANGLE_FAN                            => 16#0006#,
   GL_QUADS                                   => 16#0007#,
   GL_QUAD_STRIP                              => 16#0008#,
   GL_POLYGON                                 => 16#0009#
);
for ObjectTypeEnm'Size use GLenum'size;

procedure glBegin (mode: ObjectTypeEnm);

procedure glEnd;


-- Vertex arrays and related
type VertexTypeEnm is
(
   GL_SHORT,
   GL_INT,
   GL_FLOAT,
   GL_DOUBLE
);
for VertexTypeEnm use
(
   GL_SHORT                                   => 16#1402#,
   GL_INT                                     => 16#1404#,
   GL_FLOAT                                   => 16#1406#,
   GL_DOUBLE                                  => 16#140A#
);
for VertexTypeEnm'Size use GLenum'size;

type NormalTypeEnm is
(
   GL_BYTE,
   GL_SHORT,
   GL_INT,
   GL_FLOAT,
   GL_DOUBLE
);
for NormalTypeEnm use
(
   GL_BYTE                                    => 16#1400#,
   GL_SHORT                                   => 16#1402#,
   GL_INT                                     => 16#1404#,
   GL_FLOAT                                   => 16#1406#,
   GL_DOUBLE                                  => 16#140A#
);
for NormalTypeEnm'Size use GLenum'size;

type ColorTypeEnm is
(
   GL_BYTE,
   GL_UNSIGNED_BYTE,
   GL_SHORT,
   GL_UNSIGNED_SHORT,
   GL_INT,
   GL_UNSIGNED_INT,
   GL_FLOAT,
   GL_DOUBLE
);
for ColorTypeEnm use
(
   GL_BYTE                                    => 16#1400#,
   GL_UNSIGNED_BYTE                           => 16#1401#,
   GL_SHORT                                   => 16#1402#,
   GL_UNSIGNED_SHORT                          => 16#1403#,
   GL_INT                                     => 16#1404#,
   GL_UNSIGNED_INT                            => 16#1405#,
   GL_FLOAT                                   => 16#1406#,
   GL_DOUBLE                                  => 16#140A#
);
for ColorTypeEnm'Size use GLenum'size;

type IndexTypeEnm is
(
   GL_UNSIGNED_BYTE,
   GL_SHORT,
   GL_INT,
   GL_FLOAT,
   GL_DOUBLE
);
for IndexTypeEnm use
(
   GL_UNSIGNED_BYTE                           => 16#1401#,
   GL_SHORT                                   => 16#1402#,
   GL_INT                                     => 16#1404#,
   GL_FLOAT                                   => 16#1406#,
   GL_DOUBLE                                  => 16#140A#
);
for IndexTypeEnm'Size use GLenum'size;

type TexCoordTypeEnm is
(
   GL_SHORT,
   GL_INT,
   GL_FLOAT,
   GL_DOUBLE
);
for TexCoordTypeEnm use
(
   GL_SHORT                                   => 16#1402#,
   GL_INT                                     => 16#1404#,
   GL_FLOAT                                   => 16#1406#,
   GL_DOUBLE                                  => 16#140A#
);
for TexCoordTypeEnm'Size use GLenum'size;

type ArrayIndexTypeEnm is
(
   GL_UNSIGNED_BYTE,
   GL_UNSIGNED_SHORT,
   GL_UNSIGNED_INT
);
for ArrayIndexTypeEnm use
(
   GL_UNSIGNED_BYTE                           => 16#1401#,
   GL_UNSIGNED_SHORT                          => 16#1403#,
   GL_UNSIGNED_INT                            => 16#1405#
);
for ArrayIndexTypeEnm'Size use GLenum'size;

type InterleaveFormatEnm is
(
   GL_V2F,
   GL_V3F,
   GL_C4UB_V2F,
   GL_C4UB_V3F,
   GL_C3F_V3F,
   GL_N3F_V3F,
   GL_C4F_N3F_V3F,
   GL_T2F_V3F,
   GL_T4F_V4F,
   GL_T2F_C4UB_V3F,
   GL_T2F_C3F_V3F,
   GL_T2F_N3F_V3F,
   GL_T2F_C4F_N3F_V3F,
   GL_T4F_C4F_N3F_V4F
);
for InterleaveFormatEnm use
(
   GL_V2F                                     => 16#2A20#,
   GL_V3F                                     => 16#2A21#,
   GL_C4UB_V2F                                => 16#2A22#,
   GL_C4UB_V3F                                => 16#2A23#,
   GL_C3F_V3F                                 => 16#2A24#,
   GL_N3F_V3F                                 => 16#2A25#,
   GL_C4F_N3F_V3F                             => 16#2A26#,
   GL_T2F_V3F                                 => 16#2A27#,
   GL_T4F_V4F                                 => 16#2A28#,
   GL_T2F_C4UB_V3F                            => 16#2A29#,
   GL_T2F_C3F_V3F                             => 16#2A2A#,
   GL_T2F_N3F_V3F                             => 16#2A2B#,
   GL_T2F_C4F_N3F_V3F                         => 16#2A2C#,
   GL_T4F_C4F_N3F_V4F                         => 16#2A2D#
);
for InterleaveFormatEnm'Size use GLenum'size;

procedure glVertexPointer (size  : GLint;
                           c_type: VertexTypeEnm;
                           stride: GLsizei;
                           ptr   : GLpointer);

procedure glNormalPointer (c_type: NormalTypeEnm;
                           stride: GLsizei;
                           ptr   : GLpointer);

procedure glColorPointer (size  : GLint;
                          c_type: ColorTypeEnm;
                          stride: GLsizei;
                          ptr   : GLpointer);

procedure glIndexPointer (c_type: IndexTypeEnm;
                          stride: GLsizei;
                          ptr   : GLpointer);

procedure glTexCoordPointer (size  : GLint;
                             c_type: TexCoordTypeEnm;
                             stride: GLsizei;
                             ptr   : GLpointer);

procedure glEdgeFlagPointer (stride: GLsizei;
                             ptr   : GLbooleanPtr);

procedure glArrayElement (i: GLint);

procedure glDrawArrays (mode : ObjectTypeEnm;
                        first: GLint;
                        count: GLsizei);

procedure glDrawElements (mode   : ObjectTypeEnm;
                          count  : GLsizei;
                          c_type : ArrayIndexTypeEnm;
                          indices: GLpointer);

procedure glInterleavedArrays (format : InterleaveFormatEnm;
                               stride : GLsizei;
                               pointer: GLpointer);


-- Shading model
type ShadeModeEnm is
(
   GL_FLAT,
   GL_SMOOTH
);
for ShadeModeEnm use
(
   GL_FLAT                                    => 16#1D00#,
   GL_SMOOTH                                  => 16#1D01#
);
for ShadeModeEnm'Size use GLenum'size;

procedure glShadeModel (mode: ShadeModeEnm);


-- Lighting
type LightIDEnm is
(
   GL_LIGHT0,
   GL_LIGHT1,
   GL_LIGHT2,
   GL_LIGHT3,
   GL_LIGHT4,
   GL_LIGHT5,
   GL_LIGHT6,
   GL_LIGHT7
);
for LightIDEnm use
(
   GL_LIGHT0                                  => 16#4000#,
   GL_LIGHT1                                  => 16#4001#,
   GL_LIGHT2                                  => 16#4002#,
   GL_LIGHT3                                  => 16#4003#,
   GL_LIGHT4                                  => 16#4004#,
   GL_LIGHT5                                  => 16#4005#,
   GL_LIGHT6                                  => 16#4006#,
   GL_LIGHT7                                  => 16#4007#
);
for LightIDEnm'Size use GLenum'size;

type LightParameterEnm is
(
   GL_SPOT_EXPONENT,
   GL_SPOT_CUTOFF,
   GL_CONSTANT_ATTENUATION,
   GL_LINEAR_ATTENUATION,
   GL_QUADRATIC_ATTENUATION
);
for LightParameterEnm use
(
   GL_SPOT_EXPONENT                           => 16#1205#,
   GL_SPOT_CUTOFF                             => 16#1206#,
   GL_CONSTANT_ATTENUATION                    => 16#1207#,
   GL_LINEAR_ATTENUATION                      => 16#1208#,
   GL_QUADRATIC_ATTENUATION                   => 16#1209#
);
for LightParameterEnm'Size use GLenum'size;

type LightParameterVEnm is
(
   GL_AMBIENT,
   GL_DIFFUSE,
   GL_SPECULAR,
   GL_POSITION,
   GL_SPOT_DIRECTION,
   GL_SPOT_EXPONENT,
   GL_SPOT_CUTOFF,
   GL_CONSTANT_ATTENUATION,
   GL_LINEAR_ATTENUATION,
   GL_QUADRATIC_ATTENUATION
);
for LightParameterVEnm use
(
   GL_AMBIENT                                 => 16#1200#,
   GL_DIFFUSE                                 => 16#1201#,
   GL_SPECULAR                                => 16#1202#,
   GL_POSITION                                => 16#1203#,
   GL_SPOT_DIRECTION                          => 16#1204#,
   GL_SPOT_EXPONENT                           => 16#1205#,
   GL_SPOT_CUTOFF                             => 16#1206#,
   GL_CONSTANT_ATTENUATION                    => 16#1207#,
   GL_LINEAR_ATTENUATION                      => 16#1208#,
   GL_QUADRATIC_ATTENUATION                   => 16#1209#
);
for LightParameterVEnm'Size use GLenum'size;

type LightModelEnm is
(
   GL_LIGHT_MODEL_LOCAL_VIEWER,
   GL_LIGHT_MODEL_TWO_SIDE
);
for LightModelEnm use
(
   GL_LIGHT_MODEL_LOCAL_VIEWER                => 16#0B51#,
   GL_LIGHT_MODEL_TWO_SIDE                    => 16#0B52#
);
for LightModelEnm'Size use GLenum'size;

type LightModelVEnm is
(
   GL_LIGHT_MODEL_LOCAL_VIEWER,
   GL_LIGHT_MODEL_TWO_SIDE,
   GL_LIGHT_MODEL_AMBIENT
);
for LightModelVEnm use
(
   GL_LIGHT_MODEL_LOCAL_VIEWER                => 16#0B51#,
   GL_LIGHT_MODEL_TWO_SIDE                    => 16#0B52#,
   GL_LIGHT_MODEL_AMBIENT                     => 16#0B53#
);
for LightModelVEnm'Size use GLenum'size;

procedure glLightf (light: LightIDEnm;
                    pname: LightParameterEnm;
                    param: GLfloat);

procedure glLighti (light: LightIDEnm;
                    pname: LightParameterEnm;
                    param: GLint);

procedure glLightfv (light : LightIDEnm;
                     pname : LightParameterVEnm;
                     params: GLfloatPtr);

procedure glLightiv (light : LightIDEnm;
                     pname : LightParameterVEnm;
                     params: GLintPtr);

procedure glGetLightfv (light : LightIDEnm;
                        pname : LightParameterVEnm;
                        params: GLfloatPtr);

procedure glGetLightiv (light : LightIDEnm;
                        pname : LightParameterVEnm;
                        params: GLintPtr);

procedure glLightModelf (pname: LightModelEnm;
                         param: GLfloat);

procedure glLightModeli (pname: LightModelEnm;
                         param: GLint);

procedure glLightModelfv (pname : LightModelVEnm;
                          params: GLfloatPtr);

procedure glLightModeliv (pname : LightModelVEnm;
                          params: GLintPtr);


-- Materials
type MaterialParameterEnm is
(
   GL_SHININESS
);
for MaterialParameterEnm use
(
   GL_SHININESS                               => 16#1601#
);
for MaterialParameterEnm'Size use GLenum'size;

type MaterialParameterVEnm is
(
   GL_AMBIENT,
   GL_DIFFUSE,
   GL_SPECULAR,
   GL_EMISSION,
   GL_SHININESS,
   GL_AMBIENT_AND_DIFFUSE,
   GL_COLOR_INDEXES
);
for MaterialParameterVEnm use
(
   GL_AMBIENT                                 => 16#1200#,
   GL_DIFFUSE                                 => 16#1201#,
   GL_SPECULAR                                => 16#1202#,
   GL_EMISSION                                => 16#1600#,
   GL_SHININESS                               => 16#1601#,
   GL_AMBIENT_AND_DIFFUSE                     => 16#1602#,
   GL_COLOR_INDEXES                           => 16#1603#
);
for MaterialParameterVEnm'Size use GLenum'size;

type GetMaterialParameterEnm is
(
   GL_AMBIENT,
   GL_DIFFUSE,
   GL_SPECULAR,
   GL_EMISSION,
   GL_SHININESS,
   GL_COLOR_INDEXES
);
for GetMaterialParameterEnm use
(
   GL_AMBIENT                                 => 16#1200#,
   GL_DIFFUSE                                 => 16#1201#,
   GL_SPECULAR                                => 16#1202#,
   GL_EMISSION                                => 16#1600#,
   GL_SHININESS                               => 16#1601#,
   GL_COLOR_INDEXES                           => 16#1603#
);
for GetMaterialParameterEnm'Size use GLenum'size;

type ColorMaterialEnm is
(
   GL_AMBIENT,
   GL_DIFFUSE,
   GL_SPECULAR,
   GL_EMISSION,
   GL_AMBIENT_AND_DIFFUSE
);
for ColorMaterialEnm use
(
   GL_AMBIENT                                 => 16#1200#,
   GL_DIFFUSE                                 => 16#1201#,
   GL_SPECULAR                                => 16#1202#,
   GL_EMISSION                                => 16#1600#,
   GL_AMBIENT_AND_DIFFUSE                     => 16#1602#
);
for ColorMaterialEnm'Size use GLenum'size;

procedure glMaterialf (face : FaceEnm;
                       pname: MaterialParameterEnm;
                       param: GLfloat);

procedure glMateriali (face : FaceEnm;
                       pname: MaterialParameterEnm;
                       param: GLint);

procedure glMaterialfv (face  : FaceEnm;
                        pname : MaterialParameterVEnm;
                        params: GLfloatPtr);

procedure glMaterialiv (face  : FaceEnm;
                        pname : MaterialParameterVEnm;
                        params: GLintPtr);

procedure glGetMaterialfv (face  : FaceEnm;
                           pname : GetMaterialParameterEnm;
                           params: GLfloatPtr);

procedure glGetMaterialiv (face  : FaceEnm;
                           pname : GetMaterialParameterEnm;
                           params: GLintPtr);

procedure glColorMaterial (face: FaceEnm;
                           mode: ColorMaterialEnm);


-- Pixel stuff
type PixelStorageEnm is
(
   GL_UNPACK_SWAP_BYTES,
   GL_UNPACK_LSB_FIRST,
   GL_UNPACK_ROW_LENGTH,
   GL_UNPACK_SKIP_ROWS,
   GL_UNPACK_SKIP_PIXELS,
   GL_UNPACK_ALIGNMENT,
   GL_PACK_SWAP_BYTES,
   GL_PACK_LSB_FIRST,
   GL_PACK_ROW_LENGTH,
   GL_PACK_SKIP_ROWS,
   GL_PACK_SKIP_PIXELS,
   GL_PACK_ALIGNMENT
);
for PixelStorageEnm use
(
   GL_UNPACK_SWAP_BYTES                       => 16#0CF0#,
   GL_UNPACK_LSB_FIRST                        => 16#0CF1#,
   GL_UNPACK_ROW_LENGTH                       => 16#0CF2#,
   GL_UNPACK_SKIP_ROWS                        => 16#0CF3#,
   GL_UNPACK_SKIP_PIXELS                      => 16#0CF4#,
   GL_UNPACK_ALIGNMENT                        => 16#0CF5#,
   GL_PACK_SWAP_BYTES                         => 16#0D00#,
   GL_PACK_LSB_FIRST                          => 16#0D01#,
   GL_PACK_ROW_LENGTH                         => 16#0D02#,
   GL_PACK_SKIP_ROWS                          => 16#0D03#,
   GL_PACK_SKIP_PIXELS                        => 16#0D04#,
   GL_PACK_ALIGNMENT                          => 16#0D05#
);
for PixelStorageEnm'Size use GLenum'size;

type PixelTransferEnm is
(
   GL_MAP_COLOR,
   GL_MAP_STENCIL,
   GL_INDEX_SHIFT,
   GL_INDEX_OFFSET,
   GL_RED_SCALE,
   GL_RED_BIAS,
   GL_GREEN_SCALE,
   GL_GREEN_BIAS,
   GL_BLUE_SCALE,
   GL_BLUE_BIAS,
   GL_ALPHA_SCALE,
   GL_ALPHA_BIAS,
   GL_DEPTH_SCALE,
   GL_DEPTH_BIAS
);
for PixelTransferEnm use
(
   GL_MAP_COLOR                               => 16#0D10#,
   GL_MAP_STENCIL                             => 16#0D11#,
   GL_INDEX_SHIFT                             => 16#0D12#,
   GL_INDEX_OFFSET                            => 16#0D13#,
   GL_RED_SCALE                               => 16#0D14#,
   GL_RED_BIAS                                => 16#0D15#,
   GL_GREEN_SCALE                             => 16#0D18#,
   GL_GREEN_BIAS                              => 16#0D19#,
   GL_BLUE_SCALE                              => 16#0D1A#,
   GL_BLUE_BIAS                               => 16#0D1B#,
   GL_ALPHA_SCALE                             => 16#0D1C#,
   GL_ALPHA_BIAS                              => 16#0D1D#,
   GL_DEPTH_SCALE                             => 16#0D1E#,
   GL_DEPTH_BIAS                              => 16#0D1F#
);
for PixelTransferEnm'Size use GLenum'size;

type PixelMapEnm is
(
   GL_PIXEL_MAP_I_TO_I,
   GL_PIXEL_MAP_S_TO_S,
   GL_PIXEL_MAP_I_TO_R,
   GL_PIXEL_MAP_I_TO_G,
   GL_PIXEL_MAP_I_TO_B,
   GL_PIXEL_MAP_I_TO_A,
   GL_PIXEL_MAP_R_TO_R,
   GL_PIXEL_MAP_G_TO_G,
   GL_PIXEL_MAP_B_TO_B,
   GL_PIXEL_MAP_A_TO_A
);
for PixelMapEnm use
(
   GL_PIXEL_MAP_I_TO_I                        => 16#0C70#,
   GL_PIXEL_MAP_S_TO_S                        => 16#0C71#,
   GL_PIXEL_MAP_I_TO_R                        => 16#0C72#,
   GL_PIXEL_MAP_I_TO_G                        => 16#0C73#,
   GL_PIXEL_MAP_I_TO_B                        => 16#0C74#,
   GL_PIXEL_MAP_I_TO_A                        => 16#0C75#,
   GL_PIXEL_MAP_R_TO_R                        => 16#0C76#,
   GL_PIXEL_MAP_G_TO_G                        => 16#0C77#,
   GL_PIXEL_MAP_B_TO_B                        => 16#0C78#,
   GL_PIXEL_MAP_A_TO_A                        => 16#0C79#
);
for PixelMapEnm'Size use GLenum'size;

type PixelFormatEnm is
(
   GL_COLOR_INDEX,
   GL_STENCIL_INDEX,
   GL_DEPTH_COMPONENT,
   GL_RED,
   GL_GREEN,
   GL_BLUE,
   GL_ALPHA,
   GL_RGB,
   GL_RGBA,
   GL_LUMINANCE,
   GL_LUMINANCE_ALPHA
);
for PixelFormatEnm use
(
   GL_COLOR_INDEX                             => 16#1900#,
   GL_STENCIL_INDEX                           => 16#1901#,
   GL_DEPTH_COMPONENT                         => 16#1902#,
   GL_RED                                     => 16#1903#,
   GL_GREEN                                   => 16#1904#,
   GL_BLUE                                    => 16#1905#,
   GL_ALPHA                                   => 16#1906#,
   GL_RGB                                     => 16#1907#,
   GL_RGBA                                    => 16#1908#,
   GL_LUMINANCE                               => 16#1909#,
   GL_LUMINANCE_ALPHA                         => 16#190A#
);
for PixelFormatEnm'Size use GLenum'size;

type PixelDataTypeEnm is
(
   GL_BYTE,
   GL_UNSIGNED_BYTE,
   GL_SHORT,
   GL_UNSIGNED_SHORT,
   GL_INT,
   GL_UNSIGNED_INT,
   GL_FLOAT,
   GL_BITMAP
);
for PixelDataTypeEnm use
(
   GL_BYTE                                    => 16#1400#,
   GL_UNSIGNED_BYTE                           => 16#1401#,
   GL_SHORT                                   => 16#1402#,
   GL_UNSIGNED_SHORT                          => 16#1403#,
   GL_INT                                     => 16#1404#,
   GL_UNSIGNED_INT                            => 16#1405#,
   GL_FLOAT                                   => 16#1406#,
   GL_BITMAP                                  => 16#1A00#
);
for PixelDataTypeEnm'Size use GLenum'size;

type PixelCopyTypeEnm is
(
   GL_COLOR,
   GL_DEPTH,
   GL_STENCIL
);
for PixelCopyTypeEnm use
(
   GL_COLOR                                   => 16#1800#,
   GL_DEPTH                                   => 16#1801#,
   GL_STENCIL                                 => 16#1802#
);
for PixelCopyTypeEnm'Size use GLenum'size;

procedure glPixelZoom (xfactor: GLfloat;
                       yfactor: GLfloat);

procedure glPixelStoref (pname: PixelStorageEnm;
                         param: GLfloat);

procedure glPixelStorei (pname: PixelStorageEnm;
                         param: GLint);

procedure glPixelTransferf (pname: PixelTransferEnm;
                            param: GLfloat);

procedure glPixelTransferi (pname: PixelTransferEnm;
                            param: GLint);

procedure glPixelMapfv (map    : PixelMapEnm;
                        mapsize: GLint;
                        values : GLfloatPtr);

procedure glPixelMapuiv (map    : PixelMapEnm;
                         mapsize: GLint;
                         values : GLuintPtr);

procedure glPixelMapusv (map    : PixelMapEnm;
                         mapsize: GLint;
                         values : GLushortPtr);

procedure glGetPixelMapfv (map   : PixelMapEnm;
                           values: GLfloatPtr);

procedure glGetPixelMapuiv (map   : PixelMapEnm;
                            values: GLuintPtr);

procedure glGetPixelMapusv (map   : PixelMapEnm;
                            values: GLushortPtr);

procedure glReadPixels (x     : GLint;
                        y     : GLint;
                        width : GLsizei;
                        height: GLsizei;
                        format: PixelFormatEnm;
                        c_type: PixelDataTypeEnm;
                        pixels: GLpointer);

procedure glDrawPixels (width : GLsizei;
                        height: GLsizei;
                        format: PixelFormatEnm;
                        c_type: PixelDataTypeEnm;
                        pixels: GLpointer);

procedure glCopyPixels (x     : GLint;
                        y     : GLint;
                        width : GLsizei;
                        height: GLsizei;
                        c_type: PixelCopyTypeEnm);


-- Texturing
type TexCoordEnm is
(
   GL_S,
   GL_T,
   GL_R,
   GL_Q
);
for TexCoordEnm use
(
   GL_S                                       => 16#2000#,
   GL_T                                       => 16#2001#,
   GL_R                                       => 16#2002#,
   GL_Q                                       => 16#2003#
);
for TexCoordEnm'Size use GLenum'size;

type TexParameterEnm is
(
   GL_TEXTURE_GEN_MODE
);
for TexParameterEnm use
(
   GL_TEXTURE_GEN_MODE                        => 16#2500#
);
for TexParameterEnm'Size use GLenum'size;

type TexParameterVEnm is
(
   GL_TEXTURE_GEN_MODE,
   GL_OBJECT_PLANE,
   GL_EYE_PLANE
);
for TexParameterVEnm use
(
   GL_TEXTURE_GEN_MODE                        => 16#2500#,
   GL_OBJECT_PLANE                            => 16#2501#,
   GL_EYE_PLANE                               => 16#2502#
);
for TexParameterVEnm'Size use GLenum'size;

type TexEnvEnm is
(
   GL_TEXTURE_ENV
);
for TexEnvEnm use
(
   GL_TEXTURE_ENV                             => 16#2300#
);
for TexEnvEnm'Size use GLenum'size;

type TexEnvParameterEnm is
(
   GL_TEXTURE_ENV_MODE
);
for TexEnvParameterEnm use
(
   GL_TEXTURE_ENV_MODE                        => 16#2200#
);
for TexEnvParameterEnm'Size use GLenum'size;

type TexEnvParameterVEnm is
(
   GL_TEXTURE_ENV_MODE,
   GL_TEXTURE_ENV_COLOR
);
for TexEnvParameterVEnm use
(
   GL_TEXTURE_ENV_MODE                        => 16#2200#,
   GL_TEXTURE_ENV_COLOR                       => 16#2201#
);
for TexEnvParameterVEnm'Size use GLenum'size;

type TargetTexEnm is
(
   GL_TEXTURE_1D,
   GL_TEXTURE_2D
);
for TargetTexEnm use
(
   GL_TEXTURE_1D                              => 16#0DE0#,
   GL_TEXTURE_2D                              => 16#0DE1#
);
for TargetTexEnm'Size use GLenum'size;

type TexParamEnm is
(
   GL_TEXTURE_MAG_FILTER,
   GL_TEXTURE_MIN_FILTER,
   GL_TEXTURE_WRAP_S,
   GL_TEXTURE_WRAP_T,
   GL_TEXTURE_PRIORITY
);
for TexParamEnm use
(
   GL_TEXTURE_MAG_FILTER                      => 16#2800#,
   GL_TEXTURE_MIN_FILTER                      => 16#2801#,
   GL_TEXTURE_WRAP_S                          => 16#2802#,
   GL_TEXTURE_WRAP_T                          => 16#2803#,
   GL_TEXTURE_PRIORITY                        => 16#8066#
);
for TexParamEnm'Size use GLenum'size;

type TexParamVEnm is
(
   GL_TEXTURE_BORDER_COLOR,
   GL_TEXTURE_MAG_FILTER,
   GL_TEXTURE_MIN_FILTER,
   GL_TEXTURE_WRAP_S,
   GL_TEXTURE_WRAP_T,
   GL_TEXTURE_PRIORITY
);
for TexParamVEnm use
(
   GL_TEXTURE_BORDER_COLOR                    => 16#1004#,
   GL_TEXTURE_MAG_FILTER                      => 16#2800#,
   GL_TEXTURE_MIN_FILTER                      => 16#2801#,
   GL_TEXTURE_WRAP_S                          => 16#2802#,
   GL_TEXTURE_WRAP_T                          => 16#2803#,
   GL_TEXTURE_PRIORITY                        => 16#8066#
);
for TexParamVEnm'Size use GLenum'size;

type GetTexParamEnm is
(
   GL_TEXTURE_BORDER_COLOR,
   GL_TEXTURE_MAG_FILTER,
   GL_TEXTURE_MIN_FILTER,
   GL_TEXTURE_WRAP_S,
   GL_TEXTURE_WRAP_T,
   GL_TEXTURE_PRIORITY,
   GL_TEXTURE_RESIDENT
);
for GetTexParamEnm use
(
   GL_TEXTURE_BORDER_COLOR                    => 16#1004#,
   GL_TEXTURE_MAG_FILTER                      => 16#2800#,
   GL_TEXTURE_MIN_FILTER                      => 16#2801#,
   GL_TEXTURE_WRAP_S                          => 16#2802#,
   GL_TEXTURE_WRAP_T                          => 16#2803#,
   GL_TEXTURE_PRIORITY                        => 16#8066#,
   GL_TEXTURE_RESIDENT                        => 16#8067#
);
for GetTexParamEnm'Size use GLenum'size;

type TargetTexLevelEnm is
(
   GL_TEXTURE_1D,
   GL_TEXTURE_2D,
   GL_PROXY_TEXTURE_1D,
   GL_PROXY_TEXTURE_2D
);
for TargetTexLevelEnm use
(
   GL_TEXTURE_1D                              => 16#0DE0#,
   GL_TEXTURE_2D                              => 16#0DE1#,
   GL_PROXY_TEXTURE_1D                        => 16#8063#,
   GL_PROXY_TEXTURE_2D                        => 16#8064#
);
for TargetTexLevelEnm'Size use GLenum'size;

type TexLevelParameterEnm is
(
   GL_TEXTURE_WIDTH,
   GL_TEXTURE_HEIGHT,
   GL_TEXTURE_COMPONENTS,
   GL_TEXTURE_BORDER,
   GL_TEXTURE_RED_SIZE,
   GL_TEXTURE_GREEN_SIZE,
   GL_TEXTURE_BLUE_SIZE,
   GL_TEXTURE_ALPHA_SIZE,
   GL_TEXTURE_LUMINANCE_SIZE,
   GL_TEXTURE_INTENSITY_SIZE,
   GL_TEXTURE_INTERNAL_FORMAT
);
for TexLevelParameterEnm use
(
   GL_TEXTURE_WIDTH                           => 16#1000#,
   GL_TEXTURE_HEIGHT                          => 16#1001#,
   GL_TEXTURE_COMPONENTS                      => 16#1003#,  -- HP docs say to use this in 1.0 instead of INTERNAL_FORMAT???
   GL_TEXTURE_BORDER                          => 16#1005#,
   GL_TEXTURE_RED_SIZE                        => 16#805C#,
   GL_TEXTURE_GREEN_SIZE                      => 16#805D#,
   GL_TEXTURE_BLUE_SIZE                       => 16#805E#,
   GL_TEXTURE_ALPHA_SIZE                      => 16#805F#,
   GL_TEXTURE_LUMINANCE_SIZE                  => 16#8060#,
   GL_TEXTURE_INTENSITY_SIZE                  => 16#8061#,
   GL_TEXTURE_INTERNAL_FORMAT                 => 16#FFFF#   -- fixme: Mesa 2.5 does not support!!  What's the real value?
);
for TexLevelParameterEnm'Size use GLenum'size;

type TargetTex1DEnm is
(
   GL_TEXTURE_1D,
   GL_PROXY_TEXTURE_1D
);
for TargetTex1DEnm use
(
   GL_TEXTURE_1D                              => 16#0DE0#,
   GL_PROXY_TEXTURE_1D                        => 16#8063#
);
for TargetTex1DEnm'Size use GLenum'size;

type TexFormatEnm is
(
   GL_ALPHA,
   GL_RGB,
   GL_RGBA,
   GL_LUMINANCE,
   GL_LUMINANCE_ALPHA,
   GL_R3_G3_B2,
   GL_ALPHA4,
   GL_ALPHA8,
   GL_ALPHA12,
   GL_ALPHA16,
   GL_LUMINANCE4,
   GL_LUMINANCE8,
   GL_LUMINANCE12,
   GL_LUMINANCE16,
   GL_LUMINANCE4_ALPHA4,
   GL_LUMINANCE6_ALPHA2,
   GL_LUMINANCE8_ALPHA8,
   GL_LUMINANCE12_ALPHA4,
   GL_LUMINANCE12_ALPHA12,
   GL_LUMINANCE16_ALPHA16,
   GL_INTENSITY,
   GL_INTENSITY4,
   GL_INTENSITY8,
   GL_INTENSITY12,
   GL_INTENSITY16,
   GL_RGB4,
   GL_RGB5,
   GL_RGB8,
   GL_RGB10,
   GL_RGB12,
   GL_RGB16,
   GL_RGBA2,
   GL_RGBA4,
   GL_RGB5_A1,
   GL_RGBA8,
   GL_RGB10_A2,
   GL_RGBA12,
   GL_RGBA16
);
for TexFormatEnm use
(
   GL_ALPHA                                   => 16#1906#,
   GL_RGB                                     => 16#1907#,
   GL_RGBA                                    => 16#1908#,
   GL_LUMINANCE                               => 16#1909#,
   GL_LUMINANCE_ALPHA                         => 16#190A#,
   GL_R3_G3_B2                                => 16#2A10#,
   GL_ALPHA4                                  => 16#803B#,
   GL_ALPHA8                                  => 16#803C#,
   GL_ALPHA12                                 => 16#803D#,
   GL_ALPHA16                                 => 16#803E#,
   GL_LUMINANCE4                              => 16#803F#,
   GL_LUMINANCE8                              => 16#8040#,
   GL_LUMINANCE12                             => 16#8041#,
   GL_LUMINANCE16                             => 16#8042#,
   GL_LUMINANCE4_ALPHA4                       => 16#8043#,
   GL_LUMINANCE6_ALPHA2                       => 16#8044#,
   GL_LUMINANCE8_ALPHA8                       => 16#8045#,
   GL_LUMINANCE12_ALPHA4                      => 16#8046#,
   GL_LUMINANCE12_ALPHA12                     => 16#8047#,
   GL_LUMINANCE16_ALPHA16                     => 16#8048#,
   GL_INTENSITY                               => 16#8049#,
   GL_INTENSITY4                              => 16#804A#,
   GL_INTENSITY8                              => 16#804B#,
   GL_INTENSITY12                             => 16#804C#,
   GL_INTENSITY16                             => 16#804D#,
   GL_RGB4                                    => 16#804F#,
   GL_RGB5                                    => 16#8050#,
   GL_RGB8                                    => 16#8051#,
   GL_RGB10                                   => 16#8052#,
   GL_RGB12                                   => 16#8053#,
   GL_RGB16                                   => 16#8054#,
   GL_RGBA2                                   => 16#8055#,
   GL_RGBA4                                   => 16#8056#,
   GL_RGB5_A1                                 => 16#8057#,
   GL_RGBA8                                   => 16#8058#,
   GL_RGB10_A2                                => 16#8059#,
   GL_RGBA12                                  => 16#805A#,
   GL_RGBA16                                  => 16#805B#
);
for TexFormatEnm'Size use GLenum'size;

type TexPixelFormatEnm is
(
   GL_COLOR_INDEX,
   GL_RED,
   GL_GREEN,
   GL_BLUE,
   GL_ALPHA,
   GL_RGB,
   GL_RGBA,
   GL_LUMINANCE,
   GL_LUMINANCE_ALPHA
);
for TexPixelFormatEnm use
(
   GL_COLOR_INDEX                             => 16#1900#,
   GL_RED                                     => 16#1903#,
   GL_GREEN                                   => 16#1904#,
   GL_BLUE                                    => 16#1905#,
   GL_ALPHA                                   => 16#1906#,
   GL_RGB                                     => 16#1907#,
   GL_RGBA                                    => 16#1908#,
   GL_LUMINANCE                               => 16#1909#,
   GL_LUMINANCE_ALPHA                         => 16#190A#
);
for TexPixelFormatEnm'Size use GLenum'size;

type TargetTex2DEnm is
(
   GL_TEXTURE_2D,
   GL_PROXY_TEXTURE_2D
);
for TargetTex2DEnm use
(
   GL_TEXTURE_2D                              => 16#0DE1#,
   GL_PROXY_TEXTURE_2D                        => 16#8064#
);
for TargetTex2DEnm'Size use GLenum'size;

type TexImageFormatEnm is
(
   GL_RED,
   GL_GREEN,
   GL_BLUE,
   GL_ALPHA,
   GL_RGB,
   GL_RGBA,
   GL_LUMINANCE,
   GL_LUMINANCE_ALPHA
);
for TexImageFormatEnm use
(
   GL_RED                                     => 16#1903#,
   GL_GREEN                                   => 16#1904#,
   GL_BLUE                                    => 16#1905#,
   GL_ALPHA                                   => 16#1906#,
   GL_RGB                                     => 16#1907#,
   GL_RGBA                                    => 16#1908#,
   GL_LUMINANCE                               => 16#1909#,
   GL_LUMINANCE_ALPHA                         => 16#190A#
);
for TexImageFormatEnm'Size use GLenum'size;

type TargetTex1DOnlyEnm is
(
   GL_TEXTURE_1D
);
for TargetTex1DOnlyEnm use
(
   GL_TEXTURE_1D                              => 16#0DE0#
);
for TargetTex1DOnlyEnm'Size use GLenum'size;

type TargetTex2DOnlyEnm is
(
   GL_TEXTURE_2D
);
for TargetTex2DOnlyEnm use
(
   GL_TEXTURE_2D                              => 16#0DE1#
);
for TargetTex2DOnlyEnm'Size use GLenum'size;

type TargetTex3DEnm is
(
   GL_TEXTURE_3D_EXT,
   GL_PROXY_TEXTURE_3D_EXT
);
for TargetTex3DEnm use
(
   GL_TEXTURE_3D_EXT                          => 16#806F#,
   GL_PROXY_TEXTURE_3D_EXT                    => 16#8070#
);
for TargetTex3DEnm'Size use GLenum'size;

type TargetTex3DOnlyEnm is
(
   GL_TEXTURE_3D_EXT
);
for TargetTex3DOnlyEnm use
(
   GL_TEXTURE_3D_EXT                          => 16#806F#
);
for TargetTex3DOnlyEnm'Size use GLenum'size;

-- Texture map parameters
GL_OBJECT_LINEAR               : constant := 16#2401#;
GL_EYE_LINEAR                  : constant := 16#2400#;
GL_SPHERE_MAP                  : constant := 16#2402#;

-- Texture filter parameter values
GL_NEAREST_MIPMAP_NEAREST      : constant := 16#2700#;
GL_NEAREST_MIPMAP_LINEAR       : constant := 16#2702#;
GL_LINEAR_MIPMAP_NEAREST       : constant := 16#2701#;
GL_LINEAR_MIPMAP_LINEAR        : constant := 16#2703#;
GL_DECAL                       : constant := 16#2101#;
GL_MODULATE                    : constant := 16#2100#;
GL_NEAREST                     : constant := 16#2600#;
GL_REPEAT                      : constant := 16#2901#;
GL_CLAMP                       : constant := 16#2900#;

procedure glTexGend (coord: TexCoordEnm;
                     pname: TexParameterEnm;
                     param: GLdouble);

procedure glTexGenf (coord: TexCoordEnm;
                     pname: TexParameterEnm;
                     param: GLfloat);

procedure glTexGeni (coord: TexCoordEnm;
                     pname: TexParameterEnm;
                     param: GLint);

procedure glTexGendv (coord : TexCoordEnm;
                      pname : TexParameterVEnm;
                      params: GLdoublePtr);

procedure glTexGenfv (coord : TexCoordEnm;
                      pname : TexParameterVEnm;
                      params: GLfloatPtr);

procedure glTexGeniv (coord : TexCoordEnm;
                      pname : TexParameterVEnm;
                      params: GLintPtr);

procedure glGetTexGendv (coord : TexCoordEnm;
                         pname : TexParameterVEnm;
                         params: GLdoublePtr);

procedure glGetTexGenfv (coord : TexCoordEnm;
                         pname : TexParameterVEnm;
                         params: GLfloatPtr);

procedure glGetTexGeniv (coord : TexCoordEnm;
                         pname : TexParameterVEnm;
                         params: GLintPtr);

procedure glTexEnvf (target: TexEnvEnm;
                     pname : TexEnvParameterEnm;
                     param : GLfloat);

procedure glTexEnvi (target: TexEnvEnm;
                     pname : TexEnvParameterEnm;
                     param : GLint);

procedure glTexEnvfv (target: TexEnvEnm;
                      pname : TexEnvParameterVEnm;
                      params: GLfloatPtr);

procedure glTexEnviv (target: TexEnvEnm;
                      pname : TexEnvParameterVEnm;
                      params: GLintPtr);

procedure glGetTexEnvfv (target: TexEnvEnm;
                         pname : TexEnvParameterVEnm;
                         params: GLfloatPtr);

procedure glGetTexEnviv (target: TexEnvEnm;
                         pname : TexEnvParameterVEnm;
                         params: GLintPtr);

procedure glTexParameterf (target: TargetTexEnm;
                           pname : TexParamEnm;
                           param : GLfloat);

procedure glTexParameteri (target: TargetTexEnm;
                           pname : TexParamEnm;
                           param : GLint);

procedure glTexParameterfv (target: TargetTexEnm;
                            pname : TexParamVEnm;
                            params: GLfloatPtr);

procedure glTexParameteriv (target: TargetTexEnm;
                            pname : TexParamVEnm;
                            params: GLintPtr);

procedure glGetTexParameterfv (target: TargetTexEnm;
                               pname : GetTexParamEnm;
                               params: GLfloatPtr);

procedure glGetTexParameteriv (target: TargetTexEnm;
                               pname : GetTexParamEnm;
                               params: GLintPtr);

procedure glGetTexLevelParameterfv (target: TargetTexLevelEnm;
                                    level : GLint;
                                    pname : TexLevelParameterEnm;
                                    params: GLfloatPtr);

procedure glGetTexLevelParameteriv (target: TargetTexLevelEnm;
                                    level : GLint;
                                    pname : TexLevelParameterEnm;
                                    params: GLintPtr);

procedure glTexImage1D (target        : TargetTex1DEnm;
                        level         : GLint;
                        internalFormat: TexFormatEnm;
                        width         : GLsizei;
                        border        : GLint;
                        format        : TexPixelFormatEnm;
                        c_type        : PixelDataTypeEnm;
                        pixels        : GLpointer);

procedure glTexImage2D (target        : TargetTex2DEnm;
                        level         : GLint;
                        internalFormat: TexFormatEnm;
                        width         : GLsizei;
                        height        : GLsizei;
                        border        : GLint;
                        format        : TexPixelFormatEnm;
                        c_type        : PixelDataTypeEnm;
                        pixels        : GLpointer);

procedure glGetTexImage (target: TargetTexEnm;
                         level : GLint;
                         format: TexImageFormatEnm;
                         c_type: PixelDataTypeEnm;
                         pixels: GLpointer);

procedure glGenTextures (n       : GLsizei;
                         textures: GLuintPtr);

procedure glDeleteTextures (n       : GLsizei;
                            textures: GLuintPtr);

procedure glBindTexture (target : TargetTexEnm;
                         texture: GLuint);

procedure glPrioritizeTextures (n         : GLsizei;
                                textures  : GLuintPtr;
                                priorities: GLclampfPtr);

function glAreTexturesResident (n         : GLsizei;
                                textures  : GLuintPtr;
                                residences: GLbooleanPtr)
return GLboolean;

function glIsTexture (texture: GLuint)
return GLboolean;

procedure glTexSubImage1D (target : TargetTex1DOnlyEnm;
                           level  : GLint;
                           xoffset: GLint;
                           width  : GLsizei;
                           format : TexPixelFormatEnm;
                           c_type : PixelDataTypeEnm;
                           pixels : GLpointer);

procedure glTexSubImage2D (target : TargetTex2DOnlyEnm;
                           level  : GLint;
                           xoffset: GLint;
                           yoffset: GLint;
                           width  : GLsizei;
                           height : GLsizei;
                           format : TexPixelFormatEnm;
                           c_type : PixelDataTypeEnm;
                           pixels : GLpointer);

procedure glCopyTexImage1D (target        : TargetTex1DOnlyEnm;
                            level         : GLint;
                            internalformat: TexFormatEnm;
                            x             : GLint;
                            y             : GLint;
                            width         : GLsizei;
                            border        : GLint);

procedure glCopyTexImage2D (target        : TargetTex2DOnlyEnm;
                            level         : GLint;
                            internalformat: TexFormatEnm;
                            x             : GLint;
                            y             : GLint;
                            width         : GLsizei;
                            height        : GLsizei;
                            border        : GLint);

procedure glCopyTexSubImage1D (target : TargetTex1DOnlyEnm;
                               level  : GLint;
                               xoffset: GLint;
                               x      : GLint;
                               y      : GLint;
                               width  : GLsizei);

procedure glCopyTexSubImage2D (target : TargetTex2DOnlyEnm;
                               level  : GLint;
                               xoffset: GLint;
                               yoffset: GLint;
                               x      : GLint;
                               y      : GLint;
                               width  : GLsizei;
                               height : GLsizei);

procedure glTexImage3DEXT (target        : TargetTex3DEnm;
                           level         : GLint;
                           internalFormat: TexPixelFormatEnm;
                           width         : GLsizei;
                           height        : GLsizei;
                           depth         : GLsizei;
                           border        : GLint;
                           format        : TexPixelFormatEnm;
                           c_type        : PixelDataTypeEnm;
                           pixels        : GLpointer);

procedure glTexSubImage3DEXT (target : TargetTex3DOnlyEnm;
                              level  : GLint;
                              xoffset: GLint;
                              yoffset: GLint;
                              zoffset: GLint;
                              width  : GLsizei;
                              height : GLsizei;
                              depth  : GLsizei;
                              format : TexPixelFormatEnm;
                              c_type : PixelDataTypeEnm;
                              pixels : GLpointer);

procedure glCopyTexSubImage3DEXT (target : TargetTex3DOnlyEnm;
                                  level  : GLint;
                                  xoffset: GLint;
                                  yoffset: GLint;
                                  zoffset: GLint;
                                  x      : GLint;
                                  y      : GLint;
                                  width  : GLsizei;
                                  height : GLsizei);


-- Evaluators
type Map1TargetEnm is
(
   GL_MAP1_COLOR_4,
   GL_MAP1_INDEX,
   GL_MAP1_NORMAL,
   GL_MAP1_TEXTURE_COORD_1,
   GL_MAP1_TEXTURE_COORD_2,
   GL_MAP1_TEXTURE_COORD_3,
   GL_MAP1_TEXTURE_COORD_4,
   GL_MAP1_VERTEX_3,
   GL_MAP1_VERTEX_4
);
for Map1TargetEnm use
(
   GL_MAP1_COLOR_4                            => 16#0D90#,
   GL_MAP1_INDEX                              => 16#0D91#,
   GL_MAP1_NORMAL                             => 16#0D92#,
   GL_MAP1_TEXTURE_COORD_1                    => 16#0D93#,
   GL_MAP1_TEXTURE_COORD_2                    => 16#0D94#,
   GL_MAP1_TEXTURE_COORD_3                    => 16#0D95#,
   GL_MAP1_TEXTURE_COORD_4                    => 16#0D96#,
   GL_MAP1_VERTEX_3                           => 16#0D97#,
   GL_MAP1_VERTEX_4                           => 16#0D98#
);
for Map1TargetEnm'Size use GLenum'size;

type Map2TargetEnm is
(
   GL_MAP2_COLOR_4,
   GL_MAP2_INDEX,
   GL_MAP2_NORMAL,
   GL_MAP2_TEXTURE_COORD_1,
   GL_MAP2_TEXTURE_COORD_2,
   GL_MAP2_TEXTURE_COORD_3,
   GL_MAP2_TEXTURE_COORD_4,
   GL_MAP2_VERTEX_3,
   GL_MAP2_VERTEX_4
);
for Map2TargetEnm use
(
   GL_MAP2_COLOR_4                            => 16#0DB0#,
   GL_MAP2_INDEX                              => 16#0DB1#,
   GL_MAP2_NORMAL                             => 16#0DB2#,
   GL_MAP2_TEXTURE_COORD_1                    => 16#0DB3#,
   GL_MAP2_TEXTURE_COORD_2                    => 16#0DB4#,
   GL_MAP2_TEXTURE_COORD_3                    => 16#0DB5#,
   GL_MAP2_TEXTURE_COORD_4                    => 16#0DB6#,
   GL_MAP2_VERTEX_3                           => 16#0DB7#,
   GL_MAP2_VERTEX_4                           => 16#0DB8#
);
for Map2TargetEnm'Size use GLenum'size;

type MapTargetEnm is
(
   GL_MAP1_COLOR_4,
   GL_MAP1_INDEX,
   GL_MAP1_NORMAL,
   GL_MAP1_TEXTURE_COORD_1,
   GL_MAP1_TEXTURE_COORD_2,
   GL_MAP1_TEXTURE_COORD_3,
   GL_MAP1_TEXTURE_COORD_4,
   GL_MAP1_VERTEX_3,
   GL_MAP1_VERTEX_4,
   GL_MAP2_COLOR_4,
   GL_MAP2_INDEX,
   GL_MAP2_NORMAL,
   GL_MAP2_TEXTURE_COORD_1,
   GL_MAP2_TEXTURE_COORD_2,
   GL_MAP2_TEXTURE_COORD_3,
   GL_MAP2_TEXTURE_COORD_4,
   GL_MAP2_VERTEX_3,
   GL_MAP2_VERTEX_4
);
for MapTargetEnm use
(
   GL_MAP1_COLOR_4                            => 16#0D90#,
   GL_MAP1_INDEX                              => 16#0D91#,
   GL_MAP1_NORMAL                             => 16#0D92#,
   GL_MAP1_TEXTURE_COORD_1                    => 16#0D93#,
   GL_MAP1_TEXTURE_COORD_2                    => 16#0D94#,
   GL_MAP1_TEXTURE_COORD_3                    => 16#0D95#,
   GL_MAP1_TEXTURE_COORD_4                    => 16#0D96#,
   GL_MAP1_VERTEX_3                           => 16#0D97#,
   GL_MAP1_VERTEX_4                           => 16#0D98#,
   GL_MAP2_COLOR_4                            => 16#0DB0#,
   GL_MAP2_INDEX                              => 16#0DB1#,
   GL_MAP2_NORMAL                             => 16#0DB2#,
   GL_MAP2_TEXTURE_COORD_1                    => 16#0DB3#,
   GL_MAP2_TEXTURE_COORD_2                    => 16#0DB4#,
   GL_MAP2_TEXTURE_COORD_3                    => 16#0DB5#,
   GL_MAP2_TEXTURE_COORD_4                    => 16#0DB6#,
   GL_MAP2_VERTEX_3                           => 16#0DB7#,
   GL_MAP2_VERTEX_4                           => 16#0DB8#
);
for MapTargetEnm'Size use GLenum'size;

type MapQueryEnm is
(
   GL_COEFF,
   GL_ORDER,
   GL_DOMAIN
);
for MapQueryEnm use
(
   GL_COEFF                                   => 16#0A00#,
   GL_ORDER                                   => 16#0A01#,
   GL_DOMAIN                                  => 16#0A02#
);
for MapQueryEnm'Size use GLenum'size;

type Mesh1ModeEnm is
(
   GL_POINT,
   GL_LINE
);
for Mesh1ModeEnm use
(
   GL_POINT                                   => 16#1B00#,
   GL_LINE                                    => 16#1B01#
);
for Mesh1ModeEnm'Size use GLenum'size;

type Mesh2ModeEnm is
(
   GL_POINT,
   GL_LINE,
   GL_FILL
);
for Mesh2ModeEnm use
(
   GL_POINT                                   => 16#1B00#,
   GL_LINE                                    => 16#1B01#,
   GL_FILL                                    => 16#1B02#
);
for Mesh2ModeEnm'Size use GLenum'size;

procedure glMap1d (target: Map1TargetEnm;
                   u1    : GLdouble;
                   u2    : GLdouble;
                   stride: GLint;
                   order : GLint;
                   points: GLdoublePtr);

procedure glMap1f (target: Map1TargetEnm;
                   u1    : GLfloat;
                   u2    : GLfloat;
                   stride: GLint;
                   order : GLint;
                   points: GLfloatPtr);

procedure glMap2d (target : Map2TargetEnm;
                   u1     : GLdouble;
                   u2     : GLdouble;
                   ustride: GLint;
                   uorder : GLint;
                   v1     : GLdouble;
                   v2     : GLdouble;
                   vstride: GLint;
                   vorder : GLint;
                   points : GLdoublePtr);

procedure glMap2f (target : Map2TargetEnm;
                   u1     : GLfloat;
                   u2     : GLfloat;
                   ustride: GLint;
                   uorder : GLint;
                   v1     : GLfloat;
                   v2     : GLfloat;
                   vstride: GLint;
                   vorder : GLint;
                   points : GLfloatPtr);

procedure glGetMapdv (target: MapTargetEnm;
                      query : MapQueryEnm;
                      v     : GLdoublePtr);

procedure glGetMapfv (target: MapTargetEnm;
                      query : MapQueryEnm;
                      v     : GLfloatPtr);

procedure glGetMapiv (target: MapTargetEnm;
                      query : MapQueryEnm;
                      v     : GLintPtr);

procedure glEvalPoint1 (i: GLint);

procedure glEvalPoint2 (i: GLint;
                        j: GLint);

procedure glEvalMesh1 (mode: Mesh1ModeEnm;
                       i1  : GLint;
                       i2  : GLint);

procedure glEvalMesh2 (mode: Mesh2ModeEnm;
                       i1  : GLint;
                       i2  : GLint;
                       j1  : GLint;
                       j2  : GLint);

procedure glEvalCoord1d (u: GLdouble);

procedure glEvalCoord1f (u: GLfloat);

procedure glEvalCoord1dv (u: GLdoublePtr);

procedure glEvalCoord1fv (u: GLfloatPtr);

procedure glEvalCoord2d (u: GLdouble;
                         v: GLdouble);

procedure glEvalCoord2f (u: GLfloat;
                         v: GLfloat);

procedure glEvalCoord2dv (u: GLdoublePtr);

procedure glEvalCoord2fv (u: GLfloatPtr);

procedure glMapGrid1d (un: GLint;
                       u1: GLdouble;
                       u2: GLdouble);

procedure glMapGrid1f (un: GLint;
                       u1: GLfloat;
                       u2: GLfloat);

procedure glMapGrid2d (un: GLint;
                       u1: GLdouble;
                       u2: GLdouble;
                       vn: GLint;
                       v1: GLdouble;
                       v2: GLdouble);

procedure glMapGrid2f (un: GLint;
                       u1: GLfloat;
                       u2: GLfloat;
                       vn: GLint;
                       v1: GLfloat;
                       v2: GLfloat);


-- Fog
type FogParameterEnm is
(
   GL_FOG_INDEX,
   GL_FOG_DENSITY,
   GL_FOG_START,
   GL_FOG_END,
   GL_FOG_MODE
);
for FogParameterEnm use
(
   GL_FOG_INDEX                               => 16#0B61#,
   GL_FOG_DENSITY                             => 16#0B62#,
   GL_FOG_START                               => 16#0B63#,
   GL_FOG_END                                 => 16#0B64#,
   GL_FOG_MODE                                => 16#0B65#
);
for FogParameterEnm'Size use GLenum'size;

type FogParameterVEnm is
(
   GL_FOG_INDEX,
   GL_FOG_DENSITY,
   GL_FOG_START,
   GL_FOG_END,
   GL_FOG_MODE,
   GL_FOG_COLOR
);
for FogParameterVEnm use
(
   GL_FOG_INDEX                               => 16#0B61#,
   GL_FOG_DENSITY                             => 16#0B62#,
   GL_FOG_START                               => 16#0B63#,
   GL_FOG_END                                 => 16#0B64#,
   GL_FOG_MODE                                => 16#0B65#,
   GL_FOG_COLOR                               => 16#0B66#
);
for FogParameterVEnm'Size use GLenum'size;

-- Fog attenuation modes
GL_LINEAR                      : constant := 16#2601#;
GL_EXP                         : constant := 16#0800#;
GL_EXP2                        : constant := 16#0801#;

procedure glFogf (pname: FogParameterEnm;
                  param: GLfloat);

procedure glFogi (pname: FogParameterEnm;
                  param: GLint);

procedure glFogfv (pname : FogParameterVEnm;
                   params: GLfloatPtr);

procedure glFogiv (pname : FogParameterVEnm;
                   params: GLintPtr);


-- Feedback
type FeedbackModeEnm is
(
   GL_2D,
   GL_3D,
   GL_3D_COLOR,
   GL_3D_COLOR_TEXTURE,
   GL_4D_COLOR_TEXTURE
);
for FeedbackModeEnm use
(
   GL_2D                                      => 16#0600#,
   GL_3D                                      => 16#0601#,
   GL_3D_COLOR                                => 16#0602#,
   GL_3D_COLOR_TEXTURE                        => 16#0603#,
   GL_4D_COLOR_TEXTURE                        => 16#0604#
);
for FeedbackModeEnm'Size use GLenum'size;

-- Feedback tokens
GL_POINT_TOKEN                 : constant := 16#0701#;
GL_LINE_TOKEN                  : constant := 16#0702#;
GL_LINE_RESET_TOKEN            : constant := 16#0707#;
GL_POLYGON_TOKEN               : constant := 16#0703#;
GL_BITMAP_TOKEN                : constant := 16#0704#;
GL_DRAW_PIXEL_TOKEN            : constant := 16#0705#;
GL_COPY_PIXEL_TOKEN            : constant := 16#0706#;
GL_PASS_THROUGH_TOKEN          : constant := 16#0700#;
GL_FEEDBACK_BUFFER_SIZE        : constant := 16#0DF1#;
GL_FEEDBACK_BUFFER_TYPE        : constant := 16#0DF2#;

procedure glFeedbackBuffer (size  : GLsizei;
                            c_type: FeedbackModeEnm;
                            buffer: GLfloatPtr);

procedure glPassThrough (token: GLfloat);


-- Color tables (extension)
type ColorTableTargetEnm is
(
   GL_TEXTURE_1D,
   GL_TEXTURE_2D,
   GL_PROXY_TEXTURE_1D,
   GL_PROXY_TEXTURE_2D,
   GL_TEXTURE_3D_EXT,
   GL_PROXY_TEXTURE_3D_EXT,
   GL_SHARED_TEXTURE_PALETTE_EXT

);
for ColorTableTargetEnm use
(
   GL_TEXTURE_1D                              => 16#0DE0#,
   GL_TEXTURE_2D                              => 16#0DE1#,
   GL_PROXY_TEXTURE_1D                        => 16#8063#,
   GL_PROXY_TEXTURE_2D                        => 16#8064#,
   GL_TEXTURE_3D_EXT                          => 16#806F#,
   GL_PROXY_TEXTURE_3D_EXT                    => 16#8070#,
   GL_SHARED_TEXTURE_PALETTE_EXT              => 16#81FB#
);
for ColorTableTargetEnm'Size use GLenum'size;

type GetColorTableTargetEnm is
(
   GL_TEXTURE_1D,
   GL_TEXTURE_2D,
   GL_TEXTURE_3D_EXT,
   GL_SHARED_TEXTURE_PALETTE_EXT

);
for GetColorTableTargetEnm use
(
   GL_TEXTURE_1D                              => 16#0DE0#,
   GL_TEXTURE_2D                              => 16#0DE1#,
   GL_TEXTURE_3D_EXT                          => 16#806F#,
   GL_SHARED_TEXTURE_PALETTE_EXT              => 16#81FB#
);
for GetColorTableTargetEnm'Size use GLenum'size;

type ColorTableParameterEnm is
(
   GL_COLOR_TABLE_FORMAT_EXT,
   GL_COLOR_TABLE_WIDTH_EXT,
   GL_COLOR_TABLE_RED_SIZE_EXT,
   GL_COLOR_TABLE_GREEN_SIZE_EXT,
   GL_COLOR_TABLE_BLUE_SIZE_EXT,
   GL_COLOR_TABLE_ALPHA_SIZE_EXT,
   GL_COLOR_TABLE_LUMINANCE_SIZE_EXT,
   GL_COLOR_TABLE_INTENSITY_SIZE_EXT
);
for ColorTableParameterEnm use
(
   GL_COLOR_TABLE_FORMAT_EXT                  => 16#80D8#,
   GL_COLOR_TABLE_WIDTH_EXT                   => 16#80D9#,
   GL_COLOR_TABLE_RED_SIZE_EXT                => 16#80DA#,
   GL_COLOR_TABLE_GREEN_SIZE_EXT              => 16#80DB#,
   GL_COLOR_TABLE_BLUE_SIZE_EXT               => 16#80DC#,
   GL_COLOR_TABLE_ALPHA_SIZE_EXT              => 16#80DD#,
   GL_COLOR_TABLE_LUMINANCE_SIZE_EXT          => 16#80DE#,
   GL_COLOR_TABLE_INTENSITY_SIZE_EXT          => 16#80DF#
);
for ColorTableParameterEnm'Size use GLenum'size;

procedure glColorTableEXT (target        : ColorTableTargetEnm;
                           internalformat: TexFormatEnm;
                           width         : GLsizei;
                           format        : TexPixelFormatEnm;
                           c_type        : PixelDataTypeEnm;
                           table         : GLpointer);

procedure glColorSubTableEXT (target: ColorTableTargetEnm;
                              start : GLsizei;
                              count : GLsizei;
                              format: TexPixelFormatEnm;
                              c_type: PixelDataTypeEnm;
                              data  : GLpointer);

procedure glGetColorTableEXT (target: GetColorTableTargetEnm;
                              format: TexPixelFormatEnm;
                              c_type: PixelDataTypeEnm;
                              table : GLpointer);

procedure glGetColorTableParameterfvEXT (target: GetColorTableTargetEnm;
                                         pname : ColorTableParameterEnm;
                                         params: GLfloatPtr);

procedure glGetColorTableParameterivEXT (target: GetColorTableTargetEnm;
                                         pname : ColorTableParameterEnm;
                                         params: GLintPtr);


-- Point parameters (extension)
type PointParameterEnm is
(
   GL_POINT_SIZE_MIN_EXT,
   GL_POINT_SIZE_MAX_EXT,
   GL_POINT_FADE_THRESHOLD_SIZE_EXT
);
for PointParameterEnm use
(
   GL_POINT_SIZE_MIN_EXT                      => 16#8126#,
   GL_POINT_SIZE_MAX_EXT                      => 16#8127#,
   GL_POINT_FADE_THRESHOLD_SIZE_EXT           => 16#8128#
);
for PointParameterEnm'Size use GLenum'size;

type PointParameterVEnm is
(
   GL_POINT_SIZE_MIN_EXT,
   GL_POINT_SIZE_MAX_EXT,
   GL_POINT_FADE_THRESHOLD_SIZE_EXT,
   GL_DISTANCE_ATTENUATION_EXT
);
for PointParameterVEnm use
(
   GL_POINT_SIZE_MIN_EXT                      => 16#8126#,
   GL_POINT_SIZE_MAX_EXT                      => 16#8127#,
   GL_POINT_FADE_THRESHOLD_SIZE_EXT           => 16#8128#,
   GL_DISTANCE_ATTENUATION_EXT                => 16#8129#
);
for PointParameterVEnm'Size use GLenum'size;

procedure glPointParameterfEXT (pname: PointParameterEnm;
                                param: GLfloat);

procedure glPointParameterfvEXT (pname : PointParameterVEnm;
                                 params: GLfloatPtr);


-- Clears
procedure glClearIndex (c: GLfloat);

procedure glClearColor (red  : GLclampf;
                        green: GLclampf;
                        blue : GLclampf;
                        alpha: GLclampf);

procedure glClear (mask: GLbitfield);

procedure glClearDepth (depth: GLclampd);

procedure glClearAccum (red  : GLfloat;
                        green: GLfloat;
                        blue : GLfloat;
                        alpha: GLfloat);


-- Masks
procedure glIndexMask (mask: GLuint);

procedure glColorMask (red  : GLboolean;
                       green: GLboolean;
                       blue : GLboolean;
                       alpha: GLboolean);

-- Drawing parameters
procedure glPointSize (size: GLfloat);

procedure glLineWidth (width: GLfloat);

procedure glLineStipple (factor : GLint;
                         pattern: GLushort);

procedure glPolygonOffset (factor: GLfloat;
                           units : GLfloat);

procedure glPolygonStipple (mask: GLubytePtr);

procedure glGetPolygonStipple (mask: GLubytePtr);

procedure glEdgeFlag (flag: GLboolean);

procedure glEdgeFlagv (flag: GLbooleanPtr);

procedure glScissor (x     : GLint;
                     y     : GLint;
                     width : GLsizei;
                     height: GLsizei);


-- Atribute stacks
procedure glPushAttrib (mask: GLbitfield);

procedure glPopAttrib;

procedure glPushClientAttrib (mask: GLbitfield);

procedure glPopClientAttrib;


-- Pipeline control
procedure glFinish;

procedure glFlush;

procedure glDepthMask (flag: GLboolean);

procedure glDepthRange (near_val: GLclampd;
                        far_val : GLclampd);


-- Projections
procedure glOrtho (left    : GLdouble;
                   right   : GLdouble;
                   bottom  : GLdouble;
                   top     : GLdouble;
                   near_val: GLdouble;
                   far_val : GLdouble);

procedure glFrustum (left    : GLdouble;
                     right   : GLdouble;
                     bottom  : GLdouble;
                     top     : GLdouble;
                     near_val: GLdouble;
                     far_val : GLdouble);

procedure glViewport (x     : GLint;
                      y     : GLint;
                      width : GLsizei;
                      height: GLsizei);


-- Matrix stacks
procedure glPushMatrix;

procedure glPopMatrix;

procedure glLoadIdentity;

procedure glLoadMatrixd (m: GLdoublePtr);

procedure glLoadMatrixf (m: GLfloatPtr);

procedure glMultMatrixd (m: GLdoublePtr);

procedure glMultMatrixf (m: GLfloatPtr);


-- Transformations
procedure glRotated (angle: GLdouble;
                     x    : GLdouble;
                     y    : GLdouble;
                     z    : GLdouble);

procedure glRotatef (angle: GLfloat;
                     x    : GLfloat;
                     y    : GLfloat;
                     z    : GLfloat);

procedure glScaled (x: GLdouble;
                    y: GLdouble;
                    z: GLdouble);

procedure glScalef (x: GLfloat;
                    y: GLfloat;
                    z: GLfloat);

procedure glTranslated (x: GLdouble;
                        y: GLdouble;
                        z: GLdouble);

procedure glTranslatef (x: GLfloat;
                        y: GLfloat;
                        z: GLfloat);


-- Specify vertices
procedure glVertex2d (x: GLdouble;
                      y: GLdouble);

procedure glVertex2f (x: GLfloat;
                      y: GLfloat);

procedure glVertex2i (x: GLint;
                      y: GLint);

procedure glVertex2s (x: GLshort;
                      y: GLshort);

procedure glVertex3d (x: GLdouble;
                      y: GLdouble;
                      z: GLdouble);

procedure glVertex3f (x: GLfloat;
                      y: GLfloat;
                      z: GLfloat);

procedure glVertex3i (x: GLint;
                      y: GLint;
                      z: GLint);

procedure glVertex3s (x: GLshort;
                      y: GLshort;
                      z: GLshort);

procedure glVertex4d (x: GLdouble;
                      y: GLdouble;
                      z: GLdouble;
                      w: GLdouble);

procedure glVertex4f (x: GLfloat;
                      y: GLfloat;
                      z: GLfloat;
                      w: GLfloat);

procedure glVertex4i (x: GLint;
                      y: GLint;
                      z: GLint;
                      w: GLint);

procedure glVertex4s (x: GLshort;
                      y: GLshort;
                      z: GLshort;
                      w: GLshort);

procedure glVertex2dv (v: GLdoublePtr);

procedure glVertex2fv (v: GLfloatPtr);

procedure glVertex2iv (v: GLintPtr);

procedure glVertex2sv (v: GLshortPtr);

procedure glVertex3dv (v: GLdoublePtr);

procedure glVertex3fv (v: GLfloatPtr);

procedure glVertex3iv (v: GLintPtr);

procedure glVertex3sv (v: GLshortPtr);

procedure glVertex4dv (v: GLdoublePtr);

procedure glVertex4fv (v: GLfloatPtr);

procedure glVertex4iv (v: GLintPtr);

procedure glVertex4sv (v: GLshortPtr);


-- Specify normai vectors
procedure glNormal3b (nx: GLbyte;
                      ny: GLbyte;
                      nz: GLbyte);

procedure glNormal3d (nx: GLdouble;
                      ny: GLdouble;
                      nz: GLdouble);

procedure glNormal3f (nx: GLfloat;
                      ny: GLfloat;
                      nz: GLfloat);

procedure glNormal3i (nx: GLint;
                      ny: GLint;
                      nz: GLint);

procedure glNormal3s (nx: GLshort;
                      ny: GLshort;
                      nz: GLshort);

procedure glNormal3bv (v: GLbytePtr);

procedure glNormal3dv (v: GLdoublePtr);

procedure glNormal3fv (v: GLfloatPtr);

procedure glNormal3iv (v: GLintPtr);

procedure glNormal3sv (v: GLshortPtr);


-- Indexed color
procedure glIndexd (c: GLdouble);

procedure glIndexf (c: GLfloat);

procedure glIndexi (c: GLint);

procedure glIndexs (c: GLshort);

procedure glIndexub (c: GLubyte);

procedure glIndexdv (c: GLdoublePtr);

procedure glIndexfv (c: GLfloatPtr);

procedure glIndexiv (c: GLintPtr);

procedure glIndexsv (c: GLshortPtr);

procedure glIndexubv (c: GLubytePtr);


-- Component color
procedure glColor3b (red  : GLbyte;
                     green: GLbyte;
                     blue : GLbyte);

procedure glColor3d (red  : GLdouble;
                     green: GLdouble;
                     blue : GLdouble);

procedure glColor3f (red  : GLfloat;
                     green: GLfloat;
                     blue : GLfloat);

procedure glColor3i (red  : GLint;
                     green: GLint;
                     blue : GLint);

procedure glColor3s (red  : GLshort;
                     green: GLshort;
                     blue : GLshort);

procedure glColor3ub (red  : GLubyte;
                      green: GLubyte;
                      blue : GLubyte);

procedure glColor3ui (red  : GLuint;
                      green: GLuint;
                      blue : GLuint);

procedure glColor3us (red  : GLushort;
                      green: GLushort;
                      blue : GLushort);

procedure glColor4b (red  : GLbyte;
                     green: GLbyte;
                     blue : GLbyte;
                     alpha: GLbyte);

procedure glColor4d (red  : GLdouble;
                     green: GLdouble;
                     blue : GLdouble;
                     alpha: GLdouble);

procedure glColor4f (red  : GLfloat;
                     green: GLfloat;
                     blue : GLfloat;
                     alpha: GLfloat);

procedure glColor4i (red  : GLint;
                     green: GLint;
                     blue : GLint;
                     alpha: GLint);

procedure glColor4s (red  : GLshort;
                     green: GLshort;
                     blue : GLshort;
                     alpha: GLshort);

procedure glColor4ub (red  : GLubyte;
                      green: GLubyte;
                      blue : GLubyte;
                      alpha: GLubyte);

procedure glColor4ui (red  : GLuint;
                      green: GLuint;
                      blue : GLuint;
                      alpha: GLuint);

procedure glColor4us (red  : GLushort;
                      green: GLushort;
                      blue : GLushort;
                      alpha: GLushort);

procedure glColor3bv (v: GLbytePtr);

procedure glColor3dv (v: GLdoublePtr);

procedure glColor3fv (v: GLfloatPtr);

procedure glColor3iv (v: GLintPtr);

procedure glColor3sv (v: GLshortPtr);

procedure glColor3ubv (v: GLubytePtr);

procedure glColor3uiv (v: GLuintPtr);

procedure glColor3usv (v: GLushortPtr);

procedure glColor4bv (v: GLbytePtr);

procedure glColor4dv (v: GLdoublePtr);

procedure glColor4fv (v: GLfloatPtr);

procedure glColor4iv (v: GLintPtr);

procedure glColor4sv (v: GLshortPtr);

procedure glColor4ubv (v: GLubytePtr);

procedure glColor4uiv (v: GLuintPtr);

procedure glColor4usv (v: GLushortPtr);


-- Texture coordinates
procedure glTexCoord1d (s: GLdouble);

procedure glTexCoord1f (s: GLfloat);

procedure glTexCoord1i (s: GLint);

procedure glTexCoord1s (s: GLshort);

procedure glTexCoord2d (s: GLdouble;
                        t: GLdouble);

procedure glTexCoord2f (s: GLfloat;
                        t: GLfloat);

procedure glTexCoord2i (s: GLint;
                        t: GLint);

procedure glTexCoord2s (s: GLshort;
                        t: GLshort);

procedure glTexCoord3d (s: GLdouble;
                        t: GLdouble;
                        r: GLdouble);

procedure glTexCoord3f (s: GLfloat;
                        t: GLfloat;
                        r: GLfloat);

procedure glTexCoord3i (s: GLint;
                        t: GLint;
                        r: GLint);

procedure glTexCoord3s (s: GLshort;
                        t: GLshort;
                        r: GLshort);

procedure glTexCoord4d (s: GLdouble;
                        t: GLdouble;
                        r: GLdouble;
                        q: GLdouble);

procedure glTexCoord4f (s: GLfloat;
                        t: GLfloat;
                        r: GLfloat;
                        q: GLfloat);

procedure glTexCoord4i (s: GLint;
                        t: GLint;
                        r: GLint;
                        q: GLint);

procedure glTexCoord4s (s: GLshort;
                        t: GLshort;
                        r: GLshort;
                        q: GLshort);

procedure glTexCoord1dv (v: GLdoublePtr);

procedure glTexCoord1fv (v: GLfloatPtr);

procedure glTexCoord1iv (v: GLintPtr);

procedure glTexCoord1sv (v: GLshortPtr);

procedure glTexCoord2dv (v: GLdoublePtr);

procedure glTexCoord2fv (v: GLfloatPtr);

procedure glTexCoord2iv (v: GLintPtr);

procedure glTexCoord2sv (v: GLshortPtr);

procedure glTexCoord3dv (v: GLdoublePtr);

procedure glTexCoord3fv (v: GLfloatPtr);

procedure glTexCoord3iv (v: GLintPtr);

procedure glTexCoord3sv (v: GLshortPtr);

procedure glTexCoord4dv (v: GLdoublePtr);

procedure glTexCoord4fv (v: GLfloatPtr);

procedure glTexCoord4iv (v: GLintPtr);

procedure glTexCoord4sv (v: GLshortPtr);


-- Pixel op raster position
procedure glRasterPos2d (x: GLdouble;
                         y: GLdouble);

procedure glRasterPos2f (x: GLfloat;
                         y: GLfloat);

procedure glRasterPos2i (x: GLint;
                         y: GLint);

procedure glRasterPos2s (x: GLshort;
                         y: GLshort);

procedure glRasterPos3d (x: GLdouble;
                         y: GLdouble;
                         z: GLdouble);

procedure glRasterPos3f (x: GLfloat;
                         y: GLfloat;
                         z: GLfloat);

procedure glRasterPos3i (x: GLint;
                         y: GLint;
                         z: GLint);

procedure glRasterPos3s (x: GLshort;
                         y: GLshort;
                         z: GLshort);

procedure glRasterPos4d (x: GLdouble;
                         y: GLdouble;
                         z: GLdouble;
                         w: GLdouble);

procedure glRasterPos4f (x: GLfloat;
                         y: GLfloat;
                         z: GLfloat;
                         w: GLfloat);

procedure glRasterPos4i (x: GLint;
                         y: GLint;
                         z: GLint;
                         w: GLint);

procedure glRasterPos4s (x: GLshort;
                         y: GLshort;
                         z: GLshort;
                         w: GLshort);

procedure glRasterPos2dv (v: GLdoublePtr);

procedure glRasterPos2fv (v: GLfloatPtr);

procedure glRasterPos2iv (v: GLintPtr);

procedure glRasterPos2sv (v: GLshortPtr);

procedure glRasterPos3dv (v: GLdoublePtr);

procedure glRasterPos3fv (v: GLfloatPtr);

procedure glRasterPos3iv (v: GLintPtr);

procedure glRasterPos3sv (v: GLshortPtr);

procedure glRasterPos4dv (v: GLdoublePtr);

procedure glRasterPos4fv (v: GLfloatPtr);

procedure glRasterPos4iv (v: GLintPtr);

procedure glRasterPos4sv (v: GLshortPtr);


-- Rectangles
procedure glRectd (x1: GLdouble;
                   y1: GLdouble;
                   x2: GLdouble;
                   y2: GLdouble);

procedure glRectf (x1: GLfloat;
                   y1: GLfloat;
                   x2: GLfloat;
                   y2: GLfloat);

procedure glRecti (x1: GLint;
                   y1: GLint;
                   x2: GLint;
                   y2: GLint);

procedure glRects (x1: GLshort;
                   y1: GLshort;
                   x2: GLshort;
                   y2: GLshort);

procedure glRectdv (v1: GLdoublePtr;
                    v2: GLdoublePtr);

procedure glRectfv (v1: GLfloatPtr;
                    v2: GLfloatPtr);

procedure glRectiv (v1: GLintPtr;
                    v2: GLintPtr);

procedure glRectsv (v1: GLshortPtr;
                    v2: GLshortPtr);


-- Bitmap
procedure glBitmap (width : GLsizei;
                    height: GLsizei;
                    xorig : GLfloat;
                    yorig : GLfloat;
                    xmove : GLfloat;
                    ymove : GLfloat;
                    bitmap: GLubytePtr);


-- Stenciling
procedure glStencilMask (mask: GLuint);

procedure glClearStencil (s: GLint);


-- Selections and name stack
procedure glSelectBuffer (size  : GLsizei;
                          buffer: GLuintPtr);
procedure glInitNames;

procedure glLoadName (name: GLuint);

procedure glPushName (name: GLuint);

procedure glPopName;


-- Mesa-specific routines
procedure glWindowPos2iMESA (x: GLint;
                             y: GLint);

procedure glWindowPos2sMESA (x: GLshort;
                             y: GLshort);

procedure glWindowPos2fMESA (x: GLfloat;
                             y: GLfloat);

procedure glWindowPos2dMESA (x: GLdouble;
                             y: GLdouble);

procedure glWindowPos2ivMESA (p: GLintPtr);

procedure glWindowPos2svMESA (p: GLshortPtr);

procedure glWindowPos2fvMESA (p: GLfloatPtr);

procedure glWindowPos2dvMESA (p: GLdoublePtr);

procedure glWindowPos3iMESA (x: GLint;
                             y: GLint;
                             z: GLint);

procedure glWindowPos3sMESA (x: GLshort;
                             y: GLshort;
                             z: GLshort);

procedure glWindowPos3fMESA (x: GLfloat;
                             y: GLfloat;
                             z: GLfloat);

procedure glWindowPos3dMESA (x: GLdouble;
                             y: GLdouble;
                             z: GLdouble);

procedure glWindowPos3ivMESA (p: GLintPtr);

procedure glWindowPos3svMESA (p: GLshortPtr);

procedure glWindowPos3fvMESA (p: GLfloatPtr);

procedure glWindowPos3dvMESA (p: GLdoublePtr);

procedure glWindowPos4iMESA (x: GLint;
                             y: GLint;
                             z: GLint;
                             w: GLint);

procedure glWindowPos4sMESA (x: GLshort;
                             y: GLshort;
                             z: GLshort;
                             w: GLshort);

procedure glWindowPos4fMESA (x: GLfloat;
                             y: GLfloat;
                             z: GLfloat;
                             w: GLfloat);

procedure glWindowPos4dMESA (x: GLdouble;
                             y: GLdouble;
                             z: GLdouble;
                             w: GLdouble);

procedure glWindowPos4ivMESA (p: GLintPtr);

procedure glWindowPos4svMESA (p: GLshortPtr);

procedure glWindowPos4fvMESA (p: GLfloatPtr);

procedure glWindowPos4dvMESA (p: GLdoublePtr);

procedure glResizeBuffersMESA;

------------------------------------------------------------------------------

private

pragma Import (C, glClearIndex, "glClearIndex");
pragma Import (C, glClearColor, "glClearColor");
pragma Import (C, glClear, "glClear");
pragma Import (C, glIndexMask, "glIndexMask");
pragma Import (C, glColorMask, "glColorMask");
pragma Import (C, glAlphaFunc, "glAlphaFunc");
pragma Import (C, glBlendFunc, "glBlendFunc");
pragma Import (C, glLogicOp, "glLogicOp");
pragma Import (C, glCullFace, "glCullFace");
pragma Import (C, glFrontFace, "glFrontFace");
pragma Import (C, glPointSize, "glPointSize");
pragma Import (C, glLineWidth, "glLineWidth");
pragma Import (C, glLineStipple, "glLineStipple");
pragma Import (C, glPolygonMode, "glPolygonMode");
pragma Import (C, glPolygonOffset, "glPolygonOffset");
pragma Import (C, glPolygonStipple, "glPolygonStipple");
pragma Import (C, glGetPolygonStipple, "glGetPolygonStipple");
pragma Import (C, glEdgeFlag, "glEdgeFlag");
pragma Import (C, glEdgeFlagv, "glEdgeFlagv");
pragma Import (C, glScissor, "glScissor");
pragma Import (C, glClipPlane, "glClipPlane");
pragma Import (C, glGetClipPlane, "glGetClipPlane");
pragma Import (C, glDrawBuffer, "glDrawBuffer");
pragma Import (C, glReadBuffer, "glReadBuffer");
pragma Import (C, glEnable, "glEnable");
pragma Import (C, glDisable, "glDisable");
pragma Import (C, glIsEnabled, "glIsEnabled");
pragma Import (C, glEnableClientState, "glEnableClientState");
pragma Import (C, glDisableClientState, "glDisableClientState");
pragma Import (C, glGetBooleanv, "glGetBooleanv");
pragma Import (C, glGetDoublev, "glGetDoublev");
pragma Import (C, glGetFloatv, "glGetFloatv");
pragma Import (C, glGetIntegerv, "glGetIntegerv");
pragma Import (C, glPushAttrib, "glPushAttrib");
pragma Import (C, glPopAttrib, "glPopAttrib");
pragma Import (C, glPushClientAttrib, "glPushClientAttrib");
pragma Import (C, glPopClientAttrib, "glPopClientAttrib");
pragma Import (C, glRenderMode, "glRenderMode");
pragma Import (C, glGetError, "glGetError");
pragma Import (C, glGetString, "glGetString");
pragma Import (C, glFinish, "glFinish");
pragma Import (C, glFlush, "glFlush");
pragma Import (C, glHint, "glHint");
pragma Import (C, glClearDepth, "glClearDepth");
pragma Import (C, glDepthFunc, "glDepthFunc");
pragma Import (C, glDepthMask, "glDepthMask");
pragma Import (C, glDepthRange, "glDepthRange");
pragma Import (C, glClearAccum, "glClearAccum");
pragma Import (C, glAccum, "glAccum");
pragma Import (C, glMatrixMode, "glMatrixMode");
pragma Import (C, glOrtho, "glOrtho");
pragma Import (C, glFrustum, "glFrustum");
pragma Import (C, glViewport, "glViewport");
pragma Import (C, glPushMatrix, "glPushMatrix");
pragma Import (C, glPopMatrix, "glPopMatrix");
pragma Import (C, glLoadIdentity, "glLoadIdentity");
pragma Import (C, glLoadMatrixd, "glLoadMatrixd");
pragma Import (C, glLoadMatrixf, "glLoadMatrixf");
pragma Import (C, glMultMatrixd, "glMultMatrixd");
pragma Import (C, glMultMatrixf, "glMultMatrixf");
pragma Import (C, glRotated, "glRotated");
pragma Import (C, glRotatef, "glRotatef");
pragma Import (C, glScaled, "glScaled");
pragma Import (C, glScalef, "glScalef");
pragma Import (C, glTranslated, "glTranslated");
pragma Import (C, glTranslatef, "glTranslatef");
pragma Import (C, glIsList, "glIsList");
pragma Import (C, glDeleteLists, "glDeleteLists");
pragma Import (C, glGenLists, "glGenLists");
pragma Import (C, glNewList, "glNewList");
pragma Import (C, glEndList, "glEndList");
pragma Import (C, glCallList, "glCallList");
pragma Import (C, glCallLists, "glCallLists");
pragma Import (C, glListBase, "glListBase");
pragma Import (C, glBegin, "glBegin");
pragma Import (C, glEnd, "glEnd");
pragma Import (C, glVertex2d, "glVertex2d");
pragma Import (C, glVertex2f, "glVertex2f");
pragma Import (C, glVertex2i, "glVertex2i");
pragma Import (C, glVertex2s, "glVertex2s");
pragma Import (C, glVertex3d, "glVertex3d");
pragma Import (C, glVertex3f, "glVertex3f");
pragma Import (C, glVertex3i, "glVertex3i");
pragma Import (C, glVertex3s, "glVertex3s");
pragma Import (C, glVertex4d, "glVertex4d");
pragma Import (C, glVertex4f, "glVertex4f");
pragma Import (C, glVertex4i, "glVertex4i");
pragma Import (C, glVertex4s, "glVertex4s");
pragma Import (C, glVertex2dv, "glVertex2dv");
pragma Import (C, glVertex2fv, "glVertex2fv");
pragma Import (C, glVertex2iv, "glVertex2iv");
pragma Import (C, glVertex2sv, "glVertex2sv");
pragma Import (C, glVertex3dv, "glVertex3dv");
pragma Import (C, glVertex3fv, "glVertex3fv");
pragma Import (C, glVertex3iv, "glVertex3iv");
pragma Import (C, glVertex3sv, "glVertex3sv");
pragma Import (C, glVertex4dv, "glVertex4dv");
pragma Import (C, glVertex4fv, "glVertex4fv");
pragma Import (C, glVertex4iv, "glVertex4iv");
pragma Import (C, glVertex4sv, "glVertex4sv");
pragma Import (C, glNormal3b, "glNormal3b");
pragma Import (C, glNormal3d, "glNormal3d");
pragma Import (C, glNormal3f, "glNormal3f");
pragma Import (C, glNormal3i, "glNormal3i");
pragma Import (C, glNormal3s, "glNormal3s");
pragma Import (C, glNormal3bv, "glNormal3bv");
pragma Import (C, glNormal3dv, "glNormal3dv");
pragma Import (C, glNormal3fv, "glNormal3fv");
pragma Import (C, glNormal3iv, "glNormal3iv");
pragma Import (C, glNormal3sv, "glNormal3sv");
pragma Import (C, glIndexd, "glIndexd");
pragma Import (C, glIndexf, "glIndexf");
pragma Import (C, glIndexi, "glIndexi");
pragma Import (C, glIndexs, "glIndexs");
pragma Import (C, glIndexub, "glIndexub");
pragma Import (C, glIndexdv, "glIndexdv");
pragma Import (C, glIndexfv, "glIndexfv");
pragma Import (C, glIndexiv, "glIndexiv");
pragma Import (C, glIndexsv, "glIndexsv");
pragma Import (C, glIndexubv, "glIndexubv");
pragma Import (C, glColor3b, "glColor3b");
pragma Import (C, glColor3d, "glColor3d");
pragma Import (C, glColor3f, "glColor3f");
pragma Import (C, glColor3i, "glColor3i");
pragma Import (C, glColor3s, "glColor3s");
pragma Import (C, glColor3ub, "glColor3ub");
pragma Import (C, glColor3ui, "glColor3ui");
pragma Import (C, glColor3us, "glColor3us");
pragma Import (C, glColor4b, "glColor4b");
pragma Import (C, glColor4d, "glColor4d");
pragma Import (C, glColor4f, "glColor4f");
pragma Import (C, glColor4i, "glColor4i");
pragma Import (C, glColor4s, "glColor4s");
pragma Import (C, glColor4ub, "glColor4ub");
pragma Import (C, glColor4ui, "glColor4ui");
pragma Import (C, glColor4us, "glColor4us");
pragma Import (C, glColor3bv, "glColor3bv");
pragma Import (C, glColor3dv, "glColor3dv");
pragma Import (C, glColor3fv, "glColor3fv");
pragma Import (C, glColor3iv, "glColor3iv");
pragma Import (C, glColor3sv, "glColor3sv");
pragma Import (C, glColor3ubv, "glColor3ubv");
pragma Import (C, glColor3uiv, "glColor3uiv");
pragma Import (C, glColor3usv, "glColor3usv");
pragma Import (C, glColor4bv, "glColor4bv");
pragma Import (C, glColor4dv, "glColor4dv");
pragma Import (C, glColor4fv, "glColor4fv");
pragma Import (C, glColor4iv, "glColor4iv");
pragma Import (C, glColor4sv, "glColor4sv");
pragma Import (C, glColor4ubv, "glColor4ubv");
pragma Import (C, glColor4uiv, "glColor4uiv");
pragma Import (C, glColor4usv, "glColor4usv");
pragma Import (C, glTexCoord1d, "glTexCoord1d");
pragma Import (C, glTexCoord1f, "glTexCoord1f");
pragma Import (C, glTexCoord1i, "glTexCoord1i");
pragma Import (C, glTexCoord1s, "glTexCoord1s");
pragma Import (C, glTexCoord2d, "glTexCoord2d");
pragma Import (C, glTexCoord2f, "glTexCoord2f");
pragma Import (C, glTexCoord2i, "glTexCoord2i");
pragma Import (C, glTexCoord2s, "glTexCoord2s");
pragma Import (C, glTexCoord3d, "glTexCoord3d");
pragma Import (C, glTexCoord3f, "glTexCoord3f");
pragma Import (C, glTexCoord3i, "glTexCoord3i");
pragma Import (C, glTexCoord3s, "glTexCoord3s");
pragma Import (C, glTexCoord4d, "glTexCoord4d");
pragma Import (C, glTexCoord4f, "glTexCoord4f");
pragma Import (C, glTexCoord4i, "glTexCoord4i");
pragma Import (C, glTexCoord4s, "glTexCoord4s");
pragma Import (C, glTexCoord1dv, "glTexCoord1dv");
pragma Import (C, glTexCoord1fv, "glTexCoord1fv");
pragma Import (C, glTexCoord1iv, "glTexCoord1iv");
pragma Import (C, glTexCoord1sv, "glTexCoord1sv");
pragma Import (C, glTexCoord2dv, "glTexCoord2dv");
pragma Import (C, glTexCoord2fv, "glTexCoord2fv");
pragma Import (C, glTexCoord2iv, "glTexCoord2iv");
pragma Import (C, glTexCoord2sv, "glTexCoord2sv");
pragma Import (C, glTexCoord3dv, "glTexCoord3dv");
pragma Import (C, glTexCoord3fv, "glTexCoord3fv");
pragma Import (C, glTexCoord3iv, "glTexCoord3iv");
pragma Import (C, glTexCoord3sv, "glTexCoord3sv");
pragma Import (C, glTexCoord4dv, "glTexCoord4dv");
pragma Import (C, glTexCoord4fv, "glTexCoord4fv");
pragma Import (C, glTexCoord4iv, "glTexCoord4iv");
pragma Import (C, glTexCoord4sv, "glTexCoord4sv");
pragma Import (C, glRasterPos2d, "glRasterPos2d");
pragma Import (C, glRasterPos2f, "glRasterPos2f");
pragma Import (C, glRasterPos2i, "glRasterPos2i");
pragma Import (C, glRasterPos2s, "glRasterPos2s");
pragma Import (C, glRasterPos3d, "glRasterPos3d");
pragma Import (C, glRasterPos3f, "glRasterPos3f");
pragma Import (C, glRasterPos3i, "glRasterPos3i");
pragma Import (C, glRasterPos3s, "glRasterPos3s");
pragma Import (C, glRasterPos4d, "glRasterPos4d");
pragma Import (C, glRasterPos4f, "glRasterPos4f");
pragma Import (C, glRasterPos4i, "glRasterPos4i");
pragma Import (C, glRasterPos4s, "glRasterPos4s");
pragma Import (C, glRasterPos2dv, "glRasterPos2dv");
pragma Import (C, glRasterPos2fv, "glRasterPos2fv");
pragma Import (C, glRasterPos2iv, "glRasterPos2iv");
pragma Import (C, glRasterPos2sv, "glRasterPos2sv");
pragma Import (C, glRasterPos3dv, "glRasterPos3dv");
pragma Import (C, glRasterPos3fv, "glRasterPos3fv");
pragma Import (C, glRasterPos3iv, "glRasterPos3iv");
pragma Import (C, glRasterPos3sv, "glRasterPos3sv");
pragma Import (C, glRasterPos4dv, "glRasterPos4dv");
pragma Import (C, glRasterPos4fv, "glRasterPos4fv");
pragma Import (C, glRasterPos4iv, "glRasterPos4iv");
pragma Import (C, glRasterPos4sv, "glRasterPos4sv");
pragma Import (C, glRectd, "glRectd");
pragma Import (C, glRectf, "glRectf");
pragma Import (C, glRecti, "glRecti");
pragma Import (C, glRects, "glRects");
pragma Import (C, glRectdv, "glRectdv");
pragma Import (C, glRectfv, "glRectfv");
pragma Import (C, glRectiv, "glRectiv");
pragma Import (C, glRectsv, "glRectsv");
pragma Import (C, glVertexPointer, "glVertexPointer");
pragma Import (C, glNormalPointer, "glNormalPointer");
pragma Import (C, glColorPointer, "glColorPointer");
pragma Import (C, glIndexPointer, "glIndexPointer");
pragma Import (C, glTexCoordPointer, "glTexCoordPointer");
pragma Import (C, glEdgeFlagPointer, "glEdgeFlagPointer");
pragma Import (C, glGetPointerv, "glGetPointerv");
pragma Import (C, glArrayElement, "glArrayElement");
pragma Import (C, glDrawArrays, "glDrawArrays");
pragma Import (C, glDrawElements, "glDrawElements");
pragma Import (C, glInterleavedArrays, "glInterleavedArrays");
pragma Import (C, glShadeModel, "glShadeModel");
pragma Import (C, glLightf, "glLightf");
pragma Import (C, glLighti, "glLighti");
pragma Import (C, glLightfv, "glLightfv");
pragma Import (C, glLightiv, "glLightiv");
pragma Import (C, glGetLightfv, "glGetLightfv");
pragma Import (C, glGetLightiv, "glGetLightiv");
pragma Import (C, glLightModelf, "glLightModelf");
pragma Import (C, glLightModeli, "glLightModeli");
pragma Import (C, glLightModelfv, "glLightModelfv");
pragma Import (C, glLightModeliv, "glLightModeliv");
pragma Import (C, glMaterialf, "glMaterialf");
pragma Import (C, glMateriali, "glMateriali");
pragma Import (C, glMaterialfv, "glMaterialfv");
pragma Import (C, glMaterialiv, "glMaterialiv");
pragma Import (C, glGetMaterialfv, "glGetMaterialfv");
pragma Import (C, glGetMaterialiv, "glGetMaterialiv");
pragma Import (C, glColorMaterial, "glColorMaterial");
pragma Import (C, glPixelZoom, "glPixelZoom");
pragma Import (C, glPixelStoref, "glPixelStoref");
pragma Import (C, glPixelStorei, "glPixelStorei");
pragma Import (C, glPixelTransferf, "glPixelTransferf");
pragma Import (C, glPixelTransferi, "glPixelTransferi");
pragma Import (C, glPixelMapfv, "glPixelMapfv");
pragma Import (C, glPixelMapuiv, "glPixelMapuiv");
pragma Import (C, glPixelMapusv, "glPixelMapusv");
pragma Import (C, glGetPixelMapfv, "glGetPixelMapfv");
pragma Import (C, glGetPixelMapuiv, "glGetPixelMapuiv");
pragma Import (C, glGetPixelMapusv, "glGetPixelMapusv");
pragma Import (C, glBitmap, "glBitmap");
pragma Import (C, glReadPixels, "glReadPixels");
pragma Import (C, glDrawPixels, "glDrawPixels");
pragma Import (C, glCopyPixels, "glCopyPixels");
pragma Import (C, glStencilFunc, "glStencilFunc");
pragma Import (C, glStencilMask, "glStencilMask");
pragma Import (C, glStencilOp, "glStencilOp");
pragma Import (C, glClearStencil, "glClearStencil");
pragma Import (C, glTexGend, "glTexGend");
pragma Import (C, glTexGenf, "glTexGenf");
pragma Import (C, glTexGeni, "glTexGeni");
pragma Import (C, glTexGendv, "glTexGendv");
pragma Import (C, glTexGenfv, "glTexGenfv");
pragma Import (C, glTexGeniv, "glTexGeniv");
pragma Import (C, glGetTexGendv, "glGetTexGendv");
pragma Import (C, glGetTexGenfv, "glGetTexGenfv");
pragma Import (C, glGetTexGeniv, "glGetTexGeniv");
pragma Import (C, glTexEnvf, "glTexEnvf");
pragma Import (C, glTexEnvi, "glTexEnvi");
pragma Import (C, glTexEnvfv, "glTexEnvfv");
pragma Import (C, glTexEnviv, "glTexEnviv");
pragma Import (C, glGetTexEnvfv, "glGetTexEnvfv");
pragma Import (C, glGetTexEnviv, "glGetTexEnviv");
pragma Import (C, glTexParameterf, "glTexParameterf");
pragma Import (C, glTexParameteri, "glTexParameteri");
pragma Import (C, glTexParameterfv, "glTexParameterfv");
pragma Import (C, glTexParameteriv, "glTexParameteriv");
pragma Import (C, glGetTexParameterfv, "glGetTexParameterfv");
pragma Import (C, glGetTexParameteriv, "glGetTexParameteriv");
pragma Import (C, glGetTexLevelParameterfv, "glGetTexLevelParameterfv");
pragma Import (C, glGetTexLevelParameteriv, "glGetTexLevelParameteriv");
pragma Import (C, glTexImage1D, "glTexImage1D");
pragma Import (C, glTexImage2D, "glTexImage2D");
pragma Import (C, glGetTexImage, "glGetTexImage");
pragma Import (C, glGenTextures, "glGenTextures");
pragma Import (C, glDeleteTextures, "glDeleteTextures");
pragma Import (C, glBindTexture, "glBindTexture");
pragma Import (C, glPrioritizeTextures, "glPrioritizeTextures");
pragma Import (C, glAreTexturesResident, "glAreTexturesResident");
pragma Import (C, glIsTexture, "glIsTexture");
pragma Import (C, glTexSubImage1D, "glTexSubImage1D");
pragma Import (C, glTexSubImage2D, "glTexSubImage2D");
pragma Import (C, glCopyTexImage1D, "glCopyTexImage1D");
pragma Import (C, glCopyTexImage2D, "glCopyTexImage2D");
pragma Import (C, glCopyTexSubImage1D, "glCopyTexSubImage1D");
pragma Import (C, glCopyTexSubImage2D, "glCopyTexSubImage2D");
pragma Import (C, glMap1d, "glMap1d");
pragma Import (C, glMap1f, "glMap1f");
pragma Import (C, glMap2d, "glMap2d");
pragma Import (C, glMap2f, "glMap2f");
pragma Import (C, glGetMapdv, "glGetMapdv");
pragma Import (C, glGetMapfv, "glGetMapfv");
pragma Import (C, glGetMapiv, "glGetMapiv");
pragma Import (C, glEvalCoord1d, "glEvalCoord1d");
pragma Import (C, glEvalCoord1f, "glEvalCoord1f");
pragma Import (C, glEvalCoord1dv, "glEvalCoord1dv");
pragma Import (C, glEvalCoord1fv, "glEvalCoord1fv");
pragma Import (C, glEvalCoord2d, "glEvalCoord2d");
pragma Import (C, glEvalCoord2f, "glEvalCoord2f");
pragma Import (C, glEvalCoord2dv, "glEvalCoord2dv");
pragma Import (C, glEvalCoord2fv, "glEvalCoord2fv");
pragma Import (C, glMapGrid1d, "glMapGrid1d");
pragma Import (C, glMapGrid1f, "glMapGrid1f");
pragma Import (C, glMapGrid2d, "glMapGrid2d");
pragma Import (C, glMapGrid2f, "glMapGrid2f");
pragma Import (C, glEvalPoint1, "glEvalPoint1");
pragma Import (C, glEvalPoint2, "glEvalPoint2");
pragma Import (C, glEvalMesh1, "glEvalMesh1");
pragma Import (C, glEvalMesh2, "glEvalMesh2");
pragma Import (C, glFogf, "glFogf");
pragma Import (C, glFogi, "glFogi");
pragma Import (C, glFogfv, "glFogfv");
pragma Import (C, glFogiv, "glFogiv");
pragma Import (C, glFeedbackBuffer, "glFeedbackBuffer");
pragma Import (C, glPassThrough, "glPassThrough");
pragma Import (C, glSelectBuffer, "glSelectBuffer");
pragma Import (C, glInitNames, "glInitNames");
pragma Import (C, glLoadName, "glLoadName");
pragma Import (C, glPushName, "glPushName");
pragma Import (C, glPopName, "glPopName");
pragma Import (C, glBlendEquationEXT, "glBlendEquationEXT");
pragma Import (C, glBlendColorEXT, "glBlendColorEXT");
pragma Import (C, glTexImage3DEXT, "glTexImage3DEXT");
pragma Import (C, glTexSubImage3DEXT, "glTexSubImage3DEXT");
pragma Import (C, glCopyTexSubImage3DEXT, "glCopyTexSubImage3DEXT");
pragma Import (C, glColorTableEXT, "glColorTableEXT");
pragma Import (C, glColorSubTableEXT, "glColorSubTableEXT");
pragma Import (C, glGetColorTableEXT, "glGetColorTableEXT");
pragma Import (C, glGetColorTableParameterfvEXT, "glGetColorTableParameterfvEXT");
pragma Import (C, glGetColorTableParameterivEXT, "glGetColorTableParameterivEXT");
pragma Import (C, glPointParameterfEXT, "glPointParameterfEXT");
pragma Import (C, glPointParameterfvEXT, "glPointParameterfvEXT");
pragma Import (C, glWindowPos2iMESA, "glWindowPos2iMESA");
pragma Import (C, glWindowPos2sMESA, "glWindowPos2sMESA");
pragma Import (C, glWindowPos2fMESA, "glWindowPos2fMESA");
pragma Import (C, glWindowPos2dMESA, "glWindowPos2dMESA");
pragma Import (C, glWindowPos2ivMESA, "glWindowPos2ivMESA");
pragma Import (C, glWindowPos2svMESA, "glWindowPos2svMESA");
pragma Import (C, glWindowPos2fvMESA, "glWindowPos2fvMESA");
pragma Import (C, glWindowPos2dvMESA, "glWindowPos2dvMESA");
pragma Import (C, glWindowPos3iMESA, "glWindowPos3iMESA");
pragma Import (C, glWindowPos3sMESA, "glWindowPos3sMESA");
pragma Import (C, glWindowPos3fMESA, "glWindowPos3fMESA");
pragma Import (C, glWindowPos3dMESA, "glWindowPos3dMESA");
pragma Import (C, glWindowPos3ivMESA, "glWindowPos3ivMESA");
pragma Import (C, glWindowPos3svMESA, "glWindowPos3svMESA");
pragma Import (C, glWindowPos3fvMESA, "glWindowPos3fvMESA");
pragma Import (C, glWindowPos3dvMESA, "glWindowPos3dvMESA");
pragma Import (C, glWindowPos4iMESA, "glWindowPos4iMESA");
pragma Import (C, glWindowPos4sMESA, "glWindowPos4sMESA");
pragma Import (C, glWindowPos4fMESA, "glWindowPos4fMESA");
pragma Import (C, glWindowPos4dMESA, "glWindowPos4dMESA");
pragma Import (C, glWindowPos4ivMESA, "glWindowPos4ivMESA");
pragma Import (C, glWindowPos4svMESA, "glWindowPos4svMESA");
pragma Import (C, glWindowPos4fvMESA, "glWindowPos4fvMESA");
pragma Import (C, glWindowPos4dvMESA, "glWindowPos4dvMESA");
pragma Import (C, glResizeBuffersMESA, "glResizeBuffersMESA");

end GL;
