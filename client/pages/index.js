import { useUser } from '@auth0/nextjs-auth0';
import { Button, CircularProgress } from '@mui/material';
import AppBar from '@mui/material/AppBar';
import Box from '@mui/material/Box';
import Container from '@mui/material/Container';
import CssBaseline from '@mui/material/CssBaseline';
import Grid from '@mui/material/Grid';
import { createTheme, ThemeProvider } from '@mui/material/styles';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';
import * as React from 'react';
import Copyright from '../src/Copyright';
import Link from '../src/Link';
import ErrorIcon from '@mui/icons-material/Error';

const mdTheme = createTheme();

function DashboardContent() {
  const { user, error, isLoading } = useUser();

  return (
    <ThemeProvider theme={mdTheme}>
      <Box sx={{ display: 'flex' }}>
        <CssBaseline />
        <AppBar position="absolute">
          <Toolbar>
            <Typography
              component="h1"
              variant="h6"
              color="inherit"
              noWrap
              sx={{ flexGrow: 1 }}
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
          <Container maxWidth="lg" sx={{ mt: 4, mb: 4 }}>
            <Grid container spacing={3}></Grid>
            <Copyright sx={{ pt: 4 }} />
          </Container>
        </Box>
      </Box>
    </ThemeProvider>
  );
}

export default function Dashboard() {
  return <DashboardContent />;
}
