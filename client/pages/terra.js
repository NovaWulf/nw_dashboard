import { withPageAuthRequired } from '@auth0/nextjs-auth0';
import ChartsLayout from 'components/layouts/ChartsLayout';
import * as React from 'react';
import ClientOnly from 'components/ClientOnly';
import TerraCharts from 'components/protocols/TerraCharts';

const Terra = () => {
  return (
    <ChartsLayout>
      <ClientOnly>
        <TerraCharts />
      </ClientOnly>
    </ChartsLayout>
  );
};

export default withPageAuthRequired(Terra);
