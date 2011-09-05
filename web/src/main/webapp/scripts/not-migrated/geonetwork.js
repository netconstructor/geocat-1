// VARIABLE DECLARATIONS
// var DEFAULT_VISIBILITY_ARR = ['no', 'all', 'intranet'];
// Note (just@justobjects.nl 090517): allow only 'all' and 'no' visibility for Swiss Topo
var DEFAULT_VISIBILITY_ARR = ['no', 'all'];

function init()
{
}

// Read a cookie
function get_cookie(cookie_name)
{
	var results = document.cookie.match(cookie_name + '=(.*?)(;|$)');

	if (results)
		return ( unescape(results[1]) );
	else
		return null;
}

// New browser windows
function popNew(a)
{
	msgWindow = window.open(a, "displayWindow", "location=no, toolbar=no, directories=no, status=no, menubar=no, scrollbars=yes, resizable=yes, width=800, height=600")
	msgWindow.focus()
}

function openPage(what, type)
{
	msgWindow = window.open(what, type, "location=yes, toolbar=yes, directories=yes, status=yes, menubar=yes, scrollbars=yes, resizable=yes, width=800, height=600")
	msgWindow.focus()
}

function popFeedback(a)
{
	msgWindow = window.open(a, "feedbackWindow", "location=no, toolbar=no, directories=no, status=no, menubar=no, scrollbars=yes, resizable=yes, width=800, height=600")
	msgWindow.focus()
}

function popWindow(a)
{
	msgWindow = window.open(a, "popWindow", "location=no, toolbar=no, directories=no, status=no, menubar=no, scrollbars=yes, resizable=yes, width=800, height=600")
	msgWindow.focus()
}

function popInterMap(a)
{
	msgWindow = window.open(a, "InterMap", "location=no, toolbar=no, directories=no, status=no, menubar=no, scrollbars=yes, resizable=yes, width=800, height=600")
	msgWindow.focus()
}

// Forms
function goSubmit(form_name)
{
	document.forms[form_name].submit();
}

function goReset(form_name)
{
	document.forms[form_name].reset();
}

function entSub(form_name)
{
	if (window.event && window.event.keyCode == 13)
		goSubmit(form_name);
	else
		return true;
}

// Navigation
function goBack()
{
	history.back();
}

function processCancel()
{
	document.close();
}

function load(url)
{
	document.location.href = url;
}

function doConfirm(url, message)
{
	if (confirm(message))
	{
		load(url);
		return true;
	}
	return false;
}

function massiveDelete(message)
{
	if (!confirm(message))
		return;

	document.location.href = Env.locService + '/metadata.massiveDelete';
}

// Other actions javascript functions
function oActionsInit(name, id)
{
	if (id === undefined)
	{
		id = "";
	}
	$(name + 'Ele' + id).style.width = $(name + id).getWidth();
	$(name + 'Ele' + id).style.top = $(name + id).positionedOffset().top + $(name + id).getHeight();
	$(name + 'Ele' + id).style.left = $(name + id).positionedOffset().left;
}

function oActions(name, id)
{
	if (id === undefined)
	{
		id = "";
	}
	if (!$(name + 'Ele' + id).style.top)
		oActionsInit(name, id);

	if ($(name + 'Ele' + id).style.display == 'none')
	{
		$(name + 'Ele' + id).style.display = 'block';
		$(name + 'Img' + id).src = off;
	} else
	{
		$(name + 'Ele' + id).style.display = 'none';
		$(name + 'Img' + id).src = on;
	}

}

function actionOnSelect(msg)
{
	if ($('nbselected').innerHTML == 0 && $('oAcOsEle').style.display == 'none')
	{
		a(msg);
	} else
		oActions('oAcOs');
}

function toggleVisibilityEdit()
{
	// toggles visibility of element visibility edit icons
	$$('a.elementHiding').invoke('toggle');
}

function changeVisibility(ref, val)
{
	if (!ref)
	{
		alert('No ref id for this element, (sorry, this needs to be fixed)');
		return;
	}

	// Ref is a number: get input element
	var elVisibility = $('hide_' + ref);
	if (!elVisibility)
	{
		return;
	}

	// Determine new visibility
	var visibility;
	if (val)
	{
		// Value was passed (happens for recursive calls from parent)
		visibility = val;
	} else
	{
		// Visibility is determined by rotating visibility values

		// Default rotation of visibility values
		var visibilityArr = DEFAULT_VISIBILITY_ARR;

		// Restrict rotation on parent visibility value
		// i.e. the child can never be less restrictive
		var parents = $w(elVisibility.className);
		if (parents && parents.length > 0)
		{
			var parentRef = parents[0].sub('parent_', '', 1);
			if (parentRef)
			{
				var parentElm = $('hide_' + parentRef);
				if (parentElm)
				{
					var parentVal = parentElm.value;
					switch (parentVal)
					{
						case 'all':
							visibilityArr = ['all'];
							break;
// Note (just@justobjects.nl 090517): allow only 'all' and 'no' visibility for Swiss Topo
//						case 'intranet':
//							visibilityArr = ['intranet', 'all'];
//							break;
						case 'no':
							// Use default rotation
							break;
					}
				}
			}
		}

		// rotate visibility
		var i=0;
		for (; i < visibilityArr.length; i++) {
			if (visibilityArr[i] == elVisibility.value) {
				break;
			}
		}

		// Determine new visibility by rotation
		visibility = visibilityArr[(i+1) % visibilityArr.length];
	}

	// Set in input form element
	elVisibility.value = visibility;

	// Change icon
	setVisibilityIcon(ref, visibility);

	// Now also propagate visibility to all descendents recursively
	var children = $$('input.parent_' + ref);
	children.each(function(inputElm)
	{
		changeVisibility(inputElm.id.sub('hide_', '', 1), visibility);
	});
}

function setVisibilityIcon(ref, visibility)
{
	var icon = $(ref + '_visibility_icon');
	if (!icon)
	{
		return;
	}
	var baseURL = Env.url + '/images/';

	switch (visibility)
			{
		case 'all':
			icon.setAttribute("src", baseURL + 'red-ball.gif');
			break;
// Note (just@justobjects.nl 090517): allow only 'all' and 'no' visibility for Swiss Topo
//		case 'intranet':
//			icon.setAttribute("src", baseURL + 'yellow-ball.gif');
//			break;
		case 'no':
			icon.setAttribute("src", baseURL + 'green-ball.gif');
			break;
	}
}


function permlink(url) {
    Ext.MessageBox.show({
        title: translate("permlink"),
        msg: '<a href = "'+url+'" target="_newtab">'+url+'</a>',
        animEl: 'mb7'
    });

}