/*
 * Naive-Bayes classifier for vowel sound recognition
 *
 * Sak Lee  mail@saklee.net
 * Copyright 2014 All rights reserved
 *
 *
 * TODO: two ArrayList implementation to fight GC stop-the-world
 */
import ddf.minim.*;
import ddf.minim.analysis.*;
import fisica.*;

final float[] aProb = {
  0.62816, 0.77786, 0.43834, 0.43945, 0.58655,
  0.59398, 0.53492, 0.50371, 0.51449, 0.45059,
  0.39562, 0.37779, 0.37630, 0.37481, 0.37890,
  0.37964, 0.37927, 0.37556, 0.37333, 0.37370,
  0.37147, 0.37481, 0.37147, 0.37147, 0.37221,
  0.37147, 0.37147, 0.37147, 0.37147, 0.37147,
};

final float[] iProb = {
  0.88309, 0.81574, 0.51192, 0.46008, 0.40636,
  0.39463, 0.39160, 0.38630, 0.38820, 0.38668,
  0.38403, 0.39274, 0.40257, 0.42603, 0.42906,
  0.44873, 0.47333, 0.43133, 0.43549, 0.42187,
  0.41544, 0.39992, 0.38441, 0.40030, 0.39387,
  0.37836, 0.37836, 0.37836, 0.37836, 0.37836,
};

final float[] oProb = {
  0.83536, 0.66046, 0.52852, 0.69620, 0.45323,
  0.49011, 0.51445, 0.44259, 0.42662, 0.40114,
  0.39886, 0.38935, 0.39240, 0.39392, 0.40000,
  0.39696, 0.39696, 0.38897, 0.38745, 0.38403,
  0.38707, 0.38783, 0.38099, 0.38631, 0.38251,
  0.38023, 0.38023, 0.38023, 0.38023, 0.38023,
};

final float[] xProb = {
  0.5, 0.5, 0.5, 0.5, 0.5,
  0.5, 0.5, 0.5, 0.5, 0.5,
  0.5, 0.5, 0.5, 0.5, 0.5,
  0.5, 0.5, 0.5, 0.5, 0.5,
  0.5, 0.5, 0.5, 0.5, 0.5,
  0.5, 0.5, 0.5, 0.5, 0.5,
};

Minim minim;
AudioInput mic;
FFT fft;

// set to a power-of-two number: 44100 * timeSize = windowSize)
final int timeSize = 256;
final int freqBands = 3;  // number of frequencies to record
final int bandAll = timeSize * 2 + 1;
final int bandLimit = 30;

double[] analysisArr;  // array to receive FFT result

double pA, pI, pO, pX;  // probability

String answerString;  // to print out to the screen

int[] findFourMax()  // find four indices with largest number in the array
{
  int arrSize = bandLimit;  // entire analysis array size
  int curSize = arrSize;  // number of indices we're interested in
  int[] answer = new int[freqBands];
  int[] allIndices = new int[arrSize];  // to handle random indices
  for (int i = 0; i < arrSize; i++)
  {
    allIndices[i] = i;
  }
  int n = 0;  // answer index
  int temp;

  for (int j = 0; j < freqBands; j++)
  {
    // then go through indices
    int maxIndex = 0;
    double maxnum = analysisArr[allIndices[0]];
    for (int i = 0; i < curSize - 1; i++)
    {
      if (analysisArr[allIndices[i]] > maxnum && analysisArr[allIndices[i]] > analysisArr[allIndices[i]-1] && analysisArr[allIndices[i]] > analysisArr[allIndices[i]+1])
      {
        maxnum = analysisArr[allIndices[i]];
        maxIndex = i;
      }
    }
    //println(allIndices[maxIndex]);
    //println(analysisArr[allIndices[maxIndex]]);
    if (maxnum == 0)
    {
      while (n < freqBands)
      {
        answer[n++] = -1;
      }
      break;
    }
    else
    {
    answer[n++] = allIndices[maxIndex];
    }
    // then eliminate the index from the answer
    temp = allIndices[curSize - 1];
    allIndices[curSize - 1] = allIndices[maxIndex];
    allIndices[maxIndex] = temp;
    curSize--;
  }
  for (int i = 0; i < bandAll; i++)
  {
    analysisArr[i] = 0;
  }
  return answer;
}

