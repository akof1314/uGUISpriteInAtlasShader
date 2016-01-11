Shader "FX/Standard/Twist"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)

		_StencilComp ("Stencil Comparison", Float) = 8
		_Stencil ("Stencil ID", Float) = 0
		_StencilOp ("Stencil Operation", Float) = 0
		_StencilWriteMask ("Stencil Write Mask", Float) = 255
		_StencilReadMask ("Stencil Read Mask", Float) = 255

		_ColorMask ("Color Mask", Float) = 15

		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0

		_Distortion ("Distortion", Range(0,1)) = 0
		_PosX ("PosX", Range(0,1)) = 0
		_PosY ("PosY", Range(0,1)) = 0

		_UvRect ("UvRect", Vector) = (0, 0, 1, 1)
	}

	SubShader
	{
		Tags
		{
			"Queue"="Transparent"
			"IgnoreProjector"="True"
			"RenderType"="Transparent"
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
		}

		Stencil
		{
			Ref [_Stencil]
			Comp [_StencilComp]
			Pass [_StencilOp]
			ReadMask [_StencilReadMask]
			WriteMask [_StencilWriteMask]
		}

		Cull Off
		Lighting Off
		ZWrite Off
		ZTest [unity_GUIZTestMode]
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask [_ColorMask]

		Pass
		{
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "UnityUI.cginc"

			#pragma multi_compile __ UNITY_UI_ALPHACLIP

			struct appdata_t
			{
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
				float2 texcoord1 : TEXCOORD1;
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				half2 texcoord  : TEXCOORD0;
				float4 worldPosition : TEXCOORD1;
				float2 texcoord1 : TEXCOORD2;
			};

			fixed4 _Color;
			fixed4 _TextureSampleAdd;
			float4 _ClipRect;

			v2f vert(appdata_t IN)
			{
				v2f OUT;
				OUT.worldPosition = IN.vertex;
				OUT.vertex = mul(UNITY_MATRIX_MVP, OUT.worldPosition);
				OUT.vertex = mul(UNITY_MATRIX_MVP, IN.vertex);

				OUT.texcoord = IN.texcoord;

				#ifdef UNITY_HALF_TEXEL_OFFSET
				OUT.vertex.xy += (_ScreenParams.zw-1.0)*float2(-1,1);
				#endif

				OUT.color = IN.color * _Color;
				OUT.texcoord1 = IN.texcoord1;
				return OUT;
			}

			float _Distortion;
			float _PosX;
			float _PosY;
			float4 _UvRect;

			float4 twist(sampler2D tex, float2 uv, float time)
			{
				float radius = 0.5;
				float2 center = float2(_PosX, _PosY);
				float2 tc = uv - center;
				float dist = length(tc);
				if (dist < radius)
				{
					float percent = (radius - dist) / radius;
					float theta = percent * percent * (2.0 * sin(time)) * 8.0;
					float s = sin(theta);
					float c = cos(theta);
					tc = float2(dot(tc, float2(c, -s)), dot(tc, float2(s, c)));
				}
				tc += center;
				tc.x = _UvRect.x + (_UvRect.z - _UvRect.x) * tc.x;
				tc.y = _UvRect.y + (_UvRect.w - _UvRect.y) * tc.y;
				float4 color = tex2D(tex, tc);
				return color;
			}

			sampler2D _MainTex;

			fixed4 frag(v2f IN) : SV_Target
			{
				half4 color = twist(_MainTex, IN.texcoord1, _Distortion) * IN.color;

				color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);

				#ifdef UNITY_UI_ALPHACLIP
				clip (color.a - 0.001);
				#endif

				return color;
			}
		ENDCG
		}
	}
}
