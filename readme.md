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


-------------------------------------------------------------------------
Example - 1 


<!---
Replace <clientid> and <clientsecret> with your account values
sandbox = true, in case you are testing in sandbox mode else remove this argument
 --->

<cfparam name="VARIABLES.clientid" default="AZ5KMK3dtZXtP3-bzBoBxwEH8hW2TuWmtKmJjGoQoeEjIWO5Zp7WIkYz5AJjblmfZ-qRg_BZ_62V_kZ8">
<cfparam name="VARIABLES.clientsecret" default="EPCyTZPRMIfslW8mStmpWpiJ8h8kMyZtTmjLFuN9wPbEckajF49QHzanteqEOokSiUaIHwuL9WsIaTsZ">

<cfset VARIABLES.paypalCfc = CreateObject("component","Paypal.cfc").init(clientId = VARIABLES.clientid, clientSecret = VARIABLES.clientsecret,sandbox="true")> 

<cfset VARIABLES.processPayment = VARIABLES.paypalCfc.capture(
    total = '10.00',
    currency = 'USD',
    subtotal = '10.00',
    tax  = '0',
    shipping = '0',
    handling_fee = '0',
    shipping_discount = '0',
    insurance = '0',
    description = 'Test Item',
    custom = 'Test Item',
    invoice_number = 'INV0001',
    soft_descriptor = 'Test',
    item = {
        name: 'Test',
        description : 'test desc',
        quantity : 1,
        price : '10.00',
        currency : 'USD',
        tax : '0',
        weight : '0',
        sku : 'sku_test',
        shipping_address : {
            recipient_name : 'test',
            line1 : 'line 1',
            line2 : 'line 2',
            city : 'amsterdam',
            state : 'AM',
            postal_code : '123123',
            country_code : 'US',
            phone : '7788996655'
        }
    },
    note_to_payer = 'Test'
)>

<cfset cookie.paypal_token = VARIABLES.processPayment.ACCESSTOKEN>

<cfset redirect_url = deserializeJSON(VARIABLES.processPayment.msg).links[2].href>

<cflocation  url="#redirect_url#">

-------------------------------------------------------------------------

Example - 2 (create subscription example)


<cfset paypalCfc	=	createObject('Component','Paypal').init(clientId="AZ5KMK3dtZXtP3-bzBoBxwEH8hW2TuWmtKmJjGoQoeEjIWO5Zp7WIkYz5AJjblmfZ-qRg_BZ_62V_kZ8",
clientSecret="EPCyTZPRMIfslW8mStmpWpiJ8h8kMyZtTmjLFuN9wPbEckajF49QHzanteqEOokSiUaIHwuL9WsIaTsZ",sandbox="true")>

<!--- Create Product id --->
<cfset getProduct = paypalCfc.CreateProductApi()>


<cfset getProductId = "#deserializeJSON(getProduct.filecontent).id#">

<!--- create Plan id --->
<cfset getPlan = paypalCfc.createPlanApi(getProductId)>

<cfset planId = "#deserializeJSON(getPlan.filecontent).id#">

<!--- create Subscription --->
<cfset getSubscriptions = paypalCfc.CreateSubscriptionsApi(planId)>

<!--- result --->
<cfdump var="#getSubscriptions#">


-------------------------------------------------------------------------

Example 3 


<cfset paypalObj	=	createObject('Component','Paypal').init(clientId="AZ5KMK3dtZXtP3-bzBoBxwEH8hW2TuWmtKmJjGoQoeEjIWO5Zp7WIkYz5AJjblmfZ-qRg_BZ_62V_kZ8",
clientSecret="EPCyTZPRMIfslW8mStmpWpiJ8h8kMyZtTmjLFuN9wPbEckajF49QHzanteqEOokSiUaIHwuL9WsIaTsZ",sandbox="true")>

<cfset item = structNew()>
<cfset item['name']='hat'>
<cfset item['description']='Test Order'>
<cfset item['quantity']='3'>
<cfset item['price']='10'>
<cfset item['tax']='0'>
<cfset item['sku']='1'>
<cfset item['currency']='USD'>

<cfset item['shipping_address'] = structNew()>
<cfset item['shipping_address']['recipient_name']='Hello World'>
<cfset item['shipping_address']['line1']='4thFloor'>
<cfset item['shipping_address']['line2']='unit##34'>
<cfset item['shipping_address']['city']='SAn Jose'>
<cfset item['shipping_address']['country_code']='US'>
<cfset item['shipping_address']['postal_code']='95131'>
<cfset item['shipping_address']['phone']='011862212345678'>
<cfset item['shipping_address']['state']='CA'>

<cfset temp = paypalObj.capture(
'30',
'USD',
'30',
'0',
'0',
'0',
'0',
'0',
'This is the payment transaction description.',
'EBAY_EMS_90048630024435',
'111#dateformat(now(),"hhmmss")#',
'ECHI5786786',
item,
'Contact us for any questions on your order.'
) >

<cfif isJSON(temp.msg)>
<cfset response = deSerializeJSON(temp.msg)>
<cfelse>
<cfset response = temp.msg>
</cfif>
<cfset cookie.token = temp.accessToken>
<cfset session.paypal_token = temp.accessToken>

<cflocation url="#response.links[2].href#" addtoken="no">


-------------------------------------------------------------------------