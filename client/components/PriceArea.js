import { useTheme } from '@mui/material';
import { Area } from 'recharts';

export default function PriceArea({name = "BTC Price", token}) {
  const theme = useTheme();

  return (
    <Area
      dataKey={token}
      name={name}
      fill={theme.palette.primary.main}
      stroke={theme.palette.primary.main}
      opacity="50%"
      yAxisId={token}
    />
  );
}
