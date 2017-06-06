<!--hide this script from non-javascript-enabled browsers


/* Function that swaps images. */

function di20(id, newSrc) {
    var theImage = FWFindImage(document, id, 0);
    if (theImage) {
        theImage.src = newSrc;
    }
}

/* Functions that track and set toggle group button states. */

function FWFindImage(doc, name, j) {
    var theImage = false;
    if (doc.images) {
        theImage = doc.images[name];
    }
    if (theImage) {
        return theImage;
    }
    if (doc.layers) {
        for (j = 0; j < doc.layers.length; j++) {
            theImage = FWFindImage(doc.layers[j].document, name, 0);
            if (theImage) {
                return (theImage);
            }
        }
    }
    return (false);
}

var current = top.location;


window.saveInnerWidth = window.innerWidth;
window.saveInnerHeight = window.innerHeight;

/*
window.onresize = resize;

function resize() {
    if (saveInnerWidth < window.innerWidth || 
        saveInnerWidth > window.innerWidth || 
        saveInnerHeight > window.innerHeight || 
        saveInnerHeight < window.innerHeight ) 
    {
        window.location.replace(current);
    }
}
 window.onLoad=resize 
*/

function popIt(url){
	popwin=window.open(url,"popwin","height=330,width=570,scrollbars=0,status=yes");
}

// DynaDynamic v.1.0 (c) 1999 DynaMind-LLC
var ns, ns4, ns5, ie;
bname = navigator.appName;
ver = navigator.appVersion;
int_ver = parseInt(ver);
if (bname.indexOf("Netscape") >= 0 && int_ver >= 4) ns = 1;
if (bname.indexOf("Netscape") >= 0 && int_ver == 4) ns4 = 1;
else if (bname.indexOf("Netscape") >= 0 && int_ver == 5) ns5 = 1;
if (bname.indexOf("Microsoft Internet Explorer") >=0 && int_ver >= 4) ie = 1;
function openwin (url) {
// get window width and height
if (ns) {
	w = (window.innerWidth/2)-190;
	h = (window.innerHeight/2)-125;
}
else if (ie) {
	w = (document.body.offsetWidth/2)-210;
	h = (document.body.offsetHeight/2)-125;
} 
newwin = window.open(url,'newwin','width=386,height=300,toolbars=0,status=1,resizable=1,location=0,scrollbars=0,top='+h+',left='+w+',screenX='+w+',screenY='+h)
}

function openwinscroll (url) {
// get window width and height
if (ns) {
	w = (window.innerWidth/2)-190;
	h = (window.innerHeight/2)-125;
}
else if (ie) {
	w = (document.body.offsetWidth/2)-210;
	h = (document.body.offsetHeight/2)-125;
} 
newwin = window.open(url,'newwin','width=386,height=300,toolbars=0,status=1,resizable=1,location=0,scrollbars=1,top='+h+',left='+w+',screenX='+w+',screenY='+h)
}
// stop hiding -->



