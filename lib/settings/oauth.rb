module Settings
  class OAuth < Settingslogic
    source "#{Rails.root}/config/oauth.yml"
    namespace Rails.env
  end
end