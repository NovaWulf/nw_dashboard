import { epochFormatter } from 'lib/formatters';
import { useContext } from 'react';
import { XAxis } from 'recharts';
import { TimespanContext } from './timespan/TimespanContext';

export default function TimeAxis() {
  const { timespan } = useContext(TimespanContext);

  const startDate = new Date();
  if (timespan === '5y') {
    startDate.setFullYear(startDate.getFullYear() - 5);
  } else if (timespan === '1y') {
    startDate.setFullYear(startDate.getFullYear() - 1);
  } else if (timespan === '3m') {
    startDate.setMonth((startDate.getMonth() + 9) % 12);
  }

  return (
    <XAxis
      allowDataOverflow
      dataKey="ts"
      domain={[startDate.getTime() / 1000, 'dataMax']}
      type="number"
      scale="time"
      tickFormatter={epochFormatter}
    />
  );
}