double probA(int[] answer)
{
  double aa = 1;
  for (int i = 0; i < bandLimit; i++)
  {
    boolean temp = false;
    for (int j = 0; j < freqBands; j++)
    {
      temp = temp || (i == answer[j]);
    }
    if (temp)
    {
      aa *= aProb[i];
    }
    else
    {
      aa *= 1 - aProb[i];
    }
  }
  return aa;
}

double probI(int[] answer)
{
  double ii = 1;
  for (int i = 0; i < bandLimit; i++)
  {
    boolean temp = false;
    for (int j = 0; j < freqBands; j++)
    {
      temp = temp || (i == answer[j]);
    }
    if (temp)
    {
      ii *= iProb[i];
    }
    else
    {
      ii *= 1 - iProb[i];
    }
  }
  return ii;
}

double probO(int[] answer)
{
  double oo = 1;
  for (int i = 0; i < bandLimit; i++)
  {
    boolean temp = false;
    for (int j = 0; j < freqBands; j++)
    {
      temp = temp || (i == answer[j]);
    }
    if (temp)
    {
      oo *= oProb[i];
    }
    else
    {
      oo *= 1 - oProb[i];
    }
  }
  return oo;
}

double probX(int[] answer)
{
  double xx = 1;
  for (int i = 0; i < bandLimit; i++)
  {
    boolean temp = false;
    for (int j = 0; j < freqBands; j++)
    {
      temp = temp || (i == answer[j]);
    }
    if (temp)
    {
      xx *= xProb[i];
    }
    else
    {
      xx *= 1 - xProb[i];
    }
  }
  return xx;
}

void adjustP()
{
  for (int i = 0; i < fft.specSize(); i++)
  {
    analysisArr[i] += fft.getBand(i);
  }
  // analyze first
  int[] answer = findFourMax();
  pA *= probA(answer);
  pI *= probI(answer);
  pO *= probO(answer);
  pX *= probX(answer);
  double sum = pA + pI + pO + pX;
  pA = pA / sum;
  pI = pI / sum;
  pO = pO / sum;
  pX = pX / sum;
}

void resetP()
{
  pA = 1;
  pI = 1;
  pO = 1;
  pX = 1;
}

void shootBars()
{
  if (mic.mix.level() > 0.009)
  {
    for (int i = 0; i < fft.specSize(); i++)
    {
      analysisArr[i] += fft.getBand(i);
    }
    for (int i = 0; i < bandLimit; i++)
    {
      float barHeight = height / 2 * (float) analysisArr[i] * mic.mix.level() + 10;
      freqBars[i].setHeight(barHeight);
      freqBars[i].setPosition(dist / 2 + i * dist, height - 20 - barHeight / 2);
    }
    for (int i = 0; i < bandAll; i++)
    {
      analysisArr[i] = 0;
    }
  }
}

