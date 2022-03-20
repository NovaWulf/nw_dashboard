import { withPageAuthRequired } from '@auth0/nextjs-auth0';
import Container from '@mui/material/Container';
import * as React from 'react';
import ActivityCharts from '../components/ActivityCharts';
import ClientOnly from '../components/ClientOnly';
import EthereumCharts from '../components/EthereumCharts';
import Layout from '../components/Layout';

const Ethereum = () => {
  return (
    <Layout>
      <Container maxWidth="lg" sx={{ mt: 4, mb: 4 }}>
        <ClientOnly>
          <EthereumCharts />
        </ClientOnly>
      </Container>
    </Layout>
  );
};

export default withPageAuthRequired(Ethereum);
