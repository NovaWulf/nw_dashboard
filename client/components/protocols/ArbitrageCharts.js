import { gql, useQuery } from '@apollo/client';
import { Skeleton } from '@mui/material';
import Grid from '@mui/material/Grid';
import * as React from 'react';
import ArbitrageSignalChart from 'components/charts/ArbitrageSignalChart';
import ArbitrageBacktestChart from 'components/charts/ArbitrageBacktestChart';
import ArbitragePositionsChart from 'components/charts/ArbitragePositionsChart';
import PairChart from 'components/charts/PairChart';
import RatioChart from 'components/charts/RatioChart';


import ModelSelector from 'components/ModelSelector';

const getModelsQuery = gql`
query ($version: Int!, $basket: String!) {
  backtestModelInfo(version: $version, basket:$basket) {
    version
    sequenceNumber
  }
}
`;
export default function ArbitrageCharts({basket}) {
  const version = 2

  const [seqNumber, setSeqNumber] = React.useState(0);

  const { loading, error, data } = useQuery(getModelsQuery, {
    variables: { version, basket },
  });

  React.useEffect(() => {
    if(data) {
      setSeqNumber(data.backtestModelInfo[0].sequenceNumber);
    }
  }, [data])

  if (loading) return <p>Loading Query...</p>;
  if (error) {
    console.log(error);
    return <p>Error in Query...</p>;
  }

  
  return (
    <Grid container spacing={3}>
      <Grid item>
        <ModelSelector seqNumber={seqNumber} handleChange={setSeqNumber} basket={basket} version={version} />
      </Grid>
      <PairChart seqNumber={seqNumber} version={version} basket={basket} />
      <RatioChart seqNumber={seqNumber} version={version} basket={basket} />
      <ArbitrageSignalChart seqNumber={seqNumber} version={version} basket={basket} />
      <ArbitrageBacktestChart seqNumber={seqNumber} version={version} basket ={basket} />
      <ArbitragePositionsChart seqNumber={seqNumber} version={version} basket ={basket} />
    </Grid>
  );
}
