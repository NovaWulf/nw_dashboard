// import { handleAuth } from '@auth0/nextjs-auth0';

// export default handleAuth();

// manually doing this instead of using the built in method so we can dynamically redirect based
// on the host, so that this works with Vercel preview urls

const audience = process.env.AUTH0_AUDIENCE;
const scope = process.env.AUTH0_SCOPE;

function getUrls(req) {
  const host = req.headers['host'];
  const protocol = process.env.VERCEL_URL ? 'https' : 'http';
  const redirectUri = `${protocol}://${host}/api/auth/callback`;
  const returnTo = `${protocol}://${host}`;
  return {
    redirectUri,
    returnTo,
  };
}

export default handleAuth({
  async callback(req, res) {
    try {
      const { redirectUri } = getUrls(req);
      await handleCallback(req, res, { redirectUri: redirectUri });
    } catch (error) {
      res.status(error.status || 500).end(error.message);
    }
  },

  async login(req, res) {
    try {
      const { redirectUri, returnTo } = getUrls(req);

      await handleLogin(req, res, {
        authorizationParams: {
          audience: audience,
          scope: scope,
          redirect_uri: redirectUri,
        },
        returnTo: returnTo,
      });
    } catch (error) {
      res.status(error.status || 400).end(error.message);
    }
  },

  async logout(req, res) {
    const { returnTo } = getUrls(req);
    await handleLogout(req, res, {
      returnTo: returnTo,
    });
  },
});
