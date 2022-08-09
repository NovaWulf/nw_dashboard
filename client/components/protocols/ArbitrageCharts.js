import { gql, useQuery } from '@apollo/client';
import { Skeleton } from '@mui/material';
import Grid from '@mui/material/Grid';
import * as React from 'react';
import ArbitrageSignalChart from 'components/charts/ArbitrageSignalChart';
import ArbitrageBacktestChart from 'components/charts/ArbitrageBacktestChart';
import ModelSelector from 'components/ModelSelector'


export default function ArbitrageCharts() {
  const [seqNumber, setSeqNumber] = React.useState('');
  const QUERY = gql`
  query ($seqNumber: Int){

    cointegrationModelInfo(version:1,sequenceNumber:$seqNumber) {
      inSampleMean
      inSampleSd
      uuid
      id
      modelEndtime
    }

    arbSignalModel(version: 1) {
      ts
      v
      is
    }

    backtestModel(version: 1) {
      ts
      v
      is
    }
  }
`;
  const { data, loading, error } = useQuery(QUERY);

  const {
    cointegrationModelInfo,
    arbSignalModel,
    backtestModel,
  } = data || {};
  console.log(
    'cointegrationModelInfo: ' +
      JSON.stringify(cointegrationModelInfo),
  );
  console.log("seqNumber: " + seqNumber)
  // const vals=arbSignalModel.map(x=> x.v)
  // console.log(vals)
  // console.log("real mean: "+( vals.reduce((a,v) => a + v ,0)/vals.length))

  if (error) {
    console.error(error);
    return null;
  }
  
  
  return (
    <Grid container spacing={3}>
      <ModelSelector onChange={e => setSeqNumber(e.target.value)}/>
      <Grid item sx={{ display: 'flex' }} xs={12} md={12}>
        {loading ? (
          <Skeleton variant="rectangular" />
        ) : (
          <ArbitrageSignalChart
            arbSignal={arbSignalModel}
            mean={cointegrationModelInfo[0].inSampleMean}
            sd={cointegrationModelInfo[0].inSampleSd}
            isEndDate={cointegrationModelInfo[0].modelEndtime}
          />
        )}
      </Grid>
      <Grid item sx={{ display: 'flex' }} xs={12} md={12}>
        {loading ? (
          <Skeleton variant="rectangular" />
        ) : (
          <ArbitrageBacktestChart
            pnl={backtestModel}
            isEndDate={cointegrationModelInfo[0].modelEndtime}
          />
        )}
      </Grid>
    </Grid>
  );
}
