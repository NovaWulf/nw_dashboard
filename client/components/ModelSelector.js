import React from 'react';
import { useQuery, gql } from '@apollo/client';
import { Box, FormControl, InputLabel, MenuItem, Select } from '@mui/material';
const getModelsQuery = gql`
  query ($version: Int!, $basket: String!) {
    backtestModelInfo(version: $version, basket:$basket) {
      version
      sequenceNumber
    }
  }
`;

const ModelSelector = ({ model, handleChange, basket, version }) => {
  console.log("model in selector: "+ model + ", bsket: "+basket +", version: " + version)
  const { loading, error, data } = useQuery(getModelsQuery, {
    variables: { version, basket },
  });
  if (loading) return <p>Loading Query...</p>;
  if (error) {
    console.log(error);
    return <p>Error in Query...</p>;
  }
  if (data){
    console.log("data: "+JSON.stringify(data))
  }
  const maxSeqNum = data.backtestModelInfo[0].sequenceNumber;
  var modelSequence = [];
  for (let i = 0; i <= maxSeqNum; i++) {
    modelSequence.push(i);
  }
  console.log('maxSeqNum: ' + maxSeqNum);
  return (
    <Box sx={{ width: 120 }}>
      <FormControl fullWidth>
        <InputLabel id="select-model">Model #</InputLabel>
        <Select
          labelId="select-model-label"
          id="select-model-select"
          value={model || 0}
          label="Model #"
          onChange={e => handleChange(e.target.value)}
        >
          {modelSequence.map(model => (
            <MenuItem value={model}>{model}</MenuItem>
          ))}
        </Select>
      </FormControl>
    </Box>
  );
};

export default ModelSelector;
