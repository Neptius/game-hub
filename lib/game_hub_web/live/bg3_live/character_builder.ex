defmodule GameHubWeb.Bg3Live.CharacterBuilder do
  use GameHubWeb, :live_view

  alias GameHub.Bg3
  alias GameHub.Bg3.Character
  alias GameHub.Bg3.NameGenerator

  @race_options [
    "Humain",
    "Elfe",
    "Semi-elfe",
    "Nain",
    "Halfelin",
    "Gnome",
    "Demi-orque",
    "Tieffelin",
    "Drow",
    "Githyanki"
  ]

  @class_options [
    "Barbare",
    "Barde",
    "Clerc",
    "Druide",
    "Guerrier",
    "Moine",
    "Paladin",
    "Rôdeur",
    "Roublard",
    "Ensorceleur",
    "Magicien",
    "Occultiste"
  ]

  @background_options [
    "Acolyte",
    "Charlatan",
    "Criminel",
    "Héros du peuple",
    "Noble",
    "Sage",
    "Soldat",
    "Ermite",
    "Artiste",
    "Marin"
  ]

  @alignment_options [
    "Loyal Bon",
    "Neutre Bon",
    "Chaotique Bon",
    "Loyal Neutre",
    "Neutre",
    "Chaotique Neutre",
    "Loyal Mauvais",
    "Neutre Mauvais",
    "Chaotique Mauvais"
  ]

  @subraces %{
    "Humain" => ["Tradition humaine", "Héritier du Nord", "Marchand voyageur"],
    "Elfe" => ["Haut-elfe", "Elfe des bois", "Elfe noir", "Drow"],
    "Semi-elfe" => ["Semi-elfe de la cour", "Semi-elfe sauvage", "Semi-elfe nomade"],
    "Nain" => ["Nain de la chaîne", "Nain des montagnes", "Nain des profondeurs"],
    "Halfelin" => ["Halfelin léger", "Halfelin robuste", "Halfelin forestier"],
    "Gnome" => ["Gnome forestier", "Gnome des roches", "Gnome tinker"],
    "Demi-orque" => ["Demi-orque brutal", "Demi-orque farouche", "Demi-orque guerrier"],
    "Tieffelin" => ["Tieffelin infernal", "Tieffelin abyssal", "Tieffelin démoniaque"],
    "Drow" => ["Drow noble", "Drow guerrière", "Drow mystique"],
    "Githyanki" => ["Githyanki de la lignée noble", "Githyanki guerrier", "Githyanki mystique"]
  }

  @subclasses %{
    "Barbare" => ["Berserker", "Totem", "Path of the Ancestral Guardian"],
    "Barde" => ["College of Lore", "College of Valor", "Glamour"],
    "Clerc" => ["Vie", "Connaissance", "Guerre", "Nature"],
    "Druide" => ["Cercle de la Terre", "Cercle du Feu", "Cercle de la Lune"],
    "Guerrier" => ["Champion", "Battle Master", "Gilded Defense"],
    "Moine" => ["Voie de la Main Ouverte", "Voie de la Tempête", "Voie de la Mère Terre"],
    "Paladin" => ["Vengeance", "Ancien", "Dévotion"],
    "Rôdeur" => ["Golem Hunter", "Hunt", "Beast Master"],
    "Roublard" => ["Phantom", "Thief", "Assassin"],
    "Ensorceleur" => ["Draconic Bloodline", "Wild Magic"],
    "Magicien" => ["École d'Abjuration", "École d'Enchantment", "École d'Invocation"],
    "Occultiste" => ["Le Pacte du Diable", "Le Pacte de la Faucheuse", "Le Pacte du Ciel"]
  }

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    character = Bg3.get_character!(id)

    {:ok,
     socket
     |> assign(:page_title, "Modifier le personnage")
     |> assign(:character, character)
     |> assign(:form, to_form(Bg3.change_character(character), as: :character))}
  end

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Nouveau personnage")
     |> assign(:character, %Character{})
     |> assign(:form, to_form(Bg3.change_character(%Character{}), as: :character))}
  end

  @impl true
  def handle_event("validate", %{"character" => params}, socket) do
    changeset =
      socket.assigns.character
      |> Bg3.change_character(params)

    {:noreply, assign(socket, :form, to_form(changeset, as: :character))}
  end

  # def handle_event("generate_name", %{"race" => race}, socket) do
  #   generated_name = NameGenerator.generate(race)
  #   form_params = Map.get(socket.assigns.form.params, "character", %{})

  #   socket =
  #     assign(
  #       socket,
  #       :form,
  #       to_form(
  #         %{
  #           "character" => Map.put(form_params, "name", generated_name)
  #         },
  #         as: :character
  #       )
  #     )

  #   {:noreply, socket}
  # end

  def handle_event("save", %{"character" => params}, socket) do
    case socket.assigns.character do
      %Character{} = character ->
        case Bg3.update_character(character, params) do
          {:ok, saved} ->
            {:noreply, push_navigate(socket, to: ~p"/baldurs-gate-3/characters/#{saved.id}")}

          {:error, %Ecto.Changeset{} = changeset} ->
            {:noreply, assign(socket, :form, to_form(changeset, as: :character))}
        end

      _ ->
        case Bg3.create_character(params) do
          {:ok, saved} ->
            {:noreply, push_navigate(socket, to: ~p"/baldurs-gate-3/characters/#{saved.id}")}

          {:error, %Ecto.Changeset{} = changeset} ->
            {:noreply, assign(socket, :form, to_form(changeset, as: :character))}
        end
    end
  end

  @impl true
  def render(assigns) do
    selected_race = form_value(assigns.form, :race)
    selected_class = form_value(assigns.form, :class)
    subraces = Map.get(@subraces, selected_race, [])
    subclasses = Map.get(@subclasses, selected_class, [])

    assigns =
      assigns
      |> assign(:selected_race, selected_race)
      |> assign(:selected_class, selected_class)
      |> assign(:subraces, subraces)
      |> assign(:subclasses, subclasses)
      |> assign(:race_options, @race_options)
      |> assign(:class_options, @class_options)
      |> assign(:background_options, @background_options)
      |> assign(:alignment_options, @alignment_options)

    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="mx-auto max-w-5xl px-4 py-8">
        <div class="mb-6">
          <p class="text-sm uppercase tracking-[0.2em] text-zinc-400">Baldur's Gate 3</p>
          <h1 class="mt-2 text-3xl font-bold text-zinc-100">{@page_title}</h1>
        </div>

        <.form for={@form} id="character-form" phx-change="validate" phx-submit="save" class="space-y-8">
          <div class="rounded-2xl border border-zinc-800 bg-zinc-900/70 p-6">
            <div class="mb-4 flex items-center justify-between">
              <h2 class="text-xl font-semibold text-white">Identité</h2>
              <%!--
                <button
                  type="button"
                  phx-click="generate_name"
                  phx-value-race={form_value(@form, :race)}
                  class="rounded-lg border border-amber-500/40 bg-amber-500/10 px-3 py-2 text-sm font-medium text-amber-300 transition hover:bg-amber-500/20"
                >
                  🎲 Générer un nom
                </button>
              --%>
            </div>

            <div class="grid gap-5 md:grid-cols-2">
              <.input field={@form[:name]} type="text" label="Nom" placeholder="Ex: Aelrith Moonshadow" />
              <.input field={@form[:alignment]} type="select" label="Alignement" options={@alignment_options} />
            </div>
          </div>

          <div class="grid gap-6 lg:grid-cols-2">
            <div class="rounded-2xl border border-zinc-800 bg-zinc-900/70 p-6">
              <h2 class="mb-4 text-xl font-semibold text-white">Race & Sous-race</h2>

              <div class="space-y-5">
                <.input field={@form[:race]} type="select" label="Race" options={@race_options} />
                <.input
                  field={@form[:subrace]}
                  type="select"
                  label="Sous-race"
                  options={Enum.map(@subraces, &{&1, &1})}
                />
              </div>
            </div>

            <div class="rounded-2xl border border-zinc-800 bg-zinc-900/70 p-6">
              <h2 class="mb-4 text-xl font-semibold text-white">Classe & Sous-classe</h2>

              <div class="space-y-5">
                <.input field={@form[:class]} type="select" label="Classe" options={@class_options} />
                <.input
                  field={@form[:subclass]}
                  type="select"
                  label="Sous-classe"
                  options={Enum.map(@subclasses, &{&1, &1})}
                />
              </div>
            </div>
          </div>

          <div class="rounded-2xl border border-zinc-800 bg-zinc-900/70 p-6">
            <h2 class="mb-4 text-xl font-semibold text-white">Historique</h2>
            <div class="grid gap-5 md:grid-cols-2">
              <.input field={@form[:background]} type="select" label="Historique" options={@background_options} />
              <.input field={@form[:notes]} type="textarea" label="Notes" rows={4} />
            </div>
          </div>

          <div class="rounded-2xl border border-zinc-800 bg-zinc-900/70 p-6">
            <h2 class="mb-4 text-xl font-semibold text-white">Caractéristiques</h2>

            <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
              <.input field={@form[:strength]} type="number" label="Force" min="3" max="20" />
              <.input field={@form[:dexterity]} type="number" label="Dextérité" min="3" max="20" />
              <.input field={@form[:constitution]} type="number" label="Constitution" min="3" max="20" />
              <.input field={@form[:intelligence]} type="number" label="Intelligence" min="3" max="20" />
              <.input field={@form[:wisdom]} type="number" label="Sagesse" min="3" max="20" />
              <.input field={@form[:charisma]} type="number" label="Charisme" min="3" max="20" />
            </div>

            <div class="mt-4 rounded-xl border border-zinc-700 bg-zinc-950/60 p-4 text-sm text-zinc-300">
              Total des stats : {total_stats(@form)}
            </div>
          </div>

          <div class="flex justify-end gap-4">
            <.link
              navigate={~p"/baldurs-gate-3/characters"}
              class="inline-flex items-center rounded-xl border border-zinc-700 px-4 py-2 text-sm font-medium text-zinc-200 transition hover:border-zinc-500"
            >
              Annuler
            </.link>

            <.button type="submit" class="bg-amber-500 text-zinc-950 hover:bg-amber-400">
              Enregistrer
            </.button>
          </div>
        </.form>
      </div>
    </Layouts.app>
    """
  end

  defp form_value(form, key) do
    form.params
    |> Map.get(to_string(key), "")
  end

  defp total_stats(form) do
    [:strength, :dexterity, :constitution, :intelligence, :wisdom, :charisma]
    |> Enum.map(fn field ->
      form[field].value
      |> stat_value()
    end)
    |> Enum.sum()
  end

  defp stat_value(nil), do: 0
  defp stat_value(value) when is_integer(value), do: value

  defp stat_value(value) when is_binary(value) do
    case Integer.parse(value) do
      {integer, _rest} -> integer
      :error -> 0
    end
  end

  defp stat_value(_value), do: 0
end
