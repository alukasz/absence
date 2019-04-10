defmodule Absence.AccountsTest do
  use Absence.DataCase, async: true

  import Absence.Factory

  alias Absence.Accounts
  alias Absence.Accounts.User

  describe "user_changeset/0,1" do
    test "creates new User changeset" do
      assert %Ecto.Changeset{data: %User{}} = Accounts.user_changeset()
    end

    test "creates User changeset from existing User" do
      user = build(:user)

      assert %Ecto.Changeset{data: ^user} = Accounts.user_changeset(user)
    end
  end

  describe "register/1 with valid params" do
    test "inserts User to database" do
      assert {:ok, %User{} = user} = Accounts.register(params_for(:user))

      assert Repo.get(User, user.id)
    end

    test "password is hashed" do
      params = params_for(:user)

      assert {:ok, %User{} = user} = Accounts.register(params)

      assert Argon2.check_pass(user.password, params.password)
    end
  end

  describe "register/1 with invalid params" do
    for field <- [:first_name, :last_name, :email, :password] do
      test "#{field} is required" do
        assert {:error, changeset} =
                 Accounts.register(params_for(:user, %{unquote(field) => nil}))

        assert "can't be blank" in errors_on(changeset)[unquote(field)]
      end
    end

    test "email must be unique" do
      user = insert(:user, email: "test@example.com")

      assert {:error, changeset} = Accounts.register(params_for(:user, email: user.email))

      assert "has already been taken" in errors_on(changeset).email
    end

    test "password confirmation must match password" do
      assert {:error, changeset} =
               Accounts.register(params_for(:user, password: "a", password_confirmation: "b"))

      assert "does not match" in errors_on(changeset).password_confirmation
    end
  end
end
