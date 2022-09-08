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

import { dateFormatter, nFormatter } from 'lib/formatters';
import DashboardItem from 'components/DashboardItem';
import TimeAxisHighRes from 'components/TimeAxisHighRes';
import CsvDownloadLink from 'components/CsvDownloadLink';

export default function RatioChart({seqNumber,version,basket}) {
  const QUERY = gql`
  query ($version: Int!, $seqNumber: Int!, $basket: String!) {

    cointegrationModelWeights(version:$version,sequenceNumber:$seqNumber,basket:$basket) {
      id
      weight
      assetName
    }

    dualCandleCharts(version:$version,sequenceNumber:$seqNumber,basket:$basket) {
      ts
      v
    }

  }

  `;
  const { data, loading, error } = useQuery(QUERY, {
    variables: { seqNumber, version, basket},
  });

  const { cointegrationModelWeights, dualCandleCharts } = data || {};
  if (error) {
    console.error(error);
    return null;
  }

  let assets = [];
  let assetNames
    
  if (data) {
    assetNames = cointegrationModelWeights.map(d => d.assetName)
    const index = assetNames.indexOf("det");
    assetNames.splice(index, 1); 
    console.log("dualCandleCharts[0] length: " + dualCandleCharts[0].length +", dualCandleCharts[1]: "+dualCandleCharts[1].length)

    for (let i = 0; i < dualCandleCharts[0].length; i++) {
      assets.push({
        ts: dualCandleCharts[0][i].ts,
        v: dualCandleCharts[0][i].v/dualCandleCharts[1][i].v,
      })
    }

  }

  const theme = useTheme();

  return (
    <Grid item sx={{ display: 'flex' }} xs={12} md={12}>
      {loading ? (
        <Skeleton variant="rectangular" />
      ) : (
        <DashboardItem
          title={`${assetNames[0]}/${assetNames[1]} Ratio Plot`}
          helpText="Ratio plot gives a reference for the prices of the underlying assets"
          downloadButton={
            <CsvDownloadLink data={assets} title="Asset Ratio Chart" />
          }
        >
          <ResponsiveContainer width="99%" height={300}>
            <LineChart
              data={assets}
              margin={{ top: 5, right: 15, bottom: 5, left: 0 }}
            >
            <Line
              type="monotone"
              dataKey="v"
              name={assetNames[1]}
              stroke="green"
              dot={false}
              yAxisId={assetNames[1]}
            />
            
            <CartesianGrid stroke="#ccc" strokeDasharray="5 5" />
            {TimeAxisHighRes()}

            <YAxis yAxisId={assetNames[0]} stroke={theme.palette.secondary.main} />
            <YAxis
              yAxisId={assetNames[1]}
              orientation="left"
              tickFormatter={nFormatter}
              stroke={theme.palette.primary.main}
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
