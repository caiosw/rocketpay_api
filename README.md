# Rocketpay

This is a Payments API made with Elixir for Rocketseat's Next Level Week 4 bootcamp.

This project covered come features like:
- Elixir, Phoenix and Ecto
- Handling DB tables and transactions with Ecto.Multi
- Creating Routes with Phoenix
- Testing with ExUnit and ConnCase
- Basic auth

After the course end, I added some new features by myself like:
- Bigger test coverage;
- Fix to the API bug that was accepting negative numbers, that could be used to make a deposit subtract money from the account;
- Saving transactions data to the new table "transactions"


To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
