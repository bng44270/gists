/*
	NOTE:  map = L.map(...)
*/
//Track unique marker ID
map.options.nextMarkerId = 0;
//Is a marker currently in the process of being moved?
map.options.isMovingMarker = false;
//What marker is currently in the process of being moved?
map.options.markerMove = -1;

//Render popup text
function createMarker(loc,text) {
	thisId = map.options.nextMarkerId++;

	var deleteLink = document.createElement('a');
	deleteLink.innerText = 'Delete';
	deleteLink.setAttribute('style','cursor:pointer;');
	deleteLink.setAttribute('onClick','javascript:deleteMarker(' + thisId + ');');

	var editLink = document.createElement('a');
	editLink.innerText = 'Edit';
	editLink.setAttribute('style','cursor:pointer;');
	editLink.setAttribute('onClick','javascript:editMarker(' + thisId + ');');
	
	var moveLink = document.createElement('a');
	moveLink.innerText = 'Move';
	moveLink.setAttribute('style','cursor:pointer;');
	moveLink.setAttribute('onClick','javascript:moveMarker(' + thisId + ');');

	L.marker(loc,{
		info : text,
		id : thisId
	}).addTo(map).bindPopup(text + '<br/>[' + editLink.outerHTML + '] [' + moveLink.outerHTML + '] [' + deleteLink.outerHTML  + ']');

	
}

//Move marker where options.id = id
function moveMarker(id,newLatLng) {
	if (!map.options.isMovingMarker && !newLatLng) {
		map.closePopup();
		map.options.isMovingMarker = true;
		map.options.markerMove = id;
	}
	else {
		var layerIds = Object.keys(map._layers);
		for (var i = 0; i < layerIds.length; i++) {
			if (map._layers[layerIds[i]].options.id == id) {
				var text = map._layers[layerIds[i]].options.info;
				deleteMarker(id);
				createMarker(newLatLng,text);
				map.options.isMovingMarker = false;
				map.options.markerMove = -1;
				break;
			}
		}
	}
}

//Delete marker where options.id = id
function deleteMarker(id) {
	var layerIds = Object.keys(map._layers);
	for (var i = 0; i < layerIds.length; i++) {
		if (map._layers[layerIds[i]].options.id == id) {
			map.removeLayer(map._layers[layerIds[i]]);
			break;
		}
	}
}

//Edit marker where options.id = id
function editMarker(id) {
	map.closePopup();
	var layerIds = Object.keys(map._layers);
	for (var i = 0; i < layerIds.length; i++) {
		if (map._layers[layerIds[i]].options.id == id) {
			var text = map._layers[layerIds[i]].options.info;
			var latlng = map._layers[layerIds[i]]._latlng;
			var newText = prompt('Enter item info',text);
			
			if (newText) {
				deleteMarker(id);
				createMarker(latlng,newText);
			}
			
			break;
		}
	}
}

//Add marker layer on map click
map.on('click',function(e) {
	if (map.options.isMovingMarker) {
		moveMarker(map.options.markerMove,e.latlng);
	}
	else {
		var info = prompt("Enter point info");
		if (info) {
			createMarker(e.latlng,info);
		}
	}
});