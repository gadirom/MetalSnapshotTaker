let metalFunctions = """

#include <metal_stdlib>

using namespace metal;

typedef struct
{
   float time;
} Uniforms;

#define MAX_STEPS 5
#define MAX_DIST 70.0
#define SURF_DIST 0.001

 //distance for softmin:

#define K_Dist 0.5

float smin(float a, float b, float k) {
    float h = clamp(0.5 + 0.5*(a-b)/k, 0.0, 1.0);
    return mix(a, b, h) - k*h*(1.0-h);
}

float sdSphere( float3 p, float3 c, float r ) {
    return length(p - c) - r;
}

float getDist( float3 p, float time ) {
    float sphere = sdSphere(p, float3(0, 0, 6), 0.5);
    float distort = sin(1*p.x+time*2)*cos(2*p.y+time*2)*sin(3*p.z+time*1);
    float scene = sphere + distort*2;
    return scene;
}

float castRay( float3 ro, float3 rd, float zDir, float time) {
    float d0 = 0.0;
    bool max = false;
    
    for (int i = 0; i < MAX_STEPS; i++) {
        float3 p = ro + d0 * rd;
        float dS = getDist(p, time)*zDir;
        
        d0 += dS;        
        if ( dS <= SURF_DIST || d0 >= MAX_DIST ) {
         max = true;
         break;
        }
    }
    
    return max ? -1 : d0;
}

float3 getNormal(float3 p, float time ) {
  float d = getDist(p, time);
  float2 e = float2(0.01, 0.);
  
  float3 n = d - float3( getDist(p - e.xyy, time),
                         getDist(p - e.yxy, time),
                         getDist(p - e.yyx, time) );
                     
  return normalize(n);
}

float getLight(float3 p, float3 rd, float zDir, float time ) {
  
  float3 n = getNormal(p, time);

  n *= zDir; 
  
  float frensel = pow(0.5+abs(dot(rd, n)), 5);
  
  return frensel;
}

kernel void ray_march(texture2d<float, access::write> output [[texture(0)]],
                   constant Uniforms& uniforms [[buffer(0)]],
                   uint2 gid [[thread_position_in_grid]])

{
    uint2 textureSize = uint2(output.get_width(), output.get_height());
    if (gid.x >= textureSize.x || gid.y >= textureSize.y) {
        return;
    }
    float time = uniforms.time;

    int width = output.get_width();
    int height = output.get_height();
    float2 uv = (float2(width, height) * 0.5 - float2(gid) ) / height;
    
    float3 ro = float3(0.0, 0.0, 0.0);
    float3 rd = normalize(float3(uv, 1.0));
    
    float d = castRay(ro, rd, 1, time);

    float light;
    float3 pBack;
    if (d == -1){
       light = 0;
    }else{
       float3 pFront = ro + d * rd;
       float lightFront = getLight(pFront, rd, 1., time);
       float3 pFrontStart = pFront + rd*SURF_DIST*10;
       float3 n = getNormal(pFrontStart, time);
       float dBack = castRay(pFrontStart, n, -1, time);
       pBack = pFrontStart + dBack * rd;
       float lightBack = getLight(pBack, rd, -1., time);
       light = (lightBack-4)*0.5 + lightFront;
    }
    float3 col = float3(light*0.5, light*0.2, light);
    //if (light>0){
       //col = getNormal(pBack, time);
    //}
   
    output.write(float4(col, 1.0), gid);
}

"""

