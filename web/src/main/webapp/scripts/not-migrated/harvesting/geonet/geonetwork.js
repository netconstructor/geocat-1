//=====================================================================================
//===
//=== Geonetwork controller
//===
//=====================================================================================

ker.include('harvesting/geonet/model.js');
ker.include('harvesting/geonet/view.js');

var gn = new Object();

//=====================================================================================

function Geonetwork(xmlLoader)
{
	//--- call super constructor
	Harvester.call(this);
	
	var loader= xmlLoader;
	var model = new gn.Model(loader);
	var view  = new gn.View(loader);
	
	//--- public methods
	
	this.addSearchRow    = view.addEmptySearch;
	this.removeSearchRow = view.removeSearch;
	this.getResultTip    = view.getResultTip;
	this.retrieveSources = retrieveSources;
	this.retrieveGroups  = retrieveGroups;
	
	this.model = model;
	this.view  = view;
	
//=====================================================================================
//===
//=== API methods
//===
//=====================================================================================

this.getType      = function() { return "geonetwork"; }
this.getLabel     = function() { return loader.eval("info[@type='geonetwork']/long"); }
this.getEditPanel = function() { return "gn.editPanel"; }

//=====================================================================================

this.init = function()
{
	this.view.init();
	
	model.retrieveCategories(ker.wrap(this, init_categ_OK));
}

//-------------------------------------------------------------------------------------

function init_categ_OK(data)
{
	view.clearCategories();
		
	for (var i=0; i<data.length; i++)
		view.addCategory(data[i].id, data[i].label[Env.lang]);				
}

//=====================================================================================

function retrieveSources()
{
	var data = view.getHostData();
	
	if (data.HOST == '')
		alert(loader.getText('supplyHost'));
		
	else if (data.SERVLET == '')
		alert(loader.getText('supplyServlet'));
		
	else
		model.retrieveSources(data, ker.wrap(view, view.setSources));
}

//=====================================================================================

function retrieveGroups()
{
	var data = view.getHostData();
	
	if (data.HOST == '')
		alert(loader.getText('supplyHost'));
		
	else if (data.SERVLET == '')
		alert(loader.getText('supplyServlet'));
		
	else
	{
		var cb = ker.wrap(this, retrieveGroups_OK);
	
		if (data.USE_ACCOUNT)
			model.retrieveGroups(data, cb, data.USERNAME, data.PASSWORD);
		else
			model.retrieveGroups(data, cb);
	}
}

//-------------------------------------------------------------------------------------

function retrieveGroups_OK(data)
{
	//--- add new groups
	
	for (var i=0; i<data.length; i++)
	{	
		var remoteGroup = data[i];
		var policyGroup = view.findPolicyGroup(remoteGroup.name);
		
		//--- skip 'intranet' group
		if (remoteGroup.id == '0')
			continue;
			
		if (policyGroup == null)
			view.addPolicyGroup(remoteGroup.name, 'dontCopy');
	}
	
	//--- remove missing groups
	
	var list = view.getListedPolicyGroups();
	
	for (var i=0; i<list.length; i++)
		if (!existsGroup(list[i], data))
			view.removePolicyGroup(list[i]);
}

//-------------------------------------------------------------------------------------

function existsGroup(name, data)
{
	for (var i=0; i<data.length; i++)
		if (name == data[i].name)
			return true;
	
	return false;
}

//=====================================================================================
}
