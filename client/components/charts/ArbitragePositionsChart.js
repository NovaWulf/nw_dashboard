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
import { dateTimeFormatter, nFormatter } from 'lib/formatters';
import DashboardItem from 'components/DashboardItem';
import TimeAxisHighRes from 'components/TimeAxisHighRes';
import CsvDownloadLink from 'components/CsvDownloadLink';

export default function ArbitragePositionsChart({seqNumber,version,basket}) {
  
  const QUERY = gql`
  query ($version: Int!, $seqNumber: Int!, $basket: String!){
    cointegrationModelInfo(version:$version,sequenceNumber:$seqNumber,basket:$basket) {
      id
      modelEndtime
      modelStarttime
    }
    cointegrationModelWeights(version:$version,sequenceNumber:$seqNumber,basket:$basket) {
      id
      weight
      assetName
    }
    backtestPositions(version: $version,sequenceNumber:$seqNumber,basket: $basket) {
      ts
      v
      is
    }
  }
  `;

  const { data, loading, error } = useQuery(QUERY, {
    variables: { seqNumber,version, basket },
  });

  const { cointegrationModelInfo, backtestPositions,cointegrationModelWeights } = data || {};

  if (error) {
    console.error(error);
    return null;
  }
  const theme = useTheme();

  let assets = [];
  let assetNames
  if (data) {
    assetNames = cointegrationModelWeights.map(d => d.assetName)
    const index = assetNames.indexOf("det");
    assetNames.splice(index, 1); 
    for (let i = 0; i < backtestPositions[0].length; i++) {
      assets.push({
        ts: backtestPositions[0][i].ts,
        is: backtestPositions[0][i].is,
        v1: backtestPositions[0][i].v,
        v2: backtestPositions[1][i].v,
      })
    }
  }

  return (
    <Grid item sx={{ display: 'flex' }} xs={12} md={12}>
      {loading ? (
        <Skeleton variant="rectangular" />
      ) : (
        <DashboardItem
          title="Arbitrage Positions"
          helpText="Arbitrage Positions looks at the positions of a given trading strategy over time"
          downloadButton={
            <CsvDownloadLink data={assets} title="Arbitrage Positions" />
          }
        >
          <ResponsiveContainer width="99%" height={300}>
            <LineChart
              data={assets}
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
                dataKey="v1"
                name={assetNames[0]}
                stroke="blue"
                yAxisId="pnl"
                dot={false}
              />
              <Line
                type="monotone"
                dataKey="v2"
                name={assetNames[1]}
                stroke={"orange"}
                yAxisId="pnl"
                dot={false}
              />
              <CartesianGrid stroke="#ccc" strokeDasharray="5 5" />
              {TimeAxisHighRes()}

              <YAxis
                yAxisId="pnl"
                orientation="left"
                tickFormatter={nFormatter}
                stroke={theme.palette.primary.main}
                domain={[-2, 2]}
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
