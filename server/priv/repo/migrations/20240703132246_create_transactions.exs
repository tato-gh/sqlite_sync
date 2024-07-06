defmodule SyncCentral.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :sql, :text, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:transactions, [:user_id, :inserted_at])
  end
end
