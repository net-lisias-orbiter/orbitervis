//############################################################################//
const
// ********** GL generic constants **********

// errors
GL_NO_ERROR                                       = 0;
GL_INVALID_ENUM                                   = $0500;
GL_INVALID_VALUE                                  = $0501;
GL_INVALID_OPERATION                              = $0502;
GL_STACK_OVERFLOW                                 = $0503;
GL_STACK_UNDERFLOW                                = $0504;
GL_OUT_OF_MEMORY                                  = $0505;

// attribute bits
GL_CURRENT_BIT                                    = $00000001;
GL_POINT_BIT                                      = $00000002;
GL_LINE_BIT                                       = $00000004;
GL_POLYGON_BIT                                    = $00000008;
GL_POLYGON_STIPPLE_BIT                            = $00000010;
GL_PIXEL_MODE_BIT                                 = $00000020;
GL_LIGHTING_BIT                                   = $00000040;
GL_FOG_BIT                                        = $00000080;
GL_DEPTH_BUFFER_BIT                               = $00000100;
GL_ACCUM_BUFFER_BIT                               = $00000200;
GL_STENCIL_BUFFER_BIT                             = $00000400;
GL_VIEWPORT_BIT                                   = $00000800;
GL_TRANSFORM_BIT                                  = $00001000;
GL_ENABLE_BIT                                     = $00002000;
GL_COLOR_BUFFER_BIT                               = $00004000;
GL_HINT_BIT                                       = $00008000;
GL_EVAL_BIT                                       = $00010000;
GL_LIST_BIT                                       = $00020000;
GL_TEXTURE_BIT                                    = $00040000;
GL_SCISSOR_BIT                                    = $00080000;
GL_ALL_ATTRIB_BITS                                = $000FFFFF;

// client attribute bits
GL_CLIENT_PIXEL_STORE_BIT                         = $00000001;
GL_CLIENT_VERTEX_ARRAY_BIT                        = $00000002;
GL_CLIENT_ALL_ATTRIB_BITS                         = $FFFFFFFF;

// boolean values
GL_FALSE                                          = 0;
GL_TRUE                                           = 1;

// primitives
GL_POINTS                                         = $0000;
GL_LINES                                          = $0001;
GL_LINE_LOOP                                      = $0002;
GL_LINE_STRIP                                     = $0003;
GL_TRIANGLES                                      = $0004;
GL_TRIANGLE_STRIP                                 = $0005;
GL_TRIANGLE_FAN                                   = $0006;
GL_QUADS                                          = $0007;
GL_QUAD_STRIP                                     = $0008;
GL_POLYGON                                        = $0009;

// blending
GL_ZERO                                           = 0;
GL_ONE                                            = 1;
GL_SRC_COLOR                                      = $0300;
GL_ONE_MINUS_SRC_COLOR                            = $0301;
GL_SRC_ALPHA                                      = $0302;
GL_ONE_MINUS_SRC_ALPHA                            = $0303;
GL_DST_ALPHA                                      = $0304;
GL_ONE_MINUS_DST_ALPHA                            = $0305;
GL_DST_COLOR                                      = $0306;
GL_ONE_MINUS_DST_COLOR                            = $0307;
GL_SRC_ALPHA_SATURATE                             = $0308;
GL_BLEND_DST                                      = $0BE0;
GL_BLEND_SRC                                      = $0BE1;
GL_BLEND                                          = $0BE2;

// blending (GL 1.2 ARB imaging)
GL_BLEND_COLOR                                    = $8005;
GL_CONSTANT_COLOR                                 = $8001;
GL_ONE_MINUS_CONSTANT_COLOR                       = $8002;
GL_CONSTANT_ALPHA                                 = $8003;
GL_ONE_MINUS_CONSTANT_ALPHA                       = $8004;
GL_FUNC_ADD                                       = $8006;
GL_MIN                                            = $8007;
GL_MAX                                            = $8008;
GL_FUNC_SUBTRACT                                  = $800A;
GL_FUNC_REVERSE_SUBTRACT                          = $800B;

// color table GL 1.2 ARB imaging
GL_COLOR_TABLE                                    = $80D0;
GL_POST_CONVOLUTION_COLOR_TABLE                   = $80D1;
GL_POST_COLOR_MATRIX_COLOR_TABLE                  = $80D2;
GL_PROXY_COLOR_TABLE                              = $80D3;
GL_PROXY_POST_CONVOLUTION_COLOR_TABLE             = $80D4;
GL_PROXY_POST_COLOR_MATRIX_COLOR_TABLE            = $80D5;
GL_COLOR_TABLE_SCALE                              = $80D6;
GL_COLOR_TABLE_BIAS                               = $80D7;
GL_COLOR_TABLE_FORMAT                             = $80D8;
GL_COLOR_TABLE_WIDTH                              = $80D9;
GL_COLOR_TABLE_RED_SIZE                           = $80DA;
GL_COLOR_TABLE_GREEN_SIZE                         = $80DB;
GL_COLOR_TABLE_BLUE_SIZE                          = $80DC;
GL_COLOR_TABLE_ALPHA_SIZE                         = $80DD;
GL_COLOR_TABLE_LUMINANCE_SIZE                     = $80DE;
GL_COLOR_TABLE_INTENSITY_SIZE                     = $80DF;

// convolutions GL 1.2 ARB imaging
GL_CONVOLUTION_1D                                 = $8010;
GL_CONVOLUTION_2D                                 = $8011;
GL_SEPARABLE_2D                                   = $8012;
GL_CONVOLUTION_BORDER_MODE                        = $8013;
GL_CONVOLUTION_FILTER_SCALE                       = $8014;
GL_CONVOLUTION_FILTER_BIAS                        = $8015;
GL_REDUCE                                         = $8016;
GL_CONVOLUTION_FORMAT                             = $8017;
GL_CONVOLUTION_WIDTH                              = $8018;
GL_CONVOLUTION_HEIGHT                             = $8019;
GL_MAX_CONVOLUTION_WIDTH                          = $801A;
GL_MAX_CONVOLUTION_HEIGHT                         = $801B;
GL_POST_CONVOLUTION_RED_SCALE                     = $801C;
GL_POST_CONVOLUTION_GREEN_SCALE                   = $801D;
GL_POST_CONVOLUTION_BLUE_SCALE                    = $801E;
GL_POST_CONVOLUTION_ALPHA_SCALE                   = $801F;
GL_POST_CONVOLUTION_RED_BIAS                      = $8020;
GL_POST_CONVOLUTION_GREEN_BIAS                    = $8021;
GL_POST_CONVOLUTION_BLUE_BIAS                     = $8022;
GL_POST_CONVOLUTION_ALPHA_BIAS                    = $8023;

// histogram GL 1.2 ARB imaging
GL_HISTOGRAM                                      = $8024;
GL_PROXY_HISTOGRAM                                = $8025;
GL_HISTOGRAM_WIDTH                                = $8026;
GL_HISTOGRAM_FORMAT                               = $8027;
GL_HISTOGRAM_RED_SIZE                             = $8028;
GL_HISTOGRAM_GREEN_SIZE                           = $8029;
GL_HISTOGRAM_BLUE_SIZE                            = $802A;
GL_HISTOGRAM_ALPHA_SIZE                           = $802B;
GL_HISTOGRAM_LUMINANCE_SIZE                       = $802C;
GL_HISTOGRAM_SINK                                 = $802D;
GL_MINMAX                                         = $802E;
GL_MINMAX_FORMAT                                  = $802F;
GL_MINMAX_SINK                                    = $8030;

// buffers
GL_NONE                                           = 0;
GL_FRONT_LEFT                                     = $0400;
GL_FRONT_RIGHT                                    = $0401;
GL_BACK_LEFT                                      = $0402;
GL_BACK_RIGHT                                     = $0403;
GL_FRONT                                          = $0404;
GL_BACK                                           = $0405;
GL_LEFT                                           = $0406;
GL_RIGHT                                          = $0407;
GL_FRONT_AND_BACK                                 = $0408;
GL_AUX0                                           = $0409;
GL_AUX1                                           = $040A;
GL_AUX2                                           = $040B;
GL_AUX3                                           = $040C;
GL_AUX_BUFFERS                                    = $0C00;
GL_DRAW_BUFFER                                    = $0C01;
GL_READ_BUFFER                                    = $0C02;
GL_DOUBLEBUFFER                                   = $0C32;
GL_STEREO                                         = $0C33;

// depth buffer
GL_DEPTH_RANGE                                    = $0B70;
GL_DEPTH_TEST                                     = $0B71;
GL_DEPTH_WRITEMASK                                = $0B72;
GL_DEPTH_CLEAR_VALUE                              = $0B73;
GL_DEPTH_FUNC                                     = $0B74;
GL_NEVER                                          = $0200;
GL_LESS                                           = $0201;
GL_EQUAL                                          = $0202;
GL_LEQUAL                                         = $0203;
GL_GREATER                                        = $0204;
GL_NOTEQUAL                                       = $0205;
GL_GEQUAL                                         = $0206;
GL_ALWAYS                                         = $0207;

// accumulation buffer
GL_ACCUM                                          = $0100;
GL_LOAD                                           = $0101;
GL_RETURN                                         = $0102;
GL_MULT                                           = $0103;
GL_ADD                                            = $0104;
GL_ACCUM_CLEAR_VALUE                              = $0B80;

// feedback buffer
GL_FEEDBACK_BUFFER_POINTER                        = $0DF0;
GL_FEEDBACK_BUFFER_SIZE                           = $0DF1;
GL_FEEDBACK_BUFFER_TYPE                           = $0DF2;

// feedback types
GL_2D                                             = $0600;
GL_3D                                             = $0601;
GL_3D_COLOR                                       = $0602;
GL_3D_COLOR_TEXTURE                               = $0603;
GL_4D_COLOR_TEXTURE                               = $0604;

// feedback tokens
GL_PASS_THROUGH_TOKEN                             = $0700;
GL_POINT_TOKEN                                    = $0701;
GL_LINE_TOKEN                                     = $0702;
GL_POLYGON_TOKEN                                  = $0703;
GL_BITMAP_TOKEN                                   = $0704;
GL_DRAW_PIXEL_TOKEN                               = $0705;
GL_COPY_PIXEL_TOKEN                               = $0706;
GL_LINE_RESET_TOKEN                               = $0707;

// fog
GL_EXP                                            = $0800;
GL_EXP2                                           = $0801;
GL_FOG                                            = $0B60;
GL_FOG_INDEX                                      = $0B61;
GL_FOG_DENSITY                                    = $0B62;
GL_FOG_START                                      = $0B63;
GL_FOG_END                                        = $0B64;
GL_FOG_MODE                                       = $0B65;
GL_FOG_COLOR                                      = $0B66;

// pixel mode, transfer
GL_PIXEL_MAP_I_TO_I                               = $0C70;
GL_PIXEL_MAP_S_TO_S                               = $0C71;
GL_PIXEL_MAP_I_TO_R                               = $0C72;
GL_PIXEL_MAP_I_TO_G                               = $0C73;
GL_PIXEL_MAP_I_TO_B                               = $0C74;
GL_PIXEL_MAP_I_TO_A                               = $0C75;
GL_PIXEL_MAP_R_TO_R                               = $0C76;
GL_PIXEL_MAP_G_TO_G                               = $0C77;
GL_PIXEL_MAP_B_TO_B                               = $0C78;
GL_PIXEL_MAP_A_TO_A                               = $0C79;

// vertex arrays
GL_VERTEX_ARRAY_POINTER                           = $808E;
GL_NORMAL_ARRAY_POINTER                           = $808F;
GL_COLOR_ARRAY_POINTER                            = $8090;
GL_INDEX_ARRAY_POINTER                            = $8091;
GL_TEXTURE_COORD_ARRAY_POINTER                    = $8092;
GL_EDGE_FLAG_ARRAY_POINTER                        = $8093;

// stenciling
GL_STENCIL_TEST                                   = $0B90;
GL_STENCIL_CLEAR_VALUE                            = $0B91;
GL_STENCIL_FUNC                                   = $0B92;
GL_STENCIL_VALUE_MASK                             = $0B93;
GL_STENCIL_FAIL                                   = $0B94;
GL_STENCIL_PASS_DEPTH_FAIL                        = $0B95;
GL_STENCIL_PASS_DEPTH_PASS                        = $0B96;
GL_STENCIL_REF                                    = $0B97;
GL_STENCIL_WRITEMASK                              = $0B98;
GL_KEEP                                           = $1E00;
GL_REPLACE                                        = $1E01;
GL_INCR                                           = $1E02;
GL_DECR                                           = $1E03;

// color material
GL_COLOR_MATERIAL_FACE                            = $0B55;
GL_COLOR_MATERIAL_PARAMETER                       = $0B56;
GL_COLOR_MATERIAL                                 = $0B57;

// points
GL_POINT_SMOOTH                                   = $0B10;
GL_POINT_SIZE                                     = $0B11;
GL_POINT_SIZE_RANGE                               = $0B12;
GL_POINT_SIZE_GRANULARITY                         = $0B13;

// lines
GL_LINE_SMOOTH                                    = $0B20;
GL_LINE_WIDTH                                     = $0B21;
GL_LINE_WIDTH_RANGE                               = $0B22;
GL_LINE_WIDTH_GRANULARITY                         = $0B23;
GL_LINE_STIPPLE                                   = $0B24;
GL_LINE_STIPPLE_PATTERN                           = $0B25;
GL_LINE_STIPPLE_REPEAT                            = $0B26;

// polygons
GL_POLYGON_MODE                                   = $0B40;
GL_POLYGON_SMOOTH                                 = $0B41;
GL_POLYGON_STIPPLE                                = $0B42;
GL_EDGE_FLAG                                      = $0B43;
GL_CULL_FACE                                      = $0B44;
GL_CULL_FACE_MODE                                 = $0B45;
GL_FRONT_FACE                                     = $0B46;
GL_CW                                             = $0900;
GL_CCW                                            = $0901;
GL_POINT                                          = $1B00;
GL_LINE                                           = $1B01;
GL_FILL                                           = $1B02;

// display lists
GL_LIST_MODE                                      = $0B30;
GL_LIST_BASE                                      = $0B32;
GL_LIST_INDEX                                     = $0B33;
GL_COMPILE                                        = $1300;
GL_COMPILE_AND_EXECUTE                            = $1301;

// lighting
GL_LIGHTING                                       = $0B50;
GL_LIGHT_MODEL_LOCAL_VIEWER                       = $0B51;
GL_LIGHT_MODEL_TWO_SIDE                           = $0B52;
GL_LIGHT_MODEL_AMBIENT                            = $0B53;
GL_LIGHT_MODEL_COLOR_CONTROL                      = $81F8; // GL 1.2
GL_SHADE_MODEL                                    = $0B54;
GL_NORMALIZE                                      = $0BA1;
GL_AMBIENT                                        = $1200;
GL_DIFFUSE                                        = $1201;
GL_SPECULAR                                       = $1202;
GL_POSITION                                       = $1203;
GL_SPOT_DIRECTION                                 = $1204;
GL_SPOT_EXPONENT                                  = $1205;
GL_SPOT_CUTOFF                                    = $1206;
GL_CONSTANT_ATTENUATION                           = $1207;
GL_LINEAR_ATTENUATION                             = $1208;
GL_QUADRATIC_ATTENUATION                          = $1209;
GL_EMISSION                                       = $1600;
GL_SHININESS                                      = $1601;
GL_AMBIENT_AND_DIFFUSE                            = $1602;
GL_COLOR_INDEXES                                  = $1603;
GL_FLAT                                           = $1D00;
GL_SMOOTH                                         = $1D01;
GL_LIGHT0                                         = $4000;
GL_LIGHT1                                         = $4001;
GL_LIGHT2                                         = $4002;
GL_LIGHT3                                         = $4003;
GL_LIGHT4                                         = $4004;
GL_LIGHT5                                         = $4005;
GL_LIGHT6                                         = $4006;
GL_LIGHT7                                         = $4007;

