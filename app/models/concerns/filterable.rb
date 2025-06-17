module Filterable
  extend ActiveSupport::Concern

  class_methods do
    def apply_filters(params = {})
      results = all
      filters = params[:filter] || {}
      sort = params[:sort] || nil
      direction = params[:direction] || "asc"
      params_page = params[:page]

      # Filtros simples (por coluna)
      if filters.present?
        filters.each do |key, value|
          results = results.where(key => value) if column_names.include?(key.to_s)
        end
      end

      # Ordenação
      if sort.present? && column_names.include?(sort.to_s)
        direction = %w[asc desc].include?(direction) ? direction : "asc"
        results = results.order("#{sort} #{direction}")
      end

      # Paginação (com kaminari ou pagy)
      page = (params_page&.dig(:number) || 1).to_i
      per_page = (params_page&.dig(:size) || results.count).to_i
      results = results.page(page).per(per_page)

      results
    end
  end
end