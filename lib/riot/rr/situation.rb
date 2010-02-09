module Riot
  module RR

    class Space < ::RR::Space
      def initialize
        super
        @bootstrap = Hash.new([])
      end
    
      def memoize
        %w[double method_missing singleton_method_added].each { |doubler| memoize_hash(doubler) }
        @bootstrap[:ordered_doubles] = @ordered_doubles.clone
      end
    
      def reset
        super
        %w[double method_missing singleton_method_added].each { |doubler| recall_hash(doubler) }
        @ordered_doubles = @bootstrap[:ordered_doubles]
      end
    private
      # [ [uid, [method_name, double]], [uid1, [method_name1, double1]], ... ]
      def memoize_hash(name)
        @bootstrap[name] = instance_variable_get("@#{name}_injections").map do |uid, doubles|
          [uid, doubles.map { |method_name, double| [method_name, double.clone] }]
        end
      end
      
      def recall_hash(name)
        hash = instance_variable_get("@#{name}_injections")
        @bootstrap[name].each do |uid, doubles|
          hash[uid] ||= {}
          doubles.each { |method_name, double| hash[uid][method_name] = double}
        end
      end
    end

    class Situation < Riot::Situation
      include ::RR::Adapters::RRMethods
      def initialize
        ::RR::Space.instance = Riot::RR::Space.new
        @memoized = false
      end

      def evaluate(&block)
        unless @memoized
          ::RR::Space.instance.memoize
          @memoized = true
        end
        super(&block)
      end

    end # Situation
  end # RR
end # Riot