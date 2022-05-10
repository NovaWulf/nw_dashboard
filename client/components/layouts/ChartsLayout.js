import Timespan from 'components/timespan/Timespan';
import Layout from './Layout';

export default function ChartsLayout({ children }) {
  return (
    <Layout>
      <Timespan />
      {children}
    </Layout>
  );
}
