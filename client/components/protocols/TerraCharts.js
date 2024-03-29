import { gql, useQuery } from '@apollo/client';
import { Skeleton } from '@mui/material';
import Grid from '@mui/material/Grid';
import * as React from 'react';
import CircSupplyChart from 'components/charts/CircSupplyChart';
import DevActivityChart from 'components/charts/DevActivityChart';
import GithubCommitChart from 'components/charts/GithubCommitChart';
import McapDominanceChart from 'components/charts/McapDominanceChart';
import VolumeChart from 'components/charts/VolumeChart';
import LoadingGridItem from 'components/LoadingGridItem';

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
    santimentDevActivity(token: "luna") {
      ts
      v
    }
    volume(token: "luna") {
      ts
      v
    }
    circSupply(token: "luna") {
      ts
      v
    }
    mcapDominance(token: "luna") {
      ts
      v
    }
  }
`;

export default function TerraCharts() {
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
    circSupply,
    mcapDominance,
  } = data || {};

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
        <VolumeChart volume={volume} price={tokenPrice} token="luna" />
      </LoadingGridItem>
      <LoadingGridItem loading={loading}>
        <CircSupplyChart circSupply={circSupply} />
      </LoadingGridItem>
      <LoadingGridItem loading={loading}>
        <McapDominanceChart mcapDominance={mcapDominance} />
      </LoadingGridItem>
      <LoadingGridItem loading={loading}>
        <GithubCommitChart
          devActivity={devActivity}
          price={tokenPrice}
          tokenName="LUNA"
          chainName="Terra"
        />
      </LoadingGridItem>
      <LoadingGridItem loading={loading}>
        <DevActivityChart
          devActivity={santimentDevActivity}
          price={tokenPrice}
          tokenName="LUNA"
          chainName="Terra"
        />
      </LoadingGridItem>
    </Grid>
  );
}
