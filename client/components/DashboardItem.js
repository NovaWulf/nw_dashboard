import React from 'react';
import {
  Box,
  Card,
  CardContent,
  IconButton,
  Tooltip,
  Typography,
} from '@mui/material';
import HelpOutlineIcon from '@mui/icons-material/HelpOutline';

const DashboardItem = ({ children, title, subtitle, helpText }) => (
  <Card
    style={{
      display: 'flex',
      justifyContent: 'space-between',
      flexDirection: 'column',
      width: '100%',
    }}
  >
    <CardContent>
      <Box
        style={{
          display: 'flex',
          flexDirection: 'row',
          justifyContent: 'center',
          alignItems: 'center',
        }}
      >
        {title && (
          <Typography component="h2" variant="h6" color="primary">
            {title}
          </Typography>
        )}
        {helpText && (
          <Tooltip title={helpText}>
            <IconButton color="primary">
              <HelpOutlineIcon />
            </IconButton>
          </Tooltip>
        )}
      </Box>

      {children}
    </CardContent>
  </Card>
);

export default DashboardItem;
