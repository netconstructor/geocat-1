package org.fao.xsl.support;

import java.util.Iterator;

import org.jdom.Element;
import org.jdom.filter.Filter;

public class Count implements Requirement
{

    private final int    _expected;
    private final Filter _filter;

    public Count(int expected, Filter filter)
    {
        this._filter = filter;
        _expected = expected;
    }

    @SuppressWarnings("rawtypes")
    public boolean eval(Element e)
    {
        Iterator descendants = e.getDescendants(_filter);
        int count = 0;
        while (descendants.hasNext()) {
            count++;
            descendants.next();
        }

        if(_expected != count) {
            System.err.println("Expected "+_expected+" but got "+count);
        }
        return _expected == count;
    }

    @Override
    public String toString()
    {
        return "count[" + _filter + "] = " + _expected;
    }
}