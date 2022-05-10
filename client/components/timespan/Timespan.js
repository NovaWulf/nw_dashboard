import { Grid, ToggleButton, ToggleButtonGroup } from '@mui/material';
import { TimespanContext } from './TimespanContext';

export default function Timespan() {
  return (
    <TimespanContext.Consumer>
      {({ timespan, setTimespan }) => (
        <Grid container spacing={3} sx={{ pb: 2 }} justifyContent="flex-end">
          <Grid item>
            <ToggleButtonGroup
              color="primary"
              value={timespan}
              exclusive
              onChange={(e, v) => {
                if (v != null) setTimespan(v);
              }}
            >
              <ToggleButton value="5y">5y</ToggleButton>
              <ToggleButton value="1y">1y</ToggleButton>
              <ToggleButton value="3m">3m</ToggleButton>
            </ToggleButtonGroup>
          </Grid>
        </Grid>
      )}
    </TimespanContext.Consumer>
  );
}
