# frozen_string_literal: true

module Api
  module V1
    class CustomerBaseController < BaseController
      include CustomerAuthenticator
    end
  end
end
