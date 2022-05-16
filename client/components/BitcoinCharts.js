import { gql, useQuery } from '@apollo/client';
import { Skeleton } from '@mui/material';
import Grid from '@mui/material/Grid';
import * as React from 'react';
import ActiveAddressesChart from './ActiveAddressesChart';
import ActiveAddressRegressionChart from './ActiveAddressRegressionChart';
import MvrvChart from './MvrvChart';
import MvrvRegressionChart from './MvrvRegressionChart';
import MetcalfeChart from './MetcalfeChart';
import RhodlRatioChart from './RhodlRatioChart';
import JesseChart from './JesseChart';
import DevActivityChart from './DevActivityChart';
import VolumeChart from './VolumeChart';
import GithubCommitChart from './GithubCommitChart';
import CircMcapChart from './CircSupplyChart';
import CircSupplyChart from './CircSupplyChart';
import McapDominanceChart from './McapDominanceChart';
import TransactionCountChart from './TransactionCountChart';

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
    btcMarketCap: marketCap(token: "btc") {
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

const LoadingGridItem = ({ loading, children }) => {
  return (
    <Grid item sx={{ display: 'flex' }} xs={12} md={6}>
      {loading ? <Skeleton variant="rectangular" /> : children}
    </Grid>
  );
};

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
      {/* 
      <LoadingGridItem loading={loading}>
        <ActiveAddressRegressionChart
          activeAddresses={btcActiveAddresses}
          btc={btcPrice}
        />
      </LoadingGridItem> */}

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
