import dayjs from 'dayjs';

export function nFormatter(num) {
  if (num >= 1000000000000) {
    return (num / 1000000000000).toFixed(1).replace(/\.0$/, '') + 'T';
  }
  if (num >= 1000000000) {
    return (num / 1000000000).toFixed(1).replace(/\.0$/, '') + 'B';
  }
  if (num >= 1000000) {
    return (num / 1000000).toFixed(1).replace(/\.0$/, '') + 'M';
  }
  if (num >= 1000) {
    return (num / 1000).toFixed(1).replace(/\.0$/, '') + 'K';
  }
  return num.toFixed(2);
}

export function epochFormatter(time) {
  return dayjs(time * 1000).format('MMM YY');
}

export function dateFormatter(time) {
  return dayjs(time * 1000).format('MM/DD/YY');
}

export function mergeTimestamps(array1, array2, key) {
  const mergedData = array1.map(a1Item => {
    const p = array2.find(a2Item => a2Item.ts === a1Item.ts);
    return p ? { ...a1Item, [key]: p.v } : null;
  });

  const data = mergedData.filter(x => {
    return x !== null;
  });
  return data;
}
