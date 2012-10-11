float step = 3;
float minEnergy = 1.0;
float minLatitude = -42;
float maxLatitude = 54;
float maxCane = 0;
float maxMaize = 0;

PImage world;
MercatorMap mercator;

Scale x;
Scale y;

color maizeFrom = color(199, 233, 192, 153);
color maizeTo = color(0, 109, 44, 153);
color caneTo = color(8, 81, 156, 153);
color caneFrom = color(198, 219, 239, 153);

void setup() {
  size(1079, 721);
  
  world = loadImage("world.png");
  mercator = new MercatorMap(540, 361, 84, -58, -180, 180);
  
  for (float i = minLatitude; i < maxLatitude; i += step) {
    if (i <= 35) {
      maxCane = max(maxCane, cane(i) - minEnergy);
    }
    maxMaize = max(maxMaize, maize(i) - minEnergy);
  }
  
  x = new Scale();
  x.range = new PVector(550, width - 5);
  x.domain = new PVector(minLatitude, maxLatitude);
  
  y = new Scale();
  y.range = new PVector(width - 555, 0);
  y.domain = new PVector(0, 3.5);
  
  smooth();
  noLoop();
}

void draw() {
  background(255);

  pushMatrix();
  translate(0, (height - 361) / 2);
  
  image(world, 0, 0);
  
  for (float i = minLatitude; i < maxLatitude; i += step) {
    float m = maize(i) - minEnergy;
    float c = cane(i) - minEnergy;
    PVector tl = mercator.getScreenLocation(new PVector(i+step, -180));
    PVector br = mercator.getScreenLocation(new PVector(i, 180));
    float w = br.x - tl.x;
    float h = br.y - tl.y;
    
    noStroke();
    if (m > 0) {
      fill(lerpColor(maizeFrom, maizeTo, m / maxMaize));
      rect(tl.x, tl.y, br.x - tl.x, br.y - tl.y);
    }
    
    
    if (c > 0 && i <= 35) {
      fill(lerpColor(caneFrom, caneTo, c / maxCane));
      rect(tl.x, tl.y, br.x - tl.x, br.y - tl.y);
    }
  }
  
  popMatrix();
  
  noFill();
  stroke(caneTo);
  strokeWeight(2);
  beginShape();
  for (float i = minLatitude; i < 35; i += step) {
    curveVertex(x.value(i), y.value(cane(i)));
  }
  endShape();
  
  stroke(maizeTo);
  beginShape();
  for (float i = minLatitude; i < maxLatitude; i += step) {
    curveVertex(x.value(i), y.value(maize(i)));
  }
  endShape();
  
  stroke(255, 0, 0);
  line(x.value(minLatitude), y.value(1f), x.value(maxLatitude), y.value(1f));
  
  noFill();
  stroke(0xAA888888);
  strokeWeight(1);
  line(width/2, 0, width/2, height);
  line(0, height/2, width, height/2);
}

float maize(float x) {
  return 0.20317 + 0.0012365*x + 0.00041396*pow(x,2) + -7.9757E-7 * pow(x,3);
}

float cane(float x) {
  return 0.86884 + (-0.0083336)*x + 0.00091813*pow(x,2) + 1.418E-5 * pow(x,3);
}

void keyPressed() {
  switch (key) {
    case ENTER:
    case RETURN:
      saveFrame("map.tiff");
      break;
  }
}
