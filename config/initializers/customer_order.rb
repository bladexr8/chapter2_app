module CustomerUtility

  include Databasedotcom::Rails::Controller

  class CustomerOrder

    def getCustomerOrderSummary(userId)
      # get Order Summary for logged in user
      orderSummary = Order__c.query("Customer_ID__c = #{userId}")
      return orderSummary
    end
  end
end