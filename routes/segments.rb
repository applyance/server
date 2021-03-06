module Applyance
  module Routing
    module Segments

      def self.registered(app)

        # List segments by reviewer
        # Only owners can do this
        app.get '/reviewers/:id/segments', :provides => [:json] do
          @reviewer = Reviewer.first(:id => params[:id])
          protected! app.to_account(@reviewer.account)
          @segments = @reviewer.segments
          rabl :'segments/index'
        end

        # Create a new segment
        # Must be the owner
        app.post '/reviewers/:id/segments', :provides => [:json] do
          @reviewer = Reviewer.first(:id => params[:id])
          protected! app.to_account(@reviewer.account)

          @segment = Segment.new
          @segment.set(:reviewer_id => @reviewer.id)
          @segment.set_fields(params, ['name', 'dsl'], :missing => :skip)
          @segment.save

          status 201
          rabl :'segments/show'
        end

        # Get segment by Id
        app.get '/segments/:id', :provides => [:json] do
          @segment = Segment.first(:id => params['id'])
          protected! app.to_account(@segment.reviewer.account)

          rabl :'segments/show'
        end

        # Update a segment by Id
        # Must be the owner
        app.put '/segments/:id', :provides => [:json] do
          @segment = Segment.first(:id => params['id'])
          protected! app.to_account(@segment.reviewer.account)

          @segment.update_fields(params, ['name', 'dsl'], :missing => :skip)
          rabl :'segments/show'
        end

        # Delete a segment by Id
        # Must be the owner
        app.delete '/segments/:id', :provides => [:json] do
          @segment = Segment.first(:id => params['id'])
          protected! app.to_account(@segment.reviewer.account)

          @segment.destroy

          204
        end

      end
    end
  end
end
