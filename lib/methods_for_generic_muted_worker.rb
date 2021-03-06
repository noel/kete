# holds info about what we should mix into GenericMutedWorker
# dynamically add includes to this module to get your methods
# included in GenericMutedWorker
module MethodsForGenericMutedWorker
  unless included_modules.include? MethodsForGenericMutedWorker
    include ActionController::Caching::Fragments
    include CacheControllerHelpers
    include WorkerControllerHelpers

    def self.included(klass)
      klass.extend DefaultUrlOptions
    end
  end
end
