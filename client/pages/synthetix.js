import { withPageAuthRequired } from '@auth0/nextjs-auth0';
import ClientOnly from 'components/ClientOnly';
import ChartsLayout from 'components/layouts/ChartsLayout';
import DAppCharts from 'components/protocols/DAppCharts';

const Synthetix = () => {
  return (
    <ChartsLayout>
      <ClientOnly>
        <DAppCharts token="snx" />
      </ClientOnly>
    </ChartsLayout>
  );
};

export default withPageAuthRequired(Synthetix);
