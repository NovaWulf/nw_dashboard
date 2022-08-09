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

export default function ArbitrageSignalChart({
  arbSignal,
  mean,
  sd,
  isEndDate,
}) {
  const theme = useTheme();
  const SIGMA = 3;
  console.log('mean: ' + mean + ', sd: ' + sd);
  const updatedData = arbSignal.map(d => {
    return {
      ts: d.ts,
      v: Math.floor(100*(d.v-mean)),
      // is: d.is,
      arbLow: Math.floor(100*(- SIGMA * sd)),
      arbHigh: Math.floor(100*( SIGMA * sd)),
      arbMean: Math.floor(0),
    };
  });
  console.log('in sample end date: ' + isEndDate);
  return (
    <DashboardItem
      title="OP-ETH Arbitrage Indicator"
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
          <ReferenceLine
            strokeDasharray="3 3"
            yAxisId="spread"
            x={isEndDate}
            stroke="red"
          />
          <Line
            type="monotone"
            dataKey="arbMean"
            name="mean spread"
            stroke="red"
            yAxisId="spread"
            dot={false}
          />
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
            stroke="green"
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
            tickFormatter={percentFormatter}
            stroke={theme.palette.primary.main}
            domain={[-30, 30]}
          />

          <Tooltip labelFormatter={dateFormatter} />
          <Legend />
        </LineChart>
      </ResponsiveContainer>
    </DashboardItem>
  );
}
