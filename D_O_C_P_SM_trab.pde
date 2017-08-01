import processing.sound.*;

import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

import processing.video.*;

Capture video; //Variavel onde é armazenada captura do video

AudioIn inputAudio; // variavel que vai recolher o som do microfone
Amplitude aAmplitude; // vai aramazenar a amlpitude do som recolhido pela a variavel acima

PImage prevFrame; //Guarda o frame anterior para poder comparar com o frame atual

float threshold = 50; //limite para o qual se deve armazenar a posição dos pixeis para saber se há movimento

PImage ecgm; //armazena uma imagem do logo do curso ecgm
PImage bomba1;
PImage bomba2;
PImage bomba3;
PImage bomba4;
PImage fundo;

int moveX = 0; //Armazena a soma das posições dos pixeis
int mediaMove = 0; // Conta quantos pixeis foram armazenados para depois fazer uma posição media
int posX; 
int mexePixels = 5; //velocidade com o player move o rectangulo
float posPlayerX; //posição do retangulo no eixo dos X
float posPlayerY; //posição do retangulo no eixo dos Y


Player player;
ArrayList<Balas> balas = new ArrayList<Balas>(); //Array que armazena as balas
ArrayList<Inimigos> inimigo = new ArrayList<Inimigos>(); //Array que armazena os inimigos
ArrayList<ecgm> coleciona = new ArrayList<ecgm>(); //Array que armazena os colecionaveis

int tiposBalas;
int tiposIni;

int time = 0; //variáveis que vão contar o tempo de criação de cada inimigom, de cada colecionável e de cada bala
int time2 = 0;
int time3 = 0;

int vidas = 10; //numero de vidas que o player tem
int score = 0; //pontuação do player

boolean gameOver = false; //indica se o jogo terminou ou não

PFont f; //aramazena uma fonte de texto

Minim minim;
Minim minim2;
Minim minim3;
Minim minim4;

AudioPlayer somFundo, somColisaoBala, somMissil, somItem;

void setup()
{
  size(640, 480);
  video = new Capture(this, 640, 480, 30);
  video.start();
  
  //--criar uma imagem vazia com as dimensões do video
  prevFrame = createImage(video.width, video.height, RGB);
  
  //--posição da bola
  posX = width/2;
  
  // -- começa a "ouvir" o microfone
  // -- cria um objeto de input de áudio e captura o primeiro canal de áudio
  inputAudio = new AudioIn(this, 0);

  // -- inicia o input de áudio
  inputAudio.start();

  // -- cria um objeto para analisar a amplitude do áudio
  aAmplitude = new Amplitude(this);

  // -- passa o input para o "analyzer" de volume
  aAmplitude.input(inputAudio);
  
  bomba1 = loadImage("bomb1.png");
  bomba2 = loadImage("bomb2.png");
  bomba3 = loadImage("bomb3.png");
  bomba4 = loadImage("bomb4.png");
  
  fundo = loadImage("fundo.png");
  
  f = loadFont("font.vlw");
  
  tiposBalas = criaTipo();
  tiposIni = criaTipo();
  carregaSons();
  somFundo.loop();
  
}

