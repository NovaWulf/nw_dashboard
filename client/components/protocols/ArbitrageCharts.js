import { gql, useQuery } from '@apollo/client';
import { Skeleton } from '@mui/material';
import Grid from '@mui/material/Grid';
import * as React from 'react';
import ArbitrageSignalChart from 'components/charts/ArbitrageSignalChart';
import ArbitrageBacktestChart from 'components/charts/ArbitrageBacktestChart';
import ModelSelector from 'components/ModelSelector';

export default function ArbitrageCharts({basket}) {
  const [model, setModel] = React.useState(0);
  const version = 2
  console.log('model: ' + model);
  console.log("basket in frontend: " + basket)
  return (
    <Grid container spacing={3}>
      <Grid item>
        <ModelSelector model={model} handleChange={setModel} basket={basket} version={version} />
      </Grid>
      <ArbitrageSignalChart seqNumber={model} version={version} basket={basket} />
      <ArbitrageBacktestChart seqNumber={model} version={version} basket ={basket} />
    </Grid>
  );
}
