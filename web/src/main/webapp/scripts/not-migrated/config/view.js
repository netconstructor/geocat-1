//=====================================================================================
//===
//=== Handles all view related stuff in the MVC pattern
//===
//=====================================================================================

function ConfigView(strLoader)
{
	//--- setup validators
	this.strLoader = strLoader;
	this.validator = new Validator(strLoader);

	this.validator.add(
	[
		{ id:'site.name',     type:'length',   minSize :1,  maxSize :200 },
		{ id:'site.organ',    type:'length',   minSize :0,  maxSize :200 },
		
		{ id:'server.host',   type:'length',   minSize :1,  maxSize :200 },
		{ id:'server.host',   type:'hostname' },
		{ id:'server.port',   type:'integer',  minValue:80, maxValue:65535 },
		
		{ id:'intranet.network', type:'ipaddress' },
		{ id:'intranet.netmask', type:'ipaddress' },
		
		{ id:'z3950.port',   type:'integer',  minValue:80, maxValue:65535, empty:true },
		
		{ id:'feedback.email',     type:'length',   minSize :0,  maxSize :200 },		
		{ id:'feedback.mail.host', type:'length',   minSize :0,  maxSize :200 },
		{ id:'feedback.mail.host', type:'hostname' },
		{ id:'feedback.mail.port', type:'integer',  minValue:25, maxValue:65535, empty:true },
		
		{ id:'proxy.host',     type:'length',   minSize :0,  maxSize :200 },
		{ id:'proxy.host',     type:'hostname' },
		{ id:'proxy.port',     type:'integer',  minValue:21, maxValue:65535, empty:true },
		{ id:'proxy.username', type:'length',  minSize :0,  maxSize :200 },
		{ id:'proxy.password', type:'length',  minSize :0,  maxSize :200 },

		{ id:'removedMd.dir', type:'length', minSize :0,  maxSize :200 },
		
		{ id:'ldap.host',         type:'length',   minSize :0, maxSize :200 },
		{ id:'ldap.host',         type:'hostname' },
		{ id:'ldap.port',         type:'integer',  minValue:80, maxValue:65535, empty:true },		
		{ id:'ldap.baseDN',       type:'length',  minSize :1,  maxSize :200 },
		{ id:'ldap.usersDN',      type:'length',  minSize :1,  maxSize :200 },
		{ id:'ldap.nameAttr',     type:'length',  minSize :1,  maxSize :200 }
	]);
	
	this.z3950Shower = new Shower('z3950.enable', 'z3950.subpanel');	
	this.proxyShower = new Shower('proxy.use',    'proxy.subpanel');
	this.ldapShower  = new Shower('ldap.use',     'ldap.subpanel');
}

//=====================================================================================

ConfigView.prototype.init = function()
{
	gui.setupTooltips(this.strLoader.getNode('tips'));
}

//=====================================================================================
 
ConfigView.prototype.setData = function(data)
{
	$('site.name')  .value = data['SITE_NAME'];
	$('site.organ') .value = data['SITE_ORGAN'];	
	$('server.host').value = data['SERVER_HOST'];
	$('server.port').value = data['SERVER_PORT'];
	
	$('intranet.network').value = data['INTRANET_NETWORK'];
	$('intranet.netmask').value = data['INTRANET_NETMASK'];
	
	$('z3950.enable').checked = data['Z3950_ENABLE'] == 'true';
	$('z3950.port')  .value   = data['Z3950_PORT'];
	
	$('csw.enable').checked = data['CSW_ENABLE'] == 'true';
	$('csw.contactId').value           = data['CSW_CONTACTID'];
	$('csw.individualName').value      = data['CSW_INDIVIDUALNAME'];
	$('csw.positionName').value        = data['CSW_POSITIONNAME'];
	$('csw.voice').value               = data['CSW_VOICE'];
	$('csw.facsimile').value           = data['CSW_FACSIMILE'];
	$('csw.deliveryPoint').value       = data['CSW_DELIVERYPOINT'];
	$('csw.city').value                = data['CSW_CITY'];
	$('csw.administrativeArea').value  = data['CSW_ADMINAREA'];
	$('csw.postalCode').value          = data['CSW_POSTALCODE'];
	$('csw.country').value             = data['CSW_COUNTRY'];
	$('csw.email').value               = data['CSW_EMAIL'];
	$('csw.hoursOfService').value      = data['CSW_HOURSOFSERVICE'];
	$('csw.contactInstructions').value = data['CSW_INSTRUCTIONS'];
	$('csw.role').value                = data['CSW_ROLE'];
	$('csw.title').value               = data['CSW_TITLE'];
	$('csw.abstract').value            = data['CSW_ABSTRACT'];
	$('csw.fees').value                = data['CSW_FEES'];
	$('csw.accessConstraints').value   = data['CSW_ACCESS'];
	
	$('clickablehyperlinks.enable').checked = data['CLICKABLE_HYPERLINKS'] == 'true';

	$('proxy.use') .checked   = data['PROXY_USE'] == 'true';
	$('proxy.host').value     = data['PROXY_HOST'];
	$('proxy.port').value     = data['PROXY_PORT'];
	$('proxy.username').value = data['PROXY_USER'];
	$('proxy.password').value = data['PROXY_PASS'];
	
	$('feedback.email')    .value = data['FEEDBACK_EMAIL'];
	$('feedback.mail.host').value = data['FEEDBACK_MAIL_HOST'];
	$('feedback.mail.port').value = data['FEEDBACK_MAIL_PORT'];
	
	$('removedMd.dir').value = data['REMOVEDMD_DIR'];

	$('ldap.use')       .checked = data['LDAP_USE'] == 'true';
	$('ldap.host')        .value = data['LDAP_HOST'];
	$('ldap.port')        .value = data['LDAP_PORT'];
	$('ldap.defProfile')  .value = data['LDAP_DEF_PROFILE'];
	$('ldap.baseDN')      .value = data['LDAP_DN_BASE'];
	$('ldap.usersDN')     .value = data['LDAP_DN_USERS'];
	$('ldap.nameAttr')    .value = data['LDAP_ATTR_NAME'];
	$('ldap.profileAttr') .value = data['LDAP_ATTR_PROFILE'];
	
	$('log.enable').checked = data['LOG_ENABLE'] == 'true';

	this.z3950Shower.update();
	this.proxyShower.update();
	this.ldapShower.update();
}

