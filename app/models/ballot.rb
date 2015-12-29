# A ballot is an election process within an organization.
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
  has_many :ballot_registration_fields, -> { order("position ASC") }
  has_many :ballot_papers
  has_many :votes, :through => :ballot_papers

  #----------------------------------------------------------------------------
  # Callbacks
  #----------
  before_create :generate_uuid

  #----------------------------------------------------------------------------

  protected

  def self.permitted_params
    [:instructions, :password, :notes, :voting_system_type, :starts_at, :ends_at]
  end

  #----------------------------------------------------------------------------

  private

  # See: https://github.com/rails/rails/blob/master/activerecord/lib/active_record/secure_token.rb
  # for why we implement it this way.
  def generate_uuid
    return if self.uuid?
    self.uuid = SecureRandom.uuid
  end
end
