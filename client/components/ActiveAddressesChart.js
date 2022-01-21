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

export default function ActiveAddressesChart({ activeAddresses, btc }) {
  const theme = useTheme();

  const data = activeAddresses.map((aa, idx) => {
    return { ...aa, btc: btc[idx].v };
  });
  return (
    <DashboardItem title="Active Addresses">
      <ResponsiveContainer width="99%" height={300}>
        <LineChart
          // width={600}
          // height={300}
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
            yAxisId="aa"
            tickFormatter={nFormatter}
            label={{
              value: 'Active Addresses',
              angle: -90,
              position: 'insideBottomLeft',
              offset: '10',
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

const EpochFormatter = time => {
  return dayjs(time * 1000).format('MMM YY');
};

const DateFormatter = time => {
  return dayjs(time * 1000).format('MM/DD/YY');
};

const TooltipValueFormatter = (value, name, props) => [value, name];
