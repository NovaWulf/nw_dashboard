import { gql, useQuery } from '@apollo/client';
import { Skeleton } from '@mui/material';
import Grid from '@mui/material/Grid';
import * as React from 'react';
import DevActivityChart from './DevActivityChart';

const QUERY = gql`
  query Metrics {
    btcPrice: tokenPrice(token: "btc") {
      ts
      v
    }
    ethPrice: tokenPrice(token: "eth") {
      ts
      v
    }
    solPrice: tokenPrice(token: "sol") {
      ts
      v
    }

    btcDevActivity: devActivity(token: "btc") {
      ts
      v
    }
    ethDevActivity: devActivity(token: "eth") {
      ts
      v
    }
    solDevActivity: devActivity(token: "sol") {
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

export default function ActivityCharts() {
  const { data, loading, error } = useQuery(QUERY);

  if (error) {
    console.error(error);
    return null;
  }

  const {
    btcPrice,
    ethPrice,
    solPrice,
    btcDevActivity,
    ethDevActivity,
    solDevActivity,
  } = data || {};

  return (
    <Grid container spacing={3}>
      <LoadingGridItem loading={loading}>
        <DevActivityChart
          devActivity={btcDevActivity}
          price={btcPrice}
          tokenName="BTC"
          chainName="Bitcoin"
        />
      </LoadingGridItem>
      <LoadingGridItem loading={loading}>
        <DevActivityChart
          devActivity={ethDevActivity}
          price={ethPrice}
          tokenName="ETH"
          chainName="Ethereum"
        />
      </LoadingGridItem>
      <LoadingGridItem loading={loading}>
        <DevActivityChart
          devActivity={solDevActivity}
          price={solPrice}
          tokenName="SOL"
          chainName="Solana"
        />
      </LoadingGridItem>
    </Grid>
  );
}
