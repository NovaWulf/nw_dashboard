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

export default function MetcalfeChart({ activeAddresses, btcMarketCap }) {
  const theme = useTheme();

  const activeAddressesSquared = activeAddresses.map(aa => ({
    ...aa,
    v: aa.v * aa.v,
  }));

  const data = mergeTimestamps(
    activeAddressesSquared,
    btcMarketCap,
    'btcMarketCap',
  );

  return (
    <DashboardItem
      title="Metcalfe's Law"
      helpText="Weekly Active Addresses Squared"
    >
      <ResponsiveContainer width="99%" height={300}>
        <LineChart
          data={data}
          margin={{ top: 5, right: 15, bottom: 5, left: 10 }}
        >
          <Line
            type="monotone"
            dataKey="v"
            name="Weekly Active Addresses Squared"
            stroke={theme.palette.secondary.main}
            dot={false}
            yAxisId="aa"
          />
          <Line
            type="monotone"
            dataKey="btcMarketCap"
            name="BTC Market Cap"
            stroke={theme.palette.primary.main}
            yAxisId="btcMarketCap"
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
            yAxisId="btcMarketCap"
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
