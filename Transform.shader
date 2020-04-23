Shader "FluidSim/Transform" 
{
    Properties 
    {
        _Noise1 ("Noise1 (RGB)", 2D) = "white" {}
        _Noise2 ("Noise2 (RGB)", 2D) = "white" {}
        _Noise3 ("Noise3 (RGB)", 2D) = "white" {}
        _Noise4 ("Noise4 (RGB)", 2D) = "white" {}
    }
    SubShader 
    {
        Pass 
        {
            ZTest Always

            CGPROGRAM
            #include "UnityCG.cginc"
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag

            #define PI 3.1415926

            
            sampler2D _Noise1;
            sampler2D _Noise2;
            sampler2D _Noise3;
            sampler2D _Noise4;

            uniform sampler2D _Velocity;
        
            struct v2f 
            {
                float4  pos : SV_POSITION;
                float2  uv : TEXCOORD0;
            };

            v2f vert(appdata_base v)
            {
                v2f OUT;
                OUT.pos = UnityObjectToClipPos(v.vertex);
                OUT.uv = v.texcoord.xy;
                return OUT;
            }
            

            float2 randomRotate(float ran, float2 u)
            {
                float theta = ran * 2 * PI - PI; //旋转角度
                float2 uu = float2(u.x * cos(theta) - u.y * sin(theta), u.x * sin(theta) + u.y * cos(theta));  //旋转

                return uu;  //旋转后速度方向
            }


            // ----------------------------------------------------------------------------


// ------------------------------


            float4 frag(v2f IN) : COLOR
            {
                

                //float2 u = tex2D(_Velocity, IN.uv).xy;  //输入速度xy分量
                float GGX = tex2D(_Velocity, IN.uv).x;  //输入压力场

                
                float D_real = GGX * tex2D(_Noise1, IN.uv).r;


                //4 * 3 = 12 个服从标准正态分布的随机数
                //float3 r1 = tex2D(_Noise1, IN.uv).rgb;
                //float3 r2 = tex2D(_Noise2, IN.uv).rgb;  
                //float3 r3 = tex2D(_Noise3, IN.uv).rgb;
                //float3 r4 = tex2D(_Noise4, IN.uv).rgb;


                
                // 12 个旋转后的向量
                //float2 u1r = randomRotate(r1.r, u);
                //float2 u1g = randomRotate(r1.g, u);
                //float2 u1b = randomRotate(r1.b, u);
                
                //float2 u2r = randomRotate(r2.r, u);
                //float2 u2g = randomRotate(r2.g, u);
                //float2 u2b = randomRotate(r2.b, u);
                
                //float2 u3r = randomRotate(r3.r, u);
                //float2 u3g = randomRotate(r3.g, u);
                //float2 u3b = randomRotate(r3.b, u);
                
                //float2 u4r = randomRotate(r4.r, u);
                //float2 u4g = randomRotate(r4.g, u);
                //float2 u4b = randomRotate(r4.b, u);


                //float2 u_real = u1r + u1g + u1b + u2r + u2g + u2b + u3r + u3g + u3b + u4r + u4g + u4b;
                //float2 u_real = u1r + u1g + u1b + u2r + u2g + u2b + u3r + u3g + u3b;
                //float2 u_real = u1r + u1g + u1b;
                //u_real = u_real * 0.1;

                //float2 u_real = u1r;
                return float4(D_real, 0, 0, 1);
                 

                //错了，压力场只有一个x，要像粗粒NDF一样变换
                


                //float2 col = _FluidColor * tex2D(_MainTex, IN.uv).xy;
                //return float4(col-10,0,1);
                //return float4(-col,0,1);

                


            }
            
            ENDCG

        }
    }
}
