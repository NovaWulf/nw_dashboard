import { useUser } from '@auth0/nextjs-auth0';
import AutoGraphIcon from '@mui/icons-material/AutoGraph';
import CurrencyBitcoinIcon from '@mui/icons-material/CurrencyBitcoin';
import ErrorIcon from '@mui/icons-material/Error';
import MenuIcon from '@mui/icons-material/Menu';
import {
  Button,
  CircularProgress,
  Divider,
  Drawer,
  IconButton,
  List,
  ListItem,
  ListItemIcon,
  ListItemText
} from '@mui/material';
import AppBar from '@mui/material/AppBar';
import Box from '@mui/material/Box';
import CssBaseline from '@mui/material/CssBaseline';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';
import Image from 'next/image';
import * as React from 'react';
import logo from '../images/nw_logo.png';
import Copyright from '../src/Copyright';
import Link from '../src/Link';
import { EthereumIcon } from './icons/EthereumIcon';
import { NearIcon } from './icons/NearIcon';

const drawerWidth = 200;

export default function Layout({ children }) {
  const { user, error, isLoading } = useUser();

  const [mobileOpen, setMobileOpen] = React.useState(false);

  const handleDrawerToggle = () => {
    setMobileOpen(!mobileOpen);
  };

  const drawer = (
    <div>
      <Toolbar />
      <Divider />
      <List>
        <Link href="/">
          <ListItem button key="Bitcoin">
            <ListItemIcon>
              <CurrencyBitcoinIcon />
            </ListItemIcon>
            <ListItemText primary="Bitcoin" />
          </ListItem>
        </Link>
        <Link href="/ethereum">
          <ListItem button key="Ethereum">
            <ListItemIcon>
              <EthereumIcon />
            </ListItemIcon>
            <ListItemText primary="Ethereum" />
          </ListItem>
        </Link>
        <Link href="/near">
          <ListItem button key="Near">
            <ListItemIcon>
              <NearIcon />
            </ListItemIcon>
            <ListItemText primary="Near" />
          </ListItem>
        </Link>
      </List>
    </div>
  );

  return (
    <Box sx={{ display: 'flex' }}>
      <CssBaseline />
      <AppBar
        position="fixed"
        sx={{ zIndex: theme => theme.zIndex.drawer + 1 }}
      >
        <Toolbar>
          <IconButton
            color="inherit"
            aria-label="open drawer"
            edge="start"
            onClick={handleDrawerToggle}
            sx={{ mr: 2, display: { sm: 'none' } }}
          >
            <MenuIcon />
          </IconButton>
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
        component="nav"
        sx={{ width: { sm: drawerWidth }, flexShrink: { sm: 0 } }}
        aria-label="mailbox folders"
      >
        {/* The implementation can be swapped with js to avoid SEO duplication of links. */}
        <Drawer
          // container={container}
          variant="temporary"
          open={mobileOpen}
          onClose={handleDrawerToggle}
          ModalProps={{
            keepMounted: true, // Better open performance on mobile.
          }}
          sx={{
            display: { xs: 'block', sm: 'none' },
            '& .MuiDrawer-paper': {
              boxSizing: 'border-box',
              width: drawerWidth,
            },
          }}
        >
          {drawer}
        </Drawer>
        <Drawer
          variant="permanent"
          sx={{
            display: { xs: 'none', sm: 'block' },
            '& .MuiDrawer-paper': {
              boxSizing: 'border-box',
              width: drawerWidth,
            },
          }}
          open
        >
          {drawer}
        </Drawer>
      </Box>
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
