/**
 * Based on example by Christopher C. Jennings, PhD.
 * @see http://cgjennings.ca/toybox/turingmorph/
 */

int w = 320;
int h = 240;

// Diffusion constants for each component.
double CA;
double CB;

double[] CAs;
double[] CBs;

int iterations = 5000;

// System state for each component.
double[][][] A = new double[2][w][h];
double[][][] B = new double[2][w][h];
int activeBuffer = 0;

color colorA = color(44, 70, 204);
color colorB = color(226, 242, 77);

void setup() {
  size(w, h);
  
  double lowCA = 1;
  double highCA = 1.05;
  double lowCB = 24.05;
  double highCB = 24.15;
  CAs = new double[10];
  CBs = new double[10];
  for (int i = 0; i < 10; i++) {
    CAs[i] = lowCA + (i / 10.0) * (highCA - lowCA);
  }
  for (int i = 0; i < 10; i++) {
    CBs[i] = lowCB + (i / 10.0) * (highCB - lowCB);
  }
  
  for (int i = 0; i < CAs.length; i++) {
    CA = CAs[i];
    for (int j = 0; j < CBs.length; j++) {
      CB = CBs[j];
      reset();
      for (int n = 0; n < iterations; n++) {
        step();
      }
      
      double low = Double.MAX_VALUE;
      double high = Double.MIN_VALUE;
      
      for (int y = 0; y < h; y++) {
        for (int x = 0; x < w; x++) {
          double v = B[activeBuffer][x][y];
          if (v < low) low = v;
          if (v > high) high = v;
        }
      }
    
      background(0);
      loadPixels();
      for (int y = 0; y < h; y++) {
        for (int x = 0; x < w; x++) {
          pixels[y*w + x] = lerpColor(colorA, colorB, (float)((B[activeBuffer][x][y] - low) / (high - low)));
        }
      }
      updatePixels();
      
      textSize(22);
      text("CA: " + CA, 10, 25);
      text("CB: " + CB, 10, 50);
      
      save("out/sample" + i + "x" + j + ".jpg");
    }
  }    
      
  reset();
}

void draw() {
}

void step() {
  int n, i, j, iplus1, iminus1, jplus1, jminus1;
  double DiA, ReA, DiB, ReB;
  
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


