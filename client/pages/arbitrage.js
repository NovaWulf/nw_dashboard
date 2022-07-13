import { withPageAuthRequired } from '@auth0/nextjs-auth0';
import ClientOnly from 'components/ClientOnly';
import ChartsLayout from 'components/layouts/ChartsLayout';
import ArbitrageCharts from 'components/protocols/ArbitrageCharts';
import * as React from 'react';

const Arbitrage = () => {
  return (
    <ChartsLayout>
      <ClientOnly>
        <ArbitrageCharts />
      </ClientOnly>
    </ChartsLayout>
  );
};

export default withPageAuthRequired(Arbitrage);
