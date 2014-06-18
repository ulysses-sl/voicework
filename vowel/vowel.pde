/*
 * Naive-Bayes classifier for vowel sound recognition
 *
 * Sak Lee  Copyright 2014 All rights reserved
 */

import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;

final String[] sampleName = {
  "samples/a01.wav",
  "samples/a02.wav",
  "samples/a03.wav",
  "samples/a04.wav",
  "samples/a05.wav",
  "samples/a06.wav",
  "samples/a07.wav",
  "samples/a08.wav",
  "samples/a09.wav",
  "samples/a10.wav",
  "samples/a11.wav",
  "samples/a12.wav",
  "samples/a13.wav",
  "samples/a14.wav",
  "samples/a15.wav",
  "samples/a16.wav",
  "samples/a17.wav",
  "samples/a19.wav",
  "samples/a20.wav",
  "samples/a21.wav",
  "samples/a22.wav",
  "samples/a23.wav",
  "samples/a24.wav",
  "samples/a25.wav",
  "samples/a26.wav",
  "samples/a27.wav",
  "samples/a28.wav",
  "samples/a29.wav",
  "samples/a30.wav",
  "samples/a31.wav",
  "samples/a32.wav",
  "samples/a34.wav",
  "samples/a35.wav",
  "samples/a36.wav",
  "samples/a37.wav",
  "samples/a38.wav",
  "samples/a39.wav",
  "samples/a40.wav",
  "samples/a41.wav",
  "samples/a42.wav",
  "samples/a43.wav",
  "samples/a44.wav",
  "samples/a45.wav",
  "samples/a46.wav",
  "samples/a47.wav",
  "samples/a48.wav",
  "samples/a49.wav",
  "samples/a51.wav",
  "samples/a52.wav",
  "samples/a53.wav",
  "samples/i01.wav",
  "samples/i02.wav",
  "samples/i03.wav",
  "samples/i04.wav",
  "samples/i05.wav",
  "samples/i06.wav",
  "samples/i07.wav",
  "samples/i08.wav",
  "samples/i09.wav",
  "samples/i10.wav",
  "samples/i11.wav",
  "samples/i12.wav",
  "samples/i13.wav",
  "samples/i14.wav",
  "samples/i15.wav",
  "samples/i16.wav",
  "samples/i17.wav",
  "samples/i18.wav",
  "samples/i19.wav",
  "samples/i20.wav",
  "samples/i21.wav",
  "samples/i22.wav",
  "samples/i23.wav",
  "samples/i24.wav",
  "samples/i25.wav",
  "samples/i28.wav",
  "samples/i29.wav",
  "samples/i30.wav",
  "samples/i31.wav",
  "samples/i32.wav",
  "samples/i33.wav",
  "samples/i34.wav",
  "samples/i35.wav",
  "samples/i36.wav",
  "samples/i37.wav",
  "samples/i38.wav",
  "samples/i40.wav",
  "samples/i43.wav",
  "samples/i44.wav",
  "samples/i45.wav",
  "samples/i46.wav",
  "samples/i47.wav",
  "samples/i48.wav",
  "samples/i49.wav",
  "samples/i50.wav",
  "samples/i51.wav",
  "samples/i52.wav",
  "samples/i53.wav",
  "samples/i54.wav",
  "samples/i55.wav",
  "samples/o01.wav",
  "samples/o02.wav",
  "samples/o04.wav",
  "samples/o05.wav",
  "samples/o06.wav",
  "samples/o07.wav",
  "samples/o08.wav",
  "samples/o09.wav",
  "samples/o10.wav",
  "samples/o11.wav",
  "samples/o12.wav",
  "samples/o13.wav",
  "samples/o14.wav",
  "samples/o15.wav",
  "samples/o16.wav",
  "samples/o17.wav",
  "samples/o18.wav",
  "samples/o19.wav",
  "samples/o20.wav",
  "samples/o21.wav",
  "samples/o22.wav",
  "samples/o23.wav",
  "samples/o24.wav",
  "samples/o25.wav",
  "samples/o26.wav",
  "samples/o28.wav",
  "samples/o29.wav",
  "samples/o30.wav",
  "samples/o31.wav",
  "samples/o33.wav",
  "samples/o34.wav",
  "samples/o35.wav",
  "samples/o36.wav",
  "samples/o37.wav",
  "samples/o38.wav",
  "samples/o39.wav",
  "samples/o40.wav",
  "samples/o41.wav",
  "samples/o42.wav",
  "samples/o43.wav",
  "samples/o44.wav",
  "samples/o45.wav",
  "samples/o46.wav",
  "samples/o47.wav",
  "samples/o48.wav",
  "samples/o49.wav",
  "samples/o50.wav",
  "samples/o51.wav",
  "samples/o52.wav",
  "samples/o53.wav",
  "samples/o54.wav",
  "samples/o55.wav",
  
  "samples/a33.wav",
  "samples/i39.wav",
  "samples/o27.wav",
  "samples/a18.wav",
  "samples/i42.wav",
  "samples/o03.wav",
  "samples/a50.wav",
  "samples/i41.wav",
  "samples/o32.wav",
};

