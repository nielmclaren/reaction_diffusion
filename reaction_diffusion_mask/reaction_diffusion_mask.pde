/**
 * Based on example by Christopher C. Jennings, PhD.
 * @see http://cgjennings.ca/toybox/turingmorph/
 */

int w = 640;
int h = 480;

// Diffusion constants for each component.
double lowCA = 2.25;
double highCA = 3.4;
double lowCB = 12;
double highCB = 24;

// Diffusion masks for each component.
double[][] maskA = new double[w][h];
double[][] maskB = new double[w][h];

// System state for each component.
double[][][] A = new double[2][w][h];
double[][][] B = new double[2][w][h];
int activeBuffer = 0;

// TODO: Allow more interesting topographical transformations. Maybe have
// a gradient fill bar, like in image editing software.
color colorA = color(44, 70, 204);
color colorB = color(226, 242, 77);


void setup() {
  size(w, h);
  
  PImage img;
  
  img = loadImage("maska.jpg");
  img.resize(w, h);
  img.filter(GRAY);
  img.loadPixels();
  for (int x = 0; x < w; x++) {
    for (int y = 0; y < h; y++) {
      maskA[x][y] = lowCA + red(img.pixels[y * w + x]) / 255 * (highCA - lowCA);
    }
  }
  
  img = loadImage("maskb.jpg");
  img.resize(w, h);
  img.filter(GRAY);
  img.loadPixels();
  for (int x = 0; x < w; x++) {
    for (int y = 0; y < h; y++) {
      maskB[x][y] = lowCB + red(img.pixels[y * w + x]) / 255 * (highCB - lowCB);
    }
  }
  
  reset();
}

void draw() {
  for (int i = 0; i < 10; i++) {
    step();
  }
  
  background(0);
  
  double low = Double.MAX_VALUE;
  double high = Double.MIN_VALUE;
  
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      double v = B[activeBuffer][x][y];
      if (v < low) low = v;
      if (v > high) high = v;
    }
  }

  loadPixels();
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      pixels[y*w + x] = lerpColor(colorA, colorB, (float)((B[activeBuffer][x][y] - low) / (high - low)));
    }
  }
  updatePixels();
}

void step() {
  int n, i, j, iplus1, iminus1, jplus1, jminus1;
  double CA, CB, DiA, ReA, DiB, ReB;
  
  activeBuffer = 1 - activeBuffer;

  // uses Euler's method to solve the diff eqns
  for (i = 0; i < w; i++) {
    // treat the surface as a torus by wrapping at the edges
    iplus1 = i+1;
    iminus1 = i-1;
    if (i == 0) iminus1 = w - 1;
    if (i == w - 1) iplus1 = 0;

    for (j = 0; j < h; j++) {
      jplus1 = j+1;
      jminus1 = j-1;
      if (j == 0) jminus1 = h - 1;
      if (j == h - 1) jplus1 = 0;
      
      CA = maskA[i][j];
      CB = maskB[i][j];

      // Component A
      DiA = CA * (A[1 - activeBuffer][iplus1][j] - 2.0 * A[1 - activeBuffer][i][j] + A[1 - activeBuffer][iminus1][j]
           + A[1 - activeBuffer][i][jplus1] - 2.0 * A[1 - activeBuffer][i][j] + A[1 - activeBuffer][i][jminus1]);
      ReA = A[1 - activeBuffer][i][j] * B[1 - activeBuffer][i][j] - A[1 - activeBuffer][i][j] - 12.0;
      A[activeBuffer][i][j] = A[1 - activeBuffer][i][j] + 0.01 * (ReA + DiA);
      if (A[activeBuffer][i][j] < 0.0) A[activeBuffer][i][j] = 0.0;

      // Component B
      DiB = CB * (B[1 - activeBuffer][iplus1][j] - 2.0 * B[1 - activeBuffer][i][j] + B[1 - activeBuffer][iminus1][j]
           + B[1 - activeBuffer][i][jplus1] - 2.0 * B[1 - activeBuffer][i][j] + B[1 - activeBuffer][i][jminus1]);
      ReB = 16.0 - A[1 - activeBuffer][i][j] * B[1 - activeBuffer][i][j];
      B[activeBuffer][i][j] = B[1 - activeBuffer][i][j] + 0.01 * (ReB + DiB);
      if (B[activeBuffer][i][j] < 0.0) B[activeBuffer][i][j]=0.0;
    }
  }
}

void reset() {
  for (int x = 0; x < w; x++) {
    for (int y = 0; y < h; y++) {
      A[activeBuffer][x][y] = random(1) * 12.0 + randomGaussian() * 2.0;
      B[activeBuffer][x][y] = random(1) * 12.0 + randomGaussian() * 2.0;
    }
  }
}

void keyPressed() {
  if (key == ' ') {
    reset();
    
    // Do a bunch of iterations right off the bat.
    for (int i = 0; i < 500; i++) {
      step();
    }
  }
  else if (key == 's') {
    save("reaction_diffusion.jpg");
  }
}