// matrix modes
GL_MATRIX_MODE                                    = $0BA0;
GL_MODELVIEW                                      = $1700;
GL_PROJECTION                                     = $1701;
GL_TEXTURE                                        = $1702;

// gets
GL_CURRENT_COLOR                                  = $0B00;
GL_CURRENT_INDEX                                  = $0B01;
GL_CURRENT_NORMAL                                 = $0B02;
GL_CURRENT_TEXTURE_COORDS                         = $0B03;
GL_CURRENT_RASTER_COLOR                           = $0B04;
GL_CURRENT_RASTER_INDEX                           = $0B05;
GL_CURRENT_RASTER_TEXTURE_COORDS                  = $0B06;
GL_CURRENT_RASTER_POSITION                        = $0B07;
GL_CURRENT_RASTER_POSITION_VALID                  = $0B08;
GL_CURRENT_RASTER_DISTANCE                        = $0B09;
GL_MAX_LIST_NESTING                               = $0B31;
GL_VIEWPORT                                       = $0BA2;
GL_MODELVIEW_STACK_DEPTH                          = $0BA3;
GL_PROJECTION_STACK_DEPTH                         = $0BA4;
GL_TEXTURE_STACK_DEPTH                            = $0BA5;
GL_MODELVIEW_MATRIX                               = $0BA6;
GL_PROJECTION_MATRIX                              = $0BA7;
GL_TEXTURE_MATRIX                                 = $0BA8;
GL_ATTRIB_STACK_DEPTH                             = $0BB0;
GL_CLIENT_ATTRIB_STACK_DEPTH                      = $0BB1;

GL_SINGLE_COLOR                                   = $81F9; // GL 1.2
GL_SEPARATE_SPECULAR_COLOR                        = $81FA; // GL 1.2

// alpha testing
GL_ALPHA_TEST                                     = $0BC0;
GL_ALPHA_TEST_FUNC                                = $0BC1;
GL_ALPHA_TEST_REF                                 = $0BC2;

GL_LOGIC_OP_MODE                                  = $0BF0;
GL_INDEX_LOGIC_OP                                 = $0BF1;
GL_LOGIC_OP                                       = $0BF1;
GL_COLOR_LOGIC_OP                                 = $0BF2;
GL_SCISSOR_BOX                                    = $0C10;
GL_SCISSOR_TEST                                   = $0C11;
GL_INDEX_CLEAR_VALUE                              = $0C20;
GL_INDEX_WRITEMASK                                = $0C21;
GL_COLOR_CLEAR_VALUE                              = $0C22;
GL_COLOR_WRITEMASK                                = $0C23;
GL_INDEX_MODE                                     = $0C30;
GL_RGBA_MODE                                      = $0C31;
GL_RENDER_MODE                                    = $0C40;
GL_PERSPECTIVE_CORRECTION_HINT                    = $0C50;
GL_POINT_SMOOTH_HINT                              = $0C51;
GL_LINE_SMOOTH_HINT                               = $0C52;
GL_POLYGON_SMOOTH_HINT                            = $0C53;
GL_FOG_HINT                                       = $0C54;
GL_TEXTURE_GEN_S                                  = $0C60;
GL_TEXTURE_GEN_T                                  = $0C61;
GL_TEXTURE_GEN_R                                  = $0C62;
GL_TEXTURE_GEN_Q                                  = $0C63;
GL_PIXEL_MAP_I_TO_I_SIZE                          = $0CB0;
GL_PIXEL_MAP_S_TO_S_SIZE                          = $0CB1;
GL_PIXEL_MAP_I_TO_R_SIZE                          = $0CB2;
GL_PIXEL_MAP_I_TO_G_SIZE                          = $0CB3;
GL_PIXEL_MAP_I_TO_B_SIZE                          = $0CB4;
GL_PIXEL_MAP_I_TO_A_SIZE                          = $0CB5;
GL_PIXEL_MAP_R_TO_R_SIZE                          = $0CB6;
GL_PIXEL_MAP_G_TO_G_SIZE                          = $0CB7;
GL_PIXEL_MAP_B_TO_B_SIZE                          = $0CB8;
GL_PIXEL_MAP_A_TO_A_SIZE                          = $0CB9;
GL_UNPACK_SWAP_BYTES                              = $0CF0;
GL_UNPACK_LSB_FIRST                               = $0CF1;
GL_UNPACK_ROW_LENGTH                              = $0CF2;
GL_UNPACK_SKIP_ROWS                               = $0CF3;
GL_UNPACK_SKIP_PIXELS                             = $0CF4;
GL_UNPACK_ALIGNMENT                               = $0CF5;
GL_PACK_SWAP_BYTES                                = $0D00;
GL_PACK_LSB_FIRST                                 = $0D01;
GL_PACK_ROW_LENGTH                                = $0D02;
GL_PACK_SKIP_ROWS                                 = $0D03;
GL_PACK_SKIP_PIXELS                               = $0D04;
GL_PACK_ALIGNMENT                                 = $0D05;
GL_PACK_SKIP_IMAGES                               = $806B; // GL 1.2
GL_PACK_IMAGE_HEIGHT                              = $806C; // GL 1.2
GL_UNPACK_SKIP_IMAGES                             = $806D; // GL 1.2
GL_UNPACK_IMAGE_HEIGHT                            = $806E; // GL 1.2
GL_MAP_COLOR                                      = $0D10;
GL_MAP_STENCIL                                    = $0D11;
GL_INDEX_SHIFT                                    = $0D12;
GL_INDEX_OFFSET                                   = $0D13;
GL_RED_SCALE                                      = $0D14;
GL_RED_BIAS                                       = $0D15;
GL_ZOOM_X                                         = $0D16;
GL_ZOOM_Y                                         = $0D17;
GL_GREEN_SCALE                                    = $0D18;
GL_GREEN_BIAS                                     = $0D19;
GL_BLUE_SCALE                                     = $0D1A;
GL_BLUE_BIAS                                      = $0D1B;
GL_ALPHA_SCALE                                    = $0D1C;
GL_ALPHA_BIAS                                     = $0D1D;
GL_DEPTH_SCALE                                    = $0D1E;
GL_DEPTH_BIAS                                     = $0D1F;
GL_MAX_EVAL_ORDER                                 = $0D30;
GL_MAX_LIGHTS                                     = $0D31;
GL_MAX_CLIP_PLANES                                = $0D32;
GL_MAX_TEXTURE_SIZE                               = $0D33;
GL_MAX_3D_TEXTURE_SIZE                            = $8073; // GL 1.2
GL_MAX_PIXEL_MAP_TABLE                            = $0D34;
GL_MAX_ATTRIB_STACK_DEPTH                         = $0D35;
GL_MAX_MODELVIEW_STACK_DEPTH                      = $0D36;
GL_MAX_NAME_STACK_DEPTH                           = $0D37;
GL_MAX_PROJECTION_STACK_DEPTH                     = $0D38;
GL_MAX_TEXTURE_STACK_DEPTH                        = $0D39;
GL_MAX_VIEWPORT_DIMS                              = $0D3A;
GL_MAX_CLIENT_ATTRIB_STACK_DEPTH                  = $0D3B;
GL_MAX_ELEMENTS_VERTICES                          = $80E8; // GL 1.2
GL_MAX_ELEMENTS_INDICES                           = $80E9; // GL 1.2
GL_RESCALE_NORMAL                                 = $803A; // GL 1.2
GL_SUBPIXEL_BITS                                  = $0D50;
GL_INDEX_BITS                                     = $0D51;
GL_RED_BITS                                       = $0D52;
GL_GREEN_BITS                                     = $0D53;
GL_BLUE_BITS                                      = $0D54;
GL_ALPHA_BITS                                     = $0D55;
GL_DEPTH_BITS                                     = $0D56;
GL_STENCIL_BITS                                   = $0D57;
GL_ACCUM_RED_BITS                                 = $0D58;
GL_ACCUM_GREEN_BITS                               = $0D59;
GL_ACCUM_BLUE_BITS                                = $0D5A;
GL_ACCUM_ALPHA_BITS                               = $0D5B;
GL_NAME_STACK_DEPTH                               = $0D70;
GL_AUTO_NORMAL                                    = $0D80;
GL_MAP1_COLOR_4                                   = $0D90;
GL_MAP1_INDEX                                     = $0D91;
GL_MAP1_NORMAL                                    = $0D92;
GL_MAP1_TEXTURE_COORD_1                           = $0D93;
GL_MAP1_TEXTURE_COORD_2                           = $0D94;
GL_MAP1_TEXTURE_COORD_3                           = $0D95;
GL_MAP1_TEXTURE_COORD_4                           = $0D96;
GL_MAP1_VERTEX_3                                  = $0D97;
GL_MAP1_VERTEX_4                                  = $0D98;
GL_MAP2_COLOR_4                                   = $0DB0;
GL_MAP2_INDEX                                     = $0DB1;
GL_MAP2_NORMAL                                    = $0DB2;
GL_MAP2_TEXTURE_COORD_1                           = $0DB3;
GL_MAP2_TEXTURE_COORD_2                           = $0DB4;
GL_MAP2_TEXTURE_COORD_3                           = $0DB5;
GL_MAP2_TEXTURE_COORD_4                           = $0DB6;
GL_MAP2_VERTEX_3                                  = $0DB7;
GL_MAP2_VERTEX_4                                  = $0DB8;
GL_MAP1_GRID_DOMAIN                               = $0DD0;
GL_MAP1_GRID_SEGMENTS                             = $0DD1;
GL_MAP2_GRID_DOMAIN                               = $0DD2;
GL_MAP2_GRID_SEGMENTS                             = $0DD3;
GL_TEXTURE_1D                                     = $0DE0;
GL_TEXTURE_2D                                     = $0DE1;
GL_TEXTURE_3D                                     = $806F; // GL 1.2
GL_SELECTION_BUFFER_POINTER                       = $0DF3;
GL_SELECTION_BUFFER_SIZE                          = $0DF4;
GL_POLYGON_OFFSET_UNITS                           = $2A00;
GL_POLYGON_OFFSET_POINT                           = $2A01;
GL_POLYGON_OFFSET_LINE                            = $2A02;
GL_POLYGON_OFFSET_FILL                            = $8037;
GL_POLYGON_OFFSET_FACTOR                          = $8038;
GL_TEXTURE_BINDING_1D                             = $8068;
GL_TEXTURE_BINDING_2D                             = $8069;
GL_VERTEX_ARRAY                                   = $8074;
GL_NORMAL_ARRAY                                   = $8075;
GL_COLOR_ARRAY                                    = $8076;
GL_INDEX_ARRAY                                    = $8077;
GL_TEXTURE_COORD_ARRAY                            = $8078;
GL_EDGE_FLAG_ARRAY                                = $8079;
GL_VERTEX_ARRAY_SIZE                              = $807A;
GL_VERTEX_ARRAY_TYPE                              = $807B;
GL_VERTEX_ARRAY_STRIDE                            = $807C;
GL_NORMAL_ARRAY_TYPE                              = $807E;
GL_NORMAL_ARRAY_STRIDE                            = $807F;
GL_COLOR_ARRAY_SIZE                               = $8081;
GL_COLOR_ARRAY_TYPE                               = $8082;
GL_COLOR_ARRAY_STRIDE                             = $8083;
GL_INDEX_ARRAY_TYPE                               = $8085;
GL_INDEX_ARRAY_STRIDE                             = $8086;
GL_TEXTURE_COORD_ARRAY_SIZE                       = $8088;
GL_TEXTURE_COORD_ARRAY_TYPE                       = $8089;
GL_TEXTURE_COORD_ARRAY_STRIDE                     = $808A;
GL_EDGE_FLAG_ARRAY_STRIDE                         = $808C;
GL_COLOR_MATRIX                                   = $80B1; // GL 1.2 ARB imaging
GL_COLOR_MATRIX_STACK_DEPTH                       = $80B2; // GL 1.2 ARB imaging
GL_MAX_COLOR_MATRIX_STACK_DEPTH                   = $80B3; // GL 1.2 ARB imaging
GL_POST_COLOR_MATRIX_RED_SCALE                    = $80B4; // GL 1.2 ARB imaging
GL_POST_COLOR_MATRIX_GREEN_SCALE                  = $80B5; // GL 1.2 ARB imaging
GL_POST_COLOR_MATRIX_BLUE_SCALE                   = $80B6; // GL 1.2 ARB imaging
GL_POST_COLOR_MATRIX_ALPHA_SCALE                  = $80B7; // GL 1.2 ARB imaging
GL_POST_COLOR_MATRIX_RED_BIAS                     = $80B8; // GL 1.2 ARB imaging
GL_POST_COLOR_MATRIX_GREEN_BIAS                   = $80B9; // GL 1.2 ARB imaging
GL_POST_COLOR_MATRIX_BLUE_BIAS                    = $80BA; // GL 1.2 ARB imaging
GL_POST_COLOR_MATRIX_ALPHA_BIAS                   = $80BB; // GL 1.2 ARB imaging

// evaluators
GL_COEFF                                          = $0A00;
GL_ORDER                                          = $0A01;
GL_DOMAIN                                         = $0A02;

