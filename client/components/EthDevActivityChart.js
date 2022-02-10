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
import { nFormatter, epochFormatter, dateFormatter } from '../lib/formatters';

export default function EthDevActivityChart({ ethDevActivity, eth }) {
  const theme = useTheme();

  const data = ethDevActivity.map((da, idx) => {
    return { ...da, eth: eth[idx].v };
  });
  return (
    <DashboardItem title="Dev Activity - Ethereum Ecosystem">
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
            dataKey="eth"
            name="ETH Price"
            stroke={theme.palette.primary.main}
            yAxisId="eth"
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
            yAxisId="eth"
            orientation="right"
            tickFormatter={nFormatter}
            label={{
              value: 'ETH Price',
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
