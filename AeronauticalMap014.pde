// #FFFFFF + #b48e3f
// 12000
// #eeb47f
// 9000
// #e4bf9b
// 7000
// #f2d58b
// 5000
// #f7e8b8
// 3000
// #fff4db
// 2000
// #cfdeae
// 1000
// #dfe7c4
// sea level
// #1d95c5 (edit needed)
// -x
// color fill based on heightrange doesn't look so nice
// if i want a map with more lines inside the same color:
// create the same map with more different heights
// color alternating black/white for edge detection
//
//Fewer elevation lines at lower heights (water=0)


int unit=1  ;// unit size in pixels. Also, one block equals one unit.
float noiseXY = 0.001;// also pseudo scale
float elevationGradient = 90.0;// gradient/slope designation/amount of elevationlines
//PVector [] vertices = new PVector[800*800];
int [][] vertices = new int[width*height][width*height];
int counter=0;
float shortest =999.0;
int shortIndex;

// Noise variables
int refX, refY; // reference coordinates for sliding noise cutoff.
float distM; // max dist between ref and any coordinate. Serves as a max noise reference
float distR;
float noiseR;

int maxDx, maxDy;
int noiseLod;
float highestV = 0.3;
float lowestV = 0.6;
int lowestX, lowestY;
int highestX, highestY;
// colors must be sorted lowest to heighest
color[] colors =
  {
  #aee9ff,
  #dfedc8,
  #cfe4b4,
  #fff7df,
  #fcebbb,
  #fbd68e,
  #e9bf9c,
  #fcb47e,
  #bc8f40,
  #FFFFFF,

};

String [] mtName ={
  "Accomplish",
  "Amazing",
  "Bliss",
  "Brave",
  "Calm",
  "Dazzling",
  "Delight",
  "Divine",
  "Earnest",
  "Fabulous",
  "Fair",
  "Glamorous",
  "Hug",
  "Harmonious",
  "Imagine",
  "Keen",
  "Light",
  "Luminous",
  "Marvelous",
  "Now",
  "Novel",
  "Okay",
  "Pleasant",
  "Progress",
  "Rejoice",
  "Robust",
  "Sunny",
  "Tranquil",
  "Upright",
  "Victory",
  "Virtuous",
  "Whole",
  "Welcome",
  "Zeal",
};

void setup() {
  //fullScreen();// if used, must be in the first line
  size (800, 800);
  background (0);
  strokeCap(PROJECT);// square points, because round points leave gaps
  strokeWeight(1);

  //noiseSeed(1900);
  //noiseDetail(5,0.5);// lower cutoff = lower height value = more water
  noiseXY = 0.005;// also pseudo scale
  noiseLod = 6;
  elevationGradient = 110.0;// gradient/slope, amount of elevationlines

  for (int i=0; i<vertices.length; i++) {
    //vertices[i] = new PVector(0, 0);
  }

  refX = int(random(0, width));
  refY = int(random(0, height));

  if (refX < width / 2) {
    maxDx = width - refX;
  } else maxDx = refX;
  if (refY < width / 2) {
    maxDy = width - refY;
  } else maxDy = refY;

  distM = sqrt(sq(maxDx) + sq(maxDy));
  print("ref x,y: " + refX + "," + refY);
  print("distM: " + distM);

  elevationGradients();// creates greyscale heightmap
  elevationVertices();// arrays vertices along borders
  colorMap();// draws colored map
  drawVertices();// draw iso lines vertices from array
  latlon();
  mapIcons(refX, refY, lowestX, lowestY, highestX, highestY);
}

void draw() {
}

// grayscale map. Detail determines iso height lines
void elevationGradients() {
  background(200);
  //noiseXY += modifier;

  for (int row=0; row <height; row+=unit) {
    for (int col=0; col <width; col+=unit) {

      float distR = dist(refX, refY, col, row);
      float noiseR = 0.8 - (distR / distM) * 0.6;
      noiseDetail(noiseLod, noiseR);

      float noiseP = noise((col*noiseXY), (row*noiseXY));//

      if (noiseP < 0.1) noiseP = 0.0;

      if (noiseP > highestV) {
        highestV = noiseP;
        highestX = col;
        highestY = row;
      }
      if (noiseP < lowestV) {
        lowestV = noiseP;
        lowestX = col;
        lowestY = row;
      }

      int roundedP= int((255.0/20.0)*round((noiseP*20.0)));// twice the amount of isolines (*20 vs *10)
      // println(roundedP);
      stroke(roundedP);
      point (col, row);
    }
  }
}

// store vertices in array
void elevationVertices() {
  counter =0;

  for (int row=0; row <height; row+=unit) {
    for (int col=0; col <width; col+=unit) {
      // color N,S,E,W
      color c = get (col, row);
      color ce = get (col+1, row);
      color cs = get (col, row+1);
      if (c != ce || c != cs ) {
        // vertices[counter].set(col, row);// only store points on edges
        vertices[col][row] = 1;// place in array for later use
        stroke(255, 0, 0);
        point(col, row);
        counter++;
      }
    }
  }

  println("dots.length: "+vertices.length);
  println("dots (counter): "+counter);
  println("Elevation Vertices completed");
}

