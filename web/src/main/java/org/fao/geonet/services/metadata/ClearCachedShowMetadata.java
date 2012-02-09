package org.fao.geonet.services.metadata;

import org.fao.geonet.constants.Edit;
import org.fao.geonet.constants.Params;
import org.fao.geonet.services.Utils;
import org.jdom.Element;

import jeeves.interfaces.Service;
import jeeves.server.ServiceConfig;
import jeeves.server.context.ServiceContext;

/**
 * Clear the context of a cached metadata as placed by Show
 * @author jeichar
 *
 */
public class ClearCachedShowMetadata implements Service {

    public void init( String appPath, ServiceConfig params ) throws Exception {
    }

    public Element exec( Element params, ServiceContext context ) throws Exception {
        Element info = params.getChild(Edit.RootChild.INFO, Edit.NAMESPACE);
        String mdId;
        if(info == null) {
            mdId = Utils.getIdentifierFromParameters(params, context);
        } else {
            mdId = info.getChildText(Params.ID);
        }
        Show.unCache(context.getUserSession(), mdId);
        return new Element("ok");
    }

}
