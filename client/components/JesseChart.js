import {
  LineChart,
  Line,
  CartesianGrid,
  XAxis,
  YAxis,
  Tooltip,
  ResponsiveContainer,
  Legend,
  ReferenceLine,
} from 'recharts';
import dayjs from 'dayjs';
import DashboardItem from './DashboardItem';
import { useTheme } from '@mui/material';
import {
  nFormatter,
  epochFormatter,
  dateFormatter,
  mergeTimestamps,
} from '../lib/formatters';

export default function JesseChart({ jesse, btc }) {
  const theme = useTheme();

  const data = mergeTimestamps(jesse, btc, 'btc');

  const STD_ERROR = 3540;

  const updatedData = data.map(d => {
    return {
      ts: d.ts,
      btc: d.btc,
      jesseLow: d.v - STD_ERROR,
      jesseHigh: d.v + STD_ERROR,
    };
  });

  return (
    <DashboardItem
      title="Jesse's Indicator"
      helpText="Jesse's Indicator looks at a regression of Stock To Flow Ratio, Hashrate, Metcalfe's Law and Google Trends for Bitcoin"
    >
      <ResponsiveContainer width="99%" height={300}>
        <LineChart
          data={updatedData}
          margin={{ top: 5, right: 15, bottom: 5, left: 0 }}
        >
          <Line
            type="monotone"
            dataKey="jesseLow"
            name="Low Range"
            stroke="green"
            dot={false}
            yAxisId="btc"
          />
          <Line
            type="monotone"
            dataKey="jesseHigh"
            name="High Range"
            stroke="red"
            dot={false}
            yAxisId="btc"
          />
          <Line
            type="monotone"
            dataKey="btc"
            name="BTC Price"
            stroke={theme.palette.secondary.secondary}
            yAxisId="btc"
            dot={false}
          />
          <CartesianGrid stroke="#ccc" strokeDasharray="5 5" />
          <XAxis
            dataKey="ts"
            domain={['dataMin', 'dataMax']}
            type="number"
            scale="time"
            tickFormatter={epochFormatter}
          />
          <YAxis
            yAxisId="btc"
            orientation="left"
            tickFormatter={nFormatter}
            stroke={theme.palette.primary.main}
            domain={[-3000, 'dataMax']}
          />

          <Tooltip labelFormatter={dateFormatter} />
          <Legend />
        </LineChart>
      </ResponsiveContainer>
    </DashboardItem>
  );
}
