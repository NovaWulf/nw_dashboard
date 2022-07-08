import { useContext } from 'react';
import { YAxis } from 'recharts';
import { TimespanContext } from './timespan/TimespanContext';

export default function DynamicYAxis({
  yAxisId,
  orientation,
  tickFormatter,
  stroke,
}) {
  const { timespan } = useContext(TimespanContext);

  return (
    <YAxis
      yAxisId={yAxisId}
      orientation={orientation || 'right'}
      tickFormatter={tickFormatter || nFormatter}
      stroke={stroke || theme.palette.primary.main}
      // domain={['dataMin', 'dataMax']}
    />
  );
}
