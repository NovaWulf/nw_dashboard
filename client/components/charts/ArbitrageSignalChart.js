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

export default function ArbitrageSignalChart({ seqNumber }) {
  console.log('seqNumber in signal chart: ' + seqNumber);

  // console.log("seqNumber in signal chart: " + JSON.stringify(seqNumber))
  const QUERY = gql`
    query ($seqNumber: Int) {
      cointegrationModelInfo(version: 1, sequenceNumber: $seqNumber) {
        inSampleMean
        inSampleSd
        uuid
        id
        modelEndtime
      }

      arbSignalModel(version: 1, sequenceNumber: $seqNumber) {
        ts
        v
        is
      }
    }
  `;
  const { data, loading, error } = useQuery(QUERY, {
    variables: { seqNumber },
  });

  const { cointegrationModelInfo, arbSignalModel } = data || {};

  if (error) {
    console.error(error);
    return null;
  }
  const SIGMA = 3;

  let mean, sd, isEndDate, updatedData;
  if (data) {
    mean = cointegrationModelInfo[0].inSampleMean;
    sd = cointegrationModelInfo[0].inSampleSd;
    isEndDate = cointegrationModelInfo[0].modelEndtime;
    updatedData = arbSignalModel.map(d => {
      console.log('sd: ' + Math.floor(100 * (-SIGMA * sd)));
      return {
        ts: d.ts,
        v: Math.floor(100 * (d.v - mean)),
        // is: d.is,
        arbLow: Math.floor(100 * (-SIGMA * sd)),
        arbHigh: Math.floor(100 * (SIGMA * sd)),
        arbMean: Math.floor(0),
      };
    });
  }

  const theme = useTheme();
  console.log('mean: ' + mean + ', sd: ' + sd);

  return (
    <Grid item sx={{ display: 'flex' }} xs={12} md={12}>
      {loading ? (
        <Skeleton variant="rectangular" />
      ) : (
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
      )}
    </Grid>
  );
}