// texture mapping
GL_TEXTURE_WIDTH                                  = $1000;
GL_TEXTURE_HEIGHT                                 = $1001;
GL_TEXTURE_INTERNAL_FORMAT                        = $1003;
GL_TEXTURE_COMPONENTS                             = $1003;
GL_TEXTURE_BORDER_COLOR                           = $1004;
GL_TEXTURE_BORDER                                 = $1005;
GL_TEXTURE_RED_SIZE                               = $805C;
GL_TEXTURE_GREEN_SIZE                             = $805D;
GL_TEXTURE_BLUE_SIZE                              = $805E;
GL_TEXTURE_ALPHA_SIZE                             = $805F;
GL_TEXTURE_LUMINANCE_SIZE                         = $8060;
GL_TEXTURE_INTENSITY_SIZE                         = $8061;
GL_TEXTURE_PRIORITY                               = $8066;
GL_TEXTURE_RESIDENT                               = $8067;
GL_BGR                                            = $80E0; // v 1.2
GL_BGRA                                           = $80E1; // v 1.2
GL_S                                              = $2000;
GL_T                                              = $2001;
GL_R                                              = $2002;
GL_Q                                              = $2003;
GL_MODULATE                                       = $2100;
GL_DECAL                                          = $2101;
GL_TEXTURE_ENV_MODE                               = $2200;
GL_TEXTURE_ENV_COLOR                              = $2201;
GL_TEXTURE_ENV                                    = $2300;
GL_EYE_LINEAR                                     = $2400;
GL_OBJECT_LINEAR                                  = $2401;
GL_SPHERE_MAP                                     = $2402;
GL_TEXTURE_GEN_MODE                               = $2500;
GL_OBJECT_PLANE                                   = $2501;
GL_EYE_PLANE                                      = $2502;
GL_NEAREST                                        = $2600;
GL_LINEAR                                         = $2601;
GL_NEAREST_MIPMAP_NEAREST                         = $2700;
GL_LINEAR_MIPMAP_NEAREST                          = $2701;
GL_NEAREST_MIPMAP_LINEAR                          = $2702;
GL_LINEAR_MIPMAP_LINEAR                           = $2703;
GL_TEXTURE_MAG_FILTER                             = $2800;
GL_TEXTURE_MIN_FILTER                             = $2801;
GL_TEXTURE_WRAP_R                                 = $8072; // GL 1.2
GL_TEXTURE_WRAP_S                                 = $2802;
GL_TEXTURE_WRAP_T                                 = $2803;
GL_CLAMP_TO_EDGE                                  = $812F; // GL 1.2
GL_TEXTURE_MIN_LOD                                = $813A; // GL 1.2
GL_TEXTURE_MAX_LOD                                = $813B; // GL 1.2
GL_TEXTURE_BASE_LEVEL                             = $813C; // GL 1.2
GL_TEXTURE_MAX_LEVEL                              = $813D; // GL 1.2
GL_TEXTURE_DEPTH                                  = $8071; // GL 1.2
GL_PROXY_TEXTURE_1D                               = $8063;
GL_PROXY_TEXTURE_2D                               = $8064;
GL_PROXY_TEXTURE_3D                               = $8070; // GL 1.2
GL_CLAMP                                          = $2900;
GL_REPEAT                                         = $2901;

// hints
GL_DONT_CARE                                      = $1100;
GL_FASTEST                                        = $1101;
GL_NICEST                                         = $1102;

// data types
GL_BYTE                                           = $1400;
GL_UNSIGNED_BYTE                                  = $1401;
GL_SHORT                                          = $1402;
GL_UNSIGNED_SHORT                                 = $1403;
GL_INT                                            = $1404;
GL_UNSIGNED_INT                                   = $1405;
GL_FLOAT                                          = $1406;
GL_2_BYTES                                        = $1407;
GL_3_BYTES                                        = $1408;
GL_4_BYTES                                        = $1409;
GL_DOUBLE                                         = $140A;
GL_DOUBLE_EXT                                     = $140A;

// logic operations
GL_CLEAR                                          = $1500;
GL_AND                                            = $1501;
GL_AND_REVERSE                                    = $1502;
GL_COPY                                           = $1503;
GL_AND_INVERTED                                   = $1504;
GL_NOOP                                           = $1505;
GL_XOR                                            = $1506;
GL_OR                                             = $1507;
GL_NOR                                            = $1508;
GL_EQUIV                                          = $1509;
GL_INVERT                                         = $150A;
GL_OR_REVERSE                                     = $150B;
GL_COPY_INVERTED                                  = $150C;
GL_OR_INVERTED                                    = $150D;
GL_NAND                                           = $150E;
GL_SET                                            = $150F;

// PixelCopyType
GL_COLOR                                          = $1800;
GL_DEPTH                                          = $1801;
GL_STENCIL                                        = $1802;

// pixel formats
GL_COLOR_INDEX                                    = $1900;
GL_STENCIL_INDEX                                  = $1901;
GL_DEPTH_COMPONENT                                = $1902;
GL_RED                                            = $1903;
GL_GREEN                                          = $1904;
GL_BLUE                                           = $1905;
GL_ALPHA                                          = $1906;
GL_RGB                                            = $1907;
GL_RGBA                                           = $1908;
GL_LUMINANCE                                      = $1909;
GL_LUMINANCE_ALPHA                                = $190A;

// pixel type
GL_BITMAP                                         = $1A00;

// rendering modes
GL_RENDER                                         = $1C00;
GL_FEEDBACK                                       = $1C01;
GL_SELECT                                         = $1C02;

// implementation strings
GL_VENDOR                                         = $1F00;
GL_RENDERER                                       = $1F01;
GL_VERSION                                        = $1F02;
GL_EXTENSIONS                                     = $1F03;

// pixel formats
GL_R3_G3_B2                                       = $2A10;
GL_ALPHA4                                         = $803B;
GL_ALPHA8                                         = $803C;
GL_ALPHA12                                        = $803D;
GL_ALPHA16                                        = $803E;
GL_LUMINANCE4                                     = $803F;
GL_LUMINANCE8                                     = $8040;
GL_LUMINANCE12                                    = $8041;
GL_LUMINANCE16                                    = $8042;
GL_LUMINANCE4_ALPHA4                              = $8043;
GL_LUMINANCE6_ALPHA2                              = $8044;
GL_LUMINANCE8_ALPHA8                              = $8045;
GL_LUMINANCE12_ALPHA4                             = $8046;
GL_LUMINANCE12_ALPHA12                            = $8047;
GL_LUMINANCE16_ALPHA16                            = $8048;
GL_INTENSITY                                      = $8049;
GL_INTENSITY4                                     = $804A;
GL_INTENSITY8                                     = $804B;
GL_INTENSITY12                                    = $804C;
GL_INTENSITY16                                    = $804D;
GL_RGB4                                           = $804F;
GL_RGB5                                           = $8050;
GL_RGB8                                           = $8051;
GL_RGB10                                          = $8052;
GL_RGB12                                          = $8053;
GL_RGB16                                          = $8054;
GL_RGBA2                                          = $8055;
GL_RGBA4                                          = $8056;
GL_RGB5_A1                                        = $8057;
GL_RGBA8                                          = $8058;
GL_RGB10_A2                                       = $8059;
GL_RGBA12                                         = $805A;
GL_RGBA16                                         = $805B;
UNSIGNED_BYTE_3_3_2                               = $8032; // GL 1.2
UNSIGNED_BYTE_2_3_3_REV                           = $8362; // GL 1.2
UNSIGNED_SHORT_5_6_5                              = $8363; // GL 1.2
UNSIGNED_SHORT_5_6_5_REV                          = $8364; // GL 1.2
UNSIGNED_SHORT_4_4_4_4                            = $8033; // GL 1.2
UNSIGNED_SHORT_4_4_4_4_REV                        = $8365; // GL 1.2
UNSIGNED_SHORT_5_5_5_1                            = $8034; // GL 1.2
UNSIGNED_SHORT_1_5_5_5_REV                        = $8366; // GL 1.2
UNSIGNED_INT_8_8_8_8                              = $8035; // GL 1.2
UNSIGNED_INT_8_8_8_8_REV                          = $8367; // GL 1.2
UNSIGNED_INT_10_10_10_2                           = $8036; // GL 1.2
UNSIGNED_INT_2_10_10_10_REV                       = $8368; // GL 1.2

// interleaved arrays formats
GL_V2F                                            = $2A20;
GL_V3F                                            = $2A21;
GL_C4UB_V2F                                       = $2A22;
GL_C4UB_V3F                                       = $2A23;
GL_C3F_V3F                                        = $2A24;
GL_N3F_V3F                                        = $2A25;
GL_C4F_N3F_V3F                                    = $2A26;
GL_T2F_V3F                                        = $2A27;
GL_T4F_V4F                                        = $2A28;
GL_T2F_C4UB_V3F                                   = $2A29;
GL_T2F_C3F_V3F                                    = $2A2A;
GL_T2F_N3F_V3F                                    = $2A2B;
GL_T2F_C4F_N3F_V3F                                = $2A2C;
GL_T4F_C4F_N3F_V4F                                = $2A2D;

// clip planes
GL_CLIP_PLANE0                                    = $3000;
GL_CLIP_PLANE1                                    = $3001;
GL_CLIP_PLANE2                                    = $3002;
GL_CLIP_PLANE3                                    = $3003;
GL_CLIP_PLANE4                                    = $3004;
GL_CLIP_PLANE5                                    = $3005;

// miscellaneous
GL_DITHER                                         = $0BD0;

// ----- extensions enumerants -----
// EXT_abgr
GL_ABGR_EXT                                       = $8000;

// EXT_packed_pixels
GL_UNSIGNED_BYTE_3_3_2_EXT                        = $8032;
GL_UNSIGNED_SHORT_4_4_4_4_EXT                     = $8033;
GL_UNSIGNED_SHORT_5_5_5_1_EXT                     = $8034;
GL_UNSIGNED_INT_8_8_8_8_EXT                       = $8035;
GL_UNSIGNED_INT_10_10_10_2_EXT                    = $8036;

// EXT_bgra
GL_BGR_EXT                                        = $80E0;
GL_BGRA_EXT                                       = $80E1;

// EXT_paletted_texture
GL_COLOR_INDEX1_EXT                               = $80E2;
GL_COLOR_INDEX2_EXT                               = $80E3;
GL_COLOR_INDEX4_EXT                               = $80E4;
GL_COLOR_INDEX8_EXT                               = $80E5;
GL_COLOR_INDEX12_EXT                              = $80E6;
GL_COLOR_INDEX16_EXT                              = $80E7;

// EXT_blend_color
GL_CONSTANT_COLOR_EXT                             = $8001;
GL_ONE_MINUS_CONSTANT_COLOR_EXT                   = $8002;
GL_CONSTANT_ALPHA_EXT                             = $8003;
GL_ONE_MINUS_CONSTANT_ALPHA_EXT                   = $8004;
GL_BLEND_COLOR_EXT                                = $8005;

// EXT_blend_minmax
GL_FUNC_ADD_EXT                                   = $8006;
GL_MIN_EXT                                        = $8007;
GL_MAX_EXT                                        = $8008;
GL_BLEND_EQUATION_EXT                             = $8009;

// EXT_blend_subtract
GL_FUNC_SUBTRACT_EXT                              = $800A;
GL_FUNC_REVERSE_SUBTRACT_EXT                      = $800B;

// EXT_convolution
GL_CONVOLUTION_1D_EXT                             = $8010;
GL_CONVOLUTION_2D_EXT                             = $8011;
GL_SEPARABLE_2D_EXT                               = $8012;
GL_CONVOLUTION_BORDER_MODE_EXT                    = $8013;
GL_CONVOLUTION_FILTER_SCALE_EXT                   = $8014;
GL_CONVOLUTION_FILTER_BIAS_EXT                    = $8015;
GL_REDUCE_EXT                                     = $8016;
GL_CONVOLUTION_FORMAT_EXT                         = $8017;
GL_CONVOLUTION_WIDTH_EXT                          = $8018;
GL_CONVOLUTION_HEIGHT_EXT                         = $8019;
GL_MAX_CONVOLUTION_WIDTH_EXT                      = $801A;
GL_MAX_CONVOLUTION_HEIGHT_EXT                     = $801B;
GL_POST_CONVOLUTION_RED_SCALE_EXT                 = $801C;
GL_POST_CONVOLUTION_GREEN_SCALE_EXT               = $801D;
GL_POST_CONVOLUTION_BLUE_SCALE_EXT                = $801E;
GL_POST_CONVOLUTION_ALPHA_SCALE_EXT               = $801F;
GL_POST_CONVOLUTION_RED_BIAS_EXT                  = $8020;
GL_POST_CONVOLUTION_GREEN_BIAS_EXT                = $8021;
GL_POST_CONVOLUTION_BLUE_BIAS_EXT                 = $8022;
GL_POST_CONVOLUTION_ALPHA_BIAS_EXT                = $8023;

// EXT_histogram
GL_HISTOGRAM_EXT                                  = $8024;
GL_PROXY_HISTOGRAM_EXT                            = $8025;
GL_HISTOGRAM_WIDTH_EXT                            = $8026;
GL_HISTOGRAM_FORMAT_EXT                           = $8027;
GL_HISTOGRAM_RED_SIZE_EXT                         = $8028;
GL_HISTOGRAM_GREEN_SIZE_EXT                       = $8029;
GL_HISTOGRAM_BLUE_SIZE_EXT                        = $802A;
GL_HISTOGRAM_ALPHA_SIZE_EXT                       = $802B;
GL_HISTOGRAM_LUMINANCE_SIZE_EXT                   = $802C;
GL_HISTOGRAM_SINK_EXT                             = $802D;
GL_MINMAX_EXT                                     = $802E;
GL_MINMAX_FORMAT_EXT                              = $802F;
GL_MINMAX_SINK_EXT                                = $8030;

// EXT_polygon_offset
GL_POLYGON_OFFSET_EXT                             = $8037;
GL_POLYGON_OFFSET_FACTOR_EXT                      = $8038;
GL_POLYGON_OFFSET_BIAS_EXT                        = $8039;

// EXT_texture
GL_ALPHA4_EXT                                     = $803B;
GL_ALPHA8_EXT                                     = $803C;
GL_ALPHA12_EXT                                    = $803D;
GL_ALPHA16_EXT                                    = $803E;
GL_LUMINANCE4_EXT                                 = $803F;
GL_LUMINANCE8_EXT                                 = $8040;
GL_LUMINANCE12_EXT                                = $8041;
GL_LUMINANCE16_EXT                                = $8042;
GL_LUMINANCE4_ALPHA4_EXT                          = $8043;
GL_LUMINANCE6_ALPHA2_EXT                          = $8044;
GL_LUMINANCE8_ALPHA8_EXT                          = $8045;
GL_LUMINANCE12_ALPHA4_EXT                         = $8046;
GL_LUMINANCE12_ALPHA12_EXT                        = $8047;
GL_LUMINANCE16_ALPHA16_EXT                        = $8048;
GL_INTENSITY_EXT                                  = $8049;
GL_INTENSITY4_EXT                                 = $804A;
GL_INTENSITY8_EXT                                 = $804B;
GL_INTENSITY12_EXT                                = $804C;
GL_INTENSITY16_EXT                                = $804D;
GL_RGB2_EXT                                       = $804E;
GL_RGB4_EXT                                       = $804F;
GL_RGB5_EXT                                       = $8050;
GL_RGB8_EXT                                       = $8051;
GL_RGB10_EXT                                      = $8052;
GL_RGB12_EXT                                      = $8053;
GL_RGB16_EXT                                      = $8054;
GL_RGBA2_EXT                                      = $8055;
GL_RGBA4_EXT                                      = $8056;
GL_RGB5_A1_EXT                                    = $8057;
GL_RGBA8_EXT                                      = $8058;
GL_RGB10_A2_EXT                                   = $8059;
GL_RGBA12_EXT                                     = $805A;
GL_RGBA16_EXT                                     = $805B;
GL_TEXTURE_RED_SIZE_EXT                           = $805C;
GL_TEXTURE_GREEN_SIZE_EXT                         = $805D;
GL_TEXTURE_BLUE_SIZE_EXT                          = $805E;
GL_TEXTURE_ALPHA_SIZE_EXT                         = $805F;
GL_TEXTURE_LUMINANCE_SIZE_EXT                     = $8060;
GL_TEXTURE_INTENSITY_SIZE_EXT                     = $8061;
GL_REPLACE_EXT                                    = $8062;
GL_PROXY_TEXTURE_1D_EXT                           = $8063;
GL_PROXY_TEXTURE_2D_EXT                           = $8064;
GL_TEXTURE_TOO_LARGE_EXT                          = $8065;

