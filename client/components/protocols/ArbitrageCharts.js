import { gql, useQuery } from '@apollo/client';
import { Skeleton } from '@mui/material';
import Grid from '@mui/material/Grid';
import * as React from 'react';
import ArbitrageSignalChart from 'components/charts/ArbitrageSignalChart';


const QUERY = gql`
query {
  latestCointegrationModelInfo {
    inSampleMean,
    inSampleSd,
    uuid, 
    id
  }

  arbSignalLatestModel {
    ts
    v
  }
}
`;

export default function ArbitrageCharts() {
  const { data, loading, error } = useQuery(QUERY);
  const {
    latestCointegrationModelInfo,
    arbSignalLatestModel
  } = data || {};
  console.log("in sample mean: " + JSON.stringify(arbSignalLatestModel))

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
          <ArbitrageSignalChart arb_signal={arbSignalLatestModel} mean = {latestCointegrationModelInfo[0].inSampleMean} sd={latestCointegrationModelInfo[0].inSampleSd} />
        )}
      </Grid>
    </Grid>
  );
}
