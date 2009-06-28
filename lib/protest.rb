require 'protest/context'
require 'protest/assertion'

module Kernel
  def context(*args, &block)
    Protest.context(*args, &block)
  end
end
