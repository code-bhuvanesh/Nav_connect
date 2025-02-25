import React, { useState, useEffect } from "react";
import L from "leaflet";
import "leaflet/dist/leaflet.css";
import locationIcon from "./location.png";
import busIconImage from "./bus_icon.jpg";
import sathyabamaIcon from "./sathyabama_icon.jpg";
import { GeoSearchControl, OpenStreetMapProvider } from "leaflet-geosearch";
import "leaflet-geosearch/dist/geosearch.css";
import "./home_map.css";

function HomeMap() {
  const [map, setMap] = useState(null);
  const [marker, setMarker] = useState(null);
  const [lat, setLat] = useState(12.872597);
  const [lng, setLng] = useState(80.221548);

  useEffect(() => {
    const mapInstance = L.map("homeMap").setView([lat, lng], 15);

    L.tileLayer("https://tile.openstreetmap.org/{z}/{x}/{y}.png", {
      maxZoom: 19,
    }).addTo(mapInstance);

    const customIcon = L.icon({
      iconUrl: sathyabamaIcon,
      iconSize: [64, 64],
      className: "white-background",
      iconAnchor: [16, 32],
    });

    const markerInstance = L.marker([lat, lng], {
      icon: customIcon,
      draggable: true,
    }).addTo(mapInstance);

    const busIcon = L.icon({
      iconUrl: busIconImage, // Replace with actual bus icon URL
      iconSize: [64, 64],
      iconAnchor: [16, 32],
      className: "white-background", // Add this line
    });

    // Sathyabama coordinates
    const sathyabamaLat = 12.872597;
    const sathyabamaLng = 80.221548;

    // Fixed positions within 30km of Sathyabama
    const fixedPositions = [
      [12.892597, 80.241548], // ~3km NE
      [12.852597, 80.201548], // ~3km SW
      [12.912597, 80.221548], // ~4km N
      [12.872597, 80.181548], // ~4km W
      [12.832597, 80.221548], // ~4km S
    ];

    // Add markers at fixed positions
    fixedPositions.forEach((position) => {
      // Calculate distance from Sathyabama
      const distance =
        mapInstance.distance([sathyabamaLat, sathyabamaLng], position) / 1000; // Convert to kilometers

      // Only add marker if within 30km
      if (distance <= 30) {
        L.marker(position, { icon: busIcon })
          .addTo(mapInstance)
          .bindPopup(`Distance from Sathyabama: ${distance.toFixed(2)}km`);
      }
    });

    setMap(mapInstance);
    setMarker(markerInstance);

    // // Add click event to the map to place a marker
    // mapInstance.on("click", function (e) {
    //   const { lat, lng } = e.latlng;
    //   markerInstance.setLatLng([lat, lng]).setIcon(customIcon); // Ensure icon is set
    //   setLat(lat);
    //   setLng(lng);
    // });

    // Add search control to the map
    const provider = new OpenStreetMapProvider();

    mapInstance.on("geosearch/showlocation", (result) => {
      const location = result.location || result; // Handle both structures
      if (
        location &&
        location.lat !== undefined &&
        location.lng !== undefined
      ) {
        const { lat, lng } = location;
        mapInstance.setView([lat, lng], 20);
        setLat(lat);
        setLng(lng);
        setMap(mapInstance);
        setMarker(markerInstance);
      } else {
        console.error("Invalid location data:", result);
      }
    });
    return () => {
      mapInstance.remove();
    };
  }, []);

  return (
    <div className="homemap-container">
      <div id="homeMap" className="homeMap"></div>
    </div>
  );
}

export default HomeMap;
