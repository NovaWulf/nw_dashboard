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

export default function ArbitrageSignalChart({seqNumber,version,basket}) {
  const QUERY = gql`
  query ($version: Int!,$seqNumber: Int!,$basket:String!){

    cointegrationModelInfo(version:$version,sequenceNumber:$seqNumber,basket:$basket) {
      inSampleMean
      inSampleSd
      uuid
      id
      modelEndtime
      modelStarttime
    }
    cointegrationModelWeights(version:$version,sequenceNumber:$seqNumber,basket:$basket) {
      id
      weight
      assetName
    }
    arbSignalModel(version: $version,sequenceNumber:$seqNumber,basket:$basket) {
      ts
      v
      is
    }
  }
  `;
  const { data, loading, error } = useQuery(QUERY, {
    variables: { seqNumber,version,basket},
  });

  const { cointegrationModelInfo, arbSignalModel, cointegrationModelWeights } = data || {};

  if (error) {
    console.error(error);
    return null;
  }
  const SIGMA = 1;

  let mean, sd, isEndDate,isStartDate, updatedData,assetNames,weights;
  if (data) {
    assetNames = cointegrationModelWeights.map(d => d.assetName)
    weights = cointegrationModelWeights.map(d => d.weight)
    mean = cointegrationModelInfo[0].inSampleMean;
    sd = cointegrationModelInfo[0].inSampleSd;
    isEndDate = cointegrationModelInfo[0].modelEndtime;
    isStartDate = cointegrationModelInfo[0].modelStarttime;
    const arbLength = arbSignalModel.length
    updatedData = arbSignalModel.map(d => {
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

  return (
    <Grid item sx={{ display: 'flex' }} xs={12} md={12}>
      {loading ? (
        <Skeleton variant="rectangular" />
      ) : (
        <DashboardItem
          title={`${basket} Arbitrage Indicator: ${Math.floor(100*weights[0])/100}*log(${assetNames[0]}) + ${Math.floor(100*weights[1])/100}*log(${assetNames[1]})`}
          helpText="Arbitrage Indicator looks at the value of the mean reverting portfolio of assets"
          downloadButton={
            <CsvDownloadLink data={updatedData} title="Arbitrage Indicator:" />
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
               <ReferenceLine
                strokeDasharray="3 3"
                yAxisId="spread"
                x={isStartDate}
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
