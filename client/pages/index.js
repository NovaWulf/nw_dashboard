import { gql } from '@apollo/client';
import { useUser } from '@auth0/nextjs-auth0';
import Container from '@mui/material/Container';
import Grid from '@mui/material/Grid';
import * as React from 'react';
import client from '../apollo-client';
import Layout from '../components/Layout';
import MvrvChart from '../components/MvrvChart';
import MvrvRegressionChart from '../components/MvrvRegressionChart';

export default function Dashboard({ mvrv, btc }) {
  const { user, error, isLoading } = useUser();

  return (
    <Layout>
      <Container maxWidth="lg" sx={{ mt: 4, mb: 4 }}>
        <Grid container spacing={3}>
          <Grid item sx={{ display: 'flex' }} xs={12} md={6}>
            <MvrvChart mvrv={mvrv} btc={btc} />
          </Grid>
          <Grid item sx={{ display: 'flex' }} xs={12} md={6}>
            <MvrvRegressionChart mvrv={mvrv} btc={btc} />
          </Grid>
        </Grid>
      </Container>
    </Layout>
  );
}

export async function getStaticProps() {
  const { data } = await client.query({
    query: gql`
      query MvrvMetrics {
        mvrv {
          ts
          v
        }
        btc {
          ts
          v
        }
      }
    `,
  });

  return {
    props: {
      mvrv: data.mvrv,
      btc: data.btc,
    },
  };
}
