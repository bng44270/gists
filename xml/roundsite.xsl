<?xml version="1.0" encoding="UTF-8"?>
<!--

Required XML document

site
|- title - Page Title
|- theme
    |- bg - theme nav background color
    |- fg - theme nav foreground color
    |- bghover - theme nav hover background color
    |- fghover - theme nav hover foreground color
    |- css - custom CSS for document
    |- js - custom JavaScript for page (must be enclosed in CDATA tags)
    |- jsinc - JavaScript includes 
        |- url - URL of JavaScript file to include (many <url> tags may exist)
    |- layout - layout of navigation bar ("top" or "side")
|- header - page header content
|- footer - page footer content
|- homepage
    |- section - content of homepage
|- page - pages that will show up in navigation bar (many <page> tags may exist)
    |- section - content of page
    |- label - DOM ID of page (without "#")
    |- title - title of page
|- hiddenpage - pages that will NOT show up in navigation bar (many <hiddenpage> tags may exist)
    |- section - content of page
    |- label - DOM ID of page (without "#")
    |- title - title of page

-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output />
<xsl:template match="/">
<xsl:for-each select="site/theme">
  <xsl:if test="((layout!='top') and (layout!='side'))">
    <xsl:message terminate="yes"><html><head><title>Error</title></head><body>Unknown layout (<xsl:value-of select="layout" />)</body></html></xsl:message>
  </xsl:if>
