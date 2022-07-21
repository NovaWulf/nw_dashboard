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

export default function ArbitrageSignalChart({ arb_signal, mean, sd }) {
  const theme = useTheme();
  const SIGMA = 1;
  console.log('mean: ' + mean + ', sd: ' + sd);
  const updatedData = arb_signal.map(d => {
    return {
      ts: d.ts,
      v: d.v,
      arbLow: mean - SIGMA * sd,
      arbHigh: mean + SIGMA * sd,
    };
  });

  return (
    <DashboardItem
      title="Arbitrage Indicator"
      helpText="Arbitrage Indicator looks at the value of the mean reverting portfolio of assets"
      downloadButton={
        <CsvDownloadLink data={updatedData} title="Arbitrage Indicator" />
      }
    >
      <ResponsiveContainer width="99%" height={300}>
        <LineChart
          data={updatedData}
          margin={{ top: 5, right: 15, bottom: 5, left: 0 }}
        >
          <Line
            type="monotone"
            dataKey="arbLow"
            name="Low Range"
            stroke="green"
            dot={false}
            yAxisId="spread"
          />
          <Line
            type="monotone"
            dataKey="arbHigh"
            name="High Range"
            stroke="red"
            dot={false}
            yAxisId="spread"
          />
          <Line
            type="monotone"
            dataKey="v"
            name="spread value"
            stroke={theme.palette.secondary.secondary}
            yAxisId="spread"
            dot={false}
          />
          <CartesianGrid stroke="#ccc" strokeDasharray="5 5" />
          {TimeAxisHighRes()}

          <YAxis
            yAxisId="spread"
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
