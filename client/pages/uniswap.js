import { withPageAuthRequired } from '@auth0/nextjs-auth0';
import ClientOnly from 'components/ClientOnly';
import ChartsLayout from 'components/layouts/ChartsLayout';
import DAppCharts from 'components/protocols/DAppCharts';

const Aave = () => {
  return (
    <ChartsLayout>
      <ClientOnly>
        <DAppCharts token="uni" />
      </ClientOnly>
    </ChartsLayout>
  );
};

export default withPageAuthRequired(Aave);
