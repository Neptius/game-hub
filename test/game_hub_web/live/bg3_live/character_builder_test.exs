defmodule GameHubWeb.Bg3Live.CharacterBuilderTest do
  use GameHubWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias GameHub.BG3.{Classe, SubClasse}
  alias GameHub.Repo

  setup :register_and_log_in_user

  setup do
    classe =
      Repo.insert!(%Classe{
        internal_id: "classe-barbarian",
        name: "Barbarian",
        name_uid: "n1",
        description: "d",
        description_uid: "d1",
        base_hp: 34,
        hp_per_level: 6,
        spell_list_uid: "s",
        primary_ability: "Strength",
        spell_casting_ability: "Unknown"
      })

    sub_classe =
      Repo.insert!(%SubClasse{
        internal_id: "sub-berserker",
        name: "Berserker",
        name_uid: "n2",
        description: "d",
        description_uid: "d2",
        role: "Tank",
        classe_uid: classe.internal_id,
        classe_id: classe.id
      })

    %{classe: classe, sub_classe: sub_classe}
  end

  test "lists classes and sub-classes from the database", %{
    conn: conn,
    classe: classe,
    sub_classe: sub_classe
  } do
    {:ok, view, _html} = live(conn, ~p"/baldurs-gate-3/characters/new")

    assert has_element?(view, "#level-1 option[value='#{classe.id}']", "Barbarian")

    view
    |> element("#level-1 select[name='level_class[1]']")
    |> render_change(%{"level_class" => %{"1" => to_string(classe.id)}})

    assert has_element?(view, "#level-1 option[value='#{sub_classe.id}']", "Berserker")
  end
end
