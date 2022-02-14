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
import { dateFormatter, epochFormatter, nFormatter } from '../lib/formatters';
import DashboardItem from './DashboardItem';

export default function DevActivityChart({
  devActivity,
  price,
  tokenName,
  chainName,
}) {
  const theme = useTheme();

  const mergedData = devActivity.map((da, idx) => {
    const p = price.find(priceItem => priceItem.ts === da.ts);
    return p ? { ...da, price: p.v } : null;
  });

  const data = mergedData.filter(x => {
    return x !== null;
  });
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
            label={{
              value: 'Dev Activity',
              angle: -90,
              position: 'insideBottomLeft',
            }}
          />
          <YAxis
            yAxisId="price"
            orientation="right"
            tickFormatter={nFormatter}
            label={{
              value: `${tokenName} Price`,
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
