

PeasyCam cam;

void peasy_setup()
{
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(1000);
}