void draw()
{
  background(45, 148, 252);
  //caso o jogo não tenha acabado então executa o código que está dentro
  if(!gameOver)
  {
    
    loadPixels();//carrega os pixeis todos
    video.loadPixels();//carrega os pixeis da captura de video
    prevFrame.loadPixels();//carrega os pixeis da imagem armazenada
    
    
    moveX = 0;
    mediaMove = 0;
    
    //algoritmo responsável pela deteção de movimento da captura de vídeo
    for(int x = 0; x < video.width; x++)
    {
      for(int y = 0; y < video.height; y++)
      {
        int loc = x + y * video.width; //indice de cada pixel
        
        //--inverter a imagem na horizontal
        int loc2 = (video.width - x - 1) + y * video.width;
        
        pixels[loc2] = video.pixels[loc];
        
        color current = video.pixels[loc];//vai buscar o pixel da captura de video que está na posição loc
        color previous = prevFrame.pixels[loc];//vai buscar o pixel da imagem armazenada que está na posição loc
        
        //armazena a cor de cada pixel, tanto na imagem armazenada como na frame atual
        float r1 = red(current);
        float g1 = green(current);
        float b1 = blue(current);
        
        float r2 = red(previous);
        float g2 = green(previous);
        float b2 = blue(previous);
        
        float diff = dist(r1, g1, b1, r2, g2, b2);//faz a diferença de cor entre um pixel e outro
        
        if(diff > threshold)//caso a diferença seja maior que o threshold armazena a posição do pixel
        {
          moveX += x;
          mediaMove++;
        }
      }
    }
    
    updatePixels();//recarrega todos os pixeis da imagem
    if(mediaMove != 0)//faz a posição média dos pixeis guardados
    {
      moveX = moveX / mediaMove;
    }
     
    if(moveX > posX + mexePixels / 2)
    {
      posX += mexePixels;
    }
    else if(moveX < posX - mexePixels / 2)
    {
      posX -= mexePixels;
    }
    
    posPlayerX = width - posX;
    posPlayerY = height - 50;
    player = new Player(posPlayerX, posPlayerY, 40, 50);
    
    //background(143, 202, 239);
    image(fundo, 150, 0, width - 150, height);
    
    
    tiposIni = criaTipo();
    
    iniciaIni();
    
    iniciaEcgm();
    
    //move todas as balas
    for(int i=0; i<balas.size();i++)
    {
      Balas b = balas.get(i);
      b.moveBala();
    }
    
    
    float volume = aAmplitude.analyze();//regista a amplitude do som captado
    float limite = 0.1;
    
    //caso a amplitude seja maior que um limite cria uma bala
    if(volume > limite && millis() > time + 500)
    {
      Balas bal = new Balas(int(posPlayerX), int(posPlayerY), 8, tiposBalas);
      balas.add(bal);
      tiposBalas = criaTipo();
      somMissil.play(0);
      time = millis();
    }
    
    //move os inimigos
    for(int j=0; j<inimigo.size(); j++)
    {
      Inimigos i = inimigo.get(j);
      i.moveIni();
      if(balas.size() > 0)
      {
        //caso uma bala colida com um inimigo, o inimigo e a bala são eliminados
        for(int k = 0; k < balas.size(); k++)
        {
          Balas b = balas.get(k);
          if(rectRect(b.posBalaX, b.posBalaY, b.rectW, b.rectH, i.x, i.y, int(i.w), int(i.h)) && i.tipo == b.tipo)
          {
            inimigo.remove(j);
            balas.remove(k);
            somColisaoBala.play(0);
            break;
          }
        }
      }
    }
    
    //move os itens colecionáveis
    for(int a = 0; a < coleciona.size(); a++)
    {
      ecgm e = coleciona.get(a);
      e.moveEcgm();
    }
    
    //retira uma vida quando um inimigo chega ao fundo da janela
    for(int i = 0; i < inimigo.size(); i++)
    {
      Inimigos ini = inimigo.get(i);
      
      if(ini.y > height)
      {
        vidas = vidas - 1;
        inimigo.remove(ini);
        somColisaoBala.play(0);
      }
    }
    
    //aumenta a pontuação quando os itens colecionáveis chegam ao fundo da janela
    for(int a = 0; a < coleciona.size(); a++)
    {
      ecgm e = coleciona.get(a);
      if(rectRect(int(player.x), int(player.y), player.w, player.h, int(e.x), int(e.y), e.w, e.w))
      {
        score++;
        coleciona.remove(e);
        somItem.play(0);
      }
    }
    
    
    if(vidas == 0)
    {
      gameOver = true;
    }
    
    player.imprime();
    
    fill(98,99,99);
    rect(0, 0, 150, height);
    
    desenhaTexto();
    
    if(tiposBalas == 1)
    {
      image(bomba1, 50, 200, 50, 100);
    }
    else if(tiposBalas == 2)
    {
      image(bomba2, 50, 200, 50, 100);
    }
    else if(tiposBalas == 3)
    {
      image(bomba3, 50, 200, 50, 100);
    }
    else if(tiposBalas == 4)
    {
      image(bomba4, 50, 200, 50, 100);
    }
    //Inverte a captura de ecrã no eixo dos x
    pushMatrix(); 
    scale(-1,1); 
    image(video.get(), -150, 0, 150, 100);
    popMatrix(); 

    
  }
  else //Quando acaba o jogo imprime para o ecrã estes textos
  {
    textAlign(CENTER);
    fill(145, 0, 0);
    text("GAME OVER", width/2, height/2);
    fill(0, 0, 0);
    text("Pontuação: ", width/2 - 10, (height/2) + 30);
    fill(255, 0, 0);
    text(score, width/2 + 50, (height/2) + 30);
    fill(0, 0, 0);
    text("Pressione qualquer tecla para jogar novamente", width/2, height/2 + 60);
  }
  
}

