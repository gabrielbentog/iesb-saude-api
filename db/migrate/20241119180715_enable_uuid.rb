class EnableUuid < ActiveRecord::Migration[8.0]
  def change
    enable_extension 'pgcrypto'  unless extension_enabled?('pgcrypto')
    enable_extension 'uuid-ossp' unless extension_enabled?('uuid-ossp')
  end
end