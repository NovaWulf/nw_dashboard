import { useTheme } from '@mui/material';
import {
  CartesianGrid,
  Legend,
  Line,
  LineChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from 'recharts';
import {
  dateFormatter,
  epochFormatter,
  nFormatter,
  mergeTimestamps,
} from '../lib/formatters';
import DashboardItem from './DashboardItem';

export default function DevActivityChart({
  devActivity,
  price,
  tokenName,
  chainName,
}) {
  const theme = useTheme();

  const data = mergeTimestamps(devActivity, price, 'price');

  return (
    <DashboardItem title={`Dev Activity - ${chainName} Ecosystem`}>
      <ResponsiveContainer width="99%" height={300}>
        <LineChart
          data={data}
          margin={{ top: 5, right: 15, bottom: 5, left: 10 }}
        >
          <Line
            type="monotone"
            dataKey="v"
            name="Dev Activity"
            stroke={theme.palette.secondary.main}
            dot={false}
            yAxisId="dev"
          />
          <Line
            type="monotone"
            dataKey="price"
            name={`${tokenName} Price`}
            stroke={theme.palette.primary.main}
            yAxisId="price"
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
            yAxisId="dev"
            tickFormatter={nFormatter}
            stroke={theme.palette.secondary.main}
          />
          <YAxis
            yAxisId="price"
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
