
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
