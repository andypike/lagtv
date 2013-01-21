class User < ActiveRecord::Base
  before_create { generate_token(:auth_token) }
  has_secure_password
  attr_accessible :email, :name, :password, :password_confirmation, :role, :active, :signature, :show_signature, :hide_others_signatures
  has_many :replays
  has_many :comments
  ROLES = %w{member analyst dev_team moderator community_manager admin}

  DEFAULT_FILTERS = {
    :page => 1, 
    :query => '', 
    :role => '', 
    :active => 'true'
  }

  validates :name,      :presence => true,
                        :uniqueness => true
  validates :password,  :presence => { :if => :password_required? },
                        :length => { :minimum => 6, :if => :password_required? }
  validates :email,     :uniqueness => true,
                        :presence => true, 
                        :email_format => true
  validates :role,      :presence => true, 
                        :inclusion => { :in => ROLES }

  ROLES.each do |r|
    define_method "#{r}?" do
      role == r
    end

    scope "#{r}", where("role like '%#{r}%'")
  end

  def to_s
    name
  end

  def self.build(params)
    user = User.new(params)
    user.role = "member"
    user.active = true
    user.forem_state = "approved" # all members can post in the forums
    user
  end

  def can_read_forem_forums?
    true
  end

  def can_moderate_forem_forum?(forum)
    self.admin? || self.community_manager? || self.moderator? || self.dev_team?
  end

  def self.find_by_email(email_address)
    User.where('email ilike ?', email_address).first
  end

  # roles is a space delineated string
  def self.find_all_by_role(roles, limit, offset)
    cond = roles.inject('') {|r, str| str += "role LIKE '%#{r}%' AND"}.sub(/ AND$/, '')
    User.all(:conditions => cond, :limit => limit, :offset => offset)
  end

  def self.count_by_role(roles, limit, offset)
    cond = roles.inject('') {|r, str| str += "role LIKE '%#{r}%' AND"}.sub(/ AND$/, '')
    User.all(:conditions => cond, :limit => limit, :offset => offset)
  end

  def self.all_paged(options = {})
    options = options.reverse_merge(DEFAULT_FILTERS)

    query = "%#{options[:query]}%"
    users = self.paginate(:page => options[:page], :per_page => 25).order('created_at DESC')
    users = users.where("name ilike ? or email ilike ?", query, query) if options[:query].present?
    users = users.where(:role => options[:role]) if options[:role].present?
    users = users.where(:active => options[:active] == 'true') if options[:active].present?
    
    users
  end

  def send_password_reset
    generate_token(:password_reset_token)
    save!
    UserMailer.password_reset(self).deliver
  end

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end

  def reached_weekly_replay_limit?
    self.replays.where(:created_at => 7.days.ago..Time.now.utc).count >= Replay::WEEKLY_UPLOAD_LIMIT
  end

  def build_replay(replay_args)
    raise "Weekly upload limit exceeded" if self.reached_weekly_replay_limit?

    replay = self.replays.build(replay_args)
    replay.status = 'new'
    replay.expires_at = Time.now.utc + Replay::EXPIRY_DAYS.days
    replay
  end

  def avatar_url(size)
    Gravatar.url(email, size)
  end

  private
    def password_required?
      password_digest.blank? || !password.blank?
    end
end