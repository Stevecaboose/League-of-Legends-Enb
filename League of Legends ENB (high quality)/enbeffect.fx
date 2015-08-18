 //++++++++++++++++++++++++++++++++++++++++++++
// ENBSeries effect file
// visit http://enbdev.com for updates
// Copyright (c) 2007-2012 Boris Vorontsov
//++++++++++++++++++++++++++++++++++++++++++++

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Additions and tweaking by HD6 (HeliosDoubleSix) and LSiwora (1.5)
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

// Remove or add '//' infront of '#define' below to disable / enable the various options

////

// ENB - values could be 1, 2, 3 or 4. v4 gives unrealistic, kind of artwork style, v5 is added by HD6
	#define POSTPROCESS	5
//

// ENB - use original game processing first, then mine
	#define APPLYGAMECOLORCORRECTION
//

// ENB - use original game processing only, with vanilla bloom (basically turns everything off)
	//#define ENB_FLIPTECHNIQUE
//

////

// HD6 - Color Balance and Brightness, Contrast adjustment
	//
	#define HD6_COLOR_TWEAKS
	#define HD6_DARKER_NIGHTS
	// Right now if you do NOT darken the nights, the night sky will be very bright unless changes in enbseries.ini
	//
	// Put // or remove the // infront of "#define HD6_DARKER_NIGHTS" above, to darken the nights or not.. // will put nights back to normal
	//
	// This is by default and for examples sake set to make the nights even darker
	// When you decrease brightness you will need to increase contrast or it will look washed out
	// and if you increrase contrast that naturally increases saturation so you need to reduce saturation
	// this is just the nature of color correction :-)
	//
	// Note nights and days are being desaturated per channel(RGB) using: HD6_COLORSAT_DAYNIGHT elsewhere
	// Note Bloom is not affected by this and gets its own color/contrast adjustment in HD6_BLOOM_CRISP and HD6_BLOOM_DEBLUEIFY if used
	//
	// If the 3 numbers in rgb below do not add up to 3 it will either be darker or lighter than before
	float3 rgbd 	= float3( 1.07, 1.01, 1.04 ); 		// RGB balance day
	float3 rgbn 	= float3( 1.01, 0.96, 1.06 ); 		// RGB balance night
	//
	// First column of the 3 here is for key control only during night
	// ie you can press number '1' with pageup or pagedown to alter the brightness while playing
	// As you press pagedown it moves further towards the values in this first column.
	// As a helpful indicator you can see if you have moved away from default values by
	// noticing a very small white dot in top left corner of screen.
	// Adjust with keys till this dot vanishes, then it is back to default
	
	// Change size of that dot here, can be 0 to hide it
	float dotsize = 0.003;
	
	// The Keycontrol ONLY affects the night right now. So dont try using it during the day it wont do anything.
	
	// Darker Nights ( Night Keypress 1+Pageup/down, Night, Day )
	// Only uses these values if "#define HD6_DARKER_NIGHTS" does not have '//' infront
	
	//	keypress 1,2:	  night, day		night, day
	float4 uctbrt1 	= float4( 0.30, 0.30, 		0.40, 0.75 ); 	// Brightness Night, Day (Alters before contrast adjustment)
	float4 uctbrt2	= float4( 0.50, 0.30, 		0.95, 0.90 ); 	// Brightness Night, Day (Alters after contrast adjustment)
	float4 uctcon 	= float4( 0.90, 0.90, 		1.05, 0.92 ); 	// Contrast Night, Day, v11.2: 1.0, 0.97, 0.85
	float4 uctsat	= float4( 0.20, -0.80, 		1.05, 1.10 ); 	// Saturation Night, Day (Remember if using HD6_COLORSAT_DAYNIGHT that will also be desaturating the night)
	
	//		keypress 4: Saturation
	
	
	#ifdef HD6_DARKER_NIGHTS
		float4 darkenby1 = float4( 0.00, 0.00, 		0.00, 0.00 );
	#endif
	
			
	//
	// I have stopped relying on the palette map to darken nights, now I do all darkening here
	// When reducing brightness it seems increasing saturation is needed to restore color, and a slight increase in contrast to maintain bright spots/flames etc
	// Remember this is not darkening the bloom, which in itself has as impact on the overall brightness and hazyness of the scene
	//
	// Palette map right now is increasing contrast so I have compensated by reducing contrast here (lazy)
//

// HD6 - Enable Vignette - darkens and blurs edges of the screen which increasesfocus on center, film/camera type effect/look
	// didnt bother adding blur, could do without muddying and fuzzing things really
	// and the effect is only meant to be super subtle not a pin hole camera -_-
	//
	#define HD6_VIGNETTE
	//
	// Defaults below, I darken the corners and the bottom only, leaving the top light
	// darkening all sides feels ike you are trapping/closing in the view too much, so it is not a normal vignette
	// And it is subtle, till you turn it off I doubt you would ever even notice it
	// Also is turned off at night
	//
	float rovigpwr = 0.4; // For Round vignette // 0.2
	float2 sqvigpwr = float2( 0, 0.1 ); // For square vignette: (top, bottom)
	//
	float vsatstrength = 0.25; // How saturated vignette is
	float vignettepow = 1.0; // For Round vignette, higher pushes it to the corners and increases contrast/sharpness
	//
	float vstrengthatnight = 0.2; // How strong vignette is as night, 0-1
//

// HD6 - Desaturate Nights, can alter saturation seperately from day and night, will affect caves and indoors also for now
	//
	#define HD6_COLORSAT_DAYNIGHT
	//
	// Saturation, Red, Green, Blue
	float3 dnsatn = float3( 1.00, 1.00, 1.00 ); // Night	
	float3 dnsatd = float3( 1.00, 1.00, 1.00 ); // Day
	
//

// HD6 - removes blue tint from bloom, most apparent in distant fog
	//
	#define HD6_BLOOM_DEBLUEIFY
	//
	// HeliosDoubleSix cobbled code to deblueify bloom without loosing brightness huzah! - First time writing shader code so be gentle
	// desaturates bloom, to do this you cant just remove a color or tone it down you need to redistribute it evenly across all channels to make it grey
	// well evenly would make sense but the eye has different sensetivities to color so its actually RGB (0.3, 0.59, 0.11) to achieve greyscale
	// Careful as removing too muchblue can send snow and early morning pink	
	//
	float3 nsat = float3( 0.7, 0.7, 0.7);
	//float3 nsat = float3( 0.80, 0.65, 0.75 );
	
	//float3 nsat = float3( 0.80, 0.75, 0.73 ); // v11.3
//

// HD6 - Enable Bloom - disable bloom with this if you turn it off in enbseries, compensates for darkening
	#define USEBLOOM
//

