extern float theta = 3.14159 + 3.14159 / 2;
extern vec3 cameraPos;
extern float cameraTheta;
extern Image textureToMap;
extern float x;
extern float y;
extern float z;
extern float rx;
extern float ry;
extern float rz;

float width = love_ScreenSize.x;
float height = love_ScreenSize.y;

float angle = 3.14159 + 3.14159 / 2;

varying vec4 vpos;
varying vec3 origPos;
varying vec3 normal;
varying vec3 texColor;
varying vec3 light;

#ifdef VERTEX

attribute vec3 VertexNormal;
attribute vec3 Texture;

mat4 rotateY = mat4(vec4(cos(ry),0,-sin(ry),0),vec4(0,1,0,0),vec4(sin(ry),0,cos(ry),0),vec4(0,0,0,1));
mat4 rotateX = mat4(vec4(1,0,0,0),vec4(0,cos(rx),sin(rx),0),vec4(0,-sin(rx),cos(rx),0),vec4(0,0,0,1));
mat4 rotateZ = mat4(vec4(cos(rz),sin(rz),0,0),vec4(-sin(rz),cos(rz),0,0),vec4(0,0,1,0),vec4(0,0,0,1));


vec4 position( mat4 transform_projection, vec4 vertex_position )
{
    normal = normalize(VertexNormal);
    texColor = Texture;

    //normal = VertexNormal;

    
    vertex_position.x += x;
    vertex_position.y += y;
    vertex_position.z += z;
    

    origPos = vertex_position.xyz;

    vertex_position.xyz -= cameraPos;

    mat4 cameraRotate = mat4(vec4(cos(cameraTheta),0,-sin(cameraTheta),0),vec4(0,1,0,0),vec4(sin(cameraTheta),0,cos(cameraTheta),0),vec4(0,0,0,1));


    vec4 center = vec4(x,y,z,0) - vec4(cameraPos,0);

    //center = cameraRotate * center;

    
    light = vec3(0,0,0);
    light = cameraPos;

    
    vertex_position -= center;
    vertex_position = rotateX * vertex_position;
    vertex_position = rotateY * vertex_position;
    vertex_position = rotateZ * vertex_position;
    normal = (rotateX * vec4(normal,1)).rgb;
    normal = (rotateY * vec4(normal,1)).rgb;
    normal = (rotateZ * vec4(normal,1)).rgb;
    vertex_position += center;
    


    vertex_position = cameraRotate * vertex_position;

    vpos = vertex_position;

    if (vertex_position.z < 0){
        return vec4(-10,-10,-10,0);
    }


    vertex_position.w = 1;

    float near = .1;
    float far = 1000;
    float fov = 90;
    float aspectRatio = height/width;
    float fovRad = 1 / tan(fov * .5 /180 * 3.14159);

    mat4 perspective = mat4(vec4(aspectRatio * fovRad,0,0,0),vec4(0,fovRad,0,0),vec4(0,0,far / (far-near),(-far * near) / (far - near)),vec4(0,0,1,0));

    vertex_position = perspective * vertex_position;

    if (vertex_position.w != 0) {
        vertex_position.x /= vertex_position.w;
        vertex_position.y /= vertex_position.w;
    }

    vertex_position += 10;
    vertex_position.x *= .05 * width;
    vertex_position.y *= .05 * height;

    vertex_position.z = 0;
    vertex_position.w = 1;

    return transform_projection * vertex_position;
}

#endif

#ifdef PIXEL

vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
{
    gl_FragDepth = sqrt(dot(vpos,vpos))/500;

    vec3 lightToPoint = normalize(light-origPos);

    color = Texel(textureToMap,vec2(texColor.x,1-texColor.y));
    color.a = 1;

    float diffuse = dot(lightToPoint,normal);

    float alpha = .3;
    float beta = 1-alpha;

    vec3 cool = vec3(0,.4,1) * alpha;
    vec3 warm = vec3(1,.7,0) * beta;

    vec3 gooch = (.5 + diffuse/2) * cool + (1-(.5 + diffuse/2)) * warm;

    vec3 r = reflect(-normalize(lightToPoint),normalize(normal));

    float er = clamp(dot(normalize(vpos.rgb),normalize(r)),0,1);

    float specular = clamp(pow(er,40) * -diffuse,0,1);

    //return vec4(gooch + specular,1);

    color = color * (diffuse);
    color.a = 1;
    return color;
}

#endif