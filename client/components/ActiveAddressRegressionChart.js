import {
  LineChart,
  Line,
  CartesianGrid,
  XAxis,
  YAxis,
  Tooltip,
  ResponsiveContainer,
  Scatter,
  ComposedChart,
} from 'recharts';
import dayjs from 'dayjs';
import DashboardItem from './DashboardItem';
// import createTrend from 'trendline';
import { linearRegression } from '../lib/regression';
import { useTheme } from '@mui/material/styles';
import { Box, Typography } from '@mui/material';
import { nFormatter } from '../lib/formatters';

export default function ActiveAddressRegressionChart({ activeAddresses, btc }) {
  const theme = useTheme();

  const data = activeAddresses.map((aa, idx) => {
    return { activeAddresses: aa.v, btc: btc[idx].v };
  });
  const activeAddressess = activeAddresses.map(aa => aa.v);
  const btcs = btc.map(b => b.v);
  const yMax = Math.max(...btcs);
  const yMin = Math.min(...btcs);
  const xMax = Math.max(...activeAddressess);
  const xMin = Math.min(...activeAddressess);

  const trend = linearRegression(data, 'activeAddresses', 'btc');

  const trendData = [
    { btc: trend.calcY(xMin), activeAddresses: xMin },
    { btc: trend.calcY(xMax), activeAddresses: xMax },
  ];

  // const rSquared = getRSquared(trend.calcY, btcs).rSquared;

  return (
    <DashboardItem title="Active Address / BTC Regression">
      <ResponsiveContainer width="99%" height={300}>
        <ComposedChart
          data={data}
          margin={{ top: 5, right: 0, bottom: 10, left: 15 }}
        >
          <XAxis
            name="Active Addresses"
            dataKey="activeAddresses"
            domain={['dataMin', 'dataMax']}
            type="number"
            allowDecimals={false}
            tickFormatter={nFormatter}
            label={{
              value: 'ActiveAddresses',
              position: 'insideBottom',
              offset: '-5',
            }}
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
