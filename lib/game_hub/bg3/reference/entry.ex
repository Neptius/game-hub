defmodule GameHub.Bg3.Reference.Entry do
  @moduledoc """
  Représente une donnée de référence simulant une ligne de base de données
  (id auto-incrémenté + name), en attendant la persistance réelle en base.
  """

  @enforce_keys [:id, :name]
  defstruct [:id, :name]

  @type t :: %__MODULE__{id: pos_integer(), name: String.t()}
end
