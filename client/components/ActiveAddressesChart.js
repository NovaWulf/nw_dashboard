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

export default function ActiveAddressesChart({ activeAddresses, price, token }) {
  const theme = useTheme();

  const data = mergeTimestamps(activeAddresses, price, token);

  return (
    <DashboardItem title="Active Addresses" helpText="Weekly Active Addresses">
      <ResponsiveContainer width="99%" height={300}>
        <ComposedChart
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
          {PriceArea({token: token, name: `${token.toUpperCase()} Price`})}
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
            yAxisId={token}
            orientation="right"
            tickFormatter={nFormatter}
            stroke={theme.palette.primary.main}
          />
          <Tooltip labelFormatter={dateFormatter} />
          <Legend />
        </ComposedChart>
      </ResponsiveContainer>
    </DashboardItem>
  );
}
