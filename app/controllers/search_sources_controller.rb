class SearchSourcesController < ApplicationController

  before_filter :login_required, :only => [ :list, :index ]

  before_filter :set_page_title

  permit "site_admin"

  active_scaffold :search_sources do |config|
    config.label = I18n.t('search_sources_controller.title')

    list.sorting = { :position => 'ASC' }

    config.columns = [:title, :source_type, :base_url, :more_link_base_url, :limit, :cache_interval]
    config.list.columns.exclude [:or_syntax]

    options = { :type => :record, :inline => false }
    # images_tag and @template.image_tag arn't available in this scope
    sort_arrow_up = "<img src='/images/arrow_up.gif' title='#{I18n.t('search_sources_controller.move_higher_title')}' alt='#{I18n.t('search_sources_controller.move_higher_title')}' style='border:none;' />"
    sort_arrow_down = "<img src='/images/arrow_down.gif' title='#{I18n.t('search_sources_controller.move_lower_title')}' alt='#{I18n.t('search_sources_controller.move_lower_title')}' style='border:none;' />"
    config.action_links.add sort_arrow_up, options.merge(:action => 'move_higher', :crud_type => :move_higher)
    config.action_links.add sort_arrow_down, options.merge(:action => 'move_lower', :crud_type => :move_lower)

    config.columns[:title].required = true
    config.columns[:title].description = I18n.t('search_sources_controller.source_title_description')

    config.columns[:source_type].required = true
    config.columns[:source_type].description = I18n.t('search_sources_controller.source_type_description')
    config.columns[:source_type].form_ui = :select
    config.columns[:source_type].options = SearchSource.acceptable_source_types.collect { |st| [st.humanize, st] }

    config.columns[:base_url].required = true
    config.columns[:base_url].description = I18n.t('search_sources_controller.source_base_url_description')

    config.columns[:more_link_base_url].label = I18n.t('search_sources_controller.source_more_link_base_url_label')
    config.columns[:more_link_base_url].description = I18n.t('search_sources_controller.source_more_link_base_url_description')

    config.columns[:limit].required = true
    config.columns[:limit].description = I18n.t('search_sources_controller.source_limit_description')

    config.columns[:cache_interval].required = true
    config.columns[:cache_interval].description = I18n.t('search_sources_controller.source_cache_interval_description')

    config.columns << [:or_syntax]
    config.columns[:or_syntax].label = I18n.t('search_sources_controller.or_syntax_label')
    config.columns[:or_syntax].description = I18n.t('search_sources_controller.or_syntax_description')
  end

  def move_higher
    search_source = SearchSource.find_by_id(params[:id])
    search_source.move_higher
    flash[:notice] = I18n.t('search_sources_controller.move_higher.moved_higher')
    redirect_to :urlified_name => @site_basket.urlified_name, :action => 'list'
  end

  def move_lower
    search_source = SearchSource.find_by_id(params[:id])
    search_source.move_lower
    flash[:notice] = I18n.t('search_sources_controller.move_lower.moved_lower')
    redirect_to :urlified_name => @site_basket.urlified_name, :action => 'list'
  end

  private

  # A method used by active scaffold before creating/updating a record
  # we have to set the or_syntax here ourselves because either rails or
  # active scaffold does not set or_syntax automatically when it is a hash
  def before_create_save(record)
    record.or_syntax = params[:record][:or_syntax]
  end

  def before_update_save(record)
    record.or_syntax = params[:record][:or_syntax]
  end

  def set_page_title
    @title = t('search_sources_controller.title')
  end
end
