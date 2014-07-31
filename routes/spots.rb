module Applyance
  module Routing
    module Spots

      module Protection

        # Protection to admins
        def to_admins(entity)
          lambda do |account|
            entity.reviewers_dataset.where(:scope => "admin").collect(&:account_id).include?(account.id)
          end
        end

      end

      def self.registered(app)

        app.extend(Applyance::Routing::Spots::Protection)

        # List spots
        app.get '/entities/:id/spots', :provides => [:json] do
          @entity = Entity.first(:id => params['id'])
          @spots = @entity.spots
          rabl :'spots/index'
        end

        # Create a new unit
        # Must be a full access reviewer
        app.post '/entities/:id/spots', :provides => [:json] do
          @entity = Entity.first(:id => params['id'])
          protected! app.to_admins(@entity)

          @spot = Spot.new
          @spot.set(:entity_id => @entity.id)
          @spot.set_fields(params, ['name', 'detail', 'status'], :missing => :skip)
          @spot.save

          status 201
          rabl :'spots/show'
        end

        # Get spot by Id
        app.get '/spots/:id', :provides => [:json] do
          @spot = Spot.first(:id => params['id'])
          rabl :'spots/show'
        end

        # Update a spot by Id
        # Must be an admin
        app.put '/spots/:id', :provides => [:json] do
          @spot = Spot.first(:id => params['id'])
          protected! app.to_admins(@spot.entity)

          @spot.update_fields(params, ['name', 'detail', 'status'], :missing => :skip)
          rabl :'spots/show'
        end

        # Delete a spot by Id
        # Must be an admin
        app.delete '/spots/:id', :provides => [:json] do
          @spot = Spot.first(:id => params['id'])
          protected! app.to_admins(@spot.entity)

          @spot.remove_all_blueprints
          @spot.remove_all_applications

          @spot.destroy

          204
        end

      end
    end
  end
end
