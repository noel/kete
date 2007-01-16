class StillImage < ActiveRecord::Base
  # each topic or content item lives in exactly one basket
  belongs_to :basket

  # image files, including different sized versions of the original
  # are handled by ImageFile model
  has_many :image_files, :dependent => :delete_all
  has_one :original_file, :conditions => 'parent_id is null', :class_name => 'ImageFile'
  has_one :thumbnail_file, :conditions => "parent_id is not null and thumbnail = 'small_sq'", :class_name => 'ImageFile'
  has_many :resized_image_files, :conditions => 'parent_id is not null', :class_name => 'ImageFile'

  # this is where we handled "related to"
  has_many :content_item_relations, :as => :related_item, :dependent => :destroy
  has_many :topics, :through => :content_item_relations

  # this is where we handle contributed and created items by users
  has_many :contributions, :as => :contributed_item, :dependent => :delete_all
  # :select => "distinct contributions.role, users.*",
  # creator is intended to be just one, but we need :through functionality
  has_many :creators, :through => :contributions, :source => :user, :order => 'created_at' do
    def <<(user)
      begin
        Contribution.with_scope(:create => { :contributor_role => "creator", :version => 1}) { self.concat user }
      rescue
        logger.debug("what is contrib error: " + $!.to_s)
      end
    end
  end
  has_many :contributors, :through => :contributions, :source => :user, :order => 'created_at' do
    def <<(user)
      # TODO: figure out a better way of getting version
      begin
        Contribution.with_scope(:create => { :contributor_role => "contributor", :version => user.version}) { self.concat user }
      rescue
        logger.debug("what is contrib error: " + $!.to_s)
      end
    end
  end

  # a virtual attribute that holds the still_image's entire content (sans binary file)
  # as xml formated how we like it
  # for use by acts_as_zoom virtual_field_name, :raw => true
  # this virtual attribue will be populated/updated in our controller
  # in create and update
  # i.e. before save, which triggers our acts_as_zoom record being shot off to zebra
  attr_accessor :oai_record
  attr_accessor :basket_urlified_name
  acts_as_zoom :fields => [:oai_record], :save_to_public_zoom => ['localhost', 'public'], :raw => true, :additional_zoom_id_attribute => :basket_urlified_name

  acts_as_versioned
  validates_presence_of :title
  # this may change
  validates_uniqueness_of :title
  # TODO: add validation that prevents markup in short_summary
  # globalize stuff, uncomment later
  # translates :title, :description
end
