require_relative '../../app/serializers/active_model_serializers/adapter/data_adapter'

ActiveModelSerializers.config.adapter = :data_adapter
ActiveModelSerializers.config.key_transform = :camel_lower
