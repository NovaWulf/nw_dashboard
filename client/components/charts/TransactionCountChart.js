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
import CsvDownloadLink from 'components/CsvDownloadLink';
import DashboardItem from 'components/DashboardItem';
import PriceArea from 'components/PriceArea';
import TimeAxis from 'components/TimeAxis';

export default function TransactionCountChart({
  transactionCount,
  price,
  token,
}) {
  const theme = useTheme();

  const data = mergeTimestamps(transactionCount, price, token);

  return (
    <DashboardItem
      title="Transaction Counts"
      helpText="Daily Transaction Counts"
      downloadButton={
        <CsvDownloadLink
          data={transactionCount}
          title="Daily Transaction Counts"
        />
      }
    >
      <ResponsiveContainer width="99%" height={300}>
        <ComposedChart
          data={data}
          margin={{ top: 5, right: 15, bottom: 5, left: 10 }}
        >
          <Line
            type="monotone"
            dataKey="v"
            name="Transaction Count"
            stroke={theme.palette.secondary.main}
            dot={false}
            yAxisId="aa"
          />
          {PriceArea({ token: token, name: `${token.toUpperCase()} Price` })}
          <CartesianGrid stroke="#ccc" strokeDasharray="5 5" />
          {TimeAxis()}

          <YAxis
            yAxisId="aa"
            tickFormatter={nFormatter}
            stroke={theme.palette.secondary.main}
          />
          <YAxis
            yAxisId={token}
            orientation="right"
            tickFormatter={nFormatter}
            stroke={theme.palette.primary.main}
          />
          <Tooltip labelFormatter={dateFormatter} formatter={nFormatter} />
          <Legend />
        </ComposedChart>
      </ResponsiveContainer>
    </DashboardItem>
  );
}
