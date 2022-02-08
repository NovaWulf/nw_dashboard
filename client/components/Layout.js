import { useUser } from '@auth0/nextjs-auth0';
import ErrorIcon from '@mui/icons-material/Error';
import { Button, CircularProgress } from '@mui/material';
import AppBar from '@mui/material/AppBar';
import Box from '@mui/material/Box';
import CssBaseline from '@mui/material/CssBaseline';
import { createTheme, ThemeProvider } from '@mui/material/styles';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';
import logo from '../images/nw_logo.png';

import * as React from 'react';
import Image from 'next/image';
import Copyright from '../src/Copyright';

export default function Layout({ children }) {
  const { user, error, isLoading } = useUser();

  return (
    <Box sx={{ display: 'flex' }}>
      <CssBaseline />
      <AppBar position="absolute">
        <Toolbar>
          <Image src={logo} width="29" height="33" />
          <Typography
            component="h1"
            variant="h6"
            color="inherit"
            noWrap
            sx={{ flexGrow: 1, marginLeft: 2 }}
          >
            Dashboard
          </Typography>

          {user && (
            <Button color="inherit" href="/api/auth/logout">
              Logout
            </Button>
          )}
          {isLoading && <CircularProgress />}
          {error && <ErrorIcon />}
          {!user && (
            <Button color="inherit" href="/api/auth/login">
              Login
            </Button>
          )}
        </Toolbar>
      </AppBar>

      <Box
        component="main"
        sx={{
          backgroundColor: theme =>
            theme.palette.mode === 'light'
              ? theme.palette.grey[100]
              : theme.palette.grey[900],
          flexGrow: 1,
          height: '100vh',
          overflow: 'auto',
        }}
      >
        <Toolbar />
        {children}
        <Copyright sx={{ pt: 4 }} />
      </Box>
    </Box>
  );
}
