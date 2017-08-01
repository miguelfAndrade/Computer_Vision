public class Inimigos
{
  int x, y;
  
  float vel;
  
  int diam = 30;
  
  float w, h;
  
  int tipo;
  
  PImage bomb1 = loadImage("bomb1_ini.png");
  PImage bomb2 = loadImage("bomb2_ini.png");
  PImage bomb3 = loadImage("bomb3_ini.png");
  PImage bomb4 = loadImage("bomb4_ini.png");
  
  Inimigos(int posx, int posy, float v, int t)
  {
    x = posx;
    y = posy;
    
    w = 30;
    h=40;
    
    vel = v;
    
    tipo = t;
  }
  
  void moveIni()
  {
    y += vel;
    
      imageMode(CENTER);
      if(tipo == 1)
      {
        image(bomb1, x, y, w, h);
      }
      if(tipo == 2)
      {
        image(bomb2, x, y, w, h);
      }
      if(tipo == 3)
      {
        image(bomb3, x, y, w, h);
      }
      if(tipo == 4)
      {
        image(bomb4, x, y, w, h);
      }
      
      imageMode(CORNER);
  }
}