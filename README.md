PayPal CFC Integration (https://developer.paypal.com/docs/api/payments/v1/)
This component allows you to integrate PayPal's API into your ColdFusion application. It supports both one-time payments and subscriptions.

1. Get PayPal Credentials
  To begin, create an app on the PayPal Developer Dashboard and obtain your Client ID and Client Secret:

  Use the Live or Sandbox environment as needed:

  PayPal Developer Dashboard

2. Initialize the PayPal Component
  Before making any API calls, initialize the component with your credentials and specify whether you're using the sandbox or live environment.

  The component automatically sets the correct PayPal API endpoint based on the environment.

3. Available Functions
  - init(clientId, clientSecret, sandbox)
  Sets your PayPal credentials and environment (sandbox or live).

  - getAuthToken()
  Generates an access token required to make authenticated requests to PayPal's API.

  - capture(...)
  Creates a payment. You can specify details such as:

  Total amount

  Currency

  Tax, shipping, and item breakdown

  Invoice number and description

  Item and shipping address

  Returns a response with payment details and access token for execution.

  - ExecutePayment(paymentID, saleID, accessToken)
  Completes a previously created payment using the IDs and token returned during the capture process.

  - CreateProductApi()
  Creates a product in PayPal's catalog, required for subscription-based billing.

  - createPlanApi()
  Creates a billing plan under a product. Used to define pricing and frequency for subscriptions.

  - CreateSubscriptionsApi(planId)
  Creates a new subscription for the given plan ID. Starts a recurring payment cycle.

