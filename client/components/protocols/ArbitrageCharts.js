import { gql, useQuery } from '@apollo/client';
import { Skeleton } from '@mui/material';
import Grid from '@mui/material/Grid';
import * as React from 'react';
import ArbitrageSignalChart from 'components/charts/ArbitrageSignalChart';
import ArbitrageBacktestChart from 'components/charts/ArbitrageBacktestChart';
import ModelSelector from 'components/ModelSelector';

export default function ArbitrageCharts() {
  const [model, setModel] = React.useState(0);

  console.log('model: ' + model);
  return (
    <Grid container spacing={3}>
      <ModelSelector model={model} handleChange={setModel} />
      <ArbitrageSignalChart seqNumber={model} />
      <ArbitrageBacktestChart seqNumber={model} />
    </Grid>
  );
}
