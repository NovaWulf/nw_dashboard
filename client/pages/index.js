import { gql } from '@apollo/client';
import { useUser } from '@auth0/nextjs-auth0';
import Container from '@mui/material/Container';
import Grid from '@mui/material/Grid';
import * as React from 'react';

import { withPageAuthRequired } from '@auth0/nextjs-auth0';
import client from '../apollo-client';
import Layout from '../components/Layout';
import MvrvChart from '../components/MvrvChart';
import MvrvRegressionChart from '../components/MvrvRegressionChart';
import ActiveAddressesChart from '../components/ActiveAddressesChart';
import ActiveAddressRegressionChart from '../components/ActiveAddressRegressionChart';

const Dashboard = ({ mvrv, btc, activeAddresses }) => {
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
          <Grid item sx={{ display: 'flex' }} xs={12} md={6}>
            <ActiveAddressesChart activeAddresses={activeAddresses} btc={btc} />
          </Grid>
          <Grid item sx={{ display: 'flex' }} xs={12} md={6}>
            <ActiveAddressRegressionChart
              activeAddresses={activeAddresses}
              btc={btc}
            />
          </Grid>
        </Grid>
      </Container>
    </Layout>
  );
};

export async function getStaticProps() {
  const { data } = await client.query({
    query: gql`
      query Metrics {
        mvrv {
          ts
          v
        }
        btc {
          ts
          v
        }
        btcActiveAddresses {
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
      activeAddresses: data.btcActiveAddresses,
    },
  };
}

export default withPageAuthRequired(Dashboard);