void shootBall()
{
  float fA = (float) pA;
  float fI = (float) pI;
  float fO = (float) pO;
  float fX = (float) pX;
  if (volAvg < 0.009)
  {
    /* nuthin' */
  }
  else
  {
    FSoundBall temp = ballPool.remove(0);
    if (fX >= max(fA, fI, fO))
    {
      float dice = random(100);
      if (dice < 25)
      {
      temp.reset(volAvg * 1000, "?", 0, 255);
      }
      else if (dice < 50)
      {
      temp.reset(volAvg * 1000, "?", 0, 255);
      }
      else if (dice < 75)
      {
      temp.reset(volAvg * 1000, "?", 0, 255);
      }
      else
      {
      temp.reset(volAvg * 1000, "?", 0, 255);
      }
    }
    else if (fA >= max(fI, fO))
    {
      float dice = random(100);
      if (dice < 25)
      {
      temp.reset(volAvg * 1000, "哈", 0, 255);
      }
      else if (dice < 50)
      {
      temp.reset(volAvg * 1000, "啊", 0, 255);
      }
      else if (dice < 75)
      {
      temp.reset(volAvg * 1000, "呵", 0, 255);
      }
      else
      {
      temp.reset(volAvg * 1000, "ah", 0, 255);
      }
    }
    else if (fI >= fO)
    {
      float dice = random(100);
      if (dice < 25)
      {
      temp.reset(volAvg * 1000, "咿", 0, 255);
      }
      else if (dice < 50)
      {
      temp.reset(volAvg * 1000, "噫", 0, 255);
      }
      else if (dice < 75)
      {
      temp.reset(volAvg * 1000, "咦", 0, 255);
      }
      else
      {
      temp.reset(volAvg * 1000, "ee", 0, 255);
      }
    }
    else
    {
      float dice = random(100);
      if (dice < 25)
      {
      temp.reset(volAvg * 1000, "喔", 0, 255);
      }
      else if (dice < 50)
      {
      temp.reset(volAvg * 1000, "噢", 0, 255);
      }
      else if (dice < 75)
      {
      temp.reset(volAvg * 1000, "哦", 0, 255);
      }
      else
      {
      temp.reset(volAvg * 1000, "oh", 0, 255);
      }
    }
    temp.setPosition(width/2, height/4);
    temp.setRotation(random(2 * PI));
    world.add(temp);
    balls.add(temp);
  }
}

void delay(int wait_ms)
{
  int time = millis();
  while (millis() - time < wait_ms);
}

public class FSoundBall extends FCircle
{
  protected String tag;
  protected int maxLife, life, bodyColor, textColor;
  protected boolean atBottom;

  /**
   * Constructs a circular body that can be added to a world.
   *
   * @param size  the size of the circle
   */
  public FSoundBall(float size, String text, int bc, int tc)
  {
    super(size);
    tag = text;
    maxLife = 600 - (int) size;
    life = maxLife;
    bodyColor = bc;
    textColor = tc;
  }

  public void reset(float size, String text, int bc, int tc)
  {
    m_size = Fisica.screenToWorld(size);
    tag = text;
    maxLife = 600 - (int) size;
    life = maxLife;
    bodyColor = bc;
    textColor = tc;
  }

  public void draw(PGraphics applet)
  {
    preDraw(applet);

    if (m_image != null ) {
      drawImage(applet);
    } else {
      applet.fill(bodyColor * life / maxLife, 0);
      applet.noStroke();
      applet.ellipse(0, 0, getSize(), getSize());
      applet.textSize(getSize() * 2 / 3);
      applet.fill(textColor);
      applet.text(tag, 0, -0.08 * getSize());
    }
    life--;

    postDraw(applet);
  }
  
  public void drawDebug(PGraphics applet)
  {
    preDrawDebug(applet);
        
    applet.fill(bodyColor * life / maxLife, 0);
    applet.ellipse(0, 0, getSize(), getSize());
    applet.line(0, 0, getSize()/2, 0);
    applet.textSize(getSize() * 2 / 3);
    applet.fill(textColor);
    applet.text(tag, 0, -0.08 * getSize());

    postDrawDebug(applet);
  }

  public boolean isDead()
  {
    return life < 0;
  }

  public void fellThrough()
  {
    atBottom = true;
  }

  public boolean isAtBottom()
  {
    if (atBottom)
    {
      atBottom = false;
      return true;
    }
    return false;
  }
}

FWorld world;
ArrayList<FSoundBall> balls, ballPool;
FBox[] freqBars;
boolean[] freqBarsReset;
int counter;
float dist, volAvg;
PFont myFont;

