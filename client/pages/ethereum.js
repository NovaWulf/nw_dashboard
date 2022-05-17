import { withPageAuthRequired } from '@auth0/nextjs-auth0';
import Container from '@mui/material/Container';
import * as React from 'react';
import ClientOnly from 'components/ClientOnly';
import EthereumCharts from 'components/protocols/EthereumCharts';
import ChartsLayout from 'components/layouts/ChartsLayout';

const Ethereum = () => {
  return (
    <ChartsLayout>
      <ClientOnly>
        <EthereumCharts />
      </ClientOnly>
    </ChartsLayout>
  );
};

export default withPageAuthRequired(Ethereum);
