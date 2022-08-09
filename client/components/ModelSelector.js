import React from 'react';
import { useQuery, gql } from '@apollo/client'

const getModelsQuery = gql`
  query {
        backtestModelInfo(version:1) {
            version
            sequenceNumber
        }
    }
`;

const  SelectModel = ({model,handleChange}) => {
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
            <form id="select-model">
                <div className="field">
                    <label>Model#:</label>
                    <select id="models" value={model} onChange={handleChange}>
                        <option>Select model</option>
                        {modelSequence.map(model => <option key={ model } value={ model }>{  model  }</option> 
                )}
                    </select>
                </div>
            </form>
        );
}

export default SelectModel
