import { useTheme } from '@mui/material';
import {
  CartesianGrid,
  ComposedChart,
  Legend,
  Line,
  ResponsiveContainer,
  Tooltip,
  YAxis,
} from 'recharts';
import { dateFormatter, mergeTimestamps, nFormatter } from 'lib/formatters';
import DashboardItem from 'components/DashboardItem';
import PriceArea from 'components/PriceArea';
import TimeAxis from 'components/TimeAxis';
import CsvDownloadLink from 'components/CsvDownloadLink';
import DynamicYAxis from 'components/DynamicYAxis';

export default function TvlChart({ tvl, price, token }) {
  const theme = useTheme();

  const data = mergeTimestamps(tvl, price, token);

  return (
    <DashboardItem
      title="Total Value Locked"
      downloadButton={<CsvDownloadLink data={tvl} title="Total Value Locked" />}
    >
      <ResponsiveContainer width="99%" height={300}>
        <ComposedChart
          data={data}
          margin={{ top: 5, right: 15, bottom: 5, left: 10 }}
        >
          <Line
            type="monotone"
            dataKey="v"
            name="Total Value Locked ($)"
            stroke={theme.palette.secondary.main}
            dot={false}
            yAxisId="tvl"
          />
          {PriceArea({ token: token, name: `${token.toUpperCase()} Price` })}
          <CartesianGrid stroke="#ccc" strokeDasharray="5 5" />
          {TimeAxis()}

          {DynamicYAxis({
            yAxisId: 'tvl',
            orientation: 'left',
            tickFormatter: nFormatter,
            stroke: theme.palette.secondary.main,
          })}

          {DynamicYAxis({
            yAxisId: token,
            orientation: 'right',
            tickFormatter: nFormatter,
            stroke: theme.palette.primary.main,
          })}

          <Tooltip labelFormatter={dateFormatter} formatter={nFormatter} />
          <Legend />
        </ComposedChart>
      </ResponsiveContainer>
    </DashboardItem>
  );
}
