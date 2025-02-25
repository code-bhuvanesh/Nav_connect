import React, { useState, useEffect } from "react";
import L from "leaflet";
import "leaflet/dist/leaflet.css";
import locationIcon from "./location.png";
import { GeoSearchControl, OpenStreetMapProvider } from 'leaflet-geosearch';
import 'leaflet-geosearch/dist/geosearch.css';

function MapContainer({ onSelectPoint }) {
  const [map, setMap] = useState(null);
  const [marker, setMarker] = useState(null);
  const [lat, setLat] = useState(12.872597);
  const [lng, setLng] = useState(80.221548);

  useEffect(() => {
    const mapInstance = L.map("map").setView([lat, lng], 15);

    L.tileLayer("https://tile.openstreetmap.org/{z}/{x}/{y}.png", {
      maxZoom: 19,
    }).addTo(mapInstance);

    const customIcon = L.icon({
      iconUrl: locationIcon,
      iconSize: [32, 32],
      iconAnchor: [16, 32],
    });

    const markerInstance = L.marker([lat, lng], {
      icon: customIcon,
      draggable: true,
    }).addTo(mapInstance);

    // Update state when marker is dragged
    markerInstance.on("dragend", function (e) {
      const position = markerInstance.getLatLng();
      setLat(position.lat);
      setLng(position.lng);
      onSelectPoint(position.lat, position.lng);
    });

    setMap(mapInstance);
    setMarker(markerInstance);

    // Add click event to the map to place a marker
    mapInstance.on("click", function (e) {
      const { lat, lng } = e.latlng;
      markerInstance.setLatLng([lat, lng]).setIcon(customIcon); // Ensure icon is set
      setLat(lat);
      setLng(lng);
      onSelectPoint(lat, lng);
    });

    // Add search control to the map
    const provider = new OpenStreetMapProvider();

    const searchControl = new GeoSearchControl({
      provider,
      style: 'bar',
      autoClose: true,
      keepResult: true,
      showMarker: false,
      retainZoomLevel: true,
    });

    mapInstance.addControl(searchControl);
    mapInstance.on('geosearch/showlocation', (result) => {
      const location = result.location || result; // Handle both structures
      if (location && location.lat !== undefined && location.lng !== undefined) {
        const { lat, lng } = location;
        mapInstance.setView([lat, lng],20);
        setLat(lat);
        setLng(lng);
        onSelectPoint(lat, lng);
        setMap(mapInstance);
    setMarker(markerInstance);
      } else {
        console.error("Invalid location data:", result);
      }
    });
    return () => {
      mapInstance.remove();
    };
  }, [onSelectPoint]);

  return (
    <div className="map-container">
      <div id="map" className="map"></div>
    </div>
  );
}

export default MapContainer;
