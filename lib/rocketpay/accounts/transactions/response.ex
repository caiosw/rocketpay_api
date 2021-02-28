defmodule Rocketpay.Accounts.Transactions.Response do
  alias Rocketpay.Account

  defstruct [:from_account, :to_account, :value]

  def build(%Account{} = from_account, %Account{} = to_account, value = value) do
    %__MODULE__{
      from_account: from_account,
      to_account: to_account,
      value: value
    }
  end

end