// EXT_texture_object
GL_TEXTURE_PRIORITY_EXT                           = $8066;
GL_TEXTURE_RESIDENT_EXT                           = $8067;
GL_TEXTURE_1D_BINDING_EXT                         = $8068;
GL_TEXTURE_2D_BINDING_EXT                         = $8069;
GL_TEXTURE_3D_BINDING_EXT                         = $806A;

// EXT_texture3D
GL_PACK_SKIP_IMAGES_EXT                           = $806B;
GL_PACK_IMAGE_HEIGHT_EXT                          = $806C;
GL_UNPACK_SKIP_IMAGES_EXT                         = $806D;
GL_UNPACK_IMAGE_HEIGHT_EXT                        = $806E;
GL_TEXTURE_3D_EXT                                 = $806F;
GL_PROXY_TEXTURE_3D_EXT                           = $8070;
GL_TEXTURE_DEPTH_EXT                              = $8071;
GL_TEXTURE_WRAP_R_EXT                             = $8072;
GL_MAX_3D_TEXTURE_SIZE_EXT                        = $8073;

// SGI_color_matrix
GL_COLOR_MATRIX_SGI                               = $80B1;
GL_COLOR_MATRIX_STACK_DEPTH_SGI                   = $80B2;
GL_MAX_COLOR_MATRIX_STACK_DEPTH_SGI               = $80B3;
GL_POST_COLOR_MATRIX_RED_SCALE_SGI                = $80B4;
GL_POST_COLOR_MATRIX_GREEN_SCALE_SGI              = $80B5;
GL_POST_COLOR_MATRIX_BLUE_SCALE_SGI               = $80B6;
GL_POST_COLOR_MATRIX_ALPHA_SCALE_SGI              = $80B7;
GL_POST_COLOR_MATRIX_RED_BIAS_SGI                 = $80B8;
GL_POST_COLOR_MATRIX_GREEN_BIAS_SGI               = $80B9;
GL_POST_COLOR_MATRIX_BLUE_BIAS_SGI                = $80BA;
GL_POST_COLOR_MATRIX_ALPHA_BIAS_SGI               = $80BB;

// ARB_point_parameters
GL_POINT_SIZE_MIN_ARB                             = $8126;
GL_POINT_SIZE_MAX_ARB                             = $8127;
GL_POINT_FADE_THRESHOLD_SIZE_ARB                  = $8128;
GL_DISTANCE_ATTENUATION_ARB                       = $8129;

// EXT_rescale_normal
GL_RESCALE_NORMAL_EXT                             = $803A;

// EXT_shared_texture_palette
GL_SHARED_TEXTURE_PALETTE_EXT                     = $81FB;

// EXT_nurbs_tessellator
GLU_NURBS_MODE_EXT                                = 100160;
GLU_NURBS_TESSELLATOR_EXT                         = 100161;
GLU_NURBS_RENDERER_EXT                            = 100162;
GLU_NURBS_BEGIN_EXT                               = 100164;
GLU_NURBS_VERTEX_EXT                              = 100165;
GLU_NURBS_NORMAL_EXT                              = 100166;
GLU_NURBS_COLOR_EXT                               = 100167;
GLU_NURBS_TEX_COORD_EXT                           = 100168;
GLU_NURBS_END_EXT                                 = 100169;
GLU_NURBS_BEGIN_DATA_EXT                          = 100170;
GLU_NURBS_VERTEX_DATA_EXT                         = 100171;
GLU_NURBS_NORMAL_DATA_EXT                         = 100172;
GLU_NURBS_COLOR_DATA_EXT                          = 100173;
GLU_NURBS_TEX_COORD_DATA_EXT                      = 100174;
GLU_NURBS_END_DATA_EXT                            = 100175;

// EXT_object_space_tess
GLU_OBJECT_PARAMETRIC_ERROR_EXT                   = 100208;
GLU_OBJECT_PATH_LENGTH_EXT                        = 100209;

// EXT_compiled_vertex_array
GL_ARRAY_ELEMENT_LOCK_FIRST_EXT                   = $81A8;
GL_ARRAY_ELEMENT_LOCK_COUNT_EXT                   = $81A9;

// ARB_multitexture
GL_ACTIVE_TEXTURE_ARB                             = $84E0;
GL_CLIENT_ACTIVE_TEXTURE_ARB                      = $84E1;
GL_MAX_TEXTURE_UNITS_ARB                          = $84E2;
GL_TEXTURE0_ARB                                   = $84C0;
GL_TEXTURE1_ARB                                   = $84C1;
GL_TEXTURE2_ARB                                   = $84C2;
GL_TEXTURE3_ARB                                   = $84C3;
GL_TEXTURE4_ARB                                   = $84C4;
GL_TEXTURE5_ARB                                   = $84C5;
GL_TEXTURE6_ARB                                   = $84C6;
GL_TEXTURE7_ARB                                   = $84C7;
GL_TEXTURE8_ARB                                   = $84C8;
GL_TEXTURE9_ARB                                   = $84C9;
GL_TEXTURE10_ARB                                  = $84CA;
GL_TEXTURE11_ARB                                  = $84CB;
GL_TEXTURE12_ARB                                  = $84CC;
GL_TEXTURE13_ARB                                  = $84CD;
GL_TEXTURE14_ARB                                  = $84CE;
GL_TEXTURE15_ARB                                  = $84CF;
GL_TEXTURE16_ARB                                  = $84D0;
GL_TEXTURE17_ARB                                  = $84D1;
GL_TEXTURE18_ARB                                  = $84D2;
GL_TEXTURE19_ARB                                  = $84D3;
GL_TEXTURE20_ARB                                  = $84D4;
GL_TEXTURE21_ARB                                  = $84D5;
GL_TEXTURE22_ARB                                  = $84D6;
GL_TEXTURE23_ARB                                  = $84D7;
GL_TEXTURE24_ARB                                  = $84D8;
GL_TEXTURE25_ARB                                  = $84D9;
GL_TEXTURE26_ARB                                  = $84DA;
GL_TEXTURE27_ARB                                  = $84DB;
GL_TEXTURE28_ARB                                  = $84DC;
GL_TEXTURE29_ARB                                  = $84DD;
GL_TEXTURE30_ARB                                  = $84DE;
GL_TEXTURE31_ARB                                  = $84DF;

// EXT_stencil_wrap
GL_INCR_WRAP_EXT                                  = $8507;
GL_DECR_WRAP_EXT                                  = $8508;

// EXT_stencil_two_side
GL_STENCIL_TEST_TWO_SIDE_EXT                      = $8910;
GL_ACTIVE_STENCIL_FACE_EXT                        = $8911;

// NV_texgen_reflection
GL_NORMAL_MAP_NV                                  = $8511;
GL_REFLECTION_MAP_NV                              = $8512;

// NV_fence
GL_ALL_COMPLETED_NV                               = $84F2;
GL_FENCE_STATUS_NV                                = $84F3;
GL_FENCE_CONDITION_NV                             = $84F4;

// NV_occlusion_query
GL_PIXEL_COUNTER_BITS_NV                          = $8864;
GL_CURRENT_OCCLUSION_QUERY_ID_NV                  = $8865;
GL_PIXEL_COUNT_NV                                 = $8866;
GL_PIXEL_COUNT_AVAILABLE_NV                       = $8867;

// NV_texture_rectangle
GL_TEXTURE_RECTANGLE_NV                           = $84F5;
GL_TEXTURE_BINDING_RECTANGLE_NV                   = $84F6;
GL_PROXY_TEXTURE_RECTANGLE_NV                     = $84F7;
GL_MAX_RECTANGLE_TEXTURE_SIZE_NV                  = $84F8;

// EXT_texture_env_combine
GL_COMBINE_EXT                                    = $8570;
GL_COMBINE_RGB_EXT                                = $8571;
GL_COMBINE_ALPHA_EXT                              = $8572;
GL_RGB_SCALE_EXT                                  = $8573;
GL_ADD_SIGNED_EXT                                 = $8574;
GL_INTERPOLATE_EXT                                = $8575;
GL_CONSTANT_EXT                                   = $8576;
GL_PRIMARY_COLOR_EXT                              = $8577;
GL_PREVIOUS_EXT                                   = $8578;
GL_SOURCE0_RGB_EXT                                = $8580;
GL_SOURCE1_RGB_EXT                                = $8581;
GL_SOURCE2_RGB_EXT                                = $8582;
GL_SOURCE0_ALPHA_EXT                              = $8588;
GL_SOURCE1_ALPHA_EXT                              = $8589;
GL_SOURCE2_ALPHA_EXT                              = $858A;
GL_OPERAND0_RGB_EXT                               = $8590;
GL_OPERAND1_RGB_EXT                               = $8591;
GL_OPERAND2_RGB_EXT                               = $8592;
GL_OPERAND0_ALPHA_EXT                             = $8598;
GL_OPERAND1_ALPHA_EXT                             = $8599;
GL_OPERAND2_ALPHA_EXT                             = $859A;

// ARB_texture_env_combine
GL_COMBINE_ARB                                    = $8570;
GL_COMBINE_RGB_ARB                                = $8571;
GL_COMBINE_ALPHA_ARB                              = $8572;
GL_SOURCE0_RGB_ARB                                = $8580;
GL_SOURCE1_RGB_ARB                                = $8581;
GL_SOURCE2_RGB_ARB                                = $8582;
GL_SOURCE0_ALPHA_ARB                              = $8588;
GL_SOURCE1_ALPHA_ARB                              = $8589;
GL_SOURCE2_ALPHA_ARB                              = $858A;
GL_OPERAND0_RGB_ARB                               = $8590;
GL_OPERAND1_RGB_ARB                               = $8591;
GL_OPERAND2_RGB_ARB                               = $8592;
GL_OPERAND0_ALPHA_ARB                             = $8598;
GL_OPERAND1_ALPHA_ARB                             = $8599;
GL_OPERAND2_ALPHA_ARB                             = $859A;
GL_RGB_SCALE_ARB                                  = $8573;
GL_ADD_SIGNED_ARB                                 = $8574;
GL_INTERPOLATE_ARB                                = $8575;
GL_SUBTRACT_ARB                                   = $84E7;
GL_CONSTANT_ARB                                   = $8576;
GL_CONSTANT_COLOR_ARB                             = $8576;
GL_PRIMARY_COLOR_ARB                              = $8577;
GL_PREVIOUS_ARB                                   = $8578;

// ARB_texture_env_dot3
GL_DOT3_RGB_ARB                                   = $86AE;
GL_DOT3_RGBA_ARB                                  = $86AF;

// ARB_vertex_program
GL_VERTEX_PROGRAM_ARB                             = $8620;
GL_VERTEX_PROGRAM_POINT_SIZE_ARB                  = $8642;
GL_VERTEX_PROGRAM_TWO_SIDE_ARB                    = $8643;
GL_COLOR_SUM_ARB                                  = $8458;
GL_PROGRAM_FORMAT_ASCII_ARB                       = $8875;
GL_VERTEX_ATTRIB_ARRAY_ENABLED_ARB                = $8622;
GL_VERTEX_ATTRIB_ARRAY_SIZE_ARB                   = $8623;
GL_VERTEX_ATTRIB_ARRAY_STRIDE_ARB                 = $8624;
GL_VERTEX_ATTRIB_ARRAY_TYPE_ARB                   = $8625;
GL_VERTEX_ATTRIB_ARRAY_NORMALIZED_ARB             = $886A;
GL_CURRENT_VERTEX_ATTRIB_ARB                      = $8626;
GL_VERTEX_ATTRIB_ARRAY_POINTER_ARB                = $8645;
GL_PROGRAM_LENGTH_ARB                             = $8627;
GL_PROGRAM_FORMAT_ARB                             = $8876;
GL_PROGRAM_BINDING_ARB                            = $8677;
GL_PROGRAM_INSTRUCTIONS_ARB                       = $88A0;
GL_MAX_PROGRAM_INSTRUCTIONS_ARB                   = $88A1;
GL_PROGRAM_NATIVE_INSTRUCTIONS_ARB                = $88A2;
GL_MAX_PROGRAM_NATIVE_INSTRUCTIONS_ARB            = $88A3;
GL_PROGRAM_TEMPORARIES_ARB                        = $88A4;
GL_MAX_PROGRAM_TEMPORARIES_ARB                    = $88A5;
GL_PROGRAM_NATIVE_TEMPORARIES_ARB                 = $88A6;
GL_MAX_PROGRAM_NATIVE_TEMPORARIES_ARB             = $88A7;
GL_PROGRAM_PARAMETERS_ARB                         = $88A8;
GL_MAX_PROGRAM_PARAMETERS_ARB                     = $88A9;
GL_PROGRAM_NATIVE_PARAMETERS_ARB                  = $88AA;
GL_MAX_PROGRAM_NATIVE_PARAMETERS_ARB              = $88AB;
GL_PROGRAM_ATTRIBS_ARB                            = $88AC;
GL_MAX_PROGRAM_ATTRIBS_ARB                        = $88AD;
GL_PROGRAM_NATIVE_ATTRIBS_ARB                     = $88AE;
GL_MAX_PROGRAM_NATIVE_ATTRIBS_ARB                 = $88AF;
GL_PROGRAM_ADDRESS_REGISTERS_ARB                  = $88B0;
GL_MAX_PROGRAM_ADDRESS_REGISTERS_ARB              = $88B1;
GL_PROGRAM_NATIVE_ADDRESS_REGISTERS_ARB           = $88B2;
GL_MAX_PROGRAM_NATIVE_ADDRESS_REGISTERS_ARB       = $88B3;
GL_MAX_PROGRAM_LOCAL_PARAMETERS_ARB               = $88B4;
GL_MAX_PROGRAM_ENV_PARAMETERS_ARB                 = $88B5;
GL_PROGRAM_UNDER_NATIVE_LIMITS_ARB                = $88B6;
GL_PROGRAM_STRING_ARB                             = $8628;
GL_PROGRAM_ERROR_POSITION_ARB                     = $864B;
GL_CURRENT_MATRIX_ARB                             = $8641;
GL_TRANSPOSE_CURRENT_MATRIX_ARB                   = $88B7;
GL_CURRENT_MATRIX_STACK_DEPTH_ARB                 = $8640;
GL_MAX_VERTEX_ATTRIBS_ARB                         = $8869;
GL_MAX_PROGRAM_MATRICES_ARB                       = $862F;
GL_MAX_PROGRAM_MATRIX_STACK_DEPTH_ARB             = $862E;
GL_PROGRAM_ERROR_STRING_ARB                       = $8874;
GL_MATRIX0_ARB                                    = $88C0;
GL_MATRIX1_ARB                                    = $88C1;
GL_MATRIX2_ARB                                    = $88C2;
GL_MATRIX3_ARB                                    = $88C3;
GL_MATRIX4_ARB                                    = $88C4;
GL_MATRIX5_ARB                                    = $88C5;
GL_MATRIX6_ARB                                    = $88C6;
GL_MATRIX7_ARB                                    = $88C7;
GL_MATRIX8_ARB                                    = $88C8;
GL_MATRIX9_ARB                                    = $88C9;
GL_MATRIX10_ARB                                   = $88CA;
GL_MATRIX11_ARB                                   = $88CB;
GL_MATRIX12_ARB                                   = $88CC;
GL_MATRIX13_ARB                                   = $88CD;
GL_MATRIX14_ARB                                   = $88CE;
GL_MATRIX15_ARB                                   = $88CF;
GL_MATRIX16_ARB                                   = $88D0;
GL_MATRIX17_ARB                                   = $88D1;
GL_MATRIX18_ARB                                   = $88D2;
GL_MATRIX19_ARB                                   = $88D3;
GL_MATRIX20_ARB                                   = $88D4;
GL_MATRIX21_ARB                                   = $88D5;
GL_MATRIX22_ARB                                   = $88D6;
GL_MATRIX23_ARB                                   = $88D7;
GL_MATRIX24_ARB                                   = $88D8;
GL_MATRIX25_ARB                                   = $88D9;
GL_MATRIX26_ARB                                   = $88DA;
GL_MATRIX27_ARB                                   = $88DB;
GL_MATRIX28_ARB                                   = $88DC;
GL_MATRIX29_ARB                                   = $88DD;
GL_MATRIX30_ARB                                   = $88DE;
GL_MATRIX31_ARB                                   = $88DF;

