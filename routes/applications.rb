module Applyance
  module Routing
    module Applications

      module Protection

        # Protection to reviewers
        def to_reviewers(unit)
          lambda do |account|
            unit.reviewers.collect(&:account_id).include?(account.id)
          end
        end

        # Protection to reviewers
        def to_full_access_reviewers(unit)
          lambda do |account|
            unit.reviewers_dataset.where(:access_level => "full").collect(&:account_id).include?(account.id)
          end
        end

        # Protection to reviewers or self
        def to_reviewers_or_self(application)
          lambda do |account|
            return true if account.id == application.submitter_id
            application.unit.reviewers.collect(&:account_id).include?(account.id)
          end
        end

      end

      def self.registered(app)

        app.extend(Applyance::Routing::Applications::Protection)

        # List applications
        app.get '/units/:id/applications', :provides => [:json] do
          @unit = Unit.first(:id => params[:id])
          protected! app.to_reviewers(@unit)
          @applications = Unit.applications
          rabl :'applications/index'
        end

        # Create a new application
        # Open to the public
        app.post '/applications', :provides => [:json] do
          @application = Application.make(params)
          status 201
          rabl :'applications/show'
        end

        # Get application by Id
        # Must be a reviewer or application owner
        app.get '/applications/:id', :provides => [:json] do
          @application = Application.first(:id => params[:id])
          protected! app.to_reviewers_or_self(@application)
          rabl :'applications/show'
        end

        # Delete a entity by Id
        # Must be a full access reviewer
        app.delete '/applications/:id', :provides => [:json] do
          @application = Application.first(:id => params[:id])
          protected! app.to_full_access_reviewers(@application)

          @application.remove_all_spots
          @application.remove_all_labels
          @application.remove_all_reviewers

          @application.activities_dataset.destroy
          @application.threads_dataset.destroy
          @application.notes_dataset.destroy
          @application.ratings_dataset.destroy
          @application.fields_dataset.destroy
          @application.destroy

          204
        end

      end
    end
  end
end