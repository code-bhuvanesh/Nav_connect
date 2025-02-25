import React, { useState } from "react";
import "./home.css";
import HomeMap from "../HomeMap/HomeMap";
const Home = () => {
  return (
    <>
      {/* <div className="homecontainer">
        <h1 className="title">Bus Management</h1>
        <img className="mapimg" src="images/map.jpg"></img> 
      </div> */}

      <HomeMap />
    </>
  );
};

export default Home;