int criaTipo()
{
  int t;
  t = int(random(1,5));
  return t;
}

//Evento que é iniciado sempre que uma nova frame entra
void captureEvent(Capture video)
{
  //--gravar a frame anterior para depois detetar o movimento
  //--antes de ler o novo frame, gravamos o anterior
  //--para podermos comparar
  prevFrame.copy(video, 0, 0, video.width, video.height, 0, 0, video.width, video.height);
  prevFrame.updatePixels();
  
  //--ler a nova frame da câmara
  video.read();
}

//desenha todo o texto no ecrã que se refere às vidas e pontuação
void desenhaTexto()
{
  textFont(f, 16);
  fill(42, 45, 45);
  text("Vidas: ", width - 70, 20);
  text(vidas, width - 20, 20);
  text("Pontuação: ", width - 110, 40);
  text(score, width - 20, 40);
  fill(102, 102, 102);
  text("Miguel Andrade  nº15973", width - 180, height - 10);
  fill(0);
  text("ECGM", 10, height - 10);
  text("Bala: ", 10, height - 200);
}


//--remove as balas que saem do ecrã
void removeMe(Balas b)
{
  balas.remove(b);
  b = null;
}

//cria os inimigos de 0.5 em 0.5 segundos numa localização aleatória no eixo dos X
void iniciaIni()
{
  if(millis() > time + 1500)
  {
    Inimigos i = new Inimigos(int(random(180, 610)), 0, 2, tiposIni);
    inimigo.add(i);
    time = millis();
  }
}

//cria os colecionáveis de 1 em 1 segundo numa localização aleatória no eixo dos X
void iniciaEcgm()
{
  if(millis() > time2 + 2500)
  {
    ecgm e = new ecgm(random(180, 610), 0, 4);
    coleciona.add(e);
    time2 = millis();
  }
}

void keyPressed()
{
  //Quando o jogador perder, ao carrgar num tecla qualquer, reinicia o jogo
  if(gameOver)
  {
    textAlign(LEFT);
    vidas = 10;
    score = 0;
    eliminaTudo();
    gameOver = false;
  }
}

//Elimina todos os inimigos e todos os colecionáveis do jogo
void eliminaTudo()
{
  for(int i = 0; i < inimigo.size(); i++)
  {
    Inimigos ini = inimigo.get(i);
    inimigo.remove(ini);
  }
  for(int j = 0; j < coleciona.size(); j++)
  {
    ecgm e = coleciona.get(j);
    coleciona.remove(e);
  }
}


// Carrega os sons usados no jogo
void carregaSons()
{
  minim = new Minim(this);
  somFundo = minim.loadFile("musicBattle.mp3");
  
  minim2 = new Minim(this);
  somColisaoBala = minim.loadFile("Explosion.wav");
  
  minim3 = new Minim(this);
  somMissil = minim.loadFile("Missile.wav");
  
  minim4 = new Minim(this);
  somItem = minim.loadFile("item.wav");
}


//Função que retorna verdadeiro se ouver colisão entre um retangulo e um circulo

boolean rectRect(int x1, int y1, int w1, int h1, int x2, int y2, int w2, int h2) {
  
  // test for collision
  if (x1+w1/2 >= x2-w2/2 && x1-w1/2 <= x2+w2/2 && y1+h1/2 >= y2-h2/2 && y1-h1/2 <= y2+h2/2) {
    return true;    // if a hit, return true
  }
  else {            // if not, return false
    return false;
  }
}