import { withPageAuthRequired } from '@auth0/nextjs-auth0';
import Container from '@mui/material/Container';
import * as React from 'react';
import AvalancheCharts from '../components/AvalancheCharts';
import ClientOnly from '../components/ClientOnly';
import Layout from '../components/Layout';
import TerraCharts from '../components/TerraCharts';

const Terra = () => {
  return (
    <Layout>
      <Container maxWidth="lg" sx={{ mt: 4, mb: 4 }}>
        <ClientOnly>
          <TerraCharts />
        </ClientOnly>
      </Container>
    </Layout>
  );
};

export default withPageAuthRequired(Terra);
