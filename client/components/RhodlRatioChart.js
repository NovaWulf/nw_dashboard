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
import DashboardItem from './DashboardItem';
import { useTheme } from '@mui/material';
import { nFormatter, epochFormatter, dateFormatter } from '../lib/formatters';

export default function RhodlRatioChart({ rhodlRatio, btc }) {
  const theme = useTheme();

  const data = rhodlRatio.map((mv, idx) => {
    return { ...mv, btc: btc[idx].v };
  });
  return (
    <DashboardItem title="RHODL Ratio">
      <ResponsiveContainer width="99%" height={300}>
        <LineChart
          data={data}
          margin={{ top: 5, right: 15, bottom: 5, left: 10 }}
        >
          <Line
            type="monotone"
            dataKey="v"
            name="RHODL Ratio"
            stroke={theme.palette.secondary.main}
            dot={false}
            yAxisId="rhodlRatio"
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
            yAxisId="rhodlRatio"
            tickFormatter={nFormatter}
            label={{
              value: 'RHODL RATIO',
              angle: -90,
              position: 'insideBottomLeft',
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
