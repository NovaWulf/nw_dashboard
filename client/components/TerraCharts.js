import { gql, useQuery } from '@apollo/client';
import { Skeleton } from '@mui/material';
import Grid from '@mui/material/Grid';
import * as React from 'react';
import DevActivityChart from './DevActivityChart';
import GithubCommitChart from './GithubCommitChart';
import VolumeChart from './VolumeChart';

const QUERY = gql`
  query Metrics {
    tokenPrice(token: "luna") {
      ts
      v
    }
    activeAddresses(token: "luna") {
      ts
      v
    }
    devActivity(token: "luna") {
      ts
      v
    }
    santimentDevActivity(token: "luna") {
      ts
      v
    }
    volume(token: "luna") {
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

export default function TerraCharts() {
  const { data, loading, error } = useQuery(QUERY);

  if (error) {
    console.error(error);
    return null;
  }

  const {
    tokenPrice,
    activeAddresses,
    devActivity,
    santimentDevActivity,
    volume,
  } = data || {};

  return (
    <Grid container spacing={3}>
      {/* <LoadingGridItem loading={loading}>
        <ActiveAddressesChart
          activeAddresses={activeAddresses}
          price={tokenPrice}
          token="luna"
        />
        
      </LoadingGridItem> */}
      <LoadingGridItem loading={loading}>
        <VolumeChart volume={volume} price={tokenPrice} token="luna" />
      </LoadingGridItem>
      <LoadingGridItem loading={loading}>
        <GithubCommitChart
          devActivity={devActivity}
          price={tokenPrice}
          tokenName="LUNA"
          chainName="Terra"
        />
      </LoadingGridItem>
      <LoadingGridItem loading={loading}>
        <DevActivityChart
          devActivity={santimentDevActivity}
          price={tokenPrice}
          tokenName="LUNA"
          chainName="Terra"
        />
      </LoadingGridItem>
    </Grid>
  );
}
