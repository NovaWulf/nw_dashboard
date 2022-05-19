import { gql, useQuery } from '@apollo/client';
import { Skeleton } from '@mui/material';
import Grid from '@mui/material/Grid';
import * as React from 'react';
import ActiveAddressesChart from 'components/charts/ActiveAddressesChart';
import CircSupplyChart from 'components/charts/CircSupplyChart';
import DevActivityChart from 'components/charts/DevActivityChart';
import GithubCommitChart from 'components/charts/GithubCommitChart';
import McapDominanceChart from 'components/charts/McapDominanceChart';
import VolumeChart from 'components/charts/VolumeChart';
import TransactionFeeChart from 'components/charts/TransactionFeeChart';
import LoadingGridItem from 'components/LoadingGridItem';

const QUERY = gql`
  query Metrics {
    tokenPrice(token: "near") {
      ts
      v
    }
    activeAddresses(token: "near") {
      ts
      v
    }
    volume(token: "near") {
      ts
      v
    }
    transactionFees(token: "near") {
      ts
      v
    }
    devActivity(token: "near") {
      ts
      v
    }
    santimentDevActivity(token: "near") {
      ts
      v
    }
    circSupply(token: "near") {
      ts
      v
    }
    mcapDominance(token: "near") {
      ts
      v
    }
  }
`;

export default function NearCharts() {
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
          token="near"
        />
      </LoadingGridItem> */}
      <LoadingGridItem loading={loading}>
        <VolumeChart volume={volume} price={tokenPrice} token="near" />
      </LoadingGridItem>
      <LoadingGridItem loading={loading}>
        <TransactionFeeChart
          transactionFees={transactionFees}
          price={tokenPrice}
          token="near"
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
          tokenName="NEAR"
          chainName="Near"
        />
      </LoadingGridItem>

      <LoadingGridItem loading={loading}>
        <DevActivityChart
          devActivity={santimentDevActivity}
          price={tokenPrice}
          tokenName="NEAR"
          chainName="Near"
        />
      </LoadingGridItem>
    </Grid>
  );
}
