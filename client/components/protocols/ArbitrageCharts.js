import { gql, useQuery } from '@apollo/client';
import { Skeleton } from '@mui/material';
import Grid from '@mui/material/Grid';
import * as React from 'react';
import ActiveAddressesChart from 'components/charts/ActiveAddressesChart';


const QUERY = gql`
  query Metrics {
   
    arb_signal {
      ts
      v
    }

    latest_cointegration_model {
      in_sample_mean, 
      in_sample_sd
    }
  }
`;

export default function ArbitrageCharts() {
  const { data, loading, error } = useQuery(QUERY);

  if (error) {
    console.error(error);
    return null;
  }

  const {
    arb_signal,
    latest_cointegration_model
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
