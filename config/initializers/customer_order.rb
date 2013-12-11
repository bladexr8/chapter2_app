module CustomerUtility

  class CustomerOrder

    def getCustomerOrderSummary(userId)
      # get Order Summary for logged in user
      client = Force.new
      orderSummary = client.query("select Id, Name, Grand_Total__c, 
                                    CreatedDate, Planned_Delivery_Date__c,
                                    Delivered__c 
                                    from Order__c
                                    where Customer_ID__c = #{userId} 
                                    order by Name ASC")
      return orderSummary
    end
  end
end