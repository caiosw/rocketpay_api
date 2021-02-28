defmodule RocketpayWeb.AccountsControllerTest do
  use RocketpayWeb.ConnCase, async: true

  alias Rocketpay.{Account, User}

  describe "deposit/2" do
    setup %{conn: conn} do
      params = %{
        name: "Caio",
        password: "123456",
        nickname: "caiosw",
        email: "caiosw@gmail.com",
        age: 31
      }

      {:ok, %User{account: %Account{id: account_id}}} = Rocketpay.create_user(params)

      conn = put_req_header(conn, "authorization", "Basic cG90YXRvOlRlc3QxMjM0")

      {:ok, conn: conn, account_id: account_id}
    end

    test "when all params are valid, make the deposit", %{conn: conn, account_id: account_id} do
      params = %{"value" => "50.00"}

      response = conn
      |> post(Routes.accounts_path(conn, :deposit, account_id, params))
      |> json_response(:ok)

      expected_response = %{
        "account" => %{
          "balance" => "50.00",
          "id" => account_id
        },
        "message" => "Ballance changed successfully"
      }

      assert response == expected_response
    end

    test "when there are invalid params, returns an error", %{conn: conn, account_id: account_id} do
      params = %{"value" => "-50"}

      response = conn
      |> post(Routes.accounts_path(conn, :deposit, account_id, params))
      |> json_response(:bad_request) # or |> json_response(400)

      expected_response = %{"message" => "The value must be a positive decimal!"}

      assert response == expected_response
    end

    test "when the account id is invalid, returns an error", %{conn: conn} do
      params = %{"value" => "1"}

      response = conn
      |> post(Routes.accounts_path(conn, :deposit, "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", params))
      |> json_response(:bad_request) # or |> json_response(400)

      expected_response = %{"message" => "Account not found!"}

      assert response == expected_response
    end
  end

  describe "withdraw/2" do
    setup %{conn: conn} do
      params = %{
        name: "Caio",
        password: "123456",
        nickname: "caiosw",
        email: "caiosw@gmail.com",
        age: 31
      }

      {:ok, %User{account: %Account{id: account_id}}} = Rocketpay.create_user(params)

      conn = put_req_header(conn, "authorization", "Basic cG90YXRvOlRlc3QxMjM0")

      {:ok, conn: conn, account_id: account_id}
    end

    test "when all params are valid, make the withdraw", %{conn: conn, account_id: account_id} do
      params_deposit = %{"value" => "50"}
      params_withdraw = %{"value" => "30"}

      response = conn
      |> post(Routes.accounts_path(conn, :deposit, account_id, params_deposit))
      |> post(Routes.accounts_path(conn, :withdraw, account_id, params_withdraw))
      |> json_response(:ok)

      expected_response = %{
        "account" => %{
          "balance" => "20.00",
          "id" => account_id
        },
        "message" => "Ballance changed successfully"
      }

      assert response == expected_response
    end

    test "when there isn't enough balance, returns an error", %{conn: conn, account_id: account_id} do
      params = %{"value" => "30"}

      response = conn
      |> post(Routes.accounts_path(conn, :withdraw, account_id, params))
      |> json_response(:bad_request) # or |> json_response(400)

      expected_response = %{"message" => "There's not enough balance for this operation!"}

      assert response == expected_response
    end

    test "when there are invalid params, returns an error", %{conn: conn, account_id: account_id} do
      params_deposit = %{"value" => "50"}
      params_withdraw = %{"value" => "test"}

      response = conn
      |> post(Routes.accounts_path(conn, :deposit, account_id, params_deposit))
      |> post(Routes.accounts_path(conn, :withdraw, account_id, params_withdraw))
      |> json_response(:bad_request) # or |> json_response(400)

      expected_response = %{"message" => "Invalid value! Positive decimal expected."}

      assert response == expected_response
    end

    test "when the account id is invalid, returns an error", %{conn: conn} do
      params = %{"value" => "1"}

      response = conn
      |> post(Routes.accounts_path(conn, :withdraw, "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", params))
      |> json_response(:bad_request) # or |> json_response(400)

      expected_response = %{"message" => "Account not found!"}

      assert response == expected_response
    end
  end

  describe "transaction/3" do
    setup %{conn: conn} do
      params_user1 = %{
        name: "Caio",
        password: "123456",
        nickname: "caiosw",
        email: "caiosw@gmail.com",
        age: 31
      }

      {:ok, %User{account: %Account{id: account_id_from}}} = Rocketpay.create_user(params_user1)

      params_user2 = %{
        name: "João",
        password: "123456",
        nickname: "joao",
        email: "joao@test.test",
        age: 31
      }

      {:ok, %User{account: %Account{id: account_id_to}}} = Rocketpay.create_user(params_user2)

      conn = put_req_header(conn, "authorization", "Basic cG90YXRvOlRlc3QxMjM0")

      {:ok, conn: conn, account_id_from: account_id_from, account_id_to: account_id_to}
    end

    test "when all params are valid, make the transaction", %{conn: conn, account_id_from: account_id_from, account_id_to: account_id_to} do
      params_deposit = %{"value" => "50"}
      params_transaction = %{
        "value" => "30",
        "from" => account_id_from,
        "to" => account_id_to
      }

      response = conn
      |> post(Routes.accounts_path(conn, :deposit, account_id_from, params_deposit))
      |> post(Routes.accounts_path(conn, :transaction, params_transaction))
      |> json_response(:ok)

      expected_response = %{
        "message" => "Transaction done successfully",
        "transaction" => %{
          "from_account" => %{
            "balance" => "20.00",
            "id" => account_id_from
          },
          "to_account" => %{
            "balance" => "30.00",
            "id" => account_id_to
          }
        }
      }

      assert response == expected_response
    end

    test "when there isn't enough balance, returns an error", %{conn: conn, account_id_from: account_id_from, account_id_to: account_id_to} do
      params_transaction = %{
        "value" => "1000",
        "from" => account_id_from,
        "to" => account_id_to
      }

      response = conn
      |> post(Routes.accounts_path(conn, :transaction, params_transaction))
      |> json_response(:bad_request) # or |> json_response(400)

      expected_response = %{"message" => "There's not enough balance for this operation!"}

      assert response == expected_response
    end
  end

  test "when authorization is invalid, returns an error", %{conn: conn} do
    params = %{
      "value" => "50",
      "from" => "1234",
      "to" => "4321"
    }

    response =
      conn
      |> put_req_header("authorization", "basic potato")
      |> post(Routes.accounts_path(conn, :transaction, params))
      |> response(:unauthorized)

    expected_response = "Unauthorized"

    assert response == expected_response
  end

end
