import React from 'react';
import { Card, CardContent, Typography } from '@mui/material';

const DashboardItem = ({ children, title, subtitle }) => (
  <Card
    style={{
      display: 'flex',
      justifyContent: 'space-between',
      flexDirection: 'column',
      width: '100%',
    }}
  >
    <CardContent>
      {title && (
        <Typography
          component="h2"
          variant="h6"
          color="primary"
          gutterBottom={!subtitle}
        >
          {title}
        </Typography>
      )}
      {subtitle && (
        <Typography component="h3" variant="caption" color="secondary">
          {subtitle}
        </Typography>
      )}
      {children}
    </CardContent>
  </Card>
);

export default DashboardItem;
