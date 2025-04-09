
<cfparam name="VARIABLES.clientid" default="AZ5KMK3dtZXtP3-bzBoBxwEH8hW2TuWmtKmJjGoQoeEjIWO5Zp7WIkYz5AJjblmfZ-qRg_BZ_62V_kZ8">
<cfparam name="VARIABLES.clientsecret" default="EPCyTZPRMIfslW8mStmpWpiJ8h8kMyZtTmjLFuN9wPbEckajF49QHzanteqEOokSiUaIHwuL9WsIaTsZ">

<cfset paypalObj	=	createObject('Component','Paypal').init(clientId = VARIABLES.clientid, clientSecret = VARIABLES.clientsecret,sandbox="true")>

<cfset temp = paypalObj.ExecutePayment(
url.paymentID,
url.PayerID,
cookie.paypal_token
) >

<cfdump var="#temp#">