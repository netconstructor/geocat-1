OpenLayers.Util.onImageLoadError = function() {
    this._attempts = (this._attempts) ? (this._attempts + 1) : 1;
    if (this._attempts <= OpenLayers.IMAGE_RELOAD_ATTEMPTS) {
        //noinspection SillyAssignmentJS
        this.src = this.src;
    }
    this.style.display = "none";
};

OpenLayers.DOTS_PER_INCH = 254;
Ext.BLANK_IMAGE_URL = window.gMfLocation + '../ext/resources/images/default/s.gif';
OpenLayers.IMAGE_RELOAD_ATTEMPTS = 1;

/**
 * Class: MapComponent
 */
var MapComponent = OpenLayers.Class({

    displayLayertree: true,

    drawPanel: true,
    panelDivId: null,
    panelWidth: 500,
    panelHeight: 300,
    resizablePanel: true,
    panelMinWidth: 185,
    panelMaxWidth: 500,
    panelMinHeight: 100,
    panelMaxHeight: 410,
    enableNavigation: true,

    mapDivId: null,
    maxExtent: null,
    initialExtent: null,
    mapControls: null,
    mapLayers: null,
    resolutions: [2000, 1000, 650, 500, 250, 100, 50, 20, 10, 5, 2.5],
    //mapNavigation: false,

    map: null,
    toolbar: null,
    panel: null,


    /**
     * Constructor: MapDrawComponent
     *
     * Parameters:
     * divId - {string}
     * options - {Object} Options object
     *
     */
    initialize: function(divId, options) {
        this.mapDivId = divId + 'Map';
        this.panelDivId = divId;
        OpenLayers.Util.extend(this, options);

        var tcBounds = new OpenLayers.Bounds(420000, 30000, 900000, 350000);
        var imageBounds = new OpenLayers.Bounds(159000,-238000,1364100,569300);
        this.maxExtent = tcBounds;  //restricts where we can zoom
        this.initialExtent = new OpenLayers.Bounds(473100, 67000, 891049, 301698);
        this.mapControls = [
            new OpenLayers.Control.ArgParser(),
            new OpenLayers.Control.Attribution()
        ];
        // build the attribution target
        switch(OpenLayers.Lang.code) {
        case "fr":
            var href = "http://www.disclaimer.admin.ch/conditions_dutilisation.html";
            break;
        case "en":
            var href = "http://www.disclaimer.admin.ch/terms_and_conditions.html";
            break;
        case "de":
        default:
            var href = "http://www.disclaimer.admin.ch/index.html";
            break;
        }
        this.mapLayers = [
            new OpenLayers.Layer.Image("BigBackground", "../../images/baseMap.jpg",
                imageBounds,
                new OpenLayers.Size(1854, 1242),
                {
                    isBaseLayer: true,
                    displayInLayerSwitcher: false,
                    resolutions: this.resolutions,
                    attribution: "<a href='" + href + "' target='_blank'>&copy; swisstopo</a>"
                }
            ),
            new OpenLayers.Layer.TileCache("Background", [
                'http://tile5.bgdi.admin.ch/geoadmin/', 'http://tile6.bgdi.admin.ch/geoadmin/',
                'http://tile7.bgdi.admin.ch/geoadmin/', 'http://tile8.bgdi.admin.ch/geoadmin/',
                'http://tile9.bgdi.admin.ch/geoadmin/'
            ], 'ch.swisstopo.pixelkarte-farbe', {
                format: 'image/jpeg',
                isBaseLayer: false,
                displayInLayerSwitcher: false,
                buffer: 0,
                maxExtent: tcBounds,
                serverResolutions: [4000,3750,3500,3250,3000,2750,2500,2250,2000,1750,1500,1250,1000,750,650,500,250,100,50,20,10,5,2.5,2,1.5,1,0.5],
                calculateInRange: function() {
                    if(this.map.getScale() >= 6500000) {
                        return false; //handled by BigBackground
                    }
                    return OpenLayers.Layer.TileCache.prototype.calculateInRange.apply(this, arguments);
                }
            })
        ];

        this.map = this.getMap();

        if (this.enableNavigation) {
            this.navigate = new OpenLayers.Control.Navigation({title: OpenLayers.Lang.translate('mf.control.pan')});
            this.map.addControl(this.navigate);
        }
        if (this.drawPanel) {
            this.panel = this.getPanel();
            this.toolbar = this.getToolbar();
        }

        this.getMap().updateSize();
    },

    getToolbar: function() {
        if (this.toolbar) return this.toolbar;
        this.toolbar = new mapfish.widgets.toolbar.Toolbar({
            map: this.getMap(),
            configurable: false
        });
        //see http://trac.mapfish.org/trac/mapfish/ticket/126
        this.toolbar.autoHeight = false;
        this.toolbar.height = 26;

        return this.toolbar;
    },

    fillToolbar: function() {
        this.toolbar.addControl(new OpenLayers.Control.ZoomToMaxExtent({
                map: this.getMap(),
                title: OpenLayers.Lang.translate('mf.control.zoomAll')
            }), {
                iconCls: 'zoomfull',
                toggleGroup: 'map'
        });
        this.toolbar.addControl(new OpenLayers.Control.ZoomBox({
                title: OpenLayers.Lang.translate('mf.control.zoomIn')
            }), {
                iconCls: 'zoomin',
                toggleGroup: 'map'
        });
        this.toolbar.addControl(new OpenLayers.Control.ZoomBox({
                out: true,
                title: OpenLayers.Lang.translate('mf.control.zoomOut')
            }), {
                iconCls: 'zoomout',
                toggleGroup: 'map'
        });
        this.toolbar.add(new Ext.Toolbar.Separator());

        if (this.navigate) {
            this.toolbar.addControl(this.navigate, {
                    iconCls: 'pan',
                    toggleGroup: 'map'
            });
        }
    },

    getMap: function() {
        if (this.map) return this.map;
        var div = Ext.get(this.panelDivId);
        div.createChild({id: this.mapDivId});

        this.map = new OpenLayers.Map($(this.mapDivId), {
            controls: this.mapControls,
            projection: "EPSG:21781",
            units: "m",
            maxExtent: this.maxExtent,
            restrictedExtent: this.maxExtent,
            resolutions: this.resolutions
        });
        this.map.addLayers(this.mapLayers);
        this.zoomToFullExtent();
        return this.map;
    },

    zoomToFullExtent: function() {
        this.map.zoomToExtent(this.initialExtent, true);
    },

    getPanel: function() {
        if (this.panel) return this.panel;

        var panelItems = [];
        panelItems.push({
            region: 'center',
            contentEl: this.mapDivId,
            layout: 'fit',
            tbar: this.getToolbar()
        });
        if (this.displayLayertree) {
            panelItems.push({
                region: 'east',
                title: 'Layers',
                xtype: 'layertree',
                id: this.panelDivId+'LayerTree',
                map: this.getMap(),
                enableDD: true,
                ascending: false,
                width: 150,
                minSize: 100,
                split: true,
                collapsible: true,
                collapsed: false,
                plugins: [
                    mapfish.widgets.LayerTree.createContextualMenuPlugin(['opacitySlide','remove'])
                ]
            });
        }

        this.panel = new Ext.Panel({
            renderTo: this.panelDivId,
            layout: 'border',
            width: this.panelWidth-5,
            height: this.panelHeight-5,
            border: true,
            items: panelItems
        });

        this.fillToolbar();

        if (this.resizablePanel) {
            var mapResizer = new Ext.Resizable(this.panelDivId, {
                pinned: true,
                minWidth: this.panelMinWidth,
                maxWidth: this.panelMaxWidth,
                minHeight: this.panelMinHeight,
                maxHeight: this.panelMaxHeight,
                width: this.panelWidth,
                height: this.panelHeight
            });
            mapResizer.on('resize', function(resizable, width, height) {
                this.panel.setSize(width-5, height-5);
                this.panel.doLayout();
                this.updateMapSizes();
            }, this);
        }

        return this.panel;
    },

    updateMapSizes: function() {
        this.getMap().updateSize();
    }
});
