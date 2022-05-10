import { useTheme } from '@mui/material';
import {
  CartesianGrid,
  ComposedChart,
  Legend,
  Line,
  ResponsiveContainer,
  Tooltip,
  YAxis,
} from 'recharts';
import { dateFormatter, mergeTimestamps, nFormatter } from '../lib/formatters';
import DashboardItem from './DashboardItem';
import PriceArea from './PriceArea';
import TimeAxis from './TimeAxis';

export default function DevActivityChart({
  devActivity,
  price,
  tokenName,
  chainName,
}) {
  const theme = useTheme();

  const data = mergeTimestamps(devActivity, price, 'price');

  return (
    <DashboardItem
      title={`Dev Activity - ${chainName} Org`}
      helpText="Dev Activity includes commits, but also comments, follows, issue creation, etc"
    >
      <ResponsiveContainer width="99%" height={300}>
        <ComposedChart
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
          {PriceArea({
            token: 'price',
            name: `${tokenName.toUpperCase()} Price`,
          })}

          <CartesianGrid stroke="#ccc" strokeDasharray="5 5" />
          {TimeAxis()}
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
        </ComposedChart>
      </ResponsiveContainer>
    </DashboardItem>
  );
}
