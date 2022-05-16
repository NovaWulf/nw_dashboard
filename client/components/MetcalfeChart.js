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
import { dateFormatter, mergeTimestamps, nFormatter } from '../lib/formatters';
import DashboardItem from './DashboardItem';
import PriceArea from './PriceArea';
import TimeAxis from './TimeAxis';
import CsvDownloadLink from './CsvDownloadLink';

export default function MetcalfeChart({ activeAddresses, btcMarketCap }) {
  const theme = useTheme();

  const activeAddressesSquared = activeAddresses.map(aa => ({
    ...aa,
    v: aa.v * aa.v,
  }));

  const data = mergeTimestamps(activeAddressesSquared, btcMarketCap, 'btc');

  return (
    <DashboardItem
      title="Metcalfe's Law"
      helpText="Daily Active Addresses Squared"
      downloadButton={
        <CsvDownloadLink
          data={activeAddressesSquared}
          title="Active Addresses Squared"
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
            name="Daily Active Addresses Squared"
            stroke={theme.palette.secondary.main}
            dot={false}
            yAxisId="aa"
          />
          {PriceArea({ token: 'btc', name: 'BTC Market Cap' })}
          <CartesianGrid stroke="#ccc" strokeDasharray="5 5" />
          {TimeAxis()}

          <YAxis
            yAxisId="aa"
            tickFormatter={nFormatter}
            stroke={theme.palette.secondary.main}
          />
          <YAxis
            yAxisId="btc"
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
