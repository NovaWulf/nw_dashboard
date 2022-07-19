import { withPageAuthRequired } from '@auth0/nextjs-auth0';
import ClientOnly from 'components/ClientOnly';
import Layout from 'components/layouts/Layout';
import ArbitrageCharts from 'components/protocols/ArbitrageCharts';
import * as React from 'react';

const Arbitrage = () => {
  return (
    <Layout>
      <ClientOnly>
        <ArbitrageCharts />
      </ClientOnly>
    </Layout>
  );
};

export default withPageAuthRequired(Arbitrage);