void setup()
{
  size(1000, 700);
  Fisica.init(this);
  world = new FWorld();
  world.setEdges();
  world.setGrabbable(false);
  
  ellipseMode(CENTER);
  textAlign(CENTER, CENTER);
  imageMode(CENTER);
  myFont = createFont("WenQuanYi Micro Hei", 32);
  textFont(myFont);

  analysisArr = new double[bandAll];

  minim = new Minim(this);
  mic = minim.getLineIn(Minim.STEREO, timeSize);       

  fft = new FFT(mic.bufferSize(), mic.sampleRate());
  fft.forward(mic.mix);

  balls = new ArrayList<FSoundBall>();
  ballPool = new ArrayList<FSoundBall>();
  balls.ensureCapacity(40);
  ballPool.ensureCapacity(120);
  for (int i = 0; i < 100; i++)
  {
    ballPool.add(new FSoundBall(1000, "meh", 0, 0));
  }
  freqBars = new FBox[bandLimit];
  freqBarsReset = new boolean[bandLimit];

  dist = width / bandLimit;
  for (int i = 0; i < bandLimit; i++)
  {
    freqBars[i] = new FBox(dist * 0.5, 10);
    freqBars[i].setRotatable(false);
    freqBars[i].setStatic(true);
    freqBars[i].setPosition(dist / 2 + i * dist, height - 20);
    world.add(freqBars[i]);
  }
}

void draw()
{
  background(0);
  stroke(255);

  for (int i = 0; i < bandLimit; i++)
  {
    if ((freqBarsReset[i] || freqBars[i].getY() < height / 2) && freqBars[i].getContacts().isEmpty())
    {
    freqBars[i].setPosition(dist + i * dist, height - 20);
    freqBars[i].setVelocity(0, 0);
    freqBarsReset[i] = false;
    }
  }

  for (FSoundBall ball : balls)
  {
    if (ball.isAtBottom() && ball.getContacts().isEmpty())
    {
    ball.setPosition(ball.getX(), height - 50);
    ball.setVelocity(0, 0);
    }
  }

  for (int i = 0; i < bandLimit - 1; i++)
  {
    line(freqBars[i].getX(), freqBars[i].getY(), freqBars[i+1].getX(), freqBars[i+1].getY());
  }

  volAvg += mic.mix.level();
  adjustP();
  shootBars();
  counter++;
  if (counter == 10)
  {
    volAvg /= 10;
    counter = 0;
    shootBall();
    resetP();
  }
  fft.forward(mic.mix);

  world.step();
  world.draw();

  ArrayList<FSoundBall> temp = (ArrayList<FSoundBall>) balls.clone();

  for (FSoundBall ball : temp)
  {
    if (ball.isDead())
    {
      world.remove(ball);
      ballPool.add(ball);
      balls.remove(ball);
    }
  }

  temp = null;
}

void contactStarted(FContact contact)
{
  for (int i = 0; i < bandLimit; i++)
  {
    ArrayList<FBody> tempBodies = (ArrayList<FBody>) freqBars[i].getTouching();
    for (FBody ball : tempBodies)
    {
      ball.addImpulse(0, -1 * freqBars[i].getHeight());
    }
  }/*
  for (FSoundBall ball : balls)
  {
    if (contact.contains(ball) && contact.contains(world.bottom))
    {
      ball.addImpulse(0, -1200);
    }
    else
    {
      for (int i = 0; i < bandLimit; i++)
      {
        if (contact.contains(ball) && bodycontact.contains(freqBars[i]))
        {
          ball.addImpulse(0, -1 * freqBars[i].getHeight());
        }
      }
    }
  }*/
}

void contactPersisted(FContact contact)
{
  for (int i = 0; i < bandLimit; i++)
  {
    ArrayList<FBody> tempBodies = (ArrayList<FBody>) freqBars[i].getTouching();
    for (FBody ball : tempBodies)
    {
      ball.addImpulse(0, -1 * freqBars[i].getHeight());
    }
  }
}

void contactEnded(FContact contact)
{
  for (FSoundBall ball : balls)
  {
    if (contact.contains(ball) && contact.contains(world.bottom))
    {
      ball.fellThrough();
    }
  }
}
