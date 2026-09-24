defmodule GameHub.Bg3.Reference do
  @moduledoc """
  Centralise les données statiques BG3 (races, classes, sous-classes,
  historiques, alignements) afin d'être réutilisées par les différents
  contextes/LiveViews (character builder, générateur de noms, progression).
  """

  @races [
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

  @classes [
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

  @backgrounds [
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

  @alignments [
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

  def races, do: @races
  def classes, do: @classes
  def backgrounds, do: @backgrounds
  def alignments, do: @alignments

  def subraces_for(race), do: Map.get(@subraces, race, [])
  def subclasses_for(class), do: Map.get(@subclasses, class, [])
end
