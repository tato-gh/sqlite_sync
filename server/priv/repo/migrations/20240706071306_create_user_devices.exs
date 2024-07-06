defmodule SyncCentral.Repo.Migrations.CreateUserDevices do
  use Ecto.Migration

  def change do
    create table(:user_devices) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :name, :string, null: false
      add :retrieved_at, :utc_datetime_usec

      timestamps(type: :utc_datetime)
    end

    create index(:user_devices, [:user_id])
  end
end
