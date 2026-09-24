defmodule GameHub.Bg3.Reference do
  @moduledoc """
  Données statiques BG3, structurées comme si elles provenaient de tables
  Postgres (id auto-incrémenté + name, avec clés étrangères pour les
  tables liées). Objectif : faciliter la migration future vers de vraies
  tables sans changer les appelants.
  """

  @races [
    %{id: 1, name: "Humain"},
    %{id: 2, name: "Elfe"},
    %{id: 3, name: "Semi-elfe"},
    %{id: 4, name: "Nain"},
    %{id: 5, name: "Halfelin"},
    %{id: 6, name: "Gnome"},
    %{id: 7, name: "Demi-orque"},
    %{id: 8, name: "Tieffelin"},
    %{id: 9, name: "Drow"},
    %{id: 10, name: "Githyanki"}
  ]

  @classes [
    %{id: 1, name: "Barbare"},
    %{id: 2, name: "Barde"},
    %{id: 3, name: "Clerc"},
    %{id: 4, name: "Druide"},
    %{id: 5, name: "Guerrier"},
    %{id: 6, name: "Moine"},
    %{id: 7, name: "Paladin"},
    %{id: 8, name: "Rôdeur"},
    %{id: 9, name: "Roublard"},
    %{id: 10, name: "Ensorceleur"},
    %{id: 11, name: "Magicien"},
    %{id: 12, name: "Occultiste"}
  ]

  @backgrounds [
    %{id: 1, name: "Acolyte"},
    %{id: 2, name: "Charlatan"},
    %{id: 3, name: "Criminel"},
    %{id: 4, name: "Héros du peuple"},
    %{id: 5, name: "Noble"},
    %{id: 6, name: "Sage"},
    %{id: 7, name: "Soldat"},
    %{id: 8, name: "Ermite"},
    %{id: 9, name: "Artiste"},
    %{id: 10, name: "Marin"}
  ]

  @alignments [
    %{id: 1, name: "Loyal Bon"},
    %{id: 2, name: "Neutre Bon"},
    %{id: 3, name: "Chaotique Bon"},
    %{id: 4, name: "Loyal Neutre"},
    %{id: 5, name: "Neutre"},
    %{id: 6, name: "Chaotique Neutre"},
    %{id: 7, name: "Loyal Mauvais"},
    %{id: 8, name: "Neutre Mauvais"},
    %{id: 9, name: "Chaotique Mauvais"}
  ]

  @subraces [
    %{id: 1, race_id: 1, name: "Tradition humaine"},
    %{id: 2, race_id: 1, name: "Héritier du Nord"},
    %{id: 3, race_id: 1, name: "Marchand voyageur"},
    %{id: 4, race_id: 2, name: "Haut-elfe"},
    %{id: 5, race_id: 2, name: "Elfe des bois"},
    %{id: 6, race_id: 2, name: "Elfe noir"},
    %{id: 7, race_id: 2, name: "Drow"},
    %{id: 8, race_id: 3, name: "Semi-elfe de la cour"},
    %{id: 9, race_id: 3, name: "Semi-elfe sauvage"},
    %{id: 10, race_id: 3, name: "Semi-elfe nomade"},
    %{id: 11, race_id: 4, name: "Nain de la chaîne"},
    %{id: 12, race_id: 4, name: "Nain des montagnes"},
    %{id: 13, race_id: 4, name: "Nain des profondeurs"},
    %{id: 14, race_id: 5, name: "Halfelin léger"},
    %{id: 15, race_id: 5, name: "Halfelin robuste"},
    %{id: 16, race_id: 5, name: "Halfelin forestier"},
    %{id: 17, race_id: 6, name: "Gnome forestier"},
    %{id: 18, race_id: 6, name: "Gnome des roches"},
    %{id: 19, race_id: 6, name: "Gnome tinker"},
    %{id: 20, race_id: 7, name: "Demi-orque brutal"},
    %{id: 21, race_id: 7, name: "Demi-orque farouche"},
    %{id: 22, race_id: 7, name: "Demi-orque guerrier"},
    %{id: 23, race_id: 8, name: "Tieffelin infernal"},
    %{id: 24, race_id: 8, name: "Tieffelin abyssal"},
    %{id: 25, race_id: 8, name: "Tieffelin démoniaque"},
    %{id: 26, race_id: 9, name: "Drow noble"},
    %{id: 27, race_id: 9, name: "Drow guerrière"},
    %{id: 28, race_id: 9, name: "Drow mystique"},
    %{id: 29, race_id: 10, name: "Githyanki de la lignée noble"},
    %{id: 30, race_id: 10, name: "Githyanki guerrier"},
    %{id: 31, race_id: 10, name: "Githyanki mystique"}
  ]

  @subclasses [
    %{id: 1, class_id: 1, name: "Berserker"},
    %{id: 2, class_id: 1, name: "Totem"},
    %{id: 3, class_id: 1, name: "Path of the Ancestral Guardian"},
    %{id: 4, class_id: 2, name: "College of Lore"},
    %{id: 5, class_id: 2, name: "College of Valor"},
    %{id: 6, class_id: 2, name: "Glamour"},
    %{id: 7, class_id: 3, name: "Vie"},
    %{id: 8, class_id: 3, name: "Connaissance"},
    %{id: 9, class_id: 3, name: "Guerre"},
    %{id: 10, class_id: 3, name: "Nature"},
    %{id: 11, class_id: 4, name: "Cercle de la Terre"},
    %{id: 12, class_id: 4, name: "Cercle du Feu"},
    %{id: 13, class_id: 4, name: "Cercle de la Lune"},
    %{id: 14, class_id: 5, name: "Champion"},
    %{id: 15, class_id: 5, name: "Battle Master"},
    %{id: 16, class_id: 5, name: "Gilded Defense"},
    %{id: 17, class_id: 6, name: "Voie de la Main Ouverte"},
    %{id: 18, class_id: 6, name: "Voie de la Tempête"},
    %{id: 19, class_id: 6, name: "Voie de la Mère Terre"},
    %{id: 20, class_id: 7, name: "Vengeance"},
    %{id: 21, class_id: 7, name: "Ancien"},
    %{id: 22, class_id: 7, name: "Dévotion"},
    %{id: 23, class_id: 8, name: "Golem Hunter"},
    %{id: 24, class_id: 8, name: "Hunt"},
    %{id: 25, class_id: 8, name: "Beast Master"},
    %{id: 26, class_id: 9, name: "Phantom"},
    %{id: 27, class_id: 9, name: "Thief"},
    %{id: 28, class_id: 9, name: "Assassin"},
    %{id: 29, class_id: 10, name: "Draconic Bloodline"},
    %{id: 30, class_id: 10, name: "Wild Magic"},
    %{id: 31, class_id: 11, name: "École d'Abjuration"},
    %{id: 32, class_id: 11, name: "École d'Enchantment"},
    %{id: 33, class_id: 11, name: "École d'Invocation"},
    %{id: 34, class_id: 12, name: "Le Pacte du Diable"},
    %{id: 35, class_id: 12, name: "Le Pacte de la Faucheuse"},
    %{id: 36, class_id: 12, name: "Le Pacte du Ciel"}
  ]

  @class_passives [
    %{id: 1, class_id: 1, name: "Rage renforcée"},
    %{id: 2, class_id: 1, name: "Instinct sauvage"},
    %{id: 3, class_id: 1, name: "Peau endurcie"},
    %{id: 4, class_id: 1, name: "Frappe brutale"},
    %{id: 5, class_id: 2, name: "Inspiration améliorée"},
    %{id: 6, class_id: 2, name: "Maîtrise musicale"},
    %{id: 7, class_id: 2, name: "Paroles galvanisantes"},
    %{id: 8, class_id: 2, name: "Esprit créatif"},
    %{id: 9, class_id: 3, name: "Canalisation divine"},
    %{id: 10, class_id: 3, name: "Guérison renforcée"},
    %{id: 11, class_id: 3, name: "Foi inébranlable"},
    %{id: 12, class_id: 3, name: "Protecteur sacré"},
    %{id: 13, class_id: 4, name: "Connexion naturelle"},
    %{id: 14, class_id: 4, name: "Forme sauvage améliorée"},
    %{id: 15, class_id: 4, name: "Peau végétale"},
    %{id: 16, class_id: 4, name: "Sagesse des anciens"},
    %{id: 17, class_id: 5, name: "Maîtrise martiale"},
    %{id: 18, class_id: 5, name: "Second souffle renforcé"},
    %{id: 19, class_id: 5, name: "Garde disciplinée"},
    %{id: 20, class_id: 5, name: "Frappe précise"},
    %{id: 21, class_id: 6, name: "Défense sans armure"},
    %{id: 22, class_id: 6, name: "Ki renforcé"},
    %{id: 23, class_id: 6, name: "Pas éclair"},
    %{id: 24, class_id: 6, name: "Discipline intérieure"},
    %{id: 25, class_id: 7, name: "Aura de courage"},
    %{id: 26, class_id: 7, name: "Châtiment renforcé"},
    %{id: 27, class_id: 7, name: "Serment inébranlable"},
    %{id: 28, class_id: 7, name: "Présence imposante"},
    %{id: 29, class_id: 8, name: "Chasseur attentif"},
    %{id: 30, class_id: 8, name: "Pisteur expert"},
    %{id: 31, class_id: 8, name: "Compagnon renforcé"},
    %{id: 32, class_id: 8, name: "Instinct de survie"},
    %{id: 33, class_id: 9, name: "Expertise améliorée"},
    %{id: 34, class_id: 9, name: "Frappe sournoise"},
    %{id: 35, class_id: 9, name: "Évasion"},
    %{id: 36, class_id: 9, name: "Pas silencieux"},
    %{id: 37, class_id: 10, name: "Métamagie renforcée"},
    %{id: 38, class_id: 10, name: "Réserve magique"},
    %{id: 39, class_id: 10, name: "Affinité élémentaire"},
    %{id: 40, class_id: 10, name: "Volonté surnaturelle"},
    %{id: 41, class_id: 11, name: "Récupération arcanique"},
    %{id: 42, class_id: 11, name: "Étude spécialisée"},
    %{id: 43, class_id: 11, name: "Concentration supérieure"},
    %{id: 44, class_id: 11, name: "Mémoire magique"},
    %{id: 45, class_id: 12, name: "Invocation occulte"},
    %{id: 46, class_id: 12, name: "Pacte renforcé"},
    %{id: 47, class_id: 12, name: "Maîtrise des maléfices"},
    %{id: 48, class_id: 12, name: "Volonté obscure"}
  ]

  def races, do: @races
  def classes, do: @classes
  def backgrounds, do: @backgrounds
  def alignments, do: @alignments

  def subraces_for(nil), do: []
  def subraces_for(race_id), do: Enum.filter(@subraces, &(&1.race_id == race_id))

  def subclasses_for(nil), do: []
  def subclasses_for(class_id), do: Enum.filter(@subclasses, &(&1.class_id == class_id))

  def class_passives_for(nil), do: []
  def class_passives_for(class_id), do: Enum.filter(@class_passives, &(&1.class_id == class_id))

  def get_race(id), do: Enum.find(@races, &(&1.id == id))
  def get_class(id), do: Enum.find(@classes, &(&1.id == id))
  def get_subrace(id), do: Enum.find(@subraces, &(&1.id == id))
  def get_subclass(id), do: Enum.find(@subclasses, &(&1.id == id))
  def get_class_passive(id), do: Enum.find(@class_passives, &(&1.id == id))

  def race_name(nil), do: nil
  def race_name(id), do: get_race(id) && get_race(id).name

  def class_name(nil), do: nil
  def class_name(id), do: get_class(id) && get_class(id).name

  def subrace_name(nil), do: nil
  def subrace_name(id), do: get_subrace(id) && get_subrace(id).name

  def subclass_name(nil), do: nil
  def subclass_name(id), do: get_subclass(id) && get_subclass(id).name

  def class_passive_name(nil), do: nil
  def class_passive_name(id), do: get_class_passive(id) && get_class_passive(id).name
end
