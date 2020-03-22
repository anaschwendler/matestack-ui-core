describe "Turbolinks integration", type: :feature, js: true do

  class TestController < ActionController::Base

    before_action :check_params

    def check_params
      expect_params(params.permit!.to_h)
    end

    def expect_params(params)
    end

  end

  it "Matestack can be used with turbolinks" do

    module Apps
    end

    class Apps::TurbolinksTest < Matestack::Ui::App
      def response
        components {
          nav do
            link path: :turbolinks1_path do
              button text: "Link to Page 1"
            end
            transition path: :turbolinks2_path do
              button text: "Transition to Page 2"
            end
            link path: :turbolinks3_path do
              button text: "Link to Page 3"
            end
          end
          main do
            page_content
          end
        }
      end
    end

    module Pages::TurbolinksTest
    end

    class Pages::TurbolinksTest::Page1 < Matestack::Ui::Page
      def response
        components {
          plain "Hello from matestack with turbolinks - Page 1"
        }
      end
    end
    class Pages::TurbolinksTest::Page2 < Matestack::Ui::Page
      def response
        components {
          plain "Hello from matestack with turbolinks - Page 2"
        }
      end
    end
    class Pages::TurbolinksTest::Page3 < Matestack::Ui::Page
      def response
        components {
          plain "Hello from matestack with turbolinks - Page 3"
          action action_config do
            button text: "click me"
          end
        }
      end

      def action_config
        return {
          method: :post,
          path: :action_test_path,
          data: {
            foo: "bar"
          }
        }
      end
    end

    Rails.application.routes.append do
      get '/turbolinks1', to: 'turbolinks_test#page1', as: :turbolinks1
      get '/turbolinks2', to: 'turbolinks_test#page2', as: :turbolinks2
      get '/turbolinks3', to: 'turbolinks_test#page3', as: :turbolinks3
      post '/action_test', to: 'action_test#test'
    end
    Rails.application.reload_routes!

    class TurbolinksTestController < ActionController::Base
      layout "application_with_turbolinks"

      include Matestack::Ui::Core::ApplicationHelper

      def page1
        responder_for(Pages::TurbolinksTest::Page1)
      end
      def page2
        responder_for(Pages::TurbolinksTest::Page2)
      end
      def page3
        responder_for(Pages::TurbolinksTest::Page3)
      end
    end

    class ActionTestController < TestController

      def test
        render json: {}, status: 200
      end

    end
    allow_any_instance_of(ActionTestController).to receive(:expect_params)


    visit "/turbolinks1"

    expect(page).to have_text "Hello from matestack with turbolinks - Page 1"

    click_button "Transition to Page 2"

    expect(page).to have_text "Hello from matestack with turbolinks - Page 2"

    click_button "Link to Page 1"

    expect(page).to have_text "Hello from matestack with turbolinks - Page 1"

    click_button "Transition to Page 2"

    expect(page).to have_text "Hello from matestack with turbolinks - Page 2"

    click_button "Link to Page 1"

    expect(page).to have_text "Hello from matestack with turbolinks - Page 1"

    visit "/turbolinks3"

    expect(page).to have_text "Hello from matestack with turbolinks - Page 3"

    expect_any_instance_of(ActionTestController).to receive(:expect_params)
      .with(hash_including(:foo => "bar"))

    click_button "click me"

    expect(page).to have_text "Hello from matestack with turbolinks - Page 3"
  end
end