// 	Pick one or none:
// HD6 - BLOOM 1 - alternate crisp bloom, no hazey mud (hopefully)
	#define HD6_BLOOM_CRISP
// HD6 - BLOOM 2 - alternate bloom (using screen mode) I have abadoned this code
	//#define HD6_BLOOM_SCREEN
//

// HD6 - old weird serendipitous code to defuzz bloom
	//#define HD6_BLOOM_DEFUZZ
//

// HD6 - remove black from bloom, not working very well
	//#define HD6_BLOOM_NOBLACK
//

// Keyboard controlled temporary variables (in some versions exists in the config file).
// Press and hold key 1,2,3...8 together with PageUp or PageDown to modify. By default all set to 1.0
	float4	tempF1; // 0,1,2,3
	float4	tempF2; // 5,6,7,8
	float4	tempF3; // 9,0

// x=generic timer in range 0..1, period of 16777216 ms (4.6 hours), w=frame time elapsed (in seconds)
	float4	Timer;
// x=Width, y=1/Width, z=ScreenScaleY, w=1/ScreenScaleY
	float4	ScreenSize;
// changes in range 0..1, 0 means that night time, 1 - day time
	float	ENightDayFactor;
	
// enb version of bloom applied, ignored if original post processing used
	float	EBloomAmount;

//+++++++++++++++++++++++++++++
//POSTPROCESS 1
	float	EAdaptationMinV1 = 0.05;
	float	EAdaptationMaxV1 = 0.125;
	float	EContrastV1 = 1.0;
	float	EColorSaturationV1 = 1.0;
	float	EToneMappingCurveV1 = 3.0;
//+++++++++++++++++++++++++++++

//+++++++++++++++++++++++++++++
//POSTPROCESS 2
#if (POSTPROCESS==2)
	float	EAdaptationMinV2=0.05;
	float	EAdaptationMaxV2=0.125;
	float	EToneMappingCurveV2=8.0;
	float	EIntensityContrastV2=1.475;
	float	EColorSaturationV2=1.0;
	float	EToneMappingOversaturationV2=160.0;
#endif
//+++++++++++++++++++++++++++++

//+++++++++++++++++++++++++++++
//POSTPROCESS 5 by HD6
#if (POSTPROCESS==5)
	// HD6 - Adaptation is now ignored by my choice
	float	EAdaptationMinV2 = 0.10; // 0.28 // lower gets brighter
	
	// Increase this to darken days, but darkening them will kill the sky a bit unless you enable the SKY overirde in enberies.ini
	float	EAdaptationMaxV2 = 0.20; // 0.30 // 0.65 // 0.35 // 0.29

	// Set ridiculously high, was 8, was in attempt to keep hair colour intact
	float	EToneMappingCurveV2 = 12; // 130

	// Adjusting this will throw out all the other values, icreased to high levels to combat how high I increased ToneMappingCurve to bring some contrast back in to daytime
	float	EIntensityContrastV2 = 2.85	; // 3.2 // 4.08 // 3.16

	// high saturation also helps pop the pink/orange sunsets/mornings at 6.30pm and 7.30am, but also nights then get very blue
	// Increasing this will darken things in the process
	// v11.2 = 3.0, 1.0 increased to put even more color into the game
	float	EColorSaturationV2 = 3.3; // 1.8;
	float 	HCompensateSat = 2.6; // Compensate for darkening caused by increasing EColorSaturationV2	

	// Not using this now anymore
	float	EToneMappingOversaturationV2 = 120.0;
#endif
//+++++++++++++++++++++++++++++

//+++++++++++++++++++++++++++++
//POSTPROCESS 3
	float	EAdaptationMinV3 = 0.001; // Higher Gets Darker
	float	EAdaptationMaxV3 = 0.025;
	float	EToneMappingCurveV3 = 30.0; // Higher gets darker
	float	EToneMappingOversaturationV3 = 111160.0;
//+++++++++++++++++++++++++++++

//+++++++++++++++++++++++++++++
//POSTPROCESS 4
	float	EAdaptationMinV4 = 0.2;
	float	EAdaptationMaxV4 = 0.125;
	float	EBrightnessCurveV4 = 0.7;
	float	EBrightnessMultiplierV4 = 0.45;
	float	EBrightnessToneMappingCurveV4 = 0.3;
//+++++++++++++++++++++++++++++

//+++++++++++++++++++++++++++++
//external parameters, do not modify
//+++++++++++++++++++++++++++++
	texture2D texs0; // color
	texture2D texs1; // bloom skyrim
	texture2D texs2; // adaptation skyrim
	texture2D texs3; // bloom enb
	texture2D texs4; // adaptation enb
	texture2D texs7; // palette enb

sampler2D _s0 = sampler_state {
	Texture   = <texs0>;
	MinFilter = POINT;
	MagFilter = POINT;
	MipFilter = NONE; // LINEAR;
	AddressU  = Clamp;
	AddressV  = Clamp;
	SRGBTexture=FALSE;
	MaxMipLevel=0;
	MipMapLodBias=0;
};

sampler2D _s1 = sampler_state {
	Texture   = <texs1>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = NONE; // LINEAR;
	AddressU  = Clamp;
	AddressV  = Clamp;
	SRGBTexture=FALSE;
	MaxMipLevel=0;
	MipMapLodBias=0;
};

sampler2D _s2 = sampler_state {
	Texture   = <texs2>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = NONE; // LINEAR;
	AddressU  = Clamp;
	AddressV  = Clamp;
	SRGBTexture=FALSE;
	MaxMipLevel=0;
	MipMapLodBias=0;
};

sampler2D _s3 = sampler_state {
	Texture   = <texs3>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = NONE; // LINEAR;
	AddressU  = Clamp;
	AddressV  = Clamp;
	SRGBTexture=FALSE;
	MaxMipLevel=0;
	MipMapLodBias=0;
};

sampler2D _s4 = sampler_state {
	Texture   = <texs4>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = NONE; // LINEAR;
	AddressU  = Clamp;
	AddressV  = Clamp;
	SRGBTexture=FALSE;
	MaxMipLevel=0;
	MipMapLodBias=0;
};

sampler2D _s7 = sampler_state {
	Texture   = <texs7>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = NONE;
	AddressU  = Clamp;
	AddressV  = Clamp;
	SRGBTexture=FALSE;
	MaxMipLevel=0;
	MipMapLodBias=0;
};

struct VS_OUTPUT_POST {
	float4 vpos  	: POSITION;
	float2 txcoord0 : TEXCOORD0;
};

struct VS_INPUT_POST {
	float3 pos 		: POSITION;
	float2 txcoord0 : TEXCOORD0;
};

VS_OUTPUT_POST VS_Quad(VS_INPUT_POST IN){
	VS_OUTPUT_POST OUT;
	OUT.vpos=float4(IN.pos.x,IN.pos.y,IN.pos.z,1.0);
	OUT.txcoord0.xy=IN.txcoord0.xy;
	return OUT;
};

