import { gql, useQuery } from '@apollo/client';
import { Skeleton } from '@mui/material';
import Grid from '@mui/material/Grid';
import * as React from 'react';
import ArbitrageSignalChart from 'components/charts/ArbitrageSignalChart';
import ArbitrageBacktestChart from 'components/charts/ArbitrageBacktestChart';

const QUERY = gql`
  query {
    cointegrationModelInfo(version:1) {
      inSampleMean
      inSampleSd
      uuid
      id
      modelEndtime
    }

    arbSignalLatestModel {
      ts
      v
      is
    }

    backtestLatestModel {
      ts
      v
      is
    }
  }
`;

export default function ArbitrageCharts() {
  const { data, loading, error } = useQuery(QUERY);
  const {
    cointegrationModelInfo,
    arbSignalLatestModel,
    backtestLatestModel,
  } = data || {};
  console.log(
    'cointegrationModelInfo: ' +
      JSON.stringify(cointegrationModelInfo),
  );

  if (error) {
    console.error(error);
    return null;
  }

  return (
    <Grid container spacing={3}>
      <Grid item sx={{ display: 'flex' }} xs={12} md={12}>
        {loading ? (
          <Skeleton variant="rectangular" />
        ) : (
          <ArbitrageSignalChart
            arb_signal={arbSignalLatestModel}
            mean={cointegrationModelInfo[0].inSampleMean}
            sd={cointegrationModelInfo[0].inSampleSd}
            is_end_date={cointegrationModelInfo[0].modelEndtime}
          />
        )}
      </Grid>
      <Grid item sx={{ display: 'flex' }} xs={12} md={12}>
        {loading ? (
          <Skeleton variant="rectangular" />
        ) : (
          <ArbitrageBacktestChart
            pnl={backtestLatestModel}
            is_end_date={cointegrationModelInfo[0].modelEndtime}
          />
        )}
      </Grid>
    </Grid>
  );
}
