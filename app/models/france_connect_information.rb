# == Schema Information
#
# Table name: france_connect_informations
#
#  id                            :integer          not null, primary key
#  birthdate                     :date
#  birthplace                    :string
#  data                          :jsonb
#  email_france_connect          :string
#  family_name                   :string
#  gender                        :string
#  given_name                    :string
#  merge_token                   :string
#  merge_token_created_at        :datetime
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  france_connect_particulier_id :string
#  user_id                       :integer
#
class FranceConnectInformation < ApplicationRecord
  belongs_to :user, optional: true

  validates :france_connect_particulier_id, presence: true, allow_blank: false, allow_nil: false

  def associate_user!
    begin
      user = User.create!(
        email: email_france_connect.downcase,
        password: Devise.friendly_token[0, 20],
        confirmed_at: Time.zone.now
      )
    rescue ActiveRecord::RecordNotUnique
      # ignore this exception because we check before is user is nil.
      # exception can be raised in race conditions, when FranceConnect calls callback 2 times.
      # At the 2nd call, user is nil but exception is raised at the creation of the user
      # because the first call has already created a user
    end

    update_attribute('user_id', user.id)
    touch # needed to update updated_at column
  end
end
