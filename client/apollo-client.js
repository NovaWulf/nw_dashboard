import { ApolloClient, createHttpLink, InMemoryCache } from '@apollo/client';
import { setContext } from '@apollo/client/link/context';

const httpLink = createHttpLink({
  uri: `${process.env.NEXT_PUBLIC_NOVAWULF_API_URL}/graphql`,
});

const authLink = setContext(async (_, { headers }) => {
  const response = await fetch('/api/token');
  const { accessToken } = await response.json();

  // return the headers to the context so httpLink can read them
  return {
    headers: {
      ...headers,
      Authorization: accessToken ? `Bearer ${accessToken}` : '',
    },
  };
});

const client = new ApolloClient({
  link: authLink.concat(httpLink),
  cache: new InMemoryCache(),
});
export default client;
