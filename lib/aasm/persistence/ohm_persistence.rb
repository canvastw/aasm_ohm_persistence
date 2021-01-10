#require 'aasm/persistence/orm'
#require "aasm/persistence/base"
#require "ohm/callbacks"

module AASM
  module Persistence
    module OhmPersistence
      def self.included(base)
        base.send(:include, AASM::Persistence::Base)
        #base.extend AASM::Persistence::OhmPersistence::ClassMethods
        #base.send(:include, Ohm::Callbacks)
        base.send(:include, AASM::Persistence::OhmPersistence::InstanceMethods)
      end

      module ClassMethods
      #   def find_in_state(id, state, *args)
      #     find(aasm_column.to_sym => state)[id]
      #   end

      #   def count_in_state(state, *args)
      #     find(aasm_column.to_sym => state).count
      #   end
        def aasm_column(column_name)
          warn "[DEPRECATION] aasm_column is deprecated(Jan2021). Use aasm.attribute_name instead"
          aasm.attribute_name(column_name)
        end
      end

      module InstanceMethods
        #def initialize(*args)
        #  super
        #  aasm_ensure_initial_state
        #end
        def before_create
          super
          aasm_ensure_initial_state
        end

        # Writes <tt>state</tt> to the state column and persists it to the database
        #
        #   foo = Foo.find(1)
        #   foo.aasm.current_state # => :opened
        #   foo.close!
        #   foo.aasm.current_state # => :closed
        #   Foo.find(1).aasm.current_state # => :closed
        #
        # NOTE: intended to be called from an event

        # def aasm_write_state(state)
        #   old_value = self.send(self.class.aasm_column.to_sym)
        #   aasm_write_state_without_persistence(state)

        #   success = self.save

        #   unless success
        #     aasm_write_state_without_persistence(old_value)
        #     return false
        #   end

        #   true
        # end
        def aasm_write_state(state, name=:default)
          aasm_column = self.class.aasm(name).attribute_name
          puts "aasm_write_state - aasm_column: #{aasm_column.inspect}"
          puts "aasm_write_state - state: #{state.inspect}"
          #send("#{aasm_column}").value = state
          old_value = send("#{aasm_column}".to_sym)
          puts "aasm_write_state - old_value: #{old_value.inspect}"

          update(self.class.aasm(name).attribute_name.to_sym => state.to_s)

          unless self.valid?
            puts "aasm_write_state - not-valid, update to old_value: #{old_value.to_s}"
            update(self.class.aasm_column.to_sym => old_value.to_s)
            return false
          end

          true
        end

        # Writes <tt>state</tt> to the state column, but does not persist it to the database
        #
        #   foo = Foo.find(1)
        #   foo.aasm.current_state # => :opened
        #   foo.close
        #   foo.aasm.current_state # => :closed
        #   Foo.find(1).aasm.current_state # => :opened
        #   foo.save
        #   foo.aasm.current_state # => :closed
        #   Foo.find(1).aasm.current_state # => :closed
        #
        # NOTE: intended to be called from an event
        # def aasm_write_state_without_persistence(state)
        #   self.send(:"#{self.class.aasm_column}=", state.to_s)
        # end

      private

        # Ensures that if the aasm_state column is nil and the record is new
        # that the initial state gets populated before validation on create
        #
        #   foo = Foo.new
        #   foo.aasm_state # => nil
        #   foo.valid?
        #   foo.aasm_state # => "open" (where :open is the initial state)
        #
        #
        #   foo = Foo.find(:first)
        #   foo.aasm_state # => 1
        #   foo.aasm_state = nil
        #   foo.valid?
        #   foo.aasm_state # => nil
        #
        def aasm_ensure_initial_state
          #aasm.enter_initial_state if send(self.class.aasm_column).blank?
          #AASM::StateMachineStore.fetch(self.class, true).machine_names.each do |state_machine_name|
          #  aasm(state_machine_name).enter_initial_state if
          #    (new? || values.key?(self.class.aasm(state_machine_name).attribute_name)) &&
          #      send(self.class.aasm(state_machine_name).attribute_name).to_s.strip.empty?
          #end
          AASM::StateMachineStore.fetch(self.class, true).machine_names.each do |name|
            aasm_column = self.class.aasm(name).attribute_name
            puts "aasm_column: #{aasm_column.inspect}"
            aasm(name).enter_initial_state if send(self.class.aasm(name).attribute_name).blank?
            #aasm(name).enter_initial_state if !send(aasm_column).value || send(aasm_column).value.empty?
          end
        end
      end # InstanceMethods
    end
  end
end