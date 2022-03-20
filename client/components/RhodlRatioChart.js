import { useTheme } from '@mui/material';
import {
  CartesianGrid, ComposedChart, Legend, Line, ReferenceLine, ResponsiveContainer, Tooltip, XAxis,
  YAxis
} from 'recharts';
import {
  dateFormatter, epochFormatter, mergeTimestamps, nFormatter
} from '../lib/formatters';
import DashboardItem from './DashboardItem';
import PriceArea from './PriceArea';

export default function RhodlRatioChart({ rhodlRatio, btc }) {
  const theme = useTheme();

  const data = mergeTimestamps(rhodlRatio, btc, 'btc');

  const dataMax = Math.max(...data.map(i => i.v));
  const dataMin = Math.min(...data.map(i => i.v));
  const endOfRed = (dataMax - 50000) / dataMax;
  const startOfGreen = 100 - 350 / dataMax;

  return (
    <DashboardItem
      title="RHODL Ratio"
      helpText="The RHODL Ratio takes the ratio between the 1 week and the 1-2 years RCap HODL bands. In addition, it accounts for increased supply by weighting the ratio by the total market age. A high ratio is an indication of an overheated market and can be used to time cycle tops."
    >
      <ResponsiveContainer width="99%" height={300}>
        <ComposedChart
          data={data}
          margin={{ top: 5, right: 15, bottom: 5, left: 10 }}
        >
          <defs>
            <linearGradient id="splitColor" x1="0" y1="0" x2="0" y2="100%">
              <stop offset="0%" stopColor="red" stopOpacity={0.5} />
              <stop offset={`${endOfRed}%`} stopColor="gray" stopOpacity={1} />
              {/* <stop offset="70%" stopColor="gray" stopOpacity={1} /> */}
              <stop
                offset={`${startOfGreen}%`}
                stopColor="gray"
                stopOpacity={1}
              />
              <stop offset="100%" stopColor="green" stopOpacity={1} />
            </linearGradient>
          </defs>
          <Line
            type="monotone"
            dataKey="v"
            name="RHODL Ratio"
            stroke="url(#splitColor)"
            // stroke={theme.palette.secondary.main}
            dot={false}
            yAxisId="rhodlRatio"
          />
          {PriceArea({token: "btc"})}
      
          <CartesianGrid stroke="#ccc" strokeDasharray="5 5" />
          <XAxis
            dataKey="ts"
            domain={['dataMin', 'dataMax']}
            type="number"
            scale="time"
            tickFormatter={epochFormatter}
          />
          <YAxis
            yAxisId="rhodlRatio"
            scale="log"
            domain={['auto', 'auto']}
            tickFormatter={nFormatter}
            stroke={theme.palette.secondary.main}
          />
          <YAxis
            yAxisId="btc"
            orientation="right"
            tickFormatter={nFormatter}
            stroke={theme.palette.primary.main}
          />
          <Tooltip labelFormatter={dateFormatter} />
          <ReferenceLine
            y={50000}
            yAxisId="rhodlRatio"
            stroke="red"
            strokeDasharray="2 2"
          />
          <ReferenceLine
            y={350}
            yAxisId="rhodlRatio"
            stroke="green"
            strokeDasharray="2 2"
          />
          <Legend />
        </ComposedChart>
      </ResponsiveContainer>
    </DashboardItem>
  );
}
