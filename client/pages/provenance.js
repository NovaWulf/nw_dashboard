import { withPageAuthRequired } from '@auth0/nextjs-auth0';
import ChartsLayout from 'components/layouts/ChartsLayout';
import * as React from 'react';
import ProvenanceCharts from 'components/protocols/ProvenanceCharts';
import ClientOnly from 'components/ClientOnly';

const Provenance = () => {
  return (
    <ChartsLayout>
      <ClientOnly>
        <ProvenanceCharts />
      </ClientOnly>
    </ChartsLayout>
  );
};

export default withPageAuthRequired(Provenance);
