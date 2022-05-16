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
    tokenPrice(token: "eth") {
      ts
      v
    }
    activeAddresses(token: "eth") {
      ts
      v
    }
    transactionCount(token: "eth") {
      ts
      v
    }
    devActivity(token: "eth") {
      ts
      v
    }
    santimentDevActivity(token: "eth") {
      ts
      v
    }
    volume(token: "eth") {
      ts
      v
    }
    circSupply(token: "eth") {
      ts
      v
    }
    mcapDominance(token: "eth") {
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
          token="eth"
        />
      </LoadingGridItem>
      <LoadingGridItem loading={loading}>
        <TransactionCountChart
          transactionCount={transactionCount}
          price={tokenPrice}
          token="eth"
        />
      </LoadingGridItem>
      <LoadingGridItem loading={loading}>
        <VolumeChart volume={volume} price={tokenPrice} token="eth" />
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
          tokenName="ETH"
          chainName="Ethereum"
        />
      </LoadingGridItem>
      <LoadingGridItem loading={loading}>
        <DevActivityChart
          devActivity={santimentDevActivity}
          price={tokenPrice}
          tokenName="ETH"
          chainName="Ethereum"
        />
      </LoadingGridItem>
    </Grid>
  );
}
