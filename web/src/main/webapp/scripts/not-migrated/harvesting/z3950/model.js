//=====================================================================================
//===
//=== Model (type:z3950)
//===
//=====================================================================================

z3950.Model = function(xmlLoader) {
	HarvesterModel.call(this);

	var loader = xmlLoader;
	var callBackF = null;

	this.retrieveGroups = retrieveGroups;
	this.retrieveCategories = retrieveCategories;
	this.retrieveIcons = retrieveIcons;
	this.getUpdateRequest = getUpdateRequest;

	// =====================================================================================

	function retrieveGroups(callBack) {
		new InfoService(loader, 'groups', callBack);
	}

	// =====================================================================================

	function retrieveCategories(callBack) {
		new InfoService(loader, 'categories', callBack);
	}

	// =====================================================================================

	function retrieveIcons(callBack) {
		callBackF = callBack;

		var request = ker.createRequest('type', 'icons');

		ker.send('xml.harvesting.info', request, ker.wrap(this,
				retrieveIcons_OK));
	}

	// -------------------------------------------------------------------------------------

	function retrieveIcons_OK(xmlRes) {
		if (xmlRes.nodeName == 'error')
			ker.showError(loader.getText('cannotRetrieve'), xmlRes);
		else {
			var data = [];
			var list = xml.children(xml.children(xmlRes)[0]);

			for ( var i = 0; i < list.length; i++)
				data.push(xml.textContent(list[i]));

			callBackF(data);
		}
	}

	// =====================================================================================

	function getUpdateRequest(data) {
		var request = str.substitute(updateTemp, data);
		
		return this.substituteCommon(data, request);
	}

	// =====================================================================================

	var updateTemp = 
	' <node id="{ID}" type="{TYPE}">'+ 
	'    <site>'+
	'      <name>{NAME}</name>'+
	'      <query>{QUERY}</query>'+
	'      <icon>{ICON}</icon>'+
	'      <account>'+
	'        <use>{USE_ACCOUNT}</use>'+
	'        <username>{USERNAME}</username>'+
	'        <password>{PASSWORD}</password>'+
	'      </account>'+
	'    </site>'+
	    
	'    <options>'+
	'      <every>{EVERY}</every>'+
	'      <oneRunOnly>{ONE_RUN_ONLY}</oneRunOnly>'+
	'    </options>'+

	'    <privileges>'+
	'       {PRIVIL_LIST}'+
	'    </privileges>'+

	'    <categories>'+
	'       {CATEG_LIST}'+
	'    </categories>'+
	'  </node>';

}
