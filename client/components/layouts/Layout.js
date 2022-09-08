import { useUser } from '@auth0/nextjs-auth0';
import CurrencyBitcoinIcon from '@mui/icons-material/CurrencyBitcoin';
import ErrorIcon from '@mui/icons-material/Error';
import MenuIcon from '@mui/icons-material/Menu';
import {
  Button,
  CircularProgress,
  Container,
  Divider,
  Drawer,
  IconButton,
  List,
  ListItem,
  ListItemIcon,
  ListItemText,
  ListSubheader,
} from '@mui/material';
import AppBar from '@mui/material/AppBar';
import Box from '@mui/material/Box';
import CssBaseline from '@mui/material/CssBaseline';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';
import Image from 'next/image';
import { useRouter } from 'next/router';
import * as React from 'react';
import logo from 'images/nw_logo.png';
import Copyright from 'src/Copyright';
import Link from 'src/Link';
import { AvalancheIcon } from 'components/icons/AvalancheIcon';
import { EthereumIcon } from 'components/icons/EthereumIcon';
import { NearIcon } from 'components/icons/NearIcon';
import { SolanaIcon } from 'components/icons/SolanaIcon';
import { TerraIcon } from 'components/icons/TerraIcon';
import { CardanoIcon } from 'components/icons/CardanoIcon';
import { AaveIcon } from 'components/icons/AaveIcon';
import { CurveIcon } from 'components/icons/CurveIcon';
import { UniswapIcon } from 'components/icons/UniswapIcon';
import { SynthetixIcon } from 'components/icons/SynthetixIcon';

const drawerWidth = 200;

export default function Layout({ children }) {
  const { user, error, isLoading } = useUser();

  const [mobileOpen, setMobileOpen] = React.useState(false);

  const handleDrawerToggle = () => {
    setMobileOpen(!mobileOpen);
  };

  const router = useRouter();

  const drawer = (
    <div>
      <Toolbar />
      <Divider />
      <List>
        <ListSubheader>Layer 1s</ListSubheader>
        <Link href="/">
          <ListItem button selected={router.pathname == '/'} key="Bitcoin">
            <ListItemIcon>
              <CurrencyBitcoinIcon />
            </ListItemIcon>
            <ListItemText primary="Bitcoin" />
          </ListItem>
        </Link>
        <Link href="/ethereum">
          <ListItem
            button
            selected={router.pathname == '/ethereum'}
            key="Ethereum"
          >
            <ListItemIcon>
              <EthereumIcon />
            </ListItemIcon>
            <ListItemText primary="Ethereum" />
          </ListItem>
        </Link>
        <Link href="/near">
          <ListItem button selected={router.pathname == '/near'} key="Near">
            <ListItemIcon>
              <NearIcon />
            </ListItemIcon>
            <ListItemText primary="Near" />
          </ListItem>
        </Link>
        <Link href="/solana">
          <ListItem button selected={router.pathname == '/solana'} key="Solana">
            <ListItemIcon>
              <SolanaIcon />
            </ListItemIcon>
            <ListItemText primary="Solana" />
          </ListItem>
        </Link>
        <Link href="/avalanche">
          <ListItem
            button
            selected={router.pathname == '/avalanche'}
            key="Avalanche"
          >
            <ListItemIcon>
              <AvalancheIcon />
            </ListItemIcon>
            <ListItemText primary="Avalanche" />
          </ListItem>
        </Link>
        <Link href="/terra">
          <ListItem button selected={router.pathname == '/terra'} key="Terra">
            <ListItemIcon>
              <TerraIcon />
            </ListItemIcon>
            <ListItemText primary="Terra" />
          </ListItem>
        </Link>
        <Link href="/cardano">
          <ListItem
            button
            selected={router.pathname == '/cardano'}
            key="Cardano"
          >
            <ListItemIcon>
              <CardanoIcon />
            </ListItemIcon>
            <ListItemText primary="Cardano" />
          </ListItem>
        </Link>
      </List>
      <Divider />
      <List>
        <ListSubheader>Ethereum dApps</ListSubheader>

        <Link href="/uniswap">
          <ListItem
            button
            selected={router.pathname == '/uniswap'}
            key="Uniswap"
          >
            <ListItemIcon>
              <UniswapIcon />
            </ListItemIcon>
            <ListItemText primary="Uniswap" />
          </ListItem>
        </Link>
        <Link href="/curve">
          <ListItem button selected={router.pathname == '/curve'} key="Curve">
            <ListItemIcon>
              <CurveIcon />
            </ListItemIcon>
            <ListItemText primary="Curve" />
          </ListItem>
        </Link>
        <Link href="/aave">
          <ListItem button selected={router.pathname == '/aave'} key="Aave">
            <ListItemIcon>
              <AaveIcon />
            </ListItemIcon>
            <ListItemText primary="Aave" />
          </ListItem>
        </Link>
        <Link href="/synthetix">
          <ListItem button selected={router.pathname == '/aave'} key="Aave">
            <ListItemIcon>
              <SynthetixIcon />
            </ListItemIcon>
            <ListItemText primary="Synthetix" />
          </ListItem>
        </Link>
        <ListSubheader>Mean-Reverting Signals</ListSubheader>
        <Link href="/op_eth_arbitrage">
          <ListItem
            button
            selected={router.pathname == '/op_eth_arbitrage'}
            key="OPETHArbitrage"
          >
            <ListItemIcon>
              <EthereumIcon />
            </ListItemIcon>
            <ListItemText primary="OP-ETH" />
          </ListItem>
        </Link>
        <Link href="/uni_eth_arbitrage">
          <ListItem
            button
            selected={router.pathname == '/uni_eth_arbitrage'}
            key="UNIETHArbitrage"
          >
            <ListItemIcon>
              <EthereumIcon />
            </ListItemIcon>
            <ListItemText primary="UNI-ETH" />
          </ListItem>
        </Link>
        <Link href="/btc_eth_arbitrage">
          <ListItem
            button
            selected={router.pathname == '/btc_eth_arbitrage'}
            key="BTCETHArbitrage"
          >
            <ListItemIcon>
              <EthereumIcon />
            </ListItemIcon>
            <ListItemText primary="BTC-ETH" />
          </ListItem>
        </Link>
        <Link href="/snx_eth_arbitrage">
          <ListItem
            button
            selected={router.pathname == '/snx_eth_arbitrage'}
            key="SNXETHArbitrage"
          >
            <ListItemIcon>
              <EthereumIcon />
            </ListItemIcon>
            <ListItemText primary="SNX-ETH" />
          </ListItem>
        </Link>
        <Link href="/crv_eth_arbitrage">
          <ListItem
            button
            selected={router.pathname == '/crv_eth_arbitrage'}
            key="CRVETHArbitrage"
          >
            <ListItemIcon>
              <EthereumIcon />
            </ListItemIcon>
            <ListItemText primary="CRV-ETH" />
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
        <Container maxWidth="lg" sx={{ mt: 4, mb: 4 }}>
          {children}
        </Container>
        <Copyright sx={{ pt: 4 }} />
      </Box>
    </Box>
  );
}
