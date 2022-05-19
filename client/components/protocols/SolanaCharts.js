import { gql, useQuery } from '@apollo/client';
import { Skeleton } from '@mui/material';
import Grid from '@mui/material/Grid';
import * as React from 'react';
import ActiveAddressesChart from 'components/charts/ActiveAddressesChart';
import CircSupplyChart from 'components/charts/CircSupplyChart';
import DevActivityChart from 'components/charts/DevActivityChart';
import GithubCommitChart from 'components/charts/GithubCommitChart';
import McapDominanceChart from 'components/charts/McapDominanceChart';
import TransactionCountChart from 'components/charts/TransactionCountChart';
import VolumeChart from 'components/charts/VolumeChart';
import TransactionFeeChart from 'components/charts/TransactionFeeChart';
import LoadingGridItem from 'components/LoadingGridItem';

const QUERY = gql`
  query Metrics {
    tokenPrice(token: "sol") {
      ts
      v
    }
    activeAddresses(token: "sol") {
      ts
      v
    }
    transactionCount(token: "sol") {
      ts
      v
    }
    volume(token: "sol") {
      ts
      v
    }

    transactionFees(token: "sol") {
      ts
      v
    }
    devActivity(token: "sol") {
      ts
      v
    }
    santimentDevActivity(token: "sol") {
      ts
      v
    }
    circSupply(token: "sol") {
      ts
      v
    }
    mcapDominance(token: "sol") {
      ts
      v
    }
  }
`;

export default function SolanaCharts() {
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
    transactionFees,

    circSupply,
    mcapDominance,
  } = data || {};

  return (
    <Grid container spacing={3}>
      <LoadingGridItem loading={loading}>
        <ActiveAddressesChart
          activeAddresses={activeAddresses}
          price={tokenPrice}
          token="sol"
        />
      </LoadingGridItem>
      <LoadingGridItem loading={loading}>
        <TransactionCountChart
          transactionCount={transactionCount}
          price={tokenPrice}
          token="sol"
        />
      </LoadingGridItem>
      <LoadingGridItem loading={loading}>
        <VolumeChart volume={volume} price={tokenPrice} token="sol" />
      </LoadingGridItem>
      <LoadingGridItem loading={loading}>
        <TransactionFeeChart
          transactionFees={transactionFees}
          price={tokenPrice}
          token="sol"
        />
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
          tokenName="SOL"
          chainName="Solana"
        />
      </LoadingGridItem>
      <LoadingGridItem loading={loading}>
        <DevActivityChart
          devActivity={santimentDevActivity}
          price={tokenPrice}
          tokenName="SOL"
          chainName="Solana"
        />
      </LoadingGridItem>
    </Grid>
  );
}