// ARB_vertex_buffer_object
GL_ARRAY_BUFFER_ARB                               = $8892;
GL_ELEMENT_ARRAY_BUFFER_ARB                       = $8893;
GL_ARRAY_BUFFER_BINDING_ARB                       = $8894;
GL_ELEMENT_ARRAY_BUFFER_BINDING_ARB               = $8895;
GL_VERTEX_ARRAY_BUFFER_BINDING_ARB                = $8896;
GL_NORMAL_ARRAY_BUFFER_BINDING_ARB                = $8897;
GL_COLOR_ARRAY_BUFFER_BINDING_ARB                 = $8898;
GL_INDEX_ARRAY_BUFFER_BINDING_ARB                 = $8899;
GL_TEXTURE_COORD_ARRAY_BUFFER_BINDING_ARB         = $889A;
GL_EDGE_FLAG_ARRAY_BUFFER_BINDING_ARB             = $889B;
GL_SECONDARY_COLOR_ARRAY_BUFFER_BINDING_ARB       = $889C;
GL_FOG_COORDINATE_ARRAY_BUFFER_BINDING_ARB        = $889D;
GL_WEIGHT_ARRAY_BUFFER_BINDING_ARB                = $889E;
GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING_ARB         = $889F;
GL_STREAM_DRAW_ARB                                = $88E0;
GL_STREAM_READ_ARB                                = $88E1;
GL_STREAM_COPY_ARB                                = $88E2;
GL_STATIC_DRAW_ARB                                = $88E4;
GL_STATIC_READ_ARB                                = $88E5;
GL_STATIC_COPY_ARB                                = $88E6;
GL_DYNAMIC_DRAW_ARB                               = $88E8;
GL_DYNAMIC_READ_ARB                               = $88E9;
GL_DYNAMIC_COPY_ARB                               = $88EA;
GL_READ_ONLY_ARB                                  = $88B8;
GL_WRITE_ONLY_ARB                                 = $88B9;
GL_READ_WRITE_ARB                                 = $88BA;
GL_BUFFER_SIZE_ARB                                = $8764;
GL_BUFFER_USAGE_ARB                               = $8765;
GL_BUFFER_ACCESS_ARB                              = $88BB;
GL_BUFFER_MAPPED_ARB                              = $88BC;
GL_BUFFER_MAP_POINTER_ARB                         = $88BD;

// ARB_shader_objects
GL_PROGRAM_OBJECT_ARB                             = $8B40;
GL_OBJECT_TYPE_ARB                                = $8B4E;
GL_OBJECT_SUBTYPE_ARB                             = $8B4F;
GL_OBJECT_DELETE_STATUS_ARB                       = $8B80;
GL_OBJECT_COMPILE_STATUS_ARB                      = $8B81;
GL_OBJECT_LINK_STATUS_ARB                         = $8B82;
GL_OBJECT_VALIDATE_STATUS_ARB                     = $8B83;
GL_OBJECT_INFO_LOG_LENGTH_ARB                     = $8B84;
GL_OBJECT_ATTACHED_OBJECTS_ARB                    = $8B85;
GL_OBJECT_ACTIVE_UNIFORMS_ARB                     = $8B86;
GL_OBJECT_ACTIVE_UNIFORM_MAX_LENGTH_ARB           = $8B87;
GL_OBJECT_SHADER_SOURCE_LENGTH_ARB                = $8B88;
GL_SHADER_OBJECT_ARB                              = $8B48;
GL_FLOAT_VEC2_ARB                                 = $8B50;
GL_FLOAT_VEC3_ARB                                 = $8B51;
GL_FLOAT_VEC4_ARB                                 = $8B52;
GL_INT_VEC2_ARB                                   = $8B53;
GL_INT_VEC3_ARB                                   = $8B54;
GL_INT_VEC4_ARB                                   = $8B55;
GL_BOOL_ARB                                       = $8B56;
GL_BOOL_VEC2_ARB                                  = $8B57;
GL_BOOL_VEC3_ARB                                  = $8B58;
GL_BOOL_VEC4_ARB                                  = $8B59;
GL_FLOAT_MAT2_ARB                                 = $8B5A;
GL_FLOAT_MAT3_ARB                                 = $8B5B;
GL_FLOAT_MAT4_ARB                                 = $8B5C;

// ARB_vertex_shader
GL_VERTEX_SHADER_ARB                              = $8B31;
GL_MAX_VERTEX_UNIFORM_COMPONENTS_ARB              = $8B4A;
GL_MAX_VARYING_FLOATS_ARB                         = $8B4B;
GL_MAX_VERTEX_TEXTURE_IMAGE_UNITS_ARB             = $8B4C;
GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS_ARB           = $8B4D;
GL_OBJECT_ACTIVE_ATTRIBUTES_ARB                   = $8B89;
GL_OBJECT_ACTIVE_ATTRIBUTE_MAX_LENGTH_ARB         = $8B8A;

// ARB_fragment_shader
GL_FRAGMENT_SHADER_ARB                            = $8B30;
GL_MAX_FRAGMENT_UNIFORM_COMPONENTS_ARB            = $8B49;

// ARB_fragment_program
GL_FRAGMENT_PROGRAM_ARB                           = $8804;

// NV_texture_env_combine4
GL_COMBINE4_NV                                    = $8503;
GL_SOURCE3_RGB_NV                                 = $8583;
GL_SOURCE3_ALPHA_NV                               = $858B;
GL_OPERAND3_RGB_NV                                = $8593;
GL_OPERAND3_ALPHA_NV                              = $859B;

GL_BLEND_EQUATION                                 = $8009;
GL_TABLE_TOO_LARGE                                = $8031;
GL_UNSIGNED_BYTE_3_3_2                            = $8032;
GL_UNSIGNED_SHORT_4_4_4_4                         = $8033;
GL_UNSIGNED_SHORT_5_5_5_1                         = $8034;
GL_UNSIGNED_INT_8_8_8_8                           = $8035;
GL_UNSIGNED_INT_10_10_10_2                        = $8036;
GL_UNSIGNED_BYTE_2_3_3_REV                        = $8362;
GL_UNSIGNED_SHORT_5_6_5                           = $8363;
GL_UNSIGNED_SHORT_5_6_5_REV                       = $8364;
GL_UNSIGNED_SHORT_4_4_4_4_REV                     = $8365;
GL_UNSIGNED_SHORT_1_5_5_5_REV                     = $8366;
GL_UNSIGNED_INT_8_8_8_8_REV                       = $8367;
GL_UNSIGNED_INT_2_10_10_10_REV                    = $8368;

// GL_ARB_transpose_matrix
GL_TRANSPOSE_MODELVIEW_MATRIX_ARB                 = $84E3;
GL_TRANSPOSE_PROJECTION_MATRIX_ARB                = $84E4;
GL_TRANSPOSE_TEXTURE_MATRIX_ARB                   = $84E5;
GL_TRANSPOSE_COLOR_MATRIX_ARB                     = $84E6;

// GL_ARB_multisample
GL_MULTISAMPLE_ARB                                = $809D;
GL_SAMPLE_ALPHA_TO_COVERAGE_ARB                   = $809E;
GL_SAMPLE_ALPHA_TO_ONE_ARB                        = $809F;
GL_SAMPLE_COVERAGE_ARB                            = $80A0;
GL_SAMPLE_BUFFERS_ARB                             = $80A8;
GL_SAMPLES_ARB                                    = $80A9;
GL_SAMPLE_COVERAGE_VALUE_ARB                      = $80AA;
GL_SAMPLE_COVERAGE_INVERT_ARB                     = $80AB;
GL_MULTISAMPLE_BIT_ARB                            = $20000000;
GLX_SAMPLE_BUFFERS_ARB                            = 100000;
GLX_SAMPLES_ARB                                   = 100001;
WGL_SAMPLE_BUFFERS_ARB                            = $2041;
WGL_SAMPLES_ARB                                   = $2042;

// GL_ARB_depth_texture
GL_DEPTH_COMPONENT16_ARB                          = $81A5;
GL_DEPTH_COMPONENT24_ARB                          = $81A6;
GL_DEPTH_COMPONENT32_ARB                          = $81A7;
GL_TEXTURE_DEPTH_SIZE_ARB                         = $884A;
GL_DEPTH_TEXTURE_MODE_ARB                         = $884B;

// GL_ARB_shadow
GL_TEXTURE_COMPARE_MODE_ARB                       = $884C;
GL_TEXTURE_COMPARE_FUNC_ARB                       = $884D;
GL_COMPARE_R_TO_TEXTURE_ARB                       = $884E;

// GL_ARB_texture_cube_map
GL_NORMAL_MAP_ARB                                 = $8511;
GL_REFLECTION_MAP_ARB                             = $8512;
GL_TEXTURE_CUBE_MAP_ARB                           = $8513;
GL_TEXTURE_BINDING_CUBE_MAP_ARB                   = $8514;
GL_TEXTURE_CUBE_MAP_POSITIVE_X_ARB                = $8515;
GL_TEXTURE_CUBE_MAP_NEGATIVE_X_ARB                = $8516;
GL_TEXTURE_CUBE_MAP_POSITIVE_Y_ARB                = $8517;
GL_TEXTURE_CUBE_MAP_NEGATIVE_Y_ARB                = $8518;
GL_TEXTURE_CUBE_MAP_POSITIVE_Z_ARB                = $8519;
GL_TEXTURE_CUBE_MAP_NEGATIVE_Z_ARB                = $851A;
GL_PROXY_TEXTURE_CUBE_MAP_ARB                     = $851B;
GL_MAX_CUBE_MAP_TEXTURE_SIZE_ARB                  = $851C;

// GL_ARB_texture_border_clamp
GL_CLAMP_TO_BORDER_ARB                            = $812D;

// GL_ARB_texture_compression
GL_COMPRESSED_ALPHA_ARB                           = $84E9;
GL_COMPRESSED_LUMINANCE_ARB                       = $84EA;
GL_COMPRESSED_LUMINANCE_ALPHA_ARB                 = $84EB;
GL_COMPRESSED_INTENSITY_ARB                       = $84EC;
GL_COMPRESSED_RGB_ARB                             = $84ED;
GL_COMPRESSED_RGBA_ARB                            = $84EE;
GL_TEXTURE_COMPRESSION_HINT_ARB                   = $84EF;
GL_TEXTURE_COMPRESSED_IMAGE_SIZE_ARB              = $86A0;
GL_TEXTURE_COMPRESSED_ARB                         = $86A1;
GL_NUM_COMPRESSED_TEXTURE_FORMATS_ARB             = $86A2;
GL_COMPRESSED_TEXTURE_FORMATS_ARB                 = $86A3;

// GL_ARB_vertex_blend
GL_MAX_VERTEX_UNITS_ARB                           = $86A4;
GL_ACTIVE_VERTEX_UNITS_ARB                        = $86A5;
GL_WEIGHT_SUM_UNITY_ARB                           = $86A6;
GL_VERTEX_BLEND_ARB                               = $86A7;
GL_CURRENT_WEIGHT_ARB                             = $86A8;
GL_WEIGHT_ARRAY_TYPE_ARB                          = $86A9;
GL_WEIGHT_ARRAY_STRIDE_ARB                        = $86AA;
GL_WEIGHT_ARRAY_SIZE_ARB                          = $86AB;
GL_WEIGHT_ARRAY_POINTER_ARB                       = $86AC;
GL_WEIGHT_ARRAY_ARB                               = $86AD;
GL_MODELVIEW0_ARB                                 = $1700;
GL_MODELVIEW1_ARB                                 = $850A;
GL_MODELVIEW2_ARB                                = $8722;
GL_MODELVIEW3_ARB                                = $8723;
GL_MODELVIEW4_ARB                                = $8724;
GL_MODELVIEW5_ARB                                = $8725;
GL_MODELVIEW6_ARB                                = $8726;
GL_MODELVIEW7_ARB                                = $8727;
GL_MODELVIEW8_ARB                                = $8728;
GL_MODELVIEW9_ARB                                = $8729;
GL_MODELVIEW10_ARB                               = $872A;
GL_MODELVIEW11_ARB                               = $872B;
GL_MODELVIEW12_ARB                               = $872C;
GL_MODELVIEW13_ARB                               = $872D;
GL_MODELVIEW14_ARB                               = $872E;
GL_MODELVIEW15_ARB                               = $872F;
GL_MODELVIEW16_ARB                               = $8730;
GL_MODELVIEW17_ARB                               = $8731;
GL_MODELVIEW18_ARB                               = $8732;
GL_MODELVIEW19_ARB                               = $8733;
GL_MODELVIEW20_ARB                               = $8734;
GL_MODELVIEW21_ARB                               = $8735;
GL_MODELVIEW22_ARB                               = $8736;
GL_MODELVIEW23_ARB                               = $8737;
GL_MODELVIEW24_ARB                               = $8738;
GL_MODELVIEW25_ARB                               = $8739;
GL_MODELVIEW26_ARB                               = $873A;
GL_MODELVIEW27_ARB                               = $873B;
GL_MODELVIEW28_ARB                               = $873C;
GL_MODELVIEW29_ARB                               = $873D;
GL_MODELVIEW30_ARB                               = $873E;
GL_MODELVIEW31_ARB                               = $873F;

// GL_SGIS_texture_lod
GL_TEXTURE_MIN_LOD_SGIS                          = $813A;
GL_TEXTURE_MAX_LOD_SGIS                          = $813B;
GL_TEXTURE_BASE_LEVEL_SGIS                       = $813C;
GL_TEXTURE_MAX_LEVEL_SGIS                        = $813D;

