#version 330 core

// Atributos de fragmentos recebidos como entrada ("in") pelo Fragment Shader.
// Neste exemplo, este atributo foi gerado pelo rasterizador como a
// interpolação da posição global e a normal de cada vértice, definidas em
// "shader_vertex.glsl" e "main.cpp".
in vec4 position_world;
in vec4 normal;

// Posição do vértice atual no sistema de coordenadas local do modelo.
in vec4 position_model;

// Coordenadas de textura obtidas do arquivo OBJ (se existirem!)
in vec2 texcoords;

// Matrizes computadas no código C++ e enviadas para a GPU
uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

// Identificador que define qual objeto está sendo desenhado no momento
#define POOLTABLE 0
#define ALIEN   1
#define SPHERE  2
#define BAIANINHO 3
uniform int object_id;

// Parâmetros da axis-aligned bounding box (AABB) do modelo
uniform vec4 bbox_min;
uniform vec4 bbox_max;

// Variáveis para acesso das imagens de textura
//Texturas da mesa de sinuca
uniform sampler2D TextureImage0;
uniform sampler2D TextureImage1;
//Texturas do alien
uniform sampler2D TextureImage2;
uniform sampler2D TextureImage3;
uniform sampler2D TextureImage4;
uniform sampler2D TextureImage5;
uniform sampler2D TextureImage6;
uniform sampler2D TextureImage7;
//Textura para uma bola 8
uniform sampler2D TextureImage8;

// O valor de saída ("out") de um Fragment Shader é a cor final do fragmento.
out vec3 color;

// Constantes
#define M_PI   3.14159265358979323846
#define M_PI_2 1.57079632679489661923

