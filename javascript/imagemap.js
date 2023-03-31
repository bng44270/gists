/*

ImageMap - Create an linked image/image map

Usage:

  HTML:
    <div id="headerspace"></div>

  JS:
    var img = new ImageMap('images/header.jpg','headerimage');
    img.addRectangle(0,0,100,30,'http://www.google.com','_blank');
    img.addCircle(50,50,30,'/about-us');
    img.addPolygon([10,10,20,30,30,20],'http://www.amazon.com','_blank');
    img.addTo('headerspace');

*/
class ImageMap {
  constructor(src,id) {
    this.container = document.createElement('img');
    this.container.id = id + '_img';
    this.container.src = src;
    this.container.setAttribute('usemap','#' + id + '_map');
    this.map = document.createElement('map');
    this.map.name = id + '_map';
  }
  
  addRectangle(x,y,w,h,href,target) {
    var thisarea = document.createElement('area');
    thisarea.setAttribute('shape','rect');
    thisarea.setAttribute('coords',x.toString() + ',' + y.toString() + ',' + (x + w).toString() + ',' + (y + h).toString());
    thisarea.setAttribute('target',(target) ? target : '_self');
    thisarea.href = href;
    this.map.appendChild(thisarea);
  }
  
  addCircle(x,y,c,href,target) {
    var thisarea = document.createElement('area');
    thisarea.setAttribute('shape','circle');
    thisarea.setAttribute('coords',x.toString() + ',' + y.toString() + ',' + c.toString());
    thisarea.setAttribute('target',(target) ? target : '_self');
    thisarea.href = href;
    this.map.appendChild(thisarea);
  }
 
  addPolygon(coords,href,target) {
    var thisarea = document.createElement('area');
    thisarea.setAttribute('shape','poly');
    thisarea.setAttribute('coords',coord.join(','));
    thisarea.setAttribute('target',(target) ? target : '_self');
    thisarea.href = href;
    this.map.appendChild(thisarea);
  }
  
  addTo(id) {
    document.getElementById(id).innerHTML += this.map.outerHTML + this.container.outerHTML;
  }
}