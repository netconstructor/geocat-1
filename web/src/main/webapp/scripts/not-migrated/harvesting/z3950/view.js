//=====================================================================================
//===
//=== View (type:z3950)
//===
//=====================================================================================

z3950.View = function(xmlLoader) {
	HarvesterView.call(this);

	var privilTransf = new XSLTransformer(
			'harvesting/z3950/client-privil-row.xsl', xmlLoader);
	var resultTransf = new XSLTransformer(
			'harvesting/z3950/client-result-tip.xsl', xmlLoader);

	var loader = xmlLoader;
	var valid = new Validator(loader);
	var shower = null;

	var currSearchId = 0;

	this.setPrefix('z39');
	this.setPrivilTransf(privilTransf);
	this.setResultTransf(resultTransf);

	// --- public methods

	this.init = init;
	this.setEmpty = setEmpty;
	this.setData = setData;
	this.getData = getData;
	this.isDataValid = isDataValid;
	this.clearIcons = clearIcons;
	this.addIcon = addIcon;

	Event.observe('z39.icon', 'change', ker.wrap(this, updateIcon));

	// =====================================================================================
	// ===
	// === API methods
	// ===
	// =====================================================================================

	function init() {
		valid.add( [ {
			id :'z39.name',
			type :'length',
			minSize :1,
			maxSize :200
		}, {
			id :'z39.query',
			type :'length',
			minSize :1,
			maxSize :200
		}, {
			id :'z39.username',
			type :'length',
			minSize :0,
			maxSize :200
		}, {
			id :'z39.password',
			type :'length',
			minSize :0,
			maxSize :200
		}, {
			id :'z39.every.days',
			type :'integer',
			minValue :0,
			maxValue :99
		}, {
			id :'z39.every.hours',
			type :'integer',
			minValue :0,
			maxValue :23
		}, {
			id :'z39.every.mins',
			type :'integer',
			minValue :0,
			maxValue :59
		} ]);

		shower = new Shower('z39.useAccount', 'z39.account');
	}

	// =====================================================================================

	function setEmpty() {
		this.setEmptyCommon();

		var icons = $('z39.icon').options;

		for ( var i = 0; i < icons.length; i++)
			if (icons[i].value == 'default.gif') {
				icons[i].selected = true;
				break;
			}

		shower.update();
		updateIcon();
	}

	// =====================================================================================

	function setData(node) {
		this.setDataCommon(node);

		var site = node.getElementsByTagName('site')[0];

		hvutil.setOption(site, 'query', 'z39.query');
		hvutil.setOption(site, 'icon', 'z39.icon');

		// --- add privileges entries

		this.removeAllGroupRows();
		this.addGroupRows(node);

		// --- set categories

		this.unselectCategories();
		this.selectCategories(node);

		shower.update();
		updateIcon();
	}

	// =====================================================================================

	function getData() {
		var data = this.getDataCommon();

		data.ICON = $F('z39.icon');
		data.QUERY = $F('z39.query');

		// --- retrieve privileges and categories information

		data.PRIVILEGES = this.getPrivileges();
		data.CATEGORIES = this.getSelectedCategories();

		return data;
	}

	// =====================================================================================

	function isDataValid() {
		if (!valid.validate())
			return false;

		return this.isDataValidCommon();
	}

	// =====================================================================================

	function clearIcons() {
		$('z39.icon').options.length = 0;
	}

	// =====================================================================================

	function addIcon(file) {
		var html = '<option value="' + file + '">' + xml.escape(file)
				+ '</option>';
		new Insertion.Bottom('z39.icon', html);
	}

	// =====================================================================================

	function updateIcon() {
		var icon = $F('z39.icon');
		var image = $('z39.icon.image');

		image.setAttribute('src', Env.url + '/images/harvesting/' + icon);
	}
}
