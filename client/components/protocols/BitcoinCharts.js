import { gql, useQuery } from '@apollo/client';
import { Skeleton } from '@mui/material';
import Grid from '@mui/material/Grid';
import * as React from 'react';
import ActiveAddressesChart from 'components/charts/ActiveAddressesChart';
import CircSupplyChart from 'components/charts/CircSupplyChart';
import DevActivityChart from 'components/charts/DevActivityChart';
import GithubCommitChart from 'components/charts/GithubCommitChart';
import JesseChart from 'components/charts/JesseChart';
import McapDominanceChart from 'components/charts/McapDominanceChart';
import MetcalfeChart from 'components/charts/MetcalfeChart';
import MvrvChart from 'components/charts/MvrvChart';
import RhodlRatioChart from 'components/charts/RhodlRatioChart';
import TransactionCountChart from 'components/charts/TransactionCountChart';
import VolumeChart from 'components/charts/VolumeChart';
import TransactionFeeChart from 'components/charts/TransactionFeeChart';
import LoadingGridItem from 'components/LoadingGridItem';

const QUERY = gql`
  query Metrics {
    btcMvrv {
      ts
      v
    }
    rhodlRatio {
      ts
      v
    }
    btcPrice: tokenPrice(token: "btc") {
      ts
      v
    }
    btcActiveAddresses: activeAddresses(token: "btc") {
      ts
      v
    }
    transactionCount(token: "btc") {
      ts
      v
    }
    btcMarketCap: circMarketCap(token: "btc") {
      ts
      v
    }
    circSupply: circSupply(token: "btc") {
      ts
      v
    }
    volume(token: "btc") {
      ts
      v
    }
    transactionFees(token: "btc") {
      ts
      v
    }
    jesse {
      ts
      v
    }
    btcDevActivity: devActivity(token: "btc") {
      ts
      v
    }
    santimentDevActivity(token: "btc") {
      ts
      v
    }
    mcapDominance(token: "btc") {
      ts
      v
    }
  }
`;

export default function BitcoinCharts() {
  const { data, loading, error } = useQuery(QUERY);

  if (error) {
    console.error(error);
    return null;
  }

  const {
    btcMvrv,
    btcPrice,
    btcActiveAddresses,
    rhodlRatio,
    btcMarketCap,
    jesse,
    volume,
    transactionFees,

    btcDevActivity,
    santimentDevActivity,
    circSupply,
    mcapDominance,
    transactionCount,
  } = data || {};

  return (
    <Grid container spacing={3}>
      <Grid item sx={{ display: 'flex' }} xs={12} md={12}>
        {loading ? (
          <Skeleton variant="rectangular" />
        ) : (
          <JesseChart jesse={jesse} btc={btcPrice} />
        )}
      </Grid>
      <LoadingGridItem loading={loading}>
        <MvrvChart mvrv={btcMvrv} btc={btcPrice} />
      </LoadingGridItem>
      <LoadingGridItem loading={loading}>
        <McapDominanceChart mcapDominance={mcapDominance} />
      </LoadingGridItem>
      <LoadingGridItem loading={loading}>
        <ActiveAddressesChart
          activeAddresses={btcActiveAddresses}
          price={btcPrice}
          token="btc"
        />
      </LoadingGridItem>
      <LoadingGridItem loading={loading}>
        <TransactionCountChart
          transactionCount={transactionCount}
          price={btcPrice}
          token="btc"
        />
      </LoadingGridItem>
      <LoadingGridItem loading={loading}>
        <CircSupplyChart circSupply={circSupply} />
      </LoadingGridItem>

      <LoadingGridItem loading={loading}>
        <VolumeChart volume={volume} price={btcPrice} token="btc" />
      </LoadingGridItem>
      <LoadingGridItem loading={loading}>
        <TransactionFeeChart
          transactionFees={transactionFees}
          price={btcPrice}
          token="btc"
        />
      </LoadingGridItem>

      <LoadingGridItem loading={loading}>
        <RhodlRatioChart rhodlRatio={rhodlRatio} btc={btcPrice} />
      </LoadingGridItem>

      <LoadingGridItem loading={loading}>
        <MetcalfeChart
          activeAddresses={btcActiveAddresses}
          btcMarketCap={btcMarketCap}
        />
      </LoadingGridItem>
      <LoadingGridItem loading={loading}>
        <GithubCommitChart
          devActivity={btcDevActivity}
          price={btcPrice}
          tokenName="BTC"
          chainName="Bitcoin"
        />
      </LoadingGridItem>
      <LoadingGridItem loading={loading}>
        <DevActivityChart
          devActivity={santimentDevActivity}
          price={btcPrice}
          tokenName="BTC"
          chainName="Bitcoin"
        />
      </LoadingGridItem>
    </Grid>
  );
}
