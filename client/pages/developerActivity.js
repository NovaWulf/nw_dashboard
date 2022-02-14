import { withPageAuthRequired } from '@auth0/nextjs-auth0';
import Container from '@mui/material/Container';
import * as React from 'react';
import ActivityCharts from '../components/ActivityCharts';
import ClientOnly from '../components/ClientOnly';
import Layout from '../components/Layout';

const DeveloperActivity = () => {
  return (
    <Layout>
      <Container maxWidth="lg" sx={{ mt: 4, mb: 4 }}>
        <ClientOnly>
          <ActivityCharts />
        </ClientOnly>
      </Container>
    </Layout>
  );
};

export default withPageAuthRequired(DeveloperActivity);
