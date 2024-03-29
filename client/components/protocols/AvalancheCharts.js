import { gql, useQuery } from '@apollo/client';
import Grid from '@mui/material/Grid';
import * as React from 'react';
import ActiveAddressesChart from 'components/charts/ActiveAddressesChart';
import CircSupplyChart from 'components/charts/CircSupplyChart';
import DevActivityChart from 'components/charts/DevActivityChart';
import GithubCommitChart from 'components/charts/GithubCommitChart';
import McapDominanceChart from 'components/charts/McapDominanceChart';
import VolumeChart from 'components/charts/VolumeChart';
import TransactionFeeChart from 'components/charts/TransactionFeeChart';
import TransactionCountChart from 'components/charts/TransactionCountChart';
import LoadingGridItem from 'components/LoadingGridItem';

const QUERY = gql`
  query Metrics {
    tokenPrice(token: "avax") {
      ts
      v
    }
    activeAddresses(token: "avax") {
      ts
      v
    }
    devActivity(token: "avax") {
      ts
      v
    }
    santimentDevActivity(token: "avax") {
      ts
      v
    }
    volume(token: "avax") {
      ts
      v
    }
    transactionFees(token: "avax") {
      ts
      v
    }
    circSupply(token: "avax") {
      ts
      v
    }
    mcapDominance(token: "avax") {
      ts
      v
    }

    transactionCount(token: "avax") {
      ts
      v
    }
  }
`;

export default function AvalancheCharts() {
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
      {/* <LoadingGridItem loading={loading}>
        <ActiveAddressesChart
          activeAddresses={activeAddresses}
          price={tokenPrice}
          token="avax"
        />
      </LoadingGridItem> */}
      <LoadingGridItem loading={loading}>
        <TransactionCountChart
          transactionCount={transactionCount}
          price={tokenPrice}
          token="avax"
        />
      </LoadingGridItem>
      <LoadingGridItem loading={loading}>
        <VolumeChart volume={volume} price={tokenPrice} token="avax" />
      </LoadingGridItem>
      <LoadingGridItem loading={loading}>
        <TransactionFeeChart
          transactionFees={transactionFees}
          price={tokenPrice}
          token="avax"
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
          tokenName="AVAX"
          chainName="Avalanche"
        />
      </LoadingGridItem>
      <LoadingGridItem loading={loading}>
        <DevActivityChart
          devActivity={santimentDevActivity}
          price={tokenPrice}
          tokenName="AVAX"
          chainName="Avalanche"
        />
      </LoadingGridItem>
    </Grid>
  );
}
