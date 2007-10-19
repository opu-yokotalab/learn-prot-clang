var blnRequestEnabled = true; // error flag
// Base URL
var baseURL = "/~t_nishi/cgi-bin/prot_clang/test_cgi.cgi"; 

function fnc_alert(msg){
    window.alert(msg);
};

function call_cgi(obj) {

    var xmlhttp = null;
    var itemDiv = document.getElementById("item");
    if (itemDiv == null ) {
	//fnc_alert("Error itemDiv null.");
	throw new Error("Can't create itemDiv.");
    }

    if(blnRequestEnabled) {
	try {
	    xmlhttp = createXMLHttp();

	    if (xmlhttp == null) {
		throw new Error("Can't create XMLHttp objet.");
	    }

	    if(obj.name == "reload") {
		    pageURL = baseURL +	"?mode=html";
            } else {
                    pageURL = baseURL + "?mode=new";
            }

	    xmlhttp.open('GET', pageURL);
	    
	    xmlhttp.onreadystatechange = function() {
		if(xmlhttp.readyState == 4) {
		    if(xmlhttp.status == 200) {
			if(xmlhttp.responseText != "") {
			    //fnc_alert(xmlhttp.responseText);
			    itemDiv.innerHTML = ""; // clearü
			    itemDiv.innerHTML = xmlhttp.responseText;
			}
		    } else {
			throw new Error("Server sattus error.\n" + xmlhttp.status);
		    }
		}
	    };
	    xmlhttp.send(null);
	} catch (oException) {
	    //blnRequestEnabled = false;
	    //fnc_alert(oException.description);
	}
    }
    
};

// XMLHttps
function createXMLHttp()
{
    try {
	return new ActiveXObject ("Microsoft.XMLHTTP");
    }catch(e){
	try {
	    return new XMLHttpRequest();
	}catch(e) {
	    return null;
	}
    }
    return null;
};