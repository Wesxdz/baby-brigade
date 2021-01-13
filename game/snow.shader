shader_type spatial;

uniform float base_height = 2.0;
uniform float noise_height = 2.0;
uniform float noise_density = 4.0;
uniform vec3 snow_color = vec3(0.5, 0.8, 1.0);
uniform vec3 compressed_color = vec3(0.4, 0.1, 0.5);

uniform vec3 displacement_pos;
uniform float displacement_radius;

// Samples fade their effects as more samples are added
// TODO: In Godot 4.0 displacement samples should be global so multiple terrain
// chunks can be used
uniform int next_sample_index;
uniform int displacement_sample_root_size;
uniform sampler2D displacement_samples;

uniform sampler2D baseAlbedo : hint_albedo;
uniform sampler2D redAlbedo : hint_albedo;

float hash(vec2 p) {
  return fract(sin(dot(p * 17.17, vec2(14.91, 67.31))) * 4791.9511);
}

float noise(vec2 x) {
  vec2 p = floor(x);
  vec2 f = fract(x);
  f = f * f * (3.0 - 2.0 * f);
  vec2 a = vec2(1.0, 0.0);
  return mix(mix(hash(p + a.yy), hash(p + a.xy), f.x),
         mix(hash(p + a.yx), hash(p + a.xx), f.x), f.y);
}

float fbm(vec2 x) {
  float height = 0.0;
  float amplitude = 0.5;
  float frequency = 3.0;
  for (int i = 0; i < 6; i++){
    height += noise(x * frequency) * amplitude;
    amplitude *= 0.5;
    frequency *= 2.0;
  }
  return height;
}

float calc_displacement(vec3 vertex)
{
	vec3 to_displacement = displacement_pos - vertex;
	float dist = length(to_displacement);
	float pack = dist/displacement_radius;
	return clamp(pack, 0.0, 1.0);
}

float calc_multi_displacement(vec3 vertex)
{
	float displacement = 1.0;
	for (int y = 0; y < displacement_sample_root_size; y++)
	{
		for (int x = 0; x < displacement_sample_root_size; x++)
		{
			vec4 data = texelFetch(displacement_samples, ivec2(x, y), 0);
			vec3 to_displacement = vec3(data.x, data.y, data.z) - vertex;
			float dist = length(to_displacement);
			float pack = clamp(dist/data.w, 0.0, 1.0);
			displacement -= (1.0 - pack);
		}
	}
	return clamp(displacement, 0.2, 1.0);
}

void vertex() {
  vec2 e = vec2(0.01, 0.0);
  vec3 normal = vec3(0.0, 1.0, 0.0);
//  vec3 normal = normalize(vec3(fbm(VERTEX.xz - e) - fbm(VERTEX.xz + e), 2.0 * e.x, fbm(VERTEX.xz - e.yx) - fbm(VERTEX.xz + e.yx)));
  NORMAL = normal;
  float noise = 1.0;
//  float noise = fbm(vec2(float(int(VERTEX.x) % 100), float(int(VERTEX.z) % 100)) * noise_density);
  float snow_height = base_height + noise * noise_height;
  float displacement = 1.0;
//  float displacement = clamp(calc_multi_displacement(VERTEX), 0.2, 1.0); //- (1.0 - calc_displacement(VERTEX))
  VERTEX.y += snow_height * displacement;
  COLOR.xyz = vec3(noise) * displacement;
  COLOR.xyz *= 2.0;
  COLOR.xyz *= snow_color;
  COLOR.xyz *= 1.8;
  // compressed snow should be grey and less colorful
  COLOR.xyz = COLOR.xyz * displacement + compressed_color * (1.0 - displacement);

  // Debug
//  COLOR.xyz = vec3(0);
//  COLOR.x = displacement;
}


void fragment(){
vec3 base = texture(baseAlbedo, UV).rgb;
vec3 red = texture(redAlbedo, UV).rgb;

//ALBEDO = COLOR.r * red.rgb + (1.0 - COLOR.r) * base.rgb;
ALBEDO = min(COLOR.xyz, base.rgb);
ROUGHNESS = 1.0;
SPECULAR = 0.0;
METALLIC = 0.0;
}

