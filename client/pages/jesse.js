import { withPageAuthRequired } from '@auth0/nextjs-auth0';
import Container from '@mui/material/Container';
import * as React from 'react';
import JesseCharts from '../components/JesseCharts';
import ClientOnly from '../components/ClientOnly';
import Layout from '../components/Layout';

const DeveloperActivity = () => {
  return (
    <Layout>
      <Container maxWidth="lg" sx={{ mt: 4, mb: 4 }}>
        <ClientOnly>
          <JesseCharts />
        </ClientOnly>
      </Container>
    </Layout>
  );
};

export default withPageAuthRequired(DeveloperActivity);
