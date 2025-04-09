
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

