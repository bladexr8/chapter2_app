class User < ActiveRecord::Base
  # validations
  validates :name,  presence: true, length: { maximum: 50 }
  # Ruby constant to define regex format of email address
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, 
  format: { with: VALID_EMAIL_REGEX },
  uniqueness: { case_sensitive: false }
  
  # convert email address to lower case before a record is saved
  before_save { self.email = email.downcase }
  
  # create a remember token immediately before creating a new user in the database
  before_create :create_remember_token
  
  # add support for secure passwords
  # 1. adds virtual password and password_confirmation attributes
  # 2. makes password(s) mandatory fields
  # 3. adds an authentication method to compare an encrypted password
  #    to password_digest to authenticate users
  has_secure_password
  # ensure password is at least 6 characters
  validates :password, length: { minimum: 6 }
  
  # class methods to support encryption of session token
  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end
  
  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end
  
  private
  
  def create_remember_token
    # Create the token
    self.remember_token = User.encrypt(User.new_remember_token)
  end
  
end
