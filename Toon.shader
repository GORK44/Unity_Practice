﻿// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter 14/Toon Shading" {
    Properties {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _Ramp ("Ramp Texture", 2D) = "white" {} //控制漫反射色调的渐变纹理
        _Outline ("Outline", Range(0, 1)) = 0.1 //轮廓线宽度
        _OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _SpecularScale ("Specular Scale", Range(0, 0.1)) = 0.01
    }
    SubShader {
        Tags { "RenderType"="Opaque" "Queue"="Geometry"}
        
        Pass {
            NAME "OUTLINE"
            
            Cull Front //第一个Pass只渲染背面的三角形面片
            
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            
            float _Outline;
            fixed4 _OutlineColor;
            
            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            }; 
            
            struct v2f {
                float4 pos : SV_POSITION;
            };
            
            v2f vert (a2v v) {
                v2f o;
                
                float4 pos = mul(UNITY_MATRIX_MV, v.vertex); //相机空间坐标
                float3 normal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal); //逆转置矩阵，得到相机空间法线 
                normal.z = -0.5; //尽可能避免内凹模型背面扩张后顶点挡住正面的面片
                pos = pos + float4(normalize(normal), 0) * _Outline; //相机空间顶点沿着法线方向扩展
                o.pos = mul(UNITY_MATRIX_P, pos); //顶点到裁剪空间
                
                return o;
            }
            
            float4 frag(v2f i) : SV_Target { 
                return float4(_OutlineColor.rgb, 1);               
            }
            
            ENDCG
        }
        
        Pass {
            Tags { "LightMode"="ForwardBase" }
            
            Cull Back
        
            CGPROGRAM
        
            #pragma vertex vert
            #pragma fragment frag
            
            #pragma multi_compile_fwdbase
        
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            #include "UnityShaderVariables.cginc"
            
            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _Ramp;
            fixed4 _Specular;
            fixed _SpecularScale;
        
            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
                float4 tangent : TANGENT;
            }; 
        
            struct v2f {
                float4 pos : POSITION;
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
                SHADOW_COORDS(3)
            };
            
            v2f vert (a2v v) {
                v2f o;
                
                o.pos = UnityObjectToClipPos( v.vertex);
                o.uv = TRANSFORM_TEX (v.texcoord, _MainTex);
                o.worldNormal  = UnityObjectToWorldNormal(v.normal); //世界空间法线
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz; //世界空间顶点坐标
                
                TRANSFER_SHADOW(o);
                
                return o;
            }
            
            float4 frag(v2f i) : SV_Target { 
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 worldHalfDir = normalize(worldLightDir + worldViewDir);
                
                fixed4 c = tex2D (_MainTex, i.uv);
                fixed3 albedo = c.rgb * _Color.rgb;
                
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
                
                fixed diff =  dot(worldNormal, worldLightDir);
                diff = (diff * 0.5 + 0.5) * atten;
                
                fixed3 diffuse = _LightColor0.rgb * albedo * tex2D(_Ramp, float2(diff, diff)).rgb;
                
                fixed spec = dot(worldNormal, worldHalfDir); //法线和半程向量的点乘
                fixed w = fwidth(spec) * 2.0;   //fwidth(spec)：spec这个值在当前像素和它的下一个相邻像素之间的差值（X和Y方向偏导数的绝对值的和）
                fixed3 specular = _Specular.rgb * lerp(0, 1, smoothstep(-w, w, spec + _SpecularScale - 1)) * step(0.0001, _SpecularScale);
                // smoothstep(a,b,x) : x<a，返回 0；x>b，返回 1。 a<x<b，返回0～1的平滑插值（在高光区域边缘处实现抗锯齿）
                // step(a, x) : 如果 x<a，返回 0；否则，返回 1。（为了在_SpecularScale=0时，完全消除高光反射的光照）

                return fixed4(ambient + diffuse + specular, 1.0);
            }
        
            ENDCG
        }
    }
    FallBack "Diffuse"
}
© 2020 GitHub, Inc.