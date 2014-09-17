module Applyance
  module Routing
    module Webhooks

      def self.registered(app)

        app.post '/webhooks/stripe', :provides => [:json] do
          event_json = JSON.parse(request.body.read)

          puts "Handling webhook from Stripe with type, [#{event_json["type"]}]"
          puts "  ==  "
          puts event_json.inspect
          puts "  ==  "

          case event_json["type"]
          when "customer.subscription.updated"
            puts "  Handling a subscription update from Stripe."

          else
            puts "  Unknown event type from Stripe."
          end

          status 200
        end

      end
    end
  end
end