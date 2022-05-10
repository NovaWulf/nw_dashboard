import { withPageAuthRequired } from '@auth0/nextjs-auth0';
import ChartsLayout from 'components/layouts/ChartsLayout';
import * as React from 'react';
import AvalancheCharts from '../components/AvalancheCharts';
import ClientOnly from '../components/ClientOnly';

const Avalanche = () => {
  return (
    <ChartsLayout>
      <ClientOnly>
        <AvalancheCharts />
      </ClientOnly>
    </ChartsLayout>
  );
};

export default withPageAuthRequired(Avalanche);
