# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     CyptoBank.Repo.insert!(%CyptoBank.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

IO.puts("Adding admins, clients with deposit, withdraw, transfer and adjustment......")

filenames = ~w(
  seed
)

Enum.each(filenames, fn filename ->
  Code.require_file("#{filename}.exs", "#{__DIR__}/seeds")
end)

alias CyptoBank.Seeds.Seed

Seed.generate()

IO.puts("----------------Seed finished----------------")
