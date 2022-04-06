import { gql, useQuery } from '@apollo/client';
import { Skeleton } from '@mui/material';
import Grid from '@mui/material/Grid';
import * as React from 'react';
import ActiveAddressesChart from './ActiveAddressesChart';
import DevActivityChart from './DevActivityChart';
import GithubCommitChart from './GithubCommitChart';
import VolumeChart from './VolumeChart';

const QUERY = gql`
  query Metrics {
    tokenPrice(token: "avax") {
      ts
      v
    }
    activeAddresses(token: "avax") {
      ts
      v
    }
    devActivity(token: "avax") {
      ts
      v
    }
    santimentDevActivity(token: "avax") {
      ts
      v
    }
    volume(token: "avax") {
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

export default function AvalancheCharts() {
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
          token="avax"
        />
      </LoadingGridItem> */}
      <LoadingGridItem loading={loading}>
        <VolumeChart volume={volume} price={tokenPrice} token="avax" />
      </LoadingGridItem>
      <LoadingGridItem loading={loading}>
        <GithubCommitChart
          devActivity={devActivity}
          price={tokenPrice}
          tokenName="AVAX"
          chainName="Avalanche"
        />
      </LoadingGridItem>
      <LoadingGridItem loading={loading}>
        <DevActivityChart
          devActivity={santimentDevActivity}
          price={tokenPrice}
          tokenName="AVAX"
          chainName="Avalanche"
        />
      </LoadingGridItem>
    </Grid>
  );
}
