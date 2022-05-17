import { withPageAuthRequired } from '@auth0/nextjs-auth0';
import CardanoCharts from 'components/protocols/CardanoCharts';
import ChartsLayout from 'components/layouts/ChartsLayout';
import * as React from 'react';
import ClientOnly from 'components/ClientOnly';

const Cardano = () => {
  return (
    <ChartsLayout>
      <ClientOnly>
        <CardanoCharts />
      </ClientOnly>
    </ChartsLayout>
  );
};

export default withPageAuthRequired(Cardano);
