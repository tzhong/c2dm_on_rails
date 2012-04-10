# Represents an Android phone.
# An C2dm::Device can have many C2dm::Notification.
# 
# In order for the C2dm::Feedback system to work properly you *MUST*
# touch the <tt>last_registered_at</tt> column everytime someone opens
# your application. If you do not, then it is possible, and probably likely,
# that their device will be removed and will no longer receive notifications.
# 
# Example:
#   Device.create(:registration_id => 'FOOBAR')
class C2dm::Device < ActiveRecord::Base


  # If derived for C2dm::Base a C2dmBase table would be required
  # in DB, which throws an error when creating a device instance.
  # 
  def self.table_name # :nodoc:
    self.to_s.gsub("::", "_").tableize
  end
  
  has_many :notifications, :class_name => 'C2dm::Notification', :dependent => :destroy
  
  validates_presence_of :registration_id
  validates_uniqueness_of :registration_id
  
  before_save :set_last_registered_at
  
  # The <tt>feedback_at</tt> accessor is set when the 
  # device is marked as potentially disconnected from your
  # application by Google.
  attr_accessor :feedback_at
  
  private
  def set_last_registered_at
    self.last_registered_at = Time.now if self.last_registered_at.nil?
  end
  
end
