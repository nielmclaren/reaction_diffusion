/**
 * Based on example by Christopher C. Jennings, PhD.
 * @see http://cgjennings.ca/toybox/turingmorph/
 */

int w = 640;
int h = 480;

// Diffusion constants for each component.
float CA = 2.2;
float CB = 24;

// System state for each component.
float[][][] A = new float[2][w][h];
float[][][] B = new float[2][w][h];
int activeBuffer = 0;

color colorA = color(44, 70, 204);
color colorB = color(226, 242, 77);

void setup() {
  size(w, h);
  reset();
}

void draw() {
  for (int i = 0; i < 10; i++) {
    step();
  }
  
  background(0);
  
  float low = Float.MAX_VALUE;
  float high = Float.MIN_VALUE;
  
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      float v = B[activeBuffer][x][y];
      if (v < low) low = v;
      if (v > high) high = v;
    }
  }

  loadPixels();
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      pixels[y*w + x] = map(B[activeBuffer][x][y], low, high, 0, 1) > 0.5 ? 255 : 0; //lerpColor(colorA, colorB, map(B[activeBuffer][x][y], low, high, 0, 1));
    }
  }
  updatePixels();
}

void step() {
  int n, i, j, iplus1, iminus1, jplus1, jminus1;
  float DiA, ReA, DiB, ReB;
  
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
    save("out/reaction_diffusion.jpg");
  }
}


