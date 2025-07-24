# app/models/current.rb
class Current < ActiveSupport::CurrentAttributes
  # Liste tudo que gostaria de acessar em qualquer lugar do código
  attribute :user, :request_id, :tenant

  # Use callbacks se precisar normalizar/limpar algo
  resets do
    Time.zone = nil
  end
end