final String[] testName = {
};

final int bias = 1000;
final int delayTime = 1;

Minim minim;
AudioPlayer data;
AudioInput mic;
FFT fft;

// set to a power-of-two number: 44100 * timeSize = windowSize)
final int timeSize = 256;
final int freqBands = 3;  // number of frequencies to record

// so far the best combination is
// 1) 512, 5: 16 sample - 93.75%
// 2) 256, 4: 16 sample - 93.75%

int sampleNum, testNum, currentNum;
boolean learning, done;

int collectedSamples;  // the entire number of fft snapshots(== the number of frames)

int[] aS, iS, oS;  // will receive sample for a, i, o, x sound
double[] aSP, iSP, oSP;  // will hold the bayesian prob
double[] analysisArr;  // array to receive FFT result
int aSampleNum, iSampleNum, oSampleNum;

double pA, pI, pO;  // probability

String answerString;  // to print out to the screen

int[] findFourMax()  // find four indices with largest number in the array
{
  int arrSize = timeSize * 3 / 32 + 1;  // entire analysis array size
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
  {/*
    // first, mix the index array
    for (int i = curSize - 1; i > 0; i--)
    {
      int swapIndex = floor(random(i+1));
      temp = allIndices[i];
      allIndices[i] = allIndices[swapIndex];
      allIndices[swapIndex] = temp;
    }*/
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
  for (int i = 0; i < timeSize / 2 + 1; i++)
  {
    analysisArr[i] = 0;
  }
  return answer;
}

double probA(int[] answer)
{
  double aa = 1;
  for (int i = 0; i < timeSize * 3 / 32 + 1; i++)
  {
    boolean temp = false;
    for (int j = 0; j < freqBands; j++)
    {
      temp = temp || (i == answer[j]);
    }
    if (temp)
    {
      aa *= aSP[i];
    }
    else
    {
      aa *= 1 - aSP[i];
    }
  }
  return aa;
}

double probI(int[] answer)
{
  double ii = 1;
  for (int i = 0; i < timeSize * 3 / 32 + 1; i++)
  {
    boolean temp = false;
    for (int j = 0; j < freqBands; j++)
    {
      temp = temp || (i == answer[j]);
    }
    if (temp)
    {
      ii *= iSP[i];
    }
    else
    {
      ii *= 1 - iSP[i];
    }
  }
  return ii;
}

double probO(int[] answer)
{
  double oo = 1;
  for (int i = 0; i < timeSize * 3 / 32 + 1; i++)
  {
    boolean temp = false;
    for (int j = 0; j < freqBands; j++)
    {
      temp = temp || (i == answer[j]);
    }
    if (temp)
    {
      oo *= oSP[i];
    }
    else
    {
      oo *= 1 - oSP[i];
    }
  }
  return oo;
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
  double sum = pA + pI + pO;
  pA = pA / sum;
  pI = pI / sum;
  pO = pO / sum;
}

void resetP()
{
  pA = 1;
  pI = 1;
  pO = 1;
}

void normalizeSamples()
{
  String[] alist = new String[timeSize / 8 + 2];
  String[] ilist = new String[timeSize / 8 + 2];
  String[] olist = new String[timeSize / 8 + 2];
  alist[0] = Integer.toString(aSampleNum);
  ilist[0] = Integer.toString(iSampleNum);
  olist[0] = Integer.toString(oSampleNum);
  for (int i = 0; i < timeSize / 8 + 1; i++)
  {
    // prepare data to naive bayes net
    alist[i+1] = Integer.toString(aS[i]);
    ilist[i+1] = Integer.toString(iS[i]);
    olist[i+1] = Integer.toString(oS[i]);
  }
  saveStrings("a.txt", alist);
  saveStrings("i.txt", ilist);
  saveStrings("o.txt", olist);
  
  for (int i = 0; i < timeSize / 8 + 1; i++)
  {
    // prepare data to naive bayes net
    aSP[i] = ((double) aS[i]) / (aSampleNum);
    iSP[i] = ((double) iS[i]) / (iSampleNum);
    oSP[i] = ((double) oS[i]) / (oSampleNum);
  }
}

void printResult()
{
  float fA = (float) pA;
  float fI = (float) pI;
  float fO = (float) pO;
  //println(pA);
  //println(pI);
  //println(pO);
  if ((mic.mix.level() < 0.01))
  {
    println("X\n");
    answerString = "X, with " + Integer.toString(0) + "% certainty";
  }
  else if (fA < 0.6 && fI < 0.6 && fO < 0.6)
  {
    println("?\n");
    answerString = "?, with " + Integer.toString(0) + "% certainty";
  }
  else if (fA >= max(fI, fO))
  {
    println("A\n");
    answerString = "A, with " + Integer.toString((int) (pA * 100)) + "% certainty";
  }
  else if (fI >= fO)
  {
    println("I\n");
    answerString = "I, with " + Integer.toString((int) (pI * 100)) + "% certainty";
  }
  else
  {
    println("O\n");
    answerString = "O, with " + Integer.toString((int) (pO * 100)) + "% certainty";
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

  sampleNum = sampleName.length;
  testNum = testName.length;

  aSP = new double[timeSize / 8 + 1];
  iSP = new double[timeSize / 8 + 1];
  oSP = new double[timeSize / 8 + 1];
  aS = new int[timeSize / 8 + 1];
  iS = new int[timeSize / 8 + 1];
  oS = new int[timeSize / 8 + 1];

  for (int i = 0; i < timeSize / 8 + 1; i++)
  {
    aS[i] = bias;
    iS[i] = bias;
    oS[i] = bias;
  }
  aSampleNum += bias;
  iSampleNum += bias;
  oSampleNum += bias;

  analysisArr = new double[timeSize / 2 + 1];

  minim = new Minim(this);
  data = minim.loadFile(sampleName[currentNum], timeSize);
  delay(delayTime);
  data.play();
  fft = new FFT(data.bufferSize(), data.sampleRate());
  fft.forward(data.mix);

  learning = true;
}

void draw()
{
  background(0);
  text(answerString, width/2, height/2);
  if (!done)
  {
    if (learning)  // learning phase
    {
      collectedSamples++;
      // analyze first
      for (int i = 0; i < fft.specSize(); i++)
      {
        analysisArr[i] += fft.getBand(i);
      }
      int[] answer = findFourMax();
      if (sampleName[currentNum].charAt(8) == 'a')
      {
        aSampleNum += 1;
        for (int i = 0; i < freqBands; i++)
        {
          if (answer[i] != -1) {aS[answer[i]] += 1;}
        }
      }
      else if (sampleName[currentNum].charAt(8) == 'i')
      {
        iSampleNum += 1;
        for (int i = 0; i < freqBands; i++)
        {
          if (answer[i] != -1) {iS[answer[i]] += 1;}
        }
      }
      else if (sampleName[currentNum].charAt(8) == 'o')
      {
        oSampleNum += 1;
        for (int i = 0; i < freqBands; i++)
        {
          if (answer[i] != -1) {oS[answer[i]] += 1;}
        }
      }
      if (!data.isPlaying())
      {
        // then deal with the rest
        currentNum += 1;
        if (currentNum == sampleNum)  // done with the samples
        {
          currentNum = 0;
          learning = false;  // go to testing phase
          
          normalizeSamples();
          /*
          data = minim.loadFile(testName[currentNum], timeSize);
          data.play();
          
          fft.forward(data.mix);
          */
          resetP();
          
          done = true;  // done!
          mic = minim.getLineIn(Minim.STEREO, timeSize);       
          fft.forward(mic.mix);
        }
        else // not done with the samples
        {
          data = minim.loadFile(sampleName[currentNum], timeSize);
          data.play();
          fft.forward(data.mix);
        }
      }
      else  // the sample is being played
      {
        fft.forward(data.mix);
      }
    }
    else  // testing phase
    {
      adjustP();
      if (!data.isPlaying())
      {
        printResult();

        currentNum += 1;
        if (currentNum == testNum)  // done with the test
        {
          currentNum = 0;
          done = true;  // done!
          mic = minim.getLineIn(Minim.STEREO, timeSize);       
          fft.forward(mic.mix);
          resetP();
        }
        else
        {
          data = minim.loadFile(testName[currentNum], timeSize);
          data.play();
          fft.forward(data.mix);
          resetP();
        }
      }
      else  // the sample is being played
      {
        fft.forward(data.mix);
      }
    }
  }
  else
  {
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
}
