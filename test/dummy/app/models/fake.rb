class Fake < ApplicationRecord

  validates :name,
    length: 2..20

end
