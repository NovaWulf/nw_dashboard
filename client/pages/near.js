import { withPageAuthRequired } from '@auth0/nextjs-auth0';
import ChartsLayout from 'components/layouts/ChartsLayout';
import * as React from 'react';
import ClientOnly from '../components/ClientOnly';
import NearCharts from '../components/protocols/NearCharts';

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