//skyrim shader specific externals, do not modify
	float4 _c1 : register(c1); float4 _c2 : register(c2); float4 _c3 : register(c3);
	float4 _c4 : register(c4); float4 _c5 : register(c5);

float4 PS_D6EC7DD1(VS_OUTPUT_POST IN, float2 vPos : VPOS) : COLOR {
	float4 _oC0 = 0.0; // output
	float4 _c6 = float4(0, 0, 0, 0);
	float4 _c7 = float4(0.212500006, 0.715399981, 0.0720999986, 1.0);
	float4 r0; float4 r1; float4 r2; float4 r3; float4 r4; float4 r5; float4 r6;
	float4 r7; float4 r8; float4 r9; float4 r10; float4 r11; float4 _v0=0.0; 
	_v0.xy = IN.txcoord0.xy;
    r1=tex2D(_s0, _v0.xy); // color
	r11=r1; // my bypass
	_oC0.xyz=r1.xyz; // for future use without game color corrections
	
	// HD6 - You can play with the night/day value here, not that its advisable to :-D
	// Visualize this with 'debug triangle' further down
	float hnd = ENightDayFactor;
	//hnd-=0.4;
	//hnd = hnd - (0.5-hnd);
	//hnd = max(hnd,0);
	//hnd = min(hnd,1);
	//hnd=1;
	
	float2 hndtweak = float2( 3.1 , 1.5 );
	float vhnd = hnd; // effects vignette stregth;
	float bchnd = hnd; // effects hd6 bloom crisp
	float cdhnd = hnd; // effects hd6 colorsat daynight
	
	// Some caves are seen as daytime, so I set key 3 to force nightime
	// This doesnt work very well >_<
	hnd = tempF1.z < 1 ? 0 : hnd;
	hndtweak.x = tempF1.z < 1 ? hndtweak.y : hndtweak.x; // Dont ask, I have no idea why I need this lol
	
	
	// HD6 - Alter Brightness using keyboard during gameplay
		
		float4 tuctbrt1 = uctbrt1;
		float4 tuctbrt2 = uctbrt2;
		float4 tuctcon  = uctcon;
		float4 tuctsat  = uctsat;
		
		#ifdef HD6_DARKER_NIGHTS
			tuctbrt1 -= darkenby1;
		#endif
				
		float h1 = lerp(-1,1,tempF1.x); // Increases speed it changes by when pressing key		
		h1 = lerp( h1, 1, hnd ); // Removes affect during day		
		h1 = h1 - (h1 % 0.1); // Changes it so incriments are in steps, remove this if you want smooth changes when pressing keys
		//float hbs = EBloomAmount;
		float hbs = lerp( EBloomAmount/2, EBloomAmount, h1); // Reduce bloom as it gets darker, otherwise it just gets hazier, higher number reduces bloom more as it gets darker
		
		float h2 = lerp(-1,1,tempF1.y); // Increases speed it changes by when pressing key
		h2 = lerp( 1, h2, hnd ); // Removes affect during night
		h2 = h2 - (h2 % 0.1); // Changes it so incriments are in steps, remove this if you want smooth changes when pressing keys
		hbs = lerp( (hbs/2)-1, hbs, h2); // Reduce bloom as it gets darker, otherwise it just gets hazier, higher number reduces bloom more as it gets darker
		hbs = max(0,hbs);
		hbs = min(2,hbs); // should be able to go above 1, but not 2
		
		vhnd = lerp(-2,hnd,h2);
		vhnd = max(0,vhnd); // do not go below 0;
		vhnd = min(1,vhnd); // not above 1, just incase people like surface of sun

		cdhnd=bchnd=vhnd;
		//cdhnd=0;
		//bchnd=0;
		//vhnd=0;
		
		#ifdef HD6_COLOR_TWEAKS
			//float2 uctbrt1t = 	float2( lerp( tuctbrt1.x, 	tuctbrt1.y, h1), tuctbrt1.z );
			//float2 uctbrt2t = 	float2( lerp( tuctbrt2.x, 	tuctbrt2.y,	h1), tuctbrt2.y );			
			//float2 uctcont  =	float2( lerp( tuctcon.x, 	tuctcon.y, 	h1), tuctcon.z );
			//float2 uctsatt  =	float2( lerp( tuctsat.x, 	tuctsat.y, 	h1), tuctsat.z );
			float2 uctbrt1t = 	float2( lerp( tuctbrt1.x, 	tuctbrt1.z, h1), lerp( tuctbrt1.y, 	tuctbrt1.w, h2) );
			float2 uctbrt2t = 	float2( lerp( tuctbrt2.x, 	tuctbrt2.z,	h1), lerp( tuctbrt2.y, 	tuctbrt2.w, h2) );			
			float2 uctcont  =	float2( lerp( tuctcon.x, 	tuctcon.z, 	h1), lerp( tuctcon.y, 	tuctcon.w, h2) );
			float2 uctsatt  =	float2( lerp( tuctsat.x, 	tuctsat.z, 	h1), lerp( tuctsat.y, 	tuctsat.w, h2) );
		#endif
		
	////
	
	
	
	#ifdef APPLYGAMECOLORCORRECTION
		//apply original
		r0.x=1.0/_c2.y;
		r1=tex2D(_s2, _v0);

		//r1.xyz = lerp( 0.28, 0.5, hnd ); // HD6 - disable vanilla adapation... because it drives me CRAAAZY!!!!! >_<
		//r1.xyz+=1.0;
		r1.xyz = lerp( min( 0.28, r1.xyz ), 0.5, hnd ); // Ligthen if dark, but do not darken if too light, we do this elsewhere for extreme bright situations
		// No seriously it screws up when looking at bright lights at night and the sky during day
		
		
		
		r0.yz=r1.xy * _c1.y;
		r0.w=1.0/r0.y;
		r0.z=r0.w * r0.z;
		r1=tex2D(_s0, _v0);
		r1.xyz=r1 * _c1.y;
		r0.w=dot(_c7.xyz, r1.xyz);
		r1.w=r0.w * r0.z;
		r0.z=r0.z * r0.w + _c7.w;
		r0.z=1.0/r0.z;
		r0.x=r1.w * r0.x + _c7.w;
		r0.x=r0.x * r1.w;
		r0.x=r0.z * r0.x;
		if (r0.w<0) r0.x=_c6.x;
		r0.z=1.0/r0.w;
		r0.z=r0.z * r0.x;
		r0.x=saturate(-r0.x + _c2.x);

		//r2=tex2D(_s3, _v0); // enb bloom
		r2=tex2D(_s1, _v0);//skyrim bloom
		
		#ifdef USEBLOOM	
			//r2.xyz=min(r2,0.5); // HD6 code to stop bloom causing glitches, inverting
			//r2.xyz=max(r2,0.1);
		#else
			//r2.xyz=0.2; // compensate for lack of bloom
		#endif
		r2.xyz=0.0; // Screw it bloom should not happen here at all so just set to 0
		r2+=0.1; // HD6 - I add 0.1 to lighten it a bit, probably not great place to do it now

			//r2=tex2D(_s1, _v0); // skyrim bloom
		r2.xyz=r2 * _c1.y;
		r2.xyz=r0.x * r2;
				
		r1.xyz=r1 * r0.z + r2;
		r0.x=dot(r1.xyz, _c7.xyz);
		r1.w=_c7.w;
		
		r2=lerp(r0.x, r1, _c3.x);
			
		r1=r0.x * _c4 - r2;
		r1=_c4.w * r1 + r2;
		r1=_c3.w * r1 - r0.y; // khajiit night vision _c3.w
		r0=_c3.z * r1 + r0.y;
		r1=-r0 + _c5;
		
		_oC0=_c5.w * r1 + r0;
		//_oC0=r0;
	#endif // APPLYGAMECOLORCORRECTION

	float4 color=_oC0;		
	
	//HD6 brighten when not using original gamma, so they are at least similiar
	// Bloom is diminshed for some reason, oh well, i dont use this
	#ifndef APPLYGAMECOLORCORRECTION
		color*=1.2;
		color+=0.1;			
	#endif
	
	#ifdef HD6_COLORSAT_DAYNIGHT
		// HeliosDoubleSix code to Desaturate at night	
		// What channels to desaturate by how much, so you could just reduce blue at night and nothing else	
		// doesnt seem quite right will tinge things green if you just remove blue :-/ thought perhaps that makes perfect sense :-) *brain hurts*
		// Remember this affects caves, so might be best to remove saturation from nighttime direct and ambient light
		float3 nsatn=lerp(dnsatd,dnsatn,1-cdhnd); // So it has less to different/no effect during day
			//nsatn*=(1-cdhnd); // affect by night time value:
		float3 oldcoln = color.xyz; // store old values
		color.xyz *= nsatn; // adjust saturation	
		
		// spread lost luminace over everything
			//float3 greycn = float3(0.299, 0.587, 0.114); // perception of color luminace
		float3 greycn = float3(0.333,0.333,0.333); // screw perception
			//greycn = float3(0.811,0.523,0.996);
		color.xyz += (oldcoln.x-(oldcoln.x*nsatn.x)) * greycn.x;
		color.xyz += (oldcoln.y-(oldcoln.y*nsatn.y)) * greycn.y;
		color.xyz += (oldcoln.z-(oldcoln.z*nsatn.z)) * greycn.z;
	#endif	
	
/*
	#ifndef APPLYGAMECOLORCORRECTION
		//temporary fix for khajiit night vision, but it also degrade colors.
		//	r1=tex2D(_s2, _v0);
		//	r0.y=r1.xy * _c1.y;
		r1=_oC0;
		r1.xyz=r1 * _c1.y;
		r0.x=dot(r1.xyz, _c7.xyz);
		r2=lerp(r0.x, r1, _c3.x);
		r1=r0.x * _c4 - r2;
		r1=_c4.w * r1 + r2;
		r1=_c3.w * r1;// - r0.y;
		r0=_c3.z * r1;// + r0.y;
		r1=-r0 + _c5;
		_oC0=_c5.w * r1 + r0;
	#endif //!APPLYGAMECOLORCORRECTION
*/

	//adaptation in time
	float4	Adaptation=tex2D(_s4, 0.5);
	float	grayadaptation=max(max(Adaptation.x, Adaptation.y), Adaptation.z);
		//grayadaptation=1.0/grayadaptation;


	float4	xcolorbloom=tex2D(_s3, _v0.xy); //bloom
	
	#ifdef HD6_BLOOM_NOBLACK
		// Helios code to remove dark/black from bloom, stopping it making dark shapes on light background bleed and smudge black into them like a black glow yuck
		// not really very good, looks like black glow is actually coming from original vanilla game or something, so its toned down for now to 0.05
			// really should make bloom only contain and affect light areas of scene, but this is ok for now.
			//This also has the side effect of lightening those darkest areas
		float lowestvalue=min(min(xcolorbloom.x,xcolorbloom.y),xcolorbloom.z);
			// work out lowest possible value to set RGB without going below 0 and without changing the RGB relative values ie shifting the color in the process
		float3 lowestpossible=xcolorbloom.xyz-lowestvalue;
		xcolorbloom.xyz=max(xcolorbloom.xyz,lowestpossible+(0.12*(1-hnd))); // adds 0.1 during night only
	#endif
	
	//xcolorbloom.xyz=0.2; //HDebug
	//float	maxb=max(xcolorbloom.x, max(xcolorbloom.y, xcolorbloom.z));
	//float	violetamount=maxb/(maxb+EVioletShiftAmountInv);
	//xcolorbloom.xyz=lerp(xcolorbloom.xyz, xcolorbloom.xyz*EVioletShiftColor, violetamount*violetamount);

	#ifdef HD6_BLOOM_DEBLUEIFY
		
		//New saturation to be // 0 being no color
				//float3 nsat=float3(1,0.74,0.64); // perfect-ish - removes blue and green from fog and outdoors, makes dwarven ruins very white though
				//float3 nsat=float3(1,0.80,0.74); // Touch greener 
				//float3 nsat=float3(1,0.70,0.65); // Grey, very grey ice gaves almost white, but... foggy days go pink
			//nsat=float3(0.85,0.75,0.7); // More reasnioable, still pink sky and snow in places
			//nsat=float3(0.80,0.75,0.73);
				//float3 nsat=float3(1,0.64,0.58);
				//float3 nsat=float3(1,0.74,0.90);	
				//float3 nsat=float3(0.8,0.56,0.46);
				//float3 nsat=float3(0.7,0.6,0.4); // desatures everything a bit
				//float3 nsat=float3(0,0,0); // no color in bloom, makes everything very desaturated, fire looks white almost

		// store old values
			float3 oldcol=xcolorbloom.xyz;
			
		// adjust saturation
			xcolorbloom.xyz *= nsat;
			
		// spread lost luminace over everything
				//float3 greyc = float3(0.299, 0.587, 0.114); // perception of color luminace
			float3 greyc = float3(0.333,0.333,0.333); // screw perception
			xcolorbloom.xyz += (oldcol.x-(oldcol.x*nsat.x)) * greyc.x;
			xcolorbloom.xyz += (oldcol.y-(oldcol.y*nsat.y)) * greyc.y;
			xcolorbloom.xyz += (oldcol.z-(oldcol.z*nsat.z)) * greyc.z;

		// equiv to bloom off without destroyng scene luminance-ish
		//xcolorbloom.x=0.3;
		//xcolorbloom.y=0.3;
		//xcolorbloom.z=0.3;

		//xcolorbloom.xyz=min(xcolorbloom.xyz,1.2);
	#endif

	#ifdef HD6_BLOOM_DEFUZZ
			// Heliosdouble cobbled together bloom defuzzer - increases contrast of bloom / stop it hazing low brightness values
			// what a fudge... but... it works... fancy that
			// modulated by the overall brightness of the screen.
		float mavg=((xcolorbloom.x+xcolorbloom.y+xcolorbloom.z)*0.333);
		xcolorbloom.xyz-=(mavg*0.3);
			//xcolorbloom.xyz=min(xcolorbloom.xyz,0.0);
		xcolorbloom.xyz+=(mavg*0.22);
		xcolorbloom.xyz*(mavg*1.2);
	#endif

	
	// Altering color balance is confusing, also Im not entirely sure it works properly :-D
	#ifdef HD6_COLOR_TWEAKS
		float ctbrt1 = lerp(uctbrt1t.x,uctbrt1t.y,hnd); // Brightness Night, Day (Alters before contrast adjustment)
		float ctbrt2 = lerp(uctbrt2t.x,uctbrt2t.y,hnd); // Brightness Night, Day (Alters after contrast adjustment)
		float ctcon = lerp(uctcont.x,uctcont.y,hnd); // Contrast Night, Day
		float ctsat = lerp(uctsatt.x,uctsatt.y,hnd); // Saturation Night, Day
		
		float3 ctLumCoeff = float3(0.2125, 0.7154, 0.0721);				
		float3 ctAvgLumin = float3(0.5, 0.5, 0.5);
		float3 ctbrtColor = color.rgb * ctbrt1;

		float3 ctintensity = dot(ctbrtColor, ctLumCoeff);
		float3 ctsatColor = lerp(ctintensity, ctbrtColor, ctsat); 
		float3 cconColor = lerp(ctAvgLumin, ctsatColor, ctcon);
		
		color.xyz = cconColor * ctbrt2;
		float3 cbalance = lerp(rgbn,rgbd,hnd);
		color.xyz=cbalance.xyz * color.xyz;
	#endif
	
	
	#ifdef USEBLOOM	
		#ifdef HD6_BLOOM_CRISP	
			float3 LumCoeff = float3( 0.2125, 0.7154, 0.0721 );				
			float3 AvgLumin = float3( 0.5, 0.5, 0.5 );
				//color*=1.06;
				//color*=1.0; // Brighten it up without loosing contrast
				//color += lerp(0.1,0.1,bchnd); // Night, Day, increase kinda lowers contrast, but makes things look more washed out also, this is to lift black areas really
				//color+=((color/2)*EBloomAmount);
				//xcolorbloom-=0.4;
				//xcolorbloom=max(xcolorbloom,0); // will cause color shift/desaturation also
				//color.xyz+=(color.xyz*(xcolorbloom*EBloomAmount*0.2))+(xcolorbloom/1.5);
				//color.xyz=(color.xyz*color.xyz)/2;			
				//color.xyz=(color.xyz*0.5)+((color.xyz*(xcolorbloom*EBloomAmount))*0.5);
				//color.xyz*=0.8;		
				//color.xyz*=1.4;
				
			float3 brightbloom = ( xcolorbloom - lerp( 0.18, 0.0, bchnd )); // darkens and thus limits what triggers a bloom, used in part to stop snow at night glowing blue
			brightbloom = max( brightbloom , 0);
			
			float3 superbright = xcolorbloom - 0.7; // crop it to only include superbright elemnts like sky and fire
			superbright = max( superbright , 0 ) ; // crop so dont go any lower than black
				//superbright = lerp( AvgLumin, superbright, 0.5); // Contrast
			superbright *= 0.6;
			
				
				//float lowestvaluec=min(min(brightbloom.x,brightbloom.y),brightbloom.z);
				//float3 lowestpossiblec=brightbloom.xyz-lowestvaluec;
				//brightbloom=max(brightbloom.xyz,lowestpossiblec);			
			
			// HD6 - Bloom - Brightntess, Contrast, Saturation adjustment 1,1,1 for no change // Remember this is bloom only being altered
				float brt = lerp( 1.0, 1.0, bchnd ) ; // doesnt work properly, should be done after contrast no?
				//
				float con = lerp( 1.1, 1.0, bchnd ); // 1.0, 0.8 // 1.1, 1.1				
				float sat = lerp( 0.8, 0.7, bchnd ); // 0.5, 0.7 // 0.7, 0.7 
				//
				
				float3 brtColor = brightbloom * brt;
				float3 cintensity = dot( brtColor, LumCoeff );
				float3 satColor = lerp( cintensity, brtColor, sat ); 
				float3 conColor = lerp( AvgLumin, satColor, con );
				conColor -= 0.3;
				brightbloom = conColor;
				
				
				
				// These 2 should compensate so when even when no bloom exists it still matches brightness of scene without ENB
			color.xyz += lerp( 0.12, 0.23, bchnd ); color.xyz *= lerp( 1.1, 1.4, bchnd );
			
			// Now Add bloom and compensate for any brightness changes that introduces
			
			color.xyz += (( superbright * hbs ) * lerp( 1.0, 1.0, bchnd ));
			brightbloom -= ( superbright * 2 ); // removes superbright from brightbloom so I dont bloom the brightest area twice
			brightbloom = max( brightbloom , 0.0 );
			color.xyz += (( brightbloom * hbs ) * lerp( 1.0, 1.0, bchnd ));

				// Blend in some of the orignal bloom to bring back SOME of the hazy glow of the day, none at night
				// 1.0, 0.9 - 0.7, 0.6
			color.xyz += (xcolorbloom.xyz * hbs) * lerp( 0.7, 0.6, bchnd );
			color.xyz *= lerp( 0.8, 0.7, bchnd ); // compensate for brightening caused by above bloom
				// End Blend
			
				//color.xyz *= 1.0;
				//color.xyz += (xcolorbloom * 0.3);
				//color.xyz += 0.25;
				//float4 debug = color;
				//debug.xyz = ( superbright * EBloomAmount * 1 );			
			
				//color.xyz+=((xcolorbloom*EBloomAmount)/1);
				//color.xyz*=lerp(1.25,0.8,bchnd); // 1.25, 1 // Darkens end result to rematch with how it looks without BLOOM CRISP enabled
			
		#else
			#ifdef HD6_BLOOM_SCREEN
				// Helios code to restrict bloom to bright areas only, not smudging dark outs around
				color+=((color/1)*EBloomAmount); // compensate if bloom disabled	
					//color+=0.1;
					//xcolorbloom-=0.5;
				xcolorbloom=max(xcolorbloom,0); // will cause color shift/desaturation also
					//xcolorbloom+=0.2;
					// Soft Light: X = (((255-L)*U*L)+ (L*R_s))/255
					//1 - ((1.0 - base) * (1.0 - blend))
					//1 - ((255-U)*(255-L))/255
					//xcolorbloom.xyz*=EBloomAmount;
				float tmult = 10;
				color/=tmult; xcolorbloom/=tmult; // Screen mode wont work with floating point numbers / big numbers, so I reduce it first
				
				color.x = 1.0 - ((1.0 - color.x) * (1.0 - xcolorbloom.x));
				color.y = 1.0 - ((1.0 - color.y) * (1.0 - xcolorbloom.y));
				color.z = 1.0 - ((1.0 - color.z) * (1.0 - xcolorbloom.z));
				color*=tmult;		
			// End helios code
			#else	
				float tt=1;
					//float3 tt = float3(1*tempF1.x,1*tempF1.x,1*tempF1.x);
				color.xyz+=((xcolorbloom.xyz*EBloomAmount)*tt);
			#endif 	
		#endif 
	#else
		// No bloom
		color+=((color/1)*EBloomAmount); // compensate if bloom disabled
	#endif
		
	//+++++++++++++++++++++++++++++
		
	#ifdef HD6_VIGNETTE		
		// yes this is my own crazy creation after seing how boring the usual linear circle vignettes typically are
		// no doubt I have done it in an overly convoluted way :-)
		
			//float fExposureLevel = 1.0; // compensate for any change from vignette so center is same brightness
		float2 inTex = _v0;	
		float4 voriginal = r1;
		float4 vcolor = voriginal;
		vcolor.xyz=1;
		inTex -= 0.5; // Centers vignette
		inTex.y += 0.01; // Move it off center and up so it obscures sky less
		float vignette = 1.0 - dot( inTex, inTex );
		vcolor *= pow( vignette, vignettepow );
		
		
		// Round Vignette
		float4 rvigtex = vcolor;
		rvigtex.xyz = pow( vcolor, 1 );
		rvigtex.xyz = lerp(float3(0.5, 0.5, 0.5), rvigtex.xyz, 2.0); // Increase Contrast
		rvigtex.xyz = lerp(float3(1,1,1),rvigtex.xyz,rovigpwr); // Set strength of round vignette
		
		// Square Vignette (just top and bottom of screen)
		float4 vigtex = vcolor;
		vcolor.xyz = float3(1,1,1);
		float3 topv = min((inTex.y+0.5)*2,0.5) * 2; // Top vignette
		float3 botv = min(((0-inTex.y)+0.5)*2,0.5) * 2; // Bottom vignette
		
		topv= lerp(float3(1,1,1), topv, sqvigpwr.x);
		botv= lerp(float3(1,1,1), botv, sqvigpwr.y);
		vigtex.xyz = (topv)*(botv);
		
		//vigtex.xyz = lerp(float3(1,1,1),vigtex.xyz,sqvigpwr); // Set strength of square vignette
				
		// Add round and square together
		vigtex.xyz*=rvigtex.xyz; 
		
		vigtex.xyz = lerp(vigtex.xyz,float3(1,1,1),(1-vstrengthatnight)*(1-vhnd)); // Alter Strength at night
		
			vigtex.xyz = min(vigtex.xyz,1);
			vigtex.xyz = max(vigtex.xyz,0);
			//vigtex.xyz -= 0.5;
			//(base < 0.5 ? (2.0 * base * blend) : (1.0 - 2.0 * (1.0 - base) * (1.0 - blend)))
			//vigtex.xyz = vigtex.xyz < 0.5 ? (2.0 * color.xyz * vigtex.xyz) : (1 - 2 * (1 - color.xyz) * (1 - vigtex.xyz));
			// Crap I keep forgetting overlay mode doesnt work in floating point/32bit/hdr dur bee durr
				
		// Increase saturation where edges were darkenned
		float3 vtintensity = dot(color.xyz, float3(0.2125, 0.7154, 0.0721));
		color.xyz = lerp(vtintensity, color.xyz, ((((1-(vigtex.xyz*2))+2)-1)*vsatstrength)+1  );
		
			//color.xyz+=0.02;
		color.xyz *= (vigtex.xyz);
			//color.xyz *= fExposureLevel;	
		
	#endif
	
	// HD6 - Warning, Code below appears to reduce 'color.xyz' to 8bit / LDR
		
		
	// HD6 - Eye Adaptation for extreme extreme over bright areas only, such as stupid stupid snow
	// 0.3, 0.9 - affects day time sunny day = bad
	float toobright = max(0,tex2D(_s2, _v0).xyz - 0.2); // 0.5
	color.xyz *= 1-(0.5 * toobright); // 1.3
	
	
	// <Lazy> HD6 - dopey arse code to alter enbpalette because im too lazy to open photoshop
		// when using your own palette remove this.. ill fix this.. next
		float palmix = 0.8; // 0.4
		//color.xyz*=1.1;
		color.xyz*=lerp( 1.0, 1.10, palmix); // 0.9
	// </Lazy>
	
	
	float s1 = lerp(-1,1,tempF1.w); // Increases speed it changes by when pressing key		
	s1 = s1 - (s1 % 0.1);
	
	float3 sat1 = float3(0,0,0);
	float3 sat2 = float3(1,1,1);
	
	float3 snsat = lerp(sat1,sat2,s1);
	// store old values
		float3 soldcol=color.xyz;
		
	// adjust saturation
		color.xyz *= snsat;
		
	// spread lost luminace over everything
			//float3 sgreyc = float3(0.299, 0.587, 0.114); // perception of color luminace
		float3 sgreyc = float3(0.333,0.333,0.333); // screw perception
		color.xyz += (soldcol.x-(soldcol.x*snsat.x)) * sgreyc.x;
		color.xyz += (soldcol.y-(soldcol.y*snsat.y)) * sgreyc.y;
		color.xyz += (soldcol.z-(soldcol.z*snsat.z)) * sgreyc.z;
		
		
	//+++++++++++++++++++++++++++++
	#if (POSTPROCESS==1)
		grayadaptation=max(grayadaptation, 0.0);
		grayadaptation=min(grayadaptation, 50.0);
		color.xyz=color.xyz/(grayadaptation*EAdaptationMaxV1+EAdaptationMinV1);//*tempF1.x
		
		float cgray=dot(color.xyz, float3(0.27, 0.67, 0.06));
		cgray=pow(cgray, EContrastV1);
		float3 poweredcolor=pow(color.xyz, EColorSaturationV1);
		float newgray=dot(poweredcolor.xyz, float3(0.27, 0.67, 0.06));
		color.xyz=poweredcolor.xyz*cgray/(newgray+0.0001);

		float3	luma=color.xyz;
		float	lumamax=300.0;
		color.xyz=(color.xyz * (1.0 + color.xyz/lumamax))/(color.xyz + EToneMappingCurveV1);
	#endif
	//+++++++++++++++++++++++++++++
	
	//+++++++++++++++++++++++++++++
	#if (POSTPROCESS==2)
		grayadaptation=max(grayadaptation, 0.0);
		grayadaptation=min(grayadaptation, 50.0);
		color.xyz=color.xyz/(grayadaptation*EAdaptationMaxV2+EAdaptationMinV2);//*tempF1.x

		//color.xyz*=EBrightnessV2;
		color.xyz+=0.000001;
		float3 xncol=normalize(color.xyz);
		float3 scl=color.xyz/xncol.xyz;
		scl=pow(scl, EIntensityContrastV2);
		xncol.xyz=pow(xncol.xyz, EColorSaturationV2);
		color.xyz=scl*xncol.xyz;

		float	lumamax=EToneMappingOversaturationV2;
		color.xyz=(color.xyz * (1.0 + color.xyz/lumamax))/(color.xyz + EToneMappingCurveV2);
	#endif
	//+++++++++++++++++++++++++++++

	//+++++++++++++++++++++++++++++ HD6 version based on postprocess 2
	#if (POSTPROCESS==5)
			grayadaptation=max(grayadaptation, 0.0);
			grayadaptation=min(grayadaptation, 50.0);
			//color.xyz=color.xyz/(grayadaptation*EAdaptationMaxV2+EAdaptationMinV2); //*tempF1.x		
		// HD6 - Screw eye adaptation it drives me mad, bright sky causes everything else to darken yuck
		// Human eye adaptation happens instantly or so slowly you dont notice it in reality
		// it would make sense if the game was calibrated for true brightness values of indoors and outdoors being 10000x brighter
		// but it isnt, and thus all the pseudo tone mapping and linear colorspace adaption shenanigans just drives me mad and for little gain
		// So now simple adjust brightness based on time of day
		// with all the other effects turned off this should roughly equal the brightness when ENB is disabled
		//color.xyz*=lerp( 3.1, 1.5, hnd );
		color.xyz*=lerp( hndtweak.x, hndtweak.y, hnd );

			//color.xyz*=EBrightnessV2;
			//color.xyz+=0.000001; // HD6 - Why? how curious
		float3 xncol=normalize(color.xyz);
		float3 scl=color.xyz/xncol.xyz;
		scl=pow(scl, EIntensityContrastV2);
		xncol.xyz=pow(xncol.xyz, EColorSaturationV2);
		color.xyz=scl*xncol.xyz;
		color.xyz*=HCompensateSat; // compensate for darkening caused my EcolorSat above

			//float	lumamax=EToneMappingOversaturationV2;
			//color.xyz=(color.xyz * (1.0 + color.xyz/lumamax))/(color.xyz + EToneMappingCurveV2);

		color.xyz=color.xyz/(color.xyz + EToneMappingCurveV2);
			//color.xyz=tex2D(_s0, _v0.xy);
			//color.xyz=color.xyz-0.03;
			//color.xyz/=10;
	#endif
	//+++++++++++++++++++++++++++++

	//+++++++++++++++++++++++++++++
	#if (POSTPROCESS==3)
		grayadaptation=max(grayadaptation, 0.0);
		grayadaptation=min(grayadaptation, 50.0);
		color.xyz=color.xyz/(grayadaptation*EAdaptationMaxV3+EAdaptationMinV3); //*tempF1.x

		//float3	luma=color.xyz;
		//float	lumamax=20.0;
		float	lumamax=EToneMappingOversaturationV3;
		color.xyz=(color.xyz * (1.0 + color.xyz/lumamax))/(color.xyz + EToneMappingCurveV3);
	#endif
	//+++++++++++++++++++++++++++++
	//color.xyz=tex2D(_s0, _v0.xy) + xcolorbloom.xyz*float3(0.7, 0.6, 1.0)*0.5;
	//color.xyz=tex2D(_s0, _v0.xy) + xcolorbloom.xyz*float3(0.7, 0.6, 1.0)*0.5;
	//color.xyz*=0.7;

	//+++++++++++++++++++++++++++++
	#if (POSTPROCESS==4)
		grayadaptation=max(grayadaptation, 0.0);
		grayadaptation=min(grayadaptation, 50.0);
		color.xyz=color.xyz/(grayadaptation*EAdaptationMaxV4+EAdaptationMinV4);

		float Y = dot(color.xyz, float3(0.299, 0.587, 0.114)); //0.299 * R + 0.587 * G + 0.114 * B;
		float U = dot(color.xyz, float3(-0.14713, -0.28886, 0.436)); //-0.14713 * R - 0.28886 * G + 0.436 * B;
		float V = dot(color.xyz, float3(0.615, -0.51499, -0.10001)); //0.615 * R - 0.51499 * G - 0.10001 * B;
		
		Y=pow(Y, EBrightnessCurveV4);
		Y=Y*EBrightnessMultiplierV4;
			//Y=Y/(Y+EBrightnessToneMappingCurveV4);
			//float	desaturatefact=saturate(Y*Y*Y*1.7);
			//U=lerp(U, 0.0, desaturatefact);
			//V=lerp(V, 0.0, desaturatefact);
		color.xyz=V * float3(1.13983, -0.58060, 0.0) + U * float3(0.0, -0.39465, 2.03211) + Y;

		color.xyz=max(color.xyz, 0.0);
		color.xyz=color.xyz/(color.xyz+EBrightnessToneMappingCurveV4);
	#endif
	//+++++++++++++++++++++++++++++

	
	
	//+++++++++++++++++++++++++++++
	//pallete texture (0.082+ version feature)
	#ifdef E_CC_PALETTE
		
		
		color.rgb=saturate(color.rgb);
		float3	brightness=Adaptation.xyz; //tex2D(_s4, 0.5); //adaptation luminance
			//brightness=saturate(brightness); //old version from ldr games
		brightness=(brightness/(brightness+1.0));//new version
		brightness=max(brightness.x, max(brightness.y, brightness.z));//new version
		float3	palette;
		float4	uvsrc=0.0;
		uvsrc.y=brightness.r;
		uvsrc.x=color.r;
		palette.r=tex2Dlod(_s7, uvsrc).r;
		uvsrc.x=color.g;
		uvsrc.y=brightness.g;
		palette.g=tex2Dlod(_s7, uvsrc).g;
		uvsrc.x=color.b;
		uvsrc.y=brightness.b;
		palette.b=tex2Dlod(_s7, uvsrc).b;		
		
		color.rgb=lerp( color.rgb, palette.rgb, palmix );
		
		//color.rgb=toobright;
	#endif //E_CC_PALETTE
	//+++++++++++++++++++++++++++++

		
	/*
	// HeliosDoubleSix cobbled code to Cap values above 0, not great as limits how black it can do say if it was pure red?!
	// what is the lowest value out of r,g,b
		float lowestvalue=min(min(color.x,color.y),color.z);
		// work out lowest possible value to set RGB without going below 0 and without changing the RGB relative values ie shifting the color in the process
		float3 lowestpossible=color.xyz-lowestvalue;
		color.xyz=max(color.xyz,lowestpossible);
		//color.r=max(color.r,lowestpossible.x);
		//color.g=max(color.g,lowestpossible.y);
		//color.b=max(color.b,lowestpossible.z);
	*/

		//color.xyz=saturate(xcolorbloom.xyz);
		//color.xyz-=(pow(color.xyz, 6)/2);
		//color.xyz=max(0,color.xyz);
		//color.xyz=debug;

	/*
		//temporary testing
		color.xyz=tex2D(_s0, _v0.xy);
		//color.xyz=xcolorbloom.xyz*tempF1.x;

		//color.xyz=pow(color.xyz, 0.5);
		color.xyz+=(xcolorbloom.xyz-color.xyz)*tempF1.y;
		//color.xyz=xcolorbloom.xyz*tempF1.y;
		color.xyz=color.xyz*tempF1.x;
		//color.xyz=color.xyz/(color.xyz +1.0*tempF1.z);
		color.xyz=(color.xyz * (1.0 + color.xyz/40))/(color.xyz + EToneMappingCurveV3);
			Adaptation=tex2D(_s4, 0.5);
			grayadaptation=max(max(Adaptation.x, Adaptation.y), Adaptation.z);
			grayadaptation=max(grayadaptation, 0.0);
			grayadaptation=min(grayadaptation, 50.0);
		//	color.xyz=Adaptation*2;//*tempF1.x

		//color.xyz=tex2D(_s0, _v0.xy)*1.3;
	*/

	//color.xyz=tex2D(_s0, _v0.xy)*pow(tempF1.x,4);
	//color.xyz=max(xcolorbloom.xyz, tex2D(_s0, _v0.xy).xyz)*pow(tempF1.x,4)*0.7;

	
	
	 
	 
	_oC0.w=1.0;
	_oC0.xyz=color.xyz;
	//_oC0.xyz=debug;
	
	// HD6 - debug triangle - draws a triangle top left showing the value of night/day for testing
	//_oC0.xyz = _v0.x+_v0.y < 0.1 ? (hnd) : (_oC0.xyz);
	float h11 = h1 == 1 ? 0 : 0.4;
	_oC0.xyz += _v0.x+_v0.y < dotsize ? (h11) : (0);
	
	// Red dot in bottom left if you adjust daytime
	float h22 = h2 == 1 ? 0 : 0.4;
	_oC0.xyz += _v0.x+(1-_v0.y) < dotsize ? (h22) : (0);
	
	// White dot in top right if you adjust saturation
	float h33 = s1 == 1 ? 0 : 0.4;
	_oC0.xyz += (1-_v0.x)+_v0.y < dotsize ? (h33) : (0);
	
	return _oC0;
}




