defmodule RocketpayWeb.AccountsView do
  alias Rocketpay.Account
  alias Rocketpay.Accounts.Transactions.Response, as: TransactionResponse

  def render("update.json", %{account: %Account{id: account_id, balance: balance}}) do
    %{
      message: "Ballance changed successfully",
      account: %{
        id: account_id,
        balance: balance
      }
    }
  end

  def render("transaction.json", %{
    transaction: %TransactionResponse{to_account: to_account, from_account: from_account, value: value}
  }) do
    %{
      message: "Transaction done successfully, your new balance is #{from_account.balance}",
      your_account: %{
        id: from_account.id,
        new_balance: from_account.balance
      },
      transaction: %{
        to_account_id: to_account.id,
        transfered_value: value
      }
    }
  end
end
