
# Whitelist the attributes for delayed_job
ActiveRecord::Base.send(:attr_accessible, :priority)
ActiveRecord::Base.send(:attr_accessible, :payload_object)
