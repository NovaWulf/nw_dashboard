function getAvg(arr) {
  const total = arr.reduce((acc, c) => acc + c, 0);
  return total / arr.length;
}

function getSum(arr) {
  return arr.reduce((acc, c) => acc + c, 0);
}

export function linearRegression(data, xKey, yKey) {
  const x = data.map(value => value[xKey]);
  const y = data.map(value => value[yKey]);

  var n = y.length;
  var sum_x = 0;
  var sum_y = 0;
  var sum_xy = 0;
  var sum_xx = 0;
  var sum_yy = 0;

  for (var i = 0; i < n; i++) {
    sum_x += x[i];
    sum_y += y[i];
    sum_xy += x[i] * y[i];
    sum_xx += x[i] * x[i];
    sum_yy += y[i] * y[i];
  }

  const slope = (n * sum_xy - sum_x * sum_y) / (n * sum_xx - sum_x * sum_x);
  const yStart = (sum_y - slope * sum_x) / n;
  const r2 = Math.pow(
    (n * sum_xy - sum_x * sum_y) /
      Math.sqrt((n * sum_xx - sum_x * sum_x) * (n * sum_yy - sum_y * sum_y)),
    2,
  ).toPrecision(4);

  //   // average of X values and Y values
  //   const xMean = getAvg(xData);
  //   const yMean = getAvg(yData);

  //   // Subtract X or Y mean from corresponding axis value
  //   const xMinusxMean = xData.map(val => val - xMean);
  //   const yMinusyMean = yData.map(val => val - yMean);

  //   const xMinusxMeanSq = xMinusxMean.map(val => Math.pow(val, 2));

  //   const xy = [];
  //   for (let x = 0; x < data.length; x++) {
  //     xy.push(xMinusxMean[x] * yMinusyMean[x]);
  //   }

  //   // const xy = xMinusxMean.map((val, index) => val * yMinusyMean[index]);

  //   const xySum = getSum(xy);

  //   // b1 is the slope
  //   const b1 = xySum / getSum(xMinusxMeanSq);
  //   // b0 is the start of the slope on the Y axis
  //   const b0 = yMean - b1 * xMean;

  return {
    slope,
    yStart,
    r2,
    calcY: x => yStart + slope * x,
  };
}
export function getRSquared(predict, data) {
  var yAxis = data;
  var rPrediction = [];

  var meanValue = 0; // MEAN VALUE
  var SStot = 0; // THE TOTAL SUM OF THE SQUARES
  var SSres = 0; // RESIDUAL SUM OF SQUARES
  var rSquared = 0;

  // SUM ALL VALUES
  for (var n in yAxis) {
    meanValue += yAxis[n];
  }

  // GET MEAN VALUE
  meanValue = meanValue / yAxis.length;

  for (var n in yAxis) {
    // CALCULATE THE SSTOTAL
    SStot += Math.pow(yAxis[n] - meanValue, 2);
    // REGRESSION PREDICTION
    rPrediction.push(predict(n));
    // CALCULATE THE SSRES
    SSres += Math.pow(rPrediction[n] - yAxis[n], 2);
  }

  // R SQUARED
  rSquared = (1 - SSres / SStot).toPrecision(3);

  return {
    meanValue: meanValue,
    SStot: SStot,
    SSres: SSres,
    rSquared: rSquared,
  };
}
