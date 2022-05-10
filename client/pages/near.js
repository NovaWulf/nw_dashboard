import { withPageAuthRequired } from '@auth0/nextjs-auth0';
import Container from '@mui/material/Container';
import ChartsLayout from 'components/layouts/ChartsLayout';
import * as React from 'react';
import ClientOnly from '../components/ClientOnly';
import Layout from '../components/layouts/Layout';
import NearCharts from '../components/NearCharts';

const Near = () => {
  return (
    <ChartsLayout>
      <ClientOnly>
        <NearCharts />
      </ClientOnly>
    </ChartsLayout>
  );
};

export default withPageAuthRequired(Near);
