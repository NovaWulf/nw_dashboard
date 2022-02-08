import { getAccessToken, withApiAuthRequired } from '@auth0/nextjs-auth0';

export default withApiAuthRequired(async function token(req, res) {
  const { accessToken } = await getAccessToken(req, res, {
    audience: 'novawulf',
    scope: 'openid profile email offline_access',
  });
  console.log('access token');
  console.log(accessToken);
  res.status(200).json({ accessToken });
});
