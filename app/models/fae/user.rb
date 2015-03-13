module Fae
  class User < ActiveRecord::Base

    include Fae::UserConcern

    # Include default devise modules. Others available are:
    # :registerable, :confirmable, :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable,
           :recoverable, :rememberable, :trackable, :validatable

    belongs_to :role

    validates_presence_of :first_name, :email, :role
    validates_uniqueness_of :email, message: 'That email address is already in use. Give another one a go.'
    validates :password,
      confirmation: true,
      length: { minimum: 8 }
    validates :role_id, presence: true

    default_scope { order(:first_name, :last_name) }

    scope :public_users, -> { joins(:role).where.not('fae_roles.name = ?', 'super admin') }
    scope :live_super_admins, -> { joins(:role).where(active: true, fae_roles: { name: 'super admin' }) }

    def super_admin?
      role.name == 'super admin'
    end

    def admin?
      role.name == 'admin'
    end

    def user?
      role.name == 'user'
    end

    def full_name
      "#{first_name} #{last_name}"
    end

    # Called by Devise to see if an user can currently be signed in
    def active_for_authentication?
      active? && super
    end

    # Called by Devise to get the proper error message when an user cannot be signed in
    def inactive_message
      !active? ? :inactive : super
    end
  end
end
