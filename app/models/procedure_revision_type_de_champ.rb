# == Schema Information
#
# Table name: procedure_revision_types_de_champ
#
#  id               :bigint           not null, primary key
#  position         :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  parent_id        :bigint
#  revision_id      :bigint           not null
#  type_de_champ_id :bigint           not null
#
class ProcedureRevisionTypeDeChamp < ApplicationRecord
  belongs_to :revision, class_name: 'ProcedureRevision'
  belongs_to :type_de_champ

  belongs_to :parent, class_name: 'ProcedureRevisionTypeDeChamp', optional: true
  has_many :revision_types_de_champ, -> { ordered }, foreign_key: :parent_id, class_name: 'ProcedureRevisionTypeDeChamp', inverse_of: :parent, dependent: :destroy
  scope :root, -> { where(parent: nil) }
  scope :ordered, -> { order(:position) }
  scope :revision_ordered, -> { order(:revision_id) }
  scope :public_only, -> { joins(:type_de_champ).where(types_de_champ: { private: false }) }
  scope :private_only, -> { joins(:type_de_champ).where(types_de_champ: { private: true }) }

  before_create :set_position

  def private?
    type_de_champ.private?
  end

  private

  def set_position
    self.position ||= begin
      types_de_champ = (private? ? revision.revision_types_de_champ_private : revision.revision_types_de_champ).filter(&:persisted?)

      if types_de_champ.present?
        types_de_champ.last.position + 1
      else
        0
      end
    end
  end
end