// GL_SGIS_multisample
GL_MULTISAMPLE_SGIS                              = $809D;
GL_SAMPLE_ALPHA_TO_MASK_SGIS                     = $809E;
GL_SAMPLE_ALPHA_TO_ONE_SGIS                      = $809F;
GL_SAMPLE_MASK_SGIS                              = $80A0;
GL_1PASS_SGIS                                    = $80A1;
GL_2PASS_0_SGIS                                  = $80A2;
GL_2PASS_1_SGIS                                  = $80A3;
GL_4PASS_0_SGIS                                  = $80A4;
GL_4PASS_1_SGIS                                  = $80A5;
GL_4PASS_2_SGIS                                  = $80A6;
GL_4PASS_3_SGIS                                  = $80A7;
GL_SAMPLE_BUFFERS_SGIS                           = $80A8;
GL_SAMPLES_SGIS                                  = $80A9;
GL_SAMPLE_MASK_VALUE_SGIS                        = $80AA;
GL_SAMPLE_MASK_INVERT_SGIS                       = $80AB;
GL_SAMPLE_PATTERN_SGIS                           = $80AC;

// GL_SGIS_generate_mipmap
GL_GENERATE_MIPMAP_SGIS                          = $8191;
GL_GENERATE_MIPMAP_HINT_SGIS                     = $8192;

// GL_SGIX_shadow
GL_TEXTURE_COMPARE_SGIX                          = $819A;
GL_TEXTURE_COMPARE_OPERATOR_SGIX                 = $819B;
GL_TEXTURE_LEQUAL_R_SGIX                         = $819C;
GL_TEXTURE_GEQUAL_R_SGIX                         = $819D;

// GL_SGIS_texture_edge_clamp
GL_CLAMP_TO_EDGE_SGIS                            = $812F;

// GL_SGIS_texture_border_clamp
GL_CLAMP_TO_BORDER_SGIS                          = $812D;

// GL_EXT_paletted_texture
GL_TEXTURE_INDEX_SIZE_EXT                        = $80ED;

// GL_SGIX_shadow_ambient
GL_SHADOW_AMBIENT_SGIX                           = $80BF;

// GL_IBM_rasterpos_clip
GL_RASTER_POSITION_UNCLIPPED_IBM                 = $19262;

// GL_EXT_draw_range_elements
GL_MAX_ELEMENTS_VERTICES_EXT                     = $80E8;
GL_MAX_ELEMENTS_INDICES_EXT                      = $80E9;

// GL_HP_occlusion_test
GL_OCCLUSION_TEST_HP                             = $8165;
GL_OCCLUSION_TEST_RESULT_HP                      = $8166;

// GL_EXT_separate_specular_color
GL_LIGHT_MODEL_COLOR_CONTROL_EXT                 = $81F8;
GL_SINGLE_COLOR_EXT                              = $81F9;
GL_SEPARATE_SPECULAR_COLOR_EXT                   = $81FA;

// GL_EXT_secondary_color
GL_COLOR_SUM_EXT                                 = $8458;
GL_CURRENT_SECONDARY_COLOR_EXT                   = $8459;
GL_SECONDARY_COLOR_ARRAY_SIZE_EXT                = $845A;
GL_SECONDARY_COLOR_ARRAY_TYPE_EXT                = $845B;
GL_SECONDARY_COLOR_ARRAY_STRIDE_EXT              = $845C;
GL_SECONDARY_COLOR_ARRAY_POINTER_EXT             = $845D;
GL_SECONDARY_COLOR_ARRAY_EXT                     = $845E;

// GL_EXT_fog_coord
GL_FOG_COORDINATE_SOURCE_EXT                     = $8450;
GL_FOG_COORDINATE_EXT                            = $8451;
GL_FRAGMENT_DEPTH_EXT                            = $8452;
GL_CURRENT_FOG_COORDINATE_EXT                    = $8453;
GL_FOG_COORDINATE_ARRAY_TYPE_EXT                 = $8454;
GL_FOG_COORDINATE_ARRAY_STRIDE_EXT               = $8455;
GL_FOG_COORDINATE_ARRAY_POINTER_EXT              = $8456;
GL_FOG_COORDINATE_ARRAY_EXT                      = $8457;

// GL_EXT_texture_env_combine
GL_SOURCE3_RGB_EXT                               = $8583;
GL_SOURCE4_RGB_EXT                               = $8584;
GL_SOURCE5_RGB_EXT                               = $8585;
GL_SOURCE6_RGB_EXT                               = $8586;
GL_SOURCE7_RGB_EXT                               = $8587;
GL_SOURCE3_ALPHA_EXT                             = $858B;
GL_SOURCE4_ALPHA_EXT                             = $858C;
GL_SOURCE5_ALPHA_EXT                             = $858D;
GL_SOURCE6_ALPHA_EXT                             = $858E;
GL_SOURCE7_ALPHA_EXT                             = $858F;
GL_OPERAND3_RGB_EXT                              = $8593;
GL_OPERAND4_RGB_EXT                              = $8594;
GL_OPERAND5_RGB_EXT                              = $8595;
GL_OPERAND6_RGB_EXT                              = $8596;
GL_OPERAND7_RGB_EXT                              = $8597;
GL_OPERAND3_ALPHA_EXT                            = $859B;
GL_OPERAND4_ALPHA_EXT                            = $859C;
GL_OPERAND5_ALPHA_EXT                            = $859D;
GL_OPERAND6_ALPHA_EXT                            = $859E;
GL_OPERAND7_ALPHA_EXT                            = $859F;

// GL_EXT_blend_func_separate
GL_BLEND_DST_RGB_EXT                             = $80C8;
GL_BLEND_SRC_RGB_EXT                             = $80C9;
GL_BLEND_DST_ALPHA_EXT                           = $80CA;
GL_BLEND_SRC_ALPHA_EXT                           = $80CB;

// GL_EXT_texture_cube_map
GL_NORMAL_MAP_EXT                                = $8511;
GL_REFLECTION_MAP_EXT                            = $8512;
GL_TEXTURE_CUBE_MAP_EXT                          = $8513;
GL_TEXTURE_BINDING_CUBE_MAP_EXT                  = $8514;
GL_TEXTURE_CUBE_MAP_POSITIVE_X_EXT               = $8515;
GL_TEXTURE_CUBE_MAP_NEGATIVE_X_EXT               = $8516;
GL_TEXTURE_CUBE_MAP_POSITIVE_Y_EXT               = $8517;
GL_TEXTURE_CUBE_MAP_NEGATIVE_Y_EXT               = $8518;
GL_TEXTURE_CUBE_MAP_POSITIVE_Z_EXT               = $8519;
GL_TEXTURE_CUBE_MAP_NEGATIVE_Z_EXT               = $851A;
GL_PROXY_TEXTURE_CUBE_MAP_EXT                    = $851B;
GL_MAX_CUBE_MAP_TEXTURE_SIZE_EXT                 = $851C;

// GL_EXT_texture_lod_bias
GL_MAX_TEXTURE_LOD_BIAS_EXT                      = $84FD;
GL_TEXTURE_FILTER_CONTROL_EXT                    = $8500;
GL_TEXTURE_LOD_BIAS_EXT                          = $8501;

// GL_EXT_texture_filter_anisotropic
GL_TEXTURE_MAX_ANISOTROPY_EXT                    = $84FE;
GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT                = $84FF;

// GL_NV_light_max_exponent
GL_MAX_SHININESS_NV                              = $8504;
GL_MAX_SPOT_EXPONENT_NV                          = $8505;

// GL_NV_vertex_array_range
GL_VERTEX_ARRAY_RANGE_NV                         = $851D;
GL_VERTEX_ARRAY_RANGE_LENGTH_NV                  = $851E;
GL_VERTEX_ARRAY_RANGE_VALID_NV                   = $851F;
GL_MAX_VERTEX_ARRAY_RANGE_ELEMENT_NV             = $8520;
GL_VERTEX_ARRAY_RANGE_POINTER_NV                 = $8521;

// GL_NV_vertex_array_range2
GL_VERTEX_ARRAY_RANGE_WITHOUT_FLUSH_NV          = $8533;

// GL_NV_register_combiners
GL_REGISTER_COMBINERS_NV                         = $8522;
GL_VARIABLE_A_NV                                 = $8523;
GL_VARIABLE_B_NV                                 = $8524;
GL_VARIABLE_C_NV                                 = $8525;
GL_VARIABLE_D_NV                                 = $8526;
GL_VARIABLE_E_NV                                 = $8527;
GL_VARIABLE_F_NV                                 = $8528;
GL_VARIABLE_G_NV                                 = $8529;
GL_CONSTANT_COLOR0_NV                            = $852A;
GL_CONSTANT_COLOR1_NV                            = $852B;
GL_PRIMARY_COLOR_NV                              = $852C;
GL_SECONDARY_COLOR_NV                            = $852D;
GL_SPARE0_NV                                     = $852E;
GL_SPARE1_NV                                     = $852F;
GL_DISCARD_NV                                    = $8530;
GL_E_TIMES_F_NV                                  = $8531;
GL_SPARE0_PLUS_SECONDARY_COLOR_NV                = $8532;
GL_UNSIGNED_IDENTITY_NV                          = $8536;
GL_UNSIGNED_INVERT_NV                            = $8537;
GL_EXPAND_NORMAL_NV                              = $8538;
GL_EXPAND_NEGATE_NV                              = $8539;
GL_HALF_BIAS_NORMAL_NV                           = $853A;
GL_HALF_BIAS_NEGATE_NV                           = $853B;
GL_SIGNED_IDENTITY_NV                            = $853C;
GL_SIGNED_NEGATE_NV                              = $853D;
GL_SCALE_BY_TWO_NV                               = $853E;
GL_SCALE_BY_FOUR_NV                              = $853F;
GL_SCALE_BY_ONE_HALF_NV                          = $8540;
GL_BIAS_BY_NEGATIVE_ONE_HALF_NV                  = $8541;
GL_COMBINER_INPUT_NV                             = $8542;
GL_COMBINER_MAPPING_NV                           = $8543;
GL_COMBINER_COMPONENT_USAGE_NV                   = $8544;
GL_COMBINER_AB_DOT_PRODUCT_NV                    = $8545;
GL_COMBINER_CD_DOT_PRODUCT_NV                    = $8546;
GL_COMBINER_MUX_SUM_NV                           = $8547;
GL_COMBINER_SCALE_NV                             = $8548;
GL_COMBINER_BIAS_NV                              = $8549;
GL_COMBINER_AB_OUTPUT_NV                         = $854A;
GL_COMBINER_CD_OUTPUT_NV                         = $854B;
GL_COMBINER_SUM_OUTPUT_NV                        = $854C;
GL_MAX_GENERAL_COMBINERS_NV                      = $854D;
GL_NUM_GENERAL_COMBINERS_NV                      = $854E;
GL_COLOR_SUM_CLAMP_NV                            = $854F;
GL_COMBINER0_NV                                  = $8550;
GL_COMBINER1_NV                                  = $8551;
GL_COMBINER2_NV                                  = $8552;
GL_COMBINER3_NV                                  = $8553;
GL_COMBINER4_NV                                  = $8554;
GL_COMBINER5_NV                                  = $8555;
GL_COMBINER6_NV                                  = $8556;
GL_COMBINER7_NV                                  = $8557;

// GL_NV_fog_distance
GL_FOG_DISTANCE_MODE_NV                          = $855A;
GL_EYE_RADIAL_NV                                 = $855B;
GL_EYE_PLANE_ABSOLUTE_NV                         = $855C;

// GL_EXT_texture_compression_s3tc
GL_COMPRESSED_RGB_S3TC_DXT1_EXT                  = $83F0;
GL_COMPRESSED_RGBA_S3TC_DXT1_EXT                 = $83F1;
GL_COMPRESSED_RGBA_S3TC_DXT3_EXT                 = $83F2;
GL_COMPRESSED_RGBA_S3TC_DXT5_EXT                 = $83F3;

// GL_3DFX_texture_compression_FXT1
GL_COMPRESSED_RGB_FXT1_3DFX                      = $86B0;
GL_COMPRESSED_RGBA_FXT1_3DFX                     = $86B1;

// GL_3DFX_multisample
GL_MULTISAMPLE_3DFX                              = $86B2;
GL_SAMPLE_BUFFERS_3DFX                           = $86B3;
GL_SAMPLES_3DFX                                  = $86B4;
GL_MULTISAMPLE_BIT_3DFX                          = $20000000;

// GL_EXT_multisample
GL_MULTISAMPLE_EXT                               = $809D;
GL_SAMPLE_ALPHA_TO_MASK_EXT                      = $809E;
GL_SAMPLE_ALPHA_TO_ONE_EXT                       = $809F;
GL_SAMPLE_MASK_EXT                               = $80A0;
GL_1PASS_EXT                                     = $80A1;
GL_2PASS_0_EXT                                   = $80A2;
GL_2PASS_1_EXT                                   = $80A3;
GL_4PASS_0_EXT                                   = $80A4;
GL_4PASS_1_EXT                                   = $80A5;
GL_4PASS_2_EXT                                   = $80A6;
GL_4PASS_3_EXT                                   = $80A7;
GL_SAMPLE_BUFFERS_EXT                            = $80A8;
GL_SAMPLES_EXT                                   = $80A9;
GL_SAMPLE_MASK_VALUE_EXT                         = $80AA;
GL_SAMPLE_MASK_INVERT_EXT                        = $80AB;
GL_SAMPLE_PATTERN_EXT                            = $80AC;

// GL_EXT_clip_volume_hint
GL_CLIP_VOLUME_CLIPPING_HINT_EXT                 = $80F0;

// GL_SGIS_texture_color_mask
GL_TEXTURE_COLOR_WRITEMASK_SGIS                  = $81EF;

