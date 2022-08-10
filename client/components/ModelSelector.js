import React from 'react';
import { useQuery, gql } from '@apollo/client'
import { Box, FormControl, InputLabel, MenuItem, Select } from '@mui/material';

const getModelsQuery = gql`
  query {
        backtestModelInfo(version:1) {
            version
            sequenceNumber
        }
    }
`;

    const { loading, error, data } = useQuery(getModelsQuery);
    if (loading) return <p>Loading Query...</p>;
    if (error){
      console.log(error)
      return <p>Error in Query...</p>;
    } 
    const maxSeqNum=data.backtestModelInfo[0].sequenceNumber
    var modelSequence = []
    for (let i = 0; i <= maxSeqNum; i++) {
      modelSequence.push(i)
    }    
    console.log("maxSeqNum: "+maxSeqNum)
        return(
        );
}
const ModelSelector = ({ model, handleChange }) => {
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

export default ModelSelector;
