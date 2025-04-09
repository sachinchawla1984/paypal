
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

