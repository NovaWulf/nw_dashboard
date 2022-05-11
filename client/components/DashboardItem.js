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

const DashboardItem = ({
  children,
  title,
  subtitle,
  helpText,
  downloadButton,
}) => (
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
          <Typography
            component="h2"
            variant="h6"
            color="primary"
            style={{ marginLeft: '2em' }}
          >
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
        {downloadButton && (
          <Box style={{ marginLeft: 'auto', marginRight: '3em' }}>
            {downloadButton}
          </Box>
        )}
      </Box>

      {children}
    </CardContent>
  </Card>
);

export default DashboardItem;
