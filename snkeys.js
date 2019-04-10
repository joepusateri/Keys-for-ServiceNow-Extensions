var me = "ServiceNow Keys"; 
var JSON = new global.JSON(); 


var output = "\nservice_name,service_id,escalation_policy_id,webhook_id\n"; 
var pd = new x_pd_integration.PagerDuty(); 
var rest = new x_pd_integration.PagerDuty_REST(); 

var more_records = Boolean(true);
var offset = 0;
var page = 100;
var services = {};

while (more_records)
{
	gs.debug("Getting Services {0}", offset); 
	more_records = Boolean(false);

	var feature = "services?limit="+page+"&offset="+offset;

	var response = rest.getREST(feature); 
	var responseBody = response.haveError() ? pd._extractPDIncidentError(response) : response.getBody(); 
	var status = response.getStatusCode(); 
	gs.debug("{0} response: {1}:{2}", me, status, responseBody); 

	if (status == 200) { 
		var body = this.JSON.decode(response.getBody()); 
		gs.debug("more {0}", body.more);
		more_records = Boolean(body.more);
		offset += page;
		for (i=0;i<body.services.length;i++)
		{
			var thisService = body.services[i];
			services[thisService.id] = thisService.escalation_policy.id;
		}
		gs.debug("Service: {0}", JSON.encode(services));


	} 
	
}

more_records = Boolean(true);
offset = 0;

while (more_records)
{
	gs.debug("Getting Extensions {0}", offset); 
	more_records = Boolean(false);

	var feature = "extensions?limit="+page+"&offset="+offset;

	var response = rest.getREST(feature); 
	var responseBody = response.haveError() ? pd._extractPDIncidentError(response) : response.getBody(); 
	var status = response.getStatusCode(); 
	gs.debug("{0} response: {1}:{2}", me, status, responseBody); 

	if (status == 200) { 
		var body = this.JSON.decode(response.getBody()); 
		gs.debug("more {0}", body.more);
		more_records = Boolean(body.more);
		offset += page;
		for (i=0;i<body.extensions.length;i++)
		{
			var extension = body.extensions[i];
			var name = extension.name;
			var snow_user = extension.config.snow_user;
			if (snow_user)
			{
				var serviceid = extension.extension_objects[0].id;
				var servicename = extension.extension_objects[0].summary;
				var webhookid = extension.id;
				output += "\""+servicename+"\","+serviceid+","+services[serviceid]+","+webhookid+"\n";

			}
		}
		//gs.debug("Service: {0}", JSON.encode(services));

	
	} 
}
gs.info("\n\n\n" + output); 