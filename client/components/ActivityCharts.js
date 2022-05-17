import { gql, useQuery } from '@apollo/client';
import { Skeleton } from '@mui/material';
import Grid from '@mui/material/Grid';
import * as React from 'react';
import DevActivityChart from 'components/charts/DevActivityChart';

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
    lunaPrice: tokenPrice(token: "luna") {
      ts
      v
    }
    nearPrice: tokenPrice(token: "near") {
      ts
      v
    }
    avaxPrice: tokenPrice(token: "avax") {
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
    lunaDevActivity: devActivity(token: "luna") {
      ts
      v
    }
    nearDevActivity: devActivity(token: "near") {
      ts
      v
    }
    avaxDevActivity: devActivity(token: "avax") {
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
    lunaPrice,
    nearPrice,
    avaxPrice,
    btcDevActivity,
    ethDevActivity,
    solDevActivity,
    lunaDevActivity,
    nearDevActivity,
    avaxDevActivity,
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
      <LoadingGridItem loading={loading}>
        <DevActivityChart
          devActivity={lunaDevActivity}
          price={lunaPrice}
          tokenName="LUNA"
          chainName="Terra"
        />
      </LoadingGridItem>
      <LoadingGridItem loading={loading}>
        <DevActivityChart
          devActivity={nearDevActivity}
          price={lunaPrice}
          tokenName="NEAR"
          chainName="Near"
        />
      </LoadingGridItem>
      <LoadingGridItem loading={loading}>
        <DevActivityChart
          devActivity={avaxDevActivity}
          price={lunaPrice}
          tokenName="Avax"
          chainName="Avalanche"
        />
      </LoadingGridItem>
    </Grid>
  );
}
