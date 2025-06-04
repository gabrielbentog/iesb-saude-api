require_relative '../../app/serializers/adapter/data_adapter'

ActiveModelSerializers.config.adapter = :data
ActiveModelSerializers.config.key_transform = :camel_lower
