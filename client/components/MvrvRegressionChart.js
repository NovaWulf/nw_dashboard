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

  // const rSquared = getRSquared(trend.calcY, btcs).rSquared;

  return (
    <DashboardItem title="MVRV / BTC Regression">
      <ResponsiveContainer width="99%" height={300}>
        <ComposedChart
          // width={600}
          // height={300}
          data={data}
          margin={{ top: 5, right: 0, bottom: 10, left: 15 }}
        >
          {/* <CartesianGrid stroke="#ccc" strokeDasharray="5 5" /> */}
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
            // stroke={theme.palette.primary.main}
            fill={theme.palette.primary.main}
            // strokeWidth={1}
          />
          {/* <Tooltip
          // labelFormatter={DateFormatter}
          // formatter={TooltipValueFormatter}
          /> */}
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

const DollarFormater = number => {
  if (number > 1000000000000) {
    return '$' + (number / 1000000000000).toString() + 'T';
  } else if (number > 1000000000) {
    return '$' + (number / 1000000000).toString() + 'B';
  } else if (number > 1000000) {
    return '$' + (number / 1000000).toString() + 'M';
  } else if (number > 1000) {
    return '$' + (number / 1000).toString() + 'K';
  } else {
    return '$' + number.toString();
  }
};

const EpochFormatter = time => {
  return dayjs(time * 1000).format('MMM YY');
};

const DateFormatter = time => {
  return dayjs(time * 1000).format('MM/DD/YY');
};

const TooltipValueFormatter = (value, name, props) => [value, 'MVRV'];
