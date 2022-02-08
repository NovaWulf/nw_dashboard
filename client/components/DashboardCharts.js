import { gql, useQuery } from '@apollo/client';
import { Skeleton } from '@mui/material';
import Grid from '@mui/material/Grid';
import * as React from 'react';
import ActiveAddressesChart from '../components/ActiveAddressesChart';
import ActiveAddressRegressionChart from '../components/ActiveAddressRegressionChart';
import MvrvChart from '../components/MvrvChart';
import MvrvRegressionChart from '../components/MvrvRegressionChart';

const QUERY = gql`
  query Metrics {
    mvrv {
      ts
      v
    }
    btc {
      ts
      v
    }
    btcActiveAddresses {
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

  const { mvrv, btc, btcActiveAddresses: activeAddresses } = data || {};

  return (
    <Grid container spacing={3}>
      <LoadingGridItem loading={loading}>
        <MvrvChart mvrv={mvrv} btc={btc} />
      </LoadingGridItem>

      <LoadingGridItem loading={loading}>
        <MvrvRegressionChart mvrv={mvrv} btc={btc} />
      </LoadingGridItem>

      <LoadingGridItem loading={loading}>
        <ActiveAddressesChart activeAddresses={activeAddresses} btc={btc} />
      </LoadingGridItem>

      <LoadingGridItem loading={loading}>
        <ActiveAddressRegressionChart
          activeAddresses={activeAddresses}
          btc={btc}
        />
      </LoadingGridItem>
    </Grid>
  );
}
