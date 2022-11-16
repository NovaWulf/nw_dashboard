import { useTheme } from '@mui/material';
import { useQuery, gql } from '@apollo/client';
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
import { Skeleton } from '@mui/material';
import Grid from '@mui/material/Grid';
import { dateTimeFormatter, percentFormatter } from 'lib/formatters';
import DashboardItem from 'components/DashboardItem';
import TimeAxisHighRes from 'components/TimeAxisHighRes';
import CsvDownloadLink from 'components/CsvDownloadLink';

export default function ArbitrageMetaBacktestChart({seqNumber,version,basket}) {
  const QUERY = gql`
  query ($version: Int!, $seqNumber: Int!, $basket: String!){
    getMetaBreakpoints(version:$version,basket:$basket) {
      id
      modelEndtime
      modelStarttime
    }

    metaBacktestModel(version: $version,basket: $basket) {
      ts
      v
      is
    }
  }
  `;

  const { data, loading, error } = useQuery(QUERY, {
    variables: { seqNumber,version, basket },
  });

  const { getMetaBreakpoints, backtestModel } = data || {};


  if (error) {
    console.error(error);
    return null;
  }
  const theme = useTheme();
  
  let updatedData;
  if (data) {
    updatedData = backtestModel.map(d => {
      return {
        ts: d.ts,
        v: Math.floor(10000 * d.v)/100,
        is: d.is,
      };
    });
  }

  return (
    <Grid item sx={{ display: 'flex' }} xs={12} md={12}>
      {loading ? (
        <Skeleton variant="rectangular" />
      ) : (
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
                x={getMetaBreakpoints[0].modelEndtime}
                stroke="red"
                label="IN-SAMPLE <----------> POST"
              />
              <ReferenceLine
                strokeDasharray="3 3"
                yAxisId="pnl"
                x={getMetaBreakpoints[0].modelStarttime}
                stroke="red"
                label="PRE <----------> IN-SAMPLE"
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

              <Tooltip labelFormatter={dateTimeFormatter} />
              <Legend />
            </LineChart>
          </ResponsiveContainer>
        </DashboardItem>
      )}
    </Grid>
  );
}
