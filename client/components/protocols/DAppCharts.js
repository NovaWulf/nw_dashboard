import { gql, useQuery } from '@apollo/client';
import Grid from '@mui/material/Grid';
import ActiveAddressesChart from 'components/charts/ActiveAddressesChart';
import TransactionCountChart from 'components/charts/TransactionCountChart';
import TransactionFeeChart from 'components/charts/TransactionFeeChart';
import LoadingGridItem from 'components/LoadingGridItem';

const QUERY = gql`
  query Metrics($token: String!) {
    tokenPrice(token: $token) {
      ts
      v
    }
    activeAddresses(token: $token) {
      ts
      v
    }
    transactionCount(token: $token) {
      ts
      v
    }
    transactionFees(token: $token) {
      ts
      v
    }
  }
`;

export default function DAppCharts({ token }) {
  const { data, loading, error } = useQuery(QUERY, { variables: { token } });

  if (error) {
    console.error(error);
    return null;
  }

  const { tokenPrice, activeAddresses, transactionCount, transactionFees } =
    data || {};

  return (
    <Grid container spacing={3}>
      <LoadingGridItem loading={loading}>
        <ActiveAddressesChart
          activeAddresses={activeAddresses}
          price={tokenPrice}
          token={token}
        />
      </LoadingGridItem>
      <LoadingGridItem loading={loading}>
        <TransactionCountChart
          transactionCount={transactionCount}
          price={tokenPrice}
          token={token}
        />
      </LoadingGridItem>
      <LoadingGridItem loading={loading}>
        <TransactionFeeChart
          transactionFees={transactionFees}
          price={tokenPrice}
          token={token}
        />
      </LoadingGridItem>
    </Grid>
  );
}