</xsl:for-each>
<html>
<head>
  <title><xsl:value-of select="site/title" /></title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <xsl:for-each select="site/theme/jsinc/url">
        <script type="text/javascript">
            <xsl:attribute name="src">
                <xsl:value-of select="."/>
            </xsl:attribute>
        </script>
    </xsl:for-each>	
    <script type="text/javascript"><xsl:value-of select="site/theme/js" /></script>
    <script type="text/javascript"><![CDATA[
	  function hideElements(selector) {
	    document.querySelectorAll(selector).forEach(function(x) {
		  x.style.display = 'none';
		});
      }
	  
	  function showElement(selector) {
	    document.querySelector(selector).style.display = 'block';
	  }
	  
	  function resetActivePage(selector) {
	    document.querySelectorAll(selector).forEach(function(x) {
	      x.removeAttribute('class');
		  x.parentElement.removeAttribute('class');
		});
	  }
	  
	  function setActivePage(selector) {
		document.querySelector(selector).setAttribute('class','active');
  		document.querySelector(selector).parentElement.setAttribute('class','active');
      }
	  
	  function toggleLeftNav() {
	    var url = location.hash;
		
		var toggle = document.querySelector('nav');
	    if (toggle.style.display == 'none') {
			document.querySelector('.togglenav').innerHTML = '&lt;&lt;';
			history.pushState({}, "", url);
			toggle.style.display = 'block';			
		}
		else {
			document.querySelector('.togglenav').innerHTML = '&gt;&gt;';
			history.pushState({}, "", url);
			toggle.style.display = 'none';
		}

		scrollToTop();
	  }

	  function scrollToTop() {
        window.document.body.scroll({
		  top: 0,
		  left: 0,
		  behavior: 'smooth'
		});
      }
	
	  function switchNav() {
        var width = parseInt(window.getComputedStyle(document.querySelector('content')).width.replace(/px$/,''));
        if (width < 640) {
          document.querySelector('div.navcontainer').style.display = 'none';
          document.querySelector('topnav').style.display = 'block';
        }
        else {
          document.querySelector('div.navcontainer').style.display = 'block';
          document.querySelector('topnav').style.display = 'none';
        }

		
      }
	]]></script>
	<script type="text/javascript">
	  <xsl:for-each select="site/theme"><xsl:if test="layout='side'">
	  window.onresize = switchNav;
	  </xsl:if></xsl:for-each>
	  
	  window.onload = function() {
	    //Configure links
		document.querySelectorAll('nav ul li a').forEach(function(x) {
		  x.onclick = function() {
		    hideElements('article.homepage');
			hideElements('article.page');
			resetActivePage('nav ul li a');
			resetActivePage('topnav ul li a');
			resetActivePage('a#homepage');
			showElement('article' + x.hash);
			setActivePage('a' + x.hash);
			setActivePage('a#top' + x.id);
			document.title = x.innerText;
			history.pushState({}, "", x.hash);
			scrollToTop();

			return false;
		  };
		 
		  x.parentElement.onclick = function() {
		    hideElements('article.homepage');
			hideElements('article.page');
			resetActivePage('nav ul li a');
			resetActivePage('topnav ul li a');
			resetActivePage('a#homepage');
			showElement('article' + x.hash);
			setActivePage('a' + x.hash);
			setActivePage('a#top' + x.id);
			document.title = x.innerText;
			history.pushState({}, "", x.hash);
			scrollToTop();

			return false;
		  };
		  
		});
		
		var homeLink = function() {
	      hideElements('article.page');
		  hideElements('article.homepage');
		  resetActivePage('nav ul li a');
          resetActivePage('topnav ul li a');
		  resetActivePage('a#homepage');
		  showElement('article.homepage');
		  setActivePage('a#homepage');
		  setActivePage('a#tophomepage');
		  document.title = 'Home';
		  history.pushState({}, "",'#homepage');
		  scrollToTop();

		  return false;
		};

		

		document.querySelector('a#homepage').onclick = homeLink;
		document.querySelector('a#homepage').parentElement.onclick = homeLink;		
		
		//Load page on load
		if (location.hash.length > 1) {
		  document.querySelector('a' + location.hash).click();
		  document.querySelector('a' + location.hash).blur();
		}
		else {
		  document.querySelector('a#homepage').click();
		  document.querySelector('a#homepage').blur();
		}
		<xsl:for-each select="site/theme"><xsl:if test="layout='side'">
		switchNav();
		</xsl:if></xsl:for-each>
	  };
    </script>
    <style>
      div.container {
		border-radius: 25px;
        width: 90%;
        border: 1px solid gray;
        margin: auto;
      }

      div header {
        border-top-left-radius: 25px;
        border-top-right-radius: 25px;
      }

      div footer {
        border-bottom-left-radius: 25px;
        border-bottom-right-radius: 25px;
      }

      div header, div footer {
        padding: 1em;
        background-color: <xsl:value-of select="site/theme/bg" />;
		color: <xsl:value-of select="site/theme/fg" />;  
	    clear: left;
        text-align: center;
      }
      
      footer a {
      	color: white;
        text-decoration: none;      
      }
      
      footer span {
        display: inline-block;
        width: 20px;
      }

      footer p {
        font-size: 10pt;
      }

      belowpage {
        padding-top: 30px;
        display: flex;
        margin:auto;
        width: 300px;
      }

      belowpage div {
        text-align: center;
        width: 100px;
      }
      
      belowpage div a {
        text-decoration: none;
        color: #000000;
      }

      belowpage div.left {
        float: left;
      }

      belowpage div.right {
        float: right;
      }

	  div.navcontainer {
		float: left;
		max-width: 20%;
		margin: 0px;
        padding: 0px;
	  }
	  
	  <xsl:for-each select="site/theme"><xsl:if test="layout='top'">
	  div.navcontainer {
		display:none;
	  }
	  </xsl:if></xsl:for-each>

      nav {
        padding-top: 15px;
        top:0px;
        
      }

      nav ul {
        list-style-type: none;
        padding: 0px;
		padding: 10px;
      }
      
      nav ul li {
		background-color: <xsl:value-of select="site/theme/bg" />;
		border-top: 15px solid <xsl:value-of select="site/theme/bg" />;
		border-bottom: 15px solid <xsl:value-of select="site/theme/bg" />;
		border-right: 30px solid <xsl:value-of select="site/theme/bg" />;
		border-left: 30px solid <xsl:value-of select="site/theme/bg" />;
		color: <xsl:value-of select="site/theme/fg" />;
        
      }
   
      nav ul li:hover, nav ul li.active {
        background-color: <xsl:value-of select="site/theme/bghover" />;
		border-top: 15px solid <xsl:value-of select="site/theme/bghover" />;
		border-bottom: 15px solid <xsl:value-of select="site/theme/bghover" />;
		border-right: 30px solid <xsl:value-of select="site/theme/bghover" />;
		border-left: 30px solid <xsl:value-of select="site/theme/bghover" />;
		cursor:pointer;
      }
      
	  
	  
      nav ul li a {
        color: <xsl:value-of select="site/theme/fg" />;
        text-decoration: none;
      }
	  
	  nav ul li a:hover {
		color: <xsl:value-of select="site/theme/fghover" />;
        text-decoration: none;
	  }
      
      nav ul a:hover {
        color: #ffffff;
      }
	  
	  .togglenav {
		float: left;
		text-decoration: none;
        margin: 0;
        padding: 1em;
	  }

	  topnav {
        text-align:center;
		<xsl:for-each select="site/theme"><xsl:if test="layout='side'">
		display: none;
		</xsl:if></xsl:for-each>
      }

      topnav ul {
        list-style-type: none;
        padding: 0;
        margin: 0;
        overflow: hidden;
        background-color: <xsl:value-of select="site/theme/bg" />;
		color: <xsl:value-of select="site/theme/fg" />;
      }

      topnav ul li {
        float:left;
      }

      topnav ul li a {
        display: block;
        color: white;
        text-align: center;
        padding: 14px 16px;
        text-decoration: none;
      }

      topnav ul li a:hover, topnav ul li a.active {
        background-color: <xsl:value-of select="site/theme/bghover" />;
		color: <xsl:value-of select="site/theme/fghover" />;
      }

      
	  
      content {
        float: left;
        left: 20%;
        border-left: 0px solid gray;
        padding: 1em;
        overflow: hidden;
        width:80%;
      }
      
      article {
        display: none;
      }
	  
	  <xsl:value-of select="site/theme/css" />
    </style>
  </head>
  <body>
    <div class="container">
      <header>
        <h1 id="pageheader"><xsl:value-of select="site/title" /></h1>
      </header>
	  <div class="navcontainer">
	  <a href="#" onClick="toggleLeftNav();return false;" class="togglenav">&lt;&lt;</a>
      <nav>
        <ul>
          <li><a href="#homepage" id="homepage" class="homenav">Home</a></li>
          <xsl:for-each select="site/page">
            <li><a>
              <xsl:attribute name="href">
                <xsl:value-of select="concat('#',label)"/>
              </xsl:attribute>
              <xsl:attribute name="id">
                <xsl:value-of select="label"/>
              </xsl:attribute>
              <xsl:attribute name="class">navitem</xsl:attribute>
              <xsl:value-of select="title" />
            </a></li>
          </xsl:for-each>
        </ul>
		<ul style="display:none">
        <xsl:for-each select="site/hiddenpage">
          <li><a>
            <xsl:attribute name="href">
              <xsl:value-of select="concat('#',label)"/>
            </xsl:attribute>
            <xsl:attribute name="style">display:none;</xsl:attribute>
            <xsl:attribute name="id">
              <xsl:value-of select="label"/>
            </xsl:attribute>
            <xsl:attribute name="class">navitem</xsl:attribute>
            <xsl:value-of select="title" />
          </a></li>
        </xsl:for-each>
		</ul>
      </nav>
	  </div>
	  <topnav>
	    <ul>
		  <li><a id="tophomepage" onClick="document.querySelector('#homepage').click();" href="#homepage">Home</a></li>
          <xsl:for-each select="site/page">
            <li><a>
              <xsl:attribute name="href">
                <xsl:value-of select="concat('#',label)"/>
              </xsl:attribute>
			  <xsl:attribute name="id">
			    <xsl:value-of select="concat('top',label)"/>
			  </xsl:attribute>
			  <xsl:attribute name="onClick">
			    document.querySelector('#<xsl:value-of select="label" />').click();
			  </xsl:attribute>
              <xsl:value-of select="title" />
            </a></li>
          </xsl:for-each>
		</ul>
      </topnav>
      <content>
        <xsl:for-each select="site/homepage">
          <article>
            <xsl:attribute name="class">homepage</xsl:attribute>
            <xsl:copy-of select="section" />
          </article>
        </xsl:for-each>
        <xsl:for-each select="site/page">
          <article>
            <xsl:attribute name="class">page</xsl:attribute>
            <xsl:attribute name="id"><xsl:value-of select="label" /></xsl:attribute>
            <xsl:copy-of select="section" />
          </article>
        </xsl:for-each>
        <xsl:for-each select="site/hiddenpage">
          <article>
            <xsl:attribute name="class">page</xsl:attribute>
            <xsl:attribute name="id"><xsl:value-of select="label" /></xsl:attribute>
            <xsl:copy-of select="section" />
          </article>
        </xsl:for-each>
      </content>
      <xsl:copy-of select="site/footer" />
    </div>
  </body>
</html>
</xsl:template>
</xsl:stylesheet>