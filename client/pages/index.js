import { withPageAuthRequired } from '@auth0/nextjs-auth0';
import Container from '@mui/material/Container';
import ChartsLayout from 'components/layouts/ChartsLayout';
import * as React from 'react';
import BitcoinCharts from 'components/protocols/BitcoinCharts';
import ClientOnly from 'components/ClientOnly';

const Dashboard = () => {
  return (
    <ChartsLayout>
      <Container maxWidth="lg" sx={{ mt: 4, mb: 4 }}>
        <ClientOnly>
          <BitcoinCharts />
        </ClientOnly>
      </Container>
    </ChartsLayout>
  );
};

export default withPageAuthRequired(Dashboard);
