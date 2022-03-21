import { useTheme } from '@mui/material';
import {
  CartesianGrid,
  ComposedChart,
  Legend,
  Line,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from 'recharts';
import {
  dateFormatter,
  epochFormatter,
  mergeTimestamps,
  nFormatter,
} from '../lib/formatters';
import PriceArea from './PriceArea';
import DashboardItem from './DashboardItem';

export default function MetcalfeChart({ activeAddresses, btcMarketCap }) {
  const theme = useTheme();

  const activeAddressesSquared = activeAddresses.map(aa => ({
    ...aa,
    v: aa.v * aa.v,
  }));

  const data = mergeTimestamps(activeAddressesSquared, btcMarketCap, 'btc');

  return (
    <DashboardItem
      title="Metcalfe's Law"
      helpText="Weekly Active Addresses Squared"
    >
      <ResponsiveContainer width="99%" height={300}>
        <ComposedChart
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
          {PriceArea({ token: 'btc', name: 'BTC Market Cap' })}
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
          <Tooltip labelFormatter={dateFormatter} formatter={nFormatter} />
          <Legend />
        </ComposedChart>
      </ResponsiveContainer>
    </DashboardItem>
  );
}