void colorMap() {
  //noiseXY += modifier;

  for (int row=0; row <height; row+=unit) {
    for (int col=0; col <width; col+=unit) {

      float distR = dist(refX, refY, col, row);
      float noiseR = 0.8 - (distR / distM) * 0.6;
      noiseDetail(noiseLod, noiseR);

      float noiseP = noise((col*noiseXY), (row*noiseXY))*9;//

      if (noiseP < 0.1) noiseP = 0.0;

      if (noiseP > highestV) {
        highestV = noiseP;
        highestX = col;
        highestY = row;
      }
      if (noiseP < lowestV) {
        lowestV = noiseP;
        lowestX = col;
        lowestY = row;
      }

      int i= int (noiseP);
      if (i>9) i=9;
      strokeWeight(1.0);// if less than 1.0, background will be visible
      stroke(colors[i]);
      point (col, row);
    }
  }
}

void drawVertices() {
  for (int row=0; row <height; row+=unit) {
    for (int col=0; col <width; col+=unit) {
      // stroke(255, 0, 0);// debug red
      stroke(0, 30);
      if ( vertices[col][row] !=0) {
        point(col, row);
      }
      counter++;
    }
  }
}


void latlon() {
  strokeWeight(0.2);
  stroke(0);
  int longitudeD = 47;// in degrees
  int latitudeD = 122;//

  float longitudeR= (TWO_PI/360.0)*longitudeD;// deg to radians
  float mapAspect = 1.0/cos(longitudeR);

  int latSize = 200;//
  float lonSize = latSize*mapAspect;//
  float latSpacing = latSize/30.0;
  float lonSpacing = lonSize/30.0;

  fill(80);
  textSize(30);
  int offset = int(random(0, 100));

  pushMatrix();
  //translate(offset, offset);
  // lat lon lines
  for (int i=0; i<6; i++) {
    line (i*latSize, 0, i*latSize, height);// vertical lines
    line (0, i*lonSize, width, i*lonSize);// horizontal lines

    //float modT = latSpacing*10.0;
    //println(modT);
    // degrees
    // modulo: how many pixels equals 10 degrees: latSpacing*10.0
    // but it does not work due to float error?

    //println(latSpacing*10.0);
    for (float j = 0; j<width; j+=latSpacing) {
      line(j, i*lonSize, j, i*lonSize-5);
    }
    for (int j = 0; j<height; j+=lonSpacing) {
      line(i*latSize, j, i*latSize-5, j);
    }
    // degree icons
    // only display when lines are even
    if (i%2 ==0) {

      // degrees of longitude
      text(longitudeD+2-(i%3)+"°", latSize*3+5, i*lonSize+24);
      text(longitudeD+2-(i%3)+"°", latSize*1+5, i*lonSize+24);

      // degrees of latitude
      pushMatrix();
      translate(latSize*3+20, i*lonSize+90);
      rotate(PI/-2);
      text(latitudeD+2-(i%3)+"°", 0, 0);
      popMatrix();

      pushMatrix();
      translate(latSize*1+20, i*lonSize+90);
      rotate(PI/-2);
      text(latitudeD+2-(i%3)+"°", 0, 0);
      popMatrix();
    }
  }
  popMatrix();
  println("Map Aspect ratio at "+longitudeD+" degrees: "+mapAspect);
  println("latLon completed");
}

void mapIcons(int refX, int refY, int lowX, int lowY, int highestX, int highestY) {
  //Map noise reference point

  noFill();
  stroke(70);
  strokeWeight(1);

  push();
  translate(refX, refY);
  noFill();
  circle(0, 0, 24);
  line(0, -24, 0, 24);
  line(-24, 0, 24, 0);
  pop();



  //Map Lowest Elevation
  //circle(lowX, lowY, 10);
  triangle(lowX, lowY, lowX - 20, lowY - 30, lowX + 20, lowY - 30);

  // Map Highest Elevation
  //circle(highestX, highestY, 10);
  triangle(
    highestX,
    highestY,
    highestX - 20,
    highestY + 30,
    highestX + 20,
    highestY + 30
    );

  //Map Compass
  push();
  noFill();
  strokeWeight(0.5);
  translate(0.1 * width, 0.1 * height);
  textSize(24);
  //textFont("Times New Roman");
  text("N", -9, -16);
  triangle(0, 0, -10, 40, 0, 30);
  fill(30);
  triangle(0, 0, 10, 40, 0, 30);
  pop();

  int name = int(random(0, 34));
  fill(50);
  textSize(14);
  //textFont("Georgia");
  text("Mt. " + mtName[name], highestX + 20, highestY);
}

void airSpace() {
  noFill();
  strokeWeight(6);
  stroke(#003486, 80);
  int xPos = int(random(0, width));
  int yPos = int(random(0, width));
  circle(xPos, yPos, 300);
  circle(xPos, yPos, 500);
}


void keyPressed() {
  final int k = keyCode;

  if (k == 'S') saveFrame("save-###.png");
  if (k == 'H') elevationVertices();
  // else         noLoop();
}
