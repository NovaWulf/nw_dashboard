import { Box, Typography } from '@mui/material';
import { useTheme } from '@mui/material/styles';
import {
  ComposedChart,
  Line,
  ResponsiveContainer,
  Scatter,
  XAxis,
  YAxis,
} from 'recharts';
import { nFormatter } from '../lib/formatters';
import { linearRegression } from '../lib/regression';
import DashboardItem from './DashboardItem';

export default function MvrvRegressionChart({ mvrv, btc }) {
  const theme = useTheme();

  const data = mvrv.map((mv, idx) => {
    return { mvrv: mv.v, btc: btc[idx].v };
  });
  const mvrvs = mvrv.map(m => m.v);
  const btcs = btc.map(b => b.v);
  const yMax = Math.max(...btcs);
  const yMin = Math.min(...btcs);
  const xMax = Math.max(...mvrvs);
  const xMin = Math.min(...mvrvs);

  const trend = linearRegression(data, 'mvrv', 'btc');

  const trendData = [
    { btc: trend.calcY(xMin), mvrv: xMin },
    { btc: trend.calcY(xMax), mvrv: xMax },
  ];

  return (
    <DashboardItem title="MVRV / BTC Regression">
      <ResponsiveContainer width="99%" height={300}>
        <ComposedChart
          data={data}
          margin={{ top: 5, right: 0, bottom: 10, left: 15 }}
        >
          <XAxis
            name="MVRV"
            dataKey="mvrv"
            domain={['dataMin', 'dataMax']}
            type="number"
            allowDecimals={false}
            tickFormatter={nFormatter}
            label={{ value: 'MVRV', position: 'insideBottom', offset: '-5' }}
          />
          <YAxis
            dataKey="btc"
            name="BTC Price"
            type="number"
            domain={[yMin, yMax]}
            tickFormatter={nFormatter}
            label={{
              value: 'BTC Price',
              angle: -90,
              position: 'insideLeft',
              offset: '-5',
            }}
          />
          <Scatter
            type="monotoneX"
            dataKey="btc"
            shape="cross"
            fill={theme.palette.primary.main}
          />

          <Line
            data={trendData}
            dataKey="btc"
            stroke={theme.palette.secondary.main}
            strokeDasharray="3 3"
          />
        </ComposedChart>
      </ResponsiveContainer>
      <Box sx={{ display: 'flex', flexDirection: 'row-reverse' }}>
        <Typography component="h3" variant="caption" color="secondary">
          {`R-Squared: ${trend.r2}`}
        </Typography>
      </Box>
    </DashboardItem>
  );
}
