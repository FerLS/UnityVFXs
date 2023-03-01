Shader "Clouds"
{
    Properties
    {
        _NoiseScale("NoiseScale", Float) = 10
        _NoiseSpeed("NoiseSpeed", Float) = 0.5
        _NoiseHeight("NoiseHeight", Float) = 3
        _RemapSettings("RemapSettings", Vector) = (0, 1, -1, 1)
        _ColorA("ColorA", Color) = (0, 0, 0, 0)
        _ColorB("ColorB", Color) = (0, 0, 0, 0)
        _NoiseEdge_1("NoiseEdge 1", Float) = 0
        _NoiseEdge_2("NoiseEdge 2", Float) = 1
        _NoisePower("NoisePower", Float) = 2
        _BaseScale("BaseScale", Float) = 7
        _BaseSpeed("BaseSpeed", Float) = 0.5
        _BaseStrenght("BaseStrenght", Float) = 2
        _EmmsionStrength("EmmsionStrength", Float) = 2
        _CurvatureRadoius("CurvatureRadoius", Float) = 4.13
        _FressnelPower("FressnelPower", Float) = 2
        _FressnelOpacity("FressnelOpacity", Float) = 1
        _CloudDensity("CloudDensity", Float) = 1
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue"="Transparent"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalLitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
        
        // Render State
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _LIGHT_COOKIES
        #pragma multi_compile _ _CLUSTERED_RENDERING
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 TangentSpaceNormal;
             float3 WorldSpaceViewDirection;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float3 interp3 : INTERP3;
             float2 interp4 : INTERP4;
             float2 interp5 : INTERP5;
             float3 interp6 : INTERP6;
             float4 interp7 : INTERP7;
             float4 interp8 : INTERP8;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp4.xy =  input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.interp5.xy =  input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp6.xyz =  input.sh;
            #endif
            output.interp7.xyzw =  input.fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.interp8.xyzw =  input.shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.viewDirectionWS = input.interp3.xyz;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.interp4.xy;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.interp5.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp6.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp7.xyzw;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.interp8.xyzw;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _NoiseScale;
        float _NoiseSpeed;
        float _NoiseHeight;
        float4 _RemapSettings;
        float4 _ColorA;
        float4 _ColorB;
        float _NoiseEdge_2;
        float _NoiseEdge_1;
        float _NoisePower;
        float _BaseScale;
        float _BaseSpeed;
        float _BaseStrenght;
        float _EmmsionStrength;
        float _CurvatureRadoius;
        float _FressnelPower;
        float _FressnelOpacity;
        float _CloudDensity;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_2863dc92b6d74402b0f32cb2c401b69d_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_2863dc92b6d74402b0f32cb2c401b69d_Out_2);
            float _Property_6df4e77a3809438595c25ee246a7d2cd_Out_0 = _CurvatureRadoius;
            float _Divide_de337321412f429eb063af28777eb6ff_Out_2;
            Unity_Divide_float(_Distance_2863dc92b6d74402b0f32cb2c401b69d_Out_2, _Property_6df4e77a3809438595c25ee246a7d2cd_Out_0, _Divide_de337321412f429eb063af28777eb6ff_Out_2);
            float _Power_70280d5b57474d6db604f0b5f120b300_Out_2;
            Unity_Power_float(_Divide_de337321412f429eb063af28777eb6ff_Out_2, 3, _Power_70280d5b57474d6db604f0b5f120b300_Out_2);
            float3 _Multiply_a027f29d61de4d57b7b43aa6d9b179dc_Out_2;
            Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Power_70280d5b57474d6db604f0b5f120b300_Out_2.xxx), _Multiply_a027f29d61de4d57b7b43aa6d9b179dc_Out_2);
            float _Property_fefa513c01724d8ab75dd3332e8ca1a9_Out_0 = _NoiseHeight;
            float _Property_f0eb7ef7a3bc4dfda71e328d952abdc8_Out_0 = _NoiseEdge_1;
            float _Property_657d0b2b1ea3480995b8268a02809f28_Out_0 = _NoiseEdge_2;
            float3 _RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, float3 (1, 0, 0), 90, _RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3);
            float _Property_3947645305e34f39ac1f299738ebda99_Out_0 = _NoiseSpeed;
            float _Multiply_67e3f559250b4506978f5f580e820d64_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_3947645305e34f39ac1f299738ebda99_Out_0, _Multiply_67e3f559250b4506978f5f580e820d64_Out_2);
            float2 _TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), (_Multiply_67e3f559250b4506978f5f580e820d64_Out_2.xx), _TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3);
            float _Property_662c5c608b96480b97105ea008d323bc_Out_0 = _NoiseScale;
            float _GradientNoise_14092826abfc47279af304e84345d4d8_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3, _Property_662c5c608b96480b97105ea008d323bc_Out_0, _GradientNoise_14092826abfc47279af304e84345d4d8_Out_2);
            float2 _TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3);
            float _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3, _Property_662c5c608b96480b97105ea008d323bc_Out_0, _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2);
            float _Add_cbc089d51efa495caabb9fec5f21b91b_Out_2;
            Unity_Add_float(_GradientNoise_14092826abfc47279af304e84345d4d8_Out_2, _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2, _Add_cbc089d51efa495caabb9fec5f21b91b_Out_2);
            float _Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2;
            Unity_Divide_float(_Add_cbc089d51efa495caabb9fec5f21b91b_Out_2, 2, _Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2);
            float _Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1;
            Unity_Saturate_float(_Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2, _Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1);
            float _Property_8ec8d96f44a1446a89088f4fcfadc90a_Out_0 = _NoisePower;
            float _Power_972441ad163b41ad82e4183c8e58f482_Out_2;
            Unity_Power_float(_Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1, _Property_8ec8d96f44a1446a89088f4fcfadc90a_Out_0, _Power_972441ad163b41ad82e4183c8e58f482_Out_2);
            float4 _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0 = _RemapSettings;
            float _Split_00f91e501ce64bf6ae829204af6d2179_R_1 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[0];
            float _Split_00f91e501ce64bf6ae829204af6d2179_G_2 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[1];
            float _Split_00f91e501ce64bf6ae829204af6d2179_B_3 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[2];
            float _Split_00f91e501ce64bf6ae829204af6d2179_A_4 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[3];
            float2 _Vector2_5aa5459107114aaeb9a83fb648e0bc26_Out_0 = float2(_Split_00f91e501ce64bf6ae829204af6d2179_R_1, _Split_00f91e501ce64bf6ae829204af6d2179_G_2);
            float2 _Vector2_8aefe5df870e4b569abd97dfc4ee992f_Out_0 = float2(_Split_00f91e501ce64bf6ae829204af6d2179_B_3, _Split_00f91e501ce64bf6ae829204af6d2179_A_4);
            float _Remap_e78987da05d74d6cb721111bc0f21abf_Out_3;
            Unity_Remap_float(_Power_972441ad163b41ad82e4183c8e58f482_Out_2, _Vector2_5aa5459107114aaeb9a83fb648e0bc26_Out_0, _Vector2_8aefe5df870e4b569abd97dfc4ee992f_Out_0, _Remap_e78987da05d74d6cb721111bc0f21abf_Out_3);
            float _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1;
            Unity_Absolute_float(_Remap_e78987da05d74d6cb721111bc0f21abf_Out_3, _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1);
            float _Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3;
            Unity_Smoothstep_float(_Property_f0eb7ef7a3bc4dfda71e328d952abdc8_Out_0, _Property_657d0b2b1ea3480995b8268a02809f28_Out_0, _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1, _Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3);
            float _Property_83795617af3f40c0ab30f49b66478b73_Out_0 = _BaseSpeed;
            float _Multiply_a58beadd6372454682e1871d39a8681a_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_83795617af3f40c0ab30f49b66478b73_Out_0, _Multiply_a58beadd6372454682e1871d39a8681a_Out_2);
            float2 _TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), (_Multiply_a58beadd6372454682e1871d39a8681a_Out_2.xx), _TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3);
            float _Property_4fedba3e833c4179be61d16460fb664e_Out_0 = _BaseScale;
            float _GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3, _Property_4fedba3e833c4179be61d16460fb664e_Out_0, _GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2);
            float _Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0 = _BaseStrenght;
            float _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2;
            Unity_Multiply_float_float(_GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2, _Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0, _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2);
            float _Add_29998d0d53254a89af2d8b2baedfd332_Out_2;
            Unity_Add_float(_Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3, _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2, _Add_29998d0d53254a89af2d8b2baedfd332_Out_2);
            float _Add_6ec522987d504e818dd5f6d33104ee55_Out_2;
            Unity_Add_float(_Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0, 1, _Add_6ec522987d504e818dd5f6d33104ee55_Out_2);
            float _Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2;
            Unity_Divide_float(_Add_29998d0d53254a89af2d8b2baedfd332_Out_2, _Add_6ec522987d504e818dd5f6d33104ee55_Out_2, _Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2);
            float3 _Multiply_de0ffea2f7e0425d845f8a8b7131e078_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2.xxx), _Multiply_de0ffea2f7e0425d845f8a8b7131e078_Out_2);
            float3 _Multiply_d6c6bfb6aa73441fa8c68c76e66086f9_Out_2;
            Unity_Multiply_float3_float3((_Property_fefa513c01724d8ab75dd3332e8ca1a9_Out_0.xxx), _Multiply_de0ffea2f7e0425d845f8a8b7131e078_Out_2, _Multiply_d6c6bfb6aa73441fa8c68c76e66086f9_Out_2);
            float3 _Add_ab90fd41f6fd42e1a94942c33fca0dc3_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_d6c6bfb6aa73441fa8c68c76e66086f9_Out_2, _Add_ab90fd41f6fd42e1a94942c33fca0dc3_Out_2);
            float3 _Add_fd933f550505425caf812611c33b5405_Out_2;
            Unity_Add_float3(_Multiply_a027f29d61de4d57b7b43aa6d9b179dc_Out_2, _Add_ab90fd41f6fd42e1a94942c33fca0dc3_Out_2, _Add_fd933f550505425caf812611c33b5405_Out_2);
            description.Position = _Add_fd933f550505425caf812611c33b5405_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_f0eb7ef7a3bc4dfda71e328d952abdc8_Out_0 = _NoiseEdge_1;
            float _Property_657d0b2b1ea3480995b8268a02809f28_Out_0 = _NoiseEdge_2;
            float3 _RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, float3 (1, 0, 0), 90, _RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3);
            float _Property_3947645305e34f39ac1f299738ebda99_Out_0 = _NoiseSpeed;
            float _Multiply_67e3f559250b4506978f5f580e820d64_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_3947645305e34f39ac1f299738ebda99_Out_0, _Multiply_67e3f559250b4506978f5f580e820d64_Out_2);
            float2 _TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), (_Multiply_67e3f559250b4506978f5f580e820d64_Out_2.xx), _TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3);
            float _Property_662c5c608b96480b97105ea008d323bc_Out_0 = _NoiseScale;
            float _GradientNoise_14092826abfc47279af304e84345d4d8_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3, _Property_662c5c608b96480b97105ea008d323bc_Out_0, _GradientNoise_14092826abfc47279af304e84345d4d8_Out_2);
            float2 _TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3);
            float _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3, _Property_662c5c608b96480b97105ea008d323bc_Out_0, _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2);
            float _Add_cbc089d51efa495caabb9fec5f21b91b_Out_2;
            Unity_Add_float(_GradientNoise_14092826abfc47279af304e84345d4d8_Out_2, _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2, _Add_cbc089d51efa495caabb9fec5f21b91b_Out_2);
            float _Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2;
            Unity_Divide_float(_Add_cbc089d51efa495caabb9fec5f21b91b_Out_2, 2, _Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2);
            float _Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1;
            Unity_Saturate_float(_Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2, _Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1);
            float _Property_8ec8d96f44a1446a89088f4fcfadc90a_Out_0 = _NoisePower;
            float _Power_972441ad163b41ad82e4183c8e58f482_Out_2;
            Unity_Power_float(_Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1, _Property_8ec8d96f44a1446a89088f4fcfadc90a_Out_0, _Power_972441ad163b41ad82e4183c8e58f482_Out_2);
            float4 _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0 = _RemapSettings;
            float _Split_00f91e501ce64bf6ae829204af6d2179_R_1 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[0];
            float _Split_00f91e501ce64bf6ae829204af6d2179_G_2 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[1];
            float _Split_00f91e501ce64bf6ae829204af6d2179_B_3 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[2];
            float _Split_00f91e501ce64bf6ae829204af6d2179_A_4 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[3];
            float2 _Vector2_5aa5459107114aaeb9a83fb648e0bc26_Out_0 = float2(_Split_00f91e501ce64bf6ae829204af6d2179_R_1, _Split_00f91e501ce64bf6ae829204af6d2179_G_2);
            float2 _Vector2_8aefe5df870e4b569abd97dfc4ee992f_Out_0 = float2(_Split_00f91e501ce64bf6ae829204af6d2179_B_3, _Split_00f91e501ce64bf6ae829204af6d2179_A_4);
            float _Remap_e78987da05d74d6cb721111bc0f21abf_Out_3;
            Unity_Remap_float(_Power_972441ad163b41ad82e4183c8e58f482_Out_2, _Vector2_5aa5459107114aaeb9a83fb648e0bc26_Out_0, _Vector2_8aefe5df870e4b569abd97dfc4ee992f_Out_0, _Remap_e78987da05d74d6cb721111bc0f21abf_Out_3);
            float _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1;
            Unity_Absolute_float(_Remap_e78987da05d74d6cb721111bc0f21abf_Out_3, _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1);
            float _Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3;
            Unity_Smoothstep_float(_Property_f0eb7ef7a3bc4dfda71e328d952abdc8_Out_0, _Property_657d0b2b1ea3480995b8268a02809f28_Out_0, _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1, _Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3);
            float _Property_83795617af3f40c0ab30f49b66478b73_Out_0 = _BaseSpeed;
            float _Multiply_a58beadd6372454682e1871d39a8681a_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_83795617af3f40c0ab30f49b66478b73_Out_0, _Multiply_a58beadd6372454682e1871d39a8681a_Out_2);
            float2 _TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), (_Multiply_a58beadd6372454682e1871d39a8681a_Out_2.xx), _TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3);
            float _Property_4fedba3e833c4179be61d16460fb664e_Out_0 = _BaseScale;
            float _GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3, _Property_4fedba3e833c4179be61d16460fb664e_Out_0, _GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2);
            float _Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0 = _BaseStrenght;
            float _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2;
            Unity_Multiply_float_float(_GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2, _Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0, _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2);
            float _Add_29998d0d53254a89af2d8b2baedfd332_Out_2;
            Unity_Add_float(_Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3, _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2, _Add_29998d0d53254a89af2d8b2baedfd332_Out_2);
            float _Add_6ec522987d504e818dd5f6d33104ee55_Out_2;
            Unity_Add_float(_Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0, 1, _Add_6ec522987d504e818dd5f6d33104ee55_Out_2);
            float _Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2;
            Unity_Divide_float(_Add_29998d0d53254a89af2d8b2baedfd332_Out_2, _Add_6ec522987d504e818dd5f6d33104ee55_Out_2, _Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2);
            float _Property_5e6909be7142479cb5595465ab7396ab_Out_0 = _FressnelPower;
            float _FresnelEffect_6ad385502ba442bbbfd08c8289b8addd_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_5e6909be7142479cb5595465ab7396ab_Out_0, _FresnelEffect_6ad385502ba442bbbfd08c8289b8addd_Out_3);
            float _Multiply_28a1d2721a9b469da8137faff3ce48b6_Out_2;
            Unity_Multiply_float_float(_Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2, _FresnelEffect_6ad385502ba442bbbfd08c8289b8addd_Out_3, _Multiply_28a1d2721a9b469da8137faff3ce48b6_Out_2);
            float _Property_2bb7638bbe5e46abb573c3169b6fd8a0_Out_0 = _FressnelOpacity;
            float _Multiply_223cf800f8854807ba5c4b69d74abfb9_Out_2;
            Unity_Multiply_float_float(_Multiply_28a1d2721a9b469da8137faff3ce48b6_Out_2, _Property_2bb7638bbe5e46abb573c3169b6fd8a0_Out_0, _Multiply_223cf800f8854807ba5c4b69d74abfb9_Out_2);
            float4 _Property_9e04c6a53cf14db8af5075df14bdf933_Out_0 = _ColorA;
            float4 _Property_b8fd511244174f46a8116607e59c88de_Out_0 = _ColorB;
            float4 _Lerp_b4d037eea01443f981d467219a9716cb_Out_3;
            Unity_Lerp_float4(_Property_9e04c6a53cf14db8af5075df14bdf933_Out_0, _Property_b8fd511244174f46a8116607e59c88de_Out_0, (_Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2.xxxx), _Lerp_b4d037eea01443f981d467219a9716cb_Out_3);
            float4 _Add_d4f711b802874114a3aaedfa0820123c_Out_2;
            Unity_Add_float4((_Multiply_223cf800f8854807ba5c4b69d74abfb9_Out_2.xxxx), _Lerp_b4d037eea01443f981d467219a9716cb_Out_3, _Add_d4f711b802874114a3aaedfa0820123c_Out_2);
            float _Property_01447423b08c408283d759fb2cdebc7a_Out_0 = _EmmsionStrength;
            float4 _Multiply_336e0a5f825c42458362ed5f9974b35a_Out_2;
            Unity_Multiply_float4_float4(_Add_d4f711b802874114a3aaedfa0820123c_Out_2, (_Property_01447423b08c408283d759fb2cdebc7a_Out_0.xxxx), _Multiply_336e0a5f825c42458362ed5f9974b35a_Out_2);
            float _SceneDepth_1445156fcebf4ffc8c96120674f48392_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_1445156fcebf4ffc8c96120674f48392_Out_1);
            float4 _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0 = IN.ScreenPosition;
            float _Split_20ac0327e97147fcad31a4edfbaadfff_R_1 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[0];
            float _Split_20ac0327e97147fcad31a4edfbaadfff_G_2 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[1];
            float _Split_20ac0327e97147fcad31a4edfbaadfff_B_3 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[2];
            float _Split_20ac0327e97147fcad31a4edfbaadfff_A_4 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[3];
            float _Subtract_7c1a93a030ef421686bbee6b739bad50_Out_2;
            Unity_Subtract_float(_Split_20ac0327e97147fcad31a4edfbaadfff_A_4, 1, _Subtract_7c1a93a030ef421686bbee6b739bad50_Out_2);
            float _Subtract_02f894cc1e32412eb02601836af73907_Out_2;
            Unity_Subtract_float(_SceneDepth_1445156fcebf4ffc8c96120674f48392_Out_1, _Subtract_7c1a93a030ef421686bbee6b739bad50_Out_2, _Subtract_02f894cc1e32412eb02601836af73907_Out_2);
            float _Property_c3a2ef45c7994aa5a1a193e18d269929_Out_0 = _CloudDensity;
            float _Divide_ebdf44b2c9b84b2fb284d02eeac4fb2c_Out_2;
            Unity_Divide_float(_Subtract_02f894cc1e32412eb02601836af73907_Out_2, _Property_c3a2ef45c7994aa5a1a193e18d269929_Out_0, _Divide_ebdf44b2c9b84b2fb284d02eeac4fb2c_Out_2);
            float _Saturate_de5e588c20ff4724a90c4ac5e20d6ef1_Out_1;
            Unity_Saturate_float(_Divide_ebdf44b2c9b84b2fb284d02eeac4fb2c_Out_2, _Saturate_de5e588c20ff4724a90c4ac5e20d6ef1_Out_1);
            surface.BaseColor = (_Add_d4f711b802874114a3aaedfa0820123c_Out_2.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = (_Multiply_336e0a5f825c42458362ed5f9974b35a_Out_2.xyz);
            surface.Metallic = 0;
            surface.Smoothness = 0.5;
            surface.Occlusion = 1;
            surface.Alpha = _Saturate_de5e588c20ff4724a90c4ac5e20d6ef1_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.WorldSpaceViewDirection = normalize(input.viewDirectionWS);
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }
        
        // Render State
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_GBUFFER
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 TangentSpaceNormal;
             float3 WorldSpaceViewDirection;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float3 interp3 : INTERP3;
             float2 interp4 : INTERP4;
             float2 interp5 : INTERP5;
             float3 interp6 : INTERP6;
             float4 interp7 : INTERP7;
             float4 interp8 : INTERP8;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp4.xy =  input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.interp5.xy =  input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp6.xyz =  input.sh;
            #endif
            output.interp7.xyzw =  input.fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.interp8.xyzw =  input.shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.viewDirectionWS = input.interp3.xyz;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.interp4.xy;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.interp5.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp6.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp7.xyzw;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.interp8.xyzw;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _NoiseScale;
        float _NoiseSpeed;
        float _NoiseHeight;
        float4 _RemapSettings;
        float4 _ColorA;
        float4 _ColorB;
        float _NoiseEdge_2;
        float _NoiseEdge_1;
        float _NoisePower;
        float _BaseScale;
        float _BaseSpeed;
        float _BaseStrenght;
        float _EmmsionStrength;
        float _CurvatureRadoius;
        float _FressnelPower;
        float _FressnelOpacity;
        float _CloudDensity;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_2863dc92b6d74402b0f32cb2c401b69d_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_2863dc92b6d74402b0f32cb2c401b69d_Out_2);
            float _Property_6df4e77a3809438595c25ee246a7d2cd_Out_0 = _CurvatureRadoius;
            float _Divide_de337321412f429eb063af28777eb6ff_Out_2;
            Unity_Divide_float(_Distance_2863dc92b6d74402b0f32cb2c401b69d_Out_2, _Property_6df4e77a3809438595c25ee246a7d2cd_Out_0, _Divide_de337321412f429eb063af28777eb6ff_Out_2);
            float _Power_70280d5b57474d6db604f0b5f120b300_Out_2;
            Unity_Power_float(_Divide_de337321412f429eb063af28777eb6ff_Out_2, 3, _Power_70280d5b57474d6db604f0b5f120b300_Out_2);
            float3 _Multiply_a027f29d61de4d57b7b43aa6d9b179dc_Out_2;
            Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Power_70280d5b57474d6db604f0b5f120b300_Out_2.xxx), _Multiply_a027f29d61de4d57b7b43aa6d9b179dc_Out_2);
            float _Property_fefa513c01724d8ab75dd3332e8ca1a9_Out_0 = _NoiseHeight;
            float _Property_f0eb7ef7a3bc4dfda71e328d952abdc8_Out_0 = _NoiseEdge_1;
            float _Property_657d0b2b1ea3480995b8268a02809f28_Out_0 = _NoiseEdge_2;
            float3 _RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, float3 (1, 0, 0), 90, _RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3);
            float _Property_3947645305e34f39ac1f299738ebda99_Out_0 = _NoiseSpeed;
            float _Multiply_67e3f559250b4506978f5f580e820d64_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_3947645305e34f39ac1f299738ebda99_Out_0, _Multiply_67e3f559250b4506978f5f580e820d64_Out_2);
            float2 _TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), (_Multiply_67e3f559250b4506978f5f580e820d64_Out_2.xx), _TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3);
            float _Property_662c5c608b96480b97105ea008d323bc_Out_0 = _NoiseScale;
            float _GradientNoise_14092826abfc47279af304e84345d4d8_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3, _Property_662c5c608b96480b97105ea008d323bc_Out_0, _GradientNoise_14092826abfc47279af304e84345d4d8_Out_2);
            float2 _TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3);
            float _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3, _Property_662c5c608b96480b97105ea008d323bc_Out_0, _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2);
            float _Add_cbc089d51efa495caabb9fec5f21b91b_Out_2;
            Unity_Add_float(_GradientNoise_14092826abfc47279af304e84345d4d8_Out_2, _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2, _Add_cbc089d51efa495caabb9fec5f21b91b_Out_2);
            float _Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2;
            Unity_Divide_float(_Add_cbc089d51efa495caabb9fec5f21b91b_Out_2, 2, _Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2);
            float _Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1;
            Unity_Saturate_float(_Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2, _Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1);
            float _Property_8ec8d96f44a1446a89088f4fcfadc90a_Out_0 = _NoisePower;
            float _Power_972441ad163b41ad82e4183c8e58f482_Out_2;
            Unity_Power_float(_Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1, _Property_8ec8d96f44a1446a89088f4fcfadc90a_Out_0, _Power_972441ad163b41ad82e4183c8e58f482_Out_2);
            float4 _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0 = _RemapSettings;
            float _Split_00f91e501ce64bf6ae829204af6d2179_R_1 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[0];
            float _Split_00f91e501ce64bf6ae829204af6d2179_G_2 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[1];
            float _Split_00f91e501ce64bf6ae829204af6d2179_B_3 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[2];
            float _Split_00f91e501ce64bf6ae829204af6d2179_A_4 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[3];
            float2 _Vector2_5aa5459107114aaeb9a83fb648e0bc26_Out_0 = float2(_Split_00f91e501ce64bf6ae829204af6d2179_R_1, _Split_00f91e501ce64bf6ae829204af6d2179_G_2);
            float2 _Vector2_8aefe5df870e4b569abd97dfc4ee992f_Out_0 = float2(_Split_00f91e501ce64bf6ae829204af6d2179_B_3, _Split_00f91e501ce64bf6ae829204af6d2179_A_4);
            float _Remap_e78987da05d74d6cb721111bc0f21abf_Out_3;
            Unity_Remap_float(_Power_972441ad163b41ad82e4183c8e58f482_Out_2, _Vector2_5aa5459107114aaeb9a83fb648e0bc26_Out_0, _Vector2_8aefe5df870e4b569abd97dfc4ee992f_Out_0, _Remap_e78987da05d74d6cb721111bc0f21abf_Out_3);
            float _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1;
            Unity_Absolute_float(_Remap_e78987da05d74d6cb721111bc0f21abf_Out_3, _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1);
            float _Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3;
            Unity_Smoothstep_float(_Property_f0eb7ef7a3bc4dfda71e328d952abdc8_Out_0, _Property_657d0b2b1ea3480995b8268a02809f28_Out_0, _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1, _Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3);
            float _Property_83795617af3f40c0ab30f49b66478b73_Out_0 = _BaseSpeed;
            float _Multiply_a58beadd6372454682e1871d39a8681a_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_83795617af3f40c0ab30f49b66478b73_Out_0, _Multiply_a58beadd6372454682e1871d39a8681a_Out_2);
            float2 _TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), (_Multiply_a58beadd6372454682e1871d39a8681a_Out_2.xx), _TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3);
            float _Property_4fedba3e833c4179be61d16460fb664e_Out_0 = _BaseScale;
            float _GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3, _Property_4fedba3e833c4179be61d16460fb664e_Out_0, _GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2);
            float _Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0 = _BaseStrenght;
            float _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2;
            Unity_Multiply_float_float(_GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2, _Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0, _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2);
            float _Add_29998d0d53254a89af2d8b2baedfd332_Out_2;
            Unity_Add_float(_Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3, _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2, _Add_29998d0d53254a89af2d8b2baedfd332_Out_2);
            float _Add_6ec522987d504e818dd5f6d33104ee55_Out_2;
            Unity_Add_float(_Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0, 1, _Add_6ec522987d504e818dd5f6d33104ee55_Out_2);
            float _Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2;
            Unity_Divide_float(_Add_29998d0d53254a89af2d8b2baedfd332_Out_2, _Add_6ec522987d504e818dd5f6d33104ee55_Out_2, _Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2);
            float3 _Multiply_de0ffea2f7e0425d845f8a8b7131e078_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2.xxx), _Multiply_de0ffea2f7e0425d845f8a8b7131e078_Out_2);
            float3 _Multiply_d6c6bfb6aa73441fa8c68c76e66086f9_Out_2;
            Unity_Multiply_float3_float3((_Property_fefa513c01724d8ab75dd3332e8ca1a9_Out_0.xxx), _Multiply_de0ffea2f7e0425d845f8a8b7131e078_Out_2, _Multiply_d6c6bfb6aa73441fa8c68c76e66086f9_Out_2);
            float3 _Add_ab90fd41f6fd42e1a94942c33fca0dc3_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_d6c6bfb6aa73441fa8c68c76e66086f9_Out_2, _Add_ab90fd41f6fd42e1a94942c33fca0dc3_Out_2);
            float3 _Add_fd933f550505425caf812611c33b5405_Out_2;
            Unity_Add_float3(_Multiply_a027f29d61de4d57b7b43aa6d9b179dc_Out_2, _Add_ab90fd41f6fd42e1a94942c33fca0dc3_Out_2, _Add_fd933f550505425caf812611c33b5405_Out_2);
            description.Position = _Add_fd933f550505425caf812611c33b5405_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_f0eb7ef7a3bc4dfda71e328d952abdc8_Out_0 = _NoiseEdge_1;
            float _Property_657d0b2b1ea3480995b8268a02809f28_Out_0 = _NoiseEdge_2;
            float3 _RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, float3 (1, 0, 0), 90, _RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3);
            float _Property_3947645305e34f39ac1f299738ebda99_Out_0 = _NoiseSpeed;
            float _Multiply_67e3f559250b4506978f5f580e820d64_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_3947645305e34f39ac1f299738ebda99_Out_0, _Multiply_67e3f559250b4506978f5f580e820d64_Out_2);
            float2 _TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), (_Multiply_67e3f559250b4506978f5f580e820d64_Out_2.xx), _TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3);
            float _Property_662c5c608b96480b97105ea008d323bc_Out_0 = _NoiseScale;
            float _GradientNoise_14092826abfc47279af304e84345d4d8_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3, _Property_662c5c608b96480b97105ea008d323bc_Out_0, _GradientNoise_14092826abfc47279af304e84345d4d8_Out_2);
            float2 _TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3);
            float _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3, _Property_662c5c608b96480b97105ea008d323bc_Out_0, _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2);
            float _Add_cbc089d51efa495caabb9fec5f21b91b_Out_2;
            Unity_Add_float(_GradientNoise_14092826abfc47279af304e84345d4d8_Out_2, _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2, _Add_cbc089d51efa495caabb9fec5f21b91b_Out_2);
            float _Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2;
            Unity_Divide_float(_Add_cbc089d51efa495caabb9fec5f21b91b_Out_2, 2, _Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2);
            float _Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1;
            Unity_Saturate_float(_Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2, _Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1);
            float _Property_8ec8d96f44a1446a89088f4fcfadc90a_Out_0 = _NoisePower;
            float _Power_972441ad163b41ad82e4183c8e58f482_Out_2;
            Unity_Power_float(_Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1, _Property_8ec8d96f44a1446a89088f4fcfadc90a_Out_0, _Power_972441ad163b41ad82e4183c8e58f482_Out_2);
            float4 _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0 = _RemapSettings;
            float _Split_00f91e501ce64bf6ae829204af6d2179_R_1 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[0];
            float _Split_00f91e501ce64bf6ae829204af6d2179_G_2 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[1];
            float _Split_00f91e501ce64bf6ae829204af6d2179_B_3 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[2];
            float _Split_00f91e501ce64bf6ae829204af6d2179_A_4 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[3];
            float2 _Vector2_5aa5459107114aaeb9a83fb648e0bc26_Out_0 = float2(_Split_00f91e501ce64bf6ae829204af6d2179_R_1, _Split_00f91e501ce64bf6ae829204af6d2179_G_2);
            float2 _Vector2_8aefe5df870e4b569abd97dfc4ee992f_Out_0 = float2(_Split_00f91e501ce64bf6ae829204af6d2179_B_3, _Split_00f91e501ce64bf6ae829204af6d2179_A_4);
            float _Remap_e78987da05d74d6cb721111bc0f21abf_Out_3;
            Unity_Remap_float(_Power_972441ad163b41ad82e4183c8e58f482_Out_2, _Vector2_5aa5459107114aaeb9a83fb648e0bc26_Out_0, _Vector2_8aefe5df870e4b569abd97dfc4ee992f_Out_0, _Remap_e78987da05d74d6cb721111bc0f21abf_Out_3);
            float _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1;
            Unity_Absolute_float(_Remap_e78987da05d74d6cb721111bc0f21abf_Out_3, _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1);
            float _Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3;
            Unity_Smoothstep_float(_Property_f0eb7ef7a3bc4dfda71e328d952abdc8_Out_0, _Property_657d0b2b1ea3480995b8268a02809f28_Out_0, _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1, _Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3);
            float _Property_83795617af3f40c0ab30f49b66478b73_Out_0 = _BaseSpeed;
            float _Multiply_a58beadd6372454682e1871d39a8681a_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_83795617af3f40c0ab30f49b66478b73_Out_0, _Multiply_a58beadd6372454682e1871d39a8681a_Out_2);
            float2 _TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), (_Multiply_a58beadd6372454682e1871d39a8681a_Out_2.xx), _TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3);
            float _Property_4fedba3e833c4179be61d16460fb664e_Out_0 = _BaseScale;
            float _GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3, _Property_4fedba3e833c4179be61d16460fb664e_Out_0, _GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2);
            float _Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0 = _BaseStrenght;
            float _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2;
            Unity_Multiply_float_float(_GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2, _Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0, _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2);
            float _Add_29998d0d53254a89af2d8b2baedfd332_Out_2;
            Unity_Add_float(_Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3, _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2, _Add_29998d0d53254a89af2d8b2baedfd332_Out_2);
            float _Add_6ec522987d504e818dd5f6d33104ee55_Out_2;
            Unity_Add_float(_Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0, 1, _Add_6ec522987d504e818dd5f6d33104ee55_Out_2);
            float _Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2;
            Unity_Divide_float(_Add_29998d0d53254a89af2d8b2baedfd332_Out_2, _Add_6ec522987d504e818dd5f6d33104ee55_Out_2, _Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2);
            float _Property_5e6909be7142479cb5595465ab7396ab_Out_0 = _FressnelPower;
            float _FresnelEffect_6ad385502ba442bbbfd08c8289b8addd_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_5e6909be7142479cb5595465ab7396ab_Out_0, _FresnelEffect_6ad385502ba442bbbfd08c8289b8addd_Out_3);
            float _Multiply_28a1d2721a9b469da8137faff3ce48b6_Out_2;
            Unity_Multiply_float_float(_Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2, _FresnelEffect_6ad385502ba442bbbfd08c8289b8addd_Out_3, _Multiply_28a1d2721a9b469da8137faff3ce48b6_Out_2);
            float _Property_2bb7638bbe5e46abb573c3169b6fd8a0_Out_0 = _FressnelOpacity;
            float _Multiply_223cf800f8854807ba5c4b69d74abfb9_Out_2;
            Unity_Multiply_float_float(_Multiply_28a1d2721a9b469da8137faff3ce48b6_Out_2, _Property_2bb7638bbe5e46abb573c3169b6fd8a0_Out_0, _Multiply_223cf800f8854807ba5c4b69d74abfb9_Out_2);
            float4 _Property_9e04c6a53cf14db8af5075df14bdf933_Out_0 = _ColorA;
            float4 _Property_b8fd511244174f46a8116607e59c88de_Out_0 = _ColorB;
            float4 _Lerp_b4d037eea01443f981d467219a9716cb_Out_3;
            Unity_Lerp_float4(_Property_9e04c6a53cf14db8af5075df14bdf933_Out_0, _Property_b8fd511244174f46a8116607e59c88de_Out_0, (_Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2.xxxx), _Lerp_b4d037eea01443f981d467219a9716cb_Out_3);
            float4 _Add_d4f711b802874114a3aaedfa0820123c_Out_2;
            Unity_Add_float4((_Multiply_223cf800f8854807ba5c4b69d74abfb9_Out_2.xxxx), _Lerp_b4d037eea01443f981d467219a9716cb_Out_3, _Add_d4f711b802874114a3aaedfa0820123c_Out_2);
            float _Property_01447423b08c408283d759fb2cdebc7a_Out_0 = _EmmsionStrength;
            float4 _Multiply_336e0a5f825c42458362ed5f9974b35a_Out_2;
            Unity_Multiply_float4_float4(_Add_d4f711b802874114a3aaedfa0820123c_Out_2, (_Property_01447423b08c408283d759fb2cdebc7a_Out_0.xxxx), _Multiply_336e0a5f825c42458362ed5f9974b35a_Out_2);
            float _SceneDepth_1445156fcebf4ffc8c96120674f48392_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_1445156fcebf4ffc8c96120674f48392_Out_1);
            float4 _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0 = IN.ScreenPosition;
            float _Split_20ac0327e97147fcad31a4edfbaadfff_R_1 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[0];
            float _Split_20ac0327e97147fcad31a4edfbaadfff_G_2 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[1];
            float _Split_20ac0327e97147fcad31a4edfbaadfff_B_3 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[2];
            float _Split_20ac0327e97147fcad31a4edfbaadfff_A_4 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[3];
            float _Subtract_7c1a93a030ef421686bbee6b739bad50_Out_2;
            Unity_Subtract_float(_Split_20ac0327e97147fcad31a4edfbaadfff_A_4, 1, _Subtract_7c1a93a030ef421686bbee6b739bad50_Out_2);
            float _Subtract_02f894cc1e32412eb02601836af73907_Out_2;
            Unity_Subtract_float(_SceneDepth_1445156fcebf4ffc8c96120674f48392_Out_1, _Subtract_7c1a93a030ef421686bbee6b739bad50_Out_2, _Subtract_02f894cc1e32412eb02601836af73907_Out_2);
            float _Property_c3a2ef45c7994aa5a1a193e18d269929_Out_0 = _CloudDensity;
            float _Divide_ebdf44b2c9b84b2fb284d02eeac4fb2c_Out_2;
            Unity_Divide_float(_Subtract_02f894cc1e32412eb02601836af73907_Out_2, _Property_c3a2ef45c7994aa5a1a193e18d269929_Out_0, _Divide_ebdf44b2c9b84b2fb284d02eeac4fb2c_Out_2);
            float _Saturate_de5e588c20ff4724a90c4ac5e20d6ef1_Out_1;
            Unity_Saturate_float(_Divide_ebdf44b2c9b84b2fb284d02eeac4fb2c_Out_2, _Saturate_de5e588c20ff4724a90c4ac5e20d6ef1_Out_1);
            surface.BaseColor = (_Add_d4f711b802874114a3aaedfa0820123c_Out_2.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = (_Multiply_336e0a5f825c42458362ed5f9974b35a_Out_2.xyz);
            surface.Metallic = 0;
            surface.Smoothness = 0.5;
            surface.Occlusion = 1;
            surface.Alpha = _Saturate_de5e588c20ff4724a90c4ac5e20d6ef1_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.WorldSpaceViewDirection = normalize(input.viewDirectionWS);
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
        
        // Render State
        Cull Off
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _NoiseScale;
        float _NoiseSpeed;
        float _NoiseHeight;
        float4 _RemapSettings;
        float4 _ColorA;
        float4 _ColorB;
        float _NoiseEdge_2;
        float _NoiseEdge_1;
        float _NoisePower;
        float _BaseScale;
        float _BaseSpeed;
        float _BaseStrenght;
        float _EmmsionStrength;
        float _CurvatureRadoius;
        float _FressnelPower;
        float _FressnelOpacity;
        float _CloudDensity;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_2863dc92b6d74402b0f32cb2c401b69d_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_2863dc92b6d74402b0f32cb2c401b69d_Out_2);
            float _Property_6df4e77a3809438595c25ee246a7d2cd_Out_0 = _CurvatureRadoius;
            float _Divide_de337321412f429eb063af28777eb6ff_Out_2;
            Unity_Divide_float(_Distance_2863dc92b6d74402b0f32cb2c401b69d_Out_2, _Property_6df4e77a3809438595c25ee246a7d2cd_Out_0, _Divide_de337321412f429eb063af28777eb6ff_Out_2);
            float _Power_70280d5b57474d6db604f0b5f120b300_Out_2;
            Unity_Power_float(_Divide_de337321412f429eb063af28777eb6ff_Out_2, 3, _Power_70280d5b57474d6db604f0b5f120b300_Out_2);
            float3 _Multiply_a027f29d61de4d57b7b43aa6d9b179dc_Out_2;
            Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Power_70280d5b57474d6db604f0b5f120b300_Out_2.xxx), _Multiply_a027f29d61de4d57b7b43aa6d9b179dc_Out_2);
            float _Property_fefa513c01724d8ab75dd3332e8ca1a9_Out_0 = _NoiseHeight;
            float _Property_f0eb7ef7a3bc4dfda71e328d952abdc8_Out_0 = _NoiseEdge_1;
            float _Property_657d0b2b1ea3480995b8268a02809f28_Out_0 = _NoiseEdge_2;
            float3 _RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, float3 (1, 0, 0), 90, _RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3);
            float _Property_3947645305e34f39ac1f299738ebda99_Out_0 = _NoiseSpeed;
            float _Multiply_67e3f559250b4506978f5f580e820d64_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_3947645305e34f39ac1f299738ebda99_Out_0, _Multiply_67e3f559250b4506978f5f580e820d64_Out_2);
            float2 _TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), (_Multiply_67e3f559250b4506978f5f580e820d64_Out_2.xx), _TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3);
            float _Property_662c5c608b96480b97105ea008d323bc_Out_0 = _NoiseScale;
            float _GradientNoise_14092826abfc47279af304e84345d4d8_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3, _Property_662c5c608b96480b97105ea008d323bc_Out_0, _GradientNoise_14092826abfc47279af304e84345d4d8_Out_2);
            float2 _TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3);
            float _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3, _Property_662c5c608b96480b97105ea008d323bc_Out_0, _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2);
            float _Add_cbc089d51efa495caabb9fec5f21b91b_Out_2;
            Unity_Add_float(_GradientNoise_14092826abfc47279af304e84345d4d8_Out_2, _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2, _Add_cbc089d51efa495caabb9fec5f21b91b_Out_2);
            float _Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2;
            Unity_Divide_float(_Add_cbc089d51efa495caabb9fec5f21b91b_Out_2, 2, _Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2);
            float _Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1;
            Unity_Saturate_float(_Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2, _Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1);
            float _Property_8ec8d96f44a1446a89088f4fcfadc90a_Out_0 = _NoisePower;
            float _Power_972441ad163b41ad82e4183c8e58f482_Out_2;
            Unity_Power_float(_Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1, _Property_8ec8d96f44a1446a89088f4fcfadc90a_Out_0, _Power_972441ad163b41ad82e4183c8e58f482_Out_2);
            float4 _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0 = _RemapSettings;
            float _Split_00f91e501ce64bf6ae829204af6d2179_R_1 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[0];
            float _Split_00f91e501ce64bf6ae829204af6d2179_G_2 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[1];
            float _Split_00f91e501ce64bf6ae829204af6d2179_B_3 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[2];
            float _Split_00f91e501ce64bf6ae829204af6d2179_A_4 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[3];
            float2 _Vector2_5aa5459107114aaeb9a83fb648e0bc26_Out_0 = float2(_Split_00f91e501ce64bf6ae829204af6d2179_R_1, _Split_00f91e501ce64bf6ae829204af6d2179_G_2);
            float2 _Vector2_8aefe5df870e4b569abd97dfc4ee992f_Out_0 = float2(_Split_00f91e501ce64bf6ae829204af6d2179_B_3, _Split_00f91e501ce64bf6ae829204af6d2179_A_4);
            float _Remap_e78987da05d74d6cb721111bc0f21abf_Out_3;
            Unity_Remap_float(_Power_972441ad163b41ad82e4183c8e58f482_Out_2, _Vector2_5aa5459107114aaeb9a83fb648e0bc26_Out_0, _Vector2_8aefe5df870e4b569abd97dfc4ee992f_Out_0, _Remap_e78987da05d74d6cb721111bc0f21abf_Out_3);
            float _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1;
            Unity_Absolute_float(_Remap_e78987da05d74d6cb721111bc0f21abf_Out_3, _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1);
            float _Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3;
            Unity_Smoothstep_float(_Property_f0eb7ef7a3bc4dfda71e328d952abdc8_Out_0, _Property_657d0b2b1ea3480995b8268a02809f28_Out_0, _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1, _Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3);
            float _Property_83795617af3f40c0ab30f49b66478b73_Out_0 = _BaseSpeed;
            float _Multiply_a58beadd6372454682e1871d39a8681a_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_83795617af3f40c0ab30f49b66478b73_Out_0, _Multiply_a58beadd6372454682e1871d39a8681a_Out_2);
            float2 _TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), (_Multiply_a58beadd6372454682e1871d39a8681a_Out_2.xx), _TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3);
            float _Property_4fedba3e833c4179be61d16460fb664e_Out_0 = _BaseScale;
            float _GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3, _Property_4fedba3e833c4179be61d16460fb664e_Out_0, _GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2);
            float _Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0 = _BaseStrenght;
            float _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2;
            Unity_Multiply_float_float(_GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2, _Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0, _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2);
            float _Add_29998d0d53254a89af2d8b2baedfd332_Out_2;
            Unity_Add_float(_Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3, _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2, _Add_29998d0d53254a89af2d8b2baedfd332_Out_2);
            float _Add_6ec522987d504e818dd5f6d33104ee55_Out_2;
            Unity_Add_float(_Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0, 1, _Add_6ec522987d504e818dd5f6d33104ee55_Out_2);
            float _Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2;
            Unity_Divide_float(_Add_29998d0d53254a89af2d8b2baedfd332_Out_2, _Add_6ec522987d504e818dd5f6d33104ee55_Out_2, _Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2);
            float3 _Multiply_de0ffea2f7e0425d845f8a8b7131e078_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2.xxx), _Multiply_de0ffea2f7e0425d845f8a8b7131e078_Out_2);
            float3 _Multiply_d6c6bfb6aa73441fa8c68c76e66086f9_Out_2;
            Unity_Multiply_float3_float3((_Property_fefa513c01724d8ab75dd3332e8ca1a9_Out_0.xxx), _Multiply_de0ffea2f7e0425d845f8a8b7131e078_Out_2, _Multiply_d6c6bfb6aa73441fa8c68c76e66086f9_Out_2);
            float3 _Add_ab90fd41f6fd42e1a94942c33fca0dc3_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_d6c6bfb6aa73441fa8c68c76e66086f9_Out_2, _Add_ab90fd41f6fd42e1a94942c33fca0dc3_Out_2);
            float3 _Add_fd933f550505425caf812611c33b5405_Out_2;
            Unity_Add_float3(_Multiply_a027f29d61de4d57b7b43aa6d9b179dc_Out_2, _Add_ab90fd41f6fd42e1a94942c33fca0dc3_Out_2, _Add_fd933f550505425caf812611c33b5405_Out_2);
            description.Position = _Add_fd933f550505425caf812611c33b5405_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_1445156fcebf4ffc8c96120674f48392_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_1445156fcebf4ffc8c96120674f48392_Out_1);
            float4 _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0 = IN.ScreenPosition;
            float _Split_20ac0327e97147fcad31a4edfbaadfff_R_1 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[0];
            float _Split_20ac0327e97147fcad31a4edfbaadfff_G_2 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[1];
            float _Split_20ac0327e97147fcad31a4edfbaadfff_B_3 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[2];
            float _Split_20ac0327e97147fcad31a4edfbaadfff_A_4 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[3];
            float _Subtract_7c1a93a030ef421686bbee6b739bad50_Out_2;
            Unity_Subtract_float(_Split_20ac0327e97147fcad31a4edfbaadfff_A_4, 1, _Subtract_7c1a93a030ef421686bbee6b739bad50_Out_2);
            float _Subtract_02f894cc1e32412eb02601836af73907_Out_2;
            Unity_Subtract_float(_SceneDepth_1445156fcebf4ffc8c96120674f48392_Out_1, _Subtract_7c1a93a030ef421686bbee6b739bad50_Out_2, _Subtract_02f894cc1e32412eb02601836af73907_Out_2);
            float _Property_c3a2ef45c7994aa5a1a193e18d269929_Out_0 = _CloudDensity;
            float _Divide_ebdf44b2c9b84b2fb284d02eeac4fb2c_Out_2;
            Unity_Divide_float(_Subtract_02f894cc1e32412eb02601836af73907_Out_2, _Property_c3a2ef45c7994aa5a1a193e18d269929_Out_0, _Divide_ebdf44b2c9b84b2fb284d02eeac4fb2c_Out_2);
            float _Saturate_de5e588c20ff4724a90c4ac5e20d6ef1_Out_1;
            Unity_Saturate_float(_Divide_ebdf44b2c9b84b2fb284d02eeac4fb2c_Out_2, _Saturate_de5e588c20ff4724a90c4ac5e20d6ef1_Out_1);
            surface.Alpha = _Saturate_de5e588c20ff4724a90c4ac5e20d6ef1_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }
        
        // Render State
        Cull Off
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALS
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _NoiseScale;
        float _NoiseSpeed;
        float _NoiseHeight;
        float4 _RemapSettings;
        float4 _ColorA;
        float4 _ColorB;
        float _NoiseEdge_2;
        float _NoiseEdge_1;
        float _NoisePower;
        float _BaseScale;
        float _BaseSpeed;
        float _BaseStrenght;
        float _EmmsionStrength;
        float _CurvatureRadoius;
        float _FressnelPower;
        float _FressnelOpacity;
        float _CloudDensity;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_2863dc92b6d74402b0f32cb2c401b69d_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_2863dc92b6d74402b0f32cb2c401b69d_Out_2);
            float _Property_6df4e77a3809438595c25ee246a7d2cd_Out_0 = _CurvatureRadoius;
            float _Divide_de337321412f429eb063af28777eb6ff_Out_2;
            Unity_Divide_float(_Distance_2863dc92b6d74402b0f32cb2c401b69d_Out_2, _Property_6df4e77a3809438595c25ee246a7d2cd_Out_0, _Divide_de337321412f429eb063af28777eb6ff_Out_2);
            float _Power_70280d5b57474d6db604f0b5f120b300_Out_2;
            Unity_Power_float(_Divide_de337321412f429eb063af28777eb6ff_Out_2, 3, _Power_70280d5b57474d6db604f0b5f120b300_Out_2);
            float3 _Multiply_a027f29d61de4d57b7b43aa6d9b179dc_Out_2;
            Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Power_70280d5b57474d6db604f0b5f120b300_Out_2.xxx), _Multiply_a027f29d61de4d57b7b43aa6d9b179dc_Out_2);
            float _Property_fefa513c01724d8ab75dd3332e8ca1a9_Out_0 = _NoiseHeight;
            float _Property_f0eb7ef7a3bc4dfda71e328d952abdc8_Out_0 = _NoiseEdge_1;
            float _Property_657d0b2b1ea3480995b8268a02809f28_Out_0 = _NoiseEdge_2;
            float3 _RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, float3 (1, 0, 0), 90, _RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3);
            float _Property_3947645305e34f39ac1f299738ebda99_Out_0 = _NoiseSpeed;
            float _Multiply_67e3f559250b4506978f5f580e820d64_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_3947645305e34f39ac1f299738ebda99_Out_0, _Multiply_67e3f559250b4506978f5f580e820d64_Out_2);
            float2 _TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), (_Multiply_67e3f559250b4506978f5f580e820d64_Out_2.xx), _TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3);
            float _Property_662c5c608b96480b97105ea008d323bc_Out_0 = _NoiseScale;
            float _GradientNoise_14092826abfc47279af304e84345d4d8_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3, _Property_662c5c608b96480b97105ea008d323bc_Out_0, _GradientNoise_14092826abfc47279af304e84345d4d8_Out_2);
            float2 _TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3);
            float _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3, _Property_662c5c608b96480b97105ea008d323bc_Out_0, _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2);
            float _Add_cbc089d51efa495caabb9fec5f21b91b_Out_2;
            Unity_Add_float(_GradientNoise_14092826abfc47279af304e84345d4d8_Out_2, _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2, _Add_cbc089d51efa495caabb9fec5f21b91b_Out_2);
            float _Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2;
            Unity_Divide_float(_Add_cbc089d51efa495caabb9fec5f21b91b_Out_2, 2, _Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2);
            float _Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1;
            Unity_Saturate_float(_Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2, _Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1);
            float _Property_8ec8d96f44a1446a89088f4fcfadc90a_Out_0 = _NoisePower;
            float _Power_972441ad163b41ad82e4183c8e58f482_Out_2;
            Unity_Power_float(_Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1, _Property_8ec8d96f44a1446a89088f4fcfadc90a_Out_0, _Power_972441ad163b41ad82e4183c8e58f482_Out_2);
            float4 _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0 = _RemapSettings;
            float _Split_00f91e501ce64bf6ae829204af6d2179_R_1 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[0];
            float _Split_00f91e501ce64bf6ae829204af6d2179_G_2 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[1];
            float _Split_00f91e501ce64bf6ae829204af6d2179_B_3 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[2];
            float _Split_00f91e501ce64bf6ae829204af6d2179_A_4 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[3];
            float2 _Vector2_5aa5459107114aaeb9a83fb648e0bc26_Out_0 = float2(_Split_00f91e501ce64bf6ae829204af6d2179_R_1, _Split_00f91e501ce64bf6ae829204af6d2179_G_2);
            float2 _Vector2_8aefe5df870e4b569abd97dfc4ee992f_Out_0 = float2(_Split_00f91e501ce64bf6ae829204af6d2179_B_3, _Split_00f91e501ce64bf6ae829204af6d2179_A_4);
            float _Remap_e78987da05d74d6cb721111bc0f21abf_Out_3;
            Unity_Remap_float(_Power_972441ad163b41ad82e4183c8e58f482_Out_2, _Vector2_5aa5459107114aaeb9a83fb648e0bc26_Out_0, _Vector2_8aefe5df870e4b569abd97dfc4ee992f_Out_0, _Remap_e78987da05d74d6cb721111bc0f21abf_Out_3);
            float _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1;
            Unity_Absolute_float(_Remap_e78987da05d74d6cb721111bc0f21abf_Out_3, _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1);
            float _Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3;
            Unity_Smoothstep_float(_Property_f0eb7ef7a3bc4dfda71e328d952abdc8_Out_0, _Property_657d0b2b1ea3480995b8268a02809f28_Out_0, _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1, _Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3);
            float _Property_83795617af3f40c0ab30f49b66478b73_Out_0 = _BaseSpeed;
            float _Multiply_a58beadd6372454682e1871d39a8681a_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_83795617af3f40c0ab30f49b66478b73_Out_0, _Multiply_a58beadd6372454682e1871d39a8681a_Out_2);
            float2 _TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), (_Multiply_a58beadd6372454682e1871d39a8681a_Out_2.xx), _TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3);
            float _Property_4fedba3e833c4179be61d16460fb664e_Out_0 = _BaseScale;
            float _GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3, _Property_4fedba3e833c4179be61d16460fb664e_Out_0, _GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2);
            float _Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0 = _BaseStrenght;
            float _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2;
            Unity_Multiply_float_float(_GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2, _Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0, _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2);
            float _Add_29998d0d53254a89af2d8b2baedfd332_Out_2;
            Unity_Add_float(_Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3, _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2, _Add_29998d0d53254a89af2d8b2baedfd332_Out_2);
            float _Add_6ec522987d504e818dd5f6d33104ee55_Out_2;
            Unity_Add_float(_Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0, 1, _Add_6ec522987d504e818dd5f6d33104ee55_Out_2);
            float _Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2;
            Unity_Divide_float(_Add_29998d0d53254a89af2d8b2baedfd332_Out_2, _Add_6ec522987d504e818dd5f6d33104ee55_Out_2, _Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2);
            float3 _Multiply_de0ffea2f7e0425d845f8a8b7131e078_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2.xxx), _Multiply_de0ffea2f7e0425d845f8a8b7131e078_Out_2);
            float3 _Multiply_d6c6bfb6aa73441fa8c68c76e66086f9_Out_2;
            Unity_Multiply_float3_float3((_Property_fefa513c01724d8ab75dd3332e8ca1a9_Out_0.xxx), _Multiply_de0ffea2f7e0425d845f8a8b7131e078_Out_2, _Multiply_d6c6bfb6aa73441fa8c68c76e66086f9_Out_2);
            float3 _Add_ab90fd41f6fd42e1a94942c33fca0dc3_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_d6c6bfb6aa73441fa8c68c76e66086f9_Out_2, _Add_ab90fd41f6fd42e1a94942c33fca0dc3_Out_2);
            float3 _Add_fd933f550505425caf812611c33b5405_Out_2;
            Unity_Add_float3(_Multiply_a027f29d61de4d57b7b43aa6d9b179dc_Out_2, _Add_ab90fd41f6fd42e1a94942c33fca0dc3_Out_2, _Add_fd933f550505425caf812611c33b5405_Out_2);
            description.Position = _Add_fd933f550505425caf812611c33b5405_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_1445156fcebf4ffc8c96120674f48392_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_1445156fcebf4ffc8c96120674f48392_Out_1);
            float4 _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0 = IN.ScreenPosition;
            float _Split_20ac0327e97147fcad31a4edfbaadfff_R_1 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[0];
            float _Split_20ac0327e97147fcad31a4edfbaadfff_G_2 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[1];
            float _Split_20ac0327e97147fcad31a4edfbaadfff_B_3 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[2];
            float _Split_20ac0327e97147fcad31a4edfbaadfff_A_4 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[3];
            float _Subtract_7c1a93a030ef421686bbee6b739bad50_Out_2;
            Unity_Subtract_float(_Split_20ac0327e97147fcad31a4edfbaadfff_A_4, 1, _Subtract_7c1a93a030ef421686bbee6b739bad50_Out_2);
            float _Subtract_02f894cc1e32412eb02601836af73907_Out_2;
            Unity_Subtract_float(_SceneDepth_1445156fcebf4ffc8c96120674f48392_Out_1, _Subtract_7c1a93a030ef421686bbee6b739bad50_Out_2, _Subtract_02f894cc1e32412eb02601836af73907_Out_2);
            float _Property_c3a2ef45c7994aa5a1a193e18d269929_Out_0 = _CloudDensity;
            float _Divide_ebdf44b2c9b84b2fb284d02eeac4fb2c_Out_2;
            Unity_Divide_float(_Subtract_02f894cc1e32412eb02601836af73907_Out_2, _Property_c3a2ef45c7994aa5a1a193e18d269929_Out_0, _Divide_ebdf44b2c9b84b2fb284d02eeac4fb2c_Out_2);
            float _Saturate_de5e588c20ff4724a90c4ac5e20d6ef1_Out_1;
            Unity_Saturate_float(_Divide_ebdf44b2c9b84b2fb284d02eeac4fb2c_Out_2, _Saturate_de5e588c20ff4724a90c4ac5e20d6ef1_Out_1);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Alpha = _Saturate_de5e588c20ff4724a90c4ac5e20d6ef1_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma shader_feature _ EDITOR_VISUALIZATION
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD1
        #define VARYINGS_NEED_TEXCOORD2
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        #define _FOG_FRAGMENT 1
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 texCoord0;
             float4 texCoord1;
             float4 texCoord2;
             float3 viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 WorldSpaceViewDirection;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float4 interp3 : INTERP3;
             float4 interp4 : INTERP4;
             float3 interp5 : INTERP5;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.texCoord0;
            output.interp3.xyzw =  input.texCoord1;
            output.interp4.xyzw =  input.texCoord2;
            output.interp5.xyz =  input.viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.texCoord0 = input.interp2.xyzw;
            output.texCoord1 = input.interp3.xyzw;
            output.texCoord2 = input.interp4.xyzw;
            output.viewDirectionWS = input.interp5.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _NoiseScale;
        float _NoiseSpeed;
        float _NoiseHeight;
        float4 _RemapSettings;
        float4 _ColorA;
        float4 _ColorB;
        float _NoiseEdge_2;
        float _NoiseEdge_1;
        float _NoisePower;
        float _BaseScale;
        float _BaseSpeed;
        float _BaseStrenght;
        float _EmmsionStrength;
        float _CurvatureRadoius;
        float _FressnelPower;
        float _FressnelOpacity;
        float _CloudDensity;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_2863dc92b6d74402b0f32cb2c401b69d_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_2863dc92b6d74402b0f32cb2c401b69d_Out_2);
            float _Property_6df4e77a3809438595c25ee246a7d2cd_Out_0 = _CurvatureRadoius;
            float _Divide_de337321412f429eb063af28777eb6ff_Out_2;
            Unity_Divide_float(_Distance_2863dc92b6d74402b0f32cb2c401b69d_Out_2, _Property_6df4e77a3809438595c25ee246a7d2cd_Out_0, _Divide_de337321412f429eb063af28777eb6ff_Out_2);
            float _Power_70280d5b57474d6db604f0b5f120b300_Out_2;
            Unity_Power_float(_Divide_de337321412f429eb063af28777eb6ff_Out_2, 3, _Power_70280d5b57474d6db604f0b5f120b300_Out_2);
            float3 _Multiply_a027f29d61de4d57b7b43aa6d9b179dc_Out_2;
            Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Power_70280d5b57474d6db604f0b5f120b300_Out_2.xxx), _Multiply_a027f29d61de4d57b7b43aa6d9b179dc_Out_2);
            float _Property_fefa513c01724d8ab75dd3332e8ca1a9_Out_0 = _NoiseHeight;
            float _Property_f0eb7ef7a3bc4dfda71e328d952abdc8_Out_0 = _NoiseEdge_1;
            float _Property_657d0b2b1ea3480995b8268a02809f28_Out_0 = _NoiseEdge_2;
            float3 _RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, float3 (1, 0, 0), 90, _RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3);
            float _Property_3947645305e34f39ac1f299738ebda99_Out_0 = _NoiseSpeed;
            float _Multiply_67e3f559250b4506978f5f580e820d64_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_3947645305e34f39ac1f299738ebda99_Out_0, _Multiply_67e3f559250b4506978f5f580e820d64_Out_2);
            float2 _TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), (_Multiply_67e3f559250b4506978f5f580e820d64_Out_2.xx), _TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3);
            float _Property_662c5c608b96480b97105ea008d323bc_Out_0 = _NoiseScale;
            float _GradientNoise_14092826abfc47279af304e84345d4d8_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3, _Property_662c5c608b96480b97105ea008d323bc_Out_0, _GradientNoise_14092826abfc47279af304e84345d4d8_Out_2);
            float2 _TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3);
            float _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3, _Property_662c5c608b96480b97105ea008d323bc_Out_0, _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2);
            float _Add_cbc089d51efa495caabb9fec5f21b91b_Out_2;
            Unity_Add_float(_GradientNoise_14092826abfc47279af304e84345d4d8_Out_2, _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2, _Add_cbc089d51efa495caabb9fec5f21b91b_Out_2);
            float _Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2;
            Unity_Divide_float(_Add_cbc089d51efa495caabb9fec5f21b91b_Out_2, 2, _Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2);
            float _Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1;
            Unity_Saturate_float(_Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2, _Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1);
            float _Property_8ec8d96f44a1446a89088f4fcfadc90a_Out_0 = _NoisePower;
            float _Power_972441ad163b41ad82e4183c8e58f482_Out_2;
            Unity_Power_float(_Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1, _Property_8ec8d96f44a1446a89088f4fcfadc90a_Out_0, _Power_972441ad163b41ad82e4183c8e58f482_Out_2);
            float4 _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0 = _RemapSettings;
            float _Split_00f91e501ce64bf6ae829204af6d2179_R_1 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[0];
            float _Split_00f91e501ce64bf6ae829204af6d2179_G_2 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[1];
            float _Split_00f91e501ce64bf6ae829204af6d2179_B_3 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[2];
            float _Split_00f91e501ce64bf6ae829204af6d2179_A_4 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[3];
            float2 _Vector2_5aa5459107114aaeb9a83fb648e0bc26_Out_0 = float2(_Split_00f91e501ce64bf6ae829204af6d2179_R_1, _Split_00f91e501ce64bf6ae829204af6d2179_G_2);
            float2 _Vector2_8aefe5df870e4b569abd97dfc4ee992f_Out_0 = float2(_Split_00f91e501ce64bf6ae829204af6d2179_B_3, _Split_00f91e501ce64bf6ae829204af6d2179_A_4);
            float _Remap_e78987da05d74d6cb721111bc0f21abf_Out_3;
            Unity_Remap_float(_Power_972441ad163b41ad82e4183c8e58f482_Out_2, _Vector2_5aa5459107114aaeb9a83fb648e0bc26_Out_0, _Vector2_8aefe5df870e4b569abd97dfc4ee992f_Out_0, _Remap_e78987da05d74d6cb721111bc0f21abf_Out_3);
            float _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1;
            Unity_Absolute_float(_Remap_e78987da05d74d6cb721111bc0f21abf_Out_3, _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1);
            float _Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3;
            Unity_Smoothstep_float(_Property_f0eb7ef7a3bc4dfda71e328d952abdc8_Out_0, _Property_657d0b2b1ea3480995b8268a02809f28_Out_0, _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1, _Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3);
            float _Property_83795617af3f40c0ab30f49b66478b73_Out_0 = _BaseSpeed;
            float _Multiply_a58beadd6372454682e1871d39a8681a_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_83795617af3f40c0ab30f49b66478b73_Out_0, _Multiply_a58beadd6372454682e1871d39a8681a_Out_2);
            float2 _TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), (_Multiply_a58beadd6372454682e1871d39a8681a_Out_2.xx), _TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3);
            float _Property_4fedba3e833c4179be61d16460fb664e_Out_0 = _BaseScale;
            float _GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3, _Property_4fedba3e833c4179be61d16460fb664e_Out_0, _GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2);
            float _Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0 = _BaseStrenght;
            float _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2;
            Unity_Multiply_float_float(_GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2, _Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0, _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2);
            float _Add_29998d0d53254a89af2d8b2baedfd332_Out_2;
            Unity_Add_float(_Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3, _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2, _Add_29998d0d53254a89af2d8b2baedfd332_Out_2);
            float _Add_6ec522987d504e818dd5f6d33104ee55_Out_2;
            Unity_Add_float(_Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0, 1, _Add_6ec522987d504e818dd5f6d33104ee55_Out_2);
            float _Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2;
            Unity_Divide_float(_Add_29998d0d53254a89af2d8b2baedfd332_Out_2, _Add_6ec522987d504e818dd5f6d33104ee55_Out_2, _Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2);
            float3 _Multiply_de0ffea2f7e0425d845f8a8b7131e078_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2.xxx), _Multiply_de0ffea2f7e0425d845f8a8b7131e078_Out_2);
            float3 _Multiply_d6c6bfb6aa73441fa8c68c76e66086f9_Out_2;
            Unity_Multiply_float3_float3((_Property_fefa513c01724d8ab75dd3332e8ca1a9_Out_0.xxx), _Multiply_de0ffea2f7e0425d845f8a8b7131e078_Out_2, _Multiply_d6c6bfb6aa73441fa8c68c76e66086f9_Out_2);
            float3 _Add_ab90fd41f6fd42e1a94942c33fca0dc3_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_d6c6bfb6aa73441fa8c68c76e66086f9_Out_2, _Add_ab90fd41f6fd42e1a94942c33fca0dc3_Out_2);
            float3 _Add_fd933f550505425caf812611c33b5405_Out_2;
            Unity_Add_float3(_Multiply_a027f29d61de4d57b7b43aa6d9b179dc_Out_2, _Add_ab90fd41f6fd42e1a94942c33fca0dc3_Out_2, _Add_fd933f550505425caf812611c33b5405_Out_2);
            description.Position = _Add_fd933f550505425caf812611c33b5405_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_f0eb7ef7a3bc4dfda71e328d952abdc8_Out_0 = _NoiseEdge_1;
            float _Property_657d0b2b1ea3480995b8268a02809f28_Out_0 = _NoiseEdge_2;
            float3 _RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, float3 (1, 0, 0), 90, _RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3);
            float _Property_3947645305e34f39ac1f299738ebda99_Out_0 = _NoiseSpeed;
            float _Multiply_67e3f559250b4506978f5f580e820d64_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_3947645305e34f39ac1f299738ebda99_Out_0, _Multiply_67e3f559250b4506978f5f580e820d64_Out_2);
            float2 _TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), (_Multiply_67e3f559250b4506978f5f580e820d64_Out_2.xx), _TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3);
            float _Property_662c5c608b96480b97105ea008d323bc_Out_0 = _NoiseScale;
            float _GradientNoise_14092826abfc47279af304e84345d4d8_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3, _Property_662c5c608b96480b97105ea008d323bc_Out_0, _GradientNoise_14092826abfc47279af304e84345d4d8_Out_2);
            float2 _TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3);
            float _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3, _Property_662c5c608b96480b97105ea008d323bc_Out_0, _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2);
            float _Add_cbc089d51efa495caabb9fec5f21b91b_Out_2;
            Unity_Add_float(_GradientNoise_14092826abfc47279af304e84345d4d8_Out_2, _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2, _Add_cbc089d51efa495caabb9fec5f21b91b_Out_2);
            float _Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2;
            Unity_Divide_float(_Add_cbc089d51efa495caabb9fec5f21b91b_Out_2, 2, _Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2);
            float _Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1;
            Unity_Saturate_float(_Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2, _Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1);
            float _Property_8ec8d96f44a1446a89088f4fcfadc90a_Out_0 = _NoisePower;
            float _Power_972441ad163b41ad82e4183c8e58f482_Out_2;
            Unity_Power_float(_Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1, _Property_8ec8d96f44a1446a89088f4fcfadc90a_Out_0, _Power_972441ad163b41ad82e4183c8e58f482_Out_2);
            float4 _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0 = _RemapSettings;
            float _Split_00f91e501ce64bf6ae829204af6d2179_R_1 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[0];
            float _Split_00f91e501ce64bf6ae829204af6d2179_G_2 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[1];
            float _Split_00f91e501ce64bf6ae829204af6d2179_B_3 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[2];
            float _Split_00f91e501ce64bf6ae829204af6d2179_A_4 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[3];
            float2 _Vector2_5aa5459107114aaeb9a83fb648e0bc26_Out_0 = float2(_Split_00f91e501ce64bf6ae829204af6d2179_R_1, _Split_00f91e501ce64bf6ae829204af6d2179_G_2);
            float2 _Vector2_8aefe5df870e4b569abd97dfc4ee992f_Out_0 = float2(_Split_00f91e501ce64bf6ae829204af6d2179_B_3, _Split_00f91e501ce64bf6ae829204af6d2179_A_4);
            float _Remap_e78987da05d74d6cb721111bc0f21abf_Out_3;
            Unity_Remap_float(_Power_972441ad163b41ad82e4183c8e58f482_Out_2, _Vector2_5aa5459107114aaeb9a83fb648e0bc26_Out_0, _Vector2_8aefe5df870e4b569abd97dfc4ee992f_Out_0, _Remap_e78987da05d74d6cb721111bc0f21abf_Out_3);
            float _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1;
            Unity_Absolute_float(_Remap_e78987da05d74d6cb721111bc0f21abf_Out_3, _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1);
            float _Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3;
            Unity_Smoothstep_float(_Property_f0eb7ef7a3bc4dfda71e328d952abdc8_Out_0, _Property_657d0b2b1ea3480995b8268a02809f28_Out_0, _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1, _Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3);
            float _Property_83795617af3f40c0ab30f49b66478b73_Out_0 = _BaseSpeed;
            float _Multiply_a58beadd6372454682e1871d39a8681a_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_83795617af3f40c0ab30f49b66478b73_Out_0, _Multiply_a58beadd6372454682e1871d39a8681a_Out_2);
            float2 _TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), (_Multiply_a58beadd6372454682e1871d39a8681a_Out_2.xx), _TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3);
            float _Property_4fedba3e833c4179be61d16460fb664e_Out_0 = _BaseScale;
            float _GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3, _Property_4fedba3e833c4179be61d16460fb664e_Out_0, _GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2);
            float _Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0 = _BaseStrenght;
            float _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2;
            Unity_Multiply_float_float(_GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2, _Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0, _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2);
            float _Add_29998d0d53254a89af2d8b2baedfd332_Out_2;
            Unity_Add_float(_Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3, _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2, _Add_29998d0d53254a89af2d8b2baedfd332_Out_2);
            float _Add_6ec522987d504e818dd5f6d33104ee55_Out_2;
            Unity_Add_float(_Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0, 1, _Add_6ec522987d504e818dd5f6d33104ee55_Out_2);
            float _Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2;
            Unity_Divide_float(_Add_29998d0d53254a89af2d8b2baedfd332_Out_2, _Add_6ec522987d504e818dd5f6d33104ee55_Out_2, _Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2);
            float _Property_5e6909be7142479cb5595465ab7396ab_Out_0 = _FressnelPower;
            float _FresnelEffect_6ad385502ba442bbbfd08c8289b8addd_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_5e6909be7142479cb5595465ab7396ab_Out_0, _FresnelEffect_6ad385502ba442bbbfd08c8289b8addd_Out_3);
            float _Multiply_28a1d2721a9b469da8137faff3ce48b6_Out_2;
            Unity_Multiply_float_float(_Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2, _FresnelEffect_6ad385502ba442bbbfd08c8289b8addd_Out_3, _Multiply_28a1d2721a9b469da8137faff3ce48b6_Out_2);
            float _Property_2bb7638bbe5e46abb573c3169b6fd8a0_Out_0 = _FressnelOpacity;
            float _Multiply_223cf800f8854807ba5c4b69d74abfb9_Out_2;
            Unity_Multiply_float_float(_Multiply_28a1d2721a9b469da8137faff3ce48b6_Out_2, _Property_2bb7638bbe5e46abb573c3169b6fd8a0_Out_0, _Multiply_223cf800f8854807ba5c4b69d74abfb9_Out_2);
            float4 _Property_9e04c6a53cf14db8af5075df14bdf933_Out_0 = _ColorA;
            float4 _Property_b8fd511244174f46a8116607e59c88de_Out_0 = _ColorB;
            float4 _Lerp_b4d037eea01443f981d467219a9716cb_Out_3;
            Unity_Lerp_float4(_Property_9e04c6a53cf14db8af5075df14bdf933_Out_0, _Property_b8fd511244174f46a8116607e59c88de_Out_0, (_Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2.xxxx), _Lerp_b4d037eea01443f981d467219a9716cb_Out_3);
            float4 _Add_d4f711b802874114a3aaedfa0820123c_Out_2;
            Unity_Add_float4((_Multiply_223cf800f8854807ba5c4b69d74abfb9_Out_2.xxxx), _Lerp_b4d037eea01443f981d467219a9716cb_Out_3, _Add_d4f711b802874114a3aaedfa0820123c_Out_2);
            float _Property_01447423b08c408283d759fb2cdebc7a_Out_0 = _EmmsionStrength;
            float4 _Multiply_336e0a5f825c42458362ed5f9974b35a_Out_2;
            Unity_Multiply_float4_float4(_Add_d4f711b802874114a3aaedfa0820123c_Out_2, (_Property_01447423b08c408283d759fb2cdebc7a_Out_0.xxxx), _Multiply_336e0a5f825c42458362ed5f9974b35a_Out_2);
            float _SceneDepth_1445156fcebf4ffc8c96120674f48392_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_1445156fcebf4ffc8c96120674f48392_Out_1);
            float4 _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0 = IN.ScreenPosition;
            float _Split_20ac0327e97147fcad31a4edfbaadfff_R_1 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[0];
            float _Split_20ac0327e97147fcad31a4edfbaadfff_G_2 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[1];
            float _Split_20ac0327e97147fcad31a4edfbaadfff_B_3 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[2];
            float _Split_20ac0327e97147fcad31a4edfbaadfff_A_4 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[3];
            float _Subtract_7c1a93a030ef421686bbee6b739bad50_Out_2;
            Unity_Subtract_float(_Split_20ac0327e97147fcad31a4edfbaadfff_A_4, 1, _Subtract_7c1a93a030ef421686bbee6b739bad50_Out_2);
            float _Subtract_02f894cc1e32412eb02601836af73907_Out_2;
            Unity_Subtract_float(_SceneDepth_1445156fcebf4ffc8c96120674f48392_Out_1, _Subtract_7c1a93a030ef421686bbee6b739bad50_Out_2, _Subtract_02f894cc1e32412eb02601836af73907_Out_2);
            float _Property_c3a2ef45c7994aa5a1a193e18d269929_Out_0 = _CloudDensity;
            float _Divide_ebdf44b2c9b84b2fb284d02eeac4fb2c_Out_2;
            Unity_Divide_float(_Subtract_02f894cc1e32412eb02601836af73907_Out_2, _Property_c3a2ef45c7994aa5a1a193e18d269929_Out_0, _Divide_ebdf44b2c9b84b2fb284d02eeac4fb2c_Out_2);
            float _Saturate_de5e588c20ff4724a90c4ac5e20d6ef1_Out_1;
            Unity_Saturate_float(_Divide_ebdf44b2c9b84b2fb284d02eeac4fb2c_Out_2, _Saturate_de5e588c20ff4724a90c4ac5e20d6ef1_Out_1);
            surface.BaseColor = (_Add_d4f711b802874114a3aaedfa0820123c_Out_2.xyz);
            surface.Emission = (_Multiply_336e0a5f825c42458362ed5f9974b35a_Out_2.xyz);
            surface.Alpha = _Saturate_de5e588c20ff4724a90c4ac5e20d6ef1_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        
        
            output.WorldSpaceViewDirection = normalize(input.viewDirectionWS);
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _NoiseScale;
        float _NoiseSpeed;
        float _NoiseHeight;
        float4 _RemapSettings;
        float4 _ColorA;
        float4 _ColorB;
        float _NoiseEdge_2;
        float _NoiseEdge_1;
        float _NoisePower;
        float _BaseScale;
        float _BaseSpeed;
        float _BaseStrenght;
        float _EmmsionStrength;
        float _CurvatureRadoius;
        float _FressnelPower;
        float _FressnelOpacity;
        float _CloudDensity;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_2863dc92b6d74402b0f32cb2c401b69d_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_2863dc92b6d74402b0f32cb2c401b69d_Out_2);
            float _Property_6df4e77a3809438595c25ee246a7d2cd_Out_0 = _CurvatureRadoius;
            float _Divide_de337321412f429eb063af28777eb6ff_Out_2;
            Unity_Divide_float(_Distance_2863dc92b6d74402b0f32cb2c401b69d_Out_2, _Property_6df4e77a3809438595c25ee246a7d2cd_Out_0, _Divide_de337321412f429eb063af28777eb6ff_Out_2);
            float _Power_70280d5b57474d6db604f0b5f120b300_Out_2;
            Unity_Power_float(_Divide_de337321412f429eb063af28777eb6ff_Out_2, 3, _Power_70280d5b57474d6db604f0b5f120b300_Out_2);
            float3 _Multiply_a027f29d61de4d57b7b43aa6d9b179dc_Out_2;
            Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Power_70280d5b57474d6db604f0b5f120b300_Out_2.xxx), _Multiply_a027f29d61de4d57b7b43aa6d9b179dc_Out_2);
            float _Property_fefa513c01724d8ab75dd3332e8ca1a9_Out_0 = _NoiseHeight;
            float _Property_f0eb7ef7a3bc4dfda71e328d952abdc8_Out_0 = _NoiseEdge_1;
            float _Property_657d0b2b1ea3480995b8268a02809f28_Out_0 = _NoiseEdge_2;
            float3 _RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, float3 (1, 0, 0), 90, _RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3);
            float _Property_3947645305e34f39ac1f299738ebda99_Out_0 = _NoiseSpeed;
            float _Multiply_67e3f559250b4506978f5f580e820d64_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_3947645305e34f39ac1f299738ebda99_Out_0, _Multiply_67e3f559250b4506978f5f580e820d64_Out_2);
            float2 _TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), (_Multiply_67e3f559250b4506978f5f580e820d64_Out_2.xx), _TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3);
            float _Property_662c5c608b96480b97105ea008d323bc_Out_0 = _NoiseScale;
            float _GradientNoise_14092826abfc47279af304e84345d4d8_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3, _Property_662c5c608b96480b97105ea008d323bc_Out_0, _GradientNoise_14092826abfc47279af304e84345d4d8_Out_2);
            float2 _TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3);
            float _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3, _Property_662c5c608b96480b97105ea008d323bc_Out_0, _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2);
            float _Add_cbc089d51efa495caabb9fec5f21b91b_Out_2;
            Unity_Add_float(_GradientNoise_14092826abfc47279af304e84345d4d8_Out_2, _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2, _Add_cbc089d51efa495caabb9fec5f21b91b_Out_2);
            float _Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2;
            Unity_Divide_float(_Add_cbc089d51efa495caabb9fec5f21b91b_Out_2, 2, _Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2);
            float _Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1;
            Unity_Saturate_float(_Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2, _Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1);
            float _Property_8ec8d96f44a1446a89088f4fcfadc90a_Out_0 = _NoisePower;
            float _Power_972441ad163b41ad82e4183c8e58f482_Out_2;
            Unity_Power_float(_Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1, _Property_8ec8d96f44a1446a89088f4fcfadc90a_Out_0, _Power_972441ad163b41ad82e4183c8e58f482_Out_2);
            float4 _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0 = _RemapSettings;
            float _Split_00f91e501ce64bf6ae829204af6d2179_R_1 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[0];
            float _Split_00f91e501ce64bf6ae829204af6d2179_G_2 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[1];
            float _Split_00f91e501ce64bf6ae829204af6d2179_B_3 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[2];
            float _Split_00f91e501ce64bf6ae829204af6d2179_A_4 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[3];
            float2 _Vector2_5aa5459107114aaeb9a83fb648e0bc26_Out_0 = float2(_Split_00f91e501ce64bf6ae829204af6d2179_R_1, _Split_00f91e501ce64bf6ae829204af6d2179_G_2);
            float2 _Vector2_8aefe5df870e4b569abd97dfc4ee992f_Out_0 = float2(_Split_00f91e501ce64bf6ae829204af6d2179_B_3, _Split_00f91e501ce64bf6ae829204af6d2179_A_4);
            float _Remap_e78987da05d74d6cb721111bc0f21abf_Out_3;
            Unity_Remap_float(_Power_972441ad163b41ad82e4183c8e58f482_Out_2, _Vector2_5aa5459107114aaeb9a83fb648e0bc26_Out_0, _Vector2_8aefe5df870e4b569abd97dfc4ee992f_Out_0, _Remap_e78987da05d74d6cb721111bc0f21abf_Out_3);
            float _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1;
            Unity_Absolute_float(_Remap_e78987da05d74d6cb721111bc0f21abf_Out_3, _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1);
            float _Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3;
            Unity_Smoothstep_float(_Property_f0eb7ef7a3bc4dfda71e328d952abdc8_Out_0, _Property_657d0b2b1ea3480995b8268a02809f28_Out_0, _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1, _Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3);
            float _Property_83795617af3f40c0ab30f49b66478b73_Out_0 = _BaseSpeed;
            float _Multiply_a58beadd6372454682e1871d39a8681a_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_83795617af3f40c0ab30f49b66478b73_Out_0, _Multiply_a58beadd6372454682e1871d39a8681a_Out_2);
            float2 _TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), (_Multiply_a58beadd6372454682e1871d39a8681a_Out_2.xx), _TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3);
            float _Property_4fedba3e833c4179be61d16460fb664e_Out_0 = _BaseScale;
            float _GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3, _Property_4fedba3e833c4179be61d16460fb664e_Out_0, _GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2);
            float _Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0 = _BaseStrenght;
            float _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2;
            Unity_Multiply_float_float(_GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2, _Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0, _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2);
            float _Add_29998d0d53254a89af2d8b2baedfd332_Out_2;
            Unity_Add_float(_Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3, _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2, _Add_29998d0d53254a89af2d8b2baedfd332_Out_2);
            float _Add_6ec522987d504e818dd5f6d33104ee55_Out_2;
            Unity_Add_float(_Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0, 1, _Add_6ec522987d504e818dd5f6d33104ee55_Out_2);
            float _Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2;
            Unity_Divide_float(_Add_29998d0d53254a89af2d8b2baedfd332_Out_2, _Add_6ec522987d504e818dd5f6d33104ee55_Out_2, _Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2);
            float3 _Multiply_de0ffea2f7e0425d845f8a8b7131e078_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2.xxx), _Multiply_de0ffea2f7e0425d845f8a8b7131e078_Out_2);
            float3 _Multiply_d6c6bfb6aa73441fa8c68c76e66086f9_Out_2;
            Unity_Multiply_float3_float3((_Property_fefa513c01724d8ab75dd3332e8ca1a9_Out_0.xxx), _Multiply_de0ffea2f7e0425d845f8a8b7131e078_Out_2, _Multiply_d6c6bfb6aa73441fa8c68c76e66086f9_Out_2);
            float3 _Add_ab90fd41f6fd42e1a94942c33fca0dc3_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_d6c6bfb6aa73441fa8c68c76e66086f9_Out_2, _Add_ab90fd41f6fd42e1a94942c33fca0dc3_Out_2);
            float3 _Add_fd933f550505425caf812611c33b5405_Out_2;
            Unity_Add_float3(_Multiply_a027f29d61de4d57b7b43aa6d9b179dc_Out_2, _Add_ab90fd41f6fd42e1a94942c33fca0dc3_Out_2, _Add_fd933f550505425caf812611c33b5405_Out_2);
            description.Position = _Add_fd933f550505425caf812611c33b5405_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_1445156fcebf4ffc8c96120674f48392_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_1445156fcebf4ffc8c96120674f48392_Out_1);
            float4 _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0 = IN.ScreenPosition;
            float _Split_20ac0327e97147fcad31a4edfbaadfff_R_1 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[0];
            float _Split_20ac0327e97147fcad31a4edfbaadfff_G_2 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[1];
            float _Split_20ac0327e97147fcad31a4edfbaadfff_B_3 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[2];
            float _Split_20ac0327e97147fcad31a4edfbaadfff_A_4 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[3];
            float _Subtract_7c1a93a030ef421686bbee6b739bad50_Out_2;
            Unity_Subtract_float(_Split_20ac0327e97147fcad31a4edfbaadfff_A_4, 1, _Subtract_7c1a93a030ef421686bbee6b739bad50_Out_2);
            float _Subtract_02f894cc1e32412eb02601836af73907_Out_2;
            Unity_Subtract_float(_SceneDepth_1445156fcebf4ffc8c96120674f48392_Out_1, _Subtract_7c1a93a030ef421686bbee6b739bad50_Out_2, _Subtract_02f894cc1e32412eb02601836af73907_Out_2);
            float _Property_c3a2ef45c7994aa5a1a193e18d269929_Out_0 = _CloudDensity;
            float _Divide_ebdf44b2c9b84b2fb284d02eeac4fb2c_Out_2;
            Unity_Divide_float(_Subtract_02f894cc1e32412eb02601836af73907_Out_2, _Property_c3a2ef45c7994aa5a1a193e18d269929_Out_0, _Divide_ebdf44b2c9b84b2fb284d02eeac4fb2c_Out_2);
            float _Saturate_de5e588c20ff4724a90c4ac5e20d6ef1_Out_1;
            Unity_Saturate_float(_Divide_ebdf44b2c9b84b2fb284d02eeac4fb2c_Out_2, _Saturate_de5e588c20ff4724a90c4ac5e20d6ef1_Out_1);
            surface.Alpha = _Saturate_de5e588c20ff4724a90c4ac5e20d6ef1_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _NoiseScale;
        float _NoiseSpeed;
        float _NoiseHeight;
        float4 _RemapSettings;
        float4 _ColorA;
        float4 _ColorB;
        float _NoiseEdge_2;
        float _NoiseEdge_1;
        float _NoisePower;
        float _BaseScale;
        float _BaseSpeed;
        float _BaseStrenght;
        float _EmmsionStrength;
        float _CurvatureRadoius;
        float _FressnelPower;
        float _FressnelOpacity;
        float _CloudDensity;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_2863dc92b6d74402b0f32cb2c401b69d_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_2863dc92b6d74402b0f32cb2c401b69d_Out_2);
            float _Property_6df4e77a3809438595c25ee246a7d2cd_Out_0 = _CurvatureRadoius;
            float _Divide_de337321412f429eb063af28777eb6ff_Out_2;
            Unity_Divide_float(_Distance_2863dc92b6d74402b0f32cb2c401b69d_Out_2, _Property_6df4e77a3809438595c25ee246a7d2cd_Out_0, _Divide_de337321412f429eb063af28777eb6ff_Out_2);
            float _Power_70280d5b57474d6db604f0b5f120b300_Out_2;
            Unity_Power_float(_Divide_de337321412f429eb063af28777eb6ff_Out_2, 3, _Power_70280d5b57474d6db604f0b5f120b300_Out_2);
            float3 _Multiply_a027f29d61de4d57b7b43aa6d9b179dc_Out_2;
            Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Power_70280d5b57474d6db604f0b5f120b300_Out_2.xxx), _Multiply_a027f29d61de4d57b7b43aa6d9b179dc_Out_2);
            float _Property_fefa513c01724d8ab75dd3332e8ca1a9_Out_0 = _NoiseHeight;
            float _Property_f0eb7ef7a3bc4dfda71e328d952abdc8_Out_0 = _NoiseEdge_1;
            float _Property_657d0b2b1ea3480995b8268a02809f28_Out_0 = _NoiseEdge_2;
            float3 _RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, float3 (1, 0, 0), 90, _RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3);
            float _Property_3947645305e34f39ac1f299738ebda99_Out_0 = _NoiseSpeed;
            float _Multiply_67e3f559250b4506978f5f580e820d64_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_3947645305e34f39ac1f299738ebda99_Out_0, _Multiply_67e3f559250b4506978f5f580e820d64_Out_2);
            float2 _TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), (_Multiply_67e3f559250b4506978f5f580e820d64_Out_2.xx), _TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3);
            float _Property_662c5c608b96480b97105ea008d323bc_Out_0 = _NoiseScale;
            float _GradientNoise_14092826abfc47279af304e84345d4d8_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3, _Property_662c5c608b96480b97105ea008d323bc_Out_0, _GradientNoise_14092826abfc47279af304e84345d4d8_Out_2);
            float2 _TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3);
            float _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3, _Property_662c5c608b96480b97105ea008d323bc_Out_0, _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2);
            float _Add_cbc089d51efa495caabb9fec5f21b91b_Out_2;
            Unity_Add_float(_GradientNoise_14092826abfc47279af304e84345d4d8_Out_2, _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2, _Add_cbc089d51efa495caabb9fec5f21b91b_Out_2);
            float _Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2;
            Unity_Divide_float(_Add_cbc089d51efa495caabb9fec5f21b91b_Out_2, 2, _Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2);
            float _Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1;
            Unity_Saturate_float(_Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2, _Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1);
            float _Property_8ec8d96f44a1446a89088f4fcfadc90a_Out_0 = _NoisePower;
            float _Power_972441ad163b41ad82e4183c8e58f482_Out_2;
            Unity_Power_float(_Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1, _Property_8ec8d96f44a1446a89088f4fcfadc90a_Out_0, _Power_972441ad163b41ad82e4183c8e58f482_Out_2);
            float4 _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0 = _RemapSettings;
            float _Split_00f91e501ce64bf6ae829204af6d2179_R_1 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[0];
            float _Split_00f91e501ce64bf6ae829204af6d2179_G_2 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[1];
            float _Split_00f91e501ce64bf6ae829204af6d2179_B_3 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[2];
            float _Split_00f91e501ce64bf6ae829204af6d2179_A_4 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[3];
            float2 _Vector2_5aa5459107114aaeb9a83fb648e0bc26_Out_0 = float2(_Split_00f91e501ce64bf6ae829204af6d2179_R_1, _Split_00f91e501ce64bf6ae829204af6d2179_G_2);
            float2 _Vector2_8aefe5df870e4b569abd97dfc4ee992f_Out_0 = float2(_Split_00f91e501ce64bf6ae829204af6d2179_B_3, _Split_00f91e501ce64bf6ae829204af6d2179_A_4);
            float _Remap_e78987da05d74d6cb721111bc0f21abf_Out_3;
            Unity_Remap_float(_Power_972441ad163b41ad82e4183c8e58f482_Out_2, _Vector2_5aa5459107114aaeb9a83fb648e0bc26_Out_0, _Vector2_8aefe5df870e4b569abd97dfc4ee992f_Out_0, _Remap_e78987da05d74d6cb721111bc0f21abf_Out_3);
            float _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1;
            Unity_Absolute_float(_Remap_e78987da05d74d6cb721111bc0f21abf_Out_3, _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1);
            float _Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3;
            Unity_Smoothstep_float(_Property_f0eb7ef7a3bc4dfda71e328d952abdc8_Out_0, _Property_657d0b2b1ea3480995b8268a02809f28_Out_0, _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1, _Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3);
            float _Property_83795617af3f40c0ab30f49b66478b73_Out_0 = _BaseSpeed;
            float _Multiply_a58beadd6372454682e1871d39a8681a_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_83795617af3f40c0ab30f49b66478b73_Out_0, _Multiply_a58beadd6372454682e1871d39a8681a_Out_2);
            float2 _TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), (_Multiply_a58beadd6372454682e1871d39a8681a_Out_2.xx), _TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3);
            float _Property_4fedba3e833c4179be61d16460fb664e_Out_0 = _BaseScale;
            float _GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3, _Property_4fedba3e833c4179be61d16460fb664e_Out_0, _GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2);
            float _Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0 = _BaseStrenght;
            float _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2;
            Unity_Multiply_float_float(_GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2, _Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0, _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2);
            float _Add_29998d0d53254a89af2d8b2baedfd332_Out_2;
            Unity_Add_float(_Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3, _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2, _Add_29998d0d53254a89af2d8b2baedfd332_Out_2);
            float _Add_6ec522987d504e818dd5f6d33104ee55_Out_2;
            Unity_Add_float(_Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0, 1, _Add_6ec522987d504e818dd5f6d33104ee55_Out_2);
            float _Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2;
            Unity_Divide_float(_Add_29998d0d53254a89af2d8b2baedfd332_Out_2, _Add_6ec522987d504e818dd5f6d33104ee55_Out_2, _Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2);
            float3 _Multiply_de0ffea2f7e0425d845f8a8b7131e078_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2.xxx), _Multiply_de0ffea2f7e0425d845f8a8b7131e078_Out_2);
            float3 _Multiply_d6c6bfb6aa73441fa8c68c76e66086f9_Out_2;
            Unity_Multiply_float3_float3((_Property_fefa513c01724d8ab75dd3332e8ca1a9_Out_0.xxx), _Multiply_de0ffea2f7e0425d845f8a8b7131e078_Out_2, _Multiply_d6c6bfb6aa73441fa8c68c76e66086f9_Out_2);
            float3 _Add_ab90fd41f6fd42e1a94942c33fca0dc3_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_d6c6bfb6aa73441fa8c68c76e66086f9_Out_2, _Add_ab90fd41f6fd42e1a94942c33fca0dc3_Out_2);
            float3 _Add_fd933f550505425caf812611c33b5405_Out_2;
            Unity_Add_float3(_Multiply_a027f29d61de4d57b7b43aa6d9b179dc_Out_2, _Add_ab90fd41f6fd42e1a94942c33fca0dc3_Out_2, _Add_fd933f550505425caf812611c33b5405_Out_2);
            description.Position = _Add_fd933f550505425caf812611c33b5405_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_1445156fcebf4ffc8c96120674f48392_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_1445156fcebf4ffc8c96120674f48392_Out_1);
            float4 _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0 = IN.ScreenPosition;
            float _Split_20ac0327e97147fcad31a4edfbaadfff_R_1 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[0];
            float _Split_20ac0327e97147fcad31a4edfbaadfff_G_2 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[1];
            float _Split_20ac0327e97147fcad31a4edfbaadfff_B_3 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[2];
            float _Split_20ac0327e97147fcad31a4edfbaadfff_A_4 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[3];
            float _Subtract_7c1a93a030ef421686bbee6b739bad50_Out_2;
            Unity_Subtract_float(_Split_20ac0327e97147fcad31a4edfbaadfff_A_4, 1, _Subtract_7c1a93a030ef421686bbee6b739bad50_Out_2);
            float _Subtract_02f894cc1e32412eb02601836af73907_Out_2;
            Unity_Subtract_float(_SceneDepth_1445156fcebf4ffc8c96120674f48392_Out_1, _Subtract_7c1a93a030ef421686bbee6b739bad50_Out_2, _Subtract_02f894cc1e32412eb02601836af73907_Out_2);
            float _Property_c3a2ef45c7994aa5a1a193e18d269929_Out_0 = _CloudDensity;
            float _Divide_ebdf44b2c9b84b2fb284d02eeac4fb2c_Out_2;
            Unity_Divide_float(_Subtract_02f894cc1e32412eb02601836af73907_Out_2, _Property_c3a2ef45c7994aa5a1a193e18d269929_Out_0, _Divide_ebdf44b2c9b84b2fb284d02eeac4fb2c_Out_2);
            float _Saturate_de5e588c20ff4724a90c4ac5e20d6ef1_Out_1;
            Unity_Saturate_float(_Divide_ebdf44b2c9b84b2fb284d02eeac4fb2c_Out_2, _Saturate_de5e588c20ff4724a90c4ac5e20d6ef1_Out_1);
            surface.Alpha = _Saturate_de5e588c20ff4724a90c4ac5e20d6ef1_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            // Name: <None>
            Tags
            {
                "LightMode" = "Universal2D"
            }
        
        // Render State
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_2D
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float3 viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 WorldSpaceViewDirection;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float3 interp2 : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyz =  input.viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.viewDirectionWS = input.interp2.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _NoiseScale;
        float _NoiseSpeed;
        float _NoiseHeight;
        float4 _RemapSettings;
        float4 _ColorA;
        float4 _ColorB;
        float _NoiseEdge_2;
        float _NoiseEdge_1;
        float _NoisePower;
        float _BaseScale;
        float _BaseSpeed;
        float _BaseStrenght;
        float _EmmsionStrength;
        float _CurvatureRadoius;
        float _FressnelPower;
        float _FressnelOpacity;
        float _CloudDensity;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_2863dc92b6d74402b0f32cb2c401b69d_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_2863dc92b6d74402b0f32cb2c401b69d_Out_2);
            float _Property_6df4e77a3809438595c25ee246a7d2cd_Out_0 = _CurvatureRadoius;
            float _Divide_de337321412f429eb063af28777eb6ff_Out_2;
            Unity_Divide_float(_Distance_2863dc92b6d74402b0f32cb2c401b69d_Out_2, _Property_6df4e77a3809438595c25ee246a7d2cd_Out_0, _Divide_de337321412f429eb063af28777eb6ff_Out_2);
            float _Power_70280d5b57474d6db604f0b5f120b300_Out_2;
            Unity_Power_float(_Divide_de337321412f429eb063af28777eb6ff_Out_2, 3, _Power_70280d5b57474d6db604f0b5f120b300_Out_2);
            float3 _Multiply_a027f29d61de4d57b7b43aa6d9b179dc_Out_2;
            Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Power_70280d5b57474d6db604f0b5f120b300_Out_2.xxx), _Multiply_a027f29d61de4d57b7b43aa6d9b179dc_Out_2);
            float _Property_fefa513c01724d8ab75dd3332e8ca1a9_Out_0 = _NoiseHeight;
            float _Property_f0eb7ef7a3bc4dfda71e328d952abdc8_Out_0 = _NoiseEdge_1;
            float _Property_657d0b2b1ea3480995b8268a02809f28_Out_0 = _NoiseEdge_2;
            float3 _RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, float3 (1, 0, 0), 90, _RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3);
            float _Property_3947645305e34f39ac1f299738ebda99_Out_0 = _NoiseSpeed;
            float _Multiply_67e3f559250b4506978f5f580e820d64_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_3947645305e34f39ac1f299738ebda99_Out_0, _Multiply_67e3f559250b4506978f5f580e820d64_Out_2);
            float2 _TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), (_Multiply_67e3f559250b4506978f5f580e820d64_Out_2.xx), _TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3);
            float _Property_662c5c608b96480b97105ea008d323bc_Out_0 = _NoiseScale;
            float _GradientNoise_14092826abfc47279af304e84345d4d8_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3, _Property_662c5c608b96480b97105ea008d323bc_Out_0, _GradientNoise_14092826abfc47279af304e84345d4d8_Out_2);
            float2 _TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3);
            float _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3, _Property_662c5c608b96480b97105ea008d323bc_Out_0, _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2);
            float _Add_cbc089d51efa495caabb9fec5f21b91b_Out_2;
            Unity_Add_float(_GradientNoise_14092826abfc47279af304e84345d4d8_Out_2, _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2, _Add_cbc089d51efa495caabb9fec5f21b91b_Out_2);
            float _Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2;
            Unity_Divide_float(_Add_cbc089d51efa495caabb9fec5f21b91b_Out_2, 2, _Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2);
            float _Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1;
            Unity_Saturate_float(_Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2, _Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1);
            float _Property_8ec8d96f44a1446a89088f4fcfadc90a_Out_0 = _NoisePower;
            float _Power_972441ad163b41ad82e4183c8e58f482_Out_2;
            Unity_Power_float(_Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1, _Property_8ec8d96f44a1446a89088f4fcfadc90a_Out_0, _Power_972441ad163b41ad82e4183c8e58f482_Out_2);
            float4 _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0 = _RemapSettings;
            float _Split_00f91e501ce64bf6ae829204af6d2179_R_1 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[0];
            float _Split_00f91e501ce64bf6ae829204af6d2179_G_2 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[1];
            float _Split_00f91e501ce64bf6ae829204af6d2179_B_3 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[2];
            float _Split_00f91e501ce64bf6ae829204af6d2179_A_4 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[3];
            float2 _Vector2_5aa5459107114aaeb9a83fb648e0bc26_Out_0 = float2(_Split_00f91e501ce64bf6ae829204af6d2179_R_1, _Split_00f91e501ce64bf6ae829204af6d2179_G_2);
            float2 _Vector2_8aefe5df870e4b569abd97dfc4ee992f_Out_0 = float2(_Split_00f91e501ce64bf6ae829204af6d2179_B_3, _Split_00f91e501ce64bf6ae829204af6d2179_A_4);
            float _Remap_e78987da05d74d6cb721111bc0f21abf_Out_3;
            Unity_Remap_float(_Power_972441ad163b41ad82e4183c8e58f482_Out_2, _Vector2_5aa5459107114aaeb9a83fb648e0bc26_Out_0, _Vector2_8aefe5df870e4b569abd97dfc4ee992f_Out_0, _Remap_e78987da05d74d6cb721111bc0f21abf_Out_3);
            float _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1;
            Unity_Absolute_float(_Remap_e78987da05d74d6cb721111bc0f21abf_Out_3, _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1);
            float _Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3;
            Unity_Smoothstep_float(_Property_f0eb7ef7a3bc4dfda71e328d952abdc8_Out_0, _Property_657d0b2b1ea3480995b8268a02809f28_Out_0, _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1, _Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3);
            float _Property_83795617af3f40c0ab30f49b66478b73_Out_0 = _BaseSpeed;
            float _Multiply_a58beadd6372454682e1871d39a8681a_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_83795617af3f40c0ab30f49b66478b73_Out_0, _Multiply_a58beadd6372454682e1871d39a8681a_Out_2);
            float2 _TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), (_Multiply_a58beadd6372454682e1871d39a8681a_Out_2.xx), _TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3);
            float _Property_4fedba3e833c4179be61d16460fb664e_Out_0 = _BaseScale;
            float _GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3, _Property_4fedba3e833c4179be61d16460fb664e_Out_0, _GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2);
            float _Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0 = _BaseStrenght;
            float _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2;
            Unity_Multiply_float_float(_GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2, _Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0, _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2);
            float _Add_29998d0d53254a89af2d8b2baedfd332_Out_2;
            Unity_Add_float(_Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3, _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2, _Add_29998d0d53254a89af2d8b2baedfd332_Out_2);
            float _Add_6ec522987d504e818dd5f6d33104ee55_Out_2;
            Unity_Add_float(_Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0, 1, _Add_6ec522987d504e818dd5f6d33104ee55_Out_2);
            float _Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2;
            Unity_Divide_float(_Add_29998d0d53254a89af2d8b2baedfd332_Out_2, _Add_6ec522987d504e818dd5f6d33104ee55_Out_2, _Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2);
            float3 _Multiply_de0ffea2f7e0425d845f8a8b7131e078_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2.xxx), _Multiply_de0ffea2f7e0425d845f8a8b7131e078_Out_2);
            float3 _Multiply_d6c6bfb6aa73441fa8c68c76e66086f9_Out_2;
            Unity_Multiply_float3_float3((_Property_fefa513c01724d8ab75dd3332e8ca1a9_Out_0.xxx), _Multiply_de0ffea2f7e0425d845f8a8b7131e078_Out_2, _Multiply_d6c6bfb6aa73441fa8c68c76e66086f9_Out_2);
            float3 _Add_ab90fd41f6fd42e1a94942c33fca0dc3_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_d6c6bfb6aa73441fa8c68c76e66086f9_Out_2, _Add_ab90fd41f6fd42e1a94942c33fca0dc3_Out_2);
            float3 _Add_fd933f550505425caf812611c33b5405_Out_2;
            Unity_Add_float3(_Multiply_a027f29d61de4d57b7b43aa6d9b179dc_Out_2, _Add_ab90fd41f6fd42e1a94942c33fca0dc3_Out_2, _Add_fd933f550505425caf812611c33b5405_Out_2);
            description.Position = _Add_fd933f550505425caf812611c33b5405_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_f0eb7ef7a3bc4dfda71e328d952abdc8_Out_0 = _NoiseEdge_1;
            float _Property_657d0b2b1ea3480995b8268a02809f28_Out_0 = _NoiseEdge_2;
            float3 _RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, float3 (1, 0, 0), 90, _RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3);
            float _Property_3947645305e34f39ac1f299738ebda99_Out_0 = _NoiseSpeed;
            float _Multiply_67e3f559250b4506978f5f580e820d64_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_3947645305e34f39ac1f299738ebda99_Out_0, _Multiply_67e3f559250b4506978f5f580e820d64_Out_2);
            float2 _TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), (_Multiply_67e3f559250b4506978f5f580e820d64_Out_2.xx), _TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3);
            float _Property_662c5c608b96480b97105ea008d323bc_Out_0 = _NoiseScale;
            float _GradientNoise_14092826abfc47279af304e84345d4d8_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3, _Property_662c5c608b96480b97105ea008d323bc_Out_0, _GradientNoise_14092826abfc47279af304e84345d4d8_Out_2);
            float2 _TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3);
            float _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3, _Property_662c5c608b96480b97105ea008d323bc_Out_0, _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2);
            float _Add_cbc089d51efa495caabb9fec5f21b91b_Out_2;
            Unity_Add_float(_GradientNoise_14092826abfc47279af304e84345d4d8_Out_2, _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2, _Add_cbc089d51efa495caabb9fec5f21b91b_Out_2);
            float _Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2;
            Unity_Divide_float(_Add_cbc089d51efa495caabb9fec5f21b91b_Out_2, 2, _Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2);
            float _Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1;
            Unity_Saturate_float(_Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2, _Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1);
            float _Property_8ec8d96f44a1446a89088f4fcfadc90a_Out_0 = _NoisePower;
            float _Power_972441ad163b41ad82e4183c8e58f482_Out_2;
            Unity_Power_float(_Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1, _Property_8ec8d96f44a1446a89088f4fcfadc90a_Out_0, _Power_972441ad163b41ad82e4183c8e58f482_Out_2);
            float4 _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0 = _RemapSettings;
            float _Split_00f91e501ce64bf6ae829204af6d2179_R_1 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[0];
            float _Split_00f91e501ce64bf6ae829204af6d2179_G_2 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[1];
            float _Split_00f91e501ce64bf6ae829204af6d2179_B_3 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[2];
            float _Split_00f91e501ce64bf6ae829204af6d2179_A_4 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[3];
            float2 _Vector2_5aa5459107114aaeb9a83fb648e0bc26_Out_0 = float2(_Split_00f91e501ce64bf6ae829204af6d2179_R_1, _Split_00f91e501ce64bf6ae829204af6d2179_G_2);
            float2 _Vector2_8aefe5df870e4b569abd97dfc4ee992f_Out_0 = float2(_Split_00f91e501ce64bf6ae829204af6d2179_B_3, _Split_00f91e501ce64bf6ae829204af6d2179_A_4);
            float _Remap_e78987da05d74d6cb721111bc0f21abf_Out_3;
            Unity_Remap_float(_Power_972441ad163b41ad82e4183c8e58f482_Out_2, _Vector2_5aa5459107114aaeb9a83fb648e0bc26_Out_0, _Vector2_8aefe5df870e4b569abd97dfc4ee992f_Out_0, _Remap_e78987da05d74d6cb721111bc0f21abf_Out_3);
            float _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1;
            Unity_Absolute_float(_Remap_e78987da05d74d6cb721111bc0f21abf_Out_3, _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1);
            float _Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3;
            Unity_Smoothstep_float(_Property_f0eb7ef7a3bc4dfda71e328d952abdc8_Out_0, _Property_657d0b2b1ea3480995b8268a02809f28_Out_0, _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1, _Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3);
            float _Property_83795617af3f40c0ab30f49b66478b73_Out_0 = _BaseSpeed;
            float _Multiply_a58beadd6372454682e1871d39a8681a_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_83795617af3f40c0ab30f49b66478b73_Out_0, _Multiply_a58beadd6372454682e1871d39a8681a_Out_2);
            float2 _TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), (_Multiply_a58beadd6372454682e1871d39a8681a_Out_2.xx), _TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3);
            float _Property_4fedba3e833c4179be61d16460fb664e_Out_0 = _BaseScale;
            float _GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3, _Property_4fedba3e833c4179be61d16460fb664e_Out_0, _GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2);
            float _Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0 = _BaseStrenght;
            float _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2;
            Unity_Multiply_float_float(_GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2, _Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0, _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2);
            float _Add_29998d0d53254a89af2d8b2baedfd332_Out_2;
            Unity_Add_float(_Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3, _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2, _Add_29998d0d53254a89af2d8b2baedfd332_Out_2);
            float _Add_6ec522987d504e818dd5f6d33104ee55_Out_2;
            Unity_Add_float(_Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0, 1, _Add_6ec522987d504e818dd5f6d33104ee55_Out_2);
            float _Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2;
            Unity_Divide_float(_Add_29998d0d53254a89af2d8b2baedfd332_Out_2, _Add_6ec522987d504e818dd5f6d33104ee55_Out_2, _Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2);
            float _Property_5e6909be7142479cb5595465ab7396ab_Out_0 = _FressnelPower;
            float _FresnelEffect_6ad385502ba442bbbfd08c8289b8addd_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_5e6909be7142479cb5595465ab7396ab_Out_0, _FresnelEffect_6ad385502ba442bbbfd08c8289b8addd_Out_3);
            float _Multiply_28a1d2721a9b469da8137faff3ce48b6_Out_2;
            Unity_Multiply_float_float(_Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2, _FresnelEffect_6ad385502ba442bbbfd08c8289b8addd_Out_3, _Multiply_28a1d2721a9b469da8137faff3ce48b6_Out_2);
            float _Property_2bb7638bbe5e46abb573c3169b6fd8a0_Out_0 = _FressnelOpacity;
            float _Multiply_223cf800f8854807ba5c4b69d74abfb9_Out_2;
            Unity_Multiply_float_float(_Multiply_28a1d2721a9b469da8137faff3ce48b6_Out_2, _Property_2bb7638bbe5e46abb573c3169b6fd8a0_Out_0, _Multiply_223cf800f8854807ba5c4b69d74abfb9_Out_2);
            float4 _Property_9e04c6a53cf14db8af5075df14bdf933_Out_0 = _ColorA;
            float4 _Property_b8fd511244174f46a8116607e59c88de_Out_0 = _ColorB;
            float4 _Lerp_b4d037eea01443f981d467219a9716cb_Out_3;
            Unity_Lerp_float4(_Property_9e04c6a53cf14db8af5075df14bdf933_Out_0, _Property_b8fd511244174f46a8116607e59c88de_Out_0, (_Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2.xxxx), _Lerp_b4d037eea01443f981d467219a9716cb_Out_3);
            float4 _Add_d4f711b802874114a3aaedfa0820123c_Out_2;
            Unity_Add_float4((_Multiply_223cf800f8854807ba5c4b69d74abfb9_Out_2.xxxx), _Lerp_b4d037eea01443f981d467219a9716cb_Out_3, _Add_d4f711b802874114a3aaedfa0820123c_Out_2);
            float _SceneDepth_1445156fcebf4ffc8c96120674f48392_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_1445156fcebf4ffc8c96120674f48392_Out_1);
            float4 _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0 = IN.ScreenPosition;
            float _Split_20ac0327e97147fcad31a4edfbaadfff_R_1 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[0];
            float _Split_20ac0327e97147fcad31a4edfbaadfff_G_2 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[1];
            float _Split_20ac0327e97147fcad31a4edfbaadfff_B_3 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[2];
            float _Split_20ac0327e97147fcad31a4edfbaadfff_A_4 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[3];
            float _Subtract_7c1a93a030ef421686bbee6b739bad50_Out_2;
            Unity_Subtract_float(_Split_20ac0327e97147fcad31a4edfbaadfff_A_4, 1, _Subtract_7c1a93a030ef421686bbee6b739bad50_Out_2);
            float _Subtract_02f894cc1e32412eb02601836af73907_Out_2;
            Unity_Subtract_float(_SceneDepth_1445156fcebf4ffc8c96120674f48392_Out_1, _Subtract_7c1a93a030ef421686bbee6b739bad50_Out_2, _Subtract_02f894cc1e32412eb02601836af73907_Out_2);
            float _Property_c3a2ef45c7994aa5a1a193e18d269929_Out_0 = _CloudDensity;
            float _Divide_ebdf44b2c9b84b2fb284d02eeac4fb2c_Out_2;
            Unity_Divide_float(_Subtract_02f894cc1e32412eb02601836af73907_Out_2, _Property_c3a2ef45c7994aa5a1a193e18d269929_Out_0, _Divide_ebdf44b2c9b84b2fb284d02eeac4fb2c_Out_2);
            float _Saturate_de5e588c20ff4724a90c4ac5e20d6ef1_Out_1;
            Unity_Saturate_float(_Divide_ebdf44b2c9b84b2fb284d02eeac4fb2c_Out_2, _Saturate_de5e588c20ff4724a90c4ac5e20d6ef1_Out_1);
            surface.BaseColor = (_Add_d4f711b802874114a3aaedfa0820123c_Out_2.xyz);
            surface.Alpha = _Saturate_de5e588c20ff4724a90c4ac5e20d6ef1_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        
        
            output.WorldSpaceViewDirection = normalize(input.viewDirectionWS);
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue"="Transparent"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalLitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
        
        // Render State
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _LIGHT_COOKIES
        #pragma multi_compile _ _CLUSTERED_RENDERING
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 TangentSpaceNormal;
             float3 WorldSpaceViewDirection;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float3 interp3 : INTERP3;
             float2 interp4 : INTERP4;
             float2 interp5 : INTERP5;
             float3 interp6 : INTERP6;
             float4 interp7 : INTERP7;
             float4 interp8 : INTERP8;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp4.xy =  input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.interp5.xy =  input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp6.xyz =  input.sh;
            #endif
            output.interp7.xyzw =  input.fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.interp8.xyzw =  input.shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.viewDirectionWS = input.interp3.xyz;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.interp4.xy;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.interp5.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp6.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp7.xyzw;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.interp8.xyzw;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _NoiseScale;
        float _NoiseSpeed;
        float _NoiseHeight;
        float4 _RemapSettings;
        float4 _ColorA;
        float4 _ColorB;
        float _NoiseEdge_2;
        float _NoiseEdge_1;
        float _NoisePower;
        float _BaseScale;
        float _BaseSpeed;
        float _BaseStrenght;
        float _EmmsionStrength;
        float _CurvatureRadoius;
        float _FressnelPower;
        float _FressnelOpacity;
        float _CloudDensity;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_2863dc92b6d74402b0f32cb2c401b69d_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_2863dc92b6d74402b0f32cb2c401b69d_Out_2);
            float _Property_6df4e77a3809438595c25ee246a7d2cd_Out_0 = _CurvatureRadoius;
            float _Divide_de337321412f429eb063af28777eb6ff_Out_2;
            Unity_Divide_float(_Distance_2863dc92b6d74402b0f32cb2c401b69d_Out_2, _Property_6df4e77a3809438595c25ee246a7d2cd_Out_0, _Divide_de337321412f429eb063af28777eb6ff_Out_2);
            float _Power_70280d5b57474d6db604f0b5f120b300_Out_2;
            Unity_Power_float(_Divide_de337321412f429eb063af28777eb6ff_Out_2, 3, _Power_70280d5b57474d6db604f0b5f120b300_Out_2);
            float3 _Multiply_a027f29d61de4d57b7b43aa6d9b179dc_Out_2;
            Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Power_70280d5b57474d6db604f0b5f120b300_Out_2.xxx), _Multiply_a027f29d61de4d57b7b43aa6d9b179dc_Out_2);
            float _Property_fefa513c01724d8ab75dd3332e8ca1a9_Out_0 = _NoiseHeight;
            float _Property_f0eb7ef7a3bc4dfda71e328d952abdc8_Out_0 = _NoiseEdge_1;
            float _Property_657d0b2b1ea3480995b8268a02809f28_Out_0 = _NoiseEdge_2;
            float3 _RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, float3 (1, 0, 0), 90, _RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3);
            float _Property_3947645305e34f39ac1f299738ebda99_Out_0 = _NoiseSpeed;
            float _Multiply_67e3f559250b4506978f5f580e820d64_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_3947645305e34f39ac1f299738ebda99_Out_0, _Multiply_67e3f559250b4506978f5f580e820d64_Out_2);
            float2 _TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), (_Multiply_67e3f559250b4506978f5f580e820d64_Out_2.xx), _TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3);
            float _Property_662c5c608b96480b97105ea008d323bc_Out_0 = _NoiseScale;
            float _GradientNoise_14092826abfc47279af304e84345d4d8_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3, _Property_662c5c608b96480b97105ea008d323bc_Out_0, _GradientNoise_14092826abfc47279af304e84345d4d8_Out_2);
            float2 _TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3);
            float _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3, _Property_662c5c608b96480b97105ea008d323bc_Out_0, _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2);
            float _Add_cbc089d51efa495caabb9fec5f21b91b_Out_2;
            Unity_Add_float(_GradientNoise_14092826abfc47279af304e84345d4d8_Out_2, _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2, _Add_cbc089d51efa495caabb9fec5f21b91b_Out_2);
            float _Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2;
            Unity_Divide_float(_Add_cbc089d51efa495caabb9fec5f21b91b_Out_2, 2, _Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2);
            float _Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1;
            Unity_Saturate_float(_Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2, _Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1);
            float _Property_8ec8d96f44a1446a89088f4fcfadc90a_Out_0 = _NoisePower;
            float _Power_972441ad163b41ad82e4183c8e58f482_Out_2;
            Unity_Power_float(_Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1, _Property_8ec8d96f44a1446a89088f4fcfadc90a_Out_0, _Power_972441ad163b41ad82e4183c8e58f482_Out_2);
            float4 _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0 = _RemapSettings;
            float _Split_00f91e501ce64bf6ae829204af6d2179_R_1 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[0];
            float _Split_00f91e501ce64bf6ae829204af6d2179_G_2 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[1];
            float _Split_00f91e501ce64bf6ae829204af6d2179_B_3 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[2];
            float _Split_00f91e501ce64bf6ae829204af6d2179_A_4 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[3];
            float2 _Vector2_5aa5459107114aaeb9a83fb648e0bc26_Out_0 = float2(_Split_00f91e501ce64bf6ae829204af6d2179_R_1, _Split_00f91e501ce64bf6ae829204af6d2179_G_2);
            float2 _Vector2_8aefe5df870e4b569abd97dfc4ee992f_Out_0 = float2(_Split_00f91e501ce64bf6ae829204af6d2179_B_3, _Split_00f91e501ce64bf6ae829204af6d2179_A_4);
            float _Remap_e78987da05d74d6cb721111bc0f21abf_Out_3;
            Unity_Remap_float(_Power_972441ad163b41ad82e4183c8e58f482_Out_2, _Vector2_5aa5459107114aaeb9a83fb648e0bc26_Out_0, _Vector2_8aefe5df870e4b569abd97dfc4ee992f_Out_0, _Remap_e78987da05d74d6cb721111bc0f21abf_Out_3);
            float _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1;
            Unity_Absolute_float(_Remap_e78987da05d74d6cb721111bc0f21abf_Out_3, _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1);
            float _Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3;
            Unity_Smoothstep_float(_Property_f0eb7ef7a3bc4dfda71e328d952abdc8_Out_0, _Property_657d0b2b1ea3480995b8268a02809f28_Out_0, _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1, _Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3);
            float _Property_83795617af3f40c0ab30f49b66478b73_Out_0 = _BaseSpeed;
            float _Multiply_a58beadd6372454682e1871d39a8681a_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_83795617af3f40c0ab30f49b66478b73_Out_0, _Multiply_a58beadd6372454682e1871d39a8681a_Out_2);
            float2 _TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), (_Multiply_a58beadd6372454682e1871d39a8681a_Out_2.xx), _TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3);
            float _Property_4fedba3e833c4179be61d16460fb664e_Out_0 = _BaseScale;
            float _GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3, _Property_4fedba3e833c4179be61d16460fb664e_Out_0, _GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2);
            float _Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0 = _BaseStrenght;
            float _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2;
            Unity_Multiply_float_float(_GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2, _Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0, _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2);
            float _Add_29998d0d53254a89af2d8b2baedfd332_Out_2;
            Unity_Add_float(_Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3, _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2, _Add_29998d0d53254a89af2d8b2baedfd332_Out_2);
            float _Add_6ec522987d504e818dd5f6d33104ee55_Out_2;
            Unity_Add_float(_Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0, 1, _Add_6ec522987d504e818dd5f6d33104ee55_Out_2);
            float _Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2;
            Unity_Divide_float(_Add_29998d0d53254a89af2d8b2baedfd332_Out_2, _Add_6ec522987d504e818dd5f6d33104ee55_Out_2, _Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2);
            float3 _Multiply_de0ffea2f7e0425d845f8a8b7131e078_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2.xxx), _Multiply_de0ffea2f7e0425d845f8a8b7131e078_Out_2);
            float3 _Multiply_d6c6bfb6aa73441fa8c68c76e66086f9_Out_2;
            Unity_Multiply_float3_float3((_Property_fefa513c01724d8ab75dd3332e8ca1a9_Out_0.xxx), _Multiply_de0ffea2f7e0425d845f8a8b7131e078_Out_2, _Multiply_d6c6bfb6aa73441fa8c68c76e66086f9_Out_2);
            float3 _Add_ab90fd41f6fd42e1a94942c33fca0dc3_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_d6c6bfb6aa73441fa8c68c76e66086f9_Out_2, _Add_ab90fd41f6fd42e1a94942c33fca0dc3_Out_2);
            float3 _Add_fd933f550505425caf812611c33b5405_Out_2;
            Unity_Add_float3(_Multiply_a027f29d61de4d57b7b43aa6d9b179dc_Out_2, _Add_ab90fd41f6fd42e1a94942c33fca0dc3_Out_2, _Add_fd933f550505425caf812611c33b5405_Out_2);
            description.Position = _Add_fd933f550505425caf812611c33b5405_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_f0eb7ef7a3bc4dfda71e328d952abdc8_Out_0 = _NoiseEdge_1;
            float _Property_657d0b2b1ea3480995b8268a02809f28_Out_0 = _NoiseEdge_2;
            float3 _RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, float3 (1, 0, 0), 90, _RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3);
            float _Property_3947645305e34f39ac1f299738ebda99_Out_0 = _NoiseSpeed;
            float _Multiply_67e3f559250b4506978f5f580e820d64_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_3947645305e34f39ac1f299738ebda99_Out_0, _Multiply_67e3f559250b4506978f5f580e820d64_Out_2);
            float2 _TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), (_Multiply_67e3f559250b4506978f5f580e820d64_Out_2.xx), _TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3);
            float _Property_662c5c608b96480b97105ea008d323bc_Out_0 = _NoiseScale;
            float _GradientNoise_14092826abfc47279af304e84345d4d8_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3, _Property_662c5c608b96480b97105ea008d323bc_Out_0, _GradientNoise_14092826abfc47279af304e84345d4d8_Out_2);
            float2 _TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3);
            float _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3, _Property_662c5c608b96480b97105ea008d323bc_Out_0, _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2);
            float _Add_cbc089d51efa495caabb9fec5f21b91b_Out_2;
            Unity_Add_float(_GradientNoise_14092826abfc47279af304e84345d4d8_Out_2, _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2, _Add_cbc089d51efa495caabb9fec5f21b91b_Out_2);
            float _Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2;
            Unity_Divide_float(_Add_cbc089d51efa495caabb9fec5f21b91b_Out_2, 2, _Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2);
            float _Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1;
            Unity_Saturate_float(_Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2, _Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1);
            float _Property_8ec8d96f44a1446a89088f4fcfadc90a_Out_0 = _NoisePower;
            float _Power_972441ad163b41ad82e4183c8e58f482_Out_2;
            Unity_Power_float(_Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1, _Property_8ec8d96f44a1446a89088f4fcfadc90a_Out_0, _Power_972441ad163b41ad82e4183c8e58f482_Out_2);
            float4 _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0 = _RemapSettings;
            float _Split_00f91e501ce64bf6ae829204af6d2179_R_1 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[0];
            float _Split_00f91e501ce64bf6ae829204af6d2179_G_2 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[1];
            float _Split_00f91e501ce64bf6ae829204af6d2179_B_3 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[2];
            float _Split_00f91e501ce64bf6ae829204af6d2179_A_4 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[3];
            float2 _Vector2_5aa5459107114aaeb9a83fb648e0bc26_Out_0 = float2(_Split_00f91e501ce64bf6ae829204af6d2179_R_1, _Split_00f91e501ce64bf6ae829204af6d2179_G_2);
            float2 _Vector2_8aefe5df870e4b569abd97dfc4ee992f_Out_0 = float2(_Split_00f91e501ce64bf6ae829204af6d2179_B_3, _Split_00f91e501ce64bf6ae829204af6d2179_A_4);
            float _Remap_e78987da05d74d6cb721111bc0f21abf_Out_3;
            Unity_Remap_float(_Power_972441ad163b41ad82e4183c8e58f482_Out_2, _Vector2_5aa5459107114aaeb9a83fb648e0bc26_Out_0, _Vector2_8aefe5df870e4b569abd97dfc4ee992f_Out_0, _Remap_e78987da05d74d6cb721111bc0f21abf_Out_3);
            float _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1;
            Unity_Absolute_float(_Remap_e78987da05d74d6cb721111bc0f21abf_Out_3, _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1);
            float _Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3;
            Unity_Smoothstep_float(_Property_f0eb7ef7a3bc4dfda71e328d952abdc8_Out_0, _Property_657d0b2b1ea3480995b8268a02809f28_Out_0, _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1, _Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3);
            float _Property_83795617af3f40c0ab30f49b66478b73_Out_0 = _BaseSpeed;
            float _Multiply_a58beadd6372454682e1871d39a8681a_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_83795617af3f40c0ab30f49b66478b73_Out_0, _Multiply_a58beadd6372454682e1871d39a8681a_Out_2);
            float2 _TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), (_Multiply_a58beadd6372454682e1871d39a8681a_Out_2.xx), _TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3);
            float _Property_4fedba3e833c4179be61d16460fb664e_Out_0 = _BaseScale;
            float _GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3, _Property_4fedba3e833c4179be61d16460fb664e_Out_0, _GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2);
            float _Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0 = _BaseStrenght;
            float _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2;
            Unity_Multiply_float_float(_GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2, _Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0, _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2);
            float _Add_29998d0d53254a89af2d8b2baedfd332_Out_2;
            Unity_Add_float(_Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3, _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2, _Add_29998d0d53254a89af2d8b2baedfd332_Out_2);
            float _Add_6ec522987d504e818dd5f6d33104ee55_Out_2;
            Unity_Add_float(_Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0, 1, _Add_6ec522987d504e818dd5f6d33104ee55_Out_2);
            float _Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2;
            Unity_Divide_float(_Add_29998d0d53254a89af2d8b2baedfd332_Out_2, _Add_6ec522987d504e818dd5f6d33104ee55_Out_2, _Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2);
            float _Property_5e6909be7142479cb5595465ab7396ab_Out_0 = _FressnelPower;
            float _FresnelEffect_6ad385502ba442bbbfd08c8289b8addd_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_5e6909be7142479cb5595465ab7396ab_Out_0, _FresnelEffect_6ad385502ba442bbbfd08c8289b8addd_Out_3);
            float _Multiply_28a1d2721a9b469da8137faff3ce48b6_Out_2;
            Unity_Multiply_float_float(_Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2, _FresnelEffect_6ad385502ba442bbbfd08c8289b8addd_Out_3, _Multiply_28a1d2721a9b469da8137faff3ce48b6_Out_2);
            float _Property_2bb7638bbe5e46abb573c3169b6fd8a0_Out_0 = _FressnelOpacity;
            float _Multiply_223cf800f8854807ba5c4b69d74abfb9_Out_2;
            Unity_Multiply_float_float(_Multiply_28a1d2721a9b469da8137faff3ce48b6_Out_2, _Property_2bb7638bbe5e46abb573c3169b6fd8a0_Out_0, _Multiply_223cf800f8854807ba5c4b69d74abfb9_Out_2);
            float4 _Property_9e04c6a53cf14db8af5075df14bdf933_Out_0 = _ColorA;
            float4 _Property_b8fd511244174f46a8116607e59c88de_Out_0 = _ColorB;
            float4 _Lerp_b4d037eea01443f981d467219a9716cb_Out_3;
            Unity_Lerp_float4(_Property_9e04c6a53cf14db8af5075df14bdf933_Out_0, _Property_b8fd511244174f46a8116607e59c88de_Out_0, (_Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2.xxxx), _Lerp_b4d037eea01443f981d467219a9716cb_Out_3);
            float4 _Add_d4f711b802874114a3aaedfa0820123c_Out_2;
            Unity_Add_float4((_Multiply_223cf800f8854807ba5c4b69d74abfb9_Out_2.xxxx), _Lerp_b4d037eea01443f981d467219a9716cb_Out_3, _Add_d4f711b802874114a3aaedfa0820123c_Out_2);
            float _Property_01447423b08c408283d759fb2cdebc7a_Out_0 = _EmmsionStrength;
            float4 _Multiply_336e0a5f825c42458362ed5f9974b35a_Out_2;
            Unity_Multiply_float4_float4(_Add_d4f711b802874114a3aaedfa0820123c_Out_2, (_Property_01447423b08c408283d759fb2cdebc7a_Out_0.xxxx), _Multiply_336e0a5f825c42458362ed5f9974b35a_Out_2);
            float _SceneDepth_1445156fcebf4ffc8c96120674f48392_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_1445156fcebf4ffc8c96120674f48392_Out_1);
            float4 _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0 = IN.ScreenPosition;
            float _Split_20ac0327e97147fcad31a4edfbaadfff_R_1 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[0];
            float _Split_20ac0327e97147fcad31a4edfbaadfff_G_2 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[1];
            float _Split_20ac0327e97147fcad31a4edfbaadfff_B_3 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[2];
            float _Split_20ac0327e97147fcad31a4edfbaadfff_A_4 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[3];
            float _Subtract_7c1a93a030ef421686bbee6b739bad50_Out_2;
            Unity_Subtract_float(_Split_20ac0327e97147fcad31a4edfbaadfff_A_4, 1, _Subtract_7c1a93a030ef421686bbee6b739bad50_Out_2);
            float _Subtract_02f894cc1e32412eb02601836af73907_Out_2;
            Unity_Subtract_float(_SceneDepth_1445156fcebf4ffc8c96120674f48392_Out_1, _Subtract_7c1a93a030ef421686bbee6b739bad50_Out_2, _Subtract_02f894cc1e32412eb02601836af73907_Out_2);
            float _Property_c3a2ef45c7994aa5a1a193e18d269929_Out_0 = _CloudDensity;
            float _Divide_ebdf44b2c9b84b2fb284d02eeac4fb2c_Out_2;
            Unity_Divide_float(_Subtract_02f894cc1e32412eb02601836af73907_Out_2, _Property_c3a2ef45c7994aa5a1a193e18d269929_Out_0, _Divide_ebdf44b2c9b84b2fb284d02eeac4fb2c_Out_2);
            float _Saturate_de5e588c20ff4724a90c4ac5e20d6ef1_Out_1;
            Unity_Saturate_float(_Divide_ebdf44b2c9b84b2fb284d02eeac4fb2c_Out_2, _Saturate_de5e588c20ff4724a90c4ac5e20d6ef1_Out_1);
            surface.BaseColor = (_Add_d4f711b802874114a3aaedfa0820123c_Out_2.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = (_Multiply_336e0a5f825c42458362ed5f9974b35a_Out_2.xyz);
            surface.Metallic = 0;
            surface.Smoothness = 0.5;
            surface.Occlusion = 1;
            surface.Alpha = _Saturate_de5e588c20ff4724a90c4ac5e20d6ef1_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.WorldSpaceViewDirection = normalize(input.viewDirectionWS);
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
        
        // Render State
        Cull Off
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _NoiseScale;
        float _NoiseSpeed;
        float _NoiseHeight;
        float4 _RemapSettings;
        float4 _ColorA;
        float4 _ColorB;
        float _NoiseEdge_2;
        float _NoiseEdge_1;
        float _NoisePower;
        float _BaseScale;
        float _BaseSpeed;
        float _BaseStrenght;
        float _EmmsionStrength;
        float _CurvatureRadoius;
        float _FressnelPower;
        float _FressnelOpacity;
        float _CloudDensity;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_2863dc92b6d74402b0f32cb2c401b69d_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_2863dc92b6d74402b0f32cb2c401b69d_Out_2);
            float _Property_6df4e77a3809438595c25ee246a7d2cd_Out_0 = _CurvatureRadoius;
            float _Divide_de337321412f429eb063af28777eb6ff_Out_2;
            Unity_Divide_float(_Distance_2863dc92b6d74402b0f32cb2c401b69d_Out_2, _Property_6df4e77a3809438595c25ee246a7d2cd_Out_0, _Divide_de337321412f429eb063af28777eb6ff_Out_2);
            float _Power_70280d5b57474d6db604f0b5f120b300_Out_2;
            Unity_Power_float(_Divide_de337321412f429eb063af28777eb6ff_Out_2, 3, _Power_70280d5b57474d6db604f0b5f120b300_Out_2);
            float3 _Multiply_a027f29d61de4d57b7b43aa6d9b179dc_Out_2;
            Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Power_70280d5b57474d6db604f0b5f120b300_Out_2.xxx), _Multiply_a027f29d61de4d57b7b43aa6d9b179dc_Out_2);
            float _Property_fefa513c01724d8ab75dd3332e8ca1a9_Out_0 = _NoiseHeight;
            float _Property_f0eb7ef7a3bc4dfda71e328d952abdc8_Out_0 = _NoiseEdge_1;
            float _Property_657d0b2b1ea3480995b8268a02809f28_Out_0 = _NoiseEdge_2;
            float3 _RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, float3 (1, 0, 0), 90, _RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3);
            float _Property_3947645305e34f39ac1f299738ebda99_Out_0 = _NoiseSpeed;
            float _Multiply_67e3f559250b4506978f5f580e820d64_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_3947645305e34f39ac1f299738ebda99_Out_0, _Multiply_67e3f559250b4506978f5f580e820d64_Out_2);
            float2 _TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), (_Multiply_67e3f559250b4506978f5f580e820d64_Out_2.xx), _TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3);
            float _Property_662c5c608b96480b97105ea008d323bc_Out_0 = _NoiseScale;
            float _GradientNoise_14092826abfc47279af304e84345d4d8_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3, _Property_662c5c608b96480b97105ea008d323bc_Out_0, _GradientNoise_14092826abfc47279af304e84345d4d8_Out_2);
            float2 _TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3);
            float _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3, _Property_662c5c608b96480b97105ea008d323bc_Out_0, _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2);
            float _Add_cbc089d51efa495caabb9fec5f21b91b_Out_2;
            Unity_Add_float(_GradientNoise_14092826abfc47279af304e84345d4d8_Out_2, _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2, _Add_cbc089d51efa495caabb9fec5f21b91b_Out_2);
            float _Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2;
            Unity_Divide_float(_Add_cbc089d51efa495caabb9fec5f21b91b_Out_2, 2, _Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2);
            float _Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1;
            Unity_Saturate_float(_Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2, _Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1);
            float _Property_8ec8d96f44a1446a89088f4fcfadc90a_Out_0 = _NoisePower;
            float _Power_972441ad163b41ad82e4183c8e58f482_Out_2;
            Unity_Power_float(_Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1, _Property_8ec8d96f44a1446a89088f4fcfadc90a_Out_0, _Power_972441ad163b41ad82e4183c8e58f482_Out_2);
            float4 _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0 = _RemapSettings;
            float _Split_00f91e501ce64bf6ae829204af6d2179_R_1 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[0];
            float _Split_00f91e501ce64bf6ae829204af6d2179_G_2 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[1];
            float _Split_00f91e501ce64bf6ae829204af6d2179_B_3 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[2];
            float _Split_00f91e501ce64bf6ae829204af6d2179_A_4 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[3];
            float2 _Vector2_5aa5459107114aaeb9a83fb648e0bc26_Out_0 = float2(_Split_00f91e501ce64bf6ae829204af6d2179_R_1, _Split_00f91e501ce64bf6ae829204af6d2179_G_2);
            float2 _Vector2_8aefe5df870e4b569abd97dfc4ee992f_Out_0 = float2(_Split_00f91e501ce64bf6ae829204af6d2179_B_3, _Split_00f91e501ce64bf6ae829204af6d2179_A_4);
            float _Remap_e78987da05d74d6cb721111bc0f21abf_Out_3;
            Unity_Remap_float(_Power_972441ad163b41ad82e4183c8e58f482_Out_2, _Vector2_5aa5459107114aaeb9a83fb648e0bc26_Out_0, _Vector2_8aefe5df870e4b569abd97dfc4ee992f_Out_0, _Remap_e78987da05d74d6cb721111bc0f21abf_Out_3);
            float _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1;
            Unity_Absolute_float(_Remap_e78987da05d74d6cb721111bc0f21abf_Out_3, _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1);
            float _Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3;
            Unity_Smoothstep_float(_Property_f0eb7ef7a3bc4dfda71e328d952abdc8_Out_0, _Property_657d0b2b1ea3480995b8268a02809f28_Out_0, _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1, _Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3);
            float _Property_83795617af3f40c0ab30f49b66478b73_Out_0 = _BaseSpeed;
            float _Multiply_a58beadd6372454682e1871d39a8681a_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_83795617af3f40c0ab30f49b66478b73_Out_0, _Multiply_a58beadd6372454682e1871d39a8681a_Out_2);
            float2 _TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), (_Multiply_a58beadd6372454682e1871d39a8681a_Out_2.xx), _TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3);
            float _Property_4fedba3e833c4179be61d16460fb664e_Out_0 = _BaseScale;
            float _GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3, _Property_4fedba3e833c4179be61d16460fb664e_Out_0, _GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2);
            float _Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0 = _BaseStrenght;
            float _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2;
            Unity_Multiply_float_float(_GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2, _Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0, _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2);
            float _Add_29998d0d53254a89af2d8b2baedfd332_Out_2;
            Unity_Add_float(_Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3, _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2, _Add_29998d0d53254a89af2d8b2baedfd332_Out_2);
            float _Add_6ec522987d504e818dd5f6d33104ee55_Out_2;
            Unity_Add_float(_Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0, 1, _Add_6ec522987d504e818dd5f6d33104ee55_Out_2);
            float _Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2;
            Unity_Divide_float(_Add_29998d0d53254a89af2d8b2baedfd332_Out_2, _Add_6ec522987d504e818dd5f6d33104ee55_Out_2, _Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2);
            float3 _Multiply_de0ffea2f7e0425d845f8a8b7131e078_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2.xxx), _Multiply_de0ffea2f7e0425d845f8a8b7131e078_Out_2);
            float3 _Multiply_d6c6bfb6aa73441fa8c68c76e66086f9_Out_2;
            Unity_Multiply_float3_float3((_Property_fefa513c01724d8ab75dd3332e8ca1a9_Out_0.xxx), _Multiply_de0ffea2f7e0425d845f8a8b7131e078_Out_2, _Multiply_d6c6bfb6aa73441fa8c68c76e66086f9_Out_2);
            float3 _Add_ab90fd41f6fd42e1a94942c33fca0dc3_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_d6c6bfb6aa73441fa8c68c76e66086f9_Out_2, _Add_ab90fd41f6fd42e1a94942c33fca0dc3_Out_2);
            float3 _Add_fd933f550505425caf812611c33b5405_Out_2;
            Unity_Add_float3(_Multiply_a027f29d61de4d57b7b43aa6d9b179dc_Out_2, _Add_ab90fd41f6fd42e1a94942c33fca0dc3_Out_2, _Add_fd933f550505425caf812611c33b5405_Out_2);
            description.Position = _Add_fd933f550505425caf812611c33b5405_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_1445156fcebf4ffc8c96120674f48392_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_1445156fcebf4ffc8c96120674f48392_Out_1);
            float4 _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0 = IN.ScreenPosition;
            float _Split_20ac0327e97147fcad31a4edfbaadfff_R_1 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[0];
            float _Split_20ac0327e97147fcad31a4edfbaadfff_G_2 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[1];
            float _Split_20ac0327e97147fcad31a4edfbaadfff_B_3 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[2];
            float _Split_20ac0327e97147fcad31a4edfbaadfff_A_4 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[3];
            float _Subtract_7c1a93a030ef421686bbee6b739bad50_Out_2;
            Unity_Subtract_float(_Split_20ac0327e97147fcad31a4edfbaadfff_A_4, 1, _Subtract_7c1a93a030ef421686bbee6b739bad50_Out_2);
            float _Subtract_02f894cc1e32412eb02601836af73907_Out_2;
            Unity_Subtract_float(_SceneDepth_1445156fcebf4ffc8c96120674f48392_Out_1, _Subtract_7c1a93a030ef421686bbee6b739bad50_Out_2, _Subtract_02f894cc1e32412eb02601836af73907_Out_2);
            float _Property_c3a2ef45c7994aa5a1a193e18d269929_Out_0 = _CloudDensity;
            float _Divide_ebdf44b2c9b84b2fb284d02eeac4fb2c_Out_2;
            Unity_Divide_float(_Subtract_02f894cc1e32412eb02601836af73907_Out_2, _Property_c3a2ef45c7994aa5a1a193e18d269929_Out_0, _Divide_ebdf44b2c9b84b2fb284d02eeac4fb2c_Out_2);
            float _Saturate_de5e588c20ff4724a90c4ac5e20d6ef1_Out_1;
            Unity_Saturate_float(_Divide_ebdf44b2c9b84b2fb284d02eeac4fb2c_Out_2, _Saturate_de5e588c20ff4724a90c4ac5e20d6ef1_Out_1);
            surface.Alpha = _Saturate_de5e588c20ff4724a90c4ac5e20d6ef1_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }
        
        // Render State
        Cull Off
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALS
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _NoiseScale;
        float _NoiseSpeed;
        float _NoiseHeight;
        float4 _RemapSettings;
        float4 _ColorA;
        float4 _ColorB;
        float _NoiseEdge_2;
        float _NoiseEdge_1;
        float _NoisePower;
        float _BaseScale;
        float _BaseSpeed;
        float _BaseStrenght;
        float _EmmsionStrength;
        float _CurvatureRadoius;
        float _FressnelPower;
        float _FressnelOpacity;
        float _CloudDensity;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_2863dc92b6d74402b0f32cb2c401b69d_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_2863dc92b6d74402b0f32cb2c401b69d_Out_2);
            float _Property_6df4e77a3809438595c25ee246a7d2cd_Out_0 = _CurvatureRadoius;
            float _Divide_de337321412f429eb063af28777eb6ff_Out_2;
            Unity_Divide_float(_Distance_2863dc92b6d74402b0f32cb2c401b69d_Out_2, _Property_6df4e77a3809438595c25ee246a7d2cd_Out_0, _Divide_de337321412f429eb063af28777eb6ff_Out_2);
            float _Power_70280d5b57474d6db604f0b5f120b300_Out_2;
            Unity_Power_float(_Divide_de337321412f429eb063af28777eb6ff_Out_2, 3, _Power_70280d5b57474d6db604f0b5f120b300_Out_2);
            float3 _Multiply_a027f29d61de4d57b7b43aa6d9b179dc_Out_2;
            Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Power_70280d5b57474d6db604f0b5f120b300_Out_2.xxx), _Multiply_a027f29d61de4d57b7b43aa6d9b179dc_Out_2);
            float _Property_fefa513c01724d8ab75dd3332e8ca1a9_Out_0 = _NoiseHeight;
            float _Property_f0eb7ef7a3bc4dfda71e328d952abdc8_Out_0 = _NoiseEdge_1;
            float _Property_657d0b2b1ea3480995b8268a02809f28_Out_0 = _NoiseEdge_2;
            float3 _RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, float3 (1, 0, 0), 90, _RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3);
            float _Property_3947645305e34f39ac1f299738ebda99_Out_0 = _NoiseSpeed;
            float _Multiply_67e3f559250b4506978f5f580e820d64_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_3947645305e34f39ac1f299738ebda99_Out_0, _Multiply_67e3f559250b4506978f5f580e820d64_Out_2);
            float2 _TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), (_Multiply_67e3f559250b4506978f5f580e820d64_Out_2.xx), _TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3);
            float _Property_662c5c608b96480b97105ea008d323bc_Out_0 = _NoiseScale;
            float _GradientNoise_14092826abfc47279af304e84345d4d8_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3, _Property_662c5c608b96480b97105ea008d323bc_Out_0, _GradientNoise_14092826abfc47279af304e84345d4d8_Out_2);
            float2 _TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3);
            float _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3, _Property_662c5c608b96480b97105ea008d323bc_Out_0, _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2);
            float _Add_cbc089d51efa495caabb9fec5f21b91b_Out_2;
            Unity_Add_float(_GradientNoise_14092826abfc47279af304e84345d4d8_Out_2, _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2, _Add_cbc089d51efa495caabb9fec5f21b91b_Out_2);
            float _Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2;
            Unity_Divide_float(_Add_cbc089d51efa495caabb9fec5f21b91b_Out_2, 2, _Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2);
            float _Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1;
            Unity_Saturate_float(_Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2, _Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1);
            float _Property_8ec8d96f44a1446a89088f4fcfadc90a_Out_0 = _NoisePower;
            float _Power_972441ad163b41ad82e4183c8e58f482_Out_2;
            Unity_Power_float(_Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1, _Property_8ec8d96f44a1446a89088f4fcfadc90a_Out_0, _Power_972441ad163b41ad82e4183c8e58f482_Out_2);
            float4 _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0 = _RemapSettings;
            float _Split_00f91e501ce64bf6ae829204af6d2179_R_1 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[0];
            float _Split_00f91e501ce64bf6ae829204af6d2179_G_2 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[1];
            float _Split_00f91e501ce64bf6ae829204af6d2179_B_3 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[2];
            float _Split_00f91e501ce64bf6ae829204af6d2179_A_4 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[3];
            float2 _Vector2_5aa5459107114aaeb9a83fb648e0bc26_Out_0 = float2(_Split_00f91e501ce64bf6ae829204af6d2179_R_1, _Split_00f91e501ce64bf6ae829204af6d2179_G_2);
            float2 _Vector2_8aefe5df870e4b569abd97dfc4ee992f_Out_0 = float2(_Split_00f91e501ce64bf6ae829204af6d2179_B_3, _Split_00f91e501ce64bf6ae829204af6d2179_A_4);
            float _Remap_e78987da05d74d6cb721111bc0f21abf_Out_3;
            Unity_Remap_float(_Power_972441ad163b41ad82e4183c8e58f482_Out_2, _Vector2_5aa5459107114aaeb9a83fb648e0bc26_Out_0, _Vector2_8aefe5df870e4b569abd97dfc4ee992f_Out_0, _Remap_e78987da05d74d6cb721111bc0f21abf_Out_3);
            float _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1;
            Unity_Absolute_float(_Remap_e78987da05d74d6cb721111bc0f21abf_Out_3, _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1);
            float _Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3;
            Unity_Smoothstep_float(_Property_f0eb7ef7a3bc4dfda71e328d952abdc8_Out_0, _Property_657d0b2b1ea3480995b8268a02809f28_Out_0, _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1, _Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3);
            float _Property_83795617af3f40c0ab30f49b66478b73_Out_0 = _BaseSpeed;
            float _Multiply_a58beadd6372454682e1871d39a8681a_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_83795617af3f40c0ab30f49b66478b73_Out_0, _Multiply_a58beadd6372454682e1871d39a8681a_Out_2);
            float2 _TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), (_Multiply_a58beadd6372454682e1871d39a8681a_Out_2.xx), _TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3);
            float _Property_4fedba3e833c4179be61d16460fb664e_Out_0 = _BaseScale;
            float _GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3, _Property_4fedba3e833c4179be61d16460fb664e_Out_0, _GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2);
            float _Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0 = _BaseStrenght;
            float _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2;
            Unity_Multiply_float_float(_GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2, _Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0, _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2);
            float _Add_29998d0d53254a89af2d8b2baedfd332_Out_2;
            Unity_Add_float(_Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3, _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2, _Add_29998d0d53254a89af2d8b2baedfd332_Out_2);
            float _Add_6ec522987d504e818dd5f6d33104ee55_Out_2;
            Unity_Add_float(_Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0, 1, _Add_6ec522987d504e818dd5f6d33104ee55_Out_2);
            float _Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2;
            Unity_Divide_float(_Add_29998d0d53254a89af2d8b2baedfd332_Out_2, _Add_6ec522987d504e818dd5f6d33104ee55_Out_2, _Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2);
            float3 _Multiply_de0ffea2f7e0425d845f8a8b7131e078_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2.xxx), _Multiply_de0ffea2f7e0425d845f8a8b7131e078_Out_2);
            float3 _Multiply_d6c6bfb6aa73441fa8c68c76e66086f9_Out_2;
            Unity_Multiply_float3_float3((_Property_fefa513c01724d8ab75dd3332e8ca1a9_Out_0.xxx), _Multiply_de0ffea2f7e0425d845f8a8b7131e078_Out_2, _Multiply_d6c6bfb6aa73441fa8c68c76e66086f9_Out_2);
            float3 _Add_ab90fd41f6fd42e1a94942c33fca0dc3_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_d6c6bfb6aa73441fa8c68c76e66086f9_Out_2, _Add_ab90fd41f6fd42e1a94942c33fca0dc3_Out_2);
            float3 _Add_fd933f550505425caf812611c33b5405_Out_2;
            Unity_Add_float3(_Multiply_a027f29d61de4d57b7b43aa6d9b179dc_Out_2, _Add_ab90fd41f6fd42e1a94942c33fca0dc3_Out_2, _Add_fd933f550505425caf812611c33b5405_Out_2);
            description.Position = _Add_fd933f550505425caf812611c33b5405_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_1445156fcebf4ffc8c96120674f48392_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_1445156fcebf4ffc8c96120674f48392_Out_1);
            float4 _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0 = IN.ScreenPosition;
            float _Split_20ac0327e97147fcad31a4edfbaadfff_R_1 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[0];
            float _Split_20ac0327e97147fcad31a4edfbaadfff_G_2 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[1];
            float _Split_20ac0327e97147fcad31a4edfbaadfff_B_3 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[2];
            float _Split_20ac0327e97147fcad31a4edfbaadfff_A_4 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[3];
            float _Subtract_7c1a93a030ef421686bbee6b739bad50_Out_2;
            Unity_Subtract_float(_Split_20ac0327e97147fcad31a4edfbaadfff_A_4, 1, _Subtract_7c1a93a030ef421686bbee6b739bad50_Out_2);
            float _Subtract_02f894cc1e32412eb02601836af73907_Out_2;
            Unity_Subtract_float(_SceneDepth_1445156fcebf4ffc8c96120674f48392_Out_1, _Subtract_7c1a93a030ef421686bbee6b739bad50_Out_2, _Subtract_02f894cc1e32412eb02601836af73907_Out_2);
            float _Property_c3a2ef45c7994aa5a1a193e18d269929_Out_0 = _CloudDensity;
            float _Divide_ebdf44b2c9b84b2fb284d02eeac4fb2c_Out_2;
            Unity_Divide_float(_Subtract_02f894cc1e32412eb02601836af73907_Out_2, _Property_c3a2ef45c7994aa5a1a193e18d269929_Out_0, _Divide_ebdf44b2c9b84b2fb284d02eeac4fb2c_Out_2);
            float _Saturate_de5e588c20ff4724a90c4ac5e20d6ef1_Out_1;
            Unity_Saturate_float(_Divide_ebdf44b2c9b84b2fb284d02eeac4fb2c_Out_2, _Saturate_de5e588c20ff4724a90c4ac5e20d6ef1_Out_1);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Alpha = _Saturate_de5e588c20ff4724a90c4ac5e20d6ef1_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma shader_feature _ EDITOR_VISUALIZATION
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD1
        #define VARYINGS_NEED_TEXCOORD2
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        #define _FOG_FRAGMENT 1
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 texCoord0;
             float4 texCoord1;
             float4 texCoord2;
             float3 viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 WorldSpaceViewDirection;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float4 interp3 : INTERP3;
             float4 interp4 : INTERP4;
             float3 interp5 : INTERP5;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.texCoord0;
            output.interp3.xyzw =  input.texCoord1;
            output.interp4.xyzw =  input.texCoord2;
            output.interp5.xyz =  input.viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.texCoord0 = input.interp2.xyzw;
            output.texCoord1 = input.interp3.xyzw;
            output.texCoord2 = input.interp4.xyzw;
            output.viewDirectionWS = input.interp5.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _NoiseScale;
        float _NoiseSpeed;
        float _NoiseHeight;
        float4 _RemapSettings;
        float4 _ColorA;
        float4 _ColorB;
        float _NoiseEdge_2;
        float _NoiseEdge_1;
        float _NoisePower;
        float _BaseScale;
        float _BaseSpeed;
        float _BaseStrenght;
        float _EmmsionStrength;
        float _CurvatureRadoius;
        float _FressnelPower;
        float _FressnelOpacity;
        float _CloudDensity;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_2863dc92b6d74402b0f32cb2c401b69d_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_2863dc92b6d74402b0f32cb2c401b69d_Out_2);
            float _Property_6df4e77a3809438595c25ee246a7d2cd_Out_0 = _CurvatureRadoius;
            float _Divide_de337321412f429eb063af28777eb6ff_Out_2;
            Unity_Divide_float(_Distance_2863dc92b6d74402b0f32cb2c401b69d_Out_2, _Property_6df4e77a3809438595c25ee246a7d2cd_Out_0, _Divide_de337321412f429eb063af28777eb6ff_Out_2);
            float _Power_70280d5b57474d6db604f0b5f120b300_Out_2;
            Unity_Power_float(_Divide_de337321412f429eb063af28777eb6ff_Out_2, 3, _Power_70280d5b57474d6db604f0b5f120b300_Out_2);
            float3 _Multiply_a027f29d61de4d57b7b43aa6d9b179dc_Out_2;
            Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Power_70280d5b57474d6db604f0b5f120b300_Out_2.xxx), _Multiply_a027f29d61de4d57b7b43aa6d9b179dc_Out_2);
            float _Property_fefa513c01724d8ab75dd3332e8ca1a9_Out_0 = _NoiseHeight;
            float _Property_f0eb7ef7a3bc4dfda71e328d952abdc8_Out_0 = _NoiseEdge_1;
            float _Property_657d0b2b1ea3480995b8268a02809f28_Out_0 = _NoiseEdge_2;
            float3 _RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, float3 (1, 0, 0), 90, _RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3);
            float _Property_3947645305e34f39ac1f299738ebda99_Out_0 = _NoiseSpeed;
            float _Multiply_67e3f559250b4506978f5f580e820d64_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_3947645305e34f39ac1f299738ebda99_Out_0, _Multiply_67e3f559250b4506978f5f580e820d64_Out_2);
            float2 _TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), (_Multiply_67e3f559250b4506978f5f580e820d64_Out_2.xx), _TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3);
            float _Property_662c5c608b96480b97105ea008d323bc_Out_0 = _NoiseScale;
            float _GradientNoise_14092826abfc47279af304e84345d4d8_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3, _Property_662c5c608b96480b97105ea008d323bc_Out_0, _GradientNoise_14092826abfc47279af304e84345d4d8_Out_2);
            float2 _TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3);
            float _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3, _Property_662c5c608b96480b97105ea008d323bc_Out_0, _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2);
            float _Add_cbc089d51efa495caabb9fec5f21b91b_Out_2;
            Unity_Add_float(_GradientNoise_14092826abfc47279af304e84345d4d8_Out_2, _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2, _Add_cbc089d51efa495caabb9fec5f21b91b_Out_2);
            float _Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2;
            Unity_Divide_float(_Add_cbc089d51efa495caabb9fec5f21b91b_Out_2, 2, _Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2);
            float _Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1;
            Unity_Saturate_float(_Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2, _Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1);
            float _Property_8ec8d96f44a1446a89088f4fcfadc90a_Out_0 = _NoisePower;
            float _Power_972441ad163b41ad82e4183c8e58f482_Out_2;
            Unity_Power_float(_Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1, _Property_8ec8d96f44a1446a89088f4fcfadc90a_Out_0, _Power_972441ad163b41ad82e4183c8e58f482_Out_2);
            float4 _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0 = _RemapSettings;
            float _Split_00f91e501ce64bf6ae829204af6d2179_R_1 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[0];
            float _Split_00f91e501ce64bf6ae829204af6d2179_G_2 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[1];
            float _Split_00f91e501ce64bf6ae829204af6d2179_B_3 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[2];
            float _Split_00f91e501ce64bf6ae829204af6d2179_A_4 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[3];
            float2 _Vector2_5aa5459107114aaeb9a83fb648e0bc26_Out_0 = float2(_Split_00f91e501ce64bf6ae829204af6d2179_R_1, _Split_00f91e501ce64bf6ae829204af6d2179_G_2);
            float2 _Vector2_8aefe5df870e4b569abd97dfc4ee992f_Out_0 = float2(_Split_00f91e501ce64bf6ae829204af6d2179_B_3, _Split_00f91e501ce64bf6ae829204af6d2179_A_4);
            float _Remap_e78987da05d74d6cb721111bc0f21abf_Out_3;
            Unity_Remap_float(_Power_972441ad163b41ad82e4183c8e58f482_Out_2, _Vector2_5aa5459107114aaeb9a83fb648e0bc26_Out_0, _Vector2_8aefe5df870e4b569abd97dfc4ee992f_Out_0, _Remap_e78987da05d74d6cb721111bc0f21abf_Out_3);
            float _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1;
            Unity_Absolute_float(_Remap_e78987da05d74d6cb721111bc0f21abf_Out_3, _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1);
            float _Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3;
            Unity_Smoothstep_float(_Property_f0eb7ef7a3bc4dfda71e328d952abdc8_Out_0, _Property_657d0b2b1ea3480995b8268a02809f28_Out_0, _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1, _Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3);
            float _Property_83795617af3f40c0ab30f49b66478b73_Out_0 = _BaseSpeed;
            float _Multiply_a58beadd6372454682e1871d39a8681a_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_83795617af3f40c0ab30f49b66478b73_Out_0, _Multiply_a58beadd6372454682e1871d39a8681a_Out_2);
            float2 _TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), (_Multiply_a58beadd6372454682e1871d39a8681a_Out_2.xx), _TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3);
            float _Property_4fedba3e833c4179be61d16460fb664e_Out_0 = _BaseScale;
            float _GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3, _Property_4fedba3e833c4179be61d16460fb664e_Out_0, _GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2);
            float _Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0 = _BaseStrenght;
            float _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2;
            Unity_Multiply_float_float(_GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2, _Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0, _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2);
            float _Add_29998d0d53254a89af2d8b2baedfd332_Out_2;
            Unity_Add_float(_Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3, _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2, _Add_29998d0d53254a89af2d8b2baedfd332_Out_2);
            float _Add_6ec522987d504e818dd5f6d33104ee55_Out_2;
            Unity_Add_float(_Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0, 1, _Add_6ec522987d504e818dd5f6d33104ee55_Out_2);
            float _Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2;
            Unity_Divide_float(_Add_29998d0d53254a89af2d8b2baedfd332_Out_2, _Add_6ec522987d504e818dd5f6d33104ee55_Out_2, _Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2);
            float3 _Multiply_de0ffea2f7e0425d845f8a8b7131e078_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2.xxx), _Multiply_de0ffea2f7e0425d845f8a8b7131e078_Out_2);
            float3 _Multiply_d6c6bfb6aa73441fa8c68c76e66086f9_Out_2;
            Unity_Multiply_float3_float3((_Property_fefa513c01724d8ab75dd3332e8ca1a9_Out_0.xxx), _Multiply_de0ffea2f7e0425d845f8a8b7131e078_Out_2, _Multiply_d6c6bfb6aa73441fa8c68c76e66086f9_Out_2);
            float3 _Add_ab90fd41f6fd42e1a94942c33fca0dc3_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_d6c6bfb6aa73441fa8c68c76e66086f9_Out_2, _Add_ab90fd41f6fd42e1a94942c33fca0dc3_Out_2);
            float3 _Add_fd933f550505425caf812611c33b5405_Out_2;
            Unity_Add_float3(_Multiply_a027f29d61de4d57b7b43aa6d9b179dc_Out_2, _Add_ab90fd41f6fd42e1a94942c33fca0dc3_Out_2, _Add_fd933f550505425caf812611c33b5405_Out_2);
            description.Position = _Add_fd933f550505425caf812611c33b5405_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_f0eb7ef7a3bc4dfda71e328d952abdc8_Out_0 = _NoiseEdge_1;
            float _Property_657d0b2b1ea3480995b8268a02809f28_Out_0 = _NoiseEdge_2;
            float3 _RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, float3 (1, 0, 0), 90, _RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3);
            float _Property_3947645305e34f39ac1f299738ebda99_Out_0 = _NoiseSpeed;
            float _Multiply_67e3f559250b4506978f5f580e820d64_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_3947645305e34f39ac1f299738ebda99_Out_0, _Multiply_67e3f559250b4506978f5f580e820d64_Out_2);
            float2 _TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), (_Multiply_67e3f559250b4506978f5f580e820d64_Out_2.xx), _TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3);
            float _Property_662c5c608b96480b97105ea008d323bc_Out_0 = _NoiseScale;
            float _GradientNoise_14092826abfc47279af304e84345d4d8_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3, _Property_662c5c608b96480b97105ea008d323bc_Out_0, _GradientNoise_14092826abfc47279af304e84345d4d8_Out_2);
            float2 _TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3);
            float _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3, _Property_662c5c608b96480b97105ea008d323bc_Out_0, _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2);
            float _Add_cbc089d51efa495caabb9fec5f21b91b_Out_2;
            Unity_Add_float(_GradientNoise_14092826abfc47279af304e84345d4d8_Out_2, _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2, _Add_cbc089d51efa495caabb9fec5f21b91b_Out_2);
            float _Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2;
            Unity_Divide_float(_Add_cbc089d51efa495caabb9fec5f21b91b_Out_2, 2, _Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2);
            float _Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1;
            Unity_Saturate_float(_Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2, _Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1);
            float _Property_8ec8d96f44a1446a89088f4fcfadc90a_Out_0 = _NoisePower;
            float _Power_972441ad163b41ad82e4183c8e58f482_Out_2;
            Unity_Power_float(_Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1, _Property_8ec8d96f44a1446a89088f4fcfadc90a_Out_0, _Power_972441ad163b41ad82e4183c8e58f482_Out_2);
            float4 _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0 = _RemapSettings;
            float _Split_00f91e501ce64bf6ae829204af6d2179_R_1 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[0];
            float _Split_00f91e501ce64bf6ae829204af6d2179_G_2 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[1];
            float _Split_00f91e501ce64bf6ae829204af6d2179_B_3 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[2];
            float _Split_00f91e501ce64bf6ae829204af6d2179_A_4 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[3];
            float2 _Vector2_5aa5459107114aaeb9a83fb648e0bc26_Out_0 = float2(_Split_00f91e501ce64bf6ae829204af6d2179_R_1, _Split_00f91e501ce64bf6ae829204af6d2179_G_2);
            float2 _Vector2_8aefe5df870e4b569abd97dfc4ee992f_Out_0 = float2(_Split_00f91e501ce64bf6ae829204af6d2179_B_3, _Split_00f91e501ce64bf6ae829204af6d2179_A_4);
            float _Remap_e78987da05d74d6cb721111bc0f21abf_Out_3;
            Unity_Remap_float(_Power_972441ad163b41ad82e4183c8e58f482_Out_2, _Vector2_5aa5459107114aaeb9a83fb648e0bc26_Out_0, _Vector2_8aefe5df870e4b569abd97dfc4ee992f_Out_0, _Remap_e78987da05d74d6cb721111bc0f21abf_Out_3);
            float _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1;
            Unity_Absolute_float(_Remap_e78987da05d74d6cb721111bc0f21abf_Out_3, _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1);
            float _Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3;
            Unity_Smoothstep_float(_Property_f0eb7ef7a3bc4dfda71e328d952abdc8_Out_0, _Property_657d0b2b1ea3480995b8268a02809f28_Out_0, _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1, _Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3);
            float _Property_83795617af3f40c0ab30f49b66478b73_Out_0 = _BaseSpeed;
            float _Multiply_a58beadd6372454682e1871d39a8681a_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_83795617af3f40c0ab30f49b66478b73_Out_0, _Multiply_a58beadd6372454682e1871d39a8681a_Out_2);
            float2 _TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), (_Multiply_a58beadd6372454682e1871d39a8681a_Out_2.xx), _TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3);
            float _Property_4fedba3e833c4179be61d16460fb664e_Out_0 = _BaseScale;
            float _GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3, _Property_4fedba3e833c4179be61d16460fb664e_Out_0, _GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2);
            float _Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0 = _BaseStrenght;
            float _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2;
            Unity_Multiply_float_float(_GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2, _Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0, _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2);
            float _Add_29998d0d53254a89af2d8b2baedfd332_Out_2;
            Unity_Add_float(_Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3, _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2, _Add_29998d0d53254a89af2d8b2baedfd332_Out_2);
            float _Add_6ec522987d504e818dd5f6d33104ee55_Out_2;
            Unity_Add_float(_Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0, 1, _Add_6ec522987d504e818dd5f6d33104ee55_Out_2);
            float _Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2;
            Unity_Divide_float(_Add_29998d0d53254a89af2d8b2baedfd332_Out_2, _Add_6ec522987d504e818dd5f6d33104ee55_Out_2, _Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2);
            float _Property_5e6909be7142479cb5595465ab7396ab_Out_0 = _FressnelPower;
            float _FresnelEffect_6ad385502ba442bbbfd08c8289b8addd_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_5e6909be7142479cb5595465ab7396ab_Out_0, _FresnelEffect_6ad385502ba442bbbfd08c8289b8addd_Out_3);
            float _Multiply_28a1d2721a9b469da8137faff3ce48b6_Out_2;
            Unity_Multiply_float_float(_Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2, _FresnelEffect_6ad385502ba442bbbfd08c8289b8addd_Out_3, _Multiply_28a1d2721a9b469da8137faff3ce48b6_Out_2);
            float _Property_2bb7638bbe5e46abb573c3169b6fd8a0_Out_0 = _FressnelOpacity;
            float _Multiply_223cf800f8854807ba5c4b69d74abfb9_Out_2;
            Unity_Multiply_float_float(_Multiply_28a1d2721a9b469da8137faff3ce48b6_Out_2, _Property_2bb7638bbe5e46abb573c3169b6fd8a0_Out_0, _Multiply_223cf800f8854807ba5c4b69d74abfb9_Out_2);
            float4 _Property_9e04c6a53cf14db8af5075df14bdf933_Out_0 = _ColorA;
            float4 _Property_b8fd511244174f46a8116607e59c88de_Out_0 = _ColorB;
            float4 _Lerp_b4d037eea01443f981d467219a9716cb_Out_3;
            Unity_Lerp_float4(_Property_9e04c6a53cf14db8af5075df14bdf933_Out_0, _Property_b8fd511244174f46a8116607e59c88de_Out_0, (_Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2.xxxx), _Lerp_b4d037eea01443f981d467219a9716cb_Out_3);
            float4 _Add_d4f711b802874114a3aaedfa0820123c_Out_2;
            Unity_Add_float4((_Multiply_223cf800f8854807ba5c4b69d74abfb9_Out_2.xxxx), _Lerp_b4d037eea01443f981d467219a9716cb_Out_3, _Add_d4f711b802874114a3aaedfa0820123c_Out_2);
            float _Property_01447423b08c408283d759fb2cdebc7a_Out_0 = _EmmsionStrength;
            float4 _Multiply_336e0a5f825c42458362ed5f9974b35a_Out_2;
            Unity_Multiply_float4_float4(_Add_d4f711b802874114a3aaedfa0820123c_Out_2, (_Property_01447423b08c408283d759fb2cdebc7a_Out_0.xxxx), _Multiply_336e0a5f825c42458362ed5f9974b35a_Out_2);
            float _SceneDepth_1445156fcebf4ffc8c96120674f48392_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_1445156fcebf4ffc8c96120674f48392_Out_1);
            float4 _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0 = IN.ScreenPosition;
            float _Split_20ac0327e97147fcad31a4edfbaadfff_R_1 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[0];
            float _Split_20ac0327e97147fcad31a4edfbaadfff_G_2 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[1];
            float _Split_20ac0327e97147fcad31a4edfbaadfff_B_3 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[2];
            float _Split_20ac0327e97147fcad31a4edfbaadfff_A_4 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[3];
            float _Subtract_7c1a93a030ef421686bbee6b739bad50_Out_2;
            Unity_Subtract_float(_Split_20ac0327e97147fcad31a4edfbaadfff_A_4, 1, _Subtract_7c1a93a030ef421686bbee6b739bad50_Out_2);
            float _Subtract_02f894cc1e32412eb02601836af73907_Out_2;
            Unity_Subtract_float(_SceneDepth_1445156fcebf4ffc8c96120674f48392_Out_1, _Subtract_7c1a93a030ef421686bbee6b739bad50_Out_2, _Subtract_02f894cc1e32412eb02601836af73907_Out_2);
            float _Property_c3a2ef45c7994aa5a1a193e18d269929_Out_0 = _CloudDensity;
            float _Divide_ebdf44b2c9b84b2fb284d02eeac4fb2c_Out_2;
            Unity_Divide_float(_Subtract_02f894cc1e32412eb02601836af73907_Out_2, _Property_c3a2ef45c7994aa5a1a193e18d269929_Out_0, _Divide_ebdf44b2c9b84b2fb284d02eeac4fb2c_Out_2);
            float _Saturate_de5e588c20ff4724a90c4ac5e20d6ef1_Out_1;
            Unity_Saturate_float(_Divide_ebdf44b2c9b84b2fb284d02eeac4fb2c_Out_2, _Saturate_de5e588c20ff4724a90c4ac5e20d6ef1_Out_1);
            surface.BaseColor = (_Add_d4f711b802874114a3aaedfa0820123c_Out_2.xyz);
            surface.Emission = (_Multiply_336e0a5f825c42458362ed5f9974b35a_Out_2.xyz);
            surface.Alpha = _Saturate_de5e588c20ff4724a90c4ac5e20d6ef1_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        
        
            output.WorldSpaceViewDirection = normalize(input.viewDirectionWS);
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _NoiseScale;
        float _NoiseSpeed;
        float _NoiseHeight;
        float4 _RemapSettings;
        float4 _ColorA;
        float4 _ColorB;
        float _NoiseEdge_2;
        float _NoiseEdge_1;
        float _NoisePower;
        float _BaseScale;
        float _BaseSpeed;
        float _BaseStrenght;
        float _EmmsionStrength;
        float _CurvatureRadoius;
        float _FressnelPower;
        float _FressnelOpacity;
        float _CloudDensity;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_2863dc92b6d74402b0f32cb2c401b69d_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_2863dc92b6d74402b0f32cb2c401b69d_Out_2);
            float _Property_6df4e77a3809438595c25ee246a7d2cd_Out_0 = _CurvatureRadoius;
            float _Divide_de337321412f429eb063af28777eb6ff_Out_2;
            Unity_Divide_float(_Distance_2863dc92b6d74402b0f32cb2c401b69d_Out_2, _Property_6df4e77a3809438595c25ee246a7d2cd_Out_0, _Divide_de337321412f429eb063af28777eb6ff_Out_2);
            float _Power_70280d5b57474d6db604f0b5f120b300_Out_2;
            Unity_Power_float(_Divide_de337321412f429eb063af28777eb6ff_Out_2, 3, _Power_70280d5b57474d6db604f0b5f120b300_Out_2);
            float3 _Multiply_a027f29d61de4d57b7b43aa6d9b179dc_Out_2;
            Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Power_70280d5b57474d6db604f0b5f120b300_Out_2.xxx), _Multiply_a027f29d61de4d57b7b43aa6d9b179dc_Out_2);
            float _Property_fefa513c01724d8ab75dd3332e8ca1a9_Out_0 = _NoiseHeight;
            float _Property_f0eb7ef7a3bc4dfda71e328d952abdc8_Out_0 = _NoiseEdge_1;
            float _Property_657d0b2b1ea3480995b8268a02809f28_Out_0 = _NoiseEdge_2;
            float3 _RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, float3 (1, 0, 0), 90, _RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3);
            float _Property_3947645305e34f39ac1f299738ebda99_Out_0 = _NoiseSpeed;
            float _Multiply_67e3f559250b4506978f5f580e820d64_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_3947645305e34f39ac1f299738ebda99_Out_0, _Multiply_67e3f559250b4506978f5f580e820d64_Out_2);
            float2 _TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), (_Multiply_67e3f559250b4506978f5f580e820d64_Out_2.xx), _TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3);
            float _Property_662c5c608b96480b97105ea008d323bc_Out_0 = _NoiseScale;
            float _GradientNoise_14092826abfc47279af304e84345d4d8_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3, _Property_662c5c608b96480b97105ea008d323bc_Out_0, _GradientNoise_14092826abfc47279af304e84345d4d8_Out_2);
            float2 _TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3);
            float _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3, _Property_662c5c608b96480b97105ea008d323bc_Out_0, _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2);
            float _Add_cbc089d51efa495caabb9fec5f21b91b_Out_2;
            Unity_Add_float(_GradientNoise_14092826abfc47279af304e84345d4d8_Out_2, _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2, _Add_cbc089d51efa495caabb9fec5f21b91b_Out_2);
            float _Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2;
            Unity_Divide_float(_Add_cbc089d51efa495caabb9fec5f21b91b_Out_2, 2, _Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2);
            float _Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1;
            Unity_Saturate_float(_Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2, _Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1);
            float _Property_8ec8d96f44a1446a89088f4fcfadc90a_Out_0 = _NoisePower;
            float _Power_972441ad163b41ad82e4183c8e58f482_Out_2;
            Unity_Power_float(_Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1, _Property_8ec8d96f44a1446a89088f4fcfadc90a_Out_0, _Power_972441ad163b41ad82e4183c8e58f482_Out_2);
            float4 _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0 = _RemapSettings;
            float _Split_00f91e501ce64bf6ae829204af6d2179_R_1 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[0];
            float _Split_00f91e501ce64bf6ae829204af6d2179_G_2 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[1];
            float _Split_00f91e501ce64bf6ae829204af6d2179_B_3 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[2];
            float _Split_00f91e501ce64bf6ae829204af6d2179_A_4 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[3];
            float2 _Vector2_5aa5459107114aaeb9a83fb648e0bc26_Out_0 = float2(_Split_00f91e501ce64bf6ae829204af6d2179_R_1, _Split_00f91e501ce64bf6ae829204af6d2179_G_2);
            float2 _Vector2_8aefe5df870e4b569abd97dfc4ee992f_Out_0 = float2(_Split_00f91e501ce64bf6ae829204af6d2179_B_3, _Split_00f91e501ce64bf6ae829204af6d2179_A_4);
            float _Remap_e78987da05d74d6cb721111bc0f21abf_Out_3;
            Unity_Remap_float(_Power_972441ad163b41ad82e4183c8e58f482_Out_2, _Vector2_5aa5459107114aaeb9a83fb648e0bc26_Out_0, _Vector2_8aefe5df870e4b569abd97dfc4ee992f_Out_0, _Remap_e78987da05d74d6cb721111bc0f21abf_Out_3);
            float _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1;
            Unity_Absolute_float(_Remap_e78987da05d74d6cb721111bc0f21abf_Out_3, _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1);
            float _Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3;
            Unity_Smoothstep_float(_Property_f0eb7ef7a3bc4dfda71e328d952abdc8_Out_0, _Property_657d0b2b1ea3480995b8268a02809f28_Out_0, _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1, _Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3);
            float _Property_83795617af3f40c0ab30f49b66478b73_Out_0 = _BaseSpeed;
            float _Multiply_a58beadd6372454682e1871d39a8681a_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_83795617af3f40c0ab30f49b66478b73_Out_0, _Multiply_a58beadd6372454682e1871d39a8681a_Out_2);
            float2 _TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), (_Multiply_a58beadd6372454682e1871d39a8681a_Out_2.xx), _TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3);
            float _Property_4fedba3e833c4179be61d16460fb664e_Out_0 = _BaseScale;
            float _GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3, _Property_4fedba3e833c4179be61d16460fb664e_Out_0, _GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2);
            float _Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0 = _BaseStrenght;
            float _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2;
            Unity_Multiply_float_float(_GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2, _Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0, _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2);
            float _Add_29998d0d53254a89af2d8b2baedfd332_Out_2;
            Unity_Add_float(_Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3, _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2, _Add_29998d0d53254a89af2d8b2baedfd332_Out_2);
            float _Add_6ec522987d504e818dd5f6d33104ee55_Out_2;
            Unity_Add_float(_Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0, 1, _Add_6ec522987d504e818dd5f6d33104ee55_Out_2);
            float _Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2;
            Unity_Divide_float(_Add_29998d0d53254a89af2d8b2baedfd332_Out_2, _Add_6ec522987d504e818dd5f6d33104ee55_Out_2, _Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2);
            float3 _Multiply_de0ffea2f7e0425d845f8a8b7131e078_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2.xxx), _Multiply_de0ffea2f7e0425d845f8a8b7131e078_Out_2);
            float3 _Multiply_d6c6bfb6aa73441fa8c68c76e66086f9_Out_2;
            Unity_Multiply_float3_float3((_Property_fefa513c01724d8ab75dd3332e8ca1a9_Out_0.xxx), _Multiply_de0ffea2f7e0425d845f8a8b7131e078_Out_2, _Multiply_d6c6bfb6aa73441fa8c68c76e66086f9_Out_2);
            float3 _Add_ab90fd41f6fd42e1a94942c33fca0dc3_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_d6c6bfb6aa73441fa8c68c76e66086f9_Out_2, _Add_ab90fd41f6fd42e1a94942c33fca0dc3_Out_2);
            float3 _Add_fd933f550505425caf812611c33b5405_Out_2;
            Unity_Add_float3(_Multiply_a027f29d61de4d57b7b43aa6d9b179dc_Out_2, _Add_ab90fd41f6fd42e1a94942c33fca0dc3_Out_2, _Add_fd933f550505425caf812611c33b5405_Out_2);
            description.Position = _Add_fd933f550505425caf812611c33b5405_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_1445156fcebf4ffc8c96120674f48392_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_1445156fcebf4ffc8c96120674f48392_Out_1);
            float4 _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0 = IN.ScreenPosition;
            float _Split_20ac0327e97147fcad31a4edfbaadfff_R_1 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[0];
            float _Split_20ac0327e97147fcad31a4edfbaadfff_G_2 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[1];
            float _Split_20ac0327e97147fcad31a4edfbaadfff_B_3 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[2];
            float _Split_20ac0327e97147fcad31a4edfbaadfff_A_4 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[3];
            float _Subtract_7c1a93a030ef421686bbee6b739bad50_Out_2;
            Unity_Subtract_float(_Split_20ac0327e97147fcad31a4edfbaadfff_A_4, 1, _Subtract_7c1a93a030ef421686bbee6b739bad50_Out_2);
            float _Subtract_02f894cc1e32412eb02601836af73907_Out_2;
            Unity_Subtract_float(_SceneDepth_1445156fcebf4ffc8c96120674f48392_Out_1, _Subtract_7c1a93a030ef421686bbee6b739bad50_Out_2, _Subtract_02f894cc1e32412eb02601836af73907_Out_2);
            float _Property_c3a2ef45c7994aa5a1a193e18d269929_Out_0 = _CloudDensity;
            float _Divide_ebdf44b2c9b84b2fb284d02eeac4fb2c_Out_2;
            Unity_Divide_float(_Subtract_02f894cc1e32412eb02601836af73907_Out_2, _Property_c3a2ef45c7994aa5a1a193e18d269929_Out_0, _Divide_ebdf44b2c9b84b2fb284d02eeac4fb2c_Out_2);
            float _Saturate_de5e588c20ff4724a90c4ac5e20d6ef1_Out_1;
            Unity_Saturate_float(_Divide_ebdf44b2c9b84b2fb284d02eeac4fb2c_Out_2, _Saturate_de5e588c20ff4724a90c4ac5e20d6ef1_Out_1);
            surface.Alpha = _Saturate_de5e588c20ff4724a90c4ac5e20d6ef1_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _NoiseScale;
        float _NoiseSpeed;
        float _NoiseHeight;
        float4 _RemapSettings;
        float4 _ColorA;
        float4 _ColorB;
        float _NoiseEdge_2;
        float _NoiseEdge_1;
        float _NoisePower;
        float _BaseScale;
        float _BaseSpeed;
        float _BaseStrenght;
        float _EmmsionStrength;
        float _CurvatureRadoius;
        float _FressnelPower;
        float _FressnelOpacity;
        float _CloudDensity;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_2863dc92b6d74402b0f32cb2c401b69d_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_2863dc92b6d74402b0f32cb2c401b69d_Out_2);
            float _Property_6df4e77a3809438595c25ee246a7d2cd_Out_0 = _CurvatureRadoius;
            float _Divide_de337321412f429eb063af28777eb6ff_Out_2;
            Unity_Divide_float(_Distance_2863dc92b6d74402b0f32cb2c401b69d_Out_2, _Property_6df4e77a3809438595c25ee246a7d2cd_Out_0, _Divide_de337321412f429eb063af28777eb6ff_Out_2);
            float _Power_70280d5b57474d6db604f0b5f120b300_Out_2;
            Unity_Power_float(_Divide_de337321412f429eb063af28777eb6ff_Out_2, 3, _Power_70280d5b57474d6db604f0b5f120b300_Out_2);
            float3 _Multiply_a027f29d61de4d57b7b43aa6d9b179dc_Out_2;
            Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Power_70280d5b57474d6db604f0b5f120b300_Out_2.xxx), _Multiply_a027f29d61de4d57b7b43aa6d9b179dc_Out_2);
            float _Property_fefa513c01724d8ab75dd3332e8ca1a9_Out_0 = _NoiseHeight;
            float _Property_f0eb7ef7a3bc4dfda71e328d952abdc8_Out_0 = _NoiseEdge_1;
            float _Property_657d0b2b1ea3480995b8268a02809f28_Out_0 = _NoiseEdge_2;
            float3 _RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, float3 (1, 0, 0), 90, _RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3);
            float _Property_3947645305e34f39ac1f299738ebda99_Out_0 = _NoiseSpeed;
            float _Multiply_67e3f559250b4506978f5f580e820d64_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_3947645305e34f39ac1f299738ebda99_Out_0, _Multiply_67e3f559250b4506978f5f580e820d64_Out_2);
            float2 _TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), (_Multiply_67e3f559250b4506978f5f580e820d64_Out_2.xx), _TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3);
            float _Property_662c5c608b96480b97105ea008d323bc_Out_0 = _NoiseScale;
            float _GradientNoise_14092826abfc47279af304e84345d4d8_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3, _Property_662c5c608b96480b97105ea008d323bc_Out_0, _GradientNoise_14092826abfc47279af304e84345d4d8_Out_2);
            float2 _TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3);
            float _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3, _Property_662c5c608b96480b97105ea008d323bc_Out_0, _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2);
            float _Add_cbc089d51efa495caabb9fec5f21b91b_Out_2;
            Unity_Add_float(_GradientNoise_14092826abfc47279af304e84345d4d8_Out_2, _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2, _Add_cbc089d51efa495caabb9fec5f21b91b_Out_2);
            float _Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2;
            Unity_Divide_float(_Add_cbc089d51efa495caabb9fec5f21b91b_Out_2, 2, _Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2);
            float _Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1;
            Unity_Saturate_float(_Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2, _Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1);
            float _Property_8ec8d96f44a1446a89088f4fcfadc90a_Out_0 = _NoisePower;
            float _Power_972441ad163b41ad82e4183c8e58f482_Out_2;
            Unity_Power_float(_Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1, _Property_8ec8d96f44a1446a89088f4fcfadc90a_Out_0, _Power_972441ad163b41ad82e4183c8e58f482_Out_2);
            float4 _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0 = _RemapSettings;
            float _Split_00f91e501ce64bf6ae829204af6d2179_R_1 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[0];
            float _Split_00f91e501ce64bf6ae829204af6d2179_G_2 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[1];
            float _Split_00f91e501ce64bf6ae829204af6d2179_B_3 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[2];
            float _Split_00f91e501ce64bf6ae829204af6d2179_A_4 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[3];
            float2 _Vector2_5aa5459107114aaeb9a83fb648e0bc26_Out_0 = float2(_Split_00f91e501ce64bf6ae829204af6d2179_R_1, _Split_00f91e501ce64bf6ae829204af6d2179_G_2);
            float2 _Vector2_8aefe5df870e4b569abd97dfc4ee992f_Out_0 = float2(_Split_00f91e501ce64bf6ae829204af6d2179_B_3, _Split_00f91e501ce64bf6ae829204af6d2179_A_4);
            float _Remap_e78987da05d74d6cb721111bc0f21abf_Out_3;
            Unity_Remap_float(_Power_972441ad163b41ad82e4183c8e58f482_Out_2, _Vector2_5aa5459107114aaeb9a83fb648e0bc26_Out_0, _Vector2_8aefe5df870e4b569abd97dfc4ee992f_Out_0, _Remap_e78987da05d74d6cb721111bc0f21abf_Out_3);
            float _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1;
            Unity_Absolute_float(_Remap_e78987da05d74d6cb721111bc0f21abf_Out_3, _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1);
            float _Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3;
            Unity_Smoothstep_float(_Property_f0eb7ef7a3bc4dfda71e328d952abdc8_Out_0, _Property_657d0b2b1ea3480995b8268a02809f28_Out_0, _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1, _Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3);
            float _Property_83795617af3f40c0ab30f49b66478b73_Out_0 = _BaseSpeed;
            float _Multiply_a58beadd6372454682e1871d39a8681a_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_83795617af3f40c0ab30f49b66478b73_Out_0, _Multiply_a58beadd6372454682e1871d39a8681a_Out_2);
            float2 _TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), (_Multiply_a58beadd6372454682e1871d39a8681a_Out_2.xx), _TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3);
            float _Property_4fedba3e833c4179be61d16460fb664e_Out_0 = _BaseScale;
            float _GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3, _Property_4fedba3e833c4179be61d16460fb664e_Out_0, _GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2);
            float _Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0 = _BaseStrenght;
            float _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2;
            Unity_Multiply_float_float(_GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2, _Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0, _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2);
            float _Add_29998d0d53254a89af2d8b2baedfd332_Out_2;
            Unity_Add_float(_Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3, _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2, _Add_29998d0d53254a89af2d8b2baedfd332_Out_2);
            float _Add_6ec522987d504e818dd5f6d33104ee55_Out_2;
            Unity_Add_float(_Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0, 1, _Add_6ec522987d504e818dd5f6d33104ee55_Out_2);
            float _Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2;
            Unity_Divide_float(_Add_29998d0d53254a89af2d8b2baedfd332_Out_2, _Add_6ec522987d504e818dd5f6d33104ee55_Out_2, _Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2);
            float3 _Multiply_de0ffea2f7e0425d845f8a8b7131e078_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2.xxx), _Multiply_de0ffea2f7e0425d845f8a8b7131e078_Out_2);
            float3 _Multiply_d6c6bfb6aa73441fa8c68c76e66086f9_Out_2;
            Unity_Multiply_float3_float3((_Property_fefa513c01724d8ab75dd3332e8ca1a9_Out_0.xxx), _Multiply_de0ffea2f7e0425d845f8a8b7131e078_Out_2, _Multiply_d6c6bfb6aa73441fa8c68c76e66086f9_Out_2);
            float3 _Add_ab90fd41f6fd42e1a94942c33fca0dc3_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_d6c6bfb6aa73441fa8c68c76e66086f9_Out_2, _Add_ab90fd41f6fd42e1a94942c33fca0dc3_Out_2);
            float3 _Add_fd933f550505425caf812611c33b5405_Out_2;
            Unity_Add_float3(_Multiply_a027f29d61de4d57b7b43aa6d9b179dc_Out_2, _Add_ab90fd41f6fd42e1a94942c33fca0dc3_Out_2, _Add_fd933f550505425caf812611c33b5405_Out_2);
            description.Position = _Add_fd933f550505425caf812611c33b5405_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_1445156fcebf4ffc8c96120674f48392_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_1445156fcebf4ffc8c96120674f48392_Out_1);
            float4 _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0 = IN.ScreenPosition;
            float _Split_20ac0327e97147fcad31a4edfbaadfff_R_1 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[0];
            float _Split_20ac0327e97147fcad31a4edfbaadfff_G_2 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[1];
            float _Split_20ac0327e97147fcad31a4edfbaadfff_B_3 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[2];
            float _Split_20ac0327e97147fcad31a4edfbaadfff_A_4 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[3];
            float _Subtract_7c1a93a030ef421686bbee6b739bad50_Out_2;
            Unity_Subtract_float(_Split_20ac0327e97147fcad31a4edfbaadfff_A_4, 1, _Subtract_7c1a93a030ef421686bbee6b739bad50_Out_2);
            float _Subtract_02f894cc1e32412eb02601836af73907_Out_2;
            Unity_Subtract_float(_SceneDepth_1445156fcebf4ffc8c96120674f48392_Out_1, _Subtract_7c1a93a030ef421686bbee6b739bad50_Out_2, _Subtract_02f894cc1e32412eb02601836af73907_Out_2);
            float _Property_c3a2ef45c7994aa5a1a193e18d269929_Out_0 = _CloudDensity;
            float _Divide_ebdf44b2c9b84b2fb284d02eeac4fb2c_Out_2;
            Unity_Divide_float(_Subtract_02f894cc1e32412eb02601836af73907_Out_2, _Property_c3a2ef45c7994aa5a1a193e18d269929_Out_0, _Divide_ebdf44b2c9b84b2fb284d02eeac4fb2c_Out_2);
            float _Saturate_de5e588c20ff4724a90c4ac5e20d6ef1_Out_1;
            Unity_Saturate_float(_Divide_ebdf44b2c9b84b2fb284d02eeac4fb2c_Out_2, _Saturate_de5e588c20ff4724a90c4ac5e20d6ef1_Out_1);
            surface.Alpha = _Saturate_de5e588c20ff4724a90c4ac5e20d6ef1_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            // Name: <None>
            Tags
            {
                "LightMode" = "Universal2D"
            }
        
        // Render State
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_2D
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float3 viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 WorldSpaceViewDirection;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 WorldSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float3 interp2 : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyz =  input.viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.viewDirectionWS = input.interp2.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _NoiseScale;
        float _NoiseSpeed;
        float _NoiseHeight;
        float4 _RemapSettings;
        float4 _ColorA;
        float4 _ColorB;
        float _NoiseEdge_2;
        float _NoiseEdge_1;
        float _NoisePower;
        float _BaseScale;
        float _BaseSpeed;
        float _BaseStrenght;
        float _EmmsionStrength;
        float _CurvatureRadoius;
        float _FressnelPower;
        float _FressnelOpacity;
        float _CloudDensity;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Rotate_About_Axis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_2863dc92b6d74402b0f32cb2c401b69d_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_2863dc92b6d74402b0f32cb2c401b69d_Out_2);
            float _Property_6df4e77a3809438595c25ee246a7d2cd_Out_0 = _CurvatureRadoius;
            float _Divide_de337321412f429eb063af28777eb6ff_Out_2;
            Unity_Divide_float(_Distance_2863dc92b6d74402b0f32cb2c401b69d_Out_2, _Property_6df4e77a3809438595c25ee246a7d2cd_Out_0, _Divide_de337321412f429eb063af28777eb6ff_Out_2);
            float _Power_70280d5b57474d6db604f0b5f120b300_Out_2;
            Unity_Power_float(_Divide_de337321412f429eb063af28777eb6ff_Out_2, 3, _Power_70280d5b57474d6db604f0b5f120b300_Out_2);
            float3 _Multiply_a027f29d61de4d57b7b43aa6d9b179dc_Out_2;
            Unity_Multiply_float3_float3(IN.WorldSpaceNormal, (_Power_70280d5b57474d6db604f0b5f120b300_Out_2.xxx), _Multiply_a027f29d61de4d57b7b43aa6d9b179dc_Out_2);
            float _Property_fefa513c01724d8ab75dd3332e8ca1a9_Out_0 = _NoiseHeight;
            float _Property_f0eb7ef7a3bc4dfda71e328d952abdc8_Out_0 = _NoiseEdge_1;
            float _Property_657d0b2b1ea3480995b8268a02809f28_Out_0 = _NoiseEdge_2;
            float3 _RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, float3 (1, 0, 0), 90, _RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3);
            float _Property_3947645305e34f39ac1f299738ebda99_Out_0 = _NoiseSpeed;
            float _Multiply_67e3f559250b4506978f5f580e820d64_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_3947645305e34f39ac1f299738ebda99_Out_0, _Multiply_67e3f559250b4506978f5f580e820d64_Out_2);
            float2 _TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), (_Multiply_67e3f559250b4506978f5f580e820d64_Out_2.xx), _TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3);
            float _Property_662c5c608b96480b97105ea008d323bc_Out_0 = _NoiseScale;
            float _GradientNoise_14092826abfc47279af304e84345d4d8_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3, _Property_662c5c608b96480b97105ea008d323bc_Out_0, _GradientNoise_14092826abfc47279af304e84345d4d8_Out_2);
            float2 _TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3);
            float _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3, _Property_662c5c608b96480b97105ea008d323bc_Out_0, _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2);
            float _Add_cbc089d51efa495caabb9fec5f21b91b_Out_2;
            Unity_Add_float(_GradientNoise_14092826abfc47279af304e84345d4d8_Out_2, _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2, _Add_cbc089d51efa495caabb9fec5f21b91b_Out_2);
            float _Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2;
            Unity_Divide_float(_Add_cbc089d51efa495caabb9fec5f21b91b_Out_2, 2, _Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2);
            float _Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1;
            Unity_Saturate_float(_Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2, _Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1);
            float _Property_8ec8d96f44a1446a89088f4fcfadc90a_Out_0 = _NoisePower;
            float _Power_972441ad163b41ad82e4183c8e58f482_Out_2;
            Unity_Power_float(_Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1, _Property_8ec8d96f44a1446a89088f4fcfadc90a_Out_0, _Power_972441ad163b41ad82e4183c8e58f482_Out_2);
            float4 _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0 = _RemapSettings;
            float _Split_00f91e501ce64bf6ae829204af6d2179_R_1 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[0];
            float _Split_00f91e501ce64bf6ae829204af6d2179_G_2 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[1];
            float _Split_00f91e501ce64bf6ae829204af6d2179_B_3 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[2];
            float _Split_00f91e501ce64bf6ae829204af6d2179_A_4 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[3];
            float2 _Vector2_5aa5459107114aaeb9a83fb648e0bc26_Out_0 = float2(_Split_00f91e501ce64bf6ae829204af6d2179_R_1, _Split_00f91e501ce64bf6ae829204af6d2179_G_2);
            float2 _Vector2_8aefe5df870e4b569abd97dfc4ee992f_Out_0 = float2(_Split_00f91e501ce64bf6ae829204af6d2179_B_3, _Split_00f91e501ce64bf6ae829204af6d2179_A_4);
            float _Remap_e78987da05d74d6cb721111bc0f21abf_Out_3;
            Unity_Remap_float(_Power_972441ad163b41ad82e4183c8e58f482_Out_2, _Vector2_5aa5459107114aaeb9a83fb648e0bc26_Out_0, _Vector2_8aefe5df870e4b569abd97dfc4ee992f_Out_0, _Remap_e78987da05d74d6cb721111bc0f21abf_Out_3);
            float _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1;
            Unity_Absolute_float(_Remap_e78987da05d74d6cb721111bc0f21abf_Out_3, _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1);
            float _Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3;
            Unity_Smoothstep_float(_Property_f0eb7ef7a3bc4dfda71e328d952abdc8_Out_0, _Property_657d0b2b1ea3480995b8268a02809f28_Out_0, _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1, _Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3);
            float _Property_83795617af3f40c0ab30f49b66478b73_Out_0 = _BaseSpeed;
            float _Multiply_a58beadd6372454682e1871d39a8681a_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_83795617af3f40c0ab30f49b66478b73_Out_0, _Multiply_a58beadd6372454682e1871d39a8681a_Out_2);
            float2 _TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), (_Multiply_a58beadd6372454682e1871d39a8681a_Out_2.xx), _TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3);
            float _Property_4fedba3e833c4179be61d16460fb664e_Out_0 = _BaseScale;
            float _GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3, _Property_4fedba3e833c4179be61d16460fb664e_Out_0, _GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2);
            float _Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0 = _BaseStrenght;
            float _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2;
            Unity_Multiply_float_float(_GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2, _Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0, _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2);
            float _Add_29998d0d53254a89af2d8b2baedfd332_Out_2;
            Unity_Add_float(_Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3, _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2, _Add_29998d0d53254a89af2d8b2baedfd332_Out_2);
            float _Add_6ec522987d504e818dd5f6d33104ee55_Out_2;
            Unity_Add_float(_Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0, 1, _Add_6ec522987d504e818dd5f6d33104ee55_Out_2);
            float _Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2;
            Unity_Divide_float(_Add_29998d0d53254a89af2d8b2baedfd332_Out_2, _Add_6ec522987d504e818dd5f6d33104ee55_Out_2, _Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2);
            float3 _Multiply_de0ffea2f7e0425d845f8a8b7131e078_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2.xxx), _Multiply_de0ffea2f7e0425d845f8a8b7131e078_Out_2);
            float3 _Multiply_d6c6bfb6aa73441fa8c68c76e66086f9_Out_2;
            Unity_Multiply_float3_float3((_Property_fefa513c01724d8ab75dd3332e8ca1a9_Out_0.xxx), _Multiply_de0ffea2f7e0425d845f8a8b7131e078_Out_2, _Multiply_d6c6bfb6aa73441fa8c68c76e66086f9_Out_2);
            float3 _Add_ab90fd41f6fd42e1a94942c33fca0dc3_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_d6c6bfb6aa73441fa8c68c76e66086f9_Out_2, _Add_ab90fd41f6fd42e1a94942c33fca0dc3_Out_2);
            float3 _Add_fd933f550505425caf812611c33b5405_Out_2;
            Unity_Add_float3(_Multiply_a027f29d61de4d57b7b43aa6d9b179dc_Out_2, _Add_ab90fd41f6fd42e1a94942c33fca0dc3_Out_2, _Add_fd933f550505425caf812611c33b5405_Out_2);
            description.Position = _Add_fd933f550505425caf812611c33b5405_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_f0eb7ef7a3bc4dfda71e328d952abdc8_Out_0 = _NoiseEdge_1;
            float _Property_657d0b2b1ea3480995b8268a02809f28_Out_0 = _NoiseEdge_2;
            float3 _RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3;
            Unity_Rotate_About_Axis_Radians_float(IN.WorldSpacePosition, float3 (1, 0, 0), 90, _RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3);
            float _Property_3947645305e34f39ac1f299738ebda99_Out_0 = _NoiseSpeed;
            float _Multiply_67e3f559250b4506978f5f580e820d64_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_3947645305e34f39ac1f299738ebda99_Out_0, _Multiply_67e3f559250b4506978f5f580e820d64_Out_2);
            float2 _TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), (_Multiply_67e3f559250b4506978f5f580e820d64_Out_2.xx), _TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3);
            float _Property_662c5c608b96480b97105ea008d323bc_Out_0 = _NoiseScale;
            float _GradientNoise_14092826abfc47279af304e84345d4d8_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_5a95868f8c63464a869b9de8b907e764_Out_3, _Property_662c5c608b96480b97105ea008d323bc_Out_0, _GradientNoise_14092826abfc47279af304e84345d4d8_Out_2);
            float2 _TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3);
            float _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_168787687cb941e49dfbf8a2d0dc0e4a_Out_3, _Property_662c5c608b96480b97105ea008d323bc_Out_0, _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2);
            float _Add_cbc089d51efa495caabb9fec5f21b91b_Out_2;
            Unity_Add_float(_GradientNoise_14092826abfc47279af304e84345d4d8_Out_2, _GradientNoise_e8256b825e3e44699ffbd20a88b71f68_Out_2, _Add_cbc089d51efa495caabb9fec5f21b91b_Out_2);
            float _Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2;
            Unity_Divide_float(_Add_cbc089d51efa495caabb9fec5f21b91b_Out_2, 2, _Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2);
            float _Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1;
            Unity_Saturate_float(_Divide_dadde9f93739401198c5c400ffd4f7c3_Out_2, _Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1);
            float _Property_8ec8d96f44a1446a89088f4fcfadc90a_Out_0 = _NoisePower;
            float _Power_972441ad163b41ad82e4183c8e58f482_Out_2;
            Unity_Power_float(_Saturate_f3c94b1ac09b46af93346cd1db53cb5f_Out_1, _Property_8ec8d96f44a1446a89088f4fcfadc90a_Out_0, _Power_972441ad163b41ad82e4183c8e58f482_Out_2);
            float4 _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0 = _RemapSettings;
            float _Split_00f91e501ce64bf6ae829204af6d2179_R_1 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[0];
            float _Split_00f91e501ce64bf6ae829204af6d2179_G_2 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[1];
            float _Split_00f91e501ce64bf6ae829204af6d2179_B_3 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[2];
            float _Split_00f91e501ce64bf6ae829204af6d2179_A_4 = _Property_905ec40ae2d447e6908ddfdc5b73cd9a_Out_0[3];
            float2 _Vector2_5aa5459107114aaeb9a83fb648e0bc26_Out_0 = float2(_Split_00f91e501ce64bf6ae829204af6d2179_R_1, _Split_00f91e501ce64bf6ae829204af6d2179_G_2);
            float2 _Vector2_8aefe5df870e4b569abd97dfc4ee992f_Out_0 = float2(_Split_00f91e501ce64bf6ae829204af6d2179_B_3, _Split_00f91e501ce64bf6ae829204af6d2179_A_4);
            float _Remap_e78987da05d74d6cb721111bc0f21abf_Out_3;
            Unity_Remap_float(_Power_972441ad163b41ad82e4183c8e58f482_Out_2, _Vector2_5aa5459107114aaeb9a83fb648e0bc26_Out_0, _Vector2_8aefe5df870e4b569abd97dfc4ee992f_Out_0, _Remap_e78987da05d74d6cb721111bc0f21abf_Out_3);
            float _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1;
            Unity_Absolute_float(_Remap_e78987da05d74d6cb721111bc0f21abf_Out_3, _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1);
            float _Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3;
            Unity_Smoothstep_float(_Property_f0eb7ef7a3bc4dfda71e328d952abdc8_Out_0, _Property_657d0b2b1ea3480995b8268a02809f28_Out_0, _Absolute_42f86eefa8bb4f73be39d812a1f841d6_Out_1, _Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3);
            float _Property_83795617af3f40c0ab30f49b66478b73_Out_0 = _BaseSpeed;
            float _Multiply_a58beadd6372454682e1871d39a8681a_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_83795617af3f40c0ab30f49b66478b73_Out_0, _Multiply_a58beadd6372454682e1871d39a8681a_Out_2);
            float2 _TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_9a82dda086674dd5baabf3819fb5d0f7_Out_3.xy), float2 (1, 1), (_Multiply_a58beadd6372454682e1871d39a8681a_Out_2.xx), _TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3);
            float _Property_4fedba3e833c4179be61d16460fb664e_Out_0 = _BaseScale;
            float _GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_4165d2a8f8404ceeb612b459e66e75b8_Out_3, _Property_4fedba3e833c4179be61d16460fb664e_Out_0, _GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2);
            float _Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0 = _BaseStrenght;
            float _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2;
            Unity_Multiply_float_float(_GradientNoise_391639e6daa94ade91e81d227553fab2_Out_2, _Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0, _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2);
            float _Add_29998d0d53254a89af2d8b2baedfd332_Out_2;
            Unity_Add_float(_Smoothstep_26a87f106ce14e189e6c62d128069e84_Out_3, _Multiply_41d9eb6b52494fb28ffa239a4d4317bc_Out_2, _Add_29998d0d53254a89af2d8b2baedfd332_Out_2);
            float _Add_6ec522987d504e818dd5f6d33104ee55_Out_2;
            Unity_Add_float(_Property_d8fba3645f9d42ddb391a49d2edc8f69_Out_0, 1, _Add_6ec522987d504e818dd5f6d33104ee55_Out_2);
            float _Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2;
            Unity_Divide_float(_Add_29998d0d53254a89af2d8b2baedfd332_Out_2, _Add_6ec522987d504e818dd5f6d33104ee55_Out_2, _Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2);
            float _Property_5e6909be7142479cb5595465ab7396ab_Out_0 = _FressnelPower;
            float _FresnelEffect_6ad385502ba442bbbfd08c8289b8addd_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_5e6909be7142479cb5595465ab7396ab_Out_0, _FresnelEffect_6ad385502ba442bbbfd08c8289b8addd_Out_3);
            float _Multiply_28a1d2721a9b469da8137faff3ce48b6_Out_2;
            Unity_Multiply_float_float(_Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2, _FresnelEffect_6ad385502ba442bbbfd08c8289b8addd_Out_3, _Multiply_28a1d2721a9b469da8137faff3ce48b6_Out_2);
            float _Property_2bb7638bbe5e46abb573c3169b6fd8a0_Out_0 = _FressnelOpacity;
            float _Multiply_223cf800f8854807ba5c4b69d74abfb9_Out_2;
            Unity_Multiply_float_float(_Multiply_28a1d2721a9b469da8137faff3ce48b6_Out_2, _Property_2bb7638bbe5e46abb573c3169b6fd8a0_Out_0, _Multiply_223cf800f8854807ba5c4b69d74abfb9_Out_2);
            float4 _Property_9e04c6a53cf14db8af5075df14bdf933_Out_0 = _ColorA;
            float4 _Property_b8fd511244174f46a8116607e59c88de_Out_0 = _ColorB;
            float4 _Lerp_b4d037eea01443f981d467219a9716cb_Out_3;
            Unity_Lerp_float4(_Property_9e04c6a53cf14db8af5075df14bdf933_Out_0, _Property_b8fd511244174f46a8116607e59c88de_Out_0, (_Divide_dd3610fc7cdc4722a30ade93b1d70c26_Out_2.xxxx), _Lerp_b4d037eea01443f981d467219a9716cb_Out_3);
            float4 _Add_d4f711b802874114a3aaedfa0820123c_Out_2;
            Unity_Add_float4((_Multiply_223cf800f8854807ba5c4b69d74abfb9_Out_2.xxxx), _Lerp_b4d037eea01443f981d467219a9716cb_Out_3, _Add_d4f711b802874114a3aaedfa0820123c_Out_2);
            float _SceneDepth_1445156fcebf4ffc8c96120674f48392_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_1445156fcebf4ffc8c96120674f48392_Out_1);
            float4 _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0 = IN.ScreenPosition;
            float _Split_20ac0327e97147fcad31a4edfbaadfff_R_1 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[0];
            float _Split_20ac0327e97147fcad31a4edfbaadfff_G_2 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[1];
            float _Split_20ac0327e97147fcad31a4edfbaadfff_B_3 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[2];
            float _Split_20ac0327e97147fcad31a4edfbaadfff_A_4 = _ScreenPosition_4956939becaf4f6a811d8c7e5630dfaa_Out_0[3];
            float _Subtract_7c1a93a030ef421686bbee6b739bad50_Out_2;
            Unity_Subtract_float(_Split_20ac0327e97147fcad31a4edfbaadfff_A_4, 1, _Subtract_7c1a93a030ef421686bbee6b739bad50_Out_2);
            float _Subtract_02f894cc1e32412eb02601836af73907_Out_2;
            Unity_Subtract_float(_SceneDepth_1445156fcebf4ffc8c96120674f48392_Out_1, _Subtract_7c1a93a030ef421686bbee6b739bad50_Out_2, _Subtract_02f894cc1e32412eb02601836af73907_Out_2);
            float _Property_c3a2ef45c7994aa5a1a193e18d269929_Out_0 = _CloudDensity;
            float _Divide_ebdf44b2c9b84b2fb284d02eeac4fb2c_Out_2;
            Unity_Divide_float(_Subtract_02f894cc1e32412eb02601836af73907_Out_2, _Property_c3a2ef45c7994aa5a1a193e18d269929_Out_0, _Divide_ebdf44b2c9b84b2fb284d02eeac4fb2c_Out_2);
            float _Saturate_de5e588c20ff4724a90c4ac5e20d6ef1_Out_1;
            Unity_Saturate_float(_Divide_ebdf44b2c9b84b2fb284d02eeac4fb2c_Out_2, _Saturate_de5e588c20ff4724a90c4ac5e20d6ef1_Out_1);
            surface.BaseColor = (_Add_d4f711b802874114a3aaedfa0820123c_Out_2.xyz);
            surface.Alpha = _Saturate_de5e588c20ff4724a90c4ac5e20d6ef1_Out_1;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.WorldSpaceNormal =                           TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.WorldSpacePosition =                         TransformObjectToWorld(input.positionOS);
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        
        
            output.WorldSpaceViewDirection = normalize(input.viewDirectionWS);
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    CustomEditorForRenderPipeline "UnityEditor.ShaderGraphLitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    FallBack "Hidden/Shader Graph/FallbackError"
}