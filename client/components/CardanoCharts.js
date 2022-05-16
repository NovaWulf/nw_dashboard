import { gql, useQuery } from '@apollo/client';
import { Skeleton } from '@mui/material';
import Grid from '@mui/material/Grid';
import * as React from 'react';
import ActiveAddressesChart from './ActiveAddressesChart';
import CircSupplyChart from './CircSupplyChart';
import DevActivityChart from './DevActivityChart';
import GithubCommitChart from './GithubCommitChart';
import McapDominanceChart from './McapDominanceChart';
import TransactionCountChart from './TransactionCountChart';
import VolumeChart from './VolumeChart';

const QUERY = gql`
  query Metrics {
    tokenPrice(token: "ada") {
      ts
      v
    }
    activeAddresses(token: "ada") {
      ts
      v
    }
    transactionCount(token: "ada") {
      ts
      v
    }
    devActivity(token: "ada") {
      ts
      v
    }
    santimentDevActivity(token: "ada") {
      ts
      v
    }
    volume(token: "ada") {
      ts
      v
    }
    circSupply(token: "ada") {
      ts
      v
    }
    mcapDominance(token: "ada") {
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

export default function CardanoCharts() {
  const { data, loading, error } = useQuery(QUERY);

  if (error) {
    console.error(error);
    return null;
  }

  const {
    tokenPrice,
    activeAddresses,
    transactionCount,
    devActivity,
    santimentDevActivity,
    volume,
    circSupply,
    mcapDominance,
  } = data || {};

  return (
    <Grid container spacing={3}>
      <LoadingGridItem loading={loading}>
        <ActiveAddressesChart
          activeAddresses={activeAddresses}
          price={tokenPrice}
          token="ada"
        />
      </LoadingGridItem>
      <LoadingGridItem loading={loading}>
        <TransactionCountChart
          transactionCount={transactionCount}
          price={tokenPrice}
          token="ada"
        />
      </LoadingGridItem>
      <LoadingGridItem loading={loading}>
        <VolumeChart volume={volume} price={tokenPrice} token="ada" />
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
          tokenName="AVAX"
          chainName="Cardano"
        />
      </LoadingGridItem>
      <LoadingGridItem loading={loading}>
        <DevActivityChart
          devActivity={santimentDevActivity}
          price={tokenPrice}
          tokenName="AVAX"
          chainName="Cardano"
        />
      </LoadingGridItem>
    </Grid>
  );
}
