import { withPageAuthRequired } from '@auth0/nextjs-auth0';
import Container from '@mui/material/Container';
import * as React from 'react';
import BitcoinCharts from '../components/BitcoinCharts';
import ClientOnly from '../components/ClientOnly';
import DashboardCharts from '../components/DashboardCharts';
import Layout from '../components/Layout';

const Dashboard = () => {
  return (
    <Layout>
      <Container maxWidth="lg" sx={{ mt: 4, mb: 4 }}>
        <ClientOnly>
          <BitcoinCharts />
        </ClientOnly>
      </Container>
    </Layout>
  );
};

export default withPageAuthRequired(Dashboard);
