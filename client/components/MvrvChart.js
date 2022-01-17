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
import { nFormatter } from '../lib/formatters';

export default function MvrvChart({ mvrv, btc }) {
  const theme = useTheme();

  const data = mvrv.map((mv, idx) => {
    return { ...mv, btc: btc[idx].v };
  });
  return (
    <DashboardItem title="MVRV">
      <ResponsiveContainer width="99%" height={300}>
        <LineChart
          // width={600}
          // height={300}
          data={data}
          margin={{ top: 5, right: 15, bottom: 5, left: 0 }}
        >
          <Line
            type="monotone"
            dataKey="v"
            name="MVRV"
            stroke={theme.palette.secondary.main}
            dot={false}
            yAxisId="mvrv"
          />
          <Line
            type="monotone"
            dataKey="btc"
            name="BTC Price"
            stroke={theme.palette.primary.main}
            yAxisId="btc"
            dot={false}

            // strokeDasharray="5 5"
          />
          <CartesianGrid stroke="#ccc" strokeDasharray="5 5" />
          <XAxis
            dataKey="ts"
            domain={['dataMin', 'dataMax']}
            type="number"
            scale="time"
            tickFormatter={EpochFormatter}
          />
          <YAxis
            yAxisId="mvrv"
            label={{
              value: 'MVRV',
              angle: -90,
              position: 'inside',
              // offset: '-5',
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
              // offset: '-10',
            }}
          />
          <Tooltip
            labelFormatter={DateFormatter}
            // formatter={TooltipValueFormatter}
          />
          <Legend />
        </LineChart>
      </ResponsiveContainer>
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

const TooltipValueFormatter = (value, name, props) => [value, name];
