import * as React from 'react';

import { withPageAuthRequired } from '@auth0/nextjs-auth0';
import ClientOnly from 'components/ClientOnly';
import Layout from 'components/layouts/Layout';
import ArbitrageCharts from 'components/protocols/ArbitrageCharts';

const UNIETHArbitrage = () => {
  return (
    <Layout>
      <ClientOnly>
        <ArbitrageCharts basket={"UNI_ETH"} />
      </ClientOnly>
    </Layout>
  );
};

export default withPageAuthRequired(UNIETHArbitrage);
