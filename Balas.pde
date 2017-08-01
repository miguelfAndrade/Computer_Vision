public class Balas
{
  int posBalaX, posBalaY;

  float veloBalaY;
  
  int rectW, rectH;
  
  int tipo;
  
  PImage bomb1 = loadImage("bomb1.png");
  PImage bomb2 = loadImage("bomb2.png");
  PImage bomb3 = loadImage("bomb3.png");
  PImage bomb4 = loadImage("bomb4.png");
  
  Balas(int x, int y, float vel, int t)
  {
    posBalaX = x;
    posBalaY = y;
    
    rectW = 10;
    rectH = 20;
    
    veloBalaY = vel;
    
    tipo = t;
  }
  
  void moveBala()
  {
    posBalaY -= veloBalaY;
    
    imageMode(CENTER);
    if(tipo == 1)
      {
        image(bomb1, posBalaX, posBalaY, rectW, rectH);
      }
      if(tipo == 2)
      {
        image(bomb2, posBalaX, posBalaY, rectW, rectH);
      }
      if(tipo == 3)
      {
        image(bomb3, posBalaX, posBalaY, rectW, rectH);
      }
      if(tipo == 4)
      {
        image(bomb4, posBalaX, posBalaY, rectW, rectH);
      }
    
    imageMode(CORNER);
    
    if(posBalaY < 0)
    {
      removeMe(this);
    }
  }

}