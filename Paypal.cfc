/**
 * Paypal
 *
 * @author Sachin
 * @date 
 **/
component  displayname="Paypal" hint="Paypal"
{
	Variables.username = "";
	Variables.password = "";
	Variables.server = "";

	public function	init(required string clientId, required string clientSecret, boolean sandbox default="true" ){

		Variables.username	=	arguments.clientId;
		Variables.password	=	arguments.clientSecret;

		if(arguments.sandbox){
			Variables.server	=	'https://api.sandbox.paypal.com';
		}
		else{
			Variables.server	=	'https://api.paypal.com';
		}

		return this;
	}

	private struct function	getAuthToken(){
		//init some vars
		var returnStruct = structNew();
		var returnStruct.status='';
		var returnStruct.msg='';
		var fContent='';

		try{
			cfhttp(method="POST", charset="utf-8", url="#Variables.server#/v1/oauth2/token", result="result",username="#variables.username#", password="#variables.password#") {
			    cfhttpparam(type="header",name="Content-Type", value="application/x-www-form-urlencoded");
			    cfhttpparam(type="header",name="Accept-Language", value="en-US,en;q=0.8,id;q=0.6");
			    cfhttpparam(type="formfield",name="grant_type", value="client_credentials");
			}

			fContent	=	deSerializeJSON(result.fileContent);
			returnStruct = fContent;

			if(result.statusCode EQ '200 OK' AND structKeyExists(fContent,'access_token')){
				returnStruct.status=200;
				returnStruct.msg=fContent.access_token;
			}else{
				returnStruct.status=500;
				returnStruct.msg='Failed to generate Auth Token from Paypal';
			}

		}
		catch(any e){
			returnStruct.status=500;
			returnStruct.msg='Failed to generate Auth Token from Paypal';
		}

		return returnStruct;
	}

	public function capture(
		required string total,
		required string currency,
		required string subtotal,
		required string tax,
		required string shipping,
		required string handling_fee,
		required string shipping_discount,
		required string insurance,
		required string description,
		required string custom,
		required string invoice_number,
		required string soft_descriptor,
		required struct item,
		required string note_to_payer
	)
	 {
		//init some vars
		var LinkedHashMap = createObject("java", "java.util.LinkedHashMap");
		var requestJSON = LinkedHashMap.init();
		var returnStruct = structNew();
		var returnStruct.status='';
		var returnStruct.msg='';
		var fContent='';

		try{
			requestJSON['intent'] = 'sale';
			requestJSON['payer'] = LinkedHashMap.init();
			requestJSON['payer']['payment_method'] = 'paypal';

			requestJSON['transactions'] = ArrayNew(1);
			requestJSON['transactions'][1] = LinkedHashMap.init();

			requestJSON['transactions'][1]['amount']=LinkedHashMap.init();
			requestJSON['transactions'][1]['amount']['total']=arguments.total;
			requestJSON['transactions'][1]['amount']['currency']=arguments.currency;

			requestJSON['transactions'][1]['amount']['details']=LinkedHashMap.init();
			amtDetails = LinkedHashMap.init();
			amtDetails['subtotal']=arguments.subtotal;
			amtDetails['tax']=arguments.tax;
			amtDetails['shipping']=arguments.shipping;
			amtDetails['handling_fee']=arguments.handling_fee;
			amtDetails['shipping_discount']=arguments.shipping_discount;
			amtDetails['insurance']=arguments.insurance;

			requestJSON['transactions'][1]['amount']['details']	=amtDetails;

			requestJSON['transactions'][1]['description']=arguments.description;
			requestJSON['transactions'][1]['custom']=arguments.custom;
			requestJSON['transactions'][1]['invoice_number']=arguments.invoice_number;

			requestJSON['transactions'][1]['payment_options']=LinkedHashMap.init();
			requestJSON['transactions'][1]['payment_options']['allowed_payment_method']='INSTANT_FUNDING_SOURCE';

			requestJSON['transactions'][1]['soft_descriptor']=arguments.soft_descriptor;

			requestJSON['transactions'][1]['item_list']=LinkedHashMap.init();

			requestJSON['transactions'][1]['item_list']['items']=ArrayNew(1);
			requestJSON['transactions'][1]['item_list']['items'][1]=LinkedHashMap.init();
			requestJSON['transactions'][1]['item_list']['items'][1]['name']=arguments.item['name'];
			requestJSON['transactions'][1]['item_list']['items'][1]['description']=arguments.item['description'];
			requestJSON['transactions'][1]['item_list']['items'][1]['quantity']=arguments.item['quantity'];
			requestJSON['transactions'][1]['item_list']['items'][1]['price']=arguments.item['price'];
			requestJSON['transactions'][1]['item_list']['items'][1]['tax']=arguments.item['tax'];
			requestJSON['transactions'][1]['item_list']['items'][1]['sku']=arguments.item['sku'];
			requestJSON['transactions'][1]['item_list']['items'][1]['currency']=arguments.item['currency'];

			requestJSON['transactions'][1]['item_list']['shipping_address']=LinkedHashMap.init();
			requestJSON['transactions'][1]['item_list']['shipping_address']['recipient_name']=arguments.item['shipping_address']['recipient_name'];
			requestJSON['transactions'][1]['item_list']['shipping_address']['line1']=arguments.item['shipping_address']['line1'];
			requestJSON['transactions'][1]['item_list']['shipping_address']['line2']=arguments.item['shipping_address']['line2'];
			requestJSON['transactions'][1]['item_list']['shipping_address']['city']=arguments.item['shipping_address']['city'];
			requestJSON['transactions'][1]['item_list']['shipping_address']['country_code']=arguments.item['shipping_address']['country_code'];
			requestJSON['transactions'][1]['item_list']['shipping_address']['postal_code']=arguments.item['shipping_address']['postal_code'];
			requestJSON['transactions'][1]['item_list']['shipping_address']['phone']=arguments.item['shipping_address']['phone'];
			requestJSON['transactions'][1]['item_list']['shipping_address']['state']=arguments.item['shipping_address']['state'];

			requestJSON['note_to_payer']=arguments.note_to_payer;

			requestJSON['redirect_urls']=LinkedHashMap.init();
			requestJSON['redirect_urls']['return_url']='https://6ae3-122-180-185-195.ngrok-free.app/paypal/return.cfm';
			requestJSON['redirect_urls']['cancel_url']='https://6ae3-122-180-185-195.ngrok-free.app/paypal/cancel.cfm';
			//return requestJSON;
			return CreatePaypalPayment(SerializeJSON(requestJSON));
		}
		catch(any e){
			returnStruct.status=500;
			returnStruct.msg='Failed to generate json for Paypal';
			returnStruct.msg=e;
		}
		return returnStruct;
	}

	private function CreatePaypalPayment(required string data){
		//init some vars
		var returnStruct = structNew();
		returnStruct.status='';
		returnStruct.msg='';
		returnStruct.accessToken='';
		var fContent='';
		try{
			var accessToken = getAuthToken();

			if(accessToken.status EQ '200'){
				cfhttp(method="POST", charset="utf-8", url="#Variables.server#/v1/payments/payment", result="result",timeout="1200") {
				    cfhttpparam(type="header",name="Content-Type", value="application/json");
					cfhttpparam(type="header",name="Accept-Language", value="en-US,en;q=0.8,id;q=0.6");
				    cfhttpparam(type="header",name="Authorization", value="Bearer #accessToken.msg#");
				    cfhttpparam(type="body", value="#data#");
				}

				if(result.statusCode EQ '201 Created'){
					returnStruct.status=200;
					returnStruct.msg=result.filecontent;
					returnStruct.accessToken = accessToken.msg;
				}else{
					returnStruct.status=500;
					returnStruct.msg='Failed to make payment request to Paypal';

				}

			}
			else{
				returnStruct.status=accessToken.status;
				returnStruct.msg=accessToken.msg;
			}
		}
		catch(any e){
			returnStruct.status=500;
			//returnStruct.msg='Failed to make payment request to Paypal';
			returnStruct.msg=e;
		}
		return returnStruct;

	}
//  	execute pament method-----
public function ExecutePayment(paymentID, saleID, accessToken){
//init some vars
	var returnStruct = structNew();
	var returnStruct.status='';
	var returnStruct.msg='';
	var fContent='';
	var pData = structNew();


	try{
			pData['payer_id'] = "#saleID#";

			cfhttp(method="POST", charset="utf-8", url="#Variables.server#/v1/payments/payment/#paymentID#/execute", result="result",timeout="1200") {
				cfhttpparam(type="header",name="Content-Type", value="application/json");
				cfhttpparam(type="header",name="Accept-Language", value="en-US,en;q=0.8,id;q=0.6");
				cfhttpparam(type="header",name="Authorization", value="Bearer #accessToken#");
				cfhttpparam(type="body", value="#serializeJSON(pData)#");
			}


			if(result.statusCode EQ '200 OK'){
				returnStruct.status=200;
				returnStruct.msg=result;
			}else{
				returnStruct.status=500;
				returnStruct.msg='Failed to execute payment request to Paypal';
			}
	}
	catch(any e){
		returnStruct.status=500;
		returnStruct.msg='Failed to make payment request to Paypal';
	}
	return returnStruct;
}


	public function SearchPaymentDetails(
		string id
		) {

		//init some vars
		var returnStruct = structNew();
		var returnStruct.status='';
		var returnStruct.msg='';

		try{
			var accessToken = getAuthToken();
			if(accessToken.status EQ '200'){

				if(len(arguments.id)){
					cfhttp(method="GET", charset="utf-8", url="#Variables.server#//v1/payments/payment/#arguments.id#", result="result",timeout="1200") {
						cfhttpparam(type="header",name="Content-Type", value="application/json");
						cfhttpparam(type="header",name="Accept-Language", value="en-US,en;q=0.8,id;q=0.6");
						cfhttpparam(type="header",name="Authorization", value="Bearer #accessToken.msg#");
					}
				}
				else{
					cfhttp(method="GET", charset="utf-8", url="#Variables.server#/v1/payments/payment?count=10&start_index=0", result="result",timeout="1200") {
						cfhttpparam(type="header",name="Content-Type", value="application/json");
						cfhttpparam(type="header",name="Accept-Language", value="en-US,en;q=0.8,id;q=0.6");
						cfhttpparam(type="header",name="Authorization", value="Bearer #accessToken.msg#");
					}
				}

				if(result.statusCode EQ '200 OK'){
					returnStruct.status=200;
					returnStruct.msg=result;
				}else{
					returnStruct.status=500;
					returnStruct.msg='Failed to search payment request from Paypal';
				}

			}
			else{
				returnStruct.status=accessToken.status;
				returnStruct.msg=accessToken.msg;
			}

		}
		catch(any e){
			returnStruct.status=500;
			returnStruct.msg=e.message;
		}

		return returnStruct;

	}

	public function CreateProductApi(){
		var returnStruct = structNew();
		returnStruct.status='';
		returnStruct.msg='';
		returnStruct.accessToken='';
		var fContent='';
		var pData = structNew();
		try{
			pData['name'] = "Video Streaming Service";
			pData['description'] = "Video streaming service";
			pData['type'] = "SERVICE";

			var accessToken = getAuthToken();
			//if(accessToken.status EQ '200'){

				cfhttp(method="POST", charset="utf-8", url="#Variables.server#/v1/catalogs/products", result="result",timeout="1200") {
					cfhttpparam(type="header",name="Content-Type", value="application/json");
					cfhttpparam(type="header",name="Accept-Language", value="en-US,en;q=0.8,id;q=0.6");
					cfhttpparam(type="header",name="Authorization", value="Bearer #accessToken.msg#");
					cfhttpparam(type="body", value="#serializeJSON(pData)#");
				}

			if(result.statusCode EQ '200 OK'){
				returnStruct.status=200;
				returnStruct.msg=result;
			}else{
				returnStruct.status=500;
				returnStruct.msg='Failed to execute plan request to Paypal';
			}
		}
		catch(any e){
			returnStruct.status=500;
			returnStruct.msg='Failed to make plan request to Paypal';
		}
		return result;
	}

	public function createPlanApi(
		string getProductId
		){
		var returnStruct = structNew();
		returnStruct.status='';
		returnStruct.msg='';
		returnStruct.accessToken='';
		var fContent='';
		var pData = structNew();
		try{
			pData['product_id'] = arguments.getProductId;
			pData['name'] = "Video Streaming Service Plan";
			pData['billing_cycles'] = [
				{
					"frequency": {
					  "interval_unit": "MONTH",
					  "interval_count": 1
					},
					"tenure_type": "TRIAL",
					"sequence": 1,
					"total_cycles": 2,
					"pricing_scheme": {
					  "fixed_price": {
						"value": "3",
						"currency_code": "USD"
					  }
					}
				  },
				  {
					"frequency": {
					  "interval_unit": "MONTH",
					  "interval_count": 1
					},
					"tenure_type": "TRIAL",
					"sequence": 2,
					"total_cycles": 3,
					"pricing_scheme": {
					  "fixed_price": {
						"value": "6",
						"currency_code": "USD"
					  }
					}
				  },
				  {
					"frequency": {
					  "interval_unit": "MONTH",
					  "interval_count": 1
					},
					"tenure_type": "REGULAR",
					"sequence": 3,
					"total_cycles": 12,
					"pricing_scheme": {
					  "fixed_price": {
						"value": "10",
						"currency_code": "USD"
					  }
					}
				  }
			  ];
			pData['payment_preferences'] = {
				"auto_bill_outstanding": true,
				"setup_fee": {
				  "value": "10",
				  "currency_code": "USD"
				},
				"setup_fee_failure_action": "CONTINUE",
				"payment_failure_threshold": 3
			  };

			var accessToken = getAuthToken();

			 
				cfhttp(method="POST", charset="utf-8", url="#Variables.server#/v1/billing/plans", result="result",timeout="1200") {
					cfhttpparam(type="header",name="Content-Type", value="application/json");
					cfhttpparam(type="header",name="Accept-Language", value="en-US,en;q=0.8,id;q=0.6");
					cfhttpparam(type="header",name="Authorization", value="Bearer #accessToken.msg#");
					cfhttpparam(type="body", value="#serializeJSON(pData)#");
				}

			if(result.statusCode EQ '200 OK'){
				returnStruct.status=200;
				returnStruct.msg=result;
			}else{
				returnStruct.status=500;
				returnStruct.msg='Failed to execute plan request to Paypal';
			}
		}
		catch(any e){
			returnStruct.status=500;
			returnStruct.msg='Failed to make plan request to Paypal';
		}
		return result;
	}

	public function CreateSubscriptionsApi(
		string planId
	){
		var returnStruct = structNew();
		returnStruct.status='';
		returnStruct.msg='';
		returnStruct.accessToken='';
		var fContent='';
		var pData = structNew();
		try{
			pData['plan_id'] = arguments.planId;

			var accessToken = getAuthToken();
			//if(accessToken.status EQ '200'){

				cfhttp(method="POST", charset="utf-8", url="#Variables.server#/v1/billing/subscriptions", result="result",timeout="1200") {
					cfhttpparam(type="header",name="Content-Type", value="application/json");
					cfhttpparam(type="header",name="Accept-Language", value="en-US,en;q=0.8,id;q=0.6");
					cfhttpparam(type="header",name="Authorization", value="Bearer #accessToken.msg#");
					cfhttpparam(type="body", value="#serializeJSON(pData)#");
				}

			if(result.statusCode EQ '200 OK'){
				returnStruct.status=200;
				returnStruct.msg=result;
			}else{
				returnStruct.status=500;
				returnStruct.msg='Failed to execute plan request to Paypal';
			}
		}
		catch(any e){
			returnStruct.status=500;
			returnStruct.msg='Failed to make plan request to Paypal';
		}
		return result;
	}
}
