Shader "Unlit/SCTilemapShadowUnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ShadowColor("Shadow color", Color) = (.1, .1, .1, 1) // 影用カラーのシェーダープロパティを追加
    }
    SubShader
    {
        //Tags { "RenderType"="Opaque" }
        Tags {"Queue" = "Transparent"}
        Blend SrcAlpha OneMinusSrcAlpha
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            fixed4 _ShadowColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                fixed4 shadowCol = fixed4(_ShadowColor.x, _ShadowColor.y, _ShadowColor.z, col.w);

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, shadowCol);
                return shadowCol;
            }
            ENDCG
        }
    }
}
