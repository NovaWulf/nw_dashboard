import { withPageAuthRequired } from '@auth0/nextjs-auth0';
import Container from '@mui/material/Container';
import * as React from 'react';
import JesseCharts from '../components/JesseCharts';
import ClientOnly from '../components/ClientOnly';
import Layout from '../components/layouts/Layout';

const DeveloperActivity = () => {
  return (
    <Layout>
      <ClientOnly>
        <JesseCharts />
      </ClientOnly>
    </Layout>
  );
};

export default withPageAuthRequired(DeveloperActivity);
