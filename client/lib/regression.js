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

  return {
    slope,
    yStart,
    r2,
    calcY: x => yStart + slope * x,
  };
}
