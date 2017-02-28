# A ballot is an election process within an organization.
class Ballot < ActiveRecord::Base
  self.table_name='ballot'
  #----------------------------------------------------------------------------
  # Validations
  #------------
  validates :instructions,  :presence => true
  validates :voting_system_type, :presence => true
  validates :starts_at, :presence => true
  validates :ends_at,   :presence => true

  module VotingTypes
    RANGE = "range"
  end

  #----------------------------------------------------------------------------
  # Associations
  #-------------
  has_many :ballot_registration_fields, -> { order("position ASC") }
  has_many :ballot_papers
  has_many :votes, :through => :ballot_papers
  has_many :ballot_configurations, -> { order("position ASC")}
  has_many :candidates

  #----------------------------------------------------------------------------
  # Callbacks
  #----------
  before_create :generate_uuid

  #----------------------------------------------------------------------------

  # A ballot is said to be finished if none of the ballot papers are in draft mode.
  # TODO: This definition does not take into account ballot papers that were created
  # but not worked on. In other words, a ballot's state depends on all voters doing
  # their part... not a good way to define finished state...
  def finished?
    self.ballot_papers.where(:status => BallotPaper::Status::DRAFT).count == 0
  end

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

  before_save :default_values
  def default_values
    self.removed ||= false
    self.status ||= 0;
    self.require_registration ||= true;
    self.user_uuid_as_signature ||= false;
    self.decision_type ||= 'BINDING';
    true
  end
end
