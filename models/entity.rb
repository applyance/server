module Applyance
  class Entity < Sequel::Model

    include Applyance::Lib::Attachments
    include Applyance::Lib::Locations

    many_to_one :domain, :class => :'Applyance::Domain'
    many_to_one :logo, :class => :'Applyance::Attachment'
    many_to_one :location, :class => :'Applyance::Location'
    many_to_one :parent, :class => :'Applyance::Entity'

    one_to_many :reviewers, :class => :'Applyance::Reviewer'
    one_to_many :reviewer_invites, :class => :'Applyance::ReviewerInvite'
    one_to_many :entities, :class => :'Applyance::Entity', :key => :parent_id

    one_to_many :spots, :class => :'Applyance::Spot'
    one_to_many :templates, :class => :'Applyance::Template'
    one_to_many :pipelines, :class => :'Applyance::Pipeline'
    one_to_many :labels, :class => :'Applyance::Label'

    many_to_many :definitions, :class => :'Applyance::Definition'
    many_to_many :blueprints, :class => :'Applyance::Blueprint'
    many_to_many :applications, :class => :'Applyance::Application'

    def validate
      super
      validates_presence :name
    end

  end
end
