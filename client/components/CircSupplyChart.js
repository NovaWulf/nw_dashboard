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
import { dateFormatter, epochFormatter, nFormatter } from '../lib/formatters';
import DashboardItem from './DashboardItem';
import TimeAxis from './TimeAxis';

export default function CircSupplyChart({ circSupply }) {
  const theme = useTheme();

  return (
    <DashboardItem title={`Circulating Supply`}>
      <ResponsiveContainer width="99%" height={300}>
        <AreaChart
          data={circSupply}
          margin={{ top: 5, right: 15, bottom: 5, left: 10 }}
        >
          <Area
            dataKey="v"
            name="Circulating Supply"
            fill={theme.palette.primary.main}
            stroke={theme.palette.primary.main}
          />

          <CartesianGrid stroke="#ccc" strokeDasharray="5 5" />
          {TimeAxis()}

          <YAxis
            tickFormatter={nFormatter}
            stroke={theme.palette.secondary.main}
          />

          <Tooltip labelFormatter={dateFormatter} />
          <Legend />
        </AreaChart>
      </ResponsiveContainer>
    </DashboardItem>
  );
}
