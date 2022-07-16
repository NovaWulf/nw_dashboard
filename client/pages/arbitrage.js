import { withPageAuthRequired } from '@auth0/nextjs-auth0';
import ClientOnly from 'components/ClientOnly';
import ChartsLayout2 from 'components/layouts/ChartsLayout2';
import ArbitrageCharts from 'components/protocols/ArbitrageCharts';
import * as React from 'react';

const Arbitrage = () => {
  return (
    <ChartsLayout2>
      <ClientOnly>
        <ArbitrageCharts />
      </ClientOnly>
    </ChartsLayout2>
  );
};

export default withPageAuthRequired(Arbitrage);
