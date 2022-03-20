import { gql, useQuery } from '@apollo/client';
import { Skeleton } from '@mui/material';
import Grid from '@mui/material/Grid';
import * as React from 'react';
import ActiveAddressesChart from './ActiveAddressesChart';
import DevActivityChart from './DevActivityChart';

const QUERY = gql`
  query Metrics {
    tokenPrice(token: "eth") {
      ts
      v
    }
    activeAddresses(token: "eth") {
      ts
      v
    }
    devActivity(token: "eth") {
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

export default function EthereumCharts() {
  const { data, loading, error } = useQuery(QUERY);

  if (error) {
    console.error(error);
    return null;
  }

  const { tokenPrice, activeAddresses, devActivity } =
    data || {};

  return (
    <Grid container spacing={3}>
      <LoadingGridItem loading={loading}>
        <ActiveAddressesChart
          activeAddresses={activeAddresses}
          price={tokenPrice}
          token="eth"
        />
      </LoadingGridItem>
      <LoadingGridItem loading={loading}>
        <DevActivityChart
          devActivity={devActivity}
          price={tokenPrice}
          tokenName="ETH"
          chainName="Ethereum"
        />
      </LoadingGridItem>
    </Grid>
  );
}
