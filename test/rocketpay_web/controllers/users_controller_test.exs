defmodule RocketpayWeb.UsersControllerTest do
  use RocketpayWeb.ConnCase, async: true
  use RocketpayWeb, :controller

  alias Rocketpay.{Account, User}

  describe "create/2" do
    test "if all params are valid, create a new user" do
      params = %{
        name: "Caio",
        password: "123456",
        nickname: "caiosw",
        email: "caiosw@gmail.com",
        age: 31
      }

      response = Rocketpay.create_user(params)

      assert {:ok, %User{account: %Account{}}} = response

    end

    test "if user already existis, return an error" do
      params = %{
        name: "Caio",
        password: "123456",
        nickname: "caiosw",
        email: "caiosw@gmail.com",
        age: 31
      }

      Rocketpay.create_user(params)
      {:error, %Ecto.Changeset{errors: errors}} = Rocketpay.create_user(params)

      expected_response = [
        email: {"has already been taken",
         [
           constraint: :unique,
           constraint_name: "users_email_index"
         ]}
      ]

      assert expected_response == errors

    end

    test "if any param is invalid, return an error" do
      params = %{
        password: "12345",
        nickname: "caiosw",
        email: "caiosw.gmail.com",
        age: 17
      }

      expected_response = [
        email: {"has invalid format", [validation: :format]},
        age: {"must be greater than or equal to %{number}",
         [
           validation: :number,
           kind: :greater_than_or_equal_to,
           number: 18
         ]},
        password: {"should be at least %{count} character(s)",
         [
           count: 6,
           validation: :length,
           kind: :min,
           type: :string
         ]},
        name: {"can't be blank", [validation: :required]}
      ]

      {:error, %Ecto.Changeset{errors: errors}} = Rocketpay.create_user(params)

      assert expected_response == errors
    end
  end


end
