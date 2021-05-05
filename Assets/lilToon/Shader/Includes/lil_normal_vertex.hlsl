#ifndef LIL_VERTEX_INCLUDED
#define LIL_VERTEX_INCLUDED

//------------------------------------------------------------------------------------------------------------------------------
// Vertex shader
v2f vert(appdata input)
{
    v2f output;
    LIL_INITIALIZE_STRUCT(v2f, output);

    //----------------------------------------------------------------------------------------------------------------------
    // Invisible
    if(_Invisible) return output;

    //----------------------------------------------------------------------------------------------------------------------
    // Single Pass Instanced rendering
    LIL_SETUP_INSTANCE_ID(input);
    LIL_TRANSFER_INSTANCE_ID(input, output);
    LIL_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    //----------------------------------------------------------------------------------------------------------------------
    // Copy
    LIL_VERTEX_POSITION_INPUTS(input.positionOS, vertexInput);
    #if defined(LIL_OUTLINE) || defined(LIL_FUR)
        LIL_VERTEX_NORMAL_INPUTS(input.normalOS, vertexNormalInput);
    #else
        LIL_VERTEX_NORMAL_TANGENT_INPUTS(input.normalOS, input.tangentOS, vertexNormalInput);
    #endif

    #if defined(LIL_OUTLINE)
        //--------------------------------------------------------------------------------------------------------------
        // Outline
        float2 uvMain = input.uv * _MainTex_ST.xy + _MainTex_ST.zw;
        _OutlineWidth *= LIL_SAMPLE_2D_LOD(_OutlineWidthMask, sampler_MainTex, uvMain, 0).r * 0.01;
        vertexInput.positionWS += vertexNormalInput.normalWS * _OutlineWidth;
        output.uv           = input.uv;
        output.positionCS   = LIL_TRANSFORM_POS_WS_TO_CS(vertexInput.positionWS);
        #if defined(LIL_PASS_FORWARDADD) || !defined(LIL_BRP)
            output.positionWS   = vertexInput.positionWS;
        #endif
        #if defined(LIL_USE_LIGHTMAP) && defined(LIL_LIGHTMODE_SUBTRACTIVE)
            output.normalWS     = vertexNormalInput.normalWS;
        #endif
    #elif defined(LIL_FUR)
        //--------------------------------------------------------------------------------------------------------------
        // Fur
        #if !defined(LIL_BRP)
            output.uv           = input.uv;
            output.positionWS   = vertexInput.positionWS;
            output.positionCS   = vertexInput.positionCS;
            output.normalWS     = vertexNormalInput.normalWS;
        #elif defined(LIL_PASS_FORWARDADD)
            output.uv           = input.uv;
            output.positionWS   = vertexInput.positionWS;
            output.positionCS   = vertexInput.positionCS;
        #else
            output.uv           = input.uv;
            output.positionCS   = vertexInput.positionCS;
            output.normalWS     = vertexNormalInput.normalWS;
        #endif
    #else
        //--------------------------------------------------------------------------------------------------------------
        // Normal
        output.uv           = input.uv;
        output.positionWS   = vertexInput.positionWS;
        output.positionCS   = vertexInput.positionCS;
        output.normalWS     = vertexNormalInput.normalWS;
        output.tangentWS    = vertexNormalInput.tangentWS;
        output.bitangentWS  = vertexNormalInput.bitangentWS;
        output.tangentW     = input.tangentOS.w;
        #if defined(LIL_REFRACTION) && !defined(LIL_PASS_FORWARDADD)
            output.positionSS = vertexInput.positionSS;
        #endif
    #endif

    //----------------------------------------------------------------------------------------------------------------------
    // Fog & Lightmap & Vertex light
    LIL_TRANSFER_SHADOW(vertexInput, input.uv1, output);
    LIL_TRANSFER_FOG(vertexInput, output);
    LIL_TRANSFER_LIGHTMAPUV(input.uv1, output);
    LIL_CALC_VERTEXLIGHT(vertexInput, output);

    return output;
}

#endif