//switch between vanilla and mine post processing
#ifndef ENB_FLIPTECHNIQUE
	technique Shader_D6EC7DD1
#else
	technique Shader_ORIGINALPOSTPROCESS
#endif
{
	pass p0
	{
		VertexShader = compile vs_3_0 VS_Quad();
		PixelShader = compile ps_3_0 PS_D6EC7DD1();

		ColorWriteEnable=ALPHA|RED|GREEN|BLUE;
		ZEnable=FALSE;
		ZWriteEnable=FALSE;
		CullMode=NONE;
		AlphaTestEnable=FALSE;
		AlphaBlendEnable=FALSE;
		SRGBWRITEENABLE=FALSE;
	}
}


// HD6 - below doesnt make any diff??? so I disabled it *shrugs*
/*
//original shader of post processing
#ifndef ENB_FLIPTECHNIQUE
	technique Shader_ORIGINALPOSTPROCESS
#else
	technique Shader_D6EC7DD1
#endif
{
	pass p0
	{
		VertexShader  = compile vs_3_0 VS_Quad();
		PixelShader=
	asm
	{
// Parameters:
//   sampler2D Avg;
//   sampler2D Blend;
//   float4 Cinematic;
//   float4 ColorRange;
//   float4 Fade;
//   sampler2D Image;
//   float4 Param;
//   float4 Tint;


// Registers:

//   Name         Reg   Size
//   ------------ ----- ----
//   ColorRange   c1       1
//   Param        c2       1
//   Cinematic    c3       1
//   Tint         c4       1
//   Fade         c5       1
//   Image        s0       1
//   Blend        s1       1
//   Avg          s2       1
//s0 bloom result
//s1 color
//s2 is average color

    ps_3_0
    def c6, 0, 0, 0, 0
    //was c0 originally
    def c7, 0.212500006, 0.715399981, 0.0720999986, 1
    dcl_texcoord v0.xy
    dcl_2d s0
    dcl_2d s1
    dcl_2d s2
    rcp r0.x, c2.y
    texld r1, v0, s2
    mul r0.yz, r1.xxyw, c1.y
    rcp r0.w, r0.y
    mul r0.z, r0.w, r0.z
    texld r1, v0, s1
    mul r1.xyz, r1, c1.y
    dp3 r0.w, c7, r1
    mul r1.w, r0.w, r0.z
    mad r0.z, r0.z, r0.w, c7.w
    rcp r0.z, r0.z
    mad r0.x, r1.w, r0.x, c7.w
    mul r0.x, r0.x, r1.w
    mul r0.x, r0.z, r0.x
    cmp r0.x, -r0.w, c6.x, r0.x
    rcp r0.z, r0.w
    mul r0.z, r0.z, r0.x
    add_sat r0.x, -r0.x, c2.x
    texld r2, v0, s0
    mul r2.xyz, r2, c1.y
    mul r2.xyz, r0.x, r2
    mad r1.xyz, r1, r0.z, r2
    dp3 r0.x, r1, c7
    mov r1.w, c7.w
    lrp r2, c3.x, r1, r0.x
    mad r1, r0.x, c4, -r2
    mad r1, c4.w, r1, r2
    mad r1, c3.w, r1, -r0.y
    mad r0, c3.z, r1, r0.y
    add r1, -r0, c5
    mad oC0, c5.w, r1, r0

	};
		ColorWriteEnable=ALPHA|RED|GREEN|BLUE;
		ZEnable=FALSE;
		ZWriteEnable=FALSE;
		CullMode=NONE;
		AlphaTestEnable=FALSE;
		AlphaBlendEnable=FALSE;
		SRGBWRITEENABLE=FALSE;
    }
}
*/
