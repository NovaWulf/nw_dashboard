import dayjs from 'dayjs';

export function nFormatter(num) {
  if (num >= 1000000000) {
    return (num / 1000000000).toFixed(1).replace(/\.0$/, '') + 'G';
  }
  if (num >= 1000000) {
    return (num / 1000000).toFixed(1).replace(/\.0$/, '') + 'M';
  }
  if (num >= 1000) {
    return (num / 1000).toFixed(1).replace(/\.0$/, '') + 'K';
  }
  return num.toFixed(0);
}

export function epochFormatter(time) {
  return dayjs(time * 1000).format('MMM YY');
}

export function dateFormatter(time) {
  return dayjs(time * 1000).format('MM/DD/YY');
}