void main()
{
    // Obtemos a posição da câmera utilizando a inversa da matriz que define o
    // sistema de coordenadas da câmera.
    vec4 origin = vec4(0.0, 0.0, 0.0, 1.0);
    vec4 camera_position = inverse(view) * origin;

    // O fragmento atual é coberto por um ponto que percente à superfície de um
    // dos objetos virtuais da cena. Este ponto, p, possui uma posição no
    // sistema de coordenadas global (World coordinates). Esta posição é obtida
    // através da interpolação, feita pelo rasterizador, da posição de cada
    // vértice.
    vec4 p = position_world;

    // Normal do fragmento atual, interpolada pelo rasterizador a partir das
    // normais de cada vértice.
    vec4 n = normalize(normal);

    // Vetor que define o sentido da fonte de luz em relação ao ponto atual.
    vec4 l = normalize(vec4(1.0,1.0,0.0,0.0));

    // Vetor que define o sentido da câmera em relação ao ponto atual.
    vec4 v = normalize(camera_position - p);

    // Vetor que define o sentido da reflexão especular ideal.
    vec4 r = -l+(2*n)*dot(n,l);

     // Propriedades espectrais da superfície
    vec3 Kd; // Refletância difusa
    vec3 Ks; // Refletância especular
    vec3 Ka; // Refletância ambiente
    //Expoente para o modelo de Phong
    float q;

    // Coordenadas de textura U e V
    float U = 0.0;
    float V = 0.0;

    if ( object_id == SPHERE )
    {
        // PREENCHA AQUI as coordenadas de textura da esfera, computadas com
        // projeção esférica EM COORDENADAS DO MODELO. Utilize como referência
        // o slides 134-150 do documento Aula_20_Mapeamento_de_Texturas.pdf.
        // A esfera que define a projeção deve estar centrada na posição
        // "bbox_center" definida abaixo.

        // Você deve utilizar:
        //   função 'length( )' : comprimento Euclidiano de um vetor
        //   função 'atan( , )' : arcotangente. Veja https://en.wikipedia.org/wiki/Atan2.
        //   função 'asin( )'   : seno inverso.
        //   constante M_PI
        //   variável position_model


        //Centro da bounding box (variavel c nos slides)
        vec4 bbox_center = (bbox_min + bbox_max) / 2.0;

        //Dado que p' esta calculado, aqui definimos o vetor p
        vec4 p_vector = position_model - bbox_center;

        float px = p_vector.x;
        float py = p_vector.y;
        float pz = p_vector.z;

        float theta = atan(px,pz);
        float rho = length(p_vector);
        float phi = asin(py/rho);

        U = (theta+M_PI)/(2*M_PI);
        V = (phi+M_PI_2)/M_PI;

        // Propriedades espectrais da superfície
        Kd = vec3(0.02,0.03,0.04); // Refletância difusa
        Ks = vec3(0.6,0.5,0.5); // Refletância especular
        Ka = vec3(0.3,0.2,0.2); // Refletância ambiente

        q = 10.0;    //Expoente para o modelo de Phong


    }
    else if ( object_id == ALIEN )
    {
        // PREENCHA AQUI as coordenadas de textura do coelho, computadas com
        // projeção planar XY em COORDENADAS DO MODELO. Utilize como referência
        // o slides 99-104 do documento Aula_20_Mapeamento_de_Texturas.pdf,
        // e também use as variáveis min*/max* definidas abaixo para normalizar
        // as coordenadas de textura U e V dentro do intervalo [0,1]. Para
        // tanto, veja por exemplo o mapeamento da variável 'p_v' utilizando
        // 'h' no slides 158-160 do documento Aula_20_Mapeamento_de_Texturas.pdf.
        // Veja também a Questão 4 do Questionário 4 no Moodle.

        float minx = bbox_min.x;
        float maxx = bbox_max.x;

        float miny = bbox_min.y;
        float maxy = bbox_max.y;

        float minz = bbox_min.z;
        float maxz = bbox_max.z;

        U = (position_model.x - minx)/(maxx-minx);
        V = (position_model.y - miny)/(maxy-miny);

        // Propriedades espectrais da superfície
        Kd = vec3(0.01,0.02,0.03); // Refletância difusa
        Ks = vec3(0.4,0.3,0.3); // Refletância especular
        Ka = vec3(0.2,0.1,0.1); // Refletância ambiente

        q = 20.0;    //Expoente para o modelo de Phong
    }

    else if ( object_id == POOLTABLE )
    {
        // PREENCHA AQUI as coordenadas de textura do coelho, computadas com
        // projeção planar XY em COORDENADAS DO MODELO. Utilize como referência
        // o slides 99-104 do documento Aula_20_Mapeamento_de_Texturas.pdf,
        // e também use as variáveis min*/max* definidas abaixo para normalizar
        // as coordenadas de textura U e V dentro do intervalo [0,1]. Para
        // tanto, veja por exemplo o mapeamento da variável 'p_v' utilizando
        // 'h' no slides 158-160 do documento Aula_20_Mapeamento_de_Texturas.pdf.
        // Veja também a Questão 4 do Questionário 4 no Moodle.

        float minx = bbox_min.x;
        float maxx = bbox_max.x;

        float miny = bbox_min.y;
        float maxy = bbox_max.y;

        float minz = bbox_min.z;
        float maxz = bbox_max.z;

        U = (position_model.x - minx)/(maxx-minx);
        V = (position_model.y - miny)/(maxy-miny);

        // Propriedades espectrais da superfície
        Kd = vec3(0.01,0.02,0.03); // Refletância difusa
        Ks = vec3(0.4,0.3,0.3); // Refletância especular
        Ka = vec3(0.2,0.1,0.1); // Refletância ambiente

        q = 20.0;    //Expoente para o modelo de Phong
    }

    //Aqui vamos setar as paradas do baianinho de maua

    else if ( object_id == BAIANINHO )
    {
        // PREENCHA AQUI as coordenadas de textura do coelho, computadas com
        // projeção planar XY em COORDENADAS DO MODELO. Utilize como referência
        // o slides 99-104 do documento Aula_20_Mapeamento_de_Texturas.pdf,
        // e também use as variáveis min*/max* definidas abaixo para normalizar
        // as coordenadas de textura U e V dentro do intervalo [0,1]. Para
        // tanto, veja por exemplo o mapeamento da variável 'p_v' utilizando
        // 'h' no slides 158-160 do documento Aula_20_Mapeamento_de_Texturas.pdf.
        // Veja também a Questão 4 do Questionário 4 no Moodle.

        float minx = bbox_min.x;
        float maxx = bbox_max.x;

        float miny = bbox_min.y;
        float maxy = bbox_max.y;

        float minz = bbox_min.z;
        float maxz = bbox_max.z;

        U = (position_model.x - minx)/(maxx-minx);
        V = (position_model.y - miny)/(maxy-miny);

        // Propriedades espectrais da superfície
        Ka = vec3(0.2,0.1,0.1); // Refletância ambiente
    }

    // Obtemos a refletância difusa a partir da leitura da imagem TextureImage0
    // Textura da mesa de sinuca
    vec3 Kd0 = texture(TextureImage0, vec2(U,V)).rgb;
    vec3 Kd1 = texture(TextureImage1, vec2(U,V)).rgb;
    //Texturas do alien
    vec3 Kd2 = texture(TextureImage2, vec2(U,V)).rgb;
    vec3 Kd3 = texture(TextureImage3, vec2(U,V)).rgb;
    vec3 Kd4 = texture(TextureImage4, vec2(U,V)).rgb;
    vec3 Kd5 = texture(TextureImage5, vec2(U,V)).rgb;
    vec3 Kd6 = texture(TextureImage6, vec2(U,V)).rgb;
    vec3 Kd7 = texture(TextureImage7, vec2(U,V)).rgb;
    //Textura para uma bola 8
    vec3 Kd8 = texture(TextureImage8, vec2(U,V)).rgb;

    // Espectro da fonte de iluminação
    vec3 light_spectrum = vec3(1.0,1.0,1.0);

    // Espectro da luz ambiente
    vec3 ambient_light_spectrum = vec3(0.6,0.6,0.6);

    // Equação de Iluminação de Lambert
    float lambert = max(0,dot(n,l));

    // Termo para iluminacao de Phong
    float phong_specular_term = pow(float(max(0.0f,dot(r,v))),q);

    //Condicionais pra aplicar as texturas adequadas a cada modelo bem como seu tipo de iluminacao
    //Modelo de Phong
    if( object_id == POOLTABLE)
    {
        //Solucao utilizada no lab4
        color = Kd8 * light_spectrum * lambert //Termo difuso (Lambert)
            + Ka * ambient_light_spectrum   //Fator Ambiente
            + Ks * light_spectrum * phong_specular_term;    //
    }

    //Modelo difuso sem ambiente
    else if ( object_id == ALIEN )
    {
        color = Kd2 * kd3 * light_spectrum * lambert;
    }


    else if ( object_id == SPHERE)
    {

    }



    //color = (Kd0 * (lambert + 0.01)) + (Kd1 * (1-(lambert + 0.6)+ 0.01));



    // Cor final com correção gamma, considerando monitor sRGB.
    // Veja https://en.wikipedia.org/w/index.php?title=Gamma_correction&oldid=751281772#Windows.2C_Mac.2C_sRGB_and_TV.2Fvideo_standard_gammas
    color = pow(color, vec3(1.0,1.0,1.0)/2.2);
}

