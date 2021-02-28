defmodule Rocketpay.Accounts.Transaction do
  alias Ecto.Multi
  alias Rocketpay.{Repo, Transaction}
  alias Rocketpay.Accounts.Operation
  alias Rocketpay.Accounts.Transactions.Response, as: TransactionResponse

  def call(%{"from" => from_id, "to" => to_id, "value" => value}) do
    withdraw_params = build_params(from_id, value)
    deposit_params = build_params(to_id, value)
    transaction = %{account_id_from: from_id, account_id_to: to_id, value: value}

    Multi.new()
    |> Multi.merge(fn _changes -> Operation.call(withdraw_params, :withdraw) end)
    |> Multi.merge(fn _changes -> Operation.call(deposit_params, :deposit) end)
    |> Multi.merge(fn _changes -> insert_transaction(transaction) end)
    |> run_transaction(value)
  end

  defp build_params(id, value), do: %{"id" => id, "value" => value}

  defp insert_transaction(transaction) do
    transaction = Transaction.changeset(transaction)

    Multi.new()
    |> Multi.run(:insert_transaction, fn repo, _changes -> repo.insert(transaction) end)
  end

  defp run_transaction(multi, value) do
    IO.puts("#################################### potato ##########################################")
    IO.inspect(multi)
    case Repo.transaction(multi) do
      {:error, _operation, reason, _changes} -> {:error, reason}
      {:ok, %{deposit: to_account, withdraw: from_account}} ->
        {:ok, TransactionResponse.build(from_account, to_account, value)}
    end
  end
end
