import { gql, useQuery } from '@apollo/client';
import { Skeleton } from '@mui/material';
import Grid from '@mui/material/Grid';
import * as React from 'react';
import ActiveAddressesChart from 'components/charts/ActiveAddressesChart';


const QUERY = gql`
  query ModeledSignals {
   
    arb_signal {
      ts
      v
    }
  }
`;

const QUERY2 = gql`
  query CointegationModels {
    latestCointegrationModelInfo {
      id,
      uuid,
      inSampleMean, 
      inSampleSd
    }
  }
`;

export default function ArbitrageCharts() {
  const { data, loading, error } = useQuery(QUERY2);

  if (error) {
    console.error(error);
    return null;
  }
  console.error( "data: "  + data)
  const {
    arb_signal,
    latest_cointegration_model_info
  } = data || {};

  return (
    <Grid container spacing={3}>
      <Grid item sx={{ display: 'flex' }} xs={12} md={12}>
        {loading ? (
          <Skeleton variant="rectangular" />
        ) : (
          <ArbitrageSignalChart arb_signal={arb_signal} mean = {latest_cointegration_model.in_sample_mean} sd={latest_cointegration_model.in_sampel_sd} />
        )}
      </Grid>
    </Grid>
  );
}
