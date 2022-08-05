import { useTheme } from '@mui/material';
import {
  CartesianGrid,
  Legend,
  Line,
  LineChart,
  ResponsiveContainer,
  Tooltip,
  YAxis,
  ReferenceLine,
} from 'recharts';
import { dateFormatter, percentFormatter } from 'lib/formatters';
import DashboardItem from 'components/DashboardItem';
import TimeAxisHighRes from 'components/TimeAxisHighRes';
import CsvDownloadLink from 'components/CsvDownloadLink';

export default function ArbitrageBacktestChart({ pnl, isEndDate }) {
  const theme = useTheme();

  const updatedData = pnl.map(d => {
    return {
      ts: d.ts,
      v: Math.floor(100*d.v),
      is: d.is,
    };
  });

  return (
    <DashboardItem
      title="Arbitrage Backtester"
      helpText="Arbitrage Backtester looks at the PnL of a given trading strategy over time"
      downloadButton={
        <CsvDownloadLink data={updatedData} title="Arbitrage Backtester" />
      }
    >
      <ResponsiveContainer width="99%" height={300}>
        <LineChart
          data={updatedData}
          margin={{ top: 5, right: 15, bottom: 5, left: 0 }}
        >
          <ReferenceLine
            strokeDasharray="3 3"
            yAxisId="pnl"
            x={isEndDate}
            stroke="red"
            label="IS <-> OOS"
          />
          <Line
            type="monotone"
            dataKey="v"
            name="Profit and Loss"
            stroke={theme.palette.secondary.secondary}
            yAxisId="pnl"
            dot={false}
          />
          <CartesianGrid stroke="#ccc" strokeDasharray="5 5" />
          {TimeAxisHighRes()}

          <YAxis
            yAxisId="pnl"
            orientation="left"
            tickFormatter={percentFormatter}
            stroke={theme.palette.primary.main}
            domain={[-200, 200]}
          />

          <Tooltip labelFormatter={dateFormatter} />
          <Legend />
        </LineChart>
      </ResponsiveContainer>
    </DashboardItem>
  );
}
