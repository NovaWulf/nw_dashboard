import { gql, useQuery } from '@apollo/client';
import { Skeleton } from '@mui/material';
import Grid from '@mui/material/Grid';
import * as React from 'react';
import ActiveAddressesChart from './ActiveAddressesChart';
import DevActivityChart from './DevActivityChart';

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

  const { tokenPrice, activeAddresses, devActivity } =
    data || {};

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
        <DevActivityChart
          devActivity={devActivity}
          price={tokenPrice}
          tokenName="LUNA"
          chainName="Terra"
        />
      </LoadingGridItem>
    </Grid>
  );
}
