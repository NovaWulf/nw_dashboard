import { epochFormatter2 } from 'lib/formatters';
import { XAxis } from 'recharts';

export default function TimeAxis2() {

  const startDate = new Date();

  startDate.setMonth((startDate.getMonth() + 11) % 12);


  return (
    <XAxis
      allowDataOverflow
      dataKey="ts"
      domain={[startDate.getTime() / 1000, 'dataMax']}
      type="number"
      scale="time"
      tickFormatter={epochFormatter2}
    />
  );
}
