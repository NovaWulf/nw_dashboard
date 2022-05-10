import React, { createContext, useState } from 'react';

const TimespanContext = createContext();

function TimespanProvider({ children }) {
  const [timespan, setTimespan] = useState('5y');

  return (
    <TimespanContext.Provider value={{ timespan, setTimespan }}>
      {children}
    </TimespanContext.Provider>
  );
}
export { TimespanContext, TimespanProvider };
