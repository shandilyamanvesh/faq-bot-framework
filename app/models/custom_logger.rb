class CustomLogger < ApplicationRecord

  serialize :error_messages, Hash
  serialize :objects, Hash
  serialize :links, Hash

  scope :unfinished, -> { where("completed_at IS NULL") }

  def self.custom_logger
    @@custom_logger ||= new
  end

  def self.log(scope="", options={}, &block)
    custom_logger.log scope, options, &block
  end

  def log(scope="", options={}, &block)
    self.namespace ||= options[:namespace]

    if block_given?
      update_attributes(started_at: started_at || Time.now, scope: scope)
      begin
        if block.arity == 1
          yield self
        else
          yield
        end
      rescue => error
        add_error error
        raise error
      ensure
        update_attribute(:completed_at, Time.now)
        @@custom_logger = CustomLogger.new
      end
    else
      self.scope = scope
    end
    self
  end

  def self.add(value)
    custom_logger.add(value)
  end

  def add(value)
    self.message ||= ""
    self.message += "#{value.truncate(100)}\n"
    save
  rescue
  end

  def add_link(label="Link", href)
    self.links ||= {}
    key = label
    
    self.links[key] = href
    update_attribute(:links, self.links)
  end

  def self.add_error(error)
    custom_logger.add_error error
  end

  def add_error(error)
    error_message = "#{error.class.to_s}: #{error.message}\n"
    error_message += error.backtrace.join("\n")
    add_error_messages(error_message)
  end

  def add_error_messages(error_message)
    self.error_messages ||= {}
    self.error_messages[error_message] = (self.error_messages[error_message]) ? self.error_messages[error_message] + 1 : 1
    update_attributes(error_messages: self.error_messages)
  end

  def self.add_object(object)
    custom_logger.add_object object
  end

  def add_object(object)
    self.objects ||= {}
    key = object.class.to_s
    if self.objects.key?(key)
      self.objects[key] |= [object.id]
    else
      self.objects[key] = [object.id]
    end
    update_attribute(:objects, self.objects)
  end

  def add_objects(objects)
    objects.map{|o| add_object(o)}
  end

  def set_alert_level(level)
    update_attribute(:alert_level, level) if level > self.alert_level
  end
end
