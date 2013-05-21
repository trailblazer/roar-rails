unless defined? Mime::HAL
  Mime::Type.register 'application/json+hal', :hal

  ActionController::Renderers.add :hal do |hal, options|
    hal = hal.to_hal(options) unless hal.kind_of?(String)
    hal = "#{options[:callback]}(#{hal})" unless options[:callback].blank?
    self.content_type ||= Mime::HAL
    self.response_body  = hal
  end
end
