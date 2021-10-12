# A validator that merges errors from a relation with the errors of the parent.
#
# This fixes a shortcoming of Rails' `validate_associated`, which doesn't propagate the
# error message of the relation, and instead only reports an '<attribute> is invalid'
# message.
#
# Adapted from https://stackoverflow.com/a/31916721
#
# Usage:
#
# ```
# class Post < ApplicationRecord
#   has_one :user
#   validate :title, length: { minimum: 3 }
# end
#
# class User < ApplicationRecord
#   has_many :posts, validate: false
#   validate_associated_bubbling :posts
# end
#
# user.validate
# user.errors[:posts] # ['Title is too short']
# ```
class AssociatedBubblingValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    ((value.is_a?(Enumerable) || value.is_a?(ActiveRecord::Relation)) ? value : [value]).each do |v|
      unless v.valid?
        v.errors.full_messages.each do |msg|
          record.errors.add(attribute, msg, **options.merge(value: value))
        end
      end
    end
  end
end
