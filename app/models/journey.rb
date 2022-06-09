class Journey < ApplicationRecord
    validates :id, numericality: { only_integer: true }
    validates :people, numericality: { only_integer: true }
end
