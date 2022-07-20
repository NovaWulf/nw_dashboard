import { epochFormatterHighRes } from 'lib/formatters';
import { XAxis } from 'recharts';

export default function TimeAxisHighRes() {

  const startDate = new Date();

  startDate.setMonth((startDate.getMonth() + 10) % 12);

  return (
    <XAxis
      allowDataOverflow
      dataKey="ts"
      domain={[startDate.getTime() / 1000, 'dataMax']}
      type="number"
      scale="time"
      tickFormatter={epochFormatterHighRes}
    />
  );
}