// GL_NV_vertex_program
GL_VERTEX_PROGRAM_NV                             = $8620;
GL_VERTEX_STATE_PROGRAM_NV                       = $8621;
GL_ATTRIB_ARRAY_SIZE_NV                          = $8623;
GL_ATTRIB_ARRAY_STRIDE_NV                        = $8624;
GL_ATTRIB_ARRAY_TYPE_NV                          = $8625;
GL_CURRENT_ATTRIB_NV                             = $8626;
GL_PROGRAM_LENGTH_NV                             = $8627;
GL_PROGRAM_STRING_NV                             = $8628;
GL_MODELVIEW_PROJECTION_NV                       = $8629;
GL_IDENTITY_NV                                   = $862A;
GL_INVERSE_NV                                    = $862B;
GL_TRANSPOSE_NV                                  = $862C;
GL_INVERSE_TRANSPOSE_NV                          = $862D;
GL_MAX_TRACK_MATRIX_STACK_DEPTH_NV               = $862E;
GL_MAX_TRACK_MATRICES_NV                         = $862F;
GL_MATRIX0_NV                                    = $8630;
GL_MATRIX1_NV                                    = $8631;
GL_MATRIX2_NV                                    = $8632;
GL_MATRIX3_NV                                    = $8633;
GL_MATRIX4_NV                                    = $8634;
GL_MATRIX5_NV                                    = $8635;
GL_MATRIX6_NV                                    = $8636;
GL_MATRIX7_NV                                    = $8637;
GL_CURRENT_MATRIX_STACK_DEPTH_NV                 = $8640;
GL_CURRENT_MATRIX_NV                             = $8641;
GL_VERTEX_PROGRAM_POINT_SIZE_NV                  = $8642;
GL_VERTEX_PROGRAM_TWO_SIDE_NV                    = $8643;
GL_PROGRAM_PARAMETER_NV                          = $8644;
GL_ATTRIB_ARRAY_POINTER_NV                       = $8645;
GL_PROGRAM_TARGET_NV                             = $8646;
GL_PROGRAM_RESIDENT_NV                           = $8647;
GL_TRACK_MATRIX_NV                               = $8648;
GL_TRACK_MATRIX_TRANSFORM_NV                     = $8649;
GL_VERTEX_PROGRAM_BINDING_NV                     = $864A;
GL_PROGRAM_ERROR_POSITION_NV                     = $864B;
GL_VERTEX_ATTRIB_ARRAY0_NV                       = $8650;
GL_VERTEX_ATTRIB_ARRAY1_NV                       = $8651;
GL_VERTEX_ATTRIB_ARRAY2_NV                       = $8652;
GL_VERTEX_ATTRIB_ARRAY3_NV                       = $8653;
GL_VERTEX_ATTRIB_ARRAY4_NV                       = $8654;
GL_VERTEX_ATTRIB_ARRAY5_NV                       = $8655;
GL_VERTEX_ATTRIB_ARRAY6_NV                       = $8656;
GL_VERTEX_ATTRIB_ARRAY7_NV                       = $8657;
GL_VERTEX_ATTRIB_ARRAY8_NV                       = $8658;
GL_VERTEX_ATTRIB_ARRAY9_NV                       = $8659;
GL_VERTEX_ATTRIB_ARRAY10_NV                      = $865A;
GL_VERTEX_ATTRIB_ARRAY11_NV                      = $865B;
GL_VERTEX_ATTRIB_ARRAY12_NV                      = $865C;
GL_VERTEX_ATTRIB_ARRAY13_NV                      = $865D;
GL_VERTEX_ATTRIB_ARRAY14_NV                      = $865E;
GL_VERTEX_ATTRIB_ARRAY15_NV                      = $865F;
GL_MAP1_VERTEX_ATTRIB0_4_NV                      = $8660;
GL_MAP1_VERTEX_ATTRIB1_4_NV                      = $8661;
GL_MAP1_VERTEX_ATTRIB2_4_NV                      = $8662;
GL_MAP1_VERTEX_ATTRIB3_4_NV                      = $8663;
GL_MAP1_VERTEX_ATTRIB4_4_NV                      = $8664;
GL_MAP1_VERTEX_ATTRIB5_4_NV                      = $8665;
GL_MAP1_VERTEX_ATTRIB6_4_NV                      = $8666;
GL_MAP1_VERTEX_ATTRIB7_4_NV                      = $8667;
GL_MAP1_VERTEX_ATTRIB8_4_NV                      = $8668;
GL_MAP1_VERTEX_ATTRIB9_4_NV                      = $8669;
GL_MAP1_VERTEX_ATTRIB10_4_NV                     = $866A;
GL_MAP1_VERTEX_ATTRIB11_4_NV                     = $866B;
GL_MAP1_VERTEX_ATTRIB12_4_NV                     = $866C;
GL_MAP1_VERTEX_ATTRIB13_4_NV                     = $866D;
GL_MAP1_VERTEX_ATTRIB14_4_NV                     = $866E;
GL_MAP1_VERTEX_ATTRIB15_4_NV                     = $866F;
GL_MAP2_VERTEX_ATTRIB0_4_NV                      = $8670;
GL_MAP2_VERTEX_ATTRIB1_4_NV                      = $8671;
GL_MAP2_VERTEX_ATTRIB2_4_NV                      = $8672;
GL_MAP2_VERTEX_ATTRIB3_4_NV                      = $8673;
GL_MAP2_VERTEX_ATTRIB4_4_NV                      = $8674;
GL_MAP2_VERTEX_ATTRIB5_4_NV                      = $8675;
GL_MAP2_VERTEX_ATTRIB6_4_NV                      = $8676;
GL_MAP2_VERTEX_ATTRIB7_4_NV                      = $8677;
GL_MAP2_VERTEX_ATTRIB8_4_NV                      = $8678;
GL_MAP2_VERTEX_ATTRIB9_4_NV                      = $8679;
GL_MAP2_VERTEX_ATTRIB10_4_NV                     = $867A;
GL_MAP2_VERTEX_ATTRIB11_4_NV                     = $867B;
GL_MAP2_VERTEX_ATTRIB12_4_NV                     = $867C;
GL_MAP2_VERTEX_ATTRIB13_4_NV                     = $867D;
GL_MAP2_VERTEX_ATTRIB14_4_NV                     = $867E;
GL_MAP2_VERTEX_ATTRIB15_4_NV                     = $867F;

// NV_multisample_filter_hint
GL_MULTISAMPLE_FILTER_HINT_NV                    = $8534;

// WGL_ARB_pixel_format
WGL_NUMBER_PIXEL_FORMATS_ARB                     = $2000;
WGL_DRAW_TO_WINDOW_ARB                           = $2001;
WGL_DRAW_TO_BITMAP_ARB                           = $2002;
WGL_ACCELERATION_ARB                             = $2003;
WGL_NEED_PALETTE_ARB                             = $2004;
WGL_NEED_SYSTEM_PALETTE_ARB                      = $2005;
WGL_SWAP_LAYER_BUFFERS_ARB                       = $2006;
WGL_SWAP_METHOD_ARB                              = $2007;
WGL_NUMBER_OVERLAYS_ARB                          = $2008;
WGL_NUMBER_UNDERLAYS_ARB                         = $2009;
WGL_TRANSPARENT_ARB                              = $200A;
WGL_TRANSPARENT_RED_VALUE_ARB                    = $2037;
WGL_TRANSPARENT_GREEN_VALUE_ARB                  = $2038;
WGL_TRANSPARENT_BLUE_VALUE_ARB                   = $2039;
WGL_TRANSPARENT_ALPHA_VALUE_ARB                  = $203A;
WGL_TRANSPARENT_INDEX_VALUE_ARB                  = $203B;
WGL_SHARE_DEPTH_ARB                              = $200C;
WGL_SHARE_STENCIL_ARB                            = $200D;
WGL_SHARE_ACCUM_ARB                              = $200E;
WGL_SUPPORT_GDI_ARB                              = $200F;
WGL_SUPPORT_OPENGL_ARB                           = $2010;
WGL_DOUBLE_BUFFER_ARB                            = $2011;
WGL_STEREO_ARB                                   = $2012;
WGL_PIXEL_TYPE_ARB                               = $2013;
WGL_COLOR_BITS_ARB                               = $2014;
WGL_RED_BITS_ARB                                 = $2015;
WGL_RED_SHIFT_ARB                                = $2016;
WGL_GREEN_BITS_ARB                               = $2017;
WGL_GREEN_SHIFT_ARB                              = $2018;
WGL_BLUE_BITS_ARB                                = $2019;
WGL_BLUE_SHIFT_ARB                               = $201A;
WGL_ALPHA_BITS_ARB                               = $201B;
WGL_ALPHA_SHIFT_ARB                              = $201C;
WGL_ACCUM_BITS_ARB                               = $201D;
WGL_ACCUM_RED_BITS_ARB                           = $201E;
WGL_ACCUM_GREEN_BITS_ARB                         = $201F;
WGL_ACCUM_BLUE_BITS_ARB                          = $2020;
WGL_ACCUM_ALPHA_BITS_ARB                         = $2021;
WGL_DEPTH_BITS_ARB                               = $2022;
WGL_STENCIL_BITS_ARB                             = $2023;
WGL_AUX_BUFFERS_ARB                              = $2024;
WGL_NO_ACCELERATION_ARB                          = $2025;
WGL_GENERIC_ACCELERATION_ARB                     = $2026;
WGL_FULL_ACCELERATION_ARB                        = $2027;
WGL_SWAP_EXCHANGE_ARB                            = $2028;
WGL_SWAP_COPY_ARB                                = $2029;
WGL_SWAP_UNDEFINED_ARB                           = $202A;
WGL_TYPE_RGBA_ARB                                = $202B;
WGL_TYPE_COLORINDEX_ARB                          = $202C;

// WGL_NV_float_buffer
WGL_FLOAT_COMPONENTS_NV                          = $20B0;
WGL_BIND_TO_TEXTURE_RECTANGLE_FLOAT_R_NV         = $20B1;
WGL_BIND_TO_TEXTURE_RECTANGLE_FLOAT_RG_NV        = $20B2;
WGL_BIND_TO_TEXTURE_RECTANGLE_FLOAT_RGB_NV       = $20B3;
WGL_BIND_TO_TEXTURE_RECTANGLE_FLOAT_RGBA_NV      = $20B4;
WGL_TEXTURE_FLOAT_R_NV                           = $20B5;
WGL_TEXTURE_FLOAT_RG_NV                          = $20B6;
WGL_TEXTURE_FLOAT_RGB_NV                         = $20B7;
WGL_TEXTURE_FLOAT_RGBA_NV                        = $20B8;

// GL_NV_float_buffer
GL_FLOAT_R_NV                                    = $8880;
GL_FLOAT_RG_NV                                   = $8881;
GL_FLOAT_RGB_NV                                  = $8882;
GL_FLOAT_RGBA_NV                                 = $8883;
GL_FLOAT_R16_NV                                  = $8884;
GL_FLOAT_R32_NV                                  = $8885;
GL_FLOAT_RG16_NV                                 = $8886;
GL_FLOAT_RG32_NV                                 = $8887;
GL_FLOAT_RGB16_NV                                = $8888;
GL_FLOAT_RGB32_NV                                = $8889;
GL_FLOAT_RGBA16_NV                               = $888A;
GL_FLOAT_RGBA32_NV                               = $888B;
GL_TEXTURE_FLOAT_COMPONENTS_NV                   = $888C;
GL_FLOAT_CLEAR_COLOR_VALUE_NV                    = $888D;
GL_FLOAT_RGBA_MODE_NV                            = $888E;

// WGL_ATI_pixel_format_float
WGL_TYPE_RGBA_FLOAT_ATI                          = $21A0;
GL_TYPE_RGBA_FLOAT_ATI                           = $8820;
GL_COLOR_CLEAR_UNCLAMPED_VALUE_ATI               = $8835;

// GL_ATI_texture_float
GL_RGBA_FLOAT32_ATI                              = $8814;
GL_RGB_FLOAT32_ATI                               = $8815;
GL_ALPHA_FLOAT32_ATI                             = $8816;
GL_INTENSITY_FLOAT32_ATI                         = $8817;
GL_LUMINANCE_FLOAT32_ATI                         = $8818;
GL_LUMINANCE_ALPHA_FLOAT32_ATI                   = $8819;
GL_RGBA_FLOAT16_ATI                              = $881A;
GL_RGB_FLOAT16_ATI                               = $881B;
GL_ALPHA_FLOAT16_ATI                             = $881C;
GL_INTENSITY_FLOAT16_ATI                         = $881D;
GL_LUMINANCE_FLOAT16_ATI                         = $881E;
GL_LUMINANCE_ALPHA_FLOAT16_ATI                   = $881F;

// GL_ATI_draw_buffers
GL_MAX_DRAW_BUFFERS_ATI                          = $8824;
GL_DRAW_BUFFER0_ATI                              = $8825;
GL_DRAW_BUFFER1_ATI                              = $8826;
GL_DRAW_BUFFER2_ATI                              = $8827;
GL_DRAW_BUFFER3_ATI                              = $8828;
GL_DRAW_BUFFER4_ATI                              = $8829;
GL_DRAW_BUFFER5_ATI                              = $882A;
GL_DRAW_BUFFER6_ATI                              = $882B;
GL_DRAW_BUFFER7_ATI                              = $882C;
GL_DRAW_BUFFER8_ATI                              = $882D;
GL_DRAW_BUFFER9_ATI                              = $882E;
GL_DRAW_BUFFER10_ATI                             = $882F;
GL_DRAW_BUFFER11_ATI                             = $8830;
GL_DRAW_BUFFER12_ATI                             = $8831;
GL_DRAW_BUFFER13_ATI                             = $8832;
GL_DRAW_BUFFER14_ATI                             = $8833;
GL_DRAW_BUFFER15_ATI                             = $8834;

// WGL_ARB_pbuffer
type
HPBUFFERARB= Integer;
const
WGL_DRAW_TO_PBUFFER_ARB                          = $202D;
WGL_MAX_PBUFFER_PIXELS_ARB                       = $202E;
WGL_MAX_PBUFFER_WIDTH_ARB                        = $202F;
WGL_MAX_PBUFFER_HEIGHT_ARB                       = $2030;
WGL_PBUFFER_LARGEST_ARB                          = $2033;
WGL_PBUFFER_WIDTH_ARB                            = $2034;
WGL_PBUFFER_HEIGHT_ARB                           = $2035;
WGL_PBUFFER_LOST_ARB                             = $2036;

// WGL_ARB_buffer_region
WGL_FRONT_COLOR_BUFFER_BIT_ARB                   = $00000001;
WGL_BACK_COLOR_BUFFER_BIT_ARB                    = $00000002;
WGL_DEPTH_BUFFER_BIT_ARB                         = $00000004;
WGL_STENCIL_BUFFER_BIT_ARB                       = $00000008;

// ********** GLU generic constants **********

// Errors: (return value 0= no error)
GLU_INVALID_ENUM                                 = 100900;
GLU_INVALID_VALUE                                = 100901;
GLU_OUT_OF_MEMORY                                = 100902;
GLU_INCOMPATIBLE_GL_VERSION                      = 100903;

// StringName
GLU_VERSION                                      = 100800;
GLU_EXTENSIONS                                   = 100801;

// Boolean
GLU_TRUE                                         = GL_TRUE;
GLU_FALSE                                        = GL_FALSE;

// Quadric constants
// QuadricNormal
GLU_SMOOTH                                       = 100000;
GLU_FLAT                                         = 100001;
GLU_NONE                                         = 100002;

// QuadricDrawStyle
GLU_POINT                                        = 100010;
GLU_LINE                                         = 100011;
GLU_FILL                                         = 100012;
GLU_SILHOUETTE                                   = 100013;

// QuadricOrientation
GLU_OUTSIDE                                      = 100020;
GLU_INSIDE                                       = 100021;

// Tesselation constants
GLU_TESS_MAX_COORD                               = 1.0e150;

// TessProperty
GLU_TESS_WINDING_RULE                            = 100140;
GLU_TESS_BOUNDARY_ONLY                           = 100141;
GLU_TESS_TOLERANCE                               = 100142;

// TessWinding
GLU_TESS_WINDING_ODD                             = 100130;
GLU_TESS_WINDING_NONZERO                         = 100131;
GLU_TESS_WINDING_POSITIVE                        = 100132;
GLU_TESS_WINDING_NEGATIVE                        = 100133;
GLU_TESS_WINDING_ABS_GEQ_TWO                     = 100134;

