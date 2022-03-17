import { useTheme } from '@mui/material';
import { Area } from 'recharts';

export default function BtcArea() {
  const theme = useTheme();

  return (
    <Area
      dataKey="btc"
      name="BTC Price"
      fill={theme.palette.primary.main}
      stroke={theme.palette.primary.main}
      opacity="50%"
      yAxisId="btc"
    />
  );
}
