/*

DOMObject

Exposes DOM Structure including HTML Tag w/ DOM id, HTML Attributes, CSS Settings, innerText

Usage:

    var dom = new DOMObject();

    //Get full DOM Structure
    var root = dom.getRoot();

    //Get structure inside <BODY>
    var body = dom.getRootByTag('body');

    //Get structure inside tag where id="main"
    var main = dom.getRootById('main');

Element Object:

    {
        tag: '<TAG>',
        id: '<DOM-id>',
        attrs: [<ARRAY-OF-HTML-ATTRIBUTES>],
        style: [<ARRAY-OF-CSS-ATTRIBUTES>],
        text: '<TEXT-INSIDE-TAG>',
        children: [<ARRAY-OF-CHILD-ELEMENT-OBJECTS>]
    }

*/
class DOMObject {
    constructor() {
       
    }

    getEmptyElement() {
        return {
            tag:'',
            id:'',
            attrs:[],
            style:[],
            text:'',
            children:[]
        };
    }

    getChildren(elem) {
        var returnAr = [];

        for (var i = 0; i < elem.children.length; i++) {
            var thisItem = this.getEmptyElement();
            thisItem.tag = ('tagName' in elem.children[i]) ? elem.children[i].tagName : '';
            thisItem.id = ('id' in elem.children[i]) ? elem.children[i].id : '';
            
            if ('attributes' in elem.children[i]) {
                for (var j = 0; j < elem.children[i].attributes.length; j++) {
                    thisItem.attrs[elem.children[i].attributes[j].nodeName] = elem.children[i].attributes[j].nodeValue;
                }   
            }

            var styleObj = window.getComputedStyle(elem.children[i],null);
            for (var j = 0; j < styleObj.length; j++) {
                thisItem.style[styleObj[j]] = styleObj[styleObj[j]];
            }

            if ('children' in elem.children[i]) {
                thisItem.children = this.getChildren(elem.children[i]);
            }    
            returnAr.push(thisItem);    
        }

        return (returnAr.length == 1) ? returnAr[0] : returnAr;
    }

    getRoot() {
        return this.getChildren(document);
    }
    
    getChildrenByTag(tag) {
        var tags = document.getElementsByTagName(tag);
        if (tags.length > 1) throw 'TooManyElementsException';
        return this.getChildren(tags[0]);
    }

    getChildrenById(id) {
        return this.getChildren(document.getElementById(id));
    }
}