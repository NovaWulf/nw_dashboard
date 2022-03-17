import {
  LineChart,
  Line,
  Area,
  CartesianGrid,
  XAxis,
  YAxis,
  Tooltip,
  ResponsiveContainer,
  ComposedChart,
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
import BtcArea from './BtcArea';

export default function MvrvChart({ mvrv, btc }) {
  const theme = useTheme();

  const data = mergeTimestamps(mvrv, btc, 'btc');

  const dataMax = Math.max(...data.map(i => i.v));
  const endOfRed = (dataMax - 3) / dataMax
  const startOfGreen = 100 - (1 / dataMax)

  return (
    <DashboardItem
      title="MVRV Ratio"
      helpText="MVRV (market-value-to-realized-value) is a ratio of an asset's Market Capitalization versus its Realized Capitalization. By comparing these two metrics, MVRV can be used to get a sense of when price is above or below 'fair value', and to assess market profitability. Extreme deviations between market value and realized value can be used to identify market tops and bottoms as they reflect periods of extremes investor unrealized profit and loss, respectively"
    >
      <ResponsiveContainer width="99%" height={300}>
        <ComposedChart
          data={data}
          margin={{ top: 5, right: 15, bottom: 5, left: 0 }}
        >
          <defs>
            <linearGradient id="splitColor" x1="0" y1="0" x2="0" y2="100%">
              <stop offset="0%" stopColor="red" stopOpacity={1} />
              <stop offset={`${endOfRed}%`} stopColor="red" stopOpacity={1} />
              <stop offset="70%" stopColor="gray" stopOpacity={1} />
              <stop offset={`${startOfGreen}%`} stopColor="green" stopOpacity={1} />
              <stop offset="100%" stopColor="green" stopOpacity={1} />
            </linearGradient>
          </defs>
          <Line
            type="monotone"
            dataKey="v"
            name="MVRV"
            stroke='url(#splitColor)'
            // stroke={theme.palette.secondary.main}
            // fill="green"
            // fill="url(#splitColor)"
            dot={false}
            yAxisId="mvrv"
          />
          {BtcArea({})}
          <CartesianGrid stroke="#ccc" strokeDasharray="5 5" />
          <XAxis
            dataKey="ts"
            domain={['dataMin', 'dataMax']}
            type="number"
            scale="time"
            tickFormatter={epochFormatter}
          />
          <YAxis yAxisId="mvrv" stroke={theme.palette.secondary.main} />
          <YAxis
            yAxisId="btc"
            orientation="right"
            tickFormatter={nFormatter}
            stroke={theme.palette.primary.main}
          />
          <ReferenceLine
            y={3}
            yAxisId="mvrv"
            stroke="red"
            strokeDasharray="2 2"
          />
          <ReferenceLine
            y={1}
            yAxisId="mvrv"
            stroke="green"
            strokeDasharray="2 2"
          />

          <Tooltip labelFormatter={dateFormatter} />
          <Legend />
        </ComposedChart>
      </ResponsiveContainer>
    </DashboardItem>
  );
}
