public class ecgm
{
  float x, y;
  
  float vel;
  
  int diam = 30;
  
  int w;
  
  PImage col = loadImage("ecgm.png");
  
  ecgm(float posx, float posy, float v)
  {
    x = posx;
    y = posy;
    
    w = 30;
    vel = v;
  }
  
  void moveEcgm()
  {
    y += vel;
    
    imageMode(CENTER);
    image(col, x, y, w, w);
    imageMode(CORNER);
  }
}