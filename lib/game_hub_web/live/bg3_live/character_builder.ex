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

  @stat_fields [:strength, :dexterity, :constitution, :intelligence, :wisdom, :charisma]
  @min_stat 8
  @max_stat 15
  @total_points 27

  # Coût cumulé pour atteindre une valeur de base depuis 8
  @cost_table %{8 => 0, 9 => 1, 10 => 2, 11 => 3, 12 => 4, 13 => 5, 14 => 7, 15 => 9}

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    character = Bg3.get_character!(id)

    bonus_primary = stored_bonus_to_atom(character.bonus_primary)
    bonus_secondary = stored_bonus_to_atom(character.bonus_secondary)

    base_scores =
      init_base_scores(
        character,
        bonus_primary,
        bonus_secondary
      )

    {:ok,
     socket
     |> assign(:page_title, "Modifier le personnage")
     |> assign(:character, character)
     |> assign(:base_scores, base_scores)
     |> assign(:bonus_primary, bonus_primary)
     |> assign(:bonus_secondary, bonus_secondary)
     |> assign(:remaining_points, remaining_points(base_scores))
     |> assign(:stat_fields, @stat_fields)
     |> recompute_form()}
  end

  @impl true
  def mount(_params, _session, socket) do
    base_scores = Map.new(@stat_fields, &{&1, @min_stat})

    {:ok,
     socket
     |> assign(:page_title, "Nouveau personnage")
     |> assign(:character, %Character{})
     |> assign(:base_scores, base_scores)
     |> assign(:bonus_primary, nil)
     |> assign(:bonus_secondary, nil)
     |> assign(:remaining_points, @total_points)
     |> assign(:stat_fields, @stat_fields)
     |> recompute_form()}
  end

  def handle_event("validate", %{"character" => params}, socket) do
    merged = Map.merge(params, final_scores_params(socket.assigns))

    changeset = Bg3.change_character(socket.assigns.character, merged)

    {:noreply, assign(socket, :form, to_form(changeset, as: :character, action: :validate))}
  end

  def handle_event("generate_name", %{"race" => race}, socket) do
    generated_name = NameGenerator.generate(race)

    params =
      (socket.assigns.form.params || %{})
      |> Map.put("name", generated_name)
      |> Map.merge(final_scores_params(socket.assigns))

    changeset = Bg3.change_character(socket.assigns.character, params)

    {:noreply, assign(socket, :form, to_form(changeset, as: :character))}
  end

  @impl true
  def handle_event("save", %{"character" => params}, socket) do
    merged_params =
      Map.merge(params, final_scores_params(socket.assigns))

    result =
      case socket.assigns.character do
        %Character{id: nil} ->
          Bg3.create_character(merged_params)

        character ->
          Bg3.update_character(character, merged_params)
      end

    case result do
      {:ok, saved_character} ->
        {:noreply,
         push_navigate(
           socket,
           to: ~p"/baldurs-gate-3/characters/#{saved_character.id}"
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         assign(
           socket,
           :form,
           to_form(changeset, as: :character, action: :validate)
         )}
    end
  end

  @impl true
  def handle_event("increment_stat", %{"stat" => stat}, socket) do
    stat = String.to_existing_atom(stat)
    base_scores = socket.assigns.base_scores
    current = Map.fetch!(base_scores, stat)
    next = current + 1

    socket =
      if next <= @max_stat do
        delta = Map.fetch!(@cost_table, next) - Map.fetch!(@cost_table, current)

        if socket.assigns.remaining_points >= delta do
          new_scores = Map.put(base_scores, stat, next)

          socket
          |> assign(:base_scores, new_scores)
          |> assign(:remaining_points, socket.assigns.remaining_points - delta)
          |> recompute_form()
        else
          socket
        end
      else
        socket
      end

    {:noreply, socket}
  end

  def handle_event("decrement_stat", %{"stat" => stat}, socket) do
    stat = String.to_existing_atom(stat)
    base_scores = socket.assigns.base_scores
    current = Map.fetch!(base_scores, stat)
    prev = current - 1

    socket =
      if prev >= @min_stat do
        delta = Map.fetch!(@cost_table, current) - Map.fetch!(@cost_table, prev)
        new_scores = Map.put(base_scores, stat, prev)

        socket
        |> assign(:base_scores, new_scores)
        |> assign(:remaining_points, socket.assigns.remaining_points + delta)
        |> recompute_form()
      else
        socket
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle_bonus", %{"bonus" => bonus, "stat" => stat_name}, socket) do
    case stat_from_param(stat_name) do
      nil ->
        {:noreply, socket}

      stat ->
        {bonus_primary, bonus_secondary} =
          case bonus do
            "primary" ->
              if socket.assigns.bonus_primary == stat do
                {nil, socket.assigns.bonus_secondary}
              else
                secondary =
                  if socket.assigns.bonus_secondary == stat do
                    nil
                  else
                    socket.assigns.bonus_secondary
                  end

                {stat, secondary}
              end

            "secondary" ->
              cond do
                socket.assigns.bonus_secondary == stat ->
                  {socket.assigns.bonus_primary, nil}

                socket.assigns.bonus_primary == stat ->
                  {socket.assigns.bonus_primary, nil}

                true ->
                  {socket.assigns.bonus_primary, stat}
              end

            _ ->
              {socket.assigns.bonus_primary, socket.assigns.bonus_secondary}
          end

        {:noreply,
         socket
         |> assign(:bonus_primary, bonus_primary)
         |> assign(:bonus_secondary, bonus_secondary)
         |> recompute_form()}
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
      |> assign(:stat_fields, @stat_fields)

    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="mx-auto max-w-5xl px-4 py-8">
        <div class="mb-6">
          <p class="text-sm uppercase tracking-[0.2em] text-zinc-400">Baldur's Gate 3</p>
          <h1 class="mt-2 text-3xl font-bold text-zinc-100">{@page_title}</h1>
        </div>

        <.form
          for={@form}
          id="character-form"
          phx-change="validate"
          phx-submit="save"
          class="space-y-8"
        >
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
              <.input
                field={@form[:name]}
                type="text"
                label="Nom"
                placeholder="Ex: Aelrith Moonshadow"
              />
              <.input
                field={@form[:alignment]}
                type="select"
                label="Alignement"
                options={@alignment_options}
              />
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
              <.input
                field={@form[:background]}
                type="select"
                label="Historique"
                options={@background_options}
              />
              <.input field={@form[:notes]} type="textarea" label="Notes" rows={4} />
            </div>
          </div>

          <div class="rounded-2xl border border-zinc-800 bg-zinc-900/70 p-6">
            <div class="mb-5 flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
              <div>
                <h2 class="text-xl font-semibold text-white">Caractéristiques</h2>
                <p class="mt-1 text-sm text-zinc-400">
                  Répartissez vos 27 points entre les six caractéristiques.
                </p>
              </div>

              <div class="rounded-lg border border-amber-500/40 bg-amber-500/10 px-3 py-2 text-sm font-medium text-amber-300">
                Points restants : <span class="font-bold">{@remaining_points}</span>
                <span class="text-amber-400/70">/ 27</span>
              </div>
            </div>

            <div class="space-y-3">
              <div
                :for={stat <- @stat_fields}
                id={"stat-#{stat}"}
                class="rounded-xl border border-zinc-700 bg-zinc-950/60 p-4 transition hover:border-zinc-500"
              >
                <div class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
                  <div class="min-w-0">
                    <p class="font-semibold text-white">{stat_label(stat)}</p>

                    <p class="mt-1 text-xs text-zinc-500">
                      Base : {@base_scores[stat]}

                      <span
                        :if={@bonus_primary == stat}
                        class="ml-2 font-medium text-amber-400"
                      >
                        Bonus racial +3
                      </span>

                      <span
                        :if={@bonus_secondary == stat}
                        class="ml-2 font-medium text-emerald-400"
                      >
                        Bonus racial +1
                      </span>
                    </p>
                  </div>

                  <div class="flex items-center gap-3">
                    <button
                      type="button"
                      id={"decrement-#{stat}"}
                      phx-click="decrement_stat"
                      phx-value-stat={stat}
                      disabled={@base_scores[stat] <= 8}
                      aria-label={"Diminuer #{stat_label(stat)}"}
                      class="flex h-9 w-9 items-center justify-center rounded-lg border border-zinc-600 text-lg text-zinc-200 transition hover:border-amber-400 hover:text-amber-300 disabled:cursor-not-allowed disabled:opacity-30"
                    >
                      −
                    </button>

                    <div class="flex min-w-16 flex-col items-center rounded-lg bg-zinc-900 px-3 py-2">
                      <span class="text-2xl font-bold text-white">
                        {final_score(assigns, stat)}
                      </span>

                      <span class="mt-1 text-xs uppercase tracking-wide text-zinc-500">
                        Score
                      </span>

                      <span class="mt-1 text-sm font-bold text-amber-400">
                        {ability_modifier_label(final_score(assigns, stat))}
                      </span>

                      <span class="text-[10px] uppercase tracking-wide text-zinc-500">
                        Modificateur
                      </span>
                    </div>

                    <button
                      type="button"
                      id={"increment-#{stat}"}
                      phx-click="increment_stat"
                      phx-value-stat={stat}
                      disabled={
                        @base_scores[stat] >= 15 or
                          @remaining_points < step_display_cost(@base_scores[stat], :up)
                      }
                      aria-label={"Augmenter #{stat_label(stat)}"}
                      class="flex h-9 w-9 items-center justify-center rounded-lg border border-zinc-600 text-lg text-zinc-200 transition hover:border-amber-400 hover:text-amber-300 disabled:cursor-not-allowed disabled:opacity-30"
                    >
                      +
                    </button>
                  </div>

                  <input
                    type="hidden"
                    name={"character[#{stat}]"}
                    value={final_score(assigns, stat)}
                  />
                </div>

                <div class="mt-4 grid gap-2 border-t border-zinc-800 pt-3 sm:grid-cols-2">
                  <label class="flex cursor-pointer items-center gap-3 rounded-lg border border-zinc-800 px-3 py-2 transition hover:border-amber-500/50">
                    <input
                      type="checkbox"
                      id={"bonus-primary-#{stat}"}
                      checked={@bonus_primary == stat}
                      phx-click="toggle_bonus"
                      phx-value-bonus="primary"
                      phx-value-stat={stat}
                      class="h-4 w-4 rounded border-zinc-600 bg-zinc-900 text-amber-500 focus:ring-amber-500"
                    />

                    <span class="text-sm text-zinc-300">
                      Bonus racial <strong class="text-amber-400">+3</strong>
                    </span>
                  </label>

                  <label class={[
                    "flex items-center gap-3 rounded-lg border border-zinc-800 px-3 py-2 transition",
                    if(
                      @bonus_primary == stat,
                      do: "cursor-not-allowed opacity-40",
                      else: "cursor-pointer hover:border-emerald-500/50"
                    )
                  ]}>
                    <input
                      type="checkbox"
                      id={"bonus-secondary-#{stat}"}
                      checked={@bonus_secondary == stat}
                      disabled={@bonus_primary == stat}
                      phx-click="toggle_bonus"
                      phx-value-bonus="secondary"
                      phx-value-stat={stat}
                      class="h-4 w-4 rounded border-zinc-600 bg-zinc-900 text-emerald-500 focus:ring-emerald-500 disabled:cursor-not-allowed"
                    />

                    <span class="text-sm text-zinc-300">
                      Bonus racial <strong class="text-emerald-400">+1</strong>
                    </span>
                  </label>
                </div>
              </div>
            </div>

            <div class="mt-5 rounded-xl border border-zinc-800 bg-zinc-950/40 p-4 text-sm text-zinc-400">
              <p>
                Les valeurs de base vont de <strong class="text-zinc-200">8 à 15</strong>.
              </p>
              <p class="mt-1">
                Une caractéristique peut atteindre <strong class="text-zinc-200">18</strong>
                grâce au bonus racial de +3.
              </p>
            </div>
          </div>

          <div class="flex justify-end gap-4">
            <.link
              navigate={~p"/baldurs-gate-3/characters"}
              class="inline-flex items-center rounded-xl border border-zinc-700 px-4 py-2 text-sm font-medium text-zinc-200 transition hover:border-zinc-500"
            >
              Annuler
            </.link>

            <.button class="bg-amber-500 text-zinc-950 hover:bg-amber-400">
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

  defp init_base_scores(
         %Character{} = character,
         bonus_primary,
         bonus_secondary
       ) do
    Map.new(@stat_fields, fn field ->
      stored_value = Map.get(character, field) || @min_stat

      bonus =
        cond do
          bonus_primary == field -> 3
          bonus_secondary == field -> 1
          true -> 0
        end

      base_value =
        stored_value
        |> Kernel.-(bonus)
        |> max(@min_stat)
        |> min(@max_stat)

      {field, base_value}
    end)
  end

  defp remaining_points(base_scores) do
    spent =
      base_scores
      |> Map.values()
      |> Enum.map(&Map.fetch!(@cost_table, &1))
      |> Enum.sum()

    @total_points - spent
  end

  defp final_score(assigns, stat) do
    base = Map.fetch!(assigns.base_scores, stat)

    bonus =
      cond do
        assigns.bonus_primary == stat -> 3
        assigns.bonus_secondary == stat -> 1
        true -> 0
      end

    base + bonus
  end

  defp recompute_form(socket) do
    existing_params =
      case socket.assigns[:form] do
        nil -> %{}
        form -> form.params || %{}
      end

    params =
      existing_params
      |> Map.merge(final_scores_params(socket.assigns))

    changeset =
      Bg3.change_character(
        socket.assigns.character,
        params
      )

    assign(
      socket,
      :form,
      to_form(changeset, as: :character)
    )
  end

  defp stat_label(:strength), do: "Force"
  defp stat_label(:dexterity), do: "Dextérité"
  defp stat_label(:constitution), do: "Constitution"
  defp stat_label(:intelligence), do: "Intelligence"
  defp stat_label(:wisdom), do: "Sagesse"
  defp stat_label(:charisma), do: "Charisme"

  defp step_display_cost(current, direction) do
    case direction do
      :up -> Map.fetch!(@cost_table, current + 1) - Map.fetch!(@cost_table, current)
      :down -> Map.fetch!(@cost_table, current) - Map.fetch!(@cost_table, current - 1)
    end
  end

  defp stored_bonus_to_atom(nil), do: nil

  defp stored_bonus_to_atom(value) when is_binary(value) do
    case value do
      "strength" -> :strength
      "dexterity" -> :dexterity
      "constitution" -> :constitution
      "intelligence" -> :intelligence
      "wisdom" -> :wisdom
      "charisma" -> :charisma
      _ -> nil
    end
  end

  defp stored_bonus_to_atom(value) when is_atom(value), do: value
  defp stored_bonus_to_atom(_value), do: nil

  defp final_scores_params(assigns) do
    scores =
      Map.new(@stat_fields, fn stat ->
        {
          Atom.to_string(stat),
          Integer.to_string(final_score(assigns, stat))
        }
      end)

    Map.merge(scores, %{
      "bonus_primary" => bonus_to_param(assigns.bonus_primary),
      "bonus_secondary" => bonus_to_param(assigns.bonus_secondary)
    })
  end

  defp bonus_to_param(nil), do: nil
  defp bonus_to_param(stat) when is_atom(stat), do: Atom.to_string(stat)
  defp bonus_to_param(stat) when is_binary(stat), do: stat

  defp stat_from_param("strength"), do: :strength
  defp stat_from_param("dexterity"), do: :dexterity
  defp stat_from_param("constitution"), do: :constitution
  defp stat_from_param("intelligence"), do: :intelligence
  defp stat_from_param("wisdom"), do: :wisdom
  defp stat_from_param("charisma"), do: :charisma
  defp stat_from_param(_), do: nil

  defp ability_modifier(score) when is_integer(score) do
    Integer.floor_div(score - 10, 2)
  end

  defp ability_modifier_label(score) do
    modifier = ability_modifier(score)

    if modifier >= 0 do
      "+#{modifier}"
    else
      Integer.to_string(modifier)
    end
  end
end
