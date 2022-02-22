import { gql, useQuery } from '@apollo/client';
import { Skeleton } from '@mui/material';
import Grid from '@mui/material/Grid';
import * as React from 'react';
import JesseChart from './JesseChart';

const QUERY = gql`
  query Metrics {
    jesse {
      ts
      v
    }
    btcPrice: tokenPrice(token: "btc") {
      ts
      v
    }
  }
`;

const LoadingGridItem = ({ loading, children }) => {
  return (
    <Grid item sx={{ display: 'flex' }} xs={12} md={12}>
      {loading ? <Skeleton variant="rectangular" /> : children}
    </Grid>
  );
};

export default function JesseCharts() {
  const { data, loading, error } = useQuery(QUERY);

  if (error) {
    console.error(error);
    return null;
  }

  const { jesse, btcPrice } = data || {};

  return (
    <Grid container spacing={3}>
      <LoadingGridItem loading={loading}>
        <JesseChart jesse={jesse} btc={btcPrice} />
      </LoadingGridItem>
    </Grid>
  );
}
