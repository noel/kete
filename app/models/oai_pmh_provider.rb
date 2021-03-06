require 'oai'
if IS_CONFIGURED && defined?(Kete.provide_oai_pmh_repository?) && Kete.provide_oai_pmh_repository?
  class OaiPmhRepositoryProvider < OAI::Provider::Base
    repository_name Kete.pretty_site_name
    repository_url "#{SITE_URL}oai_pmh_repository"
    record_prefix '' # this may need to be ZoomDb.zoom_id_stub.chop
    admin_email User.find(1).email
    source_model OAI::Provider::ZoomDbWrapper.new(ZoomDb.find_by_database_name('public'), :limit => 1000)
  end
else
    class OaiPmhRepositoryProvider < OAI::Provider::Base
    end
end
