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
import { dateFormatter, percentFormatter } from 'lib/formatters';
import DashboardItem from 'components/DashboardItem';
import TimeAxisHighRes from 'components/TimeAxisHighRes';
import CsvDownloadLink from 'components/CsvDownloadLink';

export default function ArbitrageBacktestChart({seqNumber}) {

  console.log("seqNumber in backtest: "+seqNumber)

  const QUERY = gql`
  query ($seqNumber: Int){
    cointegrationModelInfo(version:2,sequenceNumber:$seqNumber) {
      inSampleMean
      inSampleSd
      uuid
      id
      modelEndtime
      modelStarttime
    }

    backtestModel(version: 2,sequenceNumber:$seqNumber) {
      ts
      v
      is
    }
  }
  `;

  const { data, loading, error } = useQuery(QUERY, {
    variables: { seqNumber },
  });

  const { cointegrationModelInfo, backtestModel } = data || {};

  if (error) {
    console.error(error);
    return null;
  }
  const theme = useTheme();

  let updatedData;
  if (data) {
    updatedData = backtestModel.map(d => {
      console.log("ts: " + d.ts +", v: " + Math.floor( d.v))

      return {
        ts: d.ts,
        v: Math.floor(100 * d.v),
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
                x={cointegrationModelInfo[0].modelEndtime}
                stroke="red"
                label="IN-SAMPLE <----------> POST"
              />
              <ReferenceLine
                strokeDasharray="3 3"
                yAxisId="pnl"
                x={cointegrationModelInfo[0].modelStarttime}
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

              <Tooltip labelFormatter={dateFormatter} />
              <Legend />
            </LineChart>
          </ResponsiveContainer>
        </DashboardItem>
      )}
    </Grid>
  );
}
