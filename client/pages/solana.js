import { withPageAuthRequired } from '@auth0/nextjs-auth0';
import ChartsLayout from 'components/layouts/ChartsLayout';
import * as React from 'react';
import ClientOnly from 'components/ClientOnly';
import SolanaCharts from 'components/protocols/SolanaCharts';

const Solana = () => {
  return (
    <ChartsLayout>
      <ClientOnly>
        <SolanaCharts />
      </ClientOnly>
    </ChartsLayout>
  );
};

export default withPageAuthRequired(Solana);
