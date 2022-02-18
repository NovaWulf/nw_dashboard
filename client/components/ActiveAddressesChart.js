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

export default function ActiveAddressesChart({ activeAddresses, btc }) {
  const theme = useTheme();

  const data = mergeTimestamps(activeAddresses, btc, 'btc');

  return (
    <DashboardItem title="Active Addresses" helpText="Weekly Active Addresses">
      <ResponsiveContainer width="99%" height={300}>
        <LineChart
          data={data}
          margin={{ top: 5, right: 15, bottom: 5, left: 10 }}
        >
          <Line
            type="monotone"
            dataKey="v"
            name="Active Addresses"
            stroke={theme.palette.secondary.main}
            dot={false}
            yAxisId="aa"
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
            yAxisId="aa"
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
          <Legend />
        </LineChart>
      </ResponsiveContainer>
    </DashboardItem>
  );
}
