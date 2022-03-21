import { gql, useQuery } from '@apollo/client';
import { Skeleton } from '@mui/material';
import Grid from '@mui/material/Grid';
import * as React from 'react';
import ActiveAddressesChart from './ActiveAddressesChart';
import DevActivityChart from './DevActivityChart';
import VolumeChart from './VolumeChart';

const QUERY = gql`
  query Metrics {
    tokenPrice(token: "near") {
      ts
      v
    }
    activeAddresses(token: "near") {
      ts
      v
    }
    volume(token: "near") {
      ts
      v
    }
    devActivity(token: "near") {
      ts
      v
    }
  }
`;

const LoadingGridItem = ({ loading, children }) => {
  return (
    <Grid item sx={{ display: 'flex' }} xs={12} md={6}>
      {loading ? <Skeleton variant="rectangular" /> : children}
    </Grid>
  );
};

export default function NearCharts() {
  const { data, loading, error } = useQuery(QUERY);

  if (error) {
    console.error(error);
    return null;
  }

  const { tokenPrice, activeAddresses, devActivity, volume } = data || {};

  return (
    <Grid container spacing={3}>
      {/* <LoadingGridItem loading={loading}>
        <ActiveAddressesChart
          activeAddresses={activeAddresses}
          price={tokenPrice}
          token="near"
        />
      </LoadingGridItem> */}
      <LoadingGridItem loading={loading}>
        <VolumeChart volume={volume} price={tokenPrice} token="near" />
      </LoadingGridItem>
      <LoadingGridItem loading={loading}>
        <DevActivityChart
          devActivity={devActivity}
          price={tokenPrice}
          tokenName="NEAR"
          chainName="Near"
        />
      </LoadingGridItem>
    </Grid>
  );
}
