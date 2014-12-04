module Wisper
  module ActiveRecord
    module Publisher
      extend ActiveSupport::Concern

      included do
        include Wisper::Publisher

        after_validation :after_validation_broadcast

        before_create    :before_create_broadcast
        before_update    :before_update_broadcast
        before_destroy   :before_destroy_broadcast

        after_commit     :after_create_broadcast,  on: :create
        after_commit     :after_update_broadcast,  on: :update
        after_commit     :after_destroy_broadcast, on: :destroy

        after_rollback   :after_rollback_broadcast
      end

      def commit(_attributes = nil)
        warn "[DEPRECATED] use save, create, update_attributes as usual"
        assign_attributes(_attributes) if _attributes.present?
        save
      end

      module ClassMethods
        def commit(_attributes = nil)
          warn "[DEPRECATED] use save, create, update_attributes as usual"
          new(_attributes).save
        end
      end

      private

      def after_validation_broadcast
        action = new_record? ? 'create' : 'update'
        broadcast("#{action}_#{self.class.model_name.param_key}_failed", self) unless errors.empty?
      end

      def after_create_broadcast
        broadcast(:after_create, self)
        broadcast("create_#{self.class.model_name.param_key}_successful", self)
      end

      def before_create_broadcast
        broadcast(:before_create, self)
      end

      def after_update_broadcast
        broadcast(:after_update, self)
        broadcast("update_#{self.class.model_name.param_key}_successful", self)
      end

      def before_update_broadcast
        broadcast(:before_update, self)
      end

      def after_destroy_broadcast
        broadcast(:after_destroy, self)
        broadcast("destroy_#{self.class.model_name.param_key}_successful", self)
      end

      def before_destroy_broadcast
        broadcast(:before_destroy, self)
      end

      def after_rollback_broadcast
        broadcast(:after_rollback, self)
      end
    end
  end
end
