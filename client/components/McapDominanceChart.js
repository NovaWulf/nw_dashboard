import { useTheme } from '@mui/material';
import {
  Area,
  AreaChart,
  CartesianGrid,
  Legend,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from 'recharts';
import {
  dateFormatter,
  epochFormatter,
  nFormatter,
  percentFormatter,
} from '../lib/formatters';
import DashboardItem from './DashboardItem';

export default function McapDominanceChart({ mcapDominance }) {
  const theme = useTheme();

  return (
    <DashboardItem
      title="Market Cap Dominance"
      helpText="The asset's percentage share of total crypto circulating marketcap"
    >
      <ResponsiveContainer width="99%" height={300}>
        <AreaChart
          data={mcapDominance}
          margin={{ top: 5, right: 15, bottom: 5, left: 10 }}
        >
          <Area
            dataKey="v"
            name="Market Cap Dominance"
            fill={theme.palette.primary.main}
            stroke={theme.palette.primary.main}
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
            tickFormatter={percentFormatter}
            stroke={theme.palette.secondary.main}
          />

          <Tooltip labelFormatter={dateFormatter} />
          <Legend />
        </AreaChart>
      </ResponsiveContainer>
    </DashboardItem>
  );
}
