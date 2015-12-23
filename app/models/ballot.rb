class Ballot < ActiveRecord::Base
  #----------------------------------------------------------------------------
  # Validations
  #------------
  validates :instructions,  :presence => true
  validates :voting_system_type, :presence => true
  validates :starts_at, :presence => true
  validates :ends_at,   :presence => true

  #----------------------------------------------------------------------------
  # Associations
  #-------------
  has_many :ballot_registration_fields
  has_many :candidates
  has_many :votes

  #----------------------------------------------------------------------------
  # Callbacks
  #----------
  before_create :generate_uuid

  #----------------------------------------------------------------------------

  private

  # See: https://github.com/rails/rails/blob/master/activerecord/lib/active_record/secure_token.rb
  # for why we implement it this way.
  def generate_uuid
    self.uuid = SecureRandom.uuid
  end
end
