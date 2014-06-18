/*
 * Naive-Bayes classifier for vowel sound recognition
 *
 * Sak Lee  Copyright 2014 All rights reserved
 */
import ddf.minim.*;
import ddf.minim.analysis.*;

final float[] aProb = {
  0.62816,
  0.77786,
  0.43834,
  0.43945,
  0.58655,
  0.59398,
  0.53492,
  0.50371,
  0.51449,
  0.45059,
  0.39562,
  0.37779,
  0.37630,
  0.37481,
  0.37890,
  0.37964,
  0.37927,
  0.37556,
  0.37333,
  0.37370,
  0.37147,
  0.37481,
  0.37147,
  0.37147,
  0.37221,
  0.37147,
  0.37147,
  0.37147,
  0.37147,
  0.37147,
  0.37147,
  0.37147,
  0.37147,
};

final float[] iProb = {
  0.88309,
  0.81574,
  0.51192,
  0.46008,
  0.40636,
  0.39463,
  0.39160,
  0.38630,
  0.38820,
  0.38668,
  0.38403,
  0.39274,
  0.40257,
  0.42603,
  0.42906,
  0.44873,
  0.47333,
  0.43133,
  0.43549,
  0.42187,
  0.41544,
  0.39992,
  0.38441,
  0.40030,
  0.39387,
  0.37836,
  0.37836,
  0.37836,
  0.37836,
  0.37836,
  0.37836,
  0.37836,
  0.37836,
};

final float[] oProb = {
  0.83536,
  0.66046,
  0.52852,
  0.69620,
  0.45323,
  0.49011,
  0.51445,
  0.44259,
  0.42662,
  0.40114,
  0.39886,
  0.38935,
  0.39240,
  0.39392,
  0.40000,
  0.39696,
  0.39696,
  0.38897,
  0.38745,
  0.38403,
  0.38707,
  0.38783,
  0.38099,
  0.38631,
  0.38251,
  0.38023,
  0.38023,
  0.38023,
  0.38023,
  0.38023,
  0.38023,
  0.38023,
  0.38023,
};

final float[] xProb = {
  0.5,
  0.5,
  0.5,
  0.5,
  0.5,
  0.5,
  0.5,
  0.5,
  0.5,
  0.5,
  0.5,
  0.5,
  0.5,
  0.5,
  0.5,
  0.5,
  0.5,
  0.5,
  0.5,
  0.5,
  0.5,
  0.5,
  0.5,
  0.5,
  0.5,
  0.5,
  0.5,
  0.5,
  0.5,
  0.5,
  0.5,
  0.5,
  0.5,
};

Minim minim;
AudioInput mic;
FFT fft;

// set to a power-of-two number: 44100 * timeSize = windowSize)
final int timeSize = 256;
final int freqBands = 3;  // number of frequencies to record
final int bandAll = timeSize * 2 + 1;
final int bandLimit = timeSize * 3 / 32 + 1;

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

void printResult()
{
  float fA = (float) pA;
  float fI = (float) pI;
  float fO = (float) pO;
  float fX = (float) pX;
  if ((mic.mix.level() < 0.01))
  {
    println("X\n");
    answerString = "X, with " + Integer.toString(0) + "% certainty";
  }
  else if (fX >= max(fA, fI, fO))
  {
    println("?\n");
    answerString = "?, with " + Integer.toString((int) (pX * 100)) + "% certainty";
  }
  else if (fA >= max(fI, fO))
  {
    println("A\n");
    answerString = "\"ah\", with " + Integer.toString((int) (pA * 100)) + "% certainty";
  }
  else if (fI >= fO)
  {
    println("I\n");
    answerString = "\"ee\", with " + Integer.toString((int) (pI * 100)) + "% certainty";
  }
  else
  {
    println("O\n");
    answerString = "\"oh\", with " + Integer.toString((int) (pO * 100)) + "% certainty";
  }
}

void delay(int wait_ms)
{
  int time = millis();
  while (millis() - time < wait_ms);
}

int counter;

void setup()
{
  size(500, 200);
  textAlign(CENTER);
  textSize(32);
  answerString = "";

  analysisArr = new double[bandAll];

  minim = new Minim(this);
  mic = minim.getLineIn(Minim.STEREO, timeSize);       

  fft = new FFT(mic.bufferSize(), mic.sampleRate());
  fft.forward(mic.mix);
}

void draw()
{
  background(0);
  text(answerString, width/2, height/2);
  adjustP();
  counter++;
  if (counter == 30)
  {
    counter = 0;
    printResult();
    resetP();
  }
  fft.forward(mic.mix);
}
