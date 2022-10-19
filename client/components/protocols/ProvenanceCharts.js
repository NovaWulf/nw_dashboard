import { gql, useQuery } from '@apollo/client';
import Grid from '@mui/material/Grid';
import TokenVolumeChart from 'components/charts/TokenVolumeChart';
import LoadingGridItem from 'components/LoadingGridItem';

const QUERY = gql`
  query Metrics {
    tokenPrice(token: "hash") {
      ts
      v
    }
    volume(token: "hash") {
      ts
      v
    }
  }
`;

export default function ProvenanceCharts() {
  const { data, loading, error } = useQuery(QUERY);

  if (error) {
    console.error(error);
    return null;
  }

  const { tokenPrice, volume } = data || {};

  return (
    <Grid container spacing={3}>
      <LoadingGridItem loading={loading}>
        <TokenVolumeChart volume={volume} price={tokenPrice} token="hash" />
      </LoadingGridItem>
    </Grid>
  );
}
