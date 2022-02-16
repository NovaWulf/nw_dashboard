import {
  LineChart,
  Line,
  CartesianGrid,
  XAxis,
  YAxis,
  Tooltip,
  ResponsiveContainer,
  Legend,
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

export default function MvrvChart({ mvrv, btc }) {
  const theme = useTheme();

  const data = mergeTimestamps(mvrv, btc, 'btc');

  return (
    <DashboardItem
      title="MVRV Ratio"
      helpText="MVRV (market-value-to-realized-value) is a ratio of an asset's Market Capitalization versus its Realized Capitalization. By comparing these two metrics, MVRV can be used to get a sense of when price is above or below 'fair value', and to assess market profitability. Extreme deviations between market value and realized value can be used to identify market tops and bottoms as they reflect periods of extremes investor unrealized profit and loss, respectively"
    >
      <ResponsiveContainer width="99%" height={300}>
        <LineChart
          data={data}
          margin={{ top: 5, right: 15, bottom: 5, left: 0 }}
        >
          <Line
            type="monotone"
            dataKey="v"
            name="MVRV"
            stroke={theme.palette.secondary.main}
            dot={false}
            yAxisId="mvrv"
          />
          <Line
            type="monotone"
            dataKey="btc"
            name="BTC Price"
            stroke={theme.palette.primary.main}
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
            yAxisId="mvrv"
            label={{
              value: 'MVRV',
              angle: -90,
              position: 'inside',
            }}
          />
          <YAxis
            yAxisId="btc"
            orientation="right"
            tickFormatter={nFormatter}
            label={{
              value: 'BTC Price',
              angle: -270,
              position: 'insideRight',
            }}
          />
          <Tooltip labelFormatter={dateFormatter} />
          <Legend />
        </LineChart>
      </ResponsiveContainer>
    </DashboardItem>
  );
}
