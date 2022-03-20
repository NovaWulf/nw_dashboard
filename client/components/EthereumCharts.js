import { gql, useQuery } from '@apollo/client';
import { Skeleton } from '@mui/material';
import Grid from '@mui/material/Grid';
import * as React from 'react';
import ActiveAddressesChart from './ActiveAddressesChart';
import ActiveAddressRegressionChart from './ActiveAddressRegressionChart';
import MvrvChart from './MvrvChart';
import MvrvRegressionChart from './MvrvRegressionChart';
import MetcalfeChart from './MetcalfeChart';
import RhodlRatioChart from './RhodlRatioChart';
import JesseChart from './JesseChart';
import DevActivityChart from './DevActivityChart';

const QUERY = gql`
  query Metrics {
    
    ethPrice: tokenPrice(token: "eth") {
      ts
      v
    }
    ethActiveAddresses: activeAddresses(token: "eth") {
      ts
      v
    }
    ethMarketCap: marketCap(token: "eth") {
      ts
      v
    }
    ethDevActivity: devActivity(token: "eth") {
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

  const {
    ethPrice,
    ethActiveAddresses,
    ethMarketCap,
    ethDevActivity,
  } = data || {};

  return (
    <Grid container spacing={3}>
   

      <LoadingGridItem loading={loading}>
        <ActiveAddressesChart
          activeAddresses={ethActiveAddresses}
          price={ethPrice}
          token="eth"
        />
      </LoadingGridItem>

      {/* <LoadingGridItem loading={loading}>
        <MetcalfeChart
          activeAddresses={btcActiveAddresses}
          btcMarketCap={btcMarketCap}
        />
      </LoadingGridItem> */}
      <LoadingGridItem loading={loading}>
        <DevActivityChart
          devActivity={ethDevActivity}
          price={ethPrice}
          tokenName="ETH"
          chainName="Ethereum"
        />
      </LoadingGridItem>
    </Grid>
  );
}
