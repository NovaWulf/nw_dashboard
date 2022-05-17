import { withPageAuthRequired } from '@auth0/nextjs-auth0';
import ClientOnly from 'components/ClientOnly';
import ChartsLayout from 'components/layouts/ChartsLayout';
import EthereumCharts from 'components/protocols/EthereumCharts';
import * as React from 'react';

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
