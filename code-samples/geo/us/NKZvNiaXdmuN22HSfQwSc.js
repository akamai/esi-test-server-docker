if (typeof(SERVER) == 'string')
W+="&server="+escape(SERVER);
if (typeof(ORDER) == 'string')
W+="&order="+escape(ORDER);
if (typeof(CONTENTGROUP) == 'string')
W+="&Group="+escape(CONTENTGROUP);
W+="&browserDate="+escape(new Date());
if (typeof(wtl_Title) == 'string')
{W+="&title="+escape(wtl_Title);}
else
{W+="&title="+escape(document.title);}
if (typeof(wtl_URL) == 'string')
{W+="&url="+escape(wtl_URL);}
else
{W+="&url="+escape(window.document.URL);}
W+="&referrer="+escape(window.document.referrer);
W+="&appname="+escape(navigator.appName);
W+="&appversion="+escape(navigator.appVersion);
W+="&cookieOK="+(navigator.cookieEnabled?"Yes":"No");
W+="&userLanguage="+(navigator.appName=="Netscape"?navigator.language:navigator.userLanguage);
W+="&platform="+navigator.platform;
W+="&bgColor="+escape(document.bgColor);
W+="&javaOK=Yes";
if(typeof(screen)=="object")
{
W+="&screenResolution="+screen.width+"x"+screen.height;
W+="&colorDepth="+screen.colorDepth;
W+="&NSpluginList=";
for( var i=0; i< navigator.plugins.length; i++)
W+=escape(navigator.plugins[i].name)+";";
}
document.write('<IMG BORDER="0" WIDTH="1" HEIGHT="1" SRC="http://statse.webtrendslive.com/S' + wtl_SID + '/button3.asp?'+W+'">');



