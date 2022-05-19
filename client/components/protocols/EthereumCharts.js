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
import TransactionFeeChart from 'components/charts/TransactionFeeChart';
import VolumeChart from 'components/charts/VolumeChart';
import SmartContractContractsChart from 'components/charts/SmartContractContractsChart';
import SmartContractActiveAddressesChart from 'components/charts/SmartContractActiveAddressesChart';
import LoadingGridItem from 'components/LoadingGridItem';

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
    transactionFees(token: "eth") {
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
    smartContractContracts(token: "eth") {
      ts
      v
    }
    smartContractActiveUsers(token: "eth") {
      ts
      v
    }
  }
`;

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
    transactionFees,
    circSupply,
    mcapDominance,
    smartContractContracts,
    smartContractActiveUsers,
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
        <TransactionFeeChart
          transactionFees={transactionFees}
          price={tokenPrice}
          token="eth"
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
      <LoadingGridItem loading={loading}>
        <SmartContractContractsChart
          smartContractContracts={smartContractContracts}
          price={tokenPrice}
          token="eth"
        />
      </LoadingGridItem>
      <LoadingGridItem loading={loading}>
        <SmartContractActiveAddressesChart
          smartContractActiveUsers={smartContractActiveUsers}
          price={tokenPrice}
          token="eth"
        />
      </LoadingGridItem>
    </Grid>
  );
}