//=====================================================================================

ConfigView.prototype.isDataValid = function()
{
	return this.validator.validate();
}

//=====================================================================================

ConfigView.prototype.getData = function()
{
	var data =
	{
		SITE_NAME   : $('site.name')  .value,	
		SITE_ORGAN  : $('site.organ') .value,		
		SERVER_HOST : $('server.host').value,
		SERVER_PORT : $('server.port').value,
		
		INTRANET_NETWORK : $('intranet.network').value,
		INTRANET_NETMASK : $('intranet.netmask').value,
	
		Z3950_ENABLE : $('z3950.enable').checked,
		Z3950_PORT   : $('z3950.port')  .value,
		
		CSW_ENABLE : $('csw.enable').checked,
		CSW_CONTACTID       : $('csw.contactId').value,
		CSW_INDIVIDUALNAME  : $('csw.individualName').value,
		CSW_POSITIONNAME    : $('csw.positionName').value,
		CSW_VOICE           : $('csw.voice').value,
		CSW_FACSIMILE       : $('csw.facsimile').value,
		CSW_DELIVERYPOINT   : $('csw.deliveryPoint').value,
		CSW_CITY            : $('csw.city').value,
		CSW_ADMINAREA       : $('csw.administrativeArea').value,
		CSW_POSTALCODE      : $('csw.postalCode').value,
		CSW_COUNTRY         : $('csw.country').value,
		CSW_EMAIL           : $('csw.email').value,
		CSW_HOURSOFSERVICE  : $('csw.hoursOfService').value,
		CSW_INSTRUCTIONS    : $('csw.contactInstructions').value,
		CSW_ROLE            : $('csw.role').value,
		CSW_TITLE           : $('csw.title').value,
		CSW_ABSTRACT        : $('csw.abstract').value,
		CSW_FEES            : $('csw.fees').value,
		CSW_ACCESS          : $('csw.accessConstraints').value,
	
		CLICKABLE_HYPERLINKS : $('clickablehyperlinks.enable').checked,

		PROXY_USE  : $('proxy.use') .checked,
		PROXY_HOST : $('proxy.host').value,
		PROXY_PORT : $('proxy.port').value,
		PROXY_USER : $('proxy.username').value,
		PROXY_PASS : $('proxy.password').value,
		
		FEEDBACK_EMAIL     : $('feedback.email')    .value,
		FEEDBACK_MAIL_HOST : $('feedback.mail.host').value,
		FEEDBACK_MAIL_PORT : $('feedback.mail.port').value,		

		REMOVEDMD_DIR : $('removedMd.dir').value,
		
		LDAP_USE           : $('ldap.use').checked,
		LDAP_HOST          : $F('ldap.host'),
		LDAP_PORT          : $F('ldap.port'),
		LDAP_DEF_PROFILE   : $F('ldap.defProfile'),
		LDAP_DN_BASE       : $F('ldap.baseDN'),
		LDAP_DN_USERS      : $F('ldap.usersDN'),
		LDAP_ATTR_NAME     : $F('ldap.nameAttr'),
		LDAP_ATTR_PROFILE  : $F('ldap.profileAttr'),
		
		LOG_ENABLE         : $('log.enable').checked
	}
	
	return data;
}

//=====================================================================================

