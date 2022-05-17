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

export default function SmartContractActiveAddressesChart({
  smartContractActiveUsers,
  price,
  token,
}) {
  const theme = useTheme();

  const data = mergeTimestamps(smartContractActiveUsers, price, token);

  return (
    <DashboardItem
      title="Smart Contracts Active Addresses"
      downloadButton={
        <CsvDownloadLink
          data={smartContractActiveUsers}
          title="Smart Contracts Active Addresses"
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
            name="Addresses"
            stroke={theme.palette.secondary.main}
            dot={false}
            yAxisId="users"
          />
          {PriceArea({ token: token, name: `${token.toUpperCase()} Price` })}
          <CartesianGrid stroke="#ccc" strokeDasharray="5 5" />
          {TimeAxis()}

          <YAxis
            yAxisId="users"
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
