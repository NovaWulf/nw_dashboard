import { useTheme } from '@mui/material';
import {
  CartesianGrid,
  Legend,
  Line,
  LineChart,
  ResponsiveContainer,
  Tooltip,
  YAxis,
} from 'recharts';
import { dateFormatter, nFormatter } from 'lib/formatters';
import DashboardItem from 'components/DashboardItem';
import TimeAxisHighRes from 'components/TimeAxisHighRes';
import CsvDownloadLink from 'components/CsvDownloadLink';

export default function ArbitrageBacktestChart({ pnl }) {
  const theme = useTheme();

  const updatedData = pnl.map(d => {
    return {
      ts: d.ts,
      v: d.v,
    };
  });

  return (
    <DashboardItem
      title="Arbitrage Backtester"
      helpText="Arbitrage Backtester looks at the value of the mean reverting portfolio of assets"
      downloadButton={
        <CsvDownloadLink data={updatedData} title="Arbitrage Backtester" />
      }
    >
      <ResponsiveContainer width="99%" height={300}>
        <LineChart
          data={updatedData}
          margin={{ top: 5, right: 15, bottom: 5, left: 0 }}
        >
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
            tickFormatter={nFormatter}
            stroke={theme.palette.primary.main}
            domain={[-150, 150]}
          />

          <Tooltip labelFormatter={dateFormatter} />
          <Legend />
        </LineChart>
      </ResponsiveContainer>
    </DashboardItem>
  );
}
