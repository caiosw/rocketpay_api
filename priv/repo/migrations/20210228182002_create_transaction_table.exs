defmodule Rocketpay.Repo.Migrations.CreateTransactionTable do
  use Ecto.Migration

  def change do
    create table :transactions do
      add :account_id_from, references(:accounts, type: :binary_id)
      add :account_id_to, references(:accounts, type: :binary_id)
      add :value, :decimal

      timestamps()
    end

    create constraint(:transactions, :value_must_be_positive, check: "value > 0")
  end
end
