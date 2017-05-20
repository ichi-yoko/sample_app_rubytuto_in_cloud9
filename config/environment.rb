# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

# Refer to http://spica350.hatenablog.com/entry/2017/03/28/215205 for CarrierWave to change user's picture
require 'carrierwave/orm/activerecord'