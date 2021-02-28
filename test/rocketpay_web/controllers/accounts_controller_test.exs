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

      expected_response = %{"message" => "Invalid deposit value! Positive decimal value expected."}

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

    test "when there are invalid params, returns an error", %{conn: conn, account_id: account_id} do
      params = %{"value" => "-50"}

      response = conn
      |> post(Routes.accounts_path(conn, :withdraw, account_id, params))
      |> json_response(:bad_request) # or |> json_response(400)

      expected_response = %{"message" => "Invalid withdraw value! Positive decimal value expected."}

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


end
