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
import { dateFormatter, epochFormatter, nFormatter } from 'lib/formatters';
import DashboardItem from 'components/DashboardItem';
import TimeAxis from 'components/TimeAxis';
import CsvDownloadLink from 'components/CsvDownloadLink';

export default function FullyDilutedMarketCapChart({ marketCap }) {
  const theme = useTheme();

  return (
    <DashboardItem
      title={`Fully Diluted Market Cap`}
      downloadButton={
        <CsvDownloadLink data={marketCap} title="Fully Diluted Market Cap" />
      }
    >
      <ResponsiveContainer width="99%" height={300}>
        <AreaChart
          data={marketCap}
          margin={{ top: 5, right: 15, bottom: 5, left: 10 }}
        >
          <Area
            dataKey="v"
            name="Fully Diluted Market Cap"
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
