import { gql, useQuery } from '@apollo/client';
import { Skeleton } from '@mui/material';
import Grid from '@mui/material/Grid';
import * as React from 'react';
import ArbitrageSignalChart from 'components/charts/ArbitrageSignalChart';
import ArbitrageBacktestChart from 'components/charts/ArbitrageBacktestChart';
import ModelSelector from 'components/ModelSelector';

export default function ArbitrageCharts({basket}) {
  const [seqNumber, setSeqNumber] = React.useState(0);
  const version = 2
  return (
    <Grid container spacing={3}>
      <Grid item>
        <ModelSelector seqNumber={seqNumber} handleChange={setSeqNumber} basket={basket} version={version} />
      </Grid>
      <ArbitrageSignalChart seqNumber={seqNumber} version={version} basket={basket} />
      <ArbitrageBacktestChart seqNumber={seqNumber} version={version} basket ={basket} />
    </Grid>
  );
}