// TessCallback
GLU_TESS_BEGIN                                   = 100100; // TGLUTessBeginProc
GLU_TESS_VERTEX                                  = 100101; // TGLUTessVertexProc
GLU_TESS_END                                     = 100102; // TGLUTessEndProc
GLU_TESS_ERROR                                   = 100103; // TGLUTessErrorProc
GLU_TESS_EDGE_FLAG                               = 100104; // TGLUTessEdgeFlagProc
GLU_TESS_COMBINE                                 = 100105; // TGLUTessCombineProc
GLU_TESS_BEGIN_DATA                              = 100106; // TGLUTessBeginDataProc
GLU_TESS_VERTEX_DATA                             = 100107; // TGLUTessVertexDataProc
GLU_TESS_END_DATA                                = 100108; // TGLUTessEndDataProc
GLU_TESS_ERROR_DATA                              = 100109; // TGLUTessErrorDataProc
GLU_TESS_EDGE_FLAG_DATA                          = 100110; // TGLUTessEdgeFlagDataProc
GLU_TESS_COMBINE_DATA                            = 100111; // TGLUTessCombineDataProc

// TessError
GLU_TESS_ERROR1                                  = 100151;
GLU_TESS_ERROR2                                  = 100152;
GLU_TESS_ERROR3                                  = 100153;
GLU_TESS_ERROR4                                  = 100154;
GLU_TESS_ERROR5                                  = 100155;
GLU_TESS_ERROR6                                  = 100156;
GLU_TESS_ERROR7                                  = 100157;
GLU_TESS_ERROR8                                  = 100158;

GLU_TESS_MISSING_BEGIN_POLYGON                   = GLU_TESS_ERROR1;
GLU_TESS_MISSING_BEGIN_CONTOUR                   = GLU_TESS_ERROR2;
GLU_TESS_MISSING_END_POLYGON                     = GLU_TESS_ERROR3;
GLU_TESS_MISSING_END_CONTOUR                     = GLU_TESS_ERROR4;
GLU_TESS_COORD_TOO_LARGE                         = GLU_TESS_ERROR5;
GLU_TESS_NEED_COMBINE_CALLBACK                   = GLU_TESS_ERROR6;

// NURBS constants

// NurbsProperty
GLU_AUTO_LOAD_MATRIX                             = 100200;
GLU_CULLING                                      = 100201;
GLU_SAMPLING_TOLERANCE                           = 100203;
GLU_DISPLAY_MODE                                 = 100204;
GLU_PARAMETRIC_TOLERANCE                         = 100202;
GLU_SAMPLING_METHOD                              = 100205;
GLU_U_STEP                                       = 100206;
GLU_V_STEP                                       = 100207;

// NurbsSampling
GLU_PATH_LENGTH                                  = 100215;
GLU_PARAMETRIC_ERROR                             = 100216;
GLU_DOMAIN_DISTANCE                              = 100217;

// NurbsTrim
GLU_MAP1_TRIM_2                                  = 100210;
GLU_MAP1_TRIM_3                                  = 100211;

// NurbsDisplay
GLU_OUTLINE_POLYGON                              = 100240;
GLU_OUTLINE_PATCH                                = 100241;

// NurbsErrors
GLU_NURBS_ERROR1                                 = 100251;
GLU_NURBS_ERROR2                                 = 100252;
GLU_NURBS_ERROR3                                 = 100253;
GLU_NURBS_ERROR4                                 = 100254;
GLU_NURBS_ERROR5                                 = 100255;
GLU_NURBS_ERROR6                                 = 100256;
GLU_NURBS_ERROR7                                 = 100257;
GLU_NURBS_ERROR8                                 = 100258;
GLU_NURBS_ERROR9                                 = 100259;
GLU_NURBS_ERROR10                                = 100260;
GLU_NURBS_ERROR11                                = 100261;
GLU_NURBS_ERROR12                                = 100262;
GLU_NURBS_ERROR13                                = 100263;
GLU_NURBS_ERROR14                                = 100264;
GLU_NURBS_ERROR15                                = 100265;
GLU_NURBS_ERROR16                                = 100266;
GLU_NURBS_ERROR17                                = 100267;
GLU_NURBS_ERROR18                                = 100268;
GLU_NURBS_ERROR19                                = 100269;
GLU_NURBS_ERROR20                                = 100270;
GLU_NURBS_ERROR21                                = 100271;
GLU_NURBS_ERROR22                                = 100272;
GLU_NURBS_ERROR23                                = 100273;
GLU_NURBS_ERROR24                                = 100274;
GLU_NURBS_ERROR25                                = 100275;
GLU_NURBS_ERROR26                                = 100276;
GLU_NURBS_ERROR27                                = 100277;
GLU_NURBS_ERROR28                                = 100278;
GLU_NURBS_ERROR29                                = 100279;
GLU_NURBS_ERROR30                                = 100280;
GLU_NURBS_ERROR31                                = 100281;
GLU_NURBS_ERROR32                                = 100282;
GLU_NURBS_ERROR33                                = 100283;
GLU_NURBS_ERROR34                                = 100284;
GLU_NURBS_ERROR35                                = 100285;
GLU_NURBS_ERROR36                                = 100286;
GLU_NURBS_ERROR37                                = 100287;

// Contours types -- obsolete!
GLU_CW                                           = 100120;
GLU_CCW                                          = 100121;
GLU_INTERIOR                                     = 100122;
GLU_EXTERIOR                                     = 100123;
GLU_UNKNOWN                                      = 100124;

// Names without "TESS_" prefix
GLU_BEGIN                                        = GLU_TESS_BEGIN;
GLU_VERTEX                                       = GLU_TESS_VERTEX;
GLU_END                                          = GLU_TESS_END;
GLU_ERROR                                        = GLU_TESS_ERROR;
GLU_EDGE_FLAG                                    = GLU_TESS_EDGE_FLAG;

GLX_VERSION_1_1                                  = 1;
GLX_VERSION_1_2                                  = 1;
GLX_VERSION_1_3                                  = 1;
GLX_EXTENSION_NAME                               = 'GLX';
GLX_USE_GL                                       = 1;
GLX_BUFFER_SIZE                                  = 2;
GLX_LEVEL                                        = 3;
GLX_RGBA                                         = 4;
GLX_DOUBLEBUFFER                                 = 5;
GLX_STEREO                                       = 6;
GLX_AUX_BUFFERS                                  = 7;
GLX_RED_SIZE                                     = 8;
GLX_GREEN_SIZE                                   = 9;
GLX_BLUE_SIZE                                    = 10;
GLX_ALPHA_SIZE                                   = 11;
GLX_DEPTH_SIZE                                   = 12;
GLX_STENCIL_SIZE                                 = 13;
GLX_ACCUM_RED_SIZE                               = 14;
GLX_ACCUM_GREEN_SIZE                             = 15;
GLX_ACCUM_BLUE_SIZE                              = 16;
GLX_ACCUM_ALPHA_SIZE                             = 17;

// Error codes returned by glXGetConfig:
GLX_BAD_SCREEN                                   = 1;
GLX_BAD_ATTRIBUTE                                = 2;
GLX_NO_EXTENSION                                 = 3;
GLX_BAD_VISUAL                                   = 4;
GLX_BAD_CONTEXT                                  = 5;
GLX_BAD_VALUE                                    = 6;
GLX_BAD_ENUM                                     = 7;

// GLX 1.1 and later:
GLX_VENDOR                                       = 1;
GLX_VERSION                                      = 2;
GLX_EXTENSIONS                                   = 3;

// GLX 1.3 and later:
GLX_CONFIG_CAVEAT                                = $20;
GLX_DONT_CARE                                    = $FFFFFFFF;
GLX_SLOW_CONFIG                                  = $8001;
GLX_NON_CONFORMANT_CONFIG                        = $800D;
GLX_X_VISUAL_TYPE                                = $22;
GLX_TRANSPARENT_TYPE                             = $23;
GLX_TRANSPARENT_INDEX_VALUE                      = $24;
GLX_TRANSPARENT_RED_VALUE                        = $25;
GLX_TRANSPARENT_GREEN_VALUE                      = $26;
GLX_TRANSPARENT_BLUE_VALUE                       = $27;
GLX_TRANSPARENT_ALPHA_VALUE                      = $28;
GLX_MAX_PBUFFER_WIDTH                            = $8016;
GLX_MAX_PBUFFER_HEIGHT                           = $8017;
GLX_MAX_PBUFFER_PIXELS                           = $8018;
GLX_PRESERVED_CONTENTS                           = $801B;
GLX_LARGEST_BUFFER                               = $801C;
GLX_DRAWABLE_TYPE                                = $8010;
GLX_FBCONFIG_ID                                  = $8013;
GLX_VISUAL_ID                                    = $800B;
GLX_WINDOW_BIT                                   = $00000001;
GLX_PIXMAP_BIT                                   = $00000002;
GLX_PBUFFER_BIT                                  = $00000004;
GLX_AUX_BUFFERS_BIT                              = $00000010;
GLX_FRONT_LEFT_BUFFER_BIT                        = $00000001;
GLX_FRONT_RIGHT_BUFFER_BIT                       = $00000002;
GLX_BACK_LEFT_BUFFER_BIT                         = $00000004;
GLX_BACK_RIGHT_BUFFER_BIT                        = $00000008;
GLX_DEPTH_BUFFER_BIT                             = $00000020;
GLX_STENCIL_BUFFER_BIT                           = $00000040;
GLX_ACCUM_BUFFER_BIT                             = $00000080;
GLX_RENDER_TYPE                                  = $8011;
GLX_X_RENDERABLE                                 = $8012;
GLX_NONE                                         = $8000;
GLX_TRUE_COLOR                                   = $8002;
GLX_DIRECT_COLOR                                 = $8003;
GLX_PSEUDO_COLOR                                 = $8004;
GLX_STATIC_COLOR                                 = $8005;
GLX_GRAY_SCALE                                   = $8006;
GLX_STATIC_GRAY                                  = $8007;
GLX_TRANSPARENT_INDEX                            = $8009;
GLX_COLOR_INDEX_TYPE                             = $8015;
GLX_COLOR_INDEX_BIT                              = $00000002;
GLX_SCREEN                                       = $800C;
GLX_PBUFFER_CLOBBER_MASK                         = $08000000;
GLX_DAMAGED                                      = $8020;
GLX_SAVED                                        = $8021;
GLX_WINDOW                                       = $8022;
GLX_PBUFFER                                      = $8023;
GLX_EXT_visual_info                              = 1;
GLX_X_VISUAL_TYPE_EXT                            = $22;
GLX_TRANSPARENT_TYPE_EXT                         = $23;
GLX_TRANSPARENT_INDEX_VALUE_EXT                  = $24;
GLX_TRANSPARENT_RED_VALUE_EXT                    = $25;
GLX_TRANSPARENT_GREEN_VALUE_EXT                  = $26;
GLX_TRANSPARENT_BLUE_VALUE_EXT                   = $27;
GLX_TRANSPARENT_ALPHA_VALUE_EXT                  = $28;
GLX_TRUE_COLOR_EXT                               = $8002;
GLX_DIRECT_COLOR_EXT                             = $8003;
GLX_PSEUDO_COLOR_EXT                             = $8004;
GLX_STATIC_COLOR_EXT                             = $8005;
GLX_GRAY_SCALE_EXT                               = $8006;
GLX_STATIC_GRAY_EXT                              = $8007;
GLX_NONE_EXT                                     = $8000;
GLX_TRANSPARENT_RGB_EXT                          = $8008;
GLX_TRANSPARENT_INDEX_EXT                        = $8009;
GLX_VISUAL_CAVEAT_EXT                            = $20;
GLX_SLOW_VISUAL_EXT                              = $8001;
GLX_NON_CONFORMANT_VISUAL_EXT                    = $800D;
GLX_SHARE_CONTEXT_EXT                            = $800A;
GLX_VISUAL_ID_EXT                                = $800B;
GLX_SCREEN_EXT                                   = $800C;
GLX_3DFX_WINDOW_MODE_MESA                        = $1;
GLX_3DFX_FULLSCREEN_MODE_MESA                    = $2;
//############################################################################//
//############################################################################//
type
TVector2d = array[0..1] of double;
TVector2f = array[0..1] of single;
TVector2i = array[0..1] of longint;
TVector2s = array[0..1] of smallint;
TVector2b = array[0..1] of byte;

TVector3d = array[0..2] of double;
TVector3f = array[0..2] of single;
TVector3i = array[0..2] of longint;
TVector3s = array[0..2] of smallint;
TVector3b = array[0..2] of byte;

TVector4d = array[0..3] of double;
TVector4f = array[0..3] of single;
TVector4i = array[0..3] of longint;
TVector4s = array[0..3] of smallint;
TVector4b = array[0..3] of byte;

TMatrix3d = array[0..2] of TVector3d;
TMatrix3f = array[0..2] of TVector3f;
TMatrix3i = array[0..2] of TVector3i;
TMatrix3s = array[0..2] of TVector3s;
TMatrix3b = array[0..2] of TVector3b;

TMatrix4d = array[0..3] of TVector4d;
TMatrix4f = array[0..3] of TVector4f;
TMatrix4i = array[0..3] of TVector4i;
TMatrix4s = array[0..3] of TVector4s;
TMatrix4b = array[0..3] of TVector4b; 
  
PMatrix4f = ^TMatrix4f;

TD3DVector = packed record
  case Integer of
    0 : (X: single;
         Y: single;
         Z: single);
    1 : (V: TVector3f);
end;

TD3DMatrix = packed record
  case Integer of
    0 : (_11, _12, _13, _14: single;
         _21, _22, _23, _24: single;
         _31, _32, _33, _34: single;
         _41, _42, _43, _44: single);
    1 : (M : TMatrix4f);
end;
//############################################################################//
uint=dword;
GLenum      = UINT;
TGLenum     = UINT; 
PGLenum     = ^TGLenum;

GLboolean   = BYTEBOOL;
TGLboolean  = BYTEBOOL;
PGLboolean  = ^TGLboolean;

GLbitfield  = UINT;
TGLbitfield = UINT;
PGLbitfield = ^TGLbitfield;

GLbyte      = ShortInt;
TGLbyte     = ShortInt;
PGLbyte     = ^TGLbyte;

GLshort     = SmallInt;
TGLshort    = SmallInt;
PGLshort    = ^TGLshort;

GLint       = Integer;
TGLint      = Integer;
PGLint      = ^Integer;

GLsizei     = Integer;
TGLsizei    = Integer;
PGLsizei    = ^TGLsizei;

GLubyte     = Byte;
TGLubyte    = Byte;
PGLubyte    = ^TGLubyte;

GLushort    = Word;
TGLushort   = Word;
PGLushort   = ^TGLushort;

GLuint      = UINT;
TGLuint     = UINT;
PGLuint     = ^TGLuint;

GLfloat     = Single;
TGLfloat    = Single;
PGLfloat    = ^TGLfloat;

GLclampf    = Single;
TGLclampf   = Single;
PGLclampf   = ^TGLclampf;

GLdouble    = Double;
TGLdouble   = Double;
PGLdouble   = ^TGLdouble;

GLclampd    = Double;
TGLclampd   = Double;
PGLclampd   = ^TGLclampd;

GLhandleARB = Cardinal;
PGLhandleARB = ^GLhandleARB;

PGLPCharArray = ^PChar;

PGLvoid = Pointer;

TVector4p = array[0..3] of Pointer;

PGLPointer = ^Pointer;  
//############################################################################//
