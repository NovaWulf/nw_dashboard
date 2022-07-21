import { gql, useQuery } from '@apollo/client';
import { Skeleton } from '@mui/material';
import Grid from '@mui/material/Grid';
import * as React from 'react';
import ArbitrageSignalChart from 'components/charts/ArbitrageSignalChart';
import ArbitrageBacktestChart from 'components/charts/ArbitrageBacktestChart';
import LoadingGridItem from 'components/LoadingGridItem';

const QUERY = gql`
  query {
    latestCointegrationModelInfo {
      inSampleMean
      inSampleSd
      uuid
      id
    }

    arbSignalLatestModel {
      ts
      v
    }

    backtestLatestModel {
      ts
      v
    }
  }
`;

export default function ArbitrageCharts() {
  const { data, loading, error } = useQuery(QUERY);
  const {
    latestCointegrationModelInfo,
    arbSignalLatestModel,
    backtestLatestModel,
  } = data || {};
  console.log(
    'latestCointegrationModelInfo: ' +
      JSON.stringify(latestCointegrationModelInfo),
  );

  if (error) {
    console.error(error);
    return null;
  }

  return (
    <Grid container spacing={3}>
      <LoadingGridItem loading={loading}>
        <ArbitrageSignalChart
          arb_signal={arbSignalLatestModel}
          mean={latestCointegrationModelInfo[0].inSampleMean}
          sd={latestCointegrationModelInfo[0].inSampleSd}
        />
      </LoadingGridItem>
      <LoadingGridItem loading={loading}>
        <ArbitrageBacktestChart pnl={backtestLatestModel} />
      </LoadingGridItem>
    </Grid>
  );
}
