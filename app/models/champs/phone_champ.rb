# == Schema Information
#
# Table name: champs
#
#  id                             :integer          not null, primary key
#  data                           :jsonb
#  fetch_external_data_exceptions :string           is an Array
#  private                        :boolean          default(FALSE), not null
#  rebased_at                     :datetime
#  row                            :integer
#  type                           :string
#  value                          :string
#  value_json                     :jsonb
#  created_at                     :datetime
#  updated_at                     :datetime
#  dossier_id                     :integer
#  etablissement_id               :integer
#  external_id                    :string
#  parent_id                      :bigint
#  type_de_champ_id               :integer
#
class Champs::PhoneChamp < Champs::TextChamp
  validates :value,
    phone: {
      possible: true,
      allow_blank: true,
      message: I18n.t(:not_a_phone, scope: 'activerecord.errors.messages')
    }, unless: -> { Phonelib.valid_for_country?(value, :pf) }

  def to_s
    value.present? ? Phonelib.parse(value).full_national : ''
  end
end
