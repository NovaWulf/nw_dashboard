import { gql, useQuery } from '@apollo/client';
import { Skeleton } from '@mui/material';
import Grid from '@mui/material/Grid';
import * as React from 'react';
import ActiveAddressesChart from '../components/ActiveAddressesChart';
import ActiveAddressRegressionChart from '../components/ActiveAddressRegressionChart';
import MvrvChart from '../components/MvrvChart';
import MvrvRegressionChart from '../components/MvrvRegressionChart';
import BtcDevActivityChart from './BtcDevActivityChart';
import EthDevActivityChart from './EthDevActivityChart';

const QUERY = gql`
  query Metrics {
    btcMvrv {
      ts
      v
    }
    btcPrice {
      ts
      v
    }
    ethPrice {
      ts
      v
    }
    btcActiveAddresses {
      ts
      v
    }
    btcDevActivity {
      ts
      v
    }
    ethDevActivity {
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

  const {
    btcMvrv,
    btcPrice,
    ethPrice,
    btcActiveAddresses,
    btcDevActivity,
    ethDevActivity,
  } = data || {};

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
        <BtcDevActivityChart btcDevActivity={btcDevActivity} btc={btcPrice} />
      </LoadingGridItem>
      <LoadingGridItem loading={loading}>
        <EthDevActivityChart ethDevActivity={ethDevActivity} eth={ethPrice} />
      </LoadingGridItem>
    </Grid>
  );
}
