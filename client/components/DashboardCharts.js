import { gql, useQuery } from '@apollo/client';
import { Skeleton } from '@mui/material';
import Grid from '@mui/material/Grid';
import * as React from 'react';
import ActiveAddressesChart from '../components/ActiveAddressesChart';
import ActiveAddressRegressionChart from '../components/ActiveAddressRegressionChart';
import MvrvChart from '../components/MvrvChart';
import MvrvRegressionChart from '../components/MvrvRegressionChart';
import RhodlRatioChart from './RhodlRatioChart';

const QUERY = gql`
  query Metrics {
    btcMvrv {
      ts
      v
    }
    rhodlRatio {
      ts
      v
    }
    btcPrice: tokenPrice(token: "btc") {
      ts
      v
    }
    btcActiveAddresses: activeAddresses(token: "btc") {
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

export default function DashboardCharts() {
  const { data, loading, error } = useQuery(QUERY);

  if (error) {
    console.error(error);
    return null;
  }

  const { btcMvrv, btcPrice, btcActiveAddresses, rhodlRatio } = data || {};

  return (
    <Grid container spacing={3}>
      <LoadingGridItem loading={loading}>
        <MvrvChart mvrv={btcMvrv} btc={btcPrice} />
      </LoadingGridItem>

      <LoadingGridItem loading={loading}>
        <MvrvRegressionChart mvrv={btcMvrv} btc={btcPrice} />
      </LoadingGridItem>

      <LoadingGridItem loading={loading}>
        <ActiveAddressesChart
          activeAddresses={btcActiveAddresses}
          btc={btcPrice}
        />
      </LoadingGridItem>

      <LoadingGridItem loading={loading}>
        <ActiveAddressRegressionChart
          activeAddresses={btcActiveAddresses}
          btc={btcPrice}
        />
      </LoadingGridItem>

      <LoadingGridItem loading={loading}>
        <RhodlRatioChart rhodlRatio={rhodlRatio} btc={btcPrice} />
      </LoadingGridItem>
    </Grid>
  );
}
