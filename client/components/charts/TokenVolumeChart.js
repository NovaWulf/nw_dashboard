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
import CsvMultiDownloadLink from 'components/CsvMultiDownloadLink';

export default function TokenVolumeChart({ volume, price, token }) {
  const theme = useTheme();

  const data = mergeTimestamps(volume, price, token);

  return (
    <DashboardItem
      title="Volume"
      helpText="Token Volume"
      downloadButton={
        <CsvMultiDownloadLink
          data={data}
          title1="Volume"
          title2="Price"
          token={token}
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
            name="Volume (tokens)"
            stroke={theme.palette.secondary.main}
            dot={false}
            yAxisId="vol"
          />
          {PriceArea({ token: token, name: `${token.toUpperCase()} Price` })}
          <CartesianGrid stroke="#ccc" strokeDasharray="5 5" />
          {TimeAxis()}

          <YAxis
            yAxisId="vol"
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